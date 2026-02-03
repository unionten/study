`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/14 11:41:44
// Design Name: 
// Module Name: tb_reconcat_rd
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


module tb_reconcat_rd(

    );

reg clk;
reg rst;
reg vs;

 wire [16*3*2-1:0]PIXEL_DATA_O;

reconcat_rd 
    #(.C_MAX_PORT_NUM(2),
      .C_DDR_PIXEL_MAX_BYTE_NUM(8),
      .C_MAX_BPC(16))
reconcat_rd_u  
(
.CLK_I                 (clk),
.RST_I                 (rst),
.PIXEL_VS_I            (vs),
.PIXEL_HS_I            (0),
.PIXEL_DE_I            (0),
.PIXEL_DATA_I          ({8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hdd,8'hcc,8'hbb,8'haa,    
                          8'h55,8'h44,8'h33,8'h22,8'h11  
    }),// [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0] 像素紧凑
.ACTUAL_DDR_BYTE_NUM_I (5),// [7:0]  mean how to analyze PIXEL_DATA_I
.TARGET_BPC_I          (8),// [3:0] mean how to analyze PIXEL_DATA_I
.PIXEL_VS_O            (vs_o),
.PIXEL_HS_O            (hs_o),
.PIXEL_DE_O            (de_o),
.PIXEL_DATA_O          (PIXEL_DATA_O)// [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0] {R G B } or  {0 U Y } or {U Y Y}/{V Y Y}

);

always #5 clk = ~clk;

initial begin
    vs = 0;
    clk = 0;
    rst = 1;
    #500;
    rst = 0;
    #400;
    
    vs = 1;
    
    


end
    
    
endmodule
