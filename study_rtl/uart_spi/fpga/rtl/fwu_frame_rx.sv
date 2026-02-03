module fwu_frame_rx #(
  parameter int unsigned MAX_PAYLOAD = 1024
)(
  input  logic        clk,
  input  logic        rst_n,

  input  logic [7:0]  in_data,
  input  logic        in_valid,
  output logic        in_ready,
  input  logic        frame_start,
  input  logic        frame_end,
  input  logic        frame_error,

  output logic        cmd_valid,
  input  logic        cmd_ready,
  output logic [7:0]  cmd_type,
  output logic [15:0] cmd_seq,
  output logic [15:0] cmd_len,
  output logic [7:0]  cmd_data,
  output logic        cmd_data_valid,
  input  logic        cmd_data_ready,
  output logic        cmd_end,

  output logic        drop_count_inc
);
  localparam int unsigned MAX_TOTAL = 8 + MAX_PAYLOAD + 4;

  logic [7:0] buf [0:MAX_TOTAL-1];
  logic [$clog2(MAX_TOTAL+1)-1:0] rx_count;
  logic [$clog2(MAX_TOTAL+1)-1:0] exp_total;
  logic exp_set;
  logic rx_active;
  logic rx_bad;

  logic crc_init, crc_en;
  logic [7:0] crc_byte;
  logic [31:0] crc_state;
  crc32_ieee u_crc(
    .clk(clk), .rst_n(rst_n),
    .init(crc_init), .en(crc_en), .data(crc_byte),
    .crc(crc_state)
  );

  logic have_frame;
  logic [15:0] payload_len;
  logic [15:0] payload_idx;
  logic [7:0]  f_type;
  logic [15:0] f_seq;

  typedef enum logic [1:0] {ST_IDLE, ST_COLLECT, ST_WAIT_ACCEPT, ST_PLAY} st_t;
  st_t st;

  function automatic logic [15:0] be16(input logic [7:0] a, input logic [7:0] b);
    be16 = {a, b};
  endfunction
  function automatic logic [31:0] be32(input logic [7:0] a, input logic [7:0] b, input logic [7:0] c, input logic [7:0] d);
    be32 = {a, b, c, d};
  endfunction

  logic [31:0] crc_rx;
  logic [31:0] crc_calc;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= ST_IDLE;
      rx_count <= '0;
      exp_total <= '0;
      exp_set <= 1'b0;
      rx_active <= 1'b0;
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
        rx_count <= '0;
        exp_total <= '0;
        exp_set <= 1'b0;
        rx_active <= 1'b1;
        rx_bad <= 1'b0;
        have_frame <= 1'b0;
        crc_init <= 1'b1;
      end

      if (frame_error) begin
        rx_bad <= 1'b1;
      end

      if (st == ST_COLLECT && in_valid && in_ready) begin
        if (rx_count < MAX_TOTAL[$clog2(MAX_TOTAL+1)-1:0]) begin
          buf[rx_count] <= in_data;
          if (!exp_set || (rx_count < (exp_total - 4))) begin
            crc_en <= 1'b1;
            crc_byte <= in_data;
          end
          rx_count <= rx_count + 1'b1;

          if (rx_count == 7) begin
            if (buf[0] != 8'h55 || buf[1] != 8'hAA || buf[2] != 8'h01) begin
              rx_bad <= 1'b1;
            end
            payload_len <= be16(buf[6], in_data);
            exp_total <= (8 + be16(buf[6], in_data) + 4);
            exp_set <= 1'b1;
            f_type <= buf[3];
            f_seq <= be16(buf[4], buf[5]);
            if ((8 + be16(buf[6], in_data) + 4) > MAX_TOTAL) rx_bad <= 1'b1;
          end
        end else begin
          rx_bad <= 1'b1;
        end
      end

      if (st == ST_COLLECT && frame_end) begin
        rx_active <= 1'b0;
        if (!exp_set) rx_bad <= 1'b1;
        if (exp_set && (rx_count != exp_total)) rx_bad <= 1'b1;
        if (!rx_bad && exp_set) begin
          crc_rx <= be32(buf[exp_total-4], buf[exp_total-3], buf[exp_total-2], buf[exp_total-1]);
          crc_calc <= ~crc_state;
          if (be32(buf[exp_total-4], buf[exp_total-3], buf[exp_total-2], buf[exp_total-1]) != ~crc_state) begin
            rx_bad <= 1'b1;
          end
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
        if (cmd_ready) begin
          st <= ST_PLAY;
        end
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

  assign cmd_data = buf[8 + payload_idx];
  assign cmd_data_valid = (st == ST_PLAY) && (payload_idx < payload_len);
  assign cmd_end = (st == ST_PLAY) && (payload_len != 0) && (payload_idx == payload_len - 1) && cmd_data_valid && cmd_data_ready;
endmodule

