# DexterLab Quickstart Guide

(Version 2026 — Installation, First Simulation, First Command File)

This guide provides a practical introduction to the DexterLab command ecosystem.

It is intended for users who want to:

- Understand the architecture
- Run their first simulation
- Execute a command file
- Validate parser behavior
- Inspect waveforms
- Experiment with different backends

This is the recommended starting point for new users.

---

# 1. DexterLab Architecture

DexterLab is built around a protocol-independent command model.

```text
Parser / Master
        |
        v
     Arbiter
        |
        v
     Backend
        |
        v
       Bus
```

All command execution uses:

```text
t_cmd_out
t_rsp_out
t_rsp_in
```

regardless of the selected backend.

---

# 2. Requirements

DexterLab is implemented in standard VHDL and supports multiple simulators.

Supported environments:

- GHDL
- Vivado / XSIM
- QuestaSim
- ModelSim
- Riviera-PRO
- Xcelium
- VCS

Recommended for beginners:

```text
GHDL
```

because it provides the fastest edit-compile-run cycle.

---

# 3. Typical Project Structure

```text
dexterlab/

├── src/
│
├── docs/
│
├── test/
│
├── sim/
│   ├── ghdl/
│   └── vivado/
│
└── tb/
```

Main directories:

| Directory | Purpose |
|------------|------------|
| src | HDL source files |
| docs | Documentation |
| test | Command files |
| sim | Simulator scripts |
| tb | Testbench environment |

---

# 4. Build and Run (GHDL)

Compile sources:

```bash
ghdl -a src/**/*.vhd

***l -a tb/tb_dexter***.vhd
```

Elaborate***```bash
ghdl -e tb_d***erlab
```

Run:

***bash
ghdl -r tb_dex***lab --wave=wave.fst
``***This produces:

- Command***ecution
- Backend activity
- Res***se generation***Waveform database

---

# 5***reate Your First Command File

***ate:

```text
test/first_test.cm****`

Contents:

```text
WRITE***1000 0xDE***EEF

READ 0x1000

CHECK 0x1000 0******EEF
```

---

# 6.***n a Command File

Example:

```b***
***l -r tb_dexterlab \
***  --cmd=test/first***st.cmd \
     --wave=wave.fst***`

Typical output***```text
WRITE executed

***D completed

CHECK passed***`

Exact formatting***pends on the selected testbench.*****

# 7. Using DRY_RUN

DRY_RUN va***ates command files without execu***g***ckend operations.

Example:

```***h
ghdl -r tb_dexter*** \
     --cmd=test/first_test.cm****     --dry-run
```

Capabilities***- Parsing
- Syntax validation
- ***antic validation
- Command norma***ation

Without:

***rbiter activity
- Backend activi*****Bus transactions

Recommended***fore running***mplex command sequences.

---

#*** Inspect*** Waveforms

Open generated wave***ms:

```bash
gtkwave wave.f***```

Recommended signals:

###***rser

```text
cmd***lid
cmd_ready
cmd_out
``***### Arbiter

```text
state_curre*****ate_next
parser_ready
master_rea***```

### Backend

```text
rsp_va******p_last
rsp_data

***_err_valid
rsp_err_code

***_end_cmd
```

### Memory Models
****text
REG
RAM
FIFO
***

Waveforms are the preferred de***ging mechanism***r protocol***d timing***sues.

---

# 9***un Example Tests

Typical***mmand files:

***text
memory_test.cmd
burst_test.***
fifo_test.cmd***ap_test.cmd***ror_test.cmd
```

Example:

***bash
ghdl -r tb_dexter*** \
     --cmd=test/burst_test***d
```

---

# 10. Example***mmand Families

Single access:

***text
***TE 0x1000 0x123***78

READ 0x1000
***

Burst operation:

```text
BURS****ITE 16 0x1000
``***Wrap operation:

```text
WRAP_RE*****0x2000
```

***O operation:

```text
FIFO_WRITE*****00 4
```

Polling:

***text
POLL_READ 0x100***x1 0x1 *** 10
``***Atomic sequence***```text
SET_ATOMIC 1

***TE 0x1000 0xAAAA***5

WRITE 0***04 0x12345678

***_ATOMIC 0
```

---

#***. Switching Backends

The comman****osystem is***ckend-independent.

Generic Back******```vhdl
u_backend :***tity work.backend_generic
```

A***FULL Backend:

```vhdl
***ackend : entity work.backend_axi***ll
``***AXI-LITE Backend:

***vhdl
u_backend : entity work.bac***d***i***te
```

AHB-FULL Backend:

```vh***u_backend : entity work.backend_***_full
```

AH***ITE Backend:

```vhdl
u***ckend : entity work.backend_ahb_***e***`

The parser and arbiter remain***changed.

---

# 12. Hardware***ster

The current hardware maste***s a placeholder implementation.
***havior:

```text
***tinuous***AD

Address = 0x00000000

Length*****```

Use***ses:

- Arbiter validation***Multi-source testing
- Response ***ting verification***uture versions may support:

- R***-V processors
- DMA engines
***PGA accelerators
- Embedded cont***lers

---

***3. Common Issues***## Address Errors***sually indicate***```text
Access outside valid add***s***p
```

###***undary Errors

Usually indicate:***``text
Invalid burst boundaries***`

### Verification Fail***s

Usually indicate:

```text
CH*** mismatch***FO_CHECK mismatch
File***mparison mismatch
```

### Polli***Fail***s

Usually indicate:

```text
Ti***ut condition reached
```

See***```text
cmd_errors.md
```

*** complete error definitions.

--***#***. Where to Go***xt

Recommended reading:

***`overview.md`
2. `cmd***le_format.md`
3. `command_set.md***. `cmd_interface.md`
5.***md_flow.md`
6. `cmd***rors.md`

Then continue***th:

- Backend documentation
-***biter documentation
- Testbench ***hitecture
-***ster integration guide***--

# 15. Summary***o get***arted with DexterLab:

1. Compil***he sources*** Run the testbench
3.***ecute a command file
4. Inspect***veforms
5. Use DRY_RUN for***lidation
6. Experiment with diff***nt***ckends

The same***mmand ecosystem works across all***pported***ckends through the unified inter***es:

```text
t_cmd_out
t_rsp_out***rsp_in
```

making DexterLab a f***ible framework for verification,***mulation, and future hardware in***ration.

---

# End of Document***``***
