module hd(mem_wb_dst, mem_wb_wrt, ex_mem_wb_dst, ex_mem_wrt, id_ex_wb_dst, id_ex_wrt, id_rd_reg1, id_rd_reg2, stall);
input mem_wb_wrt, ex_mem_wrt, id_ex_wrt;
input [3:0] mem_wb_dst, ex_mem_wb_dst, id_ex_wb_dst, id_rd_reg1, id_rd_reg2;

output stall;
reg stall;

always @(mem_wb_dst, mem_wb_wrt, ex_mem_wb_dst, ex_mem_wrt, id_ex_wb_dst, id_ex_wrt, id_rd_reg1, id_rd_reg2) begin
    if (mem_wb_wrt)
        stall <= 1;
    else if (ex_mem_wrt)
        stall <= 1;
    else if (id_ex_wrt)
        stall <= 1;
    else
        stall <= 0;
end

endmodule
