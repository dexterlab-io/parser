markdown
# DexterLab Master + Parser Arbiter

This document describes the architecture, behavior, and implementation details of
the DexterLab arbiter module (`arbiter_mux`).  
The arbiter selects between two command sources:

- the **Parser Engine** (testbench / external `.cmd` files)
- the **Master Engine** (future RISC‑V core or hardware command generator)

Both sources share the same interface (`t_cmd_out` / `t_rsp_in`), and the arbiter
ensures fair access, atomicity, and correct routing of commands and responses.

---

# 1. Overview

The arbiter is responsible for:

- selecting which source (Parser or Master) may send a command,
- forwarding the selected command to the backend executor (AXI / AHB / Generic),
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
    A --> X[Backend Executor]
    X --> A
    A --> P
    A --> M
3. Interfaces
Both sources use the same interface:

3.1 Command Inputs
Codice
parser_cmd  : in  t_cmd_out
master_cmd  : in  t_cmd_out
3.2 Command Handshake
Codice
parser_valid : in  std_logic
parser_ready : out std_logic

master_valid : in  std_logic
master_ready : out std_logic
3.3 Backend Interface
Codice
cmd_out   : out t_cmd_out
cmd_valid : out std_logic
cmd_ready : in  std_logic
3.4 Response Routing
Codice
rsp_in           : in  t_rsp_in
parser_rsp_out   : out t_rsp_in
master_rsp_out   : out t_rsp_in
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

Priority rules:

If parser_valid = '1' and backend is ready → select Parser

Else if master_valid = '1' and backend is ready → select Master

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
The arbiter tracks pending commands:

vhdl
signal s_parser_pending : std_logic;
signal s_master_pending : std_logic;
A command becomes pending when:

Codice
cmd_valid = '1' AND cmd_ready = '1'
Pending commands are cleared when:

the backend returns rsp_last = '1',

or an error occurs (rsp_err_valid = '1'),

or the FSM switches away from the active source.

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
    B -->|Parser| C[Forward parser_cmd or pending copy]
    B -->|Master| D[Forward master_cmd or pending copy]
    C --> E[cmd_out → backend]
    D --> E
8. Response Routing Logic
Responses from the backend (rsp_in) are routed back to the correct source:

vhdl
parser_rsp_out <= rsp_in when state_next = PARSER_ACTIVE else CLEAR;
master_rsp_out <= rsp_in when state_next = MASTER_ACTIVE else CLEAR;
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
rsp_err_valid = '1'
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
12. Asynchronous Arbiter Design Rationale
The arbiter is intentionally fully asynchronous, because it is designed for
simulation, not synthesis.

Why asynchronous is correct in simulation
Simulation does not suffer from:

metastability

setup/hold violations

clock skew

combinational glitches

Delta‑cycle evaluation ensures deterministic behavior.

Benefits
zero‑latency switching

immediate propagation of commands

instant reaction to pending flags

instant error propagation

Atomic mode
Atomic mode works naturally:

FSM blocks switching

combinational mux follows FSM

backend always sees the correct source

Why it must NOT be synthesized
A synthesizable arbiter would require:

registered selector

registered command path

glitch‑free handshakes

synchronous locking

This would add at least one cycle of latency.

13. Summary
The arbiter:

ensures fair and correct arbitration

supports atomic sequences

handles pending commands

routes commands and responses correctly

integrates seamlessly with AXI / AHB / Generic backends

is simulation‑optimized and not synthesizable

It is the backbone of DexterLab’s multi‑source command architecture.

End of Document
