`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/28 17:42:20
// Design Name: 
// Module Name: tb_check_constant
// Project Name: 
// Target Devices: 
//////////////////////////////////////////////////////////////////////////////////

module tb_check_constant(

    );
    
reg clk;
reg rst;
reg [1:0] d;  

wire [1:0] ALWAYS_1_O;
wire [1:0] ALWAYS_0_O;


always #5 clk = ~clk;

 initial begin
 d = 0;
 clk = 0;
 rst = 1;
 #500;
 rst = 0;
 #500;
 
 d = 1;
 #380;
 d = 0;
 #200;
 d = 3;
 #500;
d = 2;
  #500;
  d = 3;
  #500;
 d = 0;
  #500; 
  
  d = 1;
  #500;
  
 
 end
  
check_constant 
#(.THRESHOLD (32) ,
  .WIDTH     (2) ,
  .CHECK_STABLE_HIGH_EN (1),
  .CHECK_STABLE_LOW_EN  (1)
  )

    check_constant_u(
   .CLK_I         (clk),
   .RST_I         (rst),
   .D_I           (d),
   .IS_ALWAYS_1_O (ALWAYS_1_O),
   .IS_ALWAYS_0_O (ALWAYS_0_O)
    );

    



    
endmodule
