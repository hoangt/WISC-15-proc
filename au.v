`include "full_adder.v"

/*
* List of Modules within alu.v:;
* alu_common_bits
*
* overflow_detect
*
* negative_detect
*
* zero_detect
*
* vl(v_low, v_high, Sum, A, B) - find overflow in upper and lower halves
*
* au - Outputs the results for add, sub, and padd (results are already corrected for overflow), Also can be easily modified to
* output overflow and negative flag.
*/

/* THE LOGIC FOR ALL BITS OF THE ALU*/
module alu_common_bits(cout,sum,a,b,cin,c_b1);
output sum, cout;
input a, b, cin;
input c_b1;// The subtract command signal

wire bin;
xor bin_logic(bin, b, c_b1);
full_adder fa1(cout, sum, a, bin, cin);
endmodule

//Logic to detect v flag activation.
module overflow_detect(v, a, b, sum);
output v;
input a, b, sum;

assign v = (~a & ~b & sum) | (a & b & ~sum);
endmodule

//Logic to detect n flag activation
module negative_detect(n, v, s, c);
output n;
input v,s,c; //v is overflow from this clk cyc, s is sum from last bit, c is carry from last bit 

assign n = (~v & s) | (v & c);
endmodule

//Logic to detect z flag activation.
module zero_detect(z, S);
output z;
input [15:0] S;

assign z = |S;
endmodule

module vl(v_low, v_high, Sum, A, B);
output v_low, v_high; //Output the overflow in the lower and upper half (just use upper non padd)
input [15:0] Sum, A, B;

overflow_detect detect_low(.v(v_low), .a(A[7]), .b(B[7]), .sum(Sum[7]));
overflow_detect detect_high(.v(v_high), .a(A[15]), .b(B[15]), .sum(Sum[15]));
endmodule


//Module that computes sums, subs and padds.
module au( Result, cout, Cmd, A, B);
output [15:0] Result;
output cout; //The Carry from the last bit.
input [3:0] Cmd;
input [15:0] A, B;
wire [15:0] w_carry;
wire [15:0] Sum;
wire v_low, v_high;

assign cout = w_carry[15];

/********       Begin Generation of the RCA         ******/
//Create the first bit in the first half of the RCA
alu_common_bits rca_b0(w_carry[0], Sum[0], A[0], B[0], Cmd[1], Cmd[1]);

//Generate the First half of the RCA.
genvar i;
generate
for (i=1; i <= 7; i=i+1) begin:au_lower_bitgen
    alu_common_bits rca_b1_b7(w_carry[i], Sum[i], A[i], B[i], w_carry[i-1], Cmd[1]);
end
endgenerate

//Create the first bit in the second half of the RCA (needs to be different so we don't carry from first half in the case of
//padd
alu_common_bits rca_b8(w_carry[8], Sum[8], A[8], B[8], w_carry[7] & ~Cmd[3], Cmd[1]);

//Generate the second half of the RCA.
generate
for (i=9; i <= 15; i=i+1) begin:au_upper_bitgen
    alu_common_bits rca_b1_b7(w_carry[i], Sum[i], A[i], B[i], w_carry[i-1], Cmd[1]);
end
endgenerate
/******         End Generation of RCA           **********/

//Process for overflow from both upper and lower.
//TODO: ENABLE
vl check_overflow(v_low,v_high,Sum,A,B);
assign low_v_use = ((v_low & Cmd[3]) | (v_high & ~Cmd[3]));

//TESTING PURPOSES
//assign Result = 16'h0000;
//assign Result[0] = Sum[0];
//assign Result[0] = 1'hf;
//assign Result[15:1] = 15'hffff;
//assign Result = Sum;

//TODO/BUG: Fix v_high. and v_low detection.
//assign low_v_use = 0;

//overflow_detect v_h_d(v_high, A[15], B[15], Sum[15]);
//assign v_high = 0;

//TODO: Based on overflow output the final sum.
//Output for the lower bits
assign Result[6:0] = ~low_v_use ? Sum[6:0] : ~Cmd[1]; //TODO: May be a bug here since CMD is only a single bit wire going to bus
assign Result[7] = ~low_v_use ? Sum[7] : ~(Cmd[3]|Cmd[1]);    //Output either the sum or in overflow only a 1 if not padd and is not sub
//Output for the upper bits
assign Result[14:8] = ~v_high ? Sum[14:8] : ~Cmd[1];
assign Result[15] = ~v_high ? Sum[15] : Cmd[1];

endmodule
