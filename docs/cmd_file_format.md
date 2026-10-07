# DexterLab Command File Format (`.cmd`)

DexterLab uses plain‑text command files (`.cmd`) to describe sequences of bus
operations.  
These files are parsed by the DexterLab command parser and converted into
high‑level hardware commands (`t_cmd_out`).

This document defines the syntax, structure, allowed commands, and examples of
valid `.cmd` files.

---

# 1. File Structure

A `.cmd` file is composed of:

- one command per line  
- optional comments  
- optional blank lines  
- optional indentation  

The parser ignores:

- leading/trailing spaces  
- empty lines  
- comment lines starting with `#`  

### Example

```text
# This is a comment
WRITE 0x80000000 0xDEADBEEF
READ  0x80000000
2. Address Format
Addresses may be written as:

hexadecimal: 0x80000000

decimal: 2147483648

Hexadecimal is recommended.

3. Data Format
Data fields may be written as:

hexadecimal: 0xDEADBEEF

decimal: 3735928559

For burst commands, multiple data words are separated by spaces:

text
BURST_WRITE 0x1000 4  0x01 0x02 0x03 0x04
4. Supported Commands
The parser supports the following commands.

4.1 WRITE
Writes a single word.

text
WRITE <addr> <data>
Example:

text
WRITE 0x80000000 0x12345678
4.2 READ
Reads a single word.

text
READ <addr>
Example:

text
READ 0x80000000
4.3 BURST_WRITE
Writes multiple words sequentially.

text
BURST_WRITE <addr> <len> <data0> <data1> ... <dataN>
Example:

text
BURST_WRITE 0x1000 4  0xAA 0xBB 0xCC 0xDD
4.4 BURST_READ
Reads multiple words sequentially.

text
BURST_READ <addr> <len>
Example:

text
BURST_READ 0x2000 8
4.5 WRAP_WRITE
Writes a wrap burst.

text
WRAP_WRITE <addr> <len> <data...>
Example:

text
WRAP_WRITE 0x3000 4  0x01 0x02 0x03 0x04
4.6 WRAP_READ
Reads a wrap burst.

text
WRAP_READ <addr> <len>
Example:

text
WRAP_READ 0x3000 4
4.7 FIFO_WRITE
Writes into a FIFO.

text
FIFO_WRITE <addr> <len> <data...>
Example:

text
FIFO_WRITE 0x4000 3  0x10 0x20 0x30
4.8 FIFO_READ
Reads from a FIFO.

text
FIFO_READ <addr> <len>
Example:

text
FIFO_READ 0x4000 3
4.9 CHECK
Reads a word and compares it with an expected value.

text
CHECK <addr> <expected>
Example:

text
CHECK 0x80000000 0xCAFEBABE
If the value does not match, the backend generates an error.

4.10 ATOMIC_BEGIN / ATOMIC_END
Executes a sequence of commands atomically.

text
ATOMIC_BEGIN
    WRITE 0x80000000 0x01
    WRITE 0x80000004 0x02
ATOMIC_END
Atomic blocks prevent the arbiter from switching to other masters.

4.11 FILL_LEN
Writes a repeated pattern for a given length.

text
FILL_LEN <addr> <len> <pattern>
4.12 FILL_RANGE
Writes a repeated pattern from addr_start to addr_end.

text
FILL_RANGE <addr_start> <addr_end> <pattern>
4.13 DUMP_LEN
Reads and prints len words.

text
DUMP_LEN <addr> <len>
4.14 DUMP_RANGE
Reads and prints a range of addresses.

text
DUMP_RANGE <addr_start> <addr_end>
4.15 POLL_READ / POLL_TOGGLE / POLL_PING
Polling commands used for synchronization.

Examples:

text
POLL_READ   <addr> <mask> <value> <attempts> <delay>
POLL_TOGGLE <addr> <mask> <attempts> <delay>
POLL_PING   <addr> <attempts> <delay>
5. Comments
Comments start with # and extend to the end of the line.

text
# This is a comment
WRITE 0x1000 0x55   # Inline comment
6. Whitespace Rules
The parser accepts:

multiple spaces

tabs

indentation

All of the following are equivalent:

text
WRITE 0x1000 0x55
WRITE    0x1000    0x55
    WRITE 0x1000 0x55
7. Error Conditions
The parser reports errors for:

unknown commands

missing arguments

invalid numbers

burst length mismatch

wrap length mismatch

malformed lines

Example of invalid:

text
WRITE 0x1000
(missing data)

8. Complete Example
text
# Configure device
WRITE 0x80000000 0x01
WRITE 0x80000004 0x02

# Read back
READ 0x80000000
READ 0x80000004

# Burst write
BURST_WRITE 0x9000 4  0xAA 0xBB 0xCC 0xDD

# Check values
CHECK 0x80000000 0x01
CHECK 0x80000004 0x02

# Atomic block
ATOMIC_BEGIN
    WRITE 0xA000 0x10
    WRITE 0xA004 0x20
ATOMIC_END
9. Summary
A .cmd file is a simple, readable, line‑based format that describes bus
operations.
It supports single operations, bursts, wrap bursts, FIFO operations, fills,
dumps, polls, checks, and atomic blocks.

This document defines the complete syntax required to write valid DexterLab
command files.

End of Document
