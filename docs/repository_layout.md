# DexterLab Repository Layout

(Version 2026)

# Root Structure

```text
src/
docs/
tb/
test/
sim/
```

---

# src/

Contains HDL implementation.

Example:

```text
parser/
arbiter/
backend/
master/
models/
```

---

# docs/

Contains architecture and user documentation.

Every major subsystem should have a corresponding document.

---

# tb/

Testbenches.

Example:

```text
tb_dexterlab.vhd
```

---

# test/

Command files.

Example:

```text
burst_test.cmd
fifo_test.cmd
memory_test.cmd
```

---

# sim/

Simulator-specific scripts.

Examples:

```text
ghdl/
vivado/
```

---

# Rule

Documentation structure should mirror architecture structure.

---

# End of Document
