///////////////////////////////////////////////////////////////////////////////
//design name: tpg
//designer : 
//company  : 
//time     : 
///////////////////////////////////////////////////////////////////////////////

/*
tpg 
#(.OUTPUT_REGISTER_EN(0),
  .MODE( "NORMAL") // "NORMAL"  "PHIYO_DP"
)
tpg_u
(
.PIXEL_CLK_I     (),//像素时钟
.RESET_I         (),//复位时输出钳制为0,释放复位后自动从头启动
.VS_ALLIGN_I     (),//内部检测上沿,然后从头启动
.DE_VALID_I      (),//电平信号,DE_O等待DE_VALID_I拉高后才启动
.HSYNC_I         (),//参数 [15:0] 
.HBP_I           (),//参数 [15:0] 
.HACTIVE_I       (),//参数 [15:0]
.HFP_I           (),//参数 [15:0] 
.VSYNC_I         (),//参数 [15:0]
.VBP_I           (),//参数 [15:0]
.VACTIVE_I       (),//参数 [15:0] 
.VFP_I           (),//参数 [15:0] 
.HS_O            (),//输出-时序(正极性)
.VS_O            (),//输出-时序(正极性)
.DE_O            (),//输出-时序(正极性)
.TOTAL_X_O       (),//输出-辅助信息(DE_O低时为0)
.TOTAL_Y_O       (),//输出-辅助信息(DE_O低时为0)
.ACTIVE_X_O      (),//输出-辅助信息(DE_O低时为0)
.ACTIVE_Y_O      (),//输出-辅助信息(DE_O低时为0)
.BEFORE_DE_O     (),//输出-辅助信息
.AFTER_DE_O      (),//输出-辅助信息
.VS_ALLIGN_EN_I  (),//是否开启VS对齐功能
.DE_ALLIGN_EN_I  ()   //是否开启DE对齐功能
); 

*/


///////////////////////////////////////////////////////////////////////////////

module tpg(
input         PIXEL_CLK_I ,   //像素时钟
input         RESET_I     ,   //复位时输出钳制为0,释放复位后自动从头启动
input         VS_ALLIGN_I ,   //内部检测上沿,然后从头启动
input         DE_VALID_I  ,   //电平信号,DE_O等待DE_VALID_I拉高后才启动

input  [15:0]  HSYNC_I    ,   //参数 [15:0] 
input  [15:0]  HBP_I      ,   //参数 [15:0] 
input  [15:0]  HACTIVE_I  ,   //参数 [15:0]
input  [15:0]  HFP_I      ,   //参数 [15:0] 
input  [15:0]  VSYNC_I    ,   //参数 [15:0]
input  [15:0]  VBP_I      ,   //参数 [15:0]
input  [15:0]  VACTIVE_I  ,   //参数 [15:0] 
input  [15:0]  VFP_I      ,   //参数 [15:0] 
     
output reg        HS_O        ,   //输出-时序(正极性)
output reg        VS_O        ,   //输出-时序(正极性)
output reg        DE_O        ,   //输出-时序(正极性)
output reg [15:0] TOTAL_X_O   ,   //输出-辅助信息(DE_O低时为0)
output reg [15:0] TOTAL_Y_O   ,   //输出-辅助信息(DE_O低时为0)
output reg [15:0] ACTIVE_X_O  ,   //输出-辅助信息(DE_O低时为0)
output reg [15:0] ACTIVE_Y_O  ,   //输出-辅助信息(DE_O低时为0)
output reg        BEFORE_DE_O ,   //输出-辅助信息
output reg        AFTER_DE_O  ,   //输出-辅助信息
input VS_ALLIGN_EN_I      ,   //是否开启VS对齐功能
input DE_ALLIGN_EN_I           //是否开启DE对齐功能



); 

parameter [0:0] OUTPUT_REGISTER_EN    = 1;
parameter       MODE = "NORMAL";  //  "NORMAL" , "PHIYO_DP"


reg hs;
reg vs;
reg de;
wire [15:0] total_x;
wire [15:0] total_y;
wire [15:0] active_x;
wire [15:0] active_y;
wire before_de;
wire after_de;
//计数 0   1 2 3
reg [15:0] x = 0;//0  1,2,3,4 ... 1920  0
reg [15:0] y = 0;//0  1,2,3,4 ... 1080  0
wire [15:0] HTOTAL = HSYNC_I + HBP_I + HACTIVE_I + HFP_I;
wire [15:0] VTOTAL = VSYNC_I + VBP_I + VACTIVE_I + VFP_I;
wire VS_ALLIGN_I_pos;
reg  VS_ALLIGN_I_ff1 = 1;




always@(posedge PIXEL_CLK_I)begin
    if(RESET_I)begin
        VS_ALLIGN_I_ff1 <= 1;
    end
    else begin
        VS_ALLIGN_I_ff1 <= VS_ALLIGN_I;
    end
end

assign VS_ALLIGN_I_pos = VS_ALLIGN_I & ~VS_ALLIGN_I_ff1;



always@(posedge PIXEL_CLK_I)begin
    if(RESET_I)begin
        x <= 0;
    end
    else if(VS_ALLIGN_I_pos & VS_ALLIGN_EN_I)begin
        x <= 1;
    end
    else if(  ( y >= VSYNC_I + VBP_I + 1 )
            & ( y <= VSYNC_I + VBP_I + VACTIVE_I ) 
            & ( x == HSYNC_I + HBP_I ) 
            & DE_ALLIGN_EN_I
           ) begin
        if( DE_VALID_I==0 )begin
            x <= x;
        end
        else begin
            x <= x + 1;
        end
    end
    else begin
        x <= x < HTOTAL ? x + 1 : 1;
    end
end

always@(posedge PIXEL_CLK_I)begin
    if(RESET_I)begin
        y <= 0;
    end
    else if(VS_ALLIGN_I_pos & VS_ALLIGN_EN_I)begin
        y <= 1;
    end
    else begin
        y <= ( x == HTOTAL ) ? ( y < VTOTAL ? y + 1 : 1 ) : y;
    end
end

//////////////////////////////////////////////////////////////////////////////////////////////////
always@(*)begin//[0:0]
    de = ( ( x >= HSYNC_I + HBP_I + 1 )
         & ( x <= HSYNC_I + HBP_I + HACTIVE_I )
         & ( y >= VSYNC_I + VBP_I + 1 )
         & ( y <= VSYNC_I + VBP_I + VACTIVE_I ) ) ? 1 : 0;
end


generate if(MODE=="PHIYO_DP")begin
    always@(*)begin
        hs = ( ( x >= 1 ) & ( x <= HSYNC_I  ) &  ( y > (VSYNC_I+VBP_I+1) &  ( y <= (VSYNC_I+VBP_I+VACTIVE_I))  ) ) ? 1 : 0;
    end
end
else begin
    always@(*)begin//[0:0]
        hs = ( ( x >= 1 ) & ( x <= HSYNC_I  ) ) ? 1 : 0;
    end
end
endgenerate




always@(*)begin//[0:0]
    vs = ( ( y >= 1 ) & ( y <= VSYNC_I  ) )? 1 : 0;
end

assign total_x   = x ;//[15:0]
assign total_y   = y ;//[15:0]
assign active_x  = DE_O ? ( x - HSYNC_I - HBP_I ) : 0 ;//[15:0]
assign active_y  = DE_O ? ( y - VSYNC_I - VBP_I ) : 0 ;//[15:0]
assign before_de = ( y >= 1 ) && ( y <=  VSYNC_I + VBP_I ) ;//[0:0]
assign after_de  = ( y >= VTOTAL - VFP_I ) && ( y<=  VTOTAL ) ;//[0:0]

//////////////////////////////////////////////////////////////////////////////////////////////////
//输出打拍

generate if(OUTPUT_REGISTER_EN)begin

    always@(posedge PIXEL_CLK_I)begin
        if(RESET_I)begin
            HS_O <= 0;
            VS_O <= 0;
            DE_O <= 0;
            TOTAL_X_O   <= 0;
            TOTAL_Y_O   <= 0;
            ACTIVE_X_O  <= 0;
            ACTIVE_Y_O  <= 0;
            BEFORE_DE_O <= 0;
            AFTER_DE_O  <= 0;
        end
        else begin
            HS_O <= hs;
            VS_O <= vs;
            DE_O <= de;
            TOTAL_X_O   <= total_x;
            TOTAL_Y_O   <= total_y;
            ACTIVE_X_O  <= active_x;
            ACTIVE_Y_O  <= active_y;
            BEFORE_DE_O <= before_de;
            AFTER_DE_O  <= after_de;
        end
    end

end
else begin
    
   always@(*)begin  HS_O        = hs;        end
   always@(*)begin  VS_O        = vs;        end
   always@(*)begin  DE_O        = de;        end
   always@(*)begin  TOTAL_X_O   = total_x;   end
   always@(*)begin  TOTAL_Y_O   = total_y;   end
   always@(*)begin  ACTIVE_X_O  = active_x;  end
   always@(*)begin  ACTIVE_Y_O  = active_y;  end
   always@(*)begin  BEFORE_DE_O = before_de; end
   always@(*)begin  AFTER_DE_O  = after_de;  end
   
end
endgenerate



endmodule

