`timescale 1ns / 1ps
`define DELAY_OUTGEN(clk,rst,data_in,data_out,DATA_WIDTH,DLY)                generate if(DLY==0)begin  assign data_out = data_in; end  else if(DLY==1)begin  reg [DATA_WIDTH-1:0] a_temp = 0; always@(posedge clk) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [DATA_WIDTH-1:0] a_temp [DLY-1:0] ;always@(posedge clk) begin  if(rst)a_temp[DLY-1] <= 0; else   a_temp[DLY-1] <= data_in; end  for(i=0;i<=DLY-2;i=i+1)begin  always@(posedge clk)begin  if(rst)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  endgenerate

`define MACRO_80  80
`define MACRO_31  31
`define MACRO_32  32
`define MACRO_16  16

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
//////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------------------------------------
// POLY_LENGHT POLY_TAP INV_PATTERN  || nbr of   bit seq.   max 0      feedback
//                                   || stages    length  sequence      stages
//     7          6       false      ||    7         127      6 ni        6, 7   (*)
//     9          5       false      ||    9         511      8 ni        5, 9
//    11          9       false      ||   11        2047     10 ni        9,11
//    15         14       true       ||   15       32767     15 i        14,15
//    20          3       false      ||   20     1048575     19 ni        3,20
//    23         18       true       ||   23     8388607     23 i        18,23
//    29         27       true       ||   29   536870911     29 i        27,29
//    31         28       true       ||   31  2147483647     31 i        28,31


//valid  pattern mode：
//0b0000   0   usr defined pattern (also can be check)
//0b0001   1   PRBS_7  
//0b0010   2   PRBS_9
//0b0011   3   PRBS_15
//0b0100   4   PRBS_23
//0b0101   5   PRBS_31
//0b1001   9   PATTERN_2UI    (2UI per wave clk period)     10101010101101010....
//0b1010   10  PATTERN_16UI  (16UI per wave clk period)     11111111000000001111111100000000.....

// note : the structure of this module is  fixed to 32 * 80 , so there always has valid default config 
//resource : maximun 600 ; will decrease when colse some EN config

module prbs_en
(
input                         CLK_I          , 
input                         RST_I          ,
input  [31:0]                 USR_PATTERN_I  ,
input  [`MACRO_80-1:0]        DATA_I         ,
output [`MACRO_80-1:0]        DATA_O  ,
input  [3:0]                  PATTERN_I    , //0 1 2 3 4 5 9 10(when give wrong config - taking  EN para into account , will run in prbs7 default) 
input  [7:0]                 DATA_WIDTH_I   // 16 20 32 64 80 (when give wrong config - taking  EN para into account , will run in 16 default)


); 
parameter  C_CHK_MODE         = 0 ;// 0: gen mode  1: check mode
parameter  C_INPUT_FF_NUM     = 0 ;// >=0 
parameter  C_OUTPUT_FF_NUM    = 0 ;// >=0 


//////////////////////////////////////////////////////////////////////////////
//config output data_width  ---  vertical
parameter  [0:0] C_DATA_WIDTH_16_EN = 1; 
parameter  [0:0] C_DATA_WIDTH_20_EN = 1;
parameter  [0:0] C_DATA_WIDTH_32_EN = 1;
parameter  [0:0] C_DATA_WIDTH_64_EN = 1;
parameter  [0:0] C_DATA_WIDTH_80_EN = 1; //

//config pattern   ---  horizontal
parameter  [0:0] C_PATTERN_0_EN =  1;
parameter  [0:0] C_PATTERN_1_EN =  1;
parameter  [0:0] C_PATTERN_2_EN =  1;
parameter  [0:0] C_PATTERN_3_EN =  1;
parameter  [0:0] C_PATTERN_4_EN =  1;
parameter  [0:0] C_PATTERN_5_EN =  1;
parameter  [0:0] C_PATTERN_9_EN =  1;
parameter  [0:0] C_PATTERN_10_EN = 1;


//////////////////////////////////////////////////////////////////////////////
genvar i,j,k;


(*keep="true"*)wire  [`MACRO_80-1:0] DATA_I_d ;
reg  [`MACRO_80-1:0] DATA_O_b = {(`MACRO_80){1'b1}};

`DELAY_OUTGEN(CLK_I,0,DATA_I,DATA_I_d,`MACRO_80,C_INPUT_FF_NUM)
`DELAY_OUTGEN(CLK_I,0,DATA_O_b,DATA_O,`MACRO_80,C_OUTPUT_FF_NUM)



// for sim , check input para 
wire [3:0] valid_pattern_for_sim;
wire [7:0] valid_data_width_for_sim;

assign valid_pattern_for_sim = ( C_PATTERN_0_EN &&  PATTERN_I==0 ) ? 0 : 
                               ( C_PATTERN_1_EN &&  PATTERN_I==1 ) ? 1 : 
                               ( C_PATTERN_2_EN &&  PATTERN_I==2 ) ? 2 :
                               ( C_PATTERN_3_EN &&  PATTERN_I==3 ) ? 3 :
                               ( C_PATTERN_4_EN &&  PATTERN_I==4 ) ? 4 :
                               ( C_PATTERN_5_EN &&  PATTERN_I==5 ) ? 5 :
                               ( C_PATTERN_9_EN &&  PATTERN_I==9 ) ? 9 :
                               ( C_PATTERN_10_EN && PATTERN_I==10 ) ? 10 : 1 ; 

assign valid_data_width_for_sim =  ( C_DATA_WIDTH_16_EN && DATA_WIDTH_I==16) ? 16 : 
                                   ( C_DATA_WIDTH_20_EN && DATA_WIDTH_I==20) ? 20 : 
                                   ( C_DATA_WIDTH_32_EN && DATA_WIDTH_I==32) ? 32 : 
                                   ( C_DATA_WIDTH_64_EN && DATA_WIDTH_I==64) ? 64 : 
                                   ( C_DATA_WIDTH_80_EN && DATA_WIDTH_I==80) ? 80 : `MACRO_16 ; //配置都错误时，默认选择最大位宽作为输出位宽

// prbs_poly from  0  ~  `MACRO_80  ->>  poly_0

wire [1:`MACRO_32] prbs_poly   [`MACRO_80:0];  //不是从N-1开始
reg  [1:`MACRO_32] prbs_reg = {(`MACRO_32){1'b1}};
wire [`MACRO_80 - 1:0] prbs_xor_b;
wire [`MACRO_80 :   1] prbs_msb;
reg [3:0] PATTERN_I_reg = 0;
wire pattern_rst;

// situation of 01010101....
//        10101 inv
//        01010
//        10101
//        ......


// situation of 0000000000000000111111111111111100000000000000001111111111111111
//        000000000000000011111111111111110000000000000000  inv
//        100000000000000001111111111111111000000000000000
//        110000000000000000111111111111111100000000000000
//        111000000000000000011111111111111110000000000000
//        111100000000000000001111111111111111000000000000
//        111110000000000000000111111111111111100000000000
//        111111000000000000000011111111111111110000000000
//        111111100000000000000001111111111111111000000000
//        111111110000000000000000111111111111111100000000
//        111111111000000000000000011111111111111110000000
//        ......



wire [`MACRO_80 - 1:0] prbs_xor_a;
wire [`MACRO_80 - 1:0] prbs_usr_pat_shift;
wire [`MACRO_80 - 1:0] prbs_xor_a_prbs7;
wire [`MACRO_80 - 1:0] prbs_xor_a_prbs9;
wire [`MACRO_80 - 1:0] prbs_xor_a_prbs15;
wire [`MACRO_80 - 1:0] prbs_xor_a_prbs23;
wire [`MACRO_80 - 1:0] prbs_xor_a_prbs31;
wire [`MACRO_80 - 1:0] prbs_xor_a_2ui_inv;//
wire [`MACRO_80 - 1:0] prbs_xor_a_16ui_inv;// 8位的奇数倍




//linear feedback 
generate for(i=0; i<`MACRO_80; i=i+1) begin :g1
    assign prbs_xor_a_prbs7[i]    = prbs_poly[i][6] ^ prbs_poly[i][7];
    assign prbs_xor_a_prbs9[i]    = prbs_poly[i][5] ^ prbs_poly[i][9]; 
    assign prbs_xor_a_prbs15[i]   = prbs_poly[i][14] ^ prbs_poly[i][15]; 
    assign prbs_xor_a_prbs23[i]   = prbs_poly[i][18] ^ prbs_poly[i][23]; 
    assign prbs_xor_a_prbs31[i]   = prbs_poly[i][28] ^ prbs_poly[i][31];  
    assign prbs_xor_a_2ui_inv[i]  =                ~ prbs_poly[i][31];  
    assign prbs_xor_a_16ui_inv[i] =                ~ prbs_poly[i][24];    
    assign prbs_usr_pat_shift[i]    =  prbs_poly[i][32];
    
  end
endgenerate



//combinational circuit
generate for (i=0; i<`MACRO_80; i=i+1) begin :g2
   assign prbs_xor_a[i] =   (PATTERN_I==0 && C_PATTERN_0_EN ) ?  prbs_usr_pat_shift[i]  : 
                            (PATTERN_I==1 && C_PATTERN_1_EN ) ?  prbs_xor_a_prbs7[i]  :
                            (PATTERN_I==2 && C_PATTERN_2_EN ) ?  prbs_xor_a_prbs9[i]  :
                            (PATTERN_I==3 && C_PATTERN_3_EN ) ?  prbs_xor_a_prbs15[i] :
                            (PATTERN_I==4 && C_PATTERN_4_EN ) ?  prbs_xor_a_prbs23[i] :
                            (PATTERN_I==5 && C_PATTERN_5_EN ) ?  prbs_xor_a_prbs31[i] : 
                            (PATTERN_I==9 && C_PATTERN_9_EN ) ?  prbs_xor_a_2ui_inv[i] :  
                            (PATTERN_I==10 && C_PATTERN_10_EN )?  prbs_xor_a_16ui_inv[i] : prbs_xor_a_prbs7[i] ; //default : prbs7
   
   assign prbs_xor_b[i] = prbs_xor_a[i] ^ ( C_CHK_MODE ? DATA_I_d[i] : 0 );
   assign prbs_msb[i+1] = C_CHK_MODE == 0 ? prbs_xor_a[i] : DATA_I_d[i];
   assign prbs_poly[i+1] = {prbs_msb[i+1] , prbs_poly[i][1:`MACRO_32-1]};
end
endgenerate




// sequential circuit
always@(posedge CLK_I)begin
    PATTERN_I_reg <= PATTERN_I;
end
assign pattern_rst = PATTERN_I_reg != PATTERN_I;

always @(posedge CLK_I) begin
    if(RST_I | pattern_rst  ) begin
        prbs_reg <= ((PATTERN_I==9) && C_PATTERN_9_EN) ?  {(`MACRO_32/2+1){2'b01}} :  (PATTERN_I==10 && C_PATTERN_10_EN) ?  {(`MACRO_32/16+1){16'b0000000011111111}} :  (PATTERN_I==0 && C_PATTERN_0_EN) ? USR_PATTERN_I :  {(`MACRO_32){1'b1}};
        DATA_O_b   <= {(`MACRO_80){1'b1}};
    end
    else begin
        DATA_O_b   <= prbs_xor_b;
        prbs_reg <= (C_DATA_WIDTH_16_EN & DATA_WIDTH_I== 16) ?  prbs_poly[16] :
                    (C_DATA_WIDTH_20_EN & DATA_WIDTH_I== 20) ?  prbs_poly[20] :
                    (C_DATA_WIDTH_32_EN & DATA_WIDTH_I== 32) ?  prbs_poly[32] :
                    (C_DATA_WIDTH_64_EN & DATA_WIDTH_I== 64) ?  prbs_poly[64] :
                    (C_DATA_WIDTH_80_EN & DATA_WIDTH_I== 80) ?  prbs_poly[80] : 
                    prbs_poly[16] ;          
    end
end    
    
assign prbs_poly[0] = prbs_reg;
  

    
    
    
endmodule
