# DexterLab Command Parser — Overview

The DexterLab Command Parser is a protocol-independent command execution framework designed for hardware verification, simulation, validation, and system integration.

The framework provides a unified command model that remains independent of the underlying bus protocol and execution backend.

Commands may originate from:

- Command files (`.cmd`)
- Hardware masters
- DMA engines
- Processors
- Testbench generators
- Future external command sources

All command producers ultimately generate the same command interface and share the same execution infrastructure.

Supported execution targets include:

- AXI-FULL
- AXI-LITE
- AHB-FULL
- AHB-LITE
- Generic Backend

Additional protocol integration is available through:

- TileLink Bridge

---

# 1. System Architecture

The DexterLab architecture is built around three primary layers:

```text
Command Sources
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

---

## Parser Engine

The Parser Engine converts command scripts into executable transactions.

Primary input:

```text
.cmd files
```

Primary outputs:

```text
t_cmd_out
t_rsp_out
```

Primary input response channel:

```text
t_rsp_in
```

Responsibilities include:

- Command parsing
- Variable processing
- Include handling
- Syntax validation
- Semantic validation
- Micro-command generation
- Command construction

The parser is completely protocol-independent.

---

## Hardware Masters

Hardware command generators may also produce commands directly.

Examples include:

- RISC-V processors
- DMA engines
- FPGA logic
- Peripheral controllers
- Future remote command sources

Hardware masters use the same interfaces as the parser:

```text
t_cmd_out
t_rsp_out
t_rsp_in
```

and are arbitrated through the same execution path.

---

## Arbiter

The arbiter controls ownership of backend access.

Responsibilities include:

- Source arbitration
- Ownership management
- Pending-command tracking
- Locked command handling
- Response routing

The arbiter remains independent of the selected backend protocol.

---

## Backend Layer

Backends translate protocol-independent commands into protocol-specific transactions.

Available backends:

```text
backend_generic
backend_axi_full
backend_axi_lite
backend_ahb_full
backend_ahb_lite
```

Backends are responsible for:

- Bus transactions
- Protocol timing
- Error reporting
- Response generation

---

## TileLink Integration

TileLink support is provided through a dedicated bridge:

```text
tilelink_bridge
```

The bridge converts:

```text
TileLink
    ->
t_cmd_out
```

and:

```text
t_rsp_in
    ->
TileLink
```

The bridge is not a backend.

It acts as a command-source integration layer.

Supported TileLink variants:

```text
TL-UL
TL-UH
```

---

# 2. Conceptual Execution Flow

Command flow:

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
 Target Bus
      |
      v
 Peripheral
```

Response flow:

```text
Peripheral
      |
      v
 Target Bus
      |
      v
 Backend
      |
      v
 Arbiter
      |
      v
 Command Source
```

All command producers follow the same execution path.

---

# 3. Project Goals

The DexterLab framework is designed to:

- Provide a protocol-independent command model
- Support simulation and verification workflows
- Support multiple bus architectures
- Support burst transfers
- Support wrap transactions
- Support FIFO operations
- Support hardware-master integration
- Support future protocol expansion
- Simplify migration between bus protocols
- Provide deterministic execution behavior
- Maintain unified error reporting

---

# 4. Configuration Framework

Global configuration is centralized in:

```text
cmd_cfg.vhd
```

Configuration includes:

- Address width
- Data width
- Command ID width
- Timeout values
- Parser limits
- Include limits
- Logging controls
- Internal buffer sizes

Documentation:

```text
docs/cmd_cfg.md
```

---

# 5. Common Execution Model

All supported backends follow the same execution model.

```text
Phase 1
--------
Command execution

Phase 2
--------
Response publication

Phase 3
--------
Command completion
```

Completion is reported using:

```text
rsp_end_cmd
```

This model guarantees:

- Deterministic execution
- Consistent response behavior
- Protocol-independent command semantics
- Unified error handling

---

# 6. Available Backends

## backend_generic

Protocol-independent simulation backend.

Features:

- Pure VHDL implementation
- Fast execution
- WSTRB support
- Burst support
- Wrap support
- FIFO support
- Verification-oriented memory models

Typical use cases:

- Development
- Regression testing
- Continuous integration

---

## backend_axi_full

Complete AXI4 backend.

Features:

- AXI4 protocol support
- Multi-beat transfers
- Wrap bursts
- WSTRB support
- Timeout detection
- Multi-ID support
- AXI compliance checking

Typical use:

- High-performance systems
- DMA verification
- FPGA subsystems

---

## backend_axi_lite

AXI-Lite backend.

Features:

- Single-beat transfers
- MMIO operation
- WSTRB support
- Timeout handling

Typical use:

- Control registers
- Lightweight peripherals

---

## backend_ahb_full

Complete AHB backend.

Features:

- HBURST support
- Multi-beat transfers
- Wrap bursts
- Wait-state handling
- Timeout detection

Typical use:

- Embedded systems
- Deterministic interconnects

---

## backend_ahb_lite

AHB-Lite backend.

Features:

- Internal burst sequencing
- Wrap address generation
- Wait-state support
- Timeout detection

Characteristics:

- No HBURST signaling
- Backend-managed burst execution
- Full parser compatibility

Typical use:

- MCU environments
- Lightweight systems
- Verification platforms

---

# 7. Unified Command Interface

All command sources and backends share the same interfaces.

---

## Command Interface

```text
t_cmd_out
```

Contains:

- Read/write operation
- Address
- Transfer length
- Burst attributes
- Wrap attributes
- FIFO attributes
- Write strobes
- Protocol attributes
- Lock information
- Command identifiers

---

## Response Control Interface

```text
t_rsp_out
```

Provides:

- Response acceptance
- Error-response acceptance

---

## Response Interface

```text
t_rsp_in
```

Contains:

- Response data
- Command completion
- Error information
- Response identifiers

This unified model allows any command source to execute through any backend.

---

# 8. Error Handling

Runtime error reporting is unified across all supported backends.

Error groups include:

```text
AXI_FULL : 0–15
AXI_LITE : 16–31

AHB_FULL : 32–47
AHB_LITE : 48–63
```

Supported categories include:

- OKAY
- SLVERR / ERROR
- DECERR
- TIMEOUT
- PROT_ERR
- BOUNDARY_ERR
- BURST_ERR
- ID_ERR
- WSTRB_ERR

Parser and semantic validation errors are documented separately.

Complete reference:

```text
docs/cmd_errors.md
```

---

# 9. Supported Command Families

The parser supports:

---

## Basic Operations

```text
READ
WRITE
CHECK
WSTRB_WRITE
```

---

## Burst Operations

```text
BURST_READ
BURST_WRITE
BURST_CHECK
```

---

## Wrap Operations

```text
WRAP_READ
WRAP_WRITE
WRAP_CHECK
```

---

## FIFO Operations

```text
FIFO_READ
FIFO_WRITE
FIFO_CHECK
```

---

## Fill Operations

```text
FILL_LEN
FILL_RANGE
FILL_CHECK
```

---

## Poll Operations

```text
POLL_READ
POLL_TOGGLE
```

---

## Dump Operations

```text
DUMP_LEN
DUMP_RANGE

DUMP_FILE_LEN
DUMP_FILE_RANGE

DUMP_FILE_CHECK_LEN
DUMP_FILE_CHECK_RANGE
```

---

## Utility Operations

```text
PRINT
INCLUDE

WAIT_TIME
WAIT_CLOCKS
WAIT_SIM_TIME

STOP
END_SIM

TEST_ERROR
```

Detailed reference:

```text
docs/command_set.md
```

---

# 10. Hardware Master Integration

DexterLab is designed to support multiple command producers.

Potential integrations include:

- RISC-V processors
- DMA engines
- FPGA accelerators
- Embedded controllers
- Remote command generators

All command producers use:

```text
t_cmd_out
t_rsp_out
t_rsp_in
```

and share backend access through the arbiter.

The arbiter provides:

- Ownership tracking
- Pending-command handling
- Locked execution through `cmd_lock`
- Response routing

---

# 11. Verification Infrastructure

The DexterLab verification environment includes:

- Parser Engine
- Hardware Master
- Arbiter
- Backend implementations
- Register models
- RAM models
- FIFO models
- Error injection support
- Regression suites

Supported simulators:

- GHDL
- Vivado / XSIM
- QuestaSim
- ModelSim
- Riviera-PRO
- Xcelium
- VCS

---

# 12. Documentation Structure

Primary documentation includes:

```text
overview.md
cmd_cfg.md
cmd_interface.md
cmd_flow.md
cmd_errors.md
command_set.md

DexterLab Parser Engine Internals.md
DexterLab Testbench Architecture.md
DexterLab Address Map.md

backend_generic.md
backend_axi_full.md
backend_axi_lite.md
backend_ahb_full.md
backend_ahb_lite.md

tilelink_bridge.md

DexterLab Arbiter Specification.md
master_arbiter.md
```

Recommended entry points:

```text
README.md
docs/README.md
DexterLab Documentation Index.md
```

---

# 13. Summary

The DexterLab Command Parser ecosystem provides:

- Protocol-independent command execution
- Unified command interfaces
- Multi-source command generation
- Deterministic arbitration
- Unified backend integration
- Consistent error reporting
- Rich verification infrastructure
- Multi-protocol support
- Hardware-master integration
- Future extensibility

The architecture:

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

forms the common foundation for all current and future DexterLab components.

---

# End of Document
