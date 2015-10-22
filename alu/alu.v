`include "alu/shifter.v"
`include "alu/au.v"
`include "alu/full_adder.v"

/*
    * Control Signals as follows:
    * 00xx => Take AU Output
    * 01xx => Take NAND Ouput
    * 10xx => Take XOR Output
    * 11xx => Take Shifter Output
    *
    * xxx1 => Sub or Arithmetic Shift
    * 00 => ADD
    * 10 => PADDSB
    * ax => a => SRL, ~a => SRA
    * 
    * */

module alu(Result, v, n, z, A, B, Alu_ctrl, llb, lhb);
output [15:0] Result;
output v,n,z;
input [15:0] A, B;
input [3:0] Alu_ctrl;
input llb, lhb;

//reg [15:0] Result;
wire [15:0] Add_out, Shift_out, Nand_out, Xor_out;

shifter calc_shift_out(Shift_out, Alu_ctrl[1:0], A, B[3:0]);
au calc_add_out(Add_out, v, n, cout, Alu_ctrl[1:0], A, B);
assign Nand_out = ~(A & B);
assign Xor_out = A ^ B;

//Function Muxes the inputs of the various alu devices (adder,nand,xor,shifter)
assign Result = Mux_15b_4t1(Add_out, Nand_out, Xor_out, Shift_out, A, B, Alu_ctrl[3:2], llb, lhb);
assign z = ~(|A);
//assign Result = Add_out;//Add_out;
function [15:0] Mux_15b_4t1;
    input [15:0] Add_out, Nand_out, Xor_out, Shift_out, A, B;
    input [1:0] Sel;
    input llb;
    input lhb;

    begin
        if (llb)
            Mux_15b_4t1 = B;
        else if (lhb)
            Mux_15b_4t1 = {A[15:8], B[7:0]}; 
        else begin
    case (Sel) 
        2'b00: 
            //Take adder output
            Mux_15b_4t1 = Add_out;
        2'b01: 
            //Take Nand output
            Mux_15b_4t1 = Nand_out;
        2'b10: 
            //Take Xor Output
            Mux_15b_4t1 = Xor_out;
        2'b11: 
            //Take Shift Output
            Mux_15b_4t1 = Shift_out;
        endcase
    end
    end
endfunction

//always @ (Result, A, B, Alu_ctrl)
//begin
//    case (Alu_ctrl[3:2]) 
//        2'b00: 
//            //Take adder output
//            Result <= Add_out;
//        2'b01: 
//            //Take Nand output
//            Result <= Nand_out;
//        2'b10: 
//            //Take Xor Output
//            Result <= Xor_out;
//        2'b11: 
//            //Take Shift Output
//            Result <= Shift_out;
//        endcase
//end

endmodule
