# DexterLab Architecture Overview

(Version 2026 — Command-Driven Verification and Integration Framework)

DexterLab is a protocol-independent command execution framework designed for hardware verification, simulation, system integration, and future embedded control applications.

The framework provides a unified command model capable of driving multiple bus architectures through a common execution pipeline.

Rather than exposing bus-specific details to users, DexterLab abstracts all transactions into a single command interface, allowing the same command file, parser, and execution flow to operate across multiple protocols and system configurations.

Supported execution targets include:

- Generic Backend
- AXI-FULL
- AXI-LITE
- AHB-FULL
- AHB-LITE

Additional protocol integration is provided through:

- TileLink Bridge

---

# 1. Why DexterLab Exists

Hardware verification environments often suffer from fragmentation:

- AXI environments require AXI-specific tooling
- AHB environments require AHB-specific tooling
- Verification code becomes protocol-dependent
- Test reuse is limited
- Debugging becomes more complex

DexterLab solves this problem by introducing a common command layer between verification intent and protocol execution.

A single command sequence can be executed through multiple protocols without modification.

Example:

```text
WRITE 0x1000 0x12345678

CHECK 0x1000 0x12345678
```

The same command file may execute through:

```text
Generic Backend

AXI-FULL Backend

AXI-LITE Backend

AHB-FULL Backend

AHB-LITE Backend
```

without changing syntax or behavior.

---

# 2. Core Architecture

The entire framework is organized around a simple architecture:

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

Each block has a clearly defined responsibility.

---

# 3. Parser Layer

The Parser Engine transforms command files into protocol-independent transactions.

Input:

```text
.cmd files
```

Output:

```text
t_cmd_out
```

Responsibilities:

- Command parsing
- Variable expansion
- Include processing
- Syntax validation
- Semantic validation
- Command normalization
- Micro-command generation

The parser never generates protocol-specific transactions.

---

# 4. Hardware Masters

DexterLab supports command generation from hardware sources.

Examples:

- Microcontrollers
- DMA engines
- FPGA accelerators
- RISC-V processors
- Future remote systems

All command generators use the same interfaces:

```text
t_cmd_out
t_rsp_out
t_rsp_in
```

as the parser.

This ensures complete interoperability.

---

# 5. Arbiter Layer

The arbiter is responsible for backend ownership.

Responsibilities include:

- Source selection
- Ownership management
- Pending command tracking
- Response routing
- Locked command execution

The arbiter is completely protocol-independent.

Backends never know whether a command originated from:

```text
Parser
```

or:

```text
Hardware Master
```

---

# 6. Backend Layer

Backends convert protocol-independent commands into executable protocol behavior.

Available backends:

```text
backend_generic
backend_axi_full
backend_axi_lite
backend_ahb_full
backend_ahb_lite
```

Responsibilities:

- Command execution
- Protocol timing
- Transaction generation
- Error reporting
- Response generation

---

# 7. Unified Interfaces

The entire framework is built around three interfaces.

---

## Command Interface

```text
t_cmd_out
```

Carries:

- Command attributes
- Address information
- Transfer information
- Lock information
- Protocol attributes

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

Carries:

- Response data
- Error information
- Command completion status

---

# 8. Command Execution Model

Every backend implements the same execution model.

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

Command completion is indicated through:

```text
rsp_end_cmd
```

This provides deterministic behavior across all supported protocols.

---

# 9. Supported Operations

DexterLab commands are grouped into several categories.

Basic operations:

```text
READ
WRITE
CHECK
WSTRB_WRITE
```

Burst operations:

```text
BURST_READ
BURST_WRITE
BURST_CHECK
```

Wrap operations:

```text
WRAP_READ
WRAP_WRITE
WRAP_CHECK
```

FIFO operations:

```text
FIFO_READ
FIFO_WRITE
FIFO_CHECK
```

Additional categories include:

```text
POLL
FILL
DUMP
WAIT
INCLUDE
SET_VAR
TEST_ERROR
```

---

# 10. Memory Model

The default DexterLab memory map contains three logical regions.

```text
REG
RAM
FIFO
```

Address layout:

```text
REG         0x0000 - 0x001F

RAM         0x1000 - 0x2FFF

FIFO_WRITE  0x3000

FIFO_READ   0x3100
```

This memory model is shared by all verification environments.

---

# 11. Verification Philosophy

DexterLab follows several foundational principles.

---

## Protocol Independence

Command semantics must remain identical across protocols.

---

## Verification First

Simulation and verification drive architectural decisions.

---

## Single Command Model

One command language for all supported protocols.

---

## Backend Specialization

Protocol behavior belongs inside backends.

Not inside the parser.

---

## Deterministic Execution

Identical command files should produce equivalent behavior across supported environments.

---

## Extensibility

New protocols and masters can be added without modifying the command language.

---

# 12. Typical Use Cases

DexterLab may be used for:

### Protocol Verification

```text
AXI
AHB
TileLink
```

---

### Parser Validation

```text
Syntax
Semantics
Error handling
```

---

### Regression Testing

```text
Automated command suites
```

---

### Continuous Integration

```text
DRY_RUN validation
Generic Backend testing
```

---

### Future Embedded Applications

```text
RISC-V systems
DMA engines
Remote command execution
```

---

# 13. Future Evolution

Planned or possible future directions include:

- RISC-V command generation
- DMA-driven operations
- Ethernet integration
- Remote Control Protocol (RCP)
- Distributed command systems
- Multi-master infrastructures

The command architecture is intentionally designed to support long-term evolution without changing the command language.

---

# 14. Summary

DexterLab is a protocol-independent command execution framework that separates:

```text
Command Generation
```

from:

```text
Protocol Execution
```

through a simple architecture:

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

This approach provides:

- Reusable command files
- Backend independence
- Deterministic execution
- Unified error handling
- Scalable verification infrastructure
- Future hardware integration capabilities

It forms the architectural foundation for the entire DexterLab ecosystem.

---

# End of Document
