`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/13 14:55:14
// Design Name: 
// Module Name: tb_drp_init_write_rtl
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


module tb_drp_init_write_rtl(

    );
    
reg VIO_TRIG_vio_drp=0;   
    
reg    DRPCLK_I  = 0;
reg    DRPRSTN_I = 0;

wire [15:0] M_DRPADDR_O ;  
wire [15:0] M_DRPDI_O ;    
wire  M_DRPEN_O    ; 
wire  M_DRPWE_O    ; 


always #5 DRPCLK_I = ~DRPCLK_I ;


initial begin
    DRPCLK_I = 0;
    VIO_TRIG_vio_drp = 0;
    DRPRSTN_I = 0;
    #500;
    DRPRSTN_I = 1;
    
    #1000;
    VIO_TRIG_vio_drp = 1;
    #12;
    VIO_TRIG_vio_drp = 0;
    
    

end 
    
drp_init_write_rtl   
    drp_init_write_rtl_u    
    (    
    .DRPCLK_I          (DRPCLK_I ),
    .DRPRSTN_I         (DRPRSTN_I),
    .M_DRPADDR_O       (M_DRPADDR_O   ),
    .M_DRPDI_O         (M_DRPDI_O     ),
    .M_DRPEN_O         (M_DRPEN_O     ),
    .M_DRPWE_O         (M_DRPWE_O     ),
    .M_DRPRDY_I        (1),
    .VIO_TRIG_vio_drp  (VIO_TRIG_vio_drp)

    );
    
    
endmodule