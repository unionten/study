`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/19 14:07:55
// Design Name: 
// Module Name: tb_delay_reg
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


module tb_delay_reg(

    );

parameter  WIDTH = 8;
parameter  LEN = 3;   
    
reg clk;
always #10 clk = ~clk;    
reg  rst; 
reg   [WIDTH-1:0] in;
wire  [WIDTH-1:0] out;

delay_reg_unify 
    #(.WIDTH(WIDTH),
      .LEN(LEN))
uut(
.RST_I(rst),
.CLK_I(clk),
.IN_I (in),
.OUT_O(out)
);

initial begin
    clk = 0;
    rst = 0;
    #203;
    in = 200;
    #20;
    in = 255;
    #20;
    in = 245;
    #200;
    
    rst = 1;
    #20;
    rst = 0;
    
    #200;
    $stop;
end


endmodule
