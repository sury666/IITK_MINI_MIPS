# IITK Mini MIPS Processor

This repository contains the implementation of a Mini MIPS processor developed as part of the Computer Architecture CS220 course at IIT Kanpur.

## Overview

The Mini MIPS processor is a simplified MIPS architecture implementation with a subset of instructions. This project includes:

- A complete processor implementation in Verilog
- Test programs and testbenches
- Documentation of the architecture and design

## Architecture

The Mini MIPS processor supports the following components:

- 5-stage pipeline (IF, ID, EX, MEM, WB)
- Register file with 32 registers
- ALU supporting basic arithmetic and logical operations
- Data memory and instruction memory
- Control unit with hazard detection

## Instruction Set

The processor supports the following MIPS instructions:

### R-type Instructions:

- Arithmetic: ADD, ADDU, SUB, SUBU, MUL, MADD
- Logical: AND, OR, NOT, XOR
- Jump: JR (Jump Register)

### I-type Instructions:

- Arithmetic: ADDI, ADDIU, SLTI, SEQ
- Logical: ANDI, ORI, XORI
- Memory: LW (Load Word), SW (Store Word)
- Special: LUI (Load Upper Immediate)

### Branch Instructions:

- BEQ (Branch if Equal)
- BNE (Branch if Not Equal)
- BLE (Branch if Less Than)
- BLEQ (Branch if Less Than or Equal)
- BGT (Branch if Greater Than)
- BGTE (Branch if Greater Than or Equal)
- BLEU (Branch if Less Than or Equal Unsigned)
- BGTU (Branch if Greater Than Unsigned)

### Jump Instructions:

- J (Jump)
- JAL (Jump and Link)

### Floating Point Instructions:

- Data Movement: MFC1, MTC1, MOV.S
- Arithmetic: ADD.S, SUB.S
- Comparison: C.EQ.S, C.LE.S, C.LT.S, C.GE.S, C.GT.S

## Directory Structure

- `/src`: Contains the Verilog source code for the processor
- `/testbench`: Contains test cases and verification files

## Usage

To simulate the processor:

1. Load the project in a Verilog simulator (ModelSim, Icarus Verilog, Vivado etc.)
2. Run the testbench file to verify functionality
3. Use provided test programs to verify correct operation

## Implementation Details

The processor is implemented with pipeline stages, forwarding logic, and hazard detection to handle data and control hazards. The design follows the classic MIPS pipeline architecture while incorporating specific requirements from the assignment.

## Contributors

* [**Aritra Ambudh Dutta**](https://github.com/AritraAmbudhDutta)
* [**Suryansh Verma**](https://github.com/sury666)

## Acknowledgements

This project was completed as part of the Computer Architecture (CS220) course at IIT Kanpur under [Prof. Debapriya Basu Roy](https://dbroy24.wixsite.com/research).
