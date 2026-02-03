`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/12 14:20:01
// Design Name: 
// Module Name: tb_num2strb
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


module tb_num2strb(

    );
  
parameter C_STRB_BIT_NUM = 32;
  
  
reg [31:0] num;
wire [C_STRB_BIT_NUM-1:0] strb;
  
num2strb 
#(.C_STRB_BIT_NUM(C_STRB_BIT_NUM))
num2strb(
.NUM_I  (num),
.STRB_O (strb)

);
    

initial begin
num = 0;
#500;
num = 1;

#500;
num = 31;

#500;
num = 32;

#500;
num = 4;
#500;

end
    
  
    
endmodule
