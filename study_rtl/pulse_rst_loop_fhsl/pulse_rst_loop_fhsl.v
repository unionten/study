`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////////////
//first delay --- high --- low --- high ....
module pulse_rst_loop_fhsl(
RST_I,//强制归0
CLK_I,
PULSE_O
);
parameter CLK_PERIOD_TIME  = 50;//ns
parameter FIRST_DELAY_TIME = 50;//ns;>=0;复位释放后第一个clk->进入LOW的时间;整除时精确
parameter HIGH_TIME  = 50; //ns;<=4294967295;整除时精确
parameter TOTAL_TIME = 100;//ns;<=4294967295(约<=4.2s);整除时精确
//FLOOR(TOTAL_TIME/CLK_PERIOD_TIME)>FLOOR(HIGH_TIME/CLK_PERIOD_TIME)>=1
/////////////////////////////////////////////////////////////////////////////////////////
localparam MAX_CLK_NUM = f_MaxNum(f_MaxNum(FIRST_DELAY_TIME/CLK_PERIOD_TIME,HIGH_TIME/CLK_PERIOD_TIME),(TOTAL_TIME - HIGH_TIME)/CLK_PERIOD_TIME);
/////////////////////////////////////////////////////////////////////////////////////////
input RST_I;
input CLK_I;
output reg PULSE_O = 0;
/////////////////////////////////////////////////////////////////////////////////////////
reg [2:0] state = 0;
reg [f_Data2W(MAX_CLK_NUM):0] Cnt_clk_num = FIRST_DELAY_TIME/CLK_PERIOD_TIME;
always@(posedge CLK_I)begin
    if(RST_I)begin
		if(FIRST_DELAY_TIME==0)begin
			Cnt_clk_num <= HIGH_TIME/CLK_PERIOD_TIME;// changed 
			PULSE_O <= 0;
			state <= 1;
		end
		else begin
			Cnt_clk_num <= FIRST_DELAY_TIME/CLK_PERIOD_TIME;// changed 
			PULSE_O <= 0;
			state <= 0;
		end
    end
    else begin
        case(state)
            0:begin//first delay
                if( Cnt_clk_num > 0)Cnt_clk_num <= Cnt_clk_num - 1;
                else begin
                    Cnt_clk_num <= HIGH_TIME/CLK_PERIOD_TIME - 1;
                    PULSE_O <= 1;
                    state <= 1;
                end
            end
            1:begin//high
                if( Cnt_clk_num > 0)begin 
                    PULSE_O <= 1;
                    Cnt_clk_num <= Cnt_clk_num - 1;
                end
                else begin
                    Cnt_clk_num <= (TOTAL_TIME - HIGH_TIME)/CLK_PERIOD_TIME - 1;
                    PULSE_O <= 0;
                    state <= 2;
                end
            end
            2:begin//low
                if( Cnt_clk_num > 0)Cnt_clk_num <= Cnt_clk_num - 1;
                else begin
                    Cnt_clk_num <= HIGH_TIME/CLK_PERIOD_TIME - 1;
                    PULSE_O <= 1;
                    state <= 1;
                end
            end
            default:begin
                Cnt_clk_num <= FIRST_DELAY_TIME/CLK_PERIOD_TIME;
                PULSE_O <= 0;
                state <= 0;        
            end
        endcase
    end    
end


function [7:0] f_Data2W;
input [31:0] Data;
begin
    if(Data>=   0  && Data<=2**1-1 ) f_Data2W=1;      //1~1
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


function unsigned [31:0] f_MaxNum;
input unsigned [31:0] A;
input unsigned [31:0] B;
begin
    f_MaxNum = (A>=B)?A:B;
end
endfunction



function signed [31:0] f_MaxNum_S;
input signed [31:0] A;
input signed [31:0] B;
begin
    f_MaxNum_S = (A>=B)?A:B;
end
endfunction
endmodule
