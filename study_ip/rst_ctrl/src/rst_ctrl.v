`timescale 1ns / 1ps
`define POS_MONITOR_FF1(clk_in,rst_in,in,buf_name1,out)      reg buf_name1 = 1; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 1; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);
`define SYN_SINGLE_BIT_PULSE(u_name,aclk_in,arst_in,apulse_in,bclk_in,brst_in,bpulse_out)         xpm_cdc_pulse #(.DEST_SYNC_FF(4), .INIT_SYNC_FF(0),.REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) u_name (.src_clk(aclk_in),.src_rst(arst_in),.src_pulse(apulse_in),.dest_clk(bclk_in),.dest_rst(brst_in),.dest_pulse(bpulse_out));            
`define SYN_STRETCH_POS(pulse_p_in,clk_in,C_TOTAL_PERIOD,cnt_name,pulse_p_out)       reg [15:0] cnt_name = 0;always@(posedge clk_in)begin if(pulse_p_in )begin cnt_name <= C_TOTAL_PERIOD-1; end  else begin  cnt_name <= (cnt_name == 0) ? 0 : (cnt_name - 1);end end  assign pulse_p_out = pulse_p_in|((cnt_name != 0)? 1:0);
`define SYN_SINGLE_BIT_PULSE2(aclk_in,arst_in,apulse_in,bclk_in,brst_in,bpulse_out,name1,name2)    reg [5:0] name1 = 0;wire name2;always@(posedge aclk_in)if(arst_in)name1[0] <=0;else name1[0] <= apulse_in;assign name2 = apulse_in & ~name1[0]; always@(posedge aclk_in)if(arst_in)name1[1] <= 0;else name1[1] <= name2 ? ~name1[1]:name1[1];always@(posedge bclk_in)if(brst_in)name1[5:2]<=0;else begin name1[2]<=name1[1];name1[3]<=name1[2];name1[4]<=name1[3];name1[5]<=name1[4];end  assign bpulse_out=name1[4]^name1[5];

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/13 15:23:23
// Design Name: 
// Module Name: rst_ctrl_blk
//////////////////////////////////////////////////////////////////////////////////


module rst_ctrl(
input  wire                                      SYS_CLK_I       , //recommend a contant clk
output wire                                      SYS_RSTN_O      ,

input  wire                                      S_AXI_ACLK      ,
input  wire                                      S_AXI_ARESETN   ,
output wire                                      S_AXI_AWREADY   ,
input  wire [16-1:0]                             S_AXI_AWADDR    ,
input  wire                                      S_AXI_AWVALID   ,
input  wire [ 2:0]                               S_AXI_AWPROT    ,
output wire                                      S_AXI_WREADY    ,
input  wire [32-1:0]                             S_AXI_WDATA     ,
input  wire [(32/8)-1 :0]                        S_AXI_WSTRB ,
input  wire                                      S_AXI_WVALID    ,
output wire [ 1:0]                               S_AXI_BRESP     ,
output wire                                      S_AXI_BVALID    ,
input  wire                                      S_AXI_BREADY    ,
output wire                                      S_AXI_ARREADY   ,
input  wire [16-1:0]                             S_AXI_ARADDR    ,
input  wire                                      S_AXI_ARVALID   ,
input  wire [ 2:0]                               S_AXI_ARPROT    ,
output wire [ 1:0]                               S_AXI_RRESP     ,
output wire                                      S_AXI_RVALID    ,
output wire [32-1:0]                             S_AXI_RDATA     ,
input  wire                                      S_AXI_RREADY    


    );
parameter  C_RST_SYS_CLK_NUM = 50;//1 ~ 200

assign SYS_RSTN_O = ~SYS_RST;

wire write_req_cpu_to_axi ;  
wire [15:0] write_addr_cpu_to_axi  ;
wire [31:0] write_data_cpu_to_axi  ;


 
axi_lite_slave #(
.C_S_AXI_DATA_WIDTH (32 ),
.C_S_AXI_ADDR_WIDTH (16 )   
)
axi_lite_slave_u
(
.S_AXI_ACLK             (S_AXI_ACLK     ),     //input  wire                              
.S_AXI_ARESETN          (S_AXI_ARESETN  ),     //input  wire                              
.S_AXI_AWREADY          (S_AXI_AWREADY  ),     //output wire                              
.S_AXI_AWADDR           (S_AXI_AWADDR   ),     //input  wire [C_S_AXI_ADDR_WIDTH-1:0]     
.S_AXI_AWVALID          (S_AXI_AWVALID  ),     //input  wire                              
.S_AXI_AWPROT           (S_AXI_AWPROT   ),     //input  wire [ 2:0]                       
.S_AXI_WREADY           (S_AXI_WREADY   ),     //output wire                              
.S_AXI_WDATA            (S_AXI_WDATA    ),     //input  wire [C_S_AXI_DATA_WIDTH-1:0]     
.S_AXI_WSTRB            (S_AXI_WSTRB    ),         //input  wire [(C_S_AXI_DATA_WIDTH/8)-1 :0]
.S_AXI_WVALID           (S_AXI_WVALID   ),     //input  wire                              
.S_AXI_BRESP            (S_AXI_BRESP    ),     //output wire [ 1:0]                       
.S_AXI_BVALID           (S_AXI_BVALID   ),     //output wire                              
.S_AXI_BREADY           (S_AXI_BREADY   ),     //input  wire                              
.S_AXI_ARREADY          (S_AXI_ARREADY  ),     //output wire                              
.S_AXI_ARADDR           (S_AXI_ARADDR   ),     //input  wire [C_S_AXI_ADDR_WIDTH-1:0]     
.S_AXI_ARVALID          (S_AXI_ARVALID  ),     //input  wire                              
.S_AXI_ARPROT           (S_AXI_ARPROT   ),     //input  wire [ 2:0]                       
.S_AXI_RRESP            (S_AXI_RRESP    ),     //output wire [ 1:0]                       
.S_AXI_RVALID           (S_AXI_RVALID   ),     //output wire                              
.S_AXI_RDATA            (S_AXI_RDATA    ),     //output wire [C_S_AXI_DATA_WIDTH-1:0]     
.S_AXI_RREADY           (S_AXI_RREADY   ),     //input  wire                              

.write_req_cpu_to_axi   (write_req_cpu_to_axi),    //wire                              
.write_addr_cpu_to_axi  (write_addr_cpu_to_axi  ),   //wire [C_S_AXI_ADDR_WIDTH-1:0]     
.write_data_cpu_to_axi  (write_data_cpu_to_axi  ),   //wire [C_S_AXI_DATA_WIDTH-1:0]     
.read_req_cpu_to_axi    (read_req_cpu_to_axi    ),     //wire                              
.read_addr_cpu_to_axi   (read_addr_cpu_to_axi   ),    //wire [C_S_AXI_ADDR_WIDTH-1:0]     
.read_data_axi_to_cpu   (read_data_axi_to_cpu   ),    //wire [C_S_AXI_DATA_WIDTH-1:0]     
.read_finish_axi_to_cpu (1 )  //wire                              
      
); 
    
reg [7:0] cnt = 0;
reg R_RST_axiclk;
always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        R_RST_axiclk <= 0;
    end
    else if(write_req_cpu_to_axi)begin
         R_RST_axiclk <= 1;
    end
    else begin
        R_RST_axiclk <= 0;
    end
end
    
wire  R_RST_axiclk_pos;
`POS_MONITOR_FF1(S_AXI_ACLK,0,R_RST_axiclk,buf_name1,R_RST_axiclk_pos)
wire R_RST_sysclk_pos;
`SYN_SINGLE_BIT_PULSE(cdc0,S_AXI_ACLK,0,R_RST_axiclk_pos,SYS_CLK_I,0,R_RST_sysclk_pos)  


wire SYS_RST; 
`SYN_STRETCH_POS(R_RST_sysclk_pos,SYS_CLK_I,C_RST_SYS_CLK_NUM,cnt_name0,SYS_RST)
    
    
endmodule



