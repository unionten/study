`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/09 13:17:28
// Design Name: 
// Module Name: tb_axi2drp
// Project Name:  
//////////////////////////////////////////////////////////////////////////////////


module tb_axi2drp(

    );

reg clk_axi;
reg rstn_axi;
reg clk_drp;
reg rstn_drp;
always #5  clk_axi = ~clk_axi;
always #21 clk_drp = ~clk_drp;

initial begin
    S_LB_WADDR  = 0 ;
    S_LB_WDATA  = 0 ;
    S_LB_WREQ   = 0 ;
    S_LB_RADDR  = 0 ;
    S_LB_RREQ   = 0 ;
    M_DRPRDY    = 0 ;
    M_DRPDO     = 0 ;

    rstn_axi = 0;
    rstn_drp = 0;
    clk_axi = 0;
    clk_drp = 0;
    #500;
    rstn_axi = 1;
    rstn_drp = 1;
    #1000;
    
    S_LB_WADDR = 16'h0004;
    S_LB_WDATA = 32'ha5a55a5a;
    S_LB_WREQ  = 1;
    #20;
    S_LB_WREQ  = 0;
    #600;
    M_DRPRDY = 1 ; //~drp clk
    #50;
    M_DRPRDY = 0 ;
    
    #500;
    S_LB_RADDR = 16'h0008;
    S_LB_RREQ  = 1;
    #20;
    S_LB_RREQ  = 0;
    #600;
    M_DRPRDY   = 1;//~drp clk
    M_DRPDO    = 16'hFFEE;
    #50;
    M_DRPRDY   = 0;
    

 

end

reg [15:0] S_LB_WADDR ;
reg [31:0] S_LB_WDATA ;
reg        S_LB_WREQ  ;
reg [15:0] S_LB_RADDR ;
reg        S_LB_RREQ  ;

wire M_DRPEN ;
wire M_DRPWE ;
wire [11:0] M_DRPADDR;
wire [15:0] M_DRPDI;

reg M_DRPRDY;
reg [15:0] M_DRPDO;

wire [31:0] S_LB_RDATA ;
wire S_LB_RFINISH;
wire S_LB_BUSY;



axi2drp
    #(.C_AXI_LITE_ADDR_WIDTH (16),
      .C_AXI_LITE_DATA_WIDTH (32),
      .C_DRP_ADDR_WIDTH      (12),
      .C_DRP_DATA_WIDTH      (16),
      .C_LB_INTERFACE        (1),
      .C_AXI_ILA_ENABLE      (0),
      .C_DRP_ILA_ENABLE      (0)
      )
    axi2drp_u
    (
    .S_AXI_ACLK     (clk_axi),
    .S_AXI_ARESETN  (rstn_axi),
    .S_LB_WADDR     (S_LB_WADDR ), 
    .S_LB_WDATA     (S_LB_WDATA ),
    .S_LB_WREQ      (S_LB_WREQ  ), 
    .S_LB_RADDR     (S_LB_RADDR ), 
    .S_LB_RREQ      (S_LB_RREQ  ),
    .S_LB_RDATA     (S_LB_RDATA  ),
    .S_LB_RFINISH   (S_LB_RFINISH),
    .S_LB_BUSY      (S_LB_BUSY   ),
    
    .M_DRPCLK       (clk_drp),
    .M_DRPRSTN      (rstn_drp),
    .M_DRPEN        (M_DRPEN),
    .M_DRPWE        (M_DRPWE),
    .M_DRPADDR      (M_DRPADDR),
    .M_DRPRDY       (M_DRPRDY),
    .M_DRPDI        (M_DRPDI),
    .M_DRPDO        (M_DRPDO)
    
     );
    
    
    
endmodule
