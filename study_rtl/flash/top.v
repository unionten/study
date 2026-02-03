`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/17 13:11:05
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
input clk_p ,
input clk_n ,
output FLASH_WP_O   ,
output FLASH_HOLD_O ,
output FLASH_CS_O   ,
output FLASH_D0_O   ,
input  FLASH_D1_I   


    );
 

wire [63:0] pdata_o;
wire busy;
wire finish;

wire [7:0] CMD_I ;     
wire   START_I   ; 
wire [23:0] ADDR_I ;    
wire [7:0] BYTE_NUM_I ;
wire [63:0] PDATA_I ;   
wire rst;

clk_wiz_0  clk_wiz_0
 (
  .clk_out1 (clk_100),
  .clk_in1_p(clk_p),
  .clk_in1_n(clk_n)
 );



flash  
    #(.C_MAX_BYTE_NUM      (2), 
      .C_CLK_DIV           (20), 
      .C_INIT_ADDR         (24'hFF0000), 
      .C_INIT_ENABLE       (1), 
      .C_INIT_BYTE_NUM     (2),
      .C_INIT_TIMES        (4),
      .C_INIT_DELAY_SYS_CLK_NUM(100),
      .C_CS_BEGIN_PROTECT_DELAY_SYS_CLK_NUM(20),
      .C_CS_END_PROTECT_DELAY_SYS_CLK_NUM  (20),
      .C_BUSY_PROTECT_DELAY_SYS_CLK_NUM    (20)
      )
    uut(
    .SYS_RST_I        (rst),
    .SYS_CLK_I        (clk_100),//quick clk
    .FLASH_CLK_O  (FLASH_CLK_O  ),
    .FLASH_CS_O   (FLASH_CS_O   ),//flash clk
    .FLASH_D0_O   (FLASH_D0_O   ),
    .FLASH_D1_I   (FLASH_D1_I   ),
    .FLASH_WP_O   (FLASH_WP_O   ),
    .FLASH_HOLD_O (FLASH_HOLD_O ),
    .CMD_I        (CMD_I      ),
    .START_I      (START_I    ),
    .ADDR_I       (ADDR_I     ),
    .BYTE_NUM_I   (BYTE_NUM_I ),
    .PDATA_I      (PDATA_I    ), 
    .PDATA_O      (pdata_o), 
    .BUSY_O       (busy),
    .FINISH_O     (finish) 
    
    );

STARTUPE2 #(
      .PROG_USR("FALSE"),  // Activate program event security feature. Requires encrypted bitstreams.
      .SIM_CCLK_FREQ(0.0)  // Set the Configuration Clock Frequency(ns) for simulation.
    )
    STARTUPE2_u (
      .CFGCLK(CFGCLK),     // 1-bit output: Configuration main clock output
      .CFGMCLK(CFGMCLK),   // 1-bit output: Configuration internal oscillator clock output
      .EOS(EOS),           // 1-bit output: Active high output signal indicating the End Of Startup.
      .PREQ(),             // 1-bit output: PROGRAM request to fabric output
      .CLK(0),             // 1-bit input: User start-up clock input
      .GSR(0),             // 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
      .GTS(0),             // 1-bit input: Global 3-state input (GTS cannot be used for the port name)
      .KEYCLEARB(),        // 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
      .PACK(),             // 1-bit input: PROGRAM acknowledge input
      .USRCCLKO(FLASH_CLK_O),  // 1-bit input: User CCLK input
      .USRCCLKTS(0),       // 1-bit input: User CCLK 3-state enable input
      .USRDONEO(1),        // 1-bit input: User DONE pin output control
      .USRDONETS(1)        // 1-bit input: User DONE 3-state enable output
    );



vio_0 vio_0(
.clk       (clk_100),
.probe_out0(CMD_I),
.probe_out1(START_I),
.probe_out2(ADDR_I),
.probe_out3(BYTE_NUM_I),
.probe_out4(PDATA_I),
.probe_out5(rst)
);



ila_0 ila_0(
.clk (clk_100),
.probe0(pdata_o),
.probe1(busy   ),
.probe2(finish ),
.probe3(FLASH_CLK_O),
.probe4(FLASH_CS_O ), 
.probe5(FLASH_D0_O ), 
.probe6(FLASH_D1_I )

);


   
endmodule


