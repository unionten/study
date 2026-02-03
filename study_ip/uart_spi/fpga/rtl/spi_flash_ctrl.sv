module spi_flash_ctrl #(
  parameter int unsigned CLK_DIV = 4
)(
  input  logic        clk,
  input  logic        rst_n,

  output logic        spi_cs_n,
  output logic        spi_sck,
  output logic        spi_mosi,
  input  logic        spi_miso,

  input  logic        cmd_valid,
  output logic        cmd_ready,
  input  logic [7:0]  cmd_opcode,
  input  logic [23:0] cmd_addr,
  input  logic [15:0] cmd_len,
  input  logic        cmd_has_addr,
  input  logic        cmd_is_read,
  input  logic        cmd_is_write,

  input  logic [7:0]  wr_data,
  input  logic        wr_valid,
  output logic        wr_ready,

  output logic [7:0]  rd_data,
  output logic        rd_valid,
  input  logic        rd_ready,

  output logic        busy,
  output logic        done
);
  typedef enum logic [2:0] {ST_IDLE, ST_LOAD, ST_SHIFT, ST_BYTE_DONE, ST_FINISH} st_t;
  st_t st;

  logic [7:0]  op_r;
  logic [23:0] addr_r;
  logic [15:0] len_r;
  logic        has_addr_r;
  logic        is_read_r;
  logic        is_write_r;

  logic [2:0]  hdr_rem;
  logic [15:0] data_rem;

  logic [7:0] tx_byte;
  logic [7:0] rx_byte;
  logic [7:0] rx_shift;
  logic [2:0] bit_idx;

  logic [$clog2(CLK_DIV+1)-1:0] div_cnt;
  logic sck;
  logic sck_en;

  logic rd_valid_r;
  logic [7:0] rd_data_r;

  function automatic logic [7:0] hdr_sel(
    input logic [2:0] rem,
    input logic        has_addr,
    input logic [7:0]  op,
    input logic [23:0] a
  );
    logic [2:0] idx;
    begin
      idx = (has_addr ? 3'd4 : 3'd1) - rem;
      case (idx)
        3'd0: hdr_sel = op;
        3'd1: hdr_sel = a[23:16];
        3'd2: hdr_sel = a[15:8];
        default: hdr_sel = a[7:0];
      endcase
    end
  endfunction

  assign cmd_ready = (st == ST_IDLE);
  assign busy = (st != ST_IDLE);
  assign spi_sck = sck_en ? sck : 1'b0;
  assign rd_valid = rd_valid_r;
  assign rd_data = rd_data_r;

  wire rd_stall = rd_valid_r && !rd_ready;
  wire need_wr = (st == ST_LOAD) && is_write_r && (hdr_rem == 0) && (data_rem != 0);
  assign wr_ready = need_wr;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= ST_IDLE;
      op_r <= 8'h00;
      addr_r <= 24'h0;
      len_r <= 16'd0;
      has_addr_r <= 1'b0;
      is_read_r <= 1'b0;
      is_write_r <= 1'b0;
      hdr_rem <= 3'd0;
      data_rem <= 16'd0;
      tx_byte <= 8'h00;
      rx_byte <= 8'h00;
      rx_shift <= 8'h00;
      bit_idx <= 3'd7;
      div_cnt <= '0;
      sck <= 1'b0;
      sck_en <= 1'b0;
      spi_cs_n <= 1'b1;
      spi_mosi <= 1'b0;
      rd_valid_r <= 1'b0;
      rd_data_r <= 8'h00;
      done <= 1'b0;
    end else begin
      done <= 1'b0;
      if (rd_valid_r && rd_ready) rd_valid_r <= 1'b0;

      unique case (st)
        ST_IDLE: begin
          spi_cs_n <= 1'b1;
          sck_en <= 1'b0;
          sck <= 1'b0;
          div_cnt <= '0;
          if (cmd_valid) begin
            op_r <= cmd_opcode;
            addr_r <= cmd_addr;
            len_r <= cmd_len;
            has_addr_r <= cmd_has_addr;
            is_read_r <= cmd_is_read;
            is_write_r <= cmd_is_write;
            hdr_rem <= cmd_has_addr ? 3'd4 : 3'd1;
            data_rem <= cmd_len;
            spi_cs_n <= 1'b0;
            st <= ST_LOAD;
          end
        end

        ST_LOAD: begin
          sck_en <= 1'b1;
          if (rd_stall) begin
          end else if (need_wr && !wr_valid) begin
          end else begin
            rx_shift <= 8'h00;
            bit_idx <= 3'd7;
            if (hdr_rem != 0) begin
              tx_byte <= hdr_sel(hdr_rem, has_addr_r, op_r, addr_r);
            end else if (data_rem != 0) begin
              tx_byte <= is_write_r ? wr_data : 8'h00;
            end else begin
              tx_byte <= 8'h00;
            end
            spi_mosi <= (hdr_rem != 0) ? hdr_sel(hdr_rem, has_addr_r, op_r, addr_r)[7] : (is_write_r ? wr_data[7] : 1'b0);
            sck <= 1'b0;
            div_cnt <= '0;
            st <= ST_SHIFT;
          end
        end

        ST_SHIFT: begin
          if (div_cnt == (CLK_DIV-1)) begin
            div_cnt <= '0;
            sck <= ~sck;
            if (!sck) begin
              rx_shift <= {rx_shift[6:0], spi_miso};
            end else begin
              if (bit_idx == 0) begin
                rx_byte <= rx_shift;
                st <= ST_BYTE_DONE;
              end else begin
                bit_idx <= bit_idx - 1'b1;
                spi_mosi <= tx_byte[bit_idx - 1'b1];
              end
            end
          end else begin
            div_cnt <= div_cnt + 1'b1;
          end
        end

        ST_BYTE_DONE: begin
          if (hdr_rem != 0) begin
            hdr_rem <= hdr_rem - 1'b1;
          end else if (data_rem != 0) begin
            data_rem <= data_rem - 1'b1;
            if (is_read_r && !rd_valid_r) begin
              rd_valid_r <= 1'b1;
              rd_data_r <= rx_byte;
            end
          end

          if ((hdr_rem == 1) && (data_rem == 0)) begin
            st <= ST_FINISH;
          end else if ((hdr_rem == 0) && (data_rem == 1)) begin
            st <= ST_FINISH;
          end else if ((hdr_rem == 0) && (data_rem == 0)) begin
            st <= ST_FINISH;
          end else begin
            st <= ST_LOAD;
          end
        end

        ST_FINISH: begin
          spi_cs_n <= 1'b1;
          sck_en <= 1'b0;
          done <= 1'b1;
          st <= ST_IDLE;
        end
        default: st <= ST_IDLE;
      endcase
    end
  end
endmodule
