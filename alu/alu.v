//Logic to detect z flag activation.
module zero_detect(z, S);
output z;
input [15:0] S;
assign z = |S;
endmodule

module alu(Result, A, B, Cmd);
output [15:0] Result;
input [15:0] A, B;
input [7:0] Cmd; //First two bits are for the mux deciding which op to transmit
wire [15:0] Add_out, Shift_out, Nand_out, Xor_out;

shifter calc_shift_out(Shift_out, Cmd[3:0], A, B);
au calc_add_out(Add_out, v, n,cout, Cmd[3:0], A, B);
assign Nand_out = ~(A & B);
assign Xor_out = A ^ B;

//Function Muxes the inputs of the various alu devices (adder,nand,xor,shifter)
assign Result = Mux_15b_4t1(Add_out, Nand_out, Xor_out, Shift_out, Cmd[7:6]);
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
