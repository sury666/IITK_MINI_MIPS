`timescale 1ns / 1ps

module integer_testbench;

reg clk, rst;
reg [31:0] instr, data;
reg [9:0] instr_addr, data_addr;
reg ins_we, data_we;
wire [31:0] processor_out;
wire done;

// Instantiate the processor
processor_top uut(
    .clk(clk),
    .rst(rst),
    .instr(instr),
    .instr_addr(instr_addr),
    .data(data),
    .data_addr(data_addr),
    .ins_we(ins_we),
    .data_we(data_we),
    .processor_out(processor_out),
    .done(done)
);

// Clock generation
always #5 clk = ~clk;

// Test sequence
initial begin
    // Initialize
    clk = 0;
    rst = 1;
    instr = 0;
    data = 0;
    instr_addr = 0;
    data_addr = 0;
    ins_we = 0;
    data_we = 0;
    
    #10;
    rst = 0;
    
    // Load initial values into registers for testing
    
    // Set $1 = 10 (addi $1, $0, 10) - opcode 000001
    instr = 32'b00000100000000010000000000001010;
    instr_addr = 0;
    ins_we = 1;
    #10;
    
    // Set $2 = 20 (addi $2, $0, 20) - opcode 000001
    instr = 32'b00000100000000100000000000010100;
    instr_addr = 1;
    ins_we = 1;
    #10;
    
    // Test add - Integer addition (R-type, opcode 000000, funct 000000)
    // add $3, $1, $2 - $3 = $1 + $2 = 10 + 20 = 30
    instr = 32'b00000000001000100001100000000000;
    instr_addr = 2;
    ins_we = 1;
    #10;
    
    // Test addi - Integer addition immediate (opcode 000001)
    // addi $4, $3, 5 - $4 = $3 + 5 = 30 + 5 = 35
    instr = 32'b00000100011001000000000000000101;
    instr_addr = 3;
    ins_we = 1;
    #10;
    
    // Test sub - Integer subtraction (R-type, opcode 000000, funct 000010)
    // sub $5, $3, $1 - $5 = $3 - $1 = 30 - 10 = 20
    instr = 32'b00000000011000010010100000000010;
    instr_addr = 4;
    ins_we = 1;
    #10;
    
    // Test mul - Integer multiplication (R-type, opcode 000000, funct 001100)
    // mul $6, $1, $2 - $6 = $1 * $2 = 10 * 20 = 200
    instr = 32'b00000000001000100011000000001100;
    instr_addr = 5;
    ins_we = 1;
    #10;
    
    // Test and - Bitwise AND (R-type, opcode 000000, funct 000100)
    // and $7, $1, $3 - $7 = $1 & $3 = 10 & 30 = 10
    instr = 32'b00000000001000110011100000000100;
    instr_addr = 6;
    ins_we = 1;
    #10;
    
    // Test or - Bitwise OR (R-type, opcode 000000, funct 000101)
    // or $8, $1, $3 - $8 = $1 | $3 = 10 | 30 = 30
    instr = 32'b00000000001000110100000000000101;
    instr_addr = 7;
    ins_we = 1;
    #10;
    
    // Test xor - Bitwise XOR (R-type, opcode 000000, funct 000111)
    // xor $9, $1, $3 - $9 = $1 ^ $3 = 10 ^ 30 = 20
    instr = 32'b00000000001000110100100000000111;
    instr_addr = 8;
    ins_we = 1;
    #10;
    
    // Test slti - Set if Less Than Immediate (opcode 000111)
    // slti $10, $1, 15 - $10 = ($1 < 15) = (10 < 15) = 1
    instr = 32'b00011100001010100000000000001111;
    instr_addr = 9;
    ins_we = 1;
    #10;
    
    // Test beq - Branch if Equal (opcode 001011)
    // beq $1, $2, 2 - Branch if $1 = $2 (should not branch)
    instr = 32'b00101100001000100000000000000010;
    instr_addr = 10;
    ins_we = 1;
    #10;
    
    // Test bne - Branch if Not Equal (opcode 001100)
    // bne $1, $2, 2 - Branch if $1 != $2 (should branch)
    instr = 32'b00110000001000100000000000000010;
    instr_addr = 11;
    ins_we = 1;
    #10;
    
    // Set up memory for load/store tests
    // Store value 42 at memory address 100
    data = 42;
    data_addr = 100;
    data_we = 1;
    #10;
    data_we = 0;
    
    // Test sw - Store Word (opcode 001010)
    // sw $3, 0($0) - Store $3 (30) at address 0
    instr = 32'b00101000000000110000000000000000;
    instr_addr = 12;
    ins_we = 1;
    #10;
    
    // Test lw - Load Word (opcode 001001)
    // lw $11, 0($0) - Load value at address 0 (30) into $11
    instr = 32'b00100100000010110000000000000000;
    instr_addr = 13;
    ins_we = 1;
    #10;
    
    // Test lui - Load Upper Immediate (opcode 000110)
    // lui $12, 0xFF - Load 0xFF shifted left by 16 bits into $12
    instr = 32'b00011000000011000000000011111111;
    instr_addr = 14;
    ins_we = 1;
    #10;
    
    // Clear instruction write enable
    ins_we = 0;
    
    // Run the processor
    #200;
    
    $finish;
end

// Display results
initial begin
    $monitor("Time=%0t | PC=%0d | Instr=%h | OutRegs=%h | Done=%b",
             $time, uut.PC_out, uut.ins_out, processor_out, done);
    
    // Use $display to print register values at the end
    #300;
    $display("\n==== REGISTER VALUES ====");
    $display("$1 = %d", uut.regs.RF[1]);
    $display("$2 = %d", uut.regs.RF[2]);
    $display("$3 = %d", uut.regs.RF[3]);
    $display("$4 = %d", uut.regs.RF[4]);
    $display("$5 = %d", uut.regs.RF[5]);
    $display("$6 = %d", uut.regs.RF[6]);
    $display("$7 = %d", uut.regs.RF[7]);
    $display("$8 = %d", uut.regs.RF[8]);
    $display("$9 = %d", uut.regs.RF[9]);
    $display("$10 = %d", uut.regs.RF[10]);
    $display("$11 = %d", uut.regs.RF[11]);
    $display("$12 = %h", uut.regs.RF[12]);
    
    $display("\n==== MEMORY VALUES ====");
    $display("Memory[0] = %d", uut.data_mem.mem[0]);
    $display("Memory[100] = %d", uut.data_mem.mem[100]);
end

endmodule