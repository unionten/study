`timescale 1ns / 1ps



module fake_axi4_master

#(parameter C_M00_AXI_ADDR_WIDTH = 32, 
  parameter C_M00_AXI_DATA_WIDTH = 256
)

(

//////////////////////////axi4///////////////////////////////////
input                                       m_axi4_aclk         , 
input                                       m_axi4_aresetn      , 
input                                       m_axi4_awready      , 
output  reg [ 3:0]                          m_axi4_awid        = 0 , 
output  reg [C_M00_AXI_ADDR_WIDTH-1:0]      m_axi4_awaddr      = 0 , 
output  reg [ 7:0]                          m_axi4_awlen       = 0 , 
output  reg [ 2:0]                          m_axi4_awsize      = 0 , 
output  reg [ 1:0]                          m_axi4_awburst     = 0 , 
output  reg [ 1:0]                          m_axi4_awlock      = 0 , 
output  reg [ 3:0]                          m_axi4_awcache     = 0 , 
output  reg [ 2:0]                          m_axi4_awprot      = 0 , 
output  reg                                 m_axi4_awvalid     = 0 , 
output  reg [ 3:0]                          m_axi4_awqos       = 0 , 
output  reg [ 3:0]                          m_axi4_awregion    = 0 , 
input                                       m_axi4_wready       , 
output  reg [ 3:0]                          m_axi4_wid         = 0, 
output  reg [C_M00_AXI_DATA_WIDTH-1:0]      m_axi4_wdata       = 0, 
output  reg [15:0]                          m_axi4_wstrb       = 0, 
output  reg                                 m_axi4_wlast       = 0, 
output  reg                                 m_axi4_wvalid      = 0, 
input   [ 3:0]                              m_axi4_bid          , 
input   [ 1:0]                              m_axi4_bresp        , 
input                                       m_axi4_bvalid       , 
output  reg                                 m_axi4_bready      = 1 , 
input                                       m_axi4_arready      , 
output  reg [ 3:0]                          m_axi4_arid        = 0 , 
output  reg [C_M00_AXI_ADDR_WIDTH-1:0]      m_axi4_araddr      = 0 , 
output  reg [ 7:0]                          m_axi4_arlen       = 0 , 
output  reg [ 2:0]                          m_axi4_arsize      = 0 , 
output  reg [ 1:0]                          m_axi4_arburst     = 0 , 
output  reg [ 0:0]                          m_axi4_arlock      = 0 , 
output  reg [ 3:0]                          m_axi4_arcache     = 0 , 
output  reg [ 2:0]                          m_axi4_arprot      = 0 , 
output  reg                                 m_axi4_arvalid     = 0 , 
output  reg [ 3:0]                          m_axi4_arqos       = 0 , 
output  reg [ 3:0]                          m_axi4_arregion    = 0 , 
input   [ 3:0]                              m_axi4_rid          , 
input   [ 1:0]                              m_axi4_rresp        , 
input                                       m_axi4_rvalid       , 
input   [C_M00_AXI_DATA_WIDTH-1:0]          m_axi4_rdata        , 
input                                       m_axi4_rlast        , 
output  reg                                 m_axi4_rready      = 1                         

);









endmodule



