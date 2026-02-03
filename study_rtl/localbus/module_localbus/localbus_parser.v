`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2021/10/19 13:30:06
// Design Name: 
// Module Name: localbus_parsr 一次解析的分区数可配置
//////////////////////////////////////////////////////////////////////////////////
//localbus_parser
//    #(.MODE(),//0:DE_I拉低时解析不终止; 1:DE_I拉低时解析终止
//      .UNIT_BIT_NUM())
//    localbus_parser_u  (
//    .RST_I         (),
//    .CLK_I         (),//【每个分组中,先收到的放在LB_低位(即LB_0)】
//    .DE_I          (),//【数据中心和CLK_I上升沿对齐】
//    .DQ0_I         (),//b30 ... b6 b4 b2 b0  b30 ... b6 b4 b2 b0 
//    .DQ1_I         (),//b31 ... b7 b5 b3 b1  b31 ... b7 b5 b3 b1    
//    .ENABLE_I      (),
//    .LB_FINISH_0_O (),
//    .LB_DATA_0_O   (),
//    .LB_FINISH_1_O (),
//    .LB_DATA_1_O   (),
//    .LB_FINISH_2_O (),
//    .LB_DATA_2_O   (),
//    .LB_FINISH_3_O (),
//    .LB_DATA_3_O   (),
//    .UNIT_NUM_I    (),//【每次UNIT数(1~4)】
//    .CYCLE_NUM_I   () //【解析次数】
//    );
//


module localbus_parser(
RST_I         ,
CLK_I         ,//【每个分组中,先收到的放在LB_低位(即LB_0)】
DE_I          ,//【数据中心和CLK_I上升沿对齐】
DQ0_I         ,//b30 ... b6 b4 b2 b0  b30 ... b6 b4 b2 b0 
DQ1_I         ,//b31 ... b7 b5 b3 b1  b31 ... b7 b5 b3 b1    
ENABLE_I      ,
LB_FINISH_0_O ,
LB_DATA_0_O   ,
LB_FINISH_1_O ,
LB_DATA_1_O   ,
LB_FINISH_2_O ,
LB_DATA_2_O   ,
LB_FINISH_3_O ,
LB_DATA_3_O   ,
UNIT_NUM_I    ,//【每次UNIT数(1~4)】
CYCLE_NUM_I    //【解析次数】
);
parameter [0:0] MODE = 0;//0:DE_I拉低时解析不终止; 1:DE_I拉低时解析终止
parameter UNIT_BIT_NUM = 32;
///////////////////////////////////////////////////////////////////////////////////////////////////
input RST_I;
input CLK_I;
input DE_I ;
input DQ0_I;
input DQ1_I;
input ENABLE_I;
output reg                  LB_FINISH_0_O ;
output   [UNIT_BIT_NUM-1:0] LB_DATA_0_O   ;
output reg                  LB_FINISH_1_O ;
output   [UNIT_BIT_NUM-1:0] LB_DATA_1_O   ;
output reg                  LB_FINISH_2_O ;
output   [UNIT_BIT_NUM-1:0] LB_DATA_2_O   ;
output reg                  LB_FINISH_3_O ;
output   [UNIT_BIT_NUM-1:0] LB_DATA_3_O   ;
input    [7:0]  UNIT_NUM_I   ;
input    [15:0] CYCLE_NUM_I  ;
///////////////////////////////////////////////////////////////////////////////////////////////////
wire [15:0] normalization_rg_num;
assign normalization_rg_num = CYCLE_NUM_I;

///////////////////////////////////////////////////////////////////////////////////////////////////
reg [UNIT_BIT_NUM-1:0] Lb_data [0:3];
assign LB_DATA_0_O  = Lb_data[0];
assign LB_DATA_1_O  = Lb_data[1];
assign LB_DATA_2_O  = Lb_data[2];
assign LB_DATA_3_O  = Lb_data[3];

reg FF;
(*mark_debug="true"*)reg [7:0] State;
reg [7:0]  Sub_state;
reg [7:0]  Cnt_zunei;//每次解析几个分区，计数
reg [7:0]  Cnt_bit;
reg [15:0] Cnt_cycle;
reg [UNIT_BIT_NUM-1:0] Lb_buf;
localparam  shift_in_0  = 0,
            shift_in_2  = 1,
            shift_in_4  = 2,
            shift_in_6  = 3,
            shift_in_8  = 4,
            shift_in_10 = 5,
            shift_in_12 = 6,
            shift_in_14 = 7,
            shift_in_16 = 8,
            shift_in_18 = 9,
            shift_in_20 = 10,
            shift_in_22 = 11,
            shift_in_24 = 12,
            shift_in_26 = 13,
            shift_in_28 = 14,
            shift_in_30 = 15,
            shift_in_32 = 16;

task t_reset;
begin
    FF          <= 0;
    State       <= 0;
    Sub_state   <= 0;
    Cnt_bit     <= 0;
    Cnt_cycle   <= 0; 
    Cnt_zunei   <= 0;
    Lb_buf <= 0;  
    
    LB_FINISH_0_O <= 0;
    LB_FINISH_1_O <= 0;
    LB_FINISH_2_O <= 0;
    LB_FINISH_3_O <= 0;
    
    Lb_data[0]  <= 0;
    Lb_data[1]  <= 0;
    Lb_data[2]  <= 0;
    Lb_data[3]  <= 0;
end
endtask
          
always@(posedge CLK_I)begin
    if(RST_I)begin
        t_reset;
    end
    else begin
        case(State)
            0:begin
                LB_FINISH_0_O <= 0;
                LB_FINISH_1_O <= 0;
                LB_FINISH_2_O <= 0;
                LB_FINISH_3_O <= 0;
                if(DE_I & ENABLE_I & (UNIT_NUM_I>0))begin
                    Lb_buf      <= {Lb_buf[UNIT_BIT_NUM-2:0],DQ1_I,DQ0_I};
                    Sub_state   <= shift_in_2;
                    State       <= 1;
                    Cnt_cycle   <= CYCLE_NUM_I;
                    Cnt_zunei   <= UNIT_NUM_I;
                    FF <= 1;
                end
            end
            1:begin
                if(FF)t_receive_one_byte;
                else begin//收到一个分区
                    if(Cnt_zunei == 0)begin//根据spi数收到一组分区
                        if(Cnt_cycle == 1)begin
                            Lb_data[UNIT_NUM_I-Cnt_zunei-1] <= Lb_buf;
                            LB_FINISH_0_O <=                         1 ;
                            LB_FINISH_1_O <= (UNIT_NUM_I < 2) ? 0 :  1 ;
                            LB_FINISH_2_O <= (UNIT_NUM_I < 3) ? 0 :  1 ;
                            LB_FINISH_3_O <= (UNIT_NUM_I < 4) ? 0 :  1 ;
                              
                            State <= 0;
                        end
                        else begin
                            Cnt_cycle   <= Cnt_cycle - 1; 
                            Lb_data[UNIT_NUM_I-Cnt_zunei-1] <= Lb_buf;
                            
                            LB_FINISH_0_O <=                        1;
                            LB_FINISH_1_O <= (UNIT_NUM_I < 2) ? 0 : 1;
                            LB_FINISH_2_O <= (UNIT_NUM_I < 3) ? 0 : 1;
                            LB_FINISH_3_O <= (UNIT_NUM_I < 4) ? 0 : 1;
                            
                            if(MODE==0)begin//de拉低继续解析
                                Lb_buf <= {Lb_buf[UNIT_BIT_NUM-2:0],DQ1_I,DQ0_I};
                                FF        <= 1;
                                State     <= State; 
                                Cnt_zunei <= UNIT_NUM_I;
                                Sub_state <= shift_in_2;
                            end
                            else begin//de拉低停止解析
                                if(DE_I)begin
                                    Lb_buf <= {Lb_buf[UNIT_BIT_NUM-2:0],DQ1_I,DQ0_I};
                                    FF        <= 1;
                                    State     <= State; 
                                    Cnt_zunei <= UNIT_NUM_I;
                                    Sub_state <= shift_in_2;
                                end
                                else begin
                                    State     <= 0; 
                                end
                            end
                        end
                    end
                    else begin
                        Lb_data[UNIT_NUM_I-Cnt_zunei-1] <= Lb_buf;
                        Lb_buf <= {Lb_buf[UNIT_BIT_NUM-2:0],DQ1_I,DQ0_I};
                        FF        <= 1;
                        State     <= State;  
                        Sub_state <= shift_in_2;
                    end
                end
            end      
            default:begin
               t_reset;               
            end
        endcase
    end
end

task t_receive_one_byte;
begin
    case(Sub_state)
        shift_in_0 :begin
            LB_FINISH_0_O <= 0;
            LB_FINISH_1_O <= 0;
            LB_FINISH_2_O <= 0;
            LB_FINISH_3_O <= 0;
            Lb_buf <= {Lb_buf[UNIT_BIT_NUM-2:0],DQ1_I,DQ0_I};
            Sub_state <= shift_in_2;
        end
        shift_in_2 :begin
            LB_FINISH_0_O <= 0;
            LB_FINISH_1_O <= 0;
            LB_FINISH_2_O <= 0;
            LB_FINISH_3_O <= 0;
            Lb_buf <= {Lb_buf[UNIT_BIT_NUM-2:0],DQ1_I,DQ0_I};
            Sub_state <= shift_in_4;
        end
        shift_in_4 :begin
            LB_FINISH_0_O <= 0;
            LB_FINISH_1_O <= 0;
            LB_FINISH_2_O <= 0;
            LB_FINISH_3_O <= 0;
            Lb_buf <= {Lb_buf[UNIT_BIT_NUM-2:0],DQ1_I,DQ0_I};
            Sub_state <= shift_in_6;
        end
        shift_in_6 :begin
            LB_FINISH_0_O <= 0;
            LB_FINISH_1_O <= 0;
            LB_FINISH_2_O <= 0;
            LB_FINISH_3_O <= 0;
            Lb_buf <= {Lb_buf[UNIT_BIT_NUM-2:0],DQ1_I,DQ0_I};
            Sub_state <= shift_in_8;
        end
        shift_in_8 :begin
            LB_FINISH_0_O <= 0;
            LB_FINISH_1_O <= 0;
            LB_FINISH_2_O <= 0;
            LB_FINISH_3_O <= 0;
            Lb_buf <= {Lb_buf[UNIT_BIT_NUM-2:0],DQ1_I,DQ0_I};
            Sub_state <= shift_in_10;
        end
        shift_in_10:begin
            LB_FINISH_0_O <= 0;
            LB_FINISH_1_O <= 0;
            LB_FINISH_2_O <= 0;
            LB_FINISH_3_O <= 0;
            Lb_buf <= {Lb_buf[UNIT_BIT_NUM-2:0],DQ1_I,DQ0_I};
            Sub_state <= shift_in_12;
        end
        shift_in_12:begin
            LB_FINISH_0_O <= 0;
            LB_FINISH_1_O <= 0;
            LB_FINISH_2_O <= 0;
            LB_FINISH_3_O <= 0;
            Lb_buf <= {Lb_buf[UNIT_BIT_NUM-2:0],DQ1_I,DQ0_I};
            Sub_state <= shift_in_14;
        end
        shift_in_14:begin
            LB_FINISH_0_O <= 0;
            LB_FINISH_1_O <= 0;
            LB_FINISH_2_O <= 0;
            LB_FINISH_3_O <= 0;
            Lb_buf <= {Lb_buf[UNIT_BIT_NUM-2:0],DQ1_I,DQ0_I};
            Sub_state <= shift_in_16;
        end
        shift_in_16:begin
            LB_FINISH_0_O <= 0;
            LB_FINISH_1_O <= 0;
            LB_FINISH_2_O <= 0;
            LB_FINISH_3_O <= 0;
            Lb_buf <= {Lb_buf[UNIT_BIT_NUM-2:0],DQ1_I,DQ0_I};
            Sub_state <= shift_in_18;
        end
        shift_in_18:begin
            LB_FINISH_0_O <= 0;
            LB_FINISH_1_O <= 0;
            LB_FINISH_2_O <= 0;
            LB_FINISH_3_O <= 0;
            Lb_buf <= {Lb_buf[UNIT_BIT_NUM-2:0],DQ1_I,DQ0_I};
            Sub_state <= shift_in_20;
        end
        shift_in_20:begin
            LB_FINISH_0_O <= 0;
            LB_FINISH_1_O <= 0;
            LB_FINISH_2_O <= 0;
            LB_FINISH_3_O <= 0;
            Lb_buf <= {Lb_buf[UNIT_BIT_NUM-2:0],DQ1_I,DQ0_I};
            Sub_state <= shift_in_22;
        end
        shift_in_22:begin
            LB_FINISH_0_O <= 0;
            LB_FINISH_1_O <= 0;
            LB_FINISH_2_O <= 0;
            LB_FINISH_3_O <= 0;
            Lb_buf <= {Lb_buf[UNIT_BIT_NUM-2:0],DQ1_I,DQ0_I};
            Sub_state <= shift_in_24;
        end
        shift_in_24:begin
            LB_FINISH_0_O <= 0;
            LB_FINISH_1_O <= 0;
            LB_FINISH_2_O <= 0;
            LB_FINISH_3_O <= 0;
            Lb_buf <= {Lb_buf[UNIT_BIT_NUM-2:0],DQ1_I,DQ0_I};
            Sub_state <= shift_in_26;
        end
        shift_in_26:begin
            LB_FINISH_0_O <= 0;
            LB_FINISH_1_O <= 0;
            LB_FINISH_2_O <= 0;
            LB_FINISH_3_O <= 0;
            Lb_buf <= {Lb_buf[UNIT_BIT_NUM-2:0],DQ1_I,DQ0_I};
            Sub_state <= shift_in_28;
        end
        shift_in_28:begin
            LB_FINISH_0_O <= 0;
            LB_FINISH_1_O <= 0;
            LB_FINISH_2_O <= 0;
            LB_FINISH_3_O <= 0;
            Lb_buf <= {Lb_buf[UNIT_BIT_NUM-2:0],DQ1_I,DQ0_I};
            Sub_state <= shift_in_30;
        end
        shift_in_30:begin
            LB_FINISH_0_O <= 0;
            LB_FINISH_1_O <= 0;
            LB_FINISH_2_O <= 0;
            LB_FINISH_3_O <= 0;
            Lb_buf <= {Lb_buf[UNIT_BIT_NUM-2:0],DQ1_I,DQ0_I};
            Sub_state <= shift_in_0;
            FF <= 0;
            Cnt_zunei <= Cnt_zunei - 1;
        end
    endcase
end
endtask

endmodule
