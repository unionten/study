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


module spilt2(
input   [1:0] in    ,
output         out0  , 
output         out1  


);
    
    
    
assign  out0   = in[0    ];
assign  out1   = in[1    ];


    
    
    
    
    
    
endmodule
