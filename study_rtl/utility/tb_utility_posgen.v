`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/01 15:08:26
// Design Name: 
// Module Name: tb_test2
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


module tb_utility_posgen(

    );
    
reg clk ;
reg rst ;
reg in ;

wire out ;

always #5 clk = ~clk ;



initial begin
    clk = 0;
    rst = 1;
    in = 1 ;
    #200;
    rst = 0;
    #2000;
    in = 0;
    #200;
    in = 1 ;
    
    
    

end 
    
    
    
    
 test2  uu(
.    clk     ( clk   )  ,
.    rst     ( rst   )  ,
.    in      ( in    )  ,
.     out    (  out  )





    );
        
    
endmodule
