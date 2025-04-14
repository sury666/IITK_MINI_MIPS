module memory (
    input [9:0] a,         // write address
    input [31:0] d,        // data input
    input [9:0] dpra,      // read address
    input clk,             // clock
    input we,              // write enable
    output reg [31:0] dpo  // data output
);

reg [31:0] mem [1023:0];   // 1K memory, 32-bit wide

always @(posedge clk) begin
    if (we)
        mem[a] <= d;
end

always @(*) begin
    dpo = mem[dpra];
end

endmodule