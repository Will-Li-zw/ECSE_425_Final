proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position insertpoint sim:/pipelined_mips_processor_tb/*
    add wave -position insertpoint sim:/pipelined_mips_processor_tb/my_processor/fetcher/*
    add wave -position insertpoint sim:/pipelined_mips_processor_tb/my_processor/decoder/*
    add wave -position insertpoint sim:/pipelined_mips_processor_tb/my_processor/decoder/rf/r   ;# the register files array
    add wave -position insertpoint sim:/pipelined_mips_processor_tb/my_processor/executer/*
    add wave -position insertpoint sim:/pipelined_mips_processor_tb/my_processor/memoryer/*
    add wave -position insertpoint sim:/pipelined_mips_processor_tb/my_processor/writer/*
    add wave -position insertpoint  \                                                           ;# the memory array
            sim:/pipelined_mips_processor_tb/my_mem/inst_ram_block \
            sim:/pipelined_mips_processor_tb/my_mem/data_ram_block

}

vlib work

;# Compile components if any
vcom ADD.vhd
vcom TWOMUX.vhd
vcom FIVEMUX.vhd
vcom memory.vhd
vcom ALU.vhd
vcom register_file.vhd
vcom fetch_stage.vhd
vcom decode_stage.vhd
vcom execute_stage.vhd
vcom memory_stage.vhd
vcom writeback_stage.vhd
vcom Processor.vhd
vcom Pipelined_MIPS_Processor_tb.vhd


;# Start simulation
vsim pipelined_mips_processor_tb

;# Generate a clock with 1ns period
force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns

;# Add the waves
AddWaves

;# change radix
radix signal sim:/pipelined_mips_processor_tb/* Hexadecimal
radix signal sim:/pipelined_mips_processor_tb/my_processor/fetcher/* Hexadecimal
radix signal sim:/pipelined_mips_processor_tb/my_processor/decoder/* Hexadecimal
radix signal sim:/pipelined_mips_processor_tb/my_processor/decoder/rf/r Hexadecimal
radix signal sim:/pipelined_mips_processor_tb/my_processor/executer/* Hexadecimal
radix signal sim:/pipelined_mips_processor_tb/my_processor/memoryer/* Hexadecimal
radix signal sim:/pipelined_mips_processor_tb/my_processor/writer/* Hexadecimal
radix signal sim:/pipelined_mips_processor_tb/my_mem/inst_ram_block Hexadecimal
radix signal sim:/pipelined_mips_processor_tb/my_mem/data_ram_block Hexadecimal


;# Run for 51.5 ns
run 51.5 ns
