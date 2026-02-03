`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: 
// Module Name:
//////////////////////////////////////////////////////////////////////////////////
module fake_axi_lite_slave
#(
parameter C_S_AXI_DATA_WIDTH = 32,
parameter C_S_AXI_ADDR_WIDTH = 16
)

(
(*keep="true"*)input  wire                                 S_AXI_ACLK      , 
(*keep="true"*)input  wire                                 S_AXI_ARESETN   ,
(*keep="true"*)output wire                                 S_AXI_AWREADY   ,
(*keep="true"*)input  wire [C_S_AXI_ADDR_WIDTH-1:0]        S_AXI_AWADDR    ,
(*keep="true"*)input  wire                                 S_AXI_AWVALID   ,
(*keep="true"*)input  wire [ 2:0]                          S_AXI_AWPROT    ,
(*keep="true"*)output wire                                 S_AXI_WREADY    ,
(*keep="true"*)input  wire [C_S_AXI_DATA_WIDTH-1:0]        S_AXI_WDATA     ,
(*keep="true"*)input  wire [(C_S_AXI_DATA_WIDTH/8)-1 :0]   S_AXI_WSTRB ,
(*keep="true"*)input  wire                                 S_AXI_WVALID    ,
(*keep="true"*)output wire [ 1:0]                          S_AXI_BRESP     ,
(*keep="true"*)output wire                                 S_AXI_BVALID    ,
(*keep="true"*)input  wire                                 S_AXI_BREADY    ,
(*keep="true"*)output wire                                 S_AXI_ARREADY   ,
(*keep="true"*)input  wire [C_S_AXI_ADDR_WIDTH-1:0]        S_AXI_ARADDR    ,
(*keep="true"*)input  wire                                 S_AXI_ARVALID   ,
(*keep="true"*)input  wire [ 2:0]                          S_AXI_ARPROT    ,
(*keep="true"*)output wire [ 1:0]                          S_AXI_RRESP     ,
(*keep="true"*)output wire                                 S_AXI_RVALID    ,
(*keep="true"*)output wire [C_S_AXI_DATA_WIDTH-1:0]        S_AXI_RDATA     ,
(*keep="true"*)input  wire                                 S_AXI_RREADY    

);


(*keep="true"*)wire write_req_cpu_to_axi                            ;
(*keep="true"*)wire [C_S_AXI_ADDR_WIDTH-1:0] write_addr_cpu_to_axi  ;
(*keep="true"*)wire [C_S_AXI_DATA_WIDTH-1:0] write_data_cpu_to_axi  ;
(*keep="true"*)wire read_req_cpu_to_axi                             ;
(*keep="true"*)wire [C_S_AXI_ADDR_WIDTH-1:0] read_addr_cpu_to_axi   ;
(*keep="true"*)wire [C_S_AXI_DATA_WIDTH-1:0] read_data_axi_to_cpu   ;
(*keep="true"*)wire read_finish_axi_to_cpu                          ;
axi_lite_slave 
    #(.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
      .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)) 
    axi_lite_slave_u(
    .S_AXI_ACLK            (S_AXI_ACLK),
    .S_AXI_ARESETN         (S_AXI_ARESETN),
    .S_AXI_AWREADY         (S_AXI_AWREADY),
    .S_AXI_AWADDR          (S_AXI_AWADDR),
    .S_AXI_AWVALID         (S_AXI_AWVALID),
    .S_AXI_AWPROT          (S_AXI_AWPROT),
    .S_AXI_WREADY          (S_AXI_WREADY),
    .S_AXI_WDATA           (S_AXI_WDATA),
    .S_AXI_WSTRB           (S_AXI_WSTRB),
    .S_AXI_WVALID          (S_AXI_WVALID),
    .S_AXI_BRESP           (S_AXI_BRESP),
    .S_AXI_BVALID          (S_AXI_BVALID),
    .S_AXI_BREADY          (S_AXI_BREADY),
    .S_AXI_ARREADY         (S_AXI_ARREADY),
    .S_AXI_ARADDR          (S_AXI_ARADDR),
    .S_AXI_ARVALID         (S_AXI_ARVALID),
    .S_AXI_ARPROT          (S_AXI_ARPROT),
    .S_AXI_RRESP           (S_AXI_RRESP),
    .S_AXI_RVALID          (S_AXI_RVALID),
    .S_AXI_RDATA           (S_AXI_RDATA),
    .S_AXI_RREADY          (S_AXI_RREADY),
    .write_req_cpu_to_axi  (write_req_cpu_to_axi),
    .write_addr_cpu_to_axi (write_addr_cpu_to_axi),
    .write_data_cpu_to_axi (write_data_cpu_to_axi),
    .read_req_cpu_to_axi   (read_req_cpu_to_axi),
    .read_addr_cpu_to_axi  (read_addr_cpu_to_axi),
    .read_data_axi_to_cpu  (0),
    .read_finish_axi_to_cpu(1)     
    );



endmodule



