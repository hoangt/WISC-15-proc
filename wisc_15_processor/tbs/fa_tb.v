module fa_tb();

wire sum, cout;
reg [3:0] stim;

    full_adder fa1(cout, sum, stim[2], stim[1], stim[0]);
initial begin
    
    for (stim[3:0] = 0; stim < 1 << 3; stim = stim + 1) begin
        #5
        if ( sum + (cout << 1) != stim[0] + stim[1] + stim[2]) begin
            $display("Error!!");
            $display("A:%b\tB:%b\tCin:%b, COUT:%b SUM:%b ", stim[2], stim[1], stim[0], cout,sum);
        end
    end

end

endmodule
