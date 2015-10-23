`include "instr_logic.v"

module im_logic_tb();
reg branch, call, ret, halt;
reg z, v, n;
reg [3:0] Cond;
reg [15:0] Ret, B_imm, C_imm, pc;
wire [15:0] New_pc;

instr_logic iDUT(New_pc, pc, Ret, C_imm, B_imm, Cond[2:0], z,v,n, branch, call, ret, halt);

initial begin
    B_imm <= 10;
    C_imm <= 20;
    Ret <= 30;
    pc <= 5;
    #1

    branch <= 0;
    call <=0;
    ret <= 0; 
    halt <= 0;
    z <= 0;
    v <= 0;
    n <= 1;
#1
    //// CHECK BRANCHING CONDITIONS
    //for (Cond = 0; Cond <= 4'h7; Cond = Cond+1) begin
    //    #1
    //    case (Cond)
    //            3'b000: //Not Eq
    //                if (!z)
    //                    if (New_pc != B_imm + pc + 1)
    //                        $display("ERROR in cond branch");
    //            3'b001: //Eq
    //                if (z) 
    //                    if (New_pc != B_imm + pc + 1)
    //                        $display("ERROR in cond branch");
    //            3'b010: //Greater Than
    //                if ((n == z) && (!z))
    //                    if (New_pc != B_imm + pc + 1)
    //                        $display("ERROR in cond branch");
    //            3'b011: //Less than
    //                if (n) 
    //                    if (New_pc != B_imm + pc + 1)
    //                        $display("ERROR in cond branch");
    //            3'b100: //Greather than or eq
    //                if ( z || ((n == z) && !z))
    //                    if (New_pc != B_imm + pc + 1)
    //                        $display("ERROR in cond branch");
    //            3'b101: //Lt or Eq
    //                if (n || z)
    //                    if (New_pc != B_imm + pc + 1)
    //                        $display("ERROR in cond branch");
    //            3'b110: //Overflow
    //                if (v) 
    //                    if (New_pc != B_imm + pc + 1)
    //                        $display("ERROR in cond branch");
    //            3'b111: //Unconditional
    //                if (New_pc != B_imm + pc + 1)
    //                    $display("ERROR in cond branch");
    //    endcase
    //end

        // Check correctness of pc for call, ret, halt, norm
        if (call) begin
            if (New_pc != pc + 1 + C_imm)
                $display("ERROR in call");
        end
        else if (ret) begin
            if (New_pc != Ret)
                $display("ERROR in ret");
        end
        else if (halt) begin
            if (New_pc != pc)
                $display("ERROR in halt");
        end
        else if (!halt && !ret && !call && !branch) begin
            if (New_pc != pc+1)
                $display("ERROR in normal pc inc");
        end

    

end

endmodule
