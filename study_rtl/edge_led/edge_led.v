`timescale 1ns / 1ps
`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/15 16:48:03
// Design Name: 
// Module Name: edge_led
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
//////////////////////////////////////////////////////////////////////////////////


module edge_led(
input CLK_I   ,
input RSTN_I  ,
input POS_I  ,//___|——|_____
output reg FLICKER_O = 0 // 检测到一个上沿时，灯闪烁一下
);

parameter  C_CLK_PRD_NS = 10;
parameter  C_FLICKER_PRD_MS = 200;//一次亮灭的总时间


wire  POS_I_pos ;
`POS_MONITOR_OUTGEN(CLK_I,0,POS_I,POS_I_pos)
    
reg [7:0]  state = 0 ;
reg [31:0] cnt_delay = 0;  
always@(posedge CLK_I)begin
    if(~RSTN_I)begin
        FLICKER_O <= 0;
        state <= 0;
        cnt_delay <= 0;
    end
    else if(POS_I_pos)begin
        state <= 1 ;
        cnt_delay <= 0;
    end
    else begin
        case(state)
            0:begin
                ;
            end
            1:begin
                FLICKER_O <= 1 ;
                cnt_delay <= cnt_delay + 1 ;
                state <= cnt_delay==(C_FLICKER_PRD_MS*1000000/2/C_CLK_PRD_NS) ? 2 : state;
            end
            2:begin
                FLICKER_O <= 0 ;
                cnt_delay <= cnt_delay + 1 ;
                state <= cnt_delay==(C_FLICKER_PRD_MS*1000000/C_CLK_PRD_NS) ? 0 : state;  
            end
            default:;
        endcase
    end
end
    
    
endmodule



