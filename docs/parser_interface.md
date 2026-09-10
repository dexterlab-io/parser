# DexterLab Command Parser — Generic Interface Specification

This document defines the generic interface between the DexterLab Command Parser
Engine and any backend slave (Generic, AXI‑Full, AHB‑Full, AXI‑Lite, AHB‑Lite,
TileLink bridge, or custom user‑defined modules).

The interface is intentionally backend‑agnostic and stable across versions.  
It is the foundation that allows DexterLab to support multiple bus protocols
without modifying the parser engine.

---

# 1. Overview

The Command Parser Engine decodes textual commands and produces a structured
output (`t_cmd_out`).  
A backend slave receives this structure, executes the command, and returns a
response (`t_rsp_in`).

This interface is used by:

- the **Generic Slave** (simulation only)
- the **AXI‑Full Slave**
- the **AHB‑Full Slave**
- the **AXI‑Lite Wrapper**
- the **AHB‑Lite Wrapper**
- the **TileLink → AXI / AHB Bridges**
- the **future RISC‑V master**, which will generate `t_cmd_out` directly

---

# 2. Interface Diagram

```mermaid
flowchart LR
    A[Parser Engine] --> B[t_cmd_out]
    B --> C[Arbiter]
    C --> D[Slave Backend]
    D --> E[t_rsp_in]
3. Command Interface Signals
3.1 Signals from Parser → Slave
Signal	Type	Description
cmd_valid	std_logic	The parser has produced a valid command.
cmd_ready	std_logic	The slave is ready to accept a command.
cmd	t_cmd_out	Structured command containing all decoded fields.


Handshake rule:

Codice
cmd_valid = 1 AND cmd_ready = 1 → command accepted
3.2 Signals from Slave → Parser
Signal	Type	Description
rsp_valid	std_logic	Response beat is valid.
rsp_last	std_logic	Last beat of the response.
rsp	t_rsp_in	Response structure (data, errors, IDs).
rsp_ready	std_logic	Parser ready to receive data.
rsp_err_ready	std_logic	Parser ready to receive errors.


4. Structure t_cmd_out (Official Declaration)
vhdl
type t_cmd_out is record
    cmd_write : std_logic;                     -- 1 = write, 0 = read
    cmd_burst : std_logic;                     -- 1 = multi-beat
    cmd_wrap  : std_logic;                     -- 1 = wrap addressing
    cmd_fifo  : std_logic;                     -- 1 = fifo addressing
    cmd_atomic : std_logic;                    -- 1 = atomic operation
    cmd_id    : unsigned(C_ID_WIDTH-1 downto 0);
    cmd_addr  : t_addr;
    cmd_len   : natural range 0 to 256;
    cmd_data  : t_data_array;
    cmd_wstrb : std_logic_vector((C_DATA_WIDTH/8)-1 downto 0);
end record;
Notes
cmd_write → WRITE/READ

cmd_burst → INCR burst

cmd_wrap → WRAP burst

cmd_fifo → FIFO operation

cmd_atomic → atomic mode

cmd_id → correlates responses

cmd_addr → address

cmd_len → number of beats (0–256)

cmd_data → array of burst/fifo data

cmd_wstrb → AXI byte mask

5. Structure t_rsp_out (Official Declaration)
vhdl
type t_rsp_out is record
    rsp_ready     : std_logic;   -- parser ready to receive data
    rsp_err_ready : std_logic;   -- parser ready to receive errors
end record;
6. Structure t_rsp_in (Official Declaration)
vhdl
type t_rsp_in is record
    rsp_valid     : std_logic;
    rsp_last      : std_logic;
    rsp_data      : std_logic_vector(C_DATA_WIDTH-1 downto 0);
    rsp_id        : std_logic_vector(C_ID_WIDTH-1 downto 0);
    rsp_err_valid : std_logic;
    rsp_err_code  : std_logic_vector(7 downto 0);
    rsp_err_info  : std_logic_vector(31 downto 0);
    rsp_err_id    : std_logic_vector(C_ID_WIDTH-1 downto 0);
end record;
Notes
rsp_data → read data

rsp_err_code → AXI/AHB error semantics

0x00 → OKAY

0x02 → SLVERR

0x03 → DECERR

0x06 → BOUNDARY_ERR

0x07 → BURST_ERR

rsp_err_info → failing address

rsp_err_id → ID of failing command

7. Interface Timing Diagrams
7.1 Command Handshake
mermaid
sequenceDiagram
    participant P as Parser
    participant S as Slave

    P->>S: cmd_valid = 1, cmd
    S->>P: cmd_ready = 1
    Note over P,S: Command accepted
7.2 Response Flow
mermaid
sequenceDiagram
    participant S as Slave
    participant P as Parser

    S->>P: rsp_valid (beat 0)
    S->>P: rsp_valid (beat 1)
    S->>P: rsp_valid (beat N-1)
    S->>P: rsp_last = 1
8. Backend Responsibilities
Every backend must:

Accept commands via cmd_valid/cmd_ready.

Execute the command according to its protocol.

Produce responses via rsp_valid/rsp_last.

Generate error codes when needed.

Respect burst semantics (INCR, WRAP).

Respect FIFO semantics.

Respect WSTRB semantics.

Respect 4KB boundary rules (AXI).

Respect maximum burst length (256 beats).

Support command splitting (handled by parser engine).

9. Parser Responsibilities
The parser engine:

decodes textual commands,

builds t_cmd_out,

splits large bursts,

handles wrap masks,

handles boundary crossing,

handles FIFO semantics,

handles polling loops,

handles dump file comparisons,

assigns command IDs,

ensures atomic mode when requested.

10. Command Splitting Logic
mermaid
flowchart TD
    A[Command: BURST_WRITE len=1024] --> B[Parser Splitter]
    B --> C1[Burst 0: 256 beats]
    B --> C2[Burst 1: 256 beats]
    B --> C3[Burst 2: 256 beats]
    B --> C4[Burst 3: 256 beats]
11. 4KB Boundary Rule
mermaid
flowchart LR
    A[Start Address] --> B[addr + 0]
    B --> C[addr + 4]
    C --> D[addr + 8]
    D --> E{Crosses 4KB?}
    E -->|Yes| F[Split Burst]
    E -->|No| G[Continue]
12. Wrap Mask Calculation
mermaid
flowchart TD
    A[len = 8] --> B[Compute mask = len * 4 bytes]
    B --> C[Wrap boundary = base & ~(mask - 1)]
    C --> D[addr = base + (offset % mask)]
13. RISC‑V Integration (Future)
The future master replacing the current placeholder will be a RISC‑V core.

RISC‑V systems typically use TileLink internally (TL‑UL, TL‑UH, TL‑C).
DexterLab will interface with RISC‑V systems through:

TileLink → AXI

TileLink → AHB

AXI → TileLink

AHB → TileLink

The RISC‑V core will generate t_cmd_out directly, allowing firmware and external
tools to share the same hardware resources through the arbiter.

End of Document
