# DexterLab Release Notes — Version 1.0.0
Release Date: 2026-09-10  
Status: Stable

DexterLab 1.0.0 is the first fully documented and stable release of the DexterLab
command parser and its associated HDL infrastructure.  
This version introduces a complete command execution pipeline, unified bus
interfaces, full documentation, and official support for multiple simulation
environments.

---

# 1. Overview

DexterLab provides a hardware-agnostic command parser capable of generating
high-level read/write operations, bursts, wraps, FIFO transactions, and atomic
blocks.  
Commands are expressed in simple `.cmd` files and executed through a unified
interface (`t_cmd_out` / `t_rsp_in`) compatible with AXI-FULL, AXI-LITE,
AHB-FULL, AHB-LITE, and future TileLink integrations.

This release focuses on stability, clarity, and documentation completeness.

---

# 2. What’s Included in This Release

### ✔ Complete Parser Implementation
- Full `.cmd` file support  
- Burst, wrap, FIFO, atomic blocks  
- CHECK operations  
- Unified error model  
- Deterministic command translation

### ✔ Unified Command Interface
- Formal definition of `t_cmd_out`  
- Formal definition of `t_rsp_in`  
- Consistent across all backends  
- Supports multi-master architectures

### ✔ Backends and Wrappers
- AXI-FULL backend  
- AXI-LITE wrapper  
- AHB-FULL backend  
- AHB-LITE wrapper  
- Generic backend  
- Arbiter for multi-source command routing

### ✔ DRY_RUN Mode
A safe, non-intrusive mode that validates `.cmd` files without generating any
hardware activity.  
Ideal for debugging and CI pipelines.

### ✔ Simulation Environments
Official support for:
- **GHDL** (fast, pure VHDL)
- **Vivado/xsim** (accurate AXI/AHB waveform simulation)

Declared compatibility with:
- **Cadence Xcelium**
- **Synopsys VCS**
- **Mentor QuestaSim**
- **Aldec Riviera-PRO**
- **ModelSim**

### ✔ Complete Documentation
All parser-related documents are included:
- file format  
- interface  
- error model  
- execution flow  
- DRY_RUN  
- simulation environments  
- documentation index  

---

# 3. Stability and Scope

Version 1.0.0 is considered **stable** for:

- parser usage  
- AXI/AHB integration  
- simulation workflows  
- command file development  
- backend/wrapper integration  

The master module is currently a placeholder and will evolve in future releases.

---

# 4. Known Limitations

- TileLink backend is not yet implemented  
- No vendor-specific scripts for Cadence/Synopsys/Mentor/Aldec  
- No GUI tools included  
- No hardware master FSM (placeholder only)

These limitations will be addressed in future releases.

---

# 5. Recommended Usage

### For HDL Integration
Use the HDL sources under `rtl/` and the unified command interface.

### For Simulation
Start with GHDL for fast iteration, then use Vivado/xsim for AXI/AHB waveform
validation.

### For Command Development
Use DRY_RUN to validate `.cmd` files before running full simulations.

---

# 6. Summary

DexterLab 1.0.0 delivers:

- a stable command parser  
- a unified hardware interface  
- complete documentation  
- official simulation support  
- professional release structure  

This marks the first fully documented and production-ready version of the
DexterLab command system.

---

# End of Document
