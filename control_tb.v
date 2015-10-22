`include "control.v"

module control_unit_tb();

reg [4:0] Inst;
wire [3:0] Alu_Cmd;

control_unit iDUT(Alu_Cmd, alu_src, reg_wrt, mem_to_reg, mem_wrt, branch, call, ret, halt, set_over, set_zero, Inst[3:0]);

initial begin
    for (Inst = 0; Inst < 5'h10; Inst = Inst +1) begin
#1
    case(Inst)
        4'b0000: //ADD
        begin
            if (!reg_wrt || mem_wrt || mem_to_reg || branch || halt || !set_zero || !set_over || call || ret || alu_src)
                $display("Bad control sig in add");
            else if (Alu_Cmd[3:0] != 4'b0000)
                $display("Bad alu sig in add alu:%b", Alu_Cmd);
        end
        4'b0001: //Paddsb
        begin
            if (!reg_wrt || mem_wrt || mem_to_reg || branch || halt || set_zero || set_over || call || ret || alu_src)
                $display("Bad control sig in padd");
            else if (Alu_Cmd[3:0] != 4'b0010)
                $display("Bad alu sig in padd alu:%b", Alu_Cmd);
        end
        4'b0010: //sub
        begin
            if (!reg_wrt || mem_wrt || mem_to_reg || branch || halt || !set_zero || !set_over || call || ret || alu_src)
                $display("Bad control sig in sub");
            else if (Alu_Cmd[3:0] != 4'b0001)
                $display("Bad alu sig in sub alu:%b", Alu_Cmd);
        end
        4'b0011: //nand
        begin
            if (!reg_wrt || mem_wrt || mem_to_reg || branch || halt || !set_zero || set_over || call || ret || alu_src)
                $display("Bad control sig in nand");
            else if (Alu_Cmd[3:0] != 4'b10xx)
                $display("Bad alu sig in nand alu:%b", Alu_Cmd);
        end
        4'b0100: //xor
        begin
            if (!reg_wrt || mem_wrt || mem_to_reg || branch || halt || !set_zero || set_over || call || ret || alu_src)
                $display("Bad control sig in xor");
            else if (Alu_Cmd[3:0] != 4'b01xx)
                $display("Bad alu sig in xor alu:%b", Alu_Cmd);
        end
        4'b0101: //sll
        begin
            if (!reg_wrt || mem_wrt || mem_to_reg || branch || halt || !set_zero || set_over || call || ret || !alu_src)
                $display("Bad control sig in sll");
            else if (Alu_Cmd[3:0] != 4'b110x)
                $display("Bad alu sig in sll alu:%b", Alu_Cmd);
        end
        4'b0110: //srl
        begin
            if (!reg_wrt || mem_wrt || mem_to_reg || branch || halt || !set_zero || set_over || call || ret || !alu_src)
                $display("Bad control sig in srl");
            else if (Alu_Cmd[3:0] != 4'b1110)
                $display("Bad alu sig in srl alu:%b", Alu_Cmd);
        end
        4'b0111: //sra
        begin
            if (!reg_wrt || mem_wrt || mem_to_reg || branch || halt || !set_zero || set_over || call || ret || !alu_src)
                $display("Bad control sig in sra");
            else if (Alu_Cmd[3:0] != 4'b1111)
                $display("Bad alu sig in sra alu:%b", Alu_Cmd);
        end
        4'b1000: //lw
        begin
            if (!reg_wrt || mem_wrt || !mem_to_reg || branch || halt || set_zero || set_over || call || ret || !alu_src)
                $display("Bad control sig in lw");
            else if (Alu_Cmd[3:0] != 4'b0000)
                $display("Bad alu sig in lwalu:%b", Alu_Cmd);
        end
        4'b1001: //sw
        begin
            if (reg_wrt || !mem_wrt || branch || halt || set_zero || set_over || call || ret || !alu_src)
                $display("Bad control sig in sw");
            else if (Alu_Cmd[3:0] != 4'b0000)
                $display("Bad alu sig in swalu:%b", Alu_Cmd);
        end
        //4'b1010: //lhb
        //begin
        //    if (!reg_wrt || mem_wrt || mem_to_reg || branch || halt || set_zero || set_over || call || ret || alu_src)
        //        $display("Bad control sig in add");
        //    else if (Alu_Cmd[3:0] != 4'b0000)
        //        $display("Bad alu sig in add alu:%b", Alu_Cmd);
        //end
        //4'b1011: //llb
        //begin
        //    if (!reg_wrt || mem_wrt || mem_to_reg || branch || halt || set_zero || set_over || call || ret || alu_src)
        //        $display("Bad control sig in add");
        //    else if (Alu_Cmd[3:0] != 4'b0000)
        //        $display("Bad alu sig in add alu:%b", Alu_Cmd);
        //end
        4'b1100: //b
        begin
            if (reg_wrt || mem_wrt || !branch || halt || set_zero || set_over || call || ret )
                $display("Bad control sig in b");
        end
        4'b1101: //call
        begin
            if (!reg_wrt || mem_wrt || mem_to_reg || branch || halt || set_zero || set_over || !call || ret )
                $display("Bad control sig in call");
        end
        4'b1110: //ret
        begin
            if (reg_wrt || mem_wrt || branch || halt || set_zero || set_over || call || !ret )
                $display("Bad control sig in ret");
        end
        4'b1111: //hlt
        begin
            if (reg_wrt || mem_wrt || branch || !halt || set_zero || set_over || call || ret )
                $display("Bad control sig in hlt");
        end
    endcase
end
end

endmodule
