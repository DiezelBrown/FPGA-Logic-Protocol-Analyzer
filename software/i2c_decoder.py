
import numpy as np


def decode_i2c(data, scl_channel=0, sda_channel=1):
    if scl_channel not in range(8) or sda_channel not in range(8):
        raise ValueError("Channels must be between 0 and 7")

    if scl_channel == sda_channel:
        raise ValueError("SCL and SDA must use different channels")

    data = np.asarray(data, dtype=np.uint8)

    scl = (data >> scl_channel) & 1
    sda = (data >> sda_channel) & 1

    decoded = []
    active = False
    bits = []
    expecting_address = True
    byte_start = None

    for i in range(1, len(data)):
        # START: SDA falls while SCL stays HIGH.
        if scl[i - 1] == 1 and scl[i] == 1:
            if sda[i - 1] == 1 and sda[i] == 0:
                decoded.append({
                    "type": "START",
                    "sample": i
                })
                active = True
                bits = []
                expecting_address = True
                byte_start = None
                continue

            # STOP: SDA rises while SCL stays HIGH.
            if sda[i - 1] == 0 and sda[i] == 1:
                if active:
                    decoded.append({
                        "type": "STOP",
                        "sample": i
                    })
                active = False
                bits = []
                continue

        # Read SDA on rising SCL edges.
        if active and scl[i - 1] == 0 and scl[i] == 1:
            if not bits:
                byte_start = i

            bits.append(int(sda[i]))

            # Eight data bits followed by ACK/NACK.
            if len(bits) == 9:
                value = 0

                for bit in bits[:8]:
                    value = (value << 1) | bit

                ack = bits[8] == 0

                if expecting_address:
                    decoded.append({
                        "type": "ADDRESS",
                        "sample": byte_start,
                        "address": value >> 1,
                        "read": bool(value & 1),
                        "ack": ack
                    })
                    expecting_address = False
                else:
                    decoded.append({
                        "type": "DATA",
                        "sample": byte_start,
                        "value": value,
                        "ack": ack
                    })

                bits = []
                byte_start = None

    return decoded
