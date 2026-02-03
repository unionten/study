import os
import unittest

from host.sim_device import SimTransport
from host.uart_fwu import upgrade_bytes


class EndToEndSimTests(unittest.TestCase):
    def test_upgrade_flow_sim(self):
        image = os.urandom(4096)
        tr = SimTransport(flash_size=2 * 1024 * 1024)
        upgrade_bytes(tr, image=image, base_addr=0x000000, chunk=256, timeout_s=0.05, retries=2)


if __name__ == "__main__":
    unittest.main()

