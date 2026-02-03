`timescale 1ns / 1ps

`define CDC_MULTI_BIT_SIGNAL_INGEN_NOIN(adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                     begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(0),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk( ),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end    



`define   ADDR_DEBUG_0_ID    16'h0000 
`define   ADDR_DEBUG_1_ID    16'h0004 
`define   ADDR_DEBUG_2_ID    16'h0008 
`define   ADDR_DEBUG_3_ID    16'h000C 

`define   ADDR_DEBUG_H32_0_ID    16'h0010 
`define   ADDR_DEBUG_H32_1_ID    16'h0014 
`define   ADDR_DEBUG_H32_2_ID    16'h0018 
`define   ADDR_DEBUG_H32_3_ID    16'h001C 

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:  
// Design Name:  debug_io_select
// Module Name:  
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////


module debug_io_select
 (
 
input  wire                                      S_AXI_ACLK      ,//总线时钟
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


 input [7:0] FSYNC_I             ,
 input [7:0] FSYNC_FILTER_I      ,
 input [7:0] VS_I                ,
 input [7:0] AUX_I               ,
 
 input [7:0] AUX2_I              ,
 input [7:0] AUX3_I              ,
 input [7:0] AUX4_I              ,
 input [7:0] AUX5_I              ,
 
 
 output [3:0] DEBUG_O 
 
 
 );
 
parameter C_AXI_LITE_ADDR_WIDTH  =  16 ; 
parameter C_AXI_LITE_DATA_WIDTH  =  32 ;

parameter [31:0] C_DEBUG_0_ID_DEFAULT = 32'b00000000_00000000_00000000_00000001 ;
parameter [31:0] C_DEBUG_1_ID_DEFAULT = 32'b00000000_00000000_00000001_00000000 ;
parameter [31:0] C_DEBUG_2_ID_DEFAULT = 32'b00000000_00000001_00000000_00000000 ;
parameter [31:0] C_DEBUG_3_ID_DEFAULT = 32'b00000001_00000000_00000000_00000000 ;

parameter [31:0] C_DEBUG_H32_0_ID_DEFAULT = 32'b00000000_00000000_00000000_00000000 ;
parameter [31:0] C_DEBUG_H32_1_ID_DEFAULT = 32'b00000000_00000000_00000000_00000000 ;
parameter [31:0] C_DEBUG_H32_2_ID_DEFAULT = 32'b00000000_00000000_00000000_00000000 ;
parameter [31:0] C_DEBUG_H32_3_ID_DEFAULT = 32'b00000000_00000000_00000000_00000000 ;



wire [7:0] FSYNC_I_aclk         ;
wire [7:0] FSYNC_FILTER_I_aclk  ;
wire [7:0] VS_I_aclk            ;
wire [7:0] AUX_I_aclk           ;

wire [7:0] AUX2_I_aclk           ;
wire [7:0] AUX3_I_aclk           ;
wire [7:0] AUX4_I_aclk           ;
wire [7:0] AUX5_I_aclk           ;
 
 
`CDC_MULTI_BIT_SIGNAL_INGEN_NOIN(FSYNC_I,S_AXI_ACLK,FSYNC_I_aclk,8,2)                //8
`CDC_MULTI_BIT_SIGNAL_INGEN_NOIN(FSYNC_FILTER_I,S_AXI_ACLK,FSYNC_FILTER_I_aclk,8,2)  //16
`CDC_MULTI_BIT_SIGNAL_INGEN_NOIN(VS_I,S_AXI_ACLK,VS_I_aclk,8,2)                      //24
`CDC_MULTI_BIT_SIGNAL_INGEN_NOIN(AUX_I,S_AXI_ACLK,AUX_I_aclk,8,2)                    //32

`CDC_MULTI_BIT_SIGNAL_INGEN_NOIN(AUX2_I,S_AXI_ACLK,AUX2_I_aclk,8,2)         
`CDC_MULTI_BIT_SIGNAL_INGEN_NOIN(AUX3_I,S_AXI_ACLK,AUX3_I_aclk,8,2)    
`CDC_MULTI_BIT_SIGNAL_INGEN_NOIN(AUX4_I,S_AXI_ACLK,AUX4_I_aclk,8,2)    
`CDC_MULTI_BIT_SIGNAL_INGEN_NOIN(AUX5_I,S_AXI_ACLK,AUX5_I_aclk,8,2)            

 

wire                              write_req_cpu_to_axi   ;
wire  [C_AXI_LITE_ADDR_WIDTH-1:0] write_addr_cpu_to_axi  ;
wire [C_AXI_LITE_DATA_WIDTH-1:0]  write_data_cpu_to_axi  ;
wire                              read_req_cpu_to_axi    ;
wire  [C_AXI_LITE_ADDR_WIDTH-1:0] read_addr_cpu_to_axi   ;
reg   [C_AXI_LITE_DATA_WIDTH-1:0] read_data_axi_to_cpu   ;
reg                               read_finish_axi_to_cpu ;


reg [31:0] R_DEBUG_0_ID  = C_DEBUG_0_ID_DEFAULT ;
reg [31:0] R_DEBUG_1_ID  = C_DEBUG_1_ID_DEFAULT ;
reg [31:0] R_DEBUG_2_ID  = C_DEBUG_2_ID_DEFAULT ;
reg [31:0] R_DEBUG_3_ID  = C_DEBUG_3_ID_DEFAULT ;


reg [31:0] R_DEBUG_H32_0_ID  = C_DEBUG_H32_0_ID_DEFAULT ;
reg [31:0] R_DEBUG_H32_1_ID  = C_DEBUG_H32_1_ID_DEFAULT ;
reg [31:0] R_DEBUG_H32_2_ID  = C_DEBUG_H32_2_ID_DEFAULT ;
reg [31:0] R_DEBUG_H32_3_ID  = C_DEBUG_H32_3_ID_DEFAULT ;
 


axi_lite_slave #(
    .C_S_AXI_DATA_WIDTH (C_AXI_LITE_DATA_WIDTH ),
    .C_S_AXI_ADDR_WIDTH (C_AXI_LITE_ADDR_WIDTH )   
    )
    axi_lite_slave_u(

    .S_AXI_ACLK            (S_AXI_ACLK      ),     //input  wire                              
    .S_AXI_ARESETN         (S_AXI_ARESETN   ),     //input  wire                              
    .S_AXI_AWREADY         (S_AXI_AWREADY   ),     //output wire                              
    .S_AXI_AWADDR          (S_AXI_AWADDR    ),     //input  wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .S_AXI_AWVALID         (S_AXI_AWVALID   ),     //input  wire                              
    .S_AXI_AWPROT          (S_AXI_AWPROT    ),     //input  wire [ 2:0]                       
    .S_AXI_WREADY          (S_AXI_WREADY    ),     //output wire                              
    .S_AXI_WDATA           (S_AXI_WDATA     ),     //input  wire [C_S_AXI_DATA_WIDTH-1:0]     
    .S_AXI_WSTRB           (S_AXI_WSTRB     ),         //input  wire [(C_S_AXI_DATA_WIDTH/8)-1 :0]
    .S_AXI_WVALID          (S_AXI_WVALID    ),     //input  wire                              
    .S_AXI_BRESP           (S_AXI_BRESP     ),     //output wire [ 1:0]                       
    .S_AXI_BVALID          (S_AXI_BVALID    ),     //output wire                              
    .S_AXI_BREADY          (S_AXI_BREADY    ),     //input  wire                              
    .S_AXI_ARREADY         (S_AXI_ARREADY   ),     //output wire                              
    .S_AXI_ARADDR          (S_AXI_ARADDR    ),     //input  wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .S_AXI_ARVALID         (S_AXI_ARVALID   ),     //input  wire                              
    .S_AXI_ARPROT          (S_AXI_ARPROT    ),     //input  wire [ 2:0]                       
    .S_AXI_RRESP           (S_AXI_RRESP     ),     //output wire [ 1:0]                       
    .S_AXI_RVALID          (S_AXI_RVALID    ),     //output wire                              
    .S_AXI_RDATA           (S_AXI_RDATA     ),     //output wire [C_S_AXI_DATA_WIDTH-1:0]     
    .S_AXI_RREADY          (S_AXI_RREADY    ),     //input  wire                              
    
    .write_req_cpu_to_axi  (write_req_cpu_to_axi   ),    //wire                              
    .write_addr_cpu_to_axi (write_addr_cpu_to_axi  ),   //wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .write_data_cpu_to_axi (write_data_cpu_to_axi  ),   //wire [C_S_AXI_DATA_WIDTH-1:0]     
    .read_req_cpu_to_axi   (read_req_cpu_to_axi    ),     //wire                              
    .read_addr_cpu_to_axi  (read_addr_cpu_to_axi   ),    //wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .read_data_axi_to_cpu  (read_data_axi_to_cpu   ),    //wire [C_S_AXI_DATA_WIDTH-1:0]     
    .read_finish_axi_to_cpu(read_finish_axi_to_cpu )   //wire                              
      
);





always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        R_DEBUG_0_ID  <= C_DEBUG_0_ID_DEFAULT ;
        R_DEBUG_1_ID  <= C_DEBUG_1_ID_DEFAULT ;
        R_DEBUG_2_ID  <= C_DEBUG_2_ID_DEFAULT ;
        R_DEBUG_3_ID  <= C_DEBUG_3_ID_DEFAULT ;
    end
    else if(write_req_cpu_to_axi)begin
        case(write_addr_cpu_to_axi)
            `ADDR_DEBUG_0_ID  : R_DEBUG_0_ID <=  write_data_cpu_to_axi ;
            `ADDR_DEBUG_1_ID  : R_DEBUG_1_ID <=  write_data_cpu_to_axi ;            
            `ADDR_DEBUG_2_ID  : R_DEBUG_2_ID <=  write_data_cpu_to_axi ;            
            `ADDR_DEBUG_3_ID  : R_DEBUG_3_ID <=  write_data_cpu_to_axi ;   

            `ADDR_DEBUG_H32_0_ID :  R_DEBUG_H32_0_ID  <= write_data_cpu_to_axi ;
            `ADDR_DEBUG_H32_1_ID :  R_DEBUG_H32_1_ID  <= write_data_cpu_to_axi ;
            `ADDR_DEBUG_H32_2_ID :  R_DEBUG_H32_2_ID  <= write_data_cpu_to_axi ;
            `ADDR_DEBUG_H32_3_ID :  R_DEBUG_H32_3_ID  <= write_data_cpu_to_axi ;

            
            default:;
        endcase
    end
end


assign  DEBUG_O[0] = ( |  ( R_DEBUG_0_ID  & { AUX_I_aclk,VS_I_aclk,FSYNC_FILTER_I_aclk,FSYNC_I_aclk } )  )  |  ( | ( R_DEBUG_H32_0_ID  &  {AUX5_I_aclk , AUX4_I_aclk , AUX3_I_aclk, AUX2_I_aclk}  ) )   ;
assign  DEBUG_O[1] = ( |  ( R_DEBUG_1_ID  & { AUX_I_aclk,VS_I_aclk,FSYNC_FILTER_I_aclk,FSYNC_I_aclk } )  )  |  ( | ( R_DEBUG_H32_1_ID  &  {AUX5_I_aclk , AUX4_I_aclk , AUX3_I_aclk, AUX2_I_aclk}  ) )   ;
assign  DEBUG_O[2] = ( |  ( R_DEBUG_2_ID  & { AUX_I_aclk,VS_I_aclk,FSYNC_FILTER_I_aclk,FSYNC_I_aclk } )  )  |  ( | ( R_DEBUG_H32_2_ID  &  {AUX5_I_aclk , AUX4_I_aclk , AUX3_I_aclk, AUX2_I_aclk}  ) )   ;
assign  DEBUG_O[3] = ( |  ( R_DEBUG_3_ID  & { AUX_I_aclk,VS_I_aclk,FSYNC_FILTER_I_aclk,FSYNC_I_aclk } )  )  |  ( | ( R_DEBUG_H32_3_ID  &  {AUX5_I_aclk , AUX4_I_aclk , AUX3_I_aclk, AUX2_I_aclk}  ) )   ;


endmodule 
    
  