This folder contains the verification suite used to validate the processor's architectural correctness. It includes the CPU_tb.v and controller_tb.v Verilog testbench and the .hex files loaded into the instruction memory via $readmemh. These tests cover 12 automated instruction checks, including edge-case verification for shifting, memory consistency, and conditional branching.

It should be noted that for FPGA synthesization, .mif file should be used, in order to assign BRAM blocks correctly. 
