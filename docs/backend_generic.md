# DexterLab Generic Backend
The Generic Backend is the simplest executor in the DexterLab architecture.  
It does not implement AXI, AHB, TileLink, or any bus protocol.  
Instead, it provides a **pure simulation model** that executes commands directly
on internal memory arrays.

This backend is ideal for:

- unit testing the parser,
- validating command semantics,
- verifying burst splitting logic,
- checking atomic mode behavior,
- debugging the arbiter,
- running regression tests without AXI/AHB complexity.

---

# 1. Overview

The Generic Backend receives commands through the standard interface:

- `cmd_valid`, `cmd_ready`, `cmd : t_cmd_out`
- `rsp_valid`, `rsp_last`, `rsp_data`, `rsp_err_valid`, `rsp_err_code`

It implements:

- WRITE
- READ
- CHECK
- FIFO_WRITE / FIFO_READ / FIFO_CHECK
- BURST_WRITE / BURST_READ / BURST_CHECK
- WRAP_WRITE / WRAP_READ / WRAP_CHECK
- FILL_LEN / FILL_RANGE / FILL_CHECK
- DUMP_LEN / DUMP_RANGE
- DUMP_FILE_LEN / RANGE / CHECK
- POLL_READ / POLL_TOGGLE / POLL_PING

All operations are performed on **internal simulation memory**, not on a bus.

---

# 2. Architecture Diagram

```mermaid
flowchart LR
    A[t_cmd_out] --> B[Generic Backend]
    B --> C[t_rsp_in]
The backend is a simple state machine:

mermaid
stateDiagram-v2
    [*] --> IDLE
    IDLE --> EXEC: cmd_valid & cmd_ready
    EXEC --> RESP: operation complete
    RESP --> IDLE: rsp_last = 1
3. Internal Memory Model
The backend uses internal arrays:

RAM memory for READ/WRITE/BURST/WRAP/FILL/DUMP

FIFO memory for FIFO_WRITE/FIFO_READ/FIFO_CHECK

Typical structure:

vhdl
type t_ram is array(0 to RAM_SIZE-1) of std_logic_vector(C_DATA_WIDTH-1 downto 0);
type t_fifo is array(0 to FIFO_SIZE-1) of std_logic_vector(C_DATA_WIDTH-1 downto 0);
The actual sizes depend on the simulation environment.

4. Command Execution Semantics
4.1 WRITE
mermaid
flowchart LR
    A[WRITE addr, data] --> B[RAM(addr) := data]
    B --> C[rsp_valid, rsp_last]
4.2 READ
mermaid
flowchart LR
    A[READ addr] --> B[data := RAM(addr)]
    B --> C[rsp_valid, rsp_last]
4.3 CHECK
mermaid
flowchart TD
    A[RAM(addr)] --> B{== expected?}
    B -->|Yes| C[OK]
    B -->|No| D[Error]
5. Burst Operations
5.1 BURST_WRITE
mermaid
sequenceDiagram
    participant B as Backend
    loop len beats
        B->>B: RAM(addr + i*4) := data[i]
    end
    B->>Parser: rsp_valid, rsp_last
5.2 BURST_READ
Same logic, but reading.

5.3 BURST_CHECK
Reads and compares each beat.

6. Wrap Operations
Wrap bursts use modulo addressing:

mermaid
flowchart TD
    A[offset] --> B[offset % (len*4)]
    B --> C[addr = base + wrapped_offset]
7. FIFO Operations
7.1 FIFO_WRITE
mermaid
flowchart TD
    A[FIFO_WRITE] --> B[Push data into FIFO]
    B --> C[rsp_valid, rsp_last]
7.2 FIFO_READ
mermaid
flowchart TD
    A[FIFO_READ] --> B[Pop data from FIFO]
    B --> C[rsp_valid, rsp_last]
7.3 FIFO_CHECK
Compares FIFO contents with expected values.

8. Fill Operations
8.1 FILL_LEN
mermaid
flowchart TD
    A[FILL_LEN] --> B[Repeat pattern]
    B --> C[Write len words]
8.2 FILL_RANGE
Writes pattern from addr_start to addr_end.

8.3 FILL_CHECK
Reads and compares.

9. Dump Operations
9.1 DUMP_LEN
Reads len words and prints/logs them.

9.2 DUMP_RANGE
Reads from addr_start to addr_end.

9.3 DUMP_FILE_LEN / RANGE
Writes memory contents to a file.

9.4 DUMP_FILE_CHECK_LEN / RANGE
Compares memory contents with a reference file.

10. Polling Operations
10.1 POLL_READ
mermaid
flowchart TD
    A[Start] --> B[Read addr]
    B --> C{(data & mask) == value?}
    C -->|Yes| D[Success]
    C -->|No| E[Wait delay]
    E --> F{Attempts left?}
    F -->|Yes| B
    F -->|No| G[Timeout]
10.2 POLL_TOGGLE
Checks if a masked bit toggles.

10.3 POLL_PING
Checks if the address responds.

11. Error Handling
The backend generates:

rsp_err_valid = '1'

rsp_err_code

rsp_err_info (failing address)

rsp_err_id (command ID)

Errors include:

out‑of‑range address

FIFO underflow/overflow

CHECK mismatch

DUMP_FILE mismatch

POLL timeout

12. Atomic Mode
Atomic mode (cmd_atomic = '1') is handled by the arbiter, not by the backend.

The backend simply executes commands in the order received.

13. Summary
The Generic Backend:

is a pure simulation model,

executes all commands directly on internal memory,

supports bursts, wraps, FIFO, fill, dump, poll,

provides immediate responses,

is ideal for parser and arbiter testing,

is not meant for synthesis.

It is the simplest and most flexible backend in DexterLab.

End of Document
