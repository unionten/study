`timescale 1ns / 1ps

`define  ADDR_R_ENABLE_CH0  16'h0000
`define  ADDR_R_DIV_CH0     16'h0004
`define  ADDR_R_DUTY_CH0    16'h0008
`define  ADDR_R_ENABLE_CH1  16'h000C
`define  ADDR_R_DIV_CH1     16'h0010
`define  ADDR_R_DUTY_CH1    16'h0014

//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2022/09/26 14:33:16
// Design Name: 
// Module Name: pwm
// Project Name: 
// Target Devices: 
//////////////////////////////////////////////////////////////////////////////////


module pwm(
input  wire                             S_AXI_ACLK      ,
input  wire                             S_AXI_ARESETN   ,
output wire                             S_AXI_AWREADY   ,
input  wire [C_S_AXI_ADDR_WIDTH-1:0]    S_AXI_AWADDR    ,
input  wire                             S_AXI_AWVALID   ,
input  wire [ 2:0]                      S_AXI_AWPROT    ,
output wire                             S_AXI_WREADY    ,
input  wire [C_S_AXI_DATA_WIDTH-1:0]    S_AXI_WDATA     ,
input  wire [(C_S_AXI_DATA_WIDTH/8)-1 :0]   S_AXI_WSTRB ,//no use
input  wire                             S_AXI_WVALID    ,
output wire [ 1:0]                      S_AXI_BRESP     ,
output wire                             S_AXI_BVALID    ,
input  wire                             S_AXI_BREADY    ,
output wire                             S_AXI_ARREADY   ,
input  wire [C_S_AXI_ADDR_WIDTH-1:0]    S_AXI_ARADDR    ,
input  wire                             S_AXI_ARVALID   ,
input  wire [ 2:0]                      S_AXI_ARPROT    ,//no use
output wire [ 1:0]                      S_AXI_RRESP     ,
output wire                             S_AXI_RVALID    ,
output wire [C_S_AXI_DATA_WIDTH-1:0]    S_AXI_RDATA     ,
input  wire                             S_AXI_RREADY    ,


input  [C_S_AXI_ADDR_WIDTH-1:0]  LB_WADDR  ,
input  [C_S_AXI_DATA_WIDTH-1:0]   LB_WDATA ,
input  LB_WREQ ,
input   [C_S_AXI_ADDR_WIDTH-1:0]  LB_RADDR ,
input   LB_RREQ ,
output  [C_S_AXI_DATA_WIDTH-1:0] LB_RDATA ,
output  LB_RFINISH ,


output PWM_CH0_O     ,
output PWM_CH0_EN_O  ,
output PWM_CH1_O     ,
output PWM_CH1_EN_O  
);

assign PWM_CH0_EN_O = R_ENABLE_CH0;
assign PWM_CH1_EN_O = R_ENABLE_CH1;

parameter C_S_AXI_ADDR_WIDTH = 16;
parameter C_S_AXI_DATA_WIDTH = 32;
parameter [11:0] DEFAULT_DIV_CH0  = 1000;
parameter [9:0]  DEFAULT_DUTY_CH0 = 0; //VCC = VCC_PRESET * (1/6 + 5/6 * DEFAULT_DUTY)
parameter [0:0]  DEFAULT_EN_CH0   = 0;
parameter [11:0] DEFAULT_DIV_CH1  = 1000;
parameter [9:0]  DEFAULT_DUTY_CH1 = 0; //VCC = VCC_PRESET * (1/6 + 5/6 * DEFAULT_DUTY)
parameter [0:0]  DEFAULT_EN_CH1   = 0;  
parameter [0:0]  DEBUG_ENABLE     = 0;

parameter [0:0]  LB_ENABLE = 0;


     
wire                              write_req_cpu_to_axi;
wire [C_S_AXI_ADDR_WIDTH-1:0]     write_addr_cpu_to_axi;
wire [C_S_AXI_DATA_WIDTH-1:0]     write_data_cpu_to_axi;
wire                              read_req_cpu_to_axi;
wire [C_S_AXI_ADDR_WIDTH-1:0]     read_addr_cpu_to_axi;
wire [C_S_AXI_DATA_WIDTH-1:0]      read_data_axi_to_cpu;
wire                               read_finish_axi_to_cpu ;  


wire                              write_req_cpu_to_axi_ll;
wire [C_S_AXI_ADDR_WIDTH-1:0]     write_addr_cpu_to_axi_ll;
wire [C_S_AXI_DATA_WIDTH-1:0]     write_data_cpu_to_axi_ll;
wire                              read_req_cpu_to_axi_ll;
wire [C_S_AXI_ADDR_WIDTH-1:0]     read_addr_cpu_to_axi_ll;
reg [C_S_AXI_DATA_WIDTH-1:0]      read_data_axi_to_cpu_ll;
reg                               read_finish_axi_to_cpu_ll ;  


axi_lite_slave #(
    .C_S_AXI_DATA_WIDTH (C_S_AXI_DATA_WIDTH),
    .C_S_AXI_ADDR_WIDTH (C_S_AXI_ADDR_WIDTH))
    axi_lite_slave_u(
    .S_AXI_ACLK    (S_AXI_ACLK   ),
    .S_AXI_ARESETN (S_AXI_ARESETN),
    .S_AXI_AWREADY (S_AXI_AWREADY),
    .S_AXI_AWADDR  (S_AXI_AWADDR ),
    .S_AXI_AWVALID (S_AXI_AWVALID),
    .S_AXI_AWPROT  (S_AXI_AWPROT ),
    .S_AXI_WREADY  (S_AXI_WREADY ),
    .S_AXI_WDATA   (S_AXI_WDATA  ),
    .S_AXI_WSTRB   (S_AXI_WSTRB  ),
    .S_AXI_WVALID  (S_AXI_WVALID ),
    .S_AXI_BRESP   (S_AXI_BRESP  ),
    .S_AXI_BVALID  (S_AXI_BVALID ),
    .S_AXI_BREADY  (S_AXI_BREADY ),
    .S_AXI_ARREADY (S_AXI_ARREADY),
    .S_AXI_ARADDR  (S_AXI_ARADDR ),
    .S_AXI_ARVALID (S_AXI_ARVALID),
    .S_AXI_ARPROT  (S_AXI_ARPROT ),
    .S_AXI_RRESP   (S_AXI_RRESP  ),
    .S_AXI_RVALID  (S_AXI_RVALID ),
    .S_AXI_RDATA   (S_AXI_RDATA  ),
    .S_AXI_RREADY  (S_AXI_RREADY ),
    //cpu写入
    .write_req_cpu_to_axi     (write_req_cpu_to_axi   ),
    .write_addr_cpu_to_axi    (write_addr_cpu_to_axi  ),
    .write_data_cpu_to_axi    (write_data_cpu_to_axi  ),  
    //cpu请求
    .read_req_cpu_to_axi      (read_req_cpu_to_axi    ),
    .read_addr_cpu_to_axi     (read_addr_cpu_to_axi   ),
    .read_data_axi_to_cpu     (read_data_axi_to_cpu   ),
    .read_finish_axi_to_cpu   (read_finish_axi_to_cpu ));
    

reg [0:0]  R_ENABLE_CH0 = DEFAULT_EN_CH0;
reg [11:0] R_DIV_CH0    = DEFAULT_DIV_CH0;
reg [9:0]  R_DUTY_CH0   = DEFAULT_DUTY_CH0;
reg [0:0]  R_ENABLE_CH1 = DEFAULT_EN_CH1;
reg [11:0] R_DIV_CH1    = DEFAULT_DIV_CH1;
reg [9:0]  R_DUTY_CH1   = DEFAULT_DUTY_CH1;


assign write_req_cpu_to_axi_ll  = ~LB_ENABLE ?  write_req_cpu_to_axi : LB_WREQ ;
assign write_addr_cpu_to_axi_ll = ~LB_ENABLE ?  write_addr_cpu_to_axi : LB_WADDR ;
assign write_data_cpu_to_axi_ll = ~LB_ENABLE ?  write_data_cpu_to_axi : LB_WDATA ;

assign read_req_cpu_to_axi_ll  = ~LB_ENABLE  ? read_req_cpu_to_axi : LB_RREQ ;
assign read_addr_cpu_to_axi_ll =  ~LB_ENABLE ? read_addr_cpu_to_axi : LB_RADDR ;

assign read_data_axi_to_cpu = ~LB_ENABLE ? read_data_axi_to_cpu_ll : 0;
assign  read_finish_axi_to_cpu = ~LB_ENABLE ? read_finish_axi_to_cpu_ll : 0 ;

assign LB_RDATA = ~LB_ENABLE ? 0 : read_data_axi_to_cpu_ll ;
assign LB_RFINISH = ~LB_ENABLE ? 0 : read_finish_axi_to_cpu_ll ;


always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        R_ENABLE_CH0 <= DEFAULT_EN_CH0;
        R_DIV_CH0    <= DEFAULT_DIV_CH0;
        R_DUTY_CH0   <= DEFAULT_DUTY_CH0;
        R_ENABLE_CH1 <= DEFAULT_EN_CH1;
        R_DIV_CH1    <= DEFAULT_DIV_CH1;
        R_DUTY_CH1   <= DEFAULT_DUTY_CH1;
    end
    else if(write_req_cpu_to_axi_ll)begin
        case(write_addr_cpu_to_axi_ll)
            `ADDR_R_ENABLE_CH0:R_ENABLE_CH0 <= write_data_cpu_to_axi_ll;
            `ADDR_R_DIV_CH0   :R_DIV_CH0    <= write_data_cpu_to_axi_ll;
            `ADDR_R_DUTY_CH0  :R_DUTY_CH0   <= write_data_cpu_to_axi_ll;
            `ADDR_R_ENABLE_CH1:R_ENABLE_CH1 <= write_data_cpu_to_axi_ll;
            `ADDR_R_DIV_CH1   :R_DIV_CH1    <= write_data_cpu_to_axi_ll;
            `ADDR_R_DUTY_CH1  :R_DUTY_CH1   <= write_data_cpu_to_axi_ll;
            default:;
        endcase
    end
end 

always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin 
        read_data_axi_to_cpu_ll <= 0;
        read_finish_axi_to_cpu_ll <= 0;
    end
    else if(read_req_cpu_to_axi_ll)begin
        read_finish_axi_to_cpu_ll <= 1;
        case(read_addr_cpu_to_axi_ll)
            `ADDR_R_ENABLE_CH0:read_data_axi_to_cpu_ll <= {31'b0,R_ENABLE_CH0};
            `ADDR_R_DIV_CH0   :read_data_axi_to_cpu_ll <= {31'b0,R_DIV_CH0};
            `ADDR_R_DUTY_CH0  :read_data_axi_to_cpu_ll <= {31'b0,R_DUTY_CH0};
            `ADDR_R_ENABLE_CH1:read_data_axi_to_cpu_ll <= {31'b0,R_ENABLE_CH1};
            `ADDR_R_DIV_CH1   :read_data_axi_to_cpu_ll <= {31'b0,R_DIV_CH1};
            `ADDR_R_DUTY_CH1  :read_data_axi_to_cpu_ll <= {31'b0,R_DUTY_CH1};
        endcase
    end
    else begin
        read_finish_axi_to_cpu_ll <= 0;
    end
end


wire [11:0] div_safe_ch0;
wire [9:0]  duty_safe_ch0;
assign div_safe_ch0   = (R_DIV_CH0<2) ? 2 : (R_DIV_CH0>4000) ? 4000 : R_DIV_CH0;
assign duty_safe_ch0  = (R_DUTY_CH0>1000) ? 1000: R_DUTY_CH0;
  
  
pwm_core pwm_core_ch0(
    .CLK_I (S_AXI_ACLK),
    .EN_I  (R_ENABLE_CH0),
    .DIV_I (div_safe_ch0),//[11:0] 2~4000
    .DUTY_I(duty_safe_ch0),//[9:0] 0~1000
    .PWM_O (PWM_CH0_O)
    );




wire [11:0] div_safe_ch1;
wire [9:0]  duty_safe_ch1;
assign div_safe_ch1   = (R_DIV_CH1<2) ? 2 : (R_DIV_CH1>4000) ? 4000 : R_DIV_CH1;
assign duty_safe_ch1  = (R_DUTY_CH1>1000) ? 1000: R_DUTY_CH1;


pwm_core pwm_core_ch1(
    .CLK_I (S_AXI_ACLK),
    .EN_I  (R_ENABLE_CH1),
    .DIV_I (div_safe_ch1),//[11:0] 2~4000
    .DUTY_I(duty_safe_ch1),//[9:0] 0~1000
    .PWM_O (PWM_CH1_O)
    );



generate if(DEBUG_ENABLE)begin
    pwm_ila_0 
       pwm_ila_0_u(
       .clk    (S_AXI_ACLK),
       .probe0 (write_req_cpu_to_axi  ),
       .probe1 (write_addr_cpu_to_axi ),//16
       .probe2 (write_data_cpu_to_axi ),//32
       .probe3 (read_req_cpu_to_axi   ),
       .probe4 (read_addr_cpu_to_axi  ),//16
       .probe5 (read_data_axi_to_cpu  ),//32
       .probe6 (read_finish_axi_to_cpu),
       .probe7 (R_ENABLE_CH0 ),
       .probe8 (R_DIV_CH0    ),//12
       .probe9 (R_DUTY_CH0   ),//10
       .probe10(R_ENABLE_CH1 ),
       .probe11(R_DIV_CH1    ),//12
       .probe12(R_DUTY_CH1   ),//10
       .probe13(PWM_CH0_O    ),
       .probe14(PWM_CH0_EN_O ),
       .probe15(PWM_CH1_O    ),
       .probe16(PWM_CH1_EN_O ) 
    );

end
endgenerate

endmodule
