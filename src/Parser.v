module Instruction_Parse (
 input wire [31:0] instruction, output wire [4:0] rt , output wire [4:0] rs , output wire [4:0] rd ,
 output wire [5:0] func , output wire [4:0] shamt , output wire [5:0] opcode , output wire [15:0] address,
 output wire [25:0] jump_addr
);
 assign opcode = instruction[31:26];
 assign rs = instruction[25:21];
 assign rt = instruction[20:16];
 assign rd = instruction[15:11];
 assign shamt = instruction[10:6];
 assign func = instruction[5:0];
 assign addr = instruction[15:0];
 assign jump_addr = instruction[25:0];

endmodule