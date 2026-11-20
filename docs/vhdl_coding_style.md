# DexterLab VHDL Coding Style Guide

(Version 2026)

# Naming Conventions

## Signals

```text
s_*     internal signals
```

Example:

```vhdl
signal s_cmd_pending : std_logic;
```

## Inputs

```text
i_*
```

## Outputs

```text
o_*
```

## Constants

```text
c_*
```

## Generics

```text
g_*
```

---

# FSM Style

Always use:

```vhdl
state_current
state_next
```

Never:

```vhdl
current_state
nstate
state_reg
```

---

# Process Naming

Preferred:

```vhdl
fsm_sync_proc
fsm_comb_proc

main_sync_proc
main_comb_proc
```

---

# Reset Policy

Prefer synchronous resets.

All reset behavior shall be deterministic.

---

# Records

Prefer records over long port lists.

Use:

```vhdl
t_cmd_out
t_rsp_in
t_rsp_out
```

whenever possible.

---

# Packages

Common types belong in packages.

Duplicate type declarations are forbidden.

---

# Comments

Comment intent.

Do not comment obvious syntax.

Good:

```vhdl
-- retain ownership during locked sequence
```

Bad:

```vhdl
-- increment i
```

---

# End of Document
