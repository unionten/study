from __future__ import annotations

import struct
import time
from dataclasses import dataclass

import binascii

from .protocol import Frame, crc32_ieee, SlipDecoder, try_unpack_frame


MSG_HELLO = 0x01
MSG_START = 0x02
MSG_ERASE = 0x03
MSG_DATA = 0x04
MSG_FINISH = 0x05
MSG_QUERY = 0x06

MSG_HELLO_RSP = 0x81
MSG_ACK = 0x82
MSG_PROGRESS = 0x83

STATUS_OK = 0
STATUS_BUSY = 1
STATUS_BAD_CRC = 2
STATUS_BAD_STATE = 3
STATUS_FLASH_ERR = 4


@dataclass
class SimFlashCaps:
    flash_id: bytes = b"\xEF\x40\x18"
    page_size: int = 256
    sector_size: int = 4096
    max_payload: int = 1024


class SimTransport:
    def __init__(self, flash_size: int = 2 * 1024 * 1024, caps: SimFlashCaps | None = None):
        self.caps = caps or SimFlashCaps()
        self.flash = bytearray(b"\xFF" * flash_size)
        self._dec = SlipDecoder()
        self._rx_queue: list[bytes] = []

        self.base_addr = 0
        self.image_size = 0
        self.image_crc = 0
        self.written = 0
        self.running_crc = 0

        self._last_data_seq: int | None = None
        self._last_data_off: int | None = None
        self._last_data_len: int | None = None

    def close(self) -> None:
        return

    def write(self, data: bytes) -> None:
        for raw in self._dec.feed(data):
            f = try_unpack_frame(raw)
            if f is None:
                continue
            self._handle_frame(f)

    def read_frame(self, deadline_s: float) -> bytes | None:
        end = time.time() + deadline_s
        while time.time() < end:
            if self._rx_queue:
                return self._rx_queue.pop(0)
            time.sleep(0.001)
        return None

    def _push(self, frame: Frame) -> None:
        self._rx_queue.append(self._dec.feed(frame.pack())[0])

    def _ack(self, seq: int, ack_type: int, status: int, detail: int = 0) -> None:
        payload = struct.pack(">BBH", ack_type & 0xFF, status & 0xFF, detail & 0xFFFF)
        self._rx_queue.append(self._dec.feed(Frame(MSG_ACK, seq, payload).pack())[0])

    def _handle_frame(self, f: Frame) -> None:
        if f.msg_type == MSG_HELLO:
            payload = (
                self.caps.flash_id
                + struct.pack(">H", self.caps.page_size)
                + struct.pack(">I", self.caps.sector_size)
                + struct.pack(">H", self.caps.max_payload)
            )
            self._rx_queue.append(self._dec.feed(Frame(MSG_HELLO_RSP, f.seq, payload).pack())[0])
            return

        if f.msg_type == MSG_START:
            if len(f.payload) < 14:
                self._ack(f.seq, MSG_START, STATUS_BAD_STATE)
                return
            self.base_addr, self.image_size, self.image_crc, page = struct.unpack(">IIIH", f.payload[:14])
            _ = page
            self.written = 0
            self.running_crc = 0
            self._last_data_seq = None
            self._ack(f.seq, MSG_START, STATUS_OK)
            return

        if f.msg_type == MSG_ERASE:
            if len(f.payload) < 12:
                self._ack(f.seq, MSG_ERASE, STATUS_BAD_STATE)
                return
            base, size, sector = struct.unpack(">III", f.payload[:12])
            end = min(len(self.flash), base + size)
            for i in range(base, end):
                self.flash[i] = 0xFF
            self._ack(f.seq, MSG_ERASE, STATUS_OK)
            return

        if f.msg_type == MSG_DATA:
            if len(f.payload) < 6:
                self._ack(f.seq, MSG_DATA, STATUS_BAD_STATE)
                return
            off, dlen = struct.unpack(">IH", f.payload[:6])
            data = f.payload[6 : 6 + dlen]
            if len(data) != dlen:
                self._ack(f.seq, MSG_DATA, STATUS_BAD_STATE)
                return
            if (
                self._last_data_seq == f.seq
                and self._last_data_off == off
                and self._last_data_len == dlen
            ):
                self._ack(f.seq, MSG_DATA, STATUS_OK)
                return

            addr = self.base_addr + off
            if addr + dlen > len(self.flash):
                self._ack(f.seq, MSG_DATA, STATUS_FLASH_ERR)
                return
            self.flash[addr : addr + dlen] = data
            self.running_crc = binascii.crc32(data, self.running_crc) & 0xFFFFFFFF
            self.written = max(self.written, off + dlen)
            self._last_data_seq = f.seq
            self._last_data_off = off
            self._last_data_len = dlen
            self._ack(f.seq, MSG_DATA, STATUS_OK)
            return

        if f.msg_type == MSG_QUERY:
            payload = struct.pack(">II", self.written, self.running_crc)
            self._rx_queue.append(self._dec.feed(Frame(MSG_PROGRESS, f.seq, payload).pack())[0])
            return

        if f.msg_type == MSG_FINISH:
            if self.written != self.image_size:
                self._ack(f.seq, MSG_FINISH, STATUS_BAD_STATE)
                return
            if (self.running_crc & 0xFFFFFFFF) != (self.image_crc & 0xFFFFFFFF):
                self._ack(f.seq, MSG_FINISH, STATUS_FLASH_ERR)
                return
            self._ack(f.seq, MSG_FINISH, STATUS_OK)
            return

        self._ack(f.seq, f.msg_type, STATUS_BAD_STATE)
