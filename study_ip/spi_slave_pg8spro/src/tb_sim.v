`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/17 19:39:52
// Design Name: 
// Module Name: tb_sim
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


module tb_sim(

    );
    


reg  clk =0;
reg  rst =0;
reg start = 0;

wire SPI_CS_O   ;
wire SPI_SCK_O  ;
wire SPI_DO_O   ;

reg [31:0] LB_WDATA =0;
reg LB_WREQ = 0;

always  #10 clk = ~clk ;



initial begin
    clk = 0;
    rst = 1;
    start = 0;
    #400;
    rst = 0;
    #2001;
    LB_WDATA = 32'h04030201; 
    LB_WREQ   = 1;
    #20;
    LB_WREQ   = 0;
    #200;
    LB_WREQ   = 1;
    LB_WDATA = 32'h08070605; 
    #20;
    LB_WREQ = 0;
    
    
    #4000;
    
    
    start = 1 ;
    #21;
    start = 0 ;



end

  
//正常指令 下发  800'h2330343035303030303038303031313030303030303030303030303030343434342f   34
//正常指令  回读 800'h2330343035303030313038303031313030303030303030303030303030343434342f   34

//获取中断状态 下发  800'h23303430313030303030303030343434342f   18
//获取中断状态 获取  800'h233034303130303031303430303030303030303030343434342f      26
//获取中断状态 获取  800'h233034303130303031303430303030303030303030343434342f      26

    
spi_write_freqdiv_tri  
#(  . MAX_BYTE_NUM         ( 100   ),  //must >= 1
    . CLK_PERIOD_NS        ( 100   ),  //must >= 0
    . CSLOW_TO_CLKBEGIN_NS ( 10000 ),  //must >= 0
    . CLKEND_TO_CSHIGH_NS  ( 10000 ),  //must >= 0
    . CSHIGH_TO_BUSYLOW_NS ( 10000 )   //must >= 0
)

spi_write_freqdiv_tri_u
( 
.RST_I            (rst),//[0:0]    ###  同步高复位                                            ###                                                      
.CLK_I            (clk),//[0:0]    ###  时钟                                                  ###         
.CMD_I            (0),//[2:0]    ###  模式 0:【单次写】;1:【自动连续写】;2:【外部连续写】   ###     
.PDATA_I          (800'h233034303130303031303430303030303030303030343434342f),//参数决定 ###  从右往左DATA_BYTE_NUM_I个字节有效,有效部分先发高字节  ###                                                     
.DATA_BYTE_NUM_I  (26),//[7:0]    ###  有参数保护;外部连续写时,该值每轮都有效                ###   1 <= VALUE <=255                             
.ROUND_NUM_I      (1),//[15:0]   ###  有参数保护;仅用于【自动连续写】                       ###   1 <= VALUE <=65535                           
.START_I          (start),//[0:0]    ###  触发模块;内部会检测上沿                               ###                                                      
.BUSY_O           (),//[0:0]    ###  模块忙信号                                            ###
.SPI_CS_O         (SPI_CS_O   ),//[0:0]    ###  SPI接口信号                                           ###
.SPI_SCK_O        (SPI_SCK_O  ),//[0:0]    ###  SPI接口信号                                           ###
.SPI_DO_O         (SPI_DO_O   ),//[0:0]    ###  SPI接口信号                                           ###
.DIV              (10),//[9:0]    ###  SPI_SCK相对于CLK_I的分频值; 按需赋常数即可            ###   2 <= VALUE <=1023                            
.POL              (0),//[0:0]    ###  SPI模式选择位; 按需赋常数即可                         ###   0或1
.PHA              (1) //[0:0]    ###  SPI模式选择位; 按需赋常数即可                         ###   0或1
 
);
    
    
//23  3034  30353030  3030  30383030  30303030303030303030303030303030  34343434   2f
//23  04    0500      00    0800      0000000000000000                  4444       2f  
    
spi_slave_pg8s_pro   

spi_slave_pg8s_pro_u(
 
. S_AXI_ACLK   (clk) ,
 .M_AXI_ACLK   (clk),
. M_AXI_ARESETN(~rst),
 .S_AXI_ARESETN(~rst),
 
 
 
. LB_WADDR    (16'h001c) ,
. LB_WDATA    (LB_WDATA  ),
. LB_WREQ     (LB_WREQ   ),
. LB_WSTRB    (32'hffffffff), 
. LB_RADDR    (0),
. LB_RREQ     (0),
. LB_RDATA    (),
. LB_RFINISH  (),


.SPI_SCK_I    (SPI_SCK_O  ),
.SPI_CS_I     (SPI_CS_O ),
.SPI_SDO_I    (SPI_DO_O  ),
.SPI_SDI_O    (),

.INTERRUPT_O  ()



    );
    
 
   
    
    
    
endmodule
