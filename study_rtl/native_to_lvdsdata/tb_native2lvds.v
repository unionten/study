`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/27 11:37:34
// Design Name: 
// Module Name: tb_native2lvds
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


module tb_native2lvds(

    );


parameter C_PORT_NUM = 1;


wire [28*C_PORT_NUM-1:0] LVDS_DATA_O ;
wire [7*C_PORT_NUM-1:0]  LANE0_O     ;  //低位bit对应实际先输出的bit
wire [7*C_PORT_NUM-1:0]  LANE1_O     ; 
wire [7*C_PORT_NUM-1:0]  LANE2_O     ;  
wire [7*C_PORT_NUM-1:0]  LANE3_O     ;




    
native_to_lvdsdata  
#(.C_PORT_NUM(C_PORT_NUM))

native_to_lvdsdatau(
.R_I        (8'b10101111),
.G_I        (8'b00001100),
.B_I        (8'b11110000),
.VS_I       (1),
.HS_I       (1),
.DE_I       (1),
.LVDS_DATA_O (LVDS_DATA_O ),
.LANE0_O     (LANE0_O     ),   //低位bit对应实际先输出的bit
.LANE1_O     (LANE1_O     ),  
.LANE2_O     (LANE2_O     ),   
.LANE3_O     (LANE3_O     )

);
    
    




 
    
    
endmodule
