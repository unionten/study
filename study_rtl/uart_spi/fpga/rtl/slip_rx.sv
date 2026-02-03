module slip_rx(
  input  logic       clk,
  input  logic       rst_n,
  input  logic [7:0] in_data,
  input  logic       in_valid,
  output logic       in_ready,
  output logic [7:0] out_data,
  output logic       out_valid,
  input  logic       out_ready,
  output logic       frame_start,
  output logic       frame_end,
  output logic       frame_error
);
  localparam logic [7:0] END = 8'hC0;
  localparam logic [7:0] ESC = 8'hDB;
  localparam logic [7:0] ESC_END = 8'hDC;
  localparam logic [7:0] ESC_ESC = 8'hDD;

  logic esc;
  logic in_frame;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      esc <= 1'b0;
      in_frame <= 1'b0;
      out_valid <= 1'b0;
      out_data <= '0;
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

