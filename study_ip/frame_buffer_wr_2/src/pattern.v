`timescale 1ns / 1ps
`define DELAY_OUTGEN(clk,rst,data_in,data_out,DATA_WIDTH,DLY)                                           generate if(DLY==0)begin  assign data_out = data_in; end  else if(DLY==1)begin  reg [DATA_WIDTH-1:0] a_temp = 0; always@(posedge clk) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [DATA_WIDTH-1:0] a_temp [DLY-1:0] ;always@(posedge clk) begin  if(rst)a_temp[DLY-1] <= 0; else   a_temp[DLY-1] <= data_in; end  for(i=0;i<=DLY-2;i=i+1)begin  always@(posedge clk)begin  if(rst)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  endgenerate

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/25 17:00:11
// Design Name: 
// Module Name: pattern
//////////////////////////////////////////////////////////////////////////////////
//输出像素 每一行 都以rgbrgb循环排布，每一行开头都从r开始 
//exp:
//output  ____|——————————|______|——————————|_________
//             R G B R G         R G B R G
//        ____|——————————|______|——————————|_________
//             G B R G B         G B R G B
//        ____|——————————|______|——————————|_________
//             B R G B R         B R G B R
//        ____|——————————|______|——————————|_________
//             R G B R G         R G B R G

module pattern(
input CLK_I,
input RST_I,
input VS_I,
input HS_I,
input DE_I,
output [C_PORT_NUM-1:0]   VS_O,
output [C_PORT_NUM-1:0]   HS_O,
output [C_PORT_NUM-1:0]   DE_O,
output [C_PORT_NUM*8-1:0] R_O ,
output [C_PORT_NUM*8-1:0] G_O ,
output [C_PORT_NUM*8-1:0] B_O

);
parameter C_PORT_NUM = 4;


wire [7:0] r;
wire [7:0] g;
wire [7:0] b;


reg [7:0] cnt = 0;
always@(posedge CLK_I)begin
    if(RST_I | HS_I | VS_I)begin
        cnt <= 0;
    end
    else if(DE_I)begin
        cnt <= cnt==2 ? 0 : cnt + 1;
    end
end

assign r = cnt==0 ? 255 : 0;
assign g = cnt==1 ? 255 : 0;
assign b = cnt==2 ? 255 : 0;


assign VS_O = {C_PORT_NUM{VS_I}};
assign HS_O = {C_PORT_NUM{HS_I}}; 
assign DE_O = {C_PORT_NUM{DE_I}}; 

assign R_O = {C_PORT_NUM{r}};
assign G_O = {C_PORT_NUM{g}};
assign B_O = {C_PORT_NUM{b}};
    
    
endmodule




