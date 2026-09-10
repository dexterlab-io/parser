# DexterLab AHB‑LITE Command Wrapper
The AHB‑LITE Command Wrapper (`cmd_wrapper_ahb_lite`) is the module that connects
the DexterLab parser ecosystem to an AHB‑LITE bus.  
Internally, it instantiates the AHB‑FULL executor, but externally it exposes a
standard AHB‑LITE interface.

This wrapper is used when the target peripheral or memory‑mapped block supports
AHB‑LITE instead of AHB‑FULL.

---

# 1. Overview

AHB‑LITE is a simplified version of AHB:

- no multi‑master arbitration,
- no SPLIT/RETRY responses,
- no complex HBURST encodings,
- no multi‑beat wrap bursts,
- no HTRANS interleaving,
- no HREADYOUT/HRESP complexity.

The wrapper takes full AHB‑FULL commands from the parser and **adapts them** to
AHB‑LITE semantics.

Internally:

t_cmd_out → AHB-FULL executor → AHB-LITE adapter → AHB-LITE bus

Codice

Externally:

AHB-LITE signals → peripheral

Codice

---

# 2. Architecture Diagram

```mermaid
flowchart LR
    A[t_cmd_out] --> W[cmd_wrapper_ahb_lite]
    W --> X[AHB-FULL Executor]
    X --> Y[AHB-LITE Adapter]
    Y --> Z[AHB-LITE Slave]
    Z --> Y
    Y --> W
    W --> B[t_rsp_in]
3. Why AHB‑FULL Inside AHB‑LITE?
The AHB‑FULL executor already implements:

HADDR

HWRITE

HSIZE

HBURST

HTRANS

HREADY

HRESP

HRDATA

Instead of rewriting a second executor, the wrapper:

forces AHB‑FULL into AHB‑LITE mode,

removes burst semantics,

removes wrap semantics,

forces HBURST = SINGLE,

forces HTRANS = NONSEQ,

forces single‑beat transfers.

This keeps the codebase small and consistent.

4. AHB‑LITE Interface
The wrapper exposes the standard AHB‑LITE signals:

Address + Control
HADDR

HWRITE

HSIZE

HTRANS

HREADY (input)

Write Data
HWDATA

Read Data
HRDATA

HRESP (OKAY or ERROR)

AHB‑LITE does not support:

HBURST

multi‑beat bursts

wrap bursts

SPLIT/RETRY

multi‑master arbitration

5. Command Mapping
Generic Field	AHB‑LITE Behavior
cmd_write	HWRITE
cmd_addr	HADDR
cmd_len	ignored → forced to 1 beat
cmd_burst	ignored
cmd_wrap	ignored
cmd_data	HWDATA
cmd_wstrb	ignored (AHB has no byte strobes)
cmd_id	response correlation


6. AHB‑LITE Adaptation Rules
The wrapper enforces:

✔ Single‑beat writes
Codice
HBURST = SINGLE
HTRANS = NONSEQ
✔ Single‑beat reads
Codice
HBURST = SINGLE
HTRANS = NONSEQ
✔ No bursts
Even if the parser sends:

Codice
BURST_WRITE addr len=16
the wrapper converts it into:

Codice
16 AHB-LITE single writes
✔ No wrap
Ignored.

✔ No multi‑beat sequences
All multi‑beat commands are decomposed into multiple single‑beat AHB‑LITE transfers.

7. Internal Flow
mermaid
sequenceDiagram
    participant P as Parser
    participant W as Wrapper
    participant F as AHB-FULL Executor
    participant L as AHB-LITE Bus

    P->>W: t_cmd_out
    W->>F: full AHB command
    F->>W: HADDR/HWRITE/HWDATA/HRESP
    W->>L: AHB-LITE signals
    L->>W: HREADY/HRESP/HRDATA
    W->>P: t_rsp_in
8. Error Handling
AHB‑LITE supports only:

OKAY (0x00)

ERROR (0x02)

The wrapper maps AHB‑FULL errors to AHB‑LITE semantics:

AHB‑FULL Error	AHB‑LITE Mapping
OKAY	OKAY
SLVERR	ERROR
DECERR	ERROR
BOUNDARY_ERR	ERROR
BURST_ERR	ERROR


9. Atomic Mode
Atomic mode is handled by the arbiter.
The wrapper does not enforce atomicity.

10. Summary
cmd_wrapper_ahb_lite:

instantiates the AHB‑FULL executor,

adapts AHB‑FULL semantics to AHB‑LITE,

forces single‑beat transfers,

removes burst/wrap logic,

maps AHB‑FULL errors to AHB‑LITE,

is deterministic and zero‑latency,

is designed for simulation.

It is the AHB‑LITE counterpart of cmd_wrapper_ahb_full.

End of Document
