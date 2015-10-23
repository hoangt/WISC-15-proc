/*
*   Contained code is for the shifting unit in the ALU which can
*   SLL, SRA, SRL
*
* */
module shifter(Result,Ctrl,A,Imm);
output [15:0] Result;
input [15:0] A;
input [3:0] Imm;
input [1:0] Ctrl;
wire [15:0] Right_out, Left_out;

shift_ll get_left_shift(Left_out, A, Imm);
shift_r get_right_shifts(Right_out, A, Imm, Ctrl[0]);

//Mux the output of the shifters 
assign Result = (Ctrl[1]) ? Right_out : Left_out;

endmodule

module shift_ll(Result,A,Imm);
output [15:0] Result;
input [15:0] A;
input [3:0] Imm;
wire [15:0] Inter_1, Inter_2, Inter_3;

//Generate the shift by 1
genvar i;
assign Inter_1[0] = Imm[0] ? 0 : A[0];
for (i=1; i <= 15; i=i+1)
    assign Inter_1[i] = Imm[0] ? A[i-1] : A[i];

//Generate the shift by 2
for (i=0; i <= 1; i=i+1)
    assign Inter_2[i] = Imm[1] ? 0 : Inter_1[i];
for (i=2; i <= 15; i=i+1)
    assign Inter_2[i] = Imm[1] ? Inter_1[i-2] : Inter_1[i];

//Generate the shift by 4
for (i=0; i <= 3; i=i+1)
    assign Inter_3[i] = Imm[2] ? 0 : Inter_2[i];
for (i=4; i <= 15; i=i+1)
    assign Inter_3[i] = Imm[2] ? Inter_2[i-4] : Inter_2[i];

//Generate the shift by 8
for (i=0; i <= 7; i=i+1)
    assign Result[i] = Imm[3] ? 0 : Inter_3[i];
for (i=8; i <= 15; i=i+1)
    assign Result[i] = Imm[3] ? Inter_3[i-8] : Inter_3[i];

endmodule

module shift_r(Result, A, Imm, a_nl); //a_nl means arithmetic not logical
output [15:0] Result;
input [15:0] A;
input [3:0] Imm;
input a_nl;
wire [15:0] Inter_1, Inter_2, Inter_3;
wire aug_A, aug_1, aug_2, aug_3;
genvar i;


//Calculate what the shift bits should be (0 if l, 1 if a and top bit is 1)
assign aug_A = A[15] & a_nl;
//Generate the shift r by 1
assign Inter_1[15] = Imm[0] ? aug_A : A[15];
for (i=0; i <= 14; i=i+1)
    assign Inter_1[i] = Imm[0] ? A[i+1] : A[i];

//Generate the shift r by 2
for (i=14; i <= 15; i=i+1)
    assign Inter_2[i] = Imm[1] ? aug_A: Inter_1[i];
for (i=0; i <= 13; i=i+1)
    assign Inter_2[i] = Imm[1] ? Inter_1[i+2] : Inter_1[i];

//Generate the shift r by 4
for (i=12; i <= 15; i=i+1)
    assign Inter_3[i] = Imm[2] ? aug_A: Inter_2[i];
for (i=0; i <= 11; i=i+1)
    assign Inter_3[i] = Imm[2] ? Inter_2[i+4] : Inter_2[i];


//Generate the shift r by 8
for (i=8; i <= 15; i=i+1)
    assign Result[i] = Imm[3] ? aug_A: Inter_3[i];
for (i=0; i <= 7; i=i+1)
    assign Result[i] = Imm[3] ? Inter_3[i+8] : Inter_3[i];

endmodule
