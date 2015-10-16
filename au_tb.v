
//A Testbed to test functionallaity of the add, sub, and paddsw through the au
module au_tb();
wire [15:0] Result;
wire cout;
reg  [4:0] Cmd;
reg [16:0] A, B;

au iDUT(Result, cout, Cmd[3:0], A[15:0], B[15:0]);

initial 
begin
    Cmd = 4'h0;
    for (A = 20000; A < (1<<16) ; A=A+7) begin
        for (B = 0; B < (1<<16); B=B+3) begin
            //for (Cmd = 0; Cmd < (1<<4); Cmd=Cmd+1) begin

                    #1

                casez (Cmd) 
                        //normal add
                    //4'b0z0z:
                    //    if (Result != A + B)
                    //        $display("Error in add case! A:%d B:%d Result:%d", A, B, Result);
                        //subtract
                    4'b0z1z:
                        if (Result != A - B)
                            $display("Error in sub case! A:%d B:%d Result:%d", A, B, Result);
                        //padd
                    //4'b1z0z:
                endcase

            //end

        end
    end
end

endmodule
