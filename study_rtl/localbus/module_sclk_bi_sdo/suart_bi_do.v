`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/23 16:49:33
// Design Name: 
// Module Name: suart_bi_do
// Project Name: 
//////////////////////////////////////////////////////////////////////////////////

/*
suart_bi_do 
    #(.MAX_BYTE_NUM(10))
    suart_bi_do_u(
    .RST_I          (),
    .SCLK_I         (),//pos cz
    .START_I        (),
    .CMD_I          (),//[1:0]  2'b00:单次写  2'b01:外部连续写
    .PDATA_I        (),//[8*MAX_BYTE_NUM-1:0]  【先发送目测【低】字节】
    .DATA_BYTE_NUM_I(),//[7:0]
    .ALMOST_PULSE_O (),
    .SCLK_O         (),
    .D1_O           (),
    .D0_O           ()
    );
*/

//S C L K【上沿】发送, 只单纯发送数据
//S C L K  _|—|_|—|_|—|_|—|_|—|_|—|_|—|_|—|_|—|_|—|_|—|_
//D 1      —————|___////////////////\\\\\\\\\\\\\\\\
//D 0      —————|___////////////////\\\\\\\\\\\\\\\\
//                  b7  b5  b3  b1  b7  b5  b3  b1  ...
//                  b6  b4  b2  b0  b6  b4  b2  b0  ...
`define SINGLE_TO_BI_Nm1To0(a,b,in,out)   generate for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate

module suart_bi_do(
input RST_I,
input SCLK_I,//pos cz
input START_I,
input [1:0] CMD_I,//2'b00:单次写  2'b01:外部连续写
input [8*MAX_BYTE_NUM-1:0] PDATA_I,//【先发送目测【低】字节】
input [7:0] DATA_BYTE_NUM_I,
output reg ALMOST_PULSE_O,
output SCLK_O,
output reg D1_O,
output reg D0_O,
output BUSY_O
);
parameter MAX_BYTE_NUM = 10;
//////////////////////////////////////////////////////////////////////////////////
assign SCLK_O = SCLK_I;
//////////////////////////////////////////////////////////////////////////////////
genvar i,j,k;
wire [7:0] ms_byte;//引出 Pdata_i 的最高字节--当Pdata_i作为写入数据字节时
wire [7:0] pdata_m [0:MAX_BYTE_NUM-1];
`SINGLE_TO_BI_Nm1To0(8,MAX_BYTE_NUM,Pdata_i,pdata_m)
assign ms_byte = pdata_m[0];//2021年12月27日13:29:40
//////////////////////////////////////////////////////////////////////////////////
reg Cs = 1;
reg FF    ;
reg Busy;
reg [9:0]  Cnt_delay;
reg Need_continue;
reg Need_continue_reset;
reg Need_stop;

always@(posedge SCLK_I)begin
    if(RST_I)begin
        Pdata_i_2 <= 0;
        Need_continue <= 0;
        Data_byte_num_i_2 <= 0;
    end
    else if(START_I & State!=0)begin
        Need_continue  <= 1;
        Pdata_i_2      <= PDATA_I;
        Data_byte_num_i_2 <= DATA_BYTE_NUM_I;
    end
    else if(Need_continue_reset)begin
        Need_continue <= 0;
    end
end

///////////////////////////////////////////////////////////////////////////////
localparam shift_out_0 = 0,
           shift_out_1 = 1,
           shift_out_2 = 2,
           shift_out_3 = 3,
           shift_out_4 = 4,
           shift_out_5 = 5,
           shift_out_6 = 6,
           shift_out_7 = 7,
           shift_out_8 = 8; 
           
reg [8*MAX_BYTE_NUM-1:0] Pdata_i;
reg [8*MAX_BYTE_NUM-1:0] Pdata_i_2;
reg [7:0] State;
reg [7:0]  Data_byte_num_i;reg [7:0]  Data_byte_num_left;
reg [7:0]  Data_byte_num_i_2;
reg [7:0]  Shift_out_8;
reg [1:0]  Cmd_i;

assign BUSY_O = Busy | START_I;
always@(posedge SCLK_I)begin
    if(RST_I)begin
        State <= 0;
        Data_byte_num_i <= 0;
        {D1_O,D0_O} <= 2'b11;
        ALMOST_PULSE_O <= 0;
        Busy <= 0;
    end
    else begin
        case(State)
            0:begin
                if(START_I)begin
                   Data_byte_num_i <=  DATA_BYTE_NUM_I;
                   Pdata_i    <=  PDATA_I;//posedge 后 ms_byte
                   Cmd_i      <=  CMD_I;
                   Busy <= 1;
                   State      <=  1;
                end
            end
            1:begin
                case(Cmd_i)
                    2'b00:begin//单次写
                        Data_byte_num_left <= Data_byte_num_i;
                        State <= 2;
                    end
                    2'b01:begin//外部连续
                        Data_byte_num_left <= Data_byte_num_i;
                        State <= 10;
                    end
                endcase
            end
            2:begin
                {D1_O,D0_O} <= 2'b00;
                State <= 3;
            end
            3:begin
                {D1_O,D0_O} <= ms_byte[7:6];
                State <= 4;
            end
            4:begin
                {D1_O,D0_O} <= ms_byte[5:4];
                State <= 5;
            end
            5:begin
                {D1_O,D0_O} <= ms_byte[3:2];
                State <= 6;
            end
            6:begin
                {D1_O,D0_O} <= ms_byte[1:0];
                
                if(Data_byte_num_left==1)begin
                    State <= 7;
                end
                else begin
                    Pdata_i <= Pdata_i>>8;
                    Data_byte_num_left <= Data_byte_num_left - 1;
                    State <= 3;
                end
            end
            7:begin
                {D1_O,D0_O} <= 2'b11;
                Busy <= 0;
                State <= 0;
            end
            ////////////////////////////////////////////////////////////////////////
            10:begin
                {D1_O,D0_O} <= 2'b00;
                State <= 11;
            end
            11:begin
                Need_continue_reset <= 0;
                {D1_O,D0_O} <= ms_byte[7:6];
                if(Data_byte_num_left==1)begin
                    ALMOST_PULSE_O <= 1;
                end
                State <= 12;
            end
            12:begin
                {D1_O,D0_O} <= ms_byte[5:4];
                if(Data_byte_num_left==1)begin
                    ALMOST_PULSE_O <= 0;
                end
                State <= 13;
            end
            13:begin
                {D1_O,D0_O} <= ms_byte[3:2];
                State <= 14;
            end
            14:begin
                {D1_O,D0_O} <= ms_byte[1:0];
                if(Data_byte_num_left==1)begin
                    if(Need_continue)begin
                        Need_continue_reset  <= 1;
                        Pdata_i             <= Pdata_i_2;      //加载下一个周期的数据
                        Data_byte_num_i     <= Data_byte_num_i_2;
                        Data_byte_num_left  <= Data_byte_num_i_2;
                        State <= 11;
                    end
                    else begin
                        State <= 15;
                    end
                end
                else begin
                    Pdata_i <= Pdata_i>>8;
                    Data_byte_num_left <= Data_byte_num_left - 1;
                    State <= 11;
                end
            end
            15:begin
                {D1_O,D0_O} <= 2'b11;
                Busy <= 0;
                State <= 0;
            end
        endcase
    end
end



endmodule
