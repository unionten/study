`timescale 1ns / 1ps


/*
  iic_master_interconnect  uut(  
.CLK_I (clk),
.RST_I (rst),


.WR_BYTE_NUM_0_I (WR_BYTE_NUM_0_I ),
.WR_DATA_0_I     (WR_DATA_0_I     ),
.RD_BYTE_NUM_0_I (RD_BYTE_NUM_0_I ),
.RD_DATA_0_O     (RD_DATA_0_O     ),
.START_0_I       (START_0_I       ),
.BUSY_0_O        (BUSY_0_O        ),
.FINISH_0_O      (FINISH_0_O      ),
.ERROR_0_O       (ERROR_0_O       ), 



.WR_BYTE_NUM_1_I (WR_BYTE_NUM_1_I ),
.WR_DATA_1_I     (WR_DATA_1_I     ),
.RD_BYTE_NUM_1_I (RD_BYTE_NUM_1_I ),
.RD_DATA_1_O     (RD_DATA_1_O     ),
.START_1_I       (START_1_I       ),
.BUSY_1_O        (BUSY_1_O        ),
.FINISH_1_O      (FINISH_1_O      ),
.ERROR_1_O       (ERROR_1_O       ), 



.WR_BYTE_NUM_O (  ),
.WR_DATA_O     (      ),
.RD_BYTE_NUM_O (  ),
.RD_DATA_I     (45645     ),
.START_O       (START_O       ) ,
.BUSY_I        (BUSY_I        ) ,
.FINISH_I      (FINISH_I      ) ,
.ERROR_I       (ERROR_I       )



);
*/



//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/01/18 16:11:29
// Design Name: 
// Module Name: iic_master_interconnect
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


module iic_master_interconnect(
input  CLK_I ,
input  RST_I ,


input  [7:0]  WR_BYTE_NUM_0_I ,
input  [63:0] WR_DATA_0_I     ,
input  [7:0]  RD_BYTE_NUM_0_I ,
output [63:0] RD_DATA_0_O     ,
input         START_0_I       ,
output        BUSY_0_O        ,
output        FINISH_0_O      ,
output        ERROR_0_O       , 



input  [7:0]  WR_BYTE_NUM_1_I ,
input  [63:0] WR_DATA_1_I     ,
input  [7:0]  RD_BYTE_NUM_1_I ,
output [63:0] RD_DATA_1_O     ,
input         START_1_I       ,
output        BUSY_1_O        ,
output        FINISH_1_O      ,
output        ERROR_1_O       , 



output  [7:0]  WR_BYTE_NUM_O ,
output  [63:0] WR_DATA_O     ,
output  [7:0]  RD_BYTE_NUM_O ,
input   [63:0] RD_DATA_I     ,
output         START_O        ,
input          BUSY_I         ,
input          FINISH_I       ,
input          ERROR_I       



);

parameter C_CH_NUM = 2 ;

genvar i,j,k;


reg BUSY_1_O_reg = 0;
reg BUSY_0_O_reg = 0;


reg [7:0] ii,jj,kk;

reg [7:0] state_m = 0;//control sel_m state

reg   [8-1:0] WR_BYTE_NUM_buf[C_CH_NUM-1:0]   ;
reg  [64-1:0]  WR_DATA_buf    [C_CH_NUM-1:0]   ;
reg  [8-1:0]    RD_BYTE_NUM_buf[C_CH_NUM-1:0] ;
reg  START_buf[C_CH_NUM-1:0] ;



reg   [8-1:0] WR_BYTE_NUM_o[C_CH_NUM-1:0]   ;
reg  [64-1:0]  WR_DATA_o    [C_CH_NUM-1:0]   ;
reg   [8-1:0]    RD_BYTE_NUM_o[C_CH_NUM-1:0] ;
reg  START_o[C_CH_NUM-1:0] ;



reg [1:0] sel_m = 0;//select whitch SI to connect to MI 
reg     [C_CH_NUM-1:0]  si_flag   = 0       ;//哪路有请求(同时来时,ch0优先级高)
reg     [C_CH_NUM-1:0]  si_fetch  = 0       ;//取走哪路


//id 0
always@(posedge CLK_I)begin
    if(RST_I)begin
        START_buf[0]     <=  0;
        WR_BYTE_NUM_buf[0]   <=  0;
        WR_DATA_buf [0]      <=  0;
        RD_BYTE_NUM_buf[0]   <=  0;
        BUSY_0_O_reg <= 0 ;
    end
    else begin 
        START_buf[0]    <=  START_0_I ? START_0_I          : si_fetch[0] ? 0 : START_buf[0];  
        WR_BYTE_NUM_buf[0]  <=  START_0_I ? WR_BYTE_NUM_0_I    : si_fetch[0] ? 0 : WR_BYTE_NUM_buf[0];
        WR_DATA_buf[0]      <=  START_0_I ? WR_DATA_0_I        : si_fetch[0] ? 0 : WR_DATA_buf[0];
        RD_BYTE_NUM_buf[0]  <=  START_0_I ? RD_BYTE_NUM_0_I    : si_fetch[0] ? 0 : RD_BYTE_NUM_buf[0];
        si_flag[0]          <=  si_fetch[0] ? 0 : START_buf[0] ? 1 : si_flag[0];
        BUSY_0_O_reg  <= START_0_I ? 1 :  ( state_m==4 & ~BUSY_I ) ?  0 :  BUSY_0_O_reg  ;
        
    end
end



//id 1
always@(posedge CLK_I)begin
    if(RST_I)begin
        START_buf[1]     <=  0;
        WR_BYTE_NUM_buf[1]   <=  0;
        WR_DATA_buf [1]      <=  0;
        RD_BYTE_NUM_buf[1]   <=  0;
        BUSY_1_O_reg <= 0;
    end
    else begin 
        START_buf[1]    <=  START_1_I ? START_1_I          : si_fetch[1] ? 0 : START_buf[1];  
        WR_BYTE_NUM_buf[1]  <=  START_1_I ? WR_BYTE_NUM_1_I    : si_fetch[1] ? 0 : WR_BYTE_NUM_buf[1];
        WR_DATA_buf[1]      <=  START_1_I ? WR_DATA_1_I        : si_fetch[1] ? 0 : WR_DATA_buf[1];
        RD_BYTE_NUM_buf[1]  <=  START_1_I ? RD_BYTE_NUM_1_I    : si_fetch[1] ? 0 : RD_BYTE_NUM_buf[1];
        si_flag[1]          <=  si_fetch[1] ? 0 : START_buf[1] ? 1 : si_flag[1];
        BUSY_1_O_reg  <= START_1_I ? 1 :  ( state_m==5 & ~BUSY_I ) ?  0 :  BUSY_1_O_reg  ;
    end
end



///////  state///////

always@(posedge CLK_I)begin
    if(RST_I)begin
        sel_m   <= 0;
        state_m <= 0;
        for(ii=0;ii<C_CH_NUM;ii=ii+1)begin
            si_fetch[ii]<=0;
            WR_BYTE_NUM_o[ii]<=0;
            WR_DATA_o[ii]<=0;
            RD_BYTE_NUM_o[ii]<=0;
            START_o[ii]  <= 0 ;
        end
    end
    else begin
        case(state_m)
            0: begin
                if(si_flag[0])  begin sel_m <=0;  state_m <= 4; 
                    si_fetch[0]        <= 1;
                    WR_BYTE_NUM_o[0]   <= WR_BYTE_NUM_buf[0]   ;
                    WR_DATA_o[0]        <= WR_DATA_buf[0]   ;
                    RD_BYTE_NUM_o[0]    <= RD_BYTE_NUM_buf[0] ;
                    START_o[0]  <= START_buf[0] ;
                end
                else if(si_flag[1])begin sel_m <=1;  state_m <= 5; 
                    si_fetch[1]        <= 1;
                    WR_BYTE_NUM_o[1]   <= WR_BYTE_NUM_buf[1]   ;
                    WR_DATA_o[1]        <= WR_DATA_buf[1]   ;
                    RD_BYTE_NUM_o[1]    <= RD_BYTE_NUM_buf[1] ;
                    START_o[1]  <= START_buf[1] ;
                end
            end
            
            4: begin
                si_fetch[0]       <= 0;
                WR_BYTE_NUM_o[0]  <= 0  ;
                WR_DATA_o[0]      <= 0   ;
                RD_BYTE_NUM_o[0]  <= 0 ;
                START_o[0]  <= 0 ;
                state_m           <= ~BUSY_I  ? 0 : state_m ;
            end
            5: begin
                si_fetch[1]     <= 0;
                WR_BYTE_NUM_o[1]  <= 0  ;
                WR_DATA_o[1]      <= 0   ;
                RD_BYTE_NUM_o[1]  <= 0 ;
                START_o[1]  <= 0 ;
                state_m           <= ~BUSY_I  ? 0 : state_m ;
            end
            default:begin
                sel_m   <= 0;
                state_m <= 0;
                for(ii=0;ii<C_CH_NUM;ii=ii+1)begin
                   si_fetch[ii]<=0;
                    WR_BYTE_NUM_o[ii]  <= 0  ;
                    WR_DATA_o[ii]      <= 0   ;
                    RD_BYTE_NUM_o[ii]  <= 0 ;
                    START_o[ii]  <= 0 ;
                end 
            end
        endcase
    end
end



assign  WR_BYTE_NUM_O   =  sel_m==0 ? WR_BYTE_NUM_o[0]  : sel_m==1 ?  WR_BYTE_NUM_o[1]    :  WR_BYTE_NUM_o[1]   ;
assign  WR_DATA_O       =  sel_m==0 ? WR_DATA_o[0]      : sel_m==1 ?  WR_DATA_o[1]        :  WR_DATA_o[1]       ;
assign  RD_BYTE_NUM_O   =  sel_m==0 ? RD_BYTE_NUM_o[0]  : sel_m==1 ?  RD_BYTE_NUM_o[1]    :  RD_BYTE_NUM_o[1]   ;  
assign  START_O         =  sel_m==0 ? START_o[0]    : sel_m==1 ?  START_o[1]      :  START_o[1]   ;  


assign RD_DATA_0_O   = sel_m ==0 ?  RD_DATA_I : 0 ; 
assign BUSY_0_O      = BUSY_0_O_reg | START_0_I ;
assign FINISH_0_O    = sel_m ==0 ?  FINISH_I  : 0 ; 
assign ERROR_0_O     = sel_m ==0 ?  ERROR_I   : 0 ; 
    
    
assign RD_DATA_1_O   = sel_m ==1 ?  RD_DATA_I : 0 ; 
assign BUSY_1_O      = BUSY_1_O_reg |  START_1_I ;
assign FINISH_1_O    = sel_m ==1 ?  FINISH_I  : 0 ; 
assign ERROR_1_O     = sel_m ==1 ?  ERROR_I   : 0 ; 
    
    
    
endmodule
