`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/02 13:07:48
// Design Name: 
// Module Name: tb_xpll
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////


module tb_xpll(

    );

reg clk200 ;
wire clkfast;
wire clkdiv ;
wire clklocked;

       
xpll  xpll_u(
    .PLL_CLK_IN      (clk200),
    .PLL_CLK_OUT     (clkfast),
    .PLL_CLK_DIV     (clkdiv),
    .PLL_CLK_LOCKED  (clklocked)

    );


always #2.5 clk200 = ~clk200;
initial begin
    clk200 = 0;
    


end

    
    
endmodule
