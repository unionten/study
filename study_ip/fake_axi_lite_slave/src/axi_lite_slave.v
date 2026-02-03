//axi_lite_slave #(
//    .C_S_AXI_DATA_WIDTH (C_S_AXI_DATA_WIDTH),
//    .C_S_AXI_ADDR_WIDTH (C_S_AXI_ADDR_WIDTH))
//    axi_lite_slave_u(
//    .S_AXI_ACLK    (S_AXI_ACLK),
//    .S_AXI_ARESETN (S_AXI_ARESETN),
//    .S_AXI_AWREADY (S_AXI_AWREADY),
//    .S_AXI_AWADDR  (S_AXI_AWADDR ),
//    .S_AXI_AWVALID (S_AXI_AWVALID),
//    .S_AXI_AWPROT  (S_AXI_AWPROT ),
//    .S_AXI_WREADY  (S_AXI_WREADY ),
//    .S_AXI_WDATA   (S_AXI_WDATA  ),
//    .S_AXI_WSTRB   (S_AXI_WSTRB  ),
//    .S_AXI_WVALID  (S_AXI_WVALID ),
//    .S_AXI_BRESP   (S_AXI_BRESP  ),
//    .S_AXI_BVALID  (S_AXI_BVALID ),
//    .S_AXI_BREADY  (S_AXI_BREADY ),
//    .S_AXI_ARREADY (S_AXI_ARREADY),
//    .S_AXI_ARADDR  (S_AXI_ARADDR ),
//    .S_AXI_ARVALID (S_AXI_ARVALID),
//    .S_AXI_ARPROT  (S_AXI_ARPROT ),
//    .S_AXI_RRESP   (S_AXI_RRESP  ),
//    .S_AXI_RVALID  (S_AXI_RVALID ),
//    .S_AXI_RDATA   (S_AXI_RDATA  ),
//    .S_AXI_RREADY  (S_AXI_RREADY ),
//    //cpu写入
//    .write_req_cpu_to_axi     (write_req_cpu_to_axi   ),
//    .write_addr_cpu_to_axi    (write_addr_cpu_to_axi  ),
//    .write_data_cpu_to_axi    (write_data_cpu_to_axi  ),  
//    //cpu请求
//    .read_req_cpu_to_axi      (read_req_cpu_to_axi    ),
//    .read_addr_cpu_to_axi     (read_addr_cpu_to_axi   ),
//    .read_data_axi_to_cpu     (read_data_axi_to_cpu   ),
//    .read_finish_axi_to_cpu   (read_finish_axi_to_cpu ));

module axi_lite_slave #(
parameter integer  C_S_AXI_DATA_WIDTH    =  32 ,
parameter integer  C_S_AXI_ADDR_WIDTH    =  16    
)(

input  wire                             S_AXI_ACLK      ,
input  wire                             S_AXI_ARESETN   ,
output wire                             S_AXI_AWREADY   ,
input  wire [C_S_AXI_ADDR_WIDTH-1:0]    S_AXI_AWADDR    ,
input  wire                             S_AXI_AWVALID   ,
input  wire [ 2:0]                      S_AXI_AWPROT    ,
output wire                             S_AXI_WREADY    ,
input  wire [C_S_AXI_DATA_WIDTH-1:0]    S_AXI_WDATA     ,
input  wire [(C_S_AXI_DATA_WIDTH/8)-1 :0]   S_AXI_WSTRB ,
input  wire                             S_AXI_WVALID    ,
output wire [ 1:0]                      S_AXI_BRESP     ,
output wire                             S_AXI_BVALID    ,
input  wire                             S_AXI_BREADY    ,
output wire                             S_AXI_ARREADY   ,
input  wire [C_S_AXI_ADDR_WIDTH-1:0]    S_AXI_ARADDR    ,
input  wire                             S_AXI_ARVALID   ,
input  wire [ 2:0]                      S_AXI_ARPROT    ,
output wire [ 1:0]                      S_AXI_RRESP     ,
output wire                             S_AXI_RVALID    ,
output wire [C_S_AXI_DATA_WIDTH-1:0]    S_AXI_RDATA     ,
input  wire                             S_AXI_RREADY    ,

output wire                              write_req_cpu_to_axi,
output wire [C_S_AXI_ADDR_WIDTH-1:0]     write_addr_cpu_to_axi,
output wire [C_S_AXI_DATA_WIDTH-1:0]     write_data_cpu_to_axi,
output wire                              read_req_cpu_to_axi,
output wire [C_S_AXI_ADDR_WIDTH-1:0]     read_addr_cpu_to_axi,
input  wire [C_S_AXI_DATA_WIDTH-1:0]     read_data_axi_to_cpu,
input  wire                              read_finish_axi_to_cpu   
      
);

    localparam integer ADDR_LSB = 2 ;
    localparam integer OPT_MEM_ADDR_BITS = 5;

    reg [C_S_AXI_ADDR_WIDTH-1: 0]     axi_awaddr    ;
    reg                               axi_awready   ;
    reg                               axi_wready    ;
    reg [1 : 0]                       axi_bresp     ;
    reg                               axi_bvalid    ;
    reg [C_S_AXI_ADDR_WIDTH-1: 0]     axi_araddr    ;
    reg                               axi_arready   ;
    reg [C_S_AXI_DATA_WIDTH-1: 0]     axi_rdata     ;
    reg [1 : 0]                       axi_rresp     ;
    reg                               axi_rvalid    ;
    wire                              slv_reg_rden  ;
    wire                              slv_reg_wren  ;
    wire [C_S_AXI_DATA_WIDTH-1:0]     reg_data_out  ;
    wire                              w_data_out    ;


    assign S_AXI_AWREADY    = axi_awready;
    assign S_AXI_WREADY     = axi_wready;
    assign S_AXI_BRESP      = axi_bresp;
    assign S_AXI_BVALID     = axi_bvalid;
    assign S_AXI_ARREADY    = axi_arready;
    assign S_AXI_RDATA      = axi_rdata;
    assign S_AXI_RRESP      = axi_rresp;
    assign S_AXI_RVALID     = axi_rvalid;
    
    assign  reg_data_out= read_data_axi_to_cpu  ;
    assign  w_data_out  = read_finish_axi_to_cpu;

    always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin
          axi_awready <= 1'b0;
      end else begin    
          if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID) begin
              axi_awready <= 1'b1;
          end else begin
              axi_awready <= 1'b0;
          end
        end 
    end       

    always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin
          axi_awaddr <= 0;
      end else begin    
          if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID) begin
              axi_awaddr <= S_AXI_AWADDR;
          end else begin
              axi_awaddr <=  axi_awaddr;
          end
      end 
    end       

    always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin
          axi_wready <= 1'b0;
      end else begin    
          if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID) begin
              axi_wready <= 1'b1;
          end else begin
              axi_wready <= 1'b0;
          end
        end 
    end       

    assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

    always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 )  begin
          axi_bvalid  <= 0;
          axi_bresp   <= 2'b0;
      end else begin    
          if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID) begin
              axi_bvalid <= 1'b1;
              axi_bresp  <= 2'b0; 
          end else begin 
              if (S_AXI_BREADY && axi_bvalid) begin
                  axi_bvalid <= 1'b0; 
              end  
              else begin
                  axi_bvalid  <= 1'b0;
                  axi_bresp   <= 2'b0;
              end
          end
        end
    end   

    always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin
          axi_arready <= 1'b0;
          axi_araddr  <= 32'b0;
      end else begin    
          if (~axi_arready && S_AXI_ARVALID) begin
              axi_arready <= 1'b1;
              axi_araddr  <= S_AXI_ARADDR;
          end else begin
              axi_arready <= 1'b0;
          end
        end 
    end       
 
always @( posedge S_AXI_ACLK ) 
      if ( S_AXI_ARESETN == 1'b0 ) begin    
          axi_rvalid <= 0;
          axi_rresp  <= 0; 
      end
      else if(w_data_out)begin
        axi_rvalid <= 1'b1;
        axi_rresp  <= 2'b0; 
      end
      else if (axi_rvalid && S_AXI_RREADY) begin
        axi_rvalid <= 1'b0;
        axi_rresp  <= 2'b0;  
      end
      else begin
        axi_rvalid <= 1'b0;
        axi_rresp  <= 2'b0;  
      end    

assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid ;
    
always @ (posedge S_AXI_ACLK)
if(S_AXI_ARESETN == 1'b0 )       
    axi_rdata  <= 0;
else if(w_data_out)
    axi_rdata <= reg_data_out ; 
else if(axi_rvalid && S_AXI_RREADY)
    axi_rdata <=  axi_rdata;
else 
    axi_rdata  <= 0;

    assign    write_req_cpu_to_axi  = slv_reg_wren    ;
    assign    write_addr_cpu_to_axi     = axi_awaddr   ;
    assign    write_data_cpu_to_axi     = S_AXI_WDATA  ;
    
    assign    read_req_cpu_to_axi       = slv_reg_rden ;
    assign    read_addr_cpu_to_axi     = axi_araddr    ;

endmodule
