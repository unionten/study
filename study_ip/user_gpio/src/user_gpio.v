`timescale 1ns / 1ps
`define  ADDR_GPIO_O   16'h0000
`define  ADDR_GPIO_I   16'h0004




//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/28 11:19:17
// Design Name: 
// Module Name: usr_gpio
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////
//说明：用户在fpga程序内部提供，收用户控制的gpio

module user_gpio(
  
input  wire                                      S_AXI_ACLK      ,
input  wire                                      S_AXI_ARESETN   ,
output wire                                      S_AXI_AWREADY   ,
input  wire [C_AXI_LITE_ADDR_WIDTH-1:0]          S_AXI_AWADDR    ,
input  wire                                      S_AXI_AWVALID   ,
input  wire [ 2:0]                               S_AXI_AWPROT    ,
output wire                                      S_AXI_WREADY    ,
input  wire [C_AXI_LITE_DATA_WIDTH-1:0]          S_AXI_WDATA     ,
input  wire [(C_AXI_LITE_DATA_WIDTH/8)-1 :0]     S_AXI_WSTRB     ,
input  wire                                      S_AXI_WVALID    ,
output wire [ 1:0]                               S_AXI_BRESP     ,
output wire                                      S_AXI_BVALID    ,
input  wire                                      S_AXI_BREADY    ,
output wire                                      S_AXI_ARREADY   ,
input  wire [C_AXI_LITE_ADDR_WIDTH-1:0]          S_AXI_ARADDR    ,
input  wire                                      S_AXI_ARVALID   ,
input  wire [ 2:0]                               S_AXI_ARPROT    ,
output wire [ 1:0]                               S_AXI_RRESP     ,
output wire                                      S_AXI_RVALID    ,
output wire [C_AXI_LITE_DATA_WIDTH-1:0]          S_AXI_RDATA     ,
input  wire                                      S_AXI_RREADY    ,


output reg [31:0]  USER_GPIO_O = C_GPIO_O_DEFAULT,
output reg         USER_GPIO_EN_O  = 0 ,
input      [31:0]  USER_GPIO_I


    );

parameter  C_AXI_LITE_ADDR_WIDTH =  16;
parameter  C_AXI_LITE_DATA_WIDTH =  32;
parameter  [31:0]  C_GPIO_O_DEFAULT = 32'b00000000_00000000_00000000_00000000;
parameter  [0:0]   C_ILA_ENABLE = 0 ;


wire  write_req_cpu_to_axi   ;
wire  [C_AXI_LITE_ADDR_WIDTH-1:0] write_addr_cpu_to_axi  ;
wire [C_AXI_LITE_DATA_WIDTH-1:0] write_data_cpu_to_axi  ;
wire read_req_cpu_to_axi    ;
wire  [C_AXI_LITE_ADDR_WIDTH-1:0]  read_addr_cpu_to_axi   ;
reg [C_AXI_LITE_DATA_WIDTH-1:0] read_data_axi_to_cpu   ;
reg read_finish_axi_to_cpu ;


axi_lite_slave #(
    .C_S_AXI_ADDR_WIDTH (C_AXI_LITE_ADDR_WIDTH  ),
    .C_S_AXI_DATA_WIDTH (C_AXI_LITE_DATA_WIDTH  )
     
    )
    axi_lite_slave_u(

    .S_AXI_ACLK            (S_AXI_ACLK        ),     //input  wire                              
    .S_AXI_ARESETN         (S_AXI_ARESETN     ),     //input  wire                              
    .S_AXI_AWREADY         (S_AXI_AWREADY     ),     //output wire                              
    .S_AXI_AWADDR          (S_AXI_AWADDR      ),     //input  wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .S_AXI_AWVALID         (S_AXI_AWVALID     ),     //input  wire                              
    .S_AXI_AWPROT          (S_AXI_AWPROT      ),     //input  wire [ 2:0]                       
    .S_AXI_WREADY          (S_AXI_WREADY      ),     //output wire                              
    .S_AXI_WDATA           (S_AXI_WDATA       ),     //input  wire [C_S_AXI_DATA_WIDTH-1:0]     
    .S_AXI_WSTRB           (S_AXI_WSTRB       ),         //input  wire [(C_S_AXI_DATA_WIDTH/8)-1 :0]
    .S_AXI_WVALID          (S_AXI_WVALID      ),     //input  wire                              
    .S_AXI_BRESP           (S_AXI_BRESP       ),     //output wire [ 1:0]                       
    .S_AXI_BVALID          (S_AXI_BVALID      ),     //output wire                              
    .S_AXI_BREADY          (S_AXI_BREADY      ),     //input  wire                              
    .S_AXI_ARREADY         (S_AXI_ARREADY     ),     //output wire                              
    .S_AXI_ARADDR          (S_AXI_ARADDR      ),     //input  wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .S_AXI_ARVALID         (S_AXI_ARVALID     ),     //input  wire                              
    .S_AXI_ARPROT          (S_AXI_ARPROT      ),     //input  wire [ 2:0]                       
    .S_AXI_RRESP           (S_AXI_RRESP       ),     //output wire [ 1:0]                       
    .S_AXI_RVALID          (S_AXI_RVALID      ),     //output wire                              
    .S_AXI_RDATA           (S_AXI_RDATA       ),     //output wire [C_S_AXI_DATA_WIDTH-1:0]     
    .S_AXI_RREADY          (S_AXI_RREADY      ),     //input  wire                              
    
    .write_req_cpu_to_axi  (write_req_cpu_to_axi  ),    //wire                              
    .write_addr_cpu_to_axi (write_addr_cpu_to_axi ),   //wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .write_data_cpu_to_axi (write_data_cpu_to_axi ),   //wire [C_S_AXI_DATA_WIDTH-1:0]     
    .read_req_cpu_to_axi   (read_req_cpu_to_axi   ),     //wire                              
    .read_addr_cpu_to_axi  (read_addr_cpu_to_axi  ),    //wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .read_data_axi_to_cpu  (read_data_axi_to_cpu  ),    //wire [C_S_AXI_DATA_WIDTH-1:0]     
    .read_finish_axi_to_cpu(read_finish_axi_to_cpu)   //wire                              
      
);


always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        USER_GPIO_O <= C_GPIO_O_DEFAULT;
        USER_GPIO_EN_O <= 0;
    end
    else if(write_req_cpu_to_axi)begin
        case(write_addr_cpu_to_axi)
            `ADDR_GPIO_O : begin  USER_GPIO_O <= write_data_cpu_to_axi ;
                                  USER_GPIO_EN_O <= 1; 
                           end
            default:;
        endcase
    end
    else begin
        USER_GPIO_EN_O <= 0;
    end
end    



always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        read_data_axi_to_cpu <= 0;
        read_finish_axi_to_cpu <= 0;
    end
    else if(read_req_cpu_to_axi)begin
        read_finish_axi_to_cpu <= 1;
        case(read_addr_cpu_to_axi)
            `ADDR_GPIO_O : read_data_axi_to_cpu <= USER_GPIO_O  ;
            `ADDR_GPIO_I : read_data_axi_to_cpu <= USER_GPIO_I  ;
            default:;
        endcase
    end
    else begin
         read_finish_axi_to_cpu <= 0;
    end
end  


generate if(C_ILA_ENABLE)begin
ila_0  ila_0(
    .clk        (S_AXI_ACLK     ),
    .probe0     (write_addr_cpu_to_axi  ),
    .probe1     (write_data_cpu_to_axi  ),
    .probe2     (write_req_cpu_to_axi   ),
    .probe3     (USER_GPIO_I    ),
    .probe4     (USER_GPIO_O    )


);
end
endgenerate



    
    
endmodule
