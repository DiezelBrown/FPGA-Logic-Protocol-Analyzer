
import numpy as np


def decode_uart(data, channel, sample_rate, baud_rate=115200):
    if not 0 <= channel <= 7:
        raise ValueError("Channel must be between 0 and 7")

    if sample_rate <= 0 or baud_rate <= 0:
        raise ValueError("Rates must be positive")

    samples_per_bit = sample_rate / baud_rate

    if samples_per_bit < 2:
        raise ValueError("Sampling rate too low for reliable decoding")

    signal = ((np.asarray(data, dtype=np.uint8) >> channel) & 1)
    decoded = []

    i = 1

    while i < len(signal):
        # UART begins with a falling edge.
        if signal[i - 1] == 1 and signal[i] == 0:
            start = i

            # Check the middle of the start bit.
            midpoint = round(start + 0.5 * samples_per_bit)

            if midpoint >= len(signal):
                break

            if signal[midpoint] != 0:
                i += 1
                continue

            value = 0
            complete = True

            # UART sends 8 data bits, least-significant bit first.
            for bit in range(8):
                position = round(
                    start + (1.5 + bit) * samples_per_bit
                )

                if position >= len(signal):
                    complete = False
                    break

                value |= int(signal[position]) << bit

            stop_position = round(start + 9.5 * samples_per_bit)

            if not complete or stop_position >= len(signal):
                break

            if signal[stop_position] == 1:
                decoded.append({
                    "sample": start,
                    "time_us": start / sample_rate * 1e6,
                    "value": value
                })

            # Move past this frame.
            i = round(start + 10 * samples_per_bit)
        else:
            i += 1

    return decoded
