`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/26 17:16:26
// Design Name: 
// Module Name: tb_rgb_to_raw
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


module tb_rgb_to_raw(

    );
    
    
reg VID_CLK   ; 
reg VID_RSTN  ;   
reg S_VS      ;   
reg S_HS      ;   
reg S_DE      ;   
reg [31:0] S_R       ;   
reg [31:0] S_G       ;   
reg [31:0] S_B       ;   
wire M_VS      ;   
wire M_HS      ;   
wire M_DE      ;   

wire [12*4*3-1:0] M_RAW     ;   
    
reg [1:0] TRANSFER_MODE  = 0  ;
reg [1:0] RAW_BIT_NUM    = 12 ;
 
 always #5 VID_CLK = ~VID_CLK  ;
 
 
initial begin
VID_CLK = 0;
VID_RSTN = 0;
S_VS  =0;
S_HS  =0;
S_DE  =0;
S_R  = 32'b10000001_11000001_11100001_11110001;
S_G  = 32'b10000011_11000011_11100011_11110011;
S_B  = 32'b10000111_11000111_11100111_11110111;
TRANSFER_MODE = 1;



#1000;
VID_RSTN = 1;

#1000;

S_VS =1 ;
#11;
S_VS = 0;
#300;

S_HS =1;
#10;
S_HS = 0;

#200;

S_HS =1;
#10;
S_HS = 0;

#200;

S_HS =1;
#10;
S_HS = 0;

#200;

S_HS =1;
#10;
S_HS = 0;

#200;


S_DE =1;
#1000;
S_DE = 0;

#200;

S_HS =1;
#10;
S_HS = 0;

#200;

S_DE =1;
#1000;
S_DE = 0;

#200;




TRANSFER_MODE = 2 ;

#1000;


S_VS =1 ;
#11;
S_VS = 0;
#300;

S_HS =1;
#10;
S_HS = 0;

#200;

S_HS =1;
#10;
S_HS = 0;

#200;

S_HS =1;
#10;
S_HS = 0;

#200;

S_HS =1;
#10;
S_HS = 0;

#200;


S_DE =1;
#1000;
S_DE = 0;

#200;

S_HS =1;
#10;
S_HS = 0;

#200;

S_DE =1;
#1000;
S_DE = 0;

#200;




end   
    
    
    
rgb_to_raw
#( .C_IN_BPP                  (8 ) ,// = 8 ,
   .C_IN_PORT_NUM             (4 ) ,// = 4 ,
   .C_OUT_MAX_CPNTS_PER_PIXEL (2 ) ,// = 3 ,
   .C_OUT_MAX_BITS_PER_CPNT   (12)  // = 8   // 在component中右对齐   目前只支持 >= 8
    
)
rgb_to_raw_u
(

.VID_CLK  (VID_CLK) ,
.VID_RSTN (VID_RSTN),
.S_VS  (S_VS ),
.S_HS  (S_HS ),
.S_DE  (S_DE ),
.S_R_Y (S_R),
.S_G_U (S_G),
.S_B_V (S_B),
. M_VS (M_VS),
. M_HS (M_HS),
. M_DE (M_DE),
.  M_VID_DATA (M_RAW ),
. TRANSFER_MODE (TRANSFER_MODE ) ,  // 转换方式 0 1 2 :  "ORIGINAL"  "YUV_TO_YUV422"   "RGB_TO_RGGB"
. RAW_BIT_NUM   (RAW_BIT_NUM  )  // 0 1 2 : 8 10  12 bit



);
    
   
    
    
    
    
    
    
    
endmodule
