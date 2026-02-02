`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2023/10/09 10:33:57
// Design Name: 
// Module Name: tb_lb2drp
// Project Name: 
// Target Devices: 
// Tool Versions: 
//////////////////////////////////////////////////////////////////////////////////


module tb_lb2drp(

    );
parameter C_ADDR_WIDTH = 12;
parameter C_DATA_WIDTH = 16;


reg clk;
reg rst;
always #5 clk =~clk;

reg [C_ADDR_WIDTH-1:0]  S_LB_WADDR ; 
reg [C_DATA_WIDTH-1:0]  S_LB_WDATA  ;
reg S_LB_WREQ  ; 
reg [C_ADDR_WIDTH-1:0]  S_LB_RADDR ; 
reg S_LB_RREQ  ; 
wire [C_DATA_WIDTH-1:0]  S_LB_RDATA  ;
wire S_LB_RFINISH;
wire S_LB_BUSY  ; 
wire M_DRPEN  ;   
wire M_DRPWE  ;   
wire [C_ADDR_WIDTH-1:0]  M_DRPADDR ;  
reg M_DRPRDY  ;  
wire [C_DATA_WIDTH-1:0] M_DRPDI  ;   
reg [C_DATA_WIDTH-1:0] M_DRPDO ;    


initial begin
S_LB_WADDR = 0;
S_LB_WDATA = 0;
S_LB_WREQ  = 0;
S_LB_RADDR = 0;
S_LB_RREQ = 0;

    rst = 1;
    clk = 0;
    #200;
    rst = 0;
    #606;
    
S_LB_WADDR = 32'h11223344; 
S_LB_WDATA = 32'h3f3f4544 ;
S_LB_WREQ  = 1 ; 
#20;
S_LB_WREQ  = 0 ; 

#2200;



 S_LB_RADDR  = 32'heeeedddd; 
 S_LB_RREQ = 1 ; 
#20;
 S_LB_RREQ = 0 ;

end   


initial begin
    M_DRPRDY   = 0;     
    M_DRPDO     = 0;
#1300;
    M_DRPRDY   = 1;     
    M_DRPDO     = 435;
    #6
    S_LB_WREQ = 1;
    #4;
    M_DRPRDY   = 0; 
    #6;
    S_LB_WREQ = 0;
    
    
    
#800;
   M_DRPRDY   = 1;     
    M_DRPDO     = 453456;
#10;
M_DRPRDY   = 0;
#1800;

   M_DRPRDY   = 1;     
    M_DRPDO     = 98978;
#10;
M_DRPRDY   = 0;

#1000;
$stop;

end


    
lb2drp
    #(.C_ADDR_WIDTH (C_ADDR_WIDTH),
      .C_DATA_WIDTH (C_DATA_WIDTH) )
    lb2drp_u(
    .CLK_I        (clk),
    .RST_I        (rst),
    .S_LB_WADDR   (S_LB_WADDR  ), 
    .S_LB_WDATA   (S_LB_WDATA  ),
    .S_LB_WREQ    (S_LB_WREQ   ),
    .S_LB_RADDR   (S_LB_RADDR  ),
    .S_LB_RREQ    (S_LB_RREQ   ),
    .S_LB_RDATA   (S_LB_RDATA  ),
    .S_LB_RFINISH (S_LB_RFINISH),
    .S_LB_BUSY    (S_LB_BUSY   ),
    .M_DRPEN      (M_DRPEN     ),
    .M_DRPWE      (M_DRPWE     ),
    .M_DRPADDR    (M_DRPADDR   ),
    .M_DRPRDY     (M_DRPRDY    ),
    .M_DRPDI      (M_DRPDI     ),
    .M_DRPDO      (M_DRPDO     )
    
    );





    
    
endmodule
