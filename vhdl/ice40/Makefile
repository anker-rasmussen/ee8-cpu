# EE8 CPU → Nandland Go Board (iCE40 HX1K) Synthesis Makefile
# Toolchain: ghdl + yosys (via ghdl-yosys-plugin) → nextpnr-ice40 → icepack → iceprog

DEVICE   := hx1k
PACKAGE  := vq100
TOP      := go_board_top
PCF      := Go_Board_Constraints.pcf

# VHDL source files (order matters: dependencies first)
VHDL_SRC := \
	../alu.vhd \
	../register_file.vhd \
	../instruction_decoder.vhd \
	../control_unit.vhd \
	../program_counter.vhd \
	../rom.vhd \
	../ee8_cpu.vhd \
	hex_to_7seg.vhd \
	go_board_top.vhd

.PHONY: all clean prog

all: $(TOP).bin

# Synthesis: GHDL + Yosys → JSON netlist
$(TOP).json: $(VHDL_SRC)
	yosys -m ghdl -p \
		"ghdl $(VHDL_SRC) -e $(TOP); synth_ice40 -top $(TOP) -json $@"

# Place & Route: nextpnr-ice40 → ASC
$(TOP).asc: $(TOP).json $(PCF)
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $< --asc $@

# Bitstream: icepack → BIN
$(TOP).bin: $(TOP).asc
	icepack $< $@

# Flash to board
prog: $(TOP).bin
	iceprog $<

clean:
	rm -f $(TOP).json $(TOP).asc $(TOP).bin
