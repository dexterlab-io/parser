# DexterLab Command Configuration Package (`cmd_cfg.vhd`)

This document describes the configuration constants and base types defined in
`cmd_cfg.vhd`.  
These parameters control the global behavior of the DexterLab Command Parser,
the backend executors, and the simulation environment.

The package is intentionally simple, stable, and backend‑agnostic.  
All modules (parser, arbiter, AXI/AHB executors, FIFO models, dump/check logic)
depend on these constants.

---

# 1. Logging Configuration

```vhdl
constant ENABLE_DEBUG_LOG : boolean := false;
Description
Controls whether debug messages (severity note) are printed during simulation.

false → silent mode (recommended for regression runs)

true → verbose mode (useful for debugging parser behavior)

Warnings, errors, and fatal messages are always enabled.

2. Base Configuration
vhdl
constant C_ADDR_WIDTH : natural := 32;
constant C_DATA_WIDTH : natural := 32;
Description
Defines the width of:

addresses (t_addr)

data words (t_data)

These values propagate through:

parser engine

arbiter

AXI/AHB executors

dump/fill/check logic

FIFO models

3. Data Token Configuration
vhdl
constant C_MAX_DATA_TOKENS    : natural := 1024;
constant C_MAX_DATA_PER_LINE  : natural := 8;
Description
C_MAX_DATA_TOKENS
Maximum number of data tokens that a single micro‑command can contain.

From the source code:

“Il burst logico può essere > C_MAX_DATA_TOKENS (es. 1024),
ma verrà spezzato in più micro‑burst in cmd_cmd_pkg.”

Meaning:

A command like BURST_WRITE len=4096 is allowed.

The parser splits it into multiple micro‑bursts of max 1024 tokens.

C_MAX_DATA_PER_LINE
Maximum number of data tokens allowed per line in the command file.

Example:

Codice
BURST_WRITE BASE_RAM 16 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08
If more than 8 tokens are present, the parser continues reading the next line.

4. Micro‑Command Buffer Configuration
vhdl
constant C_MAX_MC : natural := 64;
Description
Maximum number of micro‑commands generated from a single command line.

From the source code:

“Una singola riga (anche con burst grandi) non genera mai più di qualche decina di microcomandi; 64 è un valore ampiamente sufficiente.”

Used internally by the parser engine to store:

split bursts

split wrap bursts

split FIFO operations

split fill/dump ranges

5. Timeout Configuration
vhdl
constant C_MAX_TIMEOUT : natural := 1024;
constant C_MAX_AXI_TIMEOUT : integer := 1024;
Description
Used by:

POLL_READ

POLL_TOGGLE

POLL_PING

WAIT_CLOCKS

AXI timeout logic inside backend executors

Defines the maximum number of internal cycles before a timeout error is raised.

6. Derived Constants
vhdl
constant C_MAX_STRING        : natural := 256;
constant C_MAX_INCLUDE_DEPTH : natural := 16;

constant C_ID_WIDTH   : natural := 4;
constant C_MAX_ATOMIC : natural := 16;

constant C_CFG_WIDTH : integer := 8;
constant C_PKG_WIDTH : integer := 16;
Description
C_MAX_STRING
Maximum length of a command line (256 characters).

C_MAX_INCLUDE_DEPTH
Maximum nesting depth for INCLUDE commands.

Example:

Codice
A includes B
B includes C
C includes D
...
Depth > 16 triggers an error.

C_ID_WIDTH
Width of command IDs (cmd_id and rsp_id).

Used for correlating responses to commands.

C_MAX_ATOMIC
Maximum number of commands allowed inside an atomic block.

Atomic mode is controlled by:

Codice
SET_ATOMIC 1
...
SET_ATOMIC 0
C_CFG_WIDTH / C_PKG_WIDTH
Internal configuration widths used by:

parser engine

command package

backend executors

These values are not meant to be modified.

7. Command Source IDs
vhdl
constant ID_PARSER : unsigned(C_ID_WIDTH-1 downto 0) := to_unsigned(0, C_ID_WIDTH);
constant ID_MASTER : unsigned(C_ID_WIDTH-1 downto 0) := to_unsigned(1, C_ID_WIDTH);
Description
Used by the arbiter to tag commands based on their origin:

ID_PARSER → commands from the text parser

ID_MASTER → commands from the hardware master (future RISC‑V)

These IDs appear in:

cmd_id

rsp_id

rsp_err_id

8. Base Types
vhdl
subtype t_addr is std_logic_vector(C_ADDR_WIDTH-1 downto 0);
subtype t_data is std_logic_vector(C_DATA_WIDTH-1 downto 0);

type t_line is array(1 to C_MAX_STRING) of character;
Description
t_addr
Address type used by all commands.

t_data
Data type used for:

WRITE

FIFO_WRITE

BURST_WRITE

WRAP_WRITE

FILL_LEN

FILL_RANGE

t_line
Internal buffer used by the parser to store a full command line.

9. Summary
cmd_cfg.vhd defines:

global configuration parameters

parser limits

burst splitting limits

timeout values

atomic mode limits

include depth

base types

command source IDs

These constants ensure consistent behavior across all DexterLab modules and
provide a stable foundation for both simulation and future synthesizable
versions.

End of Document
