# DexterLab DRY_RUN Mode

DRY_RUN mode allows validation of DexterLab command files without executing any backend transaction.

It provides a safe verification environment that parses, validates, and displays command activity while preventing interaction with the execution infrastructure.

DRY_RUN is intended for:

- Command-file development
- Regression testing
- CI pipelines
- Syntax verification
- Semantic verification
- Documentation validation

No backend activity occurs while DRY_RUN is enabled.

---

# 1. Purpose

DRY_RUN mode is designed to:

- Validate command files
- Detect parser errors
- Detect semantic errors
- Verify command structure
- Verify variable expansion
- Verify include chains
- Verify burst definitions
- Verify wrap definitions
- Verify FIFO operations
- Verify polling commands
- Verify dump commands
- Verify atomic command sequences

The goal is to validate command correctness before enabling hardware execution.

---

# 2. Execution Model

When DRY_RUN is enabled, the parser executes only the front-end stages of the command pipeline.

```text
Command File
      |
Tokenizer
      |
Decoder
      |
Validation
      |
Micro-Command Generation
      |
DRY_RUN Output
```

Execution stops before commands are submitted to the arbiter.

---

# 3. What DRY_RUN Does

For every command file, DRY_RUN performs:

1. File loading
2. Tokenization
3. Command decoding
4. Syntax validation
5. Semantic validation
6. Variable substitution
7. Include expansion
8. Micro-command generation
9. Command normalization
10. Human-readable output generation

The parser therefore verifies the same command structures that would be used during a real execution.

---

# 4. What DRY_RUN Does Not Do

DRY_RUN does not:

- Submit commands to the arbiter
- Execute backend operations
- Access memory models
- Access AXI interfaces
- Access AHB interfaces
- Access TileLink interfaces
- Perform bus transactions
- Read hardware registers
- Write hardware registers
- Perform actual FIFO accesses
- Perform actual polling activity
- Perform actual memory comparisons

The command execution path terminates before backend submission.

---

# 5. Command Processing

Commands are fully parsed and expanded.

Example:

```text
BURST_WRITE 16 0x1000
```

DRY_RUN verifies:

- Syntax validity
- Length validity
- Address validity
- Boundary rules
- Command structure

but never executes the resulting transaction.

---

# 6. Internal Structures

During DRY_RUN the parser may still generate:

```text
t_cmd
t_mc_cmd
```

and internal command representations used by the parser infrastructure.

However:

```text
No command is submitted to the arbiter.
No backend execution occurs.
```

DRY_RUN therefore exercises the parser while bypassing the execution layer.

---

# 7. Output Format

DRY_RUN prints a normalized representation of each command.

Example:

```text
[DRY_RUN] WRITE       addr=0x80000000 data=0x55

[DRY_RUN] READ        addr=0x80000000

[DRY_RUN] BURST_WRITE addr=0x9000 len=4
          data=[AA BB CC DD]

[DRY_RUN] CHECK       addr=0x80000000 expected=0x55
```

Output is deterministic and independent of simulator choice.

---

# 8. Atomic Commands

Atomic execution can be validated without running hardware transactions.

Example:

```text
SET_ATOMIC 1

WRITE 0x1000 0xAAAA5555

WRITE 0x1004 0x12345678

SET_ATOMIC 0
```

DRY_RUN verifies:

- Correct atomic structure
- Correct lock sequencing
- Correct command grouping

Generated commands may be marked internally with:

```text
cmd_lock
```

but no ownership locking is actually performed because the arbiter is bypassed.

---

# 9. Error Detection

DRY_RUN detects parser-side failures.

---

## Syntax Errors

Examples:

```text
Unknown commands
Missing parameters
Extra parameters
Malformed numbers
Malformed expressions
```

---

## Semantic Errors

Examples:

```text
Invalid burst length
Invalid wrap size
Unsupported FIFO usage
Invalid polling parameters
Address violations
Alignment violations
```

---

## Include Errors

Examples:

```text
Missing files
Recursive includes
Maximum include depth exceeded
```

---

## Variable Errors

Examples:

```text
Undefined variables
Invalid expressions
Type conversion failures
```

---

# 10. Runtime Errors

Runtime execution errors do not exist in DRY_RUN mode.

The following backend-generated signals never occur:

```text
rsp_valid
rsp_last
rsp_end_cmd

rsp_err_valid
rsp_err_code
rsp_err_addr
rsp_err_beat
rsp_err_id
```

Because no backend execution occurs, there are no bus-level failures.

---

# 11. DRY_RUN vs Normal Execution

| Feature | Normal Mode | DRY_RUN |
|----------|-------------|----------|
| Load file | ✔ | ✔ |
| Tokenize | ✔ | ✔ |
| Decode | ✔ | ✔ |
| Validate syntax | ✔ | ✔ |
| Validate semantics | ✔ | ✔ |
| Generate micro-commands | ✔ | ✔ |
| Generate normalized output | Optional | ✔ |
| Submit commands to arbiter | ✔ | ✘ |
| Execute backend operations | ✔ | ✘ |
| Generate bus traffic | ✔ | ✘ |
| Produce responses | ✔ | ✘ |
| Modify memory | ✔ | ✘ |
| Hardware side effects | ✔ | ✘ |

---

# 12. Typical Use Cases

## New Command File Validation

Verify command syntax before simulation.

```text
memory_test.cmd
```

---

## Regression Pipelines

Validate command libraries during CI execution.

```text
No backend required
No bus models required
```

---

## Documentation Examples

Confirm that example command files remain valid.

---

## Parser Development

Verify tokenizer, decoder and validator changes.

---

## Atomic Sequence Validation

Verify:

```text
SET_ATOMIC
cmd_lock generation
sequence ordering
```

without backend dependencies.

---

# 13. Simulation Environment Support

DRY_RUN works with all supported simulation environments.

Supported:

- GHDL
- Vivado / XSIM
- QuestaSim
- ModelSim
- Riviera-PRO
- Xcelium
- VCS

DRY_RUN does not depend on:

- Backend models
- Memory models
- Bus interfaces
- Protocol implementations

Only the parser infrastructure is required.

---

# 14. Advantages

DRY_RUN provides:

- Fast validation
- Deterministic output
- No hardware interaction
- No side effects
- Simulator-independent behavior
- CI-friendly execution
- Early error detection

It is typically the first validation stage before full simulation.

---

# 15. Summary

DRY_RUN is a parser-only execution mode that validates command files without interacting with the command execution infrastructure.

It:

- Parses commands
- Validates syntax
- Validates semantics
- Expands commands
- Generates normalized output
- Detects parser-side errors
- Verifies atomic command structures
- Verifies command sequences

while preventing:

- Arbiter interaction
- Backend execution
- Memory modification
- Bus transactions
- Hardware side effects

DRY_RUN is the recommended first step before executing complex command sequences in a full DexterLab simulation environment.

---

# End of Document
