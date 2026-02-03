`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/04 08:46:29
// Design Name: 
// Module Name: tb_yuv2rgb
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


module tb_yuv2rgb(

    );

parameter MAX_BPC  = 8;

reg clk;

always #10 clk = ~clk;

initial begin
    clk = 0;

end

wire [MAX_BPC-1:0] y_i ;
wire [MAX_BPC-1:0] u_i ;
wire [MAX_BPC-1:0] v_i ;


wire [MAX_BPC-1:0] r_o ;
wire [MAX_BPC-1:0] g_o ;
wire [MAX_BPC-1:0] b_o ;



assign y_i = 50;
assign u_i = 50;
assign v_i = 50 ;

 
 yuv2rgb 
    #(.C_BPC(MAX_BPC))
 uut(
.RST_I (0),
.CLK_I (clk), 
.Y_I   (y_i),
.U_I   (u_i),
.V_I   (v_i),
.R_O   (r_o  ),
.G_O   (g_o  ),
.B_O   (b_o  )
    );


    
    
    
    
endmodule
