# DexterLab Command Parser — Command Set

This document defines the complete command set supported by the DexterLab Command Parser.

The command language is protocol-independent and is converted into a unified command interface (`t_cmd_out`) before execution by the selected backend.

Supported execution targets include:

- Generic Backend
- AXI-FULL
- AXI-LITE
- AHB-FULL
- AHB-LITE
- Future protocol integrations

---

# 1. Command Categories

The command set is divided into the following categories:

| Category | Purpose |
|-----------|----------|
| Configuration | Variables and parser configuration |
| File Control | Include external command files |
| Timing | Simulation delays and waits |
| Basic Memory Access | READ, WRITE, CHECK |
| WSTRB Access | Partial writes |
| FIFO Operations | FIFO-oriented transfers |
| Burst Operations | Multi-beat incrementing transfers |
| Wrap Operations | Wrapping burst transfers |
| Fill Operations | Pattern generation |
| Poll Operations | Status polling |
| Dump Operations | Memory export and verification |
| Error Injection | Backend error testing |
| Simulation Control | STOP and END_SIM |

---

# 2. Command Enumeration

The parser currently supports:

```text
CMD_NOP

CMD_SET_VAR
CMD_INCLUDE
CMD_PRINT
CMD_END_SIM

CMD_SET_ATOMIC

CMD_WAIT_TIME
CMD_WAIT_CLOCKS
CMD_WAIT_SIM_TIME

CMD_WSTRB_WRITE

CMD_WRITE
CMD_READ
CMD_CHECK

CMD_FIFO_WRITE
CMD_FIFO_READ
CMD_FIFO_CHECK

CMD_BURST_WRITE
CMD_BURST_READ
CMD_BURST_CHECK

CMD_WRAP_WRITE
CMD_WRAP_READ
CMD_WRAP_CHECK

CMD_FILL_LEN
CMD_FILL_RANGE
CMD_FILL_CHECK

CMD_POLL_READ
CMD_POLL_TOGGLE

CMD_TEST_ERROR

CMD_DUMP_LEN
CMD_DUMP_RANGE
CMD_DUMP_FILE_LEN
CMD_DUMP_FILE_RANGE
CMD_DUMP_FILE_CHECK_LEN
CMD_DUMP_FILE_CHECK_RANGE

CMD_STOP

CMD_UNKNOWN
```

---

# 3. Configuration Commands

## SET_VAR

Assigns a parser variable.

### Syntax

```text
SET_VAR <name> <value>
```

### Example

```text
SET_VAR BASE_RAM 0x1000
```

### Purpose

Variables may later be used in expressions and addresses.

---

## SET_ATOMIC

Controls arbiter atomic locking.

### Syntax

```text
SET_ATOMIC <0|1>
```

### Examples

```text
SET_ATOMIC 1
```

```text
SET_ATOMIC 0
```

### Description

When enabled:

```text
cmd_lock = 1
```

is propagated through generated commands.

The arbiter prevents source switching until atomic mode is released.

---

# 4. File Commands

## INCLUDE

Loads and executes another command file.

### Syntax

```text
INCLUDE <filename>
```

### Example

```text
INCLUDE init_memory.cmd
```

---

# 5. Utility Commands

## PRINT

Writes a message to the log.

### Syntax

```text
PRINT <text>
```

### Example

```text
PRINT Initialization completed
```

---

# 6. Wait Commands

These commands suspend execution without generating bus activity.

---

## WAIT_TIME

### Syntax

```text
WAIT_TIME <value> <unit>
```

### Examples

```text
WAIT_TIME 100 ns
```

```text
WAIT_TIME 10 us
```

---

## WAIT_CLOCKS

### Syntax

```text
WAIT_CLOCKS <count>
```

### Example

```text
WAIT_CLOCKS 100
```

---

## WAIT_SIM_TIME

### Syntax

```text
WAIT_SIM_TIME <value>
```

### Example

```text
WAIT_SIM_TIME 500
```

---

# 7. Basic Memory Commands

## WRITE

Writes one data word.

### Syntax

```text
WRITE <addr> <data>
```

### Example

```text
WRITE 0x1000 0x12345678
```

---

## READ

Reads one data word.

### Syntax

```text
READ <addr>
```

### Example

```text
READ 0x1000
```

---

## CHECK

Reads and compares against an expected value.

### Syntax

```text
CHECK <addr> <expected>
```

### Example

```text
CHECK 0x1000 0x12345678
```

---

# 8. WSTRB_WRITE

Performs a write using an explicit write strobe mask.

### Syntax

```text
WSTRB_WRITE <addr> <data> <wstrb>
```

### Example

```text
WSTRB_WRITE 0x1000 0xAABBCCDD 0x1
```

### Purpose

Allows validation of byte-enable behavior.

Used primarily by:

- AXI-FULL
- AXI-LITE

---

# 9. FIFO Commands

## FIFO_WRITE

### Syntax

```text
FIFO_WRITE <addr> <len> <data>
```

### Example

```text
FIFO_WRITE 0x3000 8 0x55
```

Writes multiple entries into a FIFO.

---

## FIFO_READ

### Syntax

```text
FIFO_READ <addr> <len>
```

### Example

```text
FIFO_READ 0x3100 8
```

Reads multiple FIFO entries.

---

## FIFO_CHECK

### Syntax

```text
FIFO_CHECK <addr> <len> <expected>
```

### Example

```text
FIFO_CHECK 0x3100 8 0x55
```

Reads and verifies FIFO contents.

---

# 10. Burst Commands

Burst commands generate incrementing multi-beat transfers.

---

## BURST_WRITE

### Syntax

```text
BURST_WRITE <len> <addr> <data...>
```

### Example

```text
BURST_WRITE 4 0x1000
    0x01
    0x02
    0x03
    0x04
```

---

## BURST_READ

### Syntax

```text
BURST_READ <len> <addr>
```

### Example

```text
BURST_READ 16 0x1000
```

---

## BURST_CHECK

### Syntax

```text
BURST_CHECK <len> <addr> <expected...>
```

### Example

```text
BURST_CHECK 4 0x1000
```

---

# 11. Wrap Commands

Wrap commands use wrapping address generation.

---

## WRAP_WRITE

### Syntax

```text
WRAP_WRITE <wrap_size> <addr> <data...>
```

### Example

```text
WRAP_WRITE 8 0x2000
```

---

## WRAP_READ

### Syntax

```text
WRAP_READ <wrap_size> <addr>
```

### Example

```text
WRAP_READ 8 0x2000
```

---

## WRAP_CHECK

### Syntax

```text
WRAP_CHECK <wrap_size> <addr> <expected...>
```

### Example

```text
WRAP_CHECK 8 0x2000
```

---

# 12. Fill Commands

Fill commands repeatedly write a pattern.

---

## FILL_LEN

### Syntax

```text
FILL_LEN <addr> <len> <pattern>
```

### Example

```text
FILL_LEN 0x1000 1024 0xDEADBEEF
```

---

## FILL_RANGE

### Syntax

```text
FILL_RANGE <start_addr> <end_addr> <pattern>
```

### Example

```text
FILL_RANGE 0x1000 0x1FFF 0xAAAAAAAA
```

---

## FILL_CHECK

### Syntax

```text
FILL_CHECK <addr> <len> <pattern>
```

### Example

```text
FILL_CHECK 0x1000 1024 0xDEADBEEF
```

---

# 13. Poll Commands

Poll commands repeatedly read until a condition is satisfied.

---

## POLL_READ

### Syntax

```text
POLL_READ <addr> <mask> <value> <attempts> <delay>
```

### Example

```text
POLL_READ 0x4000 0x1 0x1 100 10
```

Condition:

```text
(read_value & mask) = value
```

---

## POLL_TOGGLE

### Syntax

```text
POLL_TOGGLE <addr> <mask> <attempts> <delay>
```

### Example

```text
POLL_TOGGLE 0x4000 0x1 100 10
```

Waits for the selected bits to change state.

---

# 14. Dump Commands

Dump commands read memory and optionally export or verify contents.

---

## DUMP_LEN

### Syntax

```text
DUMP_LEN <addr> <len>
```

---

## DUMP_RANGE

### Syntax

```text
DUMP_RANGE <start_addr> <end_addr>
```

---

## DUMP_FILE_LEN

### Syntax

```text
DUMP_FILE_LEN <addr> <len> <filename>
```

---

## DUMP_FILE_RANGE

### Syntax

```text
DUMP_FILE_RANGE <start_addr> <end_addr> <filename>
```

---

## DUMP_FILE_CHECK_LEN

### Syntax

```text
DUMP_FILE_CHECK_LEN <addr> <len> <filename>
```

---

## DUMP_FILE_CHECK_RANGE

### Syntax

```text
DUMP_FILE_CHECK_RANGE <start_addr> <end_addr> <filename>
```

---

# 15. Error Injection

## TEST_ERROR

Injects a backend error condition.

### Syntax

```text
TEST_ERROR <addr> <error_code>
```

### Example

```text
TEST_ERROR 0x1000 54
```

Example:

```text
54 = AHB_LITE BOUNDARY_ERR
```

Used for:

- Regression testing
- Error-path validation
- Backend verification

---

# 16. Simulation Control

## STOP

Stops command execution.

### Syntax

```text
STOP
```

---

## END_SIM

Terminates simulation.

### Syntax

```text
END_SIM
```

---

# 17. Unknown Commands

Unrecognized commands are mapped internally to:

```text
CMD_UNKNOWN
```

and reported as parser errors.

---

# 18. Common Rules

## Alignment Requirements

Commands accessing memory must satisfy alignment requirements appropriate for the configured data width.

---

## Burst Limits

Backend implementations may split large operations internally.

Typical maximum burst size:

```text
256 beats
```

---

## Wrap Operations

Wrap size must satisfy protocol requirements.

Typical values:

```text
2
4
8
16
```

---

## Atomic Mode

Atomic execution is controlled through:

```text
SET_ATOMIC
```

and enforced by the arbiter.

---

# 19. Summary

The DexterLab command language supports:

- Configuration commands
- File inclusion
- Timing controls
- Read/write operations
- WSTRB accesses
- FIFO operations
- Burst transfers
- Wrap transfers
- Fill operations
- Polling operations
- Dump operations
- Error injection
- Simulation control

All commands are converted into the protocol-independent `t_cmd_out` interface and executed through the selected backend.

---

# End of Document
