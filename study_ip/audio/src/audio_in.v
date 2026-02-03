`timescale 1ns / 1ps
`define POS_MONITOR_FF1(clk_in,rst_in,in,buf_name1,out)    reg buf_name1 = 1; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 1; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);
`define NEG_MONITOR_FF1(clk_in,rst_in,in,buf_name1,out)    reg buf_name1 = 0; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);
`define SYN_MULTI_BIT_SINGLE(u_name,clk_in,data_in,clk_out,data_out,data_width)               xpm_cdc_array_single #(.DEST_SYNC_FF(4),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(data_width)) u_name(.src_clk(clk_in),.src_in(data_in),.dest_clk(clk_out),.dest_out(data_out));       
`define SYN_SINGLE_BIT_PULSE(u_name,clk_in,rst_in,pulse_in,clk_out,rst_out,pulse_out)         xpm_cdc_pulse #(.DEST_SYNC_FF(4), .INIT_SYNC_FF(0),.REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) u_name (.src_clk(clk_in),.src_rst(rst_in),.src_pulse(pulse_in),.dest_clk(clk_out),.dest_rst(rst_out),.dest_pulse(pulse_out));            

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// Create Date: 2022/09/19 13:38:28
// Design Name: 
// Module Name: audio_in
//////////////////////////////////////////////////////////////////////////////////
//5343格式：not left-justified(tbt02中使用)
//5344格式: left-justified
//not-justified:
//           right data                   left   data
//LRCK ____|————————————————————————————|____________________
//SCLK |_|—|_|—|_|—|_|—|_|—|_|—|
//D             AAA BBB CCC

module audio_in(
//
input   CLK_12288KHZ_I,//12288KHz 和 IIS相关
//iis interface   //~IIS_SCLK_I
input   IIS_SCLK_I,//from 5343 ~功能-同步时钟
input   IIS_LRCK_I,//from 5343
input   IIS_SDIN_I,//from 5343
output  IIS_MCLK_O,//to   5343
//rd channel        //~AXI_CLK_I
input   AXI_CLK_I,
input   AXI_RSTN_I ,
input   AXI_ENABLE_I,
output  FIFO_L_ENOUGH_O, 
output  FIFO_R_ENOUGH_O,
input          FIFO_L_RD_I  ,
output  [23:0] FIFO_L_DOUT_O,
input          FIFO_R_RD_I  ,
output  [23:0] FIFO_R_DOUT_O,

output FFT_L_FINISH_O,
output FFT_R_FINISH_O,
output [63:0] FFT_SIGNAL_POWER_O,
output [63:0] FFT_NOISE_POWER_O,
output [15:0] FFT_CORE_FREQ_HZ_O,


output event_frame_started   ,
output event_tlast_unexpected,
output event_tlast_missing   ,
output event_fft_overflow  ,

output  event_status_channel_halt,
output  event_data_in_channel_halt,
output  event_data_out_channel_halt,

output [22:0] L_AVG_DATA_O ,
output [22:0] R_AVG_DATA_O 


);
parameter [0:0] MEMORY_ENABLE  = 0;
parameter [0:0] FFT_WIN_ENABLE = 0;
parameter C_EXPAND_POINTS_NUM_ONE_SIDE = 0;
parameter [15:0] AIN_AMP_AVG_POINTS = 1024;//只要能涵盖一个正弦波周期即可

localparam FFT_POINT_NUM = 512;


assign FFT_L_FINISH_O       =  sn_finish & ~right;//虽然内部逻辑反了，但是这里又反了回来!!!
assign FFT_R_FINISH_O       =  sn_finish &  right;

assign FFT_SIGNAL_POWER_O = signal_power_n1 ;
assign FFT_NOISE_POWER_O  = noice_power_n1;
assign FFT_CORE_FREQ_HZ_O = core_freq_hz ;


wire lrck_pos;
wire lrck_neg;
wire sclk_enable;//使能从axi时钟域同步到sclk时钟域
wire sclk_rstn;//复位从axi时钟域同步到sclk时钟域

`SYN_MULTI_BIT_SINGLE(cdc_u0,AXI_CLK_I,AXI_ENABLE_I,IIS_SCLK_I,sclk_enable,1)  
`SYN_MULTI_BIT_SINGLE(cdc_u1,AXI_CLK_I,AXI_RSTN_I,IIS_SCLK_I,sclk_rstn,1)  

`POS_MONITOR_FF1(IIS_SCLK_I,(~sclk_enable),IIS_LRCK_I,lrck_buf1,lrck_pos)
`NEG_MONITOR_FF1(IIS_SCLK_I,(~sclk_enable),IIS_LRCK_I,lrck_buf2,lrck_neg)

//1:right  2:left  //mod 2023年7月22日11:22:58

reg [7:0]  state_1 = 0;
reg [23:0] data_1 = 0;
reg [7:0] cnt_left_1 = 0;
reg fifo_wr_en_1 = 0;
reg [23:0] fifo_wr_data_1 = 0;


reg [7:0]  state_2 = 0;
reg [23:0] data_2 = 0;
reg [7:0] cnt_left_2 = 0;
reg fifo_wr_en_2 = 0;
reg [23:0] fifo_wr_data_2 = 0;


wire fifo_wr_full_1;
wire fifo_wr_full_2;
wire fifo_rd_empty_1;
wire fifo_rd_empty_2;

wire [9:0] fifo_wr_data_count_1;
wire [9:0] fifo_wr_data_count_2;
wire [9:0] fifo_rd_data_count_1;
wire [9:0] fifo_rd_data_count_2;


wire signed [23:0] dout_data_axi_1;//用于fft分析
wire dout_en_l;
wire signed [23:0] dout_data_axi_2;
wire dout_en_r;


wire sn_finish;
reg [7:0] state = 0;
reg fft_in_tvalid = 0;
wire fft_in_tready;
reg [15:0] cnt_have = 0;//1~1024
reg signed [23:0] fft_in_real = 0;
reg right = 0;
reg fft_in_tlast = 0;

reg [8:0] hann_addr = 0;
wire signed [10:0] hann_factor;

wire signed [23:0]fft_out_real;//: OUT STD_LOGIC_VECTOR(47 DOWNTO 0);
wire signed [23:0]fft_out_imag;//: OUT STD_LOGIC_VECTOR(47 DOWNTO 0);
wire fft_out_tvalid;//: OUT STD_LOGIC;
//wire fft_out_tready;//: IN STD_LOGIC;
wire fft_out_tlast; //: OUT STD_LOGIC;
wire fft_in_transfer;


wire signed [24+11-1:0] dout_mult_hann_2_36;
wire signed [24+11-1:0] dout_mult_hann_1_36;
wire signed [23:0] dout_mult_hann_2_24;
wire signed [23:0] dout_mult_hann_1_24;


wire [15:0] core_freq_hz;
wire [63:0] signal_power_n1;//fft输出24位，假设拉满，那么功率是48位，总功率最大 48+9 =59位
wire [63:0] noice_power_n1; //

wire [15:0] debug_cnt_id;
wire [15:0] debug_cnt_max_id;

wire [23:0] m_axis_data_tuser;
wire [7:0] m_axis_status_tdata;

assign IIS_MCLK_O = CLK_12288KHZ_I;
assign FIFO_L_ENOUGH_O = MEMORY_ENABLE ? ( fifo_rd_data_count_1 >= 512 ) : 0;
assign FIFO_R_ENOUGH_O = MEMORY_ENABLE ? ( fifo_rd_data_count_2 >= 512 ) : 0;

// IIS right channel 
always@(posedge IIS_SCLK_I)begin
    if( (~sclk_enable) | (~sclk_rstn) )begin
        state_1     <= 0;
        data_1      <= 0;
        cnt_left_1  <= 0;
        fifo_wr_en_1 <= 0;
        fifo_wr_data_1 <= 0;
    end
    else begin
        case(state_1)
            0:begin
                state_1    <= lrck_pos ? 1 : state_1;
                cnt_left_1 <= lrck_pos ? 24 :  0;
            end
            1:begin
                data_1     <= {data_1[22:0],IIS_SDIN_I};
                cnt_left_1 <= cnt_left_1 - 1;
                state_1    <= (cnt_left_1 == 1) ? 2 : 1;
            end
            2:begin
                fifo_wr_en_1   <= 1;//未满时可以写入
                fifo_wr_data_1 <= data_1;
                state_1     <= 3;
            end
            3:begin//循环写入ram
                fifo_wr_en_1   <= 0;
                state_1     <= 0;
            end
            default:begin
                state_1     <= 0;
                data_1      <= 0;
                cnt_left_1  <= 0;
                fifo_wr_en_1   <= 0;
                fifo_wr_data_1 <= 0;
            end
        endcase
    end
end

wire [22:0] fifo_wr_data_1_absolute; 
wire [22:0] r_avg_data;
wire r_avg_data_valid;
assign fifo_wr_data_1_absolute = fifo_wr_data_1[23] ? ~fifo_wr_data_1 + 1 : fifo_wr_data_1;
assign R_AVG_DATA_O = r_avg_data;


avg_filter  
    #(.C_DATA_WIDTH (24-1),
      .C_AVG_POINTS (AIN_AMP_AVG_POINTS) ) // AIN_AMP_AVG_POINTS
    r_avg_filter_u(
    .CLK_I   (IIS_SCLK_I   ),
    .RST_I   (~sclk_rstn   ),
    .WR_I    (fifo_wr_en_1 ),
    .DATA_I  (fifo_wr_data_1_absolute ),
    .AVG_O   (r_avg_data),
    .VALID_O (r_avg_data_valid) //本模块假定数据一直有，所以该信号未使用
    );
    
    

// IIS left channel 
always@(posedge IIS_SCLK_I)begin
    if( (~sclk_enable) | (~sclk_rstn) )begin
        state_2     <= 0;
        data_2      <= 0;
        cnt_left_2  <= 0;
        fifo_wr_en_2 <= 0;
        fifo_wr_data_2 <= 0;
    end
    else begin
        case(state_2)
            0:begin
                state_2    <= lrck_neg ? 1 : state_2;
                cnt_left_2 <= lrck_neg ? 24 :  0;
            end
            1:begin
                data_2     <= {data_2[22:0],IIS_SDIN_I};
                cnt_left_2 <= cnt_left_2 - 1;
                state_2    <= (cnt_left_2 == 1) ? 2 : 1;
            end
            2:begin
                fifo_wr_en_2   <= 1;//未满时可以写入
                fifo_wr_data_2 <= data_2;
                state_2     <= 3;
            end
            3:begin//
                fifo_wr_en_2   <= 0;
                state_2     <= 0;
            end
            default:begin
                state_2     <= 0;
                data_2      <= 0;
                cnt_left_2  <= 0;
                fifo_wr_en_2   <= 0;
                fifo_wr_data_2 <= 0;
            end
        endcase
    end
end


wire [22:0] fifo_wr_data_2_absolute; 
wire [22:0] l_avg_data;
wire l_avg_data_valid;
assign fifo_wr_data_2_absolute = fifo_wr_data_2[23] ? ~fifo_wr_data_2 + 1 : fifo_wr_data_2;
assign L_AVG_DATA_O = l_avg_data;

avg_filter  
    #(.C_DATA_WIDTH (24-1),
      .C_AVG_POINTS (AIN_AMP_AVG_POINTS) ) //AIN_AMP_AVG_POINTS
    l_avg_filter_u(
    .CLK_I   (IIS_SCLK_I   ),
    .RST_I   (~sclk_rstn   ),
    .WR_I    (fifo_wr_en_2 ),
    .DATA_I  (fifo_wr_data_2_absolute ),
    .AVG_O   (l_avg_data),
    .VALID_O (l_avg_data_valid)
    );
    


generate if(MEMORY_ENABLE)begin
//(*KEEP_HIERARCHY  = "TRUE"*)
fifo_xpm_async
   #(.WRITE_DATA_WIDTH   (24    ), //W/R ratio must be 1:1, 1:2, 1:4, 1:8, 8:1, 4:1 , 2:1  
     .READ_DATA_WIDTH    (24    ), //W/R ratio must be 1:1, 1:2, 1:4, 1:8, 8:1, 4:1 , 2:1  
     .WRITE_FIFO_DEPTH   (1024 ), //must>=16 ;actual depth = WRITE_FIFO_DEPTH-1; must be power of two
     .WR_DATA_COUNT_WIDTH(11   ), //as you wish ; must >= 1
     .RD_DATA_COUNT_WIDTH(11   )) //as you wish ; must >= 1
   left_channel_fifo_u(
   .WR_RST_I       ( (~sclk_enable) | (~sclk_rstn) ),//at least 1 WR_CLK_I period
   .WR_CLK_I       (IIS_SCLK_I            ),//[0:0]
   .WR_EN_I        (fifo_wr_en_1 & (~fifo_wr_full_1) ),//[0:0]
   .WR_DATA_I      (fifo_wr_data_1        ),//[WRITE_DATA_WIDTH-1:0]
   .WR_FULL_O      (fifo_wr_full_1        ),//[0:0]
   .WR_DATA_COUNT_O(fifo_wr_data_count_1  ),//[WR_DATA_COUNT_WIDTH-1:0]
   .RD_CLK_I       (AXI_CLK_I             ),//[0:0]
   //.RD_EN_I        ( DEBUG_ENABLE ?  fft_out_tvalid  :  FIFO_L_RD_I            ),//[0:0]  //为了看
   
   .RD_EN_I        ( FIFO_L_RD_I          ),
   .RD_DATA_O      (FIFO_L_DOUT_O         ),//[READ_DATA_WIDTH-1:0]
   .RD_EMPTY_O     (fifo_rd_empty_1       ),//[0:0]
   .RD_DATA_COUNT_O(fifo_rd_data_count_1  ) //[RD_DATA_COUNT_WIDTH-1:0]
   );

//(*KEEP_HIERARCHY  = "TRUE"*)
fifo_xpm_async
   #(.WRITE_DATA_WIDTH   (24    ), //W/R ratio must be 1:1, 1:2, 1:4, 1:8, 8:1, 4:1 , 2:1  
     .READ_DATA_WIDTH    (24    ), //W/R ratio must be 1:1, 1:2, 1:4, 1:8, 8:1, 4:1 , 2:1  
     .WRITE_FIFO_DEPTH   (1024 ), //must>=16 ;actual depth = WRITE_FIFO_DEPTH-1; must be power of two
     .WR_DATA_COUNT_WIDTH(11   ), //as you wish ; must >= 1
     .RD_DATA_COUNT_WIDTH(11   )) //as you wish ; must >= 1
   right_channel_fifo_u(
   .WR_RST_I       ( (~sclk_enable) | (~sclk_rstn)  ),//at least 1 WR_CLK_I period
   .WR_CLK_I       (IIS_SCLK_I            ),//[0:0]
   .WR_EN_I        (fifo_wr_en_2 & (~fifo_wr_full_2) ),//[0:0]
   .WR_DATA_I      (fifo_wr_data_2        ),//[WRITE_DATA_WIDTH-1:0]
   .WR_FULL_O      (fifo_wr_full_2        ),//[0:0]
   .WR_DATA_COUNT_O(fifo_wr_data_count_2  ),//[WR_DATA_COUNT_WIDTH-1:0]
   .RD_CLK_I       (AXI_CLK_I             ),//[0:0]
   //.RD_EN_I        (DEBUG_ENABLE ?  fft_out_tvalid  :    FIFO_R_RD_I            ),//[0:0]
   
   .RD_EN_I        ( FIFO_R_RD_I        ),//[0:0]
   .RD_DATA_O      (FIFO_R_DOUT_O          ),//[READ_DATA_WIDTH-1:0]
   .RD_EMPTY_O     (fifo_rd_empty_2       ),//[0:0]
   .RD_DATA_COUNT_O(fifo_rd_data_count_2  ) //[RD_DATA_COUNT_WIDTH-1:0]
   );
   
end
endgenerate



(*KEEP_HIERARCHY  = "TRUE"*)
fifo_xpm_buffer #(.DATA_WIDTH(24))
    fifo_sync_u(
    .DIN_RST_I  ((~sclk_enable) | (~sclk_rstn)),//at least one DIN_CLK_I period，sync reset
    .DIN_CLK_I  (IIS_SCLK_I),
    .DIN_EN_I   (fifo_wr_en_1),
    .DIN_DATA_I (fifo_wr_data_1),
    .DOUT_CLK_I (AXI_CLK_I),
    .DOUT_EN_O  (dout_en_l),
    .DOUT_DATA_O(dout_data_axi_1)
    );


(*KEEP_HIERARCHY  = "TRUE"*)
fifo_xpm_buffer #(.DATA_WIDTH(24))
    fifo_sync_u2(
    .DIN_RST_I  ((~sclk_enable) | (~sclk_rstn)),//at least one DIN_CLK_I period，sync reset
    .DIN_CLK_I  (IIS_SCLK_I),
    .DIN_EN_I   (fifo_wr_en_2),
    .DIN_DATA_I (fifo_wr_data_2),
    .DOUT_CLK_I (AXI_CLK_I),
    .DOUT_EN_O  (dout_en_r),
    .DOUT_DATA_O(dout_data_axi_2)
    );
    
    
   

assign fft_in_transfer = fft_in_tvalid && fft_in_tready;


hann_512 hann_512_u(
    .clka  (AXI_CLK_I),//: IN STD_LOGIC;
    .addra (hann_addr),//: IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    .douta (hann_factor)); //: OUT STD_LOGIC_VECTOR(10 DOWNTO 0)
    

assign dout_mult_hann_2_36 = $signed(dout_data_axi_2) * $signed(hann_factor)  ;
assign dout_mult_hann_1_36 = $signed(dout_data_axi_1) * $signed(hann_factor)  ;

assign dout_mult_hann_2_24 = FFT_WIN_ENABLE ? ( dout_mult_hann_2_36>>>11 ) :  dout_data_axi_2 ; //fft模块需24位输入
assign dout_mult_hann_1_24 = FFT_WIN_ENABLE ? ( dout_mult_hann_1_36>>>11 ) :  dout_data_axi_1 ;


always@(posedge AXI_CLK_I)begin
    if((~AXI_RSTN_I) | (~AXI_ENABLE_I))begin
        state <= 0;
        cnt_have  <= 0;
        fft_in_tvalid <= 0;
        right <= 0;
        fft_in_real <= 0;
        fft_in_tlast <= 0;
        hann_addr <= 0;
    end
    else begin
        case(state)
            0:begin
                state <= 2;
            end
            2:begin//
                if(right ? dout_en_r : dout_en_l)begin
                    hann_addr <= cnt_have;// from 0
                    state <= 3;
                end
            end
            3:begin
                state <= 4;
            end
            4:begin
                fft_in_tvalid <= 1;
                fft_in_real  <= right ? dout_mult_hann_2_24 : dout_mult_hann_1_24;
                fft_in_tlast <= (cnt_have==FFT_POINT_NUM-1 ) ? 1 : 0;
                state <= 5;
            end
            5:begin//送入fft
                if(fft_in_transfer)begin
                    fft_in_tvalid <= 0;
                    fft_in_tlast  <= 0;
                    cnt_have <= cnt_have + 1;
                    state <= 6;
                end
            end
            6:begin
                state <= (cnt_have == FFT_POINT_NUM) ? 7 : 2;
                right <= (cnt_have == FFT_POINT_NUM) ? ~right : right;
            end
            7:begin
                state <= sn_finish ? 0 : state;//信噪比计算完成才进行下一轮
                cnt_have <= 0;//复位
            end
            default:begin
                state <= 0;
                cnt_have  <= 0;
                fft_in_tvalid <= 0;
                right <= 0;
                fft_in_real <= 0;
                fft_in_tlast <= 0;
                hann_addr <= 0;
            end
        endcase
    end
end

//低
//config配置值           1024点
//NFFT      000_xxxxx    000_01010
//CP_LEN    0_xxxxxxx    0_1000000
//FWD_INV   00000_100    00000_111
//
//高


//wire [47:0] s_axis_config_tdata;
//assign s_axis_config_tdata = 48'b00000101_01010101_01010110_00000_001_0_0000000_000_01010;
//reg s_axis_config_tvalid = 0;
//wire s_axis_config_tready;

 xfft_0  xfft_0_u(
    .aclk                        (AXI_CLK_I),
    .aresetn                     (AXI_RSTN_I & AXI_ENABLE_I),
    .s_axis_config_tdata         (0),//23:0
    .s_axis_config_tvalid        (0),
    .s_axis_config_tready        (s_axis_config_tready),
    .s_axis_data_tdata           ({24'b0,fft_in_real}),//(47 DOWNTO 0);
    .s_axis_data_tvalid          (fft_in_tvalid),
    .s_axis_data_tready          (fft_in_tready),
    .s_axis_data_tlast           (fft_in_tlast ),
    .m_axis_data_tdata           ({fft_out_imag,fft_out_real}),//(47 DOWNTO 0);
    .m_axis_data_tuser           (m_axis_data_tuser), //OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
    
    .m_axis_data_tvalid          (fft_out_tvalid),
    .m_axis_data_tready          (1),
    .m_axis_data_tlast           (fft_out_tlast), 
    
    .m_axis_status_tdata          (m_axis_status_tdata),//7:0
    .m_axis_status_tvalid         (m_axis_status_tvalid),
    .m_axis_status_tready         (1),
    
    .event_frame_started         (event_frame_started   ),
    .event_tlast_unexpected      (event_tlast_unexpected),
    .event_tlast_missing         (event_tlast_missing   ),
    .event_fft_overflow          (event_fft_overflow    ),
    .event_status_channel_halt    (event_status_channel_halt),
    .event_data_in_channel_halt   (event_data_in_channel_halt),
    .event_data_out_channel_halt  (event_data_out_channel_halt)
    
    
    );




fft_sn_calc 
    #(.FFT_POINT_NUM(FFT_POINT_NUM),
      .C_EXPAND_POINTS_NUM_ONE_SIDE(C_EXPAND_POINTS_NUM_ONE_SIDE)
    )
    fft_sn_calc_u(
    .RST_I         ((~AXI_RSTN_I) | (~AXI_ENABLE_I) |  fft_in_tlast),//每一轮都会对其复位
    .CLK_I         (AXI_CLK_I),
    .TVALID_I      (fft_out_tvalid),
    .TDATA_REAL_I  (fft_out_real),//[23:0] 
    .TDATA_IMAG_I  (fft_out_imag),//[23:0]
    .FINISH_O      (sn_finish),//1 pulse
    .SIGNAL_POWER_O(signal_power_n1),//[63:0]
    .NOICE_POWER_O (noice_power_n1),//[63:0]
    .CORE_FREQ_HZ_O(core_freq_hz), //[15:0]
    .debug_cnt_id    (debug_cnt_id),//[15:0]
    .debug_cnt_max_id(debug_cnt_max_id)//[15:0]
    );
    

    
    
endmodule
