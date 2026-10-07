markdown
# DexterLab TileLink Bridge

The TileLink Bridge is the module that connects TileLink‑based systems (such as
RISC‑V SoCs) to the DexterLab command ecosystem.  
It converts TileLink UL/UH transactions into `t_cmd_out` commands, allowing a
RISC‑V master to interact with DexterLab backends through the unified command
interface.

This bridge is essential for integrating DexterLab into real RISC‑V systems.

---

# 1. Overview

TileLink is the native bus protocol used in most RISC‑V SoCs:

- **TL‑UL** (Uncached Lightweight)  
- **TL‑UH** (Uncached Heavyweight)  

DexterLab uses AXI‑FULL, AXI‑LITE, AHB‑FULL, AHB‑LITE, and Generic backends.  
Therefore, a bridge is required to translate TileLink transactions into DexterLab
commands (`t_cmd_out`), and to translate DexterLab responses (`t_rsp_in`) back
into TileLink responses.

The bridge supports:

- TL → DexterLab (`t_cmd_out`)  
- DexterLab (`t_rsp_in`) → TL  

Backend selection (AXI/AHB/Generic) is handled by the arbiter + backend layer.

---

# 2. Architecture Diagram

```mermaid
flowchart LR
    A[TileLink Master (RISC-V)] --> B[TileLink Bridge]
    B --> C[t_cmd_out]
    C --> D[Arbiter]
    D --> E[Backend Executor]
    E --> D
    D --> F[t_rsp_in]
    F --> B
    B --> A
3. TileLink Concepts
TileLink transactions include:

a channel — requests

d channel — responses

optional b, c, e channels — used only in coherent systems (not supported)

The bridge focuses on:

TL‑UL (Uncached Lightweight)
single‑beat reads/writes

simple address/data semantics

TL‑UH (Uncached Heavyweight)
multi‑beat bursts

wrap semantics

atomic operations

These map naturally to DexterLab’s t_cmd_out.

4. Mapping TileLink → t_cmd_out
TileLink Field	t_cmd_out Field
a.opcode	cmd_write / read
a.address	cmd_addr
a.size	cmd_len (converted to beats)
a.mask	cmd_wstrb
a.data	cmd_data
a.source	cmd_id
a.param	burst / wrap / atomic


TileLink opcodes
Opcode	Meaning	Mapping
PutFullData	write	cmd_write = 1
PutPartialData	masked write	cmd_write = 1 + WSTRB
Get	read	cmd_write = 0
Arithmetic	atomic	cmd_atomic = 1
Logical	atomic	cmd_atomic = 1
Intent	prefetch	ignored
Acquire	cached	not supported


5. Mapping t_rsp_in → TileLink
t_rsp_in Field	TileLink Field
rsp_data	d.data
rsp_err_code	d.error
rsp_id	d.source
rsp_last	d.last


Error mapping
TileLink supports only one error bit.

DexterLab Error	TL Error
OKAY	0
SLVERR	1
DECERR	1
BURST_ERR	1
BOUNDARY_ERR	1


6. Burst Semantics
TileLink UL/UH supports:

single‑beat transfers

multi‑beat transfers (UH)

wrap bursts (UH)

These map directly to:

cmd_burst

cmd_wrap

cmd_len (1–256 beats)

Wrap mask
mermaid
flowchart TD
    A[offset] --> B[offset % (len*4)]
    B --> C[wrapped address]
7. Atomic Operations
TileLink atomic operations:

Arithmetic

Logical

map to:

Codice
cmd_atomic = '1'
Atomicity is enforced by the arbiter.

8. Bridge FSM
mermaid
stateDiagram-v2
    [*] --> TL_RECV
    TL_RECV --> CMD_BUILD: a_valid
    CMD_BUILD --> CMD_SEND: ready
    CMD_SEND --> WAIT_RSP
    WAIT_RSP --> TL_SEND: rsp_valid
    TL_SEND --> TL_RECV
9. Backend Selection
The TileLink Bridge does not interact directly with AXI/AHB signals.

Backend selection is handled by the DexterLab architecture:

Codice
TileLink → t_cmd_out → arbiter → backend → bus
Supported backends:

AXI‑FULL

AXI‑LITE

AHB‑FULL

AHB‑LITE

Generic

Selection is static at synthesis time.

10. Summary
The TileLink Bridge:

connects RISC‑V TileLink masters to DexterLab

converts TL requests into t_cmd_out

converts t_rsp_in into TL responses

supports bursts, wrap, atomic operations

supports AXI‑FULL, AXI‑LITE, AHB‑FULL, AHB‑LITE, and Generic backends

is designed for simulation and future hardware integration

It is the final piece that enables DexterLab to operate inside real RISC‑V SoCs.

End of Document
