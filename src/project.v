// Four-byte assignment port; see docs/info.md for the write protocol.
`default_nettype none
module tt_um_joesagents_market_split_oracle (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // uio_in[1:0] = byte select, uio_in[2] = write enable (sampled on clk).
  reg [29:0] x;

  always @(posedge clk) begin
    if (!rst_n) begin
      x <= 30'd0;
    end else if (uio_in[2]) begin
      case (uio_in[1:0])
        2'd0: x[7:0]   <= ui_in;
        2'd1: x[15:8]  <= ui_in;
        2'd2: x[23:16] <= ui_in;
        2'd3: x[29:24] <= ui_in[5:0];
      endcase
    end
  end

  wire [3:0] syndrome;
  market_split_parity core (.x(x), .syndrome(syndrome));

  wire done, exact_ok;
  market_split_exact exact (
      .clk(clk), .rst_n(rst_n), .we(uio_in[2]), .sel(uio_in[1:0]), .data(ui_in),
      .done(done), .exact_ok(exact_ok)
  );

  assign uo_out  = {1'b0, exact_ok, done, syndrome == 4'd0, syndrome};
  assign uio_out = 8'd0;
  assign uio_oe  = 8'd0;

  wire _unused = &{ena, uio_in[7:3], 1'b0};

endmodule

`default_nettype wire
