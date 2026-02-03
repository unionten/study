`include "fwu_defs.vh"

module uart_tx #(
  parameter integer CLK_HZ = 50000000,
  parameter integer BAUD   = 921600
)(
  input  clk,
  input  rst_n,
  output reg tx,
  input  [7:0] data,
  input  valid,
  output ready
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
  
  localparam integer CNT_W = clog2(DIV + 1);

  localparam [2:0] T_IDLE  = 3'd0;
  localparam [2:0] T_START = 3'd1;
  localparam [2:0] T_DATA  = 3'd2;
  localparam [2:0] T_STOP  = 3'd3;

  reg [2:0] st;
  reg [CNT_W-1:0] cnt;
  reg [2:0] bit_idx;
  reg [7:0] shreg;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= T_IDLE;
      tx <= 1'b1;
      cnt <= {CNT_W{1'b0}};
      bit_idx <= 3'd0;
      shreg <= 8'h00;
    end else begin
      case (st)
        T_IDLE: begin
          tx <= 1'b1;
          cnt <= {CNT_W{1'b0}};
          bit_idx <= 3'd0;
          if (valid) begin
            shreg <= data;
            st <= T_START;
            cnt <= DIV_M1[CNT_W-1:0];
            tx <= 1'b0;
          end
        end
        T_START: begin
          if (cnt == 0) begin
            st <= T_DATA;
            cnt <= DIV_M1[CNT_W-1:0];
            tx <= shreg[0];
            bit_idx <= 3'd0;
          end else cnt <= cnt - 1'b1;
        end
        T_DATA: begin
          if (cnt == 0) begin
            if (bit_idx == 3'd7) begin
              st <= T_STOP;
              tx <= 1'b1;
            end else begin
              bit_idx <= bit_idx + 1'b1;
              tx <= shreg[bit_idx + 1'b1];
            end
            cnt <= DIV_M1[CNT_W-1:0];
          end else cnt <= cnt - 1'b1;
        end
        T_STOP: begin
          if (cnt == 0) st <= T_IDLE;
          else cnt <= cnt - 1'b1;
        end
        default: st <= T_IDLE;
      endcase
    end
  end

  assign ready = (st == T_IDLE);
endmodule

