# ======================================================================
#  DexterLab™
#  Copyright (c) DexterLab
#  Released as free example code for educational and non-commercial use.
#  No warranty is provided. Use at your own risk.
#  © 2026 DexterLab
# ======================================================================
#  File: Makefile
#  Author: Dexter
#  Date: 2026-09-06
#  Version: 1.0
# ======================================================================


.SILENT:

TOP	= tb_parser

clean:
	if exist .Xil rmdir /s /q .Xil
	if exist xsim.dir rmdir /s /q xsim.dir
	if exist *.log del /f *.log
	if exist *.jou del /f *.jou
	if exist *.pb del /f *.pb
	if exist *.wdb del /f *.wdb


# ============================================================
#  Vivado xsim setup
# ============================================================
# Please use xsim_env.bat

# ============================================================
#  Vivado / xsim targets
# ============================================================

xsim_compile:
	echo Compile RTL (Vivado)
	xvhdl ..\..\..\rtl\cmd_cfg.vhd \
		..\..\..\rtl\cmd_text_pkg.vhd \
		..\..\..\rtl\cmd_cmd_pkg.vhd \
		..\..\..\rtl\cmd_vars_pkg.vhd \
		..\..\..\rtl\cmd_map_pkg.vhd \
		..\..\..\rtl\cmd_math_pkg.vhd \
		..\..\..\rtl\cmd_time_pkg.vhd \
		..\..\..\rtl\cmd_micro_pkg.vhd \
		..\..\..\rtl\cmd_lex_pkg.vhd \
		..\..\..\rtl\cmd_eval_pkg.vhd \
		..\..\..\rtl\cmd_parse_pkg.vhd \
		..\..\..\rtl\cmd_semantic_pkg.vhd \
		..\..\..\rtl\cmd_split_pkg.vhd \
		..\..\..\rtl\cmd_log_pkg.vhd \
		..\..\..\rtl\cmd_file_pkg.vhd \
		..\..\..\rtl\cmd_pkg.vhd

	xvhdl ..\..\..\rtl\cmd_parser.vhd \
		..\..\..\rtl\cmd_master.vhd

	echo Compile TB (Vivado)
	xvhdl ..\..\..\tb\ckrst.vhd \
		..\..\..\tb\arbiter_mux.vhd \
		..\..\..\tb\ram_sync.vhd \
		..\..\..\tb\ram_sync_wstrb.vhd \
		..\..\..\tb\gen_fifo_wr.vhd \
		..\..\..\tb\gen_fifo_rd.vhd \
		..\..\..\tb\gen_fifo.vhd \
		..\..\..\tb\cmd_parser_slave_generic.vhd \
		..\..\..\tb\tb_parser.vhd

# Elaborazione del design
xsim_elab:
	echo Elaborate (Vivado)
	xelab $(TOP) -debug typical -s $(TOP)_sim

# Simulazione
xsim_run:
	echo Simulate (Vivado)
	xsim $(TOP)_sim -tclbatch stop.tcl

# Target completo
xsim: xsim_compile xsim_elab xsim_run

xsim_gui:
	xsim tb_parser_sim --gui
