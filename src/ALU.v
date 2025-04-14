module ALU (Input1toALU,Input2toALU, ALUSrc,ALU_Control,ALU_out,eq_true,hi,low);
input [31:0] Input1toALU;    // First input to ALU
input [31:0] Input2toALU;    // Second input to ALU
input [1:0] ALUSrc;          // ALU source control signal
input [3:0] ALU_Control;     // ALU control signal
output reg [31:0] ALU_out;   // ALU output
output reg eq_true;          // Equality check output
output reg [31:0] hi;        // High output for multiplication
output reg [31:0] low;       // Low output for multiplication

reg [63:0] mul_result;       // Temporary variable for multiplication result

always@(*)
begin
    // Set eq_true based on comparison results for branch instructions
    case (ALU_Control)
        8: eq_true = ($signed(Input1toALU) != $signed(Input2toALU)); // bne
        9: eq_true = ($signed(Input1toALU) == $signed(Input2toALU)); // beq
        10: eq_true = ($signed(Input1toALU) < $signed(Input2toALU));  // slti, ble
        11: eq_true = ($signed(Input1toALU) <= $signed(Input2toALU)); // bleq
        12: eq_true = ($signed(Input1toALU) > $signed(Input2toALU));  // bgt
        13: eq_true = ($signed(Input1toALU) >= $signed(Input2toALU)); // bgte
        default: eq_true = 0;
    endcase

    case (ALU_Control)
        0: ALU_out = $signed(Input1toALU) + $signed(Input2toALU); // add
        1: ALU_out = Input1toALU + Input2toALU;                   // addu
        2: ALU_out = $signed(Input1toALU) - $signed(Input2toALU); // sub
        3: ALU_out = Input1toALU - Input2toALU;                   // subu
        4: ALU_out = Input1toALU & Input2toALU;                   // and
        5: ALU_out = Input1toALU | Input2toALU;                   // or
        6: ALU_out = ~Input1toALU;                                // not
        7: ALU_out = Input1toALU ^ Input2toALU;                   // xor
        8: begin                                                  // bne, set not equal
            ALU_out = ($signed(Input1toALU) != $signed(Input2toALU));
        end
        9: begin                                                  // beq, set equal
            ALU_out = ($signed(Input1toALU) == $signed(Input2toALU));
        end
        10: begin                                                 // slti, ble, set less than
            ALU_out = ($signed(Input1toALU) < $signed(Input2toALU)); 
        end
        11: begin                                                 // bleq, set less than equal
            ALU_out = ($signed(Input1toALU) <= $signed(Input2toALU));
        end
        12: begin                                                 // bgt, set greater than
            ALU_out = ($signed(Input1toALU) > $signed(Input2toALU));
        end
        13: begin                                                 // bgte, set greater than equal
            ALU_out = ($signed(Input1toALU) >= $signed(Input2toALU));
        end
        14: ALU_out = Input2toALU << 16;                         // lui
        
        // Multiplication operations
        15: begin                                                // mul
            mul_result = Input1toALU * Input2toALU;
            {hi, low} = mul_result;
            ALU_out = low;
        end
        16: begin                                                // madd
            mul_result = $signed(Input1toALU) * $signed(Input2toALU);
            {hi, low} = {hi, low} + mul_result;
            ALU_out = low;
        end
        
        default: ALU_out = 32'bx;                                // Undefined operation
    endcase
end

endmodule