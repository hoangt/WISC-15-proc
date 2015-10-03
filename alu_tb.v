`include "alu.v"

module alu_common_bits_tb();

//reg [3:0] vals, cmd; //Vals: 2 to 0: a, b, cin
//wire sum, cout;
//
//alu_common_bits bit(cout, sum, vals[2], vals[1], vals[0], cmd);
//
//initial begin
//    for (vals = 0; vals < 1<<3; vals = vals+1) begin
//
//        //Subtraction
//        //cmd = 4'hf;
//        //#5
//        //if (sum + (cout<<1) != vals[2] + vals[0]- vals[1])
//        //    $display("Error1");
//        //    $display("A:%b\tB:%b\tCin:%b, COUT:%b SUM:%b ", vals[2],vals[1], vals[0], cout, sum);
//
//        //Adding A + B + Cin
//        cmd = 4'h0;
//        #5
//        if (sum + (cout<<1) != vals[2] + vals[1] + vals[0])
//            $display("Error2");
//            $display("A:%b\tB:%b\tCin:%b, COUT:%b SUM:%b ", vals[2],vals[1], vals[0], cout, sum);
//    end
//
//end

//ALU Tester

reg [16:0] a, b;
reg [4:0] cmd;
wire [15:0] result;

alu iDUT(result, a[15:0], b[15:0], cmd[3:0]);

initial begin

    for (a = 0; a < 1 << 16; a=a+1) begin
        for (b = 0; b < 1 << 16; b = b+1) begin
            #5
            if (result != a + b) begin //Currently is messed up on overflow case.
                $display("Error!");
                $display("a:%b b:%b out:%b", a,b,result);
            end
        end
    end
end

endmodule
