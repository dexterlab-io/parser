# DexterLab Command File Format (`.cmd`)

DexterLab uses plain-text command files (`.cmd`) to describe command sequences executed through the unified DexterLab command architecture.

Command files are parsed by the Parser Engine and converted into protocol-independent transactions using:

```text
t_cmd_out
```

The same command file can be executed through any supported backend:

- Generic Backend
- AXI-FULL
- AXI-LITE
- AHB-FULL
- AHB-LITE

This document defines the syntax, formatting rules, supported command structures, and recommended practices for DexterLab command files.

---

# 1. File Structure

A command file is composed of:

- One command per line
- Optional comments
- Optional blank lines
- Optional indentation
- Optional variable definitions
- Optional include directives

The parser ignores:

- Leading spaces
- Trailing spaces
- Empty lines
- Comment-only lines

---

## Example

```text
# Register initialization

WRITE 0x1000 0x12345678

READ 0x1000
```

---

# 2. Comments

Comments begin with:

```text
#
```

Everything following the `#` character is ignored.

---

## Comment Examples

```text
# Full-line comment

WRITE 0x1000 0x55     # Inline comment
```

---

# 3. Whitespace Rules

The parser accepts:

- Multiple spaces
- Tabs
- Indentation

All following examples are equivalent:

```text
WRITE 0x1000 0x55
```

```text
WRITE      0x1000      0x55
```

```text
    WRITE 0x1000 0x55
```

---

# 4. Numeric Formats

DexterLab supports multiple numeric formats.

---

## Hexadecimal

```text
0x1000
0xDEADBEEF
```

Recommended format.

---

## Decimal

```text
4096
3735928559
```

---

## Binary

```text
0b0001
0b10101010
```

Typically used for:

```text
WSTRB_WRITE
Masks
Polling commands
```

---

# 5. Variables

Variables are created through:

```text
SET_VAR
```

and may be used in later expressions.

---

## Definition

```text
SET_VAR BASE_RAM 0x1000
```

---

## Usage

```text
WRITE BASE_RAM 0x12345678
```

---

## Arithmetic

Supported operators:

```text
+
-
```

Example:

```text
SET_VAR REG_BASE 0x1000

WRITE REG_BASE + 0x20 0x55
```

---

# 6. Include Files

Command files may include other command files.

Syntax:

```text
INCLUDE initialization.cmd
```

Example:

```text
INCLUDE globals.cmd

INCLUDE memory_init.cmd

INCLUDE tests/burst_test.cmd
```

Include nesting is supported up to the configured limit.

---

# 7. Command Categories

The DexterLab parser supports the command families described below.

---

# 8. Utility Commands

## PRINT

Prints a message.

```text
PRINT Starting initialization
```

---

## WAIT_TIME

```text
WAIT_TIME 100 ns
```

---

## WAIT_CLOCKS

```text
WAIT_CLOCKS 50
```

---

## WAIT_SIM_TIME

```text
WAIT_SIM_TIME 1000
```

---

## STOP

```text
STOP
```

Stops command execution.

---

## END_SIM

```text
END_SIM
```

Terminates simulation.

---

# 9. Atomic Commands

Atomic execution is controlled using:

```text
SET_ATOMIC
```

---

## Enable Atomic Mode

```text
SET_ATOMIC 1
```

---

## Disable Atomic Mode

```text
SET_ATOMIC 0
```

---

## Example

```text
SET_ATOMIC 1

WRITE 0x1000 0xAAAA5555

WRITE 0x1004 0x12345678

SET_ATOMIC 0
```

Commands generated inside an atomic block produce:

```text
cmd_lock = 1
```

and ownership retention is enforced by the arbiter.

---

# 10. Basic Memory Commands

## WRITE

Writes one data word.

Syntax:

```text
WRITE <addr> <data>
```

Example:

```text
WRITE 0x1000 0x12345678
```

---

## READ

Reads one data word.

Syntax:

```text
READ <addr>
```

Example:

```text
READ 0x1000
```

---

## CHECK

Reads and compares against an expected value.

Syntax:

```text
CHECK <addr> <expected>
```

Example:

```text
CHECK 0x1000 0x12345678
```

---

## WSTRB_WRITE

Performs a partial write using a write strobe.

Syntax:

```text
WSTRB_WRITE <addr> <data> <wstrb>
```

Example:

```text
WSTRB_WRITE 0x1000 0xAABBCCDD 0b0001
```

---

# 11. FIFO Commands

## FIFO_WRITE

Syntax:

```text
FIFO_WRITE <addr> <len> <data...>
```

Example:

```text
FIFO_WRITE 0x3000 4
    0x11
    0x22
    0x33
    0x44
```

---

## FIFO_READ

Syntax:

```text
FIFO_READ <addr> <len>
```

Example:

```text
FIFO_READ 0x3100 4
```

---

## FIFO_CHECK

Syntax:

```text
FIFO_CHECK <addr> <len> <expected...>
```

Example:

```text
FIFO_CHECK 0x3100 4
    0x11
    0x22
    0x33
    0x44
```

---

# 12. Burst Commands

Burst commands use incrementing addresses.

---

## BURST_WRITE

Syntax:

```text
BURST_WRITE <len> <addr> <data...>
```

Example:

```text
BURST_WRITE 4 0x1000
    0xAA
    0xBB
    0xCC
    0xDD
```

---

## BURST_READ

Syntax:

```text
BURST_READ <len> <addr>
```

Example:

```text
BURST_READ 16 0x1000
```

---

## BURST_CHECK

Syntax:

```text
BURST_CHECK <len> <addr> <expected...>
```

Example:

```text
BURST_CHECK 4 0x1000
    0xAA
    0xBB
    0xCC
    0xDD
```

---

# 13. Wrap Commands

Wrap commands use wrapping bursts.

---

## WRAP_WRITE

Syntax:

```text
WRAP_WRITE <wrap_size> <addr> <data...>
```

Example:

```text
WRAP_WRITE 8 0x2000
    0x01
    0x02
    0x03
    0x04
```

---

## WRAP_READ

Syntax:

```text
WRAP_READ <wrap_size> <addr>
```

Example:

```text
WRAP_READ 8 0x2000
```

---

## WRAP_CHECK

Syntax:

```text
WRAP_CHECK <wrap_size> <addr> <expected...>
```

Example:

```text
WRAP_CHECK 8 0x2000
```

---

# 14. Fill Commands

## FILL_LEN

Syntax:

```text
FILL_LEN <addr> <len> <pattern>
```

Example:

```text
FILL_LEN 0x1000 256 0xDEADBEEF
```

---

## FILL_RANGE

Syntax:

```text
FILL_RANGE <start_addr> <end_addr> <pattern>
```

Example:

```text
FILL_RANGE 0x1000 0x1FFF 0xAAAAAAAA
```

---

## FILL_CHECK

Syntax:

```text
FILL_CHECK <addr> <len> <pattern>
```

Example:

```text
FILL_CHECK 0x1000 256 0xDEADBEEF
```

---

# 15. Poll Commands

## POLL_READ

Syntax:

```text
POLL_READ <addr> <mask> <value> <attempts> <delay>
```

Example:

```text
POLL_READ 0x4000 0x1 0x1 100 10
```

Condition:

```text
(read_value & mask) == value
```

---

## POLL_TOGGLE

Syntax:

```text
POLL_TOGGLE <addr> <mask> <attempts> <delay>
```

Example:

```text
POLL_TOGGLE 0x4000 0x1 100 10
```

Waits for selected bits to change state.

---

# 16. Dump Commands

## DUMP_LEN

```text
DUMP_LEN <addr> <len>
```

---

## DUMP_RANGE

```text
DUMP_RANGE <start_addr> <end_addr>
```

---

## DUMP_FILE_LEN

```text
DUMP_FILE_LEN <addr> <len> <filename>
```

---

## DUMP_FILE_RANGE

```text
DUMP_FILE_RANGE <start_addr> <end_addr> <filename>
```

---

## DUMP_FILE_CHECK_LEN

```text
DUMP_FILE_CHECK_LEN <addr> <len> <filename>
```

---

## DUMP_FILE_CHECK_RANGE

```text
DUMP_FILE_CHECK_RANGE <start_addr> <end_addr> <filename>
```

---

# 17. Error Injection

## TEST_ERROR

Used for backend error-path testing.

Syntax:

```text
TEST_ERROR <addr> <error_code>
```

Example:

```text
TEST_ERROR 0x1000 54
```

---

# 18. Common Parser Errors

Typical parser failures include:

- Unknown command
- Missing arguments
- Invalid numeric values
- Undefined variables
- Invalid expressions
- Burst length mismatch
- Wrap configuration errors
- Include failures
- Address violations

Complete error definitions:

```text
cmd_errors.md
```

---

# 19. Complete Example

```text
# Variable definitions

SET_VAR BASE_RAM 0x1000

PRINT Starting test sequence

# Single accesses

WRITE BASE_RAM 0x12345678

READ BASE_RAM

CHECK BASE_RAM 0x12345678

# Burst operation

BURST_WRITE 4 BASE_RAM + 0x100
    0xAA
    0xBB
    0xCC
    0xDD

# Atomic sequence

SET_ATOMIC 1

WRITE BASE_RAM + 0x200 0xAAAA5555

WRITE BASE_RAM + 0x204 0x12345678

SET_ATOMIC 0

# Polling

POLL_READ BASE_RAM 0x1 0x1 100 10

# End simulation

END_SIM
```

---

# 20. Summary

A DexterLab `.cmd` file is a structured, human-readable description of command activity.

The format supports:

- Variables
- Include files
- Atomic execution
- Basic reads and writes
- Burst transfers
- Wrap transfers
- FIFO operations
- Fill operations
- Dump operations
- Polling commands
- Error injection
- Simulation control

The same command file can be executed through any supported backend while preserving identical command semantics.

---

# End of Document
