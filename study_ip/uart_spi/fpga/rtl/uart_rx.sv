module uart_rx #(
  parameter int unsigned CLK_HZ = 50_000_000,
  parameter int unsigned BAUD   = 921_600
)(
  input  logic       clk,
  input  logic       rst_n,
  input  logic       rx,
  output logic [7:0] data,
  output logic       valid,
  input  logic       ready
);
  localparam int unsigned DIV = (CLK_HZ + BAUD/2) / BAUD;
  localparam int unsigned HALF_DIV = DIV/2;

  typedef enum logic [2:0] {S_IDLE, S_START, S_DATA, S_STOP} state_t;
  state_t st;

  logic [$clog2(DIV+1)-1:0] cnt;
  logic [2:0] bit_idx;
  logic [7:0] shreg;
  logic rx_sync1, rx_sync2;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rx_sync1 <= 1'b1;
      rx_sync2 <= 1'b1;
    end else begin
      rx_sync1 <= rx;
      rx_sync2 <= rx_sync1;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= S_IDLE;
      cnt <= '0;
      bit_idx <= '0;
      shreg <= '0;
      data <= '0;
      valid <= 1'b0;
    end else begin
      if (valid && ready) valid <= 1'b0;
      unique case (st)
        S_IDLE: begin
          cnt <= '0;
          bit_idx <= '0;
          if (!rx_sync2) begin
            st <= S_START;
            cnt <= HALF_DIV[$clog2(DIV+1)-1:0];
          end
        end
        S_START: begin
          if (cnt == 0) begin
            if (!rx_sync2) begin
              st <= S_DATA;
              cnt <= (DIV-1)[$clog2(DIV+1)-1:0];
              bit_idx <= 3'd0;
            end else begin
              st <= S_IDLE;
            end
          end else cnt <= cnt - 1'b1;
        end
        S_DATA: begin
          if (cnt == 0) begin
            shreg <= {rx_sync2, shreg[7:1]};
            cnt <= (DIV-1)[$clog2(DIV+1)-1:0];
            if (bit_idx == 3'd7) begin
              st <= S_STOP;
            end
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

