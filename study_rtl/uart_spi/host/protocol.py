from __future__ import annotations

import binascii
import struct
from dataclasses import dataclass
from typing import Iterable, Optional


SLIP_END = 0xC0
SLIP_ESC = 0xDB
SLIP_ESC_END = 0xDC
SLIP_ESC_ESC = 0xDD

MAGIC = b"\x55\xAA"
VERSION = 0x01


def crc32_ieee(data: bytes) -> int:
    return binascii.crc32(data) & 0xFFFFFFFF


def slip_encode(payload: bytes) -> bytes:
    out = bytearray()
    out.append(SLIP_END)
    for b in payload:
        if b == SLIP_END:
            out.extend([SLIP_ESC, SLIP_ESC_END])
        elif b == SLIP_ESC:
            out.extend([SLIP_ESC, SLIP_ESC_ESC])
        else:
            out.append(b)
    out.append(SLIP_END)
    return bytes(out)


def slip_decode_stream(byte_iter: Iterable[int]) -> Iterable[bytes]:
    buf = bytearray()
    esc = False
    in_frame = False
    for b in byte_iter:
        if b is None:
            continue
        if b < 0:
            continue
        b &= 0xFF
        if b == SLIP_END:
            if in_frame and buf:
                yield bytes(buf)
            buf.clear()
            esc = False
            in_frame = True
            continue

        if not in_frame:
            continue

        if esc:
            if b == SLIP_ESC_END:
                buf.append(SLIP_END)
            elif b == SLIP_ESC_ESC:
                buf.append(SLIP_ESC)
            else:
                buf.clear()
                in_frame = False
            esc = False
            continue

        if b == SLIP_ESC:
            esc = True
            continue

        buf.append(b)


class SlipDecoder:
    def __init__(self):
        self._buf = bytearray()
        self._esc = False
        self._in_frame = False

    def feed(self, chunk: bytes) -> list[bytes]:
        frames: list[bytes] = []
        for b in chunk:
            if b == SLIP_END:
                if self._in_frame and self._buf:
                    frames.append(bytes(self._buf))
                self._buf.clear()
                self._esc = False
                self._in_frame = True
                continue

            if not self._in_frame:
                continue

            if self._esc:
                if b == SLIP_ESC_END:
                    self._buf.append(SLIP_END)
                elif b == SLIP_ESC_ESC:
                    self._buf.append(SLIP_ESC)
                else:
                    self._buf.clear()
                    self._in_frame = False
                self._esc = False
                continue

            if b == SLIP_ESC:
                self._esc = True
                continue

            self._buf.append(b)
        return frames


@dataclass(frozen=True)
class Frame:
    msg_type: int
    seq: int
    payload: bytes

    def pack(self) -> bytes:
        header = struct.pack(">2sBBHH", MAGIC, VERSION, self.msg_type & 0xFF, self.seq & 0xFFFF, len(self.payload)
        )
        body = header + self.payload
        crc = struct.pack(">I", crc32_ieee(body))
        return slip_encode(body + crc)


def try_unpack_frame(raw: bytes) -> Optional[Frame]:
    if len(raw) < 2 + 1 + 1 + 2 + 2 + 4:
        return None
    magic, ver, msg_type, seq, length = struct.unpack(">2sBBHH", raw[:8])
    if magic != MAGIC or ver != VERSION:
        return None
    if len(raw) != 8 + length + 4:
        return None
    payload = raw[8 : 8 + length]
    (crc_rx,) = struct.unpack(">I", raw[8 + length : 8 + length + 4])
    crc_calc = crc32_ieee(raw[: 8 + length])
    if crc_rx != crc_calc:
        return None
    return Frame(msg_type=msg_type, seq=seq, payload=payload)
