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


module split40to4x10(
input   [39:0] in    ,
output  [9:0]  out0  , 
output  [9:0]   out1  , 
output  [9:0]  out2  , 
output  [9:0]   out3   
 


);
    
    
    
assign  out0   = in[0*10+:10 ];
assign  out1   = in[1*10+:10 ];
assign  out2   = in[2*10+:10 ];
assign  out3   = in[3*10+:10 ];

    
    
    
    
    
endmodule
