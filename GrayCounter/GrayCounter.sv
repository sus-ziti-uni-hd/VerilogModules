/*
Implementation of the fast gray counter algorithm described in:

Dan I.Porat, Stanley Wojcicki: Fast synchronous gray counter
Nuclear Instruments and Methods
Volume 169, Issue 1, 1 February 1980, Pages 243-244
*/

`default_nettype none
module GrayCounter #(
    parameter unsigned P_WIDTH = 4
) (
    input wire CLK,
    input wire INIT,
    output logic [P_WIDTH-1:0] COUNT
);

  timeunit 1ns; timeprecision 10ps;

  logic [P_WIDTH-1:0] bin_count;
  logic overflow;
  logic [P_WIDTH-1:0] last_bin_count;

  always @(posedge CLK) begin
    priority if (INIT) begin
      overflow <= 1'b0;
      // initialize to 1: as soon as init is released, we want to detect a
      // difference between last_bin_count and bin_count.
      bin_count <= {{P_WIDTH - 1{1'b0}}, 1'b1};
      last_bin_count <= {P_WIDTH{1'b0}};
    end else begin
      {overflow, bin_count} <= bin_count + 1'd1;
      last_bin_count <= bin_count;
    end
  end

  generate
    for (genvar i = 0; i < P_WIDTH; i++) begin : gen_gray_bits
      always @(posedge CLK) begin : bin2gray
        // looking for rising edges
        if (INIT || overflow) begin
          // when the binary count changes from all-1 to all-0, the gray count
          // also has to be reset to 0.
          COUNT[i] <= 1'b0;
        end else if ({last_bin_count[i], bin_count[i]} == 2'b01) begin
          COUNT[i] <= !COUNT[i];
        end
      end
    end
  endgenerate

endmodule : GrayCounter
