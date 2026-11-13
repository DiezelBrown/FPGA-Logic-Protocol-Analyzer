
import numpy as np
from uart_decoder import decode_uart

SAMPLE_RATE = 1_000_000
BAUD_RATE = 10_000
SAMPLES_PER_BIT = SAMPLE_RATE // BAUD_RATE

# Start with an idle HIGH UART line on channel 0.
samples = [1] * SAMPLES_PER_BIT


def add_bit(bit):
    samples.extend([bit] * SAMPLES_PER_BIT)


def transmit_byte(value):
    add_bit(0)  # Start bit

    for bit in range(8):
        add_bit((value >> bit) & 1)

    add_bit(1)  # Stop bit


transmit_byte(0xA5)
transmit_byte(0x3C)

samples.extend([1] * SAMPLES_PER_BIT)

data = np.array(samples, dtype=np.uint8)
data.tofile("software/test_uart_capture.bin")

results = decode_uart(
    data,
    channel=0,
    sample_rate=SAMPLE_RATE,
    baud_rate=BAUD_RATE
)

expected = [0xA5, 0x3C]
actual = [item["value"] for item in results]

print("Decoded bytes:", [f"0x{x:02X}" for x in actual])

assert actual == expected, f"Expected {expected}, got {actual}"

print("PASS: UART decoder reconstructed both bytes")
