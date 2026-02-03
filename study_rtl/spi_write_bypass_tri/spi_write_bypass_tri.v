`timescale 1ns / 1ps
//HDGH5F
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Create Date: 2021/09/26 09:07:27     ///////////////////////////////////////////////////////////////////////////////
// Design Name: phiyo                    ///////////////////////////////////////////////////////////////////////////////
// Module Name: spi_write_bypass_tri     ///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//典型例化
//spi_write_bypass_tri  
//    #(.MAX_BYTE_NUM        (100),
//      .CLK_PERIOD_NS       (SPI_CLK_PERIOD_NS),
//      .CSLOW_TO_CLKBEGIN_NS(CSLOW_TO_CLKBEGIN_NS),
//      .CLKEND_TO_CSHIGH_NS (CLKEND_TO_CSHIGH_NS), 
//      .CSHIGH_TO_BUSYLOW_NS(CSHIGH_TO_BUSYLOW_NS))
//    spi_u(  
//    .RST_I          (    ),
//    .CLK_I          (~CLK_I),//注意本处 gghjh
//    .CMD_I          (    ),
//    .START_I        (    ),
//    .PDATA_I        (    ),
//    .DATA_BYTE_NUM_I(    ),
//    .ROUND_NUM_I    (    ),
//    .CS_O           (    ),
//    .SCK_O          (    ),
//    .DO_O           (    ),
//    .BUSY_O         (    ),
//    .READ_PULSE_O   (    ),
//    .ALMOST_PULSE_O (    )); 


//只支持 ： POL = 0 ; PHA = 0 ;
module spi_write_bypass_tri
#(
parameter MAX_BYTE_NUM         = 100 ,//10:500LUT   50:1000LUT
parameter CLK_PERIOD_NS        = 100 ,
parameter CSLOW_TO_CLKBEGIN_NS = 2000,//>=0,程序内含最低量,至少为1~2周期
parameter CLKEND_TO_CSHIGH_NS  = 2000,//>=0,程序内含最低量,至少为1~2周期
parameter CSHIGH_TO_BUSYLOW_NS = 2000 //>=0,程序内含最低量,至少为1~2周期
)
(  //【下沿发】
input                       RST_I           ,
input                       CLK_I           ,//【内部下沿操作】bypass  negedge
input  [2:0]                CMD_I           ,//3'd0:单次写;3'd1:自动连续写;3'd2:外部连续写
input                       START_I         ,//at CLK_I posedge
input  [MAX_BYTE_NUM*8-1:0] PDATA_I         ,//at CLK_I posedge 先发高位字节，后发低位字节，高位补0
input  [7:0]                DATA_BYTE_NUM_I ,//at CLK_I posedge 外部连续写时，该值每轮都有效
input  [15:0]               ROUND_NUM_I     ,//at CLK_I posedge 
output                      CS_O            ,//at CLK_I negedge ; 
output                      SCK_O           ,//as (CLK_I & Clk_en)
output                      DO_O            ,//at CLK_I negedge ; format =  POL = 0 ; PHA = 0 ;
output                      BUSY_O          ,//at CLK_I negedge ;
output  reg                 READ_PULSE_O    ,//at CLK_I negedge ;
output  reg                 ALMOST_PULSE_O   //at CLK_I negedge ; 
);
////////////////////////////////////////////////////////////////////////////////
localparam CSLOW_TO_CLKBEGIN_PERIOD_NUM = CSLOW_TO_CLKBEGIN_NS / CLK_PERIOD_NS;
localparam CLKEND_TO_CSHIGH_PERIOD_NUM  = CLKEND_TO_CSHIGH_NS  / CLK_PERIOD_NS;
localparam CSHIGH_TO_BUSYLOW_PERIOD_NUM = CSHIGH_TO_BUSYLOW_NS / CLK_PERIOD_NS;
////////////////////////////////////////////////////////////////////////////////
`define SINGLE_TO_BI_Nm1To0(a,b,in,out)   generate for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
genvar i,j,k;
wire [7:0] ms_byte;//the MSByte of Pdata_i 
wire [7:0] pdata_m [0:MAX_BYTE_NUM-1];
wire [f_Data2W(MAX_BYTE_NUM)-1:0] INDEX ;
reg [2:0] Cmd_i = 0;
reg [MAX_BYTE_NUM*8-1:0] Pdata_i = 0;
reg [MAX_BYTE_NUM*8-1:0] Pdata_i_2 = 0;
reg [7:0]  Data_byte_num_i = 0;reg [7:0]  Data_byte_num_left = 0;
reg [15:0] Round_num_i = 0;    reg [15:0] Round_num_left = 0;
reg [7:0]  Data_byte_num_i_2 = 0;
reg [7:0]  Shift_out_8 = 0;
(*mark_debug="true"*)reg [7:0]  State = 0;
reg [7:0]  Sub_state = 0;
reg Cs = 1;
reg FF = 0;
reg Busy = 0;
reg [15:0]  Cnt_delay = 0;
reg Need_continue = 0;
reg Need_continue_reset = 0;
reg Need_stop = 0;
wire start_pos;
reg  start_buf1 = 0;
reg  start_buf2 = 0;
reg Clk_en = 0;
wire sck;
////////////////////////////////////////////////////////////////////////////////
assign CS_O   = Cs;
assign SCK_O  = sck;
assign DO_O   = Shift_out_8[7];
assign BUSY_O = START_I | Busy;
////////////////////////////////////////////////////////////////////////////////
//_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_
// START  _|¯¯¯|_______________________________
// CLK_EN _____|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
// ________________|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_
BUFGCE BUFGCE_u(
    .CE(Clk_en),
    .I(CLK_I), 
    .O(sck));
//////////////////////////////////////////////////////////////////////////////////
`SINGLE_TO_BI_Nm1To0(8,MAX_BYTE_NUM,Pdata_i,pdata_m)
assign INDEX  = ((Data_byte_num_i-1) > MAX_BYTE_NUM-1) ? 0: (Data_byte_num_i-1) ;
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
    else if(START_I & State!=0)begin
        Need_continue  <= 1;
        Pdata_i_2      <= PDATA_I;
        Data_byte_num_i_2 <= DATA_BYTE_NUM_I;
    end
    else if(Need_continue_reset)begin
        Need_continue <= 0;
    end
end
///////////////////////////////////////////////////////////////////////////////
always@(negedge CLK_I)begin
    if(RST_I)begin
        t_reset;
    end
    else begin
        case(State)
            0:begin
                if(START_I)begin
                    Cmd_i           <= CMD_I;
                    Pdata_i         <= PDATA_I;
                    Data_byte_num_i <= DATA_BYTE_NUM_I;
                    Round_num_i     <= ROUND_NUM_I;
                    Cs              <= 0;
                    Cnt_delay       <= CSLOW_TO_CLKBEGIN_PERIOD_NUM;
                    Busy            <= 1;
                    State           <= 1;
                end
            end
            1:begin
                if(Cnt_delay==0)begin
                    case(Cmd_i)
                        3'd0:begin//single write
                            State <= 2;
                        end
                        3'd1:begin//auto con write
                            State <= 3;
                        end
                        3'd2:begin//outer con write
                            State <= 4;
                        end
                        default:begin
                            t_reset;
                        end
                    endcase
                end
                else begin
                    Cnt_delay <= Cnt_delay - 1;
                end
            end
            2:begin//single write - start
                Data_byte_num_left <= Data_byte_num_i;
                Clk_en      <= 1;
                Shift_out_8 <= ms_byte;
                Pdata_i     <= Pdata_i << 8;
                Sub_state   <= shift_out_1;
                FF          <= 1;
                State       <= 10;
            end
            3:begin//auto con write - start
                READ_PULSE_O <= 1;
                Data_byte_num_left <= Data_byte_num_i;
                Round_num_left <= Round_num_i;
                State <= 11;
            end
            4:begin//outer con write - start
                Data_byte_num_left <= Data_byte_num_i;
                Clk_en      <= 1;
                Shift_out_8 <= ms_byte;
                Pdata_i     <= Pdata_i << 8;
                Sub_state   <= shift_out_1;
                FF          <= 1;
                State       <= 15;
            end
            /////////////////////////////////////////////////////////
            /////////////////////////////////////////////////////////
            10:begin//single write - process
                if(FF)t_send_one_byte;
                else begin
                    if(Data_byte_num_left==0)begin//OVER
                        Clk_en <= 0;
                        Shift_out_8 <= 0;
                        Cnt_delay <= CLKEND_TO_CSHIGH_PERIOD_NUM;
                        State  <= 30; //DATA OVER
                    end
                    else begin
                        Shift_out_8   <= ms_byte;
                        Pdata_i       <= Pdata_i<<8;
                        FF            <= 1;
                        Sub_state     <= shift_out_1;
                        State         <= 10;
                    end
                end
            end
            /////////////////////////////////////////////////////////
            11:begin//auto con write - process
                READ_PULSE_O <= 0;
                State <= 12;
            end
            12:begin
                Pdata_i <= PDATA_I;
                State <= 13;
            end
            13:begin
                Clk_en      <= 1;
                Shift_out_8 <= ms_byte;
                Pdata_i     <= Pdata_i << 8;
                Sub_state   <= shift_out_1;
                FF          <= 1;
                State       <= 14;
            end
            14:begin
                if(FF)t_send_one_byte__auto;
                else begin
                    if(Round_num_left==0)begin
                        Shift_out_8 <= 0;
                        Clk_en <= 0;
                        Cnt_delay <= CLKEND_TO_CSHIGH_PERIOD_NUM;
                        State  <= 30; //DATA OVER
                    end
                    else begin
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
            15:begin//outer con write - process
                if(FF)t_send_one_byte__outer;
                else begin
                    Need_continue_reset  <= 0; 
                    if(Need_stop==1)begin
                        Clk_en    <= 0;
                        Need_stop <= 0;
                        Cnt_delay <= CLKEND_TO_CSHIGH_PERIOD_NUM;
                        State     <= 30; //DATA OVER
                    end
                    else begin
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
                Shift_out_8 <= 0;
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
///////////////////////////////////////////////////////////////////////////////
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
            FF <= 0;
        end
    endcase
end
endtask
///////////////////////////////////////////////////////////////////////////////
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
                    READ_PULSE_O <= 0;
                end
                else begin
                    READ_PULSE_O <= 1;
                end
            end
            
        end
        shift_out_5:begin
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_6;
            
            if(Data_byte_num_left==1)begin
                READ_PULSE_O <= 0;
            end
            
        end
        shift_out_6:begin
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_7;
            
            if(Data_byte_num_left==1)begin
                Pdata_i <= PDATA_I;
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
            FF <= 0;
        end
    endcase
end
endtask
///////////////////////////////////////////////////////////////////////////////
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
            
        end
        shift_out_2:begin
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_3;
            
            

        end
        shift_out_3:begin
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_4;
            
            if(Data_byte_num_left==1)ALMOST_PULSE_O <= 1;
            
        end
        shift_out_4:begin
            Shift_out_8 <= {Shift_out_8[6:0],1'b0}; 
            Sub_state   <= shift_out_5;
            
            if(Data_byte_num_left==1)ALMOST_PULSE_O <= 0;
            
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
                    Pdata_i            <= Pdata_i_2;//next period 
                    Data_byte_num_i    <= Data_byte_num_i_2;
                    Data_byte_num_left <= Data_byte_num_i_2;
                end
                else begin
                    Need_stop <= 1;
                end
            end
            FF <= 0;
        end
    endcase
end
endtask
///////////////////////////////////////////////////////////////////////////////
task t_reset;
begin
    Cs      <= 1;
    Shift_out_8 <= 0;
    State   <= 0;
    Sub_state <= 0;
    FF      <= 0;
    Pdata_i <= {(MAX_BYTE_NUM*8){1'b0}};
    Clk_en  <= 0;
    Busy    <=0;
    Cmd_i <= 0;
    Data_byte_num_i <= 0;
    Round_num_i <= 0;    
    Data_byte_num_left <= 0;
    Round_num_left <= 0;
    READ_PULSE_O <= 0;
    Need_stop <= 0;
    ALMOST_PULSE_O <= 0; 
end
endtask
///////////////////////////////////////////////////////////////////////////////
function [7:0] f_Data2W;
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

