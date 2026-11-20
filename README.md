# DexterLab Command Parser

The DexterLab Command Parser is a VHDL module that implements a structured command interpreter for FPGA systems.

It allows external tools or hosts to send formatted commands to a target device and receive structured responses, enabling configuration, validation, debugging, automation, and system monitoring.

---

## Features

- Structured command decoding
- Structured response generation
- Support for WAIT, POLL, PING, DUMP and FILL operations
- Support for SINGLE, BURST, FIFO and WRAP command semantics
- Internal status tracking and diagnostics
- Unified interface for AXI-Full, AXI-Lite, AHB-Full and AHB-Lite bus converters
- Robust error handling and timeout detection
- Boundary, burst and protocol validation checks
- Deterministic command execution flow
- Complete testbench environment
- GHDL and Vivado simulation support
- Technical documentation included

---

## Directory Structure

```text
rtl/        VHDL source code
tb/         Testbench, stimuli and monitors
sim/        Simulation scripts (GHDL, Vivado)
docs/       Technical documentation
release/    VERSION, CHANGELOG, RELEASE_NOTES
```

---

## Simulation

### GHDL

```sh
cd sim/ghdl
./run.sh
```

### Vivado

```sh
cd sim/vivado
vivado -mode batch -source run.tcl
```

---

## Documentation

Documentation is available in the `docs/` directory and includes:

- Parser architecture
- Command format
- Response format
- WAIT / POLL / PING / DUMP mechanisms
- Bus converter integration guidelines
- Error handling and timeout management
- Boundary and burst validation
- SINGLE, BURST, FIFO and WRAP command semantics

---

## Supported Bus Converters

The parser is designed to integrate with:

- AXI-Full
- AXI-Lite
- AHB-Full
- AHB-Lite

through dedicated command-to-bus converter modules.

---

## Version

Current release: v1.1.0

Includes:
- AXI-Full bus converter
- AXI-Lite bus converter
- AHB-Full bus converter
- AHB-Lite bus converter
- Unified response/error architecture
- Full regression test coverage

---

## License

MIT License (or another license if preferred).
