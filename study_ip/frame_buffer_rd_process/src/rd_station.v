`timescale 1ns / 1ps
`define POS_MONITOR_FF1(clk_in,rst_in,in,buf_name1,out)      reg buf_name1 = 1; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 1; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);
`define NEG_MONITOR_FF1(clk_in,rst_in,in,buf_name1,out)      reg buf_name1 = 0; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);
`define DELAY_OUTGEN(clk,rst,data_in,data_out,DATA_WIDTH,DLY)                                           generate if(DLY==0)begin  assign data_out = data_in; end  else if(DLY==1)begin  reg [DATA_WIDTH-1:0] a_temp = 0; always@(posedge clk) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [DATA_WIDTH-1:0] a_temp [DLY-1:0] ;always@(posedge clk) begin  if(rst)a_temp[DLY-1] <= 0; else   a_temp[DLY-1] <= data_in; end  for(i=0;i<=DLY-2;i=i+1)begin  always@(posedge clk)begin  if(rst)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  endgenerate


//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: yzhu
//
// Create Date: 2023/06/23 13:58:55
// Design Name:
// Module Name: rd_station
// Project Name:
//////////////////////////////////////////////////////////////////////////////////

// the construction is symmetry to wr_station

module rd_station(
input                           CLK_I      ,
input                           RST_I      ,
//
input                           VS_I       ,
input                           HS_I       ,
input                           DE_I       ,
input                           DE_I_TOTAL ,
input [$clog2(C_MAX_UNIT_NUM)-1:0]  UNITS_I    ,
//
output                          RD_O       ,
input   [C_MAX_UNIT_NUM*C_BIT_NUM_PER_UNIT-1:0]      DATA_I     ,
//
output                          VS_O       ,
output                          HS_O       ,
output                          DE_O       ,
output  DE_O_TOTAL ,
output  reg [C_MAX_UNIT_NUM*C_BIT_NUM_PER_UNIT-1:0]  DATA_O  = 0

);
parameter C_MAX_UNIT_NUM = 32;
parameter C_BIT_NUM_PER_UNIT = 8 ;

genvar i,j,k;

wire [C_MAX_UNIT_NUM*C_BIT_NUM_PER_UNIT-1:0]           fifo_data_o_w;

reg [$clog2(C_MAX_UNIT_NUM)-1:0] cnt_id_sft= 0;// from 0
reg [$clog2(C_MAX_UNIT_NUM)-1:0] cnt_id_run= 0;// from 0
wire [$clog2(C_MAX_UNIT_NUM)-1:0] cnt_id_run_p;// from 0
reg  [C_MAX_UNIT_NUM*C_BIT_NUM_PER_UNIT-1:0] A= 0;
reg  [C_MAX_UNIT_NUM*C_BIT_NUM_PER_UNIT-1:0] B= 0;
wire [2*C_MAX_UNIT_NUM*C_BIT_NUM_PER_UNIT-1:0] B_A;
wire [2*C_MAX_UNIT_NUM*C_BIT_NUM_PER_UNIT-1:0] A_B;
reg A_valid= 0;
reg B_valid= 0;
wire VS_I_pos ;
wire DE_I_pos ;
wire de_pos;
reg de_pos_flag = 0;
wire DE_I_s1;
reg flag = 0;
wire rd;
wire [$clog2(C_MAX_UNIT_NUM)-1:0] cnt_id_run__p__BYTE_NUM_I;
wire [$clog2(C_MAX_UNIT_NUM)-1:0] cnt_id_sft__p__BYTE_NUM_I;
reg AB_sel;
reg valid_buf = 0;

/////////////////////////////////////////////////////////////////////////


`DELAY_OUTGEN(CLK_I,0,VS_I,VS_O,1,2)
`DELAY_OUTGEN(CLK_I,0,HS_I,HS_O,1,2)
`DELAY_OUTGEN(CLK_I,0,DE_I,DE_O,1,2)
`DELAY_OUTGEN(CLK_I,0,DE_I_TOTAL,DE_O_TOTAL,1,2)


assign B_A = {B,A};
assign A_B = {A,B};
`POS_MONITOR_FF1(CLK_I,0,VS_I,buf_name4,VS_I_pos)
`POS_MONITOR_FF1(CLK_I,0,DE_I,buf_name3,DE_I_pos)

assign de_pos = de_pos_flag ? 0 : DE_I_pos;

always@(posedge CLK_I)begin
    de_pos_flag <= VS_I_pos | RST_I  ? 0 : DE_I_pos ? 1 : de_pos_flag;
end

`DELAY_OUTGEN(CLK_I,RST_I,DE_I,DE_I_s1,1,1)


//exp: 3 为每次读取字节数(total 4)  |A| |B| 为准备好时刻
//DE_I                               ||__|————————————————
//DE_I_s1                            ||____|——————————————
//RD                                 ||__|—|______________
//当前移位bit    (直接以组合逻辑打出)|| 000|0|3|2|1|0|3|2|
//当前运行bit                        || 000|3|2|1|0|3|2|1|
//(当前运行bit)3+3跨越(需提前读取)   ||____|—|—|—|_|—|—|—|
//打入A/B                            ||----|A|B|A|—|B|A|B|
//flag当前移位bit变小则需要反转      ||----|_|_|—|_|—|—|_|
//running                            ||____|——————————————


//debug list 2023
//tpg_de  ____|————————————————|________|————————————————|____  ... ____|————————————————|_____
//fifo_rd  ___|——————————————————|________|————————————————|____  ... ____|————————————————|_____
//hs conut            1                           2                              2160
//rd invalid ____________________________________________________________________________|—|_____
//每一帧最后一次读虽然无效，但是不影响功能



reg [$clog2(C_MAX_UNIT_NUM)-1:0]  units_i  ;

always@(posedge CLK_I)begin
    if(RST_I | VS_I)begin
        units_i <= UNITS_I;
    end
    else begin
        units_i <= units_i ;
    end
end


reg [$clog2(C_MAX_UNIT_NUM)-1:0]  units_i_inter;
// --------------------bytes 的有效参数范围-----------可人为调整，以优化资源-------------------------------


always@(units_i)begin
    case(units_i)
    0 : units_i_inter   = 0 ;
    //1 : units_i_inter   = 1 ;
    2 : units_i_inter   = 2 ;
   // 3 : units_i_inter   = 2 ;
    4 : units_i_inter   = 4 ;
    8 : units_i_inter   = 8 ;
    16 : units_i_inter   = 16 ;
    //
    //.....
    //
    //C_MAX_UNIT_NUM : units_i_inter  = C_MAX_UNIT_NUM;
    default:units_i_inter   = 0 ;
    endcase
end



//控制cnt计数/////////////////////////////////////////////////////
always@(posedge CLK_I)begin
    if(RST_I)begin
        cnt_id_run <= 0;
    end
    else begin
        cnt_id_run <= DE_I ? cnt_id_run__p__BYTE_NUM_I : cnt_id_run;
    end
end

always@(posedge CLK_I)begin
    if(RST_I)begin
        flag <= 0;
        cnt_id_sft <= 0;
    end
    else begin
        cnt_id_sft <= DE_I_s1 ? (cnt_id_sft+units_i_inter) : cnt_id_sft ;
        flag <= DE_I_s1 & cnt_id_sft__p__BYTE_NUM_I <= cnt_id_sft ? ~flag : flag;
    end
end

assign cnt_id_run_p = cnt_id_run + units_i_inter ;

assign  rd = DE_I_s1 & cnt_id_run_p <= cnt_id_run;

assign cnt_id_run__p__BYTE_NUM_I = cnt_id_run + units_i_inter;

assign cnt_id_sft__p__BYTE_NUM_I = cnt_id_sft + units_i_inter;


assign RD_O = rd | de_pos; //fwft
//assign RD_O = rd ; //fwft


always@(posedge CLK_I)begin
    if(RST_I)AB_sel <= 0;
    else AB_sel <= RD_O ? ~AB_sel : AB_sel;
end

always@(posedge CLK_I)begin
    A <= RD_O & (~AB_sel) ? DATA_I : A;
    B <= RD_O & ( AB_sel) ? DATA_I : B;
end


//控制ABorBA (cnt跨越时)/////////////////////////////////////////
assign fifo_data_o_w = flag ? A_B>>(cnt_id_sft*C_BIT_NUM_PER_UNIT) :  B_A>>(cnt_id_sft*C_BIT_NUM_PER_UNIT)  ;

always@(posedge CLK_I)begin
    DATA_O  <= fifo_data_o_w;
end



endmodule



