
`timescale 1ns / 1ps
(* keep_hierarchy = "yes" *) module SD_Initial_block(
        input                     i_clk             ,
        input                     w_clk100M             ,
        input                     i_rst_n           ,

        input  wire               i_initial_en      ,
        output wire  [2:0]        o_initial_status  ,
        output reg   [7:0]        o_initial_done    , //[7] : initial done
                                                      //[6](CCS) 0:SDSC 1 : SDHC or SDXC;
                                                      //[5](UHS-II) 0: non UHS-II , 1: UHS-II
                                                      //[4](S18A)) (Switching to 1.8V Accepted) 0: Continues current voltage signaling 1:  Ready for switching signal voltage
                                                      //[3:0] 4'b0001 : Ver1.x ;4'b0010: Ver2.0; 4'b0010: Ver3.0 or later
        output reg                o_cmd_tran_dval   ,
        output reg   [5:0]        o_cmd_index       ,
        output reg   [31:0]       o_cmd_argument    ,

        input  wire  [3:0]        i_cmd_tran_reg    ,

        output  wire [15:0]       RCA               ,
        output  wire [119:0]      CSD               ,
        output  wire [119:0]      CID               ,

        input   wire  [31:0]      R1_RESP           ,
        input   wire  [119:0]     R2_RESP           ,
        input   wire  [31:0]      R3_RESP           ,
        input   wire  [31:0]      R6_RESP           ,
        input   wire  [11:0]      R7_RESP
);


localparam STATE_IDLE          = 6'd0 ;
localparam STATE_CMD0          = 6'd1 ;
localparam STATE_CMD0_RESP     = 6'd2 ;
localparam STATE_CMD8          = 6'd3 ;//check old version
localparam STATE_CMD8_RESP     = 6'd4 ;
localparam STATE_OLDVERSION    = 6'd5 ;
localparam STATE_ACMD41_0      = 6'd6 ;
localparam STATE_ACMD41_RESP_0 = 6'd7 ;
localparam STATE_ACMD41        = 6'd8 ;//read OCR
localparam STATE_ACMD41_RESP   = 6'd9 ;
localparam STATE_WAIT          = 6'd10;
localparam STATE_SDMODE        = 6'd11;
localparam STATE_CMD11         = 6'd12;
localparam STATE_CMD11_RESP    = 6'd13;
localparam STATE_CMD2          = 6'd14;//read CID
localparam STATE_CMD2_RESP     = 6'd15;
localparam STATE_CMD3          = 6'd16;//read RCA
localparam STATE_CMD3_RESP     = 6'd17;
localparam STATE_CMD9          = 6'd18;//read CSD
localparam STATE_CMD9_RESP     = 6'd19;
localparam STATE_CMD7          = 6'd20;//select card
localparam STATE_CMD7_RESP     = 6'd21;
localparam STATE_CMD42         = 6'd22;//ulock card
localparam STATE_CMD42_RESP    = 6'd23;
localparam STATE_ACMD6_0       = 6'd24;
localparam STATE_ACMD6_RESP_0  = 6'd25;
localparam STATE_ACMD6         = 6'd26;//select 4 line SDIO
localparam STATE_ACMD6_RESP    = 6'd27;
localparam STATE_CMD6_CH       = 6'd28;//switch tran speed
localparam STATE_CMD6_CH_RESP  = 6'd29;
localparam STATE_CMD6_SW       = 6'd30;//switch tran set
localparam STATE_CMD6_SW_RESP  = 6'd31;
localparam STATE_CMD16         = 6'd32;
localparam STATE_CMD16_RESP    = 6'd33;
localparam STATE_INACTIVE      = 6'd34;
localparam STATE_INT_FAIL      = 6'd35;
localparam STATE_INT_DONE      = 6'd36;


reg [5:0]   Current_state ;
reg [5:0]   Next_state    ;

reg [17:0]  r_time_count ;
reg [15:0]  r_delay_count;
reg [15:0]  r_fail_count ;


reg [ 15:0] r_RCA         ;
reg [119:0] r_CSD         ;
reg [119:0] r_CID         ;
reg [ 31:0] r_SCR         ;
reg [  1:0] r_initial_en  ;

always @ (posedge i_clk or negedge i_rst_n)
  if(~i_rst_n)
    r_initial_en    <= 2'b0;
  else begin
    r_initial_en[0] <= i_initial_en;
    r_initial_en[1] <= r_initial_en[0];
  end

always @(posedge i_clk or negedge i_rst_n)
  if(~i_rst_n)
    Current_state <= STATE_IDLE;
  else
    Current_state <= Next_state;

always @ (*)
  if(~i_rst_n)
    Next_state <= STATE_IDLE;
  else case(Current_state)
    STATE_IDLE         : Next_state <= (r_initial_en == 2'b01) ? STATE_CMD0 : STATE_IDLE;

    STATE_CMD0         : Next_state <= STATE_CMD0_RESP;

    STATE_CMD0_RESP    : Next_state <= (i_cmd_tran_reg == 4'b1000) ? STATE_CMD8 : STATE_CMD0_RESP;

    STATE_CMD8         : Next_state <= (i_cmd_tran_reg[3]) ? STATE_CMD8_RESP : STATE_CMD8;

    STATE_CMD8_RESP    : Next_state <= (i_cmd_tran_reg[2:0] == 3'b010) ? STATE_IDLE : (i_cmd_tran_reg[2:0] == 3'b001) ? STATE_OLDVERSION : (R7_RESP == 12'h1AA) ? STATE_ACMD41_0 : STATE_INACTIVE;

    STATE_OLDVERSION   : Next_state <= STATE_ACMD41_0;

    STATE_ACMD41_0     : Next_state <= (i_cmd_tran_reg[3]) ? (r_time_count < 18'd200000) ? STATE_ACMD41_RESP_0 : STATE_IDLE : STATE_ACMD41_0;

    STATE_ACMD41_RESP_0: Next_state <= (r_time_count < 18'd200000) ? (i_cmd_tran_reg[2:0] == 3'b010) ? STATE_IDLE : (i_cmd_tran_reg[2:0] == 3'b001) ? STATE_INACTIVE :  STATE_ACMD41 : STATE_IDLE;

    STATE_ACMD41       : Next_state <= (i_cmd_tran_reg[3]) ? (r_time_count < 18'd200000) ? STATE_ACMD41_RESP : STATE_IDLE : STATE_ACMD41;

    STATE_ACMD41_RESP  : Next_state <= (r_time_count < 18'd200000) ? (i_cmd_tran_reg[2:0] == 3'b010) ? STATE_IDLE : (i_cmd_tran_reg[2:0] == 3'b001) ? STATE_INACTIVE : R3_RESP[31] ? STATE_SDMODE :  STATE_WAIT : STATE_IDLE;
                                                                                                                                                                                                          //bit31 :busy bit 24 S18A

    STATE_WAIT         : Next_state <= (r_time_count < 18'd200000) ?  (r_delay_count < 16'd50000) ? STATE_WAIT : STATE_ACMD41_0 : STATE_IDLE;

    STATE_SDMODE       : Next_state <= STATE_CMD2 ;

    STATE_CMD2         : Next_state <= (i_cmd_tran_reg[3]) ? STATE_CMD2_RESP : STATE_CMD2;

    STATE_CMD2_RESP    : Next_state <= (i_cmd_tran_reg[2:0] == 3'b010) ? STATE_IDLE : (i_cmd_tran_reg[2:0] == 3'b001) ? STATE_INACTIVE : STATE_CMD3;

    STATE_CMD3         : Next_state <= (i_cmd_tran_reg[3]) ? STATE_CMD3_RESP : STATE_CMD3;

    STATE_CMD3_RESP    : Next_state <= (i_cmd_tran_reg[2:0] == 3'b010) ? STATE_IDLE : (i_cmd_tran_reg[2:0] == 3'b001) ? STATE_INACTIVE : STATE_CMD9;

    STATE_CMD9         : Next_state <= (i_cmd_tran_reg[3]) ? STATE_CMD9_RESP : STATE_CMD9;

    STATE_CMD9_RESP    : Next_state <= (i_cmd_tran_reg[2:0] == 3'b010) ? STATE_IDLE : (i_cmd_tran_reg[2:0] == 3'b001) ? STATE_INACTIVE : STATE_CMD7;

    STATE_CMD7         : Next_state <= (i_cmd_tran_reg[3]) ? STATE_CMD7_RESP : STATE_CMD7;

    STATE_CMD7_RESP    : Next_state <= (i_cmd_tran_reg[2:0] == 3'b010) ? STATE_IDLE : (i_cmd_tran_reg[2:0] == 3'b001) ? STATE_INACTIVE : STATE_ACMD6_0;

    STATE_CMD42        : Next_state <= (i_cmd_tran_reg[3]) ? STATE_CMD42_RESP : STATE_CMD42;

    STATE_CMD42_RESP   : Next_state <= (i_cmd_tran_reg[2:0] == 3'b010) ? STATE_IDLE : (i_cmd_tran_reg[2:0] == 3'b001) ? STATE_INACTIVE : STATE_ACMD6_0;

    STATE_ACMD6_0      : Next_state <= (i_cmd_tran_reg[3]) ? STATE_ACMD6_RESP_0 :  STATE_ACMD6_0;

    STATE_ACMD6_RESP_0 : Next_state <= (i_cmd_tran_reg[2:0] == 3'b010) ? STATE_IDLE : (i_cmd_tran_reg[2:0] == 3'b001) ? STATE_INACTIVE : STATE_ACMD6;

    STATE_ACMD6        : Next_state <= (i_cmd_tran_reg[3]) ? STATE_ACMD6_RESP :  STATE_ACMD6;

    STATE_ACMD6_RESP   : Next_state <= (i_cmd_tran_reg[2:0] == 3'b010) ? STATE_IDLE : (i_cmd_tran_reg[2:0] == 3'b001) ? STATE_INACTIVE : STATE_CMD16;

    STATE_CMD16        : Next_state <= (i_cmd_tran_reg[3]) ? STATE_CMD16_RESP : STATE_CMD16;

    STATE_CMD16_RESP   : Next_state <= (i_cmd_tran_reg[2:0] == 3'b010) ? STATE_IDLE : (i_cmd_tran_reg[2:0] == 3'b001) ? STATE_INACTIVE : STATE_INT_DONE;

    STATE_INACTIVE     : Next_state <= (r_fail_count > 30) ? STATE_INT_FAIL : STATE_CMD0;

    STATE_INT_FAIL     : Next_state <= STATE_IDLE ;

    STATE_INT_DONE     : Next_state <= STATE_IDLE ;
    default            :;
  endcase


always @ (posedge i_clk or negedge i_rst_n)
  if(~i_rst_n)  begin
    o_cmd_tran_dval <=  1'b0;
    o_cmd_index     <=  6'd0;
    o_cmd_argument  <= 32'h0;
  end else case(Next_state)
    STATE_IDLE         : begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= 6'd0;          o_cmd_argument <= 32'h0; end
    STATE_CMD0         : begin o_cmd_tran_dval <= 1'b1; o_cmd_index <= 6'd0;          o_cmd_argument <= 32'h0; end
    STATE_CMD0_RESP    : begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index;   o_cmd_argument <= o_cmd_argument; end
    STATE_CMD8         : begin o_cmd_tran_dval <= 1'b1; o_cmd_index <= 6'd8;          o_cmd_argument <= 32'h0000_01AA;  end //2.7~3.6 V ,Echo is 8'b1010_1010
    STATE_CMD8_RESP    : begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index;   o_cmd_argument <= o_cmd_argument; end
    STATE_OLDVERSION   : begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index;   o_cmd_argument <= o_cmd_argument; end
    STATE_ACMD41_0     : begin o_cmd_tran_dval <= 1'b1; o_cmd_index <= 6'd55;         o_cmd_argument <= 32'h0; end
    STATE_ACMD41_RESP_0: begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index;   o_cmd_argument <= o_cmd_argument; end
    STATE_ACMD41       : begin o_cmd_tran_dval <= 1'b1; o_cmd_index <= 6'd41;         o_cmd_argument <= 32'h50FF_8000;  end //all voltage support,hcs xpc support
    STATE_ACMD41_RESP  : begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index;   o_cmd_argument <= o_cmd_argument; end
    STATE_WAIT         : begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index;   o_cmd_argument <= o_cmd_argument; end
    STATE_SDMODE       : begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index;   o_cmd_argument <= o_cmd_argument; end
    STATE_CMD2         : begin o_cmd_tran_dval <= 1'b1; o_cmd_index <= 6'd2;          o_cmd_argument <= 32'h0; end
    STATE_CMD2_RESP    : begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index;   o_cmd_argument <= o_cmd_argument; end
    STATE_CMD3         : begin o_cmd_tran_dval <= 1'b1; o_cmd_index <= 6'd3;          o_cmd_argument <= 32'h0; end
    STATE_CMD3_RESP    : begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index;   o_cmd_argument <= o_cmd_argument; end
    STATE_CMD9         : begin o_cmd_tran_dval <= 1'b1; o_cmd_index <= 6'd9;          o_cmd_argument <= {r_RCA,16'b0};  end
    STATE_CMD9_RESP    : begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index;   o_cmd_argument <= o_cmd_argument; end
    STATE_CMD7         : begin o_cmd_tran_dval <= 1'b1; o_cmd_index <= 6'd7;          o_cmd_argument <= {r_RCA,16'b0};  end
    STATE_CMD7_RESP    : begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index;   o_cmd_argument <= o_cmd_argument; end
    STATE_CMD42        : begin o_cmd_tran_dval <= 1'b1; o_cmd_index <= 6'd42;         o_cmd_argument <= {r_RCA,16'b0};  end
    STATE_CMD42_RESP   : begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index;   o_cmd_argument <= o_cmd_argument; end
    STATE_ACMD6_0      : begin o_cmd_tran_dval <= 1'b1; o_cmd_index <= 6'd55;         o_cmd_argument <= {r_RCA,16'b0}; end
    STATE_ACMD6_RESP_0 : begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index;   o_cmd_argument <= o_cmd_argument; end
    STATE_ACMD6        : begin o_cmd_tran_dval <= 1'b1; o_cmd_index <= 6'd6;          o_cmd_argument <= {30'b0,2'b10};  end
    STATE_ACMD6_RESP   : begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index;   o_cmd_argument <= o_cmd_argument; end
    STATE_CMD16        : begin o_cmd_tran_dval <= 1'b1; o_cmd_index <= 6'd16;         o_cmd_argument <= 32'd512; end //512bit per sector
    STATE_CMD16_RESP   : begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index;   o_cmd_argument <= o_cmd_argument; end
    STATE_INACTIVE     : begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= 6'd0;          o_cmd_argument <= 32'h0; end
    STATE_INT_FAIL     : begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= 6'd0;          o_cmd_argument <= 32'h0; end
    STATE_INT_DONE     : begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= 6'd0;          o_cmd_argument <= 32'h0; end
    default            : begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= 6'd0;          o_cmd_argument <= 32'h0; end
  endcase

always @ (posedge i_clk or negedge i_rst_n)
  if (~i_rst_n)  begin
    r_time_count  <= 18'd0;
    r_delay_count <= 16'd0;
    r_fail_count  <= 16'b0;
  end else case(Next_state)
    STATE_IDLE         : begin r_time_count <= 18'd0;                r_delay_count <= 16'd0;               r_fail_count <= 16'b0;               end
    STATE_ACMD41_0     : begin r_time_count <= r_time_count + 1'd1;  r_delay_count <= 16'd0;               r_fail_count <= r_fail_count;        end
    STATE_ACMD41_RESP_0: begin r_time_count <= r_time_count + 1'd1;  r_delay_count <= 16'd0;               r_fail_count <= r_fail_count;        end
    STATE_ACMD41       : begin r_time_count <= r_time_count + 1'd1;  r_delay_count <= 16'd0;               r_fail_count <= r_fail_count;        end
    STATE_ACMD41_RESP  : begin r_time_count <= r_time_count + 1'd1;  r_delay_count <= 16'd0;               r_fail_count <= r_fail_count;        end
    STATE_WAIT         : begin r_time_count <= r_time_count + 1'd1;  r_delay_count <= r_delay_count + 1'd1;r_fail_count <= r_fail_count;        end
    STATE_CMD9_RESP    : begin r_time_count <= 18'd0;                r_delay_count <= r_delay_count + 1'd1;r_fail_count <= r_fail_count;        end
    STATE_INACTIVE     : begin r_time_count <= 18'd0;                r_delay_count <= 16'd0;               r_fail_count <= r_fail_count + 1'b1; end
    default            : begin r_time_count <= 18'd0;                r_delay_count <= 16'd0;               r_fail_count <= r_fail_count;        end
  endcase


always @ (posedge i_clk or negedge i_rst_n)
  if (~i_rst_n)  begin
    o_initial_done <=   8'b0;
    r_CSD          <= 120'b0;
    r_CID          <= 120'b0;
    r_RCA          <=  16'b0;
    r_SCR          <=  32'b0;
  end else case(Next_state)
    STATE_IDLE      :begin
                          o_initial_done <= o_initial_done ;
                          r_CID <= r_CID;
                          r_CSD <= r_CSD;
                          r_RCA <= r_RCA;end
    STATE_CMD0      :begin
                          o_initial_done <= 8'b0 ;
                          r_CID <= 120'b0;
                          r_CSD <= 120'b0;
                          r_RCA <= 16'b0;
                          r_SCR <= 32'b0;end
    STATE_CMD0_RESP :begin
                          o_initial_done <= o_initial_done ;
                          r_CID <= r_CID;
                          r_CSD <= r_CSD;
                          r_RCA <= r_RCA;end
    STATE_CMD8      :begin
                          o_initial_done <= o_initial_done ;
                          r_CID <= r_CID;
                          r_CSD <= r_CSD;
                          r_RCA <= r_RCA;
                          r_SCR <= r_SCR;end
    STATE_CMD8_RESP :begin
                          o_initial_done <= o_initial_done ;
                          r_CID <= r_CID;
                          r_CSD <= r_CSD;
                          r_RCA <= r_RCA;
                          r_SCR <= r_SCR;end
    STATE_OLDVERSION:begin
                          o_initial_done <= 8'b0001 ;
                          r_CID <= r_CID;
                          r_CSD <= r_CSD;
                          r_RCA <= r_RCA;
                          r_SCR <= r_SCR;end
    STATE_ACMD41_0     :begin
                          o_initial_done <= o_initial_done ;
                          r_CID <= r_CID;
                          r_CSD <= r_CSD;
                          r_RCA <= r_RCA;
                          r_SCR <= r_SCR;end
    STATE_ACMD41_RESP_0:begin
                          o_initial_done <= o_initial_done ;
                          r_CID <= r_CID;
                          r_CSD <= r_CSD;
                          r_RCA <= r_RCA;
                          r_SCR <= r_SCR;end
    STATE_ACMD41    :begin
                          o_initial_done <= o_initial_done ;
                          r_CID <= r_CID;
                          r_CSD <= r_CSD;
                          r_RCA <= r_RCA;
                          r_SCR <= r_SCR;end
    STATE_ACMD41_RESP:begin
                          o_initial_done <= o_initial_done ;
                          r_CID <= r_CID;
                          r_CSD <= r_CSD;
                          r_RCA <= r_RCA;
                          r_SCR <= r_SCR;end
    STATE_WAIT      :begin
                          o_initial_done <= o_initial_done ;
                          r_CID <= r_CID;
                          r_CSD <= r_CSD;
                          r_RCA <= r_RCA;
                          r_SCR <= r_SCR;end
    STATE_SDMODE    :begin
                          o_initial_done <= o_initial_done[0] ? o_initial_done : R3_RESP[30] ? {1'b0,R3_RESP[30:29],R3_RESP[24],4'b0011} : {1'b0,R3_RESP[30:29],R3_RESP[24],4'b0010} ;
                          r_CID <= r_CID;
                          r_CSD <= r_CSD;
                          r_RCA <= r_RCA;
                          r_SCR <= r_SCR;end
    STATE_CMD2      :begin
                          o_initial_done <= o_initial_done ;
                          r_CID <= r_CID;
                          r_CSD <= r_CSD;
                          r_RCA <= r_RCA;
                          r_SCR <= r_SCR;end
    STATE_CMD2_RESP :begin
                          o_initial_done <= o_initial_done ;
                          r_CID <= R2_RESP;
                          r_CSD <= r_CSD;
                          r_RCA <= r_RCA;
                          r_SCR <= r_SCR;end
    STATE_CMD3      :begin
                          o_initial_done <= o_initial_done ;
                          r_CID <= r_CID;
                          r_CSD <= r_CSD;
                          r_RCA <= r_RCA;
                          r_SCR <= r_SCR;end
    STATE_CMD3_RESP :begin
                          o_initial_done <= o_initial_done ;
                          r_CID <= r_CID;
                          r_CSD <= r_CSD;
                          r_RCA <= R6_RESP[31:16];
                          r_SCR <= r_SCR;end
    STATE_CMD9      :begin
                          o_initial_done <= o_initial_done ;
                          r_CID <= r_CID;
                          r_CSD <= 120'b0;
                          r_RCA <= r_RCA;
                          r_SCR <= r_SCR;end
    STATE_CMD9_RESP :begin
                          o_initial_done <= o_initial_done ;
                          r_CID <= r_CID;
                          r_CSD <= R2_RESP;
                          r_RCA <= r_RCA;
                          r_SCR <= r_SCR;end
    STATE_INACTIVE  :begin
                          o_initial_done <= o_initial_done ;
                          r_CID <= r_CID;
                          r_CSD <= r_CSD;
                          r_RCA <= r_RCA;
                          r_SCR <= r_SCR;end
    STATE_INT_FAIL  :begin
                          o_initial_done <= o_initial_done ;
                          r_CID <= r_CID;
                          r_CSD <= r_CSD;
                          r_RCA <= r_RCA;
                          r_SCR <= r_SCR;end
    STATE_INT_DONE  :begin
                          o_initial_done <= {1'b1,o_initial_done[6:0]} ;
                          r_CID <= r_CID;
                          r_CSD <= r_CSD;
                          r_RCA <= r_RCA;
                          r_SCR <= r_SCR;end
    default         :begin
                          o_initial_done <= o_initial_done ;
                          r_CID <= r_CID;
                          r_CSD <= r_CSD;
                          r_RCA <= r_RCA;
                          r_SCR <= r_SCR;end
  endcase

reg r_initial_busy;
always @ (posedge i_clk or negedge i_rst_n)
  if(~i_rst_n)begin
    r_initial_busy <= 1'b0;
  end else if ((Next_state == STATE_IDLE) || (Next_state == STATE_INT_DONE))
    r_initial_busy <= 1'b0;
  else
    r_initial_busy <= 1'b1;

reg [1:0] r_initial_fail;
always @ (posedge i_clk or negedge i_rst_n)
  if(~i_rst_n)begin
    r_initial_fail <= 2'b0;
  end else if (Next_state == STATE_INT_FAIL)
    r_initial_fail <= 2'b10;
  else if (Next_state == STATE_INT_DONE)
    r_initial_fail <= 2'b11;
  else if (Next_state == STATE_CMD0)
    r_initial_fail <= 2'b00;
  else
    r_initial_fail <= r_initial_fail;

assign o_initial_status = {r_initial_busy,r_initial_fail};
assign RCA = r_RCA;
assign CSD = r_CSD;
assign CID = r_CID;


//version 2.0

wire [ 1:0] w_csd_structure       ;
wire [ 5:0] w_reserved0_6bit      ;
wire [ 7:0] w_taac                ;
wire [ 7:0] w_nsac                ;
wire [ 7:0] w_tran_speed          ;
wire [11:0] w_ccc                 ;
wire [ 3:0] w_read_bl_len         ;
wire [ 0:0] w_read_bl_partial     ;
wire [ 0:0] w_write_blk_misaglign ;
wire [ 0:0] w_read_blk_misaglign  ;
wire [ 0:0] w_dsr_imp             ;
wire [ 5:0] w_reserved1_6bit      ;
wire [21:0] w_c_size              ; //version 2.0 : 22 bits   version 1.0 : 12bits
wire [ 2:0] w_c_size_mult         ; //version 2.0 : unuse   version 1.0 : inuse
wire [ 0:0] w_reserved0_1bit      ;
wire [ 0:0] w_erase_blk_en        ;
wire [ 6:0] w_erase_sector_size   ;
wire [ 6:0] w_wp_grp_size         ;
wire [ 0:0] w_wp_grp_enable       ;
wire [ 1:0] w_reserved0_2bit      ;
wire [ 2:0] w_r2w_factor          ;
wire [ 3:0] w_write_bl_len        ;
wire [ 0:0] w_write_bl_partial    ;
wire [ 4:0] w_reserved0_5bit      ;
wire [ 0:0] w_file_format_grp     ;
wire [ 0:0] w_copy_flag           ;
wire [ 0:0] w_permanent_write_protection;
wire [ 0:0] w_temporary_write_protection;
wire [ 1:0] w_file_format         ;
wire [ 1:0] w_reserved1_2bit      ;

// -8 : remove CRC reg
assign w_csd_structure                = r_CSD[127-8:126-8];
assign w_reserved0_6bit               = r_CSD[125-8:120-8];
assign w_taac                         = r_CSD[119-8:112-8];
assign w_nsac                         = r_CSD[111-8:104-8];
assign w_tran_speed                   = r_CSD[103-8: 96-8];
assign w_ccc                          = r_CSD[ 95-8: 84-8];
assign w_read_bl_len                  = r_CSD[ 83-8: 80-8];
assign w_read_bl_partial              = r_CSD[ 79-8: 79-8];
assign w_write_blk_misaglign          = r_CSD[ 78-8: 78-8];
assign w_read_blk_misaglign           = r_CSD[ 77-8: 77-8];
assign w_dsr_imp                      = r_CSD[ 76-8: 76-8];
assign w_reserved1_6bit               = r_CSD[127-8:126-8] == 2'b0 ? r_CSD[ 75-8: 74-8] : r_CSD[ 75-8: 70-8];
assign w_c_size                       = r_CSD[127-8:126-8] == 2'b0 ? r_CSD[ 73-8: 62-8] : r_CSD[ 69-8: 48-8];
assign w_c_size_mult                  = r_CSD[127-8:126-8] == 2'b0 ? r_CSD[ 49-8: 47-8] : 0;
assign w_reserved0_1bit               = r_CSD[127-8:126-8] == 2'b0 ? 0 : r_CSD[ 47-8: 47-8];
assign w_erase_blk_en                 = r_CSD[ 46-8: 46-8];
assign w_erase_sector_size            = r_CSD[ 45-8: 39-8];
assign w_wp_grp_size                  = r_CSD[ 38-8: 32-8];
assign w_wp_grp_enable                = r_CSD[ 31-8: 31-8];
assign w_reserved0_2bit               = r_CSD[ 30-8: 29-8];
assign w_r2w_factor                   = r_CSD[ 28-8: 26-8];
assign w_write_bl_len                 = r_CSD[ 25-8: 22-8];
assign w_write_bl_partial             = r_CSD[ 21-8: 21-8];
assign w_reserved0_5bit               = r_CSD[ 20-8: 16-8];
assign w_file_format_grp              = r_CSD[ 15-8: 15-8];
assign w_copy_flag                    = r_CSD[ 14-8: 14-8];
assign w_permanent_write_protection   = r_CSD[ 13-8: 13-8];
assign w_temporary_write_protection   = r_CSD[ 12-8: 12-8];
assign w_file_format                  = r_CSD[ 11-8: 10-8];
assign w_reserved1_2bit               = r_CSD[  9-8:  8-8];




// ila_0 sd_status (
// 	.clk(w_clk100M), // input wire clk
// 	.probe0(w_tran_speed), // input wire [7:0]  probe0
// 	.probe1(w_csd_structure), // input wire [7:0]  probe1
// 	.probe2(o_cmd_index), // input wire [15:0]  probe2
// 	.probe3({i_cmd_tran_reg,Current_state,Next_state}), // input wire [31:0]  probe3
// 	.probe4(probe4), // input wire [0:0]  probe4
// 	.probe5(i_initial_en), // input wire [0:0]  probe5
// 	.probe6(probe6), // input wire [0:0]  probe6
// 	.probe7(o_initial_done), // input wire [15:0]  probe7
// 	.probe8({R1_RESP,R3_RESP,R6_RESP,R7_RESP}), // input wire [119:0]  probe8
// 	.probe9(r_time_count) // input wire [255:0]  probe9
// );

endmodule