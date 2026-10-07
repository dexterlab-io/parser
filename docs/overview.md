markdown
# DexterLab Command Parser — Overview

The *DexterLab Command Parser* is a unified command‑execution framework designed
to provide a simple, consistent, and bus‑agnostic control interface for hardware
modules. The parser receives structured commands, decodes them into a standard
VHDL record (`t_cmd_out`), and forwards them to a backend module that executes
the requested operation on registers, RAM, FIFO, or custom peripherals.

The project offers a scalable and extensible command infrastructure that operates
over multiple bus technologies (Generic, AXI, AHB) while preserving a single,
stable command interface.

---

## 1. System Architecture

The command parser system is composed of three main elements:

- **Parser Engine**  
  Interprets incoming commands (from `.cmd` files, testbench, firmware) and
  produces a normalized command structure.

- **Backend Executor**  
  Executes the decoded command. Multiple backends exist:
  - `backend_generic` (current implementation)
  - `backend_axi_full`
  - `backend_axi_lite`
  - `backend_ahb_full`
  - `backend_ahb_lite`
  - `tilelink_bridge` (protocol conversion)

- **Master + Arbiter**  
  Allows multiple command sources (parser, CPU, DMA, RISC‑V core, etc.) to share
  the command interface through arbitration.

Conceptual diagram:

Parser → Arbiter → Backend → (REG / RAM / FIFO / Bus)

Codice

---

## 2. Project Goals

- Provide a **consistent** and **bus‑independent** command interface.
- Support complex operations (burst, wrap, FIFO, WSTRB).
- Offer lightweight backends for simulation and prototyping.
- Provide full AXI‑Full, AXI‑Lite, AHB‑Full, and AHB‑Lite support.
- Provide TileLink integration through a dedicated bridge.
- Document every component clearly for external users.

---

## 3. Configuration File (`cmd_cfg.vhd`)

The file `cmd_cfg.vhd` defines all global configuration parameters:

- address width (`C_ADDR_WIDTH`)
- data width (`C_DATA_WIDTH`)
- command ID width (`C_ID_WIDTH`)
- burst limits
- parser configuration options
- backend configuration options

This file is the central point for adapting the parser to different systems.

Full documentation:  
**docs/cmd_cfg.md**

---

## 4. Available Backends

### ✔ `backend_generic`
A simple backend without AXI/AHB handshake, but with AXI‑like semantics:

- INCR / WRAP / FIFO bursts  
- WSTRB write support  
- 4‑KB boundary check  
- unified error codes (OKAY, SLVERR, DECERR, BOUNDARY_ERR, BURST_ERR)

### ✔ `backend_axi_full`
A full AXI4 backend:

- AW/W/B and AR/R handshake  
- timeout handling  
- AXI BRESP/RRESP  
- full AXI burst support  
- multi‑ID support

### ✔ `backend_axi_lite`
A lightweight AXI‑Lite backend:

- single‑beat transfers  
- WSTRB support  
- ideal for MMIO registers

### ✔ `backend_ahb_full`
A full AHB backend:

- pipelined address/data phases  
- HTRANS, HBURST, HSIZE  
- full burst semantics

### ✔ `backend_ahb_lite`
An AHB‑Lite backend:

- single‑cycle transfers  
- wait‑state insertion  
- simplified burst support

### ✔ `tilelink_bridge`
Converts TileLink UL/UH transactions into `t_cmd_out` commands.

---

## 5. Protocol Conversion

DexterLab supports protocol conversion through dedicated modules:

- **TileLink → AXI**  
- **TileLink → AHB**  
- **AXI → TileLink**  
- **AHB → TileLink**

Wrappers (AXI‑Lite, AHB‑Lite) have been removed from the architecture and replaced
by dedicated backends.

---

## 6. Generic Command Interface

All backends share the same command interface:

### Command input (`t_cmd_out`)
- command ID  
- address  
- data array  
- burst length  
- write/read flag  
- burst type (single, incr, wrap, fifo)  
- WSTRB mask  
- atomic flag  
- parser metadata

### Response output (`t_rsp_in`)
- valid beat  
- last beat  
- read data  
- error valid  
- error code  
- error info  
- response ID

This interface is designed to be compatible with future CPU integration.

---

## 7. RISC‑V Integration (future)

The placeholder master in the testbench will be replaced by a real **RISC‑V core**.

The RISC‑V CPU will:

- generate commands using the same `t_cmd_out` interface  
- share the command bus through the arbiter  
- access RAM, FIFO, and registers using the parser protocol  
- coexist with the external parser (testbench or debug tool)

This enables hybrid systems where:

- firmware running on RISC‑V  
- and external tools  
- both control the same hardware resources.

---

## 8. TileLink Support

Modern RISC‑V systems use **TileLink** as their internal interconnect protocol.

DexterLab integrates TileLink through the **TileLink Bridge**, which converts TL
transactions into `t_cmd_out` commands.

Supported TileLink variants:

- **TL‑UL** — lightweight uncached (similar to AXI‑Lite)  
- **TL‑UH** — uncached heavy (similar to AHB‑Full)  

Coherent variants (TL‑C) are out of scope for DexterLab 2026.

---

## 9. Address Map (Generic Backend)

| Region | Address Range       | Description            |
|--------|----------------------|------------------------|
| REG    | 0x0000–0x001F        | 8 zero‑wait‑state registers |
| RAM    | 0x1000–0x2FFF        | RAM with WSTRB support |
| FIFO   | 0x3000 / 0x3100      | FIFO write / FIFO read |

Full documentation:  
**docs/address_map.md**

---

## 10. Supported Commands

The parser supports:

- WRITE  
- READ  
- WSTRB_WRITE  
- BURST (INCR, WRAP)  
- FIFO (FIXED)  
- CHECK  
- error reporting (DECERR, SLVERR, BOUNDARY_ERR, BURST_ERR)

Full documentation:  
**docs/command_set.md**

---

## 11. Testbench

The testbench includes:

- parser engine  
- arbiter  
- master placeholder  
- backend executor  
- RAM/FIFO/REG models  
- test sequences for burst, wrap, wstrb, and error conditions

Full documentation:  
**docs/testbench.md**

---

## 12. License

The project is released under the **MIT License**, a permissive open‑source
license that allows:

- commercial use  
- modification  
- distribution  
- private use  

with minimal restrictions.

---

# End of Document
