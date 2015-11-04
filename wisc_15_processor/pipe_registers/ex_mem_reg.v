module mem_ex_reg(clk, rst_n, clear, i_mem_to_reg, i_wb_dst, i_alu_result, i_mem_wrt, i_mem_wrt_data, i_mem_read, o_mem_to_reg, o_wb_dst, o_alu_result, o_mem_wrt, o_mem_wrt_data, o_mem_read);

input clk, rst_n, clear, i_mem_to_reg, i_mem_wrt, i_mem_read;
input [15:0] i_alu_result, i_mem_wrt_data;
input [3:0] i_wb_dst;

output o_mem_to_reg, o_mem_wrt, o_mem_read;
output [15:0] o_alu_result, o_mem_wrt_data;
output [3:0] o_wb_dst;

reg o_mem_to_reg, o_mem_wrt, o_mem_read;
reg [15:0] o_alu_result, o_mem_wrt_data;
reg [3:0] o_wb_dst;

always @(posedge clk, rst_n) begin
	if (!rst_n || (clk && clear)) begin
		o_mem_to_reg <= 0;
		o_mem_wrt <= 0;
		o_mem_read <= 0;
		o_alu_result <= 0;
		o_mem_wrt_data <= 0;
		o_wb_dst <= 0;
	end
	else if (clk) begin
		o_mem_to_reg <= i_mem_to_reg;
		o_mem_wrt <= i_mem_wrt ;
		o_mem_read <= i_mem_read ;
		o_alu_result <= i_alu_result ;
		o_mem_wrt_data <= i_mem_wrt_data ;
		o_wb_dst <= i_wb_dst ;
	end

end

endmodule
