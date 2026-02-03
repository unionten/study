`include "fwu_defs.vh"

module crc32_ieee(
  input  clk,
  input  rst_n,
  input  init,
  input  en,
  input  [7:0] data,
  output reg [31:0] crc
);
  function [31:0] next_crc32;
    input [31:0] c;
    input [7:0] d;
    reg [31:0] x;
    integer i;
    begin
      x = c ^ {24'd0, d};
      for (i = 0; i < 8; i = i + 1) begin
        if (x[0]) x = (x >> 1) ^ 32'hEDB88320;
        else x = (x >> 1);
      end
      next_crc32 = x;
    end
  endfunction

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      crc <= 32'hFFFFFFFF;
    end else begin
      if (init) crc <= 32'hFFFFFFFF;
      else if (en) crc <= next_crc32(crc, data);
    end
  end
endmodule

