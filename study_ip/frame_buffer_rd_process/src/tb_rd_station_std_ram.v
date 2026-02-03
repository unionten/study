`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/18 08:43:03
// Design Name: 
// Module Name: tb_rd_station_std_ram
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


module tb_rd_station_std_ram(

    );
    
    

reg clk;
reg rst;
reg de;
 reg vs;
  
wire [31:0] FIFO_DATA_O;
reg  [31:0] FIFO_DATA_I;
  
rd_station_std_ram  
    #(.C_BYTE_NUM(4))
uut(
.CLK_I              (clk),
.RST_I              (rst),
.VS_I               (vs),
.DE_I               (de), // desided by TPG
.BYTES_I            (4), //1:1byte  ... 0:C_FIFO_IN_WIDTH/8 byte ; pull speed from fifo
.DE_O               (valid),   
.DATA_O             (FIFO_DATA_O),
.RD_O               (rd),
.DATA_I             (FIFO_DATA_I));
   
    
always #5 clk = ~clk;
  

//always #2 FIFO_DATA_I = FIFO_DATA_I + 1;


initial begin

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
    #10000;
    de = 0;
    
    #5000;
    de = 1;
    #1000;
    de= 0;
    
    #1000;
    vs = 1;
    #1000;
    vs= 0;
    #2000;
    
    de = 1;
    #6000;
    de = 0;
    
    
   

end    
    
initial begin
FIFO_DATA_I =0;
#5102;
FIFO_DATA_I = 32'h44332211;
#10;
FIFO_DATA_I = 32'hddccbbaa;
#9000;
FIFO_DATA_I = 32'hddccbbaa;





end  
    
    
    
    
endmodule
