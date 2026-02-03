from __future__ import annotations

import argparse
import pathlib
import struct
import sys
import time
from dataclasses import dataclass

from .protocol import Frame, crc32_ieee, try_unpack_frame
from .transport_serial import SerialConfig, SerialTransport
from .sim_device import SimTransport

try:
    from serial.tools import list_ports
except Exception:  # pragma: no cover
    list_ports = None


MSG_HELLO = 0x01
MSG_START = 0x02
MSG_ERASE = 0x03
MSG_DATA = 0x04
MSG_FINISH = 0x05
MSG_QUERY = 0x06

MSG_HELLO_RSP = 0x81
MSG_ACK = 0x82
MSG_PROGRESS = 0x83
MSG_ERROR = 0x84


STATUS_OK = 0
STATUS_BUSY = 1
STATUS_BAD_CRC = 2
STATUS_BAD_STATE = 3
STATUS_FLASH_ERR = 4


@dataclass
class DeviceCaps:
    flash_id: bytes
    page_size: int
    sector_size: int
    max_payload: int


def _send_and_wait_ack(tr: SerialTransport, frame: Frame, ack_type: int, timeout_s: float, retries: int) -> None:
    for _ in range(retries + 1):
        tr.write(frame.pack())
        raw = tr.read_frame(deadline_s=timeout_s)
        if raw is None:
            continue
        rsp = try_unpack_frame(raw)
        if rsp is None:
            continue
        if rsp.msg_type != MSG_ACK or rsp.seq != frame.seq:
            continue
        if len(rsp.payload) < 4:
            continue
        t, status, _detail = struct.unpack(">BBH", rsp.payload[:4])
        if t != (ack_type & 0xFF):
            continue
        if status == STATUS_OK:
            return
        if status in (STATUS_BUSY, STATUS_BAD_CRC):
            continue
        raise RuntimeError(f"Device refused: ack_type=0x{t:02X} status={status}")
    raise TimeoutError(f"ACK timeout: type=0x{ack_type:02X} seq={frame.seq}")


def hello(tr: SerialTransport, seq: int, timeout_s: float = 0.5, retries: int = 5) -> DeviceCaps:
    for _ in range(retries + 1):
        tr.write(Frame(MSG_HELLO, seq, b"").pack())
        raw = tr.read_frame(deadline_s=timeout_s)
        if raw is None:
            continue
        rsp = try_unpack_frame(raw)
        if rsp is None or rsp.msg_type != MSG_HELLO_RSP:
            continue
        if len(rsp.payload) < 3 + 2 + 4 + 2:
            continue
        flash_id = rsp.payload[0:3]
        page_size, = struct.unpack(">H", rsp.payload[3:5])
        sector_size, = struct.unpack(">I", rsp.payload[5:9])
        max_payload, = struct.unpack(">H", rsp.payload[9:11])
        return DeviceCaps(flash_id=flash_id, page_size=page_size, sector_size=sector_size, max_payload=max_payload)
    raise TimeoutError("HELLO timeout")


def query_progress(tr: SerialTransport, seq: int, timeout_s: float = 0.3) -> tuple[int, int]:
    tr.write(Frame(MSG_QUERY, seq, b"").pack())
    raw = tr.read_frame(deadline_s=timeout_s)
    if raw is None:
        raise TimeoutError("QUERY timeout")
    rsp = try_unpack_frame(raw)
    if rsp is None or rsp.msg_type != MSG_PROGRESS:
        raise RuntimeError("Bad PROGRESS")
    if len(rsp.payload) < 8:
        raise RuntimeError("Bad PROGRESS payload")
    written, crc = struct.unpack(">II", rsp.payload[:8])
    return written, crc


def upgrade_bytes(tr: SerialTransport | SimTransport, image: bytes, base_addr: int, chunk: int, timeout_s: float, retries: int) -> None:
    image_crc = crc32_ieee(image)
    seq = 1
    caps = hello(tr, seq)
    seq += 1
    max_chunk = min(chunk, max(32, caps.max_payload - (4 + 2)))
    max_chunk = min(max_chunk, 1024)
    page_size = caps.page_size or 256
    sector_size = caps.sector_size or 4096

    start_payload = struct.pack(">IIIH", base_addr & 0xFFFFFFFF, len(image), image_crc, page_size)
    _send_and_wait_ack(tr, Frame(MSG_START, seq, start_payload), MSG_START, timeout_s, retries)
    seq += 1

    erase_payload = struct.pack(">III", base_addr & 0xFFFFFFFF, len(image), sector_size)
    _send_and_wait_ack(tr, Frame(MSG_ERASE, seq, erase_payload), MSG_ERASE, timeout_s * 5, retries)
    seq += 1

    offset = 0
    last_print = 0.0
    while offset < len(image):
        block = image[offset : offset + max_chunk]
        data_payload = struct.pack(">IH", offset, len(block)) + block
        _send_and_wait_ack(tr, Frame(MSG_DATA, seq, data_payload), MSG_DATA, timeout_s, retries)
        seq = (seq + 1) & 0xFFFF
        offset += len(block)

        now = time.time()
        if now - last_print > 0.5:
            written, running_crc = query_progress(tr, seq)
            seq = (seq + 1) & 0xFFFF
            pct = 100.0 * min(written, len(image)) / max(1, len(image))
            sys.stdout.write(f"\r{pct:6.2f}%  written={written} crc=0x{running_crc:08X}")
            sys.stdout.flush()
            last_print = now

    _send_and_wait_ack(tr, Frame(MSG_FINISH, seq, b""), MSG_FINISH, timeout_s * 5, retries)
    seq = (seq + 1) & 0xFFFF

    written, running_crc = query_progress(tr, seq)
    sys.stdout.write("\n")
    if written != len(image):
        raise RuntimeError(f"Size mismatch: written={written} expected={len(image)}")
    if running_crc != image_crc:
        raise RuntimeError(f"CRC mismatch: device=0x{running_crc:08X} host=0x{image_crc:08X}")
    print("Upgrade OK")


def upgrade(port: str, baud: int, bin_path: str, base_addr: int, chunk: int, timeout_s: float, retries: int) -> None:
    image = open(bin_path, "rb").read()
    tr = SerialTransport(SerialConfig(port=port, baud=baud, timeout_s=timeout_s))
    try:
        upgrade_bytes(tr, image, base_addr, chunk, timeout_s, retries)
    finally:
        tr.close()


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--port", default="auto", help="串口号，例如 COM5；可填 auto 自动选择")
    ap.add_argument("--port-like", help="按端口描述/硬件ID模糊匹配，例如 'CH340' 或 'VID:PID=1A86:7523'")
    ap.add_argument("--list-ports", action="store_true", help="列出可用串口并退出")
    ap.add_argument("--baud", type=int, default=921600)
    ap.add_argument("--fw", dest="fw_path", help="固件文件(.bin)或包含bin的目录")
    ap.add_argument("--bin", dest="bin_path", help="兼容参数：固件bin路径")
    ap.add_argument("--fw-name", help="当 --fw 为目录时，指定要使用的bin文件名（精确或包含匹配）")
    ap.add_argument("--base-addr", type=lambda s: int(s, 0), default=0)
    ap.add_argument("--chunk", type=int, default=256)
    ap.add_argument("--timeout", type=float, default=0.2)
    ap.add_argument("--retries", type=int, default=8)
    args = ap.parse_args(argv)

    def _iter_ports():
        if list_ports is None:
            return []
        return list(list_ports.comports())

    def _print_ports() -> None:
        ports = _iter_ports()
        if not ports:
            print("No serial ports found")
            return
        for p in ports:
            desc = getattr(p, "description", "")
            hwid = getattr(p, "hwid", "")
            print(f"{p.device}\t{desc}\t{hwid}")

    if args.list_ports:
        _print_ports()
        return 0

    port = str(args.port or "auto")
    if port.isdigit():
        port = f"COM{port}"
    if port.lower() == "auto":
        ports = _iter_ports()
        if args.port_like:
            key = args.port_like.lower()
            ports = [
                p
                for p in ports
                if key in (getattr(p, "device", "").lower())
                or key in (getattr(p, "description", "").lower())
                or key in (getattr(p, "hwid", "").lower())
            ]
        if len(ports) == 1:
            port = ports[0].device
        else:
            _print_ports()
            raise RuntimeError("Port not uniquely resolved; use --port COMx or --port-like")

    fw = args.fw_path or args.bin_path
    if not fw:
      ap.error("must provide --fw or --bin")

    p = pathlib.Path(fw).expanduser().resolve()
    if p.is_dir():
        if args.fw_name:
            name = args.fw_name
            direct = p / name
            if direct.exists() and direct.is_file():
                p = direct
            else:
                cands = [x for x in p.glob("*.bin") if name.lower() in x.name.lower()]
                if not cands:
                    raise FileNotFoundError(f"No .bin match '{name}' in: {p}")
                cands = sorted(cands, key=lambda x: x.stat().st_mtime, reverse=True)
                p = cands[0]
        else:
            cands = sorted(p.glob("*.bin"), key=lambda x: x.stat().st_mtime, reverse=True)
            if not cands:
                raise FileNotFoundError(f"No .bin found in: {p}")
            p = cands[0]
    if not p.exists():
        raise FileNotFoundError(str(p))

    upgrade(port, args.baud, str(p), args.base_addr, args.chunk, args.timeout, args.retries)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
