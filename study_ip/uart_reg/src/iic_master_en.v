`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:  20220202  iic_ctrl
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
//本模块不通过赋z通过上拉输出1
//iic_master_en #(.MAX_BYTE_NUM( 1 )) // 【must >= 1】
//    iic_ctrl_u(
//    .RST_I          (),      //do not need to rst
//    .CLK_I          (),      
//    .DIV_CNT_I      (),      //[11:0] 【 must >= 4 】
//    .WRITE_REQ_I    (),      //prior to READ_REQ_I
//    .READ_REQ_I     (),      
//    .DEV_ADDR_I     (),      //[6:0] dev addr 【注意只有7位】
//    .REG_ADDR_I     (),      //[15:0] first send high byte , when  IS_ADDR_2BYTE_I == 1
//    .IS_ADDR_2BYTE_I(),      //
//    .PDATA_I        (),      //[MAX_BYTE_NUM*8-1:0] PDATA_I = {0000000000 low byte(first send)......high byte}
//    .RD_FINISH_O    (),      //read finish pulse
//    .WR_FINISH_O    (),      
//    .PDATA_O        (),      //[MAX_BYTE_NUM*8-1:0] PDATA_O = {0000000000 low byte......high byte}
//    .BYTE_NUM_I     (),      //[f_Data2W(MAX_BYTE_NUM)-1:0]  【must >= 0, 新版本支持0字节】
//    .SDA_I          (),      
//    .SDA_O          (),      
//    .SDA_T          (),      
//    .SCL_I          (),      
//    .SCL_O          (),      
//    .SCL_T          (),      
//    .BUSY_O         (),      
//    .ERROR_O        ()       
//    );
//////////////////////////////////////////////////////////////////////////////////
module iic_master_en(
RST_I           ,
CLK_I           ,
DIV_CNT_I       ,//[11:0] must >= 4
READ_REQ_I      ,
WRITE_REQ_I     ,//
DEV_ADDR_I      ,//[6:0] dev addr 
REG_ADDR_I      ,//[15:0] first send high_addr_byte
IS_ADDR_2BYTE_I ,//
PDATA_I         ,//[MAX_BYTE_NUM*8-1:0] PDATA_I = {0000000000 low_addr_byte......high_addr_byte}
RD_FINISH_O     ,//read finish pulse
WR_FINISH_O     ,
PDATA_O         ,//[MAX_BYTE_NUM*8-1:0] PDATA_O = {0000000000 low_addr_byte......high_addr_byte}
BYTE_NUM_I      ,//[f_Data2W(MAX_BYTE_NUM*8)-1:0]   must >= 0
SDA_I           ,
SDA_O           ,
SDA_T           ,
SCL_I           ,
SCL_O           ,
SCL_T           ,
BUSY_O          ,
ERROR_O         
);
parameter MAX_BYTE_NUM = 10;//2:154LUT 154FF  1:134LUT 128FF
///////////////////////////////////////////////////////////////////////////////
`define    MSB    Shift_out_8[7]
localparam INTER_DELAY_500K_CLK_NUM = 0;
///////////////////////////////////////////////////////////////////////////////
input [6:0] DEV_ADDR_I;
input [11:0] DIV_CNT_I;
input CLK_I;
input RST_I;
input READ_REQ_I;
input WRITE_REQ_I;
input  SDA_I;
output SDA_O;
output reg SDA_T = 0;
input  SCL_I;
output SCL_O;
output reg  SCL_T = 0;//0 output; 1 input always 0
input [15:0] REG_ADDR_I;
input IS_ADDR_2BYTE_I;
input [MAX_BYTE_NUM*8-1:0] PDATA_I;
output BUSY_O;
output reg RD_FINISH_O = 0;
output reg WR_FINISH_O = 0;
output reg [MAX_BYTE_NUM*8-1:0] PDATA_O = 0;
input [f_Data2W(MAX_BYTE_NUM)-1:0] BYTE_NUM_I;
output reg ERROR_O = 0;
/////////////////////////////////////////////////////////////////////////////////
reg [7:0] Shift_out_8 = 0;
assign SDA_O = Shift_out_8[7];
reg Open_clk = 0;
reg Scl_o = 0;


assign SCL_O = Open_clk ? Scl_o : 1;
//assign SCL_O = 0  ; //yzhu
//assign SCL_T = Open_clk ? (Scl_o==1 ? 1 : 0) : 1 ; //yzhu


reg [f_Data2W(MAX_BYTE_NUM)-1:0] Byte_num_i = 0; 
reg [f_Data2W(MAX_BYTE_NUM)-1:0] Cnt_byte_num = 0;
reg [6:0] Dev_addr_i = 0;
reg [15:0] Reg_addr_i = 0;
reg Is_addr_2byte_i = 0;
reg [MAX_BYTE_NUM*8-1:0] Pdata_i = 0;
reg [7:0] Data_r = 0;
reg [MAX_BYTE_NUM*8-1:0] Pdata_o = 0;
reg FF = 1;
reg Busy = 0;
wire clk500k_pos;
wire clk500k_neg;
wire op_edge;
wire [7:0] byte_high;
reg [7:0] State = 0;  
///////////////////////////////////////////////////////////////////////////////
clk_div_pos_neg__AHDUDP clk_div_pos_neg_u(
    .RST_I          (RST_I),
    .CLK_I          (CLK_I),
    .DIV_CNT_I      (DIV_CNT_I>>1),//must >= 2  
    .CLK_DIV_O      ( ),
    .CLK_DIV_POS_O  (clk500k_pos),
    .CLK_DIV_NEG_O  (clk500k_neg));
assign op_edge = clk500k_neg;
///////////////////////////////////////////////////////////////////////////////
mux_byte__AHDUDP#(.MAX_BYTE_NUM(MAX_BYTE_NUM))
    select_high_byte_u(
    .PDATA_I(Pdata_i),
    .INDEX_I(Byte_num_i-1),
    .BYTE_O(byte_high));
///////////////////////////////////////////////////////////////////////////////
assign BUSY_O = WRITE_REQ_I | READ_REQ_I | Busy;
/////////////////////////////////////////////////////////////////////////////
always@(posedge CLK_I)begin
    if(RST_I)begin
        Scl_o <= 0;
    end
    else if(clk500k_pos)begin
        Scl_o <= ~Scl_o;
    end
end
///////////////////////////////////////////////////////////////////////////////
parameter S_IDLE        = 0,
          S_JUMP        = 1,
          S_W_0         = 2, 
          S_W_1         = 3,
          S_W_2         = 4,
          S_W_ACK_0     = 5,
          S_W_HA_0      = 6,
          S_W_HA_1      = 7,
          S_W_ACK_1     = 8,
          S_W_LA_0      = 9,
          S_W_LA_1      = 10,
          S_W_ACK_2     = 11,
          S_W_D_0       = 12,
          S_W_D_1       = 13,
          S_W_ACK_3     = 14,
          S_W_STOP      = 15,
          S_RW_0        = 16, 
          S_RW_1        = 17,
          S_RW_2        = 18,
          S_RW_ACK_0    = 19,
          S_RW_HA_0     = 20,
          S_RW_HA_1     = 21,
          S_RW_ACK_1    = 22,
          S_RW_LA_0     = 23,
          S_RW_LA_1     = 24,
          S_RW_ACK_2    = 25,
          S_RR_0        = 26,
          S_RR_1        = 27,
          S_RR_2        = 28,
          S_RR_ACK_0    = 29,
          S_RR_READ_0   = 30,
          S_RR_READ_1   = 31,
          S_RR_ACK_1    = 32,
          S_RR_NACK     = 33,
          S_RR_STOP     = 34,
          S_RR_READ_B   = 35,
          S_WAIT_0      = 36,
          S_IDLE_B      = 37,
          IN_CONTI_0    = 38,
          IN_CONTI_1    = 39,
          IN_CONTI_2    = 40,
          IN_CONTI_3    = 41,
          IN_CONTI_4    = 42,
          IN_CONTI_5    = 43,
          IN_CONTI_6    = 44,
          IN_CONTI_7    = 45,
          S_WAIT_1      = 46;
parameter 
          bit_out_idle = 0,
          bit_out_7    = 1,
          bit_out_6    = 2,
          bit_out_5    = 3,
          bit_out_4    = 4,
          bit_out_3    = 5,
          bit_out_2    = 6,
          bit_out_1    = 7,
          bit_out_0    = 8;        
reg [7:0] State_out = bit_out_idle;
parameter 
          bit_in_idle  = 0,
          bit_in_7     = 1,
          bit_in_6     = 2,
          bit_in_5     = 3,
          bit_in_4     = 4,
          bit_in_3     = 5,
          bit_in_2     = 6,
          bit_in_1     = 7,
          bit_in_0     = 8;  
reg [7:0] State_in = bit_in_idle;
reg Read_flag;
///////////////////////////////////////////////////////////////////////////////
always@(posedge CLK_I)begin//limited at clk500k_neg
    if(RST_I)begin
        t_reset;
    end
    else begin
        case(State)
            S_IDLE:begin
                if(WRITE_REQ_I)begin
                    ERROR_O <= 0;
                    Busy <= 1;
                    Byte_num_i      <= BYTE_NUM_I;
                    Dev_addr_i      <= DEV_ADDR_I;
                    Reg_addr_i      <= REG_ADDR_I;
                    Is_addr_2byte_i <= IS_ADDR_2BYTE_I;
                    Pdata_i         <= PDATA_I;
                    State           <= S_W_0;
                end
                else if(READ_REQ_I)begin
                    ERROR_O <= 0;
                    Busy <= 1;
                    Byte_num_i      <= BYTE_NUM_I;
                    Dev_addr_i      <= DEV_ADDR_I;
                    Reg_addr_i      <= REG_ADDR_I;
                    Is_addr_2byte_i <= IS_ADDR_2BYTE_I;
                    Pdata_i         <= PDATA_I;
                    State           <= S_RW_0;
                end
                else begin
                    t_reset;
                end
            end
            S_W_0:begin
                if(op_edge & Scl_o)begin
                    `MSB <= 0;
                    Open_clk <= 1;//open clk
                    State <= S_W_1;
                end
            end
            S_W_1:begin
                if(op_edge & ~Scl_o)begin
                    Shift_out_8 <=  {Dev_addr_i[6:0],1'b0};
                    State_out <= bit_out_7;
                    FF <= 1;
                    State <= S_W_2;
                end
            end
            S_W_2:begin
                if(op_edge)begin
                    if(FF==1)begin
                        t_shift_out_8;
                    end
                    else begin
                        State <= S_W_ACK_0;
                    end
                end
            end
            S_W_ACK_0:begin
                if(op_edge & ~Scl_o)SDA_T <= 1;
                else if(op_edge & Scl_o)begin
                    if(SDA_I==0)State <= S_W_HA_0;
                    else begin
                        ERROR_O <= 1;
                        State <= S_W_STOP;
                    end
                end
            end
            S_W_HA_0:begin
                if(op_edge & ~Scl_o)begin
                    SDA_T <= 0;
                    if(Is_addr_2byte_i)begin
                        Shift_out_8 <= Reg_addr_i[15:8];
                    end
                    else begin    
                        Shift_out_8 <= Reg_addr_i[7:0];
                    end
                    State_out <= bit_out_7; 
                    FF <= 1;
                    State <= S_W_HA_1;
                end
            end
            S_W_HA_1:begin
                if(op_edge)begin
                    if(FF==1)begin
                        t_shift_out_8;
                    end
                    else begin
                        
                        State <= S_W_ACK_1;
                    end 
                end
            end
            S_W_ACK_1:begin
                if(op_edge & ~Scl_o)SDA_T <= 1;
                else if(op_edge & Scl_o)begin
                    if(SDA_I==0)begin
                        if(Is_addr_2byte_i)begin//low address
                            State <= S_W_LA_0;
                        end
                        else begin  //单字节地址-0数据，结束
                            if(Byte_num_i==0)begin
                                State <= S_W_STOP;
                            end
                            else begin 
                                Cnt_byte_num <= Byte_num_i;
                                State <= S_W_D_0;
                            end
                        end
                    end
                    else begin    
                        ERROR_O <= 1;
                        State <= S_W_STOP;
                    end
                end
            end
            S_W_LA_0:begin
                if(op_edge)begin
                    SDA_T <= 0;
                    Shift_out_8 <= Reg_addr_i[7:0];
                    State_out <= bit_out_7;
                    FF <= 1;
                    State <= S_W_LA_1;
                end
            end
            S_W_LA_1:begin
                if(op_edge)begin
                    if(FF==1)begin
                        t_shift_out_8;
                    end
                    else begin
                        State <= S_W_ACK_2;
                    end 
                end
            end
            S_W_ACK_2:begin
                if(op_edge & ~Scl_o)SDA_T <= 1;
                else if(op_edge & Scl_o)begin
                    if(SDA_I==0)begin
                        if(Byte_num_i==0)begin// changed
                            State <= S_W_STOP;// changed
                        end// changed
                        else begin
                            State <= S_W_D_0;//write data
                            Cnt_byte_num <= Byte_num_i;
                        end
                    end
                    else begin
                        ERROR_O <= 1;
                        State <= S_W_STOP;
                    end
                end
            end
            S_W_D_0:begin
                if(op_edge & ~Scl_o)begin
                    SDA_T <= 0;
                    Shift_out_8 <= byte_high;            
                    State_out <= bit_out_7;
                    Pdata_i  <= Pdata_i<<8;
                    Cnt_byte_num <= Cnt_byte_num - 1;
                    State <= S_W_D_1;
                    FF <= 1;
                end
            end
            S_W_D_1:begin
                if(op_edge)begin
                    if(FF==1)begin
                        t_shift_out_8;
                    end
                    else begin
                        
                        State <= S_W_ACK_3;
                    end
                end
            end
            S_W_ACK_3:begin
                if(op_edge & ~Scl_o)SDA_T <= 1;
                else if(op_edge & Scl_o)begin
                    if(SDA_I==0)begin//judge ack
                        if(Cnt_byte_num>0)begin
                            State <= S_W_D_0;
                        end
                        else begin
                            WR_FINISH_O <= 1;
                            State <= S_W_STOP;
                        end
                    end
                    else begin
                        ERROR_O <= 1;
                        State <= S_W_STOP;
                    end 
                end
            end
            S_W_STOP:begin
                WR_FINISH_O <= 0;
                //ERROR_O <= 0;
                if(op_edge)begin
                    SDA_T <= 0;
                    if(Scl_o==0)begin
                        `MSB <= 0;
                    end
                    else 
                    if(Scl_o==1)begin                   
                        `MSB <= 1;
                        Open_clk <= 0;
                        State <= S_IDLE;
                    end
                end
            end
////////////////////////////////////////////////////////////////////////////////
            S_RW_0:begin
                if(op_edge & Scl_o)begin
                    `MSB <= 0;
                    Open_clk <= 1;
                    State <= S_RW_1;
                end
            end
            S_RW_1:begin
                if(op_edge & ~Scl_o)begin
                   Shift_out_8 <= {Dev_addr_i[6:0],1'b0};
                   State_out <= bit_out_7;
                   FF <= 1;
                   State <= S_RW_2;
                end
            end
            S_RW_2:begin
                if(op_edge)begin
                    if(FF==1)begin
                        t_shift_out_8;
                    end
                    else begin
                        
                        State <= S_RW_ACK_0;
                    end
                end
            end
            S_RW_ACK_0:begin
                if(op_edge & ~Scl_o)SDA_T <= 1;
                else if(op_edge & Scl_o)begin
                    if(SDA_I==0)begin
                        if(Is_addr_2byte_i==1)begin
                            State <= S_RW_HA_0;
                        end
                        else begin
                            State <= S_RW_LA_0;
                        end
                    end
                    else begin
                        ERROR_O <= 1;
                        State <= S_RR_STOP;
                    end
                end
            end
            S_RW_HA_0:begin
                if(op_edge & ~Scl_o)begin
                    SDA_T <= 0;
                    Shift_out_8 <= Reg_addr_i[15:8];
                    State_out <= bit_out_7;
                    FF <= 1;
                    State <= S_RW_HA_1;
                end
            end
            S_RW_HA_1:begin
                if(op_edge)begin
                    if(FF==1)begin
                        t_shift_out_8;
                    end
                    else begin
                        State <= S_RW_ACK_1;
                    end 
                end
            end
            S_RW_ACK_1:begin
                if(op_edge & ~Scl_o)SDA_T <= 1;
                else if(op_edge & Scl_o)begin
                    if(SDA_I==0)State <= S_RW_LA_0;
                    else begin
                        ERROR_O <= 1;
                        State <= S_RR_STOP;
                    end
                end
            end
            S_RW_LA_0:begin
                if(op_edge & ~Scl_o)begin
                    SDA_T <= 0;
                    Shift_out_8 <= Reg_addr_i[7:0];
                    State_out <= bit_out_7;
                    FF <= 1;
                    State <= S_RW_LA_1;
                end
            end
            S_RW_LA_1:begin
                if(op_edge )begin
                    if(FF==1)begin
                        t_shift_out_8;
                    end
                    else begin
                        State <= S_RW_ACK_2;
                    end 
                end
            end
            S_RW_ACK_2:begin
                if(op_edge & ~Scl_o)SDA_T <= 1;
                else if(op_edge & Scl_o)begin
                    if(SDA_I==0)begin 
                        State <= S_RR_0;
                    end
                    else begin
                        ERROR_O <= 1;
                        State <= S_RR_STOP;
                    end
                end
            end
            S_RR_0:begin
                if(op_edge & ~Scl_o)begin
                    `MSB <= 1;
                    SDA_T <= 0;
                end
                else if(op_edge & Scl_o)begin
                    `MSB <= 0;
                    State <= S_RR_1;
                end
            end
            S_RR_1:begin
                if(op_edge & ~Scl_o)begin
                    Shift_out_8 <= {Dev_addr_i[6:0],1'b1};
                    State_out <= bit_out_7;
                    FF <= 1;
                    State <= S_RR_2;
                end
            end
            S_RR_2:begin
                if(op_edge)begin
                    if(FF==1)begin
                        t_shift_out_8;
                    end
                    else begin
                        State <= S_RR_ACK_0;
                    end
                end
            end
            S_RR_ACK_0:begin
                if(op_edge & ~Scl_o)SDA_T <= 1;
                else if(op_edge & Scl_o)begin
                    if(SDA_I==0)begin
                        Cnt_byte_num <= Byte_num_i;
                        State <= S_RR_READ_0;
                    end
                    else begin
                        ERROR_O <= 1;
                        State <= S_RR_STOP;
                    end
                end
            end
            S_RR_READ_0:begin
                if(op_edge & Scl_o)begin
                    Data_r[7] <= SDA_I;
                    State_in <= bit_in_7;
                    State <= S_RR_READ_1;
                    FF <= 1;
                end
            end
            S_RR_READ_1:begin
                if(op_edge)begin
                    if(FF==1)begin
                        t_shift_in_8;
                    end
                    else begin
                        if(MAX_BYTE_NUM<=1)Pdata_o <= Data_r;
                        else Pdata_o <= {Pdata_o[MAX_BYTE_NUM*8-1-8:0],Data_r};
                        Data_r <= 0;
                        if(Cnt_byte_num == 1)begin
                            SDA_T <= 0;
                            `MSB <= 1;// noack to slave
                            State <= S_RR_NACK;
                        end
                        else begin 
                            Cnt_byte_num <= Cnt_byte_num - 1;                           
                            SDA_T <= 0;                          
                            `MSB <= 0;// ack to slave
                            State <= S_RR_ACK_1;
                        end
                    end
                end
            end
            S_RR_ACK_1:begin
                if(op_edge & ~Scl_o)begin
                    State <= S_RR_READ_0;
                    SDA_T <= 1;
                end
            end
            S_RR_NACK:begin
                if(op_edge & ~Scl_o)begin
                    PDATA_O <= Pdata_o;
                    RD_FINISH_O <= 1;
                    State <= S_RR_STOP;   
                    `MSB <= 0;
                end
            end
            S_RR_STOP:begin
                //ERROR_O <= 0;
                RD_FINISH_O <= 0;
                if(op_edge)begin
                    SDA_T <= 0;
                    if(~Scl_o)begin
                        `MSB <= 0;
                    end
                    else if(Scl_o)begin
                        `MSB <= 1;
                        Open_clk <= 0;
                        State <= S_IDLE;
                    end
                end
            end
            default:begin
                t_reset;
            end
        endcase
    end
end
///////////////////////////////////////////////////////////////////////////////
task t_shift_out_8;
    case(State_out)
        bit_out_7:begin
            if(~Scl_o)begin
                Shift_out_8 <= Shift_out_8<<1;
                State_out <= bit_out_6;
            end
        end
        bit_out_6:begin
            if(~Scl_o)begin
                Shift_out_8 <= Shift_out_8<<1;
                State_out <= bit_out_5;
            end
        end
        bit_out_5:begin
            if(~Scl_o)begin
                Shift_out_8 <= Shift_out_8<<1;
                State_out <= bit_out_4; 
            end
        end
        bit_out_4:begin
            if(~Scl_o)begin
                Shift_out_8 <= Shift_out_8<<1;
                State_out <= bit_out_3;
            end
        end
        bit_out_3:begin
            if(~Scl_o)begin
                Shift_out_8 <= Shift_out_8<<1;
                State_out <= bit_out_2;
            end
        end
        bit_out_2:begin
            if(~Scl_o)begin
                Shift_out_8 <= Shift_out_8<<1;
                State_out <= bit_out_1;
            end
        end
        bit_out_1:begin
            if(~Scl_o)begin
                Shift_out_8 <= Shift_out_8<<1;
                State_out <= bit_out_0;
                FF <= 0;
            end
        end
        bit_out_0:begin
            FF <= 0;
        end
        default:begin
            t_reset;
        end
    endcase
endtask
///////////////////////////////////////////////////////////////////////////////
task t_shift_in_8;
    case(State_in)
        bit_in_7:begin
            if(Scl_o)begin
                Data_r[6] <= SDA_I;
                State_in <= bit_in_6;
            end
        end        
        bit_in_6:begin
            if(Scl_o)begin
                Data_r[5] <= SDA_I;
                State_in <= bit_in_5;
            end
        end
        bit_in_5:begin
            if(Scl_o)begin
                Data_r[4] <= SDA_I;
                State_in <= bit_in_4;
            end
        end
        bit_in_4:begin
            if(Scl_o)begin
                Data_r[3] <= SDA_I;
                State_in <= bit_in_3;
            end
        end
        bit_in_3:begin
            if(Scl_o)begin
                Data_r[2] <= SDA_I;
                State_in <= bit_in_2;
            end
        end        
        bit_in_2:begin
            if(Scl_o)begin
                Data_r[1] <= SDA_I;
                State_in <= bit_in_1;
            end
        end
        bit_in_1:begin
            if(Scl_o)begin
                Data_r[0] <= SDA_I;
                State_in <= bit_in_0;
                FF <= 0;
            end
        end
        bit_in_0:begin
            FF <= 0;
        end
        default:begin
            t_reset;
        end
    endcase
endtask
///////////////////////////////////////////////////////////////////////////////
task t_reset;
begin
    SDA_T <= 0;
    `MSB <= 1;
    State <= S_IDLE;
    State_out <= bit_out_idle;
    State_in  <= bit_in_idle;
    Shift_out_8 <= 8'h80;
    FF <= 1;
    Busy <= 0;
    Pdata_o <= 0;
    SCL_T <= 0;
    Open_clk <= 0;
    Cnt_byte_num <= 0;
    Byte_num_i <= 0;
    RD_FINISH_O <= 0;
    WR_FINISH_O <= 0;
   // ERROR_O <= 0;
end
endtask
///////////////////////////////////////////////////////////////////////////////
function [7:0] f_Depth2W;//depth to unsigned_width
input [31:0] Depth;//****************input: 1  ~  2**32-1******************//
begin
    if(Depth>=1       && Depth<=2**1 ) f_Depth2W=1;   //1
    if(Depth>=2**1+1  && Depth<=2**2 ) f_Depth2W=2;   //3
    if(Depth>=2**2+1  && Depth<=2**3 ) f_Depth2W=3;   //5
    if(Depth>=2**3+1  && Depth<=2**4 ) f_Depth2W=4;   //9
    if(Depth>=2**4+1  && Depth<=2**5 ) f_Depth2W=5;   //17
    if(Depth>=2**5+1  && Depth<=2**6 ) f_Depth2W=6;   //33
    if(Depth>=2**6+1  && Depth<=2**7 ) f_Depth2W=7;   //65
    if(Depth>=2**7+1  && Depth<=2**8 ) f_Depth2W=8;   //129
    if(Depth>=2**8+1  && Depth<=2**9 ) f_Depth2W=9;   //257
    if(Depth>=2**9+1  && Depth<=2**10) f_Depth2W=10;  //513
    if(Depth>=2**10+1 && Depth<=2**11) f_Depth2W=11;  //1025
    if(Depth>=2**11+1 && Depth<=2**12) f_Depth2W=12;  //2049
    if(Depth>=2**12+1 && Depth<=2**13) f_Depth2W=13;  //4097
    if(Depth>=2**13+1 && Depth<=2**14) f_Depth2W=14;  //8193
    if(Depth>=2**14+1 && Depth<=2**15) f_Depth2W=15;  //16385
    if(Depth>=2**15+1 && Depth<=2**16) f_Depth2W=16;  //32769
    if(Depth>=2**16+1 && Depth<=2**17) f_Depth2W=17;  //65537
    if(Depth>=2**17+1 && Depth<=2**18) f_Depth2W=18;  //131073
    if(Depth>=2**18+1 && Depth<=2**19) f_Depth2W=19;  //262145
    if(Depth>=2**19+1 && Depth<=2**20) f_Depth2W=20;  //524289
    if(Depth>=2**20+1 && Depth<=2**21) f_Depth2W=21;  //1048577
    if(Depth>=2**21+1 && Depth<=2**22) f_Depth2W=22;  //
    if(Depth>=2**22+1 && Depth<=2**23) f_Depth2W=23;  //
    if(Depth>=2**23+1 && Depth<=2**24) f_Depth2W=24;  //8388609
    if(Depth>=2**24+1 && Depth<=2**25) f_Depth2W=25;  //16777217
    if(Depth>=2**25+1 && Depth<=2**26) f_Depth2W=26;  //33554433
    if(Depth>=2**26+1 && Depth<=2**27) f_Depth2W=27;  //67108865
    if(Depth>=2**27+1 && Depth<=2**28) f_Depth2W=28;  //134217729
    if(Depth>=2**28+1 && Depth<=2**29) f_Depth2W=29;  //268435457
    if(Depth>=2**29+1 && Depth<=2**30) f_Depth2W=30;  //536870913
    if(Depth>=2**30+1 && Depth<=2**31) f_Depth2W=31;  //1073741825
    if(Depth>=2**31+1 && Depth<=2**32-1) f_Depth2W=32;//2147483649
end
endfunction
///////////////////////////////////////////////////////////////////////////////
function [7:0] f_Data2W;//unsigned to unsigned_width
input [31:0] Data;//*****************input: 1  ~  2**32-1*********************//
begin
    if(Data>=2**0  && Data<=2**1-1 ) f_Data2W=1;      //1
    if(Data>=2**1  && Data<=2**2-1 ) f_Data2W=2;      //2
    if(Data>=2**2  && Data<=2**3-1 ) f_Data2W=3;      //4
    if(Data>=2**3  && Data<=2**4-1 ) f_Data2W=4;      //8
    if(Data>=2**4  && Data<=2**5-1 ) f_Data2W=5;      //16
    if(Data>=2**5  && Data<=2**6-1 ) f_Data2W=6;      //32
    if(Data>=2**6  && Data<=2**7-1 ) f_Data2W=7;      //64
    if(Data>=2**7  && Data<=2**8-1 ) f_Data2W=8;      //128
    if(Data>=2**8  && Data<=2**9-1 ) f_Data2W=9;      //256
    if(Data>=2**9  && Data<=2**10-1) f_Data2W=10;     //512
    if(Data>=2**10 && Data<=2**11-1) f_Data2W=11;     //1024
    if(Data>=2**11 && Data<=2**12-1) f_Data2W=12;     //2048
    if(Data>=2**12 && Data<=2**13-1) f_Data2W=13;     //4096
    if(Data>=2**13 && Data<=2**14-1) f_Data2W=14;     //8192
    if(Data>=2**14 && Data<=2**15-1) f_Data2W=15;     //16384
    if(Data>=2**15 && Data<=2**16-1) f_Data2W=16;     //32768
    if(Data>=2**16 && Data<=2**17-1) f_Data2W=17;     //65536
    if(Data>=2**17 && Data<=2**18-1) f_Data2W=18;     //131072
    if(Data>=2**18 && Data<=2**19-1) f_Data2W=19;     //262144
    if(Data>=2**19 && Data<=2**20-1) f_Data2W=20;     //524288
    if(Data>=2**20 && Data<=2**21-1) f_Data2W=21;     //1048576
    if(Data>=2**21 && Data<=2**22-1) f_Data2W=22;     //2097152
    if(Data>=2**22 && Data<=2**23-1) f_Data2W=23;     //
    if(Data>=2**23 && Data<=2**24-1) f_Data2W=24;     //
    if(Data>=2**24 && Data<=2**25-1) f_Data2W=25;     //16777216
    if(Data>=2**25 && Data<=2**26-1) f_Data2W=26;     //33554432
    if(Data>=2**26 && Data<=2**27-1) f_Data2W=27;     //67108864
    if(Data>=2**27 && Data<=2**28-1) f_Data2W=28;     //134217728
    if(Data>=2**28 && Data<=2**29-1) f_Data2W=29;     //268435456
    if(Data>=2**29 && Data<=2**30-1) f_Data2W=30;     //536870912
    if(Data>=2**30 && Data<=2**31-1) f_Data2W=31;     //1073741824
    if(Data>=2**31 && Data<=2**32-1) f_Data2W=32;     //2147483648
end
endfunction

endmodule


//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
module mux_byte__AHDUDP
#( parameter MAX_BYTE_NUM = 10 )
(
input  [MAX_BYTE_NUM*8-1:0]         PDATA_I,
input  [f_Data2W(MAX_BYTE_NUM)-1:0] INDEX_I,
output [7:0] BYTE_O
);
`define SINGLE_TO_BI_Nm1To0(a,b,in,out)  generate for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate
genvar i,j,k;
wire [7:0] pdata_m [0:MAX_BYTE_NUM-1];
///////////////////////////////////////////////////////////////////////////////
`SINGLE_TO_BI_Nm1To0(8,MAX_BYTE_NUM,PDATA_I,pdata_m)
assign BYTE_O = pdata_m[INDEX_I];
///////////////////////////////////////////////////////////////////////////////
function [7:0] f_Data2W;
input [31:0] Data;//*****************input: 1  ~  2**32-1*********************//
begin
    if(Data>=2**0  && Data<=2**1-1 ) f_Data2W=1;      //1
    if(Data>=2**1  && Data<=2**2-1 ) f_Data2W=2;      //2
    if(Data>=2**2  && Data<=2**3-1 ) f_Data2W=3;      //4
    if(Data>=2**3  && Data<=2**4-1 ) f_Data2W=4;      //8
    if(Data>=2**4  && Data<=2**5-1 ) f_Data2W=5;      //16
    if(Data>=2**5  && Data<=2**6-1 ) f_Data2W=6;      //32
    if(Data>=2**6  && Data<=2**7-1 ) f_Data2W=7;      //64
    if(Data>=2**7  && Data<=2**8-1 ) f_Data2W=8;      //128
    if(Data>=2**8  && Data<=2**9-1 ) f_Data2W=9;      //256
    if(Data>=2**9  && Data<=2**10-1) f_Data2W=10;     //512
    if(Data>=2**10 && Data<=2**11-1) f_Data2W=11;     //1024
    if(Data>=2**11 && Data<=2**12-1) f_Data2W=12;     //2048
    if(Data>=2**12 && Data<=2**13-1) f_Data2W=13;     //4096
    if(Data>=2**13 && Data<=2**14-1) f_Data2W=14;     //8192
    if(Data>=2**14 && Data<=2**15-1) f_Data2W=15;     //16384
    if(Data>=2**15 && Data<=2**16-1) f_Data2W=16;     //32768
    if(Data>=2**16 && Data<=2**17-1) f_Data2W=17;     //65536
    if(Data>=2**17 && Data<=2**18-1) f_Data2W=18;     //131072
    if(Data>=2**18 && Data<=2**19-1) f_Data2W=19;     //262144
    if(Data>=2**19 && Data<=2**20-1) f_Data2W=20;     //524288
    if(Data>=2**20 && Data<=2**21-1) f_Data2W=21;     //1048576
    if(Data>=2**21 && Data<=2**22-1) f_Data2W=22;     //2097152
    if(Data>=2**22 && Data<=2**23-1) f_Data2W=23;     //
    if(Data>=2**23 && Data<=2**24-1) f_Data2W=24;     //
    if(Data>=2**24 && Data<=2**25-1) f_Data2W=25;     //16777216
    if(Data>=2**25 && Data<=2**26-1) f_Data2W=26;     //33554432
    if(Data>=2**26 && Data<=2**27-1) f_Data2W=27;     //67108864
    if(Data>=2**27 && Data<=2**28-1) f_Data2W=28;     //134217728
    if(Data>=2**28 && Data<=2**29-1) f_Data2W=29;     //268435456
    if(Data>=2**29 && Data<=2**30-1) f_Data2W=30;     //536870912
    if(Data>=2**30 && Data<=2**31-1) f_Data2W=31;     //1073741824
    if(Data>=2**31 && Data<=2**32-1) f_Data2W=32;     //2147483648
end
endfunction
endmodule
////////////////////////////////////////////////////////////////////////////////// 
// Create Date: 2021/11/01 17:29:23
// Design Name: 
// Module Name: clk_div_pos_neg
//////////////////////////////////////////////////////////////////////////////////
module clk_div_pos_neg__AHDUDP(
input  RST_I,
input  CLK_I,
input  [11:0] DIV_CNT_I,//must >= 2
output CLK_DIV_O,
output CLK_DIV_POS_O,
output CLK_DIV_NEG_O
);
reg clk_div = 0;
reg [11:0] Cnt = 0;
reg clk_div_buf;
wire [11:0] DIV_CNT ;
///////////////////////////////////////////////////////////////////////////////
assign CLK_DIV_O = clk_div;
assign CLK_DIV_POS_O = ( ~clk_div_buf & clk_div );
assign CLK_DIV_NEG_O = ( clk_div_buf & ~clk_div );
assign DIV_CNT = (DIV_CNT_I < 2)?2:DIV_CNT_I;
///////////////////////////////////////////////////////////////////////////////
always@(posedge CLK_I)begin
    if(RST_I)begin
        clk_div_buf <= 0;
    end
    else begin
        clk_div_buf <= clk_div; 
    end
end
///////////////////////////////////////////////////////////////////////////////
always@(posedge CLK_I)begin
    if(RST_I)begin
        clk_div <= 0;
        Cnt <= 0;
    end
    else begin
        if(Cnt< DIV_CNT>>1 )begin///////////5
            Cnt <= Cnt + 1;
            clk_div <= 0;
        end
        else if(Cnt< DIV_CNT )begin/////10
            Cnt <= Cnt + 1;
            clk_div <= 1;
        end
        else begin
            Cnt <= 1;
            clk_div <= 0;
        end
    end
end

endmodule
