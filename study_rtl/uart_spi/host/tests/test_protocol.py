import os
import unittest

from host.protocol import Frame, SlipDecoder, try_unpack_frame


class ProtocolTests(unittest.TestCase):
    def test_slip_roundtrip_random(self):
        data = os.urandom(2048)
        f = Frame(msg_type=0x04, seq=0x1234, payload=data)
        encoded = f.pack()

        dec = SlipDecoder()
        frames = dec.feed(encoded)
        self.assertEqual(len(frames), 1)
        parsed = try_unpack_frame(frames[0])
        self.assertIsNotNone(parsed)
        assert parsed is not None
        self.assertEqual(parsed.msg_type, 0x04)
        self.assertEqual(parsed.seq, 0x1234)
        self.assertEqual(parsed.payload, data)


if __name__ == "__main__":
    unittest.main()
