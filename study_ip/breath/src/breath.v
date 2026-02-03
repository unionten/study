`timescale 1ns / 1ps
`define TIMER_OUTGEN(clk,rst,sec_pulse_out,breath_out,CLK_PRD_NS,PULSE_WIDTH)                           generate  begin reg [31:0] cname = 0;reg sname = 0;reg bname = 0;always@(posedge clk) if(rst)begin cname<= 0;sname<=0;bname<=0; end else if(cname==(CNT/CLK_PRD_NS-1))begin cname<=0;sname<=1;bname<=~bname;end else begin cname<= cname+1; bname<=(cname==((CNT/2)/CLK_PRD_NS-1))?~bname:bname; sname<=(cname==((PULSE_WIDTH)-1))?0:sname;end  assign sec_pulse_out = sname;assign breath_out = bname; end endgenerate

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/29 13:18:59
// Design Name: 
// Module Name: breath
// Project Name: 
//////////////////////////////////////////////////////////////////////////////////


module breath(
input  CLK_I    ,
input  RSTN_I   ,
output BREATH_O ,
output TIMER_O   

    );
parameter  CLK_PRD_NS         =  10 ;
parameter  TIMER_CYCLE_SEC    = 1;    //选择 几秒 出一个脉冲
parameter  TIMER_PULSE_WIDTH = 100 ;   //脉冲宽度（ 时钟周期）


    
localparam  CNT = TIMER_CYCLE_SEC * 1000000000 ;
    
    
    
wire  sec_pulse_out ;
    
`TIMER_OUTGEN(CLK_I,(~RSTN_I),sec_pulse_out,BREATH_O,CLK_PRD_NS,TIMER_PULSE_WIDTH)
    
    
assign  TIMER_O  =  sec_pulse_out ;
    
    
    
endmodule
