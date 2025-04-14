module control(opcode, funct, ALU_Control, RegDsT, branch, MemtoReg, MemWrite, ALUSrc, RegWrite, jump, done, FP_op, FP_RegWrite, mtc1, mfc1);

input [5:0] opcode;
input [5:0] funct;

output reg [3:0] ALU_Control;
output reg [1:0] RegDsT;
output reg branch;
output reg MemtoReg;
output reg MemWrite; 
output reg [1:0] ALUSrc;
output reg RegWrite;
output reg jump;
output reg done;
output reg FP_op;       // Signal for floating point operation
output reg FP_RegWrite; // Write to floating point register file
output reg mtc1;        // Move to Coprocessor 1
output reg mfc1;        // Move from Coprocessor 1

always@(opcode or funct)
begin
    // Default values
    RegDsT = 0;
    branch = 0;
    MemtoReg = 0;
    MemWrite = 0;
    ALUSrc = 0;
    RegWrite = 0;
    jump = 0;
    done = 0;
    FP_op = 0;
    FP_RegWrite = 0;
    mtc1 = 0;
    mfc1 = 0;

    if(opcode == 6'b000000) begin // R-type instructions
        case(funct)
            6'b000000: ALU_Control = 4'd0;  // add
            6'b000001: ALU_Control = 4'd1;  // addu
            6'b000010: ALU_Control = 4'd2;  // sub
            6'b000011: ALU_Control = 4'd3;  // subu
            6'b000100: ALU_Control = 4'd4;  // and
            6'b000101: ALU_Control = 4'd5;  // or
            6'b000110: ALU_Control = 4'd6;  // not
            6'b000111: ALU_Control = 4'd7;  // xor
            6'b001000: begin                // jr - jump register
                ALU_Control = 4'd0;         // ALU not used
                jump = 1;
                done = 1;
            end
            6'b001100: begin                // mul
                ALU_Control = 4'd15;
            end
            6'b001101: begin                // madd
                ALU_Control = 4'd16;
            end
            default: ALU_Control = 4'd0;
        endcase
        
        // Common settings for most R-type instructions
        if(funct != 6'b001000) begin  // For all except jr
            RegDsT = 1;     // Use rd as destination
            RegWrite = 1;   // Write to register file
        end
    end
    
    // I-type instructions
    else if(opcode == 6'b000001) begin // addi
        ALU_Control = 4'd0;  // add
        RegDsT = 0;       // Use rt as destination
        ALUSrc = 2'b01;   // Use immediate for 2nd ALU input
        RegWrite = 1;
    end
    else if(opcode == 6'b000010) begin // addiu
        ALU_Control = 4'd1;  // addu
        RegDsT = 0;
        ALUSrc = 2'b01;
        RegWrite = 1;
    end
    else if(opcode == 6'b000011) begin // andi
        ALU_Control = 4'd4;  // and
        RegDsT = 0;
        ALUSrc = 2'b01;
        RegWrite = 1;
    end
    else if(opcode == 6'b000100) begin // ori
        ALU_Control = 4'd5;  // or
        RegDsT = 0;
        ALUSrc = 2'b01;
        RegWrite = 1;
    end
    else if(opcode == 6'b000101) begin // xori
        ALU_Control = 4'd7;  // xor
        RegDsT = 0;
        ALUSrc = 2'b01;
        RegWrite = 1;
    end
    else if(opcode == 6'b000110) begin // lui - Load Upper Immediate
        ALU_Control = 4'd14; // Shift left by 16
        RegDsT = 0;
        ALUSrc = 2'b01;
        RegWrite = 1;
    end
    else if(opcode == 6'b000111) begin // slti - Set Less Than Immediate
        ALU_Control = 4'd10; // Set less than
        RegDsT = 0;
        ALUSrc = 2'b01;
        RegWrite = 1;
    end
    else if(opcode == 6'b001000) begin // seq - Set Equal
        ALU_Control = 4'd9;  // Set equal 
        RegDsT = 0;
        ALUSrc = 2'b01;
        RegWrite = 1;
    end
    else if(opcode == 6'b001001) begin // lw - Load Word
        ALU_Control = 4'd0;  // add (address calculation)
        RegDsT = 0;
        ALUSrc = 2'b01;
        MemtoReg = 1;     // Memory data -> register
        RegWrite = 1;
    end
    else if(opcode == 6'b001010) begin // sw - Store Word
        ALU_Control = 4'd0;  // add (address calculation)
        ALUSrc = 2'b01;
        MemWrite = 1;     // Write to memory
    end
    
    // Branch instructions
    else if(opcode == 6'b001011) begin // beq - Branch if Equal
        ALU_Control = 4'd9;  // Set equal to check condition
        branch = 1;       // Enable branch
    end
    else if(opcode == 6'b001100) begin // bne - Branch if Not Equal
        ALU_Control = 4'd8;  // Set not equal
        branch = 1;
    end
    else if(opcode == 6'b001101) begin // bgt - Branch if Greater Than
        ALU_Control = 4'd12; // Set greater than
        branch = 1;
    end
    else if(opcode == 6'b001110) begin // bgte - Branch if Greater Than or Equal
        ALU_Control = 4'd13; // Set greater than or equal
        branch = 1;
    end
    else if(opcode == 6'b001111) begin // ble - Branch if Less Than
        ALU_Control = 4'd10; // Set less than
        branch = 1;
    end
    else if(opcode == 6'b010000) begin // bleq - Branch if Less Than or Equal
        ALU_Control = 4'd11; // Set less than or equal
        branch = 1;
    end
    
    // Jump instructions
    else if(opcode == 6'b010001) begin // j - Jump
        ALU_Control = 4'd0;  // ALU not used
        jump = 1;
        done = 1;
    end
    else if(opcode == 6'b010010) begin // jal - Jump and Link
        ALU_Control = 4'd0;  // ALU not used
        RegDsT = 2'b10;      // Use register $31 (ra) as destination
        RegWrite = 1;        // Write return address
        jump = 1;
        done = 1;
    end
    
    // Floating point instructions
    else if(opcode == 6'b011000) begin // mfc1 - Move From Coprocessor 1
        ALU_Control = 4'd0;  // Not used
        RegDsT = 0;
        RegWrite = 1;        // Write to integer register
        mfc1 = 1;            // Move from FP register
    end
    else if(opcode == 6'b011001) begin // mtc1 - Move To Coprocessor 1
        ALU_Control = 4'd0;  // Not used
        mtc1 = 1;            // Move to FP register
        FP_RegWrite = 1;     // Enable writing to FP register file
    end
    else if(opcode == 6'b011010) begin // add.s - Floating Point Add
        FP_op = 1;
        FP_RegWrite = 1;
    end
    else if(opcode == 6'b011011) begin // sub.s - Floating Point Subtract
        FP_op = 1;
        FP_RegWrite = 1;
    end
    else if(opcode == 6'b011100) begin // c.eq.s - Floating Point Compare Equal
        FP_op = 1;
    end
    else if(opcode == 6'b011101) begin // c.le.s - Floating Point Compare Less or Equal
        FP_op = 1;
    end
    else if(opcode == 6'b011110) begin // c.lt.s - Floating Point Compare Less Than
        FP_op = 1;
    end
    else if(opcode == 6'b011111) begin // c.ge.s - Floating Point Compare Greater or Equal
        FP_op = 1;
    end
    else if(opcode == 6'b100000) begin // c.gt.s - Floating Point Compare Greater Than
        FP_op = 1;
    end
    else if(opcode == 6'b100001) begin // mov.s - Move Floating Point
        FP_op = 1;
        FP_RegWrite = 1;
    end
    
    // Default for unimplemented instructions
    else begin
        ALU_Control = 4'd0;
    end
end

endmodule