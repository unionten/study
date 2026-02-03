`include "fwu_defs.vh"

module fwu_top #(
  parameter integer CLK_HZ = 50000000,
  parameter integer UART_BAUD = 921600,
  parameter integer SPI_CLK_DIV = 4
)(
  input  clk,
  input  rst_n,
  input  uart_rx,
  output uart_tx,
  output spi_cs_n,
  output spi_sck,
  output spi_mosi,
  input  spi_miso
);
  wire [7:0] urx_data;
  wire urx_valid;
  wire urx_ready;
  uart_rx #(.CLK_HZ(CLK_HZ), .BAUD(UART_BAUD)) u_urx(
    .clk(clk), .rst_n(rst_n), .rx(uart_rx),
    .data(urx_data), .valid(urx_valid), .ready(urx_ready)
  );

  wire [7:0] slip_d;
  wire slip_v;
  wire slip_r;
  wire frame_start;
  wire frame_end;
  wire frame_error;
  slip_rx u_slip_rx(
    .clk(clk), .rst_n(rst_n),
    .in_data(urx_data), .in_valid(urx_valid), .in_ready(urx_ready),
    .out_data(slip_d), .out_valid(slip_v), .out_ready(slip_r),
    .frame_start(frame_start), .frame_end(frame_end), .frame_error(frame_error)
  );

  wire tx_ready;
  wire [7:0] utx_data;
  wire utx_valid;
  uart_tx #(.CLK_HZ(CLK_HZ), .BAUD(UART_BAUD)) u_utx(
    .clk(clk), .rst_n(rst_n), .tx(uart_tx),
    .data(utx_data), .valid(utx_valid), .ready(tx_ready)
  );

  wire slip_tx_start;
  wire slip_tx_end;
  wire [7:0] slip_tx_d;
  wire slip_tx_v;
  wire slip_tx_in_ready;
  slip_tx u_slip_tx(
    .clk(clk), .rst_n(rst_n),
    .start(slip_tx_start), .end_frame(slip_tx_end),
    .in_data(slip_tx_d), .in_valid(slip_tx_v), .in_ready(slip_tx_in_ready),
    .out_data(utx_data), .out_valid(utx_valid), .out_ready(tx_ready)
  );

  wire flash_cmd_valid;
  wire flash_cmd_ready;
  wire [7:0] flash_opcode;
  wire [23:0] flash_addr;
  wire [15:0] flash_len;
  wire flash_has_addr;
  wire flash_is_read;
  wire flash_is_write;
  wire [7:0] flash_wr_data;
  wire flash_wr_valid;
  wire flash_wr_ready;
  wire [7:0] flash_rd_data;
  wire flash_rd_valid;
  wire flash_rd_ready;
  wire flash_busy;
  wire flash_done;
  spi_flash_ctrl #(.CLK_DIV(SPI_CLK_DIV)) u_flash(
    .clk(clk), .rst_n(rst_n),
    .spi_cs_n(spi_cs_n), .spi_sck(spi_sck), .spi_mosi(spi_mosi), .spi_miso(spi_miso),
    .cmd_valid(flash_cmd_valid), .cmd_ready(flash_cmd_ready),
    .cmd_opcode(flash_opcode), .cmd_addr(flash_addr), .cmd_len(flash_len),
    .cmd_has_addr(flash_has_addr), .cmd_is_read(flash_is_read), .cmd_is_write(flash_is_write),
    .wr_data(flash_wr_data), .wr_valid(flash_wr_valid), .wr_ready(flash_wr_ready),
    .rd_data(flash_rd_data), .rd_valid(flash_rd_valid), .rd_ready(flash_rd_ready),
    .busy(flash_busy), .done(flash_done)
  );

  wire frx_cmd_valid;
  wire frx_cmd_ready;
  wire [7:0] frx_cmd_type;
  wire [15:0] frx_cmd_seq;
  wire [15:0] frx_cmd_len;
  wire [7:0] frx_cmd_data;
  wire frx_cmd_data_valid;
  wire frx_cmd_data_ready;
  wire frx_cmd_end;
  wire frx_drop_inc;
  fwu_frame_rx #(.MAX_PAYLOAD(`FWU_MAX_PAYLOAD)) u_fwu_rx(
    .clk(clk), .rst_n(rst_n),
    .in_data(slip_d), .in_valid(slip_v), .in_ready(slip_r),
    .frame_start(frame_start), .frame_end(frame_end), .frame_error(frame_error),
    .cmd_valid(frx_cmd_valid), .cmd_ready(frx_cmd_ready),
    .cmd_type(frx_cmd_type), .cmd_seq(frx_cmd_seq), .cmd_len(frx_cmd_len),
    .cmd_data(frx_cmd_data), .cmd_data_valid(frx_cmd_data_valid), .cmd_data_ready(frx_cmd_data_ready),
    .cmd_end(frx_cmd_end),
    .drop_count_inc(frx_drop_inc)
  );

  wire eng_rsp_valid;
  wire eng_rsp_ready;
  wire [7:0] eng_rsp_type;
  wire [15:0] eng_rsp_seq;
  wire [15:0] eng_rsp_len;
  wire [7:0] eng_rsp_data;
  wire eng_rsp_data_valid;
  wire eng_rsp_data_ready;
  wire eng_rsp_end;
  wire [31:0] progress_written;
  wire [31:0] progress_crc;

  fwu_engine #(.MAX_PAYLOAD(`FWU_MAX_PAYLOAD)) u_eng(
    .clk(clk), .rst_n(rst_n),
    .cmd_valid(frx_cmd_valid), .cmd_ready(frx_cmd_ready),
    .cmd_type(frx_cmd_type), .cmd_seq(frx_cmd_seq), .cmd_len(frx_cmd_len),
    .cmd_data(frx_cmd_data), .cmd_data_valid(frx_cmd_data_valid), .cmd_data_ready(frx_cmd_data_ready),
    .cmd_end(frx_cmd_end),
    .rsp_valid(eng_rsp_valid), .rsp_ready(eng_rsp_ready),
    .rsp_type(eng_rsp_type), .rsp_seq(eng_rsp_seq), .rsp_len(eng_rsp_len),
    .rsp_data(eng_rsp_data), .rsp_data_valid(eng_rsp_data_valid), .rsp_data_ready(eng_rsp_data_ready),
    .rsp_end(eng_rsp_end),
    .flash_cmd_valid(flash_cmd_valid), .flash_cmd_ready(flash_cmd_ready),
    .flash_opcode(flash_opcode), .flash_addr(flash_addr), .flash_len(flash_len),
    .flash_has_addr(flash_has_addr), .flash_is_read(flash_is_read), .flash_is_write(flash_is_write),
    .flash_wr_data(flash_wr_data), .flash_wr_valid(flash_wr_valid), .flash_wr_ready(flash_wr_ready),
    .flash_rd_data(flash_rd_data), .flash_rd_valid(flash_rd_valid), .flash_rd_ready(flash_rd_ready),
    .flash_busy(flash_busy), .flash_done(flash_done),
    .progress_written(progress_written), .progress_crc(progress_crc)
  );

  fwu_frame_tx #(.MAX_PAYLOAD(`FWU_MAX_PAYLOAD)) u_fwu_tx(
    .clk(clk), .rst_n(rst_n),
    .rsp_valid(eng_rsp_valid), .rsp_ready(eng_rsp_ready),
    .rsp_type(eng_rsp_type), .rsp_seq(eng_rsp_seq), .rsp_len(eng_rsp_len),
    .rsp_data(eng_rsp_data), .rsp_data_valid(eng_rsp_data_valid), .rsp_data_ready(eng_rsp_data_ready),
    .rsp_end(eng_rsp_end),
    .slip_start(slip_tx_start), .slip_end(slip_tx_end),
    .slip_data(slip_tx_d), .slip_valid(slip_tx_v), .slip_ready(slip_tx_in_ready)
  );
endmodule

