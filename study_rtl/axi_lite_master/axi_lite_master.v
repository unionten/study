`timescale 1ns / 1ps
`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define NEG_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/01 14:18:41
// Design Name: 
// Module Name: axi_lite_master
//////////////////////////////////////////////////////////////////////////////////
//input  wire                                 S_AXI_ACLK      ,
//input  wire                                 S_AXI_ARESETN   ,
//output wire                                 S_AXI_AWREADY   ,
//input  wire [C_S_AXI_ADDR_WIDTH-1:0]        S_AXI_AWADDR    ,
//input  wire                                 S_AXI_AWVALID   ,
//input  wire [ 2:0]                          S_AXI_AWPROT    ,
//output wire                                 S_AXI_WREADY    ,
//input  wire [C_S_AXI_DATA_WIDTH-1:0]        S_AXI_WDATA     ,
//input  wire [(C_S_AXI_DATA_WIDTH/8)-1 :0]   S_AXI_WSTRB     ,
//input  wire                                 S_AXI_WVALID    ,
//output wire [ 1:0]                          S_AXI_BRESP     ,
//output wire                                 S_AXI_BVALID    ,
//input  wire                                 S_AXI_BREADY    ,
//output wire                                 S_AXI_ARREADY   ,
//input  wire [C_S_AXI_ADDR_WIDTH-1:0]        S_AXI_ARADDR    ,
//input  wire                                 S_AXI_ARVALID   ,
//input  wire [ 2:0]                          S_AXI_ARPROT    ,
//output wire [ 1:0]                          S_AXI_RRESP     ,
//output wire                                 S_AXI_RVALID    ,
//output wire [C_S_AXI_DATA_WIDTH-1:0]        S_AXI_RDATA     ,
//input  wire                                 S_AXI_RREADY    ,
//reg S_LB_WREQ        ;
//reg [15:0] S_LB_WADDR;
//reg [31:0] S_LB_WDATA;
//reg S_LB_RREQ         ;
//reg [15:0] S_LB_RADDR ;
// 
// 
//axi_lite_master #(.C_M_AXI_ADDR_WIDTH(16),
//                  .C_M_AXI_DATA_WIDTH(32))
//    axi_lite_master_u(                                                                  //                                           //
//    .S_LB_WREQ   (S_LB_WREQ  ),                                                         //
//    .S_LB_WADDR  (S_LB_WADDR ),          //[C_M_AXI_ADDR_WIDTH-1:0]                        //
//    .S_LB_WDATA  (S_LB_WDATA ),         //[C_M_AXI_DATA_WIDTH-1 : 0]                       //
//    .S_LB_RREQ    (S_LB_RREQ   ),                                                         // [C_M_AXI_ADDR_WIDTH-1 : 0]   AXI_AWADDR  
//    .S_LB_RADDR   (S_LB_RADDR  ),        //[C_M_AXI_ADDR_WIDTH-1:0]                       // [2 : 0]                      AXI_AWPROT  
//    .M_AXI_ACLK             (AXI_ACLK    ),                                             //   AXI_AWVALID 
//    .M_AXI_ARESETN          (AXI_ARESETN ),                                             //   AXI_AWREADY 
//    .M_AXI_AWADDR           (AXI_AWADDR  ),//[C_M_AXI_ADDR_WIDTH-1 : 0]                 // [C_M_AXI_DATA_WIDTH-1 : 0]    AXI_WDATA   
//    .M_AXI_AWPROT           (AXI_AWPROT  ),//[2 : 0]                                    //  [C_M_AXI_DATA_WIDTH/8-1 : 0] AXI_WSTRB   
//    .M_AXI_AWVALID          (AXI_AWVALID ),                                             //   AXI_WVALID  
//    .M_AXI_AWREADY          (AXI_AWREADY ),                                             //   AXI_WREADY  
//    .M_AXI_WDATA            (AXI_WDATA   ),//[C_M_AXI_DATA_WIDTH-1 : 0]                 // [1 : 0]    AXI_BRESP   
//    .M_AXI_WSTRB            (AXI_WSTRB   ),//[C_M_AXI_DATA_WIDTH/8-1 : 0]               //   AXI_BVALID  
//    .M_AXI_WVALID           (AXI_WVALID  ),                                             //   AXI_BREADY  
//    .M_AXI_WREADY           (AXI_WREADY  ),                                             // [C_M_AXI_ADDR_WIDTH-1 : 0]   AXI_ARADDR  
//    .M_AXI_BRESP            (AXI_BRESP   ), // [1 : 0]                                  // [2 : 0]  AXI_ARPROT  
//    .M_AXI_BVALID           (AXI_BVALID  ),                                             //   AXI_ARVALID 
//    .M_AXI_BREADY           (AXI_BREADY  ),                                             //   AXI_ARREADY 
//    .M_AXI_ARADDR           (AXI_ARADDR  ),//[C_M_AXI_ADDR_WIDTH-1 : 0]                 //  [C_M_AXI_DATA_WIDTH-1 : 0] AXI_RDATA   
//    .M_AXI_ARPROT           (AXI_ARPROT  ),// [2 : 0]                                   //   AXI_RRESP   
//    .M_AXI_ARVALID          (AXI_ARVALID ),                                             //   AXI_RVALID  
//    .M_AXI_ARREADY          (AXI_ARREADY ),                                             //   AXI_RREADY  
//    .M_AXI_RDATA            (AXI_RDATA   ),//[C_M_AXI_DATA_WIDTH-1 : 0]                 //
//    .M_AXI_RRESP            (AXI_RRESP   ),//[1 : 0]                                    //
//    .M_AXI_RVALID           (AXI_RVALID  ),                                             //
//    .M_AXI_RREADY           (AXI_RREADY  )                                              //
//    );

module axi_lite_master #(
parameter integer C_M_AXI_ADDR_WIDTH    = 16,
parameter integer C_M_AXI_DATA_WIDTH    = 32
)
(
output  WRITE_ERR,
output  READ_ERR,
//USER INERFACE

input S_LB_WREQ,
output reg S_LB_WBUSY,
input [C_M_AXI_ADDR_WIDTH-1:0]  S_LB_WADDR,
input [C_M_AXI_DATA_WIDTH-1 : 0]  S_LB_WDATA,
input S_LB_RREQ, 
input [C_M_AXI_ADDR_WIDTH-1:0] S_LB_RADDR,
output  [C_M_AXI_DATA_WIDTH-1 : 0]  S_LB_RDATA , 
output reg S_LB_RBUSY,
output  S_LB_RFINISH,


//AXI-LITE INTERFACE
input wire  M_AXI_ACLK,
input wire  M_AXI_ARESETN,
output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
output wire [2 : 0] M_AXI_AWPROT,
output wire  M_AXI_AWVALID,
input wire  M_AXI_AWREADY,
output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
output wire  M_AXI_WVALID,
input wire  M_AXI_WREADY,
input wire [1 : 0] M_AXI_BRESP,
input wire  M_AXI_BVALID,
output wire  M_AXI_BREADY,
output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,
output wire [2 : 0] M_AXI_ARPROT,
output wire M_AXI_ARVALID,
input wire  M_AXI_ARREADY,
input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,
input wire [1 : 0] M_AXI_RRESP,
input wire  M_AXI_RVALID,
output wire  M_AXI_RREADY
);

    // AXI4LITE signals
    //write address valid
    reg      axi_awvalid;
    //write data valid
    reg      axi_wvalid;
    //read address valid
    reg      axi_arvalid;
    //read data acceptance
    reg      axi_rready;
    //write response acceptance
    reg      axi_bready;
    //write address
    reg [C_M_AXI_ADDR_WIDTH-1 : 0]     axi_awaddr;
    //write data
    reg [C_M_AXI_DATA_WIDTH-1 : 0]     axi_wdata;
    //read addresss
    reg [C_M_AXI_ADDR_WIDTH-1 : 0]     axi_araddr;
    //Asserts when there is a write response error
    wire      write_resp_error;
    //Asserts when there is a read response error
    wire      read_resp_error;

    // I/O Connections assignments
    assign M_AXI_AWADDR    = axi_awaddr;
    
    //AXI 4 write data
    assign M_AXI_WDATA    = axi_wdata;
    assign M_AXI_AWPROT    = 3'b000;
    assign M_AXI_AWVALID    = axi_awvalid;
    //Write Data(W)
    assign M_AXI_WVALID    = axi_wvalid;
    //Set all byte strobes in this example
    assign M_AXI_WSTRB    = 4'b1111;
    //Write Response (B)
    assign M_AXI_BREADY    = axi_bready;
    //Read Address (AR)
    assign M_AXI_ARADDR    = axi_araddr;
    assign M_AXI_ARVALID    = axi_arvalid;
    assign M_AXI_ARPROT    = 3'b001;
    //Read and Read Response (R)
    assign M_AXI_RREADY    = axi_rready;

    assign WRITE_ERR = write_resp_error;
    assign READ_ERR  = read_resp_error;

    //----------------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------
    //Write Address Channel ------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------
    

    // The purpose of the write address channel is to request the address and 
    // command information for the entire transaction.  It is a single beat
    // of information.

    // Note for this example the axi_awvalid/axi_wvalid are asserted at the same
    // time, and then each is deasserted independent from each other.
    // This is a lower-performance, but simplier control scheme.

    // AXI VALID signals must be held active until accepted by the partner.

    // A data transfer is accepted by the slave when a master has
    // VALID data and the slave acknoledges it is also READY. While the master
    // is allowed to generated multiple, back-to-back requests by not 
    // deasserting VALID, this design will add rest cycle for
    // simplicity.

    // Since only one outstanding transaction is issued by the user design,
    // there will not be a collision between a new request and an accepted
    // request on the same clock cycle. 

    always@(posedge M_AXI_ACLK)begin
        if(~M_AXI_ARESETN)begin
            S_LB_WBUSY <= 0;
        end
        else begin
            if (S_LB_WREQ) S_LB_WBUSY <= 1;
            else if(axi_bready_neg) S_LB_WBUSY <= 0;
        end
    end

      always @(posedge M_AXI_ACLK)                                              
      begin                                                                        
        //Only VALID signals must be deasserted during reset per AXI spec          
        //Consider inverting then registering active-low reset for higher fmax     
        if (M_AXI_ARESETN == 0  )                                                   
          begin                 
            axi_awaddr <= 0;
            axi_wdata <= 0;
            axi_awvalid <= 1'b0;                                                   
          end                                                                      
          //Signal a new address/data command is available by user logic           
        else                                                                       
          begin                                                                    
            if (S_LB_WREQ)                                                
              begin   
                axi_awvalid <= 1'b1;      
                axi_wdata <= S_LB_WDATA;
                axi_awaddr <= S_LB_WADDR;
              end                                                                  
         //Address accepted by interconnect/slave (issue of M_AXI_AWREADY by slave)
            else if (M_AXI_AWREADY && axi_awvalid)                                 
              begin                                                                
                axi_awvalid <= 1'b0;                                               
              end                                                                  
          end                                                                      
      end                                                                          
                                                                                                                                                   

    //----------------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------
    //Write Data Channel ---------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------

    //The write data channel is for transfering the actual data.
    //The data generation is speific to the example design, and 
    //so only the WVALID/WREADY handshake is shown here

       always @(posedge M_AXI_ACLK)                                        
       begin                                                                         
         if (M_AXI_ARESETN == 0 )                                                    
           begin                                                                     
             axi_wvalid <= 1'b0;                                                     
           end                                                                       
         //Signal a new address/data command is available by user logic              
         else if (S_LB_WREQ)                                                
           begin                                                                     
             axi_wvalid <= 1'b1;                                                     
           end                                                                       
         //Data accepted by interconnect/slave (issue of M_AXI_WREADY by slave)      
         else if (M_AXI_WREADY && axi_wvalid)                                        
           begin                                                                     
            axi_wvalid <= 1'b0;                                                      
           end                                                                       
       end                                                                           

    
    //----------------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------
    //Write Response (B) Channel -------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------

    //The write response channel provides feedback that the write has committed
    //to memory. BREADY will occur after both the data and the write address
    //has arrived and been accepted by the slave, and can guarantee that no
    //other accesses launched afterwards will be able to be reordered before it.

    //The BRESP bit [1] is used indicate any errors from the interconnect or
    //slave for the entire write burst. This example will capture the error.

    //While not necessary per spec, it is advisable to reset READY signals in
    //case of differing reset latencies between master/slave.

wire axi_bready_neg;
`NEG_MONITOR_OUTGEN(M_AXI_ACLK,0,axi_bready,axi_bready_neg)


      always @(posedge M_AXI_ACLK)                                    
      begin                                                                
        if (M_AXI_ARESETN == 0 )                                           
          begin                                                            
            axi_bready <= 1'b0;                                            
          end                                                              
        // accept/acknowledge bresp with axi_bready by the master          
        // when M_AXI_BVALID is asserted by slave                          
        else if (M_AXI_BVALID && ~axi_bready)                              
          begin                                                            
            axi_bready <= 1'b1;                                            
          end                                                              
        // deassert after one clock cycle                                  
        else if (axi_bready)                                               
          begin                                                            
            axi_bready <= 1'b0;                                            
          end                                                              
        // retain the previous value                                       
        else                                                               
          axi_bready <= axi_bready;                                        
      end                                                                  
                                                                           
    //Flag write errors                                                    
    assign write_resp_error = (axi_bready & M_AXI_BVALID & M_AXI_BRESP[1]);

    
    
    //----------------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------
    //Read Address Channel -------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------
                                                                 
      always @(posedge M_AXI_ACLK)                                                     
      begin                                                                            
        if (M_AXI_ARESETN == 0 )                                                       
          begin                    
            axi_araddr <= 0;
            axi_arvalid <= 1'b0;                                                       
          end                                                                          
        //Signal a new read address command is available by user logic                 
        else if (S_LB_RREQ)                                                    
          begin                                                                        
            axi_arvalid <= 1'b1;   
            axi_araddr <= S_LB_RADDR;           
          end                                                                          
        //RAddress accepted by interconnect/slave (issue of M_AXI_ARREADY by slave)    
        else if (M_AXI_ARREADY && axi_arvalid)                                         
          begin                                                                        
            axi_arvalid <= 1'b0;                                                       
          end                                                                          
        // retain the previous value                                                   
      end                                                                              

    
    
    //----------------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------
    //Read Data (and Response) Channel -------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------
    

    //The Read Data channel returns the results of the read request 
    //The master will accept the read data by asserting axi_rready
    //when there is a valid read data available.
    //While not necessary per spec, it is advisable to reset READY signals in
    //case of differing reset latencies between master/slave.


always@(posedge M_AXI_ACLK)begin
    if(~M_AXI_ARESETN)begin
        S_LB_RBUSY <= 0;
    end
    else if(S_LB_RREQ) S_LB_RBUSY  <= 1;
    else if(S_LB_RFINISH)  S_LB_RBUSY <= 0;

end

assign S_LB_RFINISH = M_AXI_RVALID && axi_rready ;
assign S_LB_RDATA =  M_AXI_RDATA ;


      always @(posedge M_AXI_ACLK)                                    
      begin                                                                 
        if (M_AXI_ARESETN == 0 )                                            
          begin         
            //S_LB_RFINISH <= 0;
            axi_rready <= 1'b0;     
            //S_LB_RDATA <= 0;
          end                                                               
        // accept/acknowledge rdata/rresp with axi_rready by the master     
        // when M_AXI_RVALID is asserted by slave                           
        else if (M_AXI_RVALID && ~axi_rready)begin                                                             
            axi_rready <= 1'b1;       
            //S_LB_RDATA <= M_AXI_RDATA  ;
            
            //if(S_LB_RFINISH)S_LB_RFINISH <= 0;
            //else S_LB_RFINISH <= 1;
        end    

        // deassert after one clock cycle                                   
        else if (axi_rready)                                                
          begin                                                             
            axi_rready <= 1'b0;     
            //S_LB_RFINISH <= 0;            
          end                                                               
        // retain the previous value                                        
      end                                                                   
                                                                            
    //Flag write errors                                                     
    assign read_resp_error = (axi_rready & M_AXI_RVALID & M_AXI_RRESP[1]);  


    endmodule
    
    
    
