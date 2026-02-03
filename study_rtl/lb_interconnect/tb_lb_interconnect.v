`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/06 17:31:53
// Design Name: 
// Module Name: tb_lb_interconnect
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


module tb_lb_interconnect(

    );
    
  reg clk;
reg rst;  
    
reg [15:0] LB_WADDR_0_I   ;
reg [31:0] LB_WDATA_0_I   ;
reg LB_WREQ_0_I    ;
reg [15:0]  LB_RADDR_0_I   ;
reg LB_RREQ_0_I    ;

reg  [15:0] LB_WADDR_1_I  ;
reg [31:0]LB_WDATA_1_I  ;
reg LB_WREQ_1_I   ;
reg  [15:0] LB_RADDR_1_I  ;
reg LB_RREQ_1_I   ;

reg [31:0]LB_RDATA_I   ;
reg LB_RFINISH_I ;

   
    
lb_interconnect  
#(.C_ADDR_WIDTH (16) , //= 16 ;
  .C_DATA_WIDTH (32) , //= 32 ;
  .C_CH_NUM     (2) ) //= 2 ;
lb_interconnect (
.LB_CLK_I       (clk),
.LB_RSTN_I      (~rst),

.LB_WADDR_0_I   (LB_WADDR_0_I  ),
.LB_WDATA_0_I   (LB_WDATA_0_I  ),
.LB_WREQ_0_I    (LB_WREQ_0_I   ),
.LB_RADDR_0_I   (LB_RADDR_0_I  ),
.LB_RREQ_0_I    (LB_RREQ_0_I   ),
.LB_RDATA_0_O   (   ),
.LB_RFINISH_0_O (   ),

.LB_WADDR_1_I   (LB_WADDR_1_I ),
.LB_WDATA_1_I   (LB_WDATA_1_I ),
.LB_WREQ_1_I    (LB_WREQ_1_I  ),
.LB_RADDR_1_I   (LB_RADDR_1_I ),
.LB_RREQ_1_I    (LB_RREQ_1_I  ),
.LB_RDATA_1_O   (   ),
.LB_RFINISH_1_O (   ),


.LB_WADDR_O   (),
.LB_WDATA_O   (),
.LB_WREQ_O    (),
.LB_RADDR_O   (),
.LB_RREQ_O    (),
.LB_RDATA_I   (LB_RDATA_I ),
.LB_RFINISH_I (LB_RFINISH_I ) 


);


//LB_WADDR_0_I   ;
//LB_WDATA_0_I   ;
//LB_WREQ_0_I    ;
//LB_RADDR_0_I   ;
//LB_RREQ_0_I    ;
//
//LB_WADDR_1_I  ;
//LB_WDATA_1_I  ;
//LB_WREQ_1_I   ;
//LB_RADDR_1_I  ;
//LB_RREQ_1_I   ;
//
//LB_RDATA_I   ;
//LB_RFINISH_I ;




always #5 clk = ~clk ;
initial begin
LB_WADDR_0_I  = 0;
LB_WDATA_0_I  = 0;
LB_WREQ_0_I   = 0;
LB_RADDR_0_I  = 0;
LB_RREQ_0_I   = 0;
            
LB_WADDR_1_I  = 0;
LB_WDATA_1_I  = 0;
LB_WREQ_1_I   = 0;
LB_RADDR_1_I  = 0;
LB_RREQ_1_I   = 0;
              
LB_RDATA_I    = 0;
LB_RFINISH_I  = 0;


    clk = 0;
    rst = 1;
    #2000;
    rst = 0;
    #1;
    
LB_WADDR_0_I  = 10 ;
LB_WDATA_0_I  = 32'h11223344 ;
LB_WREQ_0_I   = 1 ;

LB_WADDR_1_I  = 20;
LB_WDATA_1_I  = 32'hffeeffee;
LB_WREQ_1_I   = 1 ;

#10;
LB_WREQ_0_I   = 0 ;
LB_WREQ_1_I   = 0 ;


#200;
LB_RADDR_0_I  = 16'h8888;
LB_RREQ_0_I   = 1;

LB_RADDR_1_I  = 16'h9999;
LB_RREQ_1_I   = 1;

#10;
LB_RREQ_0_I   = 0;
LB_RREQ_1_I   = 0;


#100;
LB_RDATA_I    = 32'heeeeeeee;
LB_RFINISH_I  = 1;
#10;
LB_RFINISH_I  = 0;
#10;


LB_RDATA_I    = 32'h33333333;
LB_RFINISH_I  = 1;
#10;
LB_RFINISH_I  = 0;



    

end



    
    
    
endmodule



