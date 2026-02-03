module fwu_engine(
  input  logic        clk,
  input  logic        rst_n,

  input  logic        cmd_valid,
  output logic        cmd_ready,
  input  logic [7:0]  cmd_type,
  input  logic [15:0] cmd_seq,
  input  logic [15:0] cmd_len,
  input  logic [7:0]  cmd_data,
  input  logic        cmd_data_valid,
  output logic        cmd_data_ready,
  input  logic        cmd_end,

  output logic        rsp_valid,
  input  logic        rsp_ready,
  output logic [7:0]  rsp_type,
  output logic [15:0] rsp_seq,
  output logic [15:0] rsp_len,
  output logic [7:0]  rsp_data,
  output logic        rsp_data_valid,
  input  logic        rsp_data_ready,
  output logic        rsp_end,

  output logic        flash_cmd_valid,
  input  logic        flash_cmd_ready,
  output logic [7:0]  flash_opcode,
  output logic [23:0] flash_addr,
  output logic [15:0] flash_len,
  output logic        flash_has_addr,
  output logic        flash_is_read,
  output logic        flash_is_write,
  output logic [7:0]  flash_wr_data,
  output logic        flash_wr_valid,
  input  logic        flash_wr_ready,
  input  logic [7:0]  flash_rd_data,
  input  logic        flash_rd_valid,
  output logic        flash_rd_ready,
  input  logic        flash_busy,
  input  logic        flash_done,

  output logic [31:0] progress_written,
  output logic [31:0] progress_crc
);
  import fwu_pkg::*;

  localparam logic [15:0] MAX_PAYLOAD16 = MAX_PAYLOAD;

  typedef enum logic [5:0] {
    ST_IDLE,
    ST_RX_PAYLOAD,
    ST_HELLO_RDID,
    ST_HELLO_WAIT,
    ST_START_DONE,
    ST_ERASE_SETUP,
    ST_ERASE_WREN,
    ST_ERASE_CMD,
    ST_ERASE_POLL,
    ST_ERASE_POLL_WAIT,
    ST_ERASE_NEXT,
    ST_DATA_SETUP,
    ST_DATA_WREN,
    ST_DATA_PP,
    ST_DATA_PP_WAIT,
    ST_DATA_POLL,
    ST_DATA_POLL_WAIT,
    ST_FINISH_CHECK,
    ST_PREP_RSP,
    ST_RSP_WAIT,
    ST_RSP_SEND
  } st_t;
  st_t st;

  logic [7:0]  c_type;
  logic [15:0] c_seq;
  logic [15:0] c_len;
  logic [15:0] rx_idx;

  logic [31:0] base_addr_r;
  logic [31:0] image_size_r;
  logic [31:0] image_crc_r;
  logic [15:0] page_size_r;
  logic [31:0] sector_size_r;

  logic [31:0] written_r;

  logic [7:0] data_buf [0:255];
  logic [31:0] data_off_r;
  logic [15:0] data_len_r;
  logic dup_data;
  logic [15:0] last_data_seq;
  logic [31:0] last_data_off;
  logic [15:0] last_data_len;
  logic        last_data_done;

  logic [31:0] erase_addr_r;
  logic [31:0] erase_rem_r;
  logic [7:0]  status_r;

  logic [7:0] flash_id0, flash_id1, flash_id2;
  logic [1:0] flash_rd_cnt;

  logic crc_init, crc_en;
  logic [7:0] crc_byte;
  logic [31:0] crc_state;
  crc32_ieee u_crc(
    .clk(clk), .rst_n(rst_n),
    .init(crc_init), .en(crc_en), .data(crc_byte),
    .crc(crc_state)
  );

  assign progress_written = written_r;
  assign progress_crc = ~crc_state;

  logic [7:0] rsp_type_r;
  logic [15:0] rsp_seq_r;
  logic [15:0] rsp_len_r;
  logic [7:0] rsp_buf [0:15];
  logic [4:0] rsp_idx;

  logic [7:0] ack_of_type;
  logic [7:0] ack_status;
  logic [15:0] ack_detail;

  logic flash_cmd_valid_r;
  logic [7:0] flash_opcode_r;
  logic [23:0] flash_addr_r;
  logic [15:0] flash_len_r;
  logic flash_has_addr_r;
  logic flash_is_read_r;
  logic flash_is_write_r;

  assign flash_cmd_valid = flash_cmd_valid_r;
  assign flash_opcode = flash_opcode_r;
  assign flash_addr = flash_addr_r;
  assign flash_len = flash_len_r;
  assign flash_has_addr = flash_has_addr_r;
  assign flash_is_read = flash_is_read_r;
  assign flash_is_write = flash_is_write_r;

  logic [15:0] pp_idx;
  logic pp_cmd_sent;
  logic [31:0] pp_addr_sum;
  assign pp_addr_sum = base_addr_r + data_off_r;
  assign flash_wr_data = data_buf[pp_idx];
  assign flash_wr_valid = (st == ST_DATA_PP) && pp_cmd_sent && (pp_idx < data_len_r);
  assign flash_rd_ready = 1'b1;

  function automatic logic [31:0] be32_from_buf(input logic [7:0] b0, input logic [7:0] b1, input logic [7:0] b2, input logic [7:0] b3);
    be32_from_buf = {b0, b1, b2, b3};
  endfunction

  function automatic logic [15:0] be16_from_buf(input logic [7:0] b0, input logic [7:0] b1);
    be16_from_buf = {b0, b1};
  endfunction

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= ST_IDLE;
      c_type <= 8'h00;
      c_seq <= 16'h0000;
      c_len <= 16'd0;
      rx_idx <= 16'd0;
      base_addr_r <= 32'h0;
      image_size_r <= 32'h0;
      image_crc_r <= 32'h0;
      page_size_r <= 16'd256;
      sector_size_r <= 32'd4096;
      written_r <= 32'd0;
      data_off_r <= 32'd0;
      data_len_r <= 16'd0;
      dup_data <= 1'b0;
      last_data_seq <= 16'h0000;
      last_data_off <= 32'h0;
      last_data_len <= 16'd0;
      last_data_done <= 1'b0;
      erase_addr_r <= 32'h0;
      erase_rem_r <= 32'h0;
      status_r <= 8'h00;
      flash_id0 <= 8'h00;
      flash_id1 <= 8'h00;
      flash_id2 <= 8'h00;
      flash_rd_cnt <= 2'd0;
      crc_init <= 1'b1;
      crc_en <= 1'b0;
      crc_byte <= 8'h00;
      rsp_type_r <= 8'h00;
      rsp_seq_r <= 16'h0000;
      rsp_len_r <= 16'd0;
      rsp_idx <= 5'd0;
      ack_of_type <= 8'h00;
      ack_status <= STATUS_OK;
      ack_detail <= 16'h0000;
      flash_cmd_valid_r <= 1'b0;
      flash_opcode_r <= 8'h00;
      flash_addr_r <= 24'h0;
      flash_len_r <= 16'd0;
      flash_has_addr_r <= 1'b0;
      flash_is_read_r <= 1'b0;
      flash_is_write_r <= 1'b0;
      pp_idx <= 16'd0;
      pp_cmd_sent <= 1'b0;
    end else begin
      crc_init <= 1'b0;
      crc_en <= 1'b0;
      flash_cmd_valid_r <= 1'b0;

      if (flash_rd_valid) begin
        if (st == ST_HELLO_WAIT) begin
          if (flash_rd_cnt == 2'd0) flash_id0 <= flash_rd_data;
          if (flash_rd_cnt == 2'd1) flash_id1 <= flash_rd_data;
          if (flash_rd_cnt == 2'd2) flash_id2 <= flash_rd_data;
          flash_rd_cnt <= flash_rd_cnt + 1'b1;
        end else if (st == ST_ERASE_POLL_WAIT || st == ST_DATA_POLL_WAIT) begin
          status_r <= flash_rd_data;
        end
      end

      unique case (st)
        ST_IDLE: begin
          if (cmd_valid) begin
            c_type <= cmd_type;
            c_seq <= cmd_seq;
            c_len <= cmd_len;
            rx_idx <= 16'd0;
            dup_data <= 1'b0;
            if (cmd_len == 0) begin
              if (cmd_type == MSG_HELLO) st <= ST_HELLO_RDID;
              else if (cmd_type == MSG_QUERY) st <= ST_PREP_RSP;
              else if (cmd_type == MSG_FINISH) st <= ST_FINISH_CHECK;
              else begin
                ack_of_type <= cmd_type;
                ack_status <= STATUS_OK;
                ack_detail <= 16'h0000;
                st <= ST_PREP_RSP;
              end
            end else begin
              st <= ST_RX_PAYLOAD;
            end
          end
        end

        ST_RX_PAYLOAD: begin
          if (cmd_data_valid && cmd_data_ready) begin
            if (c_type == MSG_START) begin
              if (rx_idx == 0) base_addr_r[31:24] <= cmd_data;
              if (rx_idx == 1) base_addr_r[23:16] <= cmd_data;
              if (rx_idx == 2) base_addr_r[15:8] <= cmd_data;
              if (rx_idx == 3) base_addr_r[7:0] <= cmd_data;
              if (rx_idx == 4) image_size_r[31:24] <= cmd_data;
              if (rx_idx == 5) image_size_r[23:16] <= cmd_data;
              if (rx_idx == 6) image_size_r[15:8] <= cmd_data;
              if (rx_idx == 7) image_size_r[7:0] <= cmd_data;
              if (rx_idx == 8) image_crc_r[31:24] <= cmd_data;
              if (rx_idx == 9) image_crc_r[23:16] <= cmd_data;
              if (rx_idx == 10) image_crc_r[15:8] <= cmd_data;
              if (rx_idx == 11) image_crc_r[7:0] <= cmd_data;
              if (rx_idx == 12) page_size_r[15:8] <= cmd_data;
              if (rx_idx == 13) page_size_r[7:0] <= cmd_data;
            end else if (c_type == MSG_ERASE) begin
              if (rx_idx == 0) erase_addr_r[31:24] <= cmd_data;
              if (rx_idx == 1) erase_addr_r[23:16] <= cmd_data;
              if (rx_idx == 2) erase_addr_r[15:8] <= cmd_data;
              if (rx_idx == 3) erase_addr_r[7:0] <= cmd_data;
              if (rx_idx == 4) erase_rem_r[31:24] <= cmd_data;
              if (rx_idx == 5) erase_rem_r[23:16] <= cmd_data;
              if (rx_idx == 6) erase_rem_r[15:8] <= cmd_data;
              if (rx_idx == 7) erase_rem_r[7:0] <= cmd_data;
              if (rx_idx == 8) sector_size_r[31:24] <= cmd_data;
              if (rx_idx == 9) sector_size_r[23:16] <= cmd_data;
              if (rx_idx == 10) sector_size_r[15:8] <= cmd_data;
              if (rx_idx == 11) sector_size_r[7:0] <= cmd_data;
            end else if (c_type == MSG_DATA) begin
              if (rx_idx == 0) data_off_r[31:24] <= cmd_data;
              if (rx_idx == 1) data_off_r[23:16] <= cmd_data;
              if (rx_idx == 2) data_off_r[15:8] <= cmd_data;
              if (rx_idx == 3) data_off_r[7:0] <= cmd_data;
              if (rx_idx == 4) data_len_r[15:8] <= cmd_data;
              if (rx_idx == 5) begin
                data_len_r[7:0] <= cmd_data;
                if (cmd_seq == last_data_seq && last_data_done && data_off_r == last_data_off && {data_len_r[15:8], cmd_data} == last_data_len) begin
                  dup_data <= 1'b1;
                end
              end
              if (rx_idx >= 6 && rx_idx < 6 + 256) begin
                data_buf[rx_idx - 6] <= cmd_data;
                if (!dup_data) begin
                  crc_en <= 1'b1;
                  crc_byte <= cmd_data;
                end
              end
            end

            rx_idx <= rx_idx + 1'b1;
            if (cmd_end) begin
              if (c_type == MSG_START) begin
                written_r <= 32'd0;
                last_data_done <= 1'b0;
                crc_init <= 1'b1;
                ack_of_type <= MSG_START;
                ack_status <= STATUS_OK;
                ack_detail <= 16'h0000;
                st <= ST_PREP_RSP;
              end else if (c_type == MSG_ERASE) begin
                st <= ST_ERASE_SETUP;
              end else if (c_type == MSG_DATA) begin
                st <= ST_DATA_SETUP;
              end else begin
                ack_of_type <= c_type;
                ack_status <= STATUS_BAD_STATE;
                ack_detail <= 16'h0001;
                st <= ST_PREP_RSP;
              end
            end
          end
        end

        ST_HELLO_RDID: begin
          if (flash_cmd_ready) begin
            flash_opcode_r <= 8'h9F;
            flash_has_addr_r <= 1'b0;
            flash_addr_r <= 24'h0;
            flash_len_r <= 16'd3;
            flash_is_read_r <= 1'b1;
            flash_is_write_r <= 1'b0;
            flash_cmd_valid_r <= 1'b1;
            flash_rd_cnt <= 2'd0;
            st <= ST_HELLO_WAIT;
          end
        end

        ST_HELLO_WAIT: begin
          if (flash_done) begin
            st <= ST_PREP_RSP;
          end
        end

        ST_ERASE_SETUP: begin
          if (erase_rem_r == 0) begin
            ack_of_type <= MSG_ERASE;
            ack_status <= STATUS_OK;
            ack_detail <= 16'h0000;
            st <= ST_PREP_RSP;
          end else begin
            st <= ST_ERASE_WREN;
          end
        end

        ST_ERASE_WREN: begin
          if (flash_cmd_ready) begin
            flash_opcode_r <= 8'h06;
            flash_has_addr_r <= 1'b0;
            flash_addr_r <= 24'h0;
            flash_len_r <= 16'd0;
            flash_is_read_r <= 1'b0;
            flash_is_write_r <= 1'b0;
            flash_cmd_valid_r <= 1'b1;
            st <= ST_ERASE_CMD;
          end
        end

        ST_ERASE_CMD: begin
          if (flash_cmd_ready) begin
            flash_opcode_r <= 8'h20;
            flash_has_addr_r <= 1'b1;
            flash_addr_r <= erase_addr_r[23:0];
            flash_len_r <= 16'd0;
            flash_is_read_r <= 1'b0;
            flash_is_write_r <= 1'b0;
            flash_cmd_valid_r <= 1'b1;
            st <= ST_ERASE_POLL;
          end
        end

        ST_ERASE_POLL: begin
          if (flash_cmd_ready) begin
            flash_opcode_r <= 8'h05;
            flash_has_addr_r <= 1'b0;
            flash_addr_r <= 24'h0;
            flash_len_r <= 16'd1;
            flash_is_read_r <= 1'b1;
            flash_is_write_r <= 1'b0;
            flash_cmd_valid_r <= 1'b1;
            st <= ST_ERASE_POLL_WAIT;
          end
        end

        ST_ERASE_POLL_WAIT: begin
          if (flash_done) begin
            if (status_r[0]) st <= ST_ERASE_POLL;
            else st <= ST_ERASE_NEXT;
          end
        end

        ST_ERASE_NEXT: begin
          if (erase_rem_r > sector_size_r) erase_rem_r <= erase_rem_r - sector_size_r;
          else erase_rem_r <= 32'd0;
          erase_addr_r <= erase_addr_r + sector_size_r;
          st <= ST_ERASE_SETUP;
        end

        ST_DATA_SETUP: begin
          if (dup_data) begin
            ack_of_type <= MSG_DATA;
            ack_status <= STATUS_OK;
            ack_detail <= 16'h0000;
            st <= ST_PREP_RSP;
          end else begin
            st <= ST_DATA_WREN;
          end
        end

        ST_DATA_WREN: begin
          if (flash_cmd_ready) begin
            flash_opcode_r <= 8'h06;
            flash_has_addr_r <= 1'b0;
            flash_addr_r <= 24'h0;
            flash_len_r <= 16'd0;
            flash_is_read_r <= 1'b0;
            flash_is_write_r <= 1'b0;
            flash_cmd_valid_r <= 1'b1;
            pp_idx <= 16'd0;
            pp_cmd_sent <= 1'b0;
            st <= ST_DATA_PP;
          end
        end

        ST_DATA_PP: begin
          if (!pp_cmd_sent) begin
            if (flash_cmd_ready) begin
              flash_opcode_r <= 8'h02;
              flash_has_addr_r <= 1'b1;
              flash_addr_r <= pp_addr_sum[23:0];
              flash_len_r <= data_len_r;
              flash_is_read_r <= 1'b0;
              flash_is_write_r <= 1'b1;
              flash_cmd_valid_r <= 1'b1;
              pp_cmd_sent <= 1'b1;
            end
          end
          if (flash_wr_valid && flash_wr_ready) begin
            pp_idx <= pp_idx + 1'b1;
          end
          if (pp_cmd_sent && flash_done) begin
            st <= ST_DATA_POLL;
          end
        end

        ST_DATA_POLL: begin
          if (flash_cmd_ready) begin
            flash_opcode_r <= 8'h05;
            flash_has_addr_r <= 1'b0;
            flash_addr_r <= 24'h0;
            flash_len_r <= 16'd1;
            flash_is_read_r <= 1'b1;
            flash_is_write_r <= 1'b0;
            flash_cmd_valid_r <= 1'b1;
            st <= ST_DATA_POLL_WAIT;
          end
        end

        ST_DATA_POLL_WAIT: begin
          if (flash_done) begin
            if (status_r[0]) st <= ST_DATA_POLL;
            else begin
              if (written_r < (data_off_r + data_len_r)) written_r <= (data_off_r + data_len_r);
              last_data_seq <= c_seq;
              last_data_off <= data_off_r;
              last_data_len <= data_len_r;
              last_data_done <= 1'b1;
              ack_of_type <= MSG_DATA;
              ack_status <= STATUS_OK;
              ack_detail <= 16'h0000;
              st <= ST_PREP_RSP;
            end
          end
        end

        ST_FINISH_CHECK: begin
          ack_of_type <= MSG_FINISH;
          if (written_r != image_size_r) begin
            ack_status <= STATUS_BAD_STATE;
            ack_detail <= 16'h0002;
          end else if ((~crc_state) != image_crc_r) begin
            ack_status <= STATUS_FLASH_ERR;
            ack_detail <= 16'h0003;
          end else begin
            ack_status <= STATUS_OK;
            ack_detail <= 16'h0000;
          end
          st <= ST_PREP_RSP;
        end

        ST_PREP_RSP: begin
          rsp_seq_r <= c_seq;
          if (c_type == MSG_HELLO) begin
            rsp_type_r <= MSG_HELLO_RSP;
            rsp_len_r <= 16'd11;
            rsp_buf[0] <= flash_id0;
            rsp_buf[1] <= flash_id1;
            rsp_buf[2] <= flash_id2;
            rsp_buf[3] <= page_size_r[15:8];
            rsp_buf[4] <= page_size_r[7:0];
            rsp_buf[5] <= sector_size_r[31:24];
            rsp_buf[6] <= sector_size_r[23:16];
            rsp_buf[7] <= sector_size_r[15:8];
            rsp_buf[8] <= sector_size_r[7:0];
            rsp_buf[9] <= MAX_PAYLOAD16[15:8];
            rsp_buf[10] <= MAX_PAYLOAD16[7:0];
          end else if (c_type == MSG_QUERY) begin
            rsp_type_r <= MSG_PROGRESS;
            rsp_len_r <= 16'd8;
            rsp_buf[0] <= written_r[31:24];
            rsp_buf[1] <= written_r[23:16];
            rsp_buf[2] <= written_r[15:8];
            rsp_buf[3] <= written_r[7:0];
            rsp_buf[4] <= (~crc_state)[31:24];
            rsp_buf[5] <= (~crc_state)[23:16];
            rsp_buf[6] <= (~crc_state)[15:8];
            rsp_buf[7] <= (~crc_state)[7:0];
          end else begin
            rsp_type_r <= MSG_ACK;
            rsp_len_r <= 16'd4;
            rsp_buf[0] <= ack_of_type;
            rsp_buf[1] <= ack_status;
            rsp_buf[2] <= ack_detail[15:8];
            rsp_buf[3] <= ack_detail[7:0];
          end
          rsp_idx <= 5'd0;
          st <= ST_RSP_WAIT;
        end

        ST_RSP_WAIT: begin
          if (rsp_ready) begin
            st <= ST_RSP_SEND;
          end
        end

        ST_RSP_SEND: begin
          if (rsp_data_valid && rsp_data_ready) begin
            if (rsp_idx == rsp_len_r - 1) begin
              st <= ST_IDLE;
            end
            rsp_idx <= rsp_idx + 1'b1;
          end
        end
        default: st <= ST_IDLE;
      endcase
    end
  end

  assign cmd_ready = (st == ST_IDLE);
  assign cmd_data_ready = (st == ST_RX_PAYLOAD);

  assign rsp_valid = (st == ST_RSP_WAIT);
  assign rsp_type = rsp_type_r;
  assign rsp_seq = rsp_seq_r;
  assign rsp_len = rsp_len_r;

  assign rsp_data = rsp_buf[rsp_idx];
  assign rsp_data_valid = (st == ST_RSP_SEND) && (rsp_idx < rsp_len_r);
  assign rsp_end = rsp_data_valid && rsp_data_ready && (rsp_idx == rsp_len_r - 1);
endmodule
