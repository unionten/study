module uart_tx #(
  parameter int unsigned CLK_HZ = 50_000_000,
  parameter int unsigned BAUD   = 921_600
)(
  input  logic       clk,
  input  logic       rst_n,
  output logic       tx,
  input  logic [7:0] data,
  input  logic       valid,
  output logic       ready
);
  localparam int unsigned DIV = (CLK_HZ + BAUD/2) / BAUD;

  typedef enum logic [2:0] {T_IDLE, T_START, T_DATA, T_STOP} state_t;
  state_t st;
  logic [$clog2(DIV+1)-1:0] cnt;
  logic [2:0] bit_idx;
  logic [7:0] shreg;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= T_IDLE;
      tx <= 1'b1;
      cnt <= '0;
      bit_idx <= '0;
      shreg <= '0;
    end else begin
      unique case (st)
        T_IDLE: begin
          tx <= 1'b1;
          cnt <= '0;
          bit_idx <= '0;
          if (valid) begin
            shreg <= data;
            st <= T_START;
            cnt <= (DIV-1)[$clog2(DIV+1)-1:0];
            tx <= 1'b0;
          end
        end
        T_START: begin
          if (cnt == 0) begin
            st <= T_DATA;
            cnt <= (DIV-1)[$clog2(DIV+1)-1:0];
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
            cnt <= (DIV-1)[$clog2(DIV+1)-1:0];
          end else cnt <= cnt - 1'b1;
        end
        T_STOP: begin
          if (cnt == 0) begin
            st <= T_IDLE;
          end else cnt <= cnt - 1'b1;
        end
        default: st <= T_IDLE;
      endcase
    end
  end

  assign ready = (st == T_IDLE);
endmodule

