# DexterLab Documentation
This directory contains all documentation related to the DexterLab command
system, parser, backends, wrappers, simulation environments, and future master
architectures.

The documentation is organized to be modular, readable, and easy to navigate.
Each file focuses on a single topic and can be read independently.

---

# 1. Parser Documentation

### Command File Format  
**`cmd_file_format.md`**  
Defines the syntax of `.cmd` files, including commands, arguments, bursts, wraps,
FIFO operations, atomic blocks, comments, and examples.

### Command Interface  
**`cmd_interface.md`**  
Formal definition of the hardware command interface (`t_cmd_out` / `t_rsp_in`),
including handshake rules, timing, atomic mode, and response semantics.

### Error Model  
**`cmd_errors.md`**  
Complete list of syntax, semantic, and runtime errors, including backend error
codes and mapping.

### End-to-End Flow  
**`cmd_flow.md`**  
Describes the full execution pipeline from `.cmd` file to bus-level execution and
response handling.

### DRY_RUN Mode  
**`cmd_dry_run.md`**  
Safe validation mode that parses and prints commands without interacting with
hardware or simulation backends.

### Simulation Environments  
**`cmd_simulation_envs.md`**  
Describes the supported simulation environments:

- **GHDL** (official, fast, pure VHDL)
- **Vivado/xsim** (official, AXI/AHB waveform-level)
- **Cadence Xcelium**, **Synopsys VCS**, **Mentor QuestaSim**,  
  **Aldec Riviera-PRO**, **ModelSim**, and any IEEE-compliant simulator

---

# 2. Master Documentation

### Master Placeholder  
**`parser_master.md`**  
Current minimal master implementation (continuous READ at `0x0000_0000`), used
only for integration and future expansion.

### Master Roadmap  
**`roadmap_master.md`**  
Open-ended roadmap for future master implementations (SPI, I2C, UART, CAN,
RISC‑V, MAC Ethernet, 10BASE‑T1S, RCP, distributed systems).

---

# 3. Backend and Wrapper Documentation

These documents describe how DexterLab commands are translated into bus
transactions:

- AXI-FULL backend  
- AXI-LITE wrapper  
- AHB-FULL backend  
- AHB-LITE wrapper  
- TileLink bridge  
- arbiter  
- generic backend  

(Already present in the repository under `docs/`.)

---

# 4. Documentation Philosophy

DexterLab documentation follows these principles:

- **Modular** — each file covers one topic  
- **Bus-agnostic** — AXI/AHB/TileLink share the same command interface  
- **Open-ended** — future masters and peripherals can be added without breaking
  existing documents  
- **Simulation-neutral** — works with GHDL, Vivado, and any professional
  simulator  
- **Readable** — diagrams, examples, and clear structure  

---

# 5. How to Navigate

If you are new to DexterLab:

1. Start with **`cmd_file_format.md`**  
2. Continue with **`cmd_interface.md`**  
3. Read **`cmd_flow.md`** to understand the pipeline  
4. Use **`cmd_dry_run.md`** to validate your `.cmd` files  
5. Choose your simulator using **`cmd_simulation_envs.md`**

If you are integrating hardware:

1. Read backend/wrapper documentation  
2. Read arbiter documentation  
3. Read master placeholder + roadmap  

---

# 6. Summary

The `docs/` directory contains:

- complete parser documentation  
- complete command interface specification  
- complete error model  
- complete execution flow  
- DRY_RUN mode  
- simulation environments (GHDL, Vivado, Cadence, Synopsys, Mentor, Aldec, etc.)  
- master placeholder + roadmap  
- backend/wrapper documentation  

This README provides the entry point for navigating all DexterLab documentation.

---

# End of Document
