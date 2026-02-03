`include "fwu_defs.vh"

module spi_flash_ctrl #(
  parameter integer CLK_DIV = 4
)(
  input  clk,
  input  rst_n,

  output reg spi_cs_n,
  output spi_sck,
  output reg spi_mosi,
  input  spi_miso,

  input  cmd_valid,
  output cmd_ready,
  input  [7:0]  cmd_opcode,
  input  [23:0] cmd_addr,
  input  [15:0] cmd_len,
  input  cmd_has_addr,
  input  cmd_is_read,
  input  cmd_is_write,

  input  [7:0] wr_data,
  input  wr_valid,
  output wr_ready,

  output [7:0] rd_data,
  output rd_valid,
  input  rd_ready,

  output busy,
  output reg done
);
  function integer clog2;
    input integer value;
    integer v;
    begin
      v = value - 1;
      for (clog2 = 0; v > 0; clog2 = clog2 + 1) v = v >> 1;
    end
  endfunction

  localparam integer DIV_W = clog2(CLK_DIV + 1);

  localparam [2:0] ST_IDLE      = 3'd0;
  localparam [2:0] ST_LOAD      = 3'd1;
  localparam [2:0] ST_SHIFT     = 3'd2;
  localparam [2:0] ST_BYTE_DONE = 3'd3;
  localparam [2:0] ST_FINISH    = 3'd4;

  reg [2:0] st;

  reg [7:0]  op_r;
  reg [23:0] addr_r;
  reg [15:0] len_r;
  reg has_addr_r;
  reg is_read_r;
  reg is_write_r;

  reg [2:0]  hdr_rem;
  reg [15:0] data_rem;

  reg [7:0] tx_byte;
  reg [7:0] rx_byte;
  reg [7:0] rx_shift;
  reg [2:0] bit_idx;

  reg [DIV_W-1:0] div_cnt;
  reg sck;
  reg sck_en;

  reg rd_valid_r;
  reg [7:0] rd_data_r;


  function [7:0] hdr_sel;
    input [2:0] rem;
    input has_addr;
    input [7:0] op;
    input [23:0] a;
    reg [2:0] idx;
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


  wire [7:0] wire_hdr_sel;
  assign wire_hdr_sel = hdr_sel(hdr_rem, has_addr_r, op_r, addr_r) ;


  assign cmd_ready = (st == ST_IDLE);
  assign busy = (st != ST_IDLE);
  assign spi_sck = sck_en ? sck : 1'b0;
  assign rd_valid = rd_valid_r;
  assign rd_data = rd_data_r;

  wire rd_stall = rd_valid_r && !rd_ready;
  wire need_wr = (st == ST_LOAD) && is_write_r && (hdr_rem == 0) && (data_rem != 0);
  assign wr_ready = need_wr;

  always @(posedge clk or negedge rst_n) begin
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
      div_cnt <= {DIV_W{1'b0}};
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

      case (st)
        ST_IDLE: begin
          spi_cs_n <= 1'b1;
          sck_en <= 1'b0;
          sck <= 1'b0;
          div_cnt <= {DIV_W{1'b0}};
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

            if (hdr_rem != 0) tx_byte <= wire_hdr_sel;
            else if (data_rem != 0) tx_byte <= (is_write_r ? wr_data : 8'h00);
            else tx_byte <= 8'h00;

            if (hdr_rem != 0) spi_mosi <= wire_hdr_sel[7];
            else if (data_rem != 0) spi_mosi <= (is_write_r ? wr_data[7] : 1'b0);
            else spi_mosi <= 1'b0;

            sck <= 1'b0;
            div_cnt <= {DIV_W{1'b0}};
            st <= ST_SHIFT;
          end
        end

        ST_SHIFT: begin
          if (div_cnt == (CLK_DIV-1)) begin
            div_cnt <= {DIV_W{1'b0}};
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
            if (hdr_rem == 3'd1 && data_rem == 16'd0) begin
              st <= ST_FINISH;
              hdr_rem <= 3'd0;
            end else begin
              hdr_rem <= hdr_rem - 1'b1;
              st <= ST_LOAD;
            end
          end else if (data_rem != 0) begin
            if (is_read_r && !rd_valid_r) begin
              rd_valid_r <= 1'b1;
              rd_data_r <= rx_byte;
            end
            if (data_rem == 16'd1) begin
              data_rem <= 16'd0;
              st <= ST_FINISH;
            end else begin
              data_rem <= data_rem - 1'b1;
              st <= ST_LOAD;
            end
          end else begin
            st <= ST_FINISH;
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

