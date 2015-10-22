
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

module vl(v_low, v_high, Sum, A, B, sub);
output v_low, v_high; //Output the overflow in the lower and upper half (just use upper non padd)
input [15:0] Sum, A, B;
input sub;

overflow_detect detect_low(.v(v_low), .a(A[7]), .b(B[7]), .sum(Sum[7]));
// In subtraction, B15 is flipped.
overflow_detect detect_high(.v(v_high), .a(A[15]), .b(B[15]^sub), .sum(Sum[15]));
endmodule

//Module that computes sums, subs and padds.
module au( Result, v, n, cout, Ctrl, A, B);
output [15:0] Result;
output cout; //The Carry from the last bit.
output v, n;
input [1:0] Ctrl;
input [15:0] A, B;
wire [15:0] w_carry;
wire [15:0] Sum;
wire v_low, v_high;

assign sub = Ctrl[0];
assign padd = Ctrl[1];

assign cout = w_carry[15];

/********       Begin Generation of the RCA         ******/
//Create the first bit in the first half of the RCA
alu_common_bits rca_b0(w_carry[0], Sum[0], A[0], B[0], sub, sub);
alu_common_bits rca_b1(w_carry[1], Sum[1], A[1], B[1], w_carry[0], sub);
alu_common_bits rca_b2(w_carry[2], Sum[2], A[2], B[2], w_carry[1], sub);
alu_common_bits rca_b3(w_carry[3], Sum[3], A[3], B[3], w_carry[2], sub);
alu_common_bits rca_b4(w_carry[4], Sum[4], A[4], B[4], w_carry[3], sub);
alu_common_bits rca_b5(w_carry[5], Sum[5], A[5], B[5], w_carry[4], sub);
alu_common_bits rca_b6(w_carry[6], Sum[6], A[6], B[6], w_carry[5], sub);
alu_common_bits rca_b7(w_carry[7], Sum[7], A[7], B[7], w_carry[6], sub);

//Generate the First half of the RCA.
genvar i;
//generate
//for (i=1; i <= 7; i=i+1) begin:au_lower_bitgen
//    alu_common_bits rca_b1_b7(w_carry[i], Sum[i], A[i], B[i], w_carry[i-1], sub);
//end
//endgenerate

//Create the first bit in the second half of the RCA (needs to be different so we don't carry from first half in the case of
//padd
alu_common_bits rca_b8(w_carry[8], Sum[8], A[8], B[8], w_carry[7] & (~padd), sub);

//Generate the second half of the RCA.
alu_common_bits rca_b9(w_carry[9], Sum[9], A[9], B[9], w_carry[8], sub);
alu_common_bits rca_b10(w_carry[10], Sum[10], A[10], B[10], w_carry[9], sub);
alu_common_bits rca_b11(w_carry[11], Sum[11], A[11], B[11], w_carry[10], sub);
alu_common_bits rca_b12(w_carry[12], Sum[12], A[12], B[12], w_carry[11], sub);
alu_common_bits rca_b13(w_carry[13], Sum[13], A[13], B[13], w_carry[12], sub);
alu_common_bits rca_b14(w_carry[14], Sum[14], A[14], B[14], w_carry[13], sub);
alu_common_bits rca_b15(w_carry[15], Sum[15], A[15], B[15], w_carry[14], sub);


//generate
//for (i=9; i <= 15; i=i+1) begin:au_upper_bitgen
//    alu_common_bits rca_b9_b15(w_carry[i], Sum[i], A[i], B[i], w_carry[i-1], sub);
//end
//endgenerate
/******         End Generation of RCA           **********/

//Process for overflow from both upper and lower.
vl check_overflow(v_low,v_high,Sum,A,B,sub);
assign low_v_use = ((v_low & padd) | (v_high & ~padd));

//Logic for detecting if negative.
assign n_high = (~v_high & Sum[15]) | (v_high & w_carry[15]);
//Logic for lower bits (Mark negative if bottom is neg and paddsb, else default to n_high)
assign n_low = (((~v_low & Sum[7]) | (v_low & w_carry[7])) & padd) | (~padd & n_high);

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


//assign Result = Sum;

// Based on overflow output the final sum.
//Output for the lower bits
for (i = 0; i<= 6; i= i+ 1) begin
    assign Result[i] = ~low_v_use ? Sum[i] : ~n_low; 
end

assign Result[7] = ~low_v_use ? Sum[7] : (n_low & padd) | (~n_low & ~padd);
//Output for the upper bits
for (i = 8; i<= 14; i= i+ 1) begin
    assign Result[i] = (~low_v_use) ? Sum[i] : ~n_high; 
end
assign Result[15] = (~v_high) ? Sum[15] : n_high;  

assign v = v_high;
assign n = n_high;

endmodule
