`define DELAY_OUTGEN(clk,rst,data_in,data_out,DATA_WIDTH,DLY)                                           generate if(DLY==0)begin  assign data_out = data_in; end  else if(DLY==1)begin  reg [DATA_WIDTH-1:0] a_temp = 0; always@(posedge clk) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [DATA_WIDTH-1:0] a_temp [DLY-1:0] ;always@(posedge clk) begin  if(rst)a_temp[DLY-1] <= 0; else   a_temp[DLY-1] <= data_in; end  for(i=0;i<=DLY-2;i=i+1)begin  always@(posedge clk)begin  if(rst)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  endgenerate
`define DELAY_INGEN(clk,rst,data_in,data_out,DATA_WIDTH,DLY)                                            if(DLY==0)begin  assign data_out = data_in; end  else if(DLY==1)begin  reg [DATA_WIDTH-1:0] a_temp = 0; always@(posedge clk) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [DATA_WIDTH-1:0] a_temp [DLY-1:0] ;always@(posedge clk) begin  if(rst)a_temp[DLY-1] <= 0; else   a_temp[DLY-1] <= data_in; end  for(i=0;i<=DLY-2;i=i+1)begin  always@(posedge clk)begin  if(rst)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  

//旧版本
//`define ADDR_GPI_IRPT_STS_0  16'h0010   //gpi io 中断状态寄存器
//`define ADDR_GPI_IRPT_STS_1  16'h0014 
//`define ADDR_GPI_IRPT_STS_2  16'h0018 
//`define ADDR_GPI_IRPT_STS_3  16'h001C 
//`define ADDR_GPI_IRPT_STS_4  16'h0020 
//`define ADDR_GPI_IRPT_STS_5  16'h0024 
//`define ADDR_GPI_IRPT_STS_6  16'h0028 
//`define ADDR_GPI_IRPT_STS_7  16'h002C 

//新版本
`define ADDR_GPI_IRPT_STS_0   16'h100C    // GPI 的中断状态，例如电平中断，脉冲中断
`define ADDR_GPI_IRPT_STS_1   16'h200C 
`define ADDR_GPI_IRPT_STS_2   16'h300C 
`define ADDR_GPI_IRPT_STS_3   16'h400C 
`define ADDR_GPI_IRPT_STS_4   16'h500C 
`define ADDR_GPI_IRPT_STS_5   16'h600C 
`define ADDR_GPI_IRPT_STS_6   16'h700C 
`define ADDR_GPI_IRPT_STS_7   16'h800C 




/*
io_irpt_sts  
    
    #(.C_CH_NUM    (8) ,
      .C_GPI_WIDTH (8) ,
      .C_IRPT_PRD_NUM (10) ,
      .C_PRD_CLK_NS   ( 10),
      .C_PULSE_DET_THRESHOLD_MS (1) ) 
    io_irpt_sts_u(
    .CLK_I             (),
    .RSTN_I            (), 
    .RD_I              (),
    .RD_ADDR_I         (),
    .GPI_CH0_I         (),  
    .GPI_CH1_I         (),
    .GPI_CH2_I         (),
    .GPI_CH3_I         (),
    .GPI_CH4_I         (),
    .GPI_CH5_I         (),
    .GPI_CH6_I         (),
    .GPI_CH7_I         (),
    .GPI_INT_STS_CH0_O (),
    .GPI_INT_STS_CH1_O (),
    .GPI_INT_STS_CH2_O (),
    .GPI_INT_STS_CH3_O (),
    .GPI_INT_STS_CH4_O (),
    .GPI_INT_STS_CH5_O (),
    .GPI_INT_STS_CH6_O (),
    .GPI_INT_STS_CH7_O (),
    
    .IRPT_MODE_CH0_I (),  
    .IRPT_MODE_CH2_I (),
    .IRPT_MODE_CH3_I (),
    .IRPT_MODE_CH4_I (),
    .IRPT_MODE_CH5_I (),
    .IRPT_MODE_CH6_I (),
    .IRPT_MODE_CH7_I (),

    .IRPT_EN_CH0_I () ,  
    .IRPT_EN_CH1_I () ,
    .IRPT_EN_CH2_I () ,
    .IRPT_EN_CH3_I () ,
    .IRPT_EN_CH4_I () ,
    .IRPT_EN_CH5_I () ,
    .IRPT_EN_CH6_I () ,
    .IRPT_EN_CH7_I () ,
    
    .IRPT_O           ()

    );
*/

module io_irpt_sts
(
input  CLK_I  ,
input  RSTN_I , 

input  RD_I,
input  [15:0] RD_ADDR_I ,

input  [C_GPI_WIDTH-1:0] GPI_CH0_I , //内部打拍消除不稳态
input  [C_GPI_WIDTH-1:0] GPI_CH1_I ,
input  [C_GPI_WIDTH-1:0] GPI_CH2_I ,
input  [C_GPI_WIDTH-1:0] GPI_CH3_I ,
input  [C_GPI_WIDTH-1:0] GPI_CH4_I ,
input  [C_GPI_WIDTH-1:0] GPI_CH5_I ,
input  [C_GPI_WIDTH-1:0] GPI_CH6_I ,
input  [C_GPI_WIDTH-1:0] GPI_CH7_I ,

output [C_GPI_WIDTH-1:0] GPI_CH0_DBS_O , //消抖
output [C_GPI_WIDTH-1:0] GPI_CH1_DBS_O ,
output [C_GPI_WIDTH-1:0] GPI_CH2_DBS_O ,
output [C_GPI_WIDTH-1:0] GPI_CH3_DBS_O ,
output [C_GPI_WIDTH-1:0] GPI_CH4_DBS_O ,
output [C_GPI_WIDTH-1:0] GPI_CH5_DBS_O ,
output [C_GPI_WIDTH-1:0] GPI_CH6_DBS_O ,
output [C_GPI_WIDTH-1:0] GPI_CH7_DBS_O ,


output  [31:0] GPI_INT_STS_CH0_O , // {低脉冲中断事件,高脉冲中断事件,低电平中断事件,高电平中断事件}
output  [31:0] GPI_INT_STS_CH1_O , // {0xXXXXXXXX,0xXXXXXXXX,0xXXXXXXXX,0xXXXXXXXX,}
output  [31:0] GPI_INT_STS_CH2_O ,
output  [31:0] GPI_INT_STS_CH3_O ,
output  [31:0] GPI_INT_STS_CH4_O ,
output  [31:0] GPI_INT_STS_CH5_O ,
output  [31:0] GPI_INT_STS_CH6_O ,
output  [31:0] GPI_INT_STS_CH7_O ,

input  [C_GPI_WIDTH-1:0] IRPT_MODE_CH0_I , //0: IRPT_O 只输出电平中断   1: IRPT_O 只输出脉冲中断
input  [C_GPI_WIDTH-1:0] IRPT_MODE_CH1_I ,
input  [C_GPI_WIDTH-1:0] IRPT_MODE_CH2_I ,
input  [C_GPI_WIDTH-1:0] IRPT_MODE_CH3_I ,
input  [C_GPI_WIDTH-1:0] IRPT_MODE_CH4_I ,
input  [C_GPI_WIDTH-1:0] IRPT_MODE_CH5_I ,
input  [C_GPI_WIDTH-1:0] IRPT_MODE_CH6_I ,
input  [C_GPI_WIDTH-1:0] IRPT_MODE_CH7_I ,

input  [C_GPI_WIDTH-1:0] IRPT_EN_CH0_I , //0: IRPT_O 只输出电平中断   1: IRPT_O 只输出脉冲中断
input  [C_GPI_WIDTH-1:0] IRPT_EN_CH1_I ,
input  [C_GPI_WIDTH-1:0] IRPT_EN_CH2_I ,
input  [C_GPI_WIDTH-1:0] IRPT_EN_CH3_I ,
input  [C_GPI_WIDTH-1:0] IRPT_EN_CH4_I ,
input  [C_GPI_WIDTH-1:0] IRPT_EN_CH5_I ,
input  [C_GPI_WIDTH-1:0] IRPT_EN_CH6_I ,
input  [C_GPI_WIDTH-1:0] IRPT_EN_CH7_I ,



output  IRPT_O  // __|——|_____



);

parameter C_CH_NUM    = 8 ;
parameter C_GPI_WIDTH = 8;

parameter C_IRPT_PRD_NUM = 500;
parameter C_PRD_CLK_NS = 10;
parameter C_PULSE_DET_THRESHOLD_MS = 100 ;//10000000 - 100ms
parameter C_PULSE_DET_THRESHOLD_L_MS = 500;
parameter C_CNT_BW = 30 ;

parameter C_GPI_DEBOUNCE_HIGH_THRESHOLD_US  = 400 ;
parameter C_GPI_DEBOUNCE_LOW_THRESHOLD_US   = 400 ;
parameter C_GPI_DEBOUNCE_RST_VALUE          = 0 ;


localparam C_PULSE_DET_THRESHOLD_PRD_NUM = C_PULSE_DET_THRESHOLD_MS*1000000/C_PRD_CLK_NS;
localparam C_PULSE_DET_THRESHOLD_L_PRD_NUM = C_PULSE_DET_THRESHOLD_L_MS*1000000/C_PRD_CLK_NS;
          //检测到变化--等待这么多时间后，若还是一样的值，则发出电平中断


genvar i,j,k ;



wire [C_CH_NUM-1:0] rd ;
reg [C_GPI_WIDTH-1:0] sts_h_level  [C_CH_NUM-1:0] ;
reg [C_GPI_WIDTH-1:0] sts_l_level  [C_CH_NUM-1:0] ;
reg [C_GPI_WIDTH-1:0] sts_h_pulse  [C_CH_NUM-1:0] ;
reg [C_GPI_WIDTH-1:0] sts_l_pulse  [C_CH_NUM-1:0] ;
reg [31:0] cnt = 0;  
reg count_start;  
reg [C_GPI_WIDTH-1:0] irpt_l [C_CH_NUM-1:0] ;
reg [C_GPI_WIDTH-1:0] irpt_h [C_CH_NUM-1:0] ;
  
wire [C_GPI_WIDTH-1:0]  irpt_mode [C_CH_NUM-1:0] ;
wire [C_GPI_WIDTH-1:0]  irpt_en   [C_CH_NUM-1:0] ;
wire  IRPT_w_one_pulse ;
wire [C_GPI_WIDTH-1:0] GPI_CH_I [C_CH_NUM-1:0];
wire [C_GPI_WIDTH-1:0] GPI_CH_I_ff  [C_CH_NUM-1:0];
wire [C_GPI_WIDTH-1:0] GPI_CH_I_ff_dbs [C_CH_NUM-1:0];


assign  GPI_CH_I[0] = GPI_CH0_I ;
assign  GPI_CH_I[1] = GPI_CH1_I ;
assign  GPI_CH_I[2] = GPI_CH2_I ;
assign  GPI_CH_I[3] = GPI_CH3_I ;
assign  GPI_CH_I[4] = GPI_CH4_I ;
assign  GPI_CH_I[5] = GPI_CH5_I ;
assign  GPI_CH_I[6] = GPI_CH6_I ;
assign  GPI_CH_I[7] = GPI_CH7_I ;


wire [C_GPI_WIDTH-1:0] sig [C_CH_NUM-1:0] ;


`DELAY_OUTGEN(CLK_I,0,GPI_CH_I[0],GPI_CH_I_ff[0],C_GPI_WIDTH,2)
`DELAY_OUTGEN(CLK_I,0,GPI_CH_I[1],GPI_CH_I_ff[1],C_GPI_WIDTH,2)
`DELAY_OUTGEN(CLK_I,0,GPI_CH_I[2],GPI_CH_I_ff[2],C_GPI_WIDTH,2)
`DELAY_OUTGEN(CLK_I,0,GPI_CH_I[3],GPI_CH_I_ff[3],C_GPI_WIDTH,2)
`DELAY_OUTGEN(CLK_I,0,GPI_CH_I[4],GPI_CH_I_ff[4],C_GPI_WIDTH,2)
`DELAY_OUTGEN(CLK_I,0,GPI_CH_I[5],GPI_CH_I_ff[5],C_GPI_WIDTH,2)
`DELAY_OUTGEN(CLK_I,0,GPI_CH_I[6],GPI_CH_I_ff[6],C_GPI_WIDTH,2)
`DELAY_OUTGEN(CLK_I,0,GPI_CH_I[7],GPI_CH_I_ff[7],C_GPI_WIDTH,2)



generate for(i=0;i<C_CH_NUM;i=i+1)begin
    for(j=0;j<C_GPI_WIDTH;j=j+1)begin
        key_debounce   
            #(.C_CLK_PRD_NS            (C_PRD_CLK_NS                      ),
            .C_LOW_LEVEL_THRESHOLD_US  (C_GPI_DEBOUNCE_LOW_THRESHOLD_US   ),
            .C_HIGH_LEVEL_THRESHOLD_US (C_GPI_DEBOUNCE_HIGH_THRESHOLD_US  ),
            .C_RST_KEY_OUT_VALUE       (C_GPI_DEBOUNCE_RST_VALUE          )  )
            key_debounce_u(
                .CLK_I  (CLK_I    ),
                .RSTN_I (RSTN_I   ),
                .EN_I   ( 1       ),
                .KEY_I  (GPI_CH_I_ff[i][j]      ),
                .KEY_O  (GPI_CH_I_ff_dbs[i][j]  )
            );
            
        assign sig[i][j] = GPI_CH_I_ff_dbs[i][j] ;  
            
    end
end
endgenerate


assign  GPI_CH0_DBS_O =  GPI_CH_I_ff_dbs[0]; //消抖
assign  GPI_CH1_DBS_O =  GPI_CH_I_ff_dbs[1];  
assign  GPI_CH2_DBS_O =  GPI_CH_I_ff_dbs[2];  
assign  GPI_CH3_DBS_O =  GPI_CH_I_ff_dbs[3];  
assign  GPI_CH4_DBS_O =  GPI_CH_I_ff_dbs[4];  
assign  GPI_CH5_DBS_O =  GPI_CH_I_ff_dbs[5];  
assign  GPI_CH6_DBS_O =  GPI_CH_I_ff_dbs[6];  
assign  GPI_CH7_DBS_O =  GPI_CH_I_ff_dbs[7];  





assign  IRPT_w_one_pulse =    (|irpt_l[0]) | (|irpt_l[1]) | (|irpt_l[2]) | (|irpt_l[3]) | (|irpt_l[4]) | (|irpt_l[5]) | (|irpt_l[6]) | (|irpt_l[7])  |
                              (|irpt_h[0]) | (|irpt_h[1]) | (|irpt_h[2]) | (|irpt_h[3]) | (|irpt_h[4]) | (|irpt_h[5]) | (|irpt_h[6]) | (|irpt_h[7])   ;


      
always@(posedge CLK_I)begin
    if(~RSTN_I)begin
        cnt <= 0;
        count_start <= 0;
    end
    else begin  
        count_start <= IRPT_w_one_pulse ? 1 : (cnt==C_IRPT_PRD_NUM) ? 0 :  count_start  ;
        cnt <= IRPT_w_one_pulse ? 0 :  (  cnt==C_IRPT_PRD_NUM ? C_IRPT_PRD_NUM  : count_start ? (cnt + 1 ) : cnt  ) ;
    end
end   

              
assign IRPT_O  = count_start ;//(cnt>0) & (cnt<C_IRPT_PRD_NUM) ;



assign  irpt_mode[0][0] = IRPT_MODE_CH0_I[0] ;
assign  irpt_mode[0][1] = IRPT_MODE_CH0_I[1] ;
assign  irpt_mode[0][2] = IRPT_MODE_CH0_I[2] ;
assign  irpt_mode[0][3] = IRPT_MODE_CH0_I[3] ;
assign  irpt_mode[0][4] = IRPT_MODE_CH0_I[4] ;
assign  irpt_mode[0][5] = IRPT_MODE_CH0_I[5] ;
assign  irpt_mode[0][6] = IRPT_MODE_CH0_I[6] ;
assign  irpt_mode[0][7] = IRPT_MODE_CH0_I[7] ;

assign  irpt_mode[1][0] = IRPT_MODE_CH1_I[0] ;
assign  irpt_mode[1][1] = IRPT_MODE_CH1_I[1] ;
assign  irpt_mode[1][2] = IRPT_MODE_CH1_I[2] ;
assign  irpt_mode[1][3] = IRPT_MODE_CH1_I[3] ;
assign  irpt_mode[1][4] = IRPT_MODE_CH1_I[4] ;
assign  irpt_mode[1][5] = IRPT_MODE_CH1_I[5] ;
assign  irpt_mode[1][6] = IRPT_MODE_CH1_I[6] ;
assign  irpt_mode[1][7] = IRPT_MODE_CH1_I[7] ;

assign  irpt_mode[2][0] = IRPT_MODE_CH2_I[0] ;
assign  irpt_mode[2][1] = IRPT_MODE_CH2_I[1] ;
assign  irpt_mode[2][2] = IRPT_MODE_CH2_I[2] ;
assign  irpt_mode[2][3] = IRPT_MODE_CH2_I[3] ;
assign  irpt_mode[2][4] = IRPT_MODE_CH2_I[4] ;
assign  irpt_mode[2][5] = IRPT_MODE_CH2_I[5] ;
assign  irpt_mode[2][6] = IRPT_MODE_CH2_I[6] ;
assign  irpt_mode[2][7] = IRPT_MODE_CH2_I[7] ;

assign  irpt_mode[3][0] = IRPT_MODE_CH3_I[0] ;
assign  irpt_mode[3][1] = IRPT_MODE_CH3_I[1] ;
assign  irpt_mode[3][2] = IRPT_MODE_CH3_I[2] ;
assign  irpt_mode[3][3] = IRPT_MODE_CH3_I[3] ;
assign  irpt_mode[3][4] = IRPT_MODE_CH3_I[4] ;
assign  irpt_mode[3][5] = IRPT_MODE_CH3_I[5] ;
assign  irpt_mode[3][6] = IRPT_MODE_CH3_I[6] ;
assign  irpt_mode[3][7] = IRPT_MODE_CH3_I[7] ;


assign  irpt_mode[4][0] = IRPT_MODE_CH4_I[0] ;
assign  irpt_mode[4][1] = IRPT_MODE_CH4_I[1] ;
assign  irpt_mode[4][2] = IRPT_MODE_CH4_I[2] ;
assign  irpt_mode[4][3] = IRPT_MODE_CH4_I[3] ;
assign  irpt_mode[4][4] = IRPT_MODE_CH4_I[4] ;
assign  irpt_mode[4][5] = IRPT_MODE_CH4_I[5] ;
assign  irpt_mode[4][6] = IRPT_MODE_CH4_I[6] ;
assign  irpt_mode[4][7] = IRPT_MODE_CH4_I[7] ;


assign  irpt_mode[5][0] = IRPT_MODE_CH5_I[0] ;
assign  irpt_mode[5][1] = IRPT_MODE_CH5_I[1] ;
assign  irpt_mode[5][2] = IRPT_MODE_CH5_I[2] ;
assign  irpt_mode[5][3] = IRPT_MODE_CH5_I[3] ;
assign  irpt_mode[5][4] = IRPT_MODE_CH5_I[4] ;
assign  irpt_mode[5][5] = IRPT_MODE_CH5_I[5] ;
assign  irpt_mode[5][6] = IRPT_MODE_CH5_I[6] ;
assign  irpt_mode[5][7] = IRPT_MODE_CH5_I[7] ;

assign  irpt_mode[6][0] = IRPT_MODE_CH6_I[0] ;
assign  irpt_mode[6][1] = IRPT_MODE_CH6_I[1] ;
assign  irpt_mode[6][2] = IRPT_MODE_CH6_I[2] ;
assign  irpt_mode[6][3] = IRPT_MODE_CH6_I[3] ;
assign  irpt_mode[6][4] = IRPT_MODE_CH6_I[4] ;
assign  irpt_mode[6][5] = IRPT_MODE_CH6_I[5] ;
assign  irpt_mode[6][6] = IRPT_MODE_CH6_I[6] ;
assign  irpt_mode[6][7] = IRPT_MODE_CH6_I[7] ;

assign  irpt_mode[7][0] = IRPT_MODE_CH7_I[0] ;
assign  irpt_mode[7][1] = IRPT_MODE_CH7_I[1] ;
assign  irpt_mode[7][2] = IRPT_MODE_CH7_I[2] ;
assign  irpt_mode[7][3] = IRPT_MODE_CH7_I[3] ;
assign  irpt_mode[7][4] = IRPT_MODE_CH7_I[4] ;
assign  irpt_mode[7][5] = IRPT_MODE_CH7_I[5] ;
assign  irpt_mode[7][6] = IRPT_MODE_CH7_I[6] ;
assign  irpt_mode[7][7] = IRPT_MODE_CH7_I[7] ;



//irpt_en 
assign  irpt_en[0][0] = IRPT_EN_CH0_I[0] ;
assign  irpt_en[0][1] = IRPT_EN_CH0_I[1] ;
assign  irpt_en[0][2] = IRPT_EN_CH0_I[2] ;
assign  irpt_en[0][3] = IRPT_EN_CH0_I[3] ;
assign  irpt_en[0][4] = IRPT_EN_CH0_I[4] ;
assign  irpt_en[0][5] = IRPT_EN_CH0_I[5] ;
assign  irpt_en[0][6] = IRPT_EN_CH0_I[6] ;
assign  irpt_en[0][7] = IRPT_EN_CH0_I[7] ;

assign  irpt_en[1][0] = IRPT_EN_CH1_I[0] ;
assign  irpt_en[1][1] = IRPT_EN_CH1_I[1] ;
assign  irpt_en[1][2] = IRPT_EN_CH1_I[2] ;
assign  irpt_en[1][3] = IRPT_EN_CH1_I[3] ;
assign  irpt_en[1][4] = IRPT_EN_CH1_I[4] ;
assign  irpt_en[1][5] = IRPT_EN_CH1_I[5] ;
assign  irpt_en[1][6] = IRPT_EN_CH1_I[6] ;
assign  irpt_en[1][7] = IRPT_EN_CH1_I[7] ;

assign  irpt_en[2][0] = IRPT_EN_CH2_I[0] ;
assign  irpt_en[2][1] = IRPT_EN_CH2_I[1] ;
assign  irpt_en[2][2] = IRPT_EN_CH2_I[2] ;
assign  irpt_en[2][3] = IRPT_EN_CH2_I[3] ;
assign  irpt_en[2][4] = IRPT_EN_CH2_I[4] ;
assign  irpt_en[2][5] = IRPT_EN_CH2_I[5] ;
assign  irpt_en[2][6] = IRPT_EN_CH2_I[6] ;
assign  irpt_en[2][7] = IRPT_EN_CH2_I[7] ;

assign  irpt_en[3][0] = IRPT_EN_CH3_I[0] ;
assign  irpt_en[3][1] = IRPT_EN_CH3_I[1] ;
assign  irpt_en[3][2] = IRPT_EN_CH3_I[2] ;
assign  irpt_en[3][3] = IRPT_EN_CH3_I[3] ;
assign  irpt_en[3][4] = IRPT_EN_CH3_I[4] ;
assign  irpt_en[3][5] = IRPT_EN_CH3_I[5] ;
assign  irpt_en[3][6] = IRPT_EN_CH3_I[6] ;
assign  irpt_en[3][7] = IRPT_EN_CH3_I[7] ;


assign  irpt_en[4][0] = IRPT_EN_CH4_I[0] ;
assign  irpt_en[4][1] = IRPT_EN_CH4_I[1] ;
assign  irpt_en[4][2] = IRPT_EN_CH4_I[2] ;
assign  irpt_en[4][3] = IRPT_EN_CH4_I[3] ;
assign  irpt_en[4][4] = IRPT_EN_CH4_I[4] ;
assign  irpt_en[4][5] = IRPT_EN_CH4_I[5] ;
assign  irpt_en[4][6] = IRPT_EN_CH4_I[6] ;
assign  irpt_en[4][7] = IRPT_EN_CH4_I[7] ;


assign  irpt_en[5][0] = IRPT_EN_CH5_I[0] ;
assign  irpt_en[5][1] = IRPT_EN_CH5_I[1] ;
assign  irpt_en[5][2] = IRPT_EN_CH5_I[2] ;
assign  irpt_en[5][3] = IRPT_EN_CH5_I[3] ;
assign  irpt_en[5][4] = IRPT_EN_CH5_I[4] ;
assign  irpt_en[5][5] = IRPT_EN_CH5_I[5] ;
assign  irpt_en[5][6] = IRPT_EN_CH5_I[6] ;
assign  irpt_en[5][7] = IRPT_EN_CH5_I[7] ;

assign  irpt_en[6][0] = IRPT_EN_CH6_I[0] ;
assign  irpt_en[6][1] = IRPT_EN_CH6_I[1] ;
assign  irpt_en[6][2] = IRPT_EN_CH6_I[2] ;
assign  irpt_en[6][3] = IRPT_EN_CH6_I[3] ;
assign  irpt_en[6][4] = IRPT_EN_CH6_I[4] ;
assign  irpt_en[6][5] = IRPT_EN_CH6_I[5] ;
assign  irpt_en[6][6] = IRPT_EN_CH6_I[6] ;
assign  irpt_en[6][7] = IRPT_EN_CH6_I[7] ;

assign  irpt_en[7][0] = IRPT_EN_CH7_I[0] ;
assign  irpt_en[7][1] = IRPT_EN_CH7_I[1] ;
assign  irpt_en[7][2] = IRPT_EN_CH7_I[2] ;
assign  irpt_en[7][3] = IRPT_EN_CH7_I[3] ;
assign  irpt_en[7][4] = IRPT_EN_CH7_I[4] ;
assign  irpt_en[7][5] = IRPT_EN_CH7_I[5] ;
assign  irpt_en[7][6] = IRPT_EN_CH7_I[6] ;
assign  irpt_en[7][7] = IRPT_EN_CH7_I[7] ;




assign GPI_INT_STS_CH0_O = {  sts_l_level[0],sts_h_level[0]  ,  sts_l_pulse[0],sts_h_pulse[0]} ;
assign GPI_INT_STS_CH1_O = {  sts_l_level[1],sts_h_level[1]  ,  sts_l_pulse[1],sts_h_pulse[1]} ;
assign GPI_INT_STS_CH2_O = {  sts_l_level[2],sts_h_level[2]  ,  sts_l_pulse[2],sts_h_pulse[2]} ;
assign GPI_INT_STS_CH3_O = {  sts_l_level[3],sts_h_level[3]  ,  sts_l_pulse[3],sts_h_pulse[3]} ;
assign GPI_INT_STS_CH4_O = {  sts_l_level[4],sts_h_level[4]  ,  sts_l_pulse[4],sts_h_pulse[4]} ;
assign GPI_INT_STS_CH5_O = {  sts_l_level[5],sts_h_level[5]  ,  sts_l_pulse[5],sts_h_pulse[5]} ;
assign GPI_INT_STS_CH6_O = {  sts_l_level[6],sts_h_level[6]  ,  sts_l_pulse[6],sts_h_pulse[6]} ;
assign GPI_INT_STS_CH7_O = {  sts_l_level[7],sts_h_level[7]  ,  sts_l_pulse[7],sts_h_pulse[7]} ;




assign  rd[0] = RD_I & (RD_ADDR_I==`ADDR_GPI_IRPT_STS_0) ;
assign  rd[1] = RD_I & (RD_ADDR_I==`ADDR_GPI_IRPT_STS_1) ;
assign  rd[2] = RD_I & (RD_ADDR_I==`ADDR_GPI_IRPT_STS_2) ;
assign  rd[3] = RD_I & (RD_ADDR_I==`ADDR_GPI_IRPT_STS_3) ;
assign  rd[4] = RD_I & (RD_ADDR_I==`ADDR_GPI_IRPT_STS_4) ;
assign  rd[5] = RD_I & (RD_ADDR_I==`ADDR_GPI_IRPT_STS_5) ;
assign  rd[6] = RD_I & (RD_ADDR_I==`ADDR_GPI_IRPT_STS_6) ;
assign  rd[7] = RD_I & (RD_ADDR_I==`ADDR_GPI_IRPT_STS_7) ;



generate for(i=0;i<C_CH_NUM;i=i+1)begin:blk_i
    for(j=0;j<C_GPI_WIDTH;j=j+1)begin:blk_j

        reg  sig_ff;
        wire sig_pos;
 
        always@(posedge CLK_I)begin
            sig_ff <= sig[i][j] ;    
        end
        assign sig_pos = sig[i][j]  & ~sig_ff ;
        assign sig_neg = ~sig[i][j]  & sig_ff ;
         

        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
       
        reg [1:0] state_h = 0;
        reg [C_CNT_BW-1:0] cnt_irpt_h  = 0;
        always@(posedge CLK_I)begin
            if(~RSTN_I)begin
                state_h <= 0;
                cnt_irpt_h <= 0; 
                irpt_h[i][j] <= 0 ;
            end
            else begin
                case(state_h)
                    0 : begin
                        cnt_irpt_h <= 0 ;
                        irpt_h[i][j]  <= 0 ;
                        state_h  <= sig_pos ? 1 : state_h ;
                    end
                    1 : begin 
                        state_h    <=   (cnt_irpt_h == C_PULSE_DET_THRESHOLD_PRD_NUM) | (sig[i][j]==0)  ? 2 :    state_h    ;
                        //cnt_irpt_h <=   (cnt_irpt_h == C_PULSE_DET_THRESHOLD_PRD_NUM)  ?  cnt_irpt_h : cnt_irpt_h + 1 ;
                        cnt_irpt_h <=   cnt_irpt_h + 1 ;
                    end
                    2: begin 
                        if(irpt_en[i][j]==0)begin
                            irpt_h[i][j] <= 0 ;
                        end
                        else if( ((cnt_irpt_h == C_PULSE_DET_THRESHOLD_PRD_NUM+1)  &  (irpt_mode[i][j]==0) )  |  //电平中断  
                            ((cnt_irpt_h != C_PULSE_DET_THRESHOLD_PRD_NUM+1)  &  (irpt_mode[i][j]==1) )     //脉冲中断
                           ) begin
                            irpt_h[i][j] <= 1 ; 
                        end
                        state_h   <= 0 ;
                    end
                    default:;
                endcase
            end
        end
        
        
        always@(posedge CLK_I)begin
            if(~RSTN_I)begin
                sts_h_level[i][j]  <= 0;//电平状态
                sts_h_pulse[i][j]  <= 0;//脉冲状态
            end
            else begin
                sts_h_level[i][j]  <= rd[i] ? 0 :    ( state_h==2 & irpt_en[i][j] & ((cnt_irpt_h == C_PULSE_DET_THRESHOLD_PRD_NUM+1)  &  (irpt_mode[i][j]==0) ) )     ?     1     :     sts_h_level[i][j]     ;
                sts_h_pulse[i][j]  <= rd[i] ? 0 :    ( state_h==2 & irpt_en[i][j] & ((cnt_irpt_h != C_PULSE_DET_THRESHOLD_PRD_NUM+1)  &  (irpt_mode[i][j]==1) ) )     ?     1     :     sts_h_pulse[i][j]     ;
            end 
        end
        
        
      
        
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        reg [1:0] state_l = 0;
        reg [C_CNT_BW-1:0] cnt_irpt_l = 0;
        always@(posedge CLK_I)begin
            if(~RSTN_I)begin
                state_l <= 0;
                cnt_irpt_l <= 0; 
                irpt_l[i][j] <= 0 ;
            end
            else begin
                case(state_l)
                    0 : begin
                        cnt_irpt_l <= 0 ;
                        irpt_l[i][j]  <= 0 ;
                        state_l  <= sig_neg ? 1 : state_l ;
                    end
                    1 : begin 
                        state_l    <=   (cnt_irpt_l == C_PULSE_DET_THRESHOLD_L_PRD_NUM) | (sig[i][j]==1)  ? 2 :   state_l    ;
                        //cnt_irpt_l <=   (cnt_irpt_l == C_PULSE_DET_THRESHOLD_L_PRD_NUM)  ?  cnt_irpt_l : cnt_irpt_l + 1 ;
                        cnt_irpt_l <=   cnt_irpt_l + 1 ;
                    end
                    2: begin 
                        if(irpt_en[i][j]==0)begin
                            irpt_l[i][j] <= 0 ;
                        end
                        else if( ((cnt_irpt_l == C_PULSE_DET_THRESHOLD_L_PRD_NUM+1)  &  (irpt_mode[i][j]==0) )  |  //电平中断  
                            ((cnt_irpt_l != C_PULSE_DET_THRESHOLD_L_PRD_NUM+1)  &  (irpt_mode[i][j]==1) )     //脉冲中断
                           ) begin
                            irpt_l[i][j] <= 1 ; 
                        end
                        state_l   <= 0 ;
                    end
                    default:;
                endcase
            end
        end
        
        
        always@(posedge CLK_I)begin
            if(~RSTN_I)begin
                sts_l_level[i][j]  <= 0;//电平状态
                sts_l_pulse[i][j]  <= 0;//脉冲状态
            end
            else begin
                sts_l_level[i][j]  <= rd[i] ? 0 :    ( state_l==2 & irpt_en[i][j] & ((cnt_irpt_l == C_PULSE_DET_THRESHOLD_L_PRD_NUM+1)  &  (irpt_mode[i][j]==0) ) )     ?     1     :     sts_l_level[i][j]     ;
                sts_l_pulse[i][j]  <= rd[i] ? 0 :    ( state_l==2 & irpt_en[i][j] & ((cnt_irpt_l != C_PULSE_DET_THRESHOLD_L_PRD_NUM+1)  &  (irpt_mode[i][j]==1) ) )     ?     1     :     sts_l_pulse[i][j]     ;
            end 
        end
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
    end  //for
end //for 


endgenerate 
          



endmodule



