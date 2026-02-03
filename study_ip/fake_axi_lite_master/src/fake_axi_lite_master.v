`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/01 09:44:25
// Design Name: 
// Module Name: fake_axi_lite_master
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

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/01 14:18:41
// Design Name: 
// Module Name: axi_lite_master
//////////////////////////////////////////////////////////////////////////////////
//axi_lite_master #(.C_M_AXI_ADDR_WIDTH(32),
//                  .C_M_AXI_DATA_WIDTH(16))
//    axi_lite_master_u(
//    .WRITE_ERR              (WRITE_ERR),
//    .READ_ERR               (READ_ERR),
//    .write_req_cpu_to_axi   (),
//    .write_addr_cpu_to_axi  (),       //[C_M_AXI_ADDR_WIDTH-1:0] 
//    .write_data_cpu_to_axi  (),      //[C_M_AXI_DATA_WIDTH-1 : 0]
//    .read_req_cpu_to_axi    (), 
//    .read_addr_cpu_to_axi   (),        //[C_M_AXI_ADDR_WIDTH-1:0]
//    .M_AXI_ACLK             (AXI_ACLK    ),
//    .M_AXI_ARESETN          (AXI_ARESETN ),
//    .M_AXI_AWADDR           (AXI_AWADDR  ),//[C_M_AXI_ADDR_WIDTH-1 : 0] 
//    .M_AXI_AWPROT           (AXI_AWPROT  ),//[2 : 0]
//    .M_AXI_AWVALID          (AXI_AWVALID ),
//    .M_AXI_AWREADY          (AXI_AWREADY ),
//    .M_AXI_WDATA            (AXI_WDATA   ),//[C_M_AXI_DATA_WIDTH-1 : 0]
//    .M_AXI_WSTRB            (AXI_WSTRB   ),//[C_M_AXI_DATA_WIDTH/8-1 : 0]
//    .M_AXI_WVALID           (AXI_WVALID  ),
//    .M_AXI_WREADY           (AXI_WREADY  ),
//    .M_AXI_BRESP            (AXI_BRESP   ), // [1 : 0]
//    .M_AXI_BVALID           (AXI_BVALID  ),
//    .M_AXI_BREADY           (AXI_BREADY  ),
//    .M_AXI_ARADDR           (AXI_ARADDR  ),//[C_M_AXI_ADDR_WIDTH-1 : 0]
//    .M_AXI_ARPROT           (AXI_ARPROT  ),// [2 : 0]
//    .M_AXI_ARVALID          (AXI_ARVALID ),
//    .M_AXI_ARREADY          (AXI_ARREADY ),
//    .M_AXI_RDATA            (AXI_RDATA   ),//[C_M_AXI_DATA_WIDTH-1 : 0] 
//    .M_AXI_RRESP            (AXI_RRESP   ),//[1 : 0]
//    .M_AXI_RVALID           (AXI_RVALID  ),
//    .M_AXI_RREADY           (AXI_RREADY  )
//    );

module fake_axi_lite_master #(
parameter integer C_M_AXI_ADDR_WIDTH    = 32,
parameter integer C_M_AXI_DATA_WIDTH    = 32
)
(


//AXI-LITE INTERFACE
input wire  M_AXI_ACLK,
input wire  M_AXI_ARESETN,
output reg [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR = 0,
output reg [2 : 0] M_AXI_AWPROT = 0,
output reg  M_AXI_AWVALID = 0,
input wire  M_AXI_AWREADY,
output reg [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA = 0,
output reg [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB = 0,
output reg  M_AXI_WVALID = 0,
input wire  M_AXI_WREADY,
input wire [1 : 0] M_AXI_BRESP,
input wire  M_AXI_BVALID,
output reg  M_AXI_BREADY = 1,
output reg [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR = 0,
output reg [2 : 0] M_AXI_ARPROT = 0,
output reg M_AXI_ARVALID =0 ,
input wire  M_AXI_ARREADY,
input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,
input wire [1 : 0] M_AXI_RRESP,
input wire  M_AXI_RVALID,
output reg  M_AXI_RREADY = 1


);

wire test ;
assign test = ~M_AXI_ARESETN + M_AXI_AWREADY ;





 endmodule
    
    
    
