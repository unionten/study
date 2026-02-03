from __future__ import annotations

import time
from dataclasses import dataclass
from typing import Optional

import serial

from .protocol import SlipDecoder


@dataclass
class SerialConfig:
    port: str
    baud: int = 921600
    timeout_s: float = 0.2


class SerialTransport:
    def __init__(self, cfg: SerialConfig):
        self.cfg = cfg
        self.ser = serial.Serial(
            port=cfg.port,
            baudrate=cfg.baud,
            timeout=cfg.timeout_s,
            write_timeout=cfg.timeout_s,
        )
        self._dec = SlipDecoder()
        self._queue: list[bytes] = []

    def close(self) -> None:
        try:
            self.ser.close()
        except Exception:
            pass

    def write(self, data: bytes) -> None:
        self.ser.write(data)
        self.ser.flush()

    def read_frame(self, deadline_s: float) -> Optional[bytes]:
        end_t = time.time() + deadline_s
        while time.time() < end_t:
            if self._queue:
                return self._queue.pop(0)
            chunk = self.ser.read(256)
            if chunk:
                self._queue.extend(self._dec.feed(chunk))
                continue
            time.sleep(0.001)
        return None
