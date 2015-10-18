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

module alu(Result, v, n, z, A, B, Alu_ctrl);
output [15:0] Result;
output v,n,z;
input [15:0] A, B;
input [3:0] Alu_ctrl;

wire [15:0] Add_out, Shift_out, Nand_out, Xor_out;

shifter calc_shift_out(Shift_out, Alu_ctrl[1:0], A, B[3:0]);
au calc_add_out(Add_out, v, n, cout, Alu_ctrl[1:0], A, B);
assign Nand_out = ~(A & B);
assign Xor_out = A ^ B;

//Function Muxes the inputs of the various alu devices (adder,nand,xor,shifter)
assign Result = Mux_15b_4t1(Add_out, Nand_out, Xor_out, Shift_out, Alu_ctrl[3:2]);
assign z = ~(|A);

function [15:0] Mux_15b_4t1;
    input [15:0] Add_out, Nand_out, Xor_out, Shift_out;
    input [1:0] Sel;

    begin
    case (Sel) 
        2'b00: 
            //Take adder output
            Mux_15b_4t1= Add_out;
        2'b01: 
            //Take Nand output
            Mux_15b_4t1= Nand_out;
        2'b10: 
            //Take Xor Output
            Mux_15b_4t1= Xor_out;
        2'b11: 
            //Take Shift Output
            Mux_15b_4t1= Shift_out;
        endcase
    end
endfunction


endmodule
