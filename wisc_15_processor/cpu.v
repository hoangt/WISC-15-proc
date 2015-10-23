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

assign hlt = halt;
reg z_flag, v_flag, n_flag; 

reg [15:0] pc; 
initial pc = 0;

wire [15:0] New_pc; 

reg [15:0] C_imm, B_imm, Inst_imm, Lb_imm;
reg [15:0] call_pc;
wire [15:0] instr, Ret_reg, Imm;


//Sign extenders.
always @(C_imm, B_imm, instr, Lb_imm)
begin
    C_imm[15:0] <= {{4{instr[11]}},instr[11:0] } ;//Sign extend values for call.
    B_imm[15:0] <= {{7{instr[8]}},instr[8:0] }; //Sign extend values for branch.
    Inst_imm[15:0] <= {{12{instr[3]}},instr[3:0] }; //Sign extend the 4 bit immediate for input to alu.
    Lb_imm[15:0] <= {{8{instr[7]}}, instr[7:0]}; //Sign extend the 8 bit immediate for input to the alu on lhb llb.
    call_pc <= pc + 1; //Used to store the temp pc, for some reason pc is updated before registers.
end


//Instruction Memory Stuff
//Address Calculation.
assign Ret_reg = reg_out_1; //Grab the input for return addr as reading rs register.
instr_logic pc_calc(New_pc, pc, Ret_reg, C_imm, B_imm,instr[11:9], z_flag, v_flag, n_flag, branch, call, ret, halt);

assign rd_en =1;// ~hlt;
IM instruction_mem(clk,pc,rd_en,instr);

//CONTROL UNIT STUFF
wire [3:0] Alu_Cmd;
wire reg_wrt, mem_to_reg, mem_wrt, branch, halt, set_over, set_zero, call, ret, alu_src, llb, lhb;
control_unit control(Alu_Cmd, alu_src, reg_wrt, mem_to_reg, mem_wrt, branch, call, ret, halt, set_over, set_zero,llb,lhb, instr[15:12]);

//Register File Stuff
wire [3:0] rf_r1_addr, rf_r2_addr; //Register read inputs.
assign re0 = 1;  assign re1 = 1; //Set both registers to read perminentaly.
wire [15:0] reg_out_1, reg_out_2; //The register outputs.
wire [3:0] rf_dst_addr; //The register write address.
wire [15:0] rf_dst_in; //The register write data.
wire [3:0] bypass;
assign rf_r1_addr = (lhb) ? instr [11:8] : instr[7:4]; //REGISTER TO READ 1 in lhb use rd as src.
assign rf_r2_addr = (mem_wrt) ? instr[11:8] : instr[3:0]; //REGISTER TO READ 2
assign rf_dst_addr = (call) ? 4'hf : instr[11:8]; //Mux the input of the write destination register.
assign rf_dst_in = (call) ? call_pc : wb_data; //Mux the input of wb_data and the pc for call
rf REG_FILE(clk,rf_r1_addr,rf_r2_addr,reg_out_1,reg_out_2,re0,re1,rf_dst_addr,rf_dst_in,reg_wrt,hlt);

assign Imm = (lhb|llb) ? Lb_imm: Inst_imm; //Mux the lb immediate and normal inst immediate for input to alu.
assign B_in_alu = (alu_src) ? Imm: reg_out_2;//Mux the alu_src imm and register_rd
assign A_in_alu = reg_out_1;

//ALU STUFF
wire [15:0] Alu_result;
wire alu_v, alu_n, alu_z;
wire [15:0] A_in_alu, B_in_alu; 
alu ALU(Alu_result, alu_v, alu_n, alu_z, A_in_alu, B_in_alu, Alu_Cmd, llb, lhb);
assign mem_addr = Alu_result;



//DATA MEMORY STUFF
wire [15:0] mem_addr, mem_wrt_data , wb_data, mem_rd_data;
wire re, we; 
assign we = mem_wrt;
assign re =  ~we;
assign mem_wrt_data = reg_out_2;
DM Data_Mem(clk,mem_addr,re,we, mem_wrt_data,mem_rd_data);
assign wb_data = (mem_to_reg) ? mem_rd_data : Alu_result;//Mux the outputs of Data memory and the alu for wb to reg file

//always @ (rst_n, clk) 
//begin
//    if (clk) 
//    begin
//        pc <= New_pc;
//        //$display("pc: in cpu %d", pc);
//
//        //Set the flags (if signaled)
//            if (set_zero)
//                z_flag <= alu_z;
//            if (set_over) 
//            begin
//                v_flag <= alu_v;
//                n_flag <= alu_n;
//            end
//    end
//        if (~rst_n)
//            pc <= 0;
//end
always @ (rst_n, posedge clk) 
begin
            if (!rst_n)
                pc <= 0;
            else
                pc <= New_pc;
            //if(pc >= 16'h001A)
            //    $finish();
            //$display("New_pc:%h", branch);
end

always @ (posedge clk)
begin
    //TEST CALL
    //if(call)
    //    $display("rf_dst_in:%h rf_dst_addr:%h reg_wrt:%b",rf_dst_in,rf_dst_addr, reg_wrt);
    //if (ret)
    //    $display("rf_r1_addr:%h rf_dst_addr:%h reg_wrt:%b",rf_r1_addr,rf_dst_addr, reg_wrt);
            //if (pc >= 10)
                //$display(" oops");
            $display("pc:%h", pc);
            //$display("OP:%h WE:%b ctrl_mem_wrt:%b mem_adder:%d mem_data_in:%d mem_rd_data:%d", instr, we, mem_wrt, mem_addr, mem_wrt_data, mem_rd_data);
            //$display("OP:%h REG_RD_1:%h REG_RD_2:%h ALURESULT:%h WBDATA:%d", instr, reg_out_1, reg_out_2, Alu_result, wb_data);
            //
            //$display("lb_imm%d, lhb:%b llb:%b, Imm%d", Lb_imm, lhb, llb, Imm);
            //
            //$display("OP:%h ALU IN A:%d ALU IN B:%d RESULT:%h, ALU_CMD:%b", instr, A_in_alu, B_in_alu, Alu_result, Alu_Cmd);
end

always @ (set_zero,set_over,n_flag,v_flag,z_flag,alu_z,alu_n,alu_v)
begin
        //Set the flags (if signaled)
            if (set_zero)
                z_flag <= alu_z;
            if (set_over) 
            begin
                v_flag <= alu_v;
                n_flag <= alu_n;
            end
end


endmodule
