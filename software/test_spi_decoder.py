
import numpy as np
from spi_decoder import decode_spi

samples = []

# Channel mapping:
# CH0 = SCLK
# CH1 = MOSI
# CH2 = MISO
# CH3 = CS

def add_sample(clk, mosi, miso, cs):
    value = (
        (clk << 0) |
        (mosi << 1) |
        (miso << 2) |
        (cs << 3)
    )

    samples.append(value)


def transmit_byte(mosi_byte, miso_byte):

    for bit in range(7, -1, -1):

        mosi = (mosi_byte >> bit) & 1
        miso = (miso_byte >> bit) & 1

        for _ in range(5):
            add_sample(0, mosi, miso, 0)

        for _ in range(5):
            add_sample(1, mosi, miso, 0)


# Idle state: clock LOW, chip select HIGH.
for _ in range(10):
    add_sample(0, 0, 0, 1)

transmit_byte(0xA5, 0x3C)
transmit_byte(0xF0, 0x0F)

for _ in range(10):
    add_sample(0, 0, 0, 1)

data = np.array(samples, dtype=np.uint8)

data.tofile("software/test_spi_capture.bin")

results = decode_spi(data)

for result in results:
    print(
        f"MOSI: 0x{result['mosi']:02X} | "
        f"MISO: 0x{result['miso']:02X}"
    )

assert [r["mosi"] for r in results] == [0xA5, 0xF0]
assert [r["miso"] for r in results] == [0x3C, 0x0F]

print("PASS: SPI decoder reconstructed all bytes")
