# DexterLab Bus Integration Overview

DexterLab originally included several *wrappers* (`cmd_wrapper_axi_full`,
`cmd_wrapper_axi_lite`, `cmd_wrapper_ahb_full`, `cmd_wrapper_ahb_lite`) whose
purpose was to adapt the generic command interface (`t_cmd_out` / `t_rsp_in`)
to different bus protocols.

These wrappers have been **removed** from the system.

The current architecture no longer requires wrappers:  
the parser connects **directly** to the backend modules.

---

# 1. Current Architecture (2026)

The DexterLab command pipeline is now:

cmd_parser → arbiter → backend → bus

Codice

There is **no wrapper layer** between the arbiter and the backend.

Each backend implements its bus protocol directly:

- `backend_axi_full` → AXI‑FULL  
- `backend_ahb_full` → AHB‑FULL  
- (future) `backend_axi_lite`  
- (future) `backend_ahb_lite`  

Wrappers are no longer needed because:

- the parser already produces bus‑agnostic commands,
- the backends already implement full protocol semantics,
- the arbiter already handles atomicity, ordering, and source selection,
- adaptation logic is unnecessary and removed.

---

# 2. Why Wrappers Were Removed

Wrappers existed originally to:

- adapt AXI‑FULL → AXI‑LITE,
- adapt AXI‑FULL → AHB‑FULL,
- adapt AXI‑FULL → AHB‑LITE,
- provide a unified interface layer.

As the architecture evolved, these roles became redundant:

### ✔ Backends now expose clean, direct interfaces  
No adaptation layer is required.

### ✔ AXI‑LITE and AHB‑LITE can be implemented directly in their own backends  
No need to “downgrade” AXI‑FULL.

### ✔ The arbiter already provides all necessary control  
Atomic mode, pending flags, priority rules.

### ✔ The parser’s command format is stable and bus‑agnostic  
No wrapper logic is needed.

### ✔ The unified wrapper module was removed from the repository  
It served no purpose anymore.

---

# 3. Direct Backend Integration

The parser and hardware masters now connect directly to the backend:

```mermaid
flowchart LR
    A[t_cmd_out] --> B[Arbiter]
    B --> C[Backend]
    C --> D[Bus]
    D --> C
    C --> B
    B --> E[t_rsp_in]
This architecture is:

simpler

faster

easier to maintain

easier to simulate

easier to extend

4. Impact on Testbenches
Testbenches now instantiate backends directly:

Codice
cmd_parser → arbiter → backend_axi_full
or

Codice
cmd_parser → arbiter → backend_ahb_full
No wrapper modules are instantiated.

This reduces boilerplate and makes simulation setups cleaner.

5. Future Backends
Future bus support will be implemented directly as backends:

AXI‑LITE backend

AHB‑LITE backend

TileLink backend

Wishbone backend

APB backend

No wrapper layer will be reintroduced.

6. Summary
All wrapper modules have been removed.

The parser connects directly to backends.

Backends implement full bus semantics.

The arbiter handles ordering and atomicity.

The architecture is simpler, cleaner, and easier to extend.

DexterLab is now a fully backend‑driven system with no wrapper layer.

End of Document
