# DexterLab Command Interface
The DexterLab command interface defines the hardware protocol used to transmit
commands (`t_cmd_out`) from the parser or hardware master to the arbiter and
backend, and to receive responses (`t_rsp_in`) from the backend.

This document describes the fields, timing rules, semantics, and usage of both
interfaces.

---

# 1. Overview

DexterLab uses two record types:

- `t_cmd_out` — command sent to the arbiter/backend
- `t_rsp_in` — response returned by the backend

The interface is **bus‑agnostic**: AXI‑FULL, AXI‑LITE, AHB‑FULL, AHB‑LITE, and
TileLink all use the same command format.

---

# 2. Command Interface (`t_cmd_out`)

A command describes a single operation or a burst of operations.

## 2.1 Fields

| Field | Type | Description |
|-------|------|-------------|
| `cmd_write` | std_logic | 1 = write, 0 = read |
| `cmd_addr` | unsigned | start address |
| `cmd_len` | natural | number of beats (1 = single) |
| `cmd_burst` | std_logic | 1 = INCR burst |
| `cmd_wrap` | std_logic | 1 = WRAP burst |
| `cmd_fifo` | std_logic | 1 = FIFO mode |
| `cmd_atomic` | std_logic | 1 = atomic block |
| `cmd_id` | unsigned | command identifier |
| `cmd_data` | array | write data words |
| `cmd_wstrb` | std_logic_vector | byte mask |
| `cmd_valid` | std_logic | command valid |
| `cmd_ready` | std_logic | backend ready |

---

# 3. Response Interface (`t_rsp_in`)

A response describes the result of a command.

## 3.1 Fields

| Field | Type | Description |
|-------|------|-------------|
| `rsp_valid` | std_logic | response valid |
| `rsp_last` | std_logic | last beat of burst |
| `rsp_data` | unsigned | read data |
| `rsp_err_valid` | std_logic | error flag |
| `rsp_err_code` | unsigned | error code |
| `rsp_err_info` | unsigned | failing address |
| `rsp_id` | unsigned | command identifier |

---

# 4. Timing Rules

The interface uses a standard **valid/ready handshake**.

## 4.1 Command Handshake

cmd_valid = 1
cmd_ready = 1   → command accepted

Codice

Rules:

- `cmd_valid` must remain high until `cmd_ready = 1`.
- After acceptance, the master may deassert `cmd_valid`.
- Only one command may be active at a time.

---

## 4.2 Response Handshake

Responses are always accepted:

rsp_out.rsp_ready = 1
rsp_out.rsp_err_ready = 1

Codice

Rules:

- `rsp_valid = 1` indicates a valid response beat.
- `rsp_last = 1` indicates the final beat.
- Errors may be signaled at any beat.

---

# 5. Command Semantics

## 5.1 Single Write

cmd_write = 1
cmd_len   = 1

Codice

## 5.2 Single Read

cmd_write = 0
cmd_len   = 1

Codice

## 5.3 Burst Write

cmd_write = 1
cmd_burst = 1
cmd_len   = N

Codice

## 5.4 Burst Read

cmd_write = 0
cmd_burst = 1
cmd_len   = N

Codice

## 5.5 Wrap Burst

cmd_wrap = 1
cmd_len  = power-of-two

Codice

## 5.6 FIFO Operations

cmd_fifo = 1

Codice

## 5.7 Atomic Mode

cmd_atomic = 1

Codice

Atomic mode prevents the arbiter from switching masters.

---

# 6. Response Semantics

## 6.1 Successful Read

rsp_valid = 1
rsp_data  = data
rsp_last  = 1

Codice

## 6.2 Successful Write

Writes return only:

rsp_valid = 1
rsp_last  = 1

Codice

## 6.3 Error Response

rsp_err_valid = 1
rsp_err_code  = error code
rsp_err_info  = failing address

Codice

Errors may occur:

- at the first beat,
- during a burst,
- at the last beat.

---

# 7. Error Codes

The backend defines error codes:

| Code | Meaning |
|------|---------|
| `0x00` | OKAY |
| `0x01` | SLVERR |
| `0x02` | DECERR |
| `0x03` | BOUNDARY_ERR |
| `0x04` | BURST_ERR |
| `0x05` | CHECK_ERR |

Wrappers may map codes to simpler bus-specific values.

---

# 8. ID Matching

`cmd_id` is copied into `rsp_id`.

This allows:

- multiple masters,
- out-of-order responses (AXI),
- correlation of commands and responses.

---

# 9. End-to-End Example

### Command

cmd_write = 0
cmd_addr  = 0x80000000
cmd_len   = 4
cmd_burst = 1
cmd_valid = 1

Codice

### Response

Beat 0: rsp_valid=1, rsp_last=0, rsp_data=0xAA
Beat 1: rsp_valid=1, rsp_last=0, rsp_data=0xBB
Beat 2: rsp_valid=1, rsp_last=0, rsp_data=0xCC
Beat 3: rsp_valid=1, rsp_last=1, rsp_data=0xDD

Codice

---

# 10. Summary

The DexterLab command interface:

- is bus‑agnostic,
- supports single, burst, wrap, FIFO, and atomic operations,
- uses a simple valid/ready handshake,
- provides rich error reporting,
- supports multiple masters via `cmd_id`,
- is designed for simulation and hardware integration.

This document defines the complete hardware protocol used by the parser,
arbiter, backend, and future masters.

---

# End of Document
