`timescale 1ns / 1ps

module fp_testbench;

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
    
    // Test mtc1 - Move value to FP register (opcode = 6'b011001)
    // mtc1 $2, $f4 - Move from integer register $2 to floating point register $f4
    instr = 32'b01100100010001000000000000000000;
    instr_addr = 0;
    ins_we = 1;
    #10;
    
    // Test mfc1 - Move value from FP register (opcode = 6'b011000)
    // mfc1 $3, $f4 - Move from floating point register $f4 to integer register $3
    instr = 32'b01100000011001000000000000000000;
    instr_addr = 1;
    ins_we = 1;
    #10;
    
    // Test add.s - Floating point addition (opcode = 6'b011010)
    // add.s $f6, $f4, $f5 - $f6 = $f4 + $f5
    instr = 32'b01101000100001010011000000000000;
    instr_addr = 2;
    ins_we = 1;
    #10;
    
    // Test sub.s - Floating point subtraction (opcode = 6'b011011)
    // sub.s $f7, $f4, $f5 - $f7 = $f4 - $f5
    instr = 32'b01101100100001010011100000000000;
    instr_addr = 3;
    ins_we = 1;
    #10;
    
    // Test c.eq.s - Compare equal (opcode = 6'b011100)
    // c.eq.s $f4, $f5 - Compare $f4 = $f5
    instr = 32'b01110000100001010000000000000000;
    instr_addr = 4;
    ins_we = 1;
    #10;
    
    // Clear instruction write enable
    ins_we = 0;
    
    // Run the processor
    #100;
    
    $finish;
end

// Display results
initial begin
    $monitor("Time=%0t | PC=%0d | Instr=%h | OutRegs=%h | Done=%b",
             $time, uut.PC_out, uut.ins_out, processor_out, done);
end

endmodule