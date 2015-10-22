module instr_logic(Out_pc, In_pc, Ret_reg, C_imm, B_imm, Cond, z, v, n, branch, call, ret, halt);

output [15:0] Out_pc;
input [15:0] In_pc, Ret_reg, C_imm, B_imm;
input [2:0] Cond;
input z, v, n, branch, call, ret, halt;

reg [15:0] branch_adder;
reg [15:0] Out_pc;

always @ (In_pc, Out_pc, Cond,z,v,n,branch) 
    begin
        //Calculate the branch address.
        branch_adder <= In_pc + 1 + B_imm;
        if (branch) begin
            case (Cond)
                3'b000: //Not Eq
                    if (!z)
                        Out_pc <= branch_adder;
                3'b001: //Eq
                    if (z)
                        Out_pc <= branch_adder;
                3'b010: //Greater Than
                    if ((n == z) && (!z))
                        Out_pc <= branch_adder;
                3'b011: //Less than
                    if (n)
                        Out_pc <= branch_adder;
                3'b100: //Greather than or eq
                    if ( z || ((n == z) && !z))
                        Out_pc <= branch_adder;
                3'b101: //Lt or Eq
                    if (n || z)
                        Out_pc <= branch_adder;
                3'b110: //Overflow
                    if (v)
                        Out_pc <= branch_adder;
                3'b111: //Unconditional
                    Out_pc <= branch_adder;
            endcase
        end
        else if (call)
            Out_pc <= In_pc + 1 + C_imm;
        else if (ret)
            Out_pc <= Ret_reg;
        else if (halt)
            Out_pc <= In_pc;
        else
            Out_pc <= In_pc + 1;
    end

endmodule
