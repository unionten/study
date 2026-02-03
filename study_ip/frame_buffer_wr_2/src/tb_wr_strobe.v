`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/29 13:31:41
// Design Name: 
// Module Name: tb_wr_strobe
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


module tb_wr_strobe(

    );
reg de;
reg clk;
    
strobe_station_unify 
    #(.C_BYTE_NUM( 8 ))
    strobe_station_u(
    .RST_I       (0),
    .CLK_I       (clk),
    .DATA_I      (64'h8888444488776655),
    .DATA_EN_I   (de),  //note： BYTE_NUM_I = 0, represents C_BYTE_NUM
    .BYTE_NUM_I  (8),  //natual num ; for example  1  2  3  4(0) when C_BYTE_NUM is 4 
    .DATA_O      (  ),
    .DATA_EN_O   (  )
    ); 
    
 always #10 clk = ~clk;

initial begin
    clk = 0;
    de =0;
    #200;
    
    de=1;
    

end 
    
endmodule
