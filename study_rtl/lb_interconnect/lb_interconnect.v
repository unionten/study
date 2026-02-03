`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/06 15:20:47
// Design Name: 
// Module Name: lb_interconnect
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////

//note: 读写独立
module lb_interconnect(
input  LB_CLK_I       ,
input  LB_RSTN_I      ,

input  [C_ADDR_WIDTH-1:0] LB_WADDR_0_I   ,
input  [C_DATA_WIDTH-1:0] LB_WDATA_0_I   ,
input  LB_WREQ_0_I    ,
input  [C_ADDR_WIDTH-1:0] LB_RADDR_0_I   ,
input  LB_RREQ_0_I    ,
output [C_DATA_WIDTH-1:0] LB_RDATA_0_O   ,
output LB_RFINISH_0_O ,

input  [C_ADDR_WIDTH-1:0] LB_WADDR_1_I   ,
input  [C_DATA_WIDTH-1:0] LB_WDATA_1_I   ,
input  LB_WREQ_1_I    ,
input  [C_ADDR_WIDTH-1:0] LB_RADDR_1_I   ,
input  LB_RREQ_1_I    ,
output [C_DATA_WIDTH-1:0] LB_RDATA_1_O   ,
output LB_RFINISH_1_O ,


output  [C_ADDR_WIDTH-1:0] LB_WADDR_O   ,
output  [C_DATA_WIDTH-1:0] LB_WDATA_O   ,
output  LB_WREQ_O    ,
output  [C_ADDR_WIDTH-1:0] LB_RADDR_O   ,
output  LB_RREQ_O    ,
input  [C_DATA_WIDTH-1:0]  LB_RDATA_I   ,
input   LB_RFINISH_I  


);
parameter C_ADDR_WIDTH = 16 ;
parameter C_DATA_WIDTH = 32 ;



////////////////////////////////////////
parameter C_CH_NUM = 2 ;

genvar i,j,k;

reg [7:0] ii,jj,kk;

reg [7:0] state_m_wr = 0;//control sel_m state
reg [1:0] sel_m_wr = 0;//select whitch SI to connect to MI 

reg [7:0] state_m_rd = 0;//control sel_m state
reg [1:0] sel_m_rd = 0;//select whitch SI to connect to MI 

reg   [C_ADDR_WIDTH-1:0] S_WADDR_buf[C_CH_NUM-1:0]   ;
reg  [C_DATA_WIDTH-1:0]  S_WDATA_buf[C_CH_NUM-1:0]   ;
reg                      S_WREQ_buf[C_CH_NUM-1:0] ;
reg   [C_ADDR_WIDTH-1:0] S_RADDR_buf[C_CH_NUM-1:0]   ;
reg                      S_RREQ_buf[C_CH_NUM-1:0]   ;


reg   [C_ADDR_WIDTH-1:0] S_WADDR_buf_o[C_CH_NUM-1:0]   ;
reg  [C_DATA_WIDTH-1:0]  S_WDATA_buf_o[C_CH_NUM-1:0]   ;
reg                      S_WREQ_buf_o[C_CH_NUM-1:0] ;
reg   [C_ADDR_WIDTH-1:0] S_RADDR_buf_o[C_CH_NUM-1:0]   ;
reg                      S_RREQ_buf_o[C_CH_NUM-1:0]   ;

reg     [C_CH_NUM-1:0]  si_flag_wr   = 0       ;//哪路有请求(同时来时,ch0优先级高)
reg     [C_CH_NUM-1:0]  si_fetch_wr  = 0       ;//取走哪路

reg     [C_CH_NUM-1:0]  si_flag_rd   = 0       ;//哪路有请求(同时来时,ch0优先级高)
reg     [C_CH_NUM-1:0]  si_fetch_rd  = 0       ;//取走哪路


//id 0
always@(posedge LB_CLK_I)begin
    if(~LB_RSTN_I)begin
        S_WADDR_buf[0]   <=  0;
        S_WDATA_buf[0]   <=  0;
        S_WREQ_buf[0]    <=  0;
        si_flag_wr[0]    <=  0;
    end
    else begin 
        S_WREQ_buf[0]    <=  LB_WREQ_0_I ? LB_WREQ_0_I    : si_fetch_wr[0] ? 0 : S_WREQ_buf[0];
        S_WADDR_buf[0]   <=  LB_WREQ_0_I ? LB_WADDR_0_I   : si_fetch_wr[0] ? 0 : S_WADDR_buf[0];
        S_WDATA_buf[0]   <=  LB_WREQ_0_I ? LB_WDATA_0_I   : si_fetch_wr[0] ? 0 : S_WDATA_buf[0];
        si_flag_wr[0]    <=  si_fetch_wr[0] ? 0 : S_WREQ_buf[0] ? 1 : si_flag_wr[0];
    end
end

always@(posedge LB_CLK_I)begin
    if(~LB_RSTN_I)begin
        S_RADDR_buf[0]   <=  0;
        S_RREQ_buf[0]    <=  0;
        si_flag_rd[0]    <=  0;
    end
    else begin 
        S_RREQ_buf[0]    <=  LB_RREQ_0_I ? LB_RREQ_0_I    : si_fetch_rd[0] ? 0 : S_RREQ_buf[0];
        S_RADDR_buf[0]   <=  LB_RREQ_0_I ? LB_RADDR_0_I   : si_fetch_rd[0] ? 0 : S_RADDR_buf[0];
        si_flag_rd[0]    <=  si_fetch_rd[0] ? 0 : S_RREQ_buf[0] ? 1 : si_flag_rd[0];
    end
end


//id 1
always@(posedge LB_CLK_I)begin
    if(~LB_RSTN_I)begin
        S_WADDR_buf[1]   <=  0;
        S_WDATA_buf[1]   <=  0;
        S_WREQ_buf[1]    <=  0;
        si_flag_wr[1]    <=  0;
    end
    else begin 
        S_WREQ_buf[1]    <=  LB_WREQ_1_I ? LB_WREQ_1_I    : si_fetch_wr[1] ? 0 : S_WREQ_buf[1];
        S_WADDR_buf[1]   <=  LB_WREQ_1_I ? LB_WADDR_1_I   : si_fetch_wr[1] ? 0 : S_WADDR_buf[1];
        S_WDATA_buf[1]   <=  LB_WREQ_1_I ? LB_WDATA_1_I   : si_fetch_wr[1] ? 0 : S_WDATA_buf[1];
        si_flag_wr[1]    <=  si_fetch_wr[1] ? 0 : S_WREQ_buf[1] ? 1 : si_flag_wr[1];
    end
end


//id  2



always@(posedge LB_CLK_I)begin
    if(~LB_RSTN_I)begin
        S_RADDR_buf[1]   <=  0;
        S_RREQ_buf[1]    <=  0;
        si_flag_rd[1]    <=  0;
    end
    else begin 
        S_RREQ_buf[1]    <=  LB_RREQ_1_I ? LB_RREQ_1_I    : si_fetch_rd[1] ? 0 : S_RREQ_buf[1];
        S_RADDR_buf[1]   <=  LB_RREQ_1_I ? LB_RADDR_1_I   : si_fetch_rd[1] ? 0 : S_RADDR_buf[1];
        si_flag_rd[1]    <=  si_fetch_rd[1] ? 0 : S_RREQ_buf[1] ? 1 : si_flag_rd[1];
    end
end



///////wr state///////

always@(posedge LB_CLK_I)begin
    if(~LB_RSTN_I)begin
        sel_m_wr   <= 0;
        state_m_wr <= 0;
        for(ii=0;ii<C_CH_NUM;ii=ii+1)begin
            si_fetch_wr[ii]<=0;
            S_WADDR_buf_o[ii]<=0;
            S_WDATA_buf_o[ii]<=0;
            S_WREQ_buf_o[ii]<=0;
        end
    end
    else begin
        case(state_m_wr)
            0: begin
                if(si_flag_wr[0])  begin sel_m_wr <=0;  state_m_wr <= 4; 
                    si_fetch_wr[0]        <= 1;
                    S_WADDR_buf_o[0]      <= S_WADDR_buf[0]   ;
                    S_WDATA_buf_o[0]      <= S_WDATA_buf[0]   ;
                    S_WREQ_buf_o[0]       <= S_WREQ_buf[0] ;
                end
                else if(si_flag_wr[1])begin sel_m_wr <=1;  state_m_wr <= 5; 
                    si_fetch_wr[1]        <= 1;
                    S_WADDR_buf_o[1]      <= S_WADDR_buf[1]   ;
                    S_WDATA_buf_o[1]      <= S_WDATA_buf[1]   ;
                    S_WREQ_buf_o[1]       <= S_WREQ_buf[1] ;
                end
            end
            //1: begin
            //    si_fetch_wr[0]        <= 1;
            //    S_WADDR_buf_o[0]      <= S_WADDR_buf[0]   ;
            //    S_WDATA_buf_o[0]      <= S_WDATA_buf[0]   ;
            //    S_WREQ_buf_o[0]       <= S_WREQ_buf[0] ;
            //    state_m_wr            <= 4;
            //end
            //2:begin
            //    si_fetch_wr[1]        <= 1;
            //    S_WADDR_buf_o[1]      <= S_WADDR_buf[1]   ;
            //    S_WDATA_buf_o[1]      <= S_WDATA_buf[1]   ;
            //    S_WREQ_buf_o[1]       <= S_WREQ_buf[1] ;
            //    state_m_wr            <= 5;
            //end
            ///////////////////////////////////////////////////
 ///////////////////////////////////////////////////
            4: begin
                si_fetch_wr[0]     <= 0;
                S_WADDR_buf_o[0]   <= 0 ;
                S_WDATA_buf_o[0]   <= 0 ;
                S_WREQ_buf_o[0]    <= 0 ;
                state_m_wr         <=  0 ;
            end
            5: begin
                si_fetch_wr[1]     <= 0;
                S_WADDR_buf_o[1]   <= 0 ;
                S_WDATA_buf_o[1]   <= 0 ;
                S_WREQ_buf_o[1]    <= 0 ;
                state_m_wr            <=  0 ;
            end
            default:begin
                sel_m_wr   <= 0;
                state_m_wr <= 0;
                for(ii=0;ii<C_CH_NUM;ii=ii+1)begin
                   si_fetch_wr[ii]<=0;
                   S_WADDR_buf_o[ii]<=0;
                   S_WDATA_buf_o[ii]<=0;
                   S_WREQ_buf_o[ii]<=0;
                end 
            end
        endcase
    end
end
            


///////rd state///////

always@(posedge LB_CLK_I)begin
    if(~LB_RSTN_I)begin
        sel_m_rd   <= 0;
        state_m_rd <= 0;
        for(ii=0;ii<C_CH_NUM;ii=ii+1)begin
            si_fetch_rd[ii]<=0;
            S_RADDR_buf_o[ii]<=0;
            S_RREQ_buf_o[ii]<=0;
        end
    end
    else begin
        case(state_m_rd)
            0: begin
                if(si_flag_rd[0])     begin sel_m_rd <=0;  state_m_rd <= 4; 
                    si_fetch_rd[0]        <= 1;
                    S_RADDR_buf_o[0]      <= S_RADDR_buf[0]   ;
                    S_RREQ_buf_o[0]       <= S_RREQ_buf[0]   ;
                end
                else if(si_flag_rd[1])begin sel_m_rd <=1;  state_m_rd <= 5; 
                    si_fetch_rd[1]        <= 1;
                    S_RADDR_buf_o[1]      <= S_RADDR_buf[1]   ;
                    S_RREQ_buf_o[1]       <= S_RREQ_buf[1]   ;
                end
            end
            //1: begin
            //    si_fetch_rd[0]        <= 1;
            //    S_RADDR_buf_o[0]      <= S_RADDR_buf[0]   ;
            //    S_RREQ_buf_o[0]       <= S_RREQ_buf[0]   ;
            //    state_m_rd            <= 4;
            //end
            //2:begin
            //    si_fetch_rd[1]        <= 1;
            //    S_RADDR_buf_o[1]      <= S_RADDR_buf[1]   ;
            //    S_RREQ_buf_o[1]       <= S_RREQ_buf[1]   ;
            //    state_m_rd            <= 5;
            //end
            ///////////////////////////////////////////////////
 ///////////////////////////////////////////////////
            4: begin
                si_fetch_rd[0]     <= 0 ;
                S_RADDR_buf_o[0]   <= 0 ;
                S_RREQ_buf_o[0]    <= 0 ;
                state_m_rd         <= LB_RFINISH_I ? 0 : state_m_rd;
            end
            5: begin
                si_fetch_rd[1]     <= 0;
                S_RADDR_buf_o[1]   <= 0 ;
                S_RREQ_buf_o[1]    <= 0 ;
                state_m_rd         <= LB_RFINISH_I ? 0 : state_m_rd;
            end
            default:begin
                sel_m_rd   <= 0;
                state_m_rd <= 0;
                for(ii=0;ii<C_CH_NUM;ii=ii+1)begin
                    si_fetch_rd[ii]<=0;
                    S_RADDR_buf_o[ii]<=0;
                    S_RREQ_buf_o[ii]<=0;
                end 
            end
        endcase
    end
end



assign  LB_WADDR_O   =  sel_m_wr==0 ? S_WADDR_buf_o[0] : sel_m_wr==1 ? S_WADDR_buf_o[1]  : S_WADDR_buf_o[0] ;
assign  LB_WDATA_O   =  sel_m_wr==0 ? S_WDATA_buf_o[0] : sel_m_wr==1 ? S_WDATA_buf_o[1]  : S_WDATA_buf_o[0] ;
assign  LB_WREQ_O    =  sel_m_wr==0 ? S_WREQ_buf_o[0]  : sel_m_wr==1 ? S_WREQ_buf_o[1]   : S_WREQ_buf_o[0] ;  
assign  LB_RADDR_O   =  sel_m_rd==0 ? S_RADDR_buf_o[0] : sel_m_rd==1 ? S_RADDR_buf_o[1]  : S_RADDR_buf_o[0] ;  
assign  LB_RREQ_O    =  sel_m_rd==0 ? S_RREQ_buf_o[0]  : sel_m_rd==1 ? S_RREQ_buf_o[1]   : S_RREQ_buf_o[0] ;  


assign  LB_RDATA_0_O =  sel_m_rd==0 ? LB_RDATA_I : 0 ;
assign  LB_RDATA_1_O =  sel_m_rd==1 ? LB_RDATA_I : 0 ;


assign  LB_RFINISH_0_O = sel_m_rd==0 ? LB_RFINISH_I : 0 ;
assign  LB_RFINISH_1_O = sel_m_rd==1 ? LB_RFINISH_I : 0 ;



    
endmodule





