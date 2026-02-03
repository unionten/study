`timescale 1ps/1ps
//-------------------------------------------------------------------------------------------
// Inputs
//      SSTEP:      Start a reconfiguration. 【It should only be pulsed for one clock cycle】
//      STATE:      Determines which state the PLL_ADV will be reconfigured to. A value
//                  of 0 correlates to state 1, and a value of 1 correlates to state 2.
//      RST:        RST will reset the entire reference design including the PLL_ADV.
//      CLKIN:      Clock for the PLL_ADV CLKIN as well as the clock for the PLL_DRP module
//      SRDY:       Pulses for one clock cycle after the PLL_ADV is locked and the
//                  PLL_DRP module is ready to start another re-configuration.
//-------------------------------------------------------------------------------------------
//时序图
//CLK_IN  __|——|__|——|__|——|__|——|__|——|__|——|__|——|__
//SRDY    ______________|—————|_______________________
//LOCKED_OUT____________|——————————————————————————————
`define SYN_MULTI_BIT_SINGLE(u_name,clk_in,data_in,clk_out,data_out,data_width)               xpm_cdc_array_single #(.DEST_SYNC_FF(4),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(data_width)) u_name(.src_clk(clk_in),.src_in(data_in),.dest_clk(clk_out),.dest_out(data_out));       
`define SYN_SINGLE_BIT_PULSE(u_name,clk_in,rst_in,pulse_in,clk_out,rst_out,pulse_out)         xpm_cdc_pulse #(.DEST_SYNC_FF(4), .INIT_SYNC_FF(0),.REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) u_name (.src_clk(clk_in),.src_rst(rst_in),.src_pulse(pulse_in),.dest_clk(clk_out),.dest_rst(rst_out),.dest_pulse(pulse_out));            
module plle2_drp_top(
    input    SSTEP,//异步脉冲触发信号（~STATE）
    input    [7:0] STATE,  
    //SADDR      0      1      2     3      4   
    //CLK     37.125 133.32  65.73 148.5  74.25  MHz
    //period  36.73    7.5   15.21 6.734  13.46  ns 
    input    RST,
    input    CLKIN,//PLL输入时钟
    output   SRDY,
    output   LOCKED_OUT,
    output   CLK0OUT //BUFG inner
);
  
//内部调整顺序 
reg [7:0] state_dis;
always@(*)begin
    case(STATE)
        0:state_dis = 1;
        1:state_dis = 3;
        2:state_dis = 4;
        3:state_dis = 0;
        4:state_dis = 2;
        default:state_dis = 1;
    endcase
end
  
//-------------------------------------------------------------------------------------------
// These signals are used as direct connections between the PLL_ADV and the
// PLL_DRP.
(* MARK_DEBUG="true" *) wire [15:0]    di;
(* MARK_DEBUG="true" *) wire [6:0]     daddr; //pll_drp
(* MARK_DEBUG="true" *) wire [15:0]    dout;
(* MARK_DEBUG="true" *) wire           den;
(* MARK_DEBUG="true" *) wire           dwe;
wire            dclk;
wire            rst_pll;
wire            drdy;
reg				current_state;
reg [7:0]		sstep_int = 0;
wire			new_sstep;
reg				init_drp_state = 1;
// These signals are used for the BUFG's necessary for the design.
wire            CLKIN_ibuf;
wire            clkin_bufgout;
wire            clkfb_bufgout;
wire            clkfb_bufgin;
wire            clk0_bufgin;
wire            clk0_bufgout;
wire            clk1_bufgin;
wire            clk1_bufgout;
wire            clk2_bufgin;
wire            clk2_bufgout;
wire            clk3_bufgin;
wire            clk3_bufgout;
wire            clk4_bufgin;
wire            clk4_bufgout;
wire            clk5_bufgin;
wire            clk5_bufgout;
wire            LOCKED;
//-------------------------------------------------------------------------------------------
assign CLKIN_ibuf = CLKIN;
//
// Global buffers used in design
BUFG BUFG_IN    (.O(clkin_bufgout), .I(CLKIN_ibuf));
BUFG BUFG_FB    (.O(clkfb_bufgout), .I(clkfb_bufgin));
BUFG BUFG_inst (
      .O(CLK0OUT), // 1-bit output: Clock output
      .I(clk0_bufgin)  // 1-bit input: Clock input
   );

//BUFG BUFG_CLK0  (.O(clk0_bufgout),  .I(clk0_bufgin));
//BUFG BUFG_CLK1  (.O(clk1_bufgout),  .I(clk1_bufgin));
//BUFG BUFG_CLK2  (.O(clk2_bufgout),  .I(clk2_bufgin));
//BUFG BUFG_CLK3  (.O(clk3_bufgout),  .I(clk3_bufgin));
//BUFG BUFG_CLK4  (.O(clk4_bufgout),  .I(clk4_bufgin));
//BUFG BUFG_CLK5  (.O(clk5_bufgout),  .I(clk5_bufgin));
//
// ODDR registers used to output clocks
//ODDR ODDR_CLK0 (.Q(CLK0OUT), .C(clk0_bufgout), .CE(1'b1), .D1(1'b1), .D2(1'b0), .R(RST), .S(1'b0));
//ODDR ODDR_CLK1 (.Q(CLK1OUT), .C(clk1_bufgout), .CE(1'b1), .D1(1'b1), .D2(1'b0), .R(RST), .S(1'b0));
//ODDR ODDR_CLK2 (.Q(CLK2OUT), .C(clk2_bufgout), .CE(1'b1), .D1(1'b1), .D2(1'b0), .R(RST), .S(1'b0));
//ODDR ODDR_CLK3 (.Q(CLK3OUT), .C(clk3_bufgout), .CE(1'b1), .D1(1'b1), .D2(1'b0), .R(RST), .S(1'b0));
//ODDR ODDR_CLK4 (.Q(CLK4OUT), .C(clk4_bufgout), .CE(1'b1), .D1(1'b1), .D2(1'b0), .R(RST), .S(1'b0));
//ODDR ODDR_CLK5 (.Q(CLK5OUT), .C(clk5_bufgout), .CE(1'b1), .D1(1'b1), .D2(1'b0), .R(RST), .S(1'b0));
//
// PLL_ADV that reconfiguration will take place on
//
//  BANDWIDTH:              : "HIGH", "LOW", "OPTIMIZED"
//  DIVCLK_DIVIDE           : Value from 1 to 56
//  CLKFBOUT_MULT           : Value from 2 to 64
//  CLKIN1_PERIOD           : Value from 0.968 to 100.000. Set the period (ns) of input clocks
//  DIVIDE                  : Value from 1 to 128
//  DUTY_CYCLE              : 0.01 to 0.99 - This is dependent on the divide value.
//  PHASE                   : 0.0 to 360.0 - This is dependent on the divide value.
//
PLLE2_ADV #(
    .COMPENSATION       ("ZHOLD"),
    .BANDWIDTH          ("LOW"),
    .DIVCLK_DIVIDE      (5),
    .CLKFBOUT_MULT      (52),
    .CLKFBOUT_PHASE     (0.0),
    .CLKIN1_PERIOD      (10.000),
    .REF_JITTER1        (0.010),
    .CLKIN2_PERIOD      (10.000),
    .REF_JITTER2        (0.010),
    .CLKOUT0_DIVIDE     (7),
    .CLKOUT0_DUTY_CYCLE (0.5),
    .CLKOUT0_PHASE      (0.0))
    pll_test_inst (
    .CLKFBOUT           (clkfb_bufgin),
    .CLKOUT0            (clk0_bufgin),
    .CLKOUT1            (clk1_bufgin),
    .CLKOUT2            (clk2_bufgin),
    .CLKOUT3            (clk3_bufgin),
    .CLKOUT4            (clk4_bufgin),
    .CLKOUT5            (clk5_bufgin),
    .DO                 (dout),
    .DRDY               (drdy),
    .DADDR              (daddr),
    .DCLK               (dclk),
    .DEN                (den),
    .DI                 (di),
    .DWE                (dwe),
    .LOCKED             (LOCKED),
    .CLKFBIN            (clkfb_bufgout),
    .CLKIN1             (clkin_bufgout),//PLL输入时钟
    .CLKIN2             (clkin_bufgout),
    .CLKINSEL           (1'b1),
    .PWRDWN             (1'b0),
    .RST                (rst_pll));

plle2_drp //参数在模块内部配置
    plle2_drp_inst (
    .SADDR              (state_dis),//[7:0]
    .SEN                (sstep_int[0]),
    .RST                (RST),
    .SRDY               (SRDY),
    .SCLK               (clkin_bufgout),//PLL输入时钟
    .DO                 (dout),
    .DRDY               (drdy),
    .LOCK_REG_CLK_IN    (clkin_bufgout),
    .LOCKED_IN          (LOCKED),
    .DWE                (dwe),
    .DEN                (den),
    .DADDR              (daddr),
    .DI                 (di),
    .DCLK               (dclk),
    .RST_PLL            (rst_pll),
    .LOCKED_OUT         (LOCKED_OUT)
);


always @ (posedge clkin_bufgout or posedge SSTEP)begin
    if (SSTEP) sstep_int <= 8'h80;
    else sstep_int <= {1'b0, sstep_int[7:1]};
end

endmodule


//////////////////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
// Device:              7-Series
// Author:              Tatsukawa, Kruger, Defossez
// Entity Name:         top_plle2
// Purpose:             This calls the DRP register calculation functions and
//                      provides a state machine to perform MMCM reconfiguration
//                      based on the calculated values stored in a initialized
//                      ROM.
// Tools:               Vivado_2019.1 or newer
// Vendor:              Xilinx Inc.
// Version:             1.40
// Filename:            top_plle2.v
// Date Created:        13-Jan-2011
// Date Last Modified:  25-Jun-2019
//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
`timescale 1ps/1ps
//
module plle2_drp
    #(
        parameter REGISTER_LOCKED       = "Reg",
        parameter USE_REG_LOCKED        = "No",
        
        //SADDR    0       1       2       3       4
        //CLK    148.5  37.125   74.25  133.32   65.73 
        //////////////////////////////////////////////
        ///////////////CONFIGURATION 1////////////////148.5
        parameter S1_CLKFBOUT_PHASE     = 0,    //-360000 ~ 360000
        parameter S1_BANDWIDTH          = "LOW",
        parameter S1_CLKFBOUT_MULT      = 49,   //1 ~ 64.
        parameter S1_DIVCLK_DIVIDE      = 3,    //1 ~ 128
        parameter S1_CLKOUT0_DIVIDE     = 11,
        parameter S1_CLKOUT0_PHASE      = 0,
        parameter S1_CLKOUT0_DUTY       = 50000,

        //////////////////////////////////////////////
        ///////////////CONFIGURATION 2////////////////37.125
        parameter S2_CLKFBOUT_PHASE     = 0,    //-360000 ~ 360000
        parameter S2_BANDWIDTH          = "LOW",
        parameter S2_CLKFBOUT_MULT      = 49,   //1 ~ 64.
        parameter S2_DIVCLK_DIVIDE      = 4,    //1 ~ 128
        parameter S2_CLKOUT0_DIVIDE     = 33,
        parameter S2_CLKOUT0_PHASE      = 0,
        parameter S2_CLKOUT0_DUTY       = 50000,
        
        
        //////////////////////////////////////////////
        ///////////////CONFIGURATION 3////////////////74.25（理论）---74.242（实际）
        parameter S3_CLKFBOUT_PHASE     = 0,    //-360000 ~ 360000
        parameter S3_BANDWIDTH          = "LOW",
        parameter S3_CLKFBOUT_MULT      = 49,   //1 ~ 64.
        parameter S3_DIVCLK_DIVIDE      = 3,    //1 ~ 128
        parameter S3_CLKOUT0_DIVIDE     = 22,
        parameter S3_CLKOUT0_PHASE      = 0,
        parameter S3_CLKOUT0_DUTY       = 50000,
        
        
        //////////////////////////////////////////////
        ///////////////CONFIGURATION 4////////////////133.32
        parameter S4_CLKFBOUT_PHASE     = 0,    //-360000 ~ 360000
        parameter S4_BANDWIDTH          = "LOW",
        parameter S4_CLKFBOUT_MULT      = 28,   //1 ~ 64.
        parameter S4_DIVCLK_DIVIDE      = 3,    //1 ~ 128
        parameter S4_CLKOUT0_DIVIDE     = 7,
        parameter S4_CLKOUT0_PHASE      = 0,
        parameter S4_CLKOUT0_DUTY       = 50000,
        
        
        //////////////////////////////////////////////
        ///////////////CONFIGURATION 5////////////////65.73
        parameter S5_CLKFBOUT_PHASE     = 0,    //-360000 ~ 360000
        parameter S5_BANDWIDTH          = "LOW",
        parameter S5_CLKFBOUT_MULT      = 46,   //1 ~ 64.
        parameter S5_DIVCLK_DIVIDE      = 5,    //1 ~ 128
        parameter S5_CLKOUT0_DIVIDE     = 14,
        parameter S5_CLKOUT0_PHASE      = 0,
        parameter S5_CLKOUT0_DUTY       = 50000
        

        ) (
        // These signals are controlled by user 
        input      [7:0]  SADDR,
        input             SEN,
        input             SCLK,//100M
        input             RST,
        output reg        SRDY,
        // These signals are to be connected to the pll_ADV
        input      [15:0] DO,
        input             DRDY,
        input             LOCK_REG_CLK_IN,
        input             LOCKED_IN,
        output reg        DWE,
        output reg        DEN,
        output reg [6:0]  DADDR,
        output reg [15:0] DI,
        output            DCLK,
        output reg        RST_PLL,
        output            LOCKED_OUT
    );
    wire        IntLocked;
    wire        IntRstPll;
    //
    // 100 ps delay for behavioral simulations
    localparam  TCQ = 100;

    (* rom_style = "distributed" *)
    //
    // ROM of: 39-bit word 64 words deep
    reg [38:0]  rom [63:0];
    reg [5:0]   rom_addr;
    reg [38:0]  rom_do;
    reg         next_srdy;
    reg [5:0]   next_rom_addr;
    reg [6:0]   next_daddr;
    reg         next_dwe;
    reg         next_den;
    reg         next_RST_PLL;
    reg [15:0]  next_di;

    generate
        if (REGISTER_LOCKED == "NoReg" && USE_REG_LOCKED == "No") begin
            assign LOCKED_OUT = LOCKED_IN;
            assign IntLocked = LOCKED_IN;
        end else if (REGISTER_LOCKED == "Reg" && USE_REG_LOCKED == "No") begin
            FDRE #(
                .INIT           (0),
                .IS_C_INVERTED  (0),
                .IS_D_INVERTED  (0),
                .IS_R_INVERTED  (0)
            ) mmcme3_drp_I_Fdrp (
                .D      (LOCKED_IN),
                .CE     (1'b1),
                .R      (IntRstPll),
                .C      (LOCK_REG_CLK_IN),
                .Q      (LOCKED_OUT)
            );
            //
            assign IntLocked = LOCKED_IN;
        end else if (REGISTER_LOCKED == "Reg" && USE_REG_LOCKED == "Yes") begin
            FDRE #(
                .INIT           (0),
                .IS_C_INVERTED  (0),
                .IS_D_INVERTED  (0),
                .IS_R_INVERTED  (0)
            ) mmcme3_drp_I_Fdrp (
                .D  (LOCKED_IN),
                .CE (1'b1),
                .R  (IntRstPll),
                .C  (LOCK_REG_CLK_IN),
                .Q  (LOCKED_OUT)
            );
            //
            assign IntLocked = LOCKED_OUT;
        end
    endgenerate

    // Integer used to initialize remainder of unused ROM
    integer     ii;

    // Pass SCLK to DCLK for the MMCM
    assign DCLK = SCLK;
    assign IntRstPll = RST_PLL;

    // Include the MMCM reconfiguration functions.  This contains the constant
    // functions that are used in the calculations below.  This file is
    // required.
    
    //`include "plle2_drp_func.h"//已经复制到本文件内
    
    //**************************************************************************
    // State 1 Calculations
    //**************************************************************************
    localparam [37:0] S1_CLKFBOUT       =
       pll_count_calc(S1_CLKFBOUT_MULT, S1_CLKFBOUT_PHASE, 50000);
    localparam [9:0]  S1_DIGITAL_FILT   =
       pll_filter_lookup(S1_CLKFBOUT_MULT, S1_BANDWIDTH);
    localparam [39:0] S1_LOCK           =
       pll_lock_lookup(S1_CLKFBOUT_MULT);
    localparam [37:0] S1_DIVCLK         =
       pll_count_calc(S1_DIVCLK_DIVIDE, 0, 50000);
    localparam [37:0] S1_CLKOUT0        =
       pll_count_calc(S1_CLKOUT0_DIVIDE, S1_CLKOUT0_PHASE, S1_CLKOUT0_DUTY);
    //**************************************************************************
    // State 2 Calculations
    //**************************************************************************
    localparam [37:0] S2_CLKFBOUT       =
       pll_count_calc(S2_CLKFBOUT_MULT, S2_CLKFBOUT_PHASE, 50000);
    localparam [9:0] S2_DIGITAL_FILT    =
       pll_filter_lookup(S2_CLKFBOUT_MULT, S2_BANDWIDTH);
    localparam [39:0] S2_LOCK           =
       pll_lock_lookup(S2_CLKFBOUT_MULT);
    localparam [37:0] S2_DIVCLK         =
       pll_count_calc(S2_DIVCLK_DIVIDE, 0, 50000);
    localparam [37:0] S2_CLKOUT0        =
       pll_count_calc(S2_CLKOUT0_DIVIDE, S2_CLKOUT0_PHASE, S2_CLKOUT0_DUTY);
    //**************************************************************************
    // State 3 Calculations
    //**************************************************************************
    localparam [37:0] S3_CLKFBOUT       =
       pll_count_calc(S3_CLKFBOUT_MULT, S3_CLKFBOUT_PHASE, 50000);
    localparam [9:0] S3_DIGITAL_FILT    =
       pll_filter_lookup(S3_CLKFBOUT_MULT, S3_BANDWIDTH);
    localparam [39:0] S3_LOCK           =
       pll_lock_lookup(S3_CLKFBOUT_MULT);
    localparam [37:0] S3_DIVCLK         =
       pll_count_calc(S3_DIVCLK_DIVIDE, 0, 50000);
    localparam [37:0] S3_CLKOUT0        =
       pll_count_calc(S3_CLKOUT0_DIVIDE, S3_CLKOUT0_PHASE, S3_CLKOUT0_DUTY);
    //**************************************************************************
    // State 4 Calculations
    //**************************************************************************
    localparam [37:0] S4_CLKFBOUT       =
       pll_count_calc(S4_CLKFBOUT_MULT, S4_CLKFBOUT_PHASE, 50000);
    localparam [9:0] S4_DIGITAL_FILT    =
       pll_filter_lookup(S4_CLKFBOUT_MULT, S4_BANDWIDTH);
    localparam [39:0] S4_LOCK           =
       pll_lock_lookup(S4_CLKFBOUT_MULT);
    localparam [37:0] S4_DIVCLK         =
       pll_count_calc(S4_DIVCLK_DIVIDE, 0, 50000);
    localparam [37:0] S4_CLKOUT0        =
       pll_count_calc(S4_CLKOUT0_DIVIDE, S4_CLKOUT0_PHASE, S4_CLKOUT0_DUTY);
    //**************************************************************************
    // State 5 Calculations
    //**************************************************************************
    localparam [37:0] S5_CLKFBOUT       =
       pll_count_calc(S5_CLKFBOUT_MULT, S5_CLKFBOUT_PHASE, 50000);
    localparam [9:0] S5_DIGITAL_FILT    =
       pll_filter_lookup(S5_CLKFBOUT_MULT, S5_BANDWIDTH);
    localparam [39:0] S5_LOCK           =
       pll_lock_lookup(S5_CLKFBOUT_MULT);
    localparam [37:0] S5_DIVCLK         =
       pll_count_calc(S5_DIVCLK_DIVIDE, 0, 50000);
    localparam [37:0] S5_CLKOUT0        =
       pll_count_calc(S5_CLKOUT0_DIVIDE, S5_CLKOUT0_PHASE, S5_CLKOUT0_DUTY);

    initial begin
       // rom entries contain (in order) the address, a bitmask, and a bitset
       //***********************************************************************
       // State 1 Initialization
       //***********************************************************************

       // Store the power bits
       rom[0] = {7'h28, 16'h0000, 16'hFFFF};

       // Store CLKOUT0 divide and phase
       rom[1]  = {7'h08, 16'h1000, S1_CLKOUT0[15:0]};
       rom[2]  = {7'h09, 16'hFC00, S1_CLKOUT0[31:16]};

       // Store the input divider
       rom[3] = {7'h16, 16'hC000, {2'h0, S1_DIVCLK[23:22], S1_DIVCLK[11:0]} };

       // Store the feedback divide and phase
       rom[4] = {7'h14, 16'h1000, S1_CLKFBOUT[15:0]};
       rom[5] = {7'h15, 16'hFC00, S1_CLKFBOUT[31:16]};

       // Store the lock settings
       rom[6] = {7'h18, 16'hFC00, {6'h00, S1_LOCK[29:20]} };
       rom[7] = {7'h19, 16'h8000, {1'b0 , S1_LOCK[34:30], S1_LOCK[9:0]} };
       rom[8] = {7'h1A, 16'h8000, {1'b0 , S1_LOCK[39:35], S1_LOCK[19:10]} };

       // Store the filter settings
       rom[9] = {7'h4E, 16'h66FF,
          S1_DIGITAL_FILT[9], 2'h0, S1_DIGITAL_FILT[8:7], 2'h0,
          S1_DIGITAL_FILT[6], 8'h00 };
       rom[10] = {7'h4F, 16'h666F,
          S1_DIGITAL_FILT[5], 2'h0, S1_DIGITAL_FILT[4:3], 2'h0,
          S1_DIGITAL_FILT[2:1], 2'h0, S1_DIGITAL_FILT[0], 4'h0 };

       //***********************************************************************
       // State 2 Initialization
       //***********************************************************************

       // Store the power bits
       rom[11] = {7'h28, 16'h0000, 16'hFFFF};

       // Store CLKOUT0 divide and phase
       rom[12] = {7'h08, 16'h1000, S2_CLKOUT0[15:0]};
       rom[13] = {7'h09, 16'hFC00, S2_CLKOUT0[31:16]};

       // Store the input divider
       rom[14] = {7'h16, 16'hC000, {2'h0, S2_DIVCLK[23:22], S2_DIVCLK[11:0]} };

       // Store the feedback divide and phase
       rom[15] = {7'h14, 16'h1000, S2_CLKFBOUT[15:0]};
       rom[16] = {7'h15, 16'hFC00, S2_CLKFBOUT[31:16]};

       // Store the lock settings
       rom[17] = {7'h18, 16'hFC00, {6'h00, S2_LOCK[29:20]} };
       rom[18] = {7'h19, 16'h8000, {1'b0 , S2_LOCK[34:30], S2_LOCK[9:0]} };
       rom[19] = {7'h1A, 16'h8000, {1'b0 , S2_LOCK[39:35], S2_LOCK[19:10]} };

       // Store the filter settings
       rom[20] = {7'h4E, 16'h66FF,
          S2_DIGITAL_FILT[9], 2'h0, S2_DIGITAL_FILT[8:7], 2'h0,
          S2_DIGITAL_FILT[6], 8'h00 };
       rom[21] = {7'h4F, 16'h666F,
          S2_DIGITAL_FILT[5], 2'h0, S2_DIGITAL_FILT[4:3], 2'h0,
          S2_DIGITAL_FILT[2:1], 2'h0, S2_DIGITAL_FILT[0], 4'h0 };

    //***********************************************************************
       // State 3 Initialization
       //***********************************************************************

       // Store the power bits
       rom[22] = {7'h28, 16'h0000, 16'hFFFF};

       // Store CLKOUT0 divide and phase
       rom[23]  = {7'h08, 16'h1000, S3_CLKOUT0[15:0]};
       rom[24]  = {7'h09, 16'hFC00, S3_CLKOUT0[31:16]};

       // Store the input divider
       rom[25] = {7'h16, 16'hC000, {2'h0, S3_DIVCLK[23:22], S3_DIVCLK[11:0]} };

       // Store the feedback divide and phase
       rom[26] = {7'h14, 16'h1000, S3_CLKFBOUT[15:0]};
       rom[27] = {7'h15, 16'hFC00, S3_CLKFBOUT[31:16]};

       // Store the lock settings
       rom[28] = {7'h18, 16'hFC00, {6'h00, S3_LOCK[29:20]} };
       rom[29] = {7'h19, 16'h8000, {1'b0 , S3_LOCK[34:30], S3_LOCK[9:0]} };
       rom[30] = {7'h1A, 16'h8000, {1'b0 , S3_LOCK[39:35], S3_LOCK[19:10]} };

       // Store the filter settings
       rom[31] = {7'h4E, 16'h66FF,
          S3_DIGITAL_FILT[9], 2'h0, S3_DIGITAL_FILT[8:7], 2'h0,
          S3_DIGITAL_FILT[6], 8'h00 };
       rom[32] = {7'h4F, 16'h666F,
          S3_DIGITAL_FILT[5], 2'h0, S3_DIGITAL_FILT[4:3], 2'h0,
          S3_DIGITAL_FILT[2:1], 2'h0, S3_DIGITAL_FILT[0], 4'h0 };


        //***********************************************************************
       // State 4 Initialization
       //***********************************************************************

       // Store the power bits
       rom[33] = {7'h28, 16'h0000, 16'hFFFF};

       // Store CLKOUT0 divide and phase
       rom[34]  = {7'h08, 16'h1000, S4_CLKOUT0[15:0]};
       rom[35]  = {7'h09, 16'hFC00, S4_CLKOUT0[31:16]};

       // Store the input divider
       rom[36] = {7'h16, 16'hC000, {2'h0, S4_DIVCLK[23:22], S4_DIVCLK[11:0]} };

       // Store the feedback divide and phase
       rom[37] = {7'h14, 16'h1000, S4_CLKFBOUT[15:0]};
       rom[38] = {7'h15, 16'hFC00, S4_CLKFBOUT[31:16]};

       // Store the lock settings
       rom[39] = {7'h18, 16'hFC00, {6'h00, S4_LOCK[29:20]} };
       rom[40] = {7'h19, 16'h8000, {1'b0 , S4_LOCK[34:30], S4_LOCK[9:0]} };
       rom[41] = {7'h1A, 16'h8000, {1'b0 , S4_LOCK[39:35], S4_LOCK[19:10]} };

       // Store the filter settings
       rom[42] = {7'h4E, 16'h66FF,
          S4_DIGITAL_FILT[9], 2'h0, S4_DIGITAL_FILT[8:7], 2'h0,
          S4_DIGITAL_FILT[6], 8'h00 };
       rom[43] = {7'h4F, 16'h666F,
          S4_DIGITAL_FILT[5], 2'h0, S4_DIGITAL_FILT[4:3], 2'h0,
          S4_DIGITAL_FILT[2:1], 2'h0, S4_DIGITAL_FILT[0], 4'h0 };


       //***********************************************************************
       // State 5 Initialization
       //***********************************************************************

       // Store the power bits
       rom[44] = {7'h28, 16'h0000, 16'hFFFF};

       // Store CLKOUT0 divide and phase
       rom[45]  = {7'h08, 16'h1000, S5_CLKOUT0[15:0]};
       rom[46]  = {7'h09, 16'hFC00, S5_CLKOUT0[31:16]};

       // Store the input divider
       rom[47] = {7'h16, 16'hC000, {2'h0, S5_DIVCLK[23:22], S5_DIVCLK[11:0]} };

       // Store the feedback divide and phase
       rom[48] = {7'h14, 16'h1000, S5_CLKFBOUT[15:0]};
       rom[49] = {7'h15, 16'hFC00, S5_CLKFBOUT[31:16]};

       // Store the lock settings
       rom[50] = {7'h18, 16'hFC00, {6'h00, S5_LOCK[29:20]} };
       rom[51] = {7'h19, 16'h8000, {1'b0 , S5_LOCK[34:30], S5_LOCK[9:0]} };
       rom[52] = {7'h1A, 16'h8000, {1'b0 , S5_LOCK[39:35], S5_LOCK[19:10]} };

       // Store the filter settings
       rom[53] = {7'h4E, 16'h66FF,
          S5_DIGITAL_FILT[9], 2'h0, S5_DIGITAL_FILT[8:7], 2'h0,
          S5_DIGITAL_FILT[6], 8'h00 };
       rom[54] = {7'h4F, 16'h666F,
          S5_DIGITAL_FILT[5], 2'h0, S5_DIGITAL_FILT[4:3], 2'h0,
          S5_DIGITAL_FILT[2:1], 2'h0, S5_DIGITAL_FILT[0], 4'h0 };


       //////////////////////////////////////////////////////////////////////////////
       rom[55] = {7'h28, 32'h0000_0000};
       // Initialize the rest of the ROM
       for(ii = 56; ii < 64; ii = ii +1) begin
          rom[ii] = 0;
       end
    end

    // Output the initialized rom value based on rom_addr each clock cycle
    always @(posedge SCLK) begin
       rom_do<= #TCQ rom[rom_addr];
    end

    //**************************************************************************
    // Everything below is associated whith the state machine that is used to
    // Read/Modify/Write to the MMCM.
    //**************************************************************************

    // State Definitions
    localparam RESTART      = 4'h1;
    localparam WAIT_LOCK    = 4'h2;
    localparam WAIT_SEN     = 4'h3;
    localparam ADDRESS      = 4'h4;
    localparam WAIT_A_DRDY  = 4'h5;
    localparam BITMASK      = 4'h6;
    localparam BITSET       = 4'h7;
    localparam WRITE        = 4'h8;
    localparam WAIT_DRDY    = 4'h9;

    // State sync
    reg [3:0]  current_state   = RESTART;
    reg [3:0]  next_state      = RESTART;

    // These variables are used to keep track of the number of iterations that
    //    each state takes to reconfigure.
    // STATE_COUNT_CONST is used to reset the counters and should match the
    //    number of registers necessary to reconfigure each state.
    // STATE_COUNT_CONST：每次要配置的寄存器数 【 clk_num * 2 + 9 】
    // 思路：根据SADDR进入rom的分支，然后递增计数进行选择配置 - 所以rom的id需要连续
    localparam STATE_COUNT_CONST  = 11; 
    reg [4:0] state_count         = STATE_COUNT_CONST;
    reg [4:0] next_state_count    = STATE_COUNT_CONST;

    // This block assigns the next register value from the state machine below
    always @(posedge SCLK) begin
       DADDR       <= #TCQ next_daddr;
       DWE         <= #TCQ next_dwe;
       DEN         <= #TCQ next_den;
       RST_PLL    <= #TCQ next_RST_PLL;
       DI          <= #TCQ next_di;

       SRDY        <= #TCQ next_srdy;

       rom_addr    <= #TCQ next_rom_addr;
       state_count <= #TCQ next_state_count;
    end

    // This block assigns the next state, reset is syncronous.
    always @(posedge SCLK) begin
       if(RST) begin
          current_state <= #TCQ RESTART;
       end else begin
          current_state <= #TCQ next_state;
       end
    end

    always @* begin
       // Setup the default values
       next_srdy         = 1'b0;
       next_daddr        = DADDR;
       next_dwe          = 1'b0;
       next_den          = 1'b0;
       next_RST_PLL     = RST_PLL;
       next_di           = DI;
       next_rom_addr     = rom_addr;
       next_state_count  = state_count;

       case (current_state)
          // If RST is asserted reset the machine
          RESTART: begin//【上电时的入口】
             next_daddr     = 7'h00;
             next_di        = 16'h0000;
             next_rom_addr  = 6'h00;
             next_RST_PLL  = 1'b1; //【模块 上电时对PLL复位】
             next_state     = WAIT_LOCK;
          end

          // Waits for the MMCM to assert IntLocked - once it does asserts SRDY
          WAIT_LOCK: begin//一个大阶段配置完成后，即进入本阶段
             // Make sure reset is de-asserted
             next_RST_PLL   = 1'b0;
             // Reset the number of registers left to write for the next
             // reconfiguration event.
             next_state_count = STATE_COUNT_CONST;
             //【配置的跳转入口？】
             case(SADDR)
                    0:next_rom_addr = 8'h00;
                    1:next_rom_addr = STATE_COUNT_CONST ;
                    2:next_rom_addr = STATE_COUNT_CONST << 1;
                    //3:next_rom_addr = STATE_COUNT_CONST << 1 + STATE_COUNT_CONST;
                    3:next_rom_addr = 33;
                    4:next_rom_addr = STATE_COUNT_CONST << 2;
                    default:next_rom_addr = 8'h00;
                endcase
             
             //next_rom_addr = SADDR ? STATE_COUNT_CONST: 8'h00;//选择对应的rom

             if(IntLocked) begin
                // MMCM is IntLocked, go on to wait for the SEN signal
                next_state  = WAIT_SEN;
                // Assert SRDY to indicate that the reconfiguration module is
                // ready
                next_srdy   = 1'b1;
             end else begin
                // Keep waiting, IntLocked has not asserted yet
                next_state  = WAIT_LOCK;
             end
          end

          // Wait for the next SEN pulse and set the ROM addr appropriately
          //    based on SADDR
          WAIT_SEN: begin //一个大阶段配置完成后，锁定后，即进入本阶段---等待SEN//////【配置的入口】////////
             if (SEN) begin
                // SEN was asserted
                //【配置的跳转入口--请修改】
                //SADDR    0       1       2       3       4
                //CLK    148.5  37.125   74.25  133.32   65.73 

                case(SADDR)
                    0:next_rom_addr = 8'h00;
                    1:next_rom_addr = STATE_COUNT_CONST ;
                    2:next_rom_addr = STATE_COUNT_CONST << 1;
                    
                    //3:next_rom_addr = STATE_COUNT_CONST << 1 + STATE_COUNT_CONST;
                    3:next_rom_addr = 33;
                    4:next_rom_addr = STATE_COUNT_CONST << 2;
                    default:next_rom_addr = 8'h00;
                endcase
                
                //next_rom_addr = SADDR ? STATE_COUNT_CONST: 8'h00;//根据SADDR选择对应的rom
                // Go on to address the MMCM
                next_state = ADDRESS;
             end else begin
                // Keep waiting for SEN to be asserted
                next_state = WAIT_SEN;
             end
          end

          // Set the address on the MMCM and assert DEN to read the value
          ADDRESS: begin//固定
             // Reset the DCM through the reconfiguration
             next_RST_PLL  = 1'b1;
             // Enable a read from the MMCM and set the MMCM address
             next_den       = 1'b1;
             next_daddr     = rom_do[38:32];

             // Wait for the data to be ready
             next_state     = WAIT_A_DRDY;
          end

          // Wait for DRDY to assert after addressing the MMCM
          WAIT_A_DRDY: begin//固定
             if (DRDY) begin
                // Data is ready, mask out the bits to save
                next_state = BITMASK;
             end else begin
                // Keep waiting till data is ready
                next_state = WAIT_A_DRDY;
             end
          end

          // Zero out the bits that are not set in the mask stored in rom
          BITMASK: begin//固定
             // Do the mask
             next_di     = rom_do[31:16] & DO;
             // Go on to set the bits
             next_state  = BITSET;
          end

          // After the input is masked, OR the bits with calculated value in rom
          BITSET: begin//固定
             // Set the bits that need to be assigned
             next_di           = rom_do[15:0] | DI;
             // Set the next address to read from ROM
             next_rom_addr     = rom_addr + 1'b1;
             // Go on to write the data to the MMCM
             next_state        = WRITE;
          end

          // DI is setup so assert DWE, DEN, and RST_PLL.  Subtract one from the
          //    state count and go to wait for DRDY.
          WRITE: begin
             // Set WE and EN on MMCM
             next_dwe          = 1'b1;
             next_den          = 1'b1;

             // Decrement the number of registers left to write
             next_state_count  = state_count - 1'b1;//本阶段配置寄存器 - 1
             // Wait for the write to complete
             next_state        = WAIT_DRDY;
          end

          // Wait for DRDY to assert from the MMCM.  If the state count is not 0
          //    jump to ADDRESS (continue reconfiguration).  If state count is
          //    0 wait for lock.
          WAIT_DRDY: begin//固定
             if(DRDY) begin
                // Write is complete
                if(state_count > 0) begin
                   // If there are more registers to write keep going
                   next_state  = ADDRESS;//本阶段配置下一个寄存器
                end else begin
                   // There are no more registers to write so wait for the MMCM
                   // to lock
                   next_state  = WAIT_LOCK;
                end
             end else begin
                // Keep waiting for write to complete
                next_state     = WAIT_DRDY;
             end
          end

          // If in an unknown state reset the machine
          default: begin
             next_state = RESTART;
          end
       endcase
    end
    
///////////////////////////////////////////////////////////////////////////////
// These are user functions that should not be modified.  Changes to the defines
// or code within the functions may alter the accuracy of the calculations.
// Define debug to provide extra messages durring elaboration
//`define DEBUG 1

// FRAC_PRECISION describes the width of the fractional portion of the fixed
//    point numbers.  These should not be modified, they are for development
//    only
`define FRAC_PRECISION  10
// FIXED_WIDTH describes the total size for fixed point calculations(int+frac).
// Warning: L.50 and below will not calculate properly with FIXED_WIDTHs
//    greater than 32
`define FIXED_WIDTH     32

// This function takes a fixed point number and rounds it to the nearest
//    fractional precision bit.
function [`FIXED_WIDTH:1] round_frac
   (
      // Input is (FIXED_WIDTH-FRAC_PRECISION).FRAC_PRECISION fixed point number
      input [`FIXED_WIDTH:1] decimal,

      // This describes the precision of the fraction, for example a value
      //    of 1 would modify the fractional so that instead of being a .16
      //    fractional, it would be a .1 (rounded to the nearest 0.5 in turn)
      input [`FIXED_WIDTH:1] precision
   );

   begin

`ifdef DEBUG
      $display("round_frac - decimal: %h, precision: %h", decimal, precision);
`endif
      // If the fractional precision bit is high then round up
      if( decimal[(`FRAC_PRECISION-precision)] == 1'b1) begin
         round_frac = decimal + (1'b1 << (`FRAC_PRECISION-precision));
      end else begin
         round_frac = decimal;
      end
`ifdef DEBUG
      $display("round_frac: %h", round_frac);
`endif
   end
endfunction

// This function calculates high_time, low_time, w_edge, and no_count
//    of a non-fractional counter based on the divide and duty cycle
//
// NOTE: high_time and low_time are returned as integers between 0 and 63
//    inclusive.  64 should equal 6'b000000 (in other words it is okay to
//    ignore the overflow)
function [13:0] pll_divider
   (
      input [7:0] divide,        // Max divide is 128
      input [31:0] duty_cycle    // Duty cycle is multiplied by 100,000
   );

   reg [`FIXED_WIDTH:1]    duty_cycle_fix;
      // min/max allowed duty cycle range calc for divide => 64
   reg [`FIXED_WIDTH:1]    duty_cycle_min;
   reg [`FIXED_WIDTH:1]    duty_cycle_max;


   // High/Low time is initially calculated with a wider integer to prevent a
   // calculation error when it overflows to 64.
   reg [6:0]               high_time;
   reg [6:0]               low_time;
   reg                     w_edge;
   reg                     no_count;

   reg [`FIXED_WIDTH:1]    temp;

   begin
      // Duty Cycle must be between 0 and 1,000
      if(duty_cycle <=0 || duty_cycle >= 100000) begin
         $display("ERROR: duty_cycle: %d is invalid", duty_cycle);
         $finish;
      end
      if (divide >= 64) begin     // DCD and frequency generation fix if O divide => 64
          duty_cycle_min = ((divide - 64) * 100_000) / divide;
          duty_cycle_max = (64.5 / divide) * 100_000;
          if (duty_cycle > duty_cycle_max)  duty_cycle = duty_cycle_max;
          if (duty_cycle < duty_cycle_min)  duty_cycle = duty_cycle_min;
      end

      // Convert to FIXED_WIDTH-FRAC_PRECISION.FRAC_PRECISION fixed point
      duty_cycle_fix = (duty_cycle << `FRAC_PRECISION) / 100_000;

`ifdef DEBUG
      $display("duty_cycle_fix: %h", duty_cycle_fix);
`endif

      // If the divide is 1 nothing needs to be set except the no_count bit.
      //    Other values are dummies
      if(divide == 7'h01) begin
         high_time   = 7'h01;
         w_edge      = 1'b0;
         low_time    = 7'h01;
         no_count    = 1'b1;
      end else begin
         temp = round_frac(duty_cycle_fix*divide, 1);

         // comes from above round_frac
         high_time   = temp[`FRAC_PRECISION+7:`FRAC_PRECISION+1];
         // If the duty cycle * divide rounded is .5 or greater then this bit
         //    is set.
         w_edge      = temp[`FRAC_PRECISION]; // comes from round_frac

         // If the high time comes out to 0, it needs to be set to at least 1
         // and w_edge set to 0
         if(high_time == 7'h00) begin
            high_time   = 7'h01;
            w_edge      = 1'b0;
         end

         if(high_time == divide) begin
            high_time   = divide - 1;
            w_edge      = 1'b1;
         end

         // Calculate low_time based on the divide setting and set no_count to
         //    0 as it is only used when divide is 1.
         low_time    = divide - high_time;
         no_count    = 1'b0;
      end

      // Set the return value.
      pll_divider = {w_edge,no_count,high_time[5:0],low_time[5:0]};
   end
endfunction

// This function calculates mx, delay_time, and phase_mux
//  of a non-fractional counter based on the divide and phase
//
// NOTE: The only valid value for the MX bits is 2'b00 to ensure the coarse mux
//    is used.
function [10:0] pll_phase
   (
      // divide must be an integer (use fractional if not)
      //  assumed that divide already checked to be valid
      input [7:0] divide, // Max divide is 128

      // Phase is given in degrees (-360,000 to 360,000)
      input signed [31:0] phase
   );

   reg [`FIXED_WIDTH:1] phase_in_cycles;
   reg [`FIXED_WIDTH:1] phase_fixed;
   reg [1:0]            mx;
   reg [5:0]            delay_time;
   reg [2:0]            phase_mux;

   reg [`FIXED_WIDTH:1] temp;

   begin
`ifdef DEBUG
      $display("pll_phase-divide:%d,phase:%d",
         divide, phase);
`endif

      if ((phase < -360000) || (phase > 360000)) begin
         $display("ERROR: phase of $phase is not between -360000 and 360000");
         $finish;
      end

      // If phase is less than 0, convert it to a positive phase shift
      // Convert to (FIXED_WIDTH-FRAC_PRECISION).FRAC_PRECISION fixed point
      if(phase < 0) begin
         phase_fixed = ( (phase + 360000) << `FRAC_PRECISION ) / 1000;
      end else begin
         phase_fixed = ( phase << `FRAC_PRECISION ) / 1000;
      end

      // Put phase in terms of decimal number of vco clock cycles
      phase_in_cycles = ( phase_fixed * divide ) / 360;

`ifdef DEBUG
      $display("phase_in_cycles: %h", phase_in_cycles);
`endif


	 temp  =  round_frac(phase_in_cycles, 3);

	 // set mx to 2'b00 that the phase mux from the VCO is enabled
	 mx    			=  2'b00;
	 phase_mux      =  temp[`FRAC_PRECISION:`FRAC_PRECISION-2];
	 delay_time     =  temp[`FRAC_PRECISION+6:`FRAC_PRECISION+1];

`ifdef DEBUG
      $display("temp: %h", temp);
`endif

      // Setup the return value
      pll_phase={mx, phase_mux, delay_time};
   end
endfunction

// This function takes the divide value and outputs the necessary lock values
function [39:0] pll_lock_lookup
   (
      input [6:0] divide // Max divide is 64
   );

   reg [2559:0]   lookup;

   begin
      lookup = {
         // This table is composed of:
         // LockRefDly_LockFBDly_LockCnt_LockSatHigh_UnlockCnt
         40'b00110_00110_1111101000_1111101001_0000000001,
         40'b00110_00110_1111101000_1111101001_0000000001,
         40'b01000_01000_1111101000_1111101001_0000000001,
         40'b01011_01011_1111101000_1111101001_0000000001,
         40'b01110_01110_1111101000_1111101001_0000000001,
         40'b10001_10001_1111101000_1111101001_0000000001,
         40'b10011_10011_1111101000_1111101001_0000000001,
         40'b10110_10110_1111101000_1111101001_0000000001,
         40'b11001_11001_1111101000_1111101001_0000000001,
         40'b11100_11100_1111101000_1111101001_0000000001,
         40'b11111_11111_1110000100_1111101001_0000000001,
         40'b11111_11111_1100111001_1111101001_0000000001,
         40'b11111_11111_1011101110_1111101001_0000000001,
         40'b11111_11111_1010111100_1111101001_0000000001,
         40'b11111_11111_1010001010_1111101001_0000000001,
         40'b11111_11111_1001110001_1111101001_0000000001,
         40'b11111_11111_1000111111_1111101001_0000000001,
         40'b11111_11111_1000100110_1111101001_0000000001,
         40'b11111_11111_1000001101_1111101001_0000000001,
         40'b11111_11111_0111110100_1111101001_0000000001,
         40'b11111_11111_0111011011_1111101001_0000000001,
         40'b11111_11111_0111000010_1111101001_0000000001,
         40'b11111_11111_0110101001_1111101001_0000000001,
         40'b11111_11111_0110010000_1111101001_0000000001,
         40'b11111_11111_0110010000_1111101001_0000000001,
         40'b11111_11111_0101110111_1111101001_0000000001,
         40'b11111_11111_0101011110_1111101001_0000000001,
         40'b11111_11111_0101011110_1111101001_0000000001,
         40'b11111_11111_0101000101_1111101001_0000000001,
         40'b11111_11111_0101000101_1111101001_0000000001,
         40'b11111_11111_0100101100_1111101001_0000000001,
         40'b11111_11111_0100101100_1111101001_0000000001,
         40'b11111_11111_0100101100_1111101001_0000000001,
         40'b11111_11111_0100010011_1111101001_0000000001,
         40'b11111_11111_0100010011_1111101001_0000000001,
         40'b11111_11111_0100010011_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001,
         40'b11111_11111_0011111010_1111101001_0000000001
      };

      // Set lookup_entry with the explicit bits from lookup with a part select
      pll_lock_lookup = lookup[ ((64-divide)*40) +: 40];
`ifdef DEBUG
      $display("lock_lookup: %b", pll_lock_lookup);
`endif
   end
endfunction

// This function takes the divide value and the bandwidth setting of the PLL
//  and outputs the digital filter settings necessary.
function [9:0] pll_filter_lookup
  (
     input [6:0] divide, // Max divide is 64
     input [8*9:0] BANDWIDTH
  );

  reg [639:0] lookup_low;
  reg [639:0] lookup_high;
  reg [639:0] lookup_optimized;

  reg [9:0] lookup_entry;

  begin
      lookup_low = {
        // CP_RES_LFHF
        10'b0010_1111_00,  // 1
        10'b0010_1111_00,  // 2
        10'b0010_0111_00,  // 3
        10'b0010_1101_00,  // 4
        10'b0010_0101_00,  // ....
        10'b0010_0101_00,
        10'b0010_1001_00,
        10'b0010_1110_00,
        10'b0010_1110_00,
        10'b0010_0001_00,
        10'b0010_0001_00,
        10'b0010_0110_00,
        10'b0010_0110_00,
        10'b0010_0110_00,
        10'b0010_0110_00,
        10'b0010_1010_00,
        10'b0010_1010_00,
        10'b0010_1010_00,
        10'b0010_1010_00,
        10'b0010_1100_00,
        10'b0010_1100_00,
        10'b0010_1100_00,
        10'b0010_1100_00,
        10'b0010_1100_00,
        10'b0010_1100_00,
        10'b0010_1100_00,
        10'b0010_1100_00,
        10'b0010_1100_00,
        10'b0010_1100_00,
        10'b0010_1100_00,
        10'b0010_0010_00,
        10'b0010_0010_00,
        10'b0010_0010_00,
        10'b0010_0010_00,
        10'b0010_0010_00,
        10'b0010_0010_00,
        10'b0010_0010_00,
        10'b0010_0010_00,
        10'b0010_0010_00,
        10'b0010_0010_00,
        10'b0011_1100_00,
        10'b0011_1100_00,
        10'b0011_1100_00,
        10'b0011_1100_00,
        10'b0011_1100_00,
        10'b0011_1100_00,
        10'b0011_1100_00,
        10'b0010_0100_00,
        10'b0010_0100_00,
        10'b0010_0100_00,
        10'b0010_0100_00,
        10'b0010_0100_00,
        10'b0010_0100_00,
        10'b0010_0100_00,
        10'b0010_0100_00,
        10'b0010_0100_00,
        10'b0010_0100_00,
        10'b0010_0100_00,
        10'b0010_0100_00,
        10'b0010_0100_00,  // ......
        10'b0010_0100_00,  // 61
        10'b0010_0100_00,  // 62
        10'b0010_0100_00,  // 63
        10'b0010_0100_00   // 64
      };

      lookup_high = {
        // CP_RES_LFHF
        10'b0011_0111_00,  // 1
        10'b0011_0111_00,  // 2
        10'b0101_1111_00,  // 3
        10'b0111_1111_00,  // 4
        10'b0111_1011_00,  // ....
        10'b1101_0111_00,
        10'b1110_1011_00,
        10'b1110_1101_00,
        10'b1111_1101_00,
        10'b1111_0111_00,
        10'b1111_1011_00,
        10'b1111_1101_00,
        10'b1111_0011_00,
        10'b1110_0101_00,
        10'b1111_0101_00,
        10'b1111_0101_00,
        10'b1111_0101_00,
        10'b1111_0101_00,
        10'b0111_0110_00,
        10'b0111_0110_00,
        10'b0111_0110_00,
        10'b0111_0110_00,
        10'b0101_1100_00,
        10'b0101_1100_00,
        10'b0101_1100_00,
        10'b1100_0001_00,
        10'b1100_0001_00,
        10'b1100_0001_00,
        10'b1100_0001_00,
        10'b1100_0001_00,
        10'b1100_0001_00,
        10'b1100_0001_00,
        10'b1100_0001_00,
        10'b0100_0010_00,
        10'b0100_0010_00,
        10'b0100_0010_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0011_0100_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0100_1100_00,
        10'b0100_1100_00,
        10'b0100_1100_00,
        10'b0100_1100_00,
        10'b0100_1100_00,
        10'b0100_1100_00,
        10'b0100_1100_00,  // .....
        10'b0010_0100_00,  // 61
        10'b0010_0100_00,  // 62
        10'b0010_0100_00,  // 63
        10'b0010_0100_00   // 64
      };

      lookup_optimized = {
        // CP_RES_LFHF
        10'b0011_0111_00,  // 1
        10'b0011_0111_00,  // 2
        10'b0101_1111_00,  // 3
        10'b0111_1111_00,  // 4
        10'b0111_1011_00,  // .
        10'b1101_0111_00,
        10'b1110_1011_00,
        10'b1110_1101_00,
        10'b1111_1101_00,
        10'b1111_0111_00,
        10'b1111_1011_00,
        10'b1111_1101_00,
        10'b1111_0011_00,
        10'b1110_0101_00,
        10'b1111_0101_00,
        10'b1111_0101_00,
        10'b1111_0101_00,
        10'b1111_0101_00,
        10'b0111_0110_00,
        10'b0111_0110_00,
        10'b0111_0110_00,
        10'b0111_0110_00,
        10'b0101_1100_00,
        10'b0101_1100_00,
        10'b0101_1100_00,
        10'b1100_0001_00,
        10'b1100_0001_00,
        10'b1100_0001_00,
        10'b1100_0001_00,
        10'b1100_0001_00,
        10'b1100_0001_00,
        10'b1100_0001_00,
        10'b1100_0001_00,
        10'b0100_0010_00,
        10'b0100_0010_00,
        10'b0100_0010_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0011_0100_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0010_1000_00,
        10'b0100_1100_00,
        10'b0100_1100_00,
        10'b0100_1100_00,
        10'b0100_1100_00,
        10'b0100_1100_00,
        10'b0100_1100_00,
        10'b0100_1100_00,  // ..
        10'b0010_0100_00,  // 61
        10'b0010_0100_00,  // 62
        10'b0010_0100_00,  // 63
        10'b0010_0100_00   // 64
      };

    // Set lookup_entry with the explicit bits from lookup with a part select
    if (BANDWIDTH == "LOW") begin
      // Low Bandwidth
      pll_filter_lookup = lookup_low[((64-divide)*10) +: 10];
    end
    else if (BANDWIDTH == "HIGH") begin
      // High Bandwidth
      pll_filter_lookup = lookup_high[((64-divide)*10) +: 10];
    end
    else if (BANDWIDTH == "OPTIMIZED") begin
      //  Optimized Bandwidth
      pll_filter_lookup = lookup_optimized[((64-divide)*10) +: 10];
    end

    `ifdef DEBUG
          $display("filter_lookup: %b", pll_filter_lookup);
    `endif
  end
endfunction

// This function takes in the divide, phase, and duty cycle
// setting to calculate the upper and lower counter registers.
function [37:0] pll_count_calc
   (
      input [7:0] divide, // Max divide is 128
      input signed [31:0] phase,
      input [31:0] duty_cycle // Multiplied by 100,000
   );

   reg [13:0] div_calc;
   reg [16:0] phase_calc;

   begin
`ifdef DEBUG
      $display("pll_count_calc- divide:%h, phase:%d, duty_cycle:%d",
         divide, phase, duty_cycle);
`endif

      // w_edge[13], no_count[12], high_time[11:6], low_time[5:0]
      div_calc = pll_divider(divide, duty_cycle);
      // mx[10:9], pm[8:6], dt[5:0]
      phase_calc = pll_phase(divide, phase);

      // Return value is the upper and lower address of counter
      //    Upper address is:
      //       RESERVED    [31:26]
      //       MX          [25:24]
      //       EDGE        [23]
      //       NOCOUNT     [22]
      //       DELAY_TIME  [21:16]
      //    Lower Address is:
      //       PHASE_MUX   [15:13]
      //       RESERVED    [12]
      //       HIGH_TIME   [11:6]
      //       LOW_TIME    [5:0]

`ifdef DEBUG
      $display("div:%d dc:%d phase:%d ht:%d lt:%d ed:%d nc:%d mx:%d dt:%d pm:%d",
         divide, duty_cycle, phase, div_calc[11:6], div_calc[5:0],
         div_calc[13], div_calc[12],
         phase_calc[16:15], phase_calc[5:0], phase_calc[14:12]);
`endif

      pll_count_calc =
         {
            // Upper Address
            6'h00, phase_calc[10:9], div_calc[13:12], phase_calc[5:0],
            // Lower Address
            phase_calc[8:6], 1'b0, div_calc[11:0]
         };
   end
endfunction 
    
   
endmodule


