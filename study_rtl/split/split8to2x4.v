`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/19 14:14:22
// Design Name: 
// Module Name: spilt
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


module split8to2x4(
input   [7:0] in    ,
output  [3:0] out0  , 
output   [3:0] out1   



);
    
    
    
assign  out0   = in[3:0];
assign  out1   = in[7:4];

    
 
    
    
endmodule
