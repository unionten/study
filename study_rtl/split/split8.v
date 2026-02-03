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


module split8(
input   [7:0] in    ,
output         out0  , 
output         out1  , 
output         out2  , 
output         out3  ,
output         out4  ,
output         out5  ,
output         out6  ,
output         out7  

   


);
    
    
    
assign  out0   = in[0    ];
assign  out1   = in[1    ];
assign  out2   = in[2    ];
assign  out3   = in[3    ];
assign  out4   = in[4    ];
assign  out5   = in[5    ];
assign  out6   = in[6    ];
assign  out7   = in[7    ];
    
    
    
    
    
    
endmodule
