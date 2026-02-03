`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// 
// Create Date: 2024/01/17 13:22:03
// Design Name: 
// Module Name: oserdes
//////////////////////////////////////////////////////////////////////////////////

//OSERDESE3 Data Bits to Connect to the SerDes
//note: 用户位宽    底层位宽
//DDR 8:1           8    D7, D6, D5, D4, D3, D2, D1, D0
//DDR 4:1           4    0, 0, 0, 0, D3, D2, D1, D0
//SDR 8:1           N/A   N/A
//SDR 4:1           8    D3, D3, D2, D2, D1, D1, D0, D0
//SDR 2:1           4    0, 0, 0, 0, D1, D1, D0, D0

module oserdes(
input  [7:0] D_I      ,//对于OSERDES3, 位宽定死
input  [3:0] T_I      ,
output       OQ_O     ,
output       TQ_O     ,
input        CLK_I    ,
input        CLKDIV_I ,
input        RST_I    



    );
    
parameter C_DEVICE     =  "K7" ;//"KU" "KUP" "A7" "K7"
parameter C_DATA_RATE  =  "DDR";//"SDR" "DDR"
parameter C_DATA_WIDTH = 8;// 【已统一为用户位宽】 注意，要根据上表配置，不一定和用户认为的位宽一致  --   用户位宽

parameter C_TRI_RATE   = 4;
parameter C_TRI_WIDTH  = 1;

/////////////////////////////////////////////////////////////////////

localparam C_OS3_DATA_WIDTH = C_DATA_RATE=="DDR" ? C_DATA_WIDTH :  C_DATA_WIDTH*2 ;



generate if(C_DEVICE=="A7" | C_DEVICE=="K7" )begin  
   OSERDESE2 #(
      .DATA_RATE_OQ(C_DATA_RATE),   // DDR, SDR  有实际的sdr和ddr模式
      .DATA_RATE_TQ(C_DATA_RATE),   // DDR, BUF, SDR   T的DDR还是SDR模式可切换
      .DATA_WIDTH(C_DATA_WIDTH),         // Parallel data width (2-8,10,14)   
      .INIT_OQ(1'b0),         // Initial value of OQ output (1'b0,1'b1)
      .INIT_TQ(1'b0),         // Initial value of TQ output (1'b0,1'b1)
      .SERDES_MODE("MASTER"), // MASTER, SLAVE
      .SRVAL_OQ(1'b0),        // OQ output value when SR is used (1'b0,1'b1)
      .SRVAL_TQ(1'b0),        // TQ output value when SR is used (1'b0,1'b1)
      .TBYTE_CTL("FALSE"),    // Enable tristate byte operation (FALSE, TRUE) always false
      .TBYTE_SRC("FALSE"),    // Tristate byte source (FALSE, TRUE) always false
      .TRISTATE_WIDTH(C_TRI_WIDTH)      // 3-state converter width (1,4) , 根据手册配置
   )
   OSERDESE2_inst (
      .OFB(  ),             // 1-bit output: Feedback path for data  向ODERLAY 或者向ISERDES发送数据
      .OQ(OQ_O),               // 1-bit output: Data path output
      .SHIFTOUT1( ),// SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each) 级联
      .SHIFTOUT2( ),
      .TBYTEOUT( ),   // 1-bit output: Byte group tristate
      .TFB( ),             // 1-bit output: 3-state control
      .TQ(TQ_O),               // 1-bit output: 3-state control
      .CLK(CLK_I),             // 1-bit input: High speed clock
      .CLKDIV(CLKDIV_I),       // 1-bit input: Divided clock
      .D1(D_I[0]),// D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
      .D2(D_I[1]),
      .D3(D_I[2]),
      .D4(D_I[3]),
      .D5(D_I[4]),
      .D6(D_I[5]),
      .D7(D_I[6]),
      .D8(D_I[7]),
      .OCE(1),             // 1-bit input: Output data clock enable 
      .RST(RST_I),             // 1-bit input: Reset
      .SHIFTIN1(0 ),// SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
      .SHIFTIN2(0 ),
      .T1(T_I[0]),// T1 - T4: 1-bit (each) input: Parallel 3-state inputs
      .T2(T_I[1]),
      .T3(T_I[2]),
      .T4(T_I[3]),
      .TBYTEIN( 0 ),     // 1-bit input: Byte group tristate  不清楚功能
      .TCE(1)              // 1-bit input: 3-state clock enable
   );
end else if(C_DEVICE=="KU" | C_DEVICE=="KUP" )begin //ku和kup系列不存在实际的 sdr模式
//DDR 8:1           8    D7, D6, D5, D4, D3, D2, D1, D0
//DDR 4:1           4    0, 0, 0, 0, D3, D2, D1, D0
//SDR 8:1           N/A   N/A
//SDR 4:1           8    D3, D3, D2, D2, D1, D1, D0, D0
//SDR 2:1           4    0, 0, 0, 0, D1, D1, D0, D0

   OSERDESE3 #(
      .DATA_WIDTH(C_OS3_DATA_WIDTH),            // Parallel Data Width (4-8)
      .INIT(1'b0),               // Initialization value of the OSERDES flip-flops
      .IS_CLKDIV_INVERTED(1'b0), // Optional inversion for CLKDIV
      .IS_CLK_INVERTED(1'b0),    // Optional inversion for CLK
      .IS_RST_INVERTED(1'b0),    // Optional inversion for RST
      .SIM_DEVICE(C_DEVICE=="KU"  ? "ULTRASCALE" : "ULTRASCALE_PLUS")  // Set the device version for simulation functionality (ULTRASCALE)
   )
   OSERDESE3_inst (
      .OQ(OQ_O),         // 1-bit output: Serial Output Data
      .T_OUT(TQ_O),   // 1-bit output: 3-state control output to IOB
      .CLK(CLK_I),       // 1-bit input: High-speed clock
      .CLKDIV(CLKDIV_I), // 1-bit input: Divided Clock
      .D( C_DATA_RATE=="DDR" ?  {D_I[7],D_I[6],D_I[5],D_I[4],D_I[3],D_I[2],D_I[1],D_I[0]} : 
                                {D_I[3],D_I[3],D_I[2],D_I[2],D_I[1],D_I[1],D_I[0],D_I[0]} 
      ),           // 8-bit input: Parallel Data Input
      .RST(RST_I),       // 1-bit input: Asynchronous Reset
      .T(T_I[0])            // 1-bit input: Tristate input from fabric    8位三态同时变化
   );
end 
else begin
   OSERDESE2 #(
      .DATA_RATE_OQ(C_DATA_RATE),   // DDR, SDR  有实际的sdr和ddr模式
      .DATA_RATE_TQ(C_DATA_RATE),   // DDR, BUF, SDR   T的DDR还是SDR模式可切换
      .DATA_WIDTH(C_DATA_WIDTH),         // Parallel data width (2-8,10,14)   
      .INIT_OQ(1'b0),         // Initial value of OQ output (1'b0,1'b1)
      .INIT_TQ(1'b0),         // Initial value of TQ output (1'b0,1'b1)
      .SERDES_MODE("MASTER"), // MASTER, SLAVE
      .SRVAL_OQ(1'b0),        // OQ output value when SR is used (1'b0,1'b1)
      .SRVAL_TQ(1'b0),        // TQ output value when SR is used (1'b0,1'b1)
      .TBYTE_CTL("FALSE"),    // Enable tristate byte operation (FALSE, TRUE) always false
      .TBYTE_SRC("FALSE"),    // Tristate byte source (FALSE, TRUE) always false
      .TRISTATE_WIDTH(C_TRI_WIDTH)      // 3-state converter width (1,4) , 根据手册配置
   )
   OSERDESE2_inst (
      .OFB(  ),             // 1-bit output: Feedback path for data  向ODERLAY 或者向ISERDES发送数据
      .OQ(OQ_O),               // 1-bit output: Data path output
      .SHIFTOUT1( ),// SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each) 级联
      .SHIFTOUT2( ),
      .TBYTEOUT( ),   // 1-bit output: Byte group tristate
      .TFB( ),             // 1-bit output: 3-state control
      .TQ(TQ_O),               // 1-bit output: 3-state control
      .CLK(CLK_I),             // 1-bit input: High speed clock
      .CLKDIV(CLKDIV_I),       // 1-bit input: Divided clock
      .D1(D_I[0]),// D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
      .D2(D_I[1]),
      .D3(D_I[2]),
      .D4(D_I[3]),
      .D5(D_I[4]),
      .D6(D_I[5]),
      .D7(D_I[6]),
      .D8(D_I[7]),
      .OCE(1),             // 1-bit input: Output data clock enable 
      .RST(RST_I),             // 1-bit input: Reset
      .SHIFTIN1(0 ),// SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
      .SHIFTIN2(0 ),
      .T1(T_I[0]),// T1 - T4: 1-bit (each) input: Parallel 3-state inputs
      .T2(T_I[1]),
      .T3(T_I[2]),
      .T4(T_I[3]),
      .TBYTEIN( 0 ),     // 1-bit input: Byte group tristate  不清楚功能
      .TCE(1)              // 1-bit input: 3-state clock enable
   );
end
endgenerate
    
    
   
    
    
    
endmodule
