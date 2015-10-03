`include "full_adder.v"

module alu_common_bits(cout,sum,a,b,cin,cmd);

output sum, cout;
input a, b, cin;

input [3:0] cmd;// The command signal inputs

wire bin;

xor b_logic(bin, b, cmd[1]);

full_adder fa1(cout, sum, a, bin, cin);

endmodule

module alu(result, a, b, cmd);
//TODO: Test the bits all in a line for both adding and sub.

output [15:0] result;
input [15:0] a, b;

//TODO: later just take opcode later
input [3:0] cmd;

wire [15:0] w_carry;

genvar i;
generate
for (i=1; i < 16; i=i+1) begin:alu_common_bitgen
    alu_common_bits b(result[i], w_carry[i], a[i], b[i], win[i-1], cmd);
end
endgenerate

alu_common_bits first(result[0], w_carry[0], a[0], b[0], cmd[1], cmd);

endmodule
