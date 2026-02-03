`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/08 10:14:27
// Design Name: 
// Module Name: tb_osd
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


module tb_osd(

    );
reg clk;
reg rst;

reg [15:0] WADDR;
reg [31:0 ]WDATA;
reg WREQ ;



always #10 clk = ~clk ;



tpg ttt(
.PIXEL_CLK_I (clk),   //像素时钟
.RESET_I     (rst),   //复位时输出钳制为0,释放复位后自动从头启动
.VS_ALLIGN_I (0),   //内部检测上沿,然后从头启动
.DE_VALID_I  (0),   //电平信号,DE_O等待DE_VALID_I拉高后才启动

.HSYNC_I   (10),   //参数 [15:0] 
.HBP_I     (10),   //参数 [15:0] 
.HACTIVE_I (200),   //参数 [15:0]
.HFP_I     (10),   //参数 [15:0] 
.VSYNC_I   (10),   //参数 [15:0]
.VBP_I     (10),   //参数 [15:0]
.VACTIVE_I (200),   //参数 [15:0] 
.VFP_I     (10),   //参数 [15:0] 
     
.HS_O     (hs),   //输出-时序(正极性)
.VS_O     (vs),   //输出-时序(正极性)
.DE_O     (de),   //输出-时序(正极性)
.VS_ALLIGN_EN_I  (0)   ,   //是否开启VS对齐功能
.DE_ALLIGN_EN_I  (0)       //是否开启DE对齐功能
);


osd uut(  
.VID_CLK_I(clk),
.VID_RST_I(0),
.VS_I(vs),
.HS_I(hs),
.DE_I(de),
.R_I(12),
.G_I(12),
.B_I(12),
.VS_O(),
.HS_O(),
.DE_O(),
.R_O(),
.G_O(),
.B_O(),
//
.OSD_AXI_CLK_I(clk),//mostly AXI CLK
.OSD_AXI_RST_I(0), 
.OSD_ENABLE_I(1),
.OSD_TRANSPARENT_I(0),
.OSD_PORTS_I(2), // also actual valid input port num
.OSD_X_I(0),//from 0
.OSD_Y_I(0),//from 0
.OSD_H_I(64),
.OSD_V_I(64),
.OSD_WADDR_I (WADDR),
.OSD_WDATA_I (WDATA),
.OSD_WREQ_I  (WREQ )
 
    );

initial begin
    clk = 0;
    rst = 1;
    #201;
    WADDR = 0;
    WDATA = 32'h11001100;
    WREQ  = 1;
    #20;
    repeat (2000) begin
    WADDR = WADDR + 1;
    WDATA = WDATA + 32'h00010001;
    #20;
    end
    WREQ  = 0;
    
    #1000;
    rst = 0;

end





 
    
endmodule
