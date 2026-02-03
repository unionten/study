`timescale 1ns / 1ps
`define CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                    generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(0),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk( ),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate



`define ADDR_INSIDE_TRANSFER_MODE              16'h0000 
`define ADDR_INSIDE_DT                         16'h0004 
`define ADDR_INSIDE_VC                         16'h0008 
`define ADDR_INSIDE_WC                         16'h000c 
`define ADDR_TRANSFER_MODE_OUTSIDE_CTRL_EN     16'h0010 
`define ADDR_DT_OUTSIDE_CTRL_EN                16'h0014 
`define ADDR_WC_OUTSIDE_CTRL_EN                16'h0018 
`define ADDR_VC_OUTSIDE_CTRL_EN                16'h001c 



//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// 
// Create Date: 2025/10/10 16:03:50
// Design Name: 
// Module Name: rgb_to_raw_top
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


//典型输出---本级模块提供最大位宽 --   cpnt内部靠【左】对齐
//max cpnt = 4 ; max bit = 12   mode=ori       { 000 BB0 GG0 RR0  }  { 000 BB0 GG0 RR0  } { 000 BB0 GG0 RR0  } { 000 BB0 GG0 RR0  }  
//                              mode=raw       { 000 000 000 RAW12}  { 000 000 000 RAW12} { 000 000 000 RAW12} { 000 000 000 RAW12} 
//                              mode=yuv422    { 000 000 VV0 YY0  }  { 000 000 UU0 YY0  } { 000 000 VV0 YY0  } { 000 000 UU0 YY0  } 


module rgb_to_raw_top(
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

input  [C_AXI_LITE_ADDR_WIDTH-1:0]  LB_WADDR   ,
input  [C_AXI_LITE_DATA_WIDTH-1:0]  LB_WDATA   ,
input                               LB_WREQ    ,
input  [C_AXI_LITE_ADDR_WIDTH-1:0]  LB_RADDR   ,
input                               LB_RREQ     ,
output [C_AXI_LITE_DATA_WIDTH-1:0]  LB_RDATA   ,
output                              LB_RFINISH  ,


input  VID_CLK    ,  
input  VID_RSTN   ,

input  [1:0]  TRANSFER_MODE_I ,

input  [5:0]  MIPI_DT_I          , // 从VS上沿开始变化， 以hs分割
input  [1:0]  MIPI_VC_I          ,
input  [15:0] MIPI_WC_I          ,


input  S_NATIVE_VS       ,
input  S_NATIVE_HS       ,
input  S_NATIVE_DE       ,
input  [8*C_PORT_NUM-1:0] S_NATIVE_R ,
input  [8*C_PORT_NUM-1:0] S_NATIVE_G ,
input  [8*C_PORT_NUM-1:0] S_NATIVE_B ,

output M_VID_VS        ,
output M_VID_HS        ,
output M_VID_DE        ,
output [C_CPNTS_PER_PIXEL*C_BITS_PER_CPNT*C_PORT_NUM-1:0]  M_VID_DATA  ,

output reg [5:0] MIPI_DT_O   ,
output reg [1:0] MIPI_VC_O   ,
output reg [15:0] MIPI_WC_O   


    );
    
parameter  [0:0] C_LB_ENABLE       =  0;
parameter  C_AXI_LITE_ADDR_WIDTH    = 16;
parameter  C_AXI_LITE_DATA_WIDTH    = 32; 

parameter  C_PORT_NUM             = 4; // 2 4 (1可能不兼容)
parameter  C_CPNTS_PER_PIXEL      = 2; // 1 2 3 
parameter  C_BITS_PER_CPNT        = 14;// 8 10 12 14
    
parameter [0:0] C_TRANSFER_MODE_OUTSIDE_CTRL_EN_DEFAULT =  0 ; 
parameter [0:0] C_DT_OUTSIDE_CTRL_EN_DEFAULT =  0 ; 
parameter [0:0] C_VC_OUTSIDE_CTRL_EN_DEFAULT =  0 ; 
parameter [0:0] C_WC_OUTSIDE_CTRL_EN_DEFAULT =  0 ; 

parameter        C_INSIDE_TRANSFER_MODE_DEFAULT =  1 ; //0  ori ; 1  yuv422 ; 2 : raw
parameter [5:0]  C_INSIDE_DT_DEFAULT =  6'h1E ; 
parameter [1:0]  C_INSIDE_VC_DEFAULT =  0  ; 
parameter [15:0] C_INSIDE_WC_DEFAULT =  3840 ; 



    
wire write_req_cpu_to_axi   ;
wire [C_AXI_LITE_ADDR_WIDTH-1:0] write_addr_cpu_to_axi ;
wire [C_AXI_LITE_DATA_WIDTH-1:0] write_data_cpu_to_axi ;
wire read_req_cpu_to_axi  ;
wire [C_AXI_LITE_ADDR_WIDTH-1:0] read_addr_cpu_to_axi ;
wire  [C_AXI_LITE_DATA_WIDTH-1:0] read_data_axi_to_cpu ;
wire  read_finish_axi_to_cpu;


wire                       write_req_cpu_to_axi_ll   ;
wire [C_AXI_LITE_ADDR_WIDTH-1:0]  write_addr_cpu_to_axi_ll  ;
wire [C_AXI_LITE_DATA_WIDTH-1:0]  write_data_cpu_to_axi_ll  ;
wire                       read_req_cpu_to_axi_ll    ;
wire  [C_AXI_LITE_ADDR_WIDTH-1:0] read_addr_cpu_to_axi_ll   ;
reg  [C_AXI_LITE_DATA_WIDTH-1:0]  read_data_axi_to_cpu_ll  = 0;
reg                        read_finish_axi_to_cpu_ll  = 0;


reg [1:0] r_inside_mode  = C_INSIDE_TRANSFER_MODE_DEFAULT;
reg [5:0] r_inside_dt    = C_INSIDE_DT_DEFAULT ;
reg [1:0] r_inside_vc   = C_INSIDE_VC_DEFAULT ;
reg [15:0] r_inside_wc    = C_INSIDE_WC_DEFAULT ;

reg [0:0]  r_mode_outside_ctrl_en = C_TRANSFER_MODE_OUTSIDE_CTRL_EN_DEFAULT ; 
reg [0:0]  r_dt_outside_ctrl_en =  C_DT_OUTSIDE_CTRL_EN_DEFAULT ;
reg [0:0]  r_wc_outside_ctrl_en =  C_WC_OUTSIDE_CTRL_EN_DEFAULT ;
reg [0:0]  r_vc_outside_ctrl_en =  C_VC_OUTSIDE_CTRL_EN_DEFAULT ;

wire [1:0] r_mode_vid  ;
wire [5:0] r_dt_vid  ;
wire [1:0] r_vc_vid  ;
wire [15:0] r_wc_vid  ;

wire [0:0]  r_mode_outside_ctrl_en_vid ;
wire [0:0]  r_dt_outside_ctrl_en_vid; 
wire [0:0]  r_wc_outside_ctrl_en_vid; 
wire [0:0]  r_vc_outside_ctrl_en_vid; 





always@(posedge VID_CLK)begin
    MIPI_DT_O <= r_dt_outside_ctrl_en_vid ?  MIPI_DT_I :  r_dt_vid ;
    MIPI_VC_O <= r_vc_outside_ctrl_en_vid ?  MIPI_VC_I :  r_vc_vid ;
    MIPI_WC_O <= r_wc_outside_ctrl_en_vid ?  MIPI_WC_I :  r_wc_vid ;  
    
end


`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(r_inside_mode,       VID_CLK  , r_mode_vid, 2, 3) 
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(r_inside_dt  ,       VID_CLK  , r_dt_vid,   6, 3) 
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(r_inside_vc  ,       VID_CLK  , r_vc_vid,   2, 3) 
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(r_inside_wc  ,       VID_CLK  , r_wc_vid,   16, 3) 
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(r_mode_outside_ctrl_en ,      VID_CLK  , r_mode_outside_ctrl_en_vid,   1, 3) 
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(r_dt_outside_ctrl_en  ,       VID_CLK  , r_dt_outside_ctrl_en_vid,   1, 3) 
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(r_wc_outside_ctrl_en  ,       VID_CLK  , r_wc_outside_ctrl_en_vid,   1, 3) 
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(r_vc_outside_ctrl_en  ,       VID_CLK  , r_vc_outside_ctrl_en_vid,   1, 3) 
 


assign write_req_cpu_to_axi_ll  =  C_LB_ENABLE ? LB_WREQ  : write_req_cpu_to_axi  ;
assign write_addr_cpu_to_axi_ll =  C_LB_ENABLE ? LB_WADDR : write_addr_cpu_to_axi ;
assign write_data_cpu_to_axi_ll =  C_LB_ENABLE ? LB_WDATA : write_data_cpu_to_axi ;
assign read_req_cpu_to_axi_ll   =  C_LB_ENABLE ? LB_RREQ  : read_req_cpu_to_axi ;
assign read_addr_cpu_to_axi_ll  =  C_LB_ENABLE ? LB_RADDR : read_addr_cpu_to_axi ;

assign read_data_axi_to_cpu     =  C_LB_ENABLE ? 0 : read_data_axi_to_cpu_ll   ;
assign read_finish_axi_to_cpu   =  C_LB_ENABLE ? 0 : read_finish_axi_to_cpu_ll ;
assign LB_RDATA                 =  C_LB_ENABLE ? read_data_axi_to_cpu_ll   : 0 ;
assign LB_RFINISH               =  C_LB_ENABLE ? read_finish_axi_to_cpu_ll : 0 ;

   

    AXI_Lite_Slave #(
	.C_S_AXI_DATA_WIDTH  	(C_AXI_LITE_DATA_WIDTH),
    .C_S_AXI_ADDR_WIDTH		(C_AXI_LITE_ADDR_WIDTH)
)AXI_Lite_Slave_inst
(
	////////////////////////////////////////////////////
	// AXI4 Lite Slave interface
	.S_AXI_ACLK				(S_AXI_ACLK		),
	.S_AXI_ARESETN			(S_AXI_ARESETN	),
	.S_AXI_AWREADY			(S_AXI_AWREADY	),
	.S_AXI_AWADDR			(S_AXI_AWADDR	),
	.S_AXI_AWVALID			(S_AXI_AWVALID	),
	.S_AXI_AWPROT			(S_AXI_AWPROT	),
	.S_AXI_WREADY			(S_AXI_WREADY	),
	.S_AXI_WDATA			(S_AXI_WDATA	),
	.S_AXI_WSTRB			(S_AXI_WSTRB	),
	.S_AXI_WVALID			(S_AXI_WVALID	),
	.S_AXI_BRESP			(S_AXI_BRESP	),
	.S_AXI_BVALID			(S_AXI_BVALID	),
	.S_AXI_BREADY			(S_AXI_BREADY	),
	.S_AXI_ARREADY			(S_AXI_ARREADY	),
	.S_AXI_ARADDR			(S_AXI_ARADDR	),
	.S_AXI_ARVALID			(S_AXI_ARVALID	),
	.S_AXI_ARPROT			(S_AXI_ARPROT	),
	.S_AXI_RRESP			(S_AXI_RRESP	),
	.S_AXI_RVALID			(S_AXI_RVALID	),
	.S_AXI_RDATA			(S_AXI_RDATA	),
	.S_AXI_RREADY			(S_AXI_RREADY	),

	.o_rx_dval				(write_req_cpu_to_axi  		),
	.o_rx_addr				(write_addr_cpu_to_axi 		),
	.o_rx_data				(write_data_cpu_to_axi 		),
	.o_tx_req 				(read_req_cpu_to_axi   		),
	.o_tx_addr				(read_addr_cpu_to_axi  		),
	.i_tx_data				(read_data_axi_to_cpu  		),
	.i_tx_dval				(read_finish_axi_to_cpu		)
);


////////////////////////////////////////////////CPU WRITE////////////////////////////////////////////////////////

always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        r_inside_mode           <= C_INSIDE_TRANSFER_MODE_DEFAULT   ;
        r_inside_dt             <= C_INSIDE_DT_DEFAULT ;
        r_inside_vc             <= C_INSIDE_VC_DEFAULT ;
        r_inside_wc             <= C_INSIDE_WC_DEFAULT ;
        r_mode_outside_ctrl_en <= C_TRANSFER_MODE_OUTSIDE_CTRL_EN_DEFAULT ;
        r_dt_outside_ctrl_en  <=  C_DT_OUTSIDE_CTRL_EN_DEFAULT ;
        r_wc_outside_ctrl_en  <=  C_WC_OUTSIDE_CTRL_EN_DEFAULT ;
        r_vc_outside_ctrl_en  <=  C_VC_OUTSIDE_CTRL_EN_DEFAULT ;
    end
    else if(write_req_cpu_to_axi_ll)begin
        case(write_addr_cpu_to_axi_ll)
            `ADDR_INSIDE_TRANSFER_MODE          :  r_inside_mode      <= {0,write_data_cpu_to_axi_ll }   ;
            `ADDR_INSIDE_DT                     :  r_inside_dt        <= {0,write_data_cpu_to_axi_ll }   ;
            `ADDR_INSIDE_VC                     :  r_inside_vc        <= {0,write_data_cpu_to_axi_ll }   ;
            `ADDR_INSIDE_WC                     :  r_inside_wc        <= {0,write_data_cpu_to_axi_ll }   ;        
            `ADDR_TRANSFER_MODE_OUTSIDE_CTRL_EN :  r_mode_outside_ctrl_en <= {0,write_data_cpu_to_axi_ll }   ;
            `ADDR_DT_OUTSIDE_CTRL_EN            :  r_dt_outside_ctrl_en <= {0,write_data_cpu_to_axi_ll }   ;
            `ADDR_WC_OUTSIDE_CTRL_EN            :  r_wc_outside_ctrl_en <= {0,write_data_cpu_to_axi_ll }   ;
            `ADDR_VC_OUTSIDE_CTRL_EN            :  r_vc_outside_ctrl_en <= {0,write_data_cpu_to_axi_ll }   ;
            
            default:;
        endcase
    end
end

 
////////////////////////////////////////////////CPU READ////////////////////////////////////////////////////////

always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        read_data_axi_to_cpu_ll   <= 0;
        read_finish_axi_to_cpu_ll <= 0;
    end
    else if(read_req_cpu_to_axi_ll)begin
        read_finish_axi_to_cpu_ll <= 1;
        case(read_addr_cpu_to_axi_ll)
            `ADDR_INSIDE_TRANSFER_MODE          : read_data_axi_to_cpu_ll <= r_inside_mode ;
            `ADDR_INSIDE_DT                     : read_data_axi_to_cpu_ll <= r_inside_dt   ;  
            `ADDR_INSIDE_VC                     : read_data_axi_to_cpu_ll <= r_inside_vc   ;  
            `ADDR_INSIDE_WC                     : read_data_axi_to_cpu_ll <= r_inside_wc   ;       
            `ADDR_TRANSFER_MODE_OUTSIDE_CTRL_EN : read_data_axi_to_cpu_ll <= r_mode_outside_ctrl_en  ;
            `ADDR_DT_OUTSIDE_CTRL_EN            : read_data_axi_to_cpu_ll <= r_dt_outside_ctrl_en    ;
            `ADDR_WC_OUTSIDE_CTRL_EN            : read_data_axi_to_cpu_ll <= r_wc_outside_ctrl_en    ;
            `ADDR_VC_OUTSIDE_CTRL_EN            : read_data_axi_to_cpu_ll <= r_vc_outside_ctrl_en    ;
            default:;
        endcase
    end
    else begin
        read_finish_axi_to_cpu_ll <= 0;
    end
end
    
//典型输出---本级模块提供最大位宽 --   cpnt内部靠【左】对齐
//max cpnt = 4 ; max bit = 12   mode=ori       { 000 BB0 GG0 RR0  }  { 000 BB0 GG0 RR0  } { 000 BB0 GG0 RR0  } { 000 BB0 GG0 RR0  }  
//                              mode=raw       { 000 000 000 RAW12}  { 000 000 000 RAW12} { 000 000 000 RAW12} { 000 000 000 RAW12} 
//                              mode=yuv422    { 000 000 VV0 YY0  }  { 000 000 UU0 YY0  } { 000 000 VV0 YY0  } { 000 000 UU0 YY0  } 

rgb_to_raw
#( 
   .C_PORT_NUM            (C_PORT_NUM         ) ,
   .C_CPNTS_PER_PIXEL     (C_CPNTS_PER_PIXEL  ) ,
   .C_BITS_PER_CPNT       (C_BITS_PER_CPNT    )  
    
)
rgb_to_raw_u
(

.VID_CLK      (VID_CLK           ) ,
.VID_RSTN     (VID_RSTN          ),
.S_VS         (S_NATIVE_VS       ),
.S_HS         (S_NATIVE_HS       ),
.S_DE         (S_NATIVE_DE       ),
.S_R_Y        (S_NATIVE_R        ),
.S_G_U        (S_NATIVE_G      ),
.S_B_V        (S_NATIVE_B      ),
. M_VS        (M_VID_VS       ),
. M_HS        (M_VID_HS       ),
. M_DE        (M_VID_DE       ),
. M_VID_DATA  (M_VID_DATA     ),

. TRANSFER_MODE ( r_mode_outside_ctrl_en_vid ?  TRANSFER_MODE_I :  r_mode_vid   )    // 转换方式 0 1 2 :  "ORIGINAL"  "YUV_TO_YUV422"   "RGB_TO_RGGB"



);
     
    
    
    
endmodule
