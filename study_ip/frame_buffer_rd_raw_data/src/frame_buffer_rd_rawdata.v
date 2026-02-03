`define CDC_MULTI_BIT_SIGNAL_OUTGEN(aclk,adata_in,bclk,bdata_out,DATA_WIDTH)                            generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(4),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  
`define CDC_MULTI_BIT_SIGNAL_INGEN(aclk,adata_in,bclk,bdata_out,DATA_WIDTH)                             begin xpm_cdc_array_single #(.DEST_SYNC_FF(4),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end    
`define CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(aclk,adata_in,bclk,bdata_out,DATA_WIDTH)                       generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(4),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(0),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  
`define CDC_MULTI_BIT_SIGNAL_INGEN_NOIN(aclk,adata_in,bclk,bdata_out,DATA_WIDTH)                        begin xpm_cdc_array_single #(.DEST_SYNC_FF(4),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(0),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end    
`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define NEG_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate


//yzhu 2023年7月3日15:04:2
//localparam RD_H_ACTIVE_OFFSET	 		   = 16'h0000;
//localparam RD_V_ACTIVE_OFFSET			   = 16'h0004;
//localparam RD_VDMA_DVAL_OFFSET		   = 16'h0008;

//RAW_DATA 
`define   ADDR_ENABLE       16'h0008 //使能(默认是使能的 )
`define   ADDR_HACTIVE      16'h0000 //
`define   ADDR_VACTIVE      16'h0004 // 
`define   ADDR_MEM_BYTES    16'h000c //不关注
`define   ADDR_STRIP_SET    16'h0010 //不关注
`define   ADDR_RD_START_ADDR  16'h0014  //配置 环出地址
  


//resource , no ila : LUt 495  ,FF 707

module frame_buffer_rd_rawdata #(
//for dma read , only vs(for FRAME SYNC), hactive , vactive , byte num per pixel , frame start addr is needed 
parameter [0:0] C_LB_ENABLE = 0  ,

parameter  C_DMA_BURST_LEN                  = 16           ,        
parameter  C_AXI_LITE_DATA_WIDTH            = 32           ,
parameter  C_AXI_LITE_ADDR_WIDTH            = 16           ,    
parameter  C_AXI4_ADDR_WIDTH                = 32           , 
parameter  C_AXI4_DATA_WIDTH                = 256          ,
//ILA
parameter  [0:0]  C_AXI_LITE_ILA_ENABLE     = 0            ,
parameter  [0:0]  C_AXI4_ILA_ENABLE         = 0            ,
//hard para
parameter  [31:0] C_DDR_BASE_ADDR      =   32'h80000000  , 
parameter  [31:0] C_FRAME_OFFSET_ADDR  =   32'h00000000  , //
parameter         C_FRAME_BUF_NUM      =   1             ,
parameter  [31:0] C_FRAME_BYTE_NUM     =   32'h08000000  ,

//default   para                                                
parameter  [0:0]  C_ENABLE_DEFAULT             = 1       ,
parameter  [3:0]  C_MEM_BYTES_DEFAULT          = 4       ,
parameter  [15:0] C_HACTIVE_DEFAULT            = 3840    ,
parameter  [15:0] C_VACTIVE_DEFAULT            = 2160    ,
parameter  [2:0]  C_STRIP_NUM_DEFAULT          = 1       ,
parameter  [2:0]  C_STRIP_ID_DEFAULT           = 0      ,

parameter  [0:0]  C_RD_SIM_ENABLE             = 0   ,
parameter   C_RD_SIM_PATTERN_TYPE             = 1 ,
parameter   C_RD_SIM_PATTERN_UNIT_BYTE_NUM    = 4 ,

parameter  C_RD_NORM_DATA_SOURCE           = 0, //0时从ddr拉数据
parameter  C_RD_NORM_DATA_UNIT_BYTE_NUM    = 4,
parameter  C_SIM_INTERVAL_NUM              = 0   , //模拟从ddr拉数据时 数据间隔

parameter [0:0] C_RD_LINE_BY_LINE_EN      = 0                

    
) (

// S_AXI_ACLK CLK REGION 
input  wire                                           S_AXI_ACLK           ,
input  wire                                           S_AXI_ARESETN        ,    
output wire                                           S_AXI_AWREADY        ,
input  wire [C_AXI_LITE_ADDR_WIDTH-1:0]               S_AXI_AWADDR         ,
input  wire                                           S_AXI_AWVALID        ,    
input  wire [ 2:0]                                    S_AXI_AWPROT         ,
output wire                                           S_AXI_WREADY         ,
input  wire [C_AXI_LITE_DATA_WIDTH -1:0]              S_AXI_WDATA          ,
input  wire [(C_AXI_LITE_DATA_WIDTH /8)-1 :0]         S_AXI_WSTRB          ,
input  wire                                           S_AXI_WVALID         ,
output wire [ 1:0]                                    S_AXI_BRESP          ,
output wire                                           S_AXI_BVALID         ,
input  wire                                           S_AXI_BREADY         ,
output wire                                           S_AXI_ARREADY        ,
input  wire [C_AXI_LITE_ADDR_WIDTH-1:0]               S_AXI_ARADDR         ,
input  wire                                           S_AXI_ARVALID        ,
input  wire [ 2:0]                                    S_AXI_ARPROT         ,
output wire [ 1:0]                                    S_AXI_RRESP          ,
output wire                                           S_AXI_RVALID         ,
output wire [C_AXI_LITE_DATA_WIDTH -1:0]              S_AXI_RDATA          ,
input  wire                                           S_AXI_RREADY         ,
        

// M_AXI_ACLK CLK REGION 
input                                               M_AXI_ACLK      ,  
input                                               M_AXI_ARESETN   ,  
output    [4-1 : 0]                                 M_AXI_AWID      ,  
output    [C_AXI4_ADDR_WIDTH-1 : 0]                 M_AXI_AWADDR    , 
output    [7 : 0]                                   M_AXI_AWLEN     ,  
output    [2 : 0]                                   M_AXI_AWSIZE    ,  
output    [1 : 0]                                   M_AXI_AWBURST   ,  
output                                              M_AXI_AWLOCK    ,  
output    [3 : 0]                                   M_AXI_AWCACHE   ,  
output    [2 : 0]                                   M_AXI_AWPROT    ,  
output    [3 : 0]                                   M_AXI_AWQOS     ,  
output    [1-1 : 0]                                 M_AXI_AWUSER    ,  
output                                              M_AXI_AWVALID   ,  
input                                               M_AXI_AWREADY   ,  
output    [C_AXI4_DATA_WIDTH-1 : 0]                 M_AXI_WDATA     , 
output    [C_AXI4_DATA_WIDTH/8-1 : 0]               M_AXI_WSTRB     , 
output                                              M_AXI_WLAST     ,  
output    [1-1 : 0]                                 M_AXI_WUSER     ,  
output                                              M_AXI_WVALID    ,  
input                                               M_AXI_WREADY    ,  
input    [4-1 : 0]                                  M_AXI_BID       ,  
input    [1 : 0]                                    M_AXI_BRESP     ,  
input    [1-1 : 0]                                  M_AXI_BUSER     ,  
input                                               M_AXI_BVALID    ,  
output                                              M_AXI_BREADY    ,  
output    [4-1 : 0]                                 M_AXI_ARID      ,  
output    [C_AXI4_ADDR_WIDTH-1 : 0]                 M_AXI_ARADDR    , 
output    [7 : 0]                                   M_AXI_ARLEN     ,  
output    [2 : 0]                                   M_AXI_ARSIZE    ,  
output    [1 : 0]                                   M_AXI_ARBURST   ,  
output                                              M_AXI_ARLOCK    ,  
output    [3 : 0]                                   M_AXI_ARCACHE   ,  
output    [2 : 0]                                   M_AXI_ARPROT    ,  
output    [3 : 0]                                   M_AXI_ARQOS     ,  
output    [1-1 : 0]                                 M_AXI_ARUSER    ,  
output                                              M_AXI_ARVALID   ,  
input                                               M_AXI_ARREADY   ,  
input    [4-1 : 0]                                  M_AXI_RID       ,  
input    [C_AXI4_DATA_WIDTH-1 : 0]                  M_AXI_RDATA     , 
input    [1 : 0]                                    M_AXI_RRESP     ,  
input                                               M_AXI_RLAST     ,  
input    [1-1 : 0]                                  M_AXI_RUSER     ,  
input                                               M_AXI_RVALID    ,  
output                                              M_AXI_RREADY    ,  

input                                               VSYNC    , //~mclk ; frome TPG result; recommend leval signal 
                                                              //recommend  __|————————————————|_______
input                                               WREADY  , //~mclk  recommend one burst space
output                                              WREQ    ,
output  [C_AXI4_DATA_WIDTH-1:0]                     WRDATA  ,        
output  reg                                         WSOF    , //one pulse ;  just before WRDATA valid 
output  reg                                         WEOF    , //one pulse ;  just after  WRDATA valid


input  [C_AXI_LITE_ADDR_WIDTH-1:0]  LB_WADDR   ,
input  [C_AXI_LITE_DATA_WIDTH-1:0]  LB_WDATA   ,
input                               LB_WREQ    ,
input  [C_AXI_LITE_ADDR_WIDTH-1:0]  LB_RADDR   ,
input                               LB_RREQ     ,
output [C_AXI_LITE_DATA_WIDTH-1:0]  LB_RDATA   ,
output                              LB_RFINISH



);

///////////////////////////////////////////////////////////////////////////

reg        R_ENABLE          =  C_ENABLE_DEFAULT    ;
reg [15:0] R_HACTIVE         =  C_HACTIVE_DEFAULT   ;
reg [15:0] R_VACTIVE         =  C_VACTIVE_DEFAULT   ;
reg [3:0]  R_MEM_BYTES       =  C_MEM_BYTES_DEFAULT ;
reg [7:0]  R_STRIP           = {2'b00,C_STRIP_NUM_DEFAULT,C_STRIP_ID_DEFAULT};
reg [31:0] R_RD_START_ADDR   = C_DDR_BASE_ADDR ;
 

wire [2:0] R_STRIP_NUM;
wire [2:0] R_STRIP_ID;
assign R_STRIP_NUM = R_STRIP[5:3];
assign R_STRIP_ID  = R_STRIP[2:0];


wire        R_ENABLE_mclk          ;
wire [15:0] R_HACTIVE_mclk         ;
wire [15:0] R_VACTIVE_mclk         ;
wire [3:0]  R_MEM_BYTES_mclk       ;
wire [8:0]  R_STRIP_mclk           ;
wire [2:0]  R_STRIP_NUM_mclk  ;
wire [2:0]  R_STRIP_ID_mclk   ;


wire                             write_req_cpu_to_axi   ;
wire [C_AXI_LITE_ADDR_WIDTH-1:0] write_addr_cpu_to_axi  ;
wire [C_AXI_LITE_DATA_WIDTH-1:0] write_data_cpu_to_axi  ;
wire                             read_req_cpu_to_axi    ;
wire[C_AXI_LITE_ADDR_WIDTH-1:0]  read_addr_cpu_to_axi   ;
wire  [C_AXI_LITE_DATA_WIDTH-1:0] read_data_axi_to_cpu   ;
wire                              read_finish_axi_to_cpu ;


wire                       write_req_cpu_to_axi_ll   ;
wire [C_AXI_LITE_ADDR_WIDTH-1:0]  write_addr_cpu_to_axi_ll  ;
wire [C_AXI_LITE_DATA_WIDTH-1:0]  write_data_cpu_to_axi_ll  ;
wire                       read_req_cpu_to_axi_ll    ;
wire  [C_AXI_LITE_ADDR_WIDTH-1:0] read_addr_cpu_to_axi_ll   ;
reg  [C_AXI_LITE_DATA_WIDTH-1:0]  read_data_axi_to_cpu_ll    = 0;  
reg                        read_finish_axi_to_cpu_ll  = 0;




reg        rd_trig_axi4 = 0;
reg [31:0] rd_addr_axi4 = 0;
reg [31:0] rd_size_axi4 = 0;


wire       rd_done_axi4 ;    
wire       rd_finish_axi4 ;  

wire [31:0] frame_byte_num_mclk;

reg [7:0] state = 0;




reg    [31:0] frm_byte_num_aclk ;
wire   [31:0] frm_byte_num_mclk;

reg   [31:0] row_byte_num_aclk;
wire  [31:0]  row_byte_num_mclk;

reg   [31:0] row_byte_num_X_strip_id_aclk;//按行读时的起始地址
reg   [31:0] row_byte_num_X_strip_num_aclk;//按行读时的一次递增地址


wire   [31:0] row_byte_num_X_strip_id_mclk; 
wire   [31:0] row_byte_num_X_strip_num_mclk; 


reg [7:0]  frame_buf_id_f0 = 0;
reg [15:0] cnt_v_al;

wire [31:0] rd_beats  ;
wire [31:0] rd_bursts ;

wire VS_I_mclk;
wire VS_I_mclk_pos;
wire VS_I_mclk_neg;

wire r_master_busy ;

assign R_STRIP_NUM_mclk = R_STRIP_mclk[5:3] ;
assign R_STRIP_ID_mclk  = R_STRIP_mclk[2:0] ;





`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN( ,R_ENABLE    ,M_AXI_ACLK,R_ENABLE_mclk      ,1)
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN( ,R_HACTIVE   ,M_AXI_ACLK,R_HACTIVE_mclk     ,16)
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN( ,R_VACTIVE   ,M_AXI_ACLK,R_VACTIVE_mclk     ,16)
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN( ,R_MEM_BYTES ,M_AXI_ACLK,R_MEM_BYTES_mclk   ,4)
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN( ,R_STRIP     ,M_AXI_ACLK,R_STRIP_mclk       ,8)


`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN( ,VSYNC,M_AXI_ACLK,VS_I_mclk,1)

`POS_MONITOR_OUTGEN(M_AXI_ACLK,0,VS_I_mclk,VS_I_mclk_pos)
`NEG_MONITOR_OUTGEN(M_AXI_ACLK,0,VS_I_mclk,VS_I_mclk_neg)



always @(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        frm_byte_num_aclk <= C_HACTIVE_DEFAULT * C_VACTIVE_DEFAULT * C_MEM_BYTES_DEFAULT ;
    end
    else begin
        frm_byte_num_aclk <= R_HACTIVE * R_VACTIVE * R_MEM_BYTES ;
    end
end

`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN( ,frm_byte_num_aclk    ,M_AXI_ACLK,frm_byte_num_mclk      ,32)   


always @(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        row_byte_num_aclk <= C_HACTIVE_DEFAULT  * C_MEM_BYTES_DEFAULT ;
    end
    else begin
        row_byte_num_aclk <= R_HACTIVE * R_MEM_BYTES ;
    end
end

`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN( ,row_byte_num_aclk    ,M_AXI_ACLK,row_byte_num_mclk      ,32)   



reg   [31:0] row_byte_num_X_strip_id_aclk; 
reg   [31:0] row_byte_num_X_strip_num_aclk; 


always @(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        row_byte_num_X_strip_id_aclk <= C_HACTIVE_DEFAULT  * C_MEM_BYTES_DEFAULT * C_STRIP_ID_DEFAULT ;
    end
    else begin
        row_byte_num_X_strip_id_aclk <= R_STRIP_ID==0 ? 0 : R_STRIP_ID==1 ? row_byte_num_aclk*1 :  0   ;
    end
end

`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN( ,row_byte_num_X_strip_id_aclk    ,M_AXI_ACLK,row_byte_num_X_strip_id_mclk      ,32)   



always @(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        row_byte_num_X_strip_num_aclk <= C_HACTIVE_DEFAULT  * C_MEM_BYTES_DEFAULT * C_STRIP_NUM_DEFAULT;
    end
    else begin
        row_byte_num_X_strip_num_aclk <= C_STRIP_NUM_DEFAULT ==1 ?  row_byte_num_aclk   : C_STRIP_NUM_DEFAULT ==2  ? row_byte_num_aclk *2 :   row_byte_num_aclk;
    end
end


`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN( ,row_byte_num_X_strip_num_aclk    ,M_AXI_ACLK,row_byte_num_X_strip_num_mclk      ,32)   


assign write_req_cpu_to_axi_ll  =  C_LB_ENABLE ? LB_WREQ  : write_req_cpu_to_axi  ;
assign write_addr_cpu_to_axi_ll =  C_LB_ENABLE ? LB_WADDR : write_addr_cpu_to_axi ;
assign write_data_cpu_to_axi_ll =  C_LB_ENABLE ? LB_WDATA : write_data_cpu_to_axi ;
assign read_req_cpu_to_axi_ll   =  C_LB_ENABLE ? LB_RREQ  : read_req_cpu_to_axi ;
assign read_addr_cpu_to_axi_ll  =  C_LB_ENABLE ? LB_RADDR : read_addr_cpu_to_axi ;

assign read_data_axi_to_cpu     =  C_LB_ENABLE ? 0 : read_data_axi_to_cpu_ll   ;
assign read_finish_axi_to_cpu   =  C_LB_ENABLE ? 0 : read_finish_axi_to_cpu_ll ;
assign LB_RDATA                 =  C_LB_ENABLE ? read_data_axi_to_cpu_ll   : 0 ;
assign LB_RFINISH               =  C_LB_ENABLE ? read_finish_axi_to_cpu_ll : 0 ;




axi_lite_slave #(
    .C_S_AXI_DATA_WIDTH (C_AXI_LITE_DATA_WIDTH  ),
    .C_S_AXI_ADDR_WIDTH (C_AXI_LITE_ADDR_WIDTH  ) )
    axi_lite_slave_u(
    .S_AXI_ACLK            (S_AXI_ACLK        ),
    .S_AXI_ARESETN         (S_AXI_ARESETN     ),
    .S_AXI_AWREADY         (S_AXI_AWREADY     ),
    .S_AXI_AWADDR          (S_AXI_AWADDR      ),
    .S_AXI_AWVALID         (S_AXI_AWVALID     ),
    .S_AXI_AWPROT          (S_AXI_AWPROT      ),
    .S_AXI_WREADY          (S_AXI_WREADY      ),
    .S_AXI_WDATA           (S_AXI_WDATA       ),
    .S_AXI_WSTRB           (S_AXI_WSTRB       ),
    .S_AXI_WVALID          (S_AXI_WVALID      ),
    .S_AXI_BRESP           (S_AXI_BRESP       ),
    .S_AXI_BVALID          (S_AXI_BVALID      ),
    .S_AXI_BREADY          (S_AXI_BREADY      ),
    .S_AXI_ARREADY         (S_AXI_ARREADY     ),
    .S_AXI_ARADDR          (S_AXI_ARADDR      ),
    .S_AXI_ARVALID         (S_AXI_ARVALID     ),
    .S_AXI_ARPROT          (S_AXI_ARPROT      ),
    .S_AXI_RRESP           (S_AXI_RRESP       ),
    .S_AXI_RVALID          (S_AXI_RVALID      ),
    .S_AXI_RDATA           (S_AXI_RDATA       ),
    .S_AXI_RREADY          (S_AXI_RREADY      ),
    
    .write_req_cpu_to_axi  (write_req_cpu_to_axi   ),
    .write_addr_cpu_to_axi (write_addr_cpu_to_axi  ),
    .write_data_cpu_to_axi (write_data_cpu_to_axi  ),
    .read_req_cpu_to_axi   (read_req_cpu_to_axi    ),
    .read_addr_cpu_to_axi  (read_addr_cpu_to_axi   ),
    .read_data_axi_to_cpu  (read_data_axi_to_cpu   ),
    .read_finish_axi_to_cpu(read_finish_axi_to_cpu ) 
      
    );



//cpu write 
always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        R_ENABLE          <= C_ENABLE_DEFAULT ;
        R_HACTIVE         <= C_HACTIVE_DEFAULT ;
        R_VACTIVE         <= C_VACTIVE_DEFAULT ;
        R_MEM_BYTES       <= C_MEM_BYTES_DEFAULT ;
        R_STRIP           <= {2'b00,C_STRIP_NUM_DEFAULT,C_STRIP_ID_DEFAULT};
        R_RD_START_ADDR   <= C_DDR_BASE_ADDR ;
    end
    else if(write_req_cpu_to_axi_ll)begin
        case(write_addr_cpu_to_axi_ll)
            `ADDR_ENABLE          : R_ENABLE          <= {0,write_data_cpu_to_axi_ll} ;
            `ADDR_HACTIVE         : R_HACTIVE         <= {0,write_data_cpu_to_axi_ll} ;
            `ADDR_VACTIVE         : R_VACTIVE         <= {0,write_data_cpu_to_axi_ll} ;
            `ADDR_MEM_BYTES       : R_MEM_BYTES       <= {0,write_data_cpu_to_axi_ll} ;
            `ADDR_STRIP_SET       : R_STRIP           <= {0,write_data_cpu_to_axi_ll} ;
            `ADDR_RD_START_ADDR   : R_RD_START_ADDR   <= {0,write_data_cpu_to_axi_ll} ;
            default:;
        endcase
    end
end



//cpu read
always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        read_data_axi_to_cpu_ll   <= 0;
        read_finish_axi_to_cpu_ll <= 0;
    end
    else if(read_req_cpu_to_axi_ll)begin
        read_finish_axi_to_cpu_ll <= 1;
        case(read_addr_cpu_to_axi_ll)
            `ADDR_ENABLE          : read_data_axi_to_cpu_ll <= R_ENABLE     ; 
            `ADDR_HACTIVE         : read_data_axi_to_cpu_ll <= R_HACTIVE    ; 
            `ADDR_VACTIVE         : read_data_axi_to_cpu_ll <= R_VACTIVE    ; 
            `ADDR_MEM_BYTES       : read_data_axi_to_cpu_ll <= R_MEM_BYTES  ; 
            `ADDR_STRIP_SET       : read_data_axi_to_cpu_ll <= R_STRIP      ; 
            `ADDR_RD_START_ADDR   : read_data_axi_to_cpu_ll <= R_RD_START_ADDR ;
            default:;
        endcase
    end
    else begin
        read_finish_axi_to_cpu_ll <= 0;
    end
end


reg  [31:0]    C_FRAME_BYTE_NUM_x_frame_buf_id_f0 ;
always @(posedge M_AXI_ACLK)begin
    if(~M_AXI_ARESETN)begin
        C_FRAME_BYTE_NUM_x_frame_buf_id_f0 <= 0;//frame_buf_id_f0  * C_FRAME_BYTE_NUM  ;
    end
    else begin
        C_FRAME_BYTE_NUM_x_frame_buf_id_f0 <= frame_buf_id_f0  * C_FRAME_BYTE_NUM  ;
    end
end



/////////////////////////////////////////////////////////////////////
//vs上沿触发退出burst，等待退出完成后，生成启动操作的信号
reg  master_trig = 0;
reg [7:0] state_mt;
always@(posedge M_AXI_ACLK)begin
    if(~M_AXI_ARESETN)begin
        master_trig <= 0;
        state_mt <= 0;
    end
    else begin
        case(state_mt)
            0:begin
                master_trig <= 0;
                state_mt <=  VS_I_mclk_pos ? 1 : state_mt ;
            end
            1:begin
                master_trig <= r_master_busy==0 ? 1 : 0 ;
                state_mt    <= r_master_busy==0 ? 0 : state_mt  ;
            end
            default:;
        endcase
    end
end



always@(posedge M_AXI_ACLK)begin
    if(~M_AXI_ARESETN)begin
        state <= 0;
        WSOF <= 0;
        WEOF <= 0;
        rd_addr_axi4 <= 0;
        rd_size_axi4 <= 0;
        rd_trig_axi4 <= 0;   
        cnt_v_al    <= 0;
        frame_buf_id_f0 <= 0;
    end
    else if(VS_I_mclk_pos)begin
        frame_buf_id_f0  <=   frame_buf_id_f0 == C_FRAME_BUF_NUM-1 ? 0 : frame_buf_id_f0 + 1  ;
	    state        <= 0;
        rd_trig_axi4 <= 0;
        rd_addr_axi4 <= 0;
        rd_size_axi4 <= 0;
        cnt_v_al     <= 0;
	end
    else if(master_trig & R_ENABLE_mclk )begin
        
        rd_addr_axi4 <= R_RD_START_ADDR + C_FRAME_BYTE_NUM_x_frame_buf_id_f0  + row_byte_num_X_strip_id_mclk ;
        rd_size_axi4 <= C_RD_LINE_BY_LINE_EN ?  row_byte_num_mclk :   frm_byte_num_mclk ;
        state        <= C_RD_LINE_BY_LINE_EN ? 1 : 3;
        rd_trig_axi4 <= 1;
        WSOF         <= 1;
        WEOF         <= 0;
        cnt_v_al     <= 0;
    end 
    else case(state)
        0:begin //hollow state
            WEOF         <= 0;
            WSOF         <= 0;
        end
        1:begin
            if(cnt_v_al >= R_VACTIVE_mclk)begin
                 WEOF  <= 1;
                 state <= 0; 
            end
            else begin
                rd_addr_axi4 <= rd_addr_axi4 ;
                rd_size_axi4 <= row_byte_num_mclk ;
                rd_trig_axi4 <= 1 ; //读下一行
                WSOF         <= 0 ; 
                WEOF         <= 0 ;
                state        <= 2 ; 
            end
        end
        2:begin
            rd_trig_axi4 <= 0; 
            state        <= rd_finish_axi4 ?    1         :   state ;
            cnt_v_al     <= rd_finish_axi4 ? cnt_v_al + 1 :   cnt_v_al;
            rd_addr_axi4 <= rd_finish_axi4 ? rd_addr_axi4 +  row_byte_num_X_strip_num_mclk : rd_addr_axi4;//控制 跳地址跳几行
        end
        3:begin
            WSOF <=0;
            rd_trig_axi4 <= 0;
            state        <= rd_finish_axi4 ? 0 : state ;
            WEOF         <= rd_finish_axi4 ? 1  : state ;
        end
        default:;
    endcase
end




axi4_master 
   #(.C_M_AXI_BURST_LEN             (C_DMA_BURST_LEN   ) , //1, 2, 4, 8, 16, 32, 64, 128, 256
     .C_M_AXI_ADDR_WIDTH            (C_AXI4_ADDR_WIDTH ) , // 32 64
     .C_M_AXI_DATA_WIDTH            (C_AXI4_DATA_WIDTH ) , //32 64 128 256
     .C_RD_BLOCK_ENABLE             (1 ) , //= 1,
     .C_WR_BLOCK_ENABLE             (0 ) , //= 1,
     .C_RD_SIM_ENABLE               (C_RD_SIM_ENABLE) , //= 0,
     .C_WR_SIM_ENABLE               (0) , //= 0,
     .C_RD_SIM_PATTERN_TYPE         (C_RD_SIM_PATTERN_TYPE          ) , //0:全0  1：循环
     .C_RD_SIM_PATTERN_UNIT_BYTE_NUM(C_RD_SIM_PATTERN_UNIT_BYTE_NUM ) , //= 4,
     .C_RD_NORM_DATA_SOURCE         (C_RD_NORM_DATA_SOURCE        ) , //= 0,
     .C_RD_NORM_DATA_UNIT_BYTE_NUM  (C_RD_NORM_DATA_UNIT_BYTE_NUM ) , //= 4,
     .C_RD_ALIGN_ENABLE             (0) , //= 0,
     .C_RD_BLOCK_ALIGN_BYTE_NUM     (4096) , //= 4096,
     .C_OP_DELAY_CLK_NUM            (10) ,  //= 0  
     .C_SIM_INTERVAL_NUM             (C_SIM_INTERVAL_NUM)
    )
    axi4_master_u(
   .M_AXI_ACLK    (M_AXI_ACLK         ),  
   .M_AXI_ARESETN (M_AXI_ARESETN     ),  
   .M_AXI_AWID    (M_AXI_AWID        ), 
   .M_AXI_AWADDR  (M_AXI_AWADDR      ), 
   .M_AXI_AWLEN   (M_AXI_AWLEN       ), 
   .M_AXI_AWSIZE  (M_AXI_AWSIZE      ), 
   .M_AXI_AWBURST (M_AXI_AWBURST     ), 
   .M_AXI_AWLOCK  (M_AXI_AWLOCK      ), 
   .M_AXI_AWCACHE (M_AXI_AWCACHE     ), 
   .M_AXI_AWPROT  (M_AXI_AWPROT      ), 
   .M_AXI_AWQOS   (M_AXI_AWQOS       ), 
   .M_AXI_AWUSER  (M_AXI_AWUSER      ), 
   .M_AXI_AWVALID (M_AXI_AWVALID     ), 
   .M_AXI_AWREADY (M_AXI_AWREADY     ), 
   .M_AXI_WDATA   (M_AXI_WDATA       ), 
   .M_AXI_WSTRB   (M_AXI_WSTRB       ), 
   .M_AXI_WLAST   (M_AXI_WLAST       ), 
   .M_AXI_WUSER   (M_AXI_WUSER       ), 
   .M_AXI_WVALID  (M_AXI_WVALID      ), 
   .M_AXI_WREADY  (M_AXI_WREADY      ), 
   .M_AXI_BID     (M_AXI_BID         ), 
   .M_AXI_BRESP   (M_AXI_BRESP       ), 
   .M_AXI_BUSER   (M_AXI_BUSER       ), 
   .M_AXI_BVALID  (M_AXI_BVALID      ), 
   .M_AXI_BREADY  (M_AXI_BREADY      ), 
   .M_AXI_ARID    (M_AXI_ARID        ), 
   .M_AXI_ARADDR  (M_AXI_ARADDR      ), 
   .M_AXI_ARLEN   (M_AXI_ARLEN       ), 
   .M_AXI_ARSIZE  (M_AXI_ARSIZE      ), 
   .M_AXI_ARBURST (M_AXI_ARBURST     ), 
   .M_AXI_ARLOCK  (M_AXI_ARLOCK      ), 
   .M_AXI_ARCACHE (M_AXI_ARCACHE     ), 
   .M_AXI_ARPROT  (M_AXI_ARPROT      ), 
   .M_AXI_ARQOS   (M_AXI_ARQOS       ), 
   .M_AXI_ARUSER  (M_AXI_ARUSER      ), 
   .M_AXI_ARVALID (M_AXI_ARVALID     ), 
   .M_AXI_ARREADY (M_AXI_ARREADY     ), 
   .M_AXI_RID     (M_AXI_RID         ), 
   .M_AXI_RDATA   (M_AXI_RDATA       ), 
   .M_AXI_RRESP   (M_AXI_RRESP       ), 
   .M_AXI_RLAST   (M_AXI_RLAST       ), 
   .M_AXI_RUSER   (M_AXI_RUSER       ), 
   .M_AXI_RVALID  (M_AXI_RVALID      ), 
   .M_AXI_RREADY  (M_AXI_RREADY      ), 
    
   .R_RST_I       ( 0               ),
   .R_STOP_I      ( VS_I_mclk       ),
   .R_BUSY_O      ( r_master_busy   ),
   .R_REQ_I       (rd_trig_axi4     ),
   .R_START_ADDR_I(rd_addr_axi4     ), 
   .R_BYTE_NUM_I  (rd_size_axi4     ), 
  
   .R_FIFO_FULL_I (~WREADY          ), //when outer module's fifo is ready(wready if burst ready)
   .R_FIFO_WRITE_O(WREQ             ), 
   .R_FIFO_DATA_O (WRDATA           ), 
   .R_DONE_O      (rd_done_axi4     ), 
   .R_FINISH_O    (rd_finish_axi4   ),
   .R_INNER_DATA_RST_I (VS_I_mclk_pos   ), //用上沿的原因是，VS高时，写操作就可能开始了
   
   
   .R_BEATS_O   (rd_beats  ),//只对normal模式有效
   .R_BURSTS_O  (rd_bursts ) //只对normal模式有效
   
  
   );



generate if(C_AXI_LITE_ILA_ENABLE)begin
    ila_2    ila_axi_lite_u(
    .clk     (S_AXI_ACLK    ),
    .probe0  (R_ENABLE          ),
    .probe1  (R_HACTIVE         ),
    .probe2  (R_VACTIVE         ),
    .probe3  (R_MEM_BYTES       )

    );    


end
endgenerate



generate if(C_AXI4_ILA_ENABLE)begin
    ila_3 ila_axi4_clk_u (
    .clk   ( M_AXI_ACLK ),
    .probe0( state ),
    .probe1( VS_I_mclk ),
    .probe2( rd_trig_axi4 ),
    .probe3( rd_finish_axi4 ),
    .probe4( WREADY  ),
    .probe5( WREQ    ),
    .probe6( WRDATA  ),
    .probe7( rd_addr_axi4 ),
    .probe8( rd_size_axi4 ),
    .probe9 (cnt_v_al ),
    .probe10(R_ENABLE_mclk ),
    .probe11(rd_beats ),
    .probe12(rd_bursts),
    .probe13(r_master_busy  )
    
    );


end
endgenerate



endmodule 



