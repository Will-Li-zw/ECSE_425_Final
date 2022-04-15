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
vcom cache_tb.vhd
vcom memory.vhd

;# Start simulation
vsim cache_tb

;# Generate a clock with 1ns period
force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns

;# Add the waves
AddWaves

;# change radix
radix signal sim:/cache_tb/s_addr Hexadecimal
radix signal sim:/cache_tb/s_writedata Hexadecimal
radix signal sim:/cache_tb/s_readdata Hexadecimal


;# Run for 1850 ns
run 1850ns
