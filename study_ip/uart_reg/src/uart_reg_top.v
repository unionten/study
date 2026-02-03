`timescale 1ns / 1ps


`define  ADDR_FPD_RATE          16'h0000    //0:fpd3  1:3.375   2:6.75   3:10.8    4:12.528    5:13.5 
`define  ADDR_HSYNC             16'h0004
`define  ADDR_HBP               16'h0008
`define  ADDR_HACTIVE           16'h000c
`define  ADDR_HFP               16'h0010
`define  ADDR_VSYNC             16'h0014
`define  ADDR_VBP               16'h0018
`define  ADDR_VACTIVE           16'h001c
`define  ADDR_VFP               16'h0020
`define  ADDR_FPS               16'h0024  
`define  ADDR_SERADDR           16'h0028   //8bit addr 
`define  ADDR_DESERADDR         16'h002c   //8bit addr 
`define  ADDR_CONF              16'h0030  
`define  ADDR_PATTERN_SRC       16'h0034  
`define  ADDR_PATTERN_ID        16'h0038  
`define  ADDR_SD_PHY_ADDR       16'h003c  
`define  ADDR_STP_COAX          16'h0040 
`define  ADDR_FPD_TX_MODE       16'h0044   //b00: 单口port0模式   b10:单口port1模式   b10:双口独立模式    b11:dual模式

`define  ADDR_IIC_BYPASS        16'h0048   //iic wr bypass,  8bit(7bit + 1bit) + 16bit + 8bit
`define  ADDR_FLAG              16'h004c 

`define  _RATE_FPD3             0
`define  _RATE_FPD4_3_375       1
`define  _RATE_FPD4_6_75        2
`define  _RATE_FPD4_10_8        3
`define  _RATE_FPD4_12_528      4
`define  _RATE_FPD4_13_5        5



`define  _CONF_SER_DES          2'b11
`define  _CONF_SER              2'b01
`define  _CONF_DES              2'b10
`define  _CONF_NONE             2'b00



//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// 
// Create Date: 2025/01/14 10:11:13
// Design Name: 
// Module Name: uart_reg_top
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


module uart_reg_top(

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

input  UART_RX ,
output UART_TX ,
output reg FLAG_O  = 0  ,
output  STP_COAX_O  ,
output  reg STP_COAX_EN_O = 0,
output reg IIC_IRPT = 0 ,

output SDA_O     ,
input  SDA_I     ,
output SDA_T     ,
output SCL_O     ,
input  SCL_I     ,
output SCL_T     ,
output IIC_EN_O  


    );

parameter C_AXI_LITE_ADDR_WIDTH = 16 ;
parameter C_AXI_LITE_DATA_WIDTH = 32 ;
parameter C_AXI_PRD_NS  =  10 ;
parameter C_BAUD_RATE   =  9600 ;
parameter C_ILA_ENABLE =  0 ;


parameter C_FPD_RATE_DEFAULT  =  1      ;     
parameter C_HSYNC_DEFAULT     =  28    ;       
parameter C_HBP_DEFAULT       =  32    ;         
parameter C_HACTIVE_DEFAULT   =  2560  ;     
parameter C_HFP_DEFAULT       =  64    ;         
parameter C_VSYNC_DEFAULT     =  2     ;       
parameter C_VBP_DEFAULT       =  5     ;         
parameter C_VACTIVE_DEFAULT   =  680   ;     
parameter C_VFP_DEFAULT       =  10    ;         
parameter C_FPS_DEFAULT       =  60    ;         
parameter C_SERADDR_DEFAULT   =  8'h20 ;     
parameter C_DESERADDR_DEFAULT =  8'h58 ;   
parameter C_CONF_DEFAULT      =  2'b01 ;        
parameter  C_PATTERN_SRC_DEFAULT  = 0 ;
parameter  C_PATTERN_ID_DEFAULT =  6;
parameter  C_SD_PHY_ADDR_DEFAULT  = 46496 ;//41088
parameter  C_STP_COAX_DEFAULT      =   0 ;
parameter  C_FPD_TX_MODE_DEFAULT = 0 ;//0  1  2   3


    
reg [7:0]   R_FPD_RATE      = C_FPD_RATE_DEFAULT   ;// 16'h0000    //0:fpd3  1:3.375   2:6.75   3:10.8    4:12.528    5:13.5 
reg [15:0]  R_HSYNC         = C_HSYNC_DEFAULT      ;// 16'h0004
reg [15:0]  R_HBP           = C_HBP_DEFAULT        ;// 16'h0008
reg [15:0]  R_HACTIVE       = C_HACTIVE_DEFAULT    ;// 16'h000c
reg [15:0]  R_HFP           = C_HFP_DEFAULT        ;// 16'h0010
reg [15:0]  R_VSYNC         = C_VSYNC_DEFAULT      ;// 16'h0014
reg [15:0]  R_VBP           = C_VBP_DEFAULT        ;// 16'h0018
reg [15:0]  R_VACTIVE       = C_VACTIVE_DEFAULT    ;// 16'h001c
reg [15:0]  R_VFP           = C_VFP_DEFAULT        ;// 16'h0020
reg [15:0]  R_FPS           = C_FPS_DEFAULT        ;// 16'h0024  
reg [7:0]   R_SERADDR       = C_SERADDR_DEFAULT    ;// 16'h0028 
reg [7:0]   R_DESERADDR     = C_DESERADDR_DEFAULT  ;// 16'h002c 
reg [1:0]   R_CONF          = C_CONF_DEFAULT       ;// 16'h0030  
reg [7:0]   R_PATTERN_SRC   = C_PATTERN_SRC_DEFAULT  ;// 00(983内部) 01(fpga内部) 10(tf)
reg [7:0]   R_PATTERN_ID    = C_PATTERN_ID_DEFAULT   ;
reg [31:0]  R_SD_PHY_ADDR  = C_SD_PHY_ADDR_DEFAULT  ;

reg  R_STP_COAX = C_STP_COAX_DEFAULT ;
reg [1:0]  R_FPD_TX_MODE  =  C_FPD_TX_MODE_DEFAULT ;

// iic 
reg [6:0]   dev_addr;
reg [0:0]   wr_rd_bit;
reg [15:0]  reg_addr ;
reg [7:0]   reg_data ; 
  
assign  STP_COAX_O = R_STP_COAX ;

wire [7:0] pdata ; 
wire finish  ;
reg [7:0]  state = 0 ;
(*keep="true"*)reg [15:0] reg_addr_buf = 0 ;
(*keep="true"*)reg [31:0] reg_data_buf = 0 ;
   

   
wire  write_req_cpu_to_axi   ;
wire  [C_AXI_LITE_ADDR_WIDTH-1:0] write_addr_cpu_to_axi  ;
wire [C_AXI_LITE_DATA_WIDTH-1:0] write_data_cpu_to_axi  ;
wire read_req_cpu_to_axi    ;
wire  [C_AXI_LITE_ADDR_WIDTH-1:0]  read_addr_cpu_to_axi   ;
reg [C_AXI_LITE_DATA_WIDTH-1:0] read_data_axi_to_cpu=0   ;
reg  read_finish_axi_to_cpu =0;



axi_lite_slave #(
    .C_S_AXI_ADDR_WIDTH (C_AXI_LITE_ADDR_WIDTH  ),
    .C_S_AXI_DATA_WIDTH (C_AXI_LITE_DATA_WIDTH  )
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
    
    
    

uart_rx_byte_none
    #(.SYS_CLK_PERIOD (C_AXI_PRD_NS ),
      .BAUD_RATE      (C_BAUD_RATE  ) )
    (
    .RST_I      (~S_AXI_ARESETN  ),
    .CLK_I      (S_AXI_ACLK      ), 
    .UART_I     (UART_RX         ),
    .PDATA_O    (pdata           ),
    .FINISH_O   (finish          )
    );
 



always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        state <= 0;
        reg_addr_buf <= 0; 
        reg_data_buf <= 0;
        R_FPD_RATE    <= C_FPD_RATE_DEFAULT  ;
        R_HSYNC       <= C_HSYNC_DEFAULT     ;
        R_HBP         <= C_HBP_DEFAULT       ;
        R_HACTIVE     <= C_HACTIVE_DEFAULT   ;
        R_HFP         <= C_HFP_DEFAULT       ;
        R_VSYNC       <= C_VSYNC_DEFAULT     ;
        R_VBP         <= C_VBP_DEFAULT       ;
        R_VACTIVE     <= C_VACTIVE_DEFAULT   ;
        R_VFP         <= C_VFP_DEFAULT       ;
        R_FPS         <= C_FPS_DEFAULT       ;
        R_SERADDR     <= C_SERADDR_DEFAULT   ;
        R_DESERADDR   <= C_DESERADDR_DEFAULT ;
        R_CONF        <= C_CONF_DEFAULT      ;
        FLAG_O        <= 0     ; 
        R_PATTERN_SRC  <= C_PATTERN_SRC_DEFAULT  ;
        R_PATTERN_ID  <= C_PATTERN_ID_DEFAULT ;
        R_SD_PHY_ADDR <= C_SD_PHY_ADDR_DEFAULT ;
        R_STP_COAX    <= C_STP_COAX_DEFAULT ;
        R_FPD_TX_MODE <= C_FPD_TX_MODE_DEFAULT ;
        IIC_IRPT      <= 0 ;
    end
    else begin
        case(state)
            0:begin
                IIC_IRPT <= 0;
                state <= pdata==8'hA5 & finish ? 1 : state ;   
            end
            1:begin
                reg_addr_buf <= finish  ?  {reg_addr_buf[7:0],pdata} : reg_addr_buf ;
                state        <= finish  ?  2 : state ;
            end
            2:begin
                reg_addr_buf <= finish  ?  {reg_addr_buf[7:0],pdata} : reg_addr_buf ;
                state        <= finish  ?  3 : state ;
            end
            3:begin
                reg_data_buf <= finish  ?  {reg_data_buf[23:0],pdata} : reg_data_buf ;
                state        <= finish  ?  4 : state ;
            end
            4:begin
                reg_data_buf <= finish  ?  {reg_data_buf[23:0],pdata} : reg_data_buf ;
                state        <= finish  ?  5 : state ;
            end
            5:begin
                reg_data_buf <= finish  ?  {reg_data_buf[23:0],pdata} : reg_data_buf ;
                state        <= finish  ?  6 : state ;
            end
            6:begin
                reg_data_buf <= finish  ?  {reg_data_buf[23:0],pdata} : reg_data_buf ;
                state        <= finish  ?  7 : state ;
            end
            7:begin
                state <= finish ?  ( pdata==8'h5A ?  8 : 0  )  :  state  ;     
            end
            8:begin
                R_FPD_RATE    <=  reg_addr_buf==`ADDR_FPD_RATE   ? reg_data_buf : R_FPD_RATE     ;
                R_HSYNC       <=  reg_addr_buf==`ADDR_HSYNC      ? reg_data_buf : R_HSYNC        ;
                R_HBP         <=  reg_addr_buf==`ADDR_HBP        ? reg_data_buf : R_HBP          ;
                R_HACTIVE     <=  reg_addr_buf==`ADDR_HACTIVE    ? reg_data_buf : R_HACTIVE      ;
                R_HFP         <=  reg_addr_buf==`ADDR_HFP        ? reg_data_buf : R_HFP          ;
                R_VSYNC       <=  reg_addr_buf==`ADDR_VSYNC      ? reg_data_buf : R_VSYNC        ;
                R_VBP         <=  reg_addr_buf==`ADDR_VBP        ? reg_data_buf : R_VBP          ;
                R_VACTIVE     <=  reg_addr_buf==`ADDR_VACTIVE    ? reg_data_buf : R_VACTIVE      ;
                R_VFP         <=  reg_addr_buf==`ADDR_VFP        ? reg_data_buf : R_VFP          ;
                R_FPS         <=  reg_addr_buf==`ADDR_FPS        ? reg_data_buf : R_FPS          ;
                R_SERADDR     <=  reg_addr_buf==`ADDR_SERADDR    ? reg_data_buf : R_SERADDR      ;
                R_DESERADDR   <=  reg_addr_buf==`ADDR_DESERADDR  ? reg_data_buf : R_DESERADDR    ;
                R_CONF        <=  reg_addr_buf==`ADDR_CONF       ? reg_data_buf : R_CONF         ;
                R_PATTERN_SRC  <=  reg_addr_buf==`ADDR_PATTERN_SRC ? reg_data_buf : R_PATTERN_SRC   ;
                R_PATTERN_ID   <=  reg_addr_buf==`ADDR_PATTERN_ID  ? reg_data_buf : R_PATTERN_ID   ;
                R_SD_PHY_ADDR  <=  reg_addr_buf==`ADDR_SD_PHY_ADDR ? reg_data_buf : R_SD_PHY_ADDR   ; 
                R_STP_COAX     <=   reg_addr_buf==`ADDR_STP_COAX  ? reg_data_buf : R_STP_COAX   ;    
                STP_COAX_EN_O  <=   reg_addr_buf==`ADDR_STP_COAX  ? 1 : 0   ;    
                R_FPD_TX_MODE <=  reg_addr_buf==`ADDR_FPD_TX_MODE ? reg_data_buf : R_FPD_TX_MODE ;
                
                FLAG_O        <=  reg_addr_buf==16'hFFFF         ? ~FLAG_O      : FLAG_O         ;
                
                {dev_addr,wr_rd_bit,reg_addr,reg_data} <= reg_addr_buf ==`ADDR_IIC_BYPASS ?  reg_data_buf  :  {dev_addr,wr_rd_bit,reg_addr,reg_data}  ;
                IIC_IRPT      <= reg_addr_buf==`ADDR_IIC_BYPASS ? 1 :  0 ; 

                state <= 0;
            end
            
            default:;
        endcase
    end
end
    
    
    
 uart_to_iic  
 #(.SYS_CLK_PRD_NS (C_AXI_PRD_NS) ,
   .BAUD_RATE      (C_BAUD_RATE) ) 
 uart_to_iic_u
 (
.CLK_I         (S_AXI_ACLK   ), 
.RSTN_I        (S_AXI_ARESETN),
.WR_EN_I       (IIC_IRPT     ),
.WR_DEV_ADDR_I (dev_addr     ),
.WR_WRRD_I     (wr_rd_bit    ),
.WR_REG_ADDR_I (reg_addr     ),
.WR_REG_DATA_I (reg_data     ),
.UART_O        (UART_TX      ),
.SDA_O         (SDA_O        ),
.SDA_I         (SDA_I        ),
.SDA_T         (SDA_T        ),
.SCL_O         (SCL_O        ),
.SCL_I         (SCL_I        ),
.SCL_T         (SCL_T        ),
.IIC_EN_O      (IIC_EN_O     )

 );
    

ila_1  ila_1_u
(
.clk     (S_AXI_ACLK  ) ,
.probe0  (IIC_IRPT  ) ,
.probe1  (dev_addr  ) ,
.probe2  (wr_rd_bit ) ,
.probe3  (reg_addr  ) ,
.probe4  (reg_data  ) ,
.probe5  (reg_data_buf ),//32
.probe6  (state ),
.probe7  (uart_to_iic_u.err  )







);





 
always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        read_data_axi_to_cpu    <= 0;
        read_finish_axi_to_cpu  <= 0;
    end
    else if(read_req_cpu_to_axi)begin
        read_finish_axi_to_cpu <= 1 ;
        case(read_addr_cpu_to_axi)    
            `ADDR_FPD_RATE  : read_data_axi_to_cpu <=  R_FPD_RATE   ;
            `ADDR_HSYNC     : read_data_axi_to_cpu <=  R_HSYNC      ;
            `ADDR_HBP       : read_data_axi_to_cpu <=  R_HBP        ;
            `ADDR_HACTIVE   : read_data_axi_to_cpu <=  R_HACTIVE    ;
            `ADDR_HFP       : read_data_axi_to_cpu <=  R_HFP        ;
            `ADDR_VSYNC     : read_data_axi_to_cpu <=  R_VSYNC      ;
            `ADDR_VBP       : read_data_axi_to_cpu <=  R_VBP        ;
            `ADDR_VACTIVE   : read_data_axi_to_cpu <=  R_VACTIVE    ;
            `ADDR_VFP       : read_data_axi_to_cpu <=  R_VFP        ;
            `ADDR_FPS       : read_data_axi_to_cpu <=  R_FPS        ;
            `ADDR_SERADDR   : read_data_axi_to_cpu <=  R_SERADDR    ;
            `ADDR_DESERADDR : read_data_axi_to_cpu <=  R_DESERADDR  ;
            `ADDR_CONF      : read_data_axi_to_cpu <=  R_CONF       ;
            `ADDR_PATTERN_SRC: read_data_axi_to_cpu <=  R_PATTERN_SRC ;
            `ADDR_SD_PHY_ADDR : read_data_axi_to_cpu <= R_SD_PHY_ADDR ;
            `ADDR_PATTERN_ID : read_data_axi_to_cpu <=  R_PATTERN_ID  ;
            `ADDR_STP_COAX   : read_data_axi_to_cpu <=  R_STP_COAX ;
            `ADDR_FPD_TX_MODE : read_data_axi_to_cpu <= R_FPD_TX_MODE ;
            `ADDR_FLAG        : read_data_axi_to_cpu <= FLAG_O     ;
            
            
            default : ;
        endcase
    end
    else begin
        read_finish_axi_to_cpu <= 0;
    end
end  
    
    
    
generate if(C_ILA_ENABLE)begin
    ila_0  ila_0_u
    (
    .clk      (S_AXI_ACLK  ) ,
    .probe0   (R_FPD_RATE  ) ,   
    .probe1   (R_HSYNC     ) ,   
    .probe2   (R_HBP       ) ,        
    .probe3   (R_HACTIVE   ) ,   
    .probe4   (R_HFP       ) ,       
    .probe5   (R_VSYNC     ) ,  
    .probe6   (R_VBP       ) ,  
    .probe7   (R_VACTIVE   ) ,  
    .probe8   (R_VFP       ) ,  
    .probe9   (R_FPS       ) ,  
    .probe10  (R_SERADDR   ) ,  
    .probe11  (R_DESERADDR ) ,  
    .probe12  ({reg_data_buf,R_CONF }     ) ,  
    .probe13  ({FLAG_O,state}      ) ,  
    .probe14  (pdata      ) ,  
    .probe15  ({reg_addr_buf,finish }     )     
    
    );
    
  


end
endgenerate    
    
    
    
endmodule




