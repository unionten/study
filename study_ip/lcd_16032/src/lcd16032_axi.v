`timescale 1ns / 1ps

//reg table
//32'h0000  no.0 1 2  3 half charactor
//32'h0004  no.4 5 6  7 half charactor
//32'h0008  no.8 9 10 11 half charactor
//32'h000c  no.12 13 14 15 half charactor
//32'h0010  no.16 17 18 19 half charactor


//////////////////////////////////////////////////////////////////////////////////
// Engineer: yzhu
// Create Date: 2023/05/12 10:40:17
// Module Name: lcd16032_axi
//////////////////////////////////////////////////////////////////////////////////

module lcd16032_axi(
input                                            S_AXI_ACLK      ,
input                                            S_AXI_ARESETN   ,
output wire                                      S_AXI_AWREADY   ,
input  wire [C_AXI_ADDR_WIDTH-1:0]               S_AXI_AWADDR    ,
input  wire                                      S_AXI_AWVALID   ,
input  wire [ 2:0]                               S_AXI_AWPROT    ,
output wire                                      S_AXI_WREADY    ,
input  wire [C_AXI_DATA_WIDTH-1:0]               S_AXI_WDATA     ,
input  wire [(C_AXI_DATA_WIDTH/8)-1 :0]          S_AXI_WSTRB     ,
input  wire                                      S_AXI_WVALID    ,
output wire [ 1:0]                               S_AXI_BRESP     ,
output wire                                      S_AXI_BVALID    ,
input  wire                                      S_AXI_BREADY    ,
output wire                                      S_AXI_ARREADY   ,
input  wire [C_AXI_ADDR_WIDTH-1:0]               S_AXI_ARADDR    ,
input  wire                                      S_AXI_ARVALID   ,
input  wire [ 2:0]                               S_AXI_ARPROT    ,
output wire [ 1:0]                               S_AXI_RRESP     ,
output wire                                      S_AXI_RVALID    ,
output wire [C_AXI_DATA_WIDTH-1:0]               S_AXI_RDATA     ,
input  wire                                      S_AXI_RREADY    ,


output        LCD_CS_O      ,
output        LCD_SCK_O     ,
output        LCD_MOSI_O    

);

parameter C_AXI_DATA_WIDTH = 32;
parameter C_AXI_ADDR_WIDTH = 16;
parameter C_CLK_PRD_NS     = 10;
parameter [0:0] C_ILA_ENABLE = 0 ;


wire write_req_cpu_to_axi  ; 
wire [C_AXI_ADDR_WIDTH-1:0] write_addr_cpu_to_axi  ;
wire [C_AXI_DATA_WIDTH-1:0] write_data_cpu_to_axi ; 
wire read_req_cpu_to_axi   ; 
wire [C_AXI_ADDR_WIDTH-1:0] read_addr_cpu_to_axi  ; 
reg  [C_AXI_DATA_WIDTH-1:0] read_data_axi_to_cpu=0;   
reg  read_finish_axi_to_cpu =0;

axi_lite_slave #(
.C_S_AXI_DATA_WIDTH (C_AXI_DATA_WIDTH ),
.C_S_AXI_ADDR_WIDTH (C_AXI_ADDR_WIDTH )   
)(

.S_AXI_ACLK      (S_AXI_ACLK    ),     //input  wire                              
.S_AXI_ARESETN   (S_AXI_ARESETN ),     //input  wire                              
.S_AXI_AWREADY   (S_AXI_AWREADY ),     //output wire                              
.S_AXI_AWADDR    (S_AXI_AWADDR  ),     //input  wire [C_S_AXI_ADDR_WIDTH-1:0]     
.S_AXI_AWVALID   (S_AXI_AWVALID ),     //input  wire                              
.S_AXI_AWPROT    (S_AXI_AWPROT  ),     //input  wire [ 2:0]                       
.S_AXI_WREADY    (S_AXI_WREADY  ),     //output wire                              
.S_AXI_WDATA     (S_AXI_WDATA   ),     //input  wire [C_S_AXI_DATA_WIDTH-1:0]     
.S_AXI_WSTRB     (S_AXI_WSTRB   ),         //input  wire [(C_S_AXI_DATA_WIDTH/8)-1 :0]
.S_AXI_WVALID    (S_AXI_WVALID  ),     //input  wire                              
.S_AXI_BRESP     (S_AXI_BRESP   ),     //output wire [ 1:0]                       
.S_AXI_BVALID    (S_AXI_BVALID  ),     //output wire                              
.S_AXI_BREADY    (S_AXI_BREADY  ),     //input  wire                              
.S_AXI_ARREADY   (S_AXI_ARREADY ),     //output wire                              
.S_AXI_ARADDR    (S_AXI_ARADDR  ),     //input  wire [C_S_AXI_ADDR_WIDTH-1:0]     
.S_AXI_ARVALID   (S_AXI_ARVALID ),     //input  wire                              
.S_AXI_ARPROT    (S_AXI_ARPROT  ),     //input  wire [ 2:0]                       
.S_AXI_RRESP     (S_AXI_RRESP   ),     //output wire [ 1:0]                       
.S_AXI_RVALID    (S_AXI_RVALID  ),     //output wire                              
.S_AXI_RDATA     (S_AXI_RDATA   ),     //output wire [C_S_AXI_DATA_WIDTH-1:0]     
.S_AXI_RREADY    (S_AXI_RREADY  ),     //input  wire                              

.write_req_cpu_to_axi   (write_req_cpu_to_axi   ),    //wire                              
.write_addr_cpu_to_axi  (write_addr_cpu_to_axi  ),   //wire [C_S_AXI_ADDR_WIDTH-1:0]     
.write_data_cpu_to_axi  (write_data_cpu_to_axi  ),   //wire [C_S_AXI_DATA_WIDTH-1:0]     
.read_req_cpu_to_axi    (read_req_cpu_to_axi    ),     //wire                              
.read_addr_cpu_to_axi   (read_addr_cpu_to_axi   ),    //wire [C_S_AXI_ADDR_WIDTH-1:0]     
.read_data_axi_to_cpu   (read_data_axi_to_cpu   ),    //wire [C_S_AXI_DATA_WIDTH-1:0]     
.read_finish_axi_to_cpu (read_finish_axi_to_cpu )  //wire                              
      
);


always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        read_finish_axi_to_cpu <= 0;
        read_data_axi_to_cpu   <= 0;
    end
    else if(read_req_cpu_to_axi)begin
        read_finish_axi_to_cpu <= 1;
    end
    else begin
        read_finish_axi_to_cpu <= 0;
    end
end

wire ram_rd;
wire [9:0] ram_addr;
wire [7:0] ram_chr;

ram_rtl
    #(.WR_DATA_WIDTH (32   ),
      .WR_DATA_DEPTH (1024 ),
      .RD_DATA_WIDTH (8    ))//target : read depth = 8 * 40
  ram_u(
    .clka   (S_AXI_ACLK                  ),
    .wea    (write_req_cpu_to_axi        ),
    .addra  (write_addr_cpu_to_axi       ),
    .dina   (write_data_cpu_to_axi       ),
    .clkb   (S_AXI_ACLK                   ),
    .enb    (ram_rd                      ),
    .addrb  (ram_addr                    ),
    .doutb  (ram_chr                     ) 
    );


lcd16032  
    #(.C_SYS_CLK_PRD_NS (C_CLK_PRD_NS),
      .C_DIV            (1000.0/C_CLK_PRD_NS*1000.0/125), 
      .C_DELAY_PER_OP_US(200))
    lcd16032_u(
    .CLK_I         (S_AXI_ACLK     ),  // sync clk as you wish, such as 20M, 50M , ...
    .RST_I         (~S_AXI_ARESETN ),  // sync rst  
    .LCD_CS_O      (LCD_CS_O       ),  //must only be high  when MOSI is valid
    .LCD_SCK_O     (LCD_SCK_O      ),  //must only exists   when MOSI is valid
    .LCD_MOSI_O    (LCD_MOSI_O     ), 
    .RD_EN_O       (ram_rd         ), 
    .RD_ADDR_O     (ram_addr       ),  //[9:0] 0 to 39 
    .RD_CHR_I      (ram_chr        )   //[7:0] English charactor or half Chinese charactor
    );



generate if(C_ILA_ENABLE)begin
    ila_0  ila_0_u(
        .clk    (S_AXI_ACLK ),
        .probe0 (LCD_CS_O   ),
        .probe1 (LCD_SCK_O  ),
        .probe2 (LCD_MOSI_O ),
        .probe3 (ram_rd     ),
        .probe4 (ram_addr   ),
        .probe5 (ram_chr    )
    );
end
endgenerate



endmodule



