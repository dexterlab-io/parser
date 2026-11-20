# DexterLab Change Log

This file documents all notable changes introduced in public releases of DexterLab.

Entries are listed from newest to oldest.

---

## [1.1.0] – 2026-11-16

### Added

- Complete AHB-Full bus converter
- Complete AHB-Lite bus converter
- Unified bus-converter architecture across:
  - AXI-Full
  - AXI-Lite
  - AHB-Full
  - AHB-Lite
- Dedicated AHB-Full error code mapping
- Dedicated AHB-Lite error code mapping
- Full regression coverage for AHB-Full
- Full regression coverage for AHB-Lite
- Dedicated AHB-Full and AHB-Lite reference simulation environments
- Extended error database supporting all currently supported bus converters

### Changed

- Refactored AHB-Full state machine architecture
- Unified command response pipeline:
  - Phase 1: command execution
  - Phase 2: response publication
  - Phase 3: parser ready
- Simplified response generation logic
- Simplified timeout management
- Timeout logic is now active only during bus-transfer states
- Removed timeout handling from IDLE state
- Removed redundant AHB-Full response states:
  - WR_RESP_ERR
  - RD_RESP_ERR
- Simplified AHB error propagation and reporting
- Improved consistency between AXI and AHB converter implementations
- Updated documentation for all supported bus converters
- Updated simulation environments and regression infrastructure

### Fixed

- Correct propagation of AHB bus errors
- Correct reporting of timeout conditions through the response pipeline
- Correct reporting of error address and beat information
- Correct handling of FIFO underflow conditions in AHB reference slaves
- Correct propagation of FIFO-generated bus errors to parser responses
- Correct synchronization between timeout detection and command completion
- Removed obsolete internal buffering no longer required by the response pipeline

### Validation

Successfully validated through complete regression suites:

- Parser tests
- Base tests
- FIFO tests
- Burst tests
- Wrap tests
- Fill tests
- Poll tests
- Dump tests
- AXI tests
- AHB tests
- Error-injection tests

Regression summary:

```text
TOTAL EXEC ERRORS = 0
TOTAL ERRORS      = 0
SIMULATION RESULT = OK
```

### Notes

This release introduces stable and validated AHB-Full and AHB-Lite bus converters.

The internal parser architecture has been simplified and unified across all supported bus protocols, improving maintainability, readability, extensibility, and long-term consistency while preserving full regression compatibility.

---

## [1.0.1] – 2026-10-07

### Added

- Support for optional AXI-Full signals:
  - AWLOCK, AWREGION, AWQOS
  - ARLOCK, ARREGION, ARQOS
- Improved error handling:
  - Correct BRESP/RRESP mapping
  - Correct propagation of backend error codes to the parser
- Updated POLL/PING behavior:
  - POLL/PING now correctly fails when the peripheral does not respond
- Updated boundary checks:
  - Correct 4KB boundary validation
  - Correct burst alignment validation
- Updated burst/wrap semantics:
  - Correct wrap base and wrap size computation
  - Correct handling of burst lengths up to 256 beats
- GHDL compatibility improvements:
  - Fixed integer range bound check failures
  - Ensured consistent behavior across GHDL and Vivado/xsim

### Changed

- Documentation updated to reflect optional AXI-Full signal handling
- Documentation updated for POLL/PING, burst, wrap, and FIFO semantics
- Cleaned up internal signal naming and comments
- Updated README and VERSION files

### Notes

This release improves AXI-Full integration, error propagation, and simulation compatibility.

It is a maintenance and correctness update over version 1.0.0.

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
