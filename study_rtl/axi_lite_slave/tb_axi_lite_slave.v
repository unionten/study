`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/16 17:53:01
// Design Name: 
// Module Name: tb_axi_lite_slave
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


module tb_axi_lite_slave(

    );


reg clk;
reg rstn;
reg S_AXI_ARVALID;
 reg S_AXI_RREADY;
 reg read_finish_axi_to_cpu=0;

always #5 clk = ~clk;

initial begin
S_AXI_ARVALID = 0;


    clk = 0;
    rstn = 0;
    #500;
    rstn = 1;
    #995.5;
    
    S_AXI_ARVALID = 1;#20;S_AXI_ARVALID=0;
    //#20;
    
    #20;
    S_AXI_ARVALID = 1;#20;S_AXI_ARVALID=0;
    #200;

end

initial begin
read_finish_axi_to_cpu = 0;
#1516;

    read_finish_axi_to_cpu =1;
    #10;
    read_finish_axi_to_cpu = 0;
    
    #30;
    
    read_finish_axi_to_cpu =1;
    #10;
    read_finish_axi_to_cpu = 0;
    
end

initial begin
S_AXI_RREADY = 0;
#1535.5;
S_AXI_RREADY = 1;
#10;
S_AXI_RREADY = 0;


end


    
axi_lite_slave 
    axi_lite_slave_u
(
.S_AXI_ACLK             (clk),
.S_AXI_ARESETN          (rstn),
.S_AXI_AWREADY          ( ),
.S_AXI_AWADDR           ( ),
.S_AXI_AWVALID          ( ),
.S_AXI_AWPROT           ( ),
.S_AXI_WREADY           ( ),
.S_AXI_WDATA            ( ),
.S_AXI_WSTRB            ( ),
.S_AXI_WVALID           ( ),
.S_AXI_BRESP            ( ),
.S_AXI_BVALID           ( ),
.S_AXI_BREADY           ( ),

.S_AXI_ARREADY          (),
.S_AXI_ARADDR           (0),
.S_AXI_ARVALID          (S_AXI_ARVALID),
.S_AXI_ARPROT           (),
.S_AXI_RRESP            (),
.S_AXI_RVALID           (),
.S_AXI_RDATA            (),
.S_AXI_RREADY           (S_AXI_RREADY),
.write_req_cpu_to_axi  (),
.write_addr_cpu_to_axi (),
.write_data_cpu_to_axi (),
.read_req_cpu_to_axi   (),
.read_addr_cpu_to_axi  (),
.read_data_axi_to_cpu  (),
.read_finish_axi_to_cpu(read_finish_axi_to_cpu)   
      
);
  
    
    
endmodule
