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


module spilt
#( parameter C_IN_WIDTH = 32 , 
   parameter C_UNIT_WIDTH = 8 )
(
input   [C_IN_WIDTH-1:0] in    ,
output   [C_UNIT_WIDTH-1:0]     out0  , 
output   [C_UNIT_WIDTH-1:0]     out1  ,
output   [C_UNIT_WIDTH-1:0]     out2  ,
output   [C_UNIT_WIDTH-1:0]     out3  ,
output   [C_UNIT_WIDTH-1:0]     out4  ,
output   [C_UNIT_WIDTH-1:0]     out5  ,
output   [C_UNIT_WIDTH-1:0]     out6  ,
output   [C_UNIT_WIDTH-1:0]     out7  , 
output   [C_UNIT_WIDTH-1:0]     out8  ,
output   [C_UNIT_WIDTH-1:0]     out9  ,
output   [C_UNIT_WIDTH-1:0]     out10 ,
output   [C_UNIT_WIDTH-1:0]     out11 ,
output   [C_UNIT_WIDTH-1:0]     out12 ,
output   [C_UNIT_WIDTH-1:0]     out13 ,
output   [C_UNIT_WIDTH-1:0]     out14 ,
output   [C_UNIT_WIDTH-1:0]     out15


);

    
generate if( (C_UNIT_WIDTH*( 0 +1)) <= C_IN_WIDTH ) begin
    assign  out0    = in[C_UNIT_WIDTH*0+:C_UNIT_WIDTH];
end
endgenerate

generate if( (C_UNIT_WIDTH*( 1 +1)) <= C_IN_WIDTH ) begin
    assign  out1    = in[C_UNIT_WIDTH*1+:C_UNIT_WIDTH];
end
endgenerate

generate if( (C_UNIT_WIDTH*( 2 +1)) <= C_IN_WIDTH ) begin
    assign  out2    = in[C_UNIT_WIDTH*2+:C_UNIT_WIDTH];
end
endgenerate

generate if( (C_UNIT_WIDTH*( 3 +1)) <= C_IN_WIDTH ) begin
    assign  out3    = in[C_UNIT_WIDTH*3+:C_UNIT_WIDTH];
end
endgenerate
generate if( (C_UNIT_WIDTH*( 4 +1)) <= C_IN_WIDTH ) begin
    assign  out4    = in[C_UNIT_WIDTH*4+:C_UNIT_WIDTH];
end
endgenerate
generate if( (C_UNIT_WIDTH*( 5 +1)) <= C_IN_WIDTH ) begin
    assign  out5    = in[C_UNIT_WIDTH*5+:C_UNIT_WIDTH];
end
endgenerate

generate if( (C_UNIT_WIDTH*( 6 +1)) <= C_IN_WIDTH ) begin
    assign  out6    = in[C_UNIT_WIDTH*6+:C_UNIT_WIDTH];
end
endgenerate
generate if( (C_UNIT_WIDTH*( 7 +1)) <= C_IN_WIDTH ) begin
    assign  out7    = in[C_UNIT_WIDTH*7+:C_UNIT_WIDTH];
end
endgenerate
    
generate if( (C_UNIT_WIDTH*( 8 +1)) <= C_IN_WIDTH ) begin
    assign  out8    = in[C_UNIT_WIDTH*8+:C_UNIT_WIDTH];
end
  endgenerate
    
generate if( (C_UNIT_WIDTH*( 9 +1)) <= C_IN_WIDTH ) begin
    assign  out9    = in[C_UNIT_WIDTH*9+:C_UNIT_WIDTH];
end
endgenerate

generate if( (C_UNIT_WIDTH*( 10 +1)) <= C_IN_WIDTH ) begin
    assign  out10    = in[C_UNIT_WIDTH*10+:C_UNIT_WIDTH];
end
endgenerate
generate if( (C_UNIT_WIDTH*( 11 +1)) <= C_IN_WIDTH ) begin
    assign  out11    = in[C_UNIT_WIDTH*11+:C_UNIT_WIDTH];
end
endgenerate
generate if( (C_UNIT_WIDTH*( 12 +1)) <= C_IN_WIDTH ) begin
    assign  out12    = in[C_UNIT_WIDTH*12+:C_UNIT_WIDTH];
end
endgenerate
generate if( (C_UNIT_WIDTH*( 13 +1)) <= C_IN_WIDTH ) begin
    assign  out13    = in[C_UNIT_WIDTH*13+:C_UNIT_WIDTH];
end
  endgenerate
generate if( (C_UNIT_WIDTH*( 14 +1)) <= C_IN_WIDTH ) begin
    assign  out14    = in[C_UNIT_WIDTH*14+:C_UNIT_WIDTH];
end
endgenerate

generate if( (C_UNIT_WIDTH*( 15 +1)) <= C_IN_WIDTH ) begin
    assign  out15    = in[C_UNIT_WIDTH*15+:C_UNIT_WIDTH];
end
endgenerate

 
    
endmodule
