# DexterLab DRY_RUN Mode
The DRY_RUN mode allows executing a `.cmd` file **without sending any command to
the arbiter, wrapper, backend, or bus**.  
It is a safe, non-intrusive validation mode used to check syntax, semantics, and
command structure before running hardware operations.

DRY_RUN is essential for debugging command files and verifying complex sequences
without interacting with real devices.

---

# 1. Purpose of DRY_RUN

DRY_RUN is designed to:

- validate `.cmd` files,
- detect syntax errors,
- detect semantic errors,
- print the commands that *would* be executed,
- verify burst/wrap/FIFO structures,
- verify CHECK commands,
- verify atomic blocks,
- ensure correct formatting,
- avoid any hardware side-effects.

No hardware command is generated.

---

# 2. What DRY_RUN Does

When enabled, DRY_RUN:

1. parses the `.cmd` file,
2. validates syntax,
3. validates semantics,
4. builds the internal command structure,
5. prints each command in human-readable form,
6. stops on errors,
7. **does not assert `cmd_valid`**,
8. **does not interact with the arbiter**,
9. **does not interact with the backend**,
10. **does not generate bus transactions**.

It is a pure software-only execution path.

---

# 3. What DRY_RUN Does *Not* Do

DRY_RUN does **not**:

- send commands to hardware,
- generate `t_cmd_out`,
- wait for `cmd_ready`,
- receive `t_rsp_in`,
- perform READs,
- perform WRITEs,
- perform bursts,
- perform wraps,
- perform FIFO operations,
- perform CHECK comparisons,
- interact with AXI/AHB/TileLink.

All hardware activity is disabled.

---

# 4. DRY_RUN Output Format

For each parsed command, DRY_RUN prints a normalized representation:

Example:

[DRY_RUN] WRITE       addr=0x80000000 data=0x55
[DRY_RUN] READ        addr=0x80000000
[DRY_RUN] BURST_WRITE addr=0x9000 len=4 data=[AA BB CC DD]
[DRY_RUN] CHECK       addr=0x80000000 expected=0x55
[DRY_RUN] ATOMIC_BEGIN
[DRY_RUN]     WRITE   addr=0xA000 data=0x10
[DRY_RUN]     WRITE   addr=0xA004 data=0x20
[DRY_RUN] ATOMIC_END

Codice

This output is deterministic and identical across simulators.

---

# 5. Error Handling in DRY_RUN

DRY_RUN detects:

### Syntax errors
- unknown commands  
- missing arguments  
- invalid numbers  
- malformed bursts  
- malformed wraps  

### Semantic errors
- misalignment  
- invalid burst length  
- invalid wrap length  
- FIFO misuse  
- atomic misuse  

### Runtime errors
Not applicable — DRY_RUN does not execute hardware commands.

---

# 6. DRY_RUN vs Normal Execution

| Feature | Normal Mode | DRY_RUN |
|---------|-------------|---------|
| Parse `.cmd` | ✔ | ✔ |
| Validate syntax | ✔ | ✔ |
| Validate semantics | ✔ | ✔ |
| Build command | ✔ | ✔ |
| Send to arbiter | ✔ | ✘ |
| Send to backend | ✔ | ✘ |
| Bus execution | ✔ | ✘ |
| Receive responses | ✔ | ✘ |
| CHECK comparison | ✔ | ✘ |
| Hardware side-effects | ✔ | ✘ |
| Safe for any device | ✘ | ✔ |

DRY_RUN is guaranteed safe in all environments.

---

# 7. Typical Use Cases

### ✔ Validate a new `.cmd` file  
Before running on hardware.

### ✔ Debug command sequences  
Especially bursts, wraps, FIFO operations.

### ✔ Validate atomic blocks  
Ensure correct structure.

### ✔ Validate CHECK commands  
Ensure expected values are formatted correctly.

### ✔ Use in CI pipelines  
DRY_RUN can validate command files without requiring hardware.

### ✔ Use in GHDL or Vivado  
DRY_RUN works identically in both simulators.

---

# 8. Integration with Simulation Environments

DRY_RUN is available in:

- **GHDL** (fast, lightweight, ideal for parser-only validation)
- **Vivado/xsim** (useful when validating command sequences before waveform simulation)

DRY_RUN does not depend on:

- AXI/AHB wrappers,
- backend modules,
- bus signals.

It can run with only:

- parser,
- command packages,
- configuration packages.

---

# 9. Summary

DRY_RUN is a safe, non-intrusive mode that:

- validates `.cmd` files,
- prints normalized commands,
- detects syntax and semantic errors,
- avoids all hardware activity,
- works identically in GHDL and Vivado.

It is the recommended first step before executing any command file on real
hardware or in full simulation.

---

# End of Document
