# DexterLab Command Parser

The DexterLab Command Parser is a VHDL module that implements a structured command interpreter for FPGA systems.  
It allows external tools or hosts to send formatted commands to the device and receive structured responses, enabling configuration, debugging, automation, and system monitoring.

---

## Features

- Structured command decoding  
- Automatic response generation  
- Support for **WAIT**, **POLL**, **PING**, and **DUMP** operations  
- Internal logging and status tracking  
- Clean interface for AXI/AHB wrapper integration  
- Support for **optional AXI-Full signals** (AWLOCK, AWREGION, AWQOS, ARLOCK, ARREGION, ARQOS)  
- Robust error handling (BRESP/RRESP mapping, timeout detection, boundary checks)  
- Full support for **BURST**, **FIFO**, **WRAP**, and **SINGLE** command semantics  
- Complete testbench environment  
- GHDL and Vivado simulation scripts  
- Technical documentation included

---

## Directory Structure

rtl/        → VHDL source code of the parser
tb/         → Testbench, stimuli, monitors
sim/        → Simulation scripts (GHDL, Vivado)
docs/       → Technical documentation
release/    → VERSION, CHANGELOG, RELEASE_NOTES

Codice

---

## Simulation

### GHDL

```sh
cd sim/ghdl
./run.sh
Vivado
sh
cd sim/vivado
vivado -mode batch -source run.tcl
Documentation
Documentation is available in the docs/ directory and includes:

Parser architecture

Command format

Response format

WAIT / POLL / PING / DUMP mechanisms

Integration guidelines for AXI/AHB wrappers

Optional AXI-Full signal handling

Error handling and boundary checks

Burst, FIFO, Wrap, and Single command semantics

Version
Current release: v1.0.1  
(Updated to include optional AXI-Full signal handling, corrected POLL/PING behavior, and improved burst/wrap semantics)

License
MIT License (or another license if preferred).


