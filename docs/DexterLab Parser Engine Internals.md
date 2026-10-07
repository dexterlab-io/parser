DexterLab Parser Engine Internals
(Versione 2026 — Tokenizer, Decoder, Validator, Splitter, Executor)

The DexterLab Parser Engine is the component that converts textual .cmd files
into structured hardware commands (t_cmd_out).
It is designed to be deterministic, extensible, and bus‑agnostic.

This document describes the internal architecture of the parser, including:

tokenizer

syntax parser

semantic validator

command builder

burst splitter

wrap calculator

boundary checker

FIFO handler

polling engine

dump/check engine

atomic mode controller

ID allocator

This is the definitive reference for contributors and advanced users.

1. High‑Level Architecture
mermaid
flowchart TD
    A[Tokenizer] --> B[Syntax Parser]
    B --> C[Semantic Validator]
    C --> D[Command Builder]
    D --> E[Burst Splitter]
    E --> F[Atomic Controller]
    F --> G[Output: t_cmd_out]
The parser is fully synchronous and cycle‑accurate in simulation.

2. Tokenizer
The tokenizer converts raw text lines into structured tokens.

Responsibilities
remove comments

normalize whitespace

split tokens

detect numbers (hex, bin, dec)

detect identifiers

detect operators (+, -, =)

detect keywords (WRITE, READ, BURST_WRITE, etc.)

Example
Input:

Codice
WRITE BASE_RAM + 0x0100 0x12345678
Tokens:

Codice
WRITE | BASE_RAM | + | 0x0100 | 0x12345678
3. Syntax Parser
The syntax parser matches tokens against command templates.

Example templates
Codice
WRITE <addr> <data>
READ <addr>
CHECK <addr> <expected>
BURST_WRITE <addr> <len> <data...>
FIFO_WRITE <addr> <len> <data...>
SET_VAR <name> = <value>
INCLUDE <filename>
Responsibilities
detect command type

extract arguments

detect missing arguments

detect invalid formats

detect malformed numbers

detect malformed WSTRB masks

Syntax errors are reported immediately.

4. Semantic Validator
The semantic validator checks:

Address semantics
address inside REG/RAM/FIFO

address alignment

FIFO endpoints

wrap boundaries

burst boundaries

4KB rule

Length semantics
len >= 1

len <= 256

correct number of data words

Command semantics
CHECK requires expected data

FIFO_READ requires no data

WSTRB_WRITE requires mask

POLL commands require mask/value/attempts/delay

Variable semantics
variable exists

variable is numeric

variable substitution is valid

Semantic errors produce:

DECERR

BOUNDARY_ERR

BURST_ERR

parser‑specific errors

5. Variable Engine
The parser supports variables:

Codice
SET_VAR BASE_RAM = 0x1000
WRITE BASE_RAM + 0x20 0xDEADBEEF
Features
integer variables

hex/bin/dec formats

arithmetic (+, -)

nested expressions

variable shadowing inside INCLUDE files

Example
Codice
SET_VAR A = 0x10
SET_VAR B = A + 4
WRITE B 0x12345678
6. INCLUDE Engine
The parser supports recursive includes:

Codice
INCLUDE init.cmd
INCLUDE config/memory_map.cmd
Features
nested includes

include stack

variable inheritance

error propagation

infinite recursion detection

7. Command Builder
The command builder constructs the t_cmd_out record.

Fields
cmd_write

cmd_burst

cmd_wrap

cmd_fifo

cmd_atomic

cmd_id

cmd_addr

cmd_len

cmd_data[]

cmd_wstrb

ID Allocation
Each command receives a unique ID:

Codice
cmd_id = cmd_id + 1
Wraps at 2^C_ID_WIDTH.

8. Burst Splitter
The parser splits bursts automatically:

Conditions
len > 256

burst crosses 4KB boundary

Example
Codice
BURST_WRITE addr len=1024
Split into:

256

256

256

256

4KB Boundary Example
Codice
addr = 0x1FF0
len = 16
Split into:

burst 0: 0x1FF0 → 0x1FFC

burst 1: 0x2000 → 0x203C

Backends never need to implement splitting logic.

9. Wrap Calculator
Wrap bursts use:

Codice
mask = len * 4 bytes
wrap_base = addr & ~(mask - 1)
wrapped_addr = wrap_base + (offset % mask)
The parser computes:

wrap mask

wrap base

wrapped addresses

Backends receive pre‑computed addresses.

10. FIFO Engine
FIFO commands:

Codice
FIFO_WRITE <addr> <len> <data...>
FIFO_READ  <addr> <len>
FIFO_CHECK <addr> <len> <expected...>
Responsibilities
enforce FIFO endpoints

enforce FIFO semantics

detect underflow

detect overflow

detect mismatches

11. Polling Engine
Polling commands:

Codice
POLL_READ <addr> <mask> <value> <attempts> <delay>
POLL_TOGGLE <addr> <mask> <attempts> <delay>
POLL_PING <addr> <attempts> <delay>
Responsibilities
generate repeated READ commands

check masked values

wait between attempts

detect timeout

propagate errors

12. Dump/Check Engine
Dump commands:

Codice
DUMP_LEN <addr> <len>
DUMP_RANGE <addr_start> <addr_end>
DUMP_FILE_LEN <addr> <len>
DUMP_FILE_RANGE <addr_start> <addr_end>
DUMP_FILE_CHECK_LEN <addr> <len>
DUMP_FILE_CHECK_RANGE <addr_start> <addr_end>
Responsibilities
read memory

format hex lines

write files

compare files

detect mismatches

stop at first mismatch

13. Atomic Mode Controller
Atomic mode:

Codice
SET_ATOMIC 1
...
SET_ATOMIC 0
Responsibilities
lock arbiter

prevent interleaving

enforce sequential execution

propagate atomic flag in t_cmd_out

Atomic mode is enforced at arbiter level.

14. Output Pipeline
Final output:

Codice
t_cmd_out → arbiter → backend → bus
The parser guarantees:

valid commands

correct semantics

correct splitting

correct wrap logic

correct FIFO logic

correct polling logic

correct atomic mode

correct ID allocation

15. Summary
The DexterLab Parser Engine:

tokenizes

parses

validates

builds commands

splits bursts

computes wrap masks

enforces boundaries

handles FIFO

handles polling

handles dump/check

enforces atomic mode

allocates IDs

outputs t_cmd_out deterministically

It is the core of the DexterLab command ecosystem.

End of Document
