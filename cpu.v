`include "alu/alu.v"
`include "control.v"
`include "instr_mem.v"
`include "rf_pipelined.v"
`include "instr_logic.v"
`include "data_mem.v"

module cpu(pc, hlt, clk, rst_n);
input clk, rst_n;
output [15:0] pc;
output hlt;

reg z_flag, v_flag, n_flag; 

reg [15:0] pc; //Change to wire.
reg [15:0] addr = 0; //TODO: Mod.
wire [15:0] New_pc; 

reg [15:0] C_imm, B_imm, Inst_imm, Ret_reg;
wire [15:0] instr;


//Sign extenders.
always @(C_imm, B_imm, instr)
begin
    C_imm[15:0] <= {{7{Inst[7]}}, Inst[7:0] } ;//Sign extend values for call.
    B_imm[15:0] <= {{4{Inst[11]}}, Inst[11:0] }; //Sign extend values for branch.
    Inst_imm[15:0] <= {{12{Inst[3]}}, Inst[3:0] }; //Sign extend the 4 bit immediate for input to alu.
end

//TODO: Set Ret_reg.
instr_logic pc_in(New_pc, pc, Ret_reg, C_imm, B_imm, Inst[11:9], z_flag, v_flag, n_flag, branch, call, ret, halt);
//TODO: Take the pc and save on CALL -- Mux the input reg dest, give the pc as data..


//Instruction Memory Stuff
assign rd_en = ~hlt;
IM instruction_mem(clk,addr,rd_en,instr);

//CONTROL UNIT STUFF
wire [3:0] Alu_Cmd;
wire reg_wrt, mem_to_reg, mem_wrt, branch, halt, set_over, set_zero, call, ret, alu_src;
control_unit CU(Alu_Cmd, alu_src, reg_wrt, mem_to_reg, mem_wrt, branch, call, ret, halt, set_over, set_zero, inst[15:12]);

//Register File Stuff
wire [3:0] rf_r1_addr, rf_r2_addr; //Register read inputs.
assign re0 = 1;  assign re1 = 1; //Set both registers to read perminentaly.
wire [15:0] reg_out_1, reg_out_2; //The register outputs.
wire [3:0] rf_dst_addr; //The register write address.
wire [15:0] rf_dst_in; //The register write data.
assign rf_r1_addr = Inst[7:4]; //REGISTER TO READ 1
assign rf_r2_addr = Inst[3:0]; //REGISTER TO READ 2
assign rf_dst_addr = (call) ? 4'hf : Inst[11:8]; //Mux the input of the write destination register.
assign rf_dst_in = (call) ? pc + 1 : wb_data; //Mux the input of wb_data and the pc for call
rf REG_FILE(clk,rf_r1_addr,rf_r2_addr,reg_out_1,reg_out_2,re0,re1,rf_dst_addr,rf_dst_in,reg_wrt,hlt);

assign B_in_alu = (alu_src) ? Inst_imm : reg_out_2;//Mux the alu_src imm and register_rd

//ALU STUFF
wire [15:0] Alu_result;
wire alu_v, alu_n, alu_z;
wire [15:0] A_in_alu, B_in_alu; 
alu ALU(Alu_result, alu_v, alu_n, alu_z, A_in_alu, B_in_alu, Alu_Cmd);
assign mem_addr = Alu_result;



//DATA MEMORY STUFF
wire [15:0] mem_addr, mem_wrt_data , wb_data, mem_rd_data;
wire re, we; 
assign we = mem_wrt;
assign re =  ~we;
assign mem_wrt_data = reg_out_2;
DM Data_Mem(clk,mem_addr,re,we, mem_wrt_data,mem_rd_data);
assign wb_data = (mem_to_reg) ? mem_rd_data : Alu_result;//Mux the outputs of Data memory and the alu for wb to reg file

always @ (rst_n, posedge clk) 
    begin
        pc <= New_pc;
        //Set the flags (if signaled)
        if (set_zero)
            z_flag <= alu_z;
        if (set_over) begin
            v_flag <= alu_v;
            n_flag <= alu_n;
        end
        if (rst_n)
            pc <= 0;
    end

endmodule
