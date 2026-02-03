`include "fwu_defs.vh"

module slip_tx(
  input  clk,
  input  rst_n,
  input  start,
  input  end_frame,
  input  [7:0] in_data,
  input  in_valid,
  output in_ready,
  output reg [7:0] out_data,
  output reg out_valid,
  input  out_ready
);
  localparam [7:0] END = 8'hC0;
  localparam [7:0] ESC = 8'hDB;
  localparam [7:0] ESC_END = 8'hDC;
  localparam [7:0] ESC_ESC = 8'hDD;

  localparam [1:0] S_IDLE = 2'd0;
  localparam [1:0] S_ESC2 = 2'd1;
  reg [1:0] st;

  reg [7:0] esc_second;
  reg pend_end;
  reg pend_start;
  reg pend_data;
  reg [7:0] pend_byte;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= S_IDLE;
      out_valid <= 1'b0;
      out_data <= 8'h00;
      esc_second <= 8'h00;
      pend_end <= 1'b0;
      pend_start <= 1'b0;
      pend_data <= 1'b0;
      pend_byte <= 8'h00;
    end else begin
      if (out_valid && out_ready) out_valid <= 1'b0;

      if (start) pend_start <= 1'b1;
      if (end_frame) pend_end <= 1'b1;
      if (in_valid && in_ready) begin
        pend_data <= 1'b1;
        pend_byte <= in_data;
      end

      if (!out_valid || out_ready) begin
        case (st)
          S_IDLE: begin
            if (pend_start) begin
              pend_start <= 1'b0;
              out_data <= END;
              out_valid <= 1'b1;
            end else if (pend_data) begin
              pend_data <= 1'b0;
              if (pend_byte == END) begin
                out_data <= ESC;
                esc_second <= ESC_END;
                out_valid <= 1'b1;
                st <= S_ESC2;
              end else if (pend_byte == ESC) begin
                out_data <= ESC;
                esc_second <= ESC_ESC;
                out_valid <= 1'b1;
                st <= S_ESC2;
              end else begin
                out_data <= pend_byte;
                out_valid <= 1'b1;
              end
            end else if (pend_end) begin
              pend_end <= 1'b0;
              out_data <= END;
              out_valid <= 1'b1;
            end
          end
          S_ESC2: begin
            out_data <= esc_second;
            out_valid <= 1'b1;
            st <= S_IDLE;
          end
          default: st <= S_IDLE;
        endcase
      end
    end
  end

  assign in_ready = !pend_data;
endmodule

