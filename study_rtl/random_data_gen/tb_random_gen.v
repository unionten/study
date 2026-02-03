`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/03 09:15:03
// Design Name: 
// Module Name: tb_random_gen
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


module tb_random_gen(

    );
    
reg clk;
always #5 clk = ~clk ;

initial begin
    clk = 0;

end  
    
    
random_gen  
#(.WIDTH(2))

random_gen_u
(
    .clk(clk),
    .reset(0),
    .random_data()
);
    
    
    
    
endmodule
