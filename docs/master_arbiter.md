# DexterLab Master + Parser Arbiter
This document describes the architecture, behavior, and implementation details of
the DexterLab arbiter module (`arbiter_mux`).  
The arbiter selects between two command sources:

- the **Parser Engine** (testbench / external command scripts)
- the **Master Engine** (future RISC‑V core or hardware command generator)

Both sources share the same interface (`t_cmd_out` / `t_rsp_in`), and the arbiter
ensures fair access, atomicity, and correct routing of commands and responses.

---

# 1. Overview

The arbiter is responsible for:

- selecting which source (Parser or Master) may send a command,
- forwarding the selected command to the backend executor (AXI/AHB/Generic),
- routing responses back to the correct source,
- respecting atomic mode (`cmd_atomic = '1'`),
- handling pending commands,
- handling error propagation,
- ensuring no command is lost or interleaved incorrectly.

The arbiter is implemented as a **three‑state FSM**:

IDLE → PARSER_ACTIVE → MASTER_ACTIVE

Codice

---

# 2. High‑Level Diagram

```mermaid
flowchart LR
    P[Parser Engine] --> A[Arbiter MUX]
    M[Master Engine] --> A
    A --> X[Backend Executor (AXI/AHB/Generic)]
    X --> A
    A --> P
    A --> M
3. Interfaces
3.1 Parser Inputs
Codice
parser_valid   : in  std_logic;
parser_ready   : out std_logic;
parser_cmd     : in  t_cmd_out;
parser_rsp_in  : in  t_rsp_out;
parser_rsp_out : out t_rsp_in;
3.2 Master Inputs
Codice
master_valid   : in  std_logic;
master_ready   : out std_logic;
master_cmd     : in  t_cmd_out;
master_rsp_in  : in  t_rsp_out;
master_rsp_out : out t_rsp_in;
3.3 Backend Outputs
Codice
valid : out std_logic;
ready : in  std_logic;

cmd    : out t_cmd_out;
rsp_out: out t_rsp_out;
rsp_in : in  t_rsp_in
4. FSM Description
The arbiter uses the following states:

vhdl
type t_state is (
    IDLE,
    PARSER_ACTIVE,
    MASTER_ACTIVE
);
4.1 IDLE State
No source is currently active.

If parser_valid = '1' and backend ready = '1', the arbiter selects the parser.

Otherwise, if master_valid = '1' and backend ready = '1', the arbiter selects the master.

4.2 PARSER_ACTIVE State
Parser remains active if:

it has a pending command,

atomic mode is active (cmd_atomic = '1'),

backend is ready,

or the parser has another command ready.

Master may take control only if:

parser is not atomic,

parser has no pending commands,

master has a valid command and backend is ready.

4.3 MASTER_ACTIVE State
Symmetric to PARSER_ACTIVE, but for the master.

5. FSM Diagram
mermaid
stateDiagram-v2
    [*] --> IDLE

    IDLE --> PARSER_ACTIVE: parser_valid & ready
    IDLE --> MASTER_ACTIVE: master_valid & ready

    PARSER_ACTIVE --> PARSER_ACTIVE: parser_pending
    PARSER_ACTIVE --> PARSER_ACTIVE: cmd_atomic = 1
    PARSER_ACTIVE --> MASTER_ACTIVE: master_valid & ready & not atomic
    PARSER_ACTIVE --> IDLE: no pending & ready

    MASTER_ACTIVE --> MASTER_ACTIVE: master_pending
    MASTER_ACTIVE --> MASTER_ACTIVE: cmd_atomic = 1
    MASTER_ACTIVE --> PARSER_ACTIVE: parser_valid & ready & not atomic
    MASTER_ACTIVE --> IDLE: no pending & ready
6. Pending Command Logic
The arbiter stores commands internally:

vhdl
signal s_parser_pending : std_logic;
signal s_master_pending : std_logic;
A command becomes “pending” when:

Codice
(valid = '1') AND (ready = '1')
Pending commands are cleared when:

Codice
rsp_in.rsp_err_valid = '1'
or when the FSM switches away from the active source.

7. Command Routing Logic
The arbiter selects the correct command based on:

current state,

next state,

pending flags,

valid flags,

atomic mode.

Diagram
mermaid
flowchart TD
    A[State + Next State] --> B{Parser or Master?}
    B -->|Parser| C[Forward parser_cmd or s_parser_cmd]
    B -->|Master| D[Forward master_cmd or s_master_cmd]
    C --> E[cmd → backend]
    D --> E
The VHDL implementation uses a priority chain that exactly matches this diagram.

8. Response Routing Logic
Responses from the backend (rsp_in) are routed back to the correct source:

vhdl
parser_rsp_out <= rsp_in when state_next = PARSER_ACTIVE else s_rsp_out_clear;
master_rsp_out <= rsp_in when state_next = MASTER_ACTIVE else s_rsp_out_clear;
Diagram
mermaid
flowchart LR
    X[rsp_in] --> A{Active Source?}
    A -->|Parser| P[parser_rsp_out]
    A -->|Master| M[master_rsp_out]
9. Ready Signal Logic
The arbiter asserts parser_ready and master_ready based on:

next state,

pending flags,

backend readiness.

Diagram
mermaid
flowchart TD
    A[Backend ready] --> B{Next state?}
    B -->|Parser| C[parser_ready = 1]
    B -->|Master| D[master_ready = 1]
10. Atomic Mode Behavior
Atomic mode (cmd_atomic = '1') forces the arbiter to:

keep the current source active,

ignore the other source,

prevent interleaving.

Diagram
mermaid
flowchart LR
    A[cmd_atomic = 1] --> B[Lock Source]
    B --> C[Ignore other valid commands]
11. Error Handling
If the backend reports an error:

Codice
rsp_in.rsp_err_valid = '1'
the arbiter:

clears the pending command,

stays in the current state,

forwards the error to the correct source.

Diagram
mermaid
flowchart TD
    A[rsp_err_valid = 1] --> B[Clear pending]
    B --> C[Stay in current state]
    C --> D[Forward error]
12. Summary
The arbiter:

ensures fair and correct arbitration,

supports atomic sequences,

handles pending commands,

routes commands and responses correctly,

integrates seamlessly with AXI/AHB/Generic backends,

is ready for future RISC‑V integration.

This module is the backbone of DexterLab’s multi‑source command architecture.

# 13. Asynchronous Arbiter Design Rationale

The `arbiter_mux` module is intentionally designed as a fully asynchronous
component. This is a deliberate architectural choice, aligned with the fact that
the arbiter is **not meant to be synthesized**, but rather serves as a **pure
simulation model** for coordinating two command sources (Parser and Master).

This section explains why the arbiter is asynchronous, why this is correct in
simulation, and why a synchronous version would be required only for a
synthesizable release.

---

## 13.1 Why the Arbiter Is Asynchronous

The arbiter does not register the active source selector. Instead, the command
and response multiplexing logic is driven directly by:

- `state_current`
- `state_next`
- `parser_valid`
- `master_valid`
- `ready`
- `s_parser_pending`
- `s_master_pending`
- `cmd_atomic`

This creates a **purely combinational selection path**, allowing the arbiter to
react immediately to changes in command availability or backend readiness.

In simulation, this provides:

- zero‑latency switching between Parser and Master,
- immediate propagation of commands to the backend,
- instant reaction to pending flags,
- instant reaction to error conditions,
- transparent behavior that matches the semantics of the command parser.

---

## 13.2 Why This Is Correct in Simulation

Simulation environments do not suffer from:

- metastability,
- setup/hold violations,
- clock skew,
- combinational glitches,
- fanout‑related timing issues.

All signals are evaluated in deterministic delta cycles, meaning that even a
large combinational mux behaves perfectly.

The backend executor (AXI/AHB/Generic) is also a simulation model, so it does not
require clock‑aligned handshakes. As a result:

- `valid` may change within the same cycle,
- `cmd` may change within the same cycle,
- the active source may switch instantly,

and the simulator will still behave correctly.

This makes the asynchronous arbiter ideal for rapid prototyping and command
execution testing.

---

## 13.3 Atomic Mode and Asynchronous Behavior

Atomic mode (`cmd_atomic = '1'`) works naturally in an asynchronous arbiter:

- the FSM blocks source switching,
- the combinational mux follows the FSM,
- the backend always sees the correct source during atomic sequences.

No additional registers are required to enforce atomicity.

---

## 13.4 Why This Arbiter Must Not Be Synthesized

Although the asynchronous design is perfect for simulation, it is **not suitable
for hardware synthesis**. A synthesizable arbiter must:

- register the active source selector,
- register the command path,
- register the valid signal,
- ensure glitch‑free AXI/AHB handshakes,
- avoid combinational loops,
- guarantee timing closure.

A synchronous version would introduce at least **one cycle of latency** between
source selection and backend command emission. This is acceptable in hardware,
but undesirable in simulation.

---

## 13.5 Future Synthesizable Version

If DexterLab releases a synthesizable version of the arbiter, it will include:

- a registered `sel` signal,
- a registered `cmd_reg`,
- a registered `valid_reg`,
- a simplified FSM,
- glitch‑free AXI/AHB handshake logic,
- atomic mode implemented via synchronous locking.

This version will be architecturally similar but timing‑safe and hardware‑ready.

---

## 13.6 Summary

The current arbiter is:

- **fully asynchronous**,
- **zero‑latency**,
- **simulation‑optimized**,
- **correct and safe in a simulator**,
- **not intended for synthesis**.

A synchronous version will be developed only if DexterLab releases a hardware
implementation.

End of Document
