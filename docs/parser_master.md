# DexterLab Hardware Command Master (`cmd_master`)
The DexterLab Hardware Command Master is currently a **placeholder module** that
will be expanded in future releases when real peripherals (SPI, I2C, UART, CAN,
etc.) are integrated into the DexterLab ecosystem.

At the moment, the master implements only a minimal behavior:

> **When `start = '1'`, it continuously issues a READ command at address `0x0000_0000`.**

This allows the module to be instantiated and connected to the arbiter/backend
without generating errors, while providing a stable foundation for future
development.

---

# 1. Current Behavior (Placeholder Mode)

The current implementation (`cmd_master.vhd`) performs:

- synchronization of the `start` signal,
- activation flag (`s_active`),
- `cmd_valid = '1'` when active,
- a fixed READ command:
  - `cmd_write = '0'`
  - `cmd_addr = 0x0000_0000`
  - `cmd_len = 1`
  - no burst, no wrap, no FIFO, no atomic,
- `rsp_out` always ready,
- no processing of `rsp_in`,
- no FSM,
- no interrupt handling,
- no client/server logic.

This mode is intentionally simple and safe.

---

# 2. Purpose of the Placeholder

The placeholder master exists to:

- validate the arbiter/master interface,
- validate backend routing,
- allow simulation of continuous reads,
- provide a stable module for future expansion,
- avoid unused-module warnings in early integration phases.

It is **not** intended to perform real operations yet.

---

# 3. Future Evolution

The master will evolve into a full-featured hardware command generator when
DexterLab integrates real peripherals.

Planned features include:

### ✔ Interrupt-driven operation
The master will react to:
- SPI transfer complete,
- I2C event,
- UART RX/TX ready,
- CAN frame received,
- peripheral error conditions.

### ✔ Client/Server roles
Depending on the peripheral:
- **Client mode**: master sends commands to the peripheral.
- **Server mode**: peripheral triggers actions via interrupt.

### ✔ Event-driven FSM
A multi-state FSM will:
- detect events,
- build commands,
- send them,
- wait for responses,
- process results,
- return to idle or handle new events.

### ✔ Dynamic command generation
Commands will be built based on:
- interrupt type,
- peripheral state,
- pending operations,
- protocol requirements.

### ✔ Response handling
The master will parse:
- `rsp_valid`,
- `rsp_last`,
- `rsp_err_valid`,
- `rsp_err_code`,
- `rsp_err_info`,
- `rsp_id`.

### ✔ Flow control
The master will respect:
- arbiter priority rules,
- atomic mode,
- pending flags,
- backpressure (`cmd_ready`).

---

# 4. Planned Architecture

```mermaid
flowchart TD
    A[Interrupt Handler] --> B[Event Queue]
    B --> C[Master FSM]
    C --> D[Command Builder]
    D --> E[t_cmd_out]
    E --> F[Arbiter]
    F --> G[Backend]
    G --> F
    F --> H[t_rsp_in]
    H --> C
This architecture will be implemented once real peripherals are available.

5. Integration with Arbiter and Backend
Even in placeholder mode, the master integrates correctly:

Codice
master → arbiter → wrapper → backend → bus
The arbiter sees the master as a valid command source.

The backend executes the READ at address 0x0.

6. Summary
The current cmd_master:

is a placeholder,

issues a continuous READ at address 0x0,

has no FSM,

has no interrupt handling,

has no client/server logic,

has no response processing,

is designed to be expanded in future releases.

Future versions will transform it into a full hardware command generator capable
of managing real peripherals through DexterLab’s unified command interface.

End of Document
