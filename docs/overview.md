# DexterLab Command Parser — Overview

The *DexterLab Command Parser* is a unified command‑execution framework designed to
provide a simple, consistent, and bus‑agnostic control interface for hardware
modules. The parser receives structured commands, decodes them into a standard
VHDL record (`t_cmd_out`), and forwards them to a backend *slave* module that
executes the requested operation on registers, RAM, FIFO, or custom peripherals.

The project aims to offer a scalable and extensible command infrastructure that
can operate over multiple bus technologies (Generic, AXI, AHB) while preserving a
single, stable command interface.

---

## 1. System Architecture

The command parser system is composed of three main elements:

- **Parser Engine**  
  Interprets incoming commands (from testbench, firmware, debug tools) and
  produces a normalized command structure.

- **Slave Backend**  
  Executes the decoded command. Multiple backends exist:
  - `parser_slave_generic` (current implementation)
  - `parser_axi_full` (in development)
  - `parser_axi_lite` (planned)
  - `parser_ahb_full` (planned)
  - `parser_ahb_lite` (planned)

- **Master + Arbiter (future)**  
  Allows multiple command sources (parser, CPU, DMA, RISC‑V core, etc.) to share
  the command interface through arbitration. A placeholder implementation already
  exists in the testbench.

Conceptual diagram:

Parser → Arbiter → Slave → (REG / RAM / FIFO)


---

## 2. Project Goals

- Provide a **consistent** and **bus‑independent** command interface.
- Support complex operations (burst, wrap, FIFO, WSTRB).
- Emulate AXI semantics even without an AXI bus.
- Offer a lightweight backend for simulation and prototyping.
- Prepare the infrastructure for full AXI‑Full, AXI‑Lite, AHB‑Full, and AHB‑Lite versions.
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
- future AXI/AHB‑related parameters

This file is the central point for adapting the parser to different systems.

Full documentation:  
**docs/cmd_cfg.md**

---

## 4. Available Backends

### ✔ `parser_slave_generic`
A simple backend without AXI handshake, but with AXI‑like semantics:

- INCR / WRAP / FIFO bursts  
- WSTRB write support  
- 4‑KB boundary check  
- AXI‑style error codes (OKAY, SLVERR, DECERR)  
- parser‑specific errors (BOUNDARY_ERR, BURST_ERR)

### ✔ `parser_axi_full` (in development)
A full AXI4 backend:

- AW/W/B and AR/R handshake  
- timeout handling  
- real AXI BRESP/RRESP  
- full AXI burst support  
- multi‑ID support

### ✔ `parser_axi_lite` (planned)
A lightweight AXI‑Lite backend, typically used for register‑mapped peripherals.

### ✔ `parser_ahb_full` (planned)
A full AHB backend with:

- pipelined address/data phases  
- HTRANS, HBURST, HSIZE  
- full burst semantics

### ✔ `parser_ahb_lite` (planned)
An AHB‑Lite backend:

- single‑cycle transfers  
- wait‑state insertion  
- simplified burst support

---

## 5. Future Wrappers and Bridges

The architecture is designed to support protocol conversion:

- **AXI‑Full → AXI‑Lite wrapper**  
- **AHB‑Full → AHB‑Lite wrapper**  
- **AXI → AHB bridge**  
- **AHB → AXI bridge**

These modules will allow the same command parser to drive heterogeneous systems.

---

## 6. Generic Command Interface

All backends (Generic, AXI, AHB) share the same command interface:

### Command input (`t_cmd_out`)
- command ID  
- address  
- data array  
- burst length  
- write/read flag  
- burst type (single, incr, wrap, fifo)  
- WSTRB mask  
- additional parser metadata

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

The placeholder *master* in the testbench will be replaced by a real **RISC‑V core**
in future versions. The RISC‑V CPU will:

- generate commands using the same `t_cmd_out` interface  
- share the command bus through the arbiter  
- access RAM, FIFO, and registers using the parser protocol  
- coexist with the external parser (testbench or debug tool)

This enables hybrid systems where:

- firmware running on RISC‑V  
- and external tools  
- both control the same hardware resources.

---

## 8. RISC‑V Integration and TileLink Support (future)

The future master replacing the current placeholder will be a RISC‑V core.  
Modern RISC‑V systems typically use **TileLink** as their internal interconnect
protocol. TileLink is an open, scalable and cache‑coherent protocol originally
developed within the Berkeley Rocket Chip ecosystem and widely adopted in
open‑source RISC‑V SoCs.

TileLink variants include:

- **TL‑UL** — TileLink Uncached Lightweight (similar to AXI‑Lite)
- **TL‑UH** — TileLink Uncached Heavy (similar to AHB‑Full)
- **TL‑C** — TileLink Coherent (for multi‑core systems with cache coherence)
- **TL‑F** — TileLink FIFO (streaming accelerators)

The DexterLab Command Parser will interface with RISC‑V systems through protocol
bridges and wrappers:

- TileLink → AXI  
- TileLink → AHB  
- AXI → TileLink  
- AHB → TileLink  
- AXI‑Full → AXI‑Lite wrapper  
- AHB‑Full → AHB‑Lite wrapper  

This allows the command parser to act as a universal command endpoint across
heterogeneous bus architectures.

The RISC‑V core will generate commands using the same `t_cmd_out` interface used
by the external parser, enabling hybrid systems where firmware and external tools
share the same hardware resources through the arbiter.

---

## 9. Address Map

The generic backend exposes three memory regions:

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
- invalid address → DECERR  
- semantic errors → BOUNDARY_ERR / BURST_ERR

Full documentation:  
**docs/command_set.md**

---

## 11. Testbench

The testbench includes:

- parser engine  
- arbiter  
- master placeholder (future RISC‑V)  
- slave backend  
- RAM/FIFO/REG models  
- test sequences for burst, wrap, wstrb, and error conditions

Full documentation:  
**docs/testbench.md**

---

## 12. License

The project will be released under the **MIT License**, a permissive open‑source
license that allows:

- commercial use  
- modification  
- distribution  
- private use  

with minimal restrictions.

End of Document
