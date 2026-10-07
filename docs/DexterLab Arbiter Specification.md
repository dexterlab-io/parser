DexterLab Arbiter Specification
(Versione 2026 — Multi‑Source, Zero‑Latency, Simulation‑Optimized)

The DexterLab Arbiter (arbiter_mux) is the module that selects which command
source—Parser or Hardware Master—drives the backend at any given time.
It enforces atomicity, ordering, pending rules, and deterministic routing of both
commands (t_cmd_out) and responses (t_rsp_in).

The arbiter is intentionally fully asynchronous and simulation‑optimized.
It is not intended for synthesis.

1. Overview
DexterLab supports two command sources:

Parser Engine (text .cmd files)

Hardware Master (RISC‑V, DMA, FPGA logic)

Both sources share the same interface:

Codice
t_cmd_out → arbiter → backend → bus
The arbiter ensures:

correct source selection

atomic mode enforcement

pending command tracking

deterministic routing of responses

zero‑latency switching

no interleaving of atomic sequences

2. Architecture Diagram
mermaid
flowchart LR
    P[Parser] --> A[Arbiter]
    M[Hardware Master] --> A
    A --> B[Backend]
    B --> A
    A --> P
    A --> M
3. Arbiter Interfaces
3.1 Parser Side
Signal	Direction	Description
parser_valid	in	parser has a command ready
parser_ready	out	arbiter ready to accept parser command
parser_cmd	in	t_cmd_out
parser_rsp_in	in	parser response control
parser_rsp_out	out	t_rsp_in


3.2 Master Side
Same interface as parser:

Signal	Direction	Description
master_valid	in	master has a command ready
master_ready	out	arbiter ready to accept master command
master_cmd	in	t_cmd_out
master_rsp_in	in	master response control
master_rsp_out	out	t_rsp_in


3.3 Backend Side
Signal	Direction	Description
cmd_valid	out	arbiter sends command to backend
cmd_ready	in	backend ready
cmd	out	t_cmd_out
rsp_in	in	t_rsp_in
rsp_out	out	t_rsp_out


4. FSM Description
The arbiter uses a three‑state FSM:

vhdl
type t_state is (
    IDLE,
    PARSER_ACTIVE,
    MASTER_ACTIVE
);
4.1 IDLE
No active source

If parser_valid → select parser

Else if master_valid → select master

4.2 PARSER_ACTIVE
Parser remains active if:

it has a pending command

atomic mode is active

backend is ready

parser has another command ready

Master may take control only if:

parser is not atomic

parser has no pending commands

master_valid = '1'

backend ready = '1'

4.3 MASTER_ACTIVE
Symmetric to PARSER_ACTIVE.

5. Pending Command Logic
The arbiter tracks pending commands:

vhdl
signal s_parser_pending : std_logic;
signal s_master_pending : std_logic;
A command becomes pending when:

Codice
cmd_valid = '1' AND cmd_ready = '1'
Pending commands are cleared when:

rsp_in.rsp_err_valid = '1'

FSM switches away from the active source

Pending flags ensure:

no source loses ownership mid‑command

atomic sequences remain uninterrupted

6. Command Routing
The arbiter selects the correct command based on:

current state

next state

pending flags

valid flags

atomic mode

Routing diagram:

mermaid
flowchart TD
    A[State + Next State] --> B{Parser or Master?}
    B -->|Parser| C[Forward parser_cmd or s_parser_cmd]
    B -->|Master| D[Forward master_cmd or s_master_cmd]
    C --> E[cmd → backend]
    D --> E
7. Response Routing
Responses from the backend are routed to the active source:

vhdl
parser_rsp_out <= rsp_in when state_next = PARSER_ACTIVE else s_rsp_out_clear;
master_rsp_out <= rsp_in when state_next = MASTER_ACTIVE else s_rsp_out_clear;
Diagram:

mermaid
flowchart LR
    X[rsp_in] --> A{Active Source?}
    A -->|Parser| P[parser_rsp_out]
    A -->|Master| M[master_rsp_out]
8. Ready Signal Logic
The arbiter asserts ready signals based on:

next state

pending flags

backend readiness

Diagram:

mermaid
flowchart TD
    A[Backend ready] --> B{Next state?}
    B -->|Parser| C[parser_ready = 1]
    B -->|Master| D[master_ready = 1]
9. Atomic Mode
Atomic mode (cmd_atomic = '1') forces the arbiter to:

keep the current source active

ignore the other source

prevent interleaving

Diagram:

mermaid
flowchart LR
    A[cmd_atomic = 1] --> B[Lock Source]
    B --> C[Ignore other commands]
Atomicity is enforced at the arbiter level, not at backend level.

10. Error Handling
If the backend reports an error:

Codice
rsp_in.rsp_err_valid = '1'
The arbiter:

clears pending command

stays in current state

forwards error to correct source

Diagram:

mermaid
flowchart TD
    A[rsp_err_valid = 1] --> B[Clear pending]
    B --> C[Stay in current state]
    C --> D[Forward error]
11. Asynchronous Design Rationale
The arbiter is fully asynchronous:

no registered command path

no registered source selector

no clock‑aligned handshakes

This is correct because:

DexterLab backends are simulation models

simulators evaluate signals in delta cycles

no metastability

no setup/hold violations

no combinational glitches

Benefits:

zero‑latency switching

instant reaction to valid/ready

perfect transparency for parser semantics

12. Synthesizable Version (Future)
A hardware version would require:

registered sel signal

registered command path

glitch‑free AXI/AHB handshake

synchronous atomic locking

simplified FSM

This version will be developed only for hardware deployments.

13. Summary
The DexterLab Arbiter:

selects between parser and hardware master

enforces atomicity

tracks pending commands

routes commands and responses deterministically

integrates seamlessly with all backends

is fully asynchronous and simulation‑optimized

is not intended for synthesis

will gain a synchronous variant only for hardware releases

It is the backbone of DexterLab’s multi‑source command architecture.

End of Document
