module processor_top(clk,rst,instr,instr_addr, data, data_addr, ins_we,data_we,processor_out,done);

input clk,rst;
input [31:0] instr,data;
input [9:0] instr_addr,data_addr;
input ins_we,data_we;
output [31:0] processor_out;
output done;

// Wires and registers
wire [31:0] PC_out,ins_out,data_write;
reg [31:0] PC_in;
reg [9:0] data_write_addr; reg [9:0] data_read_addr;
wire mem_we;
wire [3:0] ALU_Control;
wire [1:0] ALUSrc;
wire branch,MemtoReg,MemWrite,done,RegWrite;
wire [1:0] RegDsT;
wire [4:0] Read1, Read2;
reg [4:0] WriteReg;
wire [31:0] WriteData, Data1,Data2;
wire [31:0] Input1toALU;
reg [31:0] Input2toALU;
wire [31:0] shamt;
wire [31:0] ALU_out,hi,low;
wire eq_true;
wire [31:0] immidiate;
wire [31:0] WB_data;
wire [31:0] branch_addr;
wire [31:0] temp_addr;
reg [31:0] jump_addr; 
wire jump;

// Floating-point related signals
wire FP_op, FP_RegWrite, mtc1, mfc1;
wire [31:0] FP_Data1, FP_Data2, FP_WriteData;
wire [31:0] converted_bin, converted_float;
wire [31:0] FPU_out;
wire fp_cc;  // Floating point condition code

// Connection from control module to PC module
assign done = jump || (branch && eq_true);  

// Calculate next sequential instruction address
assign temp_addr = PC_out + 1;

// Instantiate Program Counter
PC program_counter(clk,rst,done,PC_in,PC_out);

// Instantiate Instruction Memory
memory ins_mem (
  .a(instr_addr),        
  .d(instr),             
  .dpra(PC_out[9:0]),    
  .clk(clk),             
  .we(ins_we),           
  .dpo(ins_out)          
);

// Instantiate Control Unit with floating point support
control con(ins_out[31:26],ins_out[5:0],ALU_Control,RegDsT,branch,MemtoReg,MemWrite,ALUSrc,RegWrite,jump,done,FP_op,FP_RegWrite,mtc1,mfc1);

// Register file inputs
assign Read1 = ins_out[25:21]; // rs
assign Read2 = ins_out[20:16]; // rt

// Destination register selection
always@(*)
begin
    if(RegDsT == 2'b10)      // For JAL instruction (RegDsT=2)
        WriteReg = 5'd31;    // Register $ra (31)
    else if(RegDsT == 2'b01) // For R-type instructions
        WriteReg = ins_out[15:11]; // rd
    else
        WriteReg = ins_out[20:16]; // rt, for I-type instructions
end 

// MFC1: Move from Coprocessor 1 handling
wire [31:0] WriteData_mfc1;
assign WriteData_mfc1 = mfc1 ? converted_bin : WriteData;

// Determine data to write to register file
assign WriteData = (RegDsT == 2'b10) ? (PC_out + 1) : WB_data;

// Instantiate Register File
Register_File regs(Read1, Read2, WriteReg, WriteData_mfc1, RegWrite, Data1, Data2, rst, clk);

// Instantiate Floating Point Register File
FP_Register_File fp_regs(
    ins_out[15:11],             // Floating point destination register (fd)
    ins_out[25:21],             // Floating point source register 1 (fs)
    ins_out[20:16],             // Floating point source register 2 (ft)
    clk,
    FP_RegWrite,
    mtc1 ? converted_float : FPU_out,  // Data source selection
    FP_Data1,                   // Output from fs
    FP_Data2,                   // Output from ft
    rst
);

// Conversion modules for MFC1/MTC1
Floating_point_to_Binary fptb(.floating_input(FP_Data2), .bin_output(converted_bin));
Binary_to_FloatingPoint btfp(.bin_input(Data2), .floating_output(converted_float));

// ALU inputs
assign Input1toALU = Data1;
assign immidiate = {{16{ins_out[15]}}, ins_out[15:0]};  // Sign extend immediate
assign shamt = {27'h0, ins_out[10:6]};                 // Shift amount

// Select ALU's second input
always@(*)
begin
    case(ALUSrc)
        2'b00: Input2toALU = Data2;           // Use register value
        2'b01: Input2toALU = immidiate;       // Use immediate value
        2'b10: Input2toALU = shamt;           // Use shift amount
        default: Input2toALU = Data2;
    endcase
end

// Instantiate ALU
ALU alu(Input1toALU,Input2toALU,ALUSrc,ALU_Control,ALU_out,eq_true,hi,low);

// Instantiate FPU
FPU fpu(
    FP_Data1,                // First FP operand
    FP_Data2,                // Second FP operand
    FPU_out,                 // FPU result
    ins_out[31:26],          // Opcode
    fp_cc                    // Condition code
);

// Memory address selection
always@(*)
begin
    if(done)
        data_read_addr = data_addr;
    else 
        data_read_addr = ALU_out[9:0];
end

always@(*)
begin
    if(rst)
        data_write_addr = data_addr;
    else 
        data_write_addr = ALU_out[9:0];
end

// Data to write to memory
assign data_write = (rst == 1) ? data : Data2;
assign mem_we = (rst == 1) ? data_we : MemWrite;

// Instantiate Data Memory
memory data_mem (
  .a(data_write_addr),      
  .d(data_write),           
  .dpra(data_read_addr),    
  .clk(clk),                
  .we(mem_we),              
  .dpo(processor_out)       
);

// Write-back data selection
assign WB_data = (MemtoReg) ? processor_out : ALU_out;

// Branch target address calculation
assign branch_addr = PC_out + 1 + immidiate;

// Jump target address calculation
always@(*)
begin
    if(ins_out[31:26] == 6'b000000 && ins_out[5:0] == 6'b001000) // jr instruction
        jump_addr = Data1;  // Jump to address in rs
    else
        jump_addr = {temp_addr[31:26], ins_out[25:0]};  // J, JAL format
end

// Next PC value selection
always@(*)
begin
    if(branch == 1 && eq_true == 1)
        PC_in = branch_addr;  // Branch taken
    else if(jump == 1)
        PC_in = jump_addr;    // Jump
    else
        PC_in = PC_out + 1;   // Sequential
end

endmodule
