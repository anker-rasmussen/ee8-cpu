#!/bin/bash
# ModelSim simulation script for EE8 CPU

MODELSIM=/opt/intelFPGA/20.1/modelsim_ase/bin
cd /home/broadcom/EE/vhdl

# Create work library
$MODELSIM/vlib work

# Compile all VHDL files in order (dependencies first)
$MODELSIM/vcom -93 alu.vhd
$MODELSIM/vcom -93 register_file.vhd
$MODELSIM/vcom -93 instruction_decoder.vhd
$MODELSIM/vcom -93 program_counter.vhd
$MODELSIM/vcom -93 control_unit.vhd
$MODELSIM/vcom -93 ee8_cpu.vhd
$MODELSIM/vcom -93 ee8_cpu_tb.vhd

# Run simulation
$MODELSIM/vsim -c work.ee8_cpu_tb -do "run 200 ns; quit"
