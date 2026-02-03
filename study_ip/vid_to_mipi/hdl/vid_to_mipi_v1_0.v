
`timescale 1 ns / 1 ps
`define CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                    generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(0),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk( ),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  
`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 1; always@(posedge clk)begin if(rst)buf_name1 <= 1; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define NEG_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate
`define CDC_SINGLE_BIT_PULSE_OUTGEN(aclk,arst,apulse_in,bclk,brst,bpulse_out,SIM,DEST_FF)               generate if(SIM==0)begin  xpm_cdc_pulse #(.DEST_SYNC_FF(DEST_FF), .INIT_SYNC_FF(0),.REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) cdc_u (.src_clk(aclk),.src_rst(arst),.src_pulse(apulse_in),.dest_clk(bclk),.dest_rst(brst),.dest_pulse(bpulse_out));   end else begin   reg [5:0] name1 = 0;wire name2;always@(posedge aclk)if(arst)name1[0] <=0;else name1[0] <= apulse_in;assign name2 = apulse_in & ~name1[0]; always@(posedge aclk)if(arst)name1[1] <= 0;else name1[1] <= name2 ? ~name1[1]:name1[1];always@(posedge bclk)if(brst)name1[5:2]<=0;else begin name1[2]<=name1[1];name1[3]<=name1[2];name1[4]<=name1[3];name1[5]<=name1[4];end  assign bpulse_out=name1[4]^name1[5];  end  endgenerate



`define ADDR_DT_INSIDE               16'h0000
`define ADDR_WC_INSIDE               16'h0004
`define ADDR_VC_INSIDE               16'h0008
`define ADDR_CPNT_INSIDE             16'h000C
`define ADDR_FIFO_RST                16'h0010
`define ADDR_DT_OUTSIDE_CTRL         16'h0014
`define ADDR_WC_OUTSIDE_CTRL         16'h0018
`define ADDR_VC_OUTSIDE_CTRL         16'h001C
`define ADDR_CPNT_NUM_OUTSIDE_CTRL   16'h0020
`define ADDR_FIFO_FULL               16'h0024




module vid_to_mipi_v1_0 #
(
// Users to add parameters here
parameter C_PORT_NUM = 4,
parameter C_BITS_PER_CPNT = 14,
parameter C_MAX_CPNTS_PER_PIXEL = 2, 


///////////////////////////////////////////////////////
parameter FIFO_DEPTH = 2048,
// User parameters ends
// Do not modify the parameters beyond this line


// Parameters of Axi Slave Bus Interface S00_AXI
parameter integer C_S00_AXI_DATA_WIDTH    = 32,
parameter integer C_S00_AXI_ADDR_WIDTH    = 16 ,

parameter  [0:0] C_ILA_AXILITE_CLK_ENABLE = 0  ,
parameter  [0:0] C_ILA_AXIS_CLK_ENABLE = 0  ,
parameter  [0:0] C_ILA_PCLK_CLK_ENABLE = 0  ,

parameter  C_CPNT_NUM_DEAFULT         = 2  ,

parameter [5:0]  C_DT_DEAFULT         = 6'h1E  , // inside value
parameter [15:0] C_WC_DEAFULT         = 3840  , // inside value
parameter [1:0]  C_VC_DEAFULT         = 0  , // inside value


parameter [0:0] C_CPNT_NUM_OUTSIDE_CTRL_DEAFULT  = 0 ,

parameter [0:0] C_DT_OUTSIDE_CTRL_DEFAULT  = 0 ,
parameter [0:0] C_WC_OUTSIDE_CTRL_DEFAULT  = 0 ,
parameter [0:0] C_VC_OUTSIDE_CTRL_DEFAULT  = 0  
   
        
)
(
        // Users to add ports here
input    [C_PORT_NUM*C_MAX_CPNTS_PER_PIXEL*C_BITS_PER_CPNT-1:0]        vid_data,
input                                                vid_active_video,
input                                                vid_hsync,
input                                                vid_vsync,
input                                                vid_clk,
input                                                vid_resetn,

input  [5:0]                                        vid_dt ,
input  [15:0]                                       vid_wc ,
input  [1:0]                                        vid_vc ,



input                            mipi_axis_clk,
input                            mipi_axis_aresetn,
output                            mipi_axis_tvalid   ,
input                            mipi_axis_tready   ,
output    [95:0]                    mipi_axis_tuser    ,
output    [1:0]                    mipi_axis_tdest    ,
output                            mipi_axis_tlast    ,
output    [C_PORT_NUM*C_BITS_PER_CPNT*C_MAX_CPNTS_PER_PIXEL-1:0]       mipi_axis_tdata,  // *3 
output  reg [(C_PORT_NUM*C_BITS_PER_CPNT*C_MAX_CPNTS_PER_PIXEL)/8-1:0]       mipi_axis_tkeep = 0,          
// User ports ends
// Do not modify the ports beyond this line


// Ports of Axi Slave Bus Interface S00_AXI
input wire  s00_axi_aclk,
input wire  s00_axi_aresetn,
input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
input wire [2 : 0] s00_axi_awprot,
input wire  s00_axi_awvalid,
output wire  s00_axi_awready,
input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
input wire  s00_axi_wvalid,
output wire  s00_axi_wready,
output wire [1 : 0] s00_axi_bresp,
output wire  s00_axi_bvalid,
input wire  s00_axi_bready,
input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
input wire [2 : 0] s00_axi_arprot,
input wire  s00_axi_arvalid,
output wire  s00_axi_arready,
output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
output wire [1 : 0] s00_axi_rresp,
output wire  s00_axi_rvalid,
input wire  s00_axi_rready ,

////////////////////////////////////////////////////////////////////////////////////
output           mipi_axis_tuser0_dbg , // 原始tuser（非后来打拍生成的）
output           mipi_axis_tuser7_dbg ,
output    [5:0]  mipi_axis_dt_dbg  ,
output    [15:0] mipi_axis_wc_dbg   ,
output  [(C_PORT_NUM*C_BITS_PER_CPNT*C_MAX_CPNTS_PER_PIXEL)/8-1:0]   mipi_axis_tkeep_dbg  ,
output  [C_PORT_NUM*C_BITS_PER_CPNT*C_MAX_CPNTS_PER_PIXEL-1:0]   mipi_axis_tdata_dbg  ,
output    mipi_axis_tlast_dbg   ,
output    mipi_axis_tvalid_dbg ,
output    mipi_axis_tready_dbg  ,
output  [1:0]  mipi_axis_tdest_dbg  ,
output reg  [15:0] mipi_axis_hcnt 
  
        
);
    
genvar i;
 

reg              r_fifo_rst_aclk ;
wire              fifo_rst_vid ;
 

reg  [1:0]        r_vc_aclk    ;
reg  [5:0]        r_dt_aclk    ;
reg  [15:0]       r_wc_aclk    ;    
reg  [1:0]        r_cpnt_num_aclk  ;
reg  r_dt_outside_ctrl_aclk ;
reg  r_wc_outside_ctrl_aclk ;
reg  r_vc_outside_ctrl_aclk ;
reg  r_cpnt_num_outside_ctrl_aclk ;



wire [1:0]        vc_axis    ;
wire [5:0]        dt_axis    ;
wire [15:0]       wc_axis    ;    
wire [1:0]        cpnt_num_axis  ;
wire dt_outside_ctrl_axis ;
wire wc_outside_ctrl_axis ;
wire vc_outside_ctrl_axis ;
wire cpnt_num_outside_ctrl_axis ;


wire [5:0]  dt_axis_fifo   ;
wire [15:0] wc_axis_fifo  ;
wire [1:0]  vc_axis_fifo      ;
wire [1:0]  cpnt_num_axis_fifo ;



wire [5:0]  dt_last_axis ;
wire [15:0] wc_last_axis ;
wire [1:0]  vc_last_axis ;
wire [1:0]  cpnt_num_last_axis ;


reg axis_tuser_new = 0;// ~vs
wire vid_vsync_axisclk_pos;
wire vid_vsync_axisclk_neg;
wire vid_vsync_axisclk ;
wire [7:0] mipi_axis_byte_num ;

    
reg [C_PORT_NUM*C_MAX_CPNTS_PER_PIXEL*C_BITS_PER_CPNT-1:0] vid_data_d0 ;
reg [C_PORT_NUM*C_MAX_CPNTS_PER_PIXEL*C_BITS_PER_CPNT-1:0] vid_data_d1 ;
reg vsync_d0 ;
reg vsync_pos ;
reg vid_tlast ;
reg vid_tuser ;
reg vid_tuser_d0 ;
reg vid_active_video_d0 ;
reg vid_active_video_d1 ;


reg [5:0] vid_dt_d0 ;
reg [5:0] vid_dt_d1 ;

reg [15:0] vid_wc_d0 ;
reg [15:0] vid_wc_d1 ; 

reg [1:0] vid_vc_d0 ;
reg [1:0] vid_vc_d1 ; 

reg [1:0] vid_cpnt_d0;
reg [1:0] vid_cpnt_d1 ;  

wire    empty ;
wire    axis_tuser ;

wire    [C_PORT_NUM*C_MAX_CPNTS_PER_PIXEL*C_BITS_PER_CPNT-1:0] axis_tdata ;  
    
wire full_aclk_sig ;
wire full_aclk_pos ;



//vid_to_mipi_v1_0_S00_AXI # ( 
//    .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
//    .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH),
//    
//   .C_DT_DEAFULT       (C_DT_DEAFULT        ),
//   .C_WC_DEAFULT       (C_WC_DEAFULT        ),
//   .C_VC_DEAFULT       (C_VC_DEAFULT        ),
//   .C_CPNT_NUM_DEAFULT (C_CPNT_NUM_DEAFULT  ),
//   
//    
//   .C_DT_OUTSIDE_CTRL_DEFAULT (C_DT_OUTSIDE_CTRL_DEFAULT ),
//   .C_WC_OUTSIDE_CTRL_DEFAULT (C_WC_OUTSIDE_CTRL_DEFAULT ),
//   .C_VC_OUTSIDE_CTRL_DEFAULT (C_VC_OUTSIDE_CTRL_DEFAULT ),
//
//    .C_CPNT_NUM_OUTSIDE_CTRL_DEAFULT (C_CPNT_NUM_OUTSIDE_CTRL_DEAFULT )
//   
//      
//    
//) vid_to_mipi_v1_0_S00_AXI_inst (
//    .vc             (r_vc_aclk          ),
//    .dt             (r_dt_aclk          ),
//    .wc             (r_wc_aclk          ),
//    .cpnt_num       (r_cpnt_num_aclk    ),
//    .fifo_rst       (r_fifo_rst_aclk    ) ,
//    
//    .fifo_full      (full_aclk        ) ,// input 
//    
//    .dt_outside_ctrl   (r_dt_outside_ctrl_aclk         ),
//    .wc_outside_ctrl   (r_wc_outside_ctrl_aclk         ),
//    .vc_outside_ctrl   (r_vc_outside_ctrl_aclk         ),
//    .cpnt_num_outside_ctrl  (r_cpnt_num_outside_ctrl_aclk   ) ,
//    
//    
//    .S_AXI_ACLK(s00_axi_aclk),
//    .S_AXI_ARESETN(s00_axi_aresetn),
//    .S_AXI_AWADDR(s00_axi_awaddr),
//    .S_AXI_AWPROT(s00_axi_awprot),
//    .S_AXI_AWVALID(s00_axi_awvalid),
//    .S_AXI_AWREADY(s00_axi_awready),
//    .S_AXI_WDATA(s00_axi_wdata),
//    .S_AXI_WSTRB(s00_axi_wstrb),
//    .S_AXI_WVALID(s00_axi_wvalid),
//    .S_AXI_WREADY(s00_axi_wready),
//    .S_AXI_BRESP(s00_axi_bresp),
//    .S_AXI_BVALID(s00_axi_bvalid),
//    .S_AXI_BREADY(s00_axi_bready),
//    .S_AXI_ARADDR(s00_axi_araddr),
//    .S_AXI_ARPROT(s00_axi_arprot),
//    .S_AXI_ARVALID(s00_axi_arvalid),
//    .S_AXI_ARREADY(s00_axi_arready),
//    .S_AXI_RDATA(s00_axi_rdata),
//    .S_AXI_RRESP(s00_axi_rresp),
//    .S_AXI_RVALID(s00_axi_rvalid),
//    .S_AXI_RREADY(s00_axi_rready)
//);


wire write_req_cpu_to_axi ;  
wire [15:0] write_addr_cpu_to_axi  ;
wire [31:0] write_data_cpu_to_axi  ;
wire read_req_cpu_to_axi  ;
wire [15:0] read_addr_cpu_to_axi ;
reg [31:0] read_data_axi_to_cpu ;
reg  read_finish_axi_to_cpu ;


axi_lite_slave #(
.C_S_AXI_DATA_WIDTH (C_S00_AXI_DATA_WIDTH ),
.C_S_AXI_ADDR_WIDTH (C_S00_AXI_ADDR_WIDTH )   
)
vid_to_mipi_v1_0_S00_AXI_inst
( 

.S_AXI_ACLK      (s00_axi_aclk ) ,     //input  wire                              
.S_AXI_ARESETN   (s00_axi_aresetn ) ,     //input  wire                              
.S_AXI_AWREADY   (s00_axi_awready ) ,     //output wire                               
.S_AXI_AWADDR    (s00_axi_awaddr  ) ,     //input  wire [C_S_AXI_ADDR_WIDTH-1:0]     
.S_AXI_AWVALID   (s00_axi_awvalid ) ,     //input  wire                              
.S_AXI_AWPROT    (s00_axi_awprot  ) ,     //input  wire [ 2:0]                        
.S_AXI_WREADY    (s00_axi_wready  ) ,     //output wire                              
.S_AXI_WDATA     (s00_axi_wdata   ) ,     //input  wire [C_S_AXI_DATA_WIDTH-1:0]     
.S_AXI_WSTRB     (s00_axi_wstrb   ) ,         //input  wire [(C_S_AXI_DATA_WIDTH/8)-1 :0]
.S_AXI_WVALID    (s00_axi_wvalid  ) ,     //input  wire                              
.S_AXI_BRESP     (s00_axi_bresp   ) ,     //output wire [ 1:0]                       
.S_AXI_BVALID    (s00_axi_bvalid  ) ,     //output wire                              
.S_AXI_BREADY    (s00_axi_bready  ) ,     //input  wire                              
.S_AXI_ARREADY   (s00_axi_arready ) ,     //output wire                              
.S_AXI_ARADDR    (s00_axi_araddr  ) ,     //input  wire [C_S_AXI_ADDR_WIDTH-1:0]     
.S_AXI_ARVALID   (s00_axi_arvalid ) ,     //input  wire                              
.S_AXI_ARPROT    (s00_axi_arprot  ) ,     //input  wire [ 2:0]                       
.S_AXI_RRESP     (s00_axi_rresp   ) ,     //output wire [ 1:0]                       
.S_AXI_RVALID    (s00_axi_rvalid  ) ,     //output wire                              
.S_AXI_RDATA     (s00_axi_rdata   ) ,     //output wire [C_S_AXI_DATA_WIDTH-1:0]     
.S_AXI_RREADY    (s00_axi_rready  ) ,     //input  wire                              

.write_req_cpu_to_axi   (write_req_cpu_to_axi   )  ,    //wire                              
.write_addr_cpu_to_axi  (write_addr_cpu_to_axi  )  ,   //wire [C_S_AXI_ADDR_WIDTH-1:0]     
.write_data_cpu_to_axi  (write_data_cpu_to_axi  )  ,   //wire [C_S_AXI_DATA_WIDTH-1:0]     
.read_req_cpu_to_axi    (read_req_cpu_to_axi    )  ,     //wire                              
.read_addr_cpu_to_axi   (read_addr_cpu_to_axi   )  ,    //wire [C_S_AXI_ADDR_WIDTH-1:0]     
.read_data_axi_to_cpu   (read_data_axi_to_cpu   )  ,    //wire [C_S_AXI_DATA_WIDTH-1:0]     
.read_finish_axi_to_cpu (read_finish_axi_to_cpu )    //wire                              
      
);
 

always@(posedge s00_axi_aclk)begin
    if(~s00_axi_aresetn)begin
        r_dt_aclk               <= C_DT_DEAFULT ;
        r_wc_aclk               <= C_WC_DEAFULT ;
        r_vc_aclk                <= C_VC_DEAFULT ;
        r_cpnt_num_aclk          <= C_CPNT_NUM_DEAFULT;
        r_dt_outside_ctrl_aclk  <= C_DT_OUTSIDE_CTRL_DEFAULT ;
        r_wc_outside_ctrl_aclk  <= C_WC_OUTSIDE_CTRL_DEFAULT ;
        r_vc_outside_ctrl_aclk  <= C_VC_OUTSIDE_CTRL_DEFAULT ;
        r_cpnt_num_outside_ctrl_aclk <= C_CPNT_NUM_OUTSIDE_CTRL_DEAFULT ;
    end
    else if(write_req_cpu_to_axi)begin
        case(write_addr_cpu_to_axi)
            `ADDR_DT_INSIDE               :   r_dt_aclk  <= write_data_cpu_to_axi ;                  
            `ADDR_WC_INSIDE               :   r_wc_aclk  <= write_data_cpu_to_axi ;              
            `ADDR_VC_INSIDE               :   r_vc_aclk   <= write_data_cpu_to_axi ;             
            `ADDR_CPNT_INSIDE             :   r_cpnt_num_aclk    <= write_data_cpu_to_axi ;      
            `ADDR_DT_OUTSIDE_CTRL         :   r_dt_outside_ctrl_aclk   <= write_data_cpu_to_axi ;
            `ADDR_WC_OUTSIDE_CTRL         :   r_wc_outside_ctrl_aclk  <= write_data_cpu_to_axi ; 
            `ADDR_VC_OUTSIDE_CTRL         :   r_vc_outside_ctrl_aclk   <= write_data_cpu_to_axi ;
            `ADDR_CPNT_NUM_OUTSIDE_CTRL   :   r_cpnt_num_outside_ctrl_aclk <= write_data_cpu_to_axi ;
            `ADDR_FIFO_RST               :     r_fifo_rst_aclk  <= write_data_cpu_to_axi ;
            default : ; 

        endcase
    end
end

reg full_flag_aclk ;


always@(posedge s00_axi_aclk)begin
    if(~s00_axi_aresetn)begin
        full_flag_aclk <= 0;
    end
    else begin
        full_flag_aclk <= ( read_addr_cpu_to_axi & (read_addr_cpu_to_axi==`ADDR_FIFO_FULL)  )  ? 0 :  full_aclk ? 1  :  full_flag_aclk ;
      
    end
end


always@(posedge s00_axi_aclk)begin
    if(~s00_axi_aresetn)begin
        read_data_axi_to_cpu    <= 0;
        read_finish_axi_to_cpu <= 0;
    end
    else if(read_req_cpu_to_axi)begin
        read_finish_axi_to_cpu <= 1 ;
        case(read_addr_cpu_to_axi)
            `ADDR_DT_INSIDE               :  read_data_axi_to_cpu  <=  r_dt_aclk ;             
            `ADDR_WC_INSIDE               :  read_data_axi_to_cpu  <=  r_wc_aclk ;            
            `ADDR_VC_INSIDE               :  read_data_axi_to_cpu  <=  r_vc_aclk  ;           
            `ADDR_CPNT_INSIDE             :  read_data_axi_to_cpu  <=  r_cpnt_num_aclk  ;   
            `ADDR_DT_OUTSIDE_CTRL         :  read_data_axi_to_cpu  <=  r_dt_outside_ctrl_aclk  ;   
            `ADDR_WC_OUTSIDE_CTRL         :  read_data_axi_to_cpu  <=  r_wc_outside_ctrl_aclk  ;   
            `ADDR_VC_OUTSIDE_CTRL         :  read_data_axi_to_cpu  <=  r_vc_outside_ctrl_aclk  ;   
            `ADDR_CPNT_NUM_OUTSIDE_CTRL   :  read_data_axi_to_cpu  <=  r_cpnt_num_outside_ctrl_aclk ;   
        
            `ADDR_FIFO_FULL  :  read_data_axi_to_cpu <=  full_flag_aclk ;
            default : ;
        endcase
    end
    else begin
        read_finish_axi_to_cpu <= 0;
    end
end



assign mipi_axis_tvalid = ~empty ;

always @(posedge vid_clk)
begin
    if (~vid_resetn)
        vsync_d0 <= 0 ;
    else 
        vsync_d0 <= vid_vsync ;
end

always @(posedge vid_clk)
begin
    if (~vid_resetn)
        vsync_pos <= 0 ;
    else if (vid_active_video)
        vsync_pos <= 0 ;
    else if (~vsync_d0 & vid_vsync)
        vsync_pos <= 1 ;
end

always @(posedge vid_clk)
begin
    if (~vid_resetn)
        vid_tlast <= 0 ;
    else if (~vid_active_video & vid_active_video_d0)
        vid_tlast <= 1 ;
    else
        vid_tlast <= 0 ;
end

always @(posedge vid_clk)
begin
    if (~vid_resetn)
        vid_tuser <= 0 ;
    else if (vid_active_video & vsync_pos)
        vid_tuser <= 1 ;
    else
        vid_tuser <= 0 ;
end

always @(posedge vid_clk)
begin
    if (~vid_resetn)
    begin
        vid_tuser_d0 <= 0 ;
        vid_data_d0 <= 0 ;
        vid_data_d1 <= 0 ;
        vid_active_video_d0 <= 0 ;
        vid_active_video_d1 <= 0 ;
        
        vid_dt_d0  <=  C_DT_DEAFULT ; //inside value
        vid_dt_d1  <=  C_DT_DEAFULT ;
                    
        vid_wc_d0  <=  C_WC_DEAFULT ;
        vid_wc_d1  <=  C_WC_DEAFULT ; 
                   
        vid_vc_d0  <=  C_VC_DEAFULT  ;
        vid_vc_d1  <=  C_VC_DEAFULT ; 
        
        vid_cpnt_d0 <= C_CPNT_NUM_DEAFULT ;
        vid_cpnt_d1 <= C_CPNT_NUM_DEAFULT ;
        
    end
    else
    begin
        vid_tuser_d0 <= vid_tuser ;
        vid_data_d0 <= vid_data ;
        vid_data_d1 <= vid_data_d0 ;
        vid_active_video_d0 <= vid_active_video ;
        vid_active_video_d1 <= vid_active_video_d0 ;
        
        
        vid_dt_d0 <= vid_dt ;
        vid_dt_d1 <= vid_dt_d0 ;

        vid_wc_d0 <= vid_wc ;
        vid_wc_d1 <= vid_wc_d0 ;

        vid_vc_d0 <= vid_vc ;
        vid_vc_d1 <= vid_vc_d0 ;  

        vid_cpnt_d0 <= ( vid_dt=='h1E ? 2 : vid_dt=='h24 ? 3 : 1  ) ;
        vid_cpnt_d1 <= vid_cpnt_d0 ;
        
    end
end
    
    
    
    
    
xpm_fifo_async #(
   .CDC_SYNC_STAGES      (2),        
   .DOUT_RESET_VALUE     ("0"),      
   .ECC_MODE             ("no_ecc"), 
   .FIFO_MEMORY_TYPE     ("auto"),   
   .FIFO_READ_LATENCY    (0),        
   .FIFO_WRITE_DEPTH     (FIFO_DEPTH),  
   .FULL_RESET_VALUE     (0),        
   .PROG_EMPTY_THRESH    (10),       
   .PROG_FULL_THRESH     (10),       
   .RD_DATA_COUNT_WIDTH  ($clog2(FIFO_DEPTH)+1),       
   .READ_DATA_WIDTH      (C_PORT_NUM*C_MAX_CPNTS_PER_PIXEL*C_BITS_PER_CPNT+2  +24 + 2),        
   .READ_MODE            ("fwft"),    
   .RELATED_CLOCKS       (0),        
   .USE_ADV_FEATURES     ("070F"),   
   .WAKEUP_TIME          (0),        
   .WRITE_DATA_WIDTH     (C_PORT_NUM*C_MAX_CPNTS_PER_PIXEL*C_BITS_PER_CPNT+2  +24 + 2),        
   .WR_DATA_COUNT_WIDTH  ($clog2(FIFO_DEPTH)+1)        
)
stream_data_fifo_async_inst (
   .rst            ( (~vid_resetn)  |  fifo_rst_vid),
   .wr_clk         (vid_clk),
   .wr_en          (vid_active_video_d1),
   .din            ({vid_cpnt_d1       ,vid_vc_d1,     vid_wc_d1,    vid_dt_d1,    vid_data_d1,   vid_tuser_d0,      vid_tlast}),
   .rd_clk         (mipi_axis_clk),
   .rd_en          (mipi_axis_tvalid & mipi_axis_tready),
   .dout           ({cpnt_num_axis_fifo ,vc_axis_fifo, wc_axis_fifo, dt_axis_fifo,  axis_tdata,   axis_tuser,        mipi_axis_tlast}),
   .empty          (empty),
   .full           (full),
   .almost_empty   (),
   .almost_full    (),
   .wr_data_count  (),
   .rd_data_count  (),    
   .prog_empty     (),
   .prog_full      (),    
   .data_valid     (),
   .dbiterr        (),
   .sbiterr        (),
   .overflow       (),
   .underflow      (),
   .wr_ack         (),   
   .wr_rst_busy    (),   
   .rd_rst_busy    (),
   .injectdbiterr  (1'b0),
   .injectsbiterr  (1'b0),   
   .sleep          (1'b0)   
   );     
    
    
    //原来进来的数据是紧凑的，所以可以按component为单位处理；
    //现在数据非紧凑，所以要根据参数处理 ，同时假定输入数据都是靠左对齐的


assign full_aclk = full_aclk_sig | full_aclk_pos  ;
    
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(     full ,s00_axi_aclk  ,full_aclk_sig ,           1,3)          //   打拍
`CDC_SINGLE_BIT_PULSE_OUTGEN(vid_clk,0,full ,s00_axi_aclk, 0 ,full_aclk_pos ,0,     3)     // 获取上沿 


`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(vid_vsync,       mipi_axis_clk,vid_vsync_axisclk,1,3)       
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(r_fifo_rst_aclk   ,vid_clk,fifo_rst_vid,           1,3)       



`POS_MONITOR_OUTGEN(mipi_axis_clk,0,vid_vsync_axisclk,vid_vsync_axisclk_pos)  
`NEG_MONITOR_OUTGEN(mipi_axis_clk,0,vid_vsync_axisclk,vid_vsync_axisclk_neg)   


always@(posedge mipi_axis_clk)begin
    if(~mipi_axis_aresetn)begin
        axis_tuser_new <= 0;
    end
    else begin
        axis_tuser_new <= vid_vsync_axisclk_pos ? 1 : vid_vsync_axisclk_neg ? 0: axis_tuser_new ;
    end
    
end





 vid2mipi_concat   
     #(.C_PORT_NUM        (C_PORT_NUM      ) ,
       .C_BITS_PER_CPNT   (C_BITS_PER_CPNT ) ,
       .C_MAX_CPNTS_PER_PIXEL (C_MAX_CPNTS_PER_PIXEL   ) )
     reconcat_2_u
     (
         .ACTUAL_CPNTS_PER_PIXEL_I  (cpnt_num_last_axis      ) ,     
         .DATA_I                    (axis_tdata              ) , 
         .DATA_O                    (mipi_axis_tdata         )  
     );



    `CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(r_dt_aclk  ,mipi_axis_clk,dt_axis ,6 ,3)       
    `CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(r_wc_aclk  ,mipi_axis_clk,wc_axis ,16,3)       
    `CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(r_vc_aclk  ,mipi_axis_clk,vc_axis  ,2,3)     
     `CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(r_cpnt_num_aclk ,mipi_axis_clk,cpnt_num_axis,2,3)    
    `CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(r_dt_outside_ctrl_aclk       ,mipi_axis_clk, dt_outside_ctrl_axis         ,1,3)     
    `CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(r_wc_outside_ctrl_aclk       ,mipi_axis_clk, wc_outside_ctrl_axis         ,1,3)     
    `CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(r_vc_outside_ctrl_aclk       ,mipi_axis_clk, vc_outside_ctrl_axis         ,1,3)    
    `CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(r_cpnt_num_outside_ctrl_aclk ,mipi_axis_clk, cpnt_num_outside_ctrl_axis   ,2,3)   
    

 

    assign dt_last_axis       = dt_outside_ctrl_axis        ? dt_axis_fifo : dt_axis  ;  
    assign wc_last_axis       = wc_outside_ctrl_axis        ? wc_axis_fifo : wc_axis ;
    assign vc_last_axis       = vc_outside_ctrl_axis        ? vc_axis_fifo : vc_axis ;
    assign cpnt_num_last_axis = cpnt_num_outside_ctrl_axis  ? cpnt_num_axis_fifo : cpnt_num_axis ;
     
    
    
    assign mipi_axis_tuser = {32'd0,wc_last_axis  ,40'd0 ,  axis_tuser_new, dt_last_axis  ,axis_tuser};
    
    
   always@(posedge mipi_axis_clk)begin
      mipi_axis_tkeep <= {((C_PORT_NUM*C_BITS_PER_CPNT*C_MAX_CPNTS_PER_PIXEL)/8){1'b1}};
   end
    
    
    assign  mipi_axis_byte_num = (C_PORT_NUM*C_BITS_PER_CPNT*  cpnt_num_last_axis   )/8 ;
    
    generate for(i=0;i<=(  (C_PORT_NUM*C_BITS_PER_CPNT*C_MAX_CPNTS_PER_PIXEL)/8 -1   ) ;i=i+1     )begin
        always@(posedge mipi_axis_clk)begin
          //  mipi_axis_tkeep[i] <=  ( mipi_axis_byte_num  )  >=    ( i+1  ) ?  1'b1 : 1'b0  ;
        
        
        end
    end
    endgenerate

    assign mipi_axis_tdest = vc_last_axis  ;
    

/////////////////////////////////////////////////////debug //////////////////////////////////////////////////////////
    


    assign   mipi_axis_tuser0_dbg           =  mipi_axis_tuser[0] ; // 1  原始tuser（非后来打拍生成的）
    assign   mipi_axis_tuser7_dbg           =  mipi_axis_tuser[7] ; // 1  新逻辑下 vs
    assign   mipi_axis_dt_dbg               =  mipi_axis_tuser[6:1]  ;  // 6
    assign   mipi_axis_wc_dbg               =  mipi_axis_tuser[63:48]  ;  // 16 
    assign   mipi_axis_tkeep_dbg            =  mipi_axis_tkeep  ;  // [(C_PORT_NUM*C_BITS_PER_CPNT*C_MAX_CPNTS_PER_PIXEL)/8-1:0] 
    assign   mipi_axis_tdata_dbg            =  mipi_axis_tdata  ;  //  [C_PORT_NUM*C_BITS_PER_CPNT*C_MAX_CPNTS_PER_PIXEL-1:0] 
    assign   mipi_axis_tlast_dbg            =  mipi_axis_tlast    ; //2 
    assign   mipi_axis_tvalid_dbg           =  mipi_axis_tvalid ;  // 1
    assign   mipi_axis_tready_dbg           =  mipi_axis_tready ;  // 1
    assign   mipi_axis_tdest_dbg            =  mipi_axis_tdest ; //1
  

    reg mipi_axis_tlast_ff;
    wire mipi_axis_tlast_pos; 
    always@(posedge mipi_axis_clk)begin
        mipi_axis_tlast_ff <= mipi_axis_tlast ; 
    end
    assign  mipi_axis_tlast_pos = mipi_axis_tlast & ~mipi_axis_tlast_ff ;

    always@(posedge mipi_axis_clk)begin
        mipi_axis_hcnt <= mipi_axis_tuser[0] ? 0  :  mipi_axis_tlast_pos ? mipi_axis_hcnt + 1 : mipi_axis_hcnt ; 
    end



//for debug
reg [31:0] beats_1E_dym ;
reg [15:0] rows_1E_dym  ;
reg [31:0] beats_12_dym ;
reg [15:0] rows_12_dym  ;
reg [31:0] beats_35_dym ;
reg [15:0] rows_35_dym  ;


always@(posedge mipi_axis_clk)begin 
    if(mipi_axis_tvalid & mipi_axis_tready)begin
        if(mipi_axis_tuser[6:1] == 'h1E) beats_1E_dym <=  mipi_axis_tuser[0] ?  1 :  beats_1E_dym + 1  ;
        if(mipi_axis_tuser[6:1] == 'h12) beats_12_dym <=  mipi_axis_tuser[0] ?  1 :  beats_12_dym + 1  ;
        if(mipi_axis_tuser[6:1] == 'h35) beats_35_dym <=  mipi_axis_tuser[0] ?  1 :  beats_35_dym + 1  ;  

        if(mipi_axis_tuser[6:1] == 'h1E) rows_1E_dym <= mipi_axis_tuser[0]  ? 0 :  mipi_axis_tlast ?  rows_1E_dym + 1 :  rows_1E_dym    ;
        if(mipi_axis_tuser[6:1] == 'h12) rows_12_dym <= mipi_axis_tuser[0]  ? 0 :  mipi_axis_tlast ?  rows_12_dym + 1 :  rows_12_dym    ;
        if(mipi_axis_tuser[6:1] == 'h35) rows_35_dym <= mipi_axis_tuser[0]  ? 0 :  mipi_axis_tlast ?  rows_35_dym + 1 :  rows_35_dym    ;  
                
    end


end



generate if(C_ILA_AXIS_CLK_ENABLE)begin
    ila_0  ila_axis_0_u 
    (
        .clk    (mipi_axis_clk       ) ,
        .probe0 (mipi_axis_tvalid   ) ,
        .probe1 ({mipi_axis_tlast, mipi_axis_tready }  ) ,
        .probe2 ({axis_tuser_new, cpnt_num_last_axis, wc_last_axis  ,dt_last_axis ,mipi_axis_tuser[0]  }   ) ,//16+1+1
        .probe3 ( mipi_axis_tkeep ) ,     
        .probe4 ( beats_1E_dym        ) ,  
        .probe5 ( rows_1E_dym         ) , 
        .probe6 ( beats_12_dym        ) ,   
        .probe7 ( rows_12_dym         ) , 
        .probe8 ( beats_35_dym        ) , 
        .probe9 ( rows_35_dym         )   
        
        
        
    
    );
end
endgenerate


generate if(C_ILA_AXILITE_CLK_ENABLE)begin
    ila_1  ila_1_u 
    
    (
        .clk    (s00_axi_aclk        ) ,
        .probe0 ({full_aclk_sig,full_aclk_pos}      )  
    
    );



end
endgenerate




    endmodule
