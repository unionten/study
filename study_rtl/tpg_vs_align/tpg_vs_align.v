///////////////////////////////////////////////////////////////////////////////
//design name: tpg_vs_align
//designer : 
//company  : 
//time     : 
//modified: 1.删除固定分组接口 2.新增实时控制端口 3.HS下降沿缓存控制信号 4.单DE周期信号稳定
///////////////////////////////////////////////////////////////////////////////
/*
(*keep_hierarchy="yes"*)
tpg_vs_align
    #(.PORT_NUM          (1) )
    tpg_vs_align_u(
    .PIXEL_CLK_I     (VID_CLK_I                        ),
    .VS_ALIGN_I      (VS_ALIGN_I ^ VSYNC_POLARITY_I    ) ,
    .VS_MODE_I       (VS_MODE_I                        ) ,
    .RESETN_I         (~rst_tpg  ),  //do not need rst when VS come
    .HSYNC_I         (C_FIXED_MAX_PARA  ?  R_HSYNC_vidclk/C_MAX_PORT_NUM   : R_HSYNC_vidclk_div    ),
    .HBP_I           (C_FIXED_MAX_PARA  ?  R_HBP_vidclk/C_MAX_PORT_NUM     : R_HBP_vidclk_div      ),
    .HACTIVE_I       (C_FIXED_MAX_PARA  ?  R_HACTIVE_vidclk/C_MAX_PORT_NUM : R_HACTIVE_vidclk_div  ),
    .HFP_I           (C_FIXED_MAX_PARA  ?  R_HFP_vidclk/C_MAX_PORT_NUM     : R_HFP_vidclk_div      ),
    .VSYNC_I         (R_VSYNC_vidclk),
    .VBP_I           (R_VBP_vidclk),
    .VACTIVE_I       (R_VACTIVE_vidclk),
    .VFP_I           (R_VFP_vidclk),
    // 新增实时控制端口
    .DE_EXTEND_EN_I  (DE_EXTEND_EN_I),    // 1=启用DE延长，0=正常
    .DE_EXTEND_MODE_I(DE_EXTEND_MODE_I),  // 0=×2延长，1=×3延长（仅延长使能时生效）
    .DE_SHIELD_EN_I  (DE_SHIELD_EN_I),    // 1=屏蔽DE输出，0=正常输出
    // 输出端口不变
    .HS_O            (tpg_hs_inner     ),// tpg driver
    .VS_O            (tpg_vs_inner     ),
    .DE_O            (tpg_de_inner     ),
    .R_O             (tpg_r_inner_ori  ),  //内部pattern打开后，此处出pattern内容
    .G_O             (tpg_g_inner_ori  ),
    .B_O             (tpg_b_inner_ori  ),
    .ACTIVE_X_O      (active_x         ),//16bit    from 1
    .ACTIVE_Y_O      (active_y         ) //16bit    from 1
    );
*/
// 控制逻辑说明：
// 1. HS下降沿缓存3个控制信号，当前行DE周期内保持不变
// 2. DE_EXTEND_EN_I=1 时启用延长：
//    - DE_EXTEND_MODE_I=0 → DE有效宽度×2
//    - DE_EXTEND_MODE_I=1 → DE有效宽度×3
// 3. DE_SHIELD_EN_I=1 时屏蔽DE输出（DE_O=0），内部原始DE生成逻辑不变
// 4. VS_MODE_I 0:稳定输出 1:稳定输出且以VS_ALIGN对齐 2: VS_ALIGN来一次则触发一次，随后停止
//    就算模块不复位，模式为0和1时可立刻启动
///////////////////////////////////////////////////////////////////////////////
module tpg_vs_align(
input         PIXEL_CLK_I      ,   //像素时钟
input         RESETN_I         ,   //复位时输出钳制为0,释放复位后自动从头启动
input         VS_ALIGN_I       ,
input [1:0]   VS_MODE_I        ,
// 新增实时控制端口（核心修改）
input         DE_EXTEND_EN_I   ,   // DE延长使能（1=启用，0=禁用）
input         DE_EXTEND_MODE_I ,   // 延长倍数模式（0=×2，1=×3）
input         DE_SHIELD_EN_I   ,   // DE屏蔽使能（1=屏蔽输出，0=正常输出）
// 核心时序输入参数（保留原接口）
input [15:0]  HFP_I       ,
input [15:0]  HSYNC_I     ,
input [15:0]  HACTIVE_I   ,
input [15:0]  HBP_I       ,
input [15:0]  VFP_I       ,
input [15:0]  VSYNC_I     ,
input [15:0]  VACTIVE_I   ,
input [15:0]  VBP_I       ,
// 输出端口（保留原接口）
output reg        VS_O    = C_VS_POLARITY    ,   //输出-时序(正极性)
output reg        HS_O    = C_HS_POLARITY    ,   //输出-时序(正极性)
output reg        DE_O        ,   //输出-时序(正极性)
output   [7:0]  R_O         ,    
output   [7:0]  G_O         ,
output   [7:0]  B_O         ,
output reg [15:0] TOTAL_X_O   ,   //输出-辅助信息(DE_O低时为0)   复位时为0
output reg [15:0] TOTAL_Y_O   ,   //输出-辅助信息(DE_O低时为0)   复位时为0
output reg [15:0] ACTIVE_X_O  ,   //输出-辅助信息(DE_O低时为0)   复位时为0
output reg [15:0] ACTIVE_Y_O      //输出-辅助信息(DE_O低时为0)   复位时为0  
); 
// 参数定义（保留原核心参数）
parameter [0:0]   C_VS_POLARITY =  0 ;
parameter [0:0]   C_HS_POLARITY =  0 ;
parameter [0:0]   HARD_TIMING_EN = 0; //default : 0 -> soft para
parameter         MODE = "NORMAL"   ;  //  "NORMAL" , "PHIYO_DP"
parameter         PORT_NUM = 1      ;//1 2 4 8
///////////////////////////////////////////////////////////////////////////////
// 内置硬时序参数（HARD_TIMING_EN=1时使用）
parameter [15:0]  HSYNC    =  1     ;//参数 [15:0] 
parameter [15:0]  HBP      =  1     ;//参数 [15:0] 
parameter [15:0]  HACTIVE  =  300   ;//参数 [15:0]
parameter [15:0]  HFP      =  1     ;//参数 [15:0] 
parameter [15:0]  VSYNC    =  1     ;//参数 [15:0]
parameter [15:0]  VBP      =  1     ;//参数 [15:0]
parameter [15:0]  VACTIVE  =  120   ;//参数 [15:0] 
parameter [15:0]  VFP      =  1     ;//参数 [15:0] 
///////////////////////////////////////////////////////////////////////////////
// VS_ALIGN上升沿检测（保留原逻辑）
reg   VS_ALIGN_reg = 0;
wire  VS_ALIGN_pos;
always@(posedge PIXEL_CLK_I)begin
    VS_ALIGN_reg <= VS_ALIGN_I ;
end
assign  VS_ALIGN_pos = VS_ALIGN_I & ~VS_ALIGN_reg ;

// 时序参数解析（保留原逻辑：硬/软时序切换 + 端口数分频）
wire [15:0]  hsync   ;
wire [15:0]  hbp     ;
wire [15:0]  hactive ;
wire [15:0]  hfp     ;
wire [15:0]  vsync   ;
wire [15:0]  vbp     ;
wire [15:0]  vactive ;
wire [15:0]  vfp     ;
reg [7:0] state = 0; //0=复位态，1=运行态

assign  hsync   = HARD_TIMING_EN ? HSYNC/PORT_NUM   : HSYNC_I/PORT_NUM   ;
assign  hbp     = HARD_TIMING_EN ? HBP/PORT_NUM     : HBP_I/PORT_NUM     ;      
assign  hactive = HARD_TIMING_EN ? HACTIVE/PORT_NUM : HACTIVE_I/PORT_NUM ; 
assign  hfp     = HARD_TIMING_EN ? HFP/PORT_NUM     : HFP_I/PORT_NUM     ;    
assign  vsync   = HARD_TIMING_EN ? VSYNC            : VSYNC_I            ;   
assign  vbp     = HARD_TIMING_EN ? VBP              : VBP_I              ;     
assign  vactive = HARD_TIMING_EN ? VACTIVE          : VACTIVE_I          ; 
assign  vfp     = HARD_TIMING_EN ? VFP              : VFP_I              ;     

// 核心信号定义（新增缓存信号）
reg hs;
reg vs;
reg de_core; // 内部原始DE信号（未经过延长和屏蔽处理）
wire [15:0] total_x;
wire [15:0] total_y;
wire [15:0] active_x;
wire [15:0] active_y;
wire [15:0] vsync_vbp ;
wire [15:0] hsync_hbp ;

// 核心修改1：新增控制信号缓存寄存器（HS下降沿更新）
reg de_extend_en_buf = 0;    // 缓存DE延长使能
reg de_extend_mode_buf = 0;  // 缓存DE延长倍数
reg de_shield_en_buf = 0;    // 缓存DE屏蔽使能
reg hs_delay = 0;            // HS信号延迟1拍，用于检测下降沿

// HS下降沿检测与信号缓存
always@(posedge PIXEL_CLK_I)begin
    if(~RESETN_I)begin
        hs_delay <= 0;
        de_extend_en_buf <= 0;
        de_extend_mode_buf <= 0;
        de_shield_en_buf <= 0;
    end
    else begin
        hs_delay <= HS_O; // 延迟1拍获取上一周期HS_O状态
        // 检测HS下降沿（当前HS_O=0，上一周期HS_O=1）
        if(HS_O == 0 && hs_delay == 1)begin
            // 缓存当前控制信号，当前行内保持不变
            de_extend_en_buf <= DE_EXTEND_EN_I;
            de_extend_mode_buf <= DE_EXTEND_MODE_I;
            de_shield_en_buf <= DE_SHIELD_EN_I;
        end
    end
end

// 行/场总周期计算（新增×3延长模式的行周期）
wire [15:0] HTOTAL ;          // 正常行总周期
wire [15:0] HTOTAL_ACTIVEm2 ; // ×2延长行总周期（hactive×2）
wire [15:0] HTOTAL_ACTIVEm3 ; // ×3延长行总周期（hactive×3）
wire [15:0] VTOTAL ;          // 正常场总周期

assign HTOTAL = hsync_hbp + hactive + hfp;
assign HTOTAL_ACTIVEm2 = hsync_hbp + (hactive << 1) + hfp; // hactive×2
assign HTOTAL_ACTIVEm3 = hsync_hbp + (hactive << 1 ) +hactive + hfp;  // hactive×3
assign VTOTAL = vsync_vbp + vactive + vfp;

// 行/场计数器（根据缓存的延长使能和模式动态切换行周期）
reg [15:0] x = 0; // 行计数器（0→1→...→行总周期→0循环）
reg [15:0] y = 0; // 场计数器（0→1→...→VTOTAL→0循环）

always@(posedge PIXEL_CLK_I)begin
    if(~RESETN_I)begin
        x <= 0;
        y <= 0;
        state <= (VS_MODE_I==0 | VS_MODE_I==1) ? 1 : 0; // 模式0/1直接启动
    end
    else if((VS_MODE_I==1 | VS_MODE_I==2) & VS_ALIGN_pos)begin
        // 模式1/2：VS_ALIGN上升沿触发启动/重新对齐
        state <= 1;
        x <= 2;        
        y <= 1; 
    end
    else begin
        case(state)
            0:  begin 
                    // 等待启动：模式0/1自动启动，模式2保持等待
                    state <= (VS_MODE_I==0 | VS_MODE_I==1) ? 1 : 0;
                    x <= 0; 
                    y <= 0;
                end
            1:  begin
                    // 根据缓存的延长使能和模式，切换行计数器最大值
                    if(de_extend_en_buf) begin
                        case(de_extend_mode_buf)
                            0: begin // ×2延长：行总周期=HTOTAL_ACTIVEm2
                                x <= x < HTOTAL_ACTIVEm2 ? x + 1 : (y < VTOTAL ? 1 : 0); 
                                y <= (y == 0) ? 1 : ((x == HTOTAL_ACTIVEm2) ? (y < VTOTAL ? y + 1 : 0) : y);
                            end
                            1: begin // ×3延长：行总周期=HTOTAL_ACTIVEm3
                                x <= x < HTOTAL_ACTIVEm3 ? x + 1 : (y < VTOTAL ? 1 : 0); 
                                y <= (y == 0) ? 1 : ((x == HTOTAL_ACTIVEm3) ? (y < VTOTAL ? y + 1 : 0) : y);
                            end
                            default: begin // 默认×2延长
                                x <= x < HTOTAL_ACTIVEm2 ? x + 1 : (y < VTOTAL ? 1 : 0); 
                                y <= (y == 0) ? 1 : ((x == HTOTAL_ACTIVEm2) ? (y < VTOTAL ? y + 1 : 0) : y);
                            end
                        endcase
                    end
                    else begin // 无延长：行总周期=HTOTAL
                        x <= x < HTOTAL ? x + 1 : (y < VTOTAL ? 1 : 0); 
                        y <= (y == 0) ? 1 : ((x == HTOTAL) ? (y < VTOTAL ? y + 1 : 0) : y);
                    end

                    // 模式2：完成一场后停止（恢复为等待态）
                    state <= (VS_MODE_I==0 | VS_MODE_I==1) ? state : ((y == 0) ? 1 : ((x == (de_extend_en_buf ? (de_extend_mode_buf ? HTOTAL_ACTIVEm3 : HTOTAL_ACTIVEm2) : HTOTAL)) ? (y < VTOTAL ? 1 : 0) : state));
                end
            default:  ;
        endcase
    end
end

// 辅助信号计算（保留原逻辑）
assign vsync_vbp = vsync + vbp; // 场同步+场后沿总行数
assign hsync_hbp = hsync + hbp; // 行同步+行后沿总列数

// 内部原始DE生成（核心逻辑不变，使用缓存的延长使能和模式）
always@(*)begin
    de_core = (x >= hsync_hbp + 1)        // 行方向：跳过行同步+行后沿
            & (x <= hsync_hbp + (de_extend_en_buf ? (de_extend_mode_buf ? ((hactive<<1) + hactive) : hactive<<1) : hactive)) // 使用缓存信号扩展宽度
            & (y >= vsync_vbp + 1)        // 场方向：跳过场同步+场后沿
            & (y <= vsync_vbp + vactive)  // 场方向：有效高度=VACTIVE
            ? 1 : 0;
end

// HS/VS信号生成（保留原逻辑，支持PHIYO_DP模式）
generate if(MODE=="PHIYO_DP")begin
    always@(*)begin
        hs = (x >= 1) & (x <= hsync) & (y > (vsync_vbp+1)) & (y <= (vsync_vbp+vactive)) ? 1 : 0;
    end
end
else begin
    always@(*)begin
        hs = (x >= 1) & (x <= hsync) ? 1 : 0; // 正常模式：行同步期间HS为1
    end
end
endgenerate

always@(*)begin
    vs = (y >= 1) & (y <= vsync) ? 1 : 0; // 场同步期间VS为1
end

// 辅助坐标计算（保留原逻辑，基于内部原始DE信号）
assign total_x   = de_core ? x : 0;
assign total_y   = de_core ? y : 0;
assign active_x  = de_core ? (x - hsync_hbp) : 0; // 行有效坐标（从1开始）
assign active_y  = de_core ? (y - vsync_vbp) : 0; // 场有效坐标（从1开始）

// 输出打拍（使用缓存的屏蔽信号控制DE输出）
always@(posedge PIXEL_CLK_I)begin
    if(~RESETN_I)begin
        HS_O <= C_HS_POLARITY;
        VS_O <= C_VS_POLARITY;
        DE_O <= 0;
        TOTAL_X_O   <= 0;
        TOTAL_Y_O   <= 0;
        ACTIVE_X_O  <= 0;
        ACTIVE_Y_O  <= 0;
    end
    else begin
        // HS/VS极性控制（保留原逻辑）
        HS_O <= C_HS_POLARITY == 0 ? (hs | ((VS_MODE_I==1 | VS_MODE_I==2) & VS_ALIGN_pos)) : ~(hs | ((VS_MODE_I==1 | VS_MODE_I==2) & VS_ALIGN_pos));
        VS_O <= C_VS_POLARITY == 0 ? (vs | ((VS_MODE_I==1 | VS_MODE_I==2) & VS_ALIGN_pos)) : ~(vs | ((VS_MODE_I==1 | VS_MODE_I==2) & VS_ALIGN_pos));
        // DE输出：使用缓存的屏蔽信号，屏蔽使能=1时强制为0
        DE_O <= de_shield_en_buf ? 0 : de_core;
        // 辅助坐标输出（基于内部原始de_core，不受屏蔽影响）
        TOTAL_X_O   <= total_x;
        TOTAL_Y_O   <= total_y;
        ACTIVE_X_O  <= active_x;
        ACTIVE_Y_O  <= active_y;
    end
end

// 像素数据生成（保留原逻辑：基于内部de_core，不受屏蔽影响）
reg [23:0] b_g_r = 0;
always@(posedge PIXEL_CLK_I)begin 
    if(~RESETN_I | VS_O)begin
        b_g_r <= 0; // 复位或场同步时清零
    end
    else if(de_core)begin // 基于内部原始DE信号，屏蔽时仍正常计数
        b_g_r <= b_g_r + 1; // DE有效时RGB数据递增
    end
end
assign {B_O, G_O, R_O} = b_g_r; // 分路输出8位R/G/B

endmodule