# DexterLab Parser Documentation Index

This document provides a structured overview of the documentation related to the DexterLab command ecosystem.

It serves as the primary entry point for:

- Developers
- Verification engineers
- Integrators
- Advanced users

The documentation is organized into logical sections covering parser behavior, interfaces, arbitration, backend execution, simulation, and future system integration.

---

# 1. Recommended Reading Order

New users should follow the documentation in the following order:

1. `overview.md`
2. `cmd_file_format.md`
3. `command_set.md`
4. `cmd_interface.md`
5. `cmd_flow.md`
6. `cmd_errors.md`
7. Backend documentation for the selected protocol

This sequence provides a complete understanding of command creation, execution, response handling, and protocol integration.

---

# 2. Command Language Documentation

## Command File Format

### `cmd_file_format.md`

Defines the syntax and structure of DexterLab command files.

Topics include:

- Command syntax
- Variables
- Include files
- Expressions
- Numeric formats
- Comments
- Atomic execution
- Complete examples

---

## Command Set Reference

### `command_set.md`

Complete reference for all supported commands.

Includes:

### Utility Commands

```text
PRINT
INCLUDE
SET_VAR

WAIT_TIME
WAIT_CLOCKS
WAIT_SIM_TIME

STOP
END_SIM
```

### Basic Memory Commands

```text
READ
WRITE
CHECK
WSTRB_WRITE
```

### Burst Commands

```text
BURST_READ
BURST_WRITE
BURST_CHECK
```

### Wrap Commands

```text
WRAP_READ
WRAP_WRITE
WRAP_CHECK
```

### FIFO Commands

```text
FIFO_READ
FIFO_WRITE
FIFO_CHECK
```

### Fill Commands

```text
FILL_LEN
FILL_RANGE
FILL_CHECK
```

### Poll Commands

```text
POLL_READ
POLL_TOGGLE
```

### Dump Commands

```text
DUMP_LEN
DUMP_RANGE

DUMP_FILE_LEN
DUMP_FILE_RANGE

DUMP_FILE_CHECK_LEN
DUMP_FILE_CHECK_RANGE
```

### Error Injection

```text
TEST_ERROR
```

---

# 3. Interface Documentation

## Command Interface

### `cmd_interface.md`

Formal definition of the DexterLab interfaces:

```text
t_cmd_out
t_rsp_out
t_rsp_in
```

Topics include:

- Field definitions
- Handshake rules
- Flow control
- Response semantics
- Locked command execution
- Command completion model

---

## Configuration Package

### `cmd_cfg.md`

Documentation of:

```text
cmd_cfg.vhd
```

Includes:

- Address width
- Data width
- Timeout settings
- Parser limits
- Include depth
- Command ID configuration
- Source identifiers
- Global constants

---

# 4. Execution and Error Handling

## Command Flow

### `cmd_flow.md`

Describes the complete execution pipeline:

```text
Command File
      |
Parser
      |
Arbiter
      |
Backend
      |
Bus
      |
Response
```

Topics include:

- Command generation
- Arbitration
- Backend execution
- Response publication
- Command completion

---

## Error Model

### `cmd_errors.md`

Defines the unified DexterLab error model.

Coverage includes:

- Parser errors
- Validation errors
- Runtime errors
- AXI-FULL error mappings
- AXI-LITE error mappings
- AHB-FULL error mappings
- AHB-LITE error mappings

---

## DRY_RUN Mode

### `cmd_dry_run.md`

Documents parser-only execution mode.

Features:

- File parsing
- Syntax validation
- Semantic validation
- Command normalization

Without:

- Arbiter access
- Backend execution
- Memory modification
- Bus activity

Typical use cases:

- CI pipelines
- Regression validation
- Documentation verification
- Parser debugging

---

# 5. Parser Documentation

## Parser Engine Internals

### `DexterLab Parser Engine Internals.md`

Detailed implementation description of the parser.

Topics include:

- Tokenizer
- Command decoder
- Syntax validation
- Semantic validation
- Variable engine
- Include engine
- Micro-command generation
- Command builder
- Polling engine
- Dump engine
- Atomic command handling

This is the primary document for developers working on parser internals.

---

# 6. Arbiter Documentation

## Multi-Source Arbiter

### `master_arbiter.md`

Practical description of arbiter operation.

Topics include:

- Source selection
- Ownership management
- Pending-command handling
- Locked execution
- Response routing

---

## Arbiter Specification

### `DexterLab Arbiter Specification.md`

Formal specification of:

```text
arbiter_mux
```

Topics include:

- FSM architecture
- Ownership tracking
- Source arbitration
- Command routing
- Response routing
- Lock handling through `cmd_lock`
- Pending-command management

---

# 7. Backend Documentation

Backend documentation explains how protocol-independent commands are translated into protocol-specific transactions.

---

## Generic Backend

### `backend_generic.md`

Reference backend used for:

- Parser development
- Arbitration testing
- Regression testing
- Continuous integration

Implements internal:

```text
REG
RAM
FIFO
```

memory models.

---

## AXI-FULL Backend

### `backend_axi_full.md`

Features:

- AXI4 protocol
- Multi-beat bursts
- Wrap transactions
- WSTRB support
- Timeout handling
- Multi-ID operation

---

## AXI-LITE Backend

### `backend_axi_lite.md`

Features:

- Single-beat accesses
- MMIO operation
- WSTRB support
- Simplified protocol behavior

---

## AHB-FULL Backend

### `backend_ahb_full.md`

Features:

- HBURST support
- Multi-beat transfers
- Wrap transfers
- Wait-state support
- Timeout handling

---

## AHB-LITE Backend

### `backend_ahb_lite.md`

Features:

- Internal burst sequencing
- Wrap address generation
- Wait-state handling
- Lightweight execution model

---

## TileLink Bridge

### `tilelink_bridge.md`

Provides integration between:

```text
TileLink
```

and:

```text
t_cmd_out
```

Supports:

- TL-UL
- TL-UH

and future RISC-V integration.

---

## Backend Overview

### `DexterLab Backend Overview.md`

High-level description of backend architecture.

Topics:

- Backend responsibilities
- Protocol abstraction
- Common execution model
- Error reporting

---

## Bus Comparison

### `bus_comparison.md`

Compares:

- AXI-FULL
- AXI-LITE
- AHB-FULL
- AHB-LITE
- TileLink

Including:

- Features
- Complexity
- Performance
- Recommended use cases

---

# 8. Hardware Master Documentation

## Hardware Command Master

### `parser_master.md`

Documents the current hardware master implementation.

Current behavior:

- Continuous READ generation
- Protocol-independent operation
- Placeholder architecture

---

## Master Integration Guide

### `parser_master_integration.md`

Explains how custom masters integrate with DexterLab.

Topics:

- `t_cmd_out`
- `t_rsp_out`
- `t_rsp_in`
- Arbiter interaction
- Backend interaction
- Ownership handling

---

## Master Roadmap

### `roadmap_master.md`

Future directions for hardware command generation.

Possible areas:

- SPI
- I²C
- UART
- CAN
- DMA engines
- RISC-V
- Ethernet
- Distributed command systems

---

# 9. Verification Documentation

## Testbench Architecture

### `DexterLab Testbench Architecture.md`

Complete description of the DexterLab simulation environment.

Topics include:

- Parser Engine
- Hardware Master
- Arbiter
- Backend Layer
- REG/RAM/FIFO Models
- TileLink Integration
- Waveform Support
- Regression Execution

---

## Simulation Environments

### `cmd_simulation_envs.md`

Documents supported simulators:

### Open Source

- GHDL

### FPGA Toolchains

- Vivado / XSIM

### Commercial Simulators

- QuestaSim
- ModelSim
- Riviera-PRO
- Xcelium
- VCS

---

# 10. Reference Documentation

## Address Map

### `DexterLab Address Map.md`

Defines the default memory map:

```text
REG
RAM
FIFO
```

Including:

- Address ranges
- Supported operations
- Boundary rules
- Extension guidelines

---

## Glossary

### `DexterLab Glossary.md`

Definitions of terminology used throughout DexterLab.

Includes:

- Protocol terms
- Command terminology
- Backend terminology
- Verification terminology

---

## Architecture Diagrams

### `architecture_diagrams.md`

Collection of architecture and execution-flow diagrams used throughout the project.

---

## Documentation Index

### `DexterLab Documentation Index.md`

Alternative categorized index of the entire documentation set.

---

# 11. Documentation Philosophy

DexterLab documentation follows several principles:

### Modular

Each document focuses on a single subsystem.

### Protocol Independent

Command semantics remain identical regardless of backend.

### Verification Oriented

Documentation reflects actual HDL behavior.

### Extensible

New protocols and command sources can be added without restructuring the documentation.

### Simulator Neutral

Documentation applies to both open-source and commercial simulators.

### Traceable

Parser, arbiter, backend, and error behavior remain consistently documented.

---

# 12. Summary

The DexterLab documentation set covers:

- Command language
- Parser architecture
- Interfaces
- Error handling
- Arbitration
- Backend implementations
- Hardware masters
- TileLink integration
- Verification infrastructure
- Simulation environments

The documentation reflects the DexterLab v1.1.0 architecture:

```text
Parser / Master
        |
        v
     Arbiter
        |
        v
     Backend
        |
        v
       Bus
```

and serves as the primary technical reference for development, verification, testing, and future system integration.

---

# End of Document
