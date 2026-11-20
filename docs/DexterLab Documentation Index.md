# DexterLab Documentation Index

(Version 2026 — Unified Command Ecosystem)

This document provides a structured overview of the complete DexterLab documentation set.

It is the recommended entry point for:

- New users
- Verification engineers
- Hardware integrators
- HDL developers
- Contributors
- System architects
- Future RISC-V and TileLink users

The entire documentation reflects the DexterLab v1.1.0 architecture:

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

No wrapper layer exists in the current architecture.

---

# 1. Core Architecture Documentation

## System Overview

### `overview.md`

High-level introduction to the DexterLab ecosystem.

Topics:

- Parser architecture
- Hardware master integration
- Arbiter architecture
- Backend layer
- Supported protocols
- Verification methodology

Recommended starting point for all users.

---

## Configuration Package

### `cmd_cfg.md`

Documentation of global configuration parameters.

Includes:

- Address width
- Data width
- Command ID width
- Timeout settings
- Parser limits
- Include depth
- Logging controls
- Internal buffer configuration

---

## Command Interface

### `cmd_interface.md`

Formal specification of:

```text
t_cmd_out
t_rsp_out
t_rsp_in
```

Topics:

- Interface fields
- Flow control
- Handshake semantics
- Response handling
- Lock semantics
- Command completion model

---

## Command Flow

### `cmd_flow.md`

Describes the complete command execution architecture.

Execution path:

```text
Command Source
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

Topics:

- Command acceptance
- Execution phases
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
- AXI-FULL mappings
- AXI-LITE mappings
- AHB-FULL mappings
- AHB-LITE mappings

---

# 2. Command Language Documentation

## Command File Format

### `cmd_file_format.md`

Defines the syntax and structure of DexterLab command files.

Topics include:

- Variables
- Include files
- Expressions
- Comments
- Numeric formats
- SET_ATOMIC-based execution
- Command examples

---

## Command Set Reference

### `command_set.md`

Complete reference for all supported commands.

Includes:

### Utility Commands

```text
PRINT
SET_VAR
INCLUDE

WAIT_TIME
WAIT_CLOCKS
WAIT_SIM_TIME

STOP
END_SIM
```

### Memory Commands

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

## DRY_RUN Mode

### `cmd_dry_run.md`

Parser-only validation mode.

Features:

- Parsing
- Syntax validation
- Semantic validation
- Command normalization

Without:

- Arbiter interaction
- Backend execution
- Bus activity

Typical uses:

- CI pipelines
- Parser validation
- Documentation verification
- Command debugging

---

# 3. Parser Documentation

## Parser Engine Internals

### `DexterLab Parser Engine Internals.md`

Detailed implementation description of the parser.

Topics include:

- Tokenizer
- Command Decoder
- Syntax Validation
- Semantic Validation
- Variable Engine
- Include Engine
- Micro-Command Generator
- Command Builder
- Polling Engine
- Dump Engine
- Atomic command handling
- Wrap validation

This is the primary document for parser developers.

---

# 4. Arbiter Documentation

## Arbiter Specification

### `DexterLab Arbiter Specification.md`

Formal specification of:

```text
arbiter_mux
```

Topics include:

- FSM architecture
- Ownership tracking
- Pending-command handling
- Command routing
- Response routing
- Locked execution via `cmd_lock`
- Arbitration behavior

---

## Arbiter Overview

### `master_arbiter.md`

High-level architectural overview of the multi-source arbiter.

Topics:

- Parser ownership
- Hardware master ownership
- Backend access
- Response routing
- Multi-source operation

---

# 5. Backend Documentation

Backend documentation explains how protocol-independent commands are translated into backend-specific behavior.

---

## Backend Overview

### `DexterLab Backend Overview.md`

High-level description of the backend layer.

Topics:

- Backend responsibilities
- Common execution model
- Error propagation
- Protocol abstraction

---

## Generic Backend

### `backend_generic.md`

Reference execution backend.

Features:

- Internal memory models
- Burst support
- Wrap support
- FIFO support
- Polling support
- Fill operations
- Dump operations

Primarily used for:

- Parser development
- Regression testing
- Continuous integration

---

## AXI-FULL Backend

### `backend_axi_full.md`

Features:

- Full AXI4 protocol
- Multi-beat bursts
- Wrap support
- WSTRB support
- Multi-ID support
- Timeout handling

---

## AXI-LITE Backend

### `backend_axi_lite.md`

Features:

- Single-beat transactions
- MMIO operation
- WSTRB support
- Simplified execution model

---

## AHB-FULL Backend

### `backend_ahb_full.md`

Features:

- HBURST support
- Multi-beat transfers
- Wrap support
- Wait-state handling
- Timeout management

---

## AHB-LITE Backend

### `backend_ahb_lite.md`

Features:

- Internal burst sequencing
- Wrap address generation
- Wait-state support
- Lightweight protocol model

---

## TileLink Bridge

### `tilelink_bridge.md`

Integration layer between:

```text
TileLink
```

and:

```text
t_cmd_out
```

Supports:

```text
TL-UL
TL-UH
```

and future RISC-V integration.

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
- Performance
- Complexity
- Recommended use cases

---

# 6. Hardware Master Documentation

## Hardware Command Master

### `parser_master.md`

Documents the current hardware master implementation.

Current behavior:

- Continuous READ generation
- Protocol-independent operation
- Placeholder architecture

Used for:

- Arbiter validation
- Multi-source testing

---

## Master Integration Guide

### `parser_master_integration.md`

Explains how custom command generators integrate with DexterLab.

Topics:

- `t_cmd_out`
- `t_rsp_out`
- `t_rsp_in`
- Arbiter interaction
- Response handling
- Ownership tracking

---

## Master Roadmap

### `roadmap_master.md`

Future directions for hardware command generation.

Potential integrations:

- SPI
- I²C
- UART
- CAN
- DMA engines
- RISC-V systems
- Ethernet
- Distributed command networks

---

# 7. Memory Map Documentation

## Address Map

### `DexterLab Address Map.md`

Defines the default memory layout.

Regions:

```text
REG
RAM
FIFO
```

Topics:

- Address ranges
- Command applicability
- Boundary rules
- Extension guidelines

---

# 8. Verification Documentation

## Testbench Architecture

### `DexterLab Testbench Architecture.md`

Complete simulation environment description.

Topics:

- Parser Engine
- Hardware Master
- Arbiter
- Backend Layer
- REG/RAM/FIFO Models
- DRY_RUN Integration
- TileLink Integration
- Regression Execution

---

## Simulation Environments

### `cmd_simulation_envs.md`

Supported environments:

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

Topics:

- Build flows
- Waveform support
- DRY_RUN execution
- CI integration

---

## Quickstart Guide

### `DexterLab Quickstart Guide.md`

Practical introduction to the framework.

Topics:

- Installation
- First simulation
- First command file
- Waveform debugging
- DRY_RUN usage
- Backend selection

Recommended for first-time users.

---

# 9. Reference Documentation

## Glossary

### `DexterLab Glossary.md`

Unified terminology reference.

Includes:

- Parser terminology
- Interface terminology
- Backend terminology
- Arbiter terminology
- Verification terminology
- Memory-map terminology

---

## Architecture Diagrams

### `architecture_diagrams.md`

Collection of architecture and execution-flow diagrams.

Topics:

- Parser pipeline
- Arbitration
- Backend selection
- Burst processing
- Polling
- FIFO operations
- Error propagation
- Verification architecture

---

## Documentation Overview

### `docs/README.md`

General entry point into the documentation tree.

---

# 10. Documentation Philosophy

The DexterLab documentation follows several principles.

### Modular

Each document focuses on a single subsystem.

### Protocol Independent

Command semantics remain identical across all supported backends.

### Verification Oriented

Documentation reflects actual HDL behavior.

### Extensible

New backends and command generators can be added without restructuring the framework.

### Simulator Neutral

Documentation applies equally to open-source and commercial simulators.

### Traceable

Parser, arbiter, backend and error-model behavior are documented consistently.

---

# 11. Recommended Reading Order

## New Users

```text
overview.md

cmd_file_format.md

command_set.md

cmd_interface.md

cmd_flow.md

cmd_errors.md

DexterLab Quickstart Guide.md

DexterLab Testbench Architecture.md
```

---

## Hardware Integrators

```text
DexterLab Backend Overview.md

DexterLab Arbiter Specification.md

parser_master_integration.md

tilelink_bridge.md

DexterLab Address Map.md
```

---

## Contributors

```text
DexterLab Parser Engine Internals.md

DexterLab Arbiter Specification.md

backend_generic.md

cmd_errors.md
```

---

# 12. Summary

The DexterLab documentation suite provides:

- Complete command-language documentation
- Complete parser documentation
- Complete arbiter specification
- Complete backend documentation
- Complete hardware-master documentation
- Complete memory-map documentation
- Complete verification documentation
- Quickstart materials
- Unified glossary
- Architecture diagrams

All documentation reflects the DexterLab v1.1.0 architecture:

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

and serves as the primary technical reference for development, verification, integration, and future expansion of the DexterLab ecosystem.

---

# End of Document
