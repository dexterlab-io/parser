# DexterLab Design Principles

(Version 2026 — Architectural Foundations and Engineering Philosophy)

This document defines the fundamental architectural principles that guide the design, implementation, evolution, and maintenance of the DexterLab ecosystem.

These principles serve as the long-term foundation of the project and should be considered whenever new functionality, protocols, backends, command types, or system integrations are introduced.

The purpose of this document is to ensure that DexterLab evolves consistently over time while preserving its core architectural identity.

---

# 1. Command First

The command model is the center of the architecture.

DexterLab is not built around a specific bus protocol.

It is built around a protocol-independent command language.

Commands express:

```text
Intent
```

rather than:

```text
Bus Transactions
```

Example:

```text
WRITE 0x1000 0x12345678
```

describes:

```text
What should happen
```

not:

```text
How a specific protocol performs it
```

This separation is the foundation of the framework.

---

# 2. Protocol Independence

Command semantics must remain identical regardless of the transport protocol.

The meaning of:

```text
READ
WRITE
CHECK
BURST_WRITE
FIFO_READ
```

must not change between:

```text
Generic
AXI-FULL
AXI-LITE
AHB-FULL
AHB-LITE
```

Protocol-specific details belong exclusively inside backend implementations.

---

# 3. Unified Interfaces

All command producers and execution engines communicate through the same interfaces:

```text
t_cmd_out
t_rsp_out
t_rsp_in
```

No protocol-specific interfaces may bypass this model.

This guarantees:

- Interoperability
- Reusability
- Long-term maintainability

Every future extension should integrate through these interfaces whenever possible.

---

# 4. Backend Ownership

The parser defines command semantics.

The backend defines protocol execution.

Responsibilities must remain separated.

### Parser Responsibilities

```text
Syntax
Semantics
Validation
Normalization
Micro-command generation
```

### Backend Responsibilities

```text
Address generation
Protocol timing
Bus transactions
Protocol-specific rules
Error generation
```

A backend should never redefine command semantics.

A parser should never implement protocol behavior.

---

# 5. Arbiter Independence

The arbiter manages ownership.

The arbiter does not execute transactions.

The arbiter does not interpret protocol semantics.

The arbiter only manages:

```text
Ownership
Pending commands
Locked execution
Response routing
```

This separation guarantees scalability across multiple command sources.

---

# 6. Single Source of Truth

Every concept should have exactly one authoritative definition.

Examples:

| Concept | Authoritative Document |
|----------|----------|
| Command syntax | `cmd_file_format.md` |
| Command definitions | `command_set.md` |
| Interfaces | `cmd_interface.md` |
| Error model | `cmd_errors.md` |
| Arbiter behavior | `DexterLab Arbiter Specification.md` |

Documentation duplication should be avoided whenever practical.

Documents should reference definitions instead of redefining them.

---

# 7. Verification Before Hardware

DexterLab is verification-driven.

New functionality should first be validated through:

```text
DRY_RUN
Generic Backend
Simulation
Regression Testing
```

before being deployed through hardware-oriented backends.

Simulation correctness has priority over hardware optimization.

---

# 8. Deterministic Behavior

Equivalent inputs should produce equivalent outputs.

Given:

```text
Same command file

Same configuration

Same backend
```

the execution behavior should remain:

```text
Deterministic
Reproducible
Traceable
```

across all supported simulators.

---

# 9. Explicit Ownership

Ownership must always be visible and deterministic.

There must never be ambiguity about:

```text
Who owns the backend

Who receives the response

Who may issue the next command
```

This principle directly drives the arbiter architecture.

---

# 10. Explicit Completion

Every accepted command must have an identifiable completion point.

DexterLab uses:

```text
rsp_end_cmd
```

as the authoritative completion indicator.

Execution is not considered complete until command completion has been explicitly reported.

---

# 11. Locked Execution Is an Arbiter Function

Protected execution sequences are implemented through:

```text
cmd_lock
```

Ownership locking belongs to:

```text
Arbiter
```

not:

```text
Parser
Backend
Memory Models
```

This ensures consistent behavior across all execution environments.

---

# 12. Extensibility Without Disruption

New functionality should extend the framework instead of modifying existing behavior.

Examples:

```text
New Commands
New Backends
New Masters
New Protocol Bridges
```

should appear as additions rather than replacements.

Backward compatibility should be preserved whenever practical.

---

# 13. No Wrapper Layers

The architecture intentionally avoids protocol wrappers.

Current architecture:

```text
Parser / Master
        |
        v
     Arbiter
        |
        v
     Backend
        |
        v
       Bus
```

A backend directly implements protocol behavior.

Introducing generic wrapper layers is discouraged because they:

- Duplicate logic
- Increase complexity
- Obscure ownership
- Reduce maintainability

---

# 14. Backend Specialization

Backends may differ internally.

Examples:

```text
AXI-FULL
AXI-LITE
AHB-FULL
AHB-LITE
Generic
```

However, the command model exposed to the rest of the framework must remain stable.

Backend specialization must not leak into command semantics.

---

# 15. Simulation Neutrality

DexterLab is independent of any simulator vendor.

Supported environments include:

```text
GHDL
Vivado / XSIM
QuestaSim
ModelSim
Riviera-PRO
Xcelium
VCS
```

Behavior must remain consistent regardless of simulator choice.

Simulator-specific dependencies should be avoided whenever possible.

---

# 16. Documentation as Architecture

Documentation is part of the architecture.

Architectural decisions must be reflected in documentation.

Documentation should:

- Describe real HDL behavior
- Stay synchronized with implementation
- Document rationale, not only functionality
- Guide future development

Undocumented behavior should be treated as incomplete design.

---

# 17. Evolution Through Layering

DexterLab grows by adding layers, not by rewriting foundations.

Examples:

```text
New Backend
New Master
New Protocol Bridge
New Command Source
```

should integrate into existing architecture rather than replacing it.

This preserves stability while enabling growth.

---

# 18. Long-Term Vision

The architecture is intentionally designed to scale from:

```text
Single Command File
```

to:

```text
Multi-Protocol Verification
```

to:

```text
Embedded Systems
```

to:

```text
RISC-V Integration
```

to:

```text
Distributed Command Networks
```

without changing the core command model.

---

# 19. Architectural Summary

The most important DexterLab principles are:

```text
Command First

Protocol Independent

Unified Interfaces

Backend Ownership

Verification Before Hardware

Deterministic Execution

Explicit Ownership

Explicit Completion

No Wrapper Layers

Extensibility Without Disruption
```

Every major architectural decision should be evaluated against these principles.

---

# 20. Final Principle

If a proposed feature makes the architecture:

```text
Simpler
More deterministic
More protocol-independent
More reusable
More maintainable
```

then it is likely aligned with DexterLab.

If it introduces:

```text
Protocol leakage
Ambiguous ownership
Special-case behavior
Wrapper proliferation
Hidden execution paths
```

then it should be reconsidered.

---

# End of Document
