# DexterLab Verification Methodology

(Version 2026)

# Verification Philosophy

Verification proceeds in layers.

DRY_RUN
    ↓
Generic Backend
    ↓
Protocol Backend
    ↓
System Integration
    ↓
Regression

---

# Stage 1: DRY_RUN

Verify:

- Syntax
- Semantics
- Variables
- Includes

No backend execution.

---

# Stage 2: Generic Backend

Verify:

- Command generation
- Arbiter behavior
- FIFO
- Burst
- Wrap

Fastest execution environment.

---

# Stage 3: Protocol Backend

Verify:

- AXI timing
- AHB timing
- Protocol semantics

---

# Stage 4: Integration

Verify:

- Multiple sources
- Hardware master
- Arbiter ownership

---

# Stage 5: Regression

Run:

- Command suites
- Error suites
- Stress tests

before release.

---

# End of Document
