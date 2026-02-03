`timescale 1ns / 1ps
`define DELAY_OUTGEN(clk,rst,data_in,data_out,DATA_WIDTH,DLY)                                           generate if(DLY==0)begin  assign data_out = data_in; end  else if(DLY==1)begin  (*keep="true"*)reg [DATA_WIDTH-1:0] a_temp = 0; always@(posedge clk) a_temp <= data_in; assign data_out = a_temp ; end  else begin  (*keep="true"*) reg [DATA_WIDTH-1:0] a_temp [DLY-1:0] ;always@(posedge clk) begin  if(rst)a_temp[DLY-1] <= 0; else   a_temp[DLY-1] <= data_in; end  for(i=0;i<=DLY-2;i=i+1)begin  always@(posedge clk)begin  if(rst)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  endgenerate

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/05 14:46:36
// 
//////////////////////////////////////////////////////////////////////////////////


module mux2_iot(
input    SEL_I   ,

input    T_I_0   ,
input    O_I_0   ,
output   I_O_0   ,

input    T_I_1   ,
input    O_I_1   ,
output   I_O_1   ,

output   T_O  ,
output   O_O  ,
input    I_I

    );
    
assign  T_O = (SEL_I==0) ? T_I_0 : T_I_1 ;
assign  O_O = (SEL_I==0) ? O_I_0 : O_I_1 ;
assign  I_O_0 =  (SEL_I==0) ? I_I : 1 ;
assign  I_O_1 =  (SEL_I==1) ? I_I : 1 ;



    
 

    
    
endmodule
