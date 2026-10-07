# AXI4-Lite RAM Design

This repository contains the RTL design, testbench, and scripts for a custom 16x32-bit synchronous RAM integrated with an AXI4-Lite slave interface, developed in Verilog.

## Features
- **Memory**: 16 words x 32-bit synchronous RAM.
- **Interface**: Full AXI4-Lite slave interface with AW, W, B, AR, and R channels.
- **Handshaking**: Proper `VALID`/`READY` handshaking for reliable data transfer.
- **Address Decoding**: Byte address to word index mapping with alignment checks.
- **Simulation**: Verilog testbench covering read/write verification.

## Directory Structure
- `rtl/`: Contains the Verilog source files (Top module, AXI Slave FSM, RAM, Decoder).
- `tb/`: Contains the Verilog testbench.
- `sim/`: Contains simulation configurations (e.g., waveforms).
- `vivado/`: Contains the TCL script to rebuild the project and constraints.
- `docs/`: Architecture documentation and address maps.

## Quick Start
You can run the simulation using Vivado:
1. Open Vivado and source the TCL script: `source vivado/create_project.tcl`
2. Run the simulation from the Vivado GUI.