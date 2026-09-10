# DexterLab AXI‑LITE Command Wrapper
The AXI‑LITE Command Wrapper (`cmd_wrapper_axi_lite`) is the module that connects
the DexterLab parser ecosystem to an AXI‑LITE bus.  
Internally, it instantiates the AXI‑FULL executor, but externally it exposes a
standard AXI‑LITE interface.

This wrapper is used when the target peripheral or memory‑mapped block supports
AXI‑LITE instead of AXI‑FULL.

---

# 1. Overview

AXI‑LITE is a simplified version of AXI:

- no bursts,
- no wrap,
- no multi‑beat transfers,
- no complex HBURST/AWBURST logic,
- no WLAST/RLAST,
- no interleaving.

The wrapper takes full AXI‑FULL commands from the parser and **adapts them** to
AXI‑LITE semantics.

Internally:

t_cmd_out → AXI-FULL executor → AXI-LITE adapter → AXI-LITE bus

Codice

Externally:

AXI-LITE signals → peripheral

Codice

---

# 2. Architecture Diagram

```mermaid
flowchart LR
    A[t_cmd_out] --> W[cmd_wrapper_axi_lite]
    W --> X[AXI-FULL Executor]
    X --> Y[AXI-LITE Adapter]
    Y --> Z[AXI-LITE Slave]
    Z --> Y
    Y --> W
    W --> B[t_rsp_in]
3. Why AXI‑FULL Inside AXI‑LITE?
The AXI‑FULL executor already implements:

address channel,

data channel,

response channel,

error propagation,

burst splitting,

wrap logic,

WSTRB handling.

Instead of rewriting a second executor, the wrapper:

forces AXI‑FULL into AXI‑LITE mode,

removes burst semantics,

removes wrap semantics,

forces AWLEN/ARLEN = 0,

forces AWBURST/ARBURST = FIXED,

forces WLAST = 1,

forces single‑beat transfers.

This keeps the codebase small and consistent.

4. AXI‑LITE Interface
The wrapper exposes the standard AXI‑LITE signals:

Write Address
AWADDR

AWPROT

AWVALID

AWREADY

Write Data
WDATA

WSTRB

WVALID

WREADY

Write Response
BRESP

BVALID

BREADY

Read Address
ARADDR

ARPROT

ARVALID

ARREADY

Read Data
RDATA

RRESP

RVALID

RREADY

5. Command Mapping
Generic Field	AXI‑LITE Behavior
cmd_write	selects AW/W or AR
cmd_addr	forwarded directly
cmd_len	ignored → forced to 1 beat
cmd_burst	ignored
cmd_wrap	ignored
cmd_data	WDATA
cmd_wstrb	WSTRB
cmd_id	response correlation


6. AXI‑LITE Adaptation Rules
The wrapper enforces:

✔ Single‑beat writes
Codice
AWLEN = 0
WLAST = 1
✔ Single‑beat reads
Codice
ARLEN = 0
RLAST = 1
✔ No bursts
Codice
AWBURST = FIXED
ARBURST = FIXED
✔ No wrap
Ignored.

✔ No multi‑beat sequences
Even if the parser sends a burst command:

Codice
BURST_WRITE addr len=16
the wrapper converts it into:

Codice
16 AXI-LITE single writes
7. Internal Flow
mermaid
sequenceDiagram
    participant P as Parser
    participant W as Wrapper
    participant F as AXI-FULL Executor
    participant L as AXI-LITE Bus

    P->>W: t_cmd_out
    W->>F: full AXI command
    F->>W: AW/W/B or AR/R
    W->>L: AXI-LITE signals
    L->>W: AXI-LITE responses
    W->>P: t_rsp_in
8. Error Handling
AXI‑LITE supports only:

OKAY (0x00)

SLVERR (0x02)

The wrapper maps AXI‑FULL errors to AXI‑LITE semantics:

AXI‑FULL Error	AXI‑LITE Mapping
OKAY	OKAY
SLVERR	SLVERR
DECERR	SLVERR
BOUNDARY_ERR	SLVERR
BURST_ERR	SLVERR


9. Atomic Mode
Atomic mode is handled by the arbiter.
The wrapper does not enforce atomicity.

10. Summary
cmd_wrapper_axi_lite:

instantiates the AXI‑FULL executor,

adapts AXI‑FULL semantics to AXI‑LITE,

forces single‑beat transfers,

removes burst/wrap logic,

maps AXI‑FULL errors to AXI‑LITE,

is deterministic and zero‑latency,

is designed for simulation.

It is the AXI‑LITE counterpart of cmd_wrapper_axi_full.

End of Document
