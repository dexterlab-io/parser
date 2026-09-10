# DexterLab AHB‑FULL Backend
The AHB‑FULL Backend is the executor that converts high‑level parser commands
(`t_cmd_out`) into real AHB‑FULL transactions.  
It models the complete AHB protocol:

- HADDR  
- HWRITE  
- HSIZE  
- HBURST  
- HTRANS  
- HREADY  
- HRESP  
- HRDATA  

and supports:

- SINGLE transfers  
- INCR bursts  
- WRAP bursts  
- multi‑beat sequences  
- wait‑states  
- error propagation  

This backend is used to validate AHB‑FULL behavior in simulation.

---

# 1. Overview

The AHB‑FULL backend receives commands from the arbiter and generates AHB
transactions toward an AHB slave model.

It supports:

- WRITE  
- READ  
- CHECK  
- BURST_WRITE / BURST_READ / BURST_CHECK  
- WRAP_WRITE / WRAP_READ / WRAP_CHECK  

and enforces:

- correct HTRANS sequencing  
- correct HBURST encoding  
- correct address incrementing  
- correct wrap behavior  
- correct handling of HREADY wait‑states  
- correct error propagation (SLVERR, DECERR)

---

# 2. Architecture Diagram

```mermaid
flowchart LR
    A[t_cmd_out] --> B[AHB-FULL Backend]
    B --> C[AHB Bus Signals]
    C --> D[AHB Slave Model]
    D --> C
    B --> E[t_rsp_in]
3. AHB‑FULL Signals
Address + Control
HADDR

HWRITE

HSIZE

HBURST

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
cmd_burst	INCR burst
cmd_wrap	WRAP burst
cmd_fifo	not used in AHB
cmd_atomic	atomic mode (arbiter)
cmd_id	response correlation
cmd_addr	HADDR
cmd_len	number of beats
cmd_data	write data array
cmd_wstrb	ignored (AHB has no byte strobes)


5. AHB‑FULL FSM
mermaid
stateDiagram-v2
    [*] --> IDLE

    IDLE --> ADDR: cmd_valid
    ADDR --> DATA: HREADY = 1
    DATA --> DATA: more beats & HREADY = 1
    DATA --> RESP: last beat & HREADY = 1
    RESP --> IDLE: rsp_last = 1
6. HTRANS Sequencing
AHB requires:

first beat: HTRANS = NONSEQ

subsequent beats: HTRANS = SEQ

Diagram:

mermaid
flowchart LR
    A[Beat 0] --> B[NONSEQ]
    B --> C[Beat 1]
    C --> D[SEQ]
    D --> E[Beat 2]
    E --> F[SEQ]
7. HBURST Encoding
Burst Type	HBURST
SINGLE	000
INCR	001
WRAP4	010
INCR4	011
WRAP8	100
INCR8	101
WRAP16	110
INCR16	111


The backend selects HBURST based on:

cmd_burst

cmd_wrap

cmd_len

8. Address Incrementing
For INCR bursts:

mermaid
flowchart LR
    A[addr] --> B[addr + 4] --> C[addr + 8] --> D[...]
For WRAP bursts:

mermaid
flowchart TD
    A[offset] --> B[offset % (len*4)]
    B --> C[wrapped address]
9. Wait‑State Handling (HREADY)
AHB slaves may insert wait‑states:

mermaid
flowchart TD
    A[Beat i] --> B{HREADY?}
    B -->|Yes| C[Proceed]
    B -->|No| D[Hold HADDR/HWRITE/HTRANS]
The backend:

holds address and control signals when HREADY = 0

retries the same beat until HREADY = 1

10. Error Handling (HRESP)
AHB errors:

HRESP = OKAY → normal operation

HRESP = ERROR → SLVERR or DECERR

The backend maps errors to parser error codes:

HRESP	Parser Error
OKAY	0x00 (OKAY)
ERROR	0x02 (SLVERR)


If the address is invalid or burst crosses a forbidden boundary:

backend generates DECERR (0x03)

11. Write Transaction Flow
mermaid
sequenceDiagram
    participant B as Backend
    participant S as AHB Slave

    B->>S: HADDR, HWRITE=1, HTRANS=NONSEQ
    S->>B: HREADY

    loop len beats
        B->>S: HWDATA[i], HTRANS=SEQ
        S->>B: HREADY
    end

    S->>B: HRESP
12. Read Transaction Flow
mermaid
sequenceDiagram
    participant B as Backend
    participant S as AHB Slave

    B->>S: HADDR, HWRITE=0, HTRANS=NONSEQ
    S->>B: HREADY

    loop len beats
        S->>B: HRDATA[i], HRESP
        B->>S: HREADY
    end
13. Response Mapping
Write:

HRESP → rsp_err_code

cmd_id → rsp_id

Read:

HRDATA → rsp_data

HRESP → rsp_err_code

cmd_id → rsp_id

14. Atomic Mode
Atomic mode is handled by the arbiter.
The backend simply executes commands in the order received.

15. Summary
The AHB‑FULL backend:

converts parser commands into AHB transactions,

supports INCR and WRAP bursts,

handles wait‑states,

enforces HTRANS sequencing,

enforces HBURST encoding,

handles error propagation,

returns responses through t_rsp_in,

is designed for simulation, not synthesis.

It is the AHB counterpart of the AXI‑FULL backend and completes the dual‑bus
support of DexterLab.

End of Document
