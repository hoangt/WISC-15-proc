module hd(mem_wb_dst, mem_wb_wrt, ex_mem_wb_dst, ex_mem_wrt, id_ex_wb_dst, id_ex_wrt, id_rd_reg1, id_rd_reg2, /*id_lhb, id_llb,*/ stall);
//input clk, rst_n;
//input id_llb, id_lhb; 
input mem_wb_wrt, ex_mem_wrt, id_ex_wrt;
input [3:0] mem_wb_dst, ex_mem_wb_dst, id_ex_wb_dst, id_rd_reg1, id_rd_reg2;

output stall;
reg stall;

//TODO: Don't stall for llb
always @ (mem_wb_dst, mem_wb_wrt, ex_mem_wb_dst, ex_mem_wrt, id_ex_wb_dst, id_ex_wrt, id_rd_reg1, id_rd_reg2/*, id_lhb, id_llb*/) begin

    //DON'T halt for branch/call
    //else if(llb)
    //    stall <= 0;
    if (mem_wb_wrt && ((mem_wb_dst == id_rd_reg1) || (mem_wb_dst == id_rd_reg2)) && (mem_wb_dst != 0)) begin
        stall <= 1;
    end
    else if (ex_mem_wrt && ((ex_mem_wb_dst == id_rd_reg1) || (ex_mem_wb_dst == id_rd_reg2)) && (ex_mem_wb_dst != 0))
        stall <= 1;
    else if (id_ex_wrt && ((id_ex_wb_dst == id_rd_reg1) || (id_ex_wb_dst == id_rd_reg2)) && (id_ex_wb_dst != 0))
        stall <= 1;
    else begin
        stall <= 0;
    end
end

endmodule
