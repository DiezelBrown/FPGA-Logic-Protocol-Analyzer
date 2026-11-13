
import numpy as np


def analyze_channel(data, channel, sample_rate):
    if not 0 <= channel <= 7:
        raise ValueError("Channel must be between 0 and 7")

    if sample_rate <= 0:
        raise ValueError("Sample rate must be positive")

    values = (data >> channel) & 1

    # Find changes between consecutive samples.
    changes = np.diff(values.astype(np.int8))

    rising_edges = np.where(changes == 1)[0] + 1
    falling_edges = np.where(changes == -1)[0] + 1

    high_widths = []

    for rising in rising_edges:
        following_falls = falling_edges[falling_edges > rising]

        if len(following_falls) > 0:
            width_samples = following_falls[0] - rising
            high_widths.append(width_samples / sample_rate)

    frequency = None

    if len(rising_edges) >= 2:
        periods = np.diff(rising_edges) / sample_rate
        frequency = 1 / np.mean(periods)

    return {
        "rising_edges": len(rising_edges),
        "falling_edges": len(falling_edges),
        "frequency_hz": frequency,
        "high_widths_us": [
            width * 1e6 for width in high_widths
        ]
    }


if __name__ == "__main__":
    data = np.fromfile(
        "software/test_capture.bin",
        dtype=np.uint8
    )

    sample_rate = 1_000_000

    for channel in range(8):
        result = analyze_channel(data, channel, sample_rate)

        print(f"\nCH{channel}")
        print(f"  Rising edges: {result['rising_edges']}")
        print(f"  Falling edges: {result['falling_edges']}")

        if result["frequency_hz"] is not None:
            print(f"  Frequency: {result['frequency_hz']:.2f} Hz")
        else:
            print("  Frequency: N/A")

        widths = result["high_widths_us"]

        if widths:
            print(f"  Average HIGH width: {np.mean(widths):.2f} us")
        else:
            print("  Average HIGH width: N/A")
