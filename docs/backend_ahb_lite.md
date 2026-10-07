# ⭐ **backend_ahb_lite.md — DexterLab AHB‑LITE Backend**

```markdown
# DexterLab AHB‑LITE Backend

The AHB‑LITE Backend is a simplified executor that converts high‑level parser
commands (`t_cmd_out`) into AHB‑LITE transactions.  
It models the AHB‑LITE protocol:

- HADDR  
- HWRITE  
- HSIZE  
- HTRANS  
- HREADY  
- HRESP  
- HWDATA  
- HRDATA  

AHB‑LITE supports **only single‑beat transfers**, therefore:

- no bursts,
- no wrap,
- no multi‑beat sequences.

This backend is ideal for validating microcontroller‑class peripherals.

---

# 1. Overview

The AHB‑LITE backend receives commands directly from the arbiter and generates
AHB‑LITE transactions toward an AHB‑LITE slave model.

It supports:

- WRITE  
- READ  
- CHECK  

and enforces:

- correct HTRANS sequencing,
- correct HREADY wait‑state behavior,
- correct error propagation.

---

# 2. Architecture Diagram

```mermaid
flowchart LR
    A[t_cmd_out] --> B[AHB-LITE Backend]
    B --> C[AHB-LITE Bus Signals]
    C --> D[AHB-LITE Slave Model]
    D --> C
    B --> E[t_rsp_in]
3. AHB‑LITE Signals
Address + Control
HADDR

HWRITE

HSIZE

HTRANS

HREADY (input)

HRESP  (input)

Write Data
HWDATA

Read Data
HRDATA

4. Command Mapping
Field	Meaning
cmd_write	1 = write, 0 = read
cmd_addr	AHB‑LITE address
cmd_len	must be 1 (single beat)
cmd_data	write data
cmd_wstrb	ignored (AHB‑LITE has no strobes)
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

    IDLE --> ADDR: cmd_valid
    ADDR --> DATA: HREADY = 1
    DATA --> RESP: HREADY = 1
    RESP --> IDLE: rsp_last = 1
6. Write Transaction Flow
mermaid
sequenceDiagram
    participant B as Backend
    participant S as AHB-LITE Slave

    B->>S: HADDR, HWRITE=1, HTRANS=NONSEQ
    S->>B: HREADY

    B->>S: HWDATA
    S->>B: HREADY

    S->>B: HRESP
7. Read Transaction Flow
mermaid
sequenceDiagram
    participant B as Backend
    participant S as AHB-LITE Slave

    B->>S: HADDR, HWRITE=0, HTRANS=NONSEQ
    S->>B: HREADY

    S->>B: HRDATA, HRESP
8. Error Handling
AHB‑LITE supports:

OKAY

ERROR

The backend maps:

HRESP	Parser Error
OKAY	0x00
ERROR	0x02 (SLVERR)


Additional parser errors:

Condition	Error Code
cmd_len > 1	BURST_ERR
invalid address	DECERR


9. Response Mapping
Write
HRESP → rsp_err_code

cmd_id → rsp_id

Read
HRDATA → rsp_data

HRESP → rsp_err_code

cmd_id → rsp_id

10. Atomic Mode
Atomic mode is handled by the arbiter.
The backend executes commands in the order received.

11. Summary
The AHB‑LITE backend:

converts parser commands into AHB‑LITE transactions

supports only single‑beat transfers

handles wait‑states

propagates AHB‑LITE error codes

returns responses through t_rsp_in

is designed for simulation, not synthesis

It is the simplest AHB‑based backend in DexterLab.

End of Document
