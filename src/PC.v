module PC (clk,rst,done,PC_in,PC_out);
    input clk,rst,done;
    input reg [31:0] PC_in;
    output wire [31:0] PC_out;

    reg [31:0] PC_Value; // Program Counter Register to hold the current value of PC

    always@(posedge clk or posedge rst)
    begin
        if(rst)
            PC_Value<=0;
        else if(done) // In case of jump or branch, load the new PC value
            PC_Value<=PC_in;
        else
            PC_Value<=PC_Value+1; // We are using word level instruction storing(One location in memory is 32 bit wide)
    end

    assign PC_out=PC_Value;
endmodule