module FP_Register_File (
    input wire [4:0] WriteReg, 
    input wire [4:0] Read1, 
    input wire [4:0] Read2, 
    input clk, 
    input FP_RegWrite, 
    input wire [31:0] WriteData, 
    output reg [31:0] Data1, 
    output reg [31:0] Data2, 
    input wire rst
);

reg [31:0] FP_RF [31:0];  // 32 floating-point registers

always @(Read1 or Read2) begin
    Data2 = FP_RF[Read2];
    Data1 = FP_RF[Read1];
end

integer i;
always @(posedge clk) begin
    if(rst) begin
        for (i = 0; i < 32; i = i + 1) begin
            FP_RF[i] = 0;
        end
    end
    else begin
        if(FP_RegWrite) begin
            FP_RF[WriteReg] = WriteData;
        end
    end
end

endmodule