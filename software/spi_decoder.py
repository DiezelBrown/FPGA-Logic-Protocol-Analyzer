
import numpy as np


def decode_spi(data, clk_channel=0, mosi_channel=1,
               miso_channel=2, cs_channel=3):

    channels = [
        clk_channel,
        mosi_channel,
        miso_channel,
        cs_channel
    ]

    if any(ch < 0 or ch > 7 for ch in channels):
        raise ValueError("Channels must be between 0 and 7")

    if len(set(channels)) != 4:
        raise ValueError("SPI channels must be different")

    data = np.asarray(data, dtype=np.uint8)

    clk = (data >> clk_channel) & 1
    mosi = (data >> mosi_channel) & 1
    miso = (data >> miso_channel) & 1
    cs = (data >> cs_channel) & 1

    decoded = []

    mosi_byte = 0
    miso_byte = 0
    bit_count = 0
    start_sample = None

    for i in range(1, len(data)):

        # Reset partial bytes when chip select becomes inactive.
        if cs[i] == 1:
            bit_count = 0
            mosi_byte = 0
            miso_byte = 0
            start_sample = None
            continue

        # SPI Mode 0: sample on rising SCLK edges.
        if clk[i - 1] == 0 and clk[i] == 1:

            if bit_count == 0:
                start_sample = i

            mosi_byte = (mosi_byte << 1) | int(mosi[i])
            miso_byte = (miso_byte << 1) | int(miso[i])

            bit_count += 1

            if bit_count == 8:
                decoded.append({
                    "sample": start_sample,
                    "mosi": mosi_byte,
                    "miso": miso_byte
                })

                bit_count = 0
                mosi_byte = 0
                miso_byte = 0
                start_sample = None

    return decoded
