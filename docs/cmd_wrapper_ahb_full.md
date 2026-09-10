# DexterLab AHB‑FULL Command Wrapper
The AHB‑FULL Command Wrapper (`cmd_wrapper_ahb_full`) is the module that connects
the DexterLab parser ecosystem to a real AHB‑FULL bus.  
It receives high‑level commands (`t_cmd_out`) from the arbiter and forwards them
to the AHB‑FULL executor, which generates proper AHB‑FULL transactions.

This wrapper performs **pure routing**, without modifying command semantics.

---

# 1. Overview

The wrapper instantiates:

- the AHB‑FULL executor  
- the generic command interface  
- the AHB response interface  

Its responsibilities:

- forward commands from the arbiter to the AHB executor,
- forward AHB responses back to the arbiter,
- ensure deterministic routing,
- ensure zero‑latency propagation,
- ensure no modification of command semantics.

It does **not**:

- arbitrate,
- buffer,
- reorder,
- modify addresses,
- modify burst lengths,
- modify HTRANS/HBURST,
- modify error codes.

---

# 2. Architecture Diagram

```mermaid
flowchart LR
    A[t_cmd_out] --> W[cmd_wrapper_ahb_full]
    W --> X[AHB-FULL Executor]
    X --> W
    W --> B[t_rsp_in]
3. Wrapper Responsibilities
✔ Pure routing
The wrapper simply connects:

Codice
cmd_out → ahb_cmd
rsp_in  → ahb_rsp
✔ No logic
No FSM, no buffering, no splitting.

✔ No protocol interpretation
The AHB executor handles:

HADDR

HWRITE

HSIZE

HBURST

HTRANS

HREADY

HRESP

HRDATA

The wrapper does not.

✔ No timing logic
The arbiter controls valid and ready.

4. Interface Mapping
Generic Interface	AHB Executor
cmd_write	HWRITE
cmd_addr	HADDR
cmd_len	burst length
cmd_burst	HBURST (INCR)
cmd_wrap	HBURST (WRAP)
cmd_data	HWDATA
cmd_wstrb	ignored (AHB has no byte strobes)
cmd_id	transaction ID


Responses:

AHB Executor	Generic Interface
HRDATA	rsp_data
HRESP	rsp_err_code
cmd_id	rsp_id
HTRANS	used internally
HREADY	used internally


5. AHB‑FULL Adaptation Rules
The wrapper enforces:

✔ Full AHB semantics
All burst types are supported:

SINGLE

INCR

WRAP

✔ Multi‑beat sequences
The wrapper forwards multi‑beat bursts directly to the executor.

✔ No modification of burst length
If the parser sends:

Codice
BURST_WRITE addr len=16
the wrapper forwards:

Codice
HBURST = INCR16
HTRANS = NONSEQ → SEQ → SEQ → ...
✔ No modification of wrap semantics
Wrap bursts are forwarded unchanged.

✔ No modification of HSIZE
Always 32‑bit (C_DATA_WIDTH).

6. Internal Flow
mermaid
sequenceDiagram
    participant P as Parser
    participant W as Wrapper
    participant F as AHB-FULL Executor
    participant B as AHB Bus

    P->>W: t_cmd_out
    W->>F: full AHB command
    F->>B: HADDR/HWRITE/HTRANS/HBURST/HWDATA
    B->>F: HREADY/HRESP/HRDATA
    F->>W: t_rsp_in
    W->>P: t_rsp_in
7. Error Handling
AHB‑FULL supports:

OKAY (0x00)

SLVERR (0x02)

The wrapper forwards errors unchanged.

If the executor detects:

invalid address

burst crossing forbidden boundary

wrap mask error

FIFO misuse

CHECK mismatch

it generates:

rsp_err_valid = '1'

rsp_err_code

rsp_err_info

rsp_err_id

The wrapper does not modify these fields.

8. Atomic Mode
Atomic mode is handled by the arbiter.
The wrapper does not enforce atomicity.

9. Summary
cmd_wrapper_ahb_full:

instantiates the AHB‑FULL executor,

performs pure routing,

does not modify commands,

does not interpret protocol semantics,

is deterministic and zero‑latency,

is designed for simulation.

It is the AHB‑FULL counterpart of cmd_wrapper_axi_full.

End of Document
