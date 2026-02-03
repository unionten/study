`include "fwu_defs.vh"

module uart_rx #(
  parameter integer CLK_HZ = 50000000,
  parameter integer BAUD   = 921600
)(
  input  clk,
  input  rst_n,
  input  rx,
  output reg [7:0] data,
  output reg valid,
  input  ready
);
  function integer clog2;
    input integer value;
    integer v;
    begin
      v = value - 1;
      for (clog2 = 0; v > 0; clog2 = clog2 + 1) v = v >> 1;
    end
  endfunction

  localparam integer DIV = (CLK_HZ + BAUD/2) / BAUD;
  localparam integer DIV_M1 =  DIV - 1 ;
  localparam integer HALF_DIV = DIV/2;
  localparam integer CNT_W = clog2(DIV + 1);

  localparam [2:0] S_IDLE  = 3'd0;
  localparam [2:0] S_START = 3'd1;
  localparam [2:0] S_DATA  = 3'd2;
  localparam [2:0] S_STOP  = 3'd3;

  reg [2:0] st;
  reg [CNT_W-1:0] cnt;
  reg [2:0] bit_idx;
  reg [7:0] shreg;
  reg rx_sync1;
  reg rx_sync2;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rx_sync1 <= 1'b1;
      rx_sync2 <= 1'b1;
    end else begin
      rx_sync1 <= rx;
      rx_sync2 <= rx_sync1;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= S_IDLE;
      cnt <= {CNT_W{1'b0}};
      bit_idx <= 3'd0;
      shreg <= 8'h00;
      data <= 8'h00;
      valid <= 1'b0;
    end else begin
      if (valid && ready) valid <= 1'b0;
      case (st)
        S_IDLE: begin
          cnt <= {CNT_W{1'b0}};
          bit_idx <= 3'd0;
          if (!rx_sync2) begin
            st <= S_START;
            cnt <= HALF_DIV[CNT_W-1:0];
          end
        end
        S_START: begin
          if (cnt == 0) begin
            if (!rx_sync2) begin
              st <= S_DATA;
              cnt <= DIV_M1[CNT_W-1:0];
              bit_idx <= 3'd0;
            end else begin
              st <= S_IDLE;
            end
          end else cnt <= cnt - 1'b1;
        end
        S_DATA: begin
          if (cnt == 0) begin
            shreg <= {rx_sync2, shreg[7:1]};
            cnt <= DIV_M1[CNT_W-1:0];
            if (bit_idx == 3'd7) st <= S_STOP;
            bit_idx <= bit_idx + 1'b1;
          end else cnt <= cnt - 1'b1;
        end
        S_STOP: begin
          if (cnt == 0) begin
            if (rx_sync2) begin
              if (!valid) begin
                data <= shreg;
                valid <= 1'b1;
              end
            end
            st <= S_IDLE;
          end else cnt <= cnt - 1'b1;
        end
        default: st <= S_IDLE;
      endcase
    end
  end
endmodule

