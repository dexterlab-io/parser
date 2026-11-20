# DexterLab Parser Error Specification

This document defines the complete DexterLab error model used by the parser, arbiter, and backend executors.

Errors are divided into three categories:

1. Syntax errors
2. Semantic errors
3. Runtime errors

Runtime errors are reported through the unified backend error database (`C_ERR_INFO`) and propagated through the parser response interface.

---

# 1. Error Categories

## 1.1 Syntax Errors

Syntax errors occur during `.cmd` file parsing.

They prevent command generation and stop execution immediately.

No backend is involved.

Examples:

- Unknown command
- Missing arguments
- Invalid number format
- Invalid burst length
- Invalid wrap length
- Data count mismatch

---

## 1.2 Semantic Errors

Semantic errors occur after parsing and before backend execution.

The parser validates command consistency and rejects invalid commands.

Examples:

- Address misalignment
- Invalid burst configuration
- Invalid wrap configuration
- FIFO misuse
- Atomic block misuse
- Invalid command arguments

These errors prevent the command from reaching the backend.

---

## 1.3 Runtime Errors

Runtime errors occur during backend execution.

These errors are reported through:

```text
rsp_err_valid
rsp_err_code
rsp_err_addr
rsp_err_beat
```

and propagated through:

```text
Backend
    |
Arbiter
    |
Parser
    |
User
```

Runtime errors use the unified DexterLab error database.

---

# 2. AXI-FULL Error Codes

Error code range:

```text
0x00 - 0x0F
```

| Code | Name | Description |
|--------|--------|-------------|
| 0 | AXI_FULL OKAY | Access completed correctly |
| 1 | AXI_FULL EXOKAY | Exclusive access successful |
| 2 | AXI_FULL SLVERR | Slave internal error |
| 3 | AXI_FULL DECERR | Address decode error |
| 4 | AXI_FULL TIMEOUT | No response from slave |
| 5 | AXI_FULL PROT_ERR | Protocol violation |
| 6 | AXI_FULL BOUNDARY_ERR | 4KB boundary crossed |
| 7 | AXI_FULL BURST_ERR | Invalid or crossing burst |
| 8 | AXI_FULL ID_ERR | ID mismatch |
| 9 | AXI_FULL WSTRB_ERR | Invalid write strobe pattern |
| 10–15 | AXI_FULL UNKNOWN_ERROR | Reserved for unexpected conditions |

---

# 3. AXI-LITE Error Codes

Error code range:

```text
0x10 - 0x1F
```

| Code | Name | Description |
|--------|--------|-------------|
| 16 | AXI_LITE OKAY | Access completed correctly |
| 17 | AXI_LITE RESERVED_1 | Reserved |
| 18 | AXI_LITE SLVERR | Slave internal error |
| 19 | AXI_LITE DECERR | Address decode error |
| 20 | AXI_LITE TIMEOUT | No response from slave |
| 21 | AXI_LITE PROT_ERR | Protocol violation |
| 22 | AXI_LITE BOUNDARY_ERR | 4KB boundary crossed |
| 23 | AXI_LITE BURST_ERR | Invalid or crossing burst |
| 24 | AXI_LITE ID_ERR | ID mismatch |
| 25 | AXI_LITE WSTRB_ERR | Invalid write strobe pattern |
| 26–31 | AXI_LITE UNKNOWN_ERROR | Reserved for unexpected conditions |

---

# 4. AHB-FULL Error Codes

Error code range:

```text
0x20 - 0x2F
```

| Code | Name | Description |
|--------|--------|-------------|
| 32 | AHB_FULL OKAY | Access completed correctly |
| 33 | AHB_FULL ERROR | Error response |
| 34 | AHB_FULL RETRY | Retry requested by slave |
| 35 | AHB_FULL SPLIT | Split response from slave |
| 36 | AHB_FULL TIMEOUT | No response from slave |
| 37 | AHB_FULL PROT_ERR | Protocol violation |
| 38 | AHB_FULL BOUNDARY_ERR | 4KB boundary crossed |
| 39 | AHB_FULL BURST_ERR | Invalid or crossing burst |
| 40 | AHB_FULL ID_ERR | ID mismatch |
| 41 | AHB_FULL WSTRB_ERR | Invalid write strobe pattern |
| 42–47 | AHB_FULL UNKNOWN_ERROR | Reserved for unexpected conditions |

---

# 5. AHB-LITE Error Codes

Error code range:

```text
0x30 - 0x3F
```

| Code | Name | Description |
|--------|--------|-------------|
| 48 | AHB_LITE OKAY | Access completed correctly |
| 49 | AHB_LITE ERROR | Error response |
| 50 | AHB_LITE RESERVED_2 | Reserved |
| 51 | AHB_LITE RESERVED_3 | Reserved |
| 52 | AHB_LITE TIMEOUT | No response from slave |
| 53 | AHB_LITE PROT_ERR | Protocol violation |
| 54 | AHB_LITE BOUNDARY_ERR | 4KB boundary crossed |
| 55 | AHB_LITE BURST_ERR | Invalid or crossing burst |
| 56 | AHB_LITE ID_ERR | ID mismatch |
| 57 | AHB_LITE WSTRB_ERR | Invalid write strobe pattern |
| 58–63 | AHB_LITE UNKNOWN_ERROR | Reserved for unexpected conditions |

---

# 6. Common Runtime Error Types

The following runtime error classes are shared across all supported backends.

---

## Timeout Errors

Generated when a bus transaction does not complete within the configured timeout window.

Examples:

```text
AXI_FULL TIMEOUT
AXI_LITE TIMEOUT
AHB_FULL TIMEOUT
AHB_LITE TIMEOUT
```

---

## Protocol Errors

Generated when a backend detects a protocol violation.

Examples:

```text
AXI_FULL PROT_ERR
AXI_LITE PROT_ERR
AHB_FULL PROT_ERR
AHB_LITE PROT_ERR
```

---

## Boundary Errors

Generated when a transfer violates backend boundary rules.

Examples:

```text
AXI_FULL BOUNDARY_ERR
AHB_FULL BOUNDARY_ERR
AHB_LITE BOUNDARY_ERR
```

---

## Burst Errors

Generated when:

- Burst length is invalid
- Burst configuration is unsupported
- Burst execution would violate protocol rules

Examples:

```text
AXI_FULL BURST_ERR
AXI_LITE BURST_ERR
AHB_FULL BURST_ERR
AHB_LITE BURST_ERR
```

---

## WSTRB Errors

Generated when write strobes are invalid or inconsistent with transfer size.

Examples:

```text
AXI_FULL WSTRB_ERR
AXI_LITE WSTRB_ERR
AHB_FULL WSTRB_ERR
AHB_LITE WSTRB_ERR
```

---

## ID Errors

Generated when transaction correlation identifiers become inconsistent.

Examples:

```text
AXI_FULL ID_ERR
AXI_LITE ID_ERR
AHB_FULL ID_ERR
AHB_LITE ID_ERR
```

---

# 7. Error Reporting Interface

Backend runtime errors are reported through:

```text
rsp_err_valid
```

Indicates the presence of an error report.

```text
rsp_err_code
```

Contains the value defined in the unified error database.

```text
rsp_err_addr
```

Address associated with the error.

```text
rsp_err_beat
```

Beat index associated with the error when applicable.

---

# 8. Error Propagation

Runtime errors follow the path:

```text
Bus
    |
Backend
    |
Arbiter
    |
Parser
    |
User
```

The parser logs:

- Error code
- Address
- Beat index
- Transaction identifier

and terminates the active command when required.

---

# 9. Unknown Errors

Each backend reserves several entries for future expansion.

Examples:

```text
AXI_FULL UNKNOWN_ERROR
AXI_LITE UNKNOWN_ERROR
AHB_FULL UNKNOWN_ERROR
AHB_LITE UNKNOWN_ERROR
```

These codes are intended for:

- Future protocol extensions
- Debugging
- Unexpected implementation-specific failures

---

# 10. Summary

DexterLab uses a unified backend error database organized by protocol:

| Protocol | Error Range |
|----------|-------------|
| AXI_FULL | 0–15 |
| AXI_LITE | 16–31 |
| AHB_FULL | 32–47 |
| AHB_LITE | 48–63 |

The error system provides:

- Protocol-specific diagnostics
- Unified parser reporting
- Address and beat tracking
- Consistent backend behavior
- Extensible future expansion

This error model is the official error-reporting mechanism used by DexterLab version 1.1.0.

---

# End of Document
