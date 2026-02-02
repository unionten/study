`timescale 1ns / 1ps
`define CDC_MULTI_BIT_SIGNAL_OUTGEN(aclk,adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                    generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  
`define CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                    generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(0),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk( ),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  
`define CDC_SINGLE_BIT_PULSE_OUTGEN(aclk,arst,apulse_in,bclk,brst,bpulse_out,SIM,DEST_FF)               generate if(SIM==0)begin  xpm_cdc_pulse #(.DEST_SYNC_FF(DEST_FF), .INIT_SYNC_FF(0),.REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) cdc_u (.src_clk(aclk),.src_rst(arst),.src_pulse(apulse_in),.dest_clk(bclk),.dest_rst(brst),.dest_pulse(bpulse_out));   end else begin   reg [5:0] name1 = 0;wire name2;always@(posedge aclk)if(arst)name1[0] <=0;else name1[0] <= apulse_in;assign name2 = apulse_in & ~name1[0]; always@(posedge aclk)if(arst)name1[1] <= 0;else name1[1] <= name2 ? ~name1[1]:name1[1];always@(posedge bclk)if(brst)name1[5:2]<=0;else begin name1[2]<=name1[1];name1[3]<=name1[2];name1[4]<=name1[3];name1[5]<=name1[4];end  assign bpulse_out=name1[4]^name1[5];  end  endgenerate
`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define NEG_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate
`define HANDSHAKE_OUTGEN(aclk,arst,apulse_in,adata_in,bclk,brst,bpulse_out,bdata_out,DATA_WIDTH,SIM)    generate  if(SIM==0) begin  handshake  #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I ( bclk),.DST_DATA_O (bdata_out),.DST_SYNC_FINISH_O(bpulse_out) ); end  else  begin  handshake2 #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I (bclk),.DST_DATA_O (bdata_out ),.DST_SYNC_FINISH_O(bpulse_out) ); end  endgenerate   

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/08 21:17:58
// Design Name: 
// Module Name: axi2drp
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////
//key: 对axi-lite修改，以保证在DRP接口没有准备好时，axi-lite也不会对外发出准备好的信号
//如果DRP忙碌，则AXI-LITE操作被阻塞
//如果DRP忙碌，则LB操作无效(或人为判断后暂停操作)
module axi2drp(
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

//LB interface， axi-lite salve output interface
input [C_AXI_LITE_ADDR_WIDTH-1:0]  S_LB_WADDR , 
input [C_AXI_LITE_DATA_WIDTH-1:0]  S_LB_WDATA  ,
input                              S_LB_WREQ  , 
input [C_AXI_LITE_ADDR_WIDTH-1:0]  S_LB_RADDR , 
input                              S_LB_RREQ  ,
output [C_AXI_LITE_DATA_WIDTH-1:0] S_LB_RDATA  ,
output                             S_LB_RFINISH , //note: rfinish will dealy to busy neg
output                             S_LB_BUSY , // S_LB_BUSY     可不必连到axi-lite slave

//DRP interface
input  M_DRPCLK  ,
input  M_DRPRSTN ,
output M_DRPEN ,
output M_DRPWE ,
output [C_DRP_ADDR_WIDTH-1:0] M_DRPADDR ,
input  M_DRPRDY ,
output [C_DRP_DATA_WIDTH-1:0] M_DRPDI ,
input  [C_DRP_DATA_WIDTH-1:0] M_DRPDO

 );
parameter C_AXI_LITE_ADDR_WIDTH = 16 ;
parameter C_AXI_LITE_DATA_WIDTH = 32 ;
parameter C_DRP_ADDR_WIDTH      = 12 ;
parameter C_DRP_DATA_WIDTH      = 16 ;
parameter [0:0] C_LB_INTERFACE  = 0  ;

//ILA
parameter [0:0] C_AXI_ILA_ENABLE = 0;
parameter [0:0] C_DRP_ILA_ENABLE = 0;


wire write_req_cpu_to_axi_0 ; 
wire [C_AXI_LITE_ADDR_WIDTH-1:0] write_addr_cpu_to_axi_0 ; //axi_lite slave 原始输出
wire [C_AXI_LITE_DATA_WIDTH-1:0] write_data_cpu_to_axi_0 ;
wire read_req_cpu_to_axi_0 ;  
wire [C_AXI_LITE_ADDR_WIDTH-1:0] read_addr_cpu_to_axi_0;  

wire write_req_cpu_to_axi ; 
wire [C_AXI_LITE_ADDR_WIDTH-1:0] write_addr_cpu_to_axi ;
wire [C_AXI_LITE_DATA_WIDTH-1:0] write_data_cpu_to_axi ;
wire read_req_cpu_to_axi ;  
wire [C_AXI_LITE_ADDR_WIDTH-1:0] read_addr_cpu_to_axi;  


wire  [C_AXI_LITE_DATA_WIDTH-1:0] read_data_axi_to_cpu ; 
wire  read_finish_axi_to_cpu;

wire  [C_AXI_LITE_DATA_WIDTH-1:0] read_data_axi_to_cpu_0 ;    //直接从drp反馈同步而来
wire  read_finish_axi_to_cpu_0;


reg drp_valid_axi = 1;

wire [C_DRP_ADDR_WIDTH-1:0]  LB_WADDR ; //从axi_slave输出同步而来
wire [C_DRP_DATA_WIDTH-1:0]  LB_WDATA  ;
wire LB_WREQ  ; 
wire [C_DRP_ADDR_WIDTH-1:0]  LB_RADDR ; 
wire LB_RREQ  ; 

wire [C_DRP_DATA_WIDTH-1:0]  LB_RDATA  ;
wire LB_RFINISH;
wire LB_BUSY  ; 

wire S_LB_BUSY_axi;
wire S_LB_BUSY_axi_neg;

wire write_req_cpu_to_axi__drp ; 
wire [C_AXI_LITE_ADDR_WIDTH-1:0] write_addr_cpu_to_axi__drp ;
wire [C_AXI_LITE_DATA_WIDTH-1:0] write_data_cpu_to_axi__drp ;
wire read_req_cpu_to_axi__drp ;  
wire [C_AXI_LITE_ADDR_WIDTH-1:0] read_addr_cpu_to_axi__drp;

reg [7:0] state_axi = 0;


axi_lite_slave_drp #(
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
    .drp_valid_in          (drp_valid_axi   ),     // 【be used to prevent AXI-LITE】   drp_valid_axi 已经是AXI-LITE 时钟域
    //注意：因为DRP端不能同时进行读写，所以嵌入式也不能进行并行的读写
    .write_req_cpu_to_axi  (write_req_cpu_to_axi_0   ),  //wire                              
    .write_addr_cpu_to_axi (write_addr_cpu_to_axi_0  ),  //wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .write_data_cpu_to_axi (write_data_cpu_to_axi_0  ),  //wire [C_S_AXI_DATA_WIDTH-1:0]     
    .read_req_cpu_to_axi   (read_req_cpu_to_axi_0    ),  //wire                              
    .read_addr_cpu_to_axi  (read_addr_cpu_to_axi_0   ),  //wire [C_S_AXI_ADDR_WIDTH-1:0]    
    
    .read_data_axi_to_cpu  (read_data_axi_to_cpu   ),  //wire [C_S_AXI_DATA_WIDTH-1:0]     
    .read_finish_axi_to_cpu(read_finish_axi_to_cpu )   //wire                              
      
);  

//selsect  from   LB OR   DRP
assign write_req_cpu_to_axi  = C_LB_INTERFACE ?  S_LB_WREQ  :  write_req_cpu_to_axi_0;
assign write_addr_cpu_to_axi = C_LB_INTERFACE ?  S_LB_WADDR :  write_addr_cpu_to_axi_0 ;
assign write_data_cpu_to_axi = C_LB_INTERFACE ?  S_LB_WDATA :  write_data_cpu_to_axi_0 ;
assign read_req_cpu_to_axi   = C_LB_INTERFACE ?  S_LB_RREQ  :  read_req_cpu_to_axi_0 ;
assign read_addr_cpu_to_axi  = C_LB_INTERFACE ?  S_LB_RADDR :  read_addr_cpu_to_axi_0 ;

assign  S_LB_RFINISH = C_LB_INTERFACE ? read_finish_axi_to_cpu_0 : 0;
assign  S_LB_RDATA   = C_LB_INTERFACE ? read_data_axi_to_cpu_0 : 0 ;
assign  read_finish_axi_to_cpu = C_LB_INTERFACE ? 0 : read_finish_axi_to_cpu_0 ;
assign  read_data_axi_to_cpu   = C_LB_INTERFACE ? 0 : read_data_axi_to_cpu_0 ;

assign  S_LB_BUSY = write_req_cpu_to_axi | read_req_cpu_to_axi | (~drp_valid_axi) ;


//cdc
 
`CDC_MULTI_BIT_SIGNAL_OUTGEN(M_DRPCLK,LB_BUSY,S_AXI_ACLK,S_LB_BUSY_axi,1,4)
//`NEG_MONITOR_OUTGEN(S_AXI_ACLK,0,S_LB_BUSY_axi,S_LB_BUSY_axi_neg) 

`CDC_SINGLE_BIT_PULSE_OUTGEN(M_DRPCLK,(~M_DRPRSTN),(~LB_BUSY),S_AXI_ACLK,(~S_AXI_ARESETN),S_LB_BUSY_axi_neg,0,4)




lb2drp
    #(.C_ADDR_WIDTH (C_DRP_ADDR_WIDTH),
      .C_DATA_WIDTH (C_DRP_DATA_WIDTH) )
    lb2drp_u(
    .CLK_I        (M_DRPCLK      ),
    .RST_I        (~M_DRPRSTN    ),
    .S_LB_WADDR   (LB_WADDR  ), 
    .S_LB_WDATA   (LB_WDATA  ),
    .S_LB_WREQ    (LB_WREQ   ),
    .S_LB_RADDR   (LB_RADDR  ),
    .S_LB_RREQ    (LB_RREQ   ),
    .S_LB_RDATA   (LB_RDATA  ),
    .S_LB_RFINISH (LB_RFINISH),
    .S_LB_BUSY    (LB_BUSY   ),//LB_BUSY 为 底层 DRP 时钟域的标志
    .M_DRPEN      (M_DRPEN     ),
    .M_DRPWE      (M_DRPWE     ),
    .M_DRPADDR    (M_DRPADDR   ),
    .M_DRPRDY     (M_DRPRDY    ),//
    .M_DRPDI      (M_DRPDI     ),
    .M_DRPDO      (M_DRPDO     )
    
    );


reg wr_flag_axi = 0;

always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        drp_valid_axi <= 1;
        state_axi <= 0;
        wr_flag_axi <= 0;
    end
    else case(state_axi)
        0:begin
            if(write_req_cpu_to_axi | read_req_cpu_to_axi)begin
                wr_flag_axi <= write_req_cpu_to_axi;
                drp_valid_axi <= 0;//immediate be 0
                state_axi <= 1;
            end
        end
        1:begin
            drp_valid_axi <= wr_flag_axi ? (S_LB_BUSY_axi_neg ? 1 :  0) : (read_finish_axi_to_cpu_0 ? 1 : 0) ; //(风险点：也许busy不够长，检测neg会失败)  已经改成了脉冲同步，理论上没有风险
            state_axi <= wr_flag_axi ? ( S_LB_BUSY_axi_neg ? 0 : state_axi) : (read_finish_axi_to_cpu_0 ? 0 : state_axi) ;
        end
        default:;
    endcase
end


//位宽截断
assign LB_WREQ = write_req_cpu_to_axi__drp;
assign LB_WADDR = write_addr_cpu_to_axi__drp;
assign LB_WDATA = write_data_cpu_to_axi__drp;

assign LB_RREQ = read_req_cpu_to_axi__drp;
assign LB_RADDR = read_addr_cpu_to_axi__drp;


`HANDSHAKE_OUTGEN(S_AXI_ACLK,(~S_AXI_ARESETN),write_req_cpu_to_axi,{write_addr_cpu_to_axi,write_data_cpu_to_axi},M_DRPCLK,(~M_DRPRSTN),write_req_cpu_to_axi__drp,{write_addr_cpu_to_axi__drp,write_data_cpu_to_axi__drp},(C_AXI_LITE_ADDR_WIDTH+C_AXI_LITE_DATA_WIDTH),0)
`HANDSHAKE_OUTGEN(S_AXI_ACLK,(~S_AXI_ARESETN),read_req_cpu_to_axi,read_addr_cpu_to_axi,M_DRPCLK,(~M_DRPRSTN),read_req_cpu_to_axi__drp ,read_addr_cpu_to_axi__drp,(C_AXI_LITE_ADDR_WIDTH),0)
    
`HANDSHAKE_OUTGEN(M_DRPCLK,(~M_DRPRSTN),LB_RFINISH,{0,LB_RDATA},S_AXI_ACLK,(~S_AXI_ARESETN),read_finish_axi_to_cpu_0,read_data_axi_to_cpu_0,C_AXI_LITE_DATA_WIDTH,0)    
    
    
generate if(C_AXI_ILA_ENABLE)begin
    ila_4 ila_axi2drp_aclk(
        .clk     (S_AXI_ACLK          ),
        .probe0  (state_axi           ),
        .probe1  (drp_valid_axi       ),
        .probe2  (S_LB_BUSY_axi_neg   ),
        .probe3  (write_req_cpu_to_axi),
        .probe4  (read_req_cpu_to_axi ), 
        .probe5  (S_LB_RFINISH        )
        
   
    );
    
end
endgenerate



generate if(C_DRP_ILA_ENABLE)begin
    ila_5 ila_axi2drp_drpclk(
        .clk     (M_DRPCLK          ),
        .probe0  (write_req_cpu_to_axi__drp           ),
        .probe1  (read_req_cpu_to_axi__drp           ),
        .probe2  (lb2drp_u.state    ),
        .probe3  (lb2drp_u.S_LB_BUSY   ),
        .probe4  (lb2drp_u.S_LB_RFINISH   ) ,
        .probe5  (lb2drp_u.M_DRPEN    ),
        .probe6  (lb2drp_u.M_DRPWE   ),
        .probe7  (lb2drp_u.M_DRPRDY  ) 
          
    );  




end
endgenerate





    
endmodule





