# DexterLab Command Execution Flow

This document describes the complete execution flow used by the DexterLab command parser, from command generation to backend execution and response handling.

The execution model is shared across all currently supported backends:

- AXI-FULL
- AXI-LITE
- AHB-FULL
- AHB-LITE
- Generic Backend

This common architecture ensures consistent command semantics, error handling, and response generation regardless of the underlying bus protocol.

---

# 1. High-Level Architecture

The complete command path is:

```text
.cmd File
    |
Parser
    |
Arbiter
    |
Backend
    |
Bus
    |
Target Device
```

Responses return through:

```text
Target Device
    |
Bus
    |
Backend
    |
Arbiter
    |
Parser
```

The parser remains completely protocol-independent.

All bus-specific behavior is implemented inside the selected backend.

---

# 2. Execution Pipeline

Command execution follows three logical phases.

```text
Phase 1
--------
Command execution

Phase 2
--------
Response publication

Phase 3
--------
Parser ready
```

This model is used by all current backends.

---

# 3. Phase 1 — Command Execution

The backend receives a command through:

```text
t_cmd_out
```

and performs the requested operation.

Examples:

```text
READ
WRITE
CHECK
BURST_READ
BURST_WRITE
WRAP_READ
WRAP_WRITE
FIFO_READ
FIFO_WRITE
```

During this phase the backend:

- Generates bus transactions
- Tracks burst progress
- Applies protocol-specific rules
- Monitors timeout conditions
- Collects response information
- Detects runtime errors

Examples:

```text
AXI:
    AW/W/B
    AR/R

AHB:
    HADDR
    HTRANS
    HREADY
    HRESP
```

---

# 4. Phase 2 — Response Publication

Once execution is complete, the backend publishes the result.

Normal responses include:

```text
rsp_valid
rsp_data
rsp_last
```

Error responses include:

```text
rsp_err_valid
rsp_err_code
rsp_err_addr
rsp_err_beat
```

The backend may generate:

```text
OKAY
ERROR
TIMEOUT
BOUNDARY_ERR
BURST_ERR
PROT_ERR
WSTRB_ERR
```

depending on the active protocol and detected condition.

---

# 5. Phase 3 — Parser Ready

After response publication:

```text
rsp_end_cmd = 1
```

is generated.

At this point:

- The current command is complete
- Internal backend state is released
- Arbiter ownership may change
- A new command may be accepted

The backend returns to:

```text
IDLE
```

and waits for the next request.

---

# 6. Arbiter Interaction

The arbiter sits between command producers and the selected backend.

```text
Master(s)
    |
Arbiter
    |
Backend
```

The arbiter is responsible for:

- Command selection
- Source ownership
- Atomic execution protection
- Response routing

Backends are not aware of command origin.

They only execute commands presented through `t_cmd_out`.

---

# 7. Atomic Execution

Atomic mode prevents command interleaving.

Example:

```text
ATOMIC_BEGIN

WRITE ...
READ ...
CHECK ...

ATOMIC_END
```

During an atomic section:

```text
Source ownership remains locked.
```

The arbiter cannot switch to another command source until the atomic block completes.

Backend behavior remains unchanged.

---

# 8. Single-Beat Flow

Example:

```text
READ 0x1000
```

Execution:

```text
Parser
   |
READ command
   |
Arbiter
   |
Backend
   |
Bus access
   |
Response
   |
Parser ready
```

Result:

```text
rsp_valid = 1
rsp_last  = 1
rsp_end_cmd = 1
```

---

# 9. Multi-Beat Flow

Example:

```text
BURST_READ 0x1000 4
```

Execution:

```text
Beat 0
Beat 1
Beat 2
Beat 3
```

Responses:

```text
rsp_valid = 1
rsp_last  = 0

rsp_valid = 1
rsp_last  = 0

rsp_valid = 1
rsp_last  = 0

rsp_valid = 1
rsp_last  = 1
```

Command completion:

```text
rsp_end_cmd = 1
```

---

# 10. Wrap Flow

Example:

```text
WRAP_READ 0x2000 8
```

The backend computes wrapped addresses internally.

Examples:

```text
0x2000
0x2004
0x2008
0x200C
0x2000
...
```

depending on:

- Transfer size
- Burst length
- Protocol rules

The parser is unaware of address generation details.

---

# 11. FIFO Flow

Example:

```text
FIFO_READ 8
```

The backend performs sequential accesses to the FIFO region.

Special FIFO semantics are implemented by the target slave model.

The parser sees the operation as a normal command sequence.

---

# 12. Error Flow

When an error occurs:

```text
rsp_err_valid = 1
```

The backend generates:

```text
rsp_err_code
rsp_err_addr
rsp_err_beat
```

Example:

```text
Burst crosses boundary
```

Result:

```text
rsp_err_valid = 1

rsp_err_code = BOUNDARY_ERR

rsp_err_addr = failing address

rsp_err_beat = failing beat
```

The command is terminated according to backend policy.

---

# 13. Timeout Flow

The backend monitors execution progress while waiting for bus completion.

If a transaction exceeds the configured timeout:

```text
TIMEOUT
```

is reported.

Example:

```text
HREADY remains low
```

or

```text
AXI READY never arrives
```

Result:

```text
rsp_err_valid = 1

rsp_err_code = TIMEOUT
```

An error response is generated and execution terminates.

---

# 14. Backend Independence

The parser itself never generates bus transactions.

The parser only produces:

```text
t_cmd_out
```

and receives:

```text
t_rsp_in
```

This allows the same parser implementation to operate with:

- AXI-FULL
- AXI-LITE
- AHB-FULL
- AHB-LITE
- Generic Backend
- Future protocols

without modification.

---

# 15. Execution State Ownership

Ownership of command execution is distributed as follows:

| Component | Responsibility |
|------------|---------------|
| Parser | Command generation |
| Arbiter | Source selection |
| Backend | Protocol execution |
| Slave / Peripheral | Data processing |
| Parser Response Logic | Reporting and logging |

This separation keeps the architecture modular and scalable.

---

# 16. Summary

The DexterLab execution flow follows a common architecture:

```text
Parser
   |
Arbiter
   |
Backend
   |
Bus
   |
Target
```

using a unified execution model:

```text
Phase 1
--------
Command execution

Phase 2
--------
Response publication

Phase 3
--------
Parser ready
```

This architecture:

- Is protocol-independent
- Supports AXI, AHB, Generic and future protocols
- Handles single and multi-beat transactions
- Supports bursts, wrap and FIFO semantics
- Provides deterministic response generation
- Implements unified error reporting
- Supports atomic execution through the arbiter

It forms the foundation of the DexterLab command-execution ecosystem.

---

# End of Document
