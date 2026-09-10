# DexterLab AXI‑FULL Command Wrapper
The AXI‑FULL Command Wrapper (`cmd_wrapper_axi_full`) is the module that connects
the DexterLab parser ecosystem to a real AXI‑FULL bus.  
It receives high‑level commands (`t_cmd_out`) from the arbiter and converts them
into AXI‑FULL transactions using the AXI executor.

This wrapper is intentionally simple: it performs **pure routing**, without
interpreting or modifying commands.

---

# 1. Overview

The wrapper instantiates:

- the AXI‑FULL executor  
- the generic command interface  
- the AXI response interface  

Its responsibilities:

- forward commands from the arbiter to the AXI executor,
- forward AXI responses back to the arbiter,
- ensure deterministic routing,
- ensure no modification of command semantics.

It does **not**:

- arbitrate,
- buffer,
- reorder,
- modify addresses,
- modify burst lengths,
- modify WSTRB,
- modify error codes.

---

# 2. Architecture Diagram

```mermaid
flowchart LR
    A[t_cmd_out] --> W[cmd_wrapper_axi_full]
    W --> X[AXI-FULL Executor]
    X --> W
    W --> B[t_rsp_in]
3. Wrapper Responsibilities
✔ Pure routing
The wrapper simply connects:

Codice
cmd_out → axi_cmd
rsp_in  → axi_rsp
✔ No logic
No FSM, no buffering, no splitting.

✔ No protocol interpretation
The AXI executor handles:

AW/W/B

AR/R

bursts

wrap

boundary rules

error codes

The wrapper does not.

✔ No timing logic
The arbiter controls valid and ready.

4. Interface Mapping
Generic Interface	AXI Executor
cmd_write	AW/AR channel selection
cmd_addr	AWADDR / ARADDR
cmd_len	AWLEN / ARLEN
cmd_burst	AWBURST / ARBURST
cmd_wrap	wrap mask logic
cmd_data	WDATA
cmd_wstrb	WSTRB
cmd_id	transaction ID


Responses:

AXI Executor	Generic Interface
RDATA	rsp_data
RRESP	rsp_err_code
BRESP	rsp_err_code
cmd_id	rsp_id
RLAST	rsp_last


5. Atomic Mode
Atomic mode is handled by the arbiter.
The wrapper does not enforce atomicity.

6. Error Propagation
The AXI executor generates:

rsp_err_valid

rsp_err_code

rsp_err_info

rsp_err_id

The wrapper forwards them unchanged.

7. Summary
cmd_wrapper_axi_full:

instantiates the AXI‑FULL executor,

performs pure routing,

does not modify commands,

does not interpret protocol semantics,

is deterministic and zero‑latency,

is designed for simulation.

It is the simplest and most transparent wrapper in DexterLab.

End of Document
