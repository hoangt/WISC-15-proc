module IM(clk,addr,rd_en,instr);

input clk;
input [15:0] addr;
input rd_en;			// asserted when instruction read desired

output reg [15:0] instr;	//output of insturction memory

reg [15:0]instr_mem[0:65535];

/////////////////////////////////////
// Memory is latched on clock low //
///////////////////////////////////
always @(addr,rd_en,clk)
  if (~clk & rd_en)
    instr <= instr_mem[addr];

initial begin
    //COMP
  //$readmemh("test_progs_hex/LwStall.hex",instr_mem);
  //$readmemh("test_progs_hex/instr.hex",instr_mem);
  
  //TODO
  $readmemh("test_progs_hex/Control.hex",instr_mem);
  //$readmemh("test_progs_hex/Loop.hex",instr_mem);
  //$readmemh("test_progs_hex/DataDependence.hex",instr_mem);
  //$readmemh("test_progs_hex/BasicOp.hex",instr_mem);
  
end

endmodule
