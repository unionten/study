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


wire [MAX_BPC-1:0] R_I  ;
wire [MAX_BPC-1:0] G_I  ;
wire [MAX_BPC-1:0] B_I  ;
assign R_I = 255;//1023 255;
assign G_I = 0; //220  55; 
assign B_I = 0; //308  77; 



wire [MAX_BPC-1:0] y_i ;
wire [MAX_BPC-1:0] u_i ;
wire [MAX_BPC-1:0] v_i ;


wire [MAX_BPC-1:0] r_oz ;
wire [MAX_BPC-1:0] g_oz ;
wire [MAX_BPC-1:0] b_oz ;

wire [MAX_BPC-1:0] r_oz_uni ;
wire [MAX_BPC-1:0] g_oz_uni ;
wire [MAX_BPC-1:0] b_oz_uni ;


wire [MAX_BPC-1:0] r_ol ;
wire [MAX_BPC-1:0] g_ol ;
wire [MAX_BPC-1:0] b_ol ;



//assign y_i = 50;
//assign u_i = 50;
//assign v_i = 50 ;
//
 
 rgb2yuv   
    #(.C_BPC(MAX_BPC))
    rgb2yuv_u( 
    .RST_I (0),
    .CLK_I (clk),       
    .R_I   (R_I ),
    .G_I   (G_I ),
    .B_I   (B_I ),
    .Y_O   (y_i),
    .U_O   (u_i),
    .V_O   (v_i)

    );

// yuv2rgb_unify
//    #(.C_BPC(MAX_BPC))
// yuv2rgbzu_u(
//.RST_I (0),
//.CLK_I (clk), 
//.Y_I   (y_i),
//.U_I   (u_i),
//.V_I   (v_i),
//.R_O   (r_oz_uni  ),
//.G_O   (g_oz_uni  ),
//.B_O   (b_oz_uni  )
//    );

 
 
 yuv2rgb 
    #(.C_BPC(MAX_BPC))
 yuv2rgbz_u(
.RST_I (0),
.CLK_I (clk), 
.Y_I   (y_i),
.U_I   (u_i),
.V_I   (v_i),
.R_O   (r_oz  ),
.G_O   (g_oz  ),
.B_O   (b_oz  )
    );


    
    
//yuv_rgb yuv_rgbl(
//	.vid_clk (clk),
//	.vid_rst (0),
//	.RGB_Y   ({4{y_i}}),
//	.RGB_U   ({4{u_i}}),
//	.RGB_V   ({4{v_i}}),
//	.R       (r_ol ),
//	.G       (g_ol ),
//	.B       (b_ol ),
//	.data_rgb()
//);
//    
    
    
    
    
    
    
endmodule
