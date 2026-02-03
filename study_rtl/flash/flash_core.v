`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define NEG_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate

///////////////////////////////////CORE指令表/////////////////////////////////////
`define CMD_CORE_WREN   7'd1
`define CMD_CORE_SE     7'd2
`define CMD_CORE_BE     7'd3
`define CMD_CORE_WR_S   7'd7
`define CMD_CORE_RD     7'd8
`define CMD_CORE_RFSR   7'd9
`define CMD_CORE_WR_OC  7'd10 


/////////////////////////////////////指令表///////////////////////////////////////
`define RDID      8'b10011110
`define READ      8'b00000011 
`define FASTREAD  8'b00001011 
`define DOFR      8'b00111011 
`define DIOFR     8'b10111011
`define QOFR      8'b01101011 
`define QIOFR     8'b11101011
`define ROTP      8'b01001011 
`define WREN      8'b00000110 
`define WRDI      8'b00000100 
`define PP        8'b00000010
`define DIFP      8'b10100010 
`define DIEFP     8'b11010010
`define QIFP      8'b00110010 
`define QIEFP     8'b00010010
`define POTP      8'b01000010 
`define SSE       8'b00100000
`define SE        8'b11011000
`define BE        8'b11000111
`define PER       8'b01111010
`define PES       8'b01110101 
`define RDSR      8'b00000101 
`define WRSR      8'b00000001 
`define RDLR      8'b11101000 
`define WRLR      8'b11100101 
`define RFSR      8'b01110000 
`define CLFSR     8'b01010000
`define RDNVCR    8'b10110101
`define WRNVCR    8'b10110001
`define RDVCR     8'b10000101 
`define WRVCR     8'b10000001 
`define RDVECR    8'b01100101
`define WRVECR    8'b01100001 
`define DP        8'b10111001
`define RDP       8'b10101011 
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
// Module Name:    flash_core 
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
//特别说明：不知道是什么原因，第一次写，或者第一次擦除（和写本质一样），都失败，第二次才会成功
//所以本模块上电先随便写一个ff
/*
flash_ctrl_core_spi_en 
    #(.MAX_BYTE_NUM(),
      .NUM_WIDTH(8))
    flash_ctrl_core_spi_en_u(
    .CLK_I(),
    .RST_I(),
    .CMD_I(),//[6:0]
    .START_I(),
    .DIV_CNT_I(),//[9:0] must >= 2
    .FLASH_CS_O(),
    .FLASH_SCK_O(),
    .FLASH_DQ0_O(),
    .FLASH_DQ1_I(),
    .ADDR_I(),    //写或读的地址 （FLASH协议中地址固定为3字节）
    .PDATA_I(),   //写入:PDATA_I  =  {0000000000 低地址字节(MSB格式)......高地址字节(MSB格式)}
    .BYTE_NUM_I(),//读的字节数；写的字节数，外部连续写模式时，每一轮该值都有效
    .PDATA_O(),//读出:PDATA_O  =  {0000000000 低地址字节(MSB格式)......高地址字节(MSB格式)}
    .BUSY_O(),
    .FINISH_O(),
    .ALMOST_PULSE_O()
    );
*/

module flash_core(
CLK_I          ,
RST_I          ,
CMD_I          ,
START_I        ,
DIV_CNT_I      , //[9:0] must >= 2
FLASH_CS_O     ,
FLASH_SCK_O    ,
FLASH_DQ0_O    ,
FLASH_DQ1_I    ,
ADDR_I         , //写或读的地址
PDATA_I        , //写入:PDATA_I  =  {0000000000 低地址字节(先发送)(MSB格式)......高地址字节(后发送)(MSB格式)}
BYTE_NUM_I     , //读的字节数;写的字节数,外部连续写模式时,每一轮该值都有效
PDATA_O        , //读出:PDATA_O  =  {0000000000 低地址字节(MSB格式)......高地址字节(MSB格式)}
BUSY_O         ,
FINISH_O       , //写入成功,擦除成功,读取结束 --> 发出脉冲
ALMOST_PULSE_O

);
parameter MAX_BYTE_NUM = 10;
// ——————|_________________________|———BUSY————NOT BUSY
//_______________|—|_|—|_|—|__________________
//-------CS_BEGIN-----------CS_END-BUSY_PROTECT

parameter CS_BEGIN_PROTECT_DELAY_SYS_CLK_NUM = 20 ;//in quick clk unit ; 16 bit
parameter CS_END_PROTECT_DELAY_SYS_CLK_NUM   = 20 ;//in quick clk unit
parameter BUSY_PROTECT_DELAY_SYS_CLK_NUM     = 20 ;//in quick clk unit 
///////////////////////////////////////////////////////////////////////////////
localparam NUM_WIDTH = $clog2(MAX_BYTE_NUM);//注意：这里特别把num宽度作为一个参数
///////////////////////////////////////////////////////////////////////////////
input CLK_I;
input RST_I;
input [6:0] CMD_I;
input START_I;
input [9:0] DIV_CNT_I;
output reg FLASH_CS_O;
output reg FLASH_SCK_O;
output reg FLASH_DQ0_O;
input  FLASH_DQ1_I;
output BUSY_O;
output reg FINISH_O;
input  [23:0] ADDR_I;
input  [MAX_BYTE_NUM*8-1:0] PDATA_I;
output reg [MAX_BYTE_NUM*8-1:0] PDATA_O;
input [NUM_WIDTH:0] BYTE_NUM_I;
output ALMOST_PULSE_O;

///////////////////////////////////////////////////////////////////////////////
wire [7:0] byte_high;
reg Cs_neg = 0;
reg Cs_pos = 0;
wire sck_pos;
wire sck_neg; 
reg [NUM_WIDTH:0] byte_num_i = 0; 
reg [NUM_WIDTH:0] byte_num_i_2 = 0; 
reg [7:0] state = 0;     
reg [6:0] Cmd_i = 0;
reg [23:0] Addr_i = 0;
reg [MAX_BYTE_NUM*8-1:0] Pdata_i = 0;
reg [MAX_BYTE_NUM*8-1:0] Pdata_i_2 = 0;
reg [MAX_BYTE_NUM*8-1:0] Data_r = 0;
reg [11:0] BIT_NUM = 0;
reg [11:0] bit_cnt = 0; 
reg [15:0] delay_cnt = 0;
reg [9:0]  cnt_con = 0;//连续模式下，读或写的轮数
reg [7:0]  R_INS = 0;
reg [23:0] R_ADDR = 0;
reg Busy = 0;
reg Need_continue = 0;
reg Need_continue_reset = 0;
wire  START_I_pos;
reg Almost_pulse = 0;

///////////////////////////////////////////////////////////////////////////////
always@(posedge CLK_I)begin
    if(RST_I)begin
        FLASH_SCK_O <= 0;
    end
    else begin
        if(sck_pos)begin
            FLASH_SCK_O <= 1;
        end
        else if(sck_neg)begin
            FLASH_SCK_O <= 0;
        end
    end
end
///////////////////////////////////////////////////////////////////////////////
mux_byte__fct  #(.MAX_BYTE_NUM(MAX_BYTE_NUM)) select_high_byte_u(
    .PDATA_I(Pdata_i),
    .INDEX_I(byte_num_i-1),
    .BYTE_O(byte_high));//实际用的时候只用了最高位
///////////////////////////////////////////////////////////////////////////////        
//使用 DIV_CNT_I  DIV_CNT_I/2
//先 sck_pos 后 sck_neg
pulse_rst_loop_fhsl__s__fct  pulse_rst_loop_fhsl_su0(
    .RST_I(Cs_pos),
    .CLK_I(CLK_I),
    .PULSE_O(sck_pos),
    .FIRST_DELAY_CLK_NUM_I((DIV_CNT_I)),
    .HIGH_CLK_NUM_I(1),
    .TOTAL_CLK_NUM_I((DIV_CNT_I)));
pulse_rst_loop_fhsl__s__fct  pulse_rst_loop_fhsl_su1(
    .RST_I(Cs_neg),
    .CLK_I(CLK_I),
    .PULSE_O(sck_neg),
    .FIRST_DELAY_CLK_NUM_I((DIV_CNT_I)+(DIV_CNT_I>>1)),
    .HIGH_CLK_NUM_I(1),
    .TOTAL_CLK_NUM_I((DIV_CNT_I)));
///////////////////////////////////////////////////////////////////////////////

`POS_MONITOR_OUTGEN(CLK_I,0,START_I,START_I_pos)

///////////////////////////////////////////////////////////////////////////////
always@(posedge CLK_I)begin
    if(RST_I)begin
        Need_continue <= 0;
        Pdata_i_2 <= 0;
        byte_num_i_2 <= 0;
    end
    else begin
        if(START_I_pos && state > 2)begin
            Need_continue <= 1;
            byte_num_i_2 <= BYTE_NUM_I;
            Pdata_i_2 <= PDATA_I;
        end
        else if(Need_continue_reset)begin
            Need_continue <= 0;
        end
    end
end
///////////////////////////////////////////////////////////////////////////////
`POS_MONITOR_OUTGEN(CLK_I,0,Almost_pulse,ALMOST_PULSE_O)


///////////////////////////////////////////////////////////////////////////////
task reset;
    begin
        FLASH_CS_O <= 1;
        FLASH_DQ0_O <= 0;
        Data_r <= 0;
        state <= 0;
        bit_cnt <= 0;
        cnt_con <= 0;
        PDATA_O <= 0;
        Cs_neg <= 1;
        Cs_pos <= 1;       
        Busy<= 0;
        Almost_pulse <= 0;
        FINISH_O <= 0;
        Need_continue_reset <= 0;
        delay_cnt <= 0;
    end
endtask
///////////////////////////////////////////////////////////////////////////////
assign BUSY_O = Busy | START_I;
always@(posedge CLK_I)begin
    if(RST_I)begin
        reset;
    end
    else begin
        case(state)
            0:begin
                FINISH_O <= 0;
                Cs_neg  <= 1 ;
                Cs_pos  <= 1 ;
                if(START_I_pos)begin 
                    Cmd_i      <= CMD_I;
                    Pdata_i    <= PDATA_I;       
                    Addr_i     <= ADDR_I;
                    byte_num_i <= BYTE_NUM_I;
                    Busy       <= 1;
                    state      <= 1;
                end
            end
            1:begin
                case(Cmd_i)
                    `CMD_CORE_WREN :begin R_INS <= `WREN; end
                    `CMD_CORE_SE   :begin R_INS <= `SE;   end
                    `CMD_CORE_BE   :begin R_INS <= `BE;   end
                    `CMD_CORE_WR_S :begin R_INS <= `PP;   end
                    `CMD_CORE_RD   :begin R_INS <= `READ; end
                    `CMD_CORE_RFSR :begin R_INS <= `RFSR; end
                    `CMD_CORE_WR_OC:begin R_INS <= `PP;   end
                    default        :begin R_INS <= `READ; end
                endcase
                case(Cmd_i)//bit num after INS and ADDR(maybe) operation
                    `CMD_CORE_WREN :begin BIT_NUM <= 0;            end
                    `CMD_CORE_SE   :begin BIT_NUM <= 0;            end
                    `CMD_CORE_BE   :begin BIT_NUM <= 0;            end
                    `CMD_CORE_WR_S :begin BIT_NUM <= byte_num_i*8; end
                    `CMD_CORE_RD   :begin BIT_NUM <= byte_num_i*8; end
                    `CMD_CORE_RFSR :begin BIT_NUM <= 8;            end //RFSR 
                    `CMD_CORE_WR_OC:begin BIT_NUM <= byte_num_i*8; end
                    default        :begin BIT_NUM <= 8;            end
                endcase
                state <= 2;
            end
            2:begin
                FLASH_CS_O  <= 0;
                //Cs_neg      <= 0;
                //Cs_pos      <= 0;
                FLASH_DQ0_O <= R_INS[7];
                R_INS       <= {R_INS[6:0],1'b0};
                bit_cnt     <= 7;
                state       <= 20;
                delay_cnt   <= CS_BEGIN_PROTECT_DELAY_SYS_CLK_NUM;
            end
            20:begin
                delay_cnt <= delay_cnt - 1;
                state   <= delay_cnt==0 ? 3 : state;
                Cs_neg  <= delay_cnt==0 ? 0 : 1;
                Cs_pos  <= delay_cnt==0 ? 0 : 1;
            end
            3:begin 
                if(sck_neg)begin
                    FLASH_DQ0_O <= R_INS[7];
                    R_INS <= {R_INS[6:0],1'b0};
                    if(bit_cnt==1)begin
                        case(Cmd_i)
                            `CMD_CORE_WREN :begin state <= 8; bit_cnt <= bit_cnt; R_ADDR <= R_ADDR;  end
                            `CMD_CORE_SE   :begin state <= 4; bit_cnt <= 24;      R_ADDR <= Addr_i;  end
                            `CMD_CORE_BE   :begin state <= 8; bit_cnt <= bit_cnt; R_ADDR <= R_ADDR;  end
                            `CMD_CORE_WR_S :begin state <= 4; bit_cnt <= 24;      R_ADDR <= Addr_i;  end
                            `CMD_CORE_RD   :begin state <= 4; bit_cnt <= 24;      R_ADDR <= Addr_i;  end
                            `CMD_CORE_RFSR :begin state <= 7; bit_cnt <= BIT_NUM; R_ADDR <= R_ADDR;  end
                            `CMD_CORE_WR_OC:begin state <= 4; bit_cnt <= 24;      R_ADDR <= Addr_i;  end
                            default:;
                        endcase
                    end
                    else begin
                        bit_cnt <= bit_cnt - 1;
                    end
                end
            end
            4:begin//send addr for WR and RD
                if(sck_neg)begin
                    FLASH_DQ0_O <= R_ADDR[23];
                    R_ADDR <= {R_ADDR[22:0],1'b0};
                    if(bit_cnt==1)begin
                        bit_cnt <= BIT_NUM;//还没发送的数据量 或 还没写入的数据量
                        case(Cmd_i)
                            `CMD_CORE_WR_S  : state <= 5;
                            `CMD_CORE_WR_OC : state <= 5; 
                            `CMD_CORE_RD    : state <= 7;//中转状态
                            `CMD_CORE_SE    : state <= 8;
                        endcase
                    end
                    else begin
                        bit_cnt <= bit_cnt - 1;
                    end
                end
            end
            5:begin//单次写，外部连续写
                if(Need_continue_reset)Need_continue_reset<=0;
                else if(sck_neg)begin
                    FLASH_DQ0_O <= byte_high[7]; 
                    if(bit_cnt==1)begin
                        Almost_pulse <= 0;
                        if(Cmd_i==`CMD_CORE_WR_OC)begin//外部连续写
                            if(Need_continue)begin
                                Need_continue_reset <= 1;
                                Pdata_i     <= Pdata_i_2;                        
                                bit_cnt    <= byte_num_i_2*8;
                                byte_num_i <= byte_num_i_2;
                                state   <= 5;
                            end
                            else begin
                                state <= 8;
                            end
                        end
                        else begin//单次写
                            state <= 8;
                        end
                    end
                    else if(bit_cnt==7)begin
                        Almost_pulse <= 1;
                        Pdata_i <= Pdata_i << 1;
                        bit_cnt <= bit_cnt - 1;
                    end
                    else begin
                        Almost_pulse <= 0;
                        Pdata_i <= Pdata_i << 1;
                        bit_cnt <= bit_cnt - 1;
                    end
                end
            end
            7:begin//读操作开始
                if(sck_pos)state <= 13;
            end
            13:begin//读
                if(sck_pos)begin
                    Data_r <= {Data_r[MAX_BYTE_NUM*8-2:0],FLASH_DQ1_I};
                    if(bit_cnt==1)begin
                        Cs_pos <= 1;
                        PDATA_O <= {Data_r[MAX_BYTE_NUM*8-2:0],FLASH_DQ1_I};
                        state <= 10;
                    end
                    else begin
                        bit_cnt <= bit_cnt - 1;
                    end
                end
            end
            8:begin//写后处理 1 
                if(sck_pos)begin
                    Cs_pos  <= 1;//sck_pos 先消失（为了在2分频时，SCK时序也能正确）
                    state   <= 12;
                end
            end
            12:begin
                if(sck_neg)begin
                    Cs_neg    <= 1;//随后 sck_neg 消失
                    FLASH_DQ0_O <= 0;
                    delay_cnt <= CS_END_PROTECT_DELAY_SYS_CLK_NUM;// 配置CS后延迟
                    state <= 9;
                end
            end
            //读/写后延迟
            9:begin
                if(delay_cnt==0)begin
                    FLASH_CS_O  <= 1;
                    delay_cnt     <= BUSY_PROTECT_DELAY_SYS_CLK_NUM;// 配置BUSY延迟
                    state       <= 11;
                end
                else begin
                    delay_cnt <= delay_cnt - 1;
                end
            end
            //读--然后关cs_neg
            10:begin
                
                if(sck_neg)begin
                    Cs_neg <= 1;
                    FLASH_DQ0_O <= 0;
                    delay_cnt <= CS_END_PROTECT_DELAY_SYS_CLK_NUM;// 配置CS后延迟
                    state <= 9;
                end
            end
            //Busy 延长
            11:begin
                if(delay_cnt==0)begin
                    FINISH_O <= 1; //FINISH 统一
                    Busy <= 0;
                    state <= 0;
                end
                else begin
                    delay_cnt <= delay_cnt - 1;
                end
            end
            default:begin
                reset;
            end
        endcase
    end
end

function [7:0] f_Data2W;//无符号数宽度//输入为无符号数最大值
input [31:0] Data;//*****************input: 1  ~  2**32-1*********************//
begin
    if(Data>=2**0  && Data<=2**1-1 ) f_Data2W=1;      //1~1
    if(Data>=2**1  && Data<=2**2-1 ) f_Data2W=2;      //2~3
    if(Data>=2**2  && Data<=2**3-1 ) f_Data2W=3;      //4~7
    if(Data>=2**3  && Data<=2**4-1 ) f_Data2W=4;      //8~15
    if(Data>=2**4  && Data<=2**5-1 ) f_Data2W=5;      //16~31
    if(Data>=2**5  && Data<=2**6-1 ) f_Data2W=6;      //32~63
    if(Data>=2**6  && Data<=2**7-1 ) f_Data2W=7;      //64~127
    if(Data>=2**7  && Data<=2**8-1 ) f_Data2W=8;      //128~255
    if(Data>=2**8  && Data<=2**9-1 ) f_Data2W=9;      //256~511
    if(Data>=2**9  && Data<=2**10-1) f_Data2W=10;     //512~1023
    if(Data>=2**10 && Data<=2**11-1) f_Data2W=11;     //1024~2047
	if(Data>=2**11 && Data<=2**12-1) f_Data2W=12;     //2048~4095
	if(Data>=2**12 && Data<=2**13-1) f_Data2W=13;     //4096~8191
	if(Data>=2**13 && Data<=2**14-1) f_Data2W=14;     //8192~16383
	if(Data>=2**14 && Data<=2**15-1) f_Data2W=15;     //16384~32767
	if(Data>=2**15 && Data<=2**16-1) f_Data2W=16;     //32768~65535
	if(Data>=2**16 && Data<=2**17-1) f_Data2W=17;     //65536~131071
	if(Data>=2**17 && Data<=2**18-1) f_Data2W=18;     //131072~262143
	if(Data>=2**18 && Data<=2**19-1) f_Data2W=19;     //262144~524287
	if(Data>=2**19 && Data<=2**20-1) f_Data2W=20;     //524288~1048575
	if(Data>=2**20 && Data<=2**21-1) f_Data2W=21;     //1048576~2097151
	if(Data>=2**21 && Data<=2**22-1) f_Data2W=22;     //2097152~‭4194303‬
	if(Data>=2**22 && Data<=2**23-1) f_Data2W=23;     //‭4194304‬~‬8388607
	if(Data>=2**23 && Data<=2**24-1) f_Data2W=24;     //‬8388608~16777215
	if(Data>=2**24 && Data<=2**25-1) f_Data2W=25;     //16777216~33554431
	if(Data>=2**25 && Data<=2**26-1) f_Data2W=26;     //33554432~67108863
	if(Data>=2**26 && Data<=2**27-1) f_Data2W=27;     //67108864~134217727
	if(Data>=2**27 && Data<=2**28-1) f_Data2W=28;     //134217728~268435455
	if(Data>=2**28 && Data<=2**29-1) f_Data2W=29;     //268435456~536870911
	if(Data>=2**29 && Data<=2**30-1) f_Data2W=30;     //536870912~1073741823
	if(Data>=2**30 && Data<=2**31-1) f_Data2W=31;     //1073741824~2147483647
	if(Data>=2**31 && Data<=2**32-1) f_Data2W=32;     //2147483648~4294967295
end
endfunction

endmodule

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
`define SINGLE_TO_BI_Nm1To0(a,b,in,out)   generate for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate
module mux_byte__fct
#( parameter MAX_BYTE_NUM  = 10 )
(
input  [MAX_BYTE_NUM*8-1:0] PDATA_I,
input  [f_Data2W(MAX_BYTE_NUM)-1:0] INDEX_I,
output [7:0] BYTE_O

);
genvar i,j,k;
wire [7:0] pdata_m [0:MAX_BYTE_NUM-1];
`SINGLE_TO_BI_Nm1To0(8,MAX_BYTE_NUM,PDATA_I,pdata_m)
assign BYTE_O = pdata_m[INDEX_I];

function [7:0] f_Data2W;//无符号数宽度//输入为无符号数最大值
input [31:0] Data;//*****************input: 1  ~  2**32-1*********************//
begin
    if(Data>=2**0  && Data<=2**1-1 ) f_Data2W=1;      //1~1
    if(Data>=2**1  && Data<=2**2-1 ) f_Data2W=2;      //2~3
    if(Data>=2**2  && Data<=2**3-1 ) f_Data2W=3;      //4~7
    if(Data>=2**3  && Data<=2**4-1 ) f_Data2W=4;      //8~15
    if(Data>=2**4  && Data<=2**5-1 ) f_Data2W=5;      //16~31
    if(Data>=2**5  && Data<=2**6-1 ) f_Data2W=6;      //32~63
    if(Data>=2**6  && Data<=2**7-1 ) f_Data2W=7;      //64~127
    if(Data>=2**7  && Data<=2**8-1 ) f_Data2W=8;      //128~255
    if(Data>=2**8  && Data<=2**9-1 ) f_Data2W=9;      //256~511
    if(Data>=2**9  && Data<=2**10-1) f_Data2W=10;     //512~1023
    if(Data>=2**10 && Data<=2**11-1) f_Data2W=11;     //1024~2047
	if(Data>=2**11 && Data<=2**12-1) f_Data2W=12;     //2048~4095
	if(Data>=2**12 && Data<=2**13-1) f_Data2W=13;     //4096~8191
	if(Data>=2**13 && Data<=2**14-1) f_Data2W=14;     //8192~16383
	if(Data>=2**14 && Data<=2**15-1) f_Data2W=15;     //16384~32767
	if(Data>=2**15 && Data<=2**16-1) f_Data2W=16;     //32768~65535
	if(Data>=2**16 && Data<=2**17-1) f_Data2W=17;     //65536~131071
	if(Data>=2**17 && Data<=2**18-1) f_Data2W=18;     //131072~262143
	if(Data>=2**18 && Data<=2**19-1) f_Data2W=19;     //262144~524287
	if(Data>=2**19 && Data<=2**20-1) f_Data2W=20;     //524288~1048575
	if(Data>=2**20 && Data<=2**21-1) f_Data2W=21;     //1048576~2097151
	if(Data>=2**21 && Data<=2**22-1) f_Data2W=22;     //2097152~‭4194303‬
	if(Data>=2**22 && Data<=2**23-1) f_Data2W=23;     //‭4194304‬~‬8388607
	if(Data>=2**23 && Data<=2**24-1) f_Data2W=24;     //‬8388608~16777215
	if(Data>=2**24 && Data<=2**25-1) f_Data2W=25;     //16777216~33554431
	if(Data>=2**25 && Data<=2**26-1) f_Data2W=26;     //33554432~67108863
	if(Data>=2**26 && Data<=2**27-1) f_Data2W=27;     //67108864~134217727
	if(Data>=2**27 && Data<=2**28-1) f_Data2W=28;     //134217728~268435455
	if(Data>=2**28 && Data<=2**29-1) f_Data2W=29;     //268435456~536870911
	if(Data>=2**29 && Data<=2**30-1) f_Data2W=30;     //536870912~1073741823
	if(Data>=2**30 && Data<=2**31-1) f_Data2W=31;     //1073741824~2147483647
	if(Data>=2**31 && Data<=2**32-1) f_Data2W=32;     //2147483648~4294967295
end
endfunction

endmodule

`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////////////
//first delay --- high --- low --- high ....
module pulse_rst_loop_fhsl__s__fct(
RST_I,//强制归0
CLK_I,
PULSE_O,
FIRST_DELAY_CLK_NUM_I,
HIGH_CLK_NUM_I,
TOTAL_CLK_NUM_I
);
/////////////////////////////////////////////////////////////////////////////////////////
input RST_I;
input CLK_I;
output reg PULSE_O = 0;
input [9:0] FIRST_DELAY_CLK_NUM_I;
input [9:0] HIGH_CLK_NUM_I;
input [9:0] TOTAL_CLK_NUM_I;

/////////////////////////////////////////////////////////////////////////////////////////
reg [9:0] First_delay_clk_num_i;
reg [9:0] High_clk_num_i;
reg [9:0] Total_clk_num_i;
reg [7:0] state = 1;
reg [31:0] Cnt_clk_num ;

always@(posedge CLK_I)begin
    if(RST_I)begin 
        PULSE_O <= 0;
        First_delay_clk_num_i <= FIRST_DELAY_CLK_NUM_I;
        Cnt_clk_num <= FIRST_DELAY_CLK_NUM_I -1;
        High_clk_num_i        <= HIGH_CLK_NUM_I; 
        Total_clk_num_i       <= TOTAL_CLK_NUM_I; 
		state <= 0;
    end
    else begin
        case(state)
            0:begin//first delay
                if( Cnt_clk_num > 0)Cnt_clk_num <= Cnt_clk_num - 1;
                else begin
                    Cnt_clk_num <= High_clk_num_i - 1;
                    PULSE_O <= 1;
                    state <= 1;
                end
            end
            1:begin//high
                if( Cnt_clk_num > 0)Cnt_clk_num <= Cnt_clk_num - 1;
                else begin
                    Cnt_clk_num <= Total_clk_num_i - High_clk_num_i - 1;
                    PULSE_O <= 0;
                    state <= 2;
                end
            end
            2:begin//low
                if( Cnt_clk_num > 0)Cnt_clk_num <= Cnt_clk_num - 1;
                else begin
                    Cnt_clk_num <= High_clk_num_i - 1;
                    PULSE_O <= 1;
                    state   <= 1;
                end
            end
            default:begin
                PULSE_O <= 0;
                First_delay_clk_num_i <= FIRST_DELAY_CLK_NUM_I;
                Cnt_clk_num <= FIRST_DELAY_CLK_NUM_I -1;
                High_clk_num_i        <= HIGH_CLK_NUM_I; 
                Total_clk_num_i       <= TOTAL_CLK_NUM_I; 
                state <= 0;     
            end
        endcase
    end    
end

endmodule


