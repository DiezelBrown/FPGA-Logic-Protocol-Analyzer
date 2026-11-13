
import numpy as np
from i2c_decoder import decode_i2c

samples = []


def add_sample(scl, sda, count=5):
    value = (scl << 0) | (sda << 1)
    samples.extend([value] * count)


def send_bit(bit):
    add_sample(0, bit)
    add_sample(1, bit)
    add_sample(0, bit)


def send_byte(value, ack=0):
    for bit in range(7, -1, -1):
        send_bit((value >> bit) & 1)

    send_bit(ack)


# Idle bus: both lines HIGH.
add_sample(1, 1, 10)

# START condition.
add_sample(1, 0)
add_sample(0, 0)

# Address 0x48, write operation (R/W = 0).
send_byte(0x48 << 1)

# Transmit data 0xA5.
send_byte(0xA5)

# STOP condition.
add_sample(0, 0)
add_sample(1, 0)
add_sample(1, 1)

data = np.array(samples, dtype=np.uint8)
data.tofile("software/test_i2c_capture.bin")

results = decode_i2c(data)

for item in results:
    print(item)

assert [item["type"] for item in results] == [
    "START", "ADDRESS", "DATA", "STOP"
]

assert results[1]["address"] == 0x48
assert results[1]["read"] is False
assert results[1]["ack"] is True
assert results[2]["value"] == 0xA5
assert results[2]["ack"] is True

print("PASS: I2C decoder reconstructed the transaction")
