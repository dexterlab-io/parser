DexterLab Documentation Index
(2026 Edition — Unified Command Ecosystem)

This index provides a complete overview of all DexterLab documentation.
It is the recommended entry point for navigating the system, whether you are:

a new user

a hardware integrator

a verification engineer

a contributor

or a RISC‑V system designer

All documents follow the DexterLab 2026 architecture:
parser → arbiter → backend → bus, with no wrapper layer.

1. Parser Documentation
Command File Format
cmd_file_format.md  
Syntax of .cmd files, including commands, arguments, bursts, wraps, FIFO,
atomic blocks, comments, and examples.

Command Interface Specification
cmd_interface.md  
Formal definition of t_cmd_out / t_rsp_in, handshake rules, timing,
atomic mode, AXI/AHB semantics.

Error Model
cmd_errors.md  
Complete list of syntax, semantic, and backend error codes.

Execution Flow
cmd_flow.md  
End‑to‑end pipeline from .cmd file to bus‑level execution.

DRY_RUN Mode
cmd_dry_run.md  
Safe validation mode that parses commands without executing them.

Parser Engine Internals
parser_engine_internals.md  
Tokenizer, syntax parser, semantic validator, burst splitter, wrap calculator,
FIFO engine, polling engine, dump/check engine, atomic controller.

Simulation Environments
cmd_simulation_envs.md  
Supported simulators: GHDL, Vivado/xsim, QuestaSim, Xcelium, VCS, Riviera‑PRO.

2. Master Documentation
Master Placeholder
parser_master.md  
Minimal master generating continuous READs at 0x0000_0000.

Master Integration Guide
parser_master_integration.md  
How hardware masters (RISC‑V, DMA, FPGA logic) generate t_cmd_out.

Master Roadmap
roadmap_master.md  
Future evolution: SPI, I2C, UART, CAN, RISC‑V, Ethernet/T1S, RCP, distributed
systems.

3. Arbiter Documentation
Arbiter Specification
arbiter_specification.md  
Multi‑source arbitration, atomic mode, pending flags, deterministic routing,
response multiplexing.

4. Backend Documentation
Backend Overview
backend_overview.md  
Unified description of all backend types and their roles.

AXI‑FULL Backend
backend_axi_full.md  
Full AXI4 protocol implementation.

AXI‑LITE Backend
backend_axi_lite.md  
Single‑beat AXI‑Lite protocol.

AHB‑FULL Backend
backend_ahb_full.md  
Full AHB protocol implementation.

AHB‑LITE Backend
backend_ahb_lite.md  
Simplified AHB protocol.

Generic Backend
backend_generic.md  
Pure VHDL simulation backend.

TileLink Bridge
tilelink_bridge.md  
TL‑UL/UH → t_cmd_out conversion for RISC‑V systems.

5. Memory Map Documentation
DexterLab Address Map
address_map.md  
REG, RAM, FIFO regions, burst/wrap semantics, 4KB boundary rules, error
conditions, extension guidelines.

6. Testbench Documentation
Testbench Architecture
testbench_architecture.md  
Parser, master, arbiter, backend, memory models, waveform dump, DRY_RUN,
sequencer.

7. Quickstart Documentation
Quickstart Guide
quickstart.md  
Installation, compilation, first .cmd file, DRY_RUN, waveform inspection,
backend switching.

8. Glossary
DexterLab Glossary
glossary.md  
Definitions of all core terms: parser, arbiter, backend, FIFO, burst, wrap,
atomic, error codes, TileLink, AXI, AHB.

9. Document Organization Philosophy
DexterLab documentation is:

Modular — each file covers one topic

Bus‑agnostic — AXI/AHB/TileLink share the same command interface

Extensible — new backends and masters can be added without breaking existing documents

Simulation‑neutral — works with GHDL, Vivado, and any professional simulator

Readable — diagrams, examples, and clear structure

10. Recommended Reading Order
If you are new:
cmd_file_format.md

cmd_interface.md

cmd_flow.md

quickstart.md

testbench_architecture.md

If you are integrating hardware:
backend_overview.md

arbiter_specification.md

parser_master_integration.md

tilelink_bridge.md

address_map.md

If you are contributing:
parser_engine_internals.md

arbiter_specification.md

backend_generic.md

cmd_errors.md

11. Summary
The DexterLab documentation suite provides:

complete parser documentation

complete backend documentation

complete arbiter specification

complete master roadmap

complete memory map

complete testbench architecture

quickstart guide

glossary

unified index

This index serves as the official entry point for navigating the DexterLab
documentation.

End of Document
