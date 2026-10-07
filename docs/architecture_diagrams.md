# DexterLab Architecture Diagrams

This document contains architectural diagrams and flow representations of the
DexterLab Command Parser system.  
It complements the functional documentation by illustrating how commands are
processed, split, arbitrated, and executed across different backends.

---

# 1. Parser Engine Pipeline

```mermaid
flowchart LR
    A[Text Command] --> B[Parser Engine]
    B --> C[t_cmd_out]
    C --> D[Arbiter]
    D --> E[Backend]
    E --> F[t_rsp_in]
2. Generic Command Interface (t_cmd_out / t_rsp_in)
mermaid
flowchart TD
    A[t_cmd_out] --> B[Backend]
    B --> C[t_rsp_in]
3. Arbiter + Master (future RISC‑V)
mermaid
flowchart LR
    P[Parser Engine] --> A[Arbiter]
    R[RISC-V Master] --> A
    A --> S[Backend]
4. Backend Selection (Direct)
DexterLab no longer uses wrappers.
The arbiter connects directly to the selected backend.

mermaid
flowchart TD
    A[t_cmd_out] --> B{Backend Type}
    B --> C[AXI-Full Backend]
    B --> D[AHB-Full Backend]
    B --> E[Generic Backend]
5. AXI ↔ AHB Bridge
mermaid
flowchart LR
    A[AXI-Full] --> B[AXI → AHB Bridge]
    B --> C[AHB-Full]
6. TileLink ↔ AXI / AHB Bridges
mermaid
flowchart LR
    TL[TileLink] --> AXI[TileLink → AXI Bridge]
    TL --> AHB[TileLink → AHB Bridge]
7. Command Splitting Logic (Burst 1024 → Burst 256)
Large bursts (e.g., 1024 beats) are split into smaller AXI-compliant bursts
(max 256 beats) while respecting the 4KB boundary rule.

mermaid
flowchart TD
    A[Command: BURST_WRITE len=1024] --> B[Parser Splitter]
    B --> C1[Burst 0: 256 beats]
    B --> C2[Burst 1: 256 beats]
    B --> C3[Burst 2: 256 beats]
    B --> C4[Burst 3: 256 beats]
8. 4KB Boundary Crossing Logic
mermaid
flowchart LR
    A[Start Address] --> B[addr + 0]
    B --> C[addr + 4]
    C --> D[addr + 8]
    D --> E{Crosses 4KB?}
    E -->|Yes| F[Split Burst]
    E -->|No| G[Continue]
9. WRAP Mask Calculation
mermaid
flowchart TD
    A[Base Address] --> B[Compute Wrap Boundary]
    B --> C[Apply Wrap Mask]
    C --> D[Generate Wrapped Addresses]
10. FIFO Push/Pop Flow
mermaid
flowchart TD
    A[FIFO_WRITE] --> B[Push Data]
    B --> C[FIFO Memory]
    C --> D[Pop Data]
    D --> E[FIFO_READ]
11. Polling Logic (POLL_READ / POLL_TOGGLE / POLL_PING)
mermaid
flowchart TD
    A[Start Poll] --> B[Read Address]
    B --> C{Condition Met?}
    C -->|Yes| D[Return Success]
    C -->|No| E[Wait Delay]
    E --> F{Attempts Left?}
    F -->|Yes| B
    F -->|No| G[Return Timeout]
12. Dump File Flow (DUMP_FILE_LEN / RANGE / CHECK)
mermaid
flowchart TD
    A[DUMP_FILE_LEN] --> B[Read Memory]
    B --> C[Format Hex Lines]
    C --> D[Write File]
    D --> E[Optional: Compare File for CHECK]
13. Atomic Mode Flow (SET_ATOMIC)
mermaid
flowchart LR
    A[SET_ATOMIC 1] --> B[Enter Atomic Mode]
    B --> C[Execute Commands Sequentially]
    C --> D[No Interleaving Allowed]
    D --> E[SET_ATOMIC 0]
    E --> F[Exit Atomic Mode]
14. Error Code Flow (OKAY / SLVERR / DECERR / BOUNDARY_ERR / BURST_ERR)
mermaid
flowchart TD
    A[Backend Execution] --> B{Error?}
    B -->|No| C[OKAY]
    B -->|Yes| D[Generate Error Code]
    D --> E[rsp_err_valid]
15. Parser Engine FSM
mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> ParseCommand: New text line
    ParseCommand --> Decode: Identify command
    Decode --> BuildCmdOut: Fill t_cmd_out fields
    BuildCmdOut --> SendCmd: cmd_valid = 1
    SendCmd --> WaitRsp: rsp_valid?
    WaitRsp --> Idle: rsp_last
16. Backend FSM (Generic / AXI / AHB)
mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> AcceptCmd: cmd_valid & cmd_ready
    AcceptCmd --> Exec: Execute operation
    Exec --> SendRsp: rsp_valid = 1
    SendRsp --> Idle: rsp_last = 1
17. AXI-Full Handshake Flow
mermaid
sequenceDiagram
    participant M as Master
    participant S as Slave

    M->>S: AWVALID + AWADDR
    S->>M: AWREADY

    M->>S: WVALID + WDATA + WSTRB
    S->>M: WREADY

    S->>M: BVALID + BRESP
    M->>S: BREADY

    M->>S: ARVALID + ARADDR
    S->>M: ARREADY

    S->>M: RVALID + RDATA + RRESP
    M->>S: RREADY
18. AHB-Full Transfer Flow
mermaid
sequenceDiagram
    participant M as Master
    participant S as Slave

    M->>S: HADDR + HTRANS + HSIZE + HBURST
    M->>S: HWRITE
    S->>M: HREADY

    M->>S: HWDATA
    S->>M: HRDATA
19. Command Splitting: Detailed Address Flow
mermaid
flowchart TD
    A[Start: addr = BASE_RAM + 0x0000] --> B{Cross 4KB?}
    B -->|No| C[Split into 256-beat bursts]
    C --> D1[addr + 0x0000 → burst 0]
    C --> D2[addr + 0x0400 → burst 1]
    C --> D3[addr + 0x0800 → burst 2]
    C --> D4[addr + 0x0C00 → burst 3]
20. Boundary Crossing Example
mermaid
flowchart LR
    A[addr = BASE_RAM + 0x14] --> B[addr + 0x18]
    B --> C[addr + 0x1C]
    C --> D[addr + 0x20]
    D --> E{Cross 4KB?}
    E -->|Yes| F[Split Burst]
    E -->|No| G[Continue]
21. Wrap Mask Logic
mermaid
flowchart TD
    A[len = 8] --> B[Compute mask = len * 4 bytes]
    B --> C[Wrap boundary = base & ~(mask - 1)]
    C --> D[addr = base + (offset % mask)]
22. Fill Range Splitting (FILL_RANGE)
mermaid
flowchart TD
    A[FILL_RANGE start → end] --> B[Compute total length]
    B --> C{len > 256?}
    C -->|Yes| D[Split into 256-beat bursts]
    C -->|No| E[Single burst]
23. Dump Range Splitting (DUMP_RANGE)
mermaid
flowchart TD
    A[DUMP_RANGE start → end] --> B[Compute length]
    B --> C{len > 256?}
    C -->|Yes| D[Split into multiple reads]
    C -->|No| E[Single read]
24. WSTRB Lane Selection
mermaid
flowchart LR
    A[WSTRB_WRITE addr, wstrb] --> B{wstrb bit 0?}
    B -->|Yes| C[Write byte lane 0]
    B -->|No| D[Skip lane 0]

    A --> E{wstrb bit 1?}
    E -->|Yes| F[Write byte lane 1]
    E -->|No| G[Skip lane 1]

    A --> H{wstrb bit 2?}
    H -->|Yes| I[Write byte lane 2]
    H -->|No| J[Skip lane 2]

    A --> K{wstrb bit 3?}
    K -->|Yes| L[Write byte lane 3]
    K -->|No| M[Skip lane 3]
25. Error Propagation Flow
mermaid
flowchart TD
    A[Backend Execution] --> B{Error?}
    B -->|No| C[OKAY]
    B -->|Yes| D[Generate Error Code]
    D --> E[rsp_err_valid = 1]
    E --> F[Return to Parser]
End of Document
