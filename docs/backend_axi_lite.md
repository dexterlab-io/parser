# DexterLab AXI‑LITE Backend

The AXI‑LITE Backend is a simplified executor that converts high‑level parser
commands (`t_cmd_out`) into AXI‑LITE transactions.  
It models the AXI‑LITE protocol:

- AW (write address)
- W  (write data)
- B  (write response)
- AR (read address)
- R  (read data)

AXI‑LITE supports **only single‑beat transfers**, therefore:

- no bursts,
- no wrap,
- no multi‑beat sequences,
- no boundary rules,
- no burst errors.

This backend is ideal for validating MMIO‑style accesses.

---

# 1. Overview

The AXI‑LITE backend receives commands directly from the arbiter and generates
AXI‑LITE transactions toward an AXI‑LITE slave model.

It supports:

- WRITE  
- READ  
- CHECK  

and enforces:

- correct AXI‑LITE timing,
- correct WSTRB masking,
- correct response propagation.

---

# 2. Architecture Diagram

```mermaid
flowchart LR
    A[t_cmd_out] --> B[AXI-LITE Backend]
    B --> C[AXI-LITE AW/W/B + AR/R]
    C --> D[AXI-LITE Slave Model]
    D --> C
    B --> E[t_rsp_in]
3. AXI‑LITE Channels
Write Address (AW)
AWADDR

AWVALID

AWREADY

Write Data (W)
WDATA

WSTRB

WVALID

WREADY

Write Response (B)
BVALID

BRESP

BREADY

Read Address (AR)
ARADDR

ARVALID

ARREADY

Read Data (R)
RDATA

RRESP

RVALID

RREADY

4. Command Mapping
Field	Meaning
cmd_write	1 = write, 0 = read
cmd_addr	AXI‑LITE address
cmd_len	must be 1 (single beat)
cmd_data	write data
cmd_wstrb	AXI byte mask
cmd_id	response correlation
cmd_burst	ignored
cmd_wrap	ignored
cmd_fifo	ignored


If cmd_len > 1, the backend returns:

rsp_err_valid = '1'

rsp_err_code = BURST_ERR

5. Backend FSM
mermaid
stateDiagram-v2
    [*] --> IDLE

    IDLE --> AW: cmd_valid & cmd_write = 1
    AW --> W: AWREADY = 1
    W --> B: WREADY = 1
    B --> IDLE: BVALID & BREADY

    IDLE --> AR: cmd_valid & cmd_write = 0
    AR --> R: ARREADY = 1
    R --> IDLE: RVALID & RLAST
6. Write Transaction Flow
mermaid
sequenceDiagram
    participant B as Backend
    participant S as AXI-LITE Slave

    B->>S: AWADDR, AWVALID
    S->>B: AWREADY

    B->>S: WDATA, WSTRB, WVALID
    S->>B: WREADY

    S->>B: BVALID, BRESP
    B->>S: BREADY
7. Read Transaction Flow
mermaid
sequenceDiagram
    participant B as Backend
    participant S as AXI-LITE Slave

    B->>S: ARADDR, ARVALID
    S->>B: ARREADY

    S->>B: RDATA, RRESP, RVALID
    B->>S: RREADY
8. Error Handling
AXI‑LITE supports:

OKAY

SLVERR

The backend maps:

AXI‑LITE	Parser Error
OKAY	0x00
SLVERR	0x02


Additional parser errors:

Condition	Error Code
cmd_len > 1	BURST_ERR
invalid address	DECERR


9. Response Mapping
Write
BRESP → rsp_err_code

cmd_id → rsp_id

Read
RDATA → rsp_data

RRESP → rsp_err_code

cmd_id → rsp_id

10. Atomic Mode
Atomic mode is handled by the arbiter.
The backend executes commands in the order received.

11. Summary
The AXI‑LITE backend:

converts parser commands into AXI‑LITE transactions

supports only single‑beat transfers

handles WSTRB masking

propagates AXI‑LITE error codes

returns responses through t_rsp_in

is designed for simulation, not synthesis

It is the simplest AXI‑based backend in DexterLab.

End of Document
