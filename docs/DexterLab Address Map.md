# DexterLab Address Map

(Version 2026 — Backend-Agnostic, Command-Driven Architecture)

The DexterLab Address Map defines the logical memory regions exposed by the Generic Backend and referenced throughout the DexterLab ecosystem.

These regions provide a common memory model for:

- Generic Backend
- AXI-FULL Backend
- AXI-LITE Backend
- AHB-FULL Backend
- AHB-LITE Backend
- TileLink Bridge integrations

The address map provides a consistent view of registers, memory and FIFO endpoints, while allowing each backend to implement protocol-specific access mechanisms.

---

# 1. Overview

The default DexterLab memory space is divided into three primary regions.

| Region | Address Range | Description |
|----------|----------|----------|
| REG | 0x0000–0x001F | Control and status registers |
| RAM | 0x1000–0x2FFF | General-purpose memory region |
| FIFO | 0x3000 / 0x3100 | FIFO write and read endpoints |

---

## Architecture

```text
Parser
   |
Arbiter
   |
Backend
   |
Address Map

REG
RAM
FIFO
```

The parser is protocol-independent and does not generate bus-specific transactions.

Backends are responsible for implementing protocol execution while preserving the logical behavior defined by this address map.

---

# 2. REG Region

## Address Range

```text
0x0000 – 0x001F
```

## Description

The register region contains eight 32-bit registers.

| Register | Address |
|----------|----------|
| REG0 | 0x0000 |
| REG1 | 0x0004 |
| REG2 | 0x0008 |
| REG3 | 0x000C |
| REG4 | 0x0010 |
| REG5 | 0x0014 |
| REG6 | 0x0018 |
| REG7 | 0x001C |

---

## Supported Commands

```text
READ
WRITE
CHECK

WSTRB_WRITE

SET_ATOMIC protected accesses
```

---

## Characteristics

- Single-beat accesses
- No burst execution
- No wrap execution
- No FIFO behavior
- No wait states in the Generic Backend
- Suitable for control and status registers

---

# 3. RAM Region

## Address Range

```text
0x1000 – 0x2FFF
```

## Description

The RAM region provides the primary memory space used for:

- Read/write testing
- Burst operations
- Wrap operations
- Fill operations
- Dump operations
- Polling operations

---

## Supported Commands

### Basic Accesses

```text
READ
WRITE
CHECK
WSTRB_WRITE
```

---

### Burst Operations

```text
BURST_READ
BURST_WRITE
BURST_CHECK
```

---

### Wrap Operations

```text
WRAP_READ
WRAP_WRITE
WRAP_CHECK
```

---

### Fill Operations

```text
FILL_LEN
FILL_RANGE
FILL_CHECK
```

---

### Dump Operations

```text
DUMP_LEN
DUMP_RANGE

DUMP_FILE_LEN
DUMP_FILE_RANGE

DUMP_FILE_CHECK_LEN
DUMP_FILE_CHECK_RANGE
```

---

### Poll Operations

```text
POLL_READ
POLL_TOGGLE
```

---

## Characteristics

- WSTRB support
- Incrementing burst support
- Wrap support
- Multi-beat transfers
- Error reporting
- Boundary validation

---

# 4. Boundary Rules

DexterLab validates memory transactions against configured rules before execution.

Large logical operations may be expanded into multiple executable micro-commands when required.

Examples include:

- Large burst transfers
- Large fill operations
- Large dump operations

This expansion process is handled by the parser infrastructure before command execution.

Additional details are documented in:

```text
DexterLab Parser Engine Internals.md
```

---

# 5. Wrap Operation Rules

Wrap commands are validated by the parser.

The parser verifies:

- Wrap size
- Alignment
- Command legality

Examples:

```text
WRAP_READ
WRAP_WRITE
WRAP_CHECK
```

Address generation itself is backend-specific.

The selected backend is responsible for implementing wrap addressing according to its protocol requirements.

Supported backends include:

- AXI-FULL
- AXI-LITE
- AHB-FULL
- AHB-LITE
- Generic Backend

---

# 6. FIFO Region

DexterLab exposes dedicated FIFO endpoints.

| Endpoint | Address | Description |
|----------|----------|----------|
| FIFO_WRITE | 0x3000 | Push data into FIFO |
| FIFO_READ | 0x3100 | Pop data from FIFO |

---

## Supported Commands

```text
FIFO_WRITE
FIFO_READ
FIFO_CHECK
```

---

## FIFO Semantics

### FIFO_WRITE

```text
FIFO_WRITE <addr> <len> ...
```

Pushes data into the FIFO.

---

### FIFO_READ

```text
FIFO_READ <addr> <len>
```

Removes entries from the FIFO.

---

### FIFO_CHECK

```text
FIFO_CHECK <addr> <len> ...
```

Reads and compares FIFO contents against expected values.

---

## Characteristics

- Dedicated FIFO endpoints
- Streaming semantics
- No wrap operations
- No address progression
- No memory-style bursts

Atomic ownership protection remains available through:

```text
SET_ATOMIC
```

which propagates:

```text
cmd_lock
```

to the arbiter.

---

# 7. Error Handling

Address-map violations and execution failures are reported through the unified DexterLab error infrastructure.

Possible failure categories include:

```text
Address Errors
Boundary Errors
Burst Errors
Protocol Errors
Timeout Errors
FIFO Errors
```

Specific error code assignments are backend-dependent and documented in:

```text
cmd_errors.md
```

---

# 8. Backend Independence

The logical address map remains identical regardless of the selected backend.

Execution paths:

```text
t_cmd_out
      |
      v
AXI-FULL
```

```text
t_cmd_out
      |
      v
AXI-LITE
```

```text
t_cmd_out
      |
      v
AHB-FULL
```

```text
t_cmd_out
      |
      v
AHB-LITE
```

```text
t_cmd_out
      |
      v
Generic Backend
```

The address map therefore remains stable while protocol behavior changes.

---

# 9. Extending the Address Map

Custom address regions may be added as required.

Typical extensions include:

- Peripheral register blocks
- Accelerator memories
- DMA descriptors
- Shared memory windows
- Hardware queues
- Streaming engines

Recommended guidelines:

1. Use a non-overlapping address range.
2. Define command support explicitly.
3. Define burst behavior explicitly.
4. Define wrap behavior explicitly.
5. Implement error reporting.
6. Update the documentation.

---

# 10. Address Map Summary

| Region | Range | Main Features |
|----------|----------|----------|
| REG | 0x0000–0x001F | Control and status registers |
| RAM | 0x1000–0x2FFF | WSTRB, burst, wrap, fill, dump, polling |
| FIFO | 0x3000 / 0x3100 | Streaming FIFO operations |

---

# 11. Summary

The DexterLab Address Map provides a simple and deterministic memory model shared across all supported backends.

It defines:

- Register space
- General-purpose RAM space
- FIFO endpoints
- Command applicability rules
- Boundary constraints
- Extension guidelines

The address map forms the logical foundation upon which all DexterLab command execution is built while remaining completely independent of the underlying bus protocol.

---

# End of Document
