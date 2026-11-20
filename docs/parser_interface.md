# DexterLab Generic Interface Specification

This document provides a high-level overview of the generic interfaces used throughout the DexterLab architecture.

The authoritative interface specification is documented in:

```text
cmd_interface.md
```

All current implementations, including:

- Parser Engine
- Hardware Master
- Arbiter
- Generic Backend
- AXI-FULL Backend
- AXI-LITE Backend
- AHB-FULL Backend
- AHB-LITE Backend
- TileLink Bridge

use the same protocol-independent interfaces.

---

# Core Interfaces

## Command Interface

```text
t_cmd_out
```

Carries:

- Command attributes
- Address information
- Transfer information
- Lock information
- Protocol attributes
- Command identifiers

---

## Response Control Interface

```text
t_rsp_out
```

Carries:

- Response acceptance
- Error-response acceptance

---

## Response Interface

```text
t_rsp_in
```

Carries:

- Response data
- Command completion status
- Error information
- Response identifiers

---

# Architecture

```text
Parser / Master
        |
        v
     Arbiter
        |
        v
     Backend
```

All command sources generate:

```text
t_cmd_out
```

All backends respond through:

```text
t_rsp_in
```

and use:

```text
t_rsp_out
```

for response flow control.

---

# Related Documentation

Detailed field definitions:

```text
cmd_interface.md
```

Command execution flow:

```text
cmd_flow.md
```

Arbiter behavior:

```text
DexterLab Arbiter Specification.md
```

Master integration:

```text
parser_master_integration.md
```

Backend architecture:

```text
DexterLab Backend Overview.md
```

---

# Summary

The DexterLab architecture is built around three protocol-independent interfaces:

```text
t_cmd_out
t_rsp_out
t_rsp_in
```

These interfaces provide a stable contract between command generators, the arbiter, and backend implementations.

For complete record definitions and timing semantics, refer to:

```text
cmd_interface.md
```

---

# End of Document
