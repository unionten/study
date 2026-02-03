///////////////////////////////////////////////////////////////////////////////
//design name: tpg
//designer : anoynomous
//company  : anoynomous
//time     : long long ago
///////////////////////////////////////////////////////////////////////////////
module tpg_core_image_gen(//需要4个tpg组成一个uhd
PIXEL_CLK_I,//像素时钟
RESET_I    ,
ALLIGN_VS_I,//____|———————— 内部会做缓存处理，之所以这样做是等待一行结束
ALLIGN_DE_I,//____|———————— 内部会做缓存处理，之所以这样做是等待一行结束
HS_O       ,//目标输出
VS_O       ,//目标输出
DE_O       ,//目标输出
HACTIVE_I  ,//参数
HFP_I      ,//参数 
HBP_I      ,//参数 
HSYNC_I    ,//参数 
VACTIVE_I  ,//参数 
VFP_I      ,//参数 
VBP_I      ,//参数 
VSYNC_I    ,//参数
active_x   ,//辅助信息
active_y   ,//辅助信息
enable_de_allign,
enable_vs_allign,
de_delay_num, //额外延时的DE数量；默认为0
vs_delay_num  //额外延时的HS数量；默认为0
); 

input          PIXEL_CLK_I;
input          RESET_I;
input          ALLIGN_VS_I;//____|————————
input          ALLIGN_DE_I;//____|————————
input  [15:0]  HACTIVE_I;
input  [15:0]  HFP_I;
input  [15:0]  HBP_I;
input  [15:0]  HSYNC_I;
input  [15:0]  VACTIVE_I;
input  [15:0]  VFP_I;
input  [15:0]  VBP_I;
input  [15:0]  VSYNC_I;
output         HS_O;
output         VS_O;
output         DE_O;
output [15:0]  active_x;
output [15:0]  active_y;
input  [0:0]   enable_de_allign;
input  [0:0]   enable_vs_allign;
input  [7:0]   de_delay_num;
input  [7:0]   vs_delay_num;
///////////////////////////////////////////////////////////////////////////////
reg  [15:0]  HTOTAL;
reg  [15:0]  VTOTAL;
reg  [15:0]  HTOTAL_m1;
reg  [15:0]  VTOTAL_m1;
reg  [15:0]  total_x;
reg  [15:0]  total_y;
reg  [15:0]  active_x;
reg  [15:0]  active_y;
reg  [15:0]  HS_START_0;//start cor of hsync
reg  [15:0]  HS_END_0; //end cor of hsync 
reg  [15:0]  VS_START_0;//start cor of vsync
reg  [15:0]  VS_END_0;  //end cor of vsync 
reg  hs_b1 = 0;
reg  vs_b1 = 0;
reg  data_en = 0;
reg  de_b2 = 0;
reg  HS_O = 0;
reg  VS_O = 0;
reg  DE_O = 0;
reg  de_b1 = 0;
wire logic_reset ;
reg  Allign_buf;
reg  Allign_pos;
reg  Clear_allign;
reg  De_full_buf;//一行满
reg  De_full_pos;
reg  Clear_de;
reg [7:0] Cnt_delay_hs;//延时多少个单元，计数
reg [7:0] Cnt_delay_hs2;//延时多少个单元，计数
reg  Need_check_de_allign;//是否需要检测de信号
reg Keep;
reg Flag;
///////////////////////////////////////////////////////////////////////////////
assign logic_reset = (HACTIVE_I == 0 || HFP_I == 0 || HBP_I == 0 || HSYNC_I == 0 ||
                      VACTIVE_I == 0 || VFP_I == 0 || VBP_I == 0 || VSYNC_I == 0 ) ? 1 
                      : RESET_I;
///////////////////////////////////////////////////////////////////////////////

always@(posedge PIXEL_CLK_I)begin
    if(RESET_I)begin 
        Allign_buf <= 1;
        Allign_pos <= 0;
    end
    else begin
        Allign_buf <= ALLIGN_VS_I;
        Allign_pos <= Clear_allign ? 0 : (Allign_pos ? 1 : (ALLIGN_VS_I & (~Allign_buf)));
    end
end

always@(posedge PIXEL_CLK_I)begin
    if(RESET_I)begin 
        De_full_buf <= 1;
        De_full_pos <= 0;
    end
    else begin
        De_full_buf <= ALLIGN_DE_I;
        De_full_pos <= Clear_de ? 0 : (De_full_pos ? 1 : (ALLIGN_DE_I & (~De_full_buf)));
    end
end
///////////////////////////////////////////////////////////////////////////////
//parameter
always @ (posedge PIXEL_CLK_I)begin
    HS_START_0 <= 1;
    HS_END_0   <= HSYNC_I + 1;
    VS_START_0 <= 1;
    VS_END_0   <= VSYNC_I + 1;
end
///////////////////////////////////////////////////////////////////////////////
//parameter
always @(posedge  PIXEL_CLK_I)begin
   HTOTAL <= (HACTIVE_I + HFP_I) + (HBP_I + HSYNC_I);
   VTOTAL <= (VACTIVE_I + VFP_I) + (VBP_I + VSYNC_I);
   HTOTAL_m1 <= HTOTAL - 1;
   VTOTAL_m1 <= VTOTAL - 1;
end
///////////////////////////////////////////////////////////////////////////////
//final output 
always @(posedge PIXEL_CLK_I)begin
    HS_O  <= hs_b1;
    VS_O  <= vs_b1;
    de_b1 <= de_b2;
    DE_O  <= de_b1;
end
///////////////////////////////////////////////////////////////////////////////
//total【x basic counter】
always @(posedge PIXEL_CLK_I)begin
    if(logic_reset)begin
        total_x <= 1;
    end
    else begin
        if(total_x == HTOTAL)begin
            total_x <= 1;
        end
        else begin
            total_x <= total_x + 1;
        end
    end
end  
/////////////////////////////////////////////////////////////////////////////// 
// total_【y basic counter】  
always @(posedge PIXEL_CLK_I) begin  
    if (logic_reset)begin    
        Cnt_delay_hs <= 0;
        total_y <= 1; 
        Clear_de <= 0;
        Clear_allign <= 0;
        Need_check_de_allign <= 1;
        Cnt_delay_hs2 <= 0;
    end
    else begin 
        if(Allign_pos & enable_vs_allign)begin
            Cnt_delay_hs <= vs_delay_num;
            if(vs_delay_num==0)total_y <= 1;
            else total_y <= 0;//否则钳制在0
            Clear_allign <= 1;
        end
        else if (total_x == 1)begin
            if(Cnt_delay_hs>1)begin//如果y需要保持
                total_y <= total_y;
                Cnt_delay_hs <= Cnt_delay_hs - 1;
            end
            else if(Cnt_delay_hs2>0)begin
                total_y <= total_y;
                if(Cnt_delay_hs2==1)begin
                    total_y <= (VSYNC_I+VBP_I+1) + 1;
                    //Flag <= 1;
                end
                Cnt_delay_hs2 <= Cnt_delay_hs2 - 1;
            end
            else begin//减到 0 时 total_y 开始递增 
                //if(Flag)begin
                //    Flag <= 0;
                //    total_y <= (VSYNC_I+VBP_I+1) + 1;
                //end
                //else 
                if(( (total_y<=(VSYNC_I+VBP_I+1) & total_y>VSYNC_I) & De_full_pos & enable_de_allign))begin //提前来满信号的话，就提前开始
                    if(de_delay_num==0)begin total_y <= (VSYNC_I+VBP_I+1) + 1; end
                    else begin 
                        Cnt_delay_hs2 <= de_delay_num;
                        total_y <= total_y;
                    end
                    //total_y <= (VSYNC_I+VBP_I+1) + 1;//立刻跳转
                    //total_y <= (VSYNC_I+VBP_I+1);//维持
                    Clear_de <= 1;
                end
                else if((total_y==(VSYNC_I+VBP_I+1)) & ~De_full_pos & enable_de_allign)begin //到时间还没有一行，就继续等
                    total_y <= total_y ;
                end
                else if(total_y < VTOTAL)begin
                    total_y <= total_y + 1; 
                end
                else begin
                    total_y <= 1;
                end
            end
        end
        else begin
            Clear_allign <= 0;
            Clear_de  <= 0;
        end
    end    
end     
///////////////////////////////////////////////////////////////////////////////
// 【HS】
always @ (posedge PIXEL_CLK_I)begin
    if(logic_reset)begin
        hs_b1 <= hs_b1;//keep temperatorily
    end
    else if(total_x == HS_START_0)begin
        hs_b1 <= 1;
    end
    else if(total_x == HS_END_0)begin
        hs_b1 <= 0;
    end
    else begin
        hs_b1 <= hs_b1; 
    end
end
///////////////////////////////////////////////////////////////////////////////
// 【VS】
always @ (posedge PIXEL_CLK_I)begin
    if(logic_reset)begin
        vs_b1 <= vs_b1;//keep temperatorily
    end
    else if((total_y == VS_START_0) && (total_x == HS_START_0))begin
        vs_b1 <= 1;
    end
    else if((total_y == VS_END_0) && (total_x == HS_START_0))begin
        vs_b1 <= 0;
    end
    else begin
        vs_b1 <= vs_b1;
    end        
end  
///////////////////////////////////////////////////////////////////////////////
//active_x  【DE】
always @(posedge PIXEL_CLK_I)begin
    if((total_x > HSYNC_I + HBP_I) & (total_x <= HSYNC_I + HBP_I + HACTIVE_I) & 
      (total_y > VSYNC_I + VBP_I + 1) & (total_y <= VBP_I + VSYNC_I + VACTIVE_I + 1))begin
        de_b2 <= 1;
        active_x <= active_x + 1;
    end
    else begin
        de_b2 <= 0;
        active_x  <= 0;
    end
end  
///////////////////////////////////////////////////////////////////////////////
//active_y
always @(posedge PIXEL_CLK_I)begin
    if((total_y > VSYNC_I + VBP_I + 1) & (total_y <= VSYNC_I + VBP_I + VACTIVE_I + 1))begin
        if(total_x == 1)begin
            active_y <= active_y + 1;
        end
    end
    else begin
        active_y <= 0;
    end
end


endmodule

