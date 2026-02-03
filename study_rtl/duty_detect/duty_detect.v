`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/07 13:41:09
// Design Name: 
// Module Name: duty_detect
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define NEG_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate


module duty_detect(
input  CLK_I,
input  RST_I,
input  TAC_I,
output reg [31:0] HIGH_CLK_NUM_O, //only updata at pos or neg
output reg [31:0] LOW_CLK_NUM_O   //only updata at pos or neg

 );

reg [31:0] high_clk_cnt;
reg [31:0] low_clk_cnt;

wire TAC_I_pos;
wire TAC_I_neg;


`POS_MONITOR_OUTGEN(CLK_I,RST_I,TAC_I,TAC_I_pos)  
`NEG_MONITOR_OUTGEN(CLK_I,RST_I,TAC_I,TAC_I_neg) 
    
    
always@(posedge CLK_I)begin
    if(RST_I )begin
        high_clk_cnt   <= 0;
        HIGH_CLK_NUM_O <= 0;
    end
    else if(TAC_I_neg)begin
        HIGH_CLK_NUM_O <= high_clk_cnt;
        high_clk_cnt   <= 0;
    end
    else if(TAC_I)begin
        high_clk_cnt <= high_clk_cnt + 1;
    end
end


always@(posedge CLK_I)begin
    if(RST_I )begin
        low_clk_cnt   <= 0;
        LOW_CLK_NUM_O <= 0;
    end
    else if(TAC_I_pos)begin
        LOW_CLK_NUM_O <= low_clk_cnt;
        low_clk_cnt   <= 0;
    end
    else if(~TAC_I)begin
        low_clk_cnt <= low_clk_cnt + 1;
    end
end
    
    
    
    
    
    
    
endmodule
