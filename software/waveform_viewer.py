
import argparse

import matplotlib.pyplot as plt
import numpy as np

from measurements import analyze_channel
from uart_decoder import decode_uart
from spi_decoder import decode_spi
from spi_decoder import decode_spi
from i2c_decoder import decode_i2c

def plot_capture(filename, sample_rate, max_samples,
                 uart_channel=None, uart_baud=None,
                 spi_enabled=False, i2c_enabled=False):

    if sample_rate <= 0:
        raise ValueError("Sample rate must be positive")

    if max_samples <= 0:
        raise ValueError("Maximum samples must be positive")

    data = np.fromfile(filename, dtype=np.uint8)

    if data.size == 0:
        raise ValueError("Capture file is empty")

    count = min(len(data), max_samples)
    data = data[:count]

    time_us = np.arange(count) / sample_rate * 1e6

    fig, ax = plt.subplots(figsize=(13, 7))

    # Display all 8 digital channels.
    for channel in range(8):
        values = (data >> channel) & 1

        ax.step(
            time_us,
            values + channel * 2,
            where="post",
            linewidth=1.5,
            label=f"CH{channel}"
        )

    ax.set_yticks([channel * 2 + 0.5 for channel in range(8)])
    ax.set_yticklabels([f"CH{channel}" for channel in range(8)])
    ax.set_xlabel("Time (microseconds)")
    ax.set_title("FPGA Logic Analyzer — 8-Channel Capture")
    ax.grid(True, axis="x", alpha=0.3)
    ax.set_xlim(time_us[0], time_us[-1])
    ax.set_ylim(-0.5, 17.5)

    # Calculate channel measurements.
    measurement_lines = []

    for channel in range(8):
        result = analyze_channel(data, channel, sample_rate)

        frequency = result["frequency_hz"]
        widths = result["high_widths_us"]

        freq_text = (
            f"{frequency / 1000:.2f} kHz"
            if frequency is not None else "N/A"
        )

        width_text = (
            f"{np.mean(widths):.2f} us"
            if widths else "N/A"
        )

        measurement_lines.append(
            f"CH{channel}: {freq_text} | HIGH: {width_text}"
        )

    fig.subplots_adjust(right=0.76)

    fig.text(
        0.78,
        0.85,
        "\n".join(measurement_lines),
        fontsize=9,
        family="monospace",
        verticalalignment="top"
    )

    # Decode UART when a channel and baud rate are provided.
    if uart_channel is not None and uart_baud is not None:

        decoded = decode_uart(
            data,
            channel=uart_channel,
            sample_rate=sample_rate,
            baud_rate=uart_baud
        )

        for item in decoded:
            time = item["time_us"]
            value = item["value"]

            ax.axvline(
                time,
                linestyle=":",
                color="red",
                alpha=0.6
            )

            ax.text(
                time,
                16.5,
                f"0x{value:02X}",
                rotation=90,
                fontsize=9,
                color="red",
                verticalalignment="top"
            )

        print(f"Decoded {len(decoded)} UART bytes")

        for item in decoded:
            print(
                f"Time: {item['time_us']:.2f} us | "
                f"Byte: 0x{item['value']:02X}"
            )
    # Decode SPI Mode 0.
    if spi_enabled:
        decoded_spi = decode_spi(
            data,
            clk_channel=0,
            mosi_channel=1,
            miso_channel=2,
            cs_channel=3
        )

        for item in decoded_spi:
            time = item["sample"] / sample_rate * 1e6

            ax.axvline(
                time,
                color="purple",
                linestyle="--",
                alpha=0.5
            )

            ax.text(
                time,
                16.5,
                f"MOSI: 0x{item['mosi']:02X}\n"
                f"MISO: 0x{item['miso']:02X}",
                fontsize=8,
                color="purple",
                verticalalignment="top"
            )

        print(f"Decoded {len(decoded_spi)} SPI bytes")

            # Decode SPI Mode 0.
    if spi_enabled:
        decoded_spi = decode_spi(
            data,
            clk_channel=0,
            mosi_channel=1,
            miso_channel=2,
            cs_channel=3
        )

        for item in decoded_spi:
            time = item["sample"] / sample_rate * 1e6

            ax.axvline(
                time,
                color="purple",
                linestyle="--",
                alpha=0.5
            )

            ax.text(
                time,
                16.5,
                f"MOSI: 0x{item['mosi']:02X}\n"
                f"MISO: 0x{item['miso']:02X}",
                fontsize=8,
                color="purple",
                verticalalignment="top"
            )

        print(f"Decoded {len(decoded_spi)} SPI bytes")

    if i2c_enabled:
        decoded_i2c = decode_i2c(
            data,
            scl_channel=0,
            sda_channel=1
        )

        for item in decoded_i2c:
            time = item["sample"] / sample_rate * 1e6

            if item["type"] == "ADDRESS":
                direction = "READ" if item["read"] else "WRITE"
                ack = "ACK" if item["ack"] else "NACK"
                label = f"ADDR: 0x{item['address']:02X} {direction} {ack}"

            elif item["type"] == "DATA":
                ack = "ACK" if item["ack"] else "NACK"
                label = f"DATA: 0x{item['value']:02X} {ack}"

            else:
                label = item["type"]

            ax.axvline(
                time,
                color="darkgreen",
                linestyle="--",
                alpha=0.6
            )

            ax.text(
                time,
                16.5,
                label,
                rotation=90,
                fontsize=8,
                color="darkgreen",
                verticalalignment="top"
            )

        print(f"Decoded {len(decoded_i2c)} I2C events")
    plt.show()


if __name__ == "__main__":

    parser = argparse.ArgumentParser()

    parser.add_argument(
        "file",
        help="Binary capture file"
    )

    parser.add_argument(
        "--rate",
        type=float,
        default=1_000_000,
        help="Sampling rate in samples/second"
    )

    parser.add_argument(
        "--samples",
        type=int,
        default=1000,
        help="Maximum samples to display"
    )

    parser.add_argument(
        "--uart-channel",
        type=int,
        choices=range(8),
        default=None,
        help="Channel containing UART data (0-7)"
    )

    parser.add_argument(
        "--uart-baud",
        type=int,
        default=None,
        help="UART baud rate"
    )
    parser.add_argument(
    "--spi",
    action="store_true",
    help="Decode SPI Mode 0 on channels 0-3"
)
    parser.add_argument(
        "--i2c",
        action="store_true",
        help="Decode I2C on CH0 (SCL) and CH1 (SDA)"
    )
    args = parser.parse_args()

    if (args.uart_channel is None) != (args.uart_baud is None):
        parser.error(
            "--uart-channel and --uart-baud must be provided together"
        )

    plot_capture(
        args.file,
        args.rate,
        args.samples,
        args.uart_channel,
        args.uart_baud,
        args.spi,
        args.i2c
    )
