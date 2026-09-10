# DexterLab Simulation Environments
DexterLab supports two independent simulation environments:

1. **GHDL** — lightweight, fast, ideal for parser and backend logic  
2. **Vivado/xsim** — full-featured, ideal per AXI/AHB waveform-level simulation

Both environments execute the same VHDL sources and the same command parser, but
serve different purposes and workflows.

This document describes the structure, usage, and differences between the two
simulation environments.

---

# 1. Directory Structure

DexterLab uses two separate simulation directories:

sim/
├── ghdl/
│    ├── Makefile
│    ├── run.sh
│    ├── waves.ghw
│    └── tb_.vhd
└── vivado/
├── run.tcl
├── compile.tcl
├── simulate.tcl
├── waves.wdb
└── tb_.vhd

Codice

Each environment contains:

- its own testbench files,
- its own scripts,
- its own waveform format,
- its own compilation flow.

The VHDL sources under `src/` are shared.

---

# 2. GHDL Environment

GHDL is used for:

- fast iteration,
- parser validation,
- DRY_RUN testing,
- backend logic testing,
- arbiter testing,
- command flow validation,
- CI automation.

### 2.1 Features

- no vendor dependencies  
- runs on Linux and Windows  
- supports `.ghw` waveform format  
- ideal for pure-VHDL simulation  
- extremely fast compile/run cycle  

### 2.2 Typical Workflow

cd sim/ghdl
make
./run.sh
gtkwave waves.ghw

Codice

### 2.3 Recommended Use Cases

- testing `.cmd` files  
- validating DRY_RUN  
- verifying parser → arbiter → backend flow  
- debugging error conditions  
- verifying burst/wrap/FIFO logic  
- verifying atomic mode  
- verifying command timing  

GHDL is the preferred environment for **logic-level** simulation.

---

# 3. Vivado/xsim Environment

Vivado/xsim is used for:

- AXI-FULL waveform simulation  
- AHB-FULL waveform simulation  
- wrapper-level validation  
- timing-level debugging  
- bus protocol verification  
- integration with IP cores  
- waveform inspection with xsim or Vivado GUI  

### 3.1 Features

- vendor-accurate AXI/AHB behavior  
- `.wdb` waveform format  
- full-featured waveform viewer  
- supports complex bus timing  
- ideal for wrapper/backend integration  

### 3.2 Typical Workflow

cd sim/vivado
vivado -mode batch -source run.tcl

Codice

### 3.3 Recommended Use Cases

- verifying AXI/AHB timing  
- verifying VALID/READY handshake  
- verifying burst/wrap boundary rules  
- verifying error propagation  
- verifying wrapper behavior  
- verifying TileLink bridge (future)  
- verifying integration with vendor IP  

Vivado è l’ambiente preferito per **waveform-level** simulation.

---

# 4. Differences Between GHDL and Vivado

| Feature | GHDL | Vivado/xsim |
|---------|------|--------------|
| Speed | ★★★★★ | ★★☆☆☆ |
| AXI accuracy | ★★☆☆☆ | ★★★★★ |
| AHB accuracy | ★★☆☆☆ | ★★★★★ |
| Parser testing | ★★★★★ | ★★★☆☆ |
| DRY_RUN | ★★★★★ | ★★★☆☆ |
| Waveform viewer | GTKWave | Vivado GUI |
| Vendor IP integration | ✘ | ✔ |
| CI automation | ✔ | ✔ (batch mode) |

---

# 5. Shared Components

Both environments use:

- the same parser  
- the same command packages  
- the same backend logic  
- the same arbiter  
- the same wrappers  
- the same `.cmd` files  
- the same `t_cmd_out` / `t_rsp_in` interface  

The difference is only in:

- simulator  
- scripts  
- waveform format  
- testbench style  

---

# 6. Testbench Philosophy

DexterLab uses **two styles of testbench**:

### ✔ GHDL testbenches  
- minimal  
- pure VHDL  
- no vendor libraries  
- ideal for logic validation  

### ✔ Vivado testbenches  
- include AXI/AHB BFMs  
- include vendor timing models  
- ideal for protocol validation  

Both testbenches execute the same `.cmd` files.

---

# 7. DRY_RUN in Simulation

DRY_RUN works identically in both environments:

- no hardware commands  
- no bus activity  
- no backend interaction  
- pure parser validation  

This makes DRY_RUN ideal for:

- CI pipelines  
- pre-simulation validation  
- debugging `.cmd` files  
- verifying command structure  

---

# 8. Summary

DexterLab provides two simulation environments:

### **GHDL**
- fast  
- lightweight  
- ideal for parser/backend logic  
- perfect for DRY_RUN  
- pure VHDL  

### **Vivado/xsim**
- accurate AXI/AHB timing  
- vendor-level waveform  
- ideal for wrapper/backend integration  
- ideal for bus protocol debugging  

Both environments use the same VHDL sources and the same command parser.

---

# 9. Other Supported Simulators (Cadence, Synopsys, Mentor, Aldec)

DexterLab is fully compatible with any professional VHDL/Verilog simulator.
The project does not depend on GHDL or Vivado-specific features.

Users with commercial licenses may use:

- **Cadence Xcelium**
- **Synopsys VCS**
- **Mentor QuestaSim**
- **Aldec Riviera-PRO**
- **ModelSim PE/SE**
- **Any IEEE-compliant VHDL simulator**

### Requirements

All simulators must support:

- VHDL‑2008 (recommended)
- standard `std_logic_1164` and `numeric_std`
- hierarchical elaboration
- record types
- unconstrained arrays
- packages and configurations

### Notes

- DexterLab does not provide vendor-specific scripts for these simulators.
- Users may create their own `.do`, `.tcl`, or shell scripts.
- The parser, arbiter, wrappers, and backends require no vendor extensions.
- DRY_RUN works identically in all simulators.
- AXI/AHB timing accuracy depends on the simulator’s BFMs.

### Typical Usage

Users typically:

1. compile all VHDL sources under `src/`
2. compile the testbench under `sim/<custom>/`
3. run simulation with their vendor tool
4. load waveforms in the vendor GUI

DexterLab does not impose any restriction on simulator choice.

# End of Document
