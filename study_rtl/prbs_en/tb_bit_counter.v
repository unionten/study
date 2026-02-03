`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/29 10:47:19
// Design Name: 
// Module Name: tb_bit_counter
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


module tb_bit_counter(

    );

parameter C_WIDTH = 80;
   
wire [$clog2(80):0] result ;
reg [C_WIDTH-1:0] din;
  
bit_counter  
#(.WIDTH(C_WIDTH))
bit_counter_u(
.DATA_I    (din),
.RESULT_O  (result)

);

initial begin
din = 100'b0000101010101111;

#200;
din = 100'b1000101010101111;

#200;
din = 100'b1100101010101111;

#200;
din = 100'b0;



end





endmodule
