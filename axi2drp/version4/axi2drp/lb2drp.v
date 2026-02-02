`timescale 1ns / 1ps
`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Create Date: 2023/10/09 09:51:53
// Design Name: 
// Module Name: lb2drp
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////
//1 S_LB_WREQ and S_LB_RREQ can not exist at the same time
//2 S_LB_WREQ and S_LB_RREQ must exist when S_LB_BUSY is zero

module lb2drp(
input CLK_I,
input RST_I,

input  [C_ADDR_WIDTH-1:0]     S_LB_WADDR   , 
input  [C_DATA_WIDTH-1:0]     S_LB_WDATA   ,
input             S_LB_WREQ    ,//___|—|_____ check pos inner
input  [C_ADDR_WIDTH-1:0]     S_LB_RADDR   ,
input             S_LB_RREQ    ,//___|—|_____ check pos inner
output reg [C_DATA_WIDTH-1:0] S_LB_RDATA   = 0 ,
output reg        S_LB_RFINISH = 0 ,//___|—|_____
output reg        S_LB_BUSY    = 0 ,//indicate busy of write and read

output reg M_DRPEN = 0 ,//drp读写不能同时发生，所以LB处只有一个状态机
output reg M_DRPWE = 0 ,
output reg [C_ADDR_WIDTH-1:0] M_DRPADDR = 0 ,
input  M_DRPRDY ,
output reg [C_DATA_WIDTH-1:0] M_DRPDI = 0,
input  [C_DATA_WIDTH-1:0] M_DRPDO

);
parameter C_ADDR_WIDTH = 12;
parameter C_DATA_WIDTH = 16;


wire S_LB_WREQ_pos;
wire S_LB_RREQ_pos;
wire wreq_vld;
wire rreq_vld;
reg rreq_flag;
reg [7:0] state;

assign wreq_vld = S_LB_WREQ_pos & ~S_LB_BUSY;
assign rreq_vld = S_LB_RREQ_pos & ~S_LB_BUSY;

`POS_MONITOR_OUTGEN(CLK_I,0,S_LB_WREQ,S_LB_WREQ_pos) 
`POS_MONITOR_OUTGEN(CLK_I,0,S_LB_RREQ,S_LB_RREQ_pos) 

always@(posedge CLK_I)begin
    if(RST_I)begin
        state <= 0;
        S_LB_BUSY <= 0;
        rreq_flag <= 0;
        M_DRPEN <= 0;
        M_DRPWE <= 0;
        M_DRPADDR <= 0;
        M_DRPDI <= 0;
        S_LB_RDATA <= 0;
        S_LB_RFINISH <= 0;
    end 
    else case(state)
        0:begin
            S_LB_RFINISH <= 0;
            if(wreq_vld)begin
                rreq_flag <= 0;
                M_DRPEN   <= 1;
                M_DRPWE   <= 1;
                M_DRPADDR <= S_LB_WADDR;
                M_DRPDI   <= S_LB_WDATA;
                state     <= 1;
                S_LB_BUSY <= 1;
            end
            else if(rreq_vld)begin
                rreq_flag <= 1;
                M_DRPEN   <= 1;
                M_DRPWE   <= 0;
                M_DRPADDR <= S_LB_RADDR;
                //M_DRPDI   <= S_LB_WDATA;
                state     <= 1;
                S_LB_BUSY <= 1; 
            end
        end
        1:begin
            M_DRPEN      <= 0;
            M_DRPWE      <= 0;
            //M_DRPADDR    <= 0; // yzhu keep it stable
            //M_DRPDI      <= 0;
            state        <= M_DRPRDY ? 0 : state;
            S_LB_BUSY    <= M_DRPRDY ? 0 : 1 ;
            S_LB_RDATA   <= M_DRPRDY ? M_DRPDO : S_LB_RDATA ;
            S_LB_RFINISH <= ( M_DRPRDY & rreq_flag ) ? 1 : 0 ;
        end
        default:;
    endcase
end



endmodule



