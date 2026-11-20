# DexterLab Architecture Diagrams

This document collects the primary architecture and execution-flow diagrams used throughout the DexterLab documentation.

The diagrams reflect the DexterLab v1.1.0 architecture and are intended to complement the detailed functional specifications.

---

# 1. Global Architecture

The entire framework is organized around a protocol-independent command model.

```mermaid
flowchart TD

    A[Parser Engine]
        --> C[Arbiter]

    B[Hardware Master]
        --> C

    C --> D[Backend]

    D --> E[Bus]

    E --> D

    D --> C

    C --> A

    C --> B
```

---

# 2. Command Execution Flow

```mermaid
flowchart TD

    A[Command Source]
        --> B[t_cmd_out]

    B --> C[Arbiter]

    C --> D[Backend]

    D --> E[Target Bus]

    E --> F[Peripheral]

    F --> E

    E --> D

    D --> G[t_rsp_in]

    G --> C

    C --> A
```

---

# 3. Parser Internal Pipeline

```mermaid
flowchart TD

    A[Command File]
        --> B[Tokenizer]

    B --> C[Command Decoder]

    C --> D[Syntax Validation]

    D --> E[Semantic Validation]

    E --> F[Micro-Command Generator]

    F --> G[Command Builder]

    G --> H[t_cmd_out]
```

---

# 4. Multi-Source Arbitration

```mermaid
flowchart LR

    P[Parser Engine]
        --> A[Arbiter]

    M[Hardware Master]
        --> A

    A --> B[Backend]
```

The arbiter manages:

- Ownership
- Pending commands
- Response routing
- Locked command sequences

---

# 5. Backend Selection

```mermaid
flowchart TD

    A[t_cmd_out]
        --> B{Backend}

    B --> C[Generic]

    B --> D[AXI-FULL]

    B --> E[AXI-LITE]

    B --> F[AHB-FULL]

    B --> G[AHB-LITE]
```

---

# 6. Common Execution Model

```mermaid
flowchart TD

    A[Command Accepted]
        --> B[Execution]

    B --> C[Response Publication]

    C --> D[rsp_end_cmd = 1]

    D --> E[Command Completed]
```

---

# 7. Generic Backend Structure

```mermaid
flowchart LR

    A[t_cmd_out]
        --> B[Generic Backend]

    B --> C[REG Model]

    B --> D[RAM Model]

    B --> E[FIFO Model]

    C --> B

    D --> B

    E --> B

    B --> F[t_rsp_in]
```

---

# 8. Burst Expansion

Large logical commands may be expanded into multiple micro-commands.

```mermaid
flowchart TD

    A[BURST_WRITE len=1024]
        --> B[Micro-Command Generator]

    B --> C1[MC 0]

    B --> C2[MC 1]

    B --> C3[MC 2]

    B --> C4[MC 3]
```

---

# 9. Boundary Validation

```mermaid
flowchart TD

    A[Command]
        --> B[Boundary Validation]

    B --> C{Valid?}

    C -->|Yes| D[Execute]

    C -->|No| E[Error]
```

---

# 10. Wrap Command Processing

```mermaid
flowchart TD

    A[WRAP Command]
        --> B[Parser Validation]

    B --> C[Backend Execution]

    C --> D[Wrap Address Generation]
```

The parser validates wrap legality.

The backend implements wrap addressing.

---

# 11. FIFO Operations

```mermaid
flowchart TD

    A[FIFO_WRITE]
        --> B[FIFO Model]

    B --> C[FIFO_READ]

    C --> D[FIFO_CHECK]
```

---

# 12. Polling Operations

```mermaid
flowchart TD

    A[Start Poll]
        --> B[Read Value]

    B --> C{Condition Met?}

    C -->|Yes| D[Success]

    C -->|No| E[Delay]

    E --> F{Attempts Remaining?}

    F -->|Yes| B

    F -->|No| G[Timeout]
```

Supported commands:

```text
POLL_READ
POLL_TOGGLE
```

---

# 13. Atomic Command Flow

```mermaid
flowchart LR

    A[SET_ATOMIC 1]
        --> B[cmd_lock = 1]

    B --> C[Arbiter Ownership Retained]

    C --> D[Protected Commands]

    D --> E[SET_ATOMIC 0]

    E --> F[Ownership Released]
```

---

# 14. Error Propagation

```mermaid
flowchart TD

    A[Backend Execution]
        --> B{Error?}

    B -->|No| C[Normal Response]

    B -->|Yes| D[rsp_err_valid]

    D --> E[rsp_err_code]

    E --> F[rsp_err_addr]

    F --> G[rsp_err_beat]

    G --> H[rsp_err_id]
```

---

# 15. TileLink Integration

```mermaid
flowchart LR

    A[TileLink Master]
        --> B[TileLink Bridge]

    B --> C[t_cmd_out]

    C --> D[Arbiter]

    D --> E[Backend]

    E --> F[t_rsp_in]

    F --> B
```

---

# 16. Verification Environment

```mermaid
flowchart TD

    A[Command Files]
        --> B[Parser]

    C[Hardware Master]
        --> D[Arbiter]

    B --> D

    D --> E[Backend]

    E --> F[REG]

    E --> G[RAM]

    E --> H[FIFO]
```

---

# 17. Documentation Relationships

```mermaid
flowchart TD

    A[overview.md]
        --> B[cmd_interface.md]

    B --> C[cmd_flow.md]

    C --> D[command_set.md]

    D --> E[Backend Documentation]

    B --> F[Arbiter Documentation]

    C --> G[Testbench Documentation]
```

---

# End of Document
