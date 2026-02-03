`include "fwu_defs.vh"

module fwu_frame_rx #(
  parameter integer MAX_PAYLOAD = `FWU_MAX_PAYLOAD
)(
  input  clk,
  input  rst_n,

  input  [7:0] in_data,
  input  in_valid,
  output in_ready,
  input  frame_start,
  input  frame_end,
  input  frame_error,

  output cmd_valid,
  input  cmd_ready,
  output [7:0]  cmd_type,
  output [15:0] cmd_seq,
  output [15:0] cmd_len,
  output [7:0]  cmd_data,
  output cmd_data_valid,
  input  cmd_data_ready,
  output cmd_end,

  output reg drop_count_inc
);
  function integer clog2;
    input integer value;
    integer v;
    begin
      v = value - 1;
      for (clog2 = 0; v > 0; clog2 = clog2 + 1) v = v >> 1;
    end
  endfunction

  localparam integer MAX_TOTAL = 8 + MAX_PAYLOAD + 4;
  localparam integer CNT_W = clog2(MAX_TOTAL + 1);

  reg [7:0] buf_ [0:MAX_TOTAL-1];
  reg [CNT_W-1:0] rx_count;
  reg [CNT_W-1:0] exp_total;
  reg exp_set;
  reg rx_bad;

  reg crc_init;
  reg crc_en;
  reg [7:0] crc_byte;
  wire [31:0] crc_state;
  crc32_ieee u_crc(
    .clk(clk), .rst_n(rst_n),
    .init(crc_init), .en(crc_en), .data(crc_byte),
    .crc(crc_state)
  );

  reg have_frame;
  reg [15:0] payload_len;
  reg [15:0] payload_idx;
  reg [7:0] f_type;
  reg [15:0] f_seq;

  localparam [1:0] ST_IDLE        = 2'd0;
  localparam [1:0] ST_COLLECT     = 2'd1;
  localparam [1:0] ST_WAIT_ACCEPT = 2'd2;
  localparam [1:0] ST_PLAY        = 2'd3;
  reg [1:0] st;

  wire [31:0] crc_calc = ~crc_state;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= ST_IDLE;
      rx_count <= {CNT_W{1'b0}};
      exp_total <= {CNT_W{1'b0}};
      exp_set <= 1'b0;
      rx_bad <= 1'b0;
      crc_init <= 1'b1;
      crc_en <= 1'b0;
      crc_byte <= 8'h00;
      have_frame <= 1'b0;
      payload_len <= 16'd0;
      payload_idx <= 16'd0;
      f_type <= 8'h00;
      f_seq <= 16'h0000;
      drop_count_inc <= 1'b0;
    end else begin
      drop_count_inc <= 1'b0;
      crc_init <= 1'b0;
      crc_en <= 1'b0;

      if (frame_start) begin
        st <= ST_COLLECT;
        rx_count <= {CNT_W{1'b0}};
        exp_total <= {CNT_W{1'b0}};
        exp_set <= 1'b0;
        rx_bad <= 1'b0;
        have_frame <= 1'b0;
        crc_init <= 1'b1;
      end

      if (frame_error) rx_bad <= 1'b1;

      if (st == ST_COLLECT && in_valid && in_ready) begin
        if (rx_count < MAX_TOTAL[CNT_W-1:0]) begin
          buf_[rx_count] <= in_data;

          if (!exp_set || (rx_count < (exp_total - 4))) begin
            crc_en <= 1'b1;
            crc_byte <= in_data;
          end

          if (rx_count == 7) begin
            if (buf_[0] != 8'h55 || buf_[1] != 8'hAA || buf_[2] != 8'h01) rx_bad <= 1'b1;
            payload_len <= {buf_[6], in_data};
            exp_total <= (8 + {buf_[6], in_data} + 4);
            exp_set <= 1'b1;
            f_type <= buf_[3];
            f_seq <= {buf_[4], buf_[5]};
            if ((8 + {buf_[6], in_data} + 4) > MAX_TOTAL) rx_bad <= 1'b1;
          end

          rx_count <= rx_count + 1'b1;
        end else begin
          rx_bad <= 1'b1;
        end
      end

      if (st == ST_COLLECT && frame_end) begin
        if (!exp_set) rx_bad <= 1'b1;
        if (exp_set && (rx_count != exp_total)) rx_bad <= 1'b1;
        if (!rx_bad && exp_set) begin
          if ({buf_[exp_total-4], buf_[exp_total-3], buf_[exp_total-2], buf_[exp_total-1]} != crc_calc) rx_bad <= 1'b1;
        end

        if (!rx_bad) begin
          have_frame <= 1'b1;
          st <= ST_WAIT_ACCEPT;
          payload_idx <= 16'd0;
        end else begin
          drop_count_inc <= 1'b1;
          st <= ST_IDLE;
        end
      end

      if (st == ST_WAIT_ACCEPT) begin
        if (cmd_ready) st <= ST_PLAY;
      end

      if (st == ST_PLAY) begin
        if (payload_len == 0) begin
          if (cmd_ready) begin
            have_frame <= 1'b0;
            st <= ST_IDLE;
          end
        end else if (cmd_data_valid && cmd_data_ready) begin
          if (payload_idx == payload_len - 1) begin
            have_frame <= 1'b0;
            st <= ST_IDLE;
          end
          payload_idx <= payload_idx + 1'b1;
        end
      end
    end
  end

  assign in_ready = (st == ST_COLLECT);
  assign cmd_valid = (st == ST_WAIT_ACCEPT);
  assign cmd_type = f_type;
  assign cmd_seq = f_seq;
  assign cmd_len = payload_len;

  assign cmd_data = buf_[8 + payload_idx];
  assign cmd_data_valid = (st == ST_PLAY) && (payload_idx < payload_len);
  assign cmd_end = (st == ST_PLAY) && (payload_len != 0) && (payload_idx == payload_len - 1) && cmd_data_valid && cmd_data_ready;
endmodule

