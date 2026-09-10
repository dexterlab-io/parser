# DexterLab Change Log

This file documents all notable changes introduced in public releases of
DexterLab.  
Entries are listed from newest to oldest.

---

## [1.0.0] – 2026-09-10
### Added
- Complete parser documentation:
  - cmd_file_format.md
  - cmd_interface.md
  - cmd_errors.md
  - cmd_flow.md
  - cmd_dry_run.md
  - cmd_simulation_envs.md
  - README.md (docs)
- Full documentation structure under `docs/`
- DRY_RUN mode fully documented and integrated
- Official support for GHDL and Vivado/xsim
- Declared compatibility with professional simulators:
  - Cadence Xcelium
  - Synopsys VCS
  - Mentor QuestaSim
  - Aldec Riviera-PRO
  - ModelSim
- Documented master placeholder
- Open-ended master roadmap

### Changed
- General cleanup of repository structure
- Documentation aligned with HDL implementation

### Notes
This is the first fully documented release of the DexterLab parser.  
HDL code is stable and documentation is complete.

---

## [0.9.0] – 2026-09-01
### Added
- Working parser
- Arbiter
- AXI/AHB backends
- AXI/AHB wrappers
- Master placeholder
- GHDL and Vivado simulation environments

### Notes
Internal version, not publicly documented.

---

## [0.1.0] – 2026-07-01
### Added
- Initial project structure
- Early parser prototype
- First GHDL simulations

### Notes
Prototype version.
