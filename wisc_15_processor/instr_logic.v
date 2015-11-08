module instr_logic(flush, Out_pc, In_pc, Ret_reg, C_imm, B_imm, Cond, z, v, n, branch, call, ret, halt);

output [15:0] Out_pc;
output flush;
input [15:0] In_pc, Ret_reg, C_imm, B_imm;
input [2:0] Cond;
input z, v, n, branch, call, ret, halt;

wire [15:0] branch_adder;
reg [15:0] Out_pc;
reg flush;
assign branch_adder = In_pc + B_imm;

always @ *//(In_pc,Cond,z,v,n,branch,call,ret,halt,B_imm,C_imm,Ret_reg) 
begin
    flush <= 0;
    //Calculate the branch address.
    //$display("b_adder:%d In_pc:%d B_imm:%d zflag:%b", branch_adder, In_pc, B_imm,z);
    if (branch) begin
        //Out_pc <= In_pc + 1; //Fail of b condition means just increment pc.
        case (Cond)
            3'b000: //Not Eq
                if (!z) begin
                    Out_pc <= branch_adder;
                    flush <= 1;
                end
                else
                    Out_pc <= In_pc; //Fail of b condition means just increment pc.
                3'b001: //Eq
                if (z) begin
                    Out_pc <= branch_adder;
                    flush <= 1;
                end
                else
                    Out_pc <= In_pc; //Fail of b condition means just increment pc.
                3'b010: //Greater Than
                if ((n == z) && (!z)) begin
                    Out_pc <= branch_adder;
                    flush <= 1;
                end
                else
                    Out_pc <= In_pc; //Fail of b condition means just increment pc.
                3'b011: //Less than
                if (n) begin
                    Out_pc <= branch_adder;
                    flush <= 1;
                end
                else
                    Out_pc <= In_pc; //Fail of b condition means just increment pc.
                3'b100: //Greather than or eq
                if ( z || ((n == z) && !z)) begin
                    Out_pc <= branch_adder;
                    flush <= 1;
                end
                else
                    Out_pc <= In_pc; //Fail of b condition means just increment pc.
                3'b101: //Lt or Eq
                if (n || z) begin
                    Out_pc <= branch_adder;
                    flush <= 1;
                end
                else
                    Out_pc <= In_pc; //Fail of b condition means just increment pc.
                3'b110: //Overflow
                if (v) begin
                    Out_pc <= branch_adder;
                    flush <= 1;
                end
                else
                    Out_pc <= In_pc; //Fail of b condition means just increment pc.
                3'b111: //Unconditional 
            begin
                Out_pc <= branch_adder;
                flush <= 1;
            end
        endcase
    end
    else if (call) begin
        Out_pc <= In_pc + C_imm;
        flush <= 1;
    end
    else if (ret) begin
        //$display("RETREG%h",Ret_reg);
        Out_pc <= Ret_reg;
        flush <= 1;
    end
    else if (halt)
        Out_pc <= In_pc;
    else
        Out_pc <= In_pc + 1;
    //$display("Out_pc:%h",Out_pc);
end

endmodule
