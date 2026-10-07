markdown
# DexterLab Parser Master Integration Guide

This document explains how to integrate a hardware master (RISC‑V core, DMA
engine, FPGA logic, microcontroller subsystem) with the DexterLab command parser
using the `t_cmd_out` / `t_rsp_in` interface and the master arbiter.

The goal is to allow hardware to generate the same high‑level commands normally
produced by the text parser.

---

# 1. Overview

DexterLab supports two command sources:

1. **Parser**  
   - reads `.cmd` files  
   - generates `t_cmd_out`  
   - drives the arbiter

2. **Hardware Master**  
   - RISC‑V core  
   - DMA engine  
   - custom FPGA logic  
   - microcontroller subsystem  
   - generates `t_cmd_out`  
   - drives the arbiter

Both sources share the same interface:

t_cmd_out → arbiter → backend → bus

Codice

The arbiter selects one source at a time, enforcing atomic mode and pending
rules.

---

# 2. Architecture Diagram

```mermaid
flowchart LR
    A[Parser] --> C[t_cmd_out]
    B[Hardware Master] --> C
    C --> D[Master Arbiter]
    D --> E[Backend Executor]
    E --> D
    D --> F[t_rsp_in]
    F --> A
    F --> B
The hardware master behaves exactly like the parser:

same command format

same timing rules

same atomic semantics

same error propagation

3. Master Interface (t_cmd_out)
The hardware master must generate the following fields:

Field	Description
cmd_write	1 = write, 0 = read
cmd_addr	target address
cmd_len	number of beats (1–256)
cmd_burst	INCR burst
cmd_wrap	WRAP burst
cmd_fifo	FIFO mode
cmd_atomic	atomic block
cmd_id	master ID
cmd_data[]	write data
cmd_wstrb	byte mask
cmd_valid	command valid
cmd_ready	handshake


Handshake rule:  
cmd_valid = '1' AND cmd_ready = '1' → command accepted.

4. Response Interface (t_rsp_in)
The hardware master receives:

Field	Description
rsp_valid	response valid
rsp_last	last beat
rsp_data	read data
rsp_err_valid	error flag
rsp_err_code	error code
rsp_err_info	failing address
rsp_id	command ID


The master must consume responses until rsp_last = '1'.

5. Arbiter Behavior
The arbiter selects between:

parser commands

master commands

based on:

pending flags

atomic mode

priority rules

Priority Rules
Atomic mode

parser or master can lock the arbiter

no switching allowed until atomic block ends

Pending flags

if parser has pending commands → parser wins

if master has pending commands → master wins

Idle state

arbiter selects the first valid source

6. Master Command Examples
6.1 Single Write
vhdl
cmd_write  <= '1';
cmd_addr   <= x"8000_0000";
cmd_len    <= 1;
cmd_data(0)<= x"DEADBEEF";
cmd_valid  <= '1';
6.2 Burst Read
vhdl
cmd_write <= '0';
cmd_addr  <= x"8000_1000";
cmd_len   <= 16;
cmd_burst <= '1';
cmd_valid <= '1';
6.3 Atomic Sequence
vhdl
cmd_atomic <= '1';
cmd_valid  <= '1';
-- multiple commands
cmd_atomic <= '0';
7. Timing Requirements
The hardware master must:

assert cmd_valid only when ready to send a full command

wait for cmd_ready = '1'

deassert cmd_valid after acceptance

handle multi‑beat responses

handle backend wait‑states

handle error responses

The arbiter guarantees:

no starvation

no interleaving during atomic mode

deterministic switching rules

8. Integration with Backends
The master does not interact directly with AXI/AHB/TileLink signals.

Instead:

Codice
master → arbiter → backend → bus
Backends convert t_cmd_out into:

AXI‑FULL transactions

AXI‑Lite transactions

AHB‑FULL transactions

AHB‑Lite transactions

TileLink UL/UH transactions (via TileLink Bridge)

The master remains completely bus‑agnostic.

9. Integration with TileLink (RISC‑V)
The TileLink bridge converts TL transactions into t_cmd_out.

A RISC‑V core can generate DexterLab commands by performing:

TileLink Op	DexterLab Meaning
TL Get	READ
TL PutFull	WRITE
TL PutPartial	masked WRITE
TL Arithmetic	atomic
TL Logical	atomic
TL UH	burst/wrap


The arbiter handles TileLink‑generated commands exactly like parser commands.

10. Recommended Master Architecture
mermaid
flowchart TD
    A[Interrupt Handler] --> B[Event Queue]
    B --> C[Master FSM]
    C --> D[Command Builder]
    D --> E[t_cmd_out]
    E --> F[Arbiter]
    F --> G[Backend]
    G --> F
    F --> H[t_rsp_in]
    H --> C
The master should include:

a command builder

a response handler

an atomic controller

a burst generator

a FIFO engine (optional)

11. Summary
The hardware master:

generates the same commands as the parser

uses the same interface (t_cmd_out)

receives the same responses (t_rsp_in)

is arbitrated together with the parser

supports bursts, wrap, atomic, FIFO

integrates with AXI/AHB/TileLink through dedicated backends

behaves exactly like a second parser source

This makes DexterLab a dual‑source command engine capable of executing commands
from:

text scripts

hardware masters

RISC‑V cores

DMA engines

FPGA logic

all through the same unified interface.

End of Document
