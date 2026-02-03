`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: yzhu
// Create Date: 2022/08/10 11:36:05
// Module Name: spi_write_freqdiv_tri
//////////////////////////////////////////////////////////////////////////////////

module spi_write_freqdiv_tri
#(  parameter MAX_BYTE_NUM         = 100  ,  //must >= 1
    parameter CLK_PERIOD_NS        = 100  ,  //must >= 0
    parameter CSLOW_TO_CLKBEGIN_NS = 10000,  //must >= 0
    parameter CLKEND_TO_CSHIGH_NS  = 10000,  //must >= 0
    parameter CSHIGH_TO_BUSYLOW_NS = 10000   //must >= 0
)
( 
//----------------------------------------------------------------------------------------------------------------------------------------------
//---------------------------------------------位宽----------------------------------说明-----------------------------------合法值--------------
//----------------------------------------------------------------------------------------------------------------------------------------------
input                       RST_I           ,//[0:0]    ###  同步高复位                                            ###                                                      
input                       CLK_I           ,//[0:0]    ###  时钟                                                  ###         
//********命令接口(和START_I同时打入)***********************************************************************************************************                                  
input  [2:0]                CMD_I           ,//[2:0]    ###  模式 0:【单次写】;1:【自动连续写】;2:【外部连续写】   ###     
input  [MAX_BYTE_NUM*8-1:0] PDATA_I         ,//参数决定 ###  从右往左DATA_BYTE_NUM_I个字节有效,有效部分先发高字节  ###                                                     
input  [15:0]               DATA_BYTE_NUM_I ,//[7:0]    ###  有参数保护;外部连续写时,该值每轮都有效                ###   1 <= VALUE <=255                             
input  [15:0]               ROUND_NUM_I     ,//[15:0]   ###  有参数保护;仅用于【自动连续写】                       ###   1 <= VALUE <=65535                           
input                       START_I         ,//[0:0]    ###  触发模块;内部会检测上沿                               ###                                                      
output                      BUSY_O          ,//[0:0]    ###  模块忙信号                                            ###
output                      READ_PULSE_O    ,//[0:0]    ###  仅【自动连续写】时使用                                ###
output  reg                 ALMOST_PULSE_O  ,//[0:0]    ###  仅【外部连续写】时使用                                ###
//********************SPI接口******************************************************************************************************************** 
output                      SPI_CS_O        ,//[0:0]    ###  SPI接口信号                                           ###
output                      SPI_SCK_O       ,//[0:0]    ###  SPI接口信号                                           ###
output                      SPI_DO_O        ,//[0:0]    ###  SPI接口信号                                           ###
//*******************模式配置********************************************************************************************************************
input  [9:0]                DIV             ,//[9:0]    ###  SPI_SCK相对于CLK_I的分频值; 按需赋常数即可            ###   2 <= VALUE <=1023                            
input                       POL             ,//[0:0]    ###  SPI模式选择位; 按需赋常数即可                         ###   0或1
input                       PHA              //[0:0]    ###  SPI模式选择位; 按需赋常数即可                         ###   0或1
 
);
//需要注意的逻辑
//1 DIV_CNT==2 & PHA==1 结束时，在子状态机内部复位时钟
//2 DIV_CNT==2 & PHA==0 结束时，刚跳出子状态机时立刻复位时钟
//3 其他                结束时，刚跳出子状态机时在 sck_neg 时复位时钟

////////////////////////////////////////////////////////////////////////////////
localparam CSLOW_TO_CLKBEGIN_PERIOD_NUM = CSLOW_TO_CLKBEGIN_NS / CLK_PERIOD_NS;
localparam CLKEND_TO_CSHIGH_PERIOD_NUM  = CLKEND_TO_CSHIGH_NS  / CLK_PERIOD_NS;
localparam CSHIGH_TO_BUSYLOW_PERIOD_NUM = CSHIGH_TO_BUSYLOW_NS / CLK_PERIOD_NS;
wire [9:0] DIV_CNT = DIV<=2 ? 2 : {DIV[9:1],1'b0};
wire [15:0]  DATA_BYTE_NUM = DATA_BYTE_NUM_I==0 ? 1 : DATA_BYTE_NUM_I;
wire [15:0] ROUND_NUM     = ROUND_NUM_I==0 ? 1 : ROUND_NUM_I;
////////////////////////////////////////////////////////////////////////////////
`define SINGLE_TO_BI_Nm1To0(a,b,in,out)   generate for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
genvar i;
reg read_pulse = 0;
reg read_pulse_s1;
wire sck_pos;
wire sck_neg;  
reg pulse_rst = 1;  
reg sck_al = 0;
wire start_pos;
reg  start_buf1;
reg  start_buf2;
reg [2:0] Cmd_i;
reg [MAX_BYTE_NUM*8-1:0] Pdata_i;
reg [MAX_BYTE_NUM*8-1:0] Pdata_i_2;
reg [15:0]  Data_byte_num_i;reg [15:0]  Data_byte_num_left;
reg [15:0] Round_num_i;    reg [15:0] Round_num_left;
reg [15:0]  Data_byte_num_i_2;
reg [7:0]  Shift_out_8;
reg [7:0]  State;
reg [7:0]  Sub_state;
reg Cs = 1;
reg FF   ;
reg Busy ;
reg [9:0] Cnt_delay;
reg Need_continue;
reg Need_continue_reset;
reg Need_stop;
///////////////////////////////////////////////////////////////////////////////
assign SPI_SCK_O = (POL==0)?sck_al :~ sck_al; 
assign SPI_CS_O   = Cs;
assign SPI_DO_O   = Shift_out_8[7];
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign BUSY_O = START_I | Busy;

///////////////////////////////////////////////////////////////////////////////
assign READ_PULSE_O = read_pulse & (~read_pulse_s1);
always@(posedge CLK_I)begin
    if(RST_I)begin
        read_pulse_s1 <= 1;
    end
    else begin
        read_pulse_s1 <= read_pulse;
    end
end
///////////////////////////////////////////////////////////////////////////////        
//分频产生模块
pulse_rst_loop_fhsl__divtri
    pulse_rst_loop_fhsl_u0(
    .RST_I(pulse_rst),
    .CLK_I(CLK_I),
    .PULSE_O(sck_pos),
    .FIRST_DELAY_CLK_NUM_I((DIV_CNT)+2),
    .HIGH_CLK_NUM_I(1),
    .TOTAL_CLK_NUM_I((DIV_CNT)));
pulse_rst_loop_fhsl__divtri
    pulse_rst_loop_fhsl_u1(
    .RST_I(pulse_rst),
    .CLK_I(CLK_I),
    .PULSE_O(sck_neg),
    .FIRST_DELAY_CLK_NUM_I((DIV_CNT)+(DIV_CNT>>1)+2),
    .HIGH_CLK_NUM_I(1),
    .TOTAL_CLK_NUM_I((DIV_CNT)));
///////////////////////////////////////////////////////////////////////////////
always@(posedge CLK_I)begin
    if(RST_I)begin
        sck_al <= 0;
    end
    else begin
        if(sck_pos)begin
            sck_al <= 1;
        end
        else if(sck_neg)begin
            sck_al <= 0;
        end
    end
end
//////////////////////////////////////////////////////////////////////////////////
wire [7:0] ms_byte;//引出 Pdata_i 的最高字节--当Pdata_i作为写入数据字节时
wire [7:0] pdata_m [0:MAX_BYTE_NUM-1];
`SINGLE_TO_BI_Nm1To0(8,MAX_BYTE_NUM,Pdata_i,pdata_m)
wire [f_Data2W(MAX_BYTE_NUM)-1:0] INDEX ;
assign INDEX  = ((Data_byte_num_i-1) > (MAX_BYTE_NUM-1)) ? 0: (Data_byte_num_i-1) ;
assign ms_byte = pdata_m[INDEX];
////////////////////////////////////////////////////////////////////////////////
always@(negedge CLK_I)begin 
    if(RST_I)begin
        start_buf1 <= 1;
        start_buf2 <= 1;
    end
    else begin
        start_buf1 <= START_I;    
        start_buf2 <= start_buf1;
    end
end
assign start_pos = (start_buf1) & (~start_buf2);
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
localparam shift_out_0 = 0,
           shift_out_1 = 1,
           shift_out_2 = 2,
           shift_out_3 = 3,
           shift_out_4 = 4,
           shift_out_5 = 5,
           shift_out_6 = 6,
           shift_out_7 = 7,
           shift_out_8 = 8;   
///////////////////////////////////////////////////////////////////////////////
always@(negedge CLK_I)begin
    if(RST_I)begin
        Pdata_i_2 <= 0;
        Need_continue <= 0;
        Data_byte_num_i_2 <= 0;
    end
    else if(start_pos & State!=0)begin
        Need_continue  <= 1;
        Pdata_i_2      <= PDATA_I;
        Data_byte_num_i_2 <= DATA_BYTE_NUM;
    end
    else if(Need_continue_reset)begin
        Need_continue <= 0;
    end
end
///////////////////////////////////////////////////////////////////////////////
always@(posedge CLK_I)begin
    if(RST_I)begin
        t_reset;
    end
    else begin
        case(State)
            0:begin
                if(start_pos)begin
                    Cmd_i           <= CMD_I;
                    Pdata_i         <= PDATA_I;
                    Data_byte_num_i <= DATA_BYTE_NUM;
                    Round_num_i     <= ROUND_NUM;
                    Cs              <= 0;
                    Cnt_delay       <= CSLOW_TO_CLKBEGIN_PERIOD_NUM;
                    Busy            <= 1;
                    State           <= 1;
                end
            end
            1:begin
                if(Cnt_delay==0)begin
                    pulse_rst <= 1;
                    State <= 22;
                end
                else begin
                    Cnt_delay <= Cnt_delay - 1;
                end
            end
            22:begin
                case(Cmd_i)
                    3'd0:begin//【单次写】
                        State <= 2;
                    end
                    3'd1:begin//【自动连续写】
                        State <= 3;
                    end
                    3'd2:begin//【外部连续写】
                        State <= 4;
                    end
                    default:begin
                        t_reset;
                    end
                endcase
            end
            2:begin//【单次写】(开始)
                pulse_rst <= 0;

                if((PHA&sck_pos) | ~PHA)begin//【起步的处理】
                    Data_byte_num_left <= Data_byte_num_i;
                    Shift_out_8 <= ms_byte;
                    Pdata_i     <= Pdata_i << 8;
                    Sub_state   <= shift_out_1;
                    FF          <= 1;
                    State       <= 10;
                end
            end
            
            3:begin//【自动连续写】(开始)
                read_pulse <= 1;
                Data_byte_num_left <= Data_byte_num_i;
                Round_num_left <= Round_num_i;
                State <= 11;
            end
            4:begin//【外部连续写】(开始)
                pulse_rst <= 0;
                
                if((PHA&sck_pos) | ~PHA)begin
                    Data_byte_num_left <= Data_byte_num_i;
                    Shift_out_8 <= ms_byte;
                    Pdata_i     <= Pdata_i << 8;
                    Sub_state   <= shift_out_1;
                    FF          <= 1;
                    State       <= 15;
                end
            end
            /////////////////////////////////////////////////////////
            /////////////////////////////////////////////////////////
            10:begin//【单次写】(过程)
                if(FF)begin
                    if(PHA?sck_pos:sck_neg)begin//【凡Shift_out_8处都应和sck对齐,下同】
                        t_send_one_byte;
                    end
                end
                else begin
                    //DIV=2,PHA=0 时立刻复位时钟（DIV=2,PHA=1时在子状态中复位时钟）
                    if( Data_byte_num_left==0 )begin
                        if( DIV_CNT==2 )begin
                            Cnt_delay <= CLKEND_TO_CSHIGH_PERIOD_NUM;
                            pulse_rst <= 1;
                            State  <= 30;
                        end
                        else if( sck_neg )begin
                            Cnt_delay <= CLKEND_TO_CSHIGH_PERIOD_NUM;
                            pulse_rst <= 1;
                            State  <= 30;
                        end
                    end
                    else if(PHA?sck_pos:sck_neg)begin//下一个字节
                        Shift_out_8   <= ms_byte;
                        Pdata_i       <= Pdata_i<<8;
                        FF            <= 1;
                        Sub_state     <= shift_out_1;
                        State         <= 10;
                    end
                end
            end
            /////////////////////////////////////////////////////////
            11:begin//【自动连续写】(过程)
                read_pulse <= 0;
                State <= 12;
            end
            12:begin
                Pdata_i <= PDATA_I;
                State <= 13;
            end
            13:begin
                pulse_rst <= 0;
                
                if((PHA&sck_pos) | ~PHA)begin
                    Shift_out_8 <= ms_byte;
                    Pdata_i     <= Pdata_i << 8;
                    Sub_state   <= shift_out_1;
                    FF          <= 1;
                    State       <= 14;
                end
            end
            14:begin
                if(FF)begin
                    if(PHA?sck_pos:sck_neg)begin
                        t_send_one_byte__auto;
                    end
                end
                else begin
                    //DIV=2,PHA=0 时立刻复位时钟（DIV=2,PHA=1时在子状态中复位时钟）
                    if( Round_num_left==0 )begin
                        if( DIV_CNT==2 )begin
                            Cnt_delay <= CLKEND_TO_CSHIGH_PERIOD_NUM;
                            pulse_rst <= 1;
                            State  <= 30;
                        end
                        else if( sck_neg )begin//OVER
                            Cnt_delay <= CLKEND_TO_CSHIGH_PERIOD_NUM;
                            pulse_rst <= 1;
                            State  <= 30; //OVER
                        end
                    end
                    else if(PHA?sck_pos:sck_neg)begin
                        Shift_out_8   <= ms_byte;
                        Pdata_i       <= Pdata_i<<8;
                        FF            <= 1;
                        Sub_state     <= shift_out_1;
                        State         <= 14;
                    end
                end
            end
            /////////////////////////////////////////////////////////
            /////////////////////////////////////////////////////////
            15:begin//【外部连续写】(过程)
                if(FF)begin
                    if(PHA?sck_pos:sck_neg)begin
                        t_send_one_byte__outer;
                    end
                end
                else begin
                    Need_continue_reset  <= 0; 
                    //DIV=2,PHA=0 时立刻复位时钟（DIV=2,PHA=1时在子状态中复位时钟）
                    if( Need_stop==1 )begin
                        if( DIV_CNT==2 )begin
                            Cnt_delay <= CLKEND_TO_CSHIGH_PERIOD_NUM;
                            pulse_rst <= 1;
                            State  <= 30;
                        end
                        else if( sck_neg )begin//OVER
                            Need_stop <= 0;
                            Cnt_delay <= CLKEND_TO_CSHIGH_PERIOD_NUM;
                            pulse_rst <= 1;
                            State     <= 30; //OVER
                        end
                    end
                    else if(PHA?sck_pos:sck_neg)begin
                        Shift_out_8   <= ms_byte;
                        Pdata_i       <= Pdata_i<<8;
                        FF            <= 1;
                        Sub_state     <= shift_out_1;
                        State         <= 15;
                    end
                end
            end
            /////////////////////////////////////////////////////////
            /////////////////////////////////////////////////////////
            30:begin
                if(sck_neg)pulse_rst <= 1;//使得结束时时钟波形完整
                if(Cnt_delay==0)begin
                    State <= 20;
                end
                else begin
                    Cnt_delay <= Cnt_delay - 1;
                end
            end
            20:begin
                Cs          <= 1;
                Cnt_delay   <= CSHIGH_TO_BUSYLOW_PERIOD_NUM;
                State       <= 21;
            end
            21:begin
                if(Cnt_delay==0)begin
                    Busy  <= 0;
                    State <= 0;
                end
                else begin
                    Cnt_delay <= Cnt_delay - 1;
                end
            end
            default:begin
                t_reset; 
            end
        endcase
    end
end


task t_send_one_byte;
begin
    case(Sub_state)
        shift_out_0:begin 
            Shift_out_8 <= Shift_out_8; 
            Sub_state  <= shift_out_1;
        end
        shift_out_1:begin 
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_2;
        end
        shift_out_2:begin
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_3;
        end
        shift_out_3:begin
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_4;
        end
        shift_out_4:begin
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_5;
        end
        shift_out_5:begin
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_6;
        end
        shift_out_6:begin
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_7;
        end
        shift_out_7:begin
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_8;
            Data_byte_num_left <= Data_byte_num_left - 1;
            
            
           if(Data_byte_num_left==1 & DIV_CNT==2 & PHA==1)begin
                pulse_rst <= 1;
            end
            
            FF <= 0;
        end
    endcase
end
endtask


task t_send_one_byte__auto;
begin
    case(Sub_state)
        shift_out_0:begin 
            Shift_out_8 <= Shift_out_8; 
            Sub_state  <= shift_out_1;
        end
        shift_out_1:begin 
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_2;
        end
        shift_out_2:begin
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_3;
        end
        shift_out_3:begin
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_4;
        end
        shift_out_4:begin
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_5;
            
            if(Data_byte_num_left==1)begin
                if(Round_num_left<2)begin
                    read_pulse <= 0;
                end
                else begin
                    read_pulse <= 1;
                end
            end
            
        end
        shift_out_5:begin
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_6;
            
            if(Data_byte_num_left==1)begin
                read_pulse <= 0;
            end
            
        end
        shift_out_6:begin
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_7;
            
            if(Data_byte_num_left==1)begin
                Pdata_i <= PDATA_I;//加载新的数据
            end
            
        end
        shift_out_7:begin
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_8;

            if(Data_byte_num_left==1)begin
                if(Round_num_left==1)begin
                    Round_num_left     <= 0;
                    Data_byte_num_left <= 0;
                end
                else begin
                    Round_num_left     <= Round_num_left - 1;
                    Data_byte_num_left <= Data_byte_num_i;
                end  
            end
            else Data_byte_num_left <= Data_byte_num_left - 1;
            
            if(Round_num_left==1 & Data_byte_num_left==1 & DIV_CNT==2 & PHA==1)begin
                pulse_rst <= 1;
            end
            FF <= 0;
        end
    endcase
end
endtask


task t_send_one_byte__outer;
begin
    case(Sub_state)
        shift_out_0:begin 
            Shift_out_8 <= Shift_out_8; 
            Sub_state  <= shift_out_1;
        end
        shift_out_1:begin 
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_2;
            
            if(Data_byte_num_left==1)begin
                ALMOST_PULSE_O <= 1;
            end
        end
        shift_out_2:begin
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_3;
            
            if(Data_byte_num_left==1)begin
                ALMOST_PULSE_O <= 0;
            end
        end
        shift_out_3:begin
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_4;
        end
        shift_out_4:begin
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_5;
        end
        shift_out_5:begin
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_6;
        end
        shift_out_6:begin
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_7;
        end
        shift_out_7:begin
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_8;
            Data_byte_num_left <= Data_byte_num_left - 1;
            
            if(Data_byte_num_left ==1)begin
                if(Need_continue == 1)begin
                    Need_continue_reset  <= 1;
                    Pdata_i            <= Pdata_i_2;      //加载下一个周期的数据
                    Data_byte_num_i    <= Data_byte_num_i_2;
                    Data_byte_num_left <= Data_byte_num_i_2;
                end
                else begin
                    Need_stop <= 1;
                end
            end
            
            //补丁 2022年8月19日09:07:20 针对2分频
            if(Need_continue==0 & Data_byte_num_left==1 & DIV_CNT==2 & PHA==1)begin
                pulse_rst <= 1;
            end
            
            FF <= 0;
        end
    endcase
end
endtask


task t_reset;
begin
    Cs                 <= 1;
    Shift_out_8        <= 0;
    State              <= 0;
    Sub_state          <= 0;
    FF                 <= 0;
    Pdata_i            <= {(MAX_BYTE_NUM*8){1'b0}};
    Busy               <= 0;
    Cmd_i              <= 0;
    Data_byte_num_i    <= 0;
    Round_num_i        <= 0;    
    Data_byte_num_left <= 0;
    Round_num_left     <= 0;
    read_pulse         <= 0;
    Need_stop          <= 0;
    ALMOST_PULSE_O     <= 0; 
    pulse_rst          <= 1;
    Need_continue_reset <= 0;
    Cnt_delay          <= 0;
end
endtask


function [7:0] f_Data2W;//无符号数宽度//输入为无符号数最大值
input [31:0] Data;//*****************input: 1  ~  2**32-1*********************//
begin
    if(Data>=2**0  && Data<=2**1-1 ) f_Data2W=1;      //1~1
    if(Data>=2**1  && Data<=2**2-1 ) f_Data2W=2;      //2~3
    if(Data>=2**2  && Data<=2**3-1 ) f_Data2W=3;      //4~7
    if(Data>=2**3  && Data<=2**4-1 ) f_Data2W=4;      //8~15
    if(Data>=2**4  && Data<=2**5-1 ) f_Data2W=5;      //16~31
    if(Data>=2**5  && Data<=2**6-1 ) f_Data2W=6;      //32~63
    if(Data>=2**6  && Data<=2**7-1 ) f_Data2W=7;      //64~127
    if(Data>=2**7  && Data<=2**8-1 ) f_Data2W=8;      //128~255
    if(Data>=2**8  && Data<=2**9-1 ) f_Data2W=9;      //256~511
    if(Data>=2**9  && Data<=2**10-1) f_Data2W=10;     //512~1023
    if(Data>=2**10 && Data<=2**11-1) f_Data2W=11;     //1024~2047
	if(Data>=2**11 && Data<=2**12-1) f_Data2W=12;     //2048~4095
	if(Data>=2**12 && Data<=2**13-1) f_Data2W=13;     //4096~8191
	if(Data>=2**13 && Data<=2**14-1) f_Data2W=14;     //8192~16383
	if(Data>=2**14 && Data<=2**15-1) f_Data2W=15;     //16384~32767
	if(Data>=2**15 && Data<=2**16-1) f_Data2W=16;     //32768~65535
	if(Data>=2**16 && Data<=2**17-1) f_Data2W=17;     //65536~131071
	if(Data>=2**17 && Data<=2**18-1) f_Data2W=18;     //131072~262143
	if(Data>=2**18 && Data<=2**19-1) f_Data2W=19;     //262144~524287
	if(Data>=2**19 && Data<=2**20-1) f_Data2W=20;     //524288~1048575
	if(Data>=2**20 && Data<=2**21-1) f_Data2W=21;     //1048576~2097151
	if(Data>=2**21 && Data<=2**22-1) f_Data2W=22;     //2097152~‭4194303‬
	if(Data>=2**22 && Data<=2**23-1) f_Data2W=23;     //‭4194304‬~‬8388607
	if(Data>=2**23 && Data<=2**24-1) f_Data2W=24;     //‬8388608~16777215
	if(Data>=2**24 && Data<=2**25-1) f_Data2W=25;     //16777216~33554431
	if(Data>=2**25 && Data<=2**26-1) f_Data2W=26;     //33554432~67108863
	if(Data>=2**26 && Data<=2**27-1) f_Data2W=27;     //67108864~134217727
	if(Data>=2**27 && Data<=2**28-1) f_Data2W=28;     //134217728~268435455
	if(Data>=2**28 && Data<=2**29-1) f_Data2W=29;     //268435456~536870911
	if(Data>=2**29 && Data<=2**30-1) f_Data2W=30;     //536870912~1073741823
	if(Data>=2**30 && Data<=2**31-1) f_Data2W=31;     //1073741824~2147483647
	if(Data>=2**31 && Data<=2**32-1) f_Data2W=32;     //2147483648~4294967295
end
endfunction


endmodule




`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////////////
//first delay --- high --- low --- high ....
module pulse_rst_loop_fhsl__divtri(
RST_I,//强制归0
CLK_I,
PULSE_O,
FIRST_DELAY_CLK_NUM_I,
HIGH_CLK_NUM_I,
TOTAL_CLK_NUM_I
);
/////////////////////////////////////////////////////////////////////////////////////////
input RST_I;
input CLK_I;
output reg PULSE_O = 0;
input [9:0] FIRST_DELAY_CLK_NUM_I;
input [9:0] HIGH_CLK_NUM_I;
input [9:0] TOTAL_CLK_NUM_I;

/////////////////////////////////////////////////////////////////////////////////////////
reg [9:0] First_delay_clk_num_i;
reg [9:0] High_clk_num_i;
reg [9:0] Total_clk_num_i;
reg [7:0] State = 1;
reg [31:0] Cnt_clk_num ;

always@(posedge CLK_I)begin
    if(RST_I)begin 
        PULSE_O <= 0;
        First_delay_clk_num_i <= FIRST_DELAY_CLK_NUM_I;
        Cnt_clk_num <= FIRST_DELAY_CLK_NUM_I -1;
        High_clk_num_i        <= HIGH_CLK_NUM_I; 
        Total_clk_num_i       <= TOTAL_CLK_NUM_I; 
		State <= 0;
    end
    else begin
        case(State)
            0:begin//first delay
                if( Cnt_clk_num > 0)Cnt_clk_num <= Cnt_clk_num - 1;
                else begin
                    Cnt_clk_num <= High_clk_num_i - 1;
                    PULSE_O <= 1;
                    State <= 1;
                end
            end
            1:begin//high
                if( Cnt_clk_num > 0)Cnt_clk_num <= Cnt_clk_num - 1;
                else begin
                    Cnt_clk_num <= Total_clk_num_i - High_clk_num_i - 1;
                    PULSE_O <= 0;
                    State <= 2;
                end
            end
            2:begin//low
                if( Cnt_clk_num > 0)Cnt_clk_num <= Cnt_clk_num - 1;
                else begin
                    Cnt_clk_num <= High_clk_num_i - 1;
                    PULSE_O <= 1;
                    State   <= 1;
                end
            end
            default:begin
                PULSE_O <= 0;
                First_delay_clk_num_i <= FIRST_DELAY_CLK_NUM_I;
                Cnt_clk_num <= FIRST_DELAY_CLK_NUM_I -1;
                High_clk_num_i        <= HIGH_CLK_NUM_I; 
                Total_clk_num_i       <= TOTAL_CLK_NUM_I; 
                State <= 0;     
            end
        endcase
    end    
end
endmodule


