
//A Testbed to test functionallaity of the add, sub, and paddsw through the au
module au_tb();
wire [15:0] Result;
wire cout;
wire v,n;
reg  [1:0] Cmd;
reg [16:0] A, B;

au iDUT(Result, cout, v,n, Cmd, A[15:0], B[15:0]);

initial 
begin

    //TODO: Still need to test paddsb

    ////Set command to addition.
    Cmd = 2'b00;
    //Add neg overflow. Test
    A = 16'h8000;
    B = 16'h80f0;
    #1
    if ( Result != 16'h8000)
        $display("Error in add neg overflow case! A:%d B:%d Result:%h v:%b n:%b", A, B, Result,v,n);

    //Add neg normal Test.
    A = 16'hf00f;
    B = 16'hfff0;
    #1
    if ( Result != 16'hefff)
        $display("Error in add neg case! A:%d B:%d Result:%h v:%b n:%b", A, B, Result,v,n);

    //Add pos overflow Test.
    A = 16'h700f;
    B = 16'h7ff0;
    #1
    if ( Result != 16'h7fff)
        $display("Error in add pos overflow case! A:%d B:%d Result:%h v:%b n:%b", A, B, Result,v,n);

    //Set command to Sub.
    Cmd = 4'b0001;

    //Sub A > B pos case.
    A = 16'h70f0;
    B = 16'h2000;
    #1
    if ( Result != A - B)
        $display("Error in sub A > B pos case A:%h B:%h Result:%h expected:%h v:%b n:%b", A, B, Result,A-B,v,n);

    //Sub A < B pos case.
    B = 16'h70f0;
    A = 16'h2000;
    #1
    if ( Result != ((A - B) & 16'hffff))
        $display("Error in sub A < B pos case A:%h B:%h Result:%h expected:%h n:%b", A, B, Result,A-B,n);

    //Sub A < B neg pos case.
    A = 16'hff00;
    B = 16'h10f0;
    #1
    if ( Result != ((A - B) & 16'hffff))
        $display("Error in Sub A < B neg pos case. A:%h B:%h Result:%h expected:%h n:%b", A, B, Result,A-B,n);

    //Sub A > B pos neg case.
    B = 16'hff00;
    A = 16'h10f0;
    #1
    if ( Result != ((A - B) & 16'hffff))
        $display("Error in Sub A < B neg pos case. A:%h B:%h Result:%h expected:%h n:%b", A, B, Result,A-B,n);

    //Sub A > B pos neg pos_v case.
    B = 16'h8f00;
    A = 16'h10f0;
    #1
    if ( Result != (16'h7fff))
        $display("Error in Sub A > B neg pos pos_v case. A:%h B:%h Result:%h expected:%h n:%b", A, B, Result,16'h7fff,n);

    //Sub A < B neg pos neg_v case.
    A = 16'hff00;
    B = 16'h800f;
    #1
    if ( Result != ((A - B) & 16'hffff))
      $display("Error in Sub A > B neg pos  neg_v case. A:%h B:%h Result:%h expected:%h n:%b", A, B, Result,16'h8000,n);

    $finish;

    ////Cmd = 4'b1z0z;
    //for (A = 2000; A < (1<<16) ; A=A+79) begin
    //    for (B = 0; B < (1<<16); B=B+1) begin
    //        //for (Cmd = 0; Cmd < (1<<4); Cmd=Cmd+1) begin

    //                #1

    //            casez (Cmd) 
    //                //normal add
    //                4'b0z0z:
    //                    if(~v & ~n) begin
    //                        if (Result != A + B) begin
    //                            $display("Error in add case! A:%d B:%d Result:%h v:%b n:%b", A, B, Result,v,n);
    //                        end
    //                    end
    //                    //else if (n) begin
    //                    //    if (Result != A + B) begin
    //                    //        $display("Error in add case! A:%d B:%d Result:%h v:%b n:%b", A, B, Result,v,n);
    //                    //    end
    //                    //end
    //                    //else if (v & ~n) begin
    //                    //    if (Result != 16'h7fff)
    //                    //        $display("Error add overflow case! A:%h B:%h Result:%h", A, B, Result);
    //                    //end
    //                ////subtract
    //                //4'b0z1z:
    //                //    if (Result != A - B)
    //                //        $display("Error in sub case! A:%d B:%d Result:%d", A, B, Result);
    //                ////padd
    //                //4'b1z0z:
    //                //    $display("PADD: A:%h B:%h Result:%h", A, B, Result); //PADD Looks GOOD?
    //            endcase

    //        //end

    //    end
    //end
end

endmodule
