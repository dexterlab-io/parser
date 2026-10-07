# DexterLab Bus Comparison Guide

This document provides a unified comparison of the bus protocols supported by
DexterLab through its backend executors:

- AXI‑FULL  
- AXI‑LITE  
- AHB‑FULL  
- AHB‑LITE  
- TileLink (UL/UH)

The goal is to give developers a clear understanding of the differences,
strengths, limitations, and use‑cases of each protocol when used with the
DexterLab command parser.

---

# 1. Overview

DexterLab supports multiple bus protocols through **modular backends**:

| Protocol | Backend Module |
|----------|----------------|
| AXI‑FULL | `backend_axi_full` |
| AXI‑LITE | `backend_axi_lite` |
| AHB‑FULL | `backend_ahb_full` |
| AHB‑LITE | `backend_ahb_lite` |
| TileLink | `tilelink_bridge` |

All protocols share the same high‑level command interface:

t_cmd_out → arbiter → backend → bus → t_rsp_in

Codice

Wrappers no longer exist.  
Backends connect **directly** to the arbiter.

---

# 2. High‑Level Comparison Table

| Feature | AXI‑FULL | AXI‑LITE | AHB‑FULL | AHB‑LITE | TileLink |
|---------|----------|----------|----------|----------|----------|
| Multi‑beat bursts | ✔ | ✘ | ✔ | ✘ | ✔ (UH) |
| Wrap bursts | ✔ | ✘ | ✔ | ✘ | ✔ (UH) |
| WSTRB support | ✔ | ✔ | ✘ | ✘ | ✔ (mask) |
| Separate channels | ✔ | ✔ | ✘ | ✘ | ✔ |
| Wait‑states | ✔ | ✔ | ✔ | ✔ | ✔ |
| Atomic ops | via arbiter | via arbiter | via arbiter | via arbiter | native |
| Error codes | rich | simple | simple | simple | simple |
| 4KB boundary rule | ✔ | ✘ | ✘ | ✘ | ✘ |
| Performance | ★★★★★ | ★★☆☆☆ | ★★★★☆ | ★★☆☆☆ | ★★★★☆ |
| Complexity | high | low | medium | low | medium/high |

---

# 3. AXI‑FULL

AXI‑FULL is the most powerful protocol supported by DexterLab.

### Strengths
- multi‑beat bursts (1–256 beats)
- wrap bursts
- WSTRB masking
- independent AW/W/B and AR/R channels
- high throughput
- strict protocol guarantees
- rich error reporting (OKAY, SLVERR, DECERR, custom)

### Limitations
- complex timing
- requires careful VALID/READY handling
- 4KB boundary rule

### Best Use Cases
- high‑performance memory systems  
- DMA engines  
- large SoCs  
- RISC‑V cores with AXI interconnects  

### DexterLab Implementation
Handled by `backend_axi_full`.

---

# 4. AXI‑LITE

AXI‑LITE is a simplified version of AXI‑FULL.

### Strengths
- simple  
- single‑beat transfers  
- WSTRB support  
- ideal for MMIO registers  

### Limitations
- no bursts  
- no wrap  
- limited error reporting  

### Best Use Cases
- configuration registers  
- low‑bandwidth peripherals  

### DexterLab Implementation
Handled by `backend_axi_lite` (direct backend, no wrapper).

---

# 5. AHB‑FULL

AHB‑FULL is a simpler alternative to AXI‑FULL.

### Strengths
- multi‑beat bursts  
- wrap bursts  
- deterministic timing  
- single channel (address + data)  

### Limitations
- no WSTRB  
- limited error reporting  
- no interleaving  

### Best Use Cases
- microcontroller‑class SoCs  
- deterministic bus timing environments  

### DexterLab Implementation
Handled by `backend_ahb_full`.

---

# 6. AHB‑LITE

AHB‑LITE is the lightweight version of AHB‑FULL.

### Strengths
- simple  
- single‑beat transfers  
- deterministic timing  
- easy to integrate  

### Limitations
- no bursts  
- no wrap  
- no SPLIT/RETRY  
- no multi‑master support  

### Best Use Cases
- MMIO registers  
- low‑bandwidth peripherals  
- microcontroller subsystems  

### DexterLab Implementation
Handled by `backend_ahb_lite` (direct backend, no wrapper).

---

# 7. TileLink (UL/UH)

TileLink is the native RISC‑V protocol.

### Strengths
- multi‑beat bursts (UH)  
- wrap bursts (UH)  
- atomic operations (Arithmetic/Logical)  
- mask‑based writes  
- scalable  
- cache‑coherent variants  

### Limitations
- more complex than AXI‑LITE/AHB‑LITE  
- minimal error reporting (single bit)  
- requires bridge logic for AXI/AHB systems  

### Best Use Cases
- RISC‑V SoCs  
- coherent memory systems  
- high‑performance interconnects  

### DexterLab Implementation
Handled by `tilelink_bridge`, which converts TL → `t_cmd_out`.

---

# 8. Protocol Diagrams

## AXI‑FULL

```mermaid
flowchart LR
    AW --> W --> B
    AR --> R
AHB‑FULL
mermaid
flowchart LR
    A[ADDR+CTRL] --> B[DATA] --> C[RESP]
TileLink
mermaid
flowchart LR
    A[a-channel] --> B[d-channel]
9. Summary
DexterLab supports a wide range of bus protocols through modular backends:

AXI‑FULL → high‑performance systems

AXI‑LITE → simple MMIO peripherals

AHB‑FULL → deterministic mid‑range systems

AHB‑LITE → microcontroller‑class peripherals

TileLink → RISC‑V native interconnects

All protocols share the same high‑level command interface, making the parser
backend‑agnostic and highly reusable.

End of Document
