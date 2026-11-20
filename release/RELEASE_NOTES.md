# DexterLab Release Notes — Version 1.1.0

Release Date: 2026-11-16  
Status: Stable

DexterLab 1.1.0 extends the command parser ecosystem with complete and validated support for AHB-Full and AHB-Lite bus converters.

This release also introduces a simplified and unified internal execution architecture shared across all supported bus protocols, improving maintainability, consistency, and long-term scalability.

---

# 1. Overview

DexterLab provides a hardware-agnostic command parser capable of generating high-level transactions including:

- SINGLE accesses
- BURST accesses
- WRAP accesses
- FIFO operations
- Atomic command sequences
- POLL operations
- WAIT operations
- DUMP operations
- CHECK operations

Commands are expressed using simple `.cmd` files and executed through the unified parser interface:

```vhdl
t_cmd_out
t_rsp_in
```

The same parser interface is used across all supported bus protocols.

---

# 2. What's New in Version 1.1.0

### ✔ Complete AHB-Full Support

The AHB-Full converter is now fully implemented and validated.

Features include:

- SINGLE transfers
- INCR bursts
- WRAP bursts
- FIFO transactions
- Timeout handling
- Error propagation
- Boundary validation
- Burst validation
- WSTRB validation
- Full regression coverage

---

### ✔ Complete AHB-Lite Support

The AHB-Lite converter is now fully implemented and validated.

Features include:

- SINGLE transfers
- Multi-beat transfers
- Internal burst sequencing
- Timeout handling
- Error propagation
- Boundary validation
- Burst validation
- WSTRB validation
- Full regression coverage

The converter maintains the same parser-side semantics while adapting to the simplified AHB-Lite protocol.

---

### ✔ Unified Error Architecture

Error reporting is now standardized across all supported bus protocols.

Supported categories include:

- Protocol errors
- Timeout errors
- Boundary violations
- Invalid burst configurations
- Invalid write strobes
- Bus response errors

Dedicated error-code ranges are available for:

- AXI-Full
- AXI-Lite
- AHB-Full
- AHB-Lite

---

### ✔ Unified Response Pipeline

The parser now uses a consistent response model across all converters:

```text
Phase 1
  Command execution

Phase 2
  Response publication

Phase 3
  Parser ready
```

This model is used by:

- AXI-Full
- AXI-Lite
- AHB-Full
- AHB-Lite

---

### ✔ Simplified FSM Architecture

The AHB converters were refactored and simplified:

```text
IDLE
WR_ADDR
WR_DATA
WR_RESP

RD_ADDR
RD_DATA
RD_RESP

ERR_DRAIN
```

The previous dedicated error-response states were removed and replaced by a unified response architecture.

---

# 3. Included Components

### Parser Core

- Command parser
- Command scheduler
- Command validation
- Response generation
- Error handling framework

### Bus Converters

- AXI-Full
- AXI-Lite
- AHB-Full
- AHB-Lite

### Reference Slaves

- RAM model
- FIFO model
- Error-injection model

### Verification Environment

- GHDL support
- Vivado / XSIM support
- Regression command suites
- Automated validation scripts

---

# 4. Regression Validation

Version 1.1.0 has been validated with complete regression coverage.

Validated areas include:

- Parser functionality
- Base transactions
- FIFO transfers
- Burst transfers
- Wrap transfers
- Fill operations
- Poll operations
- Dump operations
- AXI converters
- AHB converters
- Error injection

Reference result:

```text
TOTAL EXEC ERRORS = 0
TOTAL ERRORS      = 0
SIMULATION RESULT = OK
```

---

# 5. Supported Protocols

Current supported bus protocols:

- AXI-Full
- AXI-Lite
- AHB-Full
- AHB-Lite

All protocols share the same parser interface and command format.

---

# 6. Recommended Usage

### HDL Integration

Use the parser through the unified command interface:

```vhdl
t_cmd_out
t_rsp_in
```

and connect the desired bus converter.

---

### Simulation

Recommended workflow:

1. Validate commands with GHDL
2. Validate waveforms with Vivado / XSIM
3. Run complete regression suites before release

---

### Command Development

Use:

- DRY_RUN
- CHECK
- POLL
- DUMP

to validate command files before full execution.

---

# 7. Known Limitations

Current limitations include:

- TileLink backend not yet implemented
- No vendor-specific scripts for:
  - Cadence Xcelium
  - Synopsys VCS
  - Mentor QuestaSim
  - Aldec Riviera-PRO
- No GUI front-end tools

These items remain candidates for future releases.

---

# 8. Summary

DexterLab 1.1.0 delivers:

- Stable parser architecture
- AXI-Full support
- AXI-Lite support
- AHB-Full support
- AHB-Lite support
- Unified response architecture
- Unified error model
- Complete documentation
- Automated regression environments
- Fully validated release

This release establishes the common architectural foundation for all currently supported bus protocols and serves as the baseline for future protocol and backend expansions.

---

# End of Document
