# DexterLab AXI‑FULL Backend

The AXI‑FULL Backend is the most complete and protocol‑accurate executor in the
DexterLab parser ecosystem.  
It receives commands from the arbiter (`t_cmd_out`) and generates real AXI‑FULL
transactions on all five channels:

- AW (write address)
- W  (write data)
- B  (write response)
- AR (read address)
- R  (read data)

This backend is used to validate AXI‑FULL behavior in simulation, including:

- burst semantics (INCR, WRAP)
- WSTRB masking
- 4KB boundary rules
- multi‑beat write/read sequences
- error propagation
- timing correctness

---

# 1. Overview

The AXI‑FULL backend converts high‑level parser commands into AXI transactions.
It is designed for **simulation**, not synthesis, and therefore:

- accepts commands immediately,
- uses a simple FSM,
- models AXI behavior faithfully,
- enforces AXI protocol rules,
- generates AXI error codes when needed.

The backend connects **directly** to the arbiter:

parser → arbiter → axi_full_backend → AXI bus

Codice

and returns responses through `t_rsp_in`.

---

# 2. Architecture Diagram

```mermaid
flowchart LR
    A[t_cmd_out] --> B[AXI-FULL Backend]
    B --> C[AXI AW/W/B + AR/R Channels]
    C --> D[AXI Slave Model]
    D --> C
    B --> E[t_rsp_in]
3. AXI‑FULL Channels
The backend drives all AXI‑FULL signals.

Write Address Channel (AW)
AWADDR

AWLEN

AWSIZE

AWBURST

AWVALID

AWREADY

Write Data Channel (W)
WDATA

WSTRB

WLAST

WVALID

WREADY

Write Response Channel (B)
BVALID

BRESP

BREADY

Read Address Channel (AR)
ARADDR

ARLEN

ARSIZE

ARBURST

ARVALID

ARREADY

Read Data Channel (R)
RDATA

RRESP

RLAST

RVALID

RREADY

4. Command Mapping
Field	Meaning
cmd_write	1 = write, 0 = read
cmd_burst	INCR burst
cmd_wrap	WRAP burst
cmd_fifo	not used in AXI
cmd_atomic	atomic mode (arbiter)
cmd_id	AXI transaction correlation
cmd_addr	AXI address
cmd_len	number of beats (1–256)
cmd_data	write data array
cmd_wstrb	AXI byte mask


5. Backend FSM
mermaid
stateDiagram-v2
    [*] --> IDLE

    IDLE --> AW: cmd_valid & cmd_write = 1
    AW --> W: AWREADY = 1
    W --> B: WLAST = 1
    B --> IDLE: BVALID & BREADY

    IDLE --> AR: cmd_valid & cmd_write = 0
    AR --> R: ARREADY = 1
    R --> IDLE: RLAST = 1
The FSM is intentionally simple because AXI timing is modeled but not constrained
by synthesis rules.

6. Write Transaction Flow
mermaid
sequenceDiagram
    participant P as Backend
    participant A as AXI Slave

    P->>A: AWADDR, AWLEN, AWBURST, AWVALID
    A->>P: AWREADY

    loop len beats
        P->>A: WDATA[i], WSTRB, WVALID
        A->>P: WREADY
    end

    P->>A: WLAST

    A->>P: BVALID, BRESP
    P->>A: BREADY
7. Read Transaction Flow
mermaid
sequenceDiagram
    participant P as Backend
    participant A as AXI Slave

    P->>A: ARADDR, ARLEN, ARBURST, ARVALID
    A->>P: ARREADY

    loop len beats
        A->>P: RDATA[i], RRESP, RVALID
        P->>A: RREADY
    end

    A->>P: RLAST
8. Burst Semantics
INCR Burst
mermaid
flowchart LR
    A[addr] --> B[addr + 4] --> C[addr + 8] --> D[...]
WRAP Burst
Wrap mask:

Codice
mask = len * 4 bytes
wrap_base = addr & ~(mask - 1)
next_addr = wrap_base + ((offset + 4) % mask)
mermaid
flowchart TD
    A[offset] --> B[offset % mask]
    B --> C[wrapped address]
9. 4KB Boundary Rule
AXI forbids bursts crossing 4KB boundaries.

mermaid
flowchart LR
    A[addr] --> B[addr + 4]
    B --> C[addr + 8]
    C --> D{Cross 4KB?}
    D -->|Yes| E[Error: DECERR]
    D -->|No| F[Continue]
If violated:

rsp_err_valid = '1'

rsp_err_code = DECERR

rsp_err_info = failing address

10. WSTRB Handling
WSTRB controls which bytes of WDATA are written.

mermaid
flowchart LR
    A[WSTRB bit 0] -->|1| B[Write byte 0]
    A -->|0| C[Skip byte 0]
Same for bits 1, 2, 3.

11. Error Codes
Code	Meaning
0x00	OKAY
0x02	SLVERR
0x03	DECERR
0x06	BOUNDARY_ERR
0x07	BURST_ERR


Errors are returned through:

rsp_err_valid

rsp_err_code

rsp_err_info

rsp_id

12. Response Mapping
Write
BRESP → rsp_err_code

cmd_id → rsp_id

Read
RDATA → rsp_data

RRESP → rsp_err_code

cmd_id → rsp_id

13. Atomic Mode
Atomic mode is handled entirely by the arbiter.
The backend simply executes commands in the order received.

14. Summary
The AXI‑FULL backend:

converts parser commands into AXI transactions

supports INCR and WRAP bursts

enforces 4KB boundary rules

handles WSTRB masking

generates AXI error codes

returns responses through t_rsp_in

is designed for simulation, not synthesis

It is the most complete and protocol‑accurate backend in DexterLab.

End of Document
