DexterLab Quickstart Guide
(Versione 2026 — Installazione, Esecuzione, Primo Test, Debug)

This guide provides a fast, practical introduction to DexterLab.
It is designed for new users who want to:

install DexterLab

run their first .cmd file

simulate commands

inspect waveforms

understand the basic pipeline

This is the recommended entry point for anyone approaching DexterLab for the first time.

1. Requirements
DexterLab is pure VHDL and works on any IEEE‑compliant simulator:

✔ Supported simulators
GHDL (recommended, fast, open‑source)

Vivado xsim

QuestaSim / ModelSim

Cadence Xcelium

Synopsys VCS

Aldec Riviera‑PRO

✔ Required files
cmd_parser.vhd

arbiter_mux.vhd

backend_generic.vhd (or AXI/AHB backends)

cmd_master.vhd

reg_model.vhd

ram_model.vhd

fifo_model.vhd

tb_dexterlab.vhd (testbench)

2. Directory Structure
A typical DexterLab project looks like:

Codice
dexterlab/
│
├── src/
│   ├── parser/
│   ├── arbiter/
│   ├── backend/
│   ├── models/
│   └── master/
│
├── docs/
│   ├── cmd_file_format.md
│   ├── cmd_interface.md
│   ├── cmd_flow.md
│   ├── backend_axi_full.md
│   ├── backend_ahb_full.md
│   ├── tilelink_bridge.md
│   └── ...
│
├── test/
│   ├── init.cmd
│   ├── burst_test.cmd
│   ├── fifo_test.cmd
│   └── wrap_test.cmd
│
└── tb/
    └── tb_dexterlab.vhd
3. Building DexterLab (GHDL)
Compile all sources:
bash
ghdl -a src/**/*.vhd
ghdl -a tb/tb_dexterlab.vhd
Elaborate:
bash
ghdl -e tb_dexterlab
Run:
bash
ghdl -r tb_dexterlab --wave=wave.fst
You now have:

full simulation

waveform dump

command execution

backend activity

arbiter switching

memory model interactions

4. Running Your First .cmd File
Create a file:

Codice
WRITE 0x0000 0xDEADBEEF
READ  0x0000
CHECK 0x0000 0xDEADBEEF
Place it in test/first_test.cmd.

Run the testbench:

bash
ghdl -r tb_dexterlab --cmd=test/first_test.cmd --wave=wave.fst
Expected output:

Codice
[CMD] WRITE 0x0000 = 0xDEADBEEF
[CMD] READ  0x0000 → 0xDEADBEEF
[CMD] CHECK OK
5. Using DRY_RUN Mode
DRY_RUN validates commands without executing them.

Run:

bash
ghdl -r tb_dexterlab --cmd=test/first_test.cmd --dry-run
Output:

Codice
[DRY_RUN] WRITE 0x0000 0xDEADBEEF
[DRY_RUN] READ 0x0000
[DRY_RUN] CHECK 0x0000 0xDEADBEEF
Useful for:

syntax validation

semantic validation

CI pipelines

debugging command files

6. Inspecting Waveforms
Open wave.fst in GTKWave:

bash
gtkwave wave.fst
Recommended signals:

Parser
parser_cmd_valid

parser_cmd_addr

parser_cmd_data

Arbiter
state

parser_ready

master_ready

cmd_valid

Backend
rsp_valid

rsp_data

rsp_err_code

Memory Models
reg_array

ram_array

fifo_write_ptr

fifo_read_ptr

Waveforms are essential for debugging burst, wrap, FIFO, and error conditions.

7. Running Built‑In Tests
DexterLab includes several example tests:

Burst test
Codice
BURST_WRITE 0x1000 16 0xAAAA...
BURST_READ  0x1000 16
Wrap test
Codice
WRAP_WRITE 0x1080 8 0xBBBB...
WRAP_READ  0x1080 8
FIFO test
Codice
FIFO_WRITE 0x3000 4 0x01 0x02 0x03 0x04
FIFO_READ  0x3100 4
Run:

bash
ghdl -r tb_dexterlab --cmd=test/burst_test.cmd
8. Switching Backends
To simulate AXI‑FULL:

vhdl
u_backend : entity work.backend_axi_full
To simulate AHB‑FULL:

vhdl
u_backend : entity work.backend_ahb_full
To simulate Generic:

vhdl
u_backend : entity work.backend_generic
Backends are interchangeable — the parser and arbiter do not change.

9. Using the Hardware Master
Enable the master placeholder:

vhdl
master_start <= '1';
This generates continuous READs at 0x0000_0000.

Useful for:

arbiter testing

multi‑source arbitration

atomic mode validation

Future versions will support:

RISC‑V master

DMA master

custom FPGA logic

10. Debugging Common Issues
❌ DECERR
Address outside REG/RAM/FIFO.

❌ SLVERR
Backend error (FIFO underflow, overflow, protocol violation).

❌ BOUNDARY_ERR
Burst crosses 4KB boundary.

❌ BURST_ERR
Invalid wrap mask or burst semantics.

❌ CHECK mismatch
Expected value does not match read value.

❌ POLL timeout
Condition not met within attempts.

11. Quickstart Summary
DexterLab Quickstart:

Compile sources

Run testbench

Execute .cmd file

Inspect waveforms

Use DRY_RUN for validation

Switch backends as needed

Debug using error codes

Extend with custom tests

DexterLab provides a complete, unified command ecosystem for simulation,
verification, and hardware integration.

End of Document
