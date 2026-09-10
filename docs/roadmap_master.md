# DexterLab Master Roadmap
The DexterLab Hardware Command Master is intentionally designed as an open,
extensible, multi‑generation module.  
The current implementation is a minimal placeholder, but the architecture is
meant to evolve across multiple device classes, bus types, and deployment
scenarios.

This roadmap outlines the possible future directions of the master without
restricting the design.  
All sections are intentionally open-ended.

---

# 1. Current State (2026)
The current `cmd_master` implementation is a placeholder:

- activated by `start`,
- issues a continuous READ at address `0x0000_0000`,
- no FSM,
- no interrupt handling,
- no client/server logic,
- no peripheral integration.

This version exists only to keep the system integrated and compilable.

---

# 2. Near-Future Evolution (Local Peripherals)
When real peripherals are introduced, the master will evolve into an event-driven
module capable of generating commands based on hardware activity.

Possible peripherals include:

- SPI (master/slave)
- I2C (master/slave)
- UART (RX/TX/IRQ)
- CAN / CAN-FD
- PWM / timers
- ADC / DAC
- GPIO controllers

### Possible features (open list)
- interrupt-driven command generation  
- event queues  
- multi-state FSM  
- client/server roles  
- atomic sequences  
- burst/wrap operations  
- FIFO-based streaming  
- error propagation  
- timeout handling  
- protocol-specific command templates  

None of these are mandatory; they will be added only when needed.

---

# 3. Mid-Future Evolution (RISC‑V Integration)
DexterLab will eventually support RISC‑V masters through TileLink.

Possible directions:

- TileLink UL/UH → `t_cmd_out` bridge  
- RISC‑V firmware generating DexterLab commands  
- DMA engines acting as masters  
- interrupt controllers integrated with the master  
- memory-mapped peripherals controlled via DexterLab  
- hybrid software/hardware command generation  

### Open possibilities
- multiple RISC‑V cores generating commands  
- distributed masters with arbitration  
- command batching  
- command scripting from firmware  
- remote debugging via DexterLab commands  

Again, no constraints: the design remains open.

---

# 4. Long-Term Evolution (Ethernet + 10BASE‑T1S + RCP)
DexterLab will support remote peripherals through:

- MAC Ethernet  
- PHY 10BASE‑T1S  
- RCP (Remote Control Protocol)  
- remote command execution  
- remote interrupt propagation  
- deterministic latency channels  

### Possible features
- remote master instances  
- remote event queues  
- remote FSM synchronization  
- remote error reporting  
- remote atomic sequences  
- distributed command routing  
- multi-node systems  
- deterministic industrial networks  

This is a major future milestone and intentionally left open.

---

# 5. Multi-Master Architectures
DexterLab may support multiple masters:

- local hardware master  
- RISC‑V master  
- remote master (RCP)  
- DMA master  
- parser master (software)

### Possible arbitration strategies
- priority-based  
- round-robin  
- event-driven  
- atomic locking  
- QoS-based  

No strategy is fixed; the arbiter will evolve as needed.

---

# 6. Master API (Open Specification)
The master will always generate commands through:

t_cmd_out → arbiter → backend → bus

Codice

But the *way* commands are generated is intentionally open:

- interrupt-driven  
- polling  
- scheduled  
- firmware-driven  
- remote-driven  
- protocol-driven  
- state-machine-driven  
- AI-driven (future possibility)  

The API is stable; the behavior is flexible.

---

# 7. Design Philosophy
The master is designed with these principles:

### ✔ Open-ended  
No fixed protocol, no fixed FSM, no fixed peripheral set.

### ✔ Modular  
Each peripheral or subsystem can define its own master behavior.

### ✔ Scalable  
From a single SPI device to a distributed industrial network.

### ✔ Replaceable  
Different master implementations can coexist or be swapped.

### ✔ Evolvable  
New generations of masters can be added without breaking old ones.

### ✔ Non-intrusive  
The master never forces architectural constraints on the system.

---

# 8. Summary
The DexterLab Hardware Command Master is:

- **minimal today**,  
- **expandable tomorrow**,  
- **multi-peripheral later**,  
- **RISC‑V compatible in the future**,  
- **Ethernet/T1S/RCP capable in the long term**,  
- **multi-master in advanced deployments**,  
- **always open-ended**.

This roadmap intentionally leaves all implementation paths open, allowing
DexterLab to grow organically as new peripherals, protocols, and systems are
introduced.

---

# End of Document
