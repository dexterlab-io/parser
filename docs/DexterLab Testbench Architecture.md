DexterLab Testbench Architecture
(Versione 2026 — Parser, Arbiter, Backend, Memory Models, Master)

The DexterLab Testbench provides a complete simulation environment for executing
.cmd files, validating backends, testing arbiter behavior, and integrating
hardware masters.
It is designed to be modular, deterministic, bus‑agnostic, and
compatible with any IEEE‑compliant VHDL simulator.

This document describes the internal architecture of the testbench, its
components, and how they interact.

1. High‑Level Architecture
mermaid
flowchart TD
    A[Parser Engine] --> B[Arbiter]
    M[Hardware Master] --> B
    B --> C[Backend Executor]
    C --> D[Memory Models (REG/RAM/FIFO)]
    D --> C
    C --> B
    B --> A
    B --> M
The testbench simulates the full DexterLab pipeline:

Codice
cmd_parser → arbiter → backend → memory models → backend → arbiter → parser/master
2. Testbench Components
The testbench contains the following modules:

Component	Description
Parser Engine	Reads .cmd files and generates t_cmd_out
Master Placeholder	Generates continuous READs (future: real hardware master)
Arbiter	Selects between parser and master
Backend	Executes commands using AXI/AHB/Generic semantics
REG Model	8 registers at 0x0000–0x001F
RAM Model	Memory block at 0x1000–0x2FFF
FIFO Model	FIFO endpoints at 0x3000 and 0x3100
Clock/Reset Generator	Drives synchronous backends
Waveform Dump	Optional VCD/FST/XSIM dump
Test Sequencer	Runs multiple .cmd files


All components are pure VHDL and portable across simulators.

3. Parser Integration
The parser engine:

loads .cmd files

tokenizes and parses commands

validates semantics

splits bursts

computes wrap masks

enforces atomic mode

outputs t_cmd_out

receives t_rsp_in

In the testbench, the parser is instantiated as:

vhdl
u_parser : entity work.cmd_parser
    port map (
        clk => clk,
        rst => rst,
        cmd_out => parser_cmd,
        rsp_in  => parser_rsp_in
    );
4. Master Placeholder Integration
The master placeholder (cmd_master) generates:

continuous READ commands

no FSM

no interrupt handling

no response processing

It is used to validate arbiter behavior.

vhdl
u_master : entity work.cmd_master
    port map (
        clk => clk,
        rst => rst,
        start => master_start,
        cmd_out => master_cmd,
        rsp_in  => master_rsp_in
    );
Future versions will replace this with:

RISC‑V master

DMA master

custom FPGA logic

5. Arbiter Integration
The arbiter selects between parser and master:

vhdl
u_arbiter : entity work.arbiter_mux
    port map (
        parser_cmd => parser_cmd,
        master_cmd => master_cmd,
        backend_cmd => backend_cmd,
        backend_rsp => backend_rsp,
        parser_rsp => parser_rsp,
        master_rsp => master_rsp
    );
The arbiter enforces:

atomic mode

pending flags

priority rules

deterministic switching

6. Backend Integration
The testbench can instantiate any backend:

Generic Backend
vhdl
u_backend : entity work.backend_generic
AXI‑FULL Backend
vhdl
u_backend : entity work.backend_axi_full
AHB‑FULL Backend
vhdl
u_backend : entity work.backend_ahb_full
AXI‑LITE / AHB‑LITE (future)
vhdl
u_backend : entity work.backend_axi_lite
Backends convert t_cmd_out into bus transactions and interact with memory
models.

7. Memory Models
7.1 REG Model
8 registers at:

Codice
0x0000–0x001F
Zero‑wait‑state.

7.2 RAM Model
Contiguous memory at:

Codice
0x1000–0x2FFF
Supports:

WSTRB

burst

wrap

FIFO semantics (when accessed through FIFO commands)

7.3 FIFO Model
Two endpoints:

Codice
0x3000 → FIFO_WRITE
0x3100 → FIFO_READ
Supports:

push

pop

check

underflow detection

overflow detection

8. Clock and Reset
The testbench provides:

synchronous clock for AXI/AHB backends

asynchronous reset for parser and arbiter

configurable clock period

Example:

vhdl
clk <= not clk after 5 ns;
rst <= '1', '0' after 20 ns;
9. Waveform Dump
The testbench supports:

GHDL VCD/FST dump

Vivado/xsim waveform dump

QuestaSim/ModelSim wave.do scripts

Example (GHDL):

vhdl
-- ghdl -r tb --wave=tb.fst
10. Test Sequencer
The testbench can run multiple .cmd files:

Codice
init.cmd
memory_test.cmd
fifo_test.cmd
burst_test.cmd
wrap_test.cmd
error_test.cmd
The sequencer:

loads each file

resets parser state

runs commands

checks responses

prints summary

11. DRY_RUN Mode in Testbench
DRY_RUN mode can be enabled:

via command line

via testbench constant

via parser configuration

In DRY_RUN:

commands are parsed

validated

printed

not executed

Useful for:

syntax validation

semantic validation

CI pipelines

12. TileLink Bridge Integration (optional)
The testbench can instantiate the TileLink bridge:

vhdl
u_tl_bridge : entity work.tilelink_bridge
This allows simulation of:

RISC‑V TileLink masters

TL‑UL / TL‑UH transactions

TL → t_cmd_out conversion

t_rsp_in → TL conversion

13. Testbench Flow Summary
mermaid
flowchart TD
    A[Load .cmd file] --> B[Parser Engine]
    B --> C[Arbiter]
    D[Master] --> C
    C --> E[Backend]
    E --> F[Memory Models]
    F --> E
    E --> C
    C --> B
    C --> D
14. Summary
The DexterLab Testbench:

simulates the full command pipeline

supports all backends

supports parser + master arbitration

includes REG/RAM/FIFO models

supports TileLink bridge

supports DRY_RUN

supports waveform dumps

supports multi‑file test sequences

is portable across all VHDL simulators

It is the primary environment for validating DexterLab commands, backends,
arbiter behavior, and hardware master integration.

End of Document
