# DexterLab Parser Documentation Index
This index provides a structured overview of all documents related to the
DexterLab command parser, its interfaces, error model, execution flow, and
simulation environments.

It serves as the entry point for developers, integrators, and users.

---

# 1. Command File Format
**`cmd_file_format.md`**  
Defines the syntax of `.cmd` files:

- command keywords  
- address/data formats  
- burst/wrap/FIFO syntax  
- atomic blocks  
- comments  
- complete examples  

---

# 2. Command Interface
**`cmd_interface.md`**  
Formal definition of:

- `t_cmd_out` (commands)  
- `t_rsp_in` (responses)  
- handshake rules  
- atomic mode  
- burst/wrap semantics  
- error propagation  

---

# 3. Error Model
**`cmd_errors.md`**  
Complete list of:

- syntax errors  
- semantic errors  
- runtime errors  
- backend error codes  
- mapping between parser and hardware errors  

---

# 4. End-to-End Flow
**`cmd_flow.md`**  
Describes the full execution pipeline:

file.cmd → parser → arbiter → wrapper → backend → bus → response

Codice

Includes:

- command translation  
- arbitration  
- backend execution  
- response handling  

---

# 5. DRY_RUN Mode
**`cmd_dry_run.md`**  
Defines the safe, non-intrusive validation mode:

- no hardware commands  
- no bus activity  
- prints normalized commands  
- detects syntax/semantic errors  
- identical behavior across simulators  

---

# 6. Simulation Environments
**`cmd_simulation_envs.md`**  
Describes the supported simulation environments:

### Official Environments
- **GHDL** (fast, lightweight, ideal for parser/backend logic)  
- **Vivado/xsim** (accurate AXI/AHB waveform simulation)

### Professional Environments (User-Provided)
DexterLab is fully compatible with:

- **Cadence Xcelium**  
- **Synopsys VCS**  
- **Mentor QuestaSim**  
- **Aldec Riviera-PRO**  
- **ModelSim PE/SE**  
- any IEEE-compliant VHDL simulator

No vendor-specific features are required.

---

# 7. Master Placeholder
**`parser_master.md`**  
Describes the current placeholder master:

- continuous READ at `0x0000_0000`  
- no FSM  
- no interrupt handling  
- future expansion for real peripherals  

---

# 8. Master Roadmap
**`roadmap_master.md`**  
Open-ended roadmap for future master implementations:

- SPI / I2C / UART / CAN  
- RISC-V TileLink masters  
- MAC Ethernet  
- 10BASE‑T1S  
- RCP remote peripherals  
- multi-master architectures  

---

# 9. Additional Backend / Wrapper Documentation
(Already present in the repository)

- AXI-FULL backend  
- AXI-LITE wrapper  
- AHB-FULL backend  
- AHB-LITE wrapper  
- TileLink bridge  
- arbiter  
- generic backend  

These documents describe the hardware execution layer.

---

# 10. Summary

The DexterLab parser documentation is composed of:

- **file format**  
- **command interface**  
- **error model**  
- **execution flow**  
- **DRY_RUN mode**  
- **simulation environments**  
- **master placeholder**  
- **master roadmap**  
- **backend/wrapper documentation**

This index provides a complete overview of all available documents.

---

# End of Document
