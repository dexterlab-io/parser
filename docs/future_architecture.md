# DexterLab Future Architecture

(Version 2026)

This document collects possible future evolution paths.

Nothing described here is mandatory.

---

# 1. RISC-V Integration

Potential command sources:

- Single-core systems
- Multi-core systems
- Firmware-generated commands

Integration path:

TileLink
    ↓
TileLink Bridge
    ↓
t_cmd_out

---

# 2. DMA Masters

Potential features:

- Autonomous commands
- Large burst generation
- Memory streaming

---

# 3. Ethernet Integration

Potential interfaces:

- MAC
- UDP
- TCP
- Raw Ethernet

---

# 4. Remote Control Protocol (RCP)

Potential applications:

- Remote testing
- Remote execution
- Remote diagnostics

---

# 5. 10BASE-T1S

Potential industrial deployments.

---

# 6. Distributed Command Networks

Possible architecture:

Node A
   |
Node B
   |
Node C

shared through command routing.

---

# 7. Future Protocols

Possible additions:

- APB
- Wishbone
- CHI

---

# 8. Future Verification

Potential improvements:

- Coverage collection
- Transaction recording
- Performance profiling

---

# End of Document
