markdown
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
INCLUDE init_vars.txt

Codice

---

# 3. WAIT Commands

## 3.1 WAIT_CLOCKS
WAIT_CLOCKS <N>

Codice

## 3.2 WAIT_TIME
WAIT_TIME <time>

Codice

## 3.3 WAIT_SIM_TIME
WAIT_SIM_TIME <time>

Codice

---

# 4. SET_ATOMIC

### Syntax
SET_ATOMIC <0|1>

Codice

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
WSTRB_WRITE BASE_RAM + 0x98 0b0001
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
Codice
WRITE <addr> <data>
6.2 READ
Codice
READ <addr>
6.3 CHECK
Codice
CHECK <addr> <expected>
7. FIFO Commands
7.1 FIFO_WRITE
Codice
FIFO_WRITE <addr> <len> <data...>
Diagram
mermaid
flowchart TD
    A[FIFO_WRITE] --> B[Push Data]
    B --> C[FIFO Memory]
7.2 FIFO_READ
Codice
FIFO_READ <addr> <len>
Diagram
mermaid
flowchart TD
    A[FIFO Memory] --> B[Pop Data]
    B --> C[FIFO_READ]
7.3 FIFO_CHECK
Codice
FIFO_CHECK <addr> <len> <expected...>
8. BURST Commands
8.1 BURST_WRITE
Codice
BURST_WRITE <addr> <len> <data...>
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
Codice
BURST_READ <addr> <len>
8.3 BURST_CHECK
Codice
BURST_CHECK <addr> <len> <expected...>
9. WRAP Commands
9.1 WRAP_WRITE
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
Codice
WRAP_READ <addr> <len>
9.3 WRAP_CHECK
Codice
WRAP_CHECK <addr> <len> <expected...>
10. FILL Commands
10.1 FILL_LEN
Codice
FILL_LEN <addr> <len> <pattern>
Diagram
mermaid
flowchart TD
    A[FILL_LEN] --> B[Repeat pattern]
    B --> C[Write len words]
10.2 FILL_RANGE
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
Codice
FILL_CHECK <addr> <len> <pattern>
11. DUMP Commands
11.1 DUMP_LEN
Codice
DUMP_LEN <addr> <len>
11.2 DUMP_RANGE
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
Codice
POLL_TOGGLE <addr> <mask> <attempts> <delay>
12.3 POLL_PING
Codice
POLL_PING <addr> <attempts> <delay>
13. STOP / END_SIM
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
Codice
mask = len * 4 bytes
addr = base + (offset % mask)
15.3 FIFO Underflow
Codice
FIFO_READ len > available → error
15.4 Dump File Mismatch
Codice
first mismatch stops comparison
15.5 Polling Timeout
Codice
attempts exhausted → error
End of Document
