`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/12 20:47:44
// Design Name: 
// Module Name: tb_rd_station
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


module tb_rd_station(

    );

reg clk;
reg rst;
reg de;
 reg vs;
  
wire [31:0] FIFO_DATA_O;
reg  [31:0] FIFO_DATA_I;
  
rd_station  
    #(.DLY(1))
uut(
.CLK_I              (clk),
.RST_I              (rst),
.HS_I               (0),
.VS_I               (vs),
.DE_I               (de), // desided by TPG
.BYTE_NUM_I         (1), //1:1byte  ... 0:C_FIFO_IN_WIDTH/8 byte ; pull speed from fifo
.FIFO_DATA_VALID_O  (valid),   
.FIFO_DATA_O        (FIFO_DATA_O),
.RD_O               (rd),
.FIFO_DATA_I        (32'h44332211));
   
    
always #5 clk = ~clk;
  

always #2 FIFO_DATA_I = FIFO_DATA_I + 1;


initial begin
FIFO_DATA_I = 45335346;
    vs = 0;
    de = 0;
    clk = 0;
    rst = 1;
    #500;
    rst = 0;
    #2000;
    vs = 1;
    #500;
    vs = 0; 
    #2096;
    de = 1;

    
    
   

end    
    
    
endmodule
