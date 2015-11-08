module hd(clk, rst_n, branch, call, mem_wb_dst, mem_wb_wrt, ex_mem_wb_dst, ex_mem_wrt, id_ex_wb_dst, id_ex_wrt, id_rd_reg1, id_rd_reg2, stall);
input clk, rst_n;
input branch, call, mem_wb_wrt, ex_mem_wrt, id_ex_wrt;
input [3:0] mem_wb_dst, ex_mem_wb_dst, id_ex_wb_dst, id_rd_reg1, id_rd_reg2;

reg branch_ff;

output stall;
reg stall;

//TODO:Stall the branch for one cycle to get the flags from current ex phase.
//always @(posedge clk, negedge rst_n) begin
//    if (!rst_n)
//        branch_ff = 0;
//    else if (clk && branch)
//        branch_ff <= ~branch_ff;
//end

always @(mem_wb_dst, mem_wb_wrt, ex_mem_wb_dst, ex_mem_wrt, id_ex_wb_dst, id_ex_wrt, id_rd_reg1, id_rd_reg2) begin

    //DON'T halt for branch/call
    if (branch || call)
        stall <= 0;
                                                                                    //ignore nops
    else if (mem_wb_wrt && ((mem_wb_dst == id_rd_reg1) || (mem_wb_dst == id_rd_reg2)) && (mem_wb_dst != 0))
        stall <= 1;
    else if (ex_mem_wrt && ((ex_mem_wb_dst == id_rd_reg1) || (ex_mem_wb_dst == id_rd_reg2)) && (ex_mem_wb_dst != 0))
        stall <= 1;
    else if (id_ex_wrt && ((id_ex_wb_dst == id_rd_reg1) || (id_ex_wb_dst == id_rd_reg2)) && (id_ex_wb_dst != 0))
        stall <= 1;
    //else if (branch_ff)
    //    stall <= 1;
    else
        stall <= 0;
end

endmodule
