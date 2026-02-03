`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/25 19:15:06
// Design Name: 
// Module Name: update
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




module update_en(
input clk ,
input rstn,
input  in1,
input  in1_en,
input  in2,
input  in2_en,
output reg out1 = 0

);
    
always@(posedge clk)begin
    if(~rstn)begin
        out1 <= 0;
    end
    else begin
        out1 <= in1_en ? in1 : in2_en ? in2 : out1 ;
    end
end
    
    
    
    
    
endmodule
