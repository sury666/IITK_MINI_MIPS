module Register_File (
 input wire [4:0] WriteReg , input wire [4:0] Read1 , input wire [4:0] Read2 , input clk , input RegWrite , input wire [31:0] WriteData, output reg [31:0] Data1 , output reg [31:0] Data2, input wire rst );

reg [31:0] RF [31:0];
 

always @(Read1 or Read2) begin
    Data2 = RF[Read2];
    Data1 = RF[Read1];
end
integer i;
always @(posedge clk ) begin
 if(rst) begin
 for (i = 0; i < 32; i = i + 1) begin
 RF[i] = 0;
 end
 end
 else begin
 if(RegWrite) begin
 RF[WriteReg] = WriteData;
 end
 else begin
 RF[WriteReg] = RF[WriteReg];
 end
 end
 end

endmodule