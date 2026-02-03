`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/06 09:56:29
// Design Name: 
// Module Name: xadc_reader
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


module xadc_reader(
input  wire                                 S_AXI_ACLK      ,
input  wire                                 S_AXI_ARESETN   ,
output wire                                 S_AXI_AWREADY   ,
input  wire [16-1:0]                        S_AXI_AWADDR    ,
input  wire                                 S_AXI_AWVALID   ,
input  wire [ 2:0]                          S_AXI_AWPROT    ,
output wire                                 S_AXI_WREADY    ,
input  wire [32-1:0]                        S_AXI_WDATA     ,
input  wire [(32/8)-1 :0]                   S_AXI_WSTRB     ,
input  wire                                 S_AXI_WVALID    ,
output wire [ 1:0]                          S_AXI_BRESP     ,
output wire                                 S_AXI_BVALID    ,
input  wire                                 S_AXI_BREADY    ,
output wire                                 S_AXI_ARREADY   ,
input  wire [16-1:0]                        S_AXI_ARADDR    ,
input  wire                                 S_AXI_ARVALID   ,
input  wire [ 2:0]                          S_AXI_ARPROT    ,
output wire [ 1:0]                          S_AXI_RRESP     ,
output wire                                 S_AXI_RVALID    ,
output wire [32-1:0]                        S_AXI_RDATA     ,
input  wire                                 S_AXI_RREADY    , 
input  wire [11:0]                          xadc_temp_i     

    );
    

wire         write_req_cpu_to_axi   ;
wire [15:0]  write_addr_cpu_to_axi ;
wire [31:0]  write_data_cpu_to_axi ;
wire         read_req_cpu_to_axi   ;
wire [15:0]  read_addr_cpu_to_axi  ;
reg [31:0]   read_data_axi_to_cpu  ;
reg          read_finish_axi_to_cpu;


 axi_lite_slave #(.C_S_AXI_DATA_WIDTH (32),
                  .C_S_AXI_ADDR_WIDTH (16))       
    axi_lite_slave_u (

.S_AXI_ACLK            (S_AXI_ACLK    ),
.S_AXI_ARESETN         (S_AXI_ARESETN ),
.S_AXI_AWREADY         (S_AXI_AWREADY ),
.S_AXI_AWADDR          (S_AXI_AWADDR  ),
.S_AXI_AWVALID         (S_AXI_AWVALID ),
.S_AXI_AWPROT          (S_AXI_AWPROT  ),
.S_AXI_WREADY          (S_AXI_WREADY  ),
.S_AXI_WDATA           (S_AXI_WDATA   ),
.S_AXI_WSTRB           (S_AXI_WSTRB   ),
.S_AXI_WVALID          (S_AXI_WVALID  ),
.S_AXI_BRESP           (S_AXI_BRESP   ),
.S_AXI_BVALID          (S_AXI_BVALID  ),
.S_AXI_BREADY          (S_AXI_BREADY  ),
.S_AXI_ARREADY         (S_AXI_ARREADY ),
.S_AXI_ARADDR          (S_AXI_ARADDR  ),
.S_AXI_ARVALID         (S_AXI_ARVALID ),
.S_AXI_ARPROT          (S_AXI_ARPROT  ),
.S_AXI_RRESP           (S_AXI_RRESP   ),
.S_AXI_RVALID          (S_AXI_RVALID  ),
.S_AXI_RDATA           (S_AXI_RDATA   ),
.S_AXI_RREADY          (S_AXI_RREADY  ),
.write_req_cpu_to_axi  (write_req_cpu_to_axi  ),
.write_addr_cpu_to_axi (write_addr_cpu_to_axi ),
.write_data_cpu_to_axi (write_data_cpu_to_axi ),
.read_req_cpu_to_axi   (read_req_cpu_to_axi   ),
.read_addr_cpu_to_axi  (read_addr_cpu_to_axi  ),
.read_data_axi_to_cpu  (read_data_axi_to_cpu  ),
.read_finish_axi_to_cpu(read_finish_axi_to_cpu)   
      
);

reg [11:0] xadc_temp_buf;
always @(posedge S_AXI_ACLK) begin
    if(~S_AXI_ARESETN)begin
        xadc_temp_buf <= 0;
    end
    else begin
        xadc_temp_buf <= xadc_temp_i;
    end
end


  
always@( posedge S_AXI_ACLK )begin
    if(~S_AXI_ARESETN)begin
        read_data_axi_to_cpu    <= 0;
        read_finish_axi_to_cpu  <= 0;
    end
    else begin
        if(read_req_cpu_to_axi)begin
            read_finish_axi_to_cpu <= 1;
            read_data_axi_to_cpu   <= xadc_temp_buf;
        end
        else begin
            read_finish_axi_to_cpu <= 0;
        end
    end
end
   
    
endmodule




