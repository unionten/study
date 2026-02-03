`include "fwu_defs.vh"

module slip_rx(
  input  clk,
  input  rst_n,
  input  [7:0] in_data,
  input  in_valid,
  output in_ready,
  output reg [7:0] out_data,
  output reg out_valid,
  input  out_ready,
  output reg frame_start,
  output reg frame_end,
  output reg frame_error
);
  localparam [7:0] END = 8'hC0;
  localparam [7:0] ESC = 8'hDB;
  localparam [7:0] ESC_END = 8'hDC;
  localparam [7:0] ESC_ESC = 8'hDD;

  reg esc;
  reg in_frame;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      esc <= 1'b0;
      in_frame <= 1'b0;
      out_valid <= 1'b0;
      out_data <= 8'h00;
      frame_start <= 1'b0;
      frame_end <= 1'b0;
      frame_error <= 1'b0;
    end else begin
      frame_start <= 1'b0;
      frame_end <= 1'b0;
      frame_error <= 1'b0;
      if (out_valid && out_ready) out_valid <= 1'b0;

      if (in_valid && in_ready) begin
        if (in_data == END) begin
          if (!in_frame) begin
            in_frame <= 1'b1;
            esc <= 1'b0;
            frame_start <= 1'b1;
          end else begin
            frame_end <= 1'b1;
            in_frame <= 1'b1;
            esc <= 1'b0;
          end
        end else if (in_frame) begin
          if (esc) begin
            esc <= 1'b0;
            if (in_data == ESC_END) begin
              out_data <= END;
              out_valid <= 1'b1;
            end else if (in_data == ESC_ESC) begin
              out_data <= ESC;
              out_valid <= 1'b1;
            end else begin
              in_frame <= 1'b0;
              frame_error <= 1'b1;
            end
          end else if (in_data == ESC) begin
            esc <= 1'b1;
          end else begin
            out_data <= in_data;
            out_valid <= 1'b1;
          end
        end
      end
    end
  end

  assign in_ready = (!out_valid) || out_ready;
endmodule

