`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/03 10:02:11
// Design Name: 
// Module Name: tb_random_clk_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 

//////////////////////////////////////////////////////////////////////////////////


module tb_random_clk_gen(

    );
  reg clk = 0;  
always #5 clk = ~clk;
 
    
    
random_phase_clk_gen   
#(.DIV_NUM(4))
    random_phase_clk_gen_u
    (
    .CLK_I(clk ),
    .RST_I(0   ),
    .RAN_PHA_CLK_O (RAN_PHA_CLK_O)
);








    
endmodule




