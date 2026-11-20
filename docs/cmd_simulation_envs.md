# DexterLab Simulation Environments

DexterLab is designed to operate with multiple simulation environments ranging from lightweight open-source simulators to full-featured commercial verification platforms.

All simulation environments execute the same command architecture and the same VHDL source code.

Common architecture:

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

Common interfaces:

```text
t_cmd_out
t_rsp_out
t_rsp_in
```

The selected simulator affects workflow, debugging capabilities, waveform viewers and tool integration, but does not change the DexterLab execution model.

---

# 1. Supported Simulation Environments

The DexterLab architecture is simulator-independent.

Supported environments include:

## Open Source

- GHDL

## FPGA Vendor Tools

- Vivado / XSIM

## Commercial Simulators

- QuestaSim
- ModelSim
- Riviera-PRO
- Xcelium
- VCS

Any simulator with adequate VHDL support may be used.

---

# 2. Directory Organization

A typical project may use separate simulation directories.

```text
sim/

├── ghdl/
│   ├── Makefile
│   ├── run.sh
│   └── tb_*.vhd

├── vivado/
│   ├── *un.tcl
│   ├── compile.tcl
│   ├── simulate.tcl
│   └── tb_*.vhd
```

The exact structure may vary.

All environments share:

```text
src/
docs/
cmd files
```

---

# 3. GHDL Environment

GHDL is typically used for:

- Parser validation
- DRY_RUN validation
- Arbiter validation
- Backend development
- Regression testing
- Continuous integration

Advantages:

- Open source
- Fast compilation
- Fast simulation
- Easy automation
- Excellent Linux support

Typical workflow:

```bash
cd sim/ghdl

make

./run.sh

gtkwave waves.ghw
```

---

# 4. Vivado / XSIM Environment

Vivado simulations are typically used for:

- AXI protocol debugging
- AHB protocol debugging
- IP integration
- FPGA-oriented verification
- Detailed waveform analysis

Advantages:

- Integrated waveform viewer
- FPGA workflow integration
- Vendor IP support

Typical workflow:

```bash
cd sim/vivado

vivado -mode batch -source run.tcl
```

---

# 5. Commercial Simulators

DexterLab can also be executed using:

- QuestaSim
- ModelSim
- Riviera-PRO
- Xcelium
- VCS

These environments are commonly used for:

- Enterprise verification flows
- Large regressions
- Mixed-language projects
- UVM integrations
- Advanced debug workflows

DexterLab does not require simulator-specific modifications.

---

# 6. Shared Components

All supported environments execute:

```text
Parser Engine
Hardware Master
Arbiter
Backend Layer
Memory Models
```

using:

```text
t_cmd_out
t_rsp_out
t_rsp_in
```

and the same command files:

```text
*.cmd
```

Behavior remains consist*nt across simulators.

---

# 7* DRY_RUN Support

DRY_RUN operates*identically in all supported envir*nments.

Capabilities:

- Command *arsing
- Syntax validation
- Seman*ic validation
- Command normalizat*on

Without:

- Arbiter execution
* Backend execution
- Bus traffic
-*Hardware side effects

Typical use*cases:

- CI pipelines
- Parser de*elopment
- Documentation validatio*
- Command verification

---

# 8.*Typical Simulator Selection

| Goa* | Recommended Environment |
|----*---|--------|
| Parser development*| GHDL |
| DRY_RUN validation | GH*L |
| Regression testing | GHDL |
* AXI protocol debug | Vivado / X*IM |
| AHB protocol debug | Vivado*/ XSIM |
| Vendor*IP integration | Vivado |
* Enterprise verification | QuestaS*m / Xcelium*/ VCS |
| Mixed-language projects * Commercial simulators |

---

#*9. Verification Philosophy

Dexter*ab*intentionally separates:

```*ext
Command Semantics
```

from*

```text
Simulator Choice*```

This guarantees that:

- The *arser*behaves identically
- The*arbiter behaves identically
- Back*nd*logic behaves*identically
- Command files*remain portable

*cross all*supported environments.

---

* 10. Summary

DexterLab supports a*wide range of simulation environme*ts*while preserving a single executio* architecture.

Supported simulato*s include:

- G*DL
- Vivado / XSIM
* QuestaSim
- ModelSim
- Riviera*PRO
- Xcelium
- V*S

All environments execute*the same:

```text
Parser /*Master
        |
        v
     Ar*iter*        |
        v
     Backend
`**

architecture and share the same *ommand interfaces:

```text
t_cmd_*ut
t_rsp*out
t_rsp_in
```

ensuring consist*nt behavior across development, ve*ification and*integration workflows.

---

# End*of Document
