`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/11 18:08:05
// Design Name: 
// Module Name: tb_rgb_analyze
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


module tb_rgb_analyze(

    );

reg clk = 0;

always #10 clk = ~clk ;
reg [50:0] b = 0;


wire [31:0] RAM_DATA_O ;
wire [15:0] RAM_ADDR_O ;
wire RAM_WR_O   ;
wire [31:0] FIFO_CRC_O ;
wire FIFO_WR_O ; 



reg timer;

tpg ttt(
.PIXEL_CLK_I (clk),   //像素时钟
.RESETN_I    (1),   //复位时输出钳制为0,释放复位后自动从头启动
.VS_O        (vs),   //输出-时序(正极性)             
.HS_O        (hs),   //输出-时序(正极性)
.DE_O        (de),   //输出-时序(正极性)
.VS_ALLIGN_I (0)  ,   //内部检测上沿,然后从头启动
.DE_VALID_I  (0)     //电平信号,DE_O等待DE_VALID_I拉高后才启动

);  
   reg [31:0] rr; 
   reg [31:0] gg; 
   reg [31:0] bb; 
   
rgb_analyze #( 
    .MAX_PORT_NUM       (4 ), 
    .MAX_BPC            (8 ),//6 8 10 12
    .CRC_BLOCK_EN       (1 ),
    .RAM_UPDATE_REG_NUM (64),
    .PURE_CHECK_MODE    (1)
    )
    uut
    (      
    .CLK_I      (clk),
    .RST_I      (0),   
    .TIMER_I    (timer), //check pos inside
    .PORT_NUM_I (2), //1 2 4 8 , other will transfer to  4      
    .BPC_I      (8),  
    .RH_I       (200),
    .RL_I       (30),
    .GH_I       (200),
    .GL_I       (30),
    .BH_I       (200),
    .BL_I       (30),
    .DE_I       (de),
    .HS_I       (hs),
    .VS_I       (vs), 
    .R_I        (rr),
    .G_I        (gg),
    .B_I        (bb),  
    .RAM_DATA_O (RAM_DATA_O ),
    .RAM_ADDR_O (RAM_ADDR_O ),//addr = 0 , 1, 2 , ...
    .RAM_WR_O   (RAM_WR_O   ),
    .FIFO_CRC_O (FIFO_CRC_O ),
    .FIFO_WR_O  (FIFO_WR_O  ) ,
    .EXCLUDE_PT_NUM_I (71981)
    
    );


initial begin
rr= 32'hffffffff;
gg = 0;
bb = 0;
#372591;
gg =  32'hffffffff;
rr= 32'h00000000;
#200;
rr= 32'hffffffff;
gg = 0;

end

initial begin
    



end







  
 
initial begin
     b= 0;
    timer = 0;
    #50001;
    timer = 1;
    #20;
    timer = 0;
    
    #280000;
    
    b = 666;
    
    #500000;
    timer = 1;
    #20;
    timer = 0;
    
    #200000;
    b = 666;
	#200;
	
	
	timer = 1;
    #20;
    timer = 0;
	
	
    
    
end   
    
endmodule
