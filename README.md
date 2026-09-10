DexterLab Command Parser
The DexterLab Command Parser is a VHDL module that implements a structured command interpreter for FPGA systems.
It allows external tools or hosts to send formatted commands to the device and receive structured responses, enabling configuration, debugging, automation, and system monitoring.

Features
Structured command decoding

Automatic response generation

Support for WAIT, POLL, and DUMP operations

Internal logging and status tracking

Clean interface for AXI/AHB wrapper integration

Complete testbench environment

GHDL and Vivado simulation scripts

Technical documentation included

Directory Structure
Codice
rtl/        → VHDL source code of the parser
tb/         → Testbench, stimuli, monitors
sim/        → Simulation scripts (GHDL, Vivado)
docs/       → Technical documentation
release/    → VERSION, CHANGELOG, RELEASE_NOTES
Simulation
GHDL
Codice
cd sim/ghdl
./run.sh
Vivado
Codice
cd sim/vivado
vivado -mode batch -source run.tcl
Documentation
Documentation is available in the docs/ directory and includes:

Parser architecture

Command format

Response format

WAIT / POLL / DUMP mechanisms

Integration guidelines for AXI/AHB wrappers

Version
Current release: v1.0.0

License
MIT License (or another license if preferred).
