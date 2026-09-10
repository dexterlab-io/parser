# DexterLab Command Flow (End-to-End)
This document describes the complete execution flow of a DexterLab command file,
from `.cmd` parsing to bus-level execution and response handling.

The flow is identical for AXI-FULL, AXI-LITE, AHB-FULL, AHB-LITE, and TileLink
(backends and wrappers adapt the command format as needed).

---

# 1. Overview

The full command path is:

file.cmd → parser → arbiter → wrapper → backend → bus → response → parser

Codice

Each stage is independent and bus-agnostic.

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

- parsing stops,
- an error message is printed,
- no hardware command is generated.

---

# 3. Stage 2 — Command Translation (`t_cmd_out`)

Each parsed command is converted into a hardware command record:

t_cmd_out

Codice

Fields include:

- write/read flag  
- address  
- burst/wrap/fifo flags  
- length  
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
- hardware master (future)  

Rules:

- atomic mode locks the active source  
- pending commands have priority  
- otherwise, first valid source wins  

Once selected, the arbiter forwards the command to the wrapper/backend.

---

# 5. Stage 4 — Wrapper

The wrapper adapts the generic command to the selected bus:

- AXI-FULL  
- AXI-LITE  
- AHB-FULL  
- AHB-LITE  

Examples:

- AXI-LITE → forces single-beat  
- AHB-LITE → forces NONSEQ  
- AXI-FULL → preserves bursts  
- AHB-FULL → preserves bursts  

The wrapper does **not** modify command semantics.

---

# 6. Stage 5 — Backend

The backend converts the command into bus transactions:

- AXI: AW/W/B or AR/R  
- AHB: HADDR/HWRITE/HTRANS/HWDATA/HRDATA  
- TileLink: a/d channels  

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

# 7. Stage 6 — Bus Execution

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

# 8. Stage 7 — Response (`t_rsp_in`)

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

# 9. End-to-End Example

### File
WRITE 0x80000000 0x55
READ  0x80000000

Codice

### Flow
1. Parser builds WRITE command  
2. Arbiter accepts  
3. Wrapper adapts to bus  
4. Backend performs write  
5. Backend returns OKAY  
6. Parser builds READ command  
7. Backend returns data  
8. Parser prints result  

---

# 10. Summary

The DexterLab command flow is:

1. parse  
2. validate  
3. translate  
4. arbitrate  
5. adapt  
6. execute  
7. respond  

This document defines the complete end-to-end behavior of the DexterLab command
system.

---

# End of Document
