`include "fwu_defs.vh"

module fwu_frame_tx #(
  parameter integer MAX_PAYLOAD = `FWU_MAX_PAYLOAD
)(
  input  clk,
  input  rst_n,

  input  rsp_valid,
  output rsp_ready,
  input  [7:0]  rsp_type,
  input  [15:0] rsp_seq,
  input  [15:0] rsp_len,
  input  [7:0]  rsp_data,
  input  rsp_data_valid,
  output rsp_data_ready,
  input  rsp_end,

  output reg slip_start,
  output reg slip_end,
  output [7:0] slip_data,
  output slip_valid,
  input  slip_ready
);
  reg [7:0] t_type;
  reg [15:0] t_seq;
  reg [15:0] t_len;

  localparam [2:0] ST_IDLE = 3'd0;
  localparam [2:0] ST_HDR  = 3'd1;
  localparam [2:0] ST_PAY  = 3'd2;
  localparam [2:0] ST_CRC  = 3'd3;
  localparam [2:0] ST_END  = 3'd4;
  reg [2:0] st;

  reg [3:0] idx;
  reg [15:0] pay_sent;

  reg crc_init;
  reg crc_en;
  reg [7:0] crc_byte;
  wire [31:0] crc_state;
  wire [31:0] crc_now = ~crc_state;
  crc32_ieee u_crc(
    .clk(clk), .rst_n(rst_n),
    .init(crc_init), .en(crc_en), .data(crc_byte),
    .crc(crc_state)
  );

  function [7:0] hdr_byte;
    input [3:0] i;
    begin
      case (i)
        4'd0: hdr_byte = 8'h55;
        4'd1: hdr_byte = 8'hAA;
        4'd2: hdr_byte = 8'h01;
        4'd3: hdr_byte = t_type;
        4'd4: hdr_byte = t_seq[15:8];
        4'd5: hdr_byte = t_seq[7:0];
        4'd6: hdr_byte = t_len[15:8];
        default: hdr_byte = t_len[7:0];
      endcase
    end
  endfunction

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= ST_IDLE;
      t_type <= 8'h00;
      t_seq <= 16'h0000;
      t_len <= 16'd0;
      idx <= 4'd0;
      pay_sent <= 16'd0;
      crc_init <= 1'b1;
      crc_en <= 1'b0;
      crc_byte <= 8'h00;
      slip_start <= 1'b0;
      slip_end <= 1'b0;
    end else begin
      crc_init <= 1'b0;
      crc_en <= 1'b0;
      slip_start <= 1'b0;
      slip_end <= 1'b0;

      case (st)
        ST_IDLE: begin
          if (rsp_valid && rsp_ready) begin
            t_type <= rsp_type;
            t_seq <= rsp_seq;
            t_len <= rsp_len;
            idx <= 4'd0;
            pay_sent <= 16'd0;
            crc_init <= 1'b1;
            slip_start <= 1'b1;
            st <= ST_HDR;
          end
        end

        ST_HDR: begin
          if (slip_ready) begin
            crc_en <= 1'b1;
            crc_byte <= hdr_byte(idx);
            if (idx == 4'd7) begin
              st <= (t_len == 0) ? ST_CRC : ST_PAY;
              idx <= 4'd0;
            end else idx <= idx + 1'b1;
          end
        end

        ST_PAY: begin
          if (rsp_data_valid && rsp_data_ready) begin
            crc_en <= 1'b1;
            crc_byte <= rsp_data;
            pay_sent <= pay_sent + 1'b1;
            if (pay_sent + 1'b1 >= t_len) begin
              st <= ST_CRC;
              idx <= 4'd0;
            end
          end
        end

        ST_CRC: begin
          if (slip_ready) begin
            if (idx == 4'd3) begin
              slip_end <= 1'b1;
              st <= ST_END;
            end
            idx <= idx + 1'b1;
          end
        end

        ST_END: begin
          if (slip_ready) st <= ST_IDLE;
        end
        default: st <= ST_IDLE;
      endcase
    end
  end

  assign rsp_ready = (st == ST_IDLE);
  assign rsp_data_ready = (st == ST_PAY) && slip_ready;

  assign slip_valid = (st == ST_HDR) || (st == ST_CRC) || (st == ST_PAY && rsp_data_valid);

  assign slip_data = (st == ST_HDR) ? hdr_byte(idx) :
                     (st == ST_PAY) ? rsp_data :
                     (st == ST_CRC) ? ((idx == 0) ? crc_now[31:24] :
                                      (idx == 1) ? crc_now[23:16] :
                                      (idx == 2) ? crc_now[15:8]  :
                                                 crc_now[7:0]) :
                                      8'h00;
endmodule

