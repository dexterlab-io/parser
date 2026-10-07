DexterLab Address Map
(Versione 2026 — Backend‑Agnostic, Parser‑Driven)

The DexterLab Address Map defines the memory regions exposed by the Generic
Backend and used by all backends (AXI‑FULL, AXI‑LITE, AHB‑FULL, AHB‑LITE,
TileLink Bridge).
It is the canonical reference for register, RAM, and FIFO operations performed
through the unified command interface (t_cmd_out / t_rsp_in).

The address map is intentionally simple, deterministic, and easy to extend.

1. Overview
DexterLab exposes three memory regions:

Region	Address Range	Description
REG	0x0000–0x001F	8 zero‑wait‑state registers
RAM	0x1000–0x2FFF	RAM with WSTRB + burst support
FIFO	0x3000 / 0x3100	FIFO write / FIFO read


These regions are used by:

Generic backend

AXI‑FULL backend

AXI‑LITE backend

AHB‑FULL backend

AHB‑LITE backend

TileLink bridge

The parser does not interpret bus semantics — it only enforces address rules
and boundary constraints.

2. REG Region (0x0000–0x001F)
Description
The REG region contains 8 registers, each 32‑bit wide:

Register	Address
REG0	0x0000
REG1	0x0004
REG2	0x0008
REG3	0x000C
REG4	0x0010
REG5	0x0014
REG6	0x0018
REG7	0x001C


Supported operations
WRITE

READ

CHECK

WSTRB_WRITE

BURST (len=1 only)

atomic sequences

Notes
No wait‑states

No burst support beyond single beat

No wrap

No FIFO semantics

Ideal for control/status registers

3. RAM Region (0x1000–0x2FFF)
Description
The RAM region is a contiguous memory block with:

full WSTRB support

full burst support (INCR, WRAP)

full FIFO semantics (when accessed through FIFO commands)

4KB boundary enforcement

error propagation

Supported operations
WRITE

READ

CHECK

WSTRB_WRITE

BURST_WRITE / BURST_READ / BURST_CHECK

WRAP_WRITE / WRAP_READ / WRAP_CHECK

FILL_LEN / FILL_RANGE / FILL_CHECK

DUMP_LEN / DUMP_RANGE

DUMP_FILE_LEN / RANGE

POLL_READ / POLL_TOGGLE / POLL_PING

4KB Boundary Rule
All bursts must remain within a 4KB window:

Codice
base_addr & 0xFFFFF000
If a burst crosses the boundary:

the parser splits it

the backend receives multiple bursts

no backend needs to implement splitting logic

Wrap Mask Rule
Wrap bursts use:

Codice
mask = len * 4 bytes
wrap_base = addr & ~(mask - 1)
wrapped_addr = wrap_base + (offset % mask)
4. FIFO Region (0x3000 / 0x3100)
DexterLab exposes two FIFO endpoints:

FIFO	Address	Description
FIFO_WRITE	0x3000	Push data into FIFO
FIFO_READ	0x3100	Pop data from FIFO


Supported operations
FIFO_WRITE

FIFO_READ

FIFO_CHECK

FIFO semantics
FIFO_WRITE pushes len words

FIFO_READ pops len words

FIFO_CHECK compares popped data with expected values

Underflow → SLVERR

Overflow → backend‑specific error (Generic backend raises SLVERR)

Notes
No wrap

No burst semantics

No WSTRB

No atomicity guarantees (atomic mode still applies at arbiter level)

5. Error Model
Address Errors
Condition	Error
address outside REG/RAM/FIFO	DECERR
burst crosses 4KB boundary	BOUNDARY_ERR
wrap mask invalid	BURST_ERR
FIFO underflow	SLVERR
FIFO overflow	SLVERR


Backend Errors
Backends may generate:

SLVERR

DECERR

protocol‑specific errors (AXI BRESP/RRESP, AHB HRESP)

The parser maps them into unified error codes.

6. Extending the Address Map
DexterLab allows users to extend the address map for custom peripherals.

Guidelines
Choose a new region (e.g., 0x4000–0x4FFF)

Implement a backend module that handles accesses to that region

Add documentation for the new region

Ensure no overlap with existing regions

Ensure burst/wrap semantics are well‑defined

Ensure error propagation is implemented

Typical extensions
custom RAM blocks

accelerator memory windows

MMIO peripherals

DMA descriptors

streaming engines

hardware queues

7. Address Map Summary
Region	Range	Features
REG	0x0000–0x001F	registers, single‑beat
RAM	0x1000–0x2FFF	bursts, wrap, WSTRB, FIFO semantics
FIFO	0x3000 / 0x3100	push/pop streaming


The address map is intentionally simple, deterministic, and extensible.

End of Document
