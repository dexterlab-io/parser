# DexterLab Documentation

This directory contains the complete documentation for the DexterLab command ecosystem.

The documentation covers:

- Parser architecture
- Command language
- Command interfaces
- Error handling
- Arbitration
- Backend implementations
- Memory models
- Simulation environments
- Hardware master integration
- TileLink integration
- Verification infrastructure
- Future roadmap items

Documentation is organized into independent modules so that each topic can be read separately while remaining consistent with the overall architecture.

---

# 1. Getting Started

If you are new to DexterLab, the recommended reading order is:

1. `overview.md`
2. `cmd_file_format.md`
3. `command_set.md`
4. `cmd_interface.md`
5. `cmd_flow.md`
6. `cmd_errors.md`
7. Backend documentation for your target protocol

This sequence provides a complete understanding of how commands are parsed, validated, executed, and translated into protocol-specific transactions.

---

# 2. Core Architecture Documentation

## System Overview

### `overview.md`

High-level description of the DexterLab architecture.

Topics include:

- Parser
- Arbiter
- Backend layer
- Supported protocols
- Command execution model
- Hardware master support

Recommended entry point for new users.

---

## Configuration Package

### `cmd_cfg.md`

Describes global configuration parameters defined in:

```text
cmd_cfg.vhd
```

Including:

- Address width
- Data width
- Timeout configuration
- Include depth
- Parser limits
- Source identifiers
- Base types

---

## Command Interface

### `cmd_interface.md`

Formal specification of the DexterLab interfaces:

```text
t_cmd_out
t_rsp_out
t_rsp_in
```

Including:

- Field definitions
- Handshake rules
- Response semantics
- Flow-control behavior
- Lock semantics

---

## Command Flow

### `cmd_flow.md`

Describes the execution pipeline:

```text
Command
   |
Parser
   |
Arbiter
   |
Backend
   |
Response
```

Including:

- Command execution
- Response publication
- Command completion

---

## Error Model

### `cmd_errors.md`

Defines the unified DexterLab error database.

Coverage includes:

- Parser errors
- Semantic errors
- AXI-FULL errors
- AXI-LITE errors
- AHB-FULL errors
- AHB-LITE errors

---

## Command Set Reference

### `command_set.md`

Reference for all supported commands.

Includes:

- READ / WRITE / CHECK
- BURST operations
- WRAP operations
- FIFO operations
- FILL operations
- POLL operations
- DUMP operations
- TEST_ERROR
- Utility commands

---

# 3. Command File Documentation

## Command File Format

### `cmd_file_format.md`

Specification of DexterLab command files.

Topics:

- Syntax
- Variables
- Operators
- Includes
- Comments
- Expressions

---

## DRY_RUN Mode

### `cmd_dry_run.md`

Parser-only validation mode.

Functions:

- Parse commands
- Validate syntax
- Validate semantics
- Generate normalized output

Without:

- Arbiter access
- Backend execution
- Bus transactions

---

# 4. Parser Documentation

## Parser Engine Internals

### `DexterLab Parser Engine Internals.md`

Detailed description of internal parser architecture.

Topics:

- Tokenizer
- Decoder
- Validation
- Variable engine
- Include engine
- Micro-command generation
- Command builder
- Poll engine
- Dump engine
- Atomic command handling

---

# 5. Backend Documentation

Backend modules translate the protocol-independent command model into protocol-specific transactions.

---

## Generic Backend

### `backend_generic.md`

Reference backend used for parser validation and fast simulation.

Features:

- Protocol-independent execution
- Memory-model testing
- Fast regression support

---

## AXI-FULL Backend

### `backend_axi_full.md`

Features:

- AXI4 protocol
- Multi-beat bursts
- Wrap support
- Timeout handling
- WSTRB support
- Full AXI transaction model

---

## AXI-LITE Backend

### `backend_axi_lite.md`

Features:

- Single-beat transfers
- MMIO-style accesses
- WSTRB support
- Simplified execution model

---

## AHB-FULL Backend

### `backend_ahb_full.md`

Features:

- HBURST support
- Multi-beat transfers
- Wait-state handling
- Wrap support
- Timeout management

---

## AHB-LITE Backend

### `backend_ahb_lite.md`

Features:

- Internal burst sequencing
- Wrap address generation
- Standard AHB-Lite signaling
- Timeout management

---

## TileLink Bridge

### `tilelink_bridge.md`

Provides TileLink integration.

Topics:

- TL-UL
- TL-UH
- `t_cmd_out` mapping
- `t_rsp_in` mapping
- RISC-V interoperability

---

## Backend Overview

### `DexterLab Backend Overview.md`

High-level description of backend architecture.

Topics:

- Backend responsibilities
- Protocol independence
- Execution model
- Error propagation

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

# 6. Arbiter Documentation

## Multi-Source Arbiter

### `master_arbiter.md`

Practical description of arbiter operation.

Topics:

- Source ownership
- Pending commands
- Locked command sequences
- Command routing
- Response routing

---

## Arbiter Specification

### `DexterLab Arbiter Specification.md`

Formal specification of arbiter behavior.

Topics:

- FSM architecture
- Ownership tracking
- Pending-command handling
- Response routing
- Lock handling through `cmd_lock`

---

# 7. Hardware Master Documentation

## Hardware Command Master

### `parser_master.md`

Describes the current hardware command master.

Topics:

- Placeholder implementation
- Continuous READ generation
- Future evolution

---

## Master Integration Guide

### `parser_master_integration.md`

Explains how to integrate custom hardware masters.

Topics:

- `t_cmd_out`
- `t_rsp_out`
- `t_rsp_in`
- Arbiter interaction
- Backend independence

---

## Master Roadmap

### `roadmap_master.md`

Long-term evolution of hardware command generation.

Topics:

- Peripheral integration
- DMA engines
- RISC-V support
- Distributed command systems
- Multi-master architectures

---

# 8. Verification Documentation

## Testbench Architecture

### `DexterLab Testbench Architecture.md`

Complete simulation environment documentation.

Topics:

- Parser
- Master
- Arbiter
- Backend
- Memory models
- Regression flow
- TileLink integration

---

## Simulation Environments

### `cmd_simulation_envs.md`

Supported simulators:

- GHDL
- Vivado / XSIM
- QuestaSim
- ModelSim
- Riviera-PRO
- Xcelium
- VCS

Configuration and workflow recommendations for each environment.

---

# 9. Reference Documentation

## Address Map

### `DexterLab Address Map.md`

Defines the default memory map:

```text
REG
RAM
FIFO
```

Including:

- Region descriptions
- Command applicability
- Boundary rules
- Extension guidelines

---

## Glossary

### `DexterLab Glossary.md`

Definitions of terms and acronyms used throughout the project.

---

## Documentation Index

### `DexterLab Documentation Index.md`

Alternative categorized index of all documentation files.

---

## Architecture Diagrams

### `architecture_diagrams.md`

Collection of architectural and execution-flow diagrams used throughout the documentation.

---

# 10. Deprecated Architecture

The legacy wrapper architecture has been removed from DexterLab.

Previous components:

```text
cmd_wrapper_axi_full
cmd_wrapper_axi_lite
cmd_wrapper_ahb_full
cmd_wrapper_ahb_lite
```

are no longer part of the supported architecture.

Current architecture:

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

As a result:

```text
wrapper_overview.md
```

is considered deprecated historical documentation and should not be used as a reference for current designs.

---

# 11. Documentation Philosophy

DexterLab documentation follows several principles.

### Modular

Each document focuses on a specific subsystem.

### Protocol Independent

Command semantics remain identical across bus protocols.

### Verification Oriented

Documentation reflects actual HDL behavior.

### Extensible

New protocols and masters can be added without restructuring the framework.

### Simulator Neutral

Documentation applies equally to open-source and commercial simulators.

### Traceable

Parser behavior, arbitration behavior, backend behavior, and error handling are documented consistently.

---

# 12. Summary

The `docs/` directory provides complete documentation for:

- Parser architecture
- Command language
- Configuration
- Error management
- Arbitration
- Hardware masters
- Backend implementations
- Memory models
- Simulation environments
- TileLink integration
- Verification infrastructure

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

and serves as the primary technical reference for development, simulation, verification, and future system integration.

---

# End of Document
