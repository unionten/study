module fwu_frame_tx #(
  parameter int unsigned MAX_PAYLOAD = 1024
)(
  input  logic        clk,
  input  logic        rst_n,

  input  logic        rsp_valid,
  output logic        rsp_ready,
  input  logic [7:0]  rsp_type,
  input  logic [15:0] rsp_seq,
  input  logic [15:0] rsp_len,
  input  logic [7:0]  rsp_data,
  input  logic        rsp_data_valid,
  output logic        rsp_data_ready,
  input  logic        rsp_end,

  output logic        slip_start,
  output logic        slip_end,
  output logic [7:0]  slip_data,
  output logic        slip_valid,
  input  logic        slip_ready
);
  logic [7:0] t_type;
  logic [15:0] t_seq;
  logic [15:0] t_len;

  typedef enum logic [2:0] {ST_IDLE, ST_HDR, ST_PAY, ST_CRC, ST_END} st_t;
  st_t st;

  logic [3:0] idx;
  logic [31:0] crc_state;
  logic crc_init, crc_en;
  logic [7:0] crc_byte;
  logic [31:0] crc_now;
  crc32_ieee u_crc(
    .clk(clk), .rst_n(rst_n),
    .init(crc_init), .en(crc_en), .data(crc_byte),
    .crc(crc_state)
  );
  logic [15:0] pay_sent;

  assign crc_now = ~crc_state;

  function automatic logic [7:0] hdr_byte(input logic [3:0] i);
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
  endfunction

  always_ff @(posedge clk or negedge rst_n) begin
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

      unique case (st)
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
            end else begin
              idx <= idx + 1'b1;
            end
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
            if (idx == 3) begin
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

  assign slip_valid = (st == ST_HDR) || (st == ST_CRC) || (st == ST_PAY && rsp_data_valid);

  always_comb begin
    slip_data = 8'h00;
    if (st == ST_HDR) slip_data = hdr_byte(idx);
    else if (st == ST_PAY) slip_data = rsp_data;
    else if (st == ST_CRC) begin
      case (idx)
        4'd0: slip_data = crc_now[31:24];
        4'd1: slip_data = crc_now[23:16];
        4'd2: slip_data = crc_now[15:8];
        default: slip_data = crc_now[7:0];
      endcase
    end
  end

  assign rsp_data_ready = (st == ST_PAY) && slip_ready;
endmodule
