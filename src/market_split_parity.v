`default_nettype none
module market_split_parity (
  input wire [29:0] x, output wire [3:0] syndrome
) ;
  assign syndrome[0] = (^(x & 30'h279fac4a)) ^ 1'b1;
  assign syndrome[1] = (^(x & 30'h39a3cd77)) ^ 1'b0;
  assign syndrome[2] = (^(x & 30'h0359c88f)) ^ 1'b1;
  assign syndrome[3] = (^(x & 30'h355d3a60)) ^ 1'b1;
endmodule
`default_nettype wire
