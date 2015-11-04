
module mem_wb_reg(clk, rst_n, clear, i_mem_to_reg, i_wb_dst, i_mem_data, i_alu_result, o_mem_to_reg, o_wb_dst, o_mem_data, o_alu_result);

output o_mem_to_reg;
output [15:0] o_mem_data, o_alu_result;
output [3:0] o_wb_dst;

input clk, rst_n, clear, i_mem_to_reg;
input [15:0] i_mem_data, i_alu_result;
input [3:0] i_wb_dst;

reg [15:0] o_mem_data, o_alu_result;
reg [3:0] o_wb_dst;
reg o_mem_to_reg;
wire [15:0] i_mem_data, i_alu_result;
wire [3:0] i_wb_dst;

always @(posedge clk, rst_n) begin
    if (!clear && rst_n) begin
        o_mem_to_reg <= i_mem_to_reg; 
        o_wb_dst <= i_wb_dst;
        o_mem_data <= i_mem_data;
        o_alu_result <= i_alu_result;
    end
    else begin
        o_mem_to_reg <= 0; 
        o_wb_dst <= 0;
        o_mem_data <= 0;
        o_alu_result <= 0;
    end
end

endmodule
