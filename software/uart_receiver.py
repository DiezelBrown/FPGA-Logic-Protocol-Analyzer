
import argparse
from pathlib import Path

import serial

SAMPLE_COUNT = 131_072
BAUD_RATE = 115200


def receive_capture(port, output_file):
    print(f"Connecting to {port}...")

    with serial.Serial(port, BAUD_RATE, timeout=5) as ser:
        ser.reset_input_buffer()

        print(f"Waiting for {SAMPLE_COUNT} samples...")

        samples = bytearray()

        while len(samples) < SAMPLE_COUNT:
            remaining = SAMPLE_COUNT - len(samples)
            chunk = ser.read(min(remaining, 4096))

            if not chunk:
                raise TimeoutError(
                    f"Timed out after receiving {len(samples)} samples"
                )

            samples.extend(chunk)

        Path(output_file).parent.mkdir(
            parents=True, exist_ok=True
        )
        Path(output_file).write_bytes(samples)

        print(f"Received {len(samples)} samples")
        print(f"Saved capture to {output_file}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Receive FPGA logic analyzer samples"
    )

    parser.add_argument(
        "--port",
        required=True,
        help="Serial port, e.g. /dev/cu.usbserial-0001"
    )

    parser.add_argument(
        "--output",
        default="software/capture.bin"
    )

    args = parser.parse_args()

    receive_capture(args.port, args.output)
