module Floating_point_to_Binary (
    input [31:0] floating_input, 
    output [31:0] bin_output
);
    assign bin_output = floating_input;  // Simple pass-through for now
endmodule

module Binary_to_FloatingPoint (
    input [31:0] bin_input, 
    output [31:0] floating_output
);
    assign floating_output = bin_input;  // Simple pass-through for now
endmodule

module bit_inverser (
    input invert, 
    input [31:0] inp, 
    output [31:0] out
);
    assign out = (invert) ? inp ^ 32'h80000000 : inp;
endmodule

module floating_adder (
    input wire [31:0] inp1, 
    input [31:0] inp2, 
    output reg[31:0] out
);
    // Implementation as provided in your code
    reg signa, signb;
    reg [7:0] exponenta, exponentb;
    reg [7:0] diff;
    reg [24:0] ruffa, ruffb;
    reg [24:0] ans;
    reg [24:0] manta, mantb;
    
    always @(inp1 or inp2) begin
        signa = inp1[31]; signb = inp2[31];
        exponenta = inp1[30:23]; exponentb = inp2[30:23];
        manta = {2'b1, inp1[22:0]}; mantb = {2'b1, inp2[22:0]};
        
        // Same sign addition
        if(signa == signb) begin
            if(exponenta > exponentb) begin
                diff = exponenta - exponentb;
                ruffb = mantb >> diff;
                ans = ruffb + manta;
                if(ans[24] == 1) begin
                    ans = ans >> 1;
                    exponenta = exponenta + 1;
                end
                out = {signa, exponenta, ans[22:0]};
            end
            else begin
                diff = exponentb - exponenta;
                ruffa = manta >> diff;
                ans = ruffa + mantb;
                if(ans[24] == 1) begin
                    ans = ans >> 1;
                    exponentb = exponentb + 1;
                end
                out = {signb, exponentb, ans[22:0]};
            end
        end
        // Different sign (subtraction)
        else begin
            // Rest of your implementation for subtraction
            if(inp1[30:0] > inp2[30:0]) begin
                // Your existing code for this case
                diff = exponenta - exponentb;
                ruffb = mantb >> diff;
                manta = manta - ruffb;
                
                // Normalize the result
                if(manta[22] == 1) begin
                    exponenta = exponenta - 1;
                    manta = manta << 1;
                end 
                // Rest of normalization cases...
                
                out = {signa, exponenta, manta[22:0]};
            end
            else begin
                // Your existing code for this case
                diff = exponentb - exponenta;
                ruffb = manta >> diff;
                manta = mantb - ruffb;
                exponenta = exponentb;
                
                // Normalize the result
                if(manta[22] == 1) begin
                    exponenta = exponenta - 1;
                    manta = manta << 1;
                end 
                // Rest of normalization cases...
                
                out = {signb, exponenta, manta[22:0]};
            }
        end
    end
endmodule

// Floating Point Unit
module FPU (
    input wire [31:0] inp1, 
    input wire [31:0] inp2, 
    output reg [31:0] FPUout,
    input wire [5:0] opcode,
    output reg cc  // Condition code for branch decisions
);
    wire [31:0] Adder_cout;
    wire invert;
    assign invert = (opcode == 6'b100011);  // sub.s
    wire [31:0] inp2_intoALU;
    bit_inverser bt(.invert(invert), .inp(inp2), .out(inp2_intoALU));
    floating_adder fa(.inp1(inp1), .inp2(inp2_intoALU), .out(Adder_cout));
    
    always @(inp1 or inp2 or opcode or Adder_cout) begin
        cc = 0;  // Default condition code
        case (opcode)
            6'b100010: FPUout = Adder_cout; // add.s
            6'b100011: FPUout = Adder_cout; // sub.s
            6'b100100: cc = (inp1 == inp2); // c.eq.s
            6'b100101: cc = (inp1 <= inp2); // c.le.s
            6'b100110: cc = (inp1 < inp2);  // c.lt.s
            6'b100111: cc = (inp1 >= inp2); // c.ge.s
            6'b101000: cc = (inp1 > inp2);  // c.gt.s
            6'b101001: FPUout = inp1;       // mov.s
            default: FPUout = 32'b0;        // Default case
        endcase
    end
endmodule