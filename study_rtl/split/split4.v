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


module spilt4(
input   [3:0] in    ,
output         out0  , 
output         out1  , 
output         out2  , 
output         out3    


);
    
    
    
assign  out0   = in[0    ];
assign  out1   = in[1    ];
assign  out2   = in[2    ];
assign  out3   = in[3    ];

    
    
    
    
    
    
endmodule
