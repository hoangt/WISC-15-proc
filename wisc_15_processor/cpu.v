`include "alu/alu.v"
`include "control.v"
`include "instr_mem.v"
`include "rf_pipelined.v"
`include "instr_logic.v"
`include "data_mem.v"
`include "hazard_detect.v"

//TODO: Reduce some of the extra control signals being used ex: llb,lhb and merge them into alu_op
//TODO: Create special logic for call.
//TODO: Stall for one instr on branch.

module cpu(pc, hlt, clk, rst_n);
input clk, rst_n;
output [15:0] pc;
output hlt;

assign hlt = halt;
reg z_flag, v_flag, n_flag; 

reg [15:0] pc; 
initial pc = 0;

wire [15:0] new_pc; 

wire [15:0] C_imm, B_imm, Inst_imm, Lb_imm;
reg [15:0] call_pc;
wire [15:0] if_instr, Ret_reg, Imm;

hd detect_hazard(clk, rst_n, branch, call, mem_wb_wb_dst, mem_wb_write_reg, ex_mem_wb_dst, ex_mem_write_reg, id_ex_wb_dst, id_ex_write_reg, rf_r1_addr, rf_r2_addr, stall);

/********************************  IF PHASE  ***********************************/

// ***PC REG***
assign pc_we = ~stall && !hlt;
always @ (negedge rst_n, posedge clk) 
begin
            //call_pc <= pc + 1; //Used to store the temp pc, otherwise a feedback loop is present.
            
            if (!rst_n)
                pc <= 0;
            else if (clk && pc_we)
                pc <= new_pc;
            //if(pc >= 16'h001A)
            //    $finish();
end

wire id_reg_wrt, id_mem_to_reg, mem_wrt, branch, halt, id_set_over, id_set_zero, call, ret, alu_src, id_llb, id_lhb;
//Instruction Memory Stuff/ Branch logic
//Address Calculation.

assign rd_en =1;// ~hlt;
IM instruction_mem(clk,pc,rd_en,if_instr);

// **IF_ID REG**
wire if_id_clear, if_id_we;
reg [15:0] if_id_instr;

assign if_id_we = ~stall && !hlt && !flush;
assign if_id_clear = flush;
always @ (posedge clk, negedge rst_n) begin
    //Set the registers.
    if ((!rst_n) || (clk && if_id_clear)) begin
        if_id_instr <= 0;
    end
    else if (clk && if_id_we) begin
        if_id_instr <= if_instr;
    end
end

/********************************  ID PHASE  ***********************************/

//Sign ext for branch logic.
assign  C_imm[15:0] = {{4{if_id_instr[11]}},if_id_instr[11:0] } ;//Sign extend values for call.
assign B_imm[15:0] = {{7{if_id_instr[8]}},if_id_instr[8:0] }; //Sign extend values for branch.
assign Inst_imm[15:0] = {{12{if_id_instr[3]}},if_id_instr[3:0] }; //Sign extend the 4 bit immediate for input to alu.
assign Lb_imm[15:0] = {{8{if_id_instr[7]}}, if_id_instr[7:0]}; //Sign extend the 8 bit immediate for input to the alu on lhb llb.

assign Ret_reg = reg_out_1; //Grab the input for return addr as reading rs register.
instr_logic pc_calc(flush, new_pc, pc, Ret_reg, C_imm, B_imm, if_id_instr[11:9], z_flag, v_flag, n_flag, branch, call, ret, halt);



//CONTROL UNIT STUFF
wire [3:0] id_alu_cmd;
//Sign extenders for branch offsets.
control_unit control(id_alu_cmd, alu_src, id_reg_wrt, id_mem_to_reg, id_mem_wrt, branch, call, ret, halt, id_set_over, id_set_zero,id_llb,id_lhb, if_id_instr[15:12]);


//Register File Stuff
assign re0 = 1;  assign re1 = 1; //Set both registers to read perminentaly.

wire [3:0] rf_r1_addr, rf_r2_addr; //Register read inputs.
wire [15:0] reg_out_1, reg_out_2; //The register outputs.
wire [15:0] id_alu_in_b , id_alu_in_a; 
assign rf_r1_addr = (id_lhb) ? if_id_instr [11:8] : if_id_instr[7:4]; //REGISTER TO READ 1 in lhb use rd as src.
assign rf_r2_addr = (id_mem_wrt) ? if_id_instr[11:8] : if_id_instr[3:0]; //REGISTER TO READ 2

rf REG_FILE(clk,rf_r1_addr,rf_r2_addr,reg_out_1,reg_out_2,re0,re1,mem_wb_wb_dst,wb_data,mem_wb_write_reg,hlt); 

assign Imm = (id_lhb||id_llb) ? Lb_imm: Inst_imm; //Mux the lb immediate and normal inst immediate for input to alu.
assign id_alu_in_b = (call) ? 16'h0000 : ((alu_src) ? Imm : reg_out_2);//Mux the alu_src imm and register_rd
assign id_alu_in_a = (call) ? pc : reg_out_1; // IN CALL WE ADD ZERO to current pc and store.


wire [3:0] id_wb_dst; //The register write address.
wire [15:0] id_wb_data; //The register write data.

assign id_wb_dst= (call) ? 4'hf : if_id_instr[11:8]; //Mux the input of the write destination register.

// **ID_EX REGISTER**
wire id_ex_clear, id_ex_we;
reg id_ex_mem_we, id_ex_mem_re, id_ex_mem_to_reg, id_ex_write_reg; 
reg id_ex_llb, id_ex_lhb, id_ex_set_over, id_ex_set_zero;
reg [3:0] id_ex_wb_dst;
reg [3:0] id_ex_alu_cmd;
reg [15:0] id_ex_alu_in_a, id_ex_alu_in_b, id_ex_mem_data_in;

assign id_ex_we = ~stall && !hlt;
assign id_ex_clear = stall;
always @ (posedge clk, negedge rst_n) begin
    //Set the registers.
    if ((! rst_n) || (clk && id_ex_clear)) begin
        id_ex_mem_we <= 0;
        id_ex_mem_re <= 0;
        id_ex_mem_to_reg <= 0;
        id_ex_write_reg  <= 0;
        id_ex_llb <= 0;
        id_ex_lhb <= 0;
        id_ex_wb_dst <= 0;
        id_ex_alu_cmd <= 0;
        id_ex_alu_in_a <= 0;
        id_ex_alu_in_b <= 0;
        id_ex_mem_data_in <= 0;
        id_ex_set_zero <= 0;
        id_ex_set_over <= 0;
    end
    else if (clk && id_ex_we) begin
        id_ex_mem_we <= id_mem_wrt;     //j
        id_ex_mem_re <= ~id_mem_wrt; //TODO Might need to change later (for when reading memory has cost)
        id_ex_mem_to_reg <= id_mem_to_reg; //j
        id_ex_write_reg  <= id_reg_wrt; //j
        id_ex_wb_dst <= id_wb_dst;      //j
        id_ex_llb <= id_llb;            //j
        id_ex_lhb <= id_lhb;            //j
        id_ex_alu_cmd <= id_alu_cmd;    //j
        id_ex_alu_in_a <= id_alu_in_a; //j
        id_ex_alu_in_b <= id_alu_in_b; //j
        id_ex_mem_data_in <= reg_out_2;
        id_ex_set_zero <= id_set_zero;
        id_ex_set_over <= id_set_over;
    end
end

/********************************  EX PHASE  ***********************************/

//ALU STUFF
wire [15:0] ex_alu_result;
wire ex_v, ex_n, ex_z;
alu ALU(ex_alu_result, ex_v, ex_n, ex_z, id_ex_alu_in_a, id_ex_alu_in_b, id_ex_alu_cmd, id_ex_llb, id_ex_lhb);

// **EX_MEM REGISTER**
wire ex_mem_clear, ex_mem_we;
reg ex_mem_mem_we, ex_mem_mem_re, ex_mem_mem_to_reg, ex_mem_write_reg; 
reg [3:0] ex_mem_wb_dst;
reg [15:0] ex_mem_alu_output, ex_mem_mem_data_in; //alu output, data to be written to mem.

assign ex_mem_we = 1 && !hlt;
assign ex_mem_clear = 0;
always @ (posedge clk, negedge rst_n) begin
    //Set the registers.
    if (! rst_n|| (clk && ex_mem_clear)) begin
        ex_mem_mem_we <= 0;
        ex_mem_mem_re <= 0;
        ex_mem_mem_to_reg <= 0;
        ex_mem_write_reg  <= 0;
        ex_mem_wb_dst <= 0;
        ex_mem_alu_output <= 0;
        ex_mem_mem_data_in <= 0;
    end
    else if (clk && ex_mem_we) begin
        ex_mem_mem_we <= id_ex_mem_we;
        ex_mem_mem_re <= id_ex_mem_re;
        ex_mem_mem_to_reg <= id_ex_mem_to_reg;
        ex_mem_write_reg  <= id_ex_write_reg;
        ex_mem_wb_dst <= id_ex_wb_dst;
        ex_mem_alu_output <= ex_alu_result;
        ex_mem_mem_data_in <= id_ex_mem_data_in;
    end
end

/********************************  MEM PHASE  ***********************************/


//DATA MEMORY STUFF
wire [15:0] mem_addr, mem_data_output;
assign mem_addr = ex_mem_alu_output;

DM Data_Mem(clk,mem_addr,ex_mem_mem_re,ex_mem_mem_we, ex_mem_mem_data_in, mem_data_output);


// **MEM_WB REGISTER**
wire mem_wb_clear, mem_wb_we;
reg mem_wb_mem_to_reg, mem_wb_write_reg; 
reg [3:0] mem_wb_wb_dst;
reg [15:0] mem_wb_alu_output, mem_wb_mem_data_output;

assign mem_wb_we = 1 && !hlt;
assign mem_wb_clear = 0;
always @ (posedge clk, negedge rst_n) begin
    //Set the registers.
    if (! rst_n|| (clk && mem_wb_clear)) begin
        mem_wb_mem_to_reg <= 0;
        mem_wb_write_reg <= 0;
        mem_wb_wb_dst <= 0;
        mem_wb_alu_output <= 0;
        mem_wb_mem_data_output <= 0;
    end
    else if (clk && mem_wb_we) begin
        mem_wb_mem_to_reg <= ex_mem_mem_to_reg;
        mem_wb_write_reg <= ex_mem_write_reg;
        mem_wb_wb_dst <= ex_mem_wb_dst;
        mem_wb_alu_output <= ex_mem_alu_output;
        mem_wb_mem_data_output <= mem_data_output;
    end
end


/********************************  WB PHASE  ***********************************/
// >Also see ID PHASE

//assign wb_data = (mem_wb_mem_to_reg) ? mem_rd_data : Alu_result;//Mux the outputs of Data memory and the alu for wb to reg file
wire [15:0] wb_data;
assign wb_data = (mem_wb_mem_to_reg) ? mem_wb_mem_data_output : mem_wb_alu_output;//Mux the outputs of Data memory and the alu for wb to reg file

//FLAG SETTING
always @ (posedge clk, negedge rst_n)
begin
    if (!rst_n) begin
        z_flag <= 0;
        v_flag <= 0;
        n_flag <= 0;
    end
    else if (clk) begin 
        //Set the flags (if signaled)
            if (id_ex_set_zero)
                z_flag <= ex_z;
            if (id_ex_set_over) 
            begin
                v_flag <= ex_v;
                n_flag <= ex_n;
            end
        end
    end



/* TESTING */
always @ (posedge clk)
begin
    $display("pc:%h stall:%b flush:%b", pc, stall, flush);

    //TEST CALL PC ADDR.
    //$display("id_ex_alu_a:%h id_ex_wb_dst:%h", id_ex_alu_in_a, id_ex_wb_dst);

    //$display("mem_wb_write_reg:%b  ex_mem:%b id_ex:%b", mem_wb_write_reg, ex_mem_write_reg, id_ex_write_reg);
    //Test the IF output. /j
    //$display("if_id_instr:%h if_instr:%h", if_id_instr, if_instr);

    //Test the ID output.
    $display("if_id_instr:%h", if_id_instr);
    //$display("id_ex_alu_a:%h id_ex_alu_b:%h lhb:%b llb:%b", id_ex_alu_in_a, id_ex_alu_in_b, id_ex_lhb, id_ex_llb);
end


//always @ (posedge clk)
//begin
//    //TEST CALL
//    //if(call)
//    //    $display("rf_dst_in:%h rf_dst_addr:%h reg_wrt:%b",rf_dst_in,rf_dst_addr, reg_wrt);
//    //if (ret)
//    //    $display("rf_r1_addr:%h rf_dst_addr:%h reg_wrt:%b",rf_r1_addr,rf_dst_addr, reg_wrt);
//            //if (pc >= 10)
//                //$display(" oops");
//            //$display("pc:%h", pc);
//            //$display("OP:%h WE:%b ctrl_mem_wrt:%b mem_adder:%d mem_data_in:%d mem_rd_data:%d", instr, we, mem_wrt, mem_addr, mem_wrt_data, mem_rd_data);
//            //$display("OP:%h REG_RD_1:%h REG_RD_2:%h ALURESULT:%h WBDATA:%d", instr, reg_out_1, reg_out_2, Alu_result, wb_data);
//            //
//            //$display("lb_imm%d, lhb:%b llb:%b, Imm%d", Lb_imm, lhb, llb, Imm);
//            //
//            //$display("OP:%h ALU IN A:%d ALU IN B:%d RESULT:%h, ALU_CMD:%b", instr, A_in_alu, B_in_alu, Alu_result, Alu_Cmd);
//end


endmodule
