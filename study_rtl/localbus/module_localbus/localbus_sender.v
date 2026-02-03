`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  phiyo, yzhu
// Create Date: 2021/11/07 18:20:18
// Module Name: localbus_sender
//////////////////////////////////////////////////////////////////////////////////
//localbus_sender
//    #(.MAX_UNIT_NUM(4), 
//      .UNIT_BIT_NUM(32))  
//     localbus_sender_u(
//    .RST_I           (RST_I),
//    .CLK_I           (CLK_I),
//    .PDATA_I         (),//[MAX_UNIT_NUM*UNIT_BIT_NUM-1:0]
//    .VALID_UNIT_NUM_I(),//[7:0]
//    .START_I         (),
//    .CLK_O           (),
//    .DE_O            (),
//    .DQ0_O           (),
//    .DQ1_O           (),
//    .ALMOST_PULSE_O  (),
//    .BUSY_O          (),
//    ..CONTINUE_I     ());
    
module localbus_sender(
input                                 RST_I,
input                                 CLK_I,  //【上沿操作】
input [MAX_UNIT_NUM*UNIT_BIT_NUM-1:0] PDATA_I,//【先发目测低单元】
input [7:0]                           VALID_UNIT_NUM_I,
input                                 START_I,
output                                CLK_O,  //【=~CLK_I】
output reg                            DE_O,   //【数据和CLK_I下沿对齐】
output reg                            DQ0_O,  //30 28 ... 0   30 28 ... 0  ... ...
output reg                            DQ1_O,  //31 29 ... 1   31 29 ... 1  ... ...
output reg                            ALMOST_PULSE_O,
output                                BUSY_O,
input                                 CONTINUE_I//DEFAULT:0
);
parameter MAX_UNIT_NUM = 4; 
parameter UNIT_BIT_NUM = 32;//【must==even】; when>=8,almost操作模式工作正常 
///////////////////////////////////////////////////////////////////////////////
assign CLK_O = ~CLK_I;
///////////////////////////////////////////////////////////////////////////////
genvar i,j,k;
`define SINGLE_TO_BI_Nm1To0(a,b,in,out)    generate for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate
///////////////////////////////////////////////////////////////////////////////
assign BUSY_O = Busy | START_I;
///////////////////////////////////////////////////////////////////////////////
wire [31:0]  rg_qspi_m [MAX_UNIT_NUM-1:0];
`SINGLE_TO_BI_Nm1To0(UNIT_BIT_NUM,MAX_UNIT_NUM,PDATA_I,rg_qspi_m) 
reg  [31:0]  Rg_qspi_buf_m [MAX_UNIT_NUM-1:0];
reg  [31:0]  Rg_qspi_buf_m_2 [MAX_UNIT_NUM-1:0];
reg  [7:0] q ;
reg  Need_continue;
reg  Need_continue_reset;
reg  Last_bit;
reg  [7:0] Rg_num_i;
reg  [7:0] Rg_num_i_2;
reg  [7:0] Cnt_byte;
reg  [7:0] Cnt_bit;
reg  [7:0] Cnt_delay;
reg  Busy;
(*mark_debug="true"*)reg  [7:0] State;
///////////////////////////////////////////////////////////////////////////////
always@(posedge CLK_I)begin
    if(RST_I)begin
        Need_continue <= 0;
        Rg_num_i_2 <= 0;
        for(q=0;q<MAX_UNIT_NUM;q=q+1)begin
            Rg_qspi_buf_m_2[q]<=0;
        end
    end
    else begin
        if(START_I && State==1 && CONTINUE_I==1)begin//注释：在 State 1 中才置连续标志
            Rg_num_i_2 <= VALID_UNIT_NUM_I;
            for(q=0;q<MAX_UNIT_NUM;q=q+1)begin
                Rg_qspi_buf_m_2[q] <= rg_qspi_m[q];
            end
            if(VALID_UNIT_NUM_I!=0)begin
                Need_continue <= 1;
            end
        end
        else if(Need_continue_reset)begin
            Need_continue <= 0;
        end
    end
end
///////////////////////////////////////////////////////////////////////////////
always@(posedge CLK_I)begin
    if(RST_I)begin
        State            <= 0;
        Busy             <= 0;
        Cnt_bit          <= 0;
        Cnt_byte         <= 0;
        Last_bit         <= 0;
        ALMOST_PULSE_O   <= 0;
        DQ0_O            <= 0;
        DQ1_O            <= 0;
        DE_O             <= 0;
        Cnt_delay        <= 0;
        Need_continue_reset <= 0;
        Rg_num_i         <= 0;
    end
    else begin
        case(State)
            0:begin
                DE_O  <= 0;
                DQ0_O <= 0;
                DQ1_O <= 0;
                Last_bit <= 0;
                if(START_I)begin
                    Busy <= 1;
                    if(VALID_UNIT_NUM_I!=0)begin
                        Rg_num_i <= VALID_UNIT_NUM_I;
                    end
                    else begin
                        Rg_num_i <= 1;
                    end
                    for(q=0;q<MAX_UNIT_NUM;q=q+1)begin
                        Rg_qspi_buf_m[q] <= rg_qspi_m[q];
                    end
                    Cnt_bit  <= UNIT_BIT_NUM - 1;
                    Cnt_byte <= VALID_UNIT_NUM_I;
                   
                    State <= 1;
                    
                end     
            end
            1:begin
                DE_O <= 1;
                DQ1_O <= Rg_qspi_buf_m[Rg_num_i-Cnt_byte][Cnt_bit];
                DQ0_O <= Rg_qspi_buf_m[Rg_num_i-Cnt_byte][Cnt_bit-1];
                //用户：可以根据需要修改 -3 -5 -7 ...
                if((Cnt_bit==UNIT_BIT_NUM-3)&& Cnt_byte==1)ALMOST_PULSE_O <= 1;
                else ALMOST_PULSE_O <= 0;
                
                if(Cnt_bit==1)begin
                    if(Cnt_byte==1 && Need_continue)begin//注释：需要继续发送
                        Need_continue_reset <= 1;
                        for(q=0;q<MAX_UNIT_NUM;q=q+1)begin
                            Rg_qspi_buf_m[q] <= Rg_qspi_buf_m_2[q];
                        end
                        Last_bit  <= 1;
                        Cnt_byte  <= Rg_num_i_2;
                        Rg_num_i  <= Rg_num_i_2;
                        Cnt_bit   <= UNIT_BIT_NUM - 1;
                        State     <= 1;
                    end
                    else if(Cnt_byte==1)begin//注释：不需要继续发送
                        Cnt_byte <= 0;
                        Cnt_bit  <= 0;
                        Busy     <= 1;
                        Last_bit <= 1;
                        Cnt_delay <= 3;//as you wish
                        State     <= 2;//jump out
                    end
                    else begin//注释：发送本轮中下一个字节
                        Cnt_byte <= Cnt_byte - 1; 
                        Cnt_bit  <= UNIT_BIT_NUM - 1;
                        State    <= 1;
                    end
                end
                else begin
                    Need_continue_reset <= 0;//不清零就会过早把 Need_continue 清零，导致连续发送被中断
                    Last_bit <= 0;
                    Cnt_bit  <= Cnt_bit - 2;
                    State    <= 1;
                end
            end
            2:begin
                DE_O  <= 0;
                DQ0_O <= 0;
                DQ1_O <= 0;
                Last_bit <= 0;
                if(Cnt_delay==0)begin
                    State <= 0;
                    Busy <= 0;
                end
                else begin
                    Cnt_delay <= Cnt_delay - 1;
                end
            end
            default:begin
                State            <= 0;
                Busy             <= 0;
                Cnt_bit          <= 0;
                Cnt_byte         <= 0;
                Last_bit         <= 0;
                ALMOST_PULSE_O  <= 0;
                DQ0_O            <= 0;
                DQ1_O            <= 0;
                DE_O             <= 0;
                Cnt_delay        <= 0;
                Need_continue_reset <= 0;
                Rg_num_i         <= 0;
            end
        endcase
    end
end

endmodule
