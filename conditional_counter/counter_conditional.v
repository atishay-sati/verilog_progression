`timescale 1ns / 1ps

module counter_conditional(e, r, clk, q);
input e, r, clk;
output reg [3:0] q;

initial begin
    q = 4'b0000;
end

always @(posedge clk) begin
    if (r)                 //reset takes priority if BOTH r = 1 and e = 1
        q <= 4'b0000;
     else if (e)           //if our e is 1 we add 1 to counter
        q <= q + 1'b1;
end
endmodule
