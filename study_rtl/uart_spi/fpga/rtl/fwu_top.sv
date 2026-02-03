module fwu_top #(
  parameter int unsigned CLK_HZ = 50_000_000,
  parameter int unsigned UART_BAUD = 921_600,
  parameter int unsigned SPI_CLK_DIV = 4
)(
  input  logic clk,
  input  logic rst_n,
  input  logic uart_rx,
  output logic uart_tx,
  output logic spi_cs_n,
  output logic spi_sck,
  output logic spi_mosi,
  input  logic spi_miso
);
  import fwu_pkg::*;

  logic [7:0] urx_data;
  logic urx_valid;
  logic urx_ready;
  uart_rx #(.CLK_HZ(CLK_HZ), .BAUD(UART_BAUD)) u_urx(
    .clk(clk), .rst_n(rst_n), .rx(uart_rx),
    .data(urx_data), .valid(urx_valid), .ready(urx_ready)
  );

  logic [7:0] slip_d;
  logic slip_v;
  logic slip_r;
  logic frame_start, frame_end, frame_error;
  slip_rx u_slip_rx(
    .clk(clk), .rst_n(rst_n),
    .in_data(urx_data), .in_valid(urx_valid), .in_ready(urx_ready),
    .out_data(slip_d), .out_valid(slip_v), .out_ready(slip_r),
    .frame_start(frame_start), .frame_end(frame_end), .frame_error(frame_error)
  );

  logic tx_ready;
  logic [7:0] utx_data;
  logic utx_valid;
  uart_tx #(.CLK_HZ(CLK_HZ), .BAUD(UART_BAUD)) u_utx(
    .clk(clk), .rst_n(rst_n), .tx(uart_tx),
    .data(utx_data), .valid(utx_valid), .ready(tx_ready)
  );

  logic slip_tx_start, slip_tx_end;
  logic [7:0] slip_tx_d;
  logic slip_tx_v;
  logic slip_tx_in_ready;
  slip_tx u_slip_tx(
    .clk(clk), .rst_n(rst_n),
    .start(slip_tx_start), .end_frame(slip_tx_end),
    .in_data(slip_tx_d), .in_valid(slip_tx_v), .in_ready(slip_tx_in_ready),
    .out_data(utx_data), .out_valid(utx_valid), .out_ready(tx_ready)
  );

  logic frx_cmd_valid;
  logic frx_cmd_ready;
  logic [7:0] frx_cmd_type;
  logic [15:0] frx_cmd_seq;
  logic [15:0] frx_cmd_len;
  logic [7:0] frx_cmd_data;
  logic frx_cmd_data_valid;
  logic frx_cmd_data_ready;
  logic frx_cmd_end;
  logic frx_drop_inc;

  fwu_frame_rx #(.MAX_PAYLOAD(MAX_PAYLOAD)) u_fwu_rx(
    .clk(clk), .rst_n(rst_n),
    .in_data(slip_d), .in_valid(slip_v), .in_ready(slip_r),
    .frame_start(frame_start), .frame_end(frame_end), .frame_error(frame_error),
    .cmd_valid(frx_cmd_valid), .cmd_ready(frx_cmd_ready),
    .cmd_type(frx_cmd_type), .cmd_seq(frx_cmd_seq), .cmd_len(frx_cmd_len),
    .cmd_data(frx_cmd_data), .cmd_data_valid(frx_cmd_data_valid), .cmd_data_ready(frx_cmd_data_ready),
    .cmd_end(frx_cmd_end),
    .drop_count_inc(frx_drop_inc)
  );

  logic flash_cmd_valid, flash_cmd_ready;
  logic [7:0] flash_opcode;
  logic [23:0] flash_addr;
  logic [15:0] flash_len;
  logic flash_has_addr, flash_is_read, flash_is_write;
  logic [7:0] flash_wr_data;
  logic flash_wr_valid, flash_wr_ready;
  logic [7:0] flash_rd_data;
  logic flash_rd_valid;
  logic flash_rd_ready;
  logic flash_busy, flash_done;
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

  logic eng_rsp_valid, eng_rsp_ready;
  logic [7:0] eng_rsp_type;
  logic [15:0] eng_rsp_seq;
  logic [15:0] eng_rsp_len;
  logic [7:0] eng_rsp_data;
  logic eng_rsp_data_valid;
  logic eng_rsp_data_ready;
  logic eng_rsp_end;

  logic [31:0] progress_written;
  logic [31:0] progress_crc;

  fwu_engine u_eng(
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

  fwu_frame_tx #(.MAX_PAYLOAD(MAX_PAYLOAD)) u_fwu_tx(
    .clk(clk), .rst_n(rst_n),
    .rsp_valid(eng_rsp_valid), .rsp_ready(eng_rsp_ready),
    .rsp_type(eng_rsp_type), .rsp_seq(eng_rsp_seq), .rsp_len(eng_rsp_len),
    .rsp_data(eng_rsp_data), .rsp_data_valid(eng_rsp_data_valid), .rsp_data_ready(eng_rsp_data_ready),
    .rsp_end(eng_rsp_end),
    .slip_start(slip_tx_start), .slip_end(slip_tx_end),
    .slip_data(slip_tx_d), .slip_valid(slip_tx_v), .slip_ready(slip_tx_in_ready)
  );
endmodule
