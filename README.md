# FPGA Logic & Protocol Analyzer

An 8-channel FPGA logic analyzer built on the **Digilent Basys 3 (Xilinx Artix-7)** for capturing, triggering on, and analyzing digital signals.

> **Status:** 🚧 In Development

## Overview

I'm building this project to gain hands-on experience with FPGA development, digital design, verification, and hardware debugging.

The analyzer will capture digital signals from microcontrollers, sensors, and other digital hardware. The FPGA will handle high-speed signal sampling, triggering, capture control, and data storage using Block RAM. Captured data will then be transferred to a PC for waveform visualization and protocol decoding.

The initial target is **8 channels at up to 100 MS/s**, with support for UART, SPI, and I2C analysis.

## System Architecture

```text
ESP32 / MCU / Sensor
        │
   Digital Signals
        │
        ▼
┌──────────────────┐
│     Basys 3      │
│                  │
│  Input Sampling  │
│        ↓         │
│ Trigger Engine   │
│        ↓         │
│  Capture FSM     │
│        ↓         │
│  BRAM Buffer     │
└────────┬─────────┘
         │
      USB/UART
         │
         ▼
┌──────────────────┐
│        PC        │
│                  │
│ Waveform Viewer  │
│ Protocol Decoder │
└──────────────────┘
```

## Target Features

* 8 simultaneous digital input channels
* Up to 100 MS/s target sampling rate
* Configurable sampling rates
* BRAM-based capture buffer
* Rising/falling-edge triggering
* Pre-trigger and post-trigger capture
* FPGA-to-PC data transfer
* Digital waveform visualization
* UART decoding
* SPI decoding
* I2C decoding
* Frequency and pulse-width measurements

Final specifications will be based on hardware testing and timing results.

## Hardware

* **FPGA Board:** Digilent Basys 3
* **FPGA:** Xilinx Artix-7 XC7A35T
* **System Clock:** 100 MHz
* **Test Device:** ESP32

The ESP32 will be used to generate known digital signals and UART, SPI, and I2C traffic for testing the analyzer.

## Development Roadmap

* [x] Define project architecture
* [x] Select FPGA development board
* [ ] 8-channel input sampler
* [ ] Configurable sampling
* [ ] BRAM capture buffer
* [ ] Trigger engine
* [ ] Capture-control FSM
* [ ] Basys 3 hardware testing
* [ ] FPGA-to-PC communication
* [ ] Waveform viewer
* [ ] UART decoder
* [ ] SPI decoder
* [ ] I2C decoder
* [ ] Performance testing

## Tools & Technologies

**FPGA / Digital Design**

* Verilog / SystemVerilog
* AMD Vivado
* Xilinx Artix-7
* Block RAM
* Finite State Machines

**Verification**

* Icarus Verilog
* Surfer / GTKWave
* RTL testbenches

**Software**

* Python
* Git / GitHub

**Protocols**

* UART
* SPI
* I2C

## Repository Structure

```text
FPGA-Logic-Protocol-Analyzer/
│
├── README.md
├── rtl/          # FPGA RTL
├── tb/           # Testbenches
├── sim/          # Simulation files
├── software/     # PC software
├── hardware/     # Basys 3 constraints
├── images/       # Hardware photos, waveforms, screenshots, and diagrams
└── docs/         # Design documentation
```

## Project Results

This section will be updated as the analyzer is built and tested.

Planned results to document include:

* Maximum reliable sampling rate
* Capture depth
* BRAM utilization
* LUT and flip-flop utilization
* Timing results
* Real hardware captures
* Protocol decoding examples

Project photos, simulation waveforms, hardware captures, and software screenshots will be added to the `images/` folder throughout development.

## Current Status

The project is currently in the **design and architecture phase**.

The next step is implementing and verifying the FPGA signal acquisition system.

As development continues, this README will be updated with real simulation results, hardware photos, captured waveforms, protocol-decoding examples, and measured FPGA performance.
