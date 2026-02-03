`timescale 1ns / 1ps
`define NEG_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate
`define CDC_SINGLE_BIT_PULSE_OUTGEN(aclk,arst,apulse_in,bclk,brst,bpulse_out,SIM)                       generate if(SIM==0)begin  xpm_cdc_pulse #(.DEST_SYNC_FF(4), .INIT_SYNC_FF(0),.REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) cdc_u (.src_clk(aclk),.src_rst(arst),.src_pulse(apulse_in),.dest_clk(bclk),.dest_rst(brst),.dest_pulse(bpulse_out));   end else begin   reg [5:0] name1 = 0;wire name2;always@(posedge aclk)if(arst)name1[0] <=0;else name1[0] <= apulse_in;assign name2 = apulse_in & ~name1[0]; always@(posedge aclk)if(arst)name1[1] <= 0;else name1[1] <= name2 ? ~name1[1]:name1[1];always@(posedge bclk)if(brst)name1[5:2]<=0;else begin name1[2]<=name1[1];name1[3]<=name1[2];name1[4]<=name1[3];name1[5]<=name1[4];end  assign bpulse_out=name1[4]^name1[5];  end  endgenerate
`define POS_STRETCH_CNT_OUTGEN(pulse_p_in,clk,pulse_p_out,C_RESET_SCLK_NUM)                                    generate begin  reg [31:0] cnt_name = 0;always@(posedge clk)begin if(pulse_p_in )begin cnt_name <= C_RESET_SCLK_NUM-1; end  else begin  cnt_name <= (cnt_name == 0) ? 0 : (cnt_name - 1);end end  assign pulse_p_out = pulse_p_in|((cnt_name != 0)? 1:0); end  endgenerate


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/28 15:53:14
// Design Name: 
// Module Name: native_deskew
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module native_deskew(
input   PCLK_I,
input   PRST_I,//为根据port数决定的 locked信号
input   [C_PORT_NUM-1:0] VS_I,
input   [C_PORT_NUM-1:0] HS_I,
input   [C_PORT_NUM-1:0] DE_I,//must assume inner fifo is all ready for wr
input   [C_LANE_NUM*2*C_PORT_NUM-1:0] R_I,
input   [C_LANE_NUM*2*C_PORT_NUM-1:0] G_I,
input   [C_LANE_NUM*2*C_PORT_NUM-1:0] B_I,

output  reg [C_PORT_NUM-1:0] VS_O,
output  reg [C_PORT_NUM-1:0] HS_O,
output  reg [C_PORT_NUM-1:0] DE_O,
output  reg [C_LANE_NUM*2*C_PORT_NUM-1:0] R_O,
output  reg [C_LANE_NUM*2*C_PORT_NUM-1:0] G_O,
output  reg [C_LANE_NUM*2*C_PORT_NUM-1:0] B_O,

output         MIS_ALIGNED_O,
output  [31:0] MIS_ALIGNED_ACCUS_O,//DBG:  mis aligned num of  total produce
output  [15:0] MIS_ALIGNED_ROUNDS_O,//DBG: mis aligned num of  this round
output  [15:0] MIS_ALIGNED_RETRYS_O ,//DBG: mis aligned --> rst total times

/////////////////////////////////////////////////////////////////////////////////////////////
input   SYS_CLK_I    ,//to generate independent 1to7 reset
output  RESET_1TO7_O , //~SYS_CLK_I
input [3:0] PORT_NUM_I

);
    
parameter C_LANE_NUM = 4; 
parameter C_PORT_NUM = 4;
parameter C_MISALIGN_PCLK_PROTECT = 1000; //~pclk 【建议】: 不一定有用，暂时保留。如果后续遇到问题，可以拿掉
parameter C_MISALIGNED_RST_THRESHOLD = 300;//~pclk 【建议】：稍微长一点，必然锁定后短暂不稳定造成反复复位；  连续多少次不对齐即启动复位 must <= 65535; when mis_aligned_round_count >= THIS VALUE ,then generate reset to 1to7
parameter C_1TO7_RESET_ACLK_NUM      = 100;//~aclk 时钟域下的复位长度 ; 【建议】：可以很长，因为复位时反正也会把本模块内部钳制住
///////////////////////////////////////////////////////////////////////////////////////////////
  
genvar i,j,k; 

reg  [C_PORT_NUM-1:0] VS_I_reg = 0;
reg  [C_PORT_NUM-1:0] HS_I_reg = 0;
reg  [C_PORT_NUM-1:0] DE_I_reg = 0;
reg  [C_LANE_NUM*2*C_PORT_NUM-1:0] R_I_reg = 0;
reg  [C_LANE_NUM*2*C_PORT_NUM-1:0] G_I_reg = 0;
reg  [C_LANE_NUM*2*C_PORT_NUM-1:0] B_I_reg = 0;


wire  [C_PORT_NUM-1:0] VS_w;
wire  [C_PORT_NUM-1:0] HS_w;
wire  [C_PORT_NUM-1:0] DE_w;
wire  [C_LANE_NUM*2*C_PORT_NUM-1:0] R_w;
wire  [C_LANE_NUM*2*C_PORT_NUM-1:0] G_w;
wire  [C_LANE_NUM*2*C_PORT_NUM-1:0] B_w;

wire  fifo_read_unf;
wire  [C_PORT_NUM-1:0] fifo_rd_empty;
wire  [C_PORT_NUM-1:0] fifo_wr_rst_busy;  
wire  [C_PORT_NUM-1:0] fifo_rd_rst_busy;  
reg [15:0] mis_aligned_round_count = 0;
reg [31:0] mis_aligned_accus = 0;
wire mis_aligned_rst_pclk; //only one pulse
wire mis_aligned_rst_axiclk_pos;
wire    mis_aligned;
wire mis_aligned_rst_axiclk_pos__protect;
reg [15:0] mis_aligned_retrys = 0;


///////////////////////////////////////////////////////////////////////////////////////////////
reg [C_PORT_NUM-1:0] misalign_mask;
always@(*)begin
    case(PORT_NUM_I)
        1:misalign_mask = {{C_PORT_NUM{1'b1}},1'b0};
        2:misalign_mask = {{C_PORT_NUM{1'b1}},2'b00};
        4:misalign_mask = {{C_PORT_NUM{1'b1}},4'b0000};
        5:misalign_mask = {{C_PORT_NUM{1'b1}},5'b00000};
        default:misalign_mask = {{C_PORT_NUM{1'b1}},4'b0000};
    endcase
end

//不对齐生成逻辑 ：de不等于全1或不等于全0
//方法：构造两个de变量，一个用于检测全1，一个用于检测全0
// 
wire [C_PORT_NUM-1:0] de_check1;
wire [C_PORT_NUM-1:0] de_check0;
assign de_check1 = misalign_mask  | DE_w ; //按位或，让被屏蔽的位始终为1
assign de_check0 = ~misalign_mask & DE_w ;

//使用【屏蔽后】的信号来检查是否对齐
assign mis_aligned =  ~PRST_I & ( ( de_check1 != {C_PORT_NUM{1'b1}} ) &  ( de_check0 != {C_PORT_NUM{1'b0}} ) );
assign  MIS_ALIGNED_O = mis_aligned;


always@(posedge PCLK_I)begin
    mis_aligned_accus <= mis_aligned ? mis_aligned_accus + 1 : mis_aligned_accus;
end
assign MIS_ALIGNED_ACCUS_O = mis_aligned_accus;

always@(posedge PCLK_I)begin
    if(PRST_I | mis_aligned_rst_pclk)mis_aligned_round_count <= 0;
    else mis_aligned_round_count <= mis_aligned ? mis_aligned_round_count + 1 : mis_aligned_round_count;
end
assign MIS_ALIGNED_ROUNDS_O = mis_aligned_round_count;
//


always@(posedge PCLK_I)begin
    mis_aligned_retrys <= mis_aligned_rst_pclk ? mis_aligned_retrys + 1 : mis_aligned_retrys;
end
assign MIS_ALIGNED_RETRYS_O = mis_aligned_retrys;

//rst gen////////////////////////////////////////////////////////////////////////////////////////////////// 
assign mis_aligned_rst_pclk = mis_aligned_round_count >= C_MISALIGNED_RST_THRESHOLD;// OMLY ONE Pulse
`CDC_SINGLE_BIT_PULSE_OUTGEN(PCLK_I,0,mis_aligned_rst_pclk,SYS_CLK_I,0,mis_aligned_rst_axiclk_pos,1)//cdc to one pulse
`POS_STRETCH_CNT_OUTGEN(mis_aligned_rst_pclk,PCLK_I,mis_aligned_rst_axiclk_pos__protect,C_MISALIGN_PCLK_PROTECT)  
`POS_STRETCH_CNT_OUTGEN(mis_aligned_rst_axiclk_pos,SYS_CLK_I,RESET_1TO7_O,C_1TO7_RESET_ACLK_NUM)

//note: mis_aligned_rst_pclk will disable PCLK_I
always@(posedge PCLK_I)begin
    if(PRST_I | mis_aligned_rst_axiclk_pos__protect)begin
        VS_I_reg <= 0;
        HS_I_reg <= 0;
        DE_I_reg <= 0;
        R_I_reg  <= 128'b0;
        G_I_reg  <= 128'b0;
        B_I_reg  <= 128'b0;
    end
    else begin
        VS_I_reg <= VS_I ;
        HS_I_reg <= HS_I ;
        DE_I_reg <= DE_I ;
        R_I_reg  <= R_I  ;
        G_I_reg  <= G_I  ;
        B_I_reg  <= B_I  ;
    end
end


wire [C_PORT_NUM-1:0] fifo_rd_empty_mask;
assign fifo_rd_empty_mask = fifo_rd_empty  &  ( ~misalign_mask ) ;

assign  fifo_read_unf = (~mis_aligned) & (fifo_rd_empty_mask=={C_PORT_NUM{1'b0}}) & (fifo_wr_rst_busy=={C_PORT_NUM{1'b0}}) &  (fifo_rd_rst_busy=={C_PORT_NUM{1'b0}}) ;
  
reg [C_PORT_NUM-1:0] de_start_flag = 0;
reg [C_PORT_NUM-1:0] wr_en = 0;


generate for(i=0;i<=C_PORT_NUM-1;i=i+1)begin : loop  

reg de_reg;
wire wr_rst_busy;
wire rd_rst_busy;


//保护时间后（保护时间中flag置0），de下降沿后 --> 才开始判断de的上沿并启动写入

always@(posedge PCLK_I)begin
    if(PRST_I | mis_aligned_rst_axiclk_pos__protect)begin
        de_start_flag[i] <= 0;
    end
    else begin        
        de_start_flag[i] <= de_start_flag[i]==1 ? 1 : ({de_reg,DE_I_reg[i]}==2'b10) ? 1 : de_start_flag[i] ;
    end
end     
        

always @ (posedge PCLK_I)begin
    if(PRST_I | mis_aligned_rst_axiclk_pos__protect) begin//其实也不需要 mis_aligned_rst_axiclk_pos__protect 保护, PRST_I 就已经实现了保护
        wr_en[i]  <= 0;
    end    
    else if( {de_reg,DE_I_reg[i]}==2'b01 &  de_start_flag[i] ) begin //pos
        wr_en[i]  <= 1;
    end  
end

always@(posedge PCLK_I)begin
    if(PRST_I | mis_aligned_rst_axiclk_pos__protect) begin
        de_reg <= 0;
    end
    else begin
        de_reg <= DE_I_reg[i];
    end
end

fifo_async_xpm  
    #(.C_WR_WIDTH             (C_LANE_NUM*2*3+3),// ratio must be 1:1, 1:2, 1:4, 1:8,
      .C_WR_DEPTH             (32),// must>=16 ; actual depth = C_WR_DEPTH - 1;  must be power of 2
      .C_RD_WIDTH             (C_LANE_NUM*2*3+3),
      .C_WR_COUNT_WIDTH       (16),
      .C_RD_COUNT_WIDTH       (16),
      .C_RD_PROG_EMPTY_THRESH (4), // note
      .C_WR_PROG_FULL_THRESH  (12),
      .C_RELATED_CLOCKS       (0), 
      .C_RD_MODE              ("std") //"std" "fwft"  
     )
    fifo_async_xpm_u(
    .WR_RST_I         (PRST_I | mis_aligned_rst_axiclk_pos__protect),
    .WR_CLK_I         (PCLK_I ),
    .WR_EN_I          (wr_en[i] ),
    .WR_DATA_I        ({VS_I_reg[i],HS_I_reg[i],DE_I_reg[i],R_I_reg[i*C_LANE_NUM*2+:C_LANE_NUM*2],G_I_reg[i*C_LANE_NUM*2+:C_LANE_NUM*2],B_I_reg[i*C_LANE_NUM*2+:C_LANE_NUM*2]}),
    .WR_FULL_O        (),
    .WR_RST_BUSY_O    (fifo_wr_rst_busy[i]),
    .RD_CLK_I         (PCLK_I),
    .RD_EN_I          (fifo_read_unf),
    .RD_DATA_O        ({VS_w[i],HS_w[i],DE_w[i],R_w[i*C_LANE_NUM*2+:C_LANE_NUM*2],G_w[i*C_LANE_NUM*2+:C_LANE_NUM*2],B_w[i*C_LANE_NUM*2+:C_LANE_NUM*2]}),
    .RD_PROG_EMPTY_O  (fifo_rd_empty[i]),
    .RD_RST_BUSY_O    (fifo_rd_rst_busy[i])
    );

 
always @ (posedge PCLK_I)begin
    if(PRST_I | mis_aligned_rst_axiclk_pos__protect | fifo_wr_rst_busy[i] | fifo_rd_rst_busy[i])begin //target : when mis_aligned, to produce a LONG KEEP before SRC send new data 
        DE_O[i]                            <= 'b0;
        VS_O[i]                            <= 'b0;
        HS_O[i]                            <= 'b0;
        R_O[i*C_LANE_NUM*2+:C_LANE_NUM*2]  <= 'b0;
        G_O[i*C_LANE_NUM*2+:C_LANE_NUM*2]  <= 'b0;
        B_O[i*C_LANE_NUM*2+:C_LANE_NUM*2]  <= 'b0;
    end 
    else begin
        DE_O[i]                            <= DE_w[i]                           ; 
        VS_O[i]                            <= VS_w[i]                           ; 
        HS_O[i]                            <= HS_w[i]                           ; 
        R_O[i*C_LANE_NUM*2+:C_LANE_NUM*2]  <= R_w[i*C_LANE_NUM*2+:C_LANE_NUM*2] ; 
        G_O[i*C_LANE_NUM*2+:C_LANE_NUM*2]  <= G_w[i*C_LANE_NUM*2+:C_LANE_NUM*2] ; 
        B_O[i*C_LANE_NUM*2+:C_LANE_NUM*2]  <= B_w[i*C_LANE_NUM*2+:C_LANE_NUM*2] ; 
    end 
end


end

endgenerate 


    
endmodule




