# DexterLab Master Roadmap

The DexterLab Hardware Command Master is intentionally designed as an extensible, long-term component of the DexterLab command ecosystem.

The current implementation is deliberately minimal, providing only the functionality required to validate integration with:

- Arbiter
- Backend layer
- Command interfaces
- Response interfaces

Future generations of the master may evolve in multiple directions depending on system requirements, supported peripherals, and deployment targets.

This roadmap is intentionally open-ended and should be viewed as a collection of potential evolution paths rather than a fixed development plan.

---

# 1. Current State (2026)

The current implementation of:

```text
cmd_master
```

is a placeholder command generator.

Current behavior:

- Activated through `start`
- Generates continuous READ operations
- Uses the standard DexterLab command interfaces
- Participates in arbitration
- Accepts responses through the standard response path

Generated command:

```text
cmd_write = 0
cmd_burst = 0
cmd_wrap  = 0
cmd_fifo  = 0

cmd_len   = 1

cmd_addr  = 0x00000000
```

Current implementation does not provide:

- FSM-based control
- Interrupt handling
- Peripheral integration
- Response analysis
- Error recovery
- Command scheduling

The objective is simply to validate system integration.

---

# 2. Near-Term Evolution

Future releases may transform the master into an event-driven command generator capable of interacting with real peripherals.

Potential integrations include:

- SPI
- I²C
- UART
- CAN / CAN-FD
- Timers
- PWM modules
- GPIO controllers
- ADC/DAC subsystems

---

## Potential Features

Examples of future capabilities include:

- Hardware interrupt handling
- Command queues
- Event queues
- Multi-state FSMs
- Response processing
- Timeout supervision
- Automatic retries
- Protocol-specific command generation

These features are optional and will be implemented only when justified by system requirements.

---

# 3. Extended Command Generation

Future masters may generate the full range of DexterLab commands.

Examples:

```text
READ
WRITE
CHECK

BURST_READ
BURST_WRITE

WRAP_READ
WRAP_WRITE

FIFO_READ
FIFO_WRITE

POLL_READ
POLL_TOGGLE
```

Command generation may be triggered by:

- Peripherals
- Interrupts
- DMA completion
- External events
- Firmware requests
- Application-specific logic

---

# 4. Locked Execution Support

Future master implementations may support protected command sequences through:

```text
cmd_lock
```

Examples:

```text
SET_ATOMIC
    ->
cmd_lock
    ->
arbiter ownership retention
```

Potential use cases include:

- Critical peripheral configuration
- Multi-step initialization
- Atomic register updates
- Protected memory accesses

Ownership protection is implemented by the arbiter rather than by the backend.

---

# 5. Mid-Term Evolution (RISC-V Integration)

DexterLab already defines a path for integration with RISC-V systems.

Relevant infrastructure includes:

```text
TileLink Bridge
Arbiter
Backend Layer
```

Potential future use cases:

- Firmware-generated commands
- DMA-driven command generation
- Hardware-accelerated command pipelines
- Software/hardware cooperative control

Possible command sources:

```text
RISC-V Core
DMA Engine
Peripheral Controller
Custom Accelerator
```

All remain compatible with the common DexterLab interfaces.

---

# 6. TileLink Integration

The TileLink Bridge already provides a path from:

```text
TileLink
        |
        v
    t_cmd_out
```

allowing future RISC-V based systems to interact with DexterLab.

Potential future enhancements include:

- Firmware command libraries
- Command batching
- DMA-generated bursts
- Remote firmware debugging
- Runtime scripting

Further details are documented in:

```text
tilelink_bridge.md
```

---

# 7. Long-Term Evolution

Future deployments may extend beyond local devices.

Potential areas include:

- Network-attached systems
- Distributed instrumentation
- Remote command execution
- Remote diagnostics
- Multi-node command infrastructures

Possible transport layers:

- Ethernet
- Industrial Ethernet
- 10BASE-T1S
- Custom serial links
- Remote Control Protocols (RCP)

These directions remain exploratory and intentionally unspecified.

---

# 8. Multi-Master Architectures

Future DexterLab systems may include multiple concurrent command sources.

Examples:

```text
Parser Engine
Hardware Master
RISC-V Master
DMA Master
Remote Master
Acceleration Engine
```

The current arbiter already provides the foundations for this model through:

- Ownership tracking
- Pending command retention
- Response routing
- Locked command sequences

Future arbitration strategies may include:

- Fixed priority
- Round robin
- Event-driven scheduling
- QoS-based scheduling
- Hybrid schemes

No particular strategy is currently mandated.

---

# 9. Standard Master Interfaces

The master architecture is expected to preserve the standard DexterLab interfaces.

Command generation:

```text
t_cmd_out
```

Response flow control:

```text
t_rsp_out
```

Response reception:

```text
t_rsp_in
```

These interfaces form the stable API between all current and future command generators and the rest of the system.

---

# 10. Possible Generation Models

Future master implementations may be:

### Interrupt Driven

```text
Interrupt
    ->
Command Generation
```

---

### Polling Driven

```text
Periodic Check
    ->
Command Generation
```

---

### Scheduled

```text
Time/Event Schedule
    ->
Command Generation
```

---

### Firmware Driven

```text
Software
    ->
Command Generation
```

---

### Remote Driven

```text
Network Event
    ->
Command Generation
```

---

### State-Machine Driven

```text
FSM
    ->
Command Generation
```

The command interfaces remain stable regardless of the generation method.

---

# 11. Design Philosophy

The master architecture follows several long-term principles.

### Open-Ended

The design should not constrain future integrations.

---

### Modular

Different master implementations may coexist.

---

### Scalable

The same architecture should support:

```text
Single Peripheral
        ->
Multiple SoCs
        ->
Distributed Systems
```

---

### Replaceable

Implementations can evolve without changing backend interfaces.

---

### Extensible

New command-generation sources can be introduced at any time.

---

### Backend Independent

Masters generate commands.

Backends execute commands.

The two responsibilities remain separated.

---

# 12. Summary

The DexterLab Hardware Command Master is currently a lightweight placeholder implementation designed to validate system integration.

Future generations may evolve into:

- Event-driven controllers
- Peripheral supervisors
- RISC-V command generators
- DMA engines
- Network-aware masters
- Multi-master infrastructures

The stable foundation remains:

```text
t_cmd_out
t_rsp_out
t_rsp_in
```

combined with:

```text
Arbiter
Backend Layer
Unified Command Architecture
```

This approach allows DexterLab to grow from a simple parser-driven environment into a flexible command-execution framework spanning local devices, processors, accelerators, and distributed systems.

---

# End of Document
