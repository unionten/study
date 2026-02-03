`timescale 1ns / 1ps

//【分频宏】
//C_DIV must >=2,  <= 254 ,奇数偶数皆可
//DIV_CNT分频示意
//_|—|_|—|_|—|_|—|_|—|_|—|_|—|_|—|_|
//_|———————————|___________|————————
//3分频示意
//_|—|_|—|_|—|_|—|_|—|_|—|_|—|_|—|_|
//_|—————|___|—————|___|—————
`define CLK_DIV(clk_in,rst_in,C_DIV,cnt_name,clk_div_name,clk_out)     reg clk_div_name = 0;reg [15:0] cnt_name = 0;always@(posedge clk_in)begin if(rst_in)begin clk_div_name <= 0;cnt_name <= 0;end else begin if(cnt_name<(C_DIV/2))begin cnt_name <= cnt_name + 1;clk_div_name <= 0;end else if(cnt_name<C_DIV-1) begin cnt_name <= cnt_name + 1;clk_div_name <= 1;end  else begin cnt_name <= 0;clk_div_name <= 1;end  end  end  assign clk_out = clk_div_name;
`define NEG_MONITOR_FF1(clk_in,rst_in,in,buf_name1,out)      reg buf_name1 = 0; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);
`define POS_MONITOR_FF1(clk_in,rst_in,in,buf_name1,out)      reg buf_name1 = 0; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);

//////////////////////////////////////////////////////////////////////////////////
// Engineer: yzhu
// Create Date: 2023/05/12 10:40:17
// Module Name: lcd16032
//////////////////////////////////////////////////////////////////////////////////
//DDRAM：  
//LCD addr ： 80H(ram addr 0,1)    81H  82H  83H  84H  85H  86H  87H  88H  89H(ram addr 18,19)     ->  20 operations 
//            90H(ram addr 20,21)  91H  92H  93H  94H  95H  96H  97H  98H  99H(ram addr 38,39)     ->  20 operations
//            every addr correponds one Chinese charactor or two English charactors

module lcd16032(
input         CLK_I  ,  // sync clk as you wish, such as 20M, 50M , ...
input         RST_I  ,  // sync rst  
                               
                               //pin Voltage 3.3V test pass
output reg    LCD_CS_O   = 0 , //recommend only be high  when MOSI is valid
output reg    LCD_SCK_O  = 0 , //recommend only exists   when MOSI is valid
output reg    LCD_MOSI_O = 0 , 

output            RD_EN_O       , 
output reg [9:0]  RD_ADDR_O = 0 , //ram addr : 0 to 39 
input      [7:0]  RD_CHR_I        //English charactor or half Chinese charactor


);

parameter   C_SYS_CLK_PRD_NS       = 20; // according to actual sys clk prd ; note : the unit is NS
parameter   [15:0] C_DIV           = 400;// [recommend 400] LCD_CS_O will be 50M/400 = 125KHz (has been tested)
parameter   C_DELAY_PER_OP_US      = 200;// [recommend 200] the ins delay time ( except clc )  in the sheet is 72us ; note : the unit is NS 

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
localparam  INIT_INS_NUM = 3;
initial begin
    init_ins_sequence[0] = 8'h20 ;//功能设定寄存器
    init_ins_sequence[1] = 8'h06 ;//进入点设定寄存器
    init_ins_sequence[2] = 8'h0c ;//显示状态开关寄存器
end

/*
recommended setting :
localparam  INIT_INS_NUM = 3;
initial begin
    init_ins_sequence[0] = 8'h20 ;//功能设定寄存器
    init_ins_sequence[1] = 8'h06 ;//进入点设定寄存器
    init_ins_sequence[2] = 8'h0c ;//显示状态开关寄存器
end
*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
localparam  C_OP_SHIFT_NUM      = 24; //be [fixed] to 24 ; 4-bit mode needs 24 shift num
localparam  C_HCHR_NUM_PER_LINE = 20; //be [fixed] to 20 ; one line needs 20 oprations
localparam  [7:0] C_LINE1_START_ADDR = 8'h80;//be [fixed] to 80h ; 80h is the first addr of the first line of LCD
localparam  [7:0] C_LINE2_START_ADDR = 8'h90;//be [fixed] to 90h ; 90h is the first addr of the second line of LCD

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign RD_EN_O = 1;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg  lcd_sck_en=0 ; 
wire lcd_clk_b;
wire lcd_clk_pos;
wire lcd_clk_neg;
reg [7:0] state = 0;
reg [7:0] cnt_al = 0 ;// used in LCD init and delay between two operations , al means already 
reg [7:0] cnt_bit_al = 0;// used in bit shift  , al means already 
reg [8+(1+1)*8-1:0] package_tmp = 0;
reg [15:0] cnt_delay = C_DELAY_PER_OP_US*1000/C_SYS_CLK_PRD_NS/C_DIV;
reg [7:0] init_ins_sequence [0:INIT_INS_NUM-1];


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
`CLK_DIV(CLK_I,RST_I,C_DIV,cnt_name0,clk_div_name,lcd_clk_b)
`POS_MONITOR_FF1(CLK_I,RST_I,lcd_clk_b,buf_name0,lcd_clk_pos)
`NEG_MONITOR_FF1(CLK_I,RST_I,lcd_clk_b,buf_name1,lcd_clk_neg)


always@(posedge CLK_I)begin
    if(RST_I) LCD_SCK_O <= 0;
    else if(LCD_CS_O==1)begin
        LCD_SCK_O <= lcd_clk_pos ? 1 : lcd_clk_neg ? 0 :  LCD_SCK_O;
    end
end


always@(posedge CLK_I)begin
    if(RST_I)begin
        LCD_CS_O <= 0;
        LCD_MOSI_O <= 0;
        state <= 0;
        cnt_al <= 0;
        cnt_bit_al <= 0;
        package_tmp <= 0;
        RD_ADDR_O <= 0;
        cnt_delay <= C_DELAY_PER_OP_US*1000/C_SYS_CLK_PRD_NS/C_DIV;
        lcd_sck_en <= 0;
    end
    else if(lcd_clk_neg)begin
        case(state)
            0:begin//LCD init
                package_tmp <= cnt_al==INIT_INS_NUM ? {5'b11111,2'b00,1'b0,C_LINE1_START_ADDR[7:4],4'h0,C_LINE1_START_ADDR[3:0],4'h0} : {5'b11111,2'b00,1'b0,init_ins_sequence[cnt_al][7:4],4'h0,init_ins_sequence[cnt_al][3:0],4'h0};
                cnt_al      <= cnt_al==INIT_INS_NUM ? 0 : cnt_al + 1;
                state       <= cnt_al==INIT_INS_NUM ? 2 : 1;                
            end
            1:begin//LCD init
                LCD_CS_O    <= cnt_bit_al==C_OP_SHIFT_NUM ? 0 : 1;  
                LCD_MOSI_O  <= package_tmp[C_OP_SHIFT_NUM-1];
                package_tmp <= {package_tmp[C_OP_SHIFT_NUM-2:0],1'b0};
                cnt_bit_al  <= cnt_bit_al==C_OP_SHIFT_NUM ? 0 : cnt_bit_al + 1;
                state       <= cnt_bit_al==C_OP_SHIFT_NUM ? 11 : state;  
                cnt_delay   <= C_DELAY_PER_OP_US*1000/C_SYS_CLK_PRD_NS/C_DIV;
            end
            11:begin
                state       <= cnt_delay==0 ? 0 :state;
                cnt_delay   <= cnt_delay - 1;
            end
            2:begin//send 80H addr to LCD
                LCD_CS_O    <= cnt_bit_al==C_OP_SHIFT_NUM ? 0 : 1;
                LCD_MOSI_O  <= package_tmp[C_OP_SHIFT_NUM-1];
                 
                package_tmp <= cnt_bit_al==C_OP_SHIFT_NUM ? {5'b11111,2'b01,1'b0,RD_CHR_I[7:4],4'h0,RD_CHR_I[3:0],4'h0} : {package_tmp[C_OP_SHIFT_NUM-2:0],1'b0}; 
                
                cnt_bit_al  <= cnt_bit_al==C_OP_SHIFT_NUM ? 0 : cnt_bit_al + 1;
                state       <= cnt_bit_al==C_OP_SHIFT_NUM ? 21 : state;  
                RD_ADDR_O   <= 0;
                cnt_al      <= 0;
                cnt_delay   <= C_DELAY_PER_OP_US*1000/C_SYS_CLK_PRD_NS/C_DIV;
            end
            21:begin
                state       <= cnt_delay==0 ? 3 :state;
                cnt_delay   <= cnt_delay - 1;
            end
            3:begin//send the first lins data to LCD
                LCD_CS_O    <= cnt_bit_al==C_OP_SHIFT_NUM ? 0 : 1;
                LCD_MOSI_O  <= package_tmp[C_OP_SHIFT_NUM-1];
                
                package_tmp <= cnt_bit_al==C_OP_SHIFT_NUM ? cnt_al==C_HCHR_NUM_PER_LINE-1 ? {5'b11111,2'b00,1'b0,C_LINE2_START_ADDR[7:4],4'h0,C_LINE2_START_ADDR[3:0],4'h0} : {5'b11111,2'b01,1'b0,RD_CHR_I[7:4],4'h0,RD_CHR_I[3:0],4'h0} : {package_tmp[C_OP_SHIFT_NUM-2:0],1'b0};
                
                cnt_bit_al  <= cnt_bit_al==C_OP_SHIFT_NUM ? 0 : cnt_bit_al + 1;
                state       <= cnt_bit_al==C_OP_SHIFT_NUM ? cnt_al==C_HCHR_NUM_PER_LINE-1  ? 31 : 32 : state;  
                RD_ADDR_O   <= cnt_bit_al==C_OP_SHIFT_NUM ? RD_ADDR_O + 1 : RD_ADDR_O;
                cnt_al      <= cnt_bit_al==C_OP_SHIFT_NUM ? cnt_al + 1 : cnt_al;  
                cnt_delay   <= C_DELAY_PER_OP_US*1000/C_SYS_CLK_PRD_NS/C_DIV;
            end
            31:begin
                state       <= cnt_delay==0 ? 4 :state;
                cnt_delay   <= cnt_delay - 1;
            end
            32:begin
                state       <= cnt_delay==0 ? 3 :state;
                cnt_delay   <= cnt_delay - 1;
            end
            4:begin//send 90H addr to LCD
                LCD_CS_O    <= cnt_bit_al==C_OP_SHIFT_NUM ? 0 : 1;
                LCD_MOSI_O  <= package_tmp[C_OP_SHIFT_NUM-1];
                
                package_tmp <= cnt_bit_al==C_OP_SHIFT_NUM ? {5'b11111,2'b01,1'b0,RD_CHR_I[7:4],4'h0,RD_CHR_I[3:0],4'h0} : {package_tmp[C_OP_SHIFT_NUM-2:0],1'b0};
               
                cnt_bit_al  <= cnt_bit_al==C_OP_SHIFT_NUM ? 0 : cnt_bit_al + 1;
                state       <= cnt_bit_al==C_OP_SHIFT_NUM ? 41 : state;  
                RD_ADDR_O   <= RD_ADDR_O;
                cnt_al      <= 0;
                cnt_delay   <= C_DELAY_PER_OP_US*1000/C_SYS_CLK_PRD_NS/C_DIV;
            end
            41:begin
                state       <= cnt_delay==0 ? 5 :state;
                cnt_delay   <= cnt_delay - 1;
            end
            5:begin//send the second lins data to LCD
                LCD_CS_O    <= cnt_bit_al==C_OP_SHIFT_NUM ? 0 : 1;
                LCD_MOSI_O  <= package_tmp[C_OP_SHIFT_NUM-1];
                
                package_tmp <= cnt_bit_al==C_OP_SHIFT_NUM ? cnt_al==C_HCHR_NUM_PER_LINE-1 ? {5'b11111,2'b00,1'b0,C_LINE1_START_ADDR[7:4],4'h0,C_LINE1_START_ADDR[3:0],4'h0} : {5'b11111,2'b01,1'b0,RD_CHR_I[7:4],4'h0,RD_CHR_I[3:0],4'h0} : {package_tmp[C_OP_SHIFT_NUM-2:0],1'b0};
                
                cnt_bit_al  <= cnt_bit_al==C_OP_SHIFT_NUM ? 0 : cnt_bit_al + 1;
                state       <= cnt_bit_al==C_OP_SHIFT_NUM ? cnt_al==C_HCHR_NUM_PER_LINE-1  ? 51 : 52: state;   //return to state 2
                RD_ADDR_O   <= cnt_bit_al==C_OP_SHIFT_NUM ? RD_ADDR_O + 1 : RD_ADDR_O;
                cnt_al      <= cnt_bit_al==C_OP_SHIFT_NUM ? cnt_al + 1 : cnt_al;  
                cnt_delay   <= C_DELAY_PER_OP_US*1000/C_SYS_CLK_PRD_NS/C_DIV;
            end
            51:begin
                state       <= cnt_delay==0 ? 2 :state; //return to data cycle
                cnt_delay   <= cnt_delay - 1;
            end
            52:begin
                state       <= cnt_delay==0 ? 5 :state;
                cnt_delay   <= cnt_delay - 1;
            end
            default:;
        endcase
    end
end
 

endmodule




/*
module tb_lcd16032(

    );
    
wire [9:0] RD_ADDR_O; 
lcd16032  
#(.C_DELAY_PER_OP_SHORT_US (200)  ,
 .C_DELAY_PER_OP_LONG_US(200),
  .C_SYS_CLK_PRD_NS (20) ,
  .C_DIV(400)
  ) 
lcd16032_u(
.CLK_I     (clk),
.RST_I     (rst),
.LCD_CS_O  (LCD_CS_O  ),
.LCD_SCK_O (LCD_SCK_O ),
.LCD_MOSI_O(LCD_MOSI_O),
.RD_EN_O   (RD_EN_O   ),
.RD_ADDR_O (RD_ADDR_O ),
.RD_HCODE_I(8'hAA),
.cs_2 (cs_2)

);


wire [7:0] state;
assign state = lcd16032_u.state;

always #10 clk = ~clk;
    
reg clk;
reg rst;
initial begin
clk = 0;
rst = 1;
#500;
rst = 0;
#500;



end 
    
endmodule

*/
