///////////////////////////////////////////////////////////////////////////////
//design name: tpg
//designer : 
//company  : 
//time     : 
///////////////////////////////////////////////////////////////////////////////

/*
tpg 
#(.OUTPUT_REGISTER_EN(0))
tpg_u
(
.PIXEL_CLK_I     (),//像素时钟
.RESETN_I         (),//复位时输出钳制为0,释放复位后自动从头启动
.VS_ALLIGN_I     (),//内部检测上沿,然后从头启动
.DE_VALID_I      (),//电平信号,DE_O等待DE_VALID_I拉高后才启动
.hsync         (),//参数 [15:0] 
.hbp           (),//参数 [15:0] 
.hactive       (),//参数 [15:0]
.hfp           (),//参数 [15:0] 
.vsync         (),//参数 [15:0]
.vbp           (),//参数 [15:0]
.vactive       (),//参数 [15:0] 
.vfp           (),//参数 [15:0] 
.HS_O            (),//输出-时序(正极性)
.VS_O            (),//输出-时序(正极性)
.DE_O            (),//输出-时序(正极性)
.TOTAL_X_O       (),//输出-辅助信息(DE_O低时为0)
.TOTAL_Y_O       (),//输出-辅助信息(DE_O低时为0)
.ACTIVE_X_O      (),//输出-辅助信息(DE_O低时为0)
.ACTIVE_Y_O      (),//输出-辅助信息(DE_O低时为0)
.BEFORE_DE_O     (),//输出-辅助信息
.AFTER_DE_O      (),//输出-辅助信息
.VS_ALLIGN_EN  (),//是否开启VS对齐功能
.DE_ALLIGN_EN  ()   //是否开启DE对齐功能
); 

*/


///////////////////////////////////////////////////////////////////////////////

module tpg(
input         PIXEL_CLK_I     ,   //像素时钟
input         RESETN_I         ,   //复位时输出钳制为0,释放复位后自动从头启动

input [15:0]  HFP_I       ,
input [15:0]  HSYNC_I     ,
input [15:0]  HACTIVE_I   ,
input [15:0]  HBP_I       ,
input [15:0]  VFP_I       ,
input [15:0]  VSYNC_I     ,
input [15:0]  VACTIVE_I   ,
input [15:0]  VBP_I       ,

output reg        VS_O        ,   //输出-时序(正极性)             
output reg        HS_O        ,   //输出-时序(正极性)
output reg        DE_O        ,   //输出-时序(正极性)
output reg [7:0]  R_O         ,    
output reg [7:0]  G_O         ,
output reg [7:0]  B_O         ,

output reg [15:0] TOTAL_X_O   ,   //输出-辅助信息(DE_O低时为0)
output reg [15:0] TOTAL_Y_O   ,   //输出-辅助信息(DE_O低时为0)
output reg [15:0] ACTIVE_X_O  ,   //输出-辅助信息(DE_O低时为0)
output reg [15:0] ACTIVE_Y_O  ,   //输出-辅助信息(DE_O低时为0)
output reg        BEFORE_DE_O ,   //输出-辅助信息
output reg        AFTER_DE_O  ,   //输出-辅助信息

input         VS_ALLIGN_I         ,   //内部检测上沿,然后从头启动
input         DE_VALID_I             //电平信号,DE_O等待DE_VALID_I拉高后才启动

); 
parameter [0:0]   HARD_TIMING_EN = 1; //default : 0 -> soft para
parameter [0:0] OUTPUT_REGISTER_EN    = 1;
parameter       MODE = "NORMAL";  //  "NORMAL" , "PHIYO_DP"
parameter [0:0] VS_ALLIGN_EN = 0; //default : 0
parameter [0:0] DE_ALLIGN_EN = 0; //default : 0
parameter [0:0] ILA_ENABLE = 0; 
parameter PORT_NUM = 1;//1 2 4 8
///////////////////////////////////////////////////////////////////////////////

parameter [15:0]  HSYNC    =  1  ;//参数 [15:0] 
parameter [15:0]  HBP      =  1  ;//参数 [15:0] 
parameter [15:0]  HACTIVE  =  300  ;//参数 [15:0]
parameter [15:0]  HFP      =  1  ;//参数 [15:0] 
parameter [15:0]  VSYNC    =  1  ;//参数 [15:0]
parameter [15:0]  VBP      =  1  ;//参数 [15:0]
parameter [15:0]  VACTIVE  =  120  ;//参数 [15:0] 
parameter [15:0]  VFP      =  1  ;//参数 [15:0] 

///////////////////////////////////////////////////////////////////////////////
//UI para
parameter [0:0]  SHOW_DBG_INFO = 0 ;


wire [15:0]  hsync   ;
wire [15:0]  hbp     ;
wire [15:0]  hactive ;
wire [15:0]  hfp     ;
wire [15:0]  vsync   ;
wire [15:0]  vbp     ;
wire [15:0]  vactive ;
wire [15:0]  vfp     ;


assign  hsync   =  HARD_TIMING_EN ? HSYNC/PORT_NUM   : HSYNC_I/PORT_NUM   ;
assign  hbp     =  HARD_TIMING_EN ? HBP/PORT_NUM     : HBP_I/PORT_NUM     ;      
assign  hactive =  HARD_TIMING_EN ? HACTIVE/PORT_NUM : HACTIVE_I/PORT_NUM ; 
assign  hfp     =  HARD_TIMING_EN ? HFP/PORT_NUM     : HFP_I/PORT_NUM     ;    
 
assign  vsync   =  HARD_TIMING_EN ? VSYNC   : VSYNC_I   ;   
assign  vbp     =  HARD_TIMING_EN ? VBP     : VBP_I     ;     
assign  vactive =  HARD_TIMING_EN ? VACTIVE : VACTIVE_I ; 
assign  vfp     =  HARD_TIMING_EN ? VFP     : VFP_I     ;     


reg hs;
reg vs;
reg de;
wire [15:0] total_x;
wire [15:0] total_y;
wire [15:0] active_x;
wire [15:0] active_y;
wire before_de;
wire after_de;

wire [7:0] r_o;
wire [7:0] g_o;
wire [7:0] b_o;


wire [15:0] HTOTAL = hsync + hbp + hactive + hfp;
wire [15:0] VTOTAL = vsync + vbp + vactive + vfp;

wire VS_ALLIGN_I_pos;
reg  VS_ALLIGN_I_ff1 = 1;
always@(posedge PIXEL_CLK_I)begin
    if(~RESETN_I)begin
        VS_ALLIGN_I_ff1 <= 1;
    end
    else begin
        VS_ALLIGN_I_ff1 <= VS_ALLIGN_I;
    end
end

assign VS_ALLIGN_I_pos = VS_ALLIGN_I & ~VS_ALLIGN_I_ff1;


//计数 0   1 2 3    total num (not valid num)
reg [15:0] x = 0;//0  1,2,3,4 ... 1920 .... 

reg [15:0] y = 0;//0  1,2,3,4 ... 1080 ....


always@(posedge PIXEL_CLK_I)begin
    if(~RESETN_I)begin
        x <= 0;
    end
    else if(VS_ALLIGN_I_pos & VS_ALLIGN_EN)begin
        x <= 1;
    end
    else if(  ( y >= vsync + vbp + 1 )
            & ( y <= vsync + vbp + vactive ) 
            & ( x == hsync + hbp ) 
            & DE_ALLIGN_EN
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
    if(~RESETN_I)begin
        y <= 0;
    end
    else if(VS_ALLIGN_I_pos & VS_ALLIGN_EN)begin
        y <= 1;
    end
    else begin
        y <= ( x == HTOTAL ) ? ( y < VTOTAL ? y + 1 : 1 ) : y;
    end
end

//////////////////////////////////////////////////////////////////////////////////////////////////
always@(*)begin//[0:0]
    de = ( ( x >= hsync + hbp + 1 )
         & ( x <= hsync + hbp + hactive )
         & ( y >= vsync + vbp + 1 )
         & ( y <= vsync + vbp + vactive ) ) ? 1 : 0;
end


generate if(MODE=="PHIYO_DP")begin
    always@(*)begin
        hs = ( ( x >= 1 ) & ( x <= hsync  ) &  ( y > (vsync+vbp+1) &  ( y <= (vsync+vbp+vactive))  ) ) ? 1 : 0;
    end
end
else begin
    always@(*)begin//[0:0]
        hs = ( ( x >= 1 ) & ( x <= hsync  ) ) ? 1 : 0;
    end
end
endgenerate




always@(*)begin//[0:0]
    vs = ( ( y >= 1 ) & ( y <= vsync  ) )? 1 : 0;
end

assign total_x   = x ;//[15:0]
assign total_y   = y ;//[15:0]
assign active_x  = DE_O ? ( x - hsync - hbp ) : 0 ;//[15:0]
assign active_y  = DE_O ? ( y - vsync - vbp ) : 0 ;//[15:0]
assign before_de = ( y >= 1 ) && ( y <=  vsync + vbp ) ;//[0:0]
assign after_de  = ( y >= VTOTAL - vfp ) && ( y<=  VTOTAL ) ;//[0:0]



//assign r_o =  ( x > (hactive>>1) )  ?  8'b11111111 : 8'b00000000 ;
assign r_o =  ( x > (HTOTAL>>1) )  ?  8'b11111111 : 8'b00000000 ;
assign g_o =  8'b00000000; 
assign b_o =  8'b00000000; 




//////////////////////////////////////////////////////////////////////////////////////////////////
//输出打拍

generate if(OUTPUT_REGISTER_EN)begin

    always@(posedge PIXEL_CLK_I)begin
        if(~RESETN_I)begin
            HS_O <= 0;
            VS_O <= 0;
            DE_O <= 0;
            TOTAL_X_O   <= 0;
            TOTAL_Y_O   <= 0;
            ACTIVE_X_O  <= 0;
            ACTIVE_Y_O  <= 0;
            BEFORE_DE_O <= 0;
            AFTER_DE_O  <= 0;
            R_O <= 0;
            G_O <= 0;
            B_O <= 0;
            
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
            R_O <= r_o;
            G_O <= g_o;
            B_O <= b_o;
            
            
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
   always@(*)begin  R_O  = r_o;  end
   always@(*)begin  G_O  = g_o;  end
   always@(*)begin  B_O  = b_o;  end
   
   
end
endgenerate


generate if(ILA_ENABLE)begin
    ila_0  ila_0_u(
    .clk     (PIXEL_CLK_I  ),
    .probe0  (HFP_I        ),
    .probe1  (HSYNC_I      ),
    .probe2  (HACTIVE_I    ),
    .probe3  (HBP_I        ),
    .probe4  (VFP_I        ),
    .probe5  (VSYNC_I      ),
    .probe6  (VACTIVE_I    ),
    .probe7  (VBP_I        ),
    .probe8  (VS_O         ),
    .probe9  (HS_O         ),
    .probe10 (DE_O         )
    
    );
end
endgenerate



endmodule

