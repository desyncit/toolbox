#!/usr/bin/python3

import ndef
import subprocess
import sys
import tempfile
import os

def write_url_to_tag(url: str):
    record = ndef.UriRecord(url)
    ndef_bytes = b''.join(ndef.message_encoder([record]))

    tlv = b'\x03' + bytes([len(ndef_bytes)]) + ndef_bytes + b'\xfe'

    dump = bytearray(540)
    dump[16:16 + len(tlv)] = tlv

    with tempfile.NamedTemporaryFile(suffix='.mfd', delete=False) as f:
        f.write(dump)
        tmp_path = f.name

    verify_path = tmp_path + '_verify.mfd'

    try:
        print(f"Writing URL to NFC tag: {url}")
        print("Hold your tag on the reader...")
        result = subprocess.run(
            ["nfc-mfultralight", "w", tmp_path, "--partial", "--pw", "FFFFFFFF"],
            capture_output=False
        )
        if result.returncode != 0:
            print("Write failed — check tag is on the reader.")
            return

        print("Verifying...")
        verify = subprocess.run(
            ["nfc-mfultralight", "r", verify_path, "--pw", "FFFFFFFF"],
            capture_output=False
        )
        if verify.returncode != 0:
            print("Verification read failed.")
            return

        written = bytearray(open(verify_path, 'rb').read())
        if written[16:16 + len(tlv)] == bytearray(tlv):
            print("Done! URL written and verified successfully.")
        else:
            print("Verification failed — data on tag doesn't match what was written.")

    finally:
        os.unlink(tmp_path)
        if os.path.exists(verify_path):
            os.unlink(verify_path)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: nfc-url <url>")
        print("Example: nfc-url https://example.com")
        sys.exit(1)

    write_url_to_tag(sys.argv[1])
