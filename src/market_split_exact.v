// Ordered writes accumulate exact byte contributions on the write edge.
// SEL=0 restarts; 1,2,3 must follow. Idle cycles preserve transaction.
// Malformed writes invalidate until the next SEL=0. DONE on SEL=3.
`default_nettype none
module market_split_exact (
  input wire clk, input wire rst_n, input wire we,
  input wire [1:0] sel, input wire [7:0] data,
  output reg done, output reg exact_ok
);
  reg active; reg [1:0] expected;
  reg [9:0] acc0, acc1, acc2, acc3;
  reg [9:0] part0, part1, part2, part3;
  wire [9:0] n0 = acc0 + part0;
  wire [9:0] n1 = acc1 + part1;
  wire [9:0] n2 = acc2 + part2;
  wire [9:0] n3 = acc3 + part3;
  wire match_next = (n0 == 10'd349) && (n1 == 10'd398) && (n2 == 10'd403) && (n3 == 10'd435);
  always @(*) begin
    part0=0; part1=0; part2=0; part3=0;
    case (sel)
      0: begin
        part0 = (((data[0] ? 10'd2 : 10'd0) + ((data[1] ? 10'd23 : 10'd0) + (data[2] ? 10'd42 : 10'd0))) + (((data[3] ? 10'd17 : 10'd0) + (data[4] ? 10'd28 : 10'd0)) + ((data[6] ? 10'd9 : 10'd0) + (data[7] ? 10'd50 : 10'd0))));
        part1 = (((data[0] ? 10'd35 : 10'd0) + ((data[1] ? 10'd11 : 10'd0) + (data[2] ? 10'd49 : 10'd0))) + (((data[4] ? 10'd5 : 10'd0) + (data[5] ? 10'd45 : 10'd0)) + ((data[6] ? 10'd5 : 10'd0) + (data[7] ? 10'd38 : 10'd0))));
        part2 = ((((data[0] ? 10'd27 : 10'd0) + (data[1] ? 10'd33 : 10'd0)) + ((data[2] ? 10'd29 : 10'd0) + (data[3] ? 10'd25 : 10'd0))) + (((data[4] ? 10'd10 : 10'd0) + (data[5] ? 10'd4 : 10'd0)) + ((data[6] ? 10'd14 : 10'd0) + (data[7] ? 10'd35 : 10'd0))));
        part3 = ((((data[0] ? 10'd12 : 10'd0) + (data[1] ? 10'd24 : 10'd0)) + ((data[2] ? 10'd46 : 10'd0) + (data[3] ? 10'd16 : 10'd0))) + (((data[4] ? 10'd42 : 10'd0) + (data[5] ? 10'd15 : 10'd0)) + ((data[6] ? 10'd47 : 10'd0) + (data[7] ? 10'd30 : 10'd0))));
      end
      1: begin
        part0 = ((((data[0] ? 10'd38 : 10'd0) + (data[1] ? 10'd18 : 10'd0)) + ((data[2] ? 10'd17 : 10'd0) + (data[3] ? 10'd29 : 10'd0))) + (((data[4] ? 10'd6 : 10'd0) + (data[5] ? 10'd3 : 10'd0)) + ((data[6] ? 10'd48 : 10'd0) + (data[7] ? 10'd7 : 10'd0))));
        part1 = ((((data[0] ? 10'd15 : 10'd0) + (data[1] ? 10'd32 : 10'd0)) + ((data[2] ? 10'd21 : 10'd0) + (data[3] ? 10'd25 : 10'd0))) + (((data[4] ? 10'd16 : 10'd0) + (data[5] ? 10'd22 : 10'd0)) + ((data[6] ? 10'd33 : 10'd0) + (data[7] ? 10'd35 : 10'd0))));
        part2 = ((((data[0] ? 10'd38 : 10'd0) + (data[1] ? 10'd34 : 10'd0)) + ((data[2] ? 10'd30 : 10'd0) + (data[3] ? 10'd19 : 10'd0))) + (((data[4] ? 10'd26 : 10'd0) + (data[5] ? 10'd28 : 10'd0)) + ((data[6] ? 10'd33 : 10'd0) + (data[7] ? 10'd47 : 10'd0))));
        part3 = ((((data[0] ? 10'd50 : 10'd0) + (data[1] ? 10'd19 : 10'd0)) + ((data[2] ? 10'd10 : 10'd0) + (data[3] ? 10'd27 : 10'd0))) + (((data[4] ? 10'd49 : 10'd0) + (data[5] ? 10'd33 : 10'd0)) + ((data[6] ? 10'd28 : 10'd0) + (data[7] ? 10'd50 : 10'd0))));
      end
      2: begin
        part0 = (((data[0] ? 10'd29 : 10'd0) + ((data[1] ? 10'd11 : 10'd0) + (data[2] ? 10'd41 : 10'd0))) + (((data[3] ? 10'd7 : 10'd0) + (data[4] ? 10'd31 : 10'd0)) + ((data[5] ? 10'd10 : 10'd0) + (data[7] ? 10'd29 : 10'd0))));
        part1 = ((((data[0] ? 10'd39 : 10'd0) + (data[1] ? 10'd41 : 10'd0)) + ((data[2] ? 10'd16 : 10'd0) + (data[3] ? 10'd50 : 10'd0))) + (((data[4] ? 10'd34 : 10'd0) + (data[5] ? 10'd7 : 10'd0)) + ((data[6] ? 10'd44 : 10'd0) + (data[7] ? 10'd35 : 10'd0))));
        part2 = ((((data[0] ? 10'd9 : 10'd0) + (data[1] ? 10'd30 : 10'd0)) + ((data[2] ? 10'd4 : 10'd0) + (data[3] ? 10'd29 : 10'd0))) + (((data[4] ? 10'd13 : 10'd0) + (data[5] ? 10'd48 : 10'd0)) + ((data[6] ? 10'd11 : 10'd0) + (data[7] ? 10'd40 : 10'd0))));
        part3 = ((((data[0] ? 10'd17 : 10'd0) + (data[1] ? 10'd50 : 10'd0)) + ((data[2] ? 10'd33 : 10'd0) + (data[3] ? 10'd41 : 10'd0))) + (((data[4] ? 10'd33 : 10'd0) + (data[5] ? 10'd4 : 10'd0)) + ((data[6] ? 10'd9 : 10'd0) + (data[7] ? 10'd10 : 10'd0))));
      end
      3: begin
        part0 = (((data[0] ? 10'd47 : 10'd0) + ((data[1] ? 10'd17 : 10'd0) + (data[2] ? 10'd45 : 10'd0))) + ((data[3] ? 10'd30 : 10'd0) + ((data[4] ? 10'd20 : 10'd0) + (data[5] ? 10'd45 : 10'd0))));
        part1 = (((data[0] ? 10'd19 : 10'd0) + ((data[1] ? 10'd28 : 10'd0) + (data[2] ? 10'd24 : 10'd0))) + ((data[3] ? 10'd13 : 10'd0) + ((data[4] ? 10'd47 : 10'd0) + (data[5] ? 10'd13 : 10'd0))));
        part2 = (((data[0] ? 10'd17 : 10'd0) + ((data[1] ? 10'd29 : 10'd0) + (data[2] ? 10'd48 : 10'd0))) + ((data[3] ? 10'd32 : 10'd0) + ((data[4] ? 10'd46 : 10'd0) + (data[5] ? 10'd18 : 10'd0))));
        part3 = (((data[0] ? 10'd5 : 10'd0) + ((data[1] ? 10'd50 : 10'd0) + (data[2] ? 10'd43 : 10'd0))) + ((data[3] ? 10'd32 : 10'd0) + ((data[4] ? 10'd3 : 10'd0) + (data[5] ? 10'd43 : 10'd0))));
      end
      default: begin end
    endcase
  end
  always @(posedge clk) begin
    if (!rst_n) begin
      acc0 <= 0; acc1 <= 0; acc2 <= 0; acc3 <= 0;
      active <= 0; expected <= 0; done <= 0; exact_ok <= 0;
    end else if (we) begin
      done <= 0; exact_ok <= 0;
      if (sel == 0) begin
        acc0 <= part0; acc1 <= part1; acc2 <= part2; acc3 <= part3;
        active <= 1; expected <= 1;
      end else if (active && sel == expected) begin
        acc0 <= n0; acc1 <= n1; acc2 <= n2; acc3 <= n3;
        if (sel == 3) begin
          active <= 0; done <= 1; exact_ok <= match_next;
        end else expected <= expected + 1'b1;
      end else begin active <= 0; expected <= 0; end
    end
  end
endmodule
`default_nettype wire
