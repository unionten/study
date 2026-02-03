`timescale 1ns / 1ps



module fake_axi4_salve

#(parameter C_M00_AXI_ADDR_WIDTH = 32, 
  parameter C_M00_AXI_DATA_WIDTH = 256
)

(

//////////////////////////axi4///////////////////////////////////
output                                       m_axi4_aclk         , 
output                                       m_axi4_aresetn      , 

output    reg                             m_axi4_awready   = 1   , 
input    [ 3:0]                          m_axi4_awid          , 
input    [C_M00_AXI_ADDR_WIDTH-1:0]      m_axi4_awaddr        , 
input    [ 7:0]                          m_axi4_awlen         , 
input    [ 2:0]                          m_axi4_awsize        , 
input    [ 1:0]                          m_axi4_awburst       , 
input    [ 1:0]                          m_axi4_awlock        , 
input    [ 3:0]                          m_axi4_awcache       , 
input    [ 2:0]                          m_axi4_awprot        , 
input                                    m_axi4_awvalid       , 
input    [ 3:0]                          m_axi4_awqos         , 
input    [ 3:0]                          m_axi4_awregion      , 
output    reg                                m_axi4_wready  = 1     , 
input    [ 3:0]                          m_axi4_wid          , 
input    [C_M00_AXI_DATA_WIDTH-1:0]      m_axi4_wdata        , 
input    [15:0]                          m_axi4_wstrb        , 
input                                    m_axi4_wlast        , 
input                                    m_axi4_wvalid       , 
output   [ 3:0]                              m_axi4_bid          , 
output   [ 1:0]                              m_axi4_bresp        , 
output    reg                               m_axi4_bvalid   = 0    , 
input                                      m_axi4_bready       , 
output    reg                               m_axi4_arready   = 0   , 
input    [ 3:0]                          m_axi4_arid          , 
input    [C_M00_AXI_ADDR_WIDTH-1:0]      m_axi4_araddr        , 
input    [ 7:0]                          m_axi4_arlen         , 
input    [ 2:0]                          m_axi4_arsize        , 
input    [ 1:0]                          m_axi4_arburst       , 
input    [ 0:0]                          m_axi4_arlock        , 
input    [ 3:0]                          m_axi4_arcache       , 
input    [ 2:0]                          m_axi4_arprot        , 
input                                    m_axi4_arvalid       , 
input    [ 3:0]                          m_axi4_arqos         , 
input    [ 3:0]                          m_axi4_arregion      , 
output   [ 3:0]                              m_axi4_rid          , 
output   [ 1:0]                              m_axi4_rresp        , 
output   reg                                m_axi4_rvalid    = 0   , 
output   [C_M00_AXI_DATA_WIDTH-1:0]          m_axi4_rdata        , 
output                                       m_axi4_rlast        , 
input                                        m_axi4_rready           

     
               

);









endmodule



