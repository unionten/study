///////////////////////////////////////////////////////////////////////////////
// Testbench for tpg_vs_align module (HS下降沿缓存版)
// 测试场景：
// 1. 正常模式（无延长、无屏蔽）
// 2. DE ×2 延长模式（HS下降沿缓存参数）
// 3. DE ×3 延长模式（HS下降沿缓存参数）
// 4. DE 屏蔽模式（内部逻辑不变，仅输出屏蔽）
// 5. 行内控制信号波动（验证缓存稳定性）
// 6. VS_MODE 三种输出模式切换
// 时序参数：消隐参数=16，HACTIVE=200，VACTIVE=20（缩短测试时间）
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module tb_tpg_vs_align;

// 时钟参数（100MHz像素时钟，可调整）
parameter PIXEL_CLK_PERIOD = 10; // 10ns = 100MHz

// 激励信号（输入）
reg         PIXEL_CLK_I;
reg         RESETN_I;
reg         VS_ALIGN_I;
reg [1:0]   VS_MODE_I;
// 新增实时控制端口（HS下降沿缓存）
reg         DE_EXTEND_EN_I;
reg         DE_EXTEND_MODE_I;
reg         DE_SHIELD_EN_I;
// 时序输入参数（按要求精简）
reg [15:0]  HFP_I;
reg [15:0]  HSYNC_I;
reg [15:0]  HACTIVE_I;
reg [15:0]  HBP_I;
reg [15:0]  VFP_I;
reg [15:0]  VSYNC_I;
reg [15:0]  VACTIVE_I;
reg [15:0]  VBP_I;

// 响应信号（输出）
wire        VS_O;
wire        HS_O;
wire        DE_O;
wire [7:0]  R_O;
wire [7:0]  G_O;
wire [7:0]  B_O;
wire [15:0] TOTAL_X_O;
wire [15:0] TOTAL_Y_O;
wire [15:0] ACTIVE_X_O;
wire [15:0] ACTIVE_Y_O;

// 例化被测模块（HS下降沿缓存版）
tpg_vs_align uut (
    .PIXEL_CLK_I      (PIXEL_CLK_I),
    .RESETN_I         (RESETN_I),
    .VS_ALIGN_I       (VS_ALIGN_I),
    .VS_MODE_I        (VS_MODE_I),
    .DE_EXTEND_EN_I   (DE_EXTEND_EN_I),
    .DE_EXTEND_MODE_I (DE_EXTEND_MODE_I),
    .DE_SHIELD_EN_I   (DE_SHIELD_EN_I),
    .HFP_I            (HFP_I),
    .HSYNC_I          (HSYNC_I),
    .HACTIVE_I        (HACTIVE_I),
    .HBP_I            (HBP_I),
    .VFP_I            (VFP_I),
    .VSYNC_I          (VSYNC_I),
    .VACTIVE_I        (VACTIVE_I),
    .VBP_I            (VBP_I),
    .VS_O             (VS_O),
    .HS_O             (HS_O),
    .DE_O             (DE_O),
    .R_O              (R_O),
    .G_O              (G_O),
    .B_O              (B_O),
    .TOTAL_X_O        (TOTAL_X_O),
    .TOTAL_Y_O        (TOTAL_Y_O),
    .ACTIVE_X_O       (ACTIVE_X_O),
    .ACTIVE_Y_O       (ACTIVE_Y_O)
);

// 生成像素时钟
initial begin
    PIXEL_CLK_I = 0;
    forever #(PIXEL_CLK_PERIOD/2) PIXEL_CLK_I = ~PIXEL_CLK_I;
end

// 激励序列（核心测试逻辑）
initial begin
    // 1. 初始化所有输入信号
    RESETN_I         = 0;
    VS_ALIGN_I       = 0;
    VS_MODE_I        = 2'b00; // 初始模式0：稳定输出
    DE_EXTEND_EN_I   = 0;     // 初始关闭延长
    DE_EXTEND_MODE_I = 0;     // 初始×2模式（未启用）
    DE_SHIELD_EN_I   = 0;     // 初始关闭屏蔽
    
    // 时序参数配置（按要求修改：消隐参数=16，HACTIVE=200，VACTIVE=20）
    HSYNC_I   = 16'd16;   // 行同步宽度（消隐参数=16）
    HBP_I     = 16'd16;   // 行后沿（消隐参数=16）
    HACTIVE_I = 16'd200;  // 行有效宽度（要求=200）
    HFP_I     = 16'd16;   // 行前沿（消隐参数=16）
    VSYNC_I   = 16'd16;   // 场同步宽度（消隐参数=16）
    VBP_I     = 16'd16;   // 场后沿（消隐参数=16）
    VACTIVE_I = 16'd20;   // 场有效高度（要求=20）
    VFP_I     = 16'd16;   // 场前沿（消隐参数=16）

    // 2. 复位（持续10个时钟周期）
    #(PIXEL_CLK_PERIOD * 10);
    RESETN_I = 1;
    $display("=== 复位释放，开始测试（精简时序参数）===");
    $display("时序参数：HACTIVE=%d, VACTIVE=%d, 消隐参数=16", HACTIVE_I, VACTIVE_I);

    // 3. 测试场景1：正常模式（无延长、无屏蔽）
    #(PIXEL_CLK_PERIOD * 500); // 等待500个时钟（约1场时序，精简后更快）
    $display("\n=== 测试场景1：正常模式（无延长、无屏蔽）===");
    $display("预期DE有效宽度 = %d，ACTIVE_X最大值 = %d", HACTIVE_I, HACTIVE_I);
    #(PIXEL_CLK_PERIOD * 1000); // 持续测试（覆盖10行有效数据）

    // 4. 测试场景2：DE ×2 延长模式（HS下降沿缓存）
    DE_EXTEND_EN_I   = 1;
    DE_EXTEND_MODE_I = 0;
    #(PIXEL_CLK_PERIOD * 100); // 等待HS下降沿缓存信号
    $display("\n=== 测试场景2：DE ×2 延长模式（HS下降沿缓存）===");
    $display("预期DE有效宽度 = %d，ACTIVE_X最大值 = %d", HACTIVE_I*2, HACTIVE_I*2);
    #(PIXEL_CLK_PERIOD * 1000); // 持续测试
    DE_EXTEND_EN_I = 0; // 关闭延长

    // 5. 测试场景3：DE ×3 延长模式（HS下降沿缓存）
    #(PIXEL_CLK_PERIOD * 300); // 过渡时间
    DE_EXTEND_EN_I   = 1;
    DE_EXTEND_MODE_I = 1;
    #(PIXEL_CLK_PERIOD * 100); // 等待HS下降沿缓存信号
    $display("\n=== 测试场景3：DE ×3 延长模式（HS下降沿缓存）===");
    $display("预期DE有效宽度 = %d，ACTIVE_X最大值 = %d", HACTIVE_I*3, HACTIVE_I*3);
    #(PIXEL_CLK_PERIOD * 1000); // 持续测试
    DE_EXTEND_EN_I = 0; // 关闭延长

    // 6. 测试场景4：DE 屏蔽模式（内部逻辑不变）
    #(PIXEL_CLK_PERIOD * 300); // 过渡时间
    DE_SHIELD_EN_I = 1;
    #(PIXEL_CLK_PERIOD * 100); // 等待信号稳定
    $display("\n=== 测试场景4：DE 屏蔽模式 ===");
    $display("预期DE_O=0，内部ACTIVE_X/O正常计数，RGB正常递增");
    #(PIXEL_CLK_PERIOD * 500); // 持续测试
    DE_SHIELD_EN_I = 0; // 关闭屏蔽

    // 7. 测试场景5：行内控制信号波动（验证缓存稳定性）
    #(PIXEL_CLK_PERIOD * 300);
    $display("\n=== 测试场景5：行内控制信号波动（验证HS缓存）===");
    DE_EXTEND_EN_I = 1;
    DE_EXTEND_MODE_I = 0;
    #(PIXEL_CLK_PERIOD * 100); // 等待HS下降沿缓存
    // 行内波动控制信号（理论上不影响当前行）
    DE_EXTEND_EN_I = 0;
    DE_EXTEND_MODE_I = 1;
    DE_SHIELD_EN_I = 1;
    #(PIXEL_CLK_PERIOD * 500); // 观察行内是否稳定
    $display("行内信号波动后，预期当前行仍保持×2延长（缓存生效）");
    DE_EXTEND_EN_I = 0;
    DE_SHIELD_EN_I = 0;

    // 8. 测试场景6：VS_MODE 模式切换（模式2：单次触发）
    #(PIXEL_CLK_PERIOD * 300);
    VS_MODE_I = 2'b10; // 模式2：单次触发
    $display("\n=== 测试场景6：VS_MODE=2（单次触发）===");
    #(PIXEL_CLK_PERIOD * 100);
    VS_ALIGN_I = 1; // 触发VS_ALIGN上升沿
    #(PIXEL_CLK_PERIOD);
    VS_ALIGN_I = 0;
    #(PIXEL_CLK_PERIOD * 2000); // 等待1场时序完成（精简后更快）

    // 9. 测试结束
    #(PIXEL_CLK_PERIOD * 500);
    $display("\n=== 所有测试场景完成（总测试时间大幅缩短）===");
    $finish;
end

// 波形文件生成（Vivado仿真可查看）
initial begin
    $dumpfile("tb_tpg_vs_align.vcd");
    $dumpvars(0, tb_tpg_vs_align);
end

// 实时打印关键信号（可选，便于快速观察）
always @(posedge PIXEL_CLK_I) begin
    if (RESETN_I && (DE_O || DE_SHIELD_EN_I) && (x % 200 == 0)) begin // 每200个时钟打印1次
        $display(
            "CLK: %t | DE_O: %b | SHIELD: %b | EXTEND: %b(%b) | ACTIVE_X: %d | ACTIVE_Y: %d | RGB: (%h,%h,%h)",
            $time, DE_O, DE_SHIELD_EN_I, DE_EXTEND_EN_I, DE_EXTEND_MODE_I,
            ACTIVE_X_O, ACTIVE_Y_O, R_O, G_O, B_O
        );
    end
end

reg [31:0] x = 0;
always @(posedge PIXEL_CLK_I) begin
    x <= x + 1;
end

endmodule