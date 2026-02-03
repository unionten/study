`timescale 1ns / 1ps
`define CDC_MULTI_BIT_SIGNAL_INGEN_NOIN(adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                     begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(0),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk( ),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end    
`define CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                    generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(0),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk( ),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  

`define TIMER_OUTGEN(clk,rst,sec_pulse_out,breath_out,CLK_PRD_NS,PULSE_WIDTH)                           generate  begin reg [31:0] cname = 0;reg sname = 0;reg bname = 0;always@(posedge clk) if(rst)begin cname<= 0;sname<=0;bname<=0; end else if(cname==(1000000000/CLK_PRD_NS-1))begin cname<=0;sname<=1;bname<=~bname;end else begin cname<= cname+1; bname<=(cname==(500000000/CLK_PRD_NS-1))?~bname:bname; sname<=(cname==((PULSE_WIDTH)-1))?0:sname;end  assign sec_pulse_out = sname;assign breath_out = bname; end endgenerate

`define CDC_SINGLE_BIT_PULSE_OUTGEN(aclk,arst,apulse_in,bclk,brst,bpulse_out,SIM,DEST_FF)               generate if(SIM==0)begin  xpm_cdc_pulse #(.DEST_SYNC_FF(DEST_FF), .INIT_SYNC_FF(0),.REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) cdc_u (.src_clk(aclk),.src_rst(arst),.src_pulse(apulse_in),.dest_clk(bclk),.dest_rst(brst),.dest_pulse(bpulse_out));   end else begin   reg [5:0] name1 = 0;wire name2;always@(posedge aclk)if(arst)name1[0] <=0;else name1[0] <= apulse_in;assign name2 = apulse_in & ~name1[0]; always@(posedge aclk)if(arst)name1[1] <= 0;else name1[1] <= name2 ? ~name1[1]:name1[1];always@(posedge bclk)if(brst)name1[5:2]<=0;else begin name1[2]<=name1[1];name1[3]<=name1[2];name1[4]<=name1[3];name1[5]<=name1[4];end  assign bpulse_out=name1[4]^name1[5];  end  endgenerate


`define  ADDR_FILTER_EN                      16'h0000 
`define  ADDR_STABLE_STATUS                  16'h0004 
`define  ADDR_TIMEOUT_STATUS                 16'h0008   
`define  ADDR_FSYNC_HZ_0_3                   16'h000C   
`define  ADDR_FSYNC_HZ_4_7                   16'h0010   
`define  ADDR_FSYNC_FILTER_HZ_0_3            16'h0014   
`define  ADDR_FSYNC_FILTER_HZ_4_7            16'h0018   
`define  ADDR_PROC_VS_HZ_0_3                 16'h001C   
`define  ADDR_PROC_VS_HZ_4_7                 16'h0020   
`define  ADDR_MIPI_VS_HZ_0_3                 16'h0024   
`define  ADDR_MIPI_VS_HZ_4_7                 16'h0028   

`define  ADDR_FILTER_TIMES_0                 16'h1000  //配置 连续多少次vs间隔稳定，则开启传递
`define  ADDR_FILTER_TIMES_1                 16'h1004 
`define  ADDR_FILTER_TIMES_2                 16'h1008 
`define  ADDR_FILTER_TIMES_3                 16'h100C 
`define  ADDR_FILTER_TIMES_4                 16'h1010 
`define  ADDR_FILTER_TIMES_5                 16'h1014 
`define  ADDR_FILTER_TIMES_6                 16'h1018 
`define  ADDR_FILTER_TIMES_7                 16'h101C 

`define  ADDR_FILTER_THRESHHOLD_CLKPRD_0     16'h2000  //判断两次vs间隔相同的 阈值 (时钟数)
`define  ADDR_FILTER_THRESHHOLD_CLKPRD_1     16'h2004 
`define  ADDR_FILTER_THRESHHOLD_CLKPRD_2     16'h2008 
`define  ADDR_FILTER_THRESHHOLD_CLKPRD_3     16'h200C 
`define  ADDR_FILTER_THRESHHOLD_CLKPRD_4     16'h2010 
`define  ADDR_FILTER_THRESHHOLD_CLKPRD_5     16'h2014 
`define  ADDR_FILTER_THRESHHOLD_CLKPRD_6     16'h2018 
`define  ADDR_FILTER_THRESHHOLD_CLKPRD_7     16'h201C 


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/21 17:55:44
// Design Name: 
// Module Name: vs_filter_axi
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

//全功能资源大约 1000LUT 3000FF

module vs_filter_axi(

input  wire                                      S_AXI_ACLK      ,//总线时钟
input  wire                                      S_AXI_ARESETN   ,
output wire                                      S_AXI_AWREADY   ,
input  wire [C_AXI_LITE_ADDR_WIDTH-1:0]          S_AXI_AWADDR    ,
input  wire                                      S_AXI_AWVALID   ,
input  wire [ 2:0]                               S_AXI_AWPROT    ,
output wire                                      S_AXI_WREADY    ,
input  wire [C_AXI_LITE_DATA_WIDTH-1:0]          S_AXI_WDATA     ,
input  wire [(C_AXI_LITE_DATA_WIDTH/8)-1 :0]     S_AXI_WSTRB     ,
input  wire                                      S_AXI_WVALID    ,
output wire [ 1:0]                               S_AXI_BRESP     ,
output wire                                      S_AXI_BVALID    ,
input  wire                                      S_AXI_BREADY    ,
output wire                                      S_AXI_ARREADY   ,
input  wire [C_AXI_LITE_ADDR_WIDTH-1:0]          S_AXI_ARADDR    ,
input  wire                                      S_AXI_ARVALID   ,
input  wire [ 2:0]                               S_AXI_ARPROT    ,
output wire [ 1:0]                               S_AXI_RRESP     ,
output wire                                      S_AXI_RVALID    ,
output wire [C_AXI_LITE_DATA_WIDTH-1:0]          S_AXI_RDATA     ,
input  wire                                      S_AXI_RREADY    ,



input  PCLK_I                       ,
input  RSTN_I                        ,
input  [C_VS_NUM-1:0] VS_I       ,// __|————|_____ 
output [C_VS_NUM-1:0] VS_O        ,//  --- 检测上沿 --- 极性为0时，不稳定时输出0。为1时输出1
output [C_VS_NUM-1:0] VS_STABLE_O   , // 
output [C_VS_NUM-1:0] VS_TIMEOUT_O   ,

input  [C_VS_NUM-1:0]    PROC_VS_I  ,
input  [C_VS_NUM-1:0]    MIPI_VS_I   


    );


parameter C_VS_NUM               =  8 ;   // 1 ~ 8
parameter C_AXI_LITE_ADDR_WIDTH  =  16 ; 
parameter C_AXI_LITE_DATA_WIDTH  =  32 ;
parameter C_AXI_CLK_PRD_NS       =  10 ;

parameter [7:0] C_FILTER_EN_DEFAULT      = 8'b11111111 ;
parameter [7:0] C_FILTER_TIMES_0_DEFAULT = 3 ;
parameter [7:0] C_FILTER_TIMES_1_DEFAULT = 3 ;
parameter [7:0] C_FILTER_TIMES_2_DEFAULT = 3 ;
parameter [7:0] C_FILTER_TIMES_3_DEFAULT = 3 ;
parameter [7:0] C_FILTER_TIMES_4_DEFAULT = 3 ;
parameter [7:0] C_FILTER_TIMES_5_DEFAULT = 3 ;
parameter [7:0] C_FILTER_TIMES_6_DEFAULT = 3 ;
parameter [7:0] C_FILTER_TIMES_7_DEFAULT = 3 ;

parameter [15:0] C_FILTER_THRESHHOLD_CLKPRD_0_DEFAULT = 2000 ;
parameter [15:0] C_FILTER_THRESHHOLD_CLKPRD_1_DEFAULT = 2000 ;
parameter [15:0] C_FILTER_THRESHHOLD_CLKPRD_2_DEFAULT = 2000 ;
parameter [15:0] C_FILTER_THRESHHOLD_CLKPRD_3_DEFAULT = 2000 ;
parameter [15:0] C_FILTER_THRESHHOLD_CLKPRD_4_DEFAULT = 2000 ;
parameter [15:0] C_FILTER_THRESHHOLD_CLKPRD_5_DEFAULT = 2000 ;
parameter [15:0] C_FILTER_THRESHHOLD_CLKPRD_6_DEFAULT = 2000 ;
parameter [15:0] C_FILTER_THRESHHOLD_CLKPRD_7_DEFAULT = 2000 ;

parameter C_THRESHHOLD_CLKPRD_BW = 16 ;//差值 位宽
parameter C_TIMEOUT_TIME_CLKNUM_BW = 24 ; // 超时 位宽
parameter C_FSYNC_CNT_BW           = 8 ; // 最大 8 
parameter C_TIMEOUT_TIME_US  = 100000 ; //100ms


parameter [0:0] C_ILA_AXILITE_EN = 0 ;
parameter [0:0] C_CLKPRD_DET_BLOCK_EN = 1;//C_VS_NUM 路频率检测模块
parameter [0:0] C_TIMEOUT_DET_BLOCK_EN = 1;// 0则关闭vs的超时检测
parameter [0:0] C_VS_POLARITY = 0 ;


localparam C_TIMEOUT_TIME_CLKNUM = C_TIMEOUT_TIME_US*1000/C_AXI_CLK_PRD_NS;
    
genvar i,j,k;





reg [C_VS_NUM-1:0]  R_FILTER_EN ;
reg [7:0] R_FILTER_TIMES [C_VS_NUM-1:0]  ;
reg [C_THRESHHOLD_CLKPRD_BW-1:0]  R_FILTER_THRESHHOLD_CLKPRD  [C_VS_NUM-1:0];
 
wire [C_VS_NUM-1:0]   VS_I_st  ;// VS_I 打拍后
 

wire                              write_req_cpu_to_axi   ;
wire  [C_AXI_LITE_ADDR_WIDTH-1:0] write_addr_cpu_to_axi  ;
wire [C_AXI_LITE_DATA_WIDTH-1:0]  write_data_cpu_to_axi  ;
wire                              read_req_cpu_to_axi    ;
wire  [C_AXI_LITE_ADDR_WIDTH-1:0] read_addr_cpu_to_axi   ;
reg   [C_AXI_LITE_DATA_WIDTH-1:0] read_data_axi_to_cpu   ;
reg                               read_finish_axi_to_cpu ;



wire [C_VS_NUM-1:0]  R_VS_STABLE ;
wire [C_VS_NUM-1:0]  R_VS_TIMEOUT ;

wire [C_FSYNC_CNT_BW-1:0]  R_VS_HZ         [C_VS_NUM-1:0]  ;
wire [C_FSYNC_CNT_BW-1:0]  R_VS_FILTER_HZ  [C_VS_NUM-1:0]  ;
wire [C_FSYNC_CNT_BW-1:0]  R_PROC_VS_HZ    [C_VS_NUM-1:0]  ;
wire [C_FSYNC_CNT_BW-1:0]  R_MIPI_VS_I_HZ  [C_VS_NUM-1:0]  ;


wire sec_pulse_axiclk;
 
`TIMER_OUTGEN(S_AXI_ACLK,0,sec_pulse_axiclk,breath_out,C_AXI_CLK_PRD_NS,10)   

generate for(i=0; i<C_VS_NUM;i=i+1)begin  : blk
wire       R_FILTER_EN_pclk ;
wire [7:0] R_FILTER_TIMES_pclk ;
wire [C_THRESHHOLD_CLKPRD_BW-1:0]  R_FILTER_THRESHHOLD_CLKPRD_pclk ;

`CDC_MULTI_BIT_SIGNAL_INGEN_NOIN(R_FILTER_EN[i],PCLK_I,R_FILTER_EN_pclk,1,2)
`CDC_MULTI_BIT_SIGNAL_INGEN_NOIN(R_FILTER_TIMES[i],PCLK_I,R_FILTER_TIMES_pclk,8,2)
`CDC_MULTI_BIT_SIGNAL_INGEN_NOIN(R_FILTER_THRESHHOLD_CLKPRD[i],PCLK_I,R_FILTER_THRESHHOLD_CLKPRD_pclk,C_THRESHHOLD_CLKPRD_BW,2)


`CDC_MULTI_BIT_SIGNAL_INGEN_NOIN(VS_STABLE_O[i],S_AXI_ACLK ,R_VS_STABLE[i],1,2)
`CDC_MULTI_BIT_SIGNAL_INGEN_NOIN(VS_TIMEOUT_O[i],S_AXI_ACLK,R_VS_TIMEOUT[i],1,2)



`CDC_MULTI_BIT_SIGNAL_INGEN_NOIN(VS_I[i],PCLK_I,VS_I_st[i],1,2)   // VS_I 打拍消除亚稳态

 
vs_filter  # 
     (
    .C_AXI_CLK_PRD_NS                     (C_AXI_CLK_PRD_NS                     ) , //=  10 ;
    .C_THRESHHOLD_CLKPRD_BW               (C_THRESHHOLD_CLKPRD_BW               ) , //= 16  ;
    .C_TIMEOUT_TIME_CLKNUM_BW             (C_TIMEOUT_TIME_CLKNUM_BW             ) ,
    .C_TIMEOUT_TIME_CLKNUM                (C_TIMEOUT_TIME_CLKNUM                ) ,
    .C_TIMEOUT_DET_BLOCK_EN               (C_TIMEOUT_DET_BLOCK_EN               )
    )
    filter_u
    (
    .CLK_I         (PCLK_I              )  ,
    .RSTN_I        (RSTN_I              )  ,
    .VS_I          (VS_I_st[i] ^ C_VS_POLARITY            )  ,// __|————|_____ 
    .VS_O          (VS_O[i]             )  ,//  --- 检测上沿
    .VS_STABLE_O   (VS_STABLE_O[i]      )  , // 
    .VS_TIMEOUT_O  (VS_TIMEOUT_O[i]     )  ,  
    .FILTER_EN_I                 (  R_FILTER_EN_pclk                   ) , 
    .FILTER_TIMES_I              (  R_FILTER_TIMES_pclk                ) , 
    .FILTER_THRESHHOLD_CLKPRD_I  (  R_FILTER_THRESHHOLD_CLKPRD_pclk                  )  
    
    
    );

if(C_CLKPRD_DET_BLOCK_EN)begin
    freq_test_value 
        #(.C_CNT_BW   ( C_FSYNC_CNT_BW ) ,
          .SYS_PRD_NS (C_AXI_CLK_PRD_NS ) ,
          .ID(i)  
          
          ) 
        test_u(
        .SYS_CLK_I                 (S_AXI_ACLK     ) , //用于生成内部秒脉冲 时钟域1
        .SYS_RSTN_I                (S_AXI_ARESETN  ) , //时钟域1
        .SEC_I                     (sec_pulse_axiclk ),
        .CLK_BE_TESTED_I           (VS_I_st[i]        ) , //时钟域2
       // .CLK_BE_TESTED_HZ_O        () ,  //时钟域2  最多到1000M 偏小
        .CLK_BE_TESTED_HZ_O_SYSCLK (R_VS_HZ[i]    )
    
    );
    
    
    freq_test_value 
        #(.C_CNT_BW( C_FSYNC_CNT_BW ) ,
          .SYS_PRD_NS (C_AXI_CLK_PRD_NS ),
          .ID(i)  
          ) 
        test_u1(
        .SYS_CLK_I                 (S_AXI_ACLK     ) , //用于生成内部秒脉冲 时钟域1
        .SYS_RSTN_I                (S_AXI_ARESETN  ) , //时钟域1
        .SEC_I                     (sec_pulse_axiclk ),
        .CLK_BE_TESTED_I           (VS_O[i]        ) , //时钟域2
        //.CLK_BE_TESTED_HZ_O        () ,  //时钟域2  最多到1000M 偏小
        .CLK_BE_TESTED_HZ_O_SYSCLK (R_VS_FILTER_HZ[i]    )
    
    );
    
    
    freq_test_value 
        #(.C_CNT_BW( C_FSYNC_CNT_BW ) ,
          .SYS_PRD_NS (C_AXI_CLK_PRD_NS ),
          .ID(i)  
         ) 
        test_u2(
        .SYS_CLK_I                 (S_AXI_ACLK     ) , //用于生成内部秒脉冲 时钟域1
        .SYS_RSTN_I                (S_AXI_ARESETN  ) , //时钟域1
        .SEC_I                     (sec_pulse_axiclk ),
        .CLK_BE_TESTED_I           (PROC_VS_I[i]        ) , //时钟域2
        //.CLK_BE_TESTED_HZ_O        () ,  //时钟域2  最多到1000M 偏小
        .CLK_BE_TESTED_HZ_O_SYSCLK (R_PROC_VS_HZ[i]    )
    
    );
    
    
    
    freq_test_value 
        #(.C_CNT_BW( C_FSYNC_CNT_BW ) ,
          .SYS_PRD_NS (C_AXI_CLK_PRD_NS ) ,
          .ID(i)  
          
          ) 
        test_u3(
        .SYS_CLK_I                 (S_AXI_ACLK     ) , //用于生成内部秒脉冲 时钟域1
        .SYS_RSTN_I                (S_AXI_ARESETN  ) , //时钟域1
        .SEC_I                     (sec_pulse_axiclk ),
        .CLK_BE_TESTED_I           (MIPI_VS_I[i]        ) , //时钟域2
        //.CLK_BE_TESTED_HZ_O        () ,  //时钟域2  最多到1000M 偏小
        .CLK_BE_TESTED_HZ_O_SYSCLK (R_MIPI_VS_I_HZ[i]    )
    
    );
end




end
endgenerate






axi_lite_slave #(
    .C_S_AXI_DATA_WIDTH (C_AXI_LITE_DATA_WIDTH ),
    .C_S_AXI_ADDR_WIDTH (C_AXI_LITE_ADDR_WIDTH )   
    )
    axi_lite_slave_u(

    .S_AXI_ACLK            (S_AXI_ACLK      ),     //input  wire                              
    .S_AXI_ARESETN         (S_AXI_ARESETN   ),     //input  wire                              
    .S_AXI_AWREADY         (S_AXI_AWREADY   ),     //output wire                              
    .S_AXI_AWADDR          (S_AXI_AWADDR    ),     //input  wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .S_AXI_AWVALID         (S_AXI_AWVALID   ),     //input  wire                              
    .S_AXI_AWPROT          (S_AXI_AWPROT    ),     //input  wire [ 2:0]                       
    .S_AXI_WREADY          (S_AXI_WREADY    ),     //output wire                              
    .S_AXI_WDATA           (S_AXI_WDATA     ),     //input  wire [C_S_AXI_DATA_WIDTH-1:0]     
    .S_AXI_WSTRB           (S_AXI_WSTRB     ),         //input  wire [(C_S_AXI_DATA_WIDTH/8)-1 :0]
    .S_AXI_WVALID          (S_AXI_WVALID    ),     //input  wire                              
    .S_AXI_BRESP           (S_AXI_BRESP     ),     //output wire [ 1:0]                       
    .S_AXI_BVALID          (S_AXI_BVALID    ),     //output wire                              
    .S_AXI_BREADY          (S_AXI_BREADY    ),     //input  wire                              
    .S_AXI_ARREADY         (S_AXI_ARREADY   ),     //output wire                              
    .S_AXI_ARADDR          (S_AXI_ARADDR    ),     //input  wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .S_AXI_ARVALID         (S_AXI_ARVALID   ),     //input  wire                              
    .S_AXI_ARPROT          (S_AXI_ARPROT    ),     //input  wire [ 2:0]                       
    .S_AXI_RRESP           (S_AXI_RRESP     ),     //output wire [ 1:0]                       
    .S_AXI_RVALID          (S_AXI_RVALID    ),     //output wire                              
    .S_AXI_RDATA           (S_AXI_RDATA     ),     //output wire [C_S_AXI_DATA_WIDTH-1:0]     
    .S_AXI_RREADY          (S_AXI_RREADY    ),     //input  wire                              
    
    .write_req_cpu_to_axi  (write_req_cpu_to_axi   ),    //wire                              
    .write_addr_cpu_to_axi (write_addr_cpu_to_axi  ),   //wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .write_data_cpu_to_axi (write_data_cpu_to_axi  ),   //wire [C_S_AXI_DATA_WIDTH-1:0]     
    .read_req_cpu_to_axi   (read_req_cpu_to_axi    ),     //wire                              
    .read_addr_cpu_to_axi  (read_addr_cpu_to_axi   ),    //wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .read_data_axi_to_cpu  (read_data_axi_to_cpu   ),    //wire [C_S_AXI_DATA_WIDTH-1:0]     
    .read_finish_axi_to_cpu(read_finish_axi_to_cpu )   //wire                              
      
);




always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        R_FILTER_EN[0]                <=  C_FILTER_EN_DEFAULT[0];
        R_FILTER_EN[1]                <=  C_FILTER_EN_DEFAULT[1];
        R_FILTER_EN[2]                <=  C_FILTER_EN_DEFAULT[2];
        R_FILTER_EN[3]                <=  C_FILTER_EN_DEFAULT[3];
        R_FILTER_EN[4]                <=  C_FILTER_EN_DEFAULT[4];
        R_FILTER_EN[5]                <=  C_FILTER_EN_DEFAULT[5];
        R_FILTER_EN[6]                <=  C_FILTER_EN_DEFAULT[6];
        R_FILTER_EN[7]                <=  C_FILTER_EN_DEFAULT[7];
        R_FILTER_TIMES[0]             <= C_FILTER_TIMES_0_DEFAULT ;
        R_FILTER_TIMES[1]             <= C_FILTER_TIMES_1_DEFAULT ;
        R_FILTER_TIMES[2]             <= C_FILTER_TIMES_2_DEFAULT ;
        R_FILTER_TIMES[3]             <= C_FILTER_TIMES_3_DEFAULT ;
        R_FILTER_TIMES[4]             <= C_FILTER_TIMES_4_DEFAULT ;
        R_FILTER_TIMES[5]             <= C_FILTER_TIMES_5_DEFAULT ;
        R_FILTER_TIMES[6]             <= C_FILTER_TIMES_6_DEFAULT ;
        R_FILTER_TIMES[7]             <= C_FILTER_TIMES_7_DEFAULT ;
        R_FILTER_THRESHHOLD_CLKPRD[0] <= C_FILTER_THRESHHOLD_CLKPRD_0_DEFAULT ;
        R_FILTER_THRESHHOLD_CLKPRD[1] <= C_FILTER_THRESHHOLD_CLKPRD_1_DEFAULT ;
        R_FILTER_THRESHHOLD_CLKPRD[2] <= C_FILTER_THRESHHOLD_CLKPRD_2_DEFAULT ;
        R_FILTER_THRESHHOLD_CLKPRD[3] <= C_FILTER_THRESHHOLD_CLKPRD_3_DEFAULT ;
        R_FILTER_THRESHHOLD_CLKPRD[4] <= C_FILTER_THRESHHOLD_CLKPRD_4_DEFAULT ;
        R_FILTER_THRESHHOLD_CLKPRD[5] <= C_FILTER_THRESHHOLD_CLKPRD_5_DEFAULT ;
        R_FILTER_THRESHHOLD_CLKPRD[6] <= C_FILTER_THRESHHOLD_CLKPRD_6_DEFAULT ;
        R_FILTER_THRESHHOLD_CLKPRD[7] <= C_FILTER_THRESHHOLD_CLKPRD_7_DEFAULT ;    
    end
    else if(write_req_cpu_to_axi)begin
        case(write_addr_cpu_to_axi)
            `ADDR_FILTER_EN  :{ R_FILTER_EN[7] , R_FILTER_EN[6] , R_FILTER_EN[5] ,R_FILTER_EN[4]  ,              
                                R_FILTER_EN[3] , R_FILTER_EN[2] , R_FILTER_EN[1] ,R_FILTER_EN[0]  }
                                         <=  write_data_cpu_to_axi[7:0] ;

            `ADDR_FILTER_TIMES_0             :  R_FILTER_TIMES[0]             <=  write_data_cpu_to_axi[7:0] ;
            `ADDR_FILTER_TIMES_1             :  R_FILTER_TIMES[1]             <=  write_data_cpu_to_axi[7:0] ;
            `ADDR_FILTER_TIMES_2             :  R_FILTER_TIMES[2]             <=  write_data_cpu_to_axi[7:0] ;
            `ADDR_FILTER_TIMES_3             :  R_FILTER_TIMES[3]             <=  write_data_cpu_to_axi[7:0] ;
            `ADDR_FILTER_TIMES_4             :  R_FILTER_TIMES[4]             <=  write_data_cpu_to_axi[7:0] ;
            `ADDR_FILTER_TIMES_5             :  R_FILTER_TIMES[5]             <=  write_data_cpu_to_axi[7:0] ;
            `ADDR_FILTER_TIMES_6             :  R_FILTER_TIMES[6]             <=  write_data_cpu_to_axi[7:0] ;
            `ADDR_FILTER_TIMES_7             :  R_FILTER_TIMES[7]             <=  write_data_cpu_to_axi[7:0] ;
            `ADDR_FILTER_THRESHHOLD_CLKPRD_0 :  R_FILTER_THRESHHOLD_CLKPRD[0] <=  write_data_cpu_to_axi ;
            `ADDR_FILTER_THRESHHOLD_CLKPRD_1 :  R_FILTER_THRESHHOLD_CLKPRD[1] <=  write_data_cpu_to_axi ;
            `ADDR_FILTER_THRESHHOLD_CLKPRD_2 :  R_FILTER_THRESHHOLD_CLKPRD[2] <=  write_data_cpu_to_axi ;
            `ADDR_FILTER_THRESHHOLD_CLKPRD_3 :  R_FILTER_THRESHHOLD_CLKPRD[3] <=  write_data_cpu_to_axi ;
            `ADDR_FILTER_THRESHHOLD_CLKPRD_4 :  R_FILTER_THRESHHOLD_CLKPRD[4] <=  write_data_cpu_to_axi ;
            `ADDR_FILTER_THRESHHOLD_CLKPRD_5 :  R_FILTER_THRESHHOLD_CLKPRD[5] <=  write_data_cpu_to_axi ;
            `ADDR_FILTER_THRESHHOLD_CLKPRD_6 :  R_FILTER_THRESHHOLD_CLKPRD[6] <=  write_data_cpu_to_axi ;
            `ADDR_FILTER_THRESHHOLD_CLKPRD_7 :  R_FILTER_THRESHHOLD_CLKPRD[7] <=  write_data_cpu_to_axi ;
            default:;
        endcase
    end
end




always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        read_data_axi_to_cpu <= 0;
        read_finish_axi_to_cpu <= 0;
    end
    else if(read_req_cpu_to_axi)begin
        read_finish_axi_to_cpu <= 1;
        case(read_addr_cpu_to_axi)
        
        

        `ADDR_FILTER_EN        :  read_data_axi_to_cpu  <=  { R_FILTER_EN[7] , R_FILTER_EN[6] , R_FILTER_EN[5] ,R_FILTER_EN[4]  ,              
                                R_FILTER_EN[3] , R_FILTER_EN[2] , R_FILTER_EN[1] ,R_FILTER_EN[0]  };
        `ADDR_STABLE_STATUS    :  read_data_axi_to_cpu  <=   { R_VS_STABLE[7] , R_VS_STABLE[6] , R_VS_STABLE[5] ,R_VS_STABLE[4]  ,              
                                R_VS_STABLE[3] , R_VS_STABLE[2] , R_VS_STABLE[1] ,R_VS_STABLE[0]  };
        `ADDR_TIMEOUT_STATUS   :  read_data_axi_to_cpu  <=     { R_VS_TIMEOUT[7] , R_VS_TIMEOUT[6] , R_VS_TIMEOUT[5] ,R_VS_TIMEOUT[4]  ,              
                                R_VS_TIMEOUT[3] , R_VS_TIMEOUT[2] , R_VS_TIMEOUT[1] ,R_VS_TIMEOUT[0]  };  
        `ADDR_FSYNC_HZ_0_3     :  read_data_axi_to_cpu  <= {  R_VS_HZ[3] , R_VS_HZ[2],R_VS_HZ[1],R_VS_HZ[0] }   ; 
        `ADDR_FSYNC_HZ_4_7     :  read_data_axi_to_cpu  <= {  R_VS_HZ[7] , R_VS_HZ[6],R_VS_HZ[5],R_VS_HZ[4] }   ; 
        
        `ADDR_FSYNC_FILTER_HZ_0_3     :  read_data_axi_to_cpu  <= {  R_VS_FILTER_HZ[3] , R_VS_FILTER_HZ[2],R_VS_FILTER_HZ[1],R_VS_FILTER_HZ[0] }   ; 
        `ADDR_FSYNC_FILTER_HZ_4_7     :  read_data_axi_to_cpu  <= {  R_VS_FILTER_HZ[7] , R_VS_FILTER_HZ[6],R_VS_FILTER_HZ[5],R_VS_FILTER_HZ[4] }   ; 
       
       
        `ADDR_PROC_VS_HZ_0_3 :  read_data_axi_to_cpu  <= {  R_PROC_VS_HZ[3] , R_PROC_VS_HZ[2],R_PROC_VS_HZ[1],R_PROC_VS_HZ[0] }   ; 
        `ADDR_PROC_VS_HZ_4_7 :  read_data_axi_to_cpu  <= {  R_PROC_VS_HZ[7] , R_PROC_VS_HZ[6],R_PROC_VS_HZ[5],R_PROC_VS_HZ[4] }   ; 
        
        `ADDR_MIPI_VS_HZ_0_3 :  read_data_axi_to_cpu  <= {  R_MIPI_VS_I_HZ[3] , R_MIPI_VS_I_HZ[2],R_MIPI_VS_I_HZ[1],R_MIPI_VS_I_HZ[0] }   ; 
        `ADDR_MIPI_VS_HZ_4_7 :  read_data_axi_to_cpu  <= {  R_MIPI_VS_I_HZ[7] , R_MIPI_VS_I_HZ[6],R_MIPI_VS_I_HZ[5],R_MIPI_VS_I_HZ[4] }   ;   
        
 
  
        default :  read_data_axi_to_cpu <= 0;
        endcase
    end
    else begin
        read_finish_axi_to_cpu <= 0;
    end
end
 

wire  [C_VS_NUM-1:0]  VS_I_axi;
wire  [C_VS_NUM-1:0]  VS_O_axi;
wire  [C_VS_NUM-1:0]  PROC_VS_I_axi;
wire  [C_VS_NUM-1:0]  MIPI_VS_I_axi;
 
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(VS_I,S_AXI_ACLK,VS_I_axi,C_VS_NUM,3)   
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(VS_O,S_AXI_ACLK,VS_O_axi,C_VS_NUM,3)   
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(PROC_VS_I,S_AXI_ACLK,PROC_VS_I_axi,C_VS_NUM,3)   
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(MIPI_VS_I,S_AXI_ACLK,MIPI_VS_I_axi,C_VS_NUM,3)   
 
 
generate if(C_ILA_AXILITE_EN)begin
    ila_0  ila_axilite_u
    (
        .clk     (  S_AXI_ACLK  ) ,
        .probe0  ( { R_VS_HZ[6],R_VS_HZ[4],R_VS_HZ[2],R_VS_HZ[0] }  ) ,
        .probe1  ( { R_PROC_VS_HZ[6],R_PROC_VS_HZ[4],R_PROC_VS_HZ[2],R_PROC_VS_HZ[0] } ) ,
        .probe2  ( { R_MIPI_VS_I_HZ[6],R_MIPI_VS_I_HZ[4],R_MIPI_VS_I_HZ[2],R_MIPI_VS_I_HZ[0] } ) ,
        .probe3  ( read_finish_axi_to_cpu ) ,
        .probe4  ( write_req_cpu_to_axi  ) ,
        .probe5  ( read_req_cpu_to_axi   ) ,
        .probe6  (VS_I_axi) ,
        .probe7  (VS_O_axi) ,
        .probe8  (PROC_VS_I_axi) ,
        .probe9  (MIPI_VS_I_axi) 

    
    );

end
endgenerate
    
    
endmodule
