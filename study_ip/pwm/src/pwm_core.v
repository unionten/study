`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2022/09/24 11:59:24
// Design Name: 
// Module Name: pwm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////
module pwm_core(
input  CLK_I,
input  EN_I,//注意，不是触发信号 
input  [11:0] DIV_I,//2~4000  时钟分频值，同时即每个脉冲中的最快时钟周期数
input  [9:0]  DUTY_I,//0~1000 
//内部公式 DUTY_I*DIV_I/100
output PWM_O

);
//VCC = VCC_PRESET * (1/6 + 5/6 * DEFAULT_DUTY)


//每个PWM周期的时钟数
//请保证PWM pin accepts square waveform from 【20K to 100K】.  
//数字越大，调节精度越高

assign PWM_O = pwm;


//stage 1
reg  [11:0]  div_s1;
reg  [9:0]   duty_s1;
reg          en_s1;
always @(posedge CLK_I)begin
    div_s1   <= DIV_I;
    duty_s1  <= DUTY_I;
    en_s1    <= EN_I;
end

//stage 2
reg [21:0]  HIGH_CLK_CYCLE_s2;
reg [11:0]  div_s2; 
reg  [9:0]  duty_s2;
reg         en_s2;
always @(posedge CLK_I) begin 
	HIGH_CLK_CYCLE_s2 <=  duty_s1* div_s1; 
    en_s2 <= en_s1;
    div_s2 <= div_s1;
    duty_s2 <= duty_s1;
end	


//state 3
reg   [11:0]  HIGH_CLK_CYCLE_s3 ;
wire  [11:0]  LOW_CLK_CYCLE_s3 ;
reg  [11:0] div_s3; 
reg  [9:0]  duty_s3;
reg         en_s3;
always @(posedge CLK_I) begin 
	HIGH_CLK_CYCLE_s3 <=  HIGH_CLK_CYCLE_s2 / 1000; 
    en_s3 <= en_s2;
    div_s3 <= div_s2;
    duty_s3 <= duty_s2;
end	
assign LOW_CLK_CYCLE_s3 = div_s3 - HIGH_CLK_CYCLE_s3 ;


/////////////////////////////////////////////////////////////////////////////////////////
reg pwm = 0;
reg [7:0]  state = 0;
reg [11:0] cnt = 0;
always@(posedge CLK_I)begin
    if(en_s3==0 | duty_s3==0)begin
        cnt <= HIGH_CLK_CYCLE_s3;
		pwm  <= 0;
		state  <= 0;
    end
    else if(en_s3==1 & duty_s3>=1000)begin
        cnt <= HIGH_CLK_CYCLE_s3;
        pwm   <= 1;
        state <= 0;
    end
    else begin
        case(state)
            0:begin//high
                if( cnt > 0)begin
                    pwm <= 1;
                    cnt <= cnt - 1;
                end
                else begin
                    cnt <= LOW_CLK_CYCLE_s3 - 1;
                    pwm <= 0;
                    state <= 1;
                end
            end
            1:begin//low
                if( cnt > 0)begin
                    pwm <= 0;
                    cnt <= cnt - 1;
                end
                else begin
                    cnt <= HIGH_CLK_CYCLE_s3 - 1;
                    pwm <= 1;
                    state <= 0;
                end
            end
            default:begin
                cnt <= HIGH_CLK_CYCLE_s3;
                pwm  <= 0;
                state  <= 0;      
            end
        endcase
    end    
end

 
 
 
endmodule
