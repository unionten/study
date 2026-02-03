`define CDC_MULTI_BIT_SIGNAL_OUTGEN(aclk,adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                    generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate
`define CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                    generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(0),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk( ),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate
`define CDC_SINGLE_BIT_PULSE_OUTGEN(aclk,arst,apulse_in,bclk,brst,bpulse_out,SIM,DEST_FF)               generate if(SIM==0)begin  xpm_cdc_pulse #(.DEST_SYNC_FF(DEST_FF), .INIT_SYNC_FF(0),.REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) cdc_u (.src_clk(aclk),.src_rst(arst),.src_pulse(apulse_in),.dest_clk(bclk),.dest_rst(brst),.dest_pulse(bpulse_out));   end else begin   reg [5:0] name1 = 0;wire name2;always@(posedge aclk)if(arst)name1[0] <=0;else name1[0] <= apulse_in;assign name2 = apulse_in & ~name1[0]; always@(posedge aclk)if(arst)name1[1] <= 0;else name1[1] <= name2 ? ~name1[1]:name1[1];always@(posedge bclk)if(brst)name1[5:2]<=0;else begin name1[2]<=name1[1];name1[3]<=name1[2];name1[4]<=name1[3];name1[5]<=name1[4];end  assign bpulse_out=name1[4]^name1[5];  end  endgenerate
`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define NEG_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate
`define XOR_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = buf_name1^in;  end  endgenerate
`define POS_STRETCH_OUTGEN(clk,rst,pulse_in,pulse_out,DELAY_NUM)                                        generate  begin    reg [DELAY_NUM-2:0] temp_name = 0; always@(posedge clk)begin  if(rst)temp_name <= {(DELAY_NUM-1){1'b0}}; else temp_name <= pulse_in ? {(DELAY_NUM-1){1'b1} }: temp_name<<1 ; end  assign  pulse_out = temp_name[DELAY_NUM-2]|pulse_in;  end  endgenerate
`define NEG_STRETCH_OUTGEN(clk,rst,pulsen_in,pulsen_out,DELAY_NUM)                                      generate  begin    reg [DELAY_NUM-2:0] temp_name = 0; always@(posedge clk)begin  if(rst)temp_name <= {(DELAY_NUM-1){1'b0}}; else temp_name <= ~pulsen_in ? {(DELAY_NUM-1){1'b1} }: temp_name<<1 ; end  assign  pulsen_out = ~( temp_name[DELAY_NUM-2] | ~pulsen_in ) ;  end  endgenerate
`define HANDSHAKE_OUTGEN(aclk,arst,apulse_in,adata_in,bclk,brst,bpulse_out,bdata_out,DATA_WIDTH,SIM)    generate  if(SIM==0) begin  handshake  #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I ( bclk),.DST_DATA_O (bdata_out),.DST_SYNC_FINISH_O(bpulse_out) ); end  else  begin  handshake2 #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I (bclk),.DST_DATA_O (bdata_out ),.DST_SYNC_FINISH_O(bpulse_out) ); end  endgenerate
`define DELAY_OUTGEN(clk,rst,data_in,data_out,DATA_WIDTH,DLY)                                           generate if(DLY==0)begin  assign data_out = data_in; end  else if(DLY==1)begin  reg [DATA_WIDTH-1:0] a_temp = 0; always@(posedge clk) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [DATA_WIDTH-1:0] a_temp [DLY-1:0] ;always@(posedge clk) begin  if(rst)a_temp[DLY-1] <= 0; else   a_temp[DLY-1] <= data_in; end  for(i=0;i<=DLY-2;i=i+1)begin  always@(posedge clk)begin  if(rst)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  endgenerate



module pattern_gen_core #(
  parameter  C_PORT_NUM = 4

)(
    input                           CLK_I         ,
    input                           RST_I         ,
    input  [2:0]                    PORT_NUM_I    ,
    input  [7:0]                    PATSEL_I      ,
    input  [15:0]                   HACTIVE_I     ,
    input  [15:0]                   HFP_I         ,
    input  [15:0]                   HSYNC_I       ,
    input  [15:0]                   HBP_I         ,
    input  [15:0]                   VACTIVE_I     ,
    input  [15:0]                   VFP_I         ,
    input  [15:0]                   VSYNC_I       ,
    input  [15:0]                   VBP_I         ,
    input  [31:0]                   CYCLE_VAL_I   ,
    input  [7:0]                    UART_R_I      ,
    input  [7:0]                    UART_G_I      ,
    input  [7:0]                    UART_B_I      ,
    output reg   [C_PORT_NUM-1:0]   VS_O          ,
    output reg   [C_PORT_NUM-1:0]   HS_O          ,
    output reg   [C_PORT_NUM-1:0]   DE_O          ,
    output reg   [8*C_PORT_NUM-1:0] R_O           ,
    output reg   [8*C_PORT_NUM-1:0] G_O           ,
    output reg   [8*C_PORT_NUM-1:0] B_O           ,
    output [15:0]                   ACTIVE_X_O    , // from 1
    output [15:0]                   ACTIVE_Y_O      // from 1
);



//---------------时序参数3840*2160------------------
//localparam HACTIVE_I  = 16'd3840 ;
//localparam HFP_I      = 16'd176;
//localparam HSYNC_I    = 16'd88;
//localparam HBP_I      = 16'd296;
//localparam VACTIVE_I  = 16'd2160;
//localparam VFP_I      = 16'd8;
//localparam VSYNC_I    = 16'd10;
//localparam VBP_I      = 16'd72;
//localparam H_TOTAL   = HACTIVE_I + HFP_I + HSYNC_I + HBP_I;
//localparam V_TOTAL   = VACTIVE_I + VFP_I + VSYNC_I + VBP_I;




reg [C_PORT_NUM-1:0]   w_VS= 0;
reg [C_PORT_NUM-1:0]   w_HS= 0;
reg [C_PORT_NUM-1:0]   w_DE= 0;

reg   [8*C_PORT_NUM-1:0] RGB_R= 0;
reg   [8*C_PORT_NUM-1:0] RGB_G= 0;
reg   [8*C_PORT_NUM-1:0] RGB_B= 0;
reg   [C_PORT_NUM-1:0]   VS  = 0 ;
reg   [C_PORT_NUM-1:0]   HS  = 0 ;
reg   [C_PORT_NUM-1:0]   DE  = 0 ;


(*keep="true"*)reg [16*C_PORT_NUM-1:0]   current_y= 0;


reg  [15:0]  R_HACTIVE = 0 ;
reg  [15:0]  R_HFP     = 0 ;
reg  [15:0]  R_HBP     = 0 ;
reg  [15:0]  R_HSYNC   = 0 ;
reg  [15:0]  R_VACTIVE = 0 ;
reg  [15:0]  R_VFP     = 0 ;
reg  [15:0]  R_VSYNC   = 0 ;
reg  [15:0]  R_VBP     = 0 ;


reg [2:0] R_PORT_NUM = 4;

//参数打拍
always @(posedge CLK_I)begin
    R_PORT_NUM <= PORT_NUM_I;
end


//R_HACTIVE 为 div 后
always @(posedge CLK_I) begin
   R_HACTIVE   <= (R_PORT_NUM == 3'd1)   ? HACTIVE_I   : (R_PORT_NUM == 3'd2) ? HACTIVE_I[15:1] + HACTIVE_I[0] : HACTIVE_I[15:2] + (HACTIVE_I[1] | HACTIVE_I[0]);
   R_HBP       <= (R_PORT_NUM == 3'd1)   ? HBP_I       : (R_PORT_NUM == 3'd2) ? HBP_I[15:1]     + HBP_I[0]     : HBP_I[15:2]     + (HBP_I[1]     | HBP_I[0]);
   R_HFP       <= (R_PORT_NUM == 3'd1)   ? HFP_I       : (R_PORT_NUM == 3'd2) ? HFP_I[15:1]     + HFP_I[0]     : HFP_I[15:2]     + (HFP_I[1]     | HFP_I[0]);
   R_HSYNC     <= (R_PORT_NUM == 3'd1)   ? HSYNC_I     : (R_PORT_NUM == 3'd2) ? HSYNC_I[15:1]   + HSYNC_I[0]   : HSYNC_I[15:2]   + (HSYNC_I[1]   | HSYNC_I[0]);
   R_VACTIVE   <= VACTIVE_I ;
   R_VFP       <= VFP_I     ;
   R_VSYNC     <= VSYNC_I   ;
   R_VBP       <= VBP_I     ;
end



reg [15:0] V_ACTIVE_reg = 0 ;
reg [15:0] H_ACTIVE_reg = 0;
always @ (posedge CLK_I)
begin
    V_ACTIVE_reg <= VACTIVE_I;
    H_ACTIVE_reg <= HACTIVE_I;
end





reg [15:0] V_ACTIVE_divby3 = 0;
reg [15:0] V_ACTIVE_divby9 = 0;
reg [15:0] vactivemult7div9= 0;
reg [15:0] vactivemult7div16= 0;
reg [15:0] vactivemult9div16= 0;
reg [15:0] V_ACTIVE_divby10= 0;
reg [15:0] H_ACTIVE_divby10= 0;

reg [15:0] V_ACTIVE_divby100= 0;
reg [15:0] H_ACTIVE_divby100= 0;

reg [15:0] hactivemult3div4  = 0;
reg [15:0] hactivemult5div8  = 0;
reg [15:0] hactivemult3div8  = 0;
reg [15:0] vactivemin4       = 0;
reg [15:0] hactivemult3div16 = 0;
reg [15:0] hactivemult5div16 = 0;
reg [15:0] hactivemult7div16 = 0;
reg [15:0] hactivemult9div16 = 0;
reg [15:0] hactivemult11div16= 0;
reg [15:0] hactivemin4       = 0;

reg [15:0] hactivemult9div20 = 0;
reg [15:0] hactivemult11div20= 0;
reg [15:0] vactivemult9div20 = 0;
reg [15:0] vactivemult11div20= 0;
reg [15:0] hactivemult7div8  = 0;

reg [15:0] hactivemult4div10 = 0;
reg [15:0] hactivemult6div10 = 0;
reg [15:0] vactivemult4div10 = 0;
reg [15:0] vactivemult6div10 = 0;

reg [15:0] hactivemult7div20 = 0;
reg [15:0] hactivemult13div20= 0;
reg [15:0] vactivemult7div20 = 0;
reg [15:0] vactivemult13div20= 0;


reg [15:0] hactivemult9div10 = 0;
reg [15:0] vactivemult9div10 = 0;

reg [15:0] hactivemult97div200 = 0;
reg [15:0] vactivemult97div200 = 0;

reg [15:0] hactivemult103div200 = 0;
reg [15:0] vactivemult103div200 = 0;


//for 25% 5%
reg [15:0] hactivemult5div20 = 0;
reg [15:0] hactivemult15div20= 0;
reg [15:0] vactivemult5div20 = 0;
reg [15:0] vactivemult15div20= 0;
//for 36%

reg [15:0] hactivemult4div20 = 0;
reg [15:0] hactivemult16div20= 0;
reg [15:0] vactivemult4div20 = 0;
reg [15:0] vactivemult16div20= 0;


//以下为预先计算的参数
always @ (posedge CLK_I) begin
    vactivemult7div16  <= V_ACTIVE_reg[15:4]*7;
    vactivemult9div16  <= V_ACTIVE_reg[15:4]*9;
    vactivemult7div9   <= V_ACTIVE_divby9 *7;
    hactivemult3div4   <= 3 * H_ACTIVE_reg[15:2];
    hactivemult5div8   <= 5 * H_ACTIVE_reg[15:3];
    hactivemult3div8   <= 3 * H_ACTIVE_reg[15:3];
    vactivemin4        <= V_ACTIVE_reg-4;
    hactivemin4        <= H_ACTIVE_reg-4;
    hactivemult3div16  <= 3*H_ACTIVE_reg[15:4];
    hactivemult5div16  <= 5*H_ACTIVE_reg[15:4];
    hactivemult7div16  <= 7*H_ACTIVE_reg[15:4];
    hactivemult9div16  <= 9*H_ACTIVE_reg[15:4];
    hactivemult11div16 <= 11*H_ACTIVE_reg[15:4];
    hactivemult7div8   <= 7 * H_ACTIVE_reg[15:3];

    //for 1% 1/10
     hactivemult9div20  <= 9*H_ACTIVE_divby10[15:1];
    hactivemult11div20 <= 11*H_ACTIVE_divby10[15:1];
    vactivemult9div20  <= 9*V_ACTIVE_divby10[15:1];
    vactivemult11div20 <= 11*V_ACTIVE_divby10[15:1];

    //for 4% 1/5
    hactivemult4div10 <= 4*H_ACTIVE_divby10;
    hactivemult6div10 <= 6*H_ACTIVE_divby10;
    vactivemult4div10 <= 4*V_ACTIVE_divby10;
    vactivemult6div10 <= 6*V_ACTIVE_divby10;

    //for 9% 3/10
    hactivemult7div20  <= 7*H_ACTIVE_divby10[15:1];
    hactivemult13div20 <= 13*H_ACTIVE_divby10[15:1];
    vactivemult7div20  <= 7*V_ACTIVE_divby10[15:1];
    vactivemult13div20 <= 13*V_ACTIVE_divby10[15:1];

    //for 25% 5%
    hactivemult5div20  <= 5*H_ACTIVE_divby10[15:1];
    hactivemult15div20 <=15*H_ACTIVE_divby10[15:1];
    vactivemult5div20  <= 5*V_ACTIVE_divby10[15:1];
    vactivemult15div20 <= 15*V_ACTIVE_divby10[15:1];
    //for 36%

    hactivemult4div20  <= {H_ACTIVE_divby10[14:1],2'b00};
    hactivemult16div20 <=  {H_ACTIVE_divby10[12:1],4'b0000};
    vactivemult4div20  <= {V_ACTIVE_divby10[14:1],2'b00};
    vactivemult16div20 <= {V_ACTIVE_divby10[14:1],4'b0000};




    hactivemult9div10  <= 9*H_ACTIVE_divby10;
    vactivemult9div10  <= 9*V_ACTIVE_divby10;

    hactivemult97div200  <= 97*H_ACTIVE_divby100[15:1];
    hactivemult103div200 <= 103*H_ACTIVE_divby100[15:1];
    vactivemult97div200  <= 97*V_ACTIVE_divby100[15:1];
    vactivemult103div200 <= 103*V_ACTIVE_divby100[15:1];



end


wire [11:0] lane_step;
assign  lane_step = R_HACTIVE[15:4];

reg [3:0]             cal_state  = 0 ;
reg                divisor_dval= 0;
reg  [3:0]      divisor   = 0  ;
reg  [15:0]     dividend  = 0  ;
wire [23:0]     dout_val    ;
wire                   dout_dval   ;

always @ (posedge CLK_I)
if(RST_I) begin
    cal_state        <= 3'd0;
    divisor_dval     <= 1'd0;
    dividend         <= 40'd0;
    divisor          <= 16'b0;
    V_ACTIVE_divby3  <= 16'b0;
    V_ACTIVE_divby9  <= 16'b0;
    V_ACTIVE_divby10 <= 16'b0;
    H_ACTIVE_divby10 <= 16'b0;

    V_ACTIVE_divby100  <= 16'b0;
    H_ACTIVE_divby100  <= 16'b0;
end else case(cal_state)
    4'd0 : begin
                    cal_state       <= 4'd1;
                    divisor_dval    <= 1;
                    dividend        <= VACTIVE_I;
                    divisor         <= 3;
                    V_ACTIVE_divby3 <= 16'b0;
                    V_ACTIVE_divby9 <= 16'b0;
                    V_ACTIVE_divby10 <= 16'b0;
                    H_ACTIVE_divby10 <= 16'b0;
                    V_ACTIVE_divby100  <= 16'b0;
                    H_ACTIVE_divby100  <= 16'b0;
                end
    4'd1 : begin
                    cal_state       <= dout_dval ? 4'd2 : 4'd1;
                    divisor_dval    <= dout_dval;
                    divisor         <= 9;
                    V_ACTIVE_divby3 <= dout_val[23:8];
                    V_ACTIVE_divby9 <= 32'b0;
                    V_ACTIVE_divby10 <= 16'b0;
                    H_ACTIVE_divby10 <= 16'b0;
                    V_ACTIVE_divby100  <= 16'b0;
                    H_ACTIVE_divby100  <= 16'b0;
                end
    4'd2 : begin
                    cal_state        <= dout_dval ? 4'd3 : 4'd2;
                    divisor_dval    <= dout_dval;
                    divisor         <= 10;
                    V_ACTIVE_divby9 <= dout_val[23:8];
                    V_ACTIVE_divby10 <= 16'b0;
                    H_ACTIVE_divby10 <= 16'b0;
                    V_ACTIVE_divby100  <= 16'b0;
                    H_ACTIVE_divby100  <= 16'b0;
                end
    4'd3 :begin
                    cal_state        <= dout_dval ? 4'd4 : 4'd3;
                    divisor_dval     <= dout_dval;
                    dividend         <= HACTIVE_I;
                    V_ACTIVE_divby10 <= dout_val[23:8];
                    H_ACTIVE_divby10 <= 16'b0;
                    V_ACTIVE_divby100  <= 16'b0;
                    H_ACTIVE_divby100  <= 16'b0;
                end
    4'd4 :begin
                    cal_state         <= dout_dval ? 4'd5 : 4'd4;
                    divisor_dval     <= dout_dval;
                    divisor          <= 100;
                    H_ACTIVE_divby10 <= dout_val[23:8];
                    V_ACTIVE_divby100  <= 16'b0;
                    H_ACTIVE_divby100  <= 16'b0;
                end
    4'd5 :begin
                    cal_state        <= dout_dval ? 4'd6 : 4'd5;
                    divisor_dval     <= dout_dval;
                    dividend         <= VACTIVE_I;
                    H_ACTIVE_divby100 <= dout_val[23:8];
                    V_ACTIVE_divby100 <= 16'b0;
                end
    4'd6 :begin
                    cal_state        <= dout_dval ? 4'd7 : 4'd6;
                    divisor_dval     <= dout_dval;
                    V_ACTIVE_divby100 <= dout_val[23:8];
                end
    4'd7:;
        default:;
    endcase


wire reset ;
assign   reset  =  (cal_state!=4'd7);


// pipeline = 18   check  ok    注意  被除数 看起来是4位
div_gen_pat div_inst (
  .aclk(CLK_I),                                      // input wire aclk
  .s_axis_divisor_tvalid ({0,divisor_dval}),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata  ({0,divisor}),      // input wire [31 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid({0,divisor_dval}),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata ({0,dividend}),    // input wire [63 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid    (dout_dval),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata     (dout_val)            // output wire [95 : 0] m_axis_dout_tdata
);


localparam DLY_SRL = 9 + 2;



genvar j;


reg   [C_PORT_NUM-1:0]   VS_dly= 0;
reg   [C_PORT_NUM-1:0]   HS_dly= 0;
reg   [C_PORT_NUM-1:0]   DE_dly= 0;
reg   [C_PORT_NUM-1:0]   VS_dly_reg[DLY_SRL:0];
reg   [C_PORT_NUM-1:0]   HS_dly_reg[DLY_SRL:0];
reg   [C_PORT_NUM-1:0]   DE_dly_reg[DLY_SRL:0];

generate
for (j = 0 ; j < DLY_SRL; j = j + 1) begin :  hsvsctl_dly
always @ (posedge CLK_I)
if(reset) begin
    VS_dly_reg[j]<='b0;
    HS_dly_reg[j]<='b0;
    DE_dly_reg[j]<='b0;
end else begin
    VS_dly_reg[j]<=VS_dly_reg[j+1];
    HS_dly_reg[j]<=HS_dly_reg[j+1];
    DE_dly_reg[j]<=DE_dly_reg[j+1];
end
end
endgenerate


always @ (posedge CLK_I)
if(reset) begin
    VS                    <= 'b1;
    HS                    <= 'b1;
    DE                    <= 'b0;
    VS_dly                <='b1;
    HS_dly                <='b1;
    DE_dly                <='b0;
    VS_dly_reg[DLY_SRL]   <='b1;
    HS_dly_reg[DLY_SRL]   <='b1;
    DE_dly_reg[DLY_SRL]   <='b0;
end else  begin
    VS                     <= VS_dly ;
    HS                     <= HS_dly ;
    DE                     <= DE_dly ;
    VS_dly                 <=VS_dly_reg[0];
    HS_dly                 <=HS_dly_reg[0];
    DE_dly                 <=DE_dly_reg[0];
    VS_dly_reg[DLY_SRL]    <=~w_VS;
    HS_dly_reg[DLY_SRL]    <=~w_HS;
    DE_dly_reg[DLY_SRL]    <= w_DE;
end




//yzhu
//wire [32:0]w_a2  ;
//wire [32:0]w_b2  ;
//wire [32:0]w_aa2 ;
//wire [32:0]w_bb2 ;

wire [31:0]w_a2  ;
wire [31:0]w_b2  ;
wire [31:0]w_aa2 ;
wire [31:0]w_bb2 ;



wire [63:0]w_a2b2  ;
wire [63:0]w_aa2bb2  ;
wire [31:0]w_cycle_d2;
wire [31:0]w_cycle_dd2;

reg [15:0] a_reg= 0;
reg [15:0] b_reg= 0;
reg [15:0] a= 0;
reg [15:0] b= 0;

reg [15:0] cycle_r_reg= 0;

wire [15:0] CYCLE_BIG_VAL = HACTIVE_I[15:1];
wire [15:0] CYCLE_SMALL_VAL = HACTIVE_I[15:3];




always @(posedge CLK_I)
begin
    a_reg <= 3*HACTIVE_I[15:3]-4;
    b_reg <= VACTIVE_I[15:1]-4;
    a         <= 3*HACTIVE_I[15:3];
    b         <= VACTIVE_I[15:1];
    cycle_r_reg <= CYCLE_SMALL_VAL-4;
end



//yzhu
//reg [32:0]a2  ;
//reg [32:0]b2  ;
//reg [32:0]aa2 ;
//reg [32:0]bb2 ;

reg [31:0]a2  = 0;
reg [31:0]b2  = 0;
reg [31:0]aa2 = 0;
reg [31:0]bb2 = 0;



reg [63:0]a2b2 = 0 ;
reg [63:0]aa2bb2  = 0;
reg [31:0]cycle_d2= 0;
reg [31:0]cycle_dd2= 0;


always @(posedge CLK_I)
begin
        a2       <=w_a2       ;
    b2       <=w_b2       ;
    aa2      <=w_aa2      ;
    bb2      <=w_bb2      ;
    a2b2     <=w_a2b2     ;
    aa2bb2   <=w_aa2bb2   ;
    cycle_d2 <=w_cycle_d2 ;
    cycle_dd2<=w_cycle_dd2;
end




 //pipeline stage = 3
 mult_gen_16 cycle_d2_inst (
  .CLK(CLK_I),  // input wire CLK
  .A(CYCLE_SMALL_VAL),      // input wire [15 : 0] A
  .B(CYCLE_SMALL_VAL),      // input wire [15 : 0] B
  .P(w_cycle_d2)      // output wire [31 : 0] P
);

 mult_gen_16 cycle_dd2_inst (
  .CLK(CLK_I),  // input wire CLK
  .A(cycle_r_reg),      // input wire [15 : 0] A
  .B(cycle_r_reg),      // input wire [15 : 0] B
  .P(w_cycle_dd2)      // output wire [31 : 0] P
);



 mult_gen_16 a2_inst (
  .CLK(CLK_I),  // input wire CLK
  .A(a),      // input wire [15 : 0] A
  .B(a),      // input wire [15 : 0] B
  .P(w_a2)      // output wire [31 : 0] P
);

 mult_gen_16 b2_inst (
  .CLK(CLK_I),  // input wire CLK
  .A(b),      // input wire [15 : 0] A
  .B(b),      // input wire [15 : 0] B
  .P(w_b2)      // output wire [31 : 0] P
);

 mult_gen_16 aa2_inst (
  .CLK(CLK_I),  // input wire CLK
  .A(a_reg),      // input wire [15 : 0] A
  .B(a_reg),      // input wire [15 : 0] B
  .P(w_aa2)      // output wire [31 : 0] P
);


 mult_gen_16 bb2_inst (
  .CLK(CLK_I),  // input wire CLK
  .A(b_reg),      // input wire [15 : 0] A
  .B(b_reg),      // input wire [15 : 0] B
  .P(w_bb2)      // output wire [31 : 0] P
);

// pipeline stage = 4
 mult_gen_y a2b2_inst (
  .CLK(CLK_I),  // input wire CLK
  .A( a2),      // input wire [15 : 0] A
  .B( b2),      // input wire [15 : 0] B
  .P(w_a2b2)      // output wire [31 : 0] P
);

 mult_gen_y aa2bb2_inst (
  .CLK(CLK_I),  // input wire CLK
  .A( aa2),      // input wire [15 : 0] A
  .B( bb2),      // input wire [15 : 0] B
  .P(w_aa2bb2)      // output wire [31 : 0] P
);



genvar i;

generate
  for (i = 0 ; i  < 4 ;  i= i + 1)
begin : pattern_gen


reg [63:0] a2ry2_b2rx2= 0;
reg [63:0] aa2ry2_bb2rx2= 0;


always @(posedge CLK_I)
 begin
    a2ry2_b2rx2  <= a2ry2 + b2rx2;
    aa2ry2_bb2rx2 <=aa2ry2 + bb2rx2;
end


(*keep="true"*)reg  [16-1:0]   current_x= 0;



(*keep="true"*)reg              DE_reg= 0;



//24'' 16:9 53.15 cm
//17'' 16:9 43.18cm
//integer   cycle_r    ;
(*keep="true"*)reg [31:0] cycle_r= 0;


(*keep="true"*)reg [15:0]step_val_1 = 0;
(*keep="true"*)reg [3:0]step_pixel_1= 0;
(*keep="true"*)reg [15:0]step_val_2 = 0;
(*keep="true"*)reg [3:0]step_pixel_2= 0;
(*keep="true"*)reg [15:0]cycle_x_1  = 0;
(*keep="true"*)reg [15:0]cycle_x_2  = 0;
(*keep="true"*)reg [15:0]cycle_x_3  = 0;
(*keep="true"*)reg [15:0]cycle_y_1  = 0;
(*keep="true"*)reg [15:0]cycle_y_2  = 0;
(*keep="true"*)reg [15:0]cycle_y_3  = 0;
(*keep="true"*)reg [15:0] I_x  = 0;
(*keep="true"*)reg [15:0] I_y  = 0;
(*keep="true"*)reg [15:0] II_x = 0;
(*keep="true"*)reg [15:0] II_y = 0;
(*keep="true"*)reg [15:0] III_x= 0;
(*keep="true"*)reg [15:0] III_y= 0;
(*keep="true"*)reg [15:0] IV_x = 0;
(*keep="true"*)reg [15:0] IV_y = 0;



(*keep="true"*)reg [15:0]step_val    = 0 ;
(*keep="true"*)reg [9:0] step_remain  = 0;
(*keep="true"*)reg [7:0] step_cnt= 0;
(*keep="true"*)reg [7:0] step_pixel= 0;
(*keep="true"*)reg [7:0] step_pixel_reg= 0;


(*keep="true"*)wire [31:0] cycle_n2;

always @ (posedge CLK_I) begin
    //cycle_r     <= cycle_n2/29; //43.18 ^ 2 /4 //466 16*29
    cycle_r     <= CYCLE_VAL_I;
    cycle_x_1  <= H_ACTIVE_divby10;
    cycle_x_2  <= HACTIVE_I[15:1];
    cycle_x_3  <= HACTIVE_I - H_ACTIVE_divby10;
    cycle_y_1  <= V_ACTIVE_divby10;
    cycle_y_2  <= VACTIVE_I[15:1];
    cycle_y_3  <= VACTIVE_I - V_ACTIVE_divby10;
    I_x        <= HACTIVE_I - CYCLE_SMALL_VAL;
    I_y        <= CYCLE_SMALL_VAL;
    II_x       <= CYCLE_SMALL_VAL;
    II_y       <= CYCLE_SMALL_VAL;
    III_x      <= CYCLE_SMALL_VAL;
    III_y      <= VACTIVE_I - CYCLE_SMALL_VAL;
    IV_x       <= HACTIVE_I - CYCLE_SMALL_VAL;
    IV_y       <= VACTIVE_I - CYCLE_SMALL_VAL;

end




(*keep="true"*)reg [15:0]  rx= 0;
(*keep="true"*)reg [15:0]  ry= 0;
(*keep="true"*)reg [15:0]  Elipse_rx= 0;
(*keep="true"*)reg [15:0]  Elipse_ry= 0;
(*keep="true"*)wire [31:0] Elipse_rx2;
(*keep="true"*)wire [31:0] Elipse_ry2;
(*keep="true"*)wire [31:0] rx2;
(*keep="true"*)wire [31:0] ry2;
(*keep="true"*)wire [63:0] b2rx2;
(*keep="true"*)wire [63:0] a2ry2;
(*keep="true"*)wire [63:0] bb2rx2;
(*keep="true"*)wire [63:0] aa2ry2;
always @ (posedge CLK_I)
if(reset) begin
    v_step <= 'b0;
    DE_reg <= 1'b0;
end else  begin
    v_step <= (&w_VS) ? 0 : (v_step==V_ACTIVE_divby9) ? 0: ({w_DE[i],DE_reg}==2'b10) ? v_step + 1'd1 : v_step ;
    DE_reg <= w_DE[i] ;
end


reg [15:0]h_step_edge= 0 ;

always @ (posedge CLK_I)
    h_step_edge <= H_ACTIVE_reg[15:4]-R_PORT_NUM ;

always @ (posedge CLK_I)
if(reset) begin
  current_x <= i;
    h_step    <= i;
end else if(&w_DE) begin
  current_x <= current_x + R_PORT_NUM;
    h_step    <= (h_step >= h_step_edge ) ? h_step - h_step_edge : h_step + R_PORT_NUM;
end else begin
    h_step    <= (&w_HS) ? i : h_step;
  current_x <= i;
end

(*keep="true"*)reg [15:0] current_x_dly                 = 0;
(*keep="true"*)reg [15:0] current_y_dly                 = 0;
(*keep="true"*)reg [15:0] current_x_pre                 = 0;
(*keep="true"*)reg [15:0] current_y_pre                 = 0;
(*keep="true"*)reg [15:0] current_x_dly_reg[DLY_SRL : 0];
(*keep="true"*)reg [15:0] current_y_dly_reg[DLY_SRL : 0];

for (j = 0 ; j < DLY_SRL; j = j + 1) begin :  xy_P_dly
always @ (posedge CLK_I)
if(reset) begin
    current_x_dly_reg[j] <= 'b0;
  current_y_dly_reg[j]      <= 'b0;
end else begin
    current_x_dly_reg[j] <= current_x_dly_reg[j+1];
  current_y_dly_reg[j] <= current_y_dly_reg[j+1];
end
end

always @ (posedge CLK_I)
if(reset) begin
    current_x_pre <= 'b0;
    current_y_pre <= 'b0;
    current_x_dly <= 'b0;
    current_y_dly <= 'b0;
      current_x_dly_reg[DLY_SRL] <='b0 ;
      current_y_dly_reg[DLY_SRL]    <='b0;
end else begin
        current_x_pre                        <= current_x_dly_reg[1];
    current_y_pre                        <= current_y_dly_reg[1];
    current_x_dly                        <= current_x_dly_reg[0];
    current_y_dly                        <= current_y_dly_reg[0];
      current_x_dly_reg[DLY_SRL]           <= current_x;
      current_y_dly_reg[DLY_SRL]             <= current_y[i*16+:16];
end

wire [15:0]current_x_dly_w = current_x_dly_reg[1];
wire [15:0]current_y_dly_w = current_y_dly_reg[1];




(*keep="true"*)reg [15:0] h_step                     = 0      ;
(*keep="true"*)reg [15:0] v_step                     = 0      ;
(*keep="true"*)reg [15:0] h_step_pre                 = 0    ;
(*keep="true"*)reg [15:0] v_step_pre                 = 0    ;
(*keep="true"*)reg [15:0] h_step_dly                 = 0    ;
(*keep="true"*)reg [15:0] v_step_dly                 = 0    ;
(*keep="true"*)reg [15:0] h_step_dly_reg[DLY_SRL : 0] ;
(*keep="true"*)reg [15:0] v_step_dly_reg[DLY_SRL : 0] ;

for (j = 0 ; j < DLY_SRL; j = j + 1) begin :  hvstep_dly
always @ (posedge CLK_I)
if(reset) begin
    h_step_dly_reg[j] <= 'b0;
  v_step_dly_reg[j] <= 'b0;
end else begin
    h_step_dly_reg[j] <= h_step_dly_reg[j + 1];
  v_step_dly_reg[j] <= v_step_dly_reg[j + 1];
end
end

always @ (posedge CLK_I)
if(reset) begin
    h_step_pre <= 'b0;
    v_step_pre <= 'b0;
    h_step_dly <= 'b0;
    v_step_dly <= 'b0;
    h_step_dly_reg[DLY_SRL] <='b0 ;
    v_step_dly_reg[DLY_SRL]    <='b0;
end else begin
    h_step_pre                        <= h_step_dly_reg[1];
    v_step_pre                        <= v_step_dly_reg[1];
    h_step_dly                        <= h_step_dly_reg[0];
    v_step_dly                        <= v_step_dly_reg[0];
    h_step_dly_reg[DLY_SRL]  <= h_step;
    v_step_dly_reg[DLY_SRL]    <= v_step;
end




(*keep="true"*)reg  [31:0] rx2_ry2  = 0 ;
(*keep="true"*)reg  [31:0] rx2_ry2_reg[DLY_SRL-8 : 0];

(*keep="true"*)reg  [31:0] Elipse_rx2_ry2   = 0;
(*keep="true"*)reg  [31:0] Elipse_rx2_ry2_reg[DLY_SRL-8 : 0];


for (j = 0 ; j < DLY_SRL-8 ; j = j + 1) begin :cycle_dly
always @ (posedge CLK_I)
if(reset) begin
    rx2_ry2_reg[j] <= 'b0;
end else begin
    rx2_ry2_reg[j] <= rx2_ry2_reg[j+1] ;
end

always @ (posedge CLK_I)
if(reset) begin
    rx2_ry2                         <= 'b0;
    rx2_ry2_reg[DLY_SRL-8] <= 'b0;
end else begin
    rx2_ry2                         <= rx2_ry2_reg[0];
    rx2_ry2_reg[DLY_SRL-8] <= rx2 + ry2;
end

always @ (posedge CLK_I)
if(reset) begin
    Elipse_rx2_ry2_reg[j] <= 'b0;
end else begin
    Elipse_rx2_ry2_reg[j] <= Elipse_rx2_ry2_reg[j+1] ;
end

always @ (posedge CLK_I)
if(reset) begin
    Elipse_rx2_ry2                         <= 'b0;
    Elipse_rx2_ry2_reg[DLY_SRL-8] <= 'b0;
end else begin
    Elipse_rx2_ry2                         <= Elipse_rx2_ry2_reg[0];
    Elipse_rx2_ry2_reg[DLY_SRL-8] <= Elipse_rx2 + Elipse_ry2;
end


end





reg cycle_sp;
always @ (posedge CLK_I)
if(reset)
    cycle_sp <= 1'b0;
else
    cycle_sp <= (rx2_ry2 <= cycle_r) ? 1'b1 : 1'b0;



reg          x_pos  = 0 ;
reg          y_pos  = 0 ;
reg [1:0]quadrant= 0;


always @ (posedge CLK_I)
if(reset) begin
    quadrant    <= 2'b0;
end else begin
    if((current_x>=cycle_x_2)&(current_y[i*16+:16]<cycle_y_2)) begin
        quadrant       <= 2'b0;
    end else if((current_x<cycle_x_2)&(current_y[i*16+:16]<cycle_y_2)) begin
        quadrant      <= 2'b01;
    end else if((current_x<cycle_x_2)&(current_y[i*16+:16]>=cycle_y_2)) begin
        quadrant       <= 2'b10;
    end else begin
        quadrant       <= 2'b11;
    end
end





always @ (posedge CLK_I)
if(reset) begin
    x_pos       <= 1'b0;
    y_pos       <= 1'b0;
end else  case(PATSEL_I)
    8'd9 :  begin
                            x_pos  <= (current_x_dly_reg[DLY_SRL] > cycle_x_1) ;
                            y_pos  <= (current_y_dly_reg[DLY_SRL] > cycle_y_1);
                        end
        8'd10 :  begin
                            x_pos <= (current_x_dly_reg[DLY_SRL] > cycle_x_2) ;
                            y_pos <= (current_y_dly_reg[DLY_SRL] > cycle_y_1) ;
                        end
        8'd11 :  begin
                            x_pos <= (current_x_dly_reg[DLY_SRL] > cycle_x_3) ;
                            y_pos <= (current_y_dly_reg[DLY_SRL] > cycle_y_1) ;
                        end
        8'd12 :  begin
                            x_pos <= (current_x_dly_reg[DLY_SRL] > cycle_x_1) ;
                            y_pos <= (current_y_dly_reg[DLY_SRL] > cycle_y_2) ;
                        end
        8'd13 :  begin
                            x_pos <= (current_x_dly_reg[DLY_SRL] > cycle_x_2) ;
                            y_pos <=(current_y_dly_reg[DLY_SRL] > cycle_y_2);
                        end
        8'd14 :  begin
                            x_pos <= (current_x_dly_reg[DLY_SRL] > cycle_x_3) ;
                            y_pos <= (current_y_dly_reg[DLY_SRL] > cycle_y_2) ;
                        end
        8'd15 : begin
                            x_pos <= (current_x_dly_reg[DLY_SRL] > cycle_x_1) ;
                            y_pos <= (current_y_dly_reg[DLY_SRL] > cycle_y_3) ;
                        end
        8'd16 : begin
                            x_pos <= (current_x_dly_reg[DLY_SRL] > cycle_x_2) ;
                            y_pos <= (current_y_dly_reg[DLY_SRL] > cycle_y_3) ;
                        end

        8'd17 : begin
                            x_pos <= (current_x_dly_reg[DLY_SRL] > cycle_x_3) ;
                            y_pos <= (current_y_dly_reg[DLY_SRL] > cycle_y_3) ;
                        end
        8'd18,8'd21,8'd22 : if(quadrant==2'b00)  begin
                                                    x_pos                 <= (current_x_dly_reg[DLY_SRL-1] > I_x) ;
                                                    y_pos                 <= (current_y_dly_reg[DLY_SRL-1] > I_y) ;
                                                end else if(quadrant==2'b01) begin
                                                    x_pos                 <= (current_x_dly_reg[DLY_SRL-1] > II_x) ;
                                                    y_pos                 <= (current_y_dly_reg[DLY_SRL-1] > II_y) ;
                                                end else if(quadrant==2'b10) begin
                                                    x_pos                 <= (current_x_dly_reg[DLY_SRL-1] > III_x) ;
                                                    y_pos                 <= (current_y_dly_reg[DLY_SRL-1]> III_y) ;
                                                end else begin
                                                    x_pos             <= (current_x_dly_reg[DLY_SRL-1] > IV_x) ;
                                                    y_pos             <= (current_y_dly_reg[DLY_SRL-1] > IV_y) ;
                                                end
    default:;
endcase




always @ (posedge CLK_I)
if(reset) begin
   rx <= 'b0;
   ry <= 'b0;
end else case(PATSEL_I)
        8'd9 :  begin
                            rx       <= x_pos ?  current_x_dly_reg[DLY_SRL-1]            - cycle_x_1   : cycle_x_1 - current_x_dly_reg[DLY_SRL-1];
                            ry       <= y_pos ? current_y_dly_reg[DLY_SRL-1]  - cycle_y_1 : cycle_y_1 - current_y_dly_reg[DLY_SRL-1];
                        end
        8'd10 :  begin
                            rx <= x_pos ?  current_x_dly_reg[DLY_SRL-1]            - cycle_x_2   : cycle_x_2 - current_x_dly_reg[DLY_SRL-1];
                            ry <= y_pos ? current_y_dly_reg[DLY_SRL-1]  - cycle_y_1 : cycle_y_1 - current_y_dly_reg[DLY_SRL-1];
                        end
        8'd11 :  begin
                            rx <= x_pos ?  current_x_dly_reg[DLY_SRL-1]            - cycle_x_3   : cycle_x_3 - current_x_dly_reg[DLY_SRL-1];
                            ry <= y_pos ? current_y_dly_reg[DLY_SRL-1]  - cycle_y_1 : cycle_y_1 - current_y_dly_reg[DLY_SRL-1];
                        end
        8'd12 :  begin
                            rx <= x_pos ?  current_x_dly_reg[DLY_SRL-1]            - cycle_x_1   : cycle_x_1 - current_x_dly_reg[DLY_SRL-1];
                            ry <= y_pos ? current_y_dly_reg[DLY_SRL-1]  - cycle_y_2 : cycle_y_2 - current_y_dly_reg[DLY_SRL-1];
                        end
        8'd13 :  begin
                            rx <= x_pos ?  current_x_dly_reg[DLY_SRL-1]            - cycle_x_2   : cycle_x_2 - current_x_dly_reg[DLY_SRL-1];
                            ry <=y_pos ? current_y_dly_reg[DLY_SRL-1]  - cycle_y_2 : cycle_y_2 - current_y_dly_reg[DLY_SRL-1];
                        end
        8'd14 :  begin
                            rx <= x_pos ?  current_x_dly_reg[DLY_SRL-1]            - cycle_x_3   : cycle_x_3 - current_x_dly_reg[DLY_SRL-1];
                            ry <= y_pos ? current_y_dly_reg[DLY_SRL-1]  - cycle_y_2 : cycle_y_2 - current_y_dly_reg[DLY_SRL-1];
                        end
        8'd15 : begin
                            rx <= x_pos ?  current_x_dly_reg[DLY_SRL-1]            - cycle_x_1   : cycle_x_1 - current_x_dly_reg[DLY_SRL-1];
                            ry <= y_pos ? current_y_dly_reg[DLY_SRL-1]  - cycle_y_3 : cycle_y_3 - current_y_dly_reg[DLY_SRL-1];
                        end
        8'd16 : begin
                            rx <= x_pos ?  current_x_dly_reg[DLY_SRL-1]            - cycle_x_2   : cycle_x_2 - current_x_dly_reg[DLY_SRL-1];
                            ry <= y_pos ? current_y_dly_reg[DLY_SRL-1]  - cycle_y_3 : cycle_y_3 - current_y_dly_reg[DLY_SRL-1];
                        end

        8'd17 : begin
                            rx <= x_pos ?  current_x_dly_reg[DLY_SRL-1]            - cycle_x_3   : cycle_x_3 - current_x_dly_reg[DLY_SRL-1];
                            ry <= y_pos ?  current_y_dly_reg[DLY_SRL-1]  - cycle_y_3 : cycle_y_3 - current_y_dly_reg[DLY_SRL-1];
                        end
        8'd18,8'd21,8'd22 :begin
                                            if(quadrant==2'b00) begin
                                                    rx                 <= x_pos ? current_x_dly_reg[DLY_SRL-2] - I_x : I_x - current_x_dly_reg[DLY_SRL-2];
                                                    ry                 <= y_pos ? current_y_dly_reg[DLY_SRL-2]  - I_y  : I_y - current_y_dly_reg[DLY_SRL-2];

                                                    //Elipse_rx <= current_x_dly_reg[DLY_SRL-2] - cycle_x_2;
                                                    //Elipse_ry <= cycle_y_2 - current_y_dly_reg[DLY_SRL-2];
                                                end else if(quadrant==2'b01) begin
                                                    rx                 <=x_pos ? current_x_dly_reg[DLY_SRL-2] - II_x : II_x - current_x_dly_reg[DLY_SRL-2];
                                                    ry                 <= y_pos ? current_y_dly_reg[DLY_SRL-2]  - II_y : II_y - current_y_dly_reg[DLY_SRL-2];
                                                    //Elipse_rx <= cycle_x_2 - current_x_dly_reg[DLY_SRL-2];
                                                    //Elipse_ry <= cycle_y_2- current_y_dly_reg[DLY_SRL-2];
                                                end else if(quadrant==2'b10) begin
                                                    rx                 <= x_pos? current_x_dly_reg[DLY_SRL-2] - III_x : III_x - current_x_dly_reg[DLY_SRL-2];
                                                    ry                 <= y_pos? current_y[i*16+:16]  - III_y : III_y - current_y[i*16+:16];
                                                    //Elipse_rx <= cycle_x_2 - current_x_dly_reg[DLY_SRL-2];
                                                    //Elipse_ry <= current_y_dly_reg[DLY_SRL-2] - cycle_y_2;
                                                end else begin
                                                    rx                 <= x_pos ? current_x_dly_reg[DLY_SRL-2] - IV_x : IV_x - current_x_dly_reg[DLY_SRL-2];
                                                    ry                 <= y_pos ? current_y_dly_reg[DLY_SRL-2] - IV_y : IV_y - current_y_dly_reg[DLY_SRL-2];
                                                    //Elipse_rx <= current_x_dly_reg[DLY_SRL-2] - cycle_x_2;
                                                    //Elipse_ry <= current_y_dly_reg[DLY_SRL-2] - cycle_y_2;
                                                end
                                            end
endcase

always @ (posedge CLK_I)
if(reset) begin
    Elipse_rx <= 1'b0;
  Elipse_ry <= 1'b0;
end else begin
    Elipse_rx <= (current_x_dly_reg[DLY_SRL-2] >= cycle_x_2) ? current_x_dly_reg[DLY_SRL-2] - cycle_x_2 : cycle_x_2 - current_x_dly_reg[DLY_SRL-2];
  Elipse_ry <= (current_y_dly_reg[DLY_SRL-2] >= cycle_y_2) ? current_y_dly_reg[DLY_SRL-2] - cycle_y_2 : cycle_y_2 - current_y_dly_reg[DLY_SRL-2];
end


mult_gen_16 rx_inst (
  .CLK(CLK_I),  // input wire CLK
  .A(rx),      // input wire [15 : 0] A
  .B(rx),      // input wire [15 : 0] B
  .P(rx2)      // output wire [31 : 0] P
);

mult_gen_16 ry_inst (
  .CLK(CLK_I),  // input wire CLK
  .A(ry),      // input wire [15 : 0] A
  .B(ry),      // input wire [15 : 0] B
  .P(ry2)      // output wire [31 : 0] P
);


mult_gen_16 Elipse_rx_inst (
  .CLK(CLK_I),  // input wire CLK
  .A(Elipse_rx),      // input wire [15 : 0] A
  .B(Elipse_rx),      // input wire [15 : 0] B
  .P(Elipse_rx2)      // output wire [31 : 0] P
);

mult_gen_16 Elipse_ry_inst (
  .CLK(CLK_I),  // input wire CLK
  .A(Elipse_ry),      // input wire [15 : 0] A
  .B(Elipse_ry),      // input wire [15 : 0] B
  .P(Elipse_ry2)      // output wire [31 : 0] P
);


mult_gen_y b2rx2_inst (
  .CLK(CLK_I),  // input wire CLK
  .A(b2),      // input wire [15 : 0] A
  .B(Elipse_rx2),      // input wire [15 : 0] B
  .P(b2rx2)      // output wire [31 : 0] P
);

mult_gen_y a2ry2_inst (
  .CLK(CLK_I),  // input wire CLK
  .A(a2),      // input wire [15 : 0] A
  .B(Elipse_ry2),      // input wire [15 : 0] B
  .P(a2ry2)      // output wire [31 : 0] P
);

mult_gen_y bb2rx2_inst (
  .CLK(CLK_I),  // input wire CLK
  .A(bb2),      // input wire [15 : 0] A
  .B(Elipse_rx2),      // input wire [15 : 0] B
  .P(bb2rx2)      // output wire [31 : 0] P
);

mult_gen_y aa2ry2_inst (
  .CLK(CLK_I),  // input wire CLK
  .A(aa2),      // input wire [15 : 0] A
  .B(Elipse_ry2),      // input wire [15 : 0] B
  .P(aa2ry2)      // output wire [31 : 0] P
);



reg elise_cycle= 0;
reg cycle_cycle= 0;
reg cycle_cycle_1= 0;
reg elipse_sp  = 0;

always @(posedge CLK_I)
if(reset) begin
 elise_cycle <= 1'b0;
 cycle_cycle <= 1'b0;
 cycle_cycle_1 <= 1'b0;
 elipse_sp   <= 1'b0;
end else begin
 elise_cycle      <=((a2ry2_b2rx2<=a2b2)&(aa2ry2_bb2rx2 > aa2bb2))    ;
 cycle_cycle      <=(((rx2_ry2<=cycle_d2)&(rx2_ry2>cycle_dd2))|((Elipse_rx2_ry2<=cycle_d2)&(Elipse_rx2_ry2>cycle_dd2)));
 cycle_cycle_1 <=((Elipse_rx2_ry2<=b2)&(Elipse_rx2_ry2>bb2));
 elipse_sp   <=(a2ry2_b2rx2<=a2b2);
end





reg r_line      = 0;
reg r_clr_bar   = 0;
reg r_black     = 0;
reg r_gray      = 0;
reg r_blue      = 0;
reg r_red       = 0;
reg r_pink      = 0;
reg r_green     = 0;
reg r_light_blue= 0;
reg r_yellow    = 0;
reg r_white     = 0;

reg r_y_half  = 0;
reg r_five_y  = 0;
reg r_five_x_w= 0;
reg r_five_x_b= 0;
reg genbox= 0;



reg r_y_1_4= 0;
reg r_y_2_4= 0;
reg r_y_3_4= 0;
reg r_y_4_4= 0;



reg hdcp_bar= 0;
reg r_hdcp_0= 0;
reg r_hdcp_1= 0;
reg r_hdcp_2= 0;
reg r_hdcp_3= 0;
reg r_hdcp_4= 0;
reg r_hdcp_5= 0;
reg r_hdcp_6= 0;

reg r_hdr_x10= 0;
reg r_hdr_y10= 0;

reg r_hdr_x3= 0;
reg r_hdr_y3= 0;

reg r_hdr_x20= 0;
reg r_hdr_y20= 0;

reg r_hdr_x30= 0;
reg r_hdr_y30= 0;

reg r_moire_pre= 0;
reg r_moire= 0;
reg [DLY_SRL-1:0] r_moire_reg= 0;
reg r_moire_dot= 0;






always @ (posedge CLK_I)
if(reset)
    r_moire_pre <= 1'b0;
else if ((rx <= H_ACTIVE_reg[15:4])&(ry <= H_ACTIVE_reg[15:4]))
    r_moire_pre <= ry[2] ? rx[2] : ~rx[2];
else if((Elipse_rx <= H_ACTIVE_reg[15:4])&(Elipse_ry <= H_ACTIVE_reg[15:4]))
    r_moire_pre <= quadrant[1] ? Elipse_ry[2] ? Elipse_rx[2] : ~Elipse_rx[2] :
                                                             Elipse_ry[2] ? ~Elipse_rx[2] : Elipse_rx[2];
else
    r_moire_pre <= 1'b0;






for (j = 0 ; j < DLY_SRL-5 ; j = j + 1) begin :moire
always @ (posedge CLK_I)
if(reset) begin
    r_moire_reg[j] <= 'b0;
end else begin
    r_moire_reg[j] <= r_moire_reg[j+1] ;
end

always @ (posedge CLK_I)
if(reset) begin
    r_moire                         <= 'b0;
    r_moire_reg[DLY_SRL-5] <= 'b0;
end else begin
    r_moire                         <= r_moire_reg[0];
    r_moire_reg[DLY_SRL-5] <= r_moire_pre;
end
end




reg  r_AA = 0; //yzhu

always @(posedge CLK_I)
begin
    r_AA    <= current_y_pre==1 | current_y_pre==V_ACTIVE_reg | current_x_pre==1 | current_x_pre==H_ACTIVE_reg  ;

    r_line       <=((h_step_pre<=3)|(v_step_pre<=3)|(current_x_pre>=hactivemin4) | (current_y_pre >= vactivemin4));
    r_clr_bar    <=((current_y_pre > vactivemult7div9)&(current_y_pre< {V_ACTIVE_divby9[12:0],3'b0}));
    r_black      <=(current_x_pre <= H_ACTIVE_reg[15:2]);
    r_gray       <=(current_x_pre <= hactivemult5div16);
    r_blue       <=(current_x_pre <= hactivemult3div8);
    r_red        <=(current_x_pre <= hactivemult7div16);
    r_pink       <=(current_x_pre <= H_ACTIVE_reg[15:1]);
    r_green      <=(current_x_pre <= hactivemult9div16);
    r_light_blue <=(current_x_pre <= hactivemult5div8);
    r_yellow     <=(current_x_pre <= hactivemult11div16);
    r_white      <=(current_x_pre <= hactivemult3div4);

    r_y_half     <= ( current_y_pre >= V_ACTIVE_reg[15:1]);
    r_y_1_4      <= ( current_y_pre < V_ACTIVE_reg[15:2]);
    r_y_2_4      <= ( current_y_pre < V_ACTIVE_reg[15:1]) &  ( current_y_pre >= V_ACTIVE_reg[15:2]);
    r_y_3_4      <= ( current_y_pre < V_ACTIVE_reg[15:2] * 3) &  ( current_y_pre >= V_ACTIVE_reg[15:1]);
    r_y_4_4      <= ( current_y_pre < V_ACTIVE_reg) &  ( current_y_pre >= V_ACTIVE_reg[15:2] * 3);

    r_five_y     <= ((current_y_pre<=V_ACTIVE_divby3)|   ((current_y_pre > {V_ACTIVE_divby3,1'b0})));
    r_five_x_w   <= ((current_x_pre > H_ACTIVE_reg[15:2])&(current_x_pre <= hactivemult3div4));
    r_five_x_b   <= ((current_x_pre >  hactivemult3div8) &(current_x_pre <= hactivemult5div8))    ;

    genbox       <= (((current_x_pre > hactivemult9div10)  | (current_x_pre <= H_ACTIVE_divby10))  &
                                     ((current_y_pre > vactivemult9div10) | (current_y_pre <= V_ACTIVE_divby10)));

    //genbox       <= 1'b0;

    hdcp_bar     <= (current_y_pre > V_ACTIVE_reg[15:2] * 3);
    r_hdcp_0     <= (current_x_pre <= H_ACTIVE_reg[15:3]);
    r_hdcp_1     <= (current_x_pre <= H_ACTIVE_reg[15:2]);
    r_hdcp_2     <= (current_x_pre <= hactivemult3div8);
    r_hdcp_3     <= (current_x_pre <= H_ACTIVE_reg[15:1]);
    r_hdcp_4     <= (current_x_pre <= hactivemult5div8);
    r_hdcp_5     <= (current_x_pre <= hactivemult3div4);
    r_hdcp_6     <= (current_x_pre <= hactivemult7div8);

    r_hdr_x3      <= (current_x_pre < hactivemult6div10)&((current_x_pre >= hactivemult4div10));
     r_hdr_y3      <= (current_y_pre < vactivemult6div10)&((current_y_pre >= vactivemult4div10));

    r_hdr_x10      <= (current_x_pre < hactivemult13div20)&((current_x_pre >= hactivemult7div20));
     r_hdr_y10      <= (current_y_pre < vactivemult13div20)&((current_y_pre >= vactivemult7div20));

    r_hdr_x20      <= (current_x_pre >= hactivemult5div20)&((current_x_pre < hactivemult15div20));
     r_hdr_y20      <= (current_y_pre >= vactivemult5div20)&((current_y_pre < vactivemult15div20));

    r_hdr_x30      <= (current_x_pre >= hactivemult4div20)&((current_x_pre < hactivemult16div20));
    r_hdr_y30      <= (current_y_pre >= vactivemult4div20)&((current_y_pre < vactivemult16div20));

end


always @ (posedge CLK_I)
if(reset)
    r_moire_dot <= 1'b0;
else
    //r_moire_dot <= 1'b0;
    r_moire_dot <= (current_x_pre[3:2] ==  current_y_pre[3:2]);





(*keep="true"*)reg [3:0]  r_vs_count= 0;
(*keep="true"*)reg [15:0]    r_hs_p= 0;
(*keep="true"*)reg [15:0]    r_vs_p= 0;
(*keep="true"*)reg                r_vedio_dynamic= 0;


(*keep="true"*)reg [15:0]    r_hs_p_pre= 0;
(*keep="true"*)reg [15:0]    r_vs_p_pre= 0;




always @ (posedge CLK_I)
if(reset) begin
  RGB_R[i*8 +: 8] <= 8'hFF;
  RGB_G[i*8 +: 8] <= 8'hFF;
  RGB_B[i*8 +: 8] <= 8'hFF;
  step_cnt                <=     i;
  step_pixel            <= 8'b0;
  step_pixel_reg  <= 8'b0;
end else case(PATSEL_I)
                8'd0,8'd25 : begin //黑（0，0，0）
                                    RGB_R[i*8 +: 8] <= 8'h0;
                                    RGB_G[i*8 +: 8] <= 8'h0;
                                    RGB_B[i*8 +: 8] <= 8'h0;
                              end
                8'd1,8'd24  : begin //白（255，255，255）
                                  RGB_R[i*8 +: 8] <= 8'hFF;
                                  RGB_G[i*8 +: 8] <= 8'hFF;
                                  RGB_B[i*8 +: 8] <= 8'hFF;
                              end
                8'd2 : begin //红（255，0，0）
                                   RGB_R[i*8 +: 8] <= 8'hFF;
                                   RGB_G[i*8 +: 8] <= 8'h0;
                                   RGB_B[i*8 +: 8] <= 8'h0;
                              end
                8'd3 : begin //绿（0，255，0）
                                RGB_R[i*8 +: 8] <= 8'h0;
                                RGB_G[i*8 +: 8] <= 8'hFF;
                                RGB_B[i*8 +: 8] <= 8'h0;
                              end
                8'd4 : begin //蓝（0，0，255）
                                RGB_R[i*8 +: 8] <= 8'h0;
                                RGB_G[i*8 +: 8] <= 8'h0;
                                RGB_B[i*8 +: 8] <= 8'hFF;
                              end
                8'd5 : begin //50%灰（128，128，128）
                                RGB_R[i*8 +: 8] <= 8'h80;
                                RGB_G[i*8 +: 8] <= 8'h80;
                                RGB_B[i*8 +: 8] <= 8'h80;
                             end

                8'd6,8'd26 : begin //32灰阶
                                    RGB_R[i*8 +: 8] <= r_y_half ?  8'hFF - step_pixel : 8'h07 + step_pixel ;
                                    RGB_G[i*8 +: 8] <= r_y_half ?  8'hFF - step_pixel : 8'h07 + step_pixel ;
                                    RGB_B[i*8 +: 8] <= r_y_half ?  8'hFF - step_pixel : 8'h07 + step_pixel ;
                                    step_val          <= DE_dly[i]  ?  (step_remain <= R_HACTIVE[4:0]) ?  R_HACTIVE[15:5] + 1 : R_HACTIVE[15:5] : R_HACTIVE[15:5];
                                    step_remain     <= DE_dly[i]  ? (step_cnt >= step_val-1) ? step_remain - 1 : step_remain : 32;
                                    step_cnt          <= DE_dly[i]  ? (step_cnt >= step_val-1) ? 0 : step_cnt + 1 : 1;
                                    step_pixel        <= DE_dly[i]  ?  step_pixel_reg  : 'b0;
                                    step_pixel_reg  <= DE_dly[i]  ? (step_cnt >= step_val-1) ?  step_pixel_reg + 8  : step_pixel_reg : 'b0;
                                end


                8'd7 :  begin //256灰阶
                                RGB_R[i*8 +: 8] <= r_y_half ?  8'hFF - step_pixel  : 8'h00 + step_pixel ;
                                RGB_G[i*8 +: 8] <= r_y_half ?  8'hFF - step_pixel  : 8'h00 + step_pixel ;
                                RGB_B[i*8 +: 8] <= r_y_half ?  8'hFF - step_pixel  : 8'h00 + step_pixel ;
                                step_val        <= DE_dly[i]  ? (step_remain <= R_HACTIVE[7:0]) ? R_HACTIVE[15:8] + 1 : R_HACTIVE[15:8] : R_HACTIVE[15:8];
                                step_remain     <= DE_dly[i]  ? (step_cnt >= step_val-1) ? step_remain - 1 : step_remain : 256;
                                step_cnt        <= DE_dly[i]  ? (step_cnt >= step_val-1) ? 0 : step_cnt + 1 : 1;
                                step_pixel        <= DE_dly[i]  ?  step_pixel_reg  : 'b0;
                                step_pixel_reg  <= DE_dly[i]  ? (step_cnt >= step_val-1) ?  step_pixel_reg + 1  : step_pixel_reg : 'b0;


                                end





                8'd8 :  //五方格
                                if (r_five_y) begin
                                 RGB_R[i*8 +: 8] <= r_five_x_w ? 8'h00 : 8'hFF;
                                 RGB_G[i*8 +: 8] <= r_five_x_w ? 8'h00 : 8'hFF;
                                 RGB_B[i*8 +: 8] <= r_five_x_w ? 8'h00 : 8'hFF;
                                end else begin
                                 RGB_R[i*8 +: 8] <= r_five_x_b ? 8'hFF : 8'h00;
                                 RGB_G[i*8 +: 8] <= r_five_x_b ? 8'hFF : 8'h00;
                                 RGB_B[i*8 +: 8] <= r_five_x_b ? 8'hFF : 8'h00;

                              end


                8'd9,8'd10,8'd11,8'd12,8'd13,8'd14,8'd15,8'd16,8'd17 :begin
                                        RGB_R[i*8 +: 8] <= cycle_sp ? 8'hFF : 8'h00;
                                        RGB_G[i*8 +: 8] <= cycle_sp ? 8'hFF : 8'h00;
                                        RGB_B[i*8 +: 8] <= cycle_sp ? 8'hFF : 8'h00;
                                end
                8'd18 : if (r_line) begin
                                        RGB_R[i*8 +: 8] <= 8'hFF;
                                        RGB_G[i*8 +: 8] <= 8'hFF;
                                        RGB_B[i*8 +: 8] <= 8'hFF;
                                end else if (elise_cycle | cycle_cycle | r_moire) begin
                                        RGB_R[i*8 +: 8] <= 8'hFF;
                                        RGB_G[i*8 +: 8] <= 8'hFF;
                                        RGB_B[i*8 +: 8] <= 8'hFF;
                                end
                                else if (r_clr_bar) begin
                                        if(r_black)begin
                                        RGB_R[i*8 +: 8] <= 8'h00;
                                        RGB_G[i*8 +: 8] <= 8'h00;
                                        RGB_B[i*8 +: 8] <= 8'h00;
                                    end else if(r_gray)begin
                                        RGB_R[i*8 +: 8] <= 8'h80;
                                        RGB_G[i*8 +: 8] <= 8'h80;
                                        RGB_B[i*8 +: 8] <= 8'h80;
                                    end else if(r_blue)begin
                                            RGB_R[i*8 +: 8] <= 8'h00;
                                            RGB_G[i*8 +: 8] <= 8'h00;
                                            RGB_B[i*8 +: 8] <= 8'hFF;
                                    end else if(r_red) begin
                                            RGB_R[i*8 +: 8] <= 8'hFF;
                                            RGB_G[i*8 +: 8] <= 8'h0;
                                            RGB_B[i*8 +: 8] <= 8'h0;
                                    end else if(r_pink) begin
                                            RGB_R[i*8 +: 8] <= 8'hFF;
                                            RGB_G[i*8 +: 8] <= 8'h00;
                                            RGB_B[i*8 +: 8] <= 8'hFF;
                                    end else if(r_green) begin
                                            RGB_R[i*8 +: 8] <= 8'h00;
                                            RGB_G[i*8 +: 8] <= 8'hFF;
                                            RGB_B[i*8 +: 8] <= 8'h00;
                                    end else if(r_light_blue) begin
                                            RGB_R[i*8 +: 8] <= 8'h00;
                                            RGB_G[i*8 +: 8] <= 8'hFF;
                                            RGB_B[i*8 +: 8] <= 8'hFF;
                                    end else if(r_yellow) begin
                                            RGB_R[i*8 +: 8] <= 8'hFF;
                                            RGB_G[i*8 +: 8] <= 8'hFF;
                                            RGB_B[i*8 +: 8] <= 8'h00;
                                    end else if(r_white) begin
                                            RGB_R[i*8 +: 8] <= 8'hFF;
                                            RGB_G[i*8 +: 8] <= 8'hFF;
                                            RGB_B[i*8 +: 8] <= 8'hFF;
                                    end else begin
                                            RGB_R[i*8 +: 8] <= 8'h0;
                                            RGB_G[i*8 +: 8] <= 8'h0;
                                            RGB_B[i*8 +: 8] <= 8'h0;
                                        end
                                    end
                                    else begin
                                            RGB_R[i*8 +: 8] <= 8'h0;
                                            RGB_G[i*8 +: 8] <= 8'h0;
                                            RGB_B[i*8 +: 8] <= 8'h0;
                                        end
                8'd19 : begin
                                    RGB_R[i*8 +: 8] <= UART_R_I;
                                    RGB_G[i*8 +: 8] <= UART_G_I;
                                    RGB_B[i*8 +: 8] <= UART_B_I;
                              end
                8'd20 : if(hdcp_bar) begin
                                        if(r_hdcp_1)begin
                                                RGB_R[i*8 +: 8] <= 8'b0;
                                                RGB_G[i*8 +: 8] <= 8'b0;
                                                RGB_B[i*8 +: 8] <= 8'b0;
                                        end else if(r_hdcp_3) begin
                                                RGB_R[i*8 +: 8] <= 8'hFF;
                                                RGB_G[i*8 +: 8] <= 8'hFF;
                                                RGB_B[i*8 +: 8] <= 8'hFF;
                                        end else if(r_hdcp_5) begin
                                                RGB_R[i*8 +: 8] <= 8'h80;
                                                RGB_G[i*8 +: 8] <= 8'h80;
                                                RGB_B[i*8 +: 8] <= 8'hFF;
                                        end else begin
                                                RGB_R[i*8 +: 8] <= 8'hFF;
                                                RGB_G[i*8 +: 8] <= 8'h80;
                                                RGB_B[i*8 +: 8] <= 8'h80;
                                        end
                                    end
                                    else begin
                                        if(r_hdcp_0)begin
                                        RGB_R[i*8 +: 8] <= 8'h80;
                                        RGB_G[i*8 +: 8] <= 8'h80;
                                        RGB_B[i*8 +: 8] <= 8'h80;
                                    end else if(r_hdcp_1)begin
                                            RGB_R[i*8 +: 8] <= 8'h00;
                                            RGB_G[i*8 +: 8] <= 8'h00;
                                            RGB_B[i*8 +: 8] <= 8'hFF;
                                    end else if(r_hdcp_2) begin
                                            RGB_R[i*8 +: 8] <= 8'hFF;
                                            RGB_G[i*8 +: 8] <= 8'h0;
                                            RGB_B[i*8 +: 8] <= 8'h0;
                                    end else if(r_hdcp_3) begin
                                            RGB_R[i*8 +: 8] <= 8'hFF;
                                            RGB_G[i*8 +: 8] <= 8'h00;
                                            RGB_B[i*8 +: 8] <= 8'hFF;
                                    end else if(r_hdcp_4) begin
                                            RGB_R[i*8 +: 8] <= 8'h00;
                                            RGB_G[i*8 +: 8] <= 8'hFF;
                                            RGB_B[i*8 +: 8] <= 8'h00;
                                    end else if(r_hdcp_5) begin
                                            RGB_R[i*8 +: 8] <= 8'h00;
                                            RGB_G[i*8 +: 8] <= 8'hFF;
                                            RGB_B[i*8 +: 8] <= 8'hFF;
                                    end else if(r_hdcp_6) begin
                                            RGB_R[i*8 +: 8] <= 8'hFF;
                                            RGB_G[i*8 +: 8] <= 8'hFF;
                                            RGB_B[i*8 +: 8] <= 8'h00;
                                    end else begin
                                            RGB_R[i*8 +: 8] <= 8'hFF;
                                            RGB_G[i*8 +: 8] <= 8'hFF;
                                            RGB_B[i*8 +: 8] <= 8'hFF;
                                        end
                                    end
                    8'd27     : if(r_hdr_x3&r_hdr_y3) begin
                                                RGB_R[i*8 +: 8] <= 8'hFF;
                                                RGB_G[i*8 +: 8] <= 8'hFF;
                                                RGB_B[i*8 +: 8] <= 8'hFF;
                                        end else begin
                                                RGB_R[i*8 +: 8] <= 8'h0;
                                                RGB_G[i*8 +: 8] <= 8'h0;
                                                RGB_B[i*8 +: 8] <= 8'h0;
                                        end
                    8'd21     : if(r_hdr_x10&r_hdr_y10) begin
                                                RGB_R[i*8 +: 8] <= 8'hFF;
                                                RGB_G[i*8 +: 8] <= 8'hFF;
                                                RGB_B[i*8 +: 8] <= 8'hFF;
                                        end else begin
                                                RGB_R[i*8 +: 8] <= 8'h0;
                                                RGB_G[i*8 +: 8] <= 8'h0;
                                                RGB_B[i*8 +: 8] <= 8'h0;
                                        end

                    8'd22     : if(r_hdr_x20&r_hdr_y20) begin
                                                RGB_R[i*8 +: 8] <= 8'hFF;
                                                RGB_G[i*8 +: 8] <= 8'hFF;
                                                RGB_B[i*8 +: 8] <= 8'hFF;
                                        end else begin
                                                RGB_R[i*8 +: 8] <= 8'h0;
                                                RGB_G[i*8 +: 8] <= 8'h0;
                                                RGB_B[i*8 +: 8] <= 8'h0;
                                        end

                    8'd23     : if(r_hdr_x30&r_hdr_y30) begin
                                                RGB_R[i*8 +: 8] <= 8'hFF;
                                                RGB_G[i*8 +: 8] <= 8'hFF;
                                                RGB_B[i*8 +: 8] <= 8'hFF;
                                        end else begin
                                                RGB_R[i*8 +: 8] <= 8'h0;
                                                RGB_G[i*8 +: 8] <= 8'h0;
                                                RGB_B[i*8 +: 8] <= 8'h0;
                                        end
                    8'd28  : if(genbox)begin
                                                RGB_R[i*8 +: 8] <= 8'hFF;
                                                RGB_G[i*8 +: 8] <= 8'hFF;
                                                RGB_B[i*8 +: 8] <= 8'hFF;
                                        end else begin
                                                RGB_R[i*8 +: 8] <= 8'h0;
                                                RGB_G[i*8 +: 8] <= 8'h0;
                                                RGB_B[i*8 +: 8] <= 8'h0;
                                        end

                    8'd29   : begin
                                        if(~r_y_half)
                                            begin //256灰阶
                                            RGB_R[i*8 +: 8] <= step_pixel   ;
                                            RGB_G[i*8 +: 8] <= step_pixel   ;
                                            RGB_B[i*8 +: 8] <= step_pixel   ;

                                            step_val        <= DE_dly[i]  ? (step_remain <= R_HACTIVE[7:0]) ? R_HACTIVE[15:8] + 1 : R_HACTIVE[15:8] : R_HACTIVE[15:8];
                                            step_remain     <= DE_dly[i]  ? (step_cnt >= step_val-1) ? step_remain - 1 : step_remain : 256;
                                            step_cnt        <= DE_dly[i]  ? (step_cnt >= step_val-1) ? 0 : step_cnt + 1 : 1;
                                            step_pixel        <= DE_dly[i]  ?  step_pixel_reg  : 'b0;
                                            step_pixel_reg  <= DE_dly[i]  ? (step_cnt >= step_val-1) ?  step_pixel_reg + 1  : step_pixel_reg : 'b0;
                                  end else begin
                                            if(r_hdcp_0)begin
                                        RGB_R[i*8 +: 8] <= 8'h80;
                                        RGB_G[i*8 +: 8] <= 8'h80;
                                        RGB_B[i*8 +: 8] <= 8'h80;
                                    end else if(r_hdcp_1)begin
                                            RGB_R[i*8 +: 8] <= 8'h00;
                                            RGB_G[i*8 +: 8] <= 8'h00;
                                            RGB_B[i*8 +: 8] <= 8'hFF;
                                    end else if(r_hdcp_2) begin
                                            RGB_R[i*8 +: 8] <= 8'hFF;
                                            RGB_G[i*8 +: 8] <= 8'h0;
                                            RGB_B[i*8 +: 8] <= 8'h0;
                                    end else if(r_hdcp_3) begin
                                            RGB_R[i*8 +: 8] <= 8'hFF;
                                            RGB_G[i*8 +: 8] <= 8'h00;
                                            RGB_B[i*8 +: 8] <= 8'hFF;
                                    end else if(r_hdcp_4) begin
                                            RGB_R[i*8 +: 8] <= 8'h00;
                                            RGB_G[i*8 +: 8] <= 8'hFF;
                                            RGB_B[i*8 +: 8] <= 8'h00;
                                    end else if(r_hdcp_5) begin
                                            RGB_R[i*8 +: 8] <= 8'h00;
                                            RGB_G[i*8 +: 8] <= 8'hFF;
                                            RGB_B[i*8 +: 8] <= 8'hFF;
                                    end else if(r_hdcp_6) begin
                                            RGB_R[i*8 +: 8] <= 8'hFF;
                                            RGB_G[i*8 +: 8] <= 8'hFF;
                                            RGB_B[i*8 +: 8] <= 8'h00;
                                    end else begin
                                            RGB_R[i*8 +: 8] <= 8'hFF;
                                            RGB_G[i*8 +: 8] <= 8'hFF;
                                            RGB_B[i*8 +: 8] <= 8'hFF;
                                        end
                                    end

                                end

                        8'd30 : begin
                                RGB_R[i*8 +: 8] <= (r_y_1_4|r_y_4_4) ? 8'h00 + step_pixel  : 8'h00;
                                RGB_G[i*8 +: 8] <= (r_y_2_4|r_y_4_4) ? 8'h00 + step_pixel  : 8'h00;
                                RGB_B[i*8 +: 8] <= (r_y_3_4|r_y_4_4) ? 8'h00 + step_pixel  : 8'h00;
                                step_val        <= DE_dly[i]  ? (step_remain <= R_HACTIVE[7:0]) ? R_HACTIVE[15:8] + 1 : R_HACTIVE[15:8] : R_HACTIVE[15:8];
                                step_remain     <= DE_dly[i]  ? (step_cnt >= step_val-1) ? step_remain - 1 : step_remain : 256;
                                step_cnt        <= DE_dly[i]  ? (step_cnt >= step_val-1) ? 0 : step_cnt + 1 : 1;
                                step_pixel        <= DE_dly[i]  ?  step_pixel_reg  : 'b0;
                                step_pixel_reg  <= DE_dly[i]  ? (step_cnt >= step_val-1) ?  step_pixel_reg + 1  : step_pixel_reg : 'b0;
                                end
                        8'd31 : if(r_moire_dot)begin
                                                RGB_R[i*8 +: 8] <= 8'hFF;
                                                RGB_G[i*8 +: 8] <= 8'hFF;
                                                RGB_B[i*8 +: 8] <= 8'hFF;
                                        end else begin
                                                RGB_R[i*8 +: 8] <= 8'h0;
                                                RGB_G[i*8 +: 8] <= 8'h0;
                                                RGB_B[i*8 +: 8] <= 8'h0;
                                        end
                    8'd100  : if (r_line) begin
                                        RGB_R[i*8 +: 8] <= 8'hFF;
                                        RGB_G[i*8 +: 8] <= 8'hFF;
                                        RGB_B[i*8 +: 8] <= 8'hFF;
                                end else if (r_vedio_dynamic) begin
                                        RGB_R[i*8 +: 8] <= UART_R_I;
                                        RGB_G[i*8 +: 8] <= UART_G_I;
                                        RGB_B[i*8 +: 8] <= UART_B_I;
                                end else begin
                                        RGB_R[i*8 +: 8] <= 8'h0;
                                        RGB_G[i*8 +: 8] <= 8'h0;
                                        RGB_B[i*8 +: 8] <= 8'h0;
                                end

                    8'd101 : begin
                            if(r_AA)begin
                                RGB_R[i*8 +: 8] <= 8'hFF;
                                RGB_G[i*8 +: 8] <= 8'hFF;
                                RGB_B[i*8 +: 8] <= 8'hFF;
                            end
                            else begin
                                RGB_R[i*8 +: 8] <= 8'h00;
                                RGB_G[i*8 +: 8] <= 8'h00;
                                RGB_B[i*8 +: 8] <= 8'h00;
                            end
                    end

                default:;
endcase



end
endgenerate





(*keep="true"*)reg  vs_pos= 0;
reg  vs_reg= 0;
always @(posedge CLK_I)
if(reset) begin
    vs_pos <= 'b0;
  vs_reg <= 'b0;
end else begin
    vs_pos <= {w_VS[0],vs_reg} == 2'b10 ? 1'b1 : 1'b0;
  vs_reg <= w_VS[0];
end

wire                 w_HS_1      ;
wire                 w_VS_1      ;
wire                 w_DE_1      ;
wire [15:0] w_current_y ;
wire [15:0] w_current_x ;


/*
(*KEEP_HIERARCHY="true"*)
tpg
    #(.OUTPUT_REGISTER_EN(1),  // 改善时序
      .HARD_TIMING_EN    (0),
      .PORT_NUM          (1)
      )
    tpg_u(
    .PIXEL_CLK_I     (CLK_I    ),
    .RESETN_I        (~reset   ),

    .HSYNC_I         (  R_HSYNC       ),
    .HBP_I           (  R_HBP         ),
    .HACTIVE_I       (  R_HACTIVE     ),
    .HFP_I           (  R_HFP         ),

    .VSYNC_I         (  R_VSYNC       ),
    .VBP_I           (  R_VBP         ),
    .VACTIVE_I       (  R_VACTIVE     ),
    .VFP_I           (  R_VFP         ),


    .HS_O            (w_HS_1           ),// tpg driver
    .VS_O            (w_VS_1           ),
    .DE_O            (w_DE_1           ),
    .R_O             (                 ),  //内部pattern打开后，此处出pattern内容
    .G_O             (                 ),
    .B_O             (                 ),
    .ACTIVE_X_O      (w_current_x      ),//16bit    from 1
    .ACTIVE_Y_O      (w_current_y      ) //16bit    from 1
    );

*/


// original

(*KEEP_HIERARCHY="true"*)
tpg_phiyo TPG_inst(
    .vid_clk_in   (CLK_I ),
    .sys_rst_n    (~reset), // active low
    .hs_out       (w_HS_1),
    .vs_out       (w_VS_1),
    .vid_de       (w_DE_1),

    .hpixel       (R_HACTIVE   ),
    .hfporch      (R_HFP       ),
    .hbporch      (R_HBP       ),
    .hpwidth      (R_HSYNC     ),


    .vpixel       (R_VACTIVE   ),
    .vfporch      (R_VFP       ),
    .vbporch      (R_VSYNC     ),
    .vpwidth      (R_VBP       ),

    .active_h_cnt (w_current_x),//from  1
    .active_v_cnt (w_current_y) //from  1
  );




`DELAY_OUTGEN(CLK_I,0,w_current_x,ACTIVE_X_O,16,17)
`DELAY_OUTGEN(CLK_I,0,(w_current_y+1),ACTIVE_Y_O,16,17)



generate
for (i = 0 ; i < C_PORT_NUM ; i = i + 1 ) begin : tpg_gen


always @ (*)begin
    w_HS[i]             <= w_HS_1       ;
    w_VS[i]             <= w_VS_1       ;
    w_DE[i]             <= w_DE_1       ;
    current_y[i*16+:16] <= w_current_y  ;
end


 always @ (posedge CLK_I)
if(reset ) begin
   VS_O[i]     <= 'b0;
   HS_O[i]     <= 'b0;
   DE_O[i]     <= 'b0;
   R_O[8*i+:8] <= 'b0;
   G_O[8*i+:8] <= 'b0;
   B_O[8*i+:8] <= 'b0;
end else begin
  VS_O[i]       <= ~VS[i];
  HS_O[i]       <= ~HS[i];
  DE_O[i]       <= DE[i];
  R_O[8*i+:8]   <= RGB_R[8*i+:8];
  G_O[8*i+:8]   <= RGB_G[8*i+:8];
  B_O[8*i+:8]   <= RGB_B[8*i+:8];
end




end
endgenerate






endmodule






