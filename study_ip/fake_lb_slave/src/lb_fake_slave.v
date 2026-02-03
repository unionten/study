`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/20 15:34:55
// Design Name: 
// Module Name: lb_fake_slave
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


module lb_fake_slave(
input   S_LB_CLK,
input   S_LB_RSTN,
input   S_LB_WREQ,
input   [15:0] S_LB_WADDR ,
input   [31:0] S_LB_WDATA ,
input   S_LB_RREQ ,
input   [15:0] S_LB_RADDR ,
output reg  [31:0] S_LB_RDATA = 0,
output reg  S_LB_RFINISH = 0
    );
    
always@(posedge S_LB_CLK)begin
    if(~S_LB_RSTN)begin
        S_LB_RDATA   <= 0;
        S_LB_RFINISH <= 0;
    end
    else begin
        S_LB_RDATA <= S_LB_RDATA;
        S_LB_RFINISH <= S_LB_RFINISH;
        
    end
end    
    
endmodule


