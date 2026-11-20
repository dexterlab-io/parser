# DexterLab Contributor Guide

(Version 2026 — Development Workflow and Contribution Guidelines)

---

# 1. Purpose

This document explains how to contribute to the DexterLab ecosystem.

It applies to:

- Parser development
- Arbiter development
- Backend development
- Hardware master development
- Testbench development
- Documentation contributions

The goal is to ensure that all contributions remain aligned with the DexterLab architecture and design principles.

---

# 2. Before Contributing

Every contributor should read:

```text
Architecture Overview.md

design_principles.md

cmd_interface.md

DexterLab Arbiter Specification.md

DexterLab Backend Overview.md
```

Understanding these documents is considered mandatory before implementing new features.

---

# 3. Architecture Rule

Every contribution must fit the architecture:

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

No feature should bypass this model.

---

# 4. Adding a New Command

Checklist:

1. Define semantics.
2. Update command_set.md.
3. Update cmd_file_format.md.
4. Update parser decoder.
5. Update semantic validator.
6. Update DRY_RUN support.
7. Update Generic Backend.
8. Add regression tests.
9. Update documentation.

A command is not complete until all steps are finished.

---

# 5. Adding a New Backend

Requirements:

- Accept t_cmd_out
- Implement t_rsp_out
- Generate t_rsp_in
- Support rsp_end_cmd
- Follow cmd_lock behavior

Every backend must preserve command semantics.

The backend may implement protocol-specific behavior but must not redefine command meaning.

---

# 6. Adding a New Hardware Master

Requirements:

```text
Generate t_cmd_out
Consume t_rsp_in
Drive t_rsp_out
```

The master must never access the backend directly.

All accesses must pass through the arbiter.

---

# 7. Documentation Requirements

New features require documentation updates.

Mandatory files:

- Implementation document
- Interface changes
- Error handling updates
- Examples

Undocumented behavior is considered incomplete.

---

# 8. Testing Requirements

Before merging:

```text
DRY_RUN test

Generic Backend test

Protocol Backend test

Regression suite
```

must pass.

---

# 9. Commit Philosophy

Good commits:

```text
Add FIFO_CHECK support

Fix burst boundary split

Update arbiter lock handling
```

Bad commits:

```text
misc fixes

update

changes
```

---

# 10. Pull Request Checklist

- Code compiles
- Tests pass
- Documentation updated
- No protocol leakage
- Design principles respected

---

# End of Document
