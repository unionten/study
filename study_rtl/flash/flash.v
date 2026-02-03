`timescale 1ns / 1ps
`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define NEG_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate

//flash_top CMD table FOR USER
`define CMD_WR  8'd0
`define CMD_RD  8'd1
`define CMD_SE  8'd2
`define CMD_BE  8'd3
 
 
//note: 顶层操作全部由底层操作组合
//flash_core CMD table 
`define CMD_CORE_WREN   7'd1
`define CMD_CORE_SE     7'd2
`define CMD_CORE_BE     7'd3
`define CMD_CORE_WR_S   7'd7
`define CMD_CORE_RD     7'd8
`define CMD_CORE_RFSR   7'd9
`define CMD_CORE_WR_OC  7'd10 



/////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// 
// Create Date: 2023/08/16 11:12:52
// Design Name: 
// Module Name: flash
// Project Name: 
/////////////////////////////////////////////////////////////////////////////


module flash(
input  SYS_RST_I    ,
input  SYS_CLK_I    ,
output FLASH_CLK_O  ,
output FLASH_CS_O   ,
output FLASH_D0_O   ,
input  FLASH_D1_I   ,
output FLASH_WP_O   ,
output FLASH_HOLD_O ,
input  [7:0] CMD_I  ,
input        START_I,
input  [23:0] ADDR_I,
input  [$clog2(C_MAX_BYTE_NUM):0] BYTE_NUM_I ,
input  [C_MAX_BYTE_NUM*8-1:0]     PDATA_I    , 
output reg [C_MAX_BYTE_NUM*8-1:0] PDATA_O = 0, //超出有效字节范围的内容无效
output     BUSY_O,
output reg FINISH_O = 0 //when any op is done

);

//when MAX_BYTE=8; LUT=390 FF=719
//when MAX_BYTE=1; LUT=292 FF=317 / 340 334

parameter C_MAX_BYTE_NUM  = 1;//must >= 1
parameter C_CLK_DIV       = 10;//must >= 2
parameter [0:0]  C_INIT_ENABLE = 1;
parameter [23:0] C_INIT_ADDR   = 24'hFF0000;//上电读取默认地址
parameter        C_INIT_BYTE_NUM = 1 ;//must <= C_MAX_BYTE_NUM
parameter [7:0]  C_INIT_TIMES    = 4 ; // >= 0 and <= 255 ; default=3 ; 
parameter [15:0] C_INIT_DELAY_SYS_CLK_NUM = 50;//>=0 ; 只针对上电读取 (when C_INIT_ENABLE==1); 不过感觉和延迟关系不大

parameter [15:0] C_CS_BEGIN_PROTECT_DELAY_SYS_CLK_NUM = 15;//>=0 and <=65535 
parameter [15:0] C_CS_END_PROTECT_DELAY_SYS_CLK_NUM   = 15;//>=0 and <=65535 
parameter [15:0] C_BUSY_PROTECT_DELAY_SYS_CLK_NUM     = 15;//>=0 and <=65535 

/////////////////////////////////////////////////////////////////////////////
assign FLASH_WP_O   = 1;
assign FLASH_HOLD_O = 1;

reg  [7:0] cnt_rd_left = 0;
reg  [6:0] flash_cmd = 0;
reg  flash_start = 0;
reg  [23:0] flash_addr = 0;
reg  [C_MAX_BYTE_NUM*8-1:0] flash_pdata_i = 0;
reg  [$clog2(C_MAX_BYTE_NUM):0] flash_num = 0;//全部统一为 $clog2(C_MAX_BYTE_NUM)
wire [C_MAX_BYTE_NUM*8-1:0]  flash_pdata_o;
wire flash_busy;
wire flash_finish;
wire flash_almost_pulse;
wire start_pos;
reg [7:0] Cmd_i=0;
reg [23:0] Addr_i =0;
reg [$clog2(C_MAX_BYTE_NUM):0]  Bytes_i =0;
reg [C_MAX_BYTE_NUM*8-1:0] Pdata_i = 0;
reg [7:0] state = 0;
reg Busy = 0;
reg init_done = 0;
reg spec_done = 0;//上电额外写
reg [15:0] cnt_delay = 0;

assign BUSY_O = Busy | START_I;


flash_core  
    #(.MAX_BYTE_NUM(C_MAX_BYTE_NUM),
      .CS_BEGIN_PROTECT_DELAY_SYS_CLK_NUM(C_CS_BEGIN_PROTECT_DELAY_SYS_CLK_NUM ),
      .CS_END_PROTECT_DELAY_SYS_CLK_NUM  (C_CS_END_PROTECT_DELAY_SYS_CLK_NUM   ),
      .BUSY_PROTECT_DELAY_SYS_CLK_NUM    (C_BUSY_PROTECT_DELAY_SYS_CLK_NUM     )
    ) 
    flash_core_u(
    .CLK_I         (SYS_CLK_I      ),
    .RST_I         (SYS_RST_I      ),
    .CMD_I         (flash_cmd      ),
    .START_I       (flash_start    ),
    .DIV_CNT_I     (C_CLK_DIV      ),
    .FLASH_CS_O    (FLASH_CS_O     ),
    .FLASH_SCK_O   (FLASH_CLK_O    ),
    .FLASH_DQ0_O   (FLASH_D0_O     ),
    .FLASH_DQ1_I   (FLASH_D1_I     ),
    .ADDR_I        (flash_addr     ), 
    .PDATA_I       (flash_pdata_i  ), 
    .BYTE_NUM_I    (flash_num      ),    
    .PDATA_O       (flash_pdata_o  ),
    .BUSY_O        (flash_busy     ),
    .FINISH_O      (flash_finish   ),
    .ALMOST_PULSE_O(flash_almost_pulse)
    );


`POS_MONITOR_OUTGEN(SYS_CLK_I,0,START_I,start_pos)


always@(posedge SYS_CLK_I)begin
    if(SYS_RST_I)begin
        state <= 0;
        Cmd_i <= 0;
        flash_cmd <= 0;
        flash_start <= 0;
        flash_addr <= 0;
        flash_pdata_i <= 0;
        flash_num <= 0;
        Busy <= 0;
        FINISH_O <= 0;
        PDATA_O <= 0;
        init_done <= 0;
        cnt_delay <= 0;
        spec_done <= 0;
    end
    else begin
        case(state)
            0:begin
                FINISH_O    <= 0;
                flash_start <= 0;
                if(init_done==0 & C_INIT_ENABLE)begin
                    Busy    <= 1;
                    cnt_rd_left <= C_INIT_TIMES ;
                    cnt_delay   <= C_INIT_DELAY_SYS_CLK_NUM;
                    state       <= 20;
                end
                else begin
                    if(start_pos )begin
                        Busy    <= 1;
                        Cmd_i   <= CMD_I;
                        Pdata_i <= PDATA_I;
                        Addr_i  <= ADDR_I;
                        Bytes_i <= BYTE_NUM_I;
                        state   <= 1;
                    end
                end
            end
            1:begin
                case(Cmd_i)
                    `CMD_WR :begin
                        state <= 2;
                    end
                    `CMD_RD :begin
                        state <= 7;
                    end
                    `CMD_SE :begin
                        state <= 2;
                    end
                    `CMD_BE :begin
                        state <= 2;
                    end
                    default:;
                endcase
            end
            2:begin
                flash_cmd   <= `CMD_CORE_WREN;
                flash_start <= 1;
                state       <= 3;
            end
            3:begin
                flash_start <= 0;
                state <= flash_busy==0 ? 4 : state;
            end
            4:begin//所有 "类写" 操作 - 分支
                case(Cmd_i)
                    `CMD_WR: begin 
                        flash_cmd  <= `CMD_CORE_WR_S;
                        flash_addr <= Addr_i ;
                        flash_num  <= Bytes_i ;
                        flash_pdata_i <= Pdata_i;
                    end
                    `CMD_SE: begin 
                        flash_cmd  <= `CMD_CORE_SE;
                        flash_addr <= Addr_i ;
                    end
                    `CMD_BE: begin
                        flash_cmd <= `CMD_CORE_BE;
                    end
                    default: begin  
                        flash_cmd  <= `CMD_CORE_WR_S;
                        flash_addr <= Addr_i ;
                        flash_num  <= Bytes_i ;
                        flash_pdata_i <= Pdata_i;
                    end
                endcase
                flash_start <= 1;
                state <= 5;
            end
            5:begin//读取 RFSR ,判断操作是否完成
                if(flash_busy==0)begin
                    flash_cmd   <= `CMD_CORE_RFSR;//特殊指令不需要 addr 和 num
                    flash_start <= 1;
                    state <= 6;
                end
                else begin
                    flash_start <= 0;
                end
            end
            6:begin
                flash_start <= 0; 
                if(flash_finish)begin
                    if(flash_pdata_o[7])begin
                        FINISH_O <= 1;
                        Busy  <= 0;
                        state <= 0;
                    end
                    else begin
                        state <= 5;
                    end
                end
            end
            7:begin
                flash_cmd   <= `CMD_CORE_RD;
                flash_addr  <= Addr_i;
                flash_num   <= Bytes_i;
                flash_start <= 1;
                state       <= 8;
            end
            8:begin
                if(flash_finish)begin
                    init_done <= 1;
                    PDATA_O  <= flash_pdata_o ;
                    FINISH_O <= 1;
                    Busy     <= 0;
                    state    <= 0;
                end
                else begin
                    flash_start <= 0;
                end
            end
            //////////////////////////上电读/////////////////////////////
            20:begin 
                cnt_delay <= cnt_delay - 1;
                state     <= cnt_delay==0 ? 21 : state;
            end
            21:begin
                if(cnt_rd_left!=0)begin
                    cnt_rd_left <= cnt_rd_left - 1;
                    flash_cmd   <= `CMD_CORE_RD;
                    flash_addr  <= C_INIT_ADDR;
                    flash_num   <= C_INIT_BYTE_NUM;
                    flash_start <= 1;
                    state       <= 22;
                end
                else begin
                    init_done <= 1;
                    PDATA_O   <= flash_pdata_o ;
                    FINISH_O  <= 1;
                    Busy      <= 0;
                    state     <= 0;
                end
            end
            22:begin
                flash_start <= 0;
                state <= flash_finish ? 21 : state; 
            end    
            default:;
        endcase
    end
end


endmodule


