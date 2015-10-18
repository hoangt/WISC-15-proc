module alu_tb();
reg [16:0] A, B; //Inputs A and B
reg [3:0] Alu_Ctrl; //The Alu_Control Signals
wire [16:0] Result; //Result of alu
wire z,n,v; //Flags output.

alu iDUT(Result[15:0], v, n, z, A[15:0], B[15:0], Alu_Ctrl);
assign Result[16] = 0; //Make the garbage bit auto 0

initial begin
    //Test XOR
    //Alu_Ctrl = 4'b1000;
    //for (A = 0; A < (1<<15); A = A+31) begin
    //    for (B = 0; B < (1<<15); B = B+73) begin
    //        #1
    //        if (Result != (A^B))
    //            $display("BAD XOR, A:%h B%h Result:%h Expected:%h", A, B, Result, A^B);
    //    end
    //end
    
    //Test NAND
    Alu_Ctrl = 4'b0100;
    for (A = 0; A < (1<<15); A = A+31) begin
        for (B = 0; B < (1<<15); B = B+73) begin
            #1
            if (Result != (~(A&B)& 17'h0ffff))
                $display("BAD NAND, A:%h B%h Result:%h Expected:%h", A, B, Result, ~(A&B)& 17'h0ffff);
        end
    end
    
end

endmodule
