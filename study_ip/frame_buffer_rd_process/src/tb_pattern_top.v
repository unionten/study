`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/06 20:44:22
// Design Name: 
// Module Name: tb_pattern_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 

//////////////////////////////////////////////////////////////////////////////////


module tb_pattern_top(

    );
    
reg clk ;
reg rst ;


wire [3:0] o_VS   ;       
wire [3:0] o_HS   ;    
wire [3:0] o_DE   ;    
wire [31:0] o_RGB_R  ;  
wire [31:0] o_RGB_G  ;  
wire [31:0] o_RGB_B ;   




always #2 clk = ~clk;

initial begin
    clk = 0 ;
    rst = 1 ;  
    #2000;
    
    rst = 0;
    #2000;
    
    
    



end

wire  [15:0] ACTIVE_X;
wire  [15:0] ACTIVE_Y;

pattern_gen_core #(.C_PORT_NUM (4))
    pattern_gen_core (  
    .CLK_I               ( clk ),
    .RST_I               ( rst  ),
    .PORT_NUM_I          ( 4 ), //[2:0] 
    .PATSEL_I            ( 18 ), // [7:0] 
    .HACTIVE_I           ( 3840 ),  
    .HFP_I               ( 20 ),  
    .HSYNC_I             ( 20 ), 
    .HBP_I               ( 20 ),           
    .VACTIVE_I           ( 2160 ), 
    .VFP_I               ( 20 ),        
    .VSYNC_I             ( 20 ), 
    .VBP_I               ( 20 ), 
    .CYCLE_VAL_I         ( 1  ), //[31:0] 
    .UART_R_I            ( 0 ), //[7:0] input
    .UART_G_I            ( 0 ), //[7:0] input
    .UART_B_I            ( 0 ), //[7:0] input   
    .VS_O                (o_VS         ),  //[PIXELS_PER_CLOCK-1:0] 
    .HS_O                (o_HS         ), //[PIXELS_PER_CLOCK-1:0] 
    .DE_O                (o_DE         ), //[PIXELS_PER_CLOCK-1:0] 
    .R_O                 (o_RGB_R      ), //[8*PIXELS_PER_CLOCK-1:0]
    .G_O                 (o_RGB_G      ), //[8*PIXELS_PER_CLOCK-1:0]
    .B_O                 (o_RGB_B      ),
    .ACTIVE_X_O          (ACTIVE_X     ) ,
    .ACTIVE_Y_O          (ACTIVE_Y     )
    
    
    
);
    
    
    
    
    
    
    
endmodule
