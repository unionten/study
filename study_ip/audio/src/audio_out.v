`timescale 1ns / 1ps
//memory_initialization_radix=16; 
//memory_initialization_vector=085F20 10B514 18F8B6 2120F9 2924EB 30FBC2 389CE7 3FFFFC 471CE9 4DEBE1 54656D 5A8275 603C45 658C96 6A6D94 6ED9E7 72CCB6 7641AC 7934FE 7BA372 7D8A5D 7EE7A8 7FB9D6 7FFFFF 7FB9D8 7EE7AB 7D8A61 7BA378 793505 7641B4 72CCC0 6ED9F3 6A6DA1 658CA3 603C54 5A8285 54657E 4DEBF2 471CFB 400010 389CFB 30FBD7 292500 21210F 18F8CC 10B52A 085F36 000016 F7A0F6 EF4B02 E7075F DEDF1C D6DB2A CF0452 C7632D C00017 B8E32A B21431 AB9AA3 A57D9B 9FC3CA 9A7378 959278 912624 8D3354 89BE5D 86CB09 845C94 8275A7 81185A 80462B 800001 804627 811852 82759A 845C82 86CAF3 89BE43 8D3336 912602 959253 9A734F 9FC39E A57D6B AB9A71 B213FC B8E2F2 BFFFDD C762F1 CF0415 D6DAEB DEDEDC E7071E EF4AC0 F7A0B3 FFFFD4;
//C_DIV must >=2,  <= 254 ,偶数

`define CLK_DIV(clk_in,rst_in,C_DIV,cnt_name,clk_div_name,clk_out)    reg clk_div_name = 0;reg [7:0] cnt_name = 0;always@(posedge clk_in)begin if(rst_in)begin clk_div_name <= 0;cnt_name <= 0;end else begin if(cnt_name<(C_DIV/2))begin cnt_name <= cnt_name + 1;clk_div_name <= 0;end else if(cnt_name<C_DIV-1) begin cnt_name <= cnt_name + 1;clk_div_name <= 1;end  else begin cnt_name <= 0;clk_div_name <= 1;end  end  end  assign clk_out = clk_div_name;
//高脉冲延长宏, 会从pulse_p_in的结尾开始延长, C_TOTAL_PERIOD must >= 1 ,==1 时脉冲原样传递 ,已验证
`define SYN_STRETCH_POS(pulse_p_in,clk_in,C_TOTAL_PERIOD,cnt_name,pulse_p_out)    reg [15:0] cnt_name = 0;always@(posedge clk_in)begin if(pulse_p_in )begin cnt_name <= C_TOTAL_PERIOD-1; end  else begin  cnt_name <= (cnt_name == 0) ? 0 : (cnt_name - 1);end end  assign pulse_p_out = pulse_p_in|((cnt_name != 0)? 1:0);

`define POS_MONITOR_FF1(clk_in,rst_in,in,buf_name1,out)    reg buf_name1 = 1; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 1; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);
`define NEG_MONITOR_FF1(clk_in,rst_in,in,buf_name1,out)    reg buf_name1 = 0; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// Create Date: 2022/09/19 13:38:45
// Design Name: 
// Module Name: audio_out
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
//5343格式：iis ( not left-justified )
//            right data                     left data
//LRCK ____|————————————————————————————|____________________
//SCLK |_|—|_|—|_|—|_|—|_|—|_|—|
//D             AAA BBB CCC（地址DD的数据）
//LRCKPOS _|———|____________ 采边沿有风险
//        _|—|____________ 
//        _|—————|____________ 
//_____________|______
//ADDR       DD DD+1
//RAMOUT   XXXXXXXX|AAABBBCCC-NEXT
//       LRCK上沿从left rom中读取24位，随后发出左声道（【延后一个LRCK周期】）
//


//_1 :  右通道
//_2 :  左通道



module audio_out(
input   CLK_12288KHZ_I,//12288KHz 和 IIS相关
input   SCLK_RSTN_I,//复位后状态机复位
input SCLK_LEFT_ENABLE_I ,//屏蔽了ram的输出（变为0）
input SCLK_RIGHT_ENABLE_I,//屏蔽了ram的输出（变为0）
input  [3:0] AUDIO_FERQ_I,
//iis interface
output  IIS_SCLK_O, //to 5343 ~功能-同步时钟
output  IIS_LRCK_O, //to 5343
output  reg IIS_SDOUT_O = 0,//to 5343
output  IIS_MCLK_O  //to 5343

);
parameter OUT_MCLK_LRCK_RATIO = 256;
parameter OUT_SCLK_LRCK_RATIO = 64;


assign IIS_MCLK_O = CLK_12288KHZ_I;
`CLK_DIV(IIS_MCLK_O,0,OUT_MCLK_LRCK_RATIO,cntml,cdivml,IIS_LRCK_O) 
`CLK_DIV(IIS_MCLK_O,0,(OUT_MCLK_LRCK_RATIO/OUT_SCLK_LRCK_RATIO),cntsc,cdivsc,IIS_SCLK_O) 

(*keep="true"*)reg [23:0]  dout_1_reg = 0;
(*keep="true"*)reg [23:0]  dout_2_reg = 0;

always@(negedge IIS_SCLK_O)begin
    if(~SCLK_RSTN_I)begin
        addr_1 <= 0;
    end
    else begin
        addr_1 <= lrck_pos_tr2 ? ( (addr_1 >= 63) ? 0 : (addr_1 + AUDIO_FERQ_I+1) ) : addr_1;
    end
end  

always@(negedge IIS_SCLK_O)begin
    if( ~SCLK_RSTN_I)begin
        addr_2 <= 0;
    end
    else begin
        addr_2 <= lrck_neg_tr2 ? ( (addr_2 >= 63) ? 0 : (addr_2 + AUDIO_FERQ_I+1) ) : addr_2;
    end
end  
    

(*keep="true"*)wire lrck_pos;
(*keep="true"*)wire lrck_neg;

`POS_MONITOR_FF1(IIS_SCLK_O,0,IIS_LRCK_O,lrck_buf1,lrck_pos)
`NEG_MONITOR_FF1(IIS_SCLK_O,0,IIS_LRCK_O,lrck_buf2,lrck_neg)

(*keep="true"*)wire lrck_pos_tr1;
(*keep="true"*)wire lrck_neg_tr1;
`SYN_STRETCH_POS(lrck_pos,IIS_SCLK_O,2,cnt_name2,lrck_pos_tr1) 
`SYN_STRETCH_POS(lrck_neg,IIS_SCLK_O,2,cnt_name3,lrck_neg_tr1) 

(*keep="true"*)wire lrck_pos_tr2;
(*keep="true"*)wire lrck_neg_tr2;
assign lrck_pos_tr2 = lrck_pos_tr1 & (~lrck_pos) ;
assign lrck_neg_tr2 = lrck_neg_tr1 & (~lrck_neg) ;

reg [7:0] state = 0;
reg [7:0] cnt = 0;

always @(negedge IIS_SCLK_O)begin
    if( ~SCLK_RSTN_I)begin
        state <= 0;
        IIS_SDOUT_O <= 0;
        cnt <= 0;
        dout_1_reg <= 0;
        dout_2_reg <= 0;
    end
    else begin
        case(state)
            0:begin
                state <= lrck_pos_tr2 ? 1 : state;
                dout_1_reg <= lrck_pos_tr2 ? {dout_1_final[22:0],1'b0} : dout_1_reg;//移位保存
                IIS_SDOUT_O <= lrck_pos_tr2 ? dout_1_final[23] :0 ;//立刻打出
                cnt   <= 23;
            end
            1:begin
                cnt <= (cnt==1) ? 23: cnt - 1;
                state <= (cnt==1) ? 2 : state;
                IIS_SDOUT_O <= dout_1_reg[23];
                dout_1_reg <= {dout_1_reg[22:0],1'b0};
            end
            2:begin
                state <= lrck_neg_tr2 ? 3 : state;  
                dout_2_reg <= lrck_neg_tr2 ? {dout_2_final[22:0],1'b0}: dout_2_reg;
                IIS_SDOUT_O <= lrck_neg_tr2 ? dout_2_final[23] : 0;
            end
            3:begin
                cnt <= (cnt==1) ? 23: cnt - 1;
                state <= (cnt==1) ? 0 : state;
                IIS_SDOUT_O <= dout_2_reg[23];
                dout_2_reg <= {dout_2_reg[22:0],1'b0};
            end
            default:begin
                state <= 0;
                IIS_SDOUT_O <= 0;
                cnt <= 0;   
                dout_1_reg <= 0;
                dout_2_reg <= 0;
            end
        endcase
    end
end



(*keep="true"*)reg  [9:0]  addr_1 = 0;
(*keep="true"*)wire [23:0] dout_1;
(*keep="true"*)wire [23:0] dout_1_final;
(*keep="true"*)reg  [9:0]  addr_2 = 0;
(*keep="true"*)wire [23:0] dout_2;
(*keep="true"*)wire [23:0] dout_2_final; 

assign dout_1_final = SCLK_RIGHT_ENABLE_I  ?  dout_1 : 0;
assign dout_2_final = SCLK_LEFT_ENABLE_I   ?  dout_2 : 0;



(*KEEP_HIERARCHY  = "TRUE"*)
rom_sin_2comp_96 rom_sin_2comp_96_left_u
  (
    .clka  (IIS_SCLK_O),//: IN STD_LOGIC;
    .addra (addr_1),//: IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    .douta (dout_1) //: OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
  );

(*KEEP_HIERARCHY  = "TRUE"*)
rom_sin_2comp_96 rom_sin_2comp_96_right_u
  (
    .clka  (IIS_SCLK_O),//: IN STD_LOGIC;
    .addra (addr_2),//: IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    .douta (dout_2) //: OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
  );



 
endmodule
