`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/02 11:58:04
// Design Name: 
// Module Name: xpll
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////


module xpll(
input  PLL_CLK_IN  ,
output PLL_CLK_OUT ,
output PLL_CLK_DIV ,
output PLL_CLK_LOCKED 

);
    
    
PLLE4_BASE #(
      .CLKFBOUT_MULT(1),          // Multiply value for all CLKOUT
      .CLKFBOUT_PHASE(0.0),       // Phase offset in degrees of CLKFB
      .CLKIN_PERIOD(0.0),         // Input clock period in ns to ps resolution (i.e., 33.333 is 30 MHz).
      .CLKOUT0_DIVIDE(1),         // Divide amount for CLKOUT0
      .CLKOUT0_DUTY_CYCLE(0.5),   // Duty cycle for CLKOUT0
      .CLKOUT0_PHASE(0.0),        // Phase offset for CLKOUT0
      .CLKOUT1_DIVIDE(4),         // Divide amount for CLKOUT1
      .CLKOUT1_DUTY_CYCLE(0.5),   // Duty cycle for CLKOUT1
      .CLKOUT1_PHASE(0.0),        // Phase offset for CLKOUT1
      .CLKOUTPHY_MODE("VCO_2X"),  // Frequency of the CLKOUTPHY
      .DIVCLK_DIVIDE(1),          // Master division value
      .IS_CLKFBIN_INVERTED(1'b0), // Optional inversion for CLKFBIN
      .IS_CLKIN_INVERTED(1'b0),   // Optional inversion for CLKIN
      .IS_PWRDWN_INVERTED(1'b0),  // Optional inversion for PWRDWN
      .IS_RST_INVERTED(1'b0),     // Optional inversion for RST
      .REF_JITTER(0.0),           // Reference input jitter in UI
      .STARTUP_WAIT("FALSE")      // Delays DONE until PLL is locked
   )
   PLLE4_BASE_inst (
      .CLKFBOUT(CLKFBOUT),       // 1-bit output: Feedback clock
      .CLKOUT0(PLL_CLK_OUT),         // 1-bit output: General Clock output
      .CLKOUT0B( ),       // 1-bit output: Inverted CLKOUT0
      .CLKOUT1(PLL_CLK_DIV),         // 1-bit output: General Clock output
      .CLKOUT1B( ),       // 1-bit output: Inverted CLKOUT1
      .CLKOUTPHY( ),     // 1-bit output: Bitslice clock
      .LOCKED(PLL_CLK_LOCKED),           // 1-bit output: LOCK
      .CLKFBIN(CLKFBOUT),         // 1-bit input: Feedback clock
      .CLKIN(PLL_CLK_IN),             // 1-bit input: Input clock
      .CLKOUTPHYEN(1), // 1-bit input: CLKOUTPHY enable
      .PWRDWN(0),           // 1-bit input: Power-down
      .RST(0)                  // 1-bit input: Reset
   );






    
endmodule



