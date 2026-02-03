`timescale 1ns / 1ps
`define DELAY_OUTGEN(clk,rst,data_in,data_out,DATA_WIDTH,DLY)                                           generate if(DLY==0)begin  assign data_out = data_in; end  else if(DLY==1)begin  (*keep="true"*)reg [DATA_WIDTH-1:0] a_temp = 0; always@(posedge clk) a_temp <= data_in; assign data_out = a_temp ; end  else begin  (*keep="true"*) reg [DATA_WIDTH-1:0] a_temp [DLY-1:0] ;always@(posedge clk) begin  if(rst)a_temp[DLY-1] <= 0; else   a_temp[DLY-1] <= data_in; end  for(i=0;i<=DLY-2;i=i+1)begin  always@(posedge clk)begin  if(rst)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  endgenerate

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/05 14:46:36
// Design Name: 
// Module Name: blank_running
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


module blank_running(
input                     CLK_I   ,
input                     RSTN_I  ,
input  [C_BIT_WIDTH-1:0]  DIN_I   ,
output [C_BIT_WIDTH-1:0]  DOUT_O

    );
    
parameter C_BIT_WIDTH = 20 ;
parameter C_FILP_NUM  = 2000;   

genvar i,j,k;

    
`DELAY_OUTGEN(CLK_I,(~RSTN_I),DIN_I,DOUT_O,C_BIT_WIDTH,C_FILP_NUM)  
    
    
endmodule
