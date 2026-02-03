`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// 
// Create Date: 2023/06/23 09:44:07
// Design Name: 
// Module Name: reconcat_top
// Project Name: 
//////////////////////////////////////////////////////////////////////////////////

/*

reconcat_top
    #(.C_MAX_PORT_NUM           () ,
      .C_MAX_BPC                () ,
      .C_DDR_PIXEL_MAX_BYTE_NUM () 
     )
    reconcat_top_u(
    .TARGET_DDR_BYTE_NUM_I  (),
    .TARGET_BPC_I           (),
    .RST_I                  (),       
    .CLK_I                  (),       
    .PIXEL_VS_I             (),  
    .PIXEL_HS_I             (),   
    .PIXEL_DE_I             (),  
    .PIXEL_DATA_I           (), 
    .PIXEL_VS_O             (),          
    .PIXEL_HS_O             (),          
    .PIXEL_DE_O             (), //        
    .PIXEL_DATA_O           ()  //allign tightly according TARGET_DDR_BYTE_NUM_I and TARGET_BPC_I
    );

*/


module reconcat_top(
input [7:0] TARGET_DDR_BYTE_NUM_I ,
input [3:0] TARGET_BPC_I,
input RST_I  ,       
input CLK_I  ,       
input PIXEL_VS_I  ,  
input PIXEL_HS_I ,   
input PIXEL_DE_I  ,  
input [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0] PIXEL_DATA_I , 
output PIXEL_VS_O  ,          
output PIXEL_HS_O  ,          
output PIXEL_DE_O ,           
output [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0] PIXEL_DATA_O // allign tightly as TARGET_DDR_BYTE_NUM_I and  TARGET_BPC_I     

    );

//C_MAX_PORT_NUM   C_MAX_BPC   C_DDR_PIXEL_MAX_BYTE_NUM     LUT      FF
//    8               16                 8                  553      694
//    4               8                  4                  183      222


parameter C_MAX_PORT_NUM           = 4   ;     //valid:  1  2  4   8
parameter C_MAX_BPC                = 8  ;     //valid : 6  8  10  12  16
parameter C_DDR_PIXEL_MAX_BYTE_NUM = 4   ;     //valid : 2  3  4   8 
  
  
wire vs1;
wire hs1; 
wire de1; 
wire vs2;
wire hs2; 
wire de2; 
wire [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0] pixel_data_tmp1;
wire   [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0]  pixel_data_tmp2;


reconcat1
    #(.C_MAX_PORT_NUM(C_MAX_PORT_NUM),  //valid: 1 2 4 8
      .C_MAX_BPC     (C_MAX_BPC))  //valid : 6 8 10 12 16
    reconcat1_u  (
    .RST_I         (RST_I         ) ,
    .CLK_I         (CLK_I         ) ,
    .TARGET_BPC_I  (TARGET_BPC_I  ) , //[3:0]
    .PIXEL_VS_I    (PIXEL_VS_I    ) ,
    .PIXEL_HS_I    (PIXEL_HS_I    ) ,
    .PIXEL_DE_I    (PIXEL_DE_I    ) ,
    .PIXEL_DATA_I  (PIXEL_DATA_I  ) ,//[C_MAX_BPC*3*C_MAX_PORT_NUM-1:0]  {R10  G10   B10},{R10  G10   B10},{R10  G10   B10},{R10  G10   B10}
    .PIXEL_VS_O    (vs1    ) ,
    .PIXEL_HS_O    (hs1    ) ,
    .PIXEL_DE_O    (de1    ) ,
    .PIXEL_DATA_O  (pixel_data_tmp1  ) //[C_MAX_BPC*3*C_MAX_PORT_NUM-1:0]   {R10  G10   B10},{R10  G10   B10},{R10  G10   B10},{R10  G10   B10}
                                                     //   {R8 G8 B8  6'b0},{R8 G8 B8  6'b0},{R8 G8 B8  6'b0},{R8 G8 B8  6'b0}  
                                                     //or {R6 G6 B6 12'b0},{R6 G6 B6 12'b0},{R6 G6 B6 12'b0},{R6 G6 B6 12'b0} 
    );

    
reconcat2
    #(.C_MAX_PORT_NUM(C_MAX_PORT_NUM),
      .C_MAX_BPC     (C_MAX_BPC),
      .C_DDR_PIXEL_MAX_BYTE_NUM(C_DDR_PIXEL_MAX_BYTE_NUM))
    reconcat2_u(
    .PIXEL_VS_I    (vs1) ,
    .PIXEL_HS_I    (hs1) ,
    .PIXEL_DE_I    (de1) ,
    .PIXEL_VS_O    (vs2) ,
    .PIXEL_HS_O    (hs2) ,
    .PIXEL_DE_O    (de2) ,
    .PIXEL_DATA_I  (pixel_data_tmp1) ,  // [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0]  {R10  G10   B10},{R10  G10   B10},{R10  G10   B10},{R10  G10   B10}
    .PIXEL_DATA_O  (pixel_data_tmp2)    // [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0]  {R10  G10   B10  2'b0},{R10  G10   B10  2'b0},{R10  G10   B10  2'b0},{R10  G10   B10  2'b0}
    );                                                              // or{R10  G6},{R10  G6},{R10  G6},{R10  G6}
    
  reconcat3
    #(.C_MAX_PORT_NUM(C_MAX_PORT_NUM),
      .C_DDR_PIXEL_MAX_BYTE_NUM(C_DDR_PIXEL_MAX_BYTE_NUM))
    reconcat3_u(
    .CLK_I                 (CLK_I),
    .RST_I                 (RST_I),
    .PIXEL_VS_I            (vs2),
    .PIXEL_HS_I            (hs2),
    .PIXEL_DE_I            (de2),
    .PIXEL_VS_O            (PIXEL_VS_O ),
    .PIXEL_HS_O            (PIXEL_HS_O ),
    .PIXEL_DE_O            (PIXEL_DE_O ),
    .PIXEL_DATA_I          (pixel_data_tmp2),// [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0]   {R8  G8   B8  8'b0},{R8  G8   B8  8'b0},{R8  G8   B8  8'b0},{R8  G8   B8  8'b0}
    .ACTUAL_DDR_BYTE_NUM_I ({0,TARGET_DDR_BYTE_NUM_I}), //[7:0]             ;2 3 4 8  valid : <= C_DDR_PIXEL_MAX_BYTE_NUM
    .PIXEL_DATA_O          (PIXEL_DATA_O) // [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0] 紧凑拼接 when autual_num is 3 ->    {R8 G8 B8 },{R8 G8 B8 },{R8 G8 B8 },{R8 G8 B8 }


    );  
    
    
endmodule



