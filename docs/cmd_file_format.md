# DexterLab Command File Format (`.cmd`)
DexterLab uses plain-text command files (`.cmd`) to describe sequences of bus
operations.  
These files are parsed by the DexterLab command parser and converted into
high‑level hardware commands (`t_cmd_out`).

This document defines the syntax, structure, allowed commands, and examples of
valid `.cmd` files.

---

# 1. File Structure

A `.cmd` file is composed of:

- one command per line,
- optional comments,
- optional blank lines,
- optional indentation.

The parser ignores:

- leading/trailing spaces,
- empty lines,
- comment lines starting with `#`.

Example:

This is a comment
WRITE 0x80000000 0xDEADBEEF
READ  0x80000000

Codice

---

# 2. Address Format

Addresses may be written as:

- hexadecimal: `0x80000000`
- decimal: `2147483648`

Hexadecimal is recommended.

---

# 3. Data Format

Data fields may be written as:

- hexadecimal: `0xDEADBEEF`
- decimal: `3735928559`

For burst commands, multiple data words are separated by spaces:

BURST_WRITE 0x1000 4  0x01 0x02 0x03 0x04

Codice

---

# 4. Supported Commands

The parser supports the following commands:

## 4.1 WRITE
Writes a single word.

WRITE <addr> <data>

Codice

Example:

WRITE 0x80000000 0x12345678

Codice

---

## 4.2 READ
Reads a single word.

READ <addr>

Codice

Example:

READ 0x80000000

Codice

---

## 4.3 BURST_WRITE
Writes multiple words sequentially.

BURST_WRITE <addr> <len> <data0> <data1> ... <dataN>

Codice

Example:

BURST_WRITE 0x1000 4  0xAA 0xBB 0xCC 0xDD

Codice

---

## 4.4 BURST_READ
Reads multiple words sequentially.

BURST_READ <addr> <len>

Codice

Example:

BURST_READ 0x2000 8

Codice

---

## 4.5 WRAP_WRITE
Writes a wrap burst.

WRAP_WRITE <addr> <len> <data...>

Codice

Example:

WRAP_WRITE 0x3000 4  0x01 0x02 0x03 0x04

Codice

---

## 4.6 WRAP_READ
Reads a wrap burst.

WRAP_READ <addr> <len>

Codice

Example:

WRAP_READ 0x3000 4

Codice

---

## 4.7 FIFO_WRITE
Writes into a FIFO.

FIFO_WRITE <addr> <len> <data...>

Codice

Example:

FIFO_WRITE 0x4000 3  0x10 0x20 0x30

Codice

---

## 4.8 FIFO_READ
Reads from a FIFO.

FIFO_READ <addr> <len>

Codice

Example:

FIFO_READ 0x4000 3

Codice

---

## 4.9 CHECK
Reads a word and compares it with an expected value.

CHECK <addr> <expected>

Codice

Example:

CHECK 0x80000000 0xCAFEBABE

Codice

If the value does not match, the backend generates an error.

---

## 4.10 ATOMIC_BEGIN / ATOMIC_END
Executes a sequence of commands atomically.

ATOMIC_BEGIN
WRITE 0x80000000 0x01
WRITE 0x80000004 0x02
ATOMIC_END

Codice

Atomic blocks prevent the arbiter from switching to other masters.

---

# 5. Comments

Comments start with `#` and extend to the end of the line.

This is a comment
WRITE 0x1000 0x55   # Inline comment

Codice

---

# 6. Whitespace Rules

The parser accepts:

- multiple spaces,
- tabs,
- indentation.

All of the following are equivalent:

WRITE 0x1000 0x55
WRITE    0x1000    0x55
WRITE 0x1000 0x55

Codice

---

# 7. Error Conditions

The parser reports errors for:

- unknown commands,
- missing arguments,
- invalid numbers,
- burst length mismatch,
- wrap length mismatch,
- CHECK mismatch,
- malformed lines.

Example of invalid:

WRITE 0x1000

Codice

(missing data)

---

# 8. Complete Example

Configure device
WRITE 0x80000000 0x01
WRITE 0x80000004 0x02

Read back
READ 0x80000000
READ 0x80000004

Burst write
BURST_WRITE 0x9000 4  0xAA 0xBB 0xCC 0xDD

Check values
CHECK 0x80000000 0x01
CHECK 0x80000004 0x02

Atomic block
ATOMIC_BEGIN
WRITE 0xA000 0x10
WRITE 0xA004 0x20
ATOMIC_END

Codice

---

# 9. Summary

A `.cmd` file is a simple, readable, line‑based format that describes bus
operations.  
It supports single operations, bursts, wrap bursts, FIFO operations, checks, and
atomic blocks.

This document defines the complete syntax required to write valid DexterLab
command files.

---

# End of Document
