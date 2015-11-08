module instr_logic(do_branch, Cond, z_flag, v_flag, n_flag);

output do_branch;
input [2:0] Cond;
input z_flag, v_flag, n_flag;
reg do_branch;


always @ *//(Cond, z_flag, v_flag, n_flag)
begin
    do_branch = 0;
        case (Cond)
            3'b000: //Not Eq 
            begin
                    if (!z_flag) do_branch = 1;

                end
                    //else do_branch = 0;
            3'b001: //Eq
                    if (z_flag) do_branch = 1;
                    //else do_branch = 0;
            3'b010: //Greater Than
                    if ((n_flag == z_flag) && (!z_flag)) do_branch = 1;
                    //else do_branch = 0;
            3'b011: //Less than
                    if (n_flag) do_branch = 1;
                    //else do_branch = 0;
            3'b100: //Greather than or eq
                    if ( z_flag || ((n_flag == z_flag) && !z_flag)) do_branch = 1;
                    //else do_branch = 0;
            3'b101: //Lt or Eq
                    if (n_flag || z_flag) do_branch = 1;
                    //else do_branch = 0;
            3'b110: //Overflow
                    if (v_flag) do_branch = 1;
                    //else do_branch = 0;
            3'b111: //Unconditional 
                do_branch = 1;
        endcase
end

endmodule
