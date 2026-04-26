# 32-bit Single-Cycle ARM Processor

## 📌 Overview
This repository contains a fully functional 32-bit single-cycle processor designed for the ARM Instruction Set Architecture (ISA). The design is partitioned into a modular datapath and a hard-wired control unit, capable of executing an instruction in exactly one clock cycle.

## 🛠 Supported Instruction Set
The processor supports a restricted yet powerful ARM ISA, validated through automated testbenches:

| Mnemonic | Operation | Description |
| :--- | :--- | :--- |
| **ADD / SUB** | $Rd \leftarrow Rn \pm Src2$ | Arithmetic with shifted operand |
| **AND / ORR** | $Rd \leftarrow Rn \text{ AND/OR } Src2$ | Bitwise logic operations |
| **MOV** | $Rd \leftarrow Src2$ | Register or immediate move |
| **CMP** | $SetFlags(Rn - Rm)$ | Comparison and flag update (Zero flag) |
| **LDR / STR** | $Mem[Rn + imm12]$ | Memory Load and Store |
| **B / BL** | Branch / Branch with Link | PC-relative jumps with R14 link support |
| **BX** | Branch Exchange | Indirect branch via register (Rm) |

## 🚀 Advanced Architectural Features
This implementation includes several custom modifications to support the full ARM specification requirements:

* **Register-Shifted Immediates:** Integrated rotation logic within the bit-extender that dynamically applies bitwise right-rotation for 8-bit immediate values based on the rotation field.
* **MOV Optimization:** Implemented a bypass mechanism to force the ALU's primary input to zero, allowing the second operand to flow to the result without interference.
* **Subroutine Support (BL):** Dedicated hardware logic to save the return address ($PC + 4$) into the Link Register (R14) during branch operations.
* **Indirect Branching (BX):** A custom bypass path to route raw register values directly into the Program Counter, bypassing the barrel shifter for direct address jumps.

## ✅ Verification & Testbench Results
The architecture was verified using an automated Verilog testbench in ModelSim. 

**Final Status:** `CPU IS FULLY OPERATIONAL`
* **Total Passes:** 12 / 12
* **Validated Cases:** Arithmetic/Logic with Shifting, Memory consistency, Conditional branching (BEQ, BNE), and Subroutine calls.

## 💻 Technical Stack
* **Hardware Description Language:** Verilog HDL
* **Simulation & Debugging:** ModelSim
* **Synthesis Tool:** Intel Quartus II
* **Target Hardware:** Intel DE1-SoC (Cyclone V FPGA)
