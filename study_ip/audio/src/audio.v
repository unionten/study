`timescale 1ns / 1ps
`define SYN_MULTI_BIT_SINGLE(u_name,clk_in,data_in,clk_out,data_out,data_width)               xpm_cdc_array_single #(.DEST_SYNC_FF(4),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(data_width)) u_name(.src_clk(clk_in),.src_in(data_in),.dest_clk(clk_out),.dest_out(data_out));       
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//本模块支持格式:
// IIS (not left justied)  
//              right data                   left data
// LRCK ____|————————————————————————————|_____________________________
// SCLK |_|—|_|—|_|—|_|—|_|—|_|—|
// DATA          AAA BBB CCC (total 24 bit, 2-comp format)
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//本模块特别说明:
//0 因为5343的mclk是fpga给，所以5343总是有数据输出的，fpga无法判断是否有物理音频口接入
//  所以音频数据是不会中断的，只要5343芯片没坏
//1 audio_in为master模式：LRCK和SCLK由5343产生；
//2 5343的SDOUT脚上拉则为master模式；
//3 audio_out的分频参数由parameter设置，需保证整除（一般不用修改）；
//4 4354会根据audio_out的LRCK频率自动调整工作模式；
//5 本模块输入输出固定为 IIS格式（ NOT_LEFT_JUSTIFIED）
//7 音频主时钟AUDIO_MCLK_I可根据芯片手册选择，但是为了fft分析方便请给8192KHZ(同时输入500Hz音频)
//8 audio_out：使用了64点的完整周期sin，freq=0时输出500Hz,1时输出1000Hz ...
//9 内部fft固定512点 
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//拓展知识:
//常见音频采样频率(即LRCK频率)
//32KHz    (本模块使用)    即主时钟频率 8192KHZ / 256 = 32KHz, 而32KHz 为 500Hz 的整数倍，于是fft分析结果准确
//44.1KHz 
//48KHz 
//88.2KHz
//96KHz
//
//
//典型音频波形是正负都有的对称波形
//经测试：台式机 USB 转 音频，100幅度时，输出电压为正负1V左右（﹢1V  -1V）
//因为声音只有振荡时才会有声音，5V电平如果没有振荡，也不会有声音
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//寄存器表:
`define ADDR_AUDIO_IN_ENABLE          16'h0000  //输入使能（同时不断进行fft分析）
`define ADDR_AUDIO_OUT_LEFT_ENABLE    16'h0004  //左通道输出使能
`define ADDR_AUDIO_OUT_RIGHT_ENABLE   16'h0044  //右通道输出使能
`define ADDR_L_SIGNAL_POWER_LOW       16'h0008  //左声道 信号功率  低32位
`define ADDR_L_SIGNAL_POWER_HIGH      16'h000c  //左声道 信号功率  高32位
`define ADDR_L_NOICE_POWER_LOW        16'h0010  //左声道 噪声功率  低32位
`define ADDR_L_NOICE_POWER_HIGH       16'h0014  //左声道 噪声功率  高32位
`define ADDR_L_CORE_FREQ_HZ           16'h0018  //左声道 信号频率（Hz）
`define ADDR_R_SIGNAL_POWER_LOW       16'h001c  //右声道 信号功率  低32位
`define ADDR_R_SIGNAL_POWER_HIGH      16'h0020  //右声道 信号功率  高32位                                                                               
`define ADDR_R_NOICE_POWER_LOW        16'h0024  //右声道 噪声功率  低32位
`define ADDR_R_NOICE_POWER_HIGH       16'h0028  //右声道 噪声功率  高32位
`define ADDR_R_CORE_FREQ_HZ           16'h002c  //右声道 信号频率（Hz）
`define ADDR_FIFO_L_ENOUGH            16'h0030  //fifo中数据已经超过了1024，上位机可以读取512个值，
`define ADDR_FIFO_R_ENOUGH            16'h0034  //fifo中数据已经超过了1024，上位机可以读取512个值，
`define ADDR_RD_LEFT_CHANNEL          16'h0038  //上位机读取左通道的寄存器地址（建议连续读取）
`define ADDR_RD_RIGHT_CHANNEL         16'h003c  //内部一个fifo，只依赖于上位机读取
`define ADDR_AUDIO_OUT_FREQ           16'h0040  //用于配置内部生成器的频率
`define ADDR_L_AMP_CODE               16'h0048  //返回23位数字码
`define ADDR_R_AMP_CODE               16'h004c  //返回23位数字码

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Create Date: 2022/09/09 10:54:55
// Design Name: 
// Module Name: audio
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module audio
#( 
   parameter AXI_ADDR_WIDTH                  = 16    , 
   parameter AXI_DATA_WIDTH                  = 32    , 
   parameter [0:0] AIN_DEFAULT_ENABLE        = 1     , 
   parameter [0:0] AOUT_LEFT_DEFAULT_ENABLE  = 1     , 
   parameter [0:0] AOUT_RIGHT_DEFAULT_ENABLE = 1     , 
   parameter [0:0] AIN_FFT_WIN_ENABLE        = 0     , //在输入音频频率恰好落在频率分辨点上时，加窗反而效果不好
   parameter AIN_EXPAND_POINTS_NUM_ONE_SIDE  = 0     , //0: 只取最高点功率作为信号功率  1：左右各加一个点(作假时用)   2 3 ... 
   parameter AOUT_MCLK_LRCK_RATIO            = 256   , //用于配置输出音频特征, 不用修改
   parameter AOUT_SCLK_LRCK_RATIO            = 64    , //用于配置输出音频特征, 不用修改
   parameter [15:0] AIN_AMP_AVG_POINTS       = 256   , //计算平均幅度时采用的点数，最大65535,
   parameter [3:0] AOUT_DEFAULT_FREQ         = 0     , //0: 输出500Hz  1:输出1000Hz ...
   parameter [0:0] AOUT_RING_OUT_ENABLE      = 0     ,
   parameter [0:0] AIN_MEMORY_ENABLE         = 0     ,     // 是否缓存数据(提供上位机读取), 不选可节省
   parameter [0:0] IIS_INPUT_DEBUG           = 0     , //抓IIS输入端口，用于判断输入状态
   parameter [0:0] DEBUG_ENABLE              = 0       //抓内部详细debug数据，包括fft过程，信号噪声解析结果等
   
  
)
(
input  wire                                 S_AXI_ACLK      ,
input  wire                                 S_AXI_ARESETN   ,
output wire                                 S_AXI_AWREADY   ,
input  wire [AXI_ADDR_WIDTH-1:0]            S_AXI_AWADDR    ,
input  wire                                 S_AXI_AWVALID   ,
input  wire [ 2:0]                          S_AXI_AWPROT    ,
output wire                                 S_AXI_WREADY    ,
input  wire [AXI_DATA_WIDTH-1:0]            S_AXI_WDATA     ,
input  wire [(AXI_DATA_WIDTH/8)-1 :0]       S_AXI_WSTRB     ,
input  wire                                 S_AXI_WVALID    ,
output wire [ 1:0]                          S_AXI_BRESP     ,
output wire                                 S_AXI_BVALID    ,
input  wire                                 S_AXI_BREADY    ,
output wire                                 S_AXI_ARREADY   ,
input  wire [AXI_ADDR_WIDTH-1:0]            S_AXI_ARADDR    ,
input  wire                                 S_AXI_ARVALID   ,
input  wire [ 2:0]                          S_AXI_ARPROT    ,
output wire [ 1:0]                          S_AXI_RRESP     ,
output wire                                 S_AXI_RVALID    ,
output wire [AXI_DATA_WIDTH-1:0]            S_AXI_RDATA     ,
input  wire                                 S_AXI_RREADY    ,  

//音频系统采样时钟/主时钟
input   CLK8192KHZ_I,

//iis input
output  AIN_MCLK_O,
input   AIN_LRCK_I,
input   AIN_SCLK_I,
input   AIN_SDIN_I,

output  AIN_MCLK_O_1,
input   AIN_LRCK_I_1,
input   AIN_SCLK_I_1,
input   AIN_SDIN_I_1,

input   AIN_SEL_I ,

//iis output
output  AOUT_MCLK_O,
output  AOUT_LRCK_O,
output  AOUT_SCLK_O,
output  AOUT_SDOUT_O


);


wire                       write_req_cpu_to_axi   ;
wire [AXI_ADDR_WIDTH-1:0]  write_addr_cpu_to_axi  ;
wire [AXI_DATA_WIDTH-1:0]  write_data_cpu_to_axi  ;
wire                       read_req_cpu_to_axi    ;
wire  [AXI_ADDR_WIDTH-1:0] read_addr_cpu_to_axi   ;
reg  [AXI_DATA_WIDTH-1:0]  read_data_axi_to_cpu   ;  
reg                        read_finish_axi_to_cpu ;

reg R_AUDIO_IN_ENABLE        = AIN_DEFAULT_ENABLE;
reg R_AUDIO_OUT_LEFT_ENABLE  = AOUT_LEFT_DEFAULT_ENABLE;
reg R_AUDIO_OUT_RIGHT_ENABLE = AOUT_RIGHT_DEFAULT_ENABLE;
reg [3:0] R_AUDIO_FREQ       = AOUT_DEFAULT_FREQ;

reg [7:0] state = 0;

wire        ram_rd_1;
reg  [15:0] ram_rd_addr_1 = 0;
wire [23:0] ram_rd_dout_1;

wire        ram_rd_2;
reg  [15:0] ram_rd_addr_2 = 0;
wire [23:0] ram_rd_dout_2;

assign ram_rd_1 = read_req_cpu_to_axi & ( read_addr_cpu_to_axi==`ADDR_RD_LEFT_CHANNEL  ) ;
assign ram_rd_2 = read_req_cpu_to_axi & ( read_addr_cpu_to_axi==`ADDR_RD_RIGHT_CHANNEL ) ;

wire l_fft_finish;
wire r_fft_finish;
wire [63:0] fft_signal_power;
wire [63:0] fft_noise_power ;
wire [15:0] fft_core_freq_hz;
wire l_enough;
wire r_enough;

reg [63:0] l_fft_signal_power_buf = 0;
reg [63:0] l_fft_noise_power_buf  = 0;
reg [15:0] l_fft_core_freq_hz_buf = 0;

reg [63:0] r_fft_signal_power_buf = 0;
reg [63:0] r_fft_noise_power_buf  = 0;
reg [15:0] r_fft_core_freq_hz_buf = 0;

wire aresten_sclk;
wire [3:0] audio_freq__sclk;
wire [0:0] audio_out_left_enable__sclk;
wire [0:0] audio_out_right_enable__sclk;

`SYN_MULTI_BIT_SINGLE(cdc_u0,S_AXI_ACLK,R_AUDIO_FREQ,AOUT_SCLK_O,audio_freq__sclk,4)
`SYN_MULTI_BIT_SINGLE(cdc_u2,S_AXI_ACLK,R_AUDIO_OUT_LEFT_ENABLE,AOUT_SCLK_O,audio_out_left_enable__sclk,1)
`SYN_MULTI_BIT_SINGLE(cdc_u3,S_AXI_ACLK,R_AUDIO_OUT_RIGHT_ENABLE,AOUT_SCLK_O,audio_out_right_enable__sclk,1)
`SYN_MULTI_BIT_SINGLE(cdc_u4,S_AXI_ACLK,S_AXI_ARESETN,AOUT_SCLK_O,aresten_sclk,1)

wire [22:0] l_avg_data;
wire [22:0] r_avg_data;

wire [3:0]  audio_freq_vio;
wire audio_out_left_en;
wire audio_out_right_en;
wire ain_mclk;

assign AIN_MCLK_O   = ain_mclk;
assign AIN_MCLK_O_1 = ain_mclk;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//axi interface
axi_lite_slave #(
    .C_S_AXI_DATA_WIDTH (AXI_DATA_WIDTH ),
    .C_S_AXI_ADDR_WIDTH (AXI_ADDR_WIDTH ))
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
    .write_req_cpu_to_axi     (write_req_cpu_to_axi         ),
    .write_addr_cpu_to_axi    (write_addr_cpu_to_axi        ),
    .write_data_cpu_to_axi    (write_data_cpu_to_axi        ),  
    .read_req_cpu_to_axi      (read_req_cpu_to_axi          ),
    .read_addr_cpu_to_axi     (read_addr_cpu_to_axi         ),
    .read_data_axi_to_cpu     (read_data_axi_to_cpu         ),
    .read_finish_axi_to_cpu   (read_finish_axi_to_cpu       )
    );
    


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//axi write
always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        R_AUDIO_IN_ENABLE        <= AIN_DEFAULT_ENABLE;
        R_AUDIO_OUT_LEFT_ENABLE  <= AOUT_LEFT_DEFAULT_ENABLE;
        R_AUDIO_OUT_RIGHT_ENABLE <= AOUT_RIGHT_DEFAULT_ENABLE;
        R_AUDIO_FREQ             <= AOUT_DEFAULT_FREQ;  
    end
    else if(write_req_cpu_to_axi)begin
        case(write_addr_cpu_to_axi)
            `ADDR_AUDIO_IN_ENABLE        : R_AUDIO_IN_ENABLE        <= write_data_cpu_to_axi;
            `ADDR_AUDIO_OUT_LEFT_ENABLE  : R_AUDIO_OUT_LEFT_ENABLE  <= write_data_cpu_to_axi;
            `ADDR_AUDIO_OUT_RIGHT_ENABLE : R_AUDIO_OUT_RIGHT_ENABLE <= write_data_cpu_to_axi;
            `ADDR_AUDIO_OUT_FREQ         : R_AUDIO_FREQ             <= write_data_cpu_to_axi;
            default:;
        endcase
    end 
end


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//axi read
always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        read_finish_axi_to_cpu <= 0;
        state <= 0;
    end
    else begin
        case(state)
            0:begin
                read_finish_axi_to_cpu <= 0;
                if(read_req_cpu_to_axi) state <= 1;
            end
            1:begin
                read_finish_axi_to_cpu <=1;
                case(read_addr_cpu_to_axi)
                    `ADDR_AUDIO_IN_ENABLE         : begin read_data_axi_to_cpu <=  {0,R_AUDIO_IN_ENABLE} ; end
                    `ADDR_AUDIO_OUT_LEFT_ENABLE   : begin read_data_axi_to_cpu <=  {0,R_AUDIO_OUT_LEFT_ENABLE} ; end
                    `ADDR_AUDIO_OUT_RIGHT_ENABLE  : begin read_data_axi_to_cpu <=  {0,R_AUDIO_OUT_RIGHT_ENABLE} ; end
                    `ADDR_AUDIO_OUT_FREQ          : begin read_data_axi_to_cpu <=  {0,R_AUDIO_FREQ} ; end
                    `ADDR_FIFO_L_ENOUGH           : begin read_data_axi_to_cpu <=  {0,l_enough};   end
                    `ADDR_FIFO_R_ENOUGH           : begin read_data_axi_to_cpu <=  {0,r_enough};   end    
                    `ADDR_L_SIGNAL_POWER_LOW      : begin read_data_axi_to_cpu <=  {0,l_fft_signal_power_buf[31:0] }; end
                    `ADDR_L_NOICE_POWER_LOW       : begin read_data_axi_to_cpu <=  {0,l_fft_noise_power_buf[31:0]}  ; end
                    `ADDR_L_SIGNAL_POWER_HIGH     : begin read_data_axi_to_cpu <=  {0,l_fft_signal_power_buf[63:32] }; end
                    `ADDR_L_NOICE_POWER_HIGH      : begin read_data_axi_to_cpu <=  {0,l_fft_noise_power_buf[63:32]}  ; end
                    
                    `ADDR_L_CORE_FREQ_HZ          : begin read_data_axi_to_cpu <=  {0,l_fft_core_freq_hz_buf}; end
                    `ADDR_R_SIGNAL_POWER_LOW      : begin read_data_axi_to_cpu <=  {0,r_fft_signal_power_buf[31:0]} ; end
                    `ADDR_R_NOICE_POWER_LOW       : begin read_data_axi_to_cpu <=  {0,r_fft_noise_power_buf[31:0] } ; end
                    `ADDR_R_SIGNAL_POWER_HIGH     : begin read_data_axi_to_cpu <=  {0,r_fft_signal_power_buf[63:32]} ; end
                    `ADDR_R_NOICE_POWER_HIGH      : begin read_data_axi_to_cpu <=  {0,r_fft_noise_power_buf[63:32] } ; end
                    
                    `ADDR_R_CORE_FREQ_HZ          : begin read_data_axi_to_cpu <=  {0,r_fft_core_freq_hz_buf }; end
                    
                    `ADDR_RD_LEFT_CHANNEL         : begin read_data_axi_to_cpu <=  {0,ram_rd_dout_1 }; end
                    `ADDR_RD_RIGHT_CHANNEL        : begin read_data_axi_to_cpu <=  {0,ram_rd_dout_2 }; end
                    
                    `ADDR_L_AMP_CODE              : begin read_data_axi_to_cpu <= { 0, l_avg_data }; end
                    `ADDR_R_AMP_CODE              : begin read_data_axi_to_cpu <= { 0, r_avg_data }; end
                    
                    default:begin read_data_axi_to_cpu <=  32'hffffffff; end
                endcase  
                state <= 0;
            end
            default:;
        endcase
    end
end


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
audio_in //端口的right代表实际的left, 一开始理解错
    #(.MEMORY_ENABLE                (AIN_MEMORY_ENABLE),
      .FFT_WIN_ENABLE               (AIN_FFT_WIN_ENABLE),
      .C_EXPAND_POINTS_NUM_ONE_SIDE (AIN_EXPAND_POINTS_NUM_ONE_SIDE),
      .AIN_AMP_AVG_POINTS           (AIN_AMP_AVG_POINTS)
      )
    audio_in_u(
    .AXI_CLK_I       (S_AXI_ACLK        ),
    .AXI_RSTN_I      (S_AXI_ARESETN     ),
    .AXI_ENABLE_I    (R_AUDIO_IN_ENABLE ),
    
    //IIS相关
    .CLK_12288KHZ_I  (CLK8192KHZ_I  ),
    .IIS_SCLK_I      (AIN_SEL_I ? AIN_SCLK_I_1 :  AIN_SCLK_I  ),//from 5343  ; analyzing is based on this clk
    .IIS_LRCK_I      (AIN_SEL_I ? AIN_LRCK_I_1 :  AIN_LRCK_I  ),//from 5343
    .IIS_SDIN_I      (AIN_SEL_I ? AIN_SDIN_I_1 :  AIN_SDIN_I  ),//from 5343
    .IIS_MCLK_O      (ain_mclk      ),//to   5343    equal to CLK_12288KHZ_I
      
    //数据缓存接口 (如果内部逻辑反了，请修改此处)    
    .FIFO_L_ENOUGH_O (l_enough      ), //[0:0]     //~AXI_CLK_I
    .FIFO_R_ENOUGH_O (r_enough      ), //[0:0]     //~AXI_CLK_I
    .FIFO_L_RD_I     (ram_rd_1      ), //[0:0]     //~AXI_CLK_I  
    .FIFO_L_DOUT_O   (ram_rd_dout_1 ), //[23:0]    //~AXI_CLK_I
    .FIFO_R_RD_I     (ram_rd_2      ), //[0:0]     //~AXI_CLK_I
    .FIFO_R_DOUT_O   (ram_rd_dout_2 ), //[23:0]    //~AXI_CLK_I
                
    //FFT分析接口 (如果内部逻辑反了，请修改此处)               
    .FFT_L_FINISH_O    (l_fft_finish      ),//1    //~AXI_CLK_I       
    .FFT_R_FINISH_O    (r_fft_finish      ),//1    //~AXI_CLK_I
    .FFT_SIGNAL_POWER_O(fft_signal_power  ),//64   //~AXI_CLK_I
    .FFT_NOISE_POWER_O (fft_noise_power   ),//64   //~AXI_CLK_I
    .FFT_CORE_FREQ_HZ_O(fft_core_freq_hz  ),//16   //~AXI_CLK_I
           

    //FFT模块状态           
    .event_frame_started        (event_frame_started        ),//for debug     //~AXI_CLK_I
    .event_tlast_unexpected     (event_tlast_unexpected     ),//for debug     //~AXI_CLK_I
    .event_tlast_missing        (event_tlast_missing        ),//for debug     //~AXI_CLK_I
    .event_fft_overflow         (event_fft_overflow         ),//for debug     //~AXI_CLK_I
    .event_status_channel_halt  (event_status_channel_halt  ),//for debug     //~AXI_CLK_I
    .event_data_in_channel_halt (event_data_in_channel_halt ),//for debug     //~AXI_CLK_I
    .event_data_out_channel_halt(event_data_out_channel_halt), //for debug     //~AXI_CLK_I
    
    
    .L_AVG_DATA_O               (l_avg_data ),
    .R_AVG_DATA_O               (r_avg_data )

    );
    

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
always @ (posedge S_AXI_ACLK) begin
    if(~S_AXI_ARESETN)begin      
        l_fft_signal_power_buf <= 0;
        l_fft_noise_power_buf  <= 0;
        l_fft_core_freq_hz_buf <= 0;
        r_fft_signal_power_buf <= 0;
        r_fft_noise_power_buf  <= 0;
        r_fft_core_freq_hz_buf <= 0;
    end
    else begin
        l_fft_signal_power_buf  <=  l_fft_finish  ?  fft_signal_power : l_fft_signal_power_buf ;
        l_fft_noise_power_buf   <=  l_fft_finish  ?  fft_noise_power  : l_fft_noise_power_buf  ;
        l_fft_core_freq_hz_buf  <=  l_fft_finish  ?  fft_core_freq_hz : l_fft_core_freq_hz_buf ;   
        r_fft_signal_power_buf  <=  r_fft_finish  ?  fft_signal_power : r_fft_signal_power_buf ;
        r_fft_noise_power_buf   <=  r_fft_finish  ?  fft_noise_power  : r_fft_noise_power_buf  ;
        r_fft_core_freq_hz_buf  <=  r_fft_finish  ?  fft_core_freq_hz : r_fft_core_freq_hz_buf ;  
    end
end



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire  aout_sclk_inner;
wire  aout_lrck_inner;
wire  aout_sdout_inner;
wire  aout_mclk_innner;

audio_out 
    #(.OUT_MCLK_LRCK_RATIO(AOUT_MCLK_LRCK_RATIO),
      .OUT_SCLK_LRCK_RATIO(AOUT_SCLK_LRCK_RATIO))
    audio_out_u(
    .CLK_12288KHZ_I      (CLK8192KHZ_I ),
    .SCLK_RSTN_I         (aresten_sclk ),
    
    .SCLK_LEFT_ENABLE_I  (  audio_out_left_enable__sclk   ),//(不使能时左右声道输出为0，三个时钟时钟存在)
    .SCLK_RIGHT_ENABLE_I (  audio_out_right_enable__sclk  ),//(不使能时左右声道输出为0，三个时钟时钟存在)
    .AUDIO_FERQ_I        (  audio_freq__sclk              ),//[3:0] ~SCLK

    .IIS_SCLK_O          (aout_sclk_inner  ),//to 5343 本模块运行时钟
    .IIS_LRCK_O          (aout_lrck_inner  ),//to 5343
    .IIS_SDOUT_O         (aout_sdout_inner ),//to 5343
    .IIS_MCLK_O          (aout_mclk_innner ) //to 5343  equal to CLK_12288KHZ_I
    ); 




generate if(AOUT_RING_OUT_ENABLE)begin
    assign   AOUT_MCLK_O  =  AIN_SEL_I ? AIN_MCLK_O_1 : AIN_MCLK_O ;
    assign   AOUT_LRCK_O  =  AIN_SEL_I ? AIN_LRCK_I_1 : AIN_LRCK_I ;
    assign   AOUT_SCLK_O  =  AIN_SEL_I ? AIN_SCLK_I_1 : AIN_SCLK_I;
    assign   AOUT_SDOUT_O =  AIN_SEL_I ? AIN_SDIN_I_1 : AIN_SDIN_I;
end
else begin
    assign   AOUT_MCLK_O  =  aout_mclk_innner  ;
    assign   AOUT_LRCK_O  =  aout_lrck_inner  ;
    assign   AOUT_SCLK_O  =  aout_sclk_inner ;
    assign   AOUT_SDOUT_O =  aout_sdout_inner ; 
end
endgenerate




generate if(IIS_INPUT_DEBUG)begin
    
    ila_1 ila_1_u(
    .clk    (S_AXI_ACLK),
    .probe0 (AIN_LRCK_I),//4
    .probe1 (AIN_SCLK_I),// 1 1 4 1 1 = 8
    .probe2 (AIN_SDIN_I)  ,  //1 
    .probe3 (AIN_LRCK_I_1 ) ,  //16  
    .probe4 (AIN_SCLK_I_1 ) , //32  
    .probe5 (AIN_SDIN_I_1   )    //1  
);

end
endgenerate




///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
generate if(DEBUG_ENABLE)begin

    ila_0   ila_audio_u(
    .clk    (S_AXI_ACLK),
    .probe0 (l_fft_finish      ),//1
    .probe1(r_fft_finish      ),//1
    .probe2(fft_signal_power),//64
    .probe3(fft_noise_power ),//64
    .probe4(fft_core_freq_hz),//16  

    .probe5(audio_in_u.fft_in_real),
    .probe6(audio_in_u.fft_in_tvalid),
    .probe7(audio_in_u.fft_in_tready),
    .probe8(audio_in_u.fft_in_tlast )

  
    );
end
endgenerate




endmodule





