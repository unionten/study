`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/12 16:46:22
// Design Name: 
// Module Name: tb_axi_lite_master
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


module tb_axi_lite_master(

    );

parameter C_M_AXI_ADDR_WIDTH = 32;
parameter C_M_AXI_DATA_WIDTH = 32;


reg clk  ;
reg rstn ;

always #10 clk = ~clk;



reg S_LB_WREQ   ;
reg [C_M_AXI_ADDR_WIDTH-1:0] S_LB_WADDR  ;
reg [C_M_AXI_DATA_WIDTH-1:0]S_LB_WDATA  ;
reg S_LB_RREQ   ;
reg [C_M_AXI_ADDR_WIDTH-1:0] S_LB_RADDR  ;

wire S_LB_WBUSY ; 
wire S_LB_RBUSY ; 
wire [C_M_AXI_DATA_WIDTH-1:0]  S_LB_RDATA ; 
wire S_LB_RFINISH;


reg                                 AXI_AWREADY   ;
wire [C_M_AXI_ADDR_WIDTH-1:0]        AXI_AWADDR    ;
wire                                 AXI_AWVALID   ;
wire [ 2:0]                          AXI_AWPROT    ;
reg                                 AXI_WREADY    ;
wire [C_M_AXI_DATA_WIDTH-1:0]        AXI_WDATA     ;
wire [(C_M_AXI_DATA_WIDTH/8)-1 :0]   AXI_WSTRB     ;
wire                                 AXI_WVALID    ;
wire [ 1:0]                           AXI_BRESP     ;
reg                                  AXI_BVALID    ;
wire                                 AXI_BREADY    ;
reg                                 AXI_ARREADY   ;
wire [C_M_AXI_ADDR_WIDTH-1:0]        AXI_ARADDR    ;
wire                                 AXI_ARVALID   ;
wire [ 2:0]                          AXI_ARPROT    ;
wire [ 1:0]                          AXI_RRESP     ;
reg                                 AXI_RVALID    ;
wire [C_M_AXI_DATA_WIDTH-1:0]        AXI_RDATA     ;
wire                                 AXI_RREADY    ;
 

    
axi_lite_master #(.C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
                  .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH))
    axi_lite_master_u(  
    .S_LB_WREQ    (S_LB_WREQ    ),                                                         //
    .S_LB_WADDR   (S_LB_WADDR   ),       //[C_M_AXI_ADDR_WIDTH-1:0]                        //
    .S_LB_WDATA   (S_LB_WDATA   ),      //[C_M_AXI_DATA_WIDTH-1 : 0]                       //
    .S_LB_RREQ    (S_LB_RREQ    ),                                                         // [C_M_AXI_ADDR_WIDTH-1 : 0]   AXI_AWADDR  
    .S_LB_RADDR   (S_LB_RADDR   ),        //[C_M_AXI_ADDR_WIDTH-1:0]                       // [2 : 0]                      AXI_AWPROT  
    .S_LB_WBUSY   (S_LB_WBUSY   ),
    .S_LB_RBUSY   (S_LB_RBUSY   ),
    .S_LB_RDATA   (S_LB_RDATA),
    .S_LB_RFINISH (S_LB_RFINISH),

    .M_AXI_ACLK             (clk    ),                                             //   AXI_AWVALID 
    .M_AXI_ARESETN          (rstn   ),                                             //   AXI_AWREADY 
    .M_AXI_AWADDR           (AXI_AWADDR  ),//[C_M_AXI_ADDR_WIDTH-1 : 0]                 // [C_M_AXI_DATA_WIDTH-1 : 0]    AXI_WDATA   
    .M_AXI_AWPROT           (AXI_AWPROT  ),//[2 : 0]                                    //  [C_M_AXI_DATA_WIDTH/8-1 : 0] AXI_WSTRB   
    .M_AXI_AWVALID          (AXI_AWVALID ),                                             //   AXI_WVALID  
    .M_AXI_AWREADY          (AXI_AWREADY ),                                             //   AXI_WREADY  
    .M_AXI_WDATA            (AXI_WDATA   ),//[C_M_AXI_DATA_WIDTH-1 : 0]                 // [1 : 0]    AXI_BRESP   
    .M_AXI_WSTRB            (AXI_WSTRB   ),//[C_M_AXI_DATA_WIDTH/8-1 : 0]               //   AXI_BVALID  
    .M_AXI_WVALID           (AXI_WVALID  ),                                             //   AXI_BREADY  
    .M_AXI_WREADY           (AXI_WREADY  ),                                             // [C_M_AXI_ADDR_WIDTH-1 : 0]   AXI_ARADDR  
    .M_AXI_BRESP            (AXI_BRESP   ), // [1 : 0]                                  // [2 : 0]  AXI_ARPROT  
    .M_AXI_BVALID           (AXI_BVALID  ),                                             //   AXI_ARVALID 
    .M_AXI_BREADY           (AXI_BREADY  ),                                             //   AXI_ARREADY 
    
    .M_AXI_ARADDR           (AXI_ARADDR  ),//[C_M_AXI_ADDR_WIDTH-1 : 0]                 //  [C_M_AXI_DATA_WIDTH-1 : 0] AXI_RDATA   
    .M_AXI_ARPROT           (AXI_ARPROT  ),// [2 : 0]                                   //   AXI_RRESP   
    .M_AXI_ARVALID          (AXI_ARVALID ),                                             //   AXI_RVALID  
    .M_AXI_ARREADY          (AXI_ARREADY ),                                             //   AXI_RREADY  
    .M_AXI_RDATA            (32'h12341234   ),//[C_M_AXI_DATA_WIDTH-1 : 0]                 //
    .M_AXI_RRESP            (AXI_RRESP   ),//[1 : 0]                                    //
    .M_AXI_RVALID           (AXI_RVALID  ),                                             //
    .M_AXI_RREADY           (AXI_RREADY  )                                              //
    );
  
  
  
  initial begin
    AXI_RVALID = 0;
    AXI_ARREADY = 0;
     AXI_BVALID = 0;
    AXI_AWREADY = 0;
    AXI_WREADY = 0;
    
    
    S_LB_WREQ   = 0;
    S_LB_WADDR  = 0;
    S_LB_WDATA  = 0;
    S_LB_RREQ   = 0;
    S_LB_RADDR  = 0;
  
    clk = 0;
    rstn = 0;
    #203;
    rstn = 1;
    #300;
    
    
    S_LB_WREQ  =1 ;
    S_LB_WADDR = 32'h22335566;
    S_LB_WDATA = 34;
    #21;
    S_LB_WREQ = 0;
    #500;
    
    AXI_AWREADY = 1;
    #200;
    AXI_WREADY = 1;
    #100;
    AXI_WREADY= 0;
    AXI_AWREADY = 0;
    
    #400;
    AXI_BVALID = 1;
    #41;
    AXI_BVALID = 0;
    
    #400;
    S_LB_RREQ = 1;
    S_LB_RADDR = 32'haabbccd;
    #21;
    S_LB_RREQ = 0;
    #200;
    AXI_ARREADY = 1;
    
    #300;
    AXI_ARREADY = 0;
    #200;
    
    
    AXI_RVALID = 1;
    #41;
    AXI_RVALID = 0;
    
    
  
  end
  







  
endmodule
