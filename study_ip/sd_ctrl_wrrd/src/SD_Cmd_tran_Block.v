module SD_Cmd_tran_Block (
      input                       i_clk,  //FOD 200Khz
      input                       i_rst_n   ,

      input                       w_clk100M,
      //SD CMD bus
      // inout                       b_sd_cmd  ,
      input                       i_sd_cs_n ,
      output  reg sd_cmd_o,
      input       sd_cmd_i,

      input                       i_cmd_tran_dval ,
      input   wire  [ 5:0]        i_cmd_index     ,
      input   wire  [31:0]        i_cmd_argument  ,
      output  reg   [ 3:0]        o_cmd_tran_reg  ,//1000 done ,1001 no response ,1010 CRC err
      output  reg                 sd_cmd_dir      ,

      output  wire  [ 31:0]       R1_RESP         ,
      output  wire  [119:0]       R2_RESP         ,
      output  wire  [ 31:0]       R3_RESP         ,
      output  wire  [ 31:0]       R6_RESP         ,
      output  wire  [ 11:0]       R7_RESP

);


localparam STATE_IDLE   = 5'd0;
localparam STATE_WAIT   = 5'd1;
localparam STATE_TRAN   = 5'd2;
localparam STATE_R1_WAIT= 5'd3;
localparam STATE_R1     = 5'd4;
localparam STATE_R2_WAIT= 5'd5;
localparam STATE_R2     = 5'd6;
localparam STATE_R3_WAIT= 5'd7;
localparam STATE_R3     = 5'd8;
localparam STATE_R6_WAIT= 5'd9;
localparam STATE_R6     = 5'd10;
localparam STATE_R7_WAIT= 5'd11;
localparam STATE_R7     = 5'd12;
localparam STATE_CRC    = 5'd13;
localparam STATE_NORESP = 5'd14;
localparam STATE_WAIT0  = 5'd15;
localparam STATE_DONE   = 5'd16;

reg [4:0]       Current_state ;
reg [4:0]       Next_state    ;

reg [9:0]       r_cmd_cnt     ;
reg [9:0]       r_cmd_cnt1    ;
reg             r_time_out    ;

reg [ 39:0]     r_cmd_reg     ;

reg [ 31:0]     r_R1_RESP     ;
reg [119:0]     r_R2_RESP     ;
reg [ 31:0]     r_R3_RESP     ;
reg [ 31:0]     r_R6_RESP     ;
reg [ 11:0]     r_R7_RESP     ;

reg             r_crc_dval    ;
reg    [6:0]    r_crc_data    ;

wire            inv;

assign  inv = sd_cmd_i ^ r_crc_data[6];

//
wire  sd_cmd_i    ;
reg   r_sd_cmd_i  ;


// assign b_sd_cmd = sd_cmd_dir ? sd_cmd_o : 1'bz;
// assign sd_cmd_i = b_sd_cmd;


reg [1:0]  r_cmd_tran_dval;
always @ (posedge i_clk or negedge i_rst_n)
  if(~i_rst_n)
    r_cmd_tran_dval <= 2'b0;
  else begin
    r_cmd_tran_dval[0] <= i_cmd_tran_dval;
    r_cmd_tran_dval[1] <= r_cmd_tran_dval[0];
  end

// always @ (posedge i_clk or negedge i_rst_n)
// if(~i_rst_n)
	// sd_cmd_i <= 1'b1;
// else
  // sd_cmd_i <= b_sd_cmd;

always @ (posedge i_clk or negedge i_rst_n)
  if(~i_rst_n)
    Current_state <= STATE_IDLE;
  else
    Current_state <= Next_state;

always @ (*)
  if(~i_rst_n)
    Next_state <= STATE_IDLE;
  else case(Current_state)
    STATE_IDLE   :Next_state <= (r_cmd_tran_dval == 2'b01) ? STATE_WAIT : STATE_IDLE;
    STATE_WAIT   :Next_state <= STATE_TRAN;
    STATE_TRAN   :case(i_cmd_index)
                    6'd0 : Next_state <= (r_cmd_cnt < 10'd56) ? STATE_TRAN : STATE_DONE; //wait for Ncc cycles(8 clocks)
                    6'd2 : Next_state <= (r_cmd_cnt < 10'd50) ? STATE_TRAN : STATE_R2_WAIT; //R2 response Ncr cycles(2-64 clocks)
                    6'd3 : Next_state <= (r_cmd_cnt < 10'd50) ? STATE_TRAN : STATE_R6_WAIT; //R6 response Ncr cycles(2-64 clocks)
                    6'd6 : Next_state <= (r_cmd_cnt < 10'd50) ? STATE_TRAN : STATE_R1_WAIT; //R1 response Ncr cycles(2-64 clocks)
                    6'd7 : Next_state <= (r_cmd_cnt < 10'd50) ? STATE_TRAN : STATE_R1_WAIT; //R1 response Ncr cycles(2-64 clocks)
                    6'd8 : Next_state <= (r_cmd_cnt < 10'd50) ? STATE_TRAN : STATE_R7_WAIT; //R7 response Ncr cycles(2-64 clocks)
                    6'd9 : Next_state <= (r_cmd_cnt < 10'd50) ? STATE_TRAN : STATE_R2_WAIT; //R2 response Ncr cycles(2-64 clocks)
                    6'd11: Next_state <= (r_cmd_cnt < 10'd50) ? STATE_TRAN : STATE_R1_WAIT; //R1 response Ncr cycles(2-64 clocks)
                    6'd12: Next_state <= (r_cmd_cnt < 10'd50) ? STATE_TRAN : STATE_R1_WAIT; //R1 response Ncr cycles(2-64 clocks)
                    6'd13: Next_state <= (r_cmd_cnt < 10'd50) ? STATE_TRAN : STATE_R1_WAIT; //R1 response Ncr cycles(2-64 clocks)
                    6'd16: Next_state <= (r_cmd_cnt < 10'd50) ? STATE_TRAN : STATE_R1_WAIT; //R1 response Ncr cycles(2-64 clocks)
                    6'd17: Next_state <= (r_cmd_cnt < 10'd50) ? STATE_TRAN : STATE_R1_WAIT; //R1 response Ncr cycles(2-64 clocks)
                    6'd18: Next_state <= (r_cmd_cnt < 10'd50) ? STATE_TRAN : STATE_R1_WAIT; //R1 response Ncr cycles(2-64 clocks)
                    6'd24: Next_state <= (r_cmd_cnt < 10'd50) ? STATE_TRAN : STATE_R1_WAIT; //R1 response Ncr cycles(2-64 clocks)
                    6'd23: Next_state <= (r_cmd_cnt < 10'd50) ? STATE_TRAN : STATE_R1_WAIT; //R1 response Ncr cycles(2-64 clocks)
                    6'd25: Next_state <= (r_cmd_cnt < 10'd50) ? STATE_TRAN : STATE_R1_WAIT; //R1 response Ncr cycles(2-64 clocks)
                    6'd41: Next_state <= (r_cmd_cnt < 10'd50) ? STATE_TRAN : STATE_R3_WAIT; //R3 Response Nid cycles(5 clocks)
                    6'd42: Next_state <= (r_cmd_cnt < 10'd50) ? STATE_TRAN : STATE_R1_WAIT; //R3 Response Nid cycles(5 clocks)
                    6'd51: Next_state <= (r_cmd_cnt < 10'd50) ? STATE_TRAN : STATE_R1_WAIT; //R1 response Ncr cycles(2-64 clocks)
                    6'd55: Next_state <= (r_cmd_cnt < 10'd50) ? STATE_TRAN : STATE_R1_WAIT; //R1 response Ncr cycles(2-64 clocks)
                  default: Next_state <= STATE_NORESP;
                endcase
    STATE_R1_WAIT :Next_state <= (r_cmd_cnt  == 10'd114)  ? STATE_NORESP : sd_cmd_i ? STATE_R1_WAIT : STATE_R1;
    STATE_R1      :Next_state <= (r_cmd_cnt1 == 10'd40)   ? STATE_CRC    : STATE_R1;
    STATE_R2_WAIT :Next_state <= (r_cmd_cnt  == 10'd114)  ? STATE_NORESP : sd_cmd_i ? STATE_R2_WAIT : STATE_R2;
    STATE_R2      :Next_state <= (r_cmd_cnt1 == 10'd128)  ? STATE_CRC    : STATE_R2;
    STATE_R3_WAIT :Next_state <= (r_cmd_cnt  == 10'd55)   ? STATE_NORESP : sd_cmd_i ? STATE_R3_WAIT : STATE_R3;
    STATE_R3      :Next_state <= (r_cmd_cnt1 == 10'd40)   ? STATE_CRC    : STATE_R3;
    STATE_R6_WAIT :Next_state <= (r_cmd_cnt  == 10'd114)  ? STATE_NORESP : sd_cmd_i ? STATE_R6_WAIT : STATE_R6;
    STATE_R6      :Next_state <= (r_cmd_cnt1 == 10'd40)   ? STATE_CRC    : STATE_R6;
    STATE_R7_WAIT :Next_state <= (r_cmd_cnt  == 10'd114)  ? STATE_NORESP : sd_cmd_i ? STATE_R7_WAIT : STATE_R7;
    STATE_R7      :Next_state <= (r_cmd_cnt1 == 10'd40)   ? STATE_CRC    : STATE_R7;
    STATE_CRC     :Next_state <= (r_cmd_cnt  == 10'd8)    ? STATE_WAIT0  : STATE_CRC;
    STATE_NORESP  :Next_state <= STATE_DONE;
    STATE_WAIT0   :Next_state <= (r_cmd_cnt  == 10'd10)   ? STATE_DONE   : STATE_WAIT0;
    STATE_DONE    :Next_state <= STATE_IDLE;
    default       :;
  endcase


always @ (posedge i_clk or negedge i_rst_n)
  if(~i_rst_n)begin
    r_cmd_cnt   <= 10'd0;
    r_cmd_cnt1  <= 10'd0;
  end else case(Next_state)
    STATE_IDLE    : begin r_cmd_cnt <= 10'd0;            r_cmd_cnt1 <= 10'd0;             end
    STATE_WAIT    : begin r_cmd_cnt <= 10'd0;            r_cmd_cnt1 <= 10'd0;             end
    STATE_TRAN    : begin r_cmd_cnt <= r_cmd_cnt + 1'd1; r_cmd_cnt1 <= 10'd0;             end
    STATE_R1_WAIT : begin r_cmd_cnt <= r_cmd_cnt + 1'd1; r_cmd_cnt1 <= 10'd0;             end
    STATE_R1      : begin r_cmd_cnt <= 10'd0;            r_cmd_cnt1 <= r_cmd_cnt1 + 1'd1; end
    STATE_R2_WAIT : begin r_cmd_cnt <= r_cmd_cnt + 1'd1; r_cmd_cnt1 <= 10'd0;             end
    STATE_R2      : begin r_cmd_cnt <= 10'd0;            r_cmd_cnt1 <= r_cmd_cnt1 + 1'd1; end
    STATE_R3_WAIT : begin r_cmd_cnt <= r_cmd_cnt + 1'd1; r_cmd_cnt1 <= 10'd0;             end
    STATE_R3      : begin r_cmd_cnt <= 10'd0;            r_cmd_cnt1 <= r_cmd_cnt1 + 1'd1; end
    STATE_R6_WAIT : begin r_cmd_cnt <= r_cmd_cnt + 1'd1; r_cmd_cnt1 <= 10'd0;             end
    STATE_R6      : begin r_cmd_cnt <= 10'd0;            r_cmd_cnt1 <= r_cmd_cnt1 + 1'd1; end
    STATE_R7_WAIT : begin r_cmd_cnt <= r_cmd_cnt + 1'd1; r_cmd_cnt1 <= 10'd0;             end
    STATE_R7      : begin r_cmd_cnt <= 10'd0;            r_cmd_cnt1 <= r_cmd_cnt1 + 1'd1; end
    STATE_CRC     : begin r_cmd_cnt <= r_cmd_cnt + 1'd1; r_cmd_cnt1 <= 10'd0;             end
    STATE_NORESP  : begin r_cmd_cnt <= 10'd0;            r_cmd_cnt1 <= 10'd0;             end
    STATE_WAIT0   : begin r_cmd_cnt <= r_cmd_cnt + 1'd1; r_cmd_cnt1 <= 10'd0;             end
    STATE_DONE    : begin r_cmd_cnt <= 10'd0;            r_cmd_cnt1 <= 10'd0;             end
    default:;
  endcase

always @ (posedge i_clk or negedge i_rst_n)
  if(~i_rst_n) begin
    sd_cmd_dir <= 1'b1;
    sd_cmd_o   <= 1'b1;
    r_cmd_reg  <= 40'b0;
  end  else case(Next_state)
    STATE_IDLE    : begin sd_cmd_dir <= 1'b1; sd_cmd_o <= 1'b1; r_cmd_reg  <= {2'b01,i_cmd_index,i_cmd_argument}; end
    STATE_WAIT    : begin sd_cmd_dir <= 1'b1; sd_cmd_o <= 1'b1; r_cmd_reg  <= {2'b01,i_cmd_index,i_cmd_argument}; end
    STATE_TRAN    : begin sd_cmd_dir <= 1'b1;
                          r_cmd_reg  <= {r_cmd_reg[38:0],r_cmd_reg[39]};
                          if(r_cmd_cnt <= 10'd39)
                              sd_cmd_o <= r_cmd_reg[39];
                          else if(r_cmd_cnt <= 10'd47)
                              sd_cmd_o <= r_crc_data[6];
                          else
                              sd_cmd_o <= 1'd1;
                    end
    STATE_R1_WAIT : begin sd_cmd_dir <= 1'b0; sd_cmd_o <= 1'b1; r_cmd_reg  <= 40'b0; end
    STATE_R1      : begin sd_cmd_dir <= 1'b0; sd_cmd_o <= 1'b1; r_cmd_reg  <= 40'b0; end
    STATE_R2_WAIT : begin sd_cmd_dir <= 1'b0; sd_cmd_o <= 1'b1; r_cmd_reg  <= 40'b0; end
    STATE_R2      : begin sd_cmd_dir <= 1'b0; sd_cmd_o <= 1'b1; r_cmd_reg  <= 40'b0; end
    STATE_R3_WAIT : begin sd_cmd_dir <= 1'b0; sd_cmd_o <= 1'b1; r_cmd_reg  <= 40'b0; end
    STATE_R3      : begin sd_cmd_dir <= 1'b0; sd_cmd_o <= 1'b1; r_cmd_reg  <= 40'b0; end
    STATE_R6_WAIT : begin sd_cmd_dir <= 1'b0; sd_cmd_o <= 1'b1; r_cmd_reg  <= 40'b0; end
    STATE_R6      : begin sd_cmd_dir <= 1'b0; sd_cmd_o <= 1'b1; r_cmd_reg  <= 40'b0; end
    STATE_R7_WAIT : begin sd_cmd_dir <= 1'b0; sd_cmd_o <= 1'b1; r_cmd_reg  <= 40'b0; end
    STATE_R7      : begin sd_cmd_dir <= 1'b0; sd_cmd_o <= 1'b1; r_cmd_reg  <= 40'b0; end
    STATE_CRC     : begin sd_cmd_dir <= 1'b0; sd_cmd_o <= 1'b1; r_cmd_reg  <= 40'b0; end
    STATE_NORESP  : begin sd_cmd_dir <= 1'b1; sd_cmd_o <= 1'b1; r_cmd_reg  <= 40'b0; end
    STATE_WAIT0   : begin sd_cmd_dir <= 1'b1; sd_cmd_o <= 1'b1; r_cmd_reg  <= 40'b0; end
    STATE_DONE    : begin sd_cmd_dir <= 1'b1; sd_cmd_o <= 1'b1; r_cmd_reg  <= 40'b0; end
    default:;
  endcase

always @ (posedge i_clk or negedge i_rst_n)
  if(~i_rst_n) begin
    r_R1_RESP <=  32'b0;
    r_R2_RESP <= 120'b0;
    r_R3_RESP <=  32'b0;
    r_R6_RESP <=  32'b0;
    r_R7_RESP <=  12'b0;
  end else case(Next_state)
    STATE_IDLE:  begin
                  r_R1_RESP <= r_R1_RESP;
                  r_R2_RESP <= r_R2_RESP;
                  r_R3_RESP <= r_R3_RESP;
                  r_R6_RESP <= r_R6_RESP;
                  r_R7_RESP <= r_R7_RESP;
                end
    STATE_R1  :begin
                  r_R1_RESP <= (r_cmd_cnt1 < 10'd8) ? 32'b0 : {r_R1_RESP[30:0],sd_cmd_i};
                  r_R2_RESP <= 120'b0;
                  r_R3_RESP <=  32'b0;
                  r_R6_RESP <=  32'b0;
                  r_R7_RESP <=  12'b0;
                end
    STATE_R2  :begin
                  r_R1_RESP <= 32'b0;
                  r_R2_RESP <= (r_cmd_cnt1 < 10'd8) ? 120'b0 : {r_R2_RESP[118:0],sd_cmd_i};
                  r_R3_RESP <= 32'b0;
                  r_R6_RESP <= 32'b0;
                  r_R7_RESP <= 12'b0;
                end
    STATE_R3  :begin
                  r_R1_RESP <=  32'b0;
                  r_R2_RESP <= 120'b0;
                  r_R3_RESP <= (r_cmd_cnt1 < 10'd8) ? 32'b0 : {r_R3_RESP[30:0],sd_cmd_i};
                  r_R6_RESP <=  32'b0;
                  r_R7_RESP <=  12'b0;
                end
    STATE_R6  :begin
                  r_R1_RESP <=  32'b0;
                  r_R2_RESP <= 120'b0;
                  r_R3_RESP <=  32'b0;
                  r_R6_RESP <= (r_cmd_cnt1 < 10'd8) ? 32'b0 : {r_R6_RESP[30:0],sd_cmd_i};
                  r_R7_RESP <=  12'b0;
                end
    STATE_R7  :begin
                  r_R1_RESP <=  32'b0;
                  r_R2_RESP <= 120'b0;
                  r_R3_RESP <=  32'b0;
                  r_R6_RESP <=  32'b0;
                  r_R7_RESP <= (r_cmd_cnt1 < 10'd28) ? 12'b0 : {r_R7_RESP[10:0],sd_cmd_i};
                end
    STATE_CRC  :begin
                  r_R1_RESP <= r_R1_RESP;
                  r_R2_RESP <= r_R2_RESP;
                  r_R3_RESP <= r_R3_RESP;
                  r_R6_RESP <= r_R6_RESP;
                  r_R7_RESP <= r_R7_RESP;
                end
    STATE_WAIT0:begin
                  r_R1_RESP <= r_R1_RESP;
                  r_R2_RESP <= r_R2_RESP;
                  r_R3_RESP <= r_R3_RESP;
                  r_R6_RESP <= r_R6_RESP;
                  r_R7_RESP <= r_R7_RESP;
                end
    STATE_DONE:begin
                  r_R1_RESP <= r_R1_RESP;
                  r_R2_RESP <= r_R2_RESP;
                  r_R3_RESP <= r_R3_RESP;
                  r_R6_RESP <= r_R6_RESP;
                  r_R7_RESP <= r_R7_RESP;
                end
    default    :  begin
                  r_R1_RESP <=  32'b0;
                  r_R2_RESP <= 120'b0;
                  r_R3_RESP <=  32'b0;
                  r_R6_RESP <=  32'b0;
                  r_R7_RESP <=  12'b0;
                end
    endcase

always @ (posedge i_clk or negedge i_rst_n)
  if(~i_rst_n)
    o_cmd_tran_reg <= 4'b0;
  else case(Next_state)
    STATE_IDLE    : o_cmd_tran_reg <= {1'b0,o_cmd_tran_reg[2:0]};
    STATE_WAIT    : o_cmd_tran_reg <= 4'b0;
    STATE_TRAN    : o_cmd_tran_reg <= 4'b0;
    STATE_R1_WAIT : o_cmd_tran_reg <= 4'b0;
    STATE_R1      : o_cmd_tran_reg <= 4'b0;
    STATE_R2_WAIT : o_cmd_tran_reg <= 4'b0;
    STATE_R2      : o_cmd_tran_reg <= 4'b0;
    STATE_R3_WAIT : o_cmd_tran_reg <= 4'b0;
    STATE_R3      : o_cmd_tran_reg <= 4'b0;
    STATE_R6_WAIT : o_cmd_tran_reg <= 4'b0;
    STATE_R6      : o_cmd_tran_reg <= 4'b0;
    STATE_R7_WAIT : o_cmd_tran_reg <= 4'b0;
    STATE_R7      : o_cmd_tran_reg <= 4'b0;
    STATE_CRC     : o_cmd_tran_reg <= o_cmd_tran_reg[1] ? o_cmd_tran_reg : (sd_cmd_i == r_crc_data[6]) ? 4'b0 : 4'b0010;
    STATE_NORESP  : o_cmd_tran_reg <= 4'b0001;
    STATE_WAIT0   : o_cmd_tran_reg <= 4'b0;
    STATE_DONE    : o_cmd_tran_reg <= {1'b1,o_cmd_tran_reg[2:0]};
    default:;
  endcase



//CRC-7 calculation
always @ (posedge i_clk or negedge i_rst_n)
  if(~i_rst_n)
    r_crc_data <= 7'b0;
  else case(Next_state)
    STATE_IDLE     : r_crc_data <= 7'b0;
    STATE_WAIT     : r_crc_data <= 7'b0;
    STATE_TRAN     : if(r_cmd_cnt < 10'd40)begin
                      r_crc_data[6] <= r_crc_data[5];
                      r_crc_data[5] <= r_crc_data[4];
                      r_crc_data[4] <= r_crc_data[3];
                      r_crc_data[3] <= r_crc_data[2] ^ (r_cmd_reg[39] ^ r_crc_data[6]);
                      r_crc_data[2] <= r_crc_data[1];
                      r_crc_data[1] <= r_crc_data[0];
                      r_crc_data[0] <= r_cmd_reg[39] ^ r_crc_data[6];
                    end else
                      r_crc_data <= {r_crc_data[5:0],1'b1};
    STATE_R1_WAIT  : r_crc_data <= 7'b0;
    STATE_R1       : if(r_cmd_cnt1 <= 10'd39)begin
                      r_crc_data[6] <= r_crc_data[5];
                      r_crc_data[5] <= r_crc_data[4];
                      r_crc_data[4] <= r_crc_data[3];
                      r_crc_data[3] <= r_crc_data[2] ^ (sd_cmd_i ^ r_crc_data[6]);
                      r_crc_data[2] <= r_crc_data[1];
                      r_crc_data[1] <= r_crc_data[0];
                      r_crc_data[0] <= sd_cmd_i ^ r_crc_data[6];
                    end else
                      r_crc_data <= r_crc_data[6:0];
    STATE_R2_WAIT  : r_crc_data <= 7'b0;
    STATE_R2       : if(r_cmd_cnt1 <= 10'd127)begin
                      r_crc_data[6] <= r_crc_data[5];
                      r_crc_data[5] <= r_crc_data[4];
                      r_crc_data[4] <= r_crc_data[3];
                      r_crc_data[3] <= r_crc_data[2] ^ (sd_cmd_i ^ r_crc_data[6]);
                      r_crc_data[2] <= r_crc_data[1];
                      r_crc_data[1] <= r_crc_data[0];
                      r_crc_data[0] <= sd_cmd_i ^ r_crc_data[6];
                    end else
                      r_crc_data <= r_crc_data[6:0];
    STATE_R3_WAIT  : r_crc_data <= 7'b0;
    STATE_R3       : r_crc_data <= 7'b111_1111;
    STATE_R6_WAIT  : r_crc_data <= 7'b0;
    STATE_R6       : if(r_cmd_cnt1 <= 10'd39)begin
                      r_crc_data[6] <= r_crc_data[5];
                      r_crc_data[5] <= r_crc_data[4];
                      r_crc_data[4] <= r_crc_data[3];
                      r_crc_data[3] <= r_crc_data[2] ^ (sd_cmd_i ^ r_crc_data[6]);
                      r_crc_data[2] <= r_crc_data[1];
                      r_crc_data[1] <= r_crc_data[0];
                      r_crc_data[0] <= sd_cmd_i ^ r_crc_data[6];
                    end else
                      r_crc_data <= r_crc_data[6:0];
    STATE_R7_WAIT  : r_crc_data <= 7'b0;
    STATE_R7       : if(r_cmd_cnt1 <= 10'd39)begin
                      r_crc_data[6] <= r_crc_data[5];
                      r_crc_data[5] <= r_crc_data[4];
                      r_crc_data[4] <= r_crc_data[3];
                      r_crc_data[3] <= r_crc_data[2] ^ (sd_cmd_i^r_crc_data[6]);
                      r_crc_data[2] <= r_crc_data[1];
                      r_crc_data[1] <= r_crc_data[0];
                      r_crc_data[0] <= sd_cmd_i ^ r_crc_data[6];
                    end else
                      r_crc_data <= r_crc_data[6:0];
    STATE_CRC      : r_crc_data <= {r_crc_data[5:0],1'b1};
    STATE_NORESP   : r_crc_data <= 7'b0;
    STATE_DONE     : r_crc_data <= 7'b0;
    default:;
  endcase


assign  R1_RESP = r_R1_RESP;
assign  R2_RESP = r_R2_RESP;
assign  R3_RESP = r_R3_RESP;
assign  R6_RESP = r_R6_RESP;
assign  R7_RESP = r_R7_RESP;






// ila_0 Cmd_tran_inst (
// 	.clk(w_clk100M), // input wire clk
// 	.probe0(Current_state), // input wire [7:0]  probe0
// 	.probe1(i_cmd_index), // input wire [7:0]  probe1
// 	.probe2(o_cmd_tran_reg), // input wire [15:0]  probe2
// 	.probe3(i_cmd_argument), // input wire [31:0]  probe3
// 	.probe4(i_cmd_tran_dval), // input wire [0:0]  probe4
// 	.probe5(sd_cmd_dir), // input wire [0:0]  probe5
// 	.probe6(probe6), // input wire [0:0]  probe6
// 	.probe7(r_cmd_cnt1), // input wire [15:0]  probe7
// 	.probe8({r_crc_data,Next_state,r_cmd_reg}), // input wire [119:0]  probe8
// 	.probe9(r_cmd_cnt) // input wire [255:0]  probe9
// );







endmodule
