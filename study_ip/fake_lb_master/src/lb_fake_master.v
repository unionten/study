`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/20 15:18:24
// Design Name: 
// Module Name: lb_fake_master
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


module lb_fake_master(
input   M_LB_CLK,
input   M_LB_RSTN,
output  reg M_LB_WREQ = 0,
output  reg [15:0] M_LB_WADDR = 0,
output  reg [31:0] M_LB_WDATA = 0,
output  reg       M_LB_RREQ = 0,
output  reg [15:0] M_LB_RADDR = 0,
input   [31:0] M_LB_RDATA,
input          M_LB_RFINISH

    );


always@(posedge M_LB_CLK)begin
    if(~M_LB_RSTN)begin
        M_LB_WREQ  <= 0;
        M_LB_WADDR <= 0;
        M_LB_WDATA <= 0;
        M_LB_RREQ  <= 0;
        M_LB_RADDR <= 0;
    end
    else begin
        M_LB_WREQ  <= M_LB_WREQ  ;
        M_LB_WADDR <= M_LB_WADDR ;
        M_LB_WDATA <= M_LB_WDATA ;
        M_LB_RREQ  <= M_LB_RREQ  ;
        M_LB_RADDR <= M_LB_RADDR ;
    end
end  
    
endmodule 


