`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/02 17:52:46
// Design Name: 
// Module Name: tb_drp_interconnect
// Project Name: 
// Target Devices: 
//////////////////////////////////////////////////////////////////////////////////


module tb_drp_interconnect(

    );

reg  DRP_CLK ; 
reg  DRP_RESETN ;
reg  S_DRPEN_0 ;
reg  S_DRPWE_0 ;
wire S_DRPRDY_0 ;
reg  [11:0] S_DRPADDR_0; 
reg  [15:0] S_DRPDI_0;   
wire [15:0] S_DRPDO_0 ;  
reg  S_DRPEN_1 ;  
reg  S_DRPWE_1 ;  
reg  [11:0] S_DRPADDR_1 ;
wire S_DRPRDY_1 ;
reg  [15:0] S_DRPDI_1 ;  
wire [15:0] S_DRPDO_1 ; 
reg  S_DRPEN_2 ;  
reg  S_DRPWE_2 ;  
reg  [11:0] S_DRPADDR_2 ;
wire S_DRPRDY_2 ;
reg  [15:0] S_DRPDI_2 ;  
wire [15:0] S_DRPDO_2 ;  
wire M_DRPEN ;    
wire M_DRPWE ;  
reg  M_DRPRDY ;     
wire [11:0] M_DRPADDR ;  
reg  [15:0] M_DRPDI;     
wire [15:0] M_DRPDO ;    

always #5 DRP_CLK = ~ DRP_CLK ;

initial begin
S_DRPEN_0   = 0;
S_DRPWE_0   = 0;
S_DRPADDR_0 = 0; 
S_DRPDI_0   = 0;   
S_DRPEN_1   = 0;  
S_DRPWE_1   = 0;  
S_DRPADDR_1 = 0;
S_DRPDI_1   = 0; 
S_DRPEN_2   = 0;  
S_DRPWE_2   = 0;  
S_DRPADDR_2 = 0;
S_DRPDI_2   = 0; 
 
M_DRPRDY    = 0;   
M_DRPDI     = 0;   
DRP_CLK    = 0;
DRP_RESETN = 0;
#500;
DRP_RESETN = 1;
#502;


S_DRPEN_0   = 1;
S_DRPWE_0   = 1;
S_DRPADDR_0 = 16'h00A4; 
S_DRPDI_0   = 16'h0AA4; 
  
S_DRPEN_1   = 1;  
S_DRPWE_1   = 1;  
S_DRPADDR_1 = 16'h00B4; 
S_DRPDI_1   = 16'h0BB4;  


S_DRPEN_2   = 1;  
S_DRPWE_2   = 1;  
S_DRPADDR_2 = 16'h00C4; 
S_DRPDI_2   = 16'h0CC4; 

 
M_DRPRDY    = 0;   
M_DRPDI     = 0;     
#10;
S_DRPEN_0   = 0;
S_DRPWE_0   = 0;
S_DRPEN_1   = 0;  
S_DRPWE_1   = 0;  
S_DRPEN_2   = 0;  
S_DRPWE_2   = 0; 

#200;

M_DRPRDY    = 1;   
M_DRPDI     = 16'hAAAA;     
#10 ;
M_DRPRDY    = 0;   

#500;

M_DRPRDY    = 1;   
M_DRPDI     = 16'hBBBB;    
#10 ;
M_DRPRDY    = 0;   


#500;
M_DRPRDY    = 1;   
M_DRPDI     = 16'hCCCC;    
#10 ;
M_DRPRDY    = 0;   






end



 
drp_interconnect   
#(.C_SI_NUM    (3),
  .C_ADDR_WIDTH(12),
  .C_DATA_WIDTH(16) )
drp_interconnect_u(
.DRP_CLK     (DRP_CLK     ),
.DRP_RESETN  (DRP_RESETN  ),
.S_DRPEN_0   (S_DRPEN_0   ),
.S_DRPWE_0   (S_DRPWE_0   ),
.S_DRPADDR_0 (S_DRPADDR_0 ),
.S_DRPRDY_0  (S_DRPRDY_0  ),
.S_DRPDI_0   (S_DRPDI_0   ),
.S_DRPDO_0   (S_DRPDO_0   ),
.S_DRPEN_1   (S_DRPEN_1   ),
.S_DRPWE_1   (S_DRPWE_1   ),
.S_DRPADDR_1 (S_DRPADDR_1 ),
.S_DRPRDY_1  (S_DRPRDY_1  ),
.S_DRPDI_1   (S_DRPDI_1   ),
.S_DRPDO_1   (S_DRPDO_1   ),
.S_DRPEN_2   (S_DRPEN_2   ),  
.S_DRPWE_2   (S_DRPWE_2   ),  
.S_DRPADDR_2 (S_DRPADDR_2 ),
.S_DRPRDY_2  (S_DRPRDY_2  ),
.S_DRPDI_2   (S_DRPDI_2   ),  
.S_DRPDO_2   (S_DRPDO_2   ), 
.M_DRPEN     (M_DRPEN     ),
.M_DRPWE     (M_DRPWE     ),
.M_DRPADDR   (M_DRPADDR   ),
.M_DRPRDY    (M_DRPRDY    ),
.M_DRPDI     (M_DRPDI     ), //note : the direction is as name
.M_DRPDO     (M_DRPDO     )

);


    
    
endmodule
