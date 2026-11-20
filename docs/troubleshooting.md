# DexterLab Troubleshooting Guide

(Version 2026 — Common Problems, Diagnostics, and Recovery Procedures)

This guide helps users diagnose and resolve the most common issues encountered while using DexterLab.

It is intended for:

- New users
- Verification engineers
- Hardware integrators
- CI maintainers
- Backend developers

The guide focuses on practical debugging workflows rather than internal implementation details.

For formal error definitions, refer to:

```text
cmd_errors.md
```

---

# 1. General Debug Strategy

When something does not behave as expected:

### Step 1

Run the command file in:

```text
DRY_RUN
```

mode.

This eliminates:

- Backend issues
- Memory-model issues
- Bus issues

and verifies only parser behavior.

---

### Step 2

Verify command syntax.

Check:

```text
Command names
Parameter count
Numeric values
Variables
Includes
```

---

### Step 3

Inspect waveforms.

Recommended signals:

```text
cmd_valid
cmd_ready

rsp_valid
rsp_last

rsp_err_valid
rsp_err_code

rsp_end_cmd
```

---

### Step 4

Verify memory map usage.

Check addresses against:

```text
DexterLab Address Map.md
```

---

### Step 5

Check backend-specific behavior.

Determine whether the issue occurs in:

```text
Generic Backend

AXI-FULL

AXI-LITE

AHB-FULL

AHB-LITE
```

or all of them.

---

# 2. Parser Errors

## Unknown Command

Example:

```text
WRTE 0x1000 0x55
```

Problem:

```text
Command keyword does not exist.
```

Solution:

Verify the command name against:

```text
command_set.md
```

---

## Missing Parameters

Example:

```text
WRITE 0x1000
```

Problem:

```text
Required argument missing.
```

Solution:

Check command syntax.

Correct form:

```text
WRITE 0x1000 0x12345678
```

---

## Invalid Number Format

Example:

```text
WRITE 0x1000 0xGGGG
```

Problem:

```text
Malformed numeric value.
```

Solution:

Use valid:

```text
Hexadecimal
Decimal
Binary
```

formats.

---

## Undefined Variable

Example:

```text
WRITE BASE_RAM 0x55
```

Problem:

```text
Variable not defined.
```

Solution:

Define the variable first:

```text
SET_VAR BASE_RAM 0x1000
```

---

## Include Failure

Example:

```text
INCLUDE startup.cmd
```

Problem:

```text
File not found.
```

Solution:

Verify:

- Path
- Filename
- Extension
- Working directory

---

# 3. Validation Errors

## Address Alignment Error

Problem:

```text
Address is not properly aligned.
```

Typical causes:

```text
Misaligned word access

Incorrect burst start address
```

Solution:

Verify address alignment requirements.

---

## Invalid Burst Length

Problem:

```text
Burst length outside allowed range.
```

Solution:

Review:

```text
BURST_READ
BURST_WRITE
BURST_CHECK
```

parameters.

---

## Invalid Wrap Configuration

Problem:

```text
Illegal wrap length or alignment.
```

Solution:

Verify:

```text
Wrap size
Address alignment
Command syntax
```

---

## Invalid FIFO Usage

Problem:

```text
FIFO operation performed on invalid endpoint.
```

Solution:

Use documented FIFO addresses.

See:

```text
DexterLab Address Map.md
```

---

# 4. Runtime Errors

## DECERR

Meaning:

```text
Decode Error
```

Typical causes:

- Address outside valid region
- Invalid address map entry
- Unimplemented address region

Example:

```text
READ 0xFFFF0000
```

Checklist:

- Verify address
- Verify variable expansion
- Verify address map

Relevant documents:

```text
DexterLab Address Map.md
cmd_file_format.md
```

---

## SLVERR

Meaning:

```text
Backend execution failure
```

Typical causes:

- FIFO underflow
- FIFO overflow
- Protocol violation
- Backend-specific failure

Checklist:

- Verify FIFO state
- Verify command ordering
- Inspect backend waveforms

---

## TIMEOUT

Meaning:

```text
Operation exceeded allowed completion time.
```

Typical causes:

- Slave not responding
- Poll condition never satisfied
- Backend waiting indefinitely

Checklist:

- Verify target device
- Verify poll condition
- Verify timeout settings

---

## BOUNDARY_ERR

Meaning:

```text
Illegal boundary crossing detected.
```

Typical causes:

- Invalid burst start address
- Backend address constraints
- Boundary rule violation

Checklist:

- Verify burst length
- Verify start address
- Inspect generated micro-commands

---

## BURST_ERR

Meaning:

```text
Invalid burst semantics.
```

Typical causes:

- Length mismatch
- Illegal burst parameters
- Unsupported configuration

Checklist:

- Verify burst length
- Verify command syntax
- Verify backend support

---

## PROT_ERR

Meaning:

```text
Protocol-specific protection error.
```

Typical causes:

- Illegal permissions
- Protocol restrictions
- Backend configuration issues

---

## WSTRB_ERR

Meaning:

```text
Invalid write strobe configuration.
```

Typical causes:

- Unsupported mask
- Incorrect byte-lane selection
- Invalid partial write

Example:

```text
WSTRB_WRITE 0x1000 0x12345678 0b0000
```

---

# 5. Verification Failures

## CHECK Failure

Example:

```text
CHECK 0x1000 0x55
```

Problem:

```text
Read value differs from expected value.
```

Checklist:

- Verify previous writes
- Verify address
- Inspect waveforms
- Verify memory content

---

## BURST_CHECK Failure

Problem:

```text
At least one beat differs from expected data.
```

Checklist:

- Compare each expected value
- Verify burst sequence
- Verify backend execution

---

## FIFO_CHECK Failure

Problem:

```text
FIFO contents differ from expected values.
```

Checklist:

- Verify FIFO write sequence
- Verify FIFO read order
- Check for underflow or overflow

---

## FILL_CHECK Failure

Problem:

```text
Memory pattern differs from expected fill pattern.
```

Checklist:

- Verify fill parameters
- Verify address range
- Verify memory contents

---

## File Comparison Failure

Problem:

```text
Memory dump differs from reference file.
```

Commands:

```text
DUMP_FILE_CHECK_LEN
DUMP_FILE_CHECK_RANGE
```

Checklist:

- Verify reference file
- Verify dump range
- Verify line formatting

---

# 6. Polling Issues

## POLL_READ Timeout

Problem:

```text
Condition never becomes true.
```

Checklist:

- Verify address
- Verify mask
- Verify expected value
- Increase attempt count
- Inspect target register

Example:

```text
POLL_READ 0x1000 0x1 0x1 100 10
```

---

## POLL_TOGGLE Timeout

Problem:

```text
Selected bits never changed state.
```

Checklist:

- Verify mask
- Verify target register
- Verify stimulus generation

---

# 7. Arbiter Issues

## Backend Appears Stuck

Possible causes:

```text
Pending command not completed
No rsp_end_cmd generated
Backend deadlock
```

Check:

```text
rsp_end_cmd
rsp_valid
rsp_err_valid
```

---

## Ownership Never Switches

Possible causes:

```text
cmd_lock remains active
Pending command still active
Source continuously generates commands
```

Check:

```text
cmd_lock
pending state
arbiter FSM state
```

---

## Response Returned to Wrong Source

Possible causes:

```text
Response routing issue
Ownership tracking issue
Testbench wiring error
```

Check:

```text
Parser response path
Master response path
Arbiter state
```

---

# 8. Backend-Specific Issues

## Generic Backend

Verify:

```text
REG model
RAM model
FIFO model
```

Useful for isolating protocol-independent problems.

---

## AXI-FULL Backend

Verify:

```text
AW channel
W channel
B channel

AR channel
R channel
```

Inspect:

```text
VALID
READY
RESP
LAST
```

signals.

---

## AXI-LITE Backend

Verify:

```text
Single-beat operation
WSTRB usage
Address decoding
```

---

## AHB-FULL Backend

Verify:

```text
HTRANS
HBURST
HREADY
```

behavior.

---

## AHB-LITE Backend

Verify:

```text
Internal burst sequencing
Address generation
Wait-state handling
```

---

# 9. DRY_RUN Checklist

When DRY_RUN fails:

Verify:

```text
Command syntax

Variables

Includes

Expressions

File paths
```

Remember:

```text
DRY_RUN does not execute hardware commands.
```

Any failure is therefore:

```text
Parser-related
Validation-related
Configuration-related
```

---

# 10. Waveform Debugging Checklist

When investigating a problem:

Observe:

```text
cmd_valid
cmd_ready

rsp_valid
rsp_last

rsp_err_valid
rsp_err_code

rsp_end_cmd
```

Then verify:

```text
Arbiter ownership

Backend state

Memory model contents
```

Finally:

```text
Compare actual behavior against command intent.
```

---

# 11. Recovery Workflow

Recommended debugging workflow:

```text
1. Run DRY_RUN

2. Verify parser output

3. Execute with Generic Backend

4. Inspect waveforms

5. Test protocol-specific backend

6. Compare behavior

7. Review error codes
```

This workflow isolates problems quickly and minimizes debugging time.

---

# 12. Summary

When troubleshooting DexterLab:

- Start with DRY_RUN
- Verify command syntax
- Check variables and includes
- Validate addresses
- Inspect waveforms
- Review error codes
- Confirm backend behavior

Most issues can be isolated by moving progressively through:

```text
Parser
    ->
Arbiter
    ->
Backend
    ->
Bus
```

and verifying each layer independently.

---

# End of Document
