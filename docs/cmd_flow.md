markdown
# DexterLab Command Flow (End-to-End)

This document describes the complete execution flow of a DexterLab command file,
from `.cmd` parsing to bus-level execution and response handling.

The flow is identical for AXI-FULL, AXI-LITE, AHB-FULL, AHB-LITE, and TileLink.
Backends convert the generic command format into protocol-specific bus
transactions.

---

# 1. Overview

The full command path is:

file.cmd → parser → arbiter → backend → bus → response → parser

Codice

Each stage is independent and bus-agnostic.

Wrappers no longer exist in DexterLab 2026.

---

# 2. Stage 1 — Command File Parsing

The parser reads the `.cmd` file line-by-line:

1. remove whitespace  
2. ignore comments  
3. tokenize the command  
4. validate syntax  
5. validate semantics  
6. build an internal command structure  

If any error is detected:

- parsing stops  
- an error message is printed  
- no hardware command is generated  

---

# 3. Stage 2 — Command Translation (`t_cmd_out`)

Each parsed command is converted into a hardware command record:

t_cmd_out

Codice

Fields include:

- write/read flag  
- address  
- burst / wrap / FIFO flags  
- length (1–256 beats)  
- data words  
- byte strobes  
- atomic flag  
- command ID  

The parser asserts:

cmd_valid = 1

Codice

until the arbiter accepts the command.

---

# 4. Stage 3 — Arbiter

The arbiter selects between:

- parser  
- hardware master (future RISC‑V TileLink master)  

Rules:

- atomic mode locks the active source  
- pending commands have priority  
- otherwise, first valid source wins  

Once selected, the arbiter forwards the command directly to the backend.

---

# 5. Stage 4 — Backend

The backend converts the generic command into protocol-specific bus transactions:

- **AXI-FULL**: AW/W/B + AR/R  
- **AXI-LITE**: AW/W/B + AR/R (single beat)  
- **AHB-FULL**: HADDR/HWRITE/HTRANS/HWDATA/HRDATA  
- **AHB-LITE**: single-beat AHB transactions  
- **TileLink Bridge**: TL a/d channels → `t_cmd_out`  

The backend enforces:

- burst rules  
- wrap rules  
- alignment  
- boundary constraints  
- error detection  

Errors are reported through:

rsp_err_valid = 1
rsp_err_code
rsp_err_info

Codice

---

# 6. Stage 5 — Bus Execution

The bus executes the transaction:

- single read/write  
- burst  
- wrap burst  
- FIFO operation  

The bus may introduce:

- wait states  
- backpressure  
- error responses  

The backend handles these and returns a unified response.

---

# 7. Stage 6 — Response (`t_rsp_in`)

The backend returns:

- `rsp_valid`  
- `rsp_last`  
- `rsp_data`  
- `rsp_err_valid`  
- `rsp_err_code`  
- `rsp_err_info`  
- `rsp_id`  

The parser consumes responses until:

rsp_last = 1

Codice

If an error occurs, the parser logs it and stops execution unless configured
otherwise.

---

# 8. End-to-End Example

### File

```text
WRITE 0x80000000 0x55
READ  0x80000000
Flow
Parser builds WRITE command

Arbiter accepts

Backend performs AXI/AHB write

Backend returns OKAY

Parser builds READ command

Backend performs read

Backend returns data

Parser prints result

9. Summary
The DexterLab command flow is:

parse

validate

translate

arbitrate

execute

respond

This document defines the complete end-to-end behavior of the DexterLab command
system.

End of Document
