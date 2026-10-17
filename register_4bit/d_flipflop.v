`timescale 1ns / 1ps

module d_flipflop(d, clk, q);
input d, clk;
output reg q;

always @(posedge clk) begin
    q <= d;
end

endmodule
