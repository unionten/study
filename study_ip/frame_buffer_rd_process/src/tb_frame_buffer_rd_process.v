`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/16 09:37:54
// Design Name: 
// Module Name: tb_frame_buffer_rd_process
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


module tb_frame_buffer_rd_process(

    );
parameter C_MAX_PORT_NUM           = 4;
parameter C_MAX_BPC                = 8;
parameter C_DDR_PIXEL_MAX_BYTE_NUM = 4;
parameter C_COLOR_SPACE_DEFAULT    = 3;//in color space
parameter C_MEM_BYTES_DEFAULT      = 4;//<= C_DDR_PIXEL_MAX_BYTE_NUM
parameter C_HACTIVE_DEFAULT        = 256 ;
parameter C_VACTIVE_DEFAULT        = 128;
    
localparam C_FIFO_OUT_WIDTH = f_upper(C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM);
  
    
    
reg clk = 0;
reg rst ;

always #5 clk = ~clk;

wire pixel_rd_0;
wire [C_FIFO_OUT_WIDTH-1:0] pixel_data_0;
wire pixel_de_1;
wire [C_FIFO_OUT_WIDTH-1:0] pixel_data_1;
wire pixel_de_2;
wire [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0] pixel_data_2;
wire pixel_de_3;
wire [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0] pixel_data_3;
wire pixel_de_4;
wire [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0] pixel_data_4;

assign  pixel_rd_0   = uut.pixel_rd_0;
assign  pixel_data_0 = uut.pixel_data_0;
assign  pixel_de_1   = uut.pixel_de_1;
assign  pixel_data_1 = uut.pixel_data_1;
assign  pixel_de_2   = uut.pixel_de_2;
assign  pixel_data_2 = uut.pixel_data_2;
assign  pixel_de_3   = uut.pixel_de_3;
assign  pixel_data_3 = uut.pixel_data_3;
assign  pixel_de_4   = uut.pixel_de_4;
assign  pixel_data_4 = uut.pixel_data_4;


initial begin
    clk = 0;
    rst = 1;
    
    #500;
    
    rst = 0;
    
    #500; 

end


wire [3:0] VS ;
wire [3:0] HS ;
wire [3:0] DE ;
wire [31:0] R  ;
wire [31:0] G  ;
wire [31:0] B  ;


   
frame_buffer_rd_process 
   #(.C_AXI_LITE_ADDR_WIDTH   ( 20  ),
    .C_AXI_LITE_DATA_WIDTH    ( 32  ),
    .C_RAW_DATA_WIDTH         ( 256 ),
    .C_MAX_PORT_NUM           ( C_MAX_PORT_NUM   ),
    .C_MAX_BPC                ( C_MAX_BPC   ),
    .C_DDR_PIXEL_MAX_BYTE_NUM ( C_DDR_PIXEL_MAX_BYTE_NUM   ),
    .C_OUT_FORMAT             ( 1   ),
    .C_OSD_BLOCK_EN           ( 0   ),
    .C_TPG_SRC                ( 0   ),
    .C_ENABLE_DEFAULT         ( 1   ), 
    .C_PORT_NUM_DEFAULT       ( C_MAX_PORT_NUM   ),
    .C_COLOR_DEPTH_DEFAULT    ( C_MAX_BPC   ),
    .C_COLOR_SPACE_DEFAULT    ( C_COLOR_SPACE_DEFAULT   ),
    .C_MEM_BYTES_DEFAULT      ( C_MEM_BYTES_DEFAULT   ),
    .C_HACTIVE_DEFAULT        ( C_HACTIVE_DEFAULT ),
    .C_VACTIVE_DEFAULT        ( C_VACTIVE_DEFAULT ),
    .C_HSYNC_DEFAULT          ( 20  ),
    .C_HBP_DEFAULT            ( 20  ),
    .C_HFP_DEFAULT            ( 20  ),
    .C_VSYNC_DEFAULT          ( 20  ),
    .C_VBP_DEFAULT            ( 20  ),
    .C_VFP_DEFAULT            ( 20  ),
    .C_OSD_HPIXEL_DEFAULT     ( 500 ),
    .C_OSD_VPIXEL_DEFAULT     ( 400 ),
    .C_OSD_X_DEFAULT          ( 0   ),
    .C_OSD_Y_DEFAULT          ( 0   ),
    .C_OSD_ENABLE_DEFAULT     ( 0   ),
    .C_OSD_SETTING_DEFAULT    ( 1   )
    )
uut(
.S_AXI_ACLK     (clk) ,
.S_AXI_ARESETN  (~rst) ,
.ENABLE_O      (LINK_EN) ,
.AXI4_CLK_I      (clk) ,
.AXI4_RSTN_I     (~rst) ,
.WDATA         (256'h0015954c0055954c0015954c0055954c0015954c0055954c0015954c0055954c) ,
.WREQ          (1) ,
.VID_CLK_I      (clk)  ,
.VID_RSTN_I     (~rst)  ,
.VID_VS_O           (VS  )  ,
.VID_HS_O           (HS  )  ,
.VID_DE_O           (DE  )  ,
.VID_R_O            (R   )  ,
.VID_G_O            (G   )  ,
.VID_B_O            (B   )  
                                     

);


function [15:0] f_upper;
input  [15:0] in;
begin
         if(in>0 && in<=2)     f_upper = 2 ;
    else if(in>2 && in<=4)     f_upper = 4 ;
    else if(in>4 && in<=8)     f_upper = 8 ;
    else if(in>8 && in<=16)    f_upper = 16;
    else if(in>16 && in<=32)   f_upper = 32;
    else if(in>32 && in<=64)   f_upper = 64;
    else if(in>64 && in<=128)  f_upper = 128;
    else if(in>128 && in<=256) f_upper = 256;
    else if(in>256 && in<=512) f_upper = 512;
    else                       f_upper = 128;
end
endfunction
  
    
endmodule




