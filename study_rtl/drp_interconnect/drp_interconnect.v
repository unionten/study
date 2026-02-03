`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/02 14:19:13
// Design Name: 
// Module Name: drp_interconnect
// Project Name: 
//////////////////////////////////////////////////////////////////////////////////

module drp_interconnect(
input                    DRP_CLK     ,
input                    DRP_RESETN  ,

input                      S_DRPEN_0   ,
input                      S_DRPWE_0   ,
input   [C_ADDR_WIDTH-1:0] S_DRPADDR_0 ,
output                     S_DRPRDY_0  ,
input  [C_DATA_WIDTH-1:0]  S_DRPDI_0   ,
output  [C_DATA_WIDTH-1:0] S_DRPDO_0   ,
input                      S_DRPEN_1   ,
input                      S_DRPWE_1   ,
input [C_ADDR_WIDTH-1:0]   S_DRPADDR_1 ,
output                     S_DRPRDY_1  ,
input [C_DATA_WIDTH-1:0]   S_DRPDI_1   ,
output  [C_DATA_WIDTH-1:0] S_DRPDO_1   ,
input                      S_DRPEN_2   ,
input                      S_DRPWE_2   ,
input [C_ADDR_WIDTH-1:0]   S_DRPADDR_2 ,
output                     S_DRPRDY_2  ,
input [C_DATA_WIDTH-1:0]   S_DRPDI_2   ,
output  [C_DATA_WIDTH-1:0] S_DRPDO_2   ,


output                    M_DRPEN   ,
output                    M_DRPWE   ,
output [C_ADDR_WIDTH-1:0] M_DRPADDR ,
input                     M_DRPRDY  ,
input  [C_DATA_WIDTH-1:0] M_DRPDI   , //note : the direction is as name
output  [C_DATA_WIDTH-1:0] M_DRPDO   

);

parameter  C_ADDR_WIDTH =  12;
parameter  C_DATA_WIDTH =  16;

genvar i,j,k;

reg [7:0] ii,jj,kk;

reg [7:0] state_m = 0;//control sel_m state
reg [1:0] sel_m = 0;//select whitch SI to connect to MI 

reg                      S_DRPEN_buf[3-1:0]   ;
reg                      S_DRPWE_buf[3-1:0]   ;
reg   [C_ADDR_WIDTH-1:0] S_DRPADDR_buf[3-1:0] ;
reg   [C_DATA_WIDTH-1:0] S_DRPDI_buf[3-1:0]   ;

reg                      S_DRPEN_buf_o[3-1:0]   ;// 注意两边都有
reg                      S_DRPWE_buf_o[3-1:0]   ;
reg   [C_ADDR_WIDTH-1:0] S_DRPADDR_buf_o[3-1:0] ;
reg   [C_DATA_WIDTH-1:0] S_DRPDI_buf_o[3-1:0]   ;

reg                      si_flag[3-1:0]          ;//哪路有请求(同时来时,ch0优先级高)
reg                      si_fetch[3-1:0]         ;



always@(posedge DRP_CLK)begin
    if(~DRP_RESETN)begin
        S_DRPEN_buf[0]   <=  0;
        S_DRPWE_buf[0]   <=  0;
        S_DRPADDR_buf[0] <=  0;
        S_DRPDI_buf[0]   <=  0;
        si_flag[0]       <=  0;
    end
    else begin 
        S_DRPEN_buf[0]   <=  S_DRPEN_0 ? S_DRPEN_0   : si_fetch[0] ? 0 : S_DRPEN_buf[0];
        S_DRPWE_buf[0]   <=  S_DRPEN_0 ? S_DRPWE_0   : si_fetch[0] ? 0 : S_DRPWE_buf[0];
        S_DRPADDR_buf[0] <=  S_DRPEN_0 ? S_DRPADDR_0 : si_fetch[0] ? 0 : S_DRPADDR_buf[0];
        S_DRPDI_buf[0]   <=  S_DRPEN_0 ? S_DRPDI_0   : si_fetch[0] ? 0 : S_DRPDI_buf[0];
        si_flag[0]       <=  si_fetch[0] ? 0 : S_DRPEN_buf[0] ? 1 : si_flag[0];
    end
end


always@(posedge DRP_CLK)begin
    if(~DRP_RESETN)begin
        S_DRPEN_buf[1]   <=  0;
        S_DRPWE_buf[1]   <=  0;
        S_DRPADDR_buf[1] <=  0;
        S_DRPDI_buf[1]   <=  0;
        si_flag[1]       <=  0;
    end
    else begin //note: 上位机时序需要自己控制
        S_DRPEN_buf[1]   <=  S_DRPEN_1 ? S_DRPEN_1   : si_fetch[1] ? 0 : S_DRPEN_buf[1];
        S_DRPWE_buf[1]   <=  S_DRPEN_1 ? S_DRPWE_1   : si_fetch[1] ? 0 : S_DRPWE_buf[1];
        S_DRPADDR_buf[1] <=  S_DRPEN_1 ? S_DRPADDR_1 : si_fetch[1] ? 0 : S_DRPADDR_buf[1];
        S_DRPDI_buf[1]   <=  S_DRPEN_1 ? S_DRPDI_1   : si_fetch[1] ? 0 : S_DRPDI_buf[1];
        si_flag[1]       <=  si_fetch[1] ? 0 : S_DRPEN_buf[1] ? 1 : si_flag[1];
    end
end


always@(posedge DRP_CLK)begin
    if(~DRP_RESETN)begin
        S_DRPEN_buf[2]   <=  0;
        S_DRPWE_buf[2]   <=  0;
        S_DRPADDR_buf[2] <=  0;
        S_DRPDI_buf[2]   <=  0;
        si_flag[2]       <=  0;
    end
    else begin //note: 上位机时序需要自己控制
        S_DRPEN_buf[2]   <=  S_DRPEN_2 ? S_DRPEN_2    : si_fetch[2] ? 0 : S_DRPEN_buf[2];
        S_DRPWE_buf[2]   <=  S_DRPEN_2 ? S_DRPWE_2    : si_fetch[2] ? 0 : S_DRPWE_buf[2];
        S_DRPADDR_buf[2] <=  S_DRPEN_2 ? S_DRPADDR_2  : si_fetch[2] ? 0 : S_DRPADDR_buf[2];
        S_DRPDI_buf[2]   <=  S_DRPEN_2 ? S_DRPDI_2    : si_fetch[2] ? 0 : S_DRPDI_buf[2];
        si_flag[2]       <=  si_fetch[2] ? 0 : S_DRPEN_buf[2] ? 1 : si_flag[2];
    end
end


 
always@(posedge DRP_CLK)begin
    if(~DRP_RESETN)begin
        sel_m   <= 0;
        state_m <= 0;
        for(ii=0;ii<3;ii=ii+1)begin
            si_fetch[ii]<=0;
            S_DRPEN_buf_o[ii]<=0;
            S_DRPWE_buf_o[ii]<=0;
            S_DRPADDR_buf_o[ii]<=0;
            S_DRPDI_buf_o[ii]<=0;
        end
    end
    else begin
        case(state_m)
            0: begin
                if(si_flag[0])     begin sel_m <=0;  state_m <= 1; end
                else if(si_flag[1])begin sel_m <=1;  state_m <= 2; end
                else if(si_flag[2])begin sel_m <=2;  state_m <= 3; end  
            end
            1: begin
                si_fetch[0]        <= 1;
                S_DRPEN_buf_o[0]   <= S_DRPEN_buf[0]   ;
                S_DRPWE_buf_o[0]   <= S_DRPWE_buf[0]   ;
                S_DRPADDR_buf_o[0] <= S_DRPADDR_buf[0] ;
                S_DRPDI_buf_o[0]   <= S_DRPDI_buf[0]   ;
                state_m            <= 4;
            end
            2:begin
                si_fetch[1]        <= 1;
                S_DRPEN_buf_o[1]   <= S_DRPEN_buf[1]   ;
                S_DRPWE_buf_o[1]   <= S_DRPWE_buf[1]   ;
                S_DRPADDR_buf_o[1] <= S_DRPADDR_buf[1] ;
                S_DRPDI_buf_o[1]   <= S_DRPDI_buf[1]   ;
                state_m            <= 5;
            end
            3:begin
                si_fetch[2]        <= 1;
                S_DRPEN_buf_o[2]   <= S_DRPEN_buf[2]   ;
                S_DRPWE_buf_o[2]   <= S_DRPWE_buf[2]   ;
                S_DRPADDR_buf_o[2] <= S_DRPADDR_buf[2] ;
                S_DRPDI_buf_o[2]   <= S_DRPDI_buf[2]   ;
                state_m            <= 6;
            end
            ///////////////////////////////////////////////////
            4: begin
                si_fetch[0]        <= 0;
                S_DRPEN_buf_o[0]   <= 0 ;
                S_DRPWE_buf_o[0]   <= 0 ;
                S_DRPADDR_buf_o[0] <= 0 ;
                S_DRPDI_buf_o[0]   <= 0 ;
                state_m            <= M_DRPRDY ? 0 : state_m;
            end
            5: begin
                si_fetch[1]        <= 0;
                S_DRPEN_buf_o[1]   <= 0 ;
                S_DRPWE_buf_o[1]   <= 0 ;
                S_DRPADDR_buf_o[1] <= 0 ;
                S_DRPDI_buf_o[1]   <= 0 ;
                state_m            <= M_DRPRDY ? 0 : state_m;
            end
            6: begin
                si_fetch[2]        <= 0;
                S_DRPEN_buf_o[2]   <= 0 ;
                S_DRPWE_buf_o[2]   <= 0 ;
                S_DRPADDR_buf_o[2] <= 0 ;
                S_DRPDI_buf_o[2]   <= 0 ;
                state_m            <= M_DRPRDY ? 0 : state_m;
            end

            default:begin
                sel_m   <= 0;
                state_m <= 0;
                for(ii=0;ii<3;ii=ii+1)begin
                    si_fetch[ii]<=0;
                    S_DRPEN_buf_o[ii]<=0;
                    S_DRPWE_buf_o[ii]<=0;
                    S_DRPADDR_buf_o[ii]<=0;
                    S_DRPDI_buf_o[ii]<=0;
                end 
            end
        endcase
    end
end


assign  M_DRPEN   =  sel_m==0 ? S_DRPEN_buf_o[0] : sel_m==1 ? S_DRPEN_buf_o[1] : S_DRPEN_buf_o[2] ;
assign  M_DRPWE   =  sel_m==0 ? S_DRPWE_buf_o[0] : sel_m==1 ? S_DRPWE_buf_o[1] : S_DRPWE_buf_o[2] ;
assign  M_DRPADDR =  sel_m==0 ? S_DRPADDR_buf_o[0] : sel_m==1 ? S_DRPADDR_buf_o[1] : S_DRPADDR_buf_o[2] ;  
assign  M_DRPDO   =  sel_m==0 ? S_DRPDI_buf_o[0] : sel_m==1 ? S_DRPDI_buf_o[1] : S_DRPDI_buf_o[2] ; 


assign  S_DRPRDY_0 = sel_m==0 ? M_DRPRDY : 0;
assign  S_DRPRDY_1 = sel_m==1 ? M_DRPRDY : 0;
assign  S_DRPRDY_2 = sel_m==2 ? M_DRPRDY : 0;

assign  S_DRPDO_0  = sel_m==0 ? M_DRPDI : 0;
assign  S_DRPDO_1  = sel_m==1 ? M_DRPDI : 0;
assign  S_DRPDO_2  = sel_m==2 ? M_DRPDI : 0;



endmodule




