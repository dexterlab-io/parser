DexterLab Backend Overview
The DexterLab backend layer is responsible for converting high‑level parser
commands (t_cmd_out) into real bus transactions.
Each backend implements a specific bus protocol (AXI, AHB, TileLink, Generic)
while preserving the unified DexterLab command interface.

Backends are the final stage of the command pipeline:

Codice
cmd_parser → arbiter → backend → bus
This document provides an overview of all backend types, their roles, and how
they integrate into DexterLab systems.

1. Backend Responsibilities
Every backend must:

accept commands via t_cmd_out

execute them according to its bus protocol

generate responses via t_rsp_in

support bursts, wrap, FIFO, atomic mode

enforce protocol‑specific rules (WSTRB, boundary checks, wait‑states)

propagate errors (OKAY, SLVERR, DECERR, BOUNDARY_ERR, BURST_ERR)

integrate seamlessly with the arbiter

Backends are protocol‑specific, but command‑agnostic.

2. Backend Types
DexterLab supports multiple backend families:

✔ 2.1 Generic Backend (backend_generic)
A lightweight backend used for simulation and prototyping.

Features:

pure VHDL

no AXI/AHB handshake

AXI‑like semantics (INCR, WRAP, FIFO)

WSTRB support

4KB boundary checks

simple RAM/FIFO/REG model

Use cases:

fast simulation

CI pipelines

parser development

backend prototyping

✔ 2.2 AXI‑FULL Backend (backend_axi_full)
Implements the full AXI4 protocol:

AW/W/B and AR/R channels

multi‑beat bursts

wrap bursts

WSTRB support

AXI BRESP/RRESP error semantics

multi‑ID support

optional AXI signals (AWLOCK, AWREGION, AWQOS, ARLOCK, ARREGION, ARQOS)

Use cases:

high‑performance SoCs

FPGA IP integration

vendor IP simulation (Vivado/xsim)

✔ 2.3 AXI‑LITE Backend (backend_axi_lite)
Lightweight AXI backend:

single‑beat transfers

WSTRB support

no bursts

no wrap

no FIFO

Use cases:

MMIO registers

control/status interfaces

simple peripherals

✔ 2.4 AHB‑FULL Backend (backend_ahb_full)
Implements full AHB semantics:

pipelined address/data phases

HTRANS, HBURST, HSIZE

multi‑beat bursts

wrap bursts

deterministic timing

Use cases:

microcontroller subsystems

lightweight SoCs

deterministic bus architectures

✔ 2.5 AHB‑LITE Backend (backend_ahb_lite)
Simplified AHB backend:

single‑cycle transfers

optional wait‑states

simplified burst support

Use cases:

simple peripherals

low‑complexity systems

✔ 2.6 TileLink Bridge (tilelink_bridge)
Converts TileLink UL/UH transactions into t_cmd_out.

Supports:

TL Get → READ

TL PutFull → WRITE

TL PutPartial → masked WRITE

TL Arithmetic/Logical → atomic

TL UH → burst/wrap

Use cases:

RISC‑V SoCs

TileLink‑based systems

hybrid firmware/hardware command generation

3. Backend Selection
Backend selection is static at synthesis time:

Codice
backend_axi_full
backend_axi_lite
backend_ahb_full
backend_ahb_lite
backend_generic
tilelink_bridge
The arbiter and parser do not need to know which backend is active.

All backends implement the same interface:

Codice
t_cmd_out → backend → t_rsp_in
4. Backend Integration Diagram
mermaid
flowchart LR
    A[t_cmd_out] --> B[Arbiter]
    B --> C[Backend Executor]
    C --> D[Bus Protocol]
    D --> C
    C --> B
    B --> E[t_rsp_in]
5. Adding a Custom Backend
DexterLab allows users to implement custom backends:

Required steps:
Implement t_cmd_out → protocol conversion

Implement protocol → t_rsp_in conversion

Support bursts, wrap, FIFO, atomic

Support error propagation

Integrate with arbiter

Provide a testbench

Typical custom backends:
Wishbone

APB

proprietary buses

streaming engines

accelerator interfaces

6. Backend Comparison Table
Backend	Bursts	Wrap	FIFO	WSTRB	Multi‑ID	Use Case
Generic	✔	✔	✔	✔	✘	simulation
AXI‑FULL	✔	✔	✔	✔	✔	high‑performance
AXI‑LITE	✘	✘	✘	✔	✘	MMIO
AHB‑FULL	✔	✔	✔	✘	✘	deterministic SoCs
AHB‑LITE	limited	limited	✘	✘	✘	simple peripherals
TileLink Bridge	✔	✔	✘	✔	✔	RISC‑V systems


7. Summary
DexterLab backends:

convert high‑level commands into bus transactions

support AXI, AHB, TileLink, and Generic protocols

integrate directly with the arbiter

support bursts, wrap, FIFO, atomic

propagate errors

are easy to extend

require no wrapper layer

Backends are the foundation that allows DexterLab to operate across heterogeneous
hardware systems while preserving a unified command interface.

End of Document
