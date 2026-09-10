# DexterLab Command Parser — Command Set

This document describes all commands supported by the DexterLab Command Parser.
It combines formal specification, practical examples, and visual diagrams to
clarify the semantics of each command category.

The command set is backend‑agnostic: every slave (Generic, AXI, AHB) receives the
same `t_cmd_out` structure and executes the command according to its own bus
semantics.

---

# 1. Command Enumeration

The parser supports the following commands:

CMD_NOP
CMD_SET_VAR
CMD_INCLUDE
CMD_PRINT
CMD_END_SIM
CMD_SET_ATOMIC
CMD_WAIT_TIME
CMD_WAIT_CLOCKS
CMD_WAIT_SIM_TIME
CMD_WSTRB_WRITE
CMD_WRITE
CMD_READ
CMD_CHECK
CMD_FIFO_WRITE
CMD_FIFO_READ
CMD_FIFO_CHECK
CMD_BURST_WRITE
CMD_BURST_READ
CMD_BURST_CHECK
CMD_WRAP_WRITE
CMD_WRAP_READ
CMD_WRAP_CHECK
CMD_FILL_LEN
CMD_FILL_RANGE
CMD_FILL_CHECK
CMD_POLL_READ
CMD_POLL_TOGGLE
CMD_POLL_PING
CMD_DUMP_LEN
CMD_DUMP_RANGE
CMD_DUMP_FILE_LEN
CMD_DUMP_FILE_RANGE
CMD_DUMP_FILE_CHECK_LEN
CMD_DUMP_FILE_CHECK_RANGE
CMD_STOP
CMD_UNKNOWN

Codice

---

# 2. INCLUDE

### Syntax
INCLUDE <filename>

Codice

### Description
Loads and executes another command file.

### Example
INCLUDE init_var.txt

Codice

### Typical use
SET_VAR BASE_RAM = 0x00001000
SET_VAR BASE_FIFO_WR = 0x00003000
SET_VAR BASE_FIFO_RD = 0x00003100

Codice

---

# 3. WAIT Commands

## 3.1 WAIT_CLOCKS

### Syntax
WAIT_CLOCKS <N>

Codice

### Example
WAIT_CLOCKS 5

Codice

---

## 3.2 WAIT_TIME

### Syntax
WAIT_TIME <time>

Codice

### Example
WAIT_TIME 10ns

Codice

---

## 3.3 WAIT_SIM_TIME

### Syntax
WAIT_SIM_TIME <time>

Codice

### Example
WAIT_SIM_TIME 450ns

Codice

---

# 4. SET_ATOMIC

### Syntax
SET_ATOMIC <0|1>

Codice

### Description
Enables or disables atomic execution mode.

### Diagram

```mermaid
flowchart LR
    A[SET_ATOMIC 1] --> B[Atomic Mode Enabled]
    B --> C[Commands Execute Sequentially]
    C --> D[No Interleaving Allowed]
    D --> E[SET_ATOMIC 0]
    E --> F[Atomic Mode Disabled]
5. WSTRB_WRITE
Syntax
Codice
WSTRB_WRITE <addr> <wstrb>
Example
Codice
WSTRB_WRITE BASE_RAM 0x00000098 0b0001
Diagram
mermaid
flowchart LR
    A[WSTRB_WRITE] --> B{WSTRB bit 0?}
    B -->|Yes| C[Write lane 0]
    B -->|No| D[Skip lane 0]
    A --> E{WSTRB bit 1?}
    E -->|Yes| F[Write lane 1]
    E -->|No| G[Skip lane 1]
    A --> H{WSTRB bit 2?}
    H -->|Yes| I[Write lane 2]
    H -->|No| J[Skip lane 2]
    A --> K{WSTRB bit 3?}
    K -->|Yes| L[Write lane 3]
    K -->|No| M[Skip lane 3]
6. WRITE / READ / CHECK
6.1 WRITE
Syntax
Codice
WRITE <addr> <data>
Example
Codice
WRITE BASE_RAM + 0x0000 0x12345678
6.2 READ
Syntax
Codice
READ <addr>
Example
Codice
READ BASE_RAM + 0x0000
6.3 CHECK
Syntax
Codice
CHECK <addr> <expected>
Example
Codice
CHECK BASE_RAM + 0x0000 0x12345678
7. FIFO Commands
7.1 FIFO_WRITE
Syntax
Codice
FIFO_WRITE <addr> <len> <data...>
Example
Codice
FIFO_WRITE BASE_FIFO_WR 8 0x11 0x22 0x33 0x44 0x55 0x66 0x77 0x88
Diagram
mermaid
flowchart TD
    A[FIFO_WRITE] --> B[Push Data]
    B --> C[FIFO Memory]
7.2 FIFO_READ
Syntax
Codice
FIFO_READ <addr> <len>
Diagram
mermaid
flowchart TD
    A[FIFO Memory] --> B[Pop Data]
    B --> C[FIFO_READ]
7.3 FIFO_CHECK
Syntax
Codice
FIFO_CHECK <addr> <len> <expected...>
8. BURST Commands
8.1 BURST_WRITE
Syntax
Codice
BURST_WRITE <addr> <len> <data...>
Example
Codice
BURST_WRITE BASE_RAM + 0x0100 4 0x01 0x02 0x03 0x04
Diagram
mermaid
sequenceDiagram
    participant P as Parser
    participant S as Slave
    P->>S: BURST_WRITE addr, len=4
    Note right of S: INCR burst<br/>addr+0<br/>addr+4<br/>addr+8<br/>addr+12
    S->>P: rsp_valid (4 beats)
    S->>P: rsp_last
8.2 BURST_READ
Syntax
Codice
BURST_READ <addr> <len>
8.3 BURST_CHECK
Syntax
Codice
BURST_CHECK <addr> <len> <expected...>
9. WRAP Commands
9.1 WRAP_WRITE
Syntax
Codice
WRAP_WRITE <addr> <len> <data...>
Diagram
mermaid
flowchart LR
    A[Start Address] --> B[addr + 0]
    B --> C[addr + 4]
    C --> D[addr + 8]
    D --> E[addr + 12]
    E --> F[Wrap to base]
9.2 WRAP_READ
Syntax
Codice
WRAP_READ <addr> <len>
9.3 WRAP_CHECK
Syntax
Codice
WRAP_CHECK <addr> <len> <expected...>
10. FILL Commands
10.1 FILL_LEN
Syntax
Codice
FILL_LEN <addr> <len> <pattern>
Diagram
mermaid
flowchart TD
    A[FILL_LEN] --> B[Repeat pattern]
    B --> C[Write len words]
10.2 FILL_RANGE
Syntax
Codice
FILL_RANGE <addr_start> <addr_end> <pattern>
Diagram
mermaid
flowchart TD
    A[FILL_RANGE] --> B[Compute length]
    B --> C{len > 256?}
    C -->|Yes| D[Split into bursts]
    C -->|No| E[Single burst]
10.3 FILL_CHECK
Syntax
Codice
FILL_CHECK <addr> <len> <pattern>
11. DUMP Commands
11.1 DUMP_LEN
Syntax
Codice
DUMP_LEN <addr> <len>
11.2 DUMP_RANGE
Syntax
Codice
DUMP_RANGE <addr_start> <addr_end>
11.3 DUMP_FILE_LEN / RANGE
Diagram
mermaid
flowchart TD
    A[DUMP_FILE_LEN] --> B[Read Memory]
    B --> C[Format Hex Lines]
    C --> D[Write File]
11.4 DUMP_FILE_CHECK_LEN / RANGE
Diagram
mermaid
flowchart TD
    A[Read Memory] --> B[Load File]
    B --> C[Compare Lines]
    C --> D{Match?}
    D -->|Yes| E[OK]
    D -->|No| F[Error]
12. POLL Commands
12.1 POLL_READ
Syntax
Codice
POLL_READ <addr> <mask> <value> <attempts> <delay>
Diagram
mermaid
flowchart TD
    A[Start Poll] --> B[Read Address]
    B --> C{(data & mask) == value?}
    C -->|Yes| D[Success]
    C -->|No| E[Wait delay]
    E --> F{Attempts left?}
    F -->|Yes| B
    F -->|No| G[Timeout]
12.2 POLL_TOGGLE
Syntax
Codice
POLL_TOGGLE <addr> <mask> <attempts> <delay>
12.3 POLL_PING
Syntax
Codice
POLL_PING <addr> <attempts> <delay>
13. STOP / END_SIM
Syntax
Codice
STOP
END_SIM
14. UNKNOWN
Any unrecognized command is mapped to:

Codice
CMD_UNKNOWN
15. Corner Cases
15.1 Burst Splitting (len > 256)
Burst 1024 → 4 bursts of 256

Boundary 4KB → additional split

15.2 Wrap Boundary
wrap mask = len * 4 bytes

address = base + (offset % mask)

15.3 FIFO Underflow
FIFO_READ len > available → error

15.4 Dump File Mismatch
first mismatch stops comparison

15.5 Polling Timeout
attempts exhausted → error

End of Document
