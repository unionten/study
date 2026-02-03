`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/01/18 17:14:15
// Design Name: 
// Module Name: tb_iic_master_interconnect
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


module tb_iic_master_interconnect(

    );
    
reg clk;
reg rst ;

reg [7:0] WR_BYTE_NUM_0_I  =0 ;
reg [63:0] WR_DATA_0_I    =0  ;
reg [7:0]  RD_BYTE_NUM_0_I =0 ;
reg        START_0_I     =0  ;


reg [7:0] WR_BYTE_NUM_1_I =0 ;
reg [63:0]WR_DATA_1_I    =0  ;
wire [63:0] RD_DATA_1_O ;
wire [63:0] RD_DATA_0_O ;
reg [7:0] RD_BYTE_NUM_1_I =0 ;
reg START_1_I             =0 ;


reg BUSY_I  = 1 ;
reg FINISH_I =  0 ;
reg ERROR_I  = 0 ;

always #5 clk = ~clk;

initial begin
    BUSY_I =1;
    clk = 0;
    rst = 1;
    #200;
    rst = 0;
    #200;
    
WR_BYTE_NUM_0_I  = 3;
 WR_DATA_0_I     = 64'haabbccdd;
 RD_BYTE_NUM_0_I = 2;
 START_0_I       = 1 ;
 
 
 WR_BYTE_NUM_1_I  = 5;
 WR_DATA_1_I     = 64'h11223344;
 RD_BYTE_NUM_1_I = 4;
 START_1_I       = 1 ;
 #11;
  START_0_I       = 0;
   START_1_I       = 0 ;
 
 
 #20000;
 
 BUSY_I = 0;
 
 
 

  





end





  iic_master_interconnect  uurt(  
.CLK_I (clk),
.RST_I (rst),


.WR_BYTE_NUM_0_I (WR_BYTE_NUM_0_I ),
.WR_DATA_0_I     (WR_DATA_0_I     ),
.RD_BYTE_NUM_0_I (RD_BYTE_NUM_0_I ),
.RD_DATA_0_O     (RD_DATA_0_O     ),
.START_0_I       (START_0_I       ),
.BUSY_0_O        (BUSY_0_O        ),
.FINISH_0_O      (FINISH_0_O      ),
.ERROR_0_O       (ERROR_0_O       ), 



.WR_BYTE_NUM_1_I (WR_BYTE_NUM_1_I ),
.WR_DATA_1_I     (WR_DATA_1_I     ),
.RD_BYTE_NUM_1_I (RD_BYTE_NUM_1_I ),
.RD_DATA_1_O     (RD_DATA_1_O     ),
.START_1_I       (START_1_I       ),
.BUSY_1_O        (BUSY_1_O        ),
.FINISH_1_O      (FINISH_1_O      ),
.ERROR_1_O       (ERROR_1_O       ), 



.WR_BYTE_NUM_O (  ),
.WR_DATA_O     (      ),
.RD_BYTE_NUM_O (  ),
.RD_DATA_I     (45645     ),
.START_O       (START_O       ) ,
.BUSY_I        (BUSY_I        ) ,
.FINISH_I      (FINISH_I      ) ,
.ERROR_I       (ERROR_I       )



);

    
    
    
endmodule
