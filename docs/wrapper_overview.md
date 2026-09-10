# DexterLab Wrapper Overview
DexterLab provides four bus wrappers that connect the generic command parser
(`t_cmd_out` / `t_rsp_in`) to different bus protocols:

- AXI‑FULL  
- AXI‑LITE  
- AHB‑FULL  
- AHB‑LITE  

All wrappers share the same philosophy:

> **The parser is bus‑agnostic.  
> The backend implements the bus.  
> The wrapper connects the two.**

This document explains the purpose, structure, and differences between the four
wrappers.

---

# 1. Why Wrappers Exist

The DexterLab parser produces high‑level commands:

WRITE addr data
READ addr
BURST_WRITE addr len data[]
WRAP_READ addr len
CHECK addr expected
...

Codice

These commands are **generic** and independent of any bus protocol.

To execute them on a real bus (AXI or AHB), DexterLab uses:

1. **Backends**  
   - `backend_axi_full`  
   - `backend_ahb_full`

2. **Wrappers**  
   - `cmd_wrapper_axi_full`  
   - `cmd_wrapper_axi_lite`  
   - `cmd_wrapper_ahb_full`  
   - `cmd_wrapper_ahb_lite`

The wrapper is the glue between:

parser → arbiter → wrapper → backend → bus

Codice

---

# 2. Architecture Diagram

```mermaid
flowchart LR
    A[t_cmd_out] --> B[Wrapper]
    B --> C[Backend]
    C --> D[Bus Interface]
    D --> C
    C --> B
    B --> E[t_rsp_in]
Wrappers do not interpret commands.
They only route signals and adapt bus semantics when needed.

3. The Four Wrappers
3.1 cmd_wrapper_axi_full
Purpose
Connects the parser to a full AXI‑FULL bus.

Characteristics
multi‑beat bursts

wrap bursts

WSTRB support

AW/W/B + AR/R channels

high throughput

full error reporting

Internal Structure
Instantiates:

backend_axi_full

No adaptation is required.

3.2 cmd_wrapper_axi_lite
Purpose
Connects the parser to an AXI‑LITE bus.

Characteristics
single‑beat transfers

no bursts

no wrap

WSTRB supported

simple control/status access

Internal Structure
Instantiates:

backend_axi_full

Then adapts AXI‑FULL → AXI‑LITE:

forces AWLEN/ARLEN = 0

forces AWBURST/ARBURST = FIXED

forces WLAST = 1

decomposes bursts into multiple AXI‑LITE single transfers

3.3 cmd_wrapper_ahb_full
Purpose
Connects the parser to an AHB‑FULL bus.

Characteristics
multi‑beat bursts

wrap bursts

deterministic timing

single channel (address + data)

simple error reporting

Internal Structure
Instantiates:

backend_ahb_full

No adaptation is required.

3.4 cmd_wrapper_ahb_lite
Purpose
Connects the parser to an AHB‑LITE bus.

Characteristics
single‑beat transfers

no bursts

no wrap

deterministic timing

simple integration

Internal Structure
Instantiates:

backend_ahb_full

Then adapts AHB‑FULL → AHB‑LITE:

forces HBURST = SINGLE

forces HTRANS = NONSEQ

decomposes bursts into multiple AHB‑LITE single transfers

4. Comparison Table
Wrapper	Backend	External Bus	Bursts	Wrap	WSTRB	Notes
AXI‑FULL	AXI‑FULL	AXI‑FULL	✔	✔	✔	full performance
AXI‑LITE	AXI‑FULL	AXI‑LITE	✘	✘	✔	decomposes bursts
AHB‑FULL	AHB‑FULL	AHB‑FULL	✔	✔	✘	deterministic timing
AHB‑LITE	AHB‑FULL	AHB‑LITE	✘	✘	✘	decomposes bursts


5. Atomic Mode
Atomic mode (cmd_atomic = '1') is enforced by the arbiter.

Wrappers do not implement atomicity.
They simply forward commands in the order received.

6. Error Handling
Wrappers do not generate errors.
Errors come from the backend:

AXI‑FULL: OKAY, SLVERR, DECERR, custom

AXI‑LITE: OKAY, SLVERR

AHB‑FULL: OKAY, ERROR

AHB‑LITE: OKAY, ERROR

Wrappers forward error codes unchanged.

7. Why Wrappers Are Separate Modules
✔ Clean separation of concerns
Parser is bus‑agnostic.
Backend is protocol‑specific.
Wrapper is interface‑specific.

✔ Reusability
The same backend can serve multiple wrappers.

✔ Scalability
Future wrappers (TileLink, Wishbone, APB) can be added easily.

✔ Simplicity
Wrappers contain no logic except routing and adaptation.

8. Summary
DexterLab provides four wrappers:

AXI‑FULL → full performance

AXI‑LITE → simple MMIO

AHB‑FULL → deterministic mid‑range systems

AHB‑LITE → microcontroller‑class peripherals

All wrappers:

use the same parser

use the same arbiter

use the same command interface

use the same response interface

differ only in bus semantics

This modular design makes DexterLab flexible, scalable, and easy to integrate
into any SoC architecture.

End of Document
