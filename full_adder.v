module full_adder(cout, sum, a, b, cin);

output cout, sum;
input a, b, cin;

wire w1,w2,w3;

xor lu1(w1, a, b);
xor lu2(sum, cin, w1);
and lu3(w2, w1, cin);
and lu4(w3, a, b);
or  lu5(cout, w2, w3);

endmodule
