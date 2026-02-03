//////////////////////////////////////////////////////////////////////////////
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.2
//  \   \        Filename: top5x2_7to1_ddr_rx.v
//  /   /        Date Last Modified:  21JAN2015
// /___/   /\    Date Created: 30SEP2013
// \   \  /  \
//  \___\/\___\
//Device:     7-Series
//Purpose:      DDR top level receiver example - 2 channels of 5-bits each
//Reference:    XAPP585
//////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps
(*KEEP_HIERARCHY  = "TRUE"*)
module lvds_1to7_ddr_unify_image_parse #(
    parameter PORT_NUM    = 4,
    parameter LANE_NUM    = 4,
    parameter SAMPL_CLOCK = "BUFIO",          // default:"BUFIO"
    parameter INTER_CLOCK = "BUF_R",          // default:"BUF_R"
    parameter PIXEL_CLOCK = "BUF_G",          // default:"BUF_G"
    parameter MMCM_MODE   = 1,                // default:1
    parameter ENABLE_PHASE_DETECTOR = 1'b0,   // enable phase detector operation
    parameter ENABLE_MONITOR        = 1'b0,   // enables data eye monitoring
    parameter DCD_CORRECT           = 1'b0,   // enables clock duty cycle correction
    parameter USE_PLL               = "FALSE",// default:"FALSE"
    parameter HIGH_PERFORMANCE_MODE = "FALSE",// default:"FALSE"
    parameter REF_FREQ              = 200.0,  // default:200.0
    parameter CLKIN_PERIOD          = 6.734,  // default:6.734
    parameter BIT_RATE_VALUE        = 16'h1050// default:16'h1050

)(
ref_clk             ,//
rst                 ,//
lvds_clk_p          ,//[PORT_NUM-1:0]
lvds_clk_n          ,//[PORT_NUM-1:0] 
lvds_data_p         ,//[LANE_NUM*PORT_NUM-1:0]
lvds_data_n         ,//[LANE_NUM*PORT_NUM-1:0]
rx_pixel_clk        ,//
rx_pixel_clk_locked ,//
rx_lvds_data         //[LANE_NUM*PORT_NUM*7-1:0] 
);
///////////////////////////////////////////////////////////////////////////////
input  ref_clk;
input  rst;                                                                                     
input  [PORT_NUM-1:0]  lvds_clk_p;
input  [PORT_NUM-1:0]  lvds_clk_n;                                                                                         
input  [LANE_NUM*PORT_NUM-1:0]  lvds_data_p;
input  [LANE_NUM*PORT_NUM-1:0]  lvds_data_n; 
output  rx_pixel_clk;
output  rx_pixel_clk_locked;
output [LANE_NUM*PORT_NUM*7-1:0] rx_lvds_data; 
///////////////////////////////////////////////////////////////////////////////
wire refclkint ;         
wire rx_mmcm_lckdps ;        
wire [1:0] rx_pixel_clk_locked ;    
wire rx_pixel_clk ;                   
(*keep = "ture"*)wire  delay_ready ;        
wire rx_mmcm_lckd;    
wire locked;
wire   [LANE_NUM*PORT_NUM*7-1:0] rx_lvds_data    ;
(*keep = "ture"*)wire [15:0]  bit_rate_value;
wire  enable_phase_detector;
///////////////////////////////////////////////////////////////////////////////
(*KEEP_HIERARCHY  = "TRUE"*)    
IDELAYCTRL icontrol(// Instantiate input delay control block
    .REFCLK (ref_clk),
    .RST    (rst),
    .RDY    (delay_ready));
// Input clock and data for 2 channels
(*KEEP_HIERARCHY  = "TRUE"*)        
n_x_serdes_1_to_7_mmcm_idelay_ddr #(
    .N                      (PORT_NUM),
    .SAMPL_CLOCK            (SAMPL_CLOCK),
    .INTER_CLOCK            (INTER_CLOCK),
    .PIXEL_CLOCK            (PIXEL_CLOCK),
    .USE_PLL                (USE_PLL),
    .HIGH_PERFORMANCE_MODE  (HIGH_PERFORMANCE_MODE),
    .D                      (LANE_NUM),      // Number of data lines
    .REF_FREQ               (REF_FREQ),    // Set idelay control reference frequency
    .CLKIN_PERIOD           (CLKIN_PERIOD),// Set input clock period
    .MMCM_MODE              (MMCM_MODE),   // Parameter to set multiplier for MMCM to get VCO in correct operating range. 1 multiplies input clock by 7, 2 multiplies clock by 14, etc
    .DIFF_TERM              ("TRUE"),
    .DATA_FORMAT            ("PER_CLOCK")) // PER_CLOCK or PER_CHANL data formatting
    rx0 (                      
    .clkin_p                (lvds_clk_p),
    .clkin_n                (lvds_clk_n),
    .datain_p               (lvds_data_p),
    .datain_n               (lvds_data_n),
    .enable_phase_detector  (ENABLE_PHASE_DETECTOR),          // enable phase detector operation
    .enable_monitor         (ENABLE_MONITOR),          // enables data eye monitoring
    .dcd_correct            (DCD_CORRECT),          // enables clock duty cycle correction
    .rxclk                  (),
    .rxclk_d4               (),              // intermediate clock, use with data monitoring logic
    .idelay_rdy             (delay_ready),
    .pixel_clk              (rx_pixel_clk),
    .reset                  (rst),
    .rx_mmcm_lckd           (rx_mmcm_lckd),
    .rx_mmcm_lckdps         (rx_mmcm_lckdps),
    .rx_mmcm_lckdpsbs       (rx_pixel_clk_locked),
    .clk_data               (),
    .rx_data                (rx_lvds_data),
    .bit_rate_value         (BIT_RATE_VALUE),      // required bit rate value in BCD 
                                             //maximum for 4K@60Hz quad piexl mode for 148.5Mhz
    .bit_time_value         (),
    .status                 (),
    .eye_info               (),              // data eye monitor per line
    .m_delay_1hot           (),              // sample point monitor per line
    .debug                  ()) ;            // debug bus

    
endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.2
//  \   \        Filename: n_x_serdes_1_to_7_mmcm_idelay_ddr.v
//  /   /        Date Last Modified:  20JAN2015
// /___/   /\    Date Created: 5MAR2010
// \   \  /  \
//  \___\/\___\
//Device:     7 Series
//Purpose:      Wrapper for multiple 1 to 7 receiver clock and data receiver using one MMCM for clock multiplication
//Reference:    XAPP585
//    
//Revision History:
//    Rev 1.0 - First created (nicks)
//    Rev 1.1 - rxclk_d4 output added
//    Rev 1.2 - master and slaves gearbox sync added, updated format
//////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps
module n_x_serdes_1_to_7_mmcm_idelay_ddr (clkin_p, clkin_n, datain_p, datain_n, enable_phase_detector, rxclk, rxclk_d4, idelay_rdy, reset, pixel_clk, enable_monitor, 
                                          rx_mmcm_lckdps, rx_mmcm_lckd, rx_mmcm_lckdpsbs, clk_data, rx_data, status, debug, dcd_correct, bit_rate_value, bit_time_value, m_delay_1hot, eye_info) ;

parameter integer  N = 8 ;                // Set the number of channels
parameter integer  D = 6 ;                // Parameter to set the number of data lines per channel
parameter integer  MMCM_MODE = 1 ;        // Parameter to set multiplier for MMCM to get VCO in correct operating range. 1 multiplies input clock by 7, 2 multiplies clock by 14, etc
parameter real     CLKIN_PERIOD = 6.000 ; // clock period (ns) of input clock on clkin_p
parameter real     REF_FREQ = 200.0 ;     // Parameter to set reference frequency used by idelay controller
parameter          HIGH_PERFORMANCE_MODE = "FALSE";// Parameter to set HIGH_PERFORMANCE_MODE of input delays to reduce jitter
parameter          DIFF_TERM = "FALSE" ;  // Parameter to enable internal differential termination
parameter          SAMPL_CLOCK = "BUFIO" ;// Parameter to set sampling clock buffer type, BUFIO, BUF_H, BUF_G
parameter          INTER_CLOCK = "BUF_R" ;// Parameter to set intermediate clock buffer type, BUFR, BUF_H, BUF_G
parameter          PIXEL_CLOCK = "BUF_G" ;// Parameter to set pixel clock buffer type, BUF_R, BUF_H, BUF_G
parameter          USE_PLL = "FALSE" ;    // Parameter to enable PLL use rather than MMCM use, overides SAMPL_CLOCK and INTER_CLOCK to be both BUFH
parameter          DATA_FORMAT = "PER_CLOCK" ;     // Parameter Used to determine method for mapping input parallel word to output serial words
                                           
input  [N-1:0]   clkin_p ;           // Input from LVDS clock receiver pin
input  [N-1:0]   clkin_n ;           // Input from LVDS clock receiver pin
input  [N*D-1:0] datain_p ;          // Input from LVDS clock data pins
input  [N*D-1:0] datain_n ;          // Input from LVDS clock data pins
input  enable_phase_detector ;       // Enables the phase detector logic when high
input  enable_monitor ;       // Enable monitoring function
input  reset ;                // Reset line
input  idelay_rdy ;           // input delays are ready
output rxclk ;                // Global/BUFIO rx clock network
output rxclk_d4 ;             // Global/BUFIO rx clock network
output pixel_clk ;            // Global/Regional clock output
output rx_mmcm_lckd ;         // MMCM locked, synchronous to rxclk_d4
output rx_mmcm_lckdps ;       // MMCM locked and phase shifting finished, synchronous to rxclk_d4
output [N-1:0]     rx_mmcm_lckdpsbs ;  // MMCM locked and phase shifting finished and bitslipping finished, synchronous to pixel_clk
output [7*N-1:0]   clk_data ;          // Clock Data
output [N*D*7-1:0] rx_data ;           // Received Data
output [(10*D+6)*N-1:0]debug ;         // debug info
output [6:0] status ;                  // clock status
input  dcd_correct ;                   // '0' = square, '1' = assume 10% DCD
input  [15:0] bit_rate_value ;         // Bit rate in Mbps, for example 16'h0585
output [4:0]  bit_time_value ;         // Calculated bit time value for slave devices
output [32*D*N-1:0] m_delay_1hot ;     // Master delay control value as a one-hot vector
output [32*D*N-1:0] eye_info ;         // eye info

genvar i ;
genvar j ;
wire   rxclk_d4 ;
wire   [1:0] gb_rst_out ;

serdes_1_to_7_mmcm_idelay_ddr #(
    .SAMPL_CLOCK  (SAMPL_CLOCK),
    .INTER_CLOCK  (INTER_CLOCK),
    .PIXEL_CLOCK  (PIXEL_CLOCK),
    .USE_PLL      (USE_PLL),
    .REF_FREQ     (REF_FREQ),
    .HIGH_PERFORMANCE_MODE (HIGH_PERFORMANCE_MODE),
    .D            (D),  // Number of data lines
    .CLKIN_PERIOD (CLKIN_PERIOD), // Set input clock period
    .MMCM_MODE    (MMCM_MODE),    // Set mmcm vco, either 1 or 2
    .DIFF_TERM    (DIFF_TERM),
    .DATA_FORMAT  (DATA_FORMAT))
    rx0 (
    .clkin_p      (clkin_p[0]),
    .clkin_n      (clkin_n[0]),
    .datain_p     (datain_p[D-1:0]),
    .datain_n     (datain_n[D-1:0]),
    .enable_phase_detector (enable_phase_detector),
    .enable_monitor(enable_monitor),
    .rxclk         (rxclk),
    .idelay_rdy    (idelay_rdy),
    .pixel_clk     (pixel_clk),
    .rxclk_d4      (rxclk_d4),
    .reset         (reset),
    .rx_mmcm_lckd  (rx_mmcm_lckd),
    .rx_mmcm_lckdps(rx_mmcm_lckdps),
    .rx_mmcm_lckdpsbs (rx_mmcm_lckdpsbs[0]),
    .clk_data      (clk_data[6:0]),
    .rx_data       (rx_data[7*D-1:0]),
    .dcd_correct   (dcd_correct),
    .bit_rate_value(bit_rate_value),
    .bit_time_value(bit_time_value),
    .del_mech      (del_mech), 
    .status        (status),
    .debug         (debug[10*D+5:0]),
    .rst_iserdes   (rst_iserdes),
    .gb_rst_out    (gb_rst_out),
    .m_delay_1hot  (m_delay_1hot[32*D-1:0]),
    .eye_info      (eye_info[32*D-1:0]));

generate
for (i = 1 ; i <= (N-1) ; i = i+1)
begin : loop0

serdes_1_to_7_slave_idelay_ddr #(
    .D          (D),   // Number of data lines
    .REF_FREQ   (REF_FREQ),
    .HIGH_PERFORMANCE_MODE (HIGH_PERFORMANCE_MODE),
    .DIFF_TERM  (DIFF_TERM),
    .DATA_FORMAT(DATA_FORMAT))
    rxn (
    .clkin_p     (clkin_p[i]),
    .clkin_n     (clkin_n[i]),
    .datain_p    (datain_p[D*(i+1)-1:D*i]),
    .datain_n    (datain_n[D*(i+1)-1:D*i]),
    .enable_phase_detector (enable_phase_detector),
    .enable_monitor (enable_monitor),
    .rxclk          (rxclk),
    .idelay_rdy     (idelay_rdy),
    .pixel_clk      (pixel_clk),
    .rxclk_d4       (rxclk_d4),
    .reset          (~rx_mmcm_lckdps),
    .bitslip_finished (rx_mmcm_lckdpsbs[i]),
    .clk_data         (clk_data[7*i+6:7*i]),
    .rx_data          (rx_data[(D*(i+1)*7)-1:D*i*7]),
    .bit_time_value   (bit_time_value),
    .del_mech         (del_mech), 
    .debug            (debug[(10*D+6)*(i+1)-1:(10*D+6)*i]),
    .rst_iserdes      (rst_iserdes),
    .gb_rst_in        (gb_rst_out),
    .m_delay_1hot     (m_delay_1hot[(32*D)*(i+1)-1:(32*D)*i]),
    .eye_info         (eye_info[(32*D)*(i+1)-1:(32*D)*i]));

end
endgenerate
endmodule

//////////////////////////////////////////////////////////////////////////////
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.2
//  \   \        Filename: serdes_1_to_7_mmcm_idelay_ddr.v
//  /   /        Date Last Modified:  21JAN2015
// /___/   /\    Date Created: 5MAR2010
// \   \  /  \
//Device:     7 Series
//Purpose:      1 to 7 DDR receiver clock and data receiver using an MMCM for clock multiplication
//        Data formatting is set by the DATA_FORMAT parameter. 
//        PER_CLOCK (default) format receives bits for 0, 1, 2 .. on the same sample edge
//        PER_CHANL format receives bits for 0, 7, 14 ..  on the same sample edge
//Reference:    XAPP585
//Revision History:
//    Rev 1.0 - First created (nicks)
//    Rev 1.1 - PER_CLOCK and PER_CHANL descriptions swapped
//    Rev 1.2 - State machine moved to a new level of hierarchy, eye monitor added, gearbox sync added, updated format
/////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps

module serdes_1_to_7_mmcm_idelay_ddr (clkin_p, clkin_n, datain_p, datain_n, enable_phase_detector, rxclk, idelay_rdy, reset, pixel_clk, rxclk_d4, enable_monitor,
                                      rx_mmcm_lckdps, rx_mmcm_lckd, rx_mmcm_lckdpsbs, clk_data, rx_data, status, debug, bit_rate_value, dcd_correct, bit_time_value, rst_iserdes, del_mech, gb_rst_out, m_delay_1hot, eye_info) ;

parameter integer  D = 8 ;                 // Parameter to set the number of data lines
parameter integer  MMCM_MODE = 1 ;         // Parameter to set multiplier for MMCM to get VCO in correct operating range. 1 multiplies input clock by 7, 2 multiplies clock by 14, etc
parameter real     REF_FREQ = 200 ;        // Parameter to set reference frequency used by idelay controller
parameter          HIGH_PERFORMANCE_MODE = "FALSE";// Parameter to set HIGH_PERFORMANCE_MODE of input delays to reduce jitter
parameter real     CLKIN_PERIOD = 6.000 ;  // clock period (ns) of input clock on clkin_p
parameter          DIFF_TERM = "FALSE" ;   // Parameter to enable internal differential termination
parameter          SAMPL_CLOCK = "BUFIO" ; // Parameter to set sampling clock buffer type, BUFIO, BUF_H, BUF_G
parameter          INTER_CLOCK = "BUF_R" ; // Parameter to set intermediate clock buffer type, BUFR, BUF_H, BUF_G
parameter          PIXEL_CLOCK = "BUF_G" ; // Parameter to set final pixel buffer type, BUF_R, BUF_H, BUF_G
parameter          USE_PLL = "FALSE" ;     // Parameter to enable PLL use rather than MMCM use, note, PLL does not support BUFIO and BUFR
parameter          DATA_FORMAT = "PER_CLOCK" ; // Parameter Used to determine method for mapping input parallel word to output serial words
                                         
input  clkin_p ;            // Input from LVDS clock receiver pin
input  clkin_n ;            // Input from LVDS clock receiver pin
input  [D-1:0] datain_p ;            // Input from LVDS clock data pins
input  [D-1:0] datain_n ;            // Input from LVDS clock data pins
input  enable_phase_detector ;        // Enables the phase detector logic when high
input  enable_monitor ;        // Enable monitoring function
input  reset ;                // Reset line
input  idelay_rdy ;            // input delays are ready
output rxclk ;                // Global/BUFIO rx clock network
output pixel_clk ;            // Global/Regional clock output
output rxclk_d4 ;            // Global/Regional clock output
output rx_mmcm_lckd ;             // MMCM locked, synchronous to rxclk_d4
output rx_mmcm_lckdps ;         // MMCM locked and phase shifting finished, synchronous to pixel_clk
output rx_mmcm_lckdpsbs ;         // MMCM locked and phase shifting finished and bitslipping finished, synchronous to pixel_clk
output [6:0] clk_data ;             // Clock Data
output [D*7-1:0]  rx_data ;             // Received Data
output [10*D+5:0] debug ;                 // debug info
output [6:0] status ;             // clock status
input  dcd_correct ;            // '0' = square, '1' = assume 10% DCD
input  [15:0] bit_rate_value ;         // Bit rate in Mbps, for example 16'h0585 16'h1050 ..
output [4:0]  bit_time_value ;        // Calculated bit time value for slave devices
output reg  del_mech ;            // DCD correct cascade to slaves
output reg  rst_iserdes ;            // serdes reset signal to slaves
output [1:0] gb_rst_out ;            // gearbox reset signals to slaves
output [32*D-1:0] m_delay_1hot ;            // Master delay control value as a one-hot vector
output [D*32-1:0] eye_info ;             // eye info

wire   [D*5-1:0] m_delay_val_in ;
wire   [D*5-1:0] s_delay_val_in ;
wire   [3:0] cdataout ;            
reg    [3:0] cdataouta ;            
reg    [3:0] cdataoutb ;            
reg    [3:0] cdataoutc ;            
wire   rx_clk_in_p ;            
reg    [1:0] bsstate ;                     
reg    bslip ;                     
reg    bslipreq ;                     
reg    bslipr_dom_ch ;                     
reg    [3:0] bcount ;                     
reg    [6*D-1:0] pdcount ;                     
wire   [6:0] clk_iserdes_data ;          
reg    [6:0] clk_iserdes_data_d ;        
reg    enable ;                    
reg    flag1 ;                     
reg    flag2 ;                     
reg    [2:0] state2 ;            
reg    [4:0] state2_count ;            
reg    [5:0] scount ;            
reg    locked_out ;    
reg    locked_out_dom_ch ;    
reg    chfound ;    
reg    chfoundc ;
reg    rx_mmcm_lckd_int ;
reg    not_rx_mmcm_lckd_intd4 ;
reg    [4:0] c_delay_in ;
reg    [4:0] c_delay_in_target ;
reg    c_delay_in_ud ;
wire   [D-1:0] rx_data_in_p ;            
wire   [D-1:0] rx_data_in_n ;            
wire   [D-1:0] rx_data_in_m ;            
wire   [D-1:0] rx_data_in_s ;        
wire   [D-1:0] rx_data_in_md ;            
wire   [D-1:0] rx_data_in_sd ;                
wire   [(4*D)-1:0] mdataout ;                        
wire   [(4*D)-1:0] mdataoutd ;            
wire   [(4*D)-1:0] sdataout ;                        
wire   [(7*D)-1:0] dataout ;                    
reg    jog;        
reg    [2:0]  slip_count ;                    
reg    bslip_ack_dom_ch ;        
reg    bslip_ack ;        
reg    [1:0] bstate ;
reg    data_different ;
reg    data_different_dom_ch ;
reg    [D-1:0] s_ovflw ;        
reg    [D-1:0] s_hold ;        
reg    bs_finished ;
reg    not_bs_finished_dom_ch ;
reg    [4:0] bt_val ;  
wire   mmcm_locked ;
(*keep="true"*)wire rxpllmmcm_x1 ;
(*keep="true"*)wire rxpllmmcm_xs ;
(*keep="true"*)wire rxpllmmcm_d4 ;
reg    rstcserdes ;
reg    [1:0] c_loop_cnt ;  

parameter [D-1:0] RX_SWAP_MASK = 16'h0000 ; // pinswap mask for input data bits (0 = no swap (default), 1 = swap). Allows inputs to be connected the wrong way round to ease PCB routing.

assign clk_data = clk_iserdes_data ;
assign debug = {s_delay_val_in, m_delay_val_in, bslip, c_delay_in} ;
assign rx_mmcm_lckdpsbs = bs_finished & mmcm_locked ;
assign rx_mmcm_lckd = ~not_rx_mmcm_lckd_intd4 & mmcm_locked ;
assign rx_mmcm_lckdps = locked_out_dom_ch & mmcm_locked ;
assign bit_time_value = bt_val ;

if (REF_FREQ < 210.0) begin
  always @ (bit_rate_value) begin   // Generate tap number to be used for input bit rate (200 MHz ref clock)
      if      (bit_rate_value > 16'h1984) begin bt_val <= 5'h07 ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h1717) begin bt_val <= 5'h08 ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h1514) begin bt_val <= 5'h09 ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h1353) begin bt_val <= 5'h0A ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h1224) begin bt_val <= 5'h0B ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h1117) begin bt_val <= 5'h0C ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h1027) begin bt_val <= 5'h0D ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h0951) begin bt_val <= 5'h0E ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h0885) begin bt_val <= 5'h0F ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h0828) begin bt_val <= 5'h10 ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h0778) begin bt_val <= 5'h11 ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h0733) begin bt_val <= 5'h12 ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h0694) begin bt_val <= 5'h13 ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h0658) begin bt_val <= 5'h14 ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h0626) begin bt_val <= 5'h15 ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h0597) begin bt_val <= 5'h16 ; del_mech <= 1'b0 ; end
      else if (bit_rate_value > 16'h0570) begin bt_val <= 5'h17 ; del_mech <= 1'b0 ; end
      else if (bit_rate_value > 16'h0546) begin bt_val <= 5'h18 ; del_mech <= 1'b0 ; end
      else if (bit_rate_value > 16'h0524) begin bt_val <= 5'h19 ; del_mech <= 1'b0 ; end
      else if (bit_rate_value > 16'h0503) begin bt_val <= 5'h1A ; del_mech <= 1'b0 ; end
      else if (bit_rate_value > 16'h0484) begin bt_val <= 5'h1B ; del_mech <= 1'b0 ; end
      else if (bit_rate_value > 16'h0466) begin bt_val <= 5'h1C ; del_mech <= 1'b0 ; end
      else if (bit_rate_value > 16'h0450) begin bt_val <= 5'h1D ; del_mech <= 1'b0 ; end
      else if (bit_rate_value > 16'h0435) begin bt_val <= 5'h1E ; del_mech <= 1'b0 ; end
      else                                begin bt_val <= 5'h1F ; del_mech <= 1'b0 ; end        // min bit rate 420 Mbps
  end
end else begin
  always @ (bit_rate_value or dcd_correct) begin                        // Generate tap number to be used for input bit rate (300 MHz ref clock)
      if      ((bit_rate_value > 16'h2030 && dcd_correct == 1'b0) || (bit_rate_value > 16'h1845 && dcd_correct == 1'b1)) begin bt_val <= 5'h0A ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h1836 && dcd_correct == 1'b0) || (bit_rate_value > 16'h1669 && dcd_correct == 1'b1)) begin bt_val <= 5'h0B ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h1675 && dcd_correct == 1'b0) || (bit_rate_value > 16'h1523 && dcd_correct == 1'b1)) begin bt_val <= 5'h0C ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h1541 && dcd_correct == 1'b0) || (bit_rate_value > 16'h1401 && dcd_correct == 1'b1)) begin bt_val <= 5'h0D ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h1426 && dcd_correct == 1'b0) || (bit_rate_value > 16'h1297 && dcd_correct == 1'b1)) begin bt_val <= 5'h0E ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h1328 && dcd_correct == 1'b0) || (bit_rate_value > 16'h1207 && dcd_correct == 1'b1)) begin bt_val <= 5'h0F ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h1242 && dcd_correct == 1'b0) || (bit_rate_value > 16'h1129 && dcd_correct == 1'b1)) begin bt_val <= 5'h10 ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h1167 && dcd_correct == 1'b0) || (bit_rate_value > 16'h1061 && dcd_correct == 1'b1)) begin bt_val <= 5'h11 ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h1100 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0999 && dcd_correct == 1'b1)) begin bt_val <= 5'h12 ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h1040 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0946 && dcd_correct == 1'b1)) begin bt_val <= 5'h13 ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h0987 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0897 && dcd_correct == 1'b1)) begin bt_val <= 5'h14 ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h0939 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0853 && dcd_correct == 1'b1)) begin bt_val <= 5'h15 ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h0895 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0814 && dcd_correct == 1'b1)) begin bt_val <= 5'h16 ; del_mech <= 1'b0 ; end
      else if ((bit_rate_value > 16'h0855 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0777 && dcd_correct == 1'b1)) begin bt_val <= 5'h17 ; del_mech <= 1'b0 ; end
      else if ((bit_rate_value > 16'h0819 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0744 && dcd_correct == 1'b1)) begin bt_val <= 5'h18 ; del_mech <= 1'b0 ; end
      else if ((bit_rate_value > 16'h0785 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0714 && dcd_correct == 1'b1)) begin bt_val <= 5'h19 ; del_mech <= 1'b0 ; end
      else if ((bit_rate_value > 16'h0754 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0686 && dcd_correct == 1'b1)) begin bt_val <= 5'h1A ; del_mech <= 1'b0 ; end
      else if ((bit_rate_value > 16'h0726 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0660 && dcd_correct == 1'b1)) begin bt_val <= 5'h1B ; del_mech <= 1'b0 ; end
      else if ((bit_rate_value > 16'h0700 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0636 && dcd_correct == 1'b1)) begin bt_val <= 5'h1C ; del_mech <= 1'b0 ; end
      else if ((bit_rate_value > 16'h0675 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0614 && dcd_correct == 1'b1)) begin bt_val <= 5'h1D ; del_mech <= 1'b0 ; end
      else if ((bit_rate_value > 16'h0652 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0593 && dcd_correct == 1'b1)) begin bt_val <= 5'h1E ; del_mech <= 1'b0 ; end
      else                                                                           begin bt_val <= 5'h1F ;   del_mech <= 1'b0 ; end        // min bit rate 631 Mbps
  end
end

// Bitslip state machine, split over two clock domains
always @ (posedge pixel_clk)begin
begin
locked_out_dom_ch <= locked_out ;
if (locked_out_dom_ch == 1'b0) begin
    bsstate <= 2 ;
    enable <= 1'b0 ;
    bslipreq <= 1'b0 ;
    bcount <= 4'h0 ;
    jog <= 1'b0 ;
    slip_count <= 3'h0 ;
    bs_finished <= 1'b0 ;
end
else begin
       bslip_ack_dom_ch <= bslip_ack ;
    enable <= 1'b1 ;
       if (enable == 1'b1) begin
           if (clk_iserdes_data != 7'b1100001) begin flag1 <= 1'b1 ; end else begin flag1 <= 1'b0 ; end 
           if (clk_iserdes_data != 7'b1100011) begin flag2 <= 1'b1 ; end else begin flag2 <= 1'b0 ; end
           if (bsstate == 0) begin
               if (flag1 == 1'b1 && flag2 == 1'b1) begin
                    bslipreq <= 1'b1 ;                    // bitslip needed
                    bsstate <= 1 ;
               end
               else begin
                   bs_finished <= 1'b1 ;                    // bitslip done
               end
        end
        else if (bsstate == 1) begin                        // wait for bitslip ack from other clock domain
            if (bslip_ack_dom_ch == 1'b1) begin
                bslipreq <= 1'b0 ;                    // bitslip low
                bcount <= 4'h0 ;
                slip_count <= slip_count + 3'h1 ;
                bsstate <= 2 ;
            end
        end
        else if (bsstate == 2) begin                
            bcount <= bcount + 4'h1 ;
            if (bcount == 4'hF) begin
                if (slip_count == 3'h5) begin
                    jog <= ~jog ;
                end
                bsstate <= 0 ;
            end
        end
    end
end
end
end

always @ (posedge rxclk_d4)begin
begin
    not_bs_finished_dom_ch <= ~bs_finished ;
    bslipr_dom_ch <= bslipreq ;
    if (locked_out == 1'b0) begin
        bslip <= 1'b0 ;
        bslip_ack <= 1'b0 ;
        bstate <= 0 ;    
    end    
    else if (bstate == 0 && bslipr_dom_ch == 1'b1) begin
        bslip <= 1'b1 ;
        bslip_ack <= 1'b1 ;
        bstate <= 1 ;
    end
    else if (bstate == 1) begin
        bslip <= 1'b0 ;
        bslip_ack <= 1'b1 ;
        bstate <= 2 ;
    end
    else if (bstate == 2 && bslipr_dom_ch == 1'b0) begin
        bslip_ack <= 1'b0 ;
        bstate <= 0 ;
    end        
end
end

// Clock input 

IBUFGDS_DIFF_OUT #(
    .DIFF_TERM        (DIFF_TERM), 
    .IBUF_LOW_PWR     ("FALSE"))
    iob_clk_in (
    .I                (clkin_p),
    .IB               (clkin_n),
    .O                (rx_clk_in_p),
    .OB               (rx_clk_in_n));

genvar i ;
genvar j ;

IDELAYE2 #(
    .REFCLK_FREQUENCY    (REF_FREQ),
    .HIGH_PERFORMANCE_MODE (HIGH_PERFORMANCE_MODE),
          .IDELAY_VALUE    (1),
          .DELAY_SRC       ("IDATAIN"),
          .IDELAY_TYPE     ("VAR_LOAD"))
    idelay_cm(                   
    .DATAOUT        (rx_clkin_p_d),
    .C              (rxclk_d4),
    .CE             (1'b0),
    .INC            (1'b0),
    .DATAIN         (1'b0),
    .IDATAIN        (rx_clk_in_p),
    .LD             (1'b1),
    .LDPIPEEN        (1'b0),
    .REGRST          (1'b0),
    .CINVCTRL        (1'b0),
    .CNTVALUEIN      (c_delay_in),
    .CNTVALUEOUT     ());
        
IDELAYE2 #(
    .REFCLK_FREQUENCY    (REF_FREQ),
    .HIGH_PERFORMANCE_MODE  (HIGH_PERFORMANCE_MODE),
          .IDELAY_VALUE     (1),
          .DELAY_SRC        ("IDATAIN"),
          .IDELAY_TYPE      ("VAR_LOAD"))
    idelay_cs(                   
    .DATAOUT        (rx_clk_in_n_d),
    .C            (rxclk_d4),
    .CE            (1'b0),
    .INC           (1'b0),
    .DATAIN        (1'b0),
    .IDATAIN       (~rx_clk_in_n),
    .LD            (1'b1),
    .LDPIPEEN        (1'b0),
    .REGRST          (1'b0),
    .CINVCTRL        (1'b0),
    .CNTVALUEIN      ({1'b0, bt_val[4:1]}),
    .CNTVALUEOUT     ());

ISERDESE2 #(
    .DATA_WIDTH        (4),                 
    .DATA_RATE         ("DDR"),             
//    .SERDES_MODE     ("MASTER"),             
    .IOBDELAY          ("IFD"),             
    .INTERFACE_TYPE    ("NETWORKING"),
    .NUM_CE            (1))        
    iserdes_cs (
    .D              (1'b0),
    .DDLY           (rx_clk_in_n_d),
    .CE1            (1'b1),
    .CE2            (1'b1),
    .CLK            (rxclk),
    .CLKB           (~rxclk),
    .RST            (rstcserdes),
    .CLKDIV         (rxclk_d4),
    .CLKDIVP        (1'b0),
    .OCLK           (1'b0),
    .OCLKB          (1'b0),
    .DYNCLKSEL      (1'b0),
    .DYNCLKDIVSEL   (1'b0),
    .SHIFTIN1       (1'b0),
    .SHIFTIN2       (1'b0),
    .BITSLIP        (bslip),
    .O              (),
    .Q8             (),
    .Q7             (),
    .Q6             (),
    .Q5             (),
    .Q4             (cdataout[0]),
    .Q3             (cdataout[1]),
    .Q2             (cdataout[2]),
    .Q1             (cdataout[3]),
    .OFB            (),
    .SHIFTOUT1      (),
    .SHIFTOUT2      ());

generate
if (USE_PLL == "FALSE") begin : loop8                    // use an MMCM
assign status[6] = 1'b1 ; 
(*KEEP_HIERARCHY  = "TRUE"*)    
MMCME2_ADV #(
    .BANDWIDTH          ("OPTIMIZED"),          
    .CLKFBOUT_MULT_F     (7*MMCM_MODE),                   
    .CLKFBOUT_PHASE      (0.0),                 
    .CLKIN1_PERIOD       (CLKIN_PERIOD),          
    .CLKIN2_PERIOD       (CLKIN_PERIOD),          
    .CLKOUT0_DIVIDE_F    (2*MMCM_MODE),                   
    .CLKOUT0_DUTY_CYCLE  (0.5),                 
    .CLKOUT0_PHASE       (0.0),                
    .CLKOUT0_USE_FINE_PS    ("FALSE"),
    .CLKOUT1_PHASE       (11.25),                
    .CLKOUT1_DIVIDE      (4*MMCM_MODE),                   
    .CLKOUT1_DUTY_CYCLE  (0.5),                 
    .CLKOUT1_USE_FINE_PS       ("FALSE"),                
    .COMPENSATION        ("ZHOLD"),        
    .DIVCLK_DIVIDE       (1),                
    .REF_JITTER1        (0.100))                
    rx_mmcm_adv_inst (
    .CLKFBOUT       (rxpllmmcm_x1),                      
    .CLKFBOUTB      (),                      
    .CLKFBSTOPPED   (),                      
    .CLKINSTOPPED   (),                      
    .CLKOUT0        (rxpllmmcm_xs),              
    .CLKOUT0B       (),                  
    .CLKOUT1        (rxpllmmcm_d4),               
    .PSCLK          (1'b0),  
    .PSEN           (1'b0),  
    .PSINCDEC       (1'b0),  
    .PWRDWN         (1'b0), 
    .LOCKED         (mmcm_locked),                
    .CLKFBIN        (pixel_clk),            
    .CLKIN1         (rx_clkin_p_d),         
    .CLKIN2         (1'b0),                     
    .CLKINSEL       (1'b1),                     
    .DADDR          (7'h00),                    
    .DCLK           (1'b0),                       
    .DEN            (1'b0),                        
    .DI             (16'h0000),                
    .DWE            (1'b0),                        
    .RST            (reset)) ;                   

   if (PIXEL_CLOCK == "BUF_G") begin                         // Final clock selection
      BUFG    bufg_mmcm_x1 (.I(rxpllmmcm_x1), .O(pixel_clk)) ;
      assign status[1:0] = 2'b00 ;
   end
   else if (PIXEL_CLOCK == "BUF_R") begin
      BUFR #(.BUFR_DIVIDE("1"),.SIM_DEVICE("7SERIES"))bufr_mmcm_x1 (.I(rxpllmmcm_x1),.CE(1'b1),.O(pixel_clk),.CLR(1'b0)) ;
      assign status[1:0] = 2'b01 ;
   end
   else begin 
      BUFH    bufh_mmcm_x1 (.I(rxpllmmcm_x1), .O(pixel_clk)) ;
      assign status[1:0] = 2'b10 ;
   end

   if (INTER_CLOCK == "BUF_G") begin                         // Intermediate clock selection
      BUFG    bufg_mmcm_d4 (.I(rxpllmmcm_d4), .O(rxclk_d4)) ;
      assign status[3:2] = 2'b00 ;
   end
   else if (INTER_CLOCK == "BUF_R") begin
      BUFR #(.BUFR_DIVIDE("2"),.SIM_DEVICE("7SERIES"))bufr_mmcm_d4 (.I(rxpllmmcm_xs),.CE(1'b1),.O(rxclk_d4),.CLR(1'b0)) ;
      assign status[3:2] = 2'b01 ;
   end
   else begin 
      BUFH    bufh_mmcm_d4 (.I(rxpllmmcm_d4), .O(rxclk_d4)) ;
      assign status[3:2] = 2'b10 ;
   end
      
   if (SAMPL_CLOCK == "BUF_G") begin                        // Sample clock selection
      BUFG    bufg_mmcm_xn (.I(rxpllmmcm_xs), .O(rxclk)) ;
      assign status[5:4] = 2'b00 ;
   end
   else if (SAMPL_CLOCK == "BUFIO") begin
      BUFIO      bufio_mmcm_xn (.I (rxpllmmcm_xs), .O(rxclk)) ;
      assign status[5:4] = 2'b11 ;
   end
   else begin 
      BUFH    bufh_mmcm_xn (.I(rxpllmmcm_xs), .O(rxclk)) ;
      assign status[5:4] = 2'b10 ;
   end
   
end 
else begin                                    // Use a PLL
assign status[6] = 1'b0 ; 

PLLE2_ADV #(
    .BANDWIDTH           ("OPTIMIZED"),          
    .CLKFBOUT_MULT       (7*MMCM_MODE),                   
    .CLKFBOUT_PHASE      (0.0),                 
    .CLKIN1_PERIOD       (CLKIN_PERIOD),          
    .CLKIN2_PERIOD       (CLKIN_PERIOD),          
    .CLKOUT0_DIVIDE      (2*MMCM_MODE),                   
    .CLKOUT0_DUTY_CYCLE  (0.5),                 
    .CLKOUT0_PHASE       (0.0),                 
    .CLKOUT1_DIVIDE      (4*MMCM_MODE),                   
    .CLKOUT1_DUTY_CYCLE  (0.5),                 
    .CLKOUT1_PHASE       (11.25),                                                   
    .COMPENSATION        ("ZHOLD"),        
    .DIVCLK_DIVIDE       (1),                
    .REF_JITTER1         (0.100))                
    rx_plle2_adv_inst (
    .CLKFBOUT       (rxpllmmcm_x1),                      
    .CLKOUT0        (rxpllmmcm_xs),              
    .CLKOUT1        (rxpllmmcm_d4),                                        
    .PWRDWN         (1'b0), 
    .LOCKED         (mmcm_locked),                
    .CLKFBIN        (pixel_clk),            
    .CLKIN1         (rx_clkin_p_d),         
    .CLKIN2         (1'b0),                     
    .CLKINSEL       (1'b1),                     
    .DADDR          (7'h00),                    
    .DCLK           (1'b0),                       
    .DEN            (1'b0),                        
    .DI             (16'h0000),                
    .DWE            (1'b0),                        
    .RST            (reset)) ;  

   if (PIXEL_CLOCK == "BUF_G") begin                         // Final clock selection
      BUFG    bufg_pll_x1 (.I(rxpllmmcm_x1), .O(pixel_clk)) ;
      assign status[1:0] = 2'b00 ;
   end
   else if (PIXEL_CLOCK == "BUF_R") begin
      BUFR #(.BUFR_DIVIDE("1"),.SIM_DEVICE("7SERIES"))bufr_pll_x1 (.I(rxpllmmcm_x1),.CE(1'b1),.O(pixel_clk),.CLR(1'b0)) ;
      assign status[1:0] = 2'b01 ;
   end
   else begin 
      BUFH    bufh_pll_x1 (.I(rxpllmmcm_x1), .O(pixel_clk)) ;
      assign status[1:0] = 2'b10 ;
   end

   if (INTER_CLOCK == "BUF_G") begin                         // Intermediate clock selection
      BUFG    bufg_pll_d4 (.I(rxpllmmcm_d4), .O(rxclk_d4)) ;
      assign status[3:2] = 2'b00 ;
   end
   else if (INTER_CLOCK == "BUF_R") begin
      BUFR #(.BUFR_DIVIDE("2"),.SIM_DEVICE("7SERIES"))bufr_pll_d4 (.I(rxpllmmcm_xs),.CE(1'b1),.O(rxclk_d4),.CLR(1'b0)) ;
      assign status[3:2] = 2'b01 ;
   end
   else begin 
      BUFH    bufh_pll_d4 (.I(rxpllmmcm_d4), .O(rxclk_d4)) ;
      assign status[3:2] = 2'b10 ;
   end
      
   if (SAMPL_CLOCK == "BUF_G") begin                        // Sample clock selection
      BUFG    bufg_pll_xn (.I(rxpllmmcm_xs), .O(rxclk)) ;
      assign status[5:4] = 2'b00 ;
   end
   else if (SAMPL_CLOCK == "BUFIO") begin
      BUFIO      bufio_pll_xn (.I (rxpllmmcm_xs), .O(rxclk)) ;
      assign status[5:4] = 2'b11 ;
   end
   else begin 
      BUFH    bufh_pll_xn (.I(rxpllmmcm_xs), .O(rxclk)) ;
      assign status[5:4] = 2'b10 ;
   end

end
endgenerate

always @ (posedge pixel_clk) begin                    // retiming
    clk_iserdes_data_d <= clk_iserdes_data ;
    if ((clk_iserdes_data != clk_iserdes_data_d) && (clk_iserdes_data != 7'h00) && (clk_iserdes_data != 7'h7F)) begin
        data_different <= 1'b1 ;
    end
    else begin
        data_different <= 1'b0 ;
    end
end
    
always @ (posedge rxclk_d4) begin                            // clock delay shift state machine
    not_rx_mmcm_lckd_intd4 <= ~(mmcm_locked & idelay_rdy) ;
    rstcserdes <= not_rx_mmcm_lckd_intd4 | rst_iserdes ;
    if (not_rx_mmcm_lckd_intd4 == 1'b1) begin
        scount <= 6'h00 ;
        state2 <= 0 ;
        state2_count <= 5'h00 ;
        locked_out <= 1'b0 ;
        chfoundc <= 1'b1 ;
        c_delay_in <= bt_val ;                            // Start the delay line at the current bit period
        rst_iserdes <= 1'b0 ;
        c_loop_cnt <= 2'b00 ;    
    end
    else begin
        if (scount[5] == 1'b0) begin
            scount <= scount + 6'h01 ;
        end
        state2_count <= state2_count + 5'h01 ;
        data_different_dom_ch <= data_different ;
        if (chfoundc == 1'b1) begin
            chfound <= 1'b0 ;
        end
        else if (chfound == 1'b0 && data_different_dom_ch == 1'b1) begin
            chfound <= 1'b1 ;
        end
        if ((state2_count == 5'h1F && scount[5] == 1'b1)) begin
            case(state2)                     
            0    : begin                            // decrement delay and look for a change
                  if (chfound == 1'b1 || (c_loop_cnt == 2'b11 && c_delay_in == 5'h00)) begin  // quit loop if we've been around a few times
                    chfoundc <= 1'b1 ;
                    state2 <= 1 ;
                  end
                  else begin
                    chfoundc <= 1'b0 ;
                    if (c_delay_in != 5'h00) begin            // check for underflow
                        c_delay_in <= c_delay_in - 5'h01 ;
                    end
                    else begin
                        c_delay_in <= bt_val ;
                        c_loop_cnt <= c_loop_cnt + 2'b01 ;
                    end
                  end
                  end
            1    : begin                            // add half a bit period using input information
                  state2 <= 2 ; 
                  if (c_delay_in < {1'b0, bt_val[4:1]}) begin        // choose the lowest delay value to minimise jitter
                       c_delay_in_target <= c_delay_in + {1'b0, bt_val[4:1]} ;
                  end
                  else begin
                       c_delay_in_target <= c_delay_in - {1'b0, bt_val[4:1]} ;
                  end
                  end
            2     : begin
                  if (c_delay_in == c_delay_in_target) begin
                       state2 <= 3 ;
                  end
                  else begin
                       if (c_delay_in_ud == 1'b1) begin        // move gently to end position to stop MMCM unlocking
                        c_delay_in <= c_delay_in + 5'h01 ;
                           c_delay_in_ud <= 1'b1 ;
                       end
                       else begin
                        c_delay_in <= c_delay_in - 5'h01 ;
                           c_delay_in_ud <= 1'b0 ;
                       end
                  end
                  end
            3     : begin rst_iserdes <= 1'b1 ; state2 <= 4 ; end        // remove serdes reset
            default    : begin                            // issue locked out signal 
                  rst_iserdes <= 1'b0 ;  locked_out <= 1'b1 ;
                   end
            endcase
        end
    end
end
    
generate
for (i = 0 ; i <= D-1 ; i = i+1)
begin : loop3

delay_controller_wrap # (.S(4))
    dc_inst (                       
    .m_datain        (mdataout[4*i+3:4*i]),
    .s_datain        (sdataout[4*i+3:4*i]),
    .enable_phase_detector (enable_phase_detector),
    .enable_monitor        (enable_monitor),
    .reset          (not_bs_finished_dom_ch),
    .clk            (rxclk_d4),
    .c_delay_in     ({1'b0, bt_val[4:1]}),
    .m_delay_out    (m_delay_val_in[5*i+4:5*i]),
    .s_delay_out    (s_delay_val_in[5*i+4:5*i]),
    .data_out       (mdataoutd[4*i+3:4*i]),
    .bt_val         (bt_val),
    .results        (eye_info[32*i+31:32*i]),
    .m_delay_1hot   (m_delay_1hot[32*i+31:32*i]),
    .del_mech       (del_mech)) ;

end
endgenerate 

always @ (posedge rxclk_d4) begin                            // clock balancing
    if (enable_phase_detector == 1'b1) begin
        cdataouta[3:0] <= cdataout[3:0] ;
        cdataoutb[3:0] <= cdataouta[3:0] ;
        cdataoutc[3:0] <= cdataoutb[3:0] ;
    end
    else begin
        cdataoutc[3:0] <= cdataout[3:0] ;
    end
end

// Data gearbox (includes clock data) - this is a master and will generate reset for the slaves

gearbox_4_to_7 # (.D (D+1))         
    gb0 (                           
    .input_clock    (rxclk_d4),
    .output_clock   (pixel_clk),
    .datain         ({cdataoutc, mdataoutd}),
    .reset          (not_rx_mmcm_lckd_intd4),
    .reset_out      (gb_rst_out),
    .jog            (jog),
    .dataout        ({clk_iserdes_data, dataout})) ;
    
// Data bit Receivers 

generate
for (i = 0 ; i <= D-1 ; i = i+1) begin : loop0
for (j = 0 ; j <= 6 ; j = j+1) begin : loop1            // Assign data bits to correct serdes according to required format
    if (DATA_FORMAT == "PER_CLOCK") begin
        assign rx_data[D*j+i] = dataout[7*i+j] ;
    end 
    else begin
        assign rx_data[7*i+j] = dataout[7*i+j] ;
    end
end

IBUFDS_DIFF_OUT #(
    .DIFF_TERM         (DIFF_TERM),
    .IBUF_LOW_PWR      ("FALSE")) 
    data_in (
    .I                (datain_p[i]),
    .IB               (datain_n[i]),
    .O                (rx_data_in_p[i]),
    .OB               (rx_data_in_n[i]));

assign rx_data_in_m[i] = rx_data_in_p[i]  ^ RX_SWAP_MASK[i] ;
assign rx_data_in_s[i] = ~rx_data_in_n[i] ^ RX_SWAP_MASK[i] ;

IDELAYE2 #(
    .REFCLK_FREQUENCY    (REF_FREQ),
    .HIGH_PERFORMANCE_MODE(HIGH_PERFORMANCE_MODE),
          .IDELAY_VALUE   (0),
          .DELAY_SRC      ("IDATAIN"),
          .IDELAY_TYPE    ("VAR_LOAD"))
    idelay_m(                   
    .DATAOUT      (rx_data_in_md[i]),
    .C            (rxclk_d4),
    .CE           (1'b0),
    .INC          (1'b0),
    .DATAIN       (1'b0),
    .IDATAIN      (rx_data_in_m[i]),
    .LD           (1'b1),
    .LDPIPEEN     (1'b0),
    .REGRST       (1'b0),
    .CINVCTRL     (1'b0),
    .CNTVALUEIN   (m_delay_val_in[5*i+4:5*i]),
    .CNTVALUEOUT  ());
        
ISERDESE2 #(
    .DATA_WIDTH        (4),             
    .DATA_RATE         ("DDR"),         
    .SERDES_MODE       ("MASTER"),         
    .IOBDELAY          ("IFD"),         
    .INTERFACE_TYPE    ("NETWORKING"),
    .NUM_CE            (1))     
    iserdes_m (
    .D               (1'b0),
    .DDLY            (rx_data_in_md[i]),
    .CE1             (1'b1),
    .CE2             (1'b1),
    .CLK             (rxclk),
    .CLKB            (~rxclk),
    .RST             (rst_iserdes),
    .CLKDIV          (rxclk_d4),
    .CLKDIVP         (1'b0),
    .OCLK            (1'b0),
    .OCLKB           (1'b0),
    .DYNCLKSEL       (1'b0),
    .DYNCLKDIVSEL    (1'b0),
    .SHIFTIN1        (1'b0),
    .SHIFTIN2        (1'b0),
    .BITSLIP         (bslip),
    .O               (),
    .Q8              (),
    .Q7              (),
    .Q6              (),
    .Q5              (),
    .Q4              (mdataout[4*i+0]),
    .Q3              (mdataout[4*i+1]),
    .Q2              (mdataout[4*i+2]),
    .Q1              (mdataout[4*i+3]),
    .OFB             (),
    .SHIFTOUT1       (),
    .SHIFTOUT2       ());

IDELAYE2 #(
    .REFCLK_FREQUENCY   (REF_FREQ),
    .HIGH_PERFORMANCE_MODE(HIGH_PERFORMANCE_MODE),
          .IDELAY_VALUE   (0),
          .DELAY_SRC      ("IDATAIN"),
          .IDELAY_TYPE    ("VAR_LOAD"))
    idelay_s(                   
    .DATAOUT      (rx_data_in_sd[i]),
    .C            (rxclk_d4),
    .CE           (1'b0),
    .INC          (1'b0),
    .DATAIN       (1'b0),
    .IDATAIN      (rx_data_in_s[i]),
    .LD           (1'b1),
    .LDPIPEEN     (1'b0),
    .REGRST       (1'b0),
    .CINVCTRL     (1'b0),
    .CNTVALUEIN   (s_delay_val_in[5*i+4:5*i]),
    .CNTVALUEOUT  ());
    
ISERDESE2 #(
    .DATA_WIDTH   (4),             
    .DATA_RATE    ("DDR"),         
    .SERDES_MODE  ("MASTER"),         
    .IOBDELAY     ("IFD"),         
    .INTERFACE_TYPE ("NETWORKING"),
    .NUM_CE       (1))     
    iserdes_s (
    .D            (1'b0),
    .DDLY         (rx_data_in_sd[i]),
    .CE1          (1'b1),
    .CE2          (1'b1),
    .CLK          (rxclk),
    .CLKB         (~rxclk),
    .RST          (rst_iserdes),
    .CLKDIV       (rxclk_d4),
    .CLKDIVP      (1'b0),
    .OCLK         (1'b0),
    .OCLKB        (1'b0),
    .DYNCLKSEL    (1'b0),
    .DYNCLKDIVSEL (1'b0),
    .SHIFTIN1     (1'b0),
    .SHIFTIN2     (1'b0),
    .BITSLIP      (bslip),
    .O            (),
    .Q8           (),
    .Q7           (),
    .Q6           (),
    .Q5           (),
    .Q4           (sdataout[4*i+0]),
    .Q3           (sdataout[4*i+1]),
    .Q2           (sdataout[4*i+2]),
    .Q1           (sdataout[4*i+3]),
    .OFB          (),
    .SHIFTOUT1    (),
    .SHIFTOUT2    ());
    
end
endgenerate

endmodule

//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2012-2015 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
//////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.2
//  \   \        Filename: delay_controller_wrap.v
//  /   /        Date Last Modified: 21JAN2015
// /___/   /\    Date Created: 8JAN2013
// \   \  /  \
//  \___\/\___\
// 
//Device: 	7 Series
//Purpose:  	Controls delays on a per-bit basis
//		Number of bits from each seres set via an attribute
//
//Reference:	XAPP585
//    
//Revision History:
//    Rev 1.0 - First created (nicks)
//    Rev 1.2 - Updated format (brandond)
//////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

module delay_controller_wrap (m_datain, s_datain, enable_phase_detector, enable_monitor, reset, clk, c_delay_in, m_delay_out, s_delay_out, data_out, bt_val, results, m_delay_1hot, del_mech) ;

parameter integer 	S = 4 ;   			// Set the number of bits

input		[S-1:0]	m_datain ;			// Inputs from master serdes
input		[S-1:0]	s_datain ;			// Inputs from slave serdes
input		enable_phase_detector ;		// Enables the phase detector logic when high
input		enable_monitor ;		// Enables the eye monitoring logic when high
input		reset ;				// Reset line synchronous to clk 
input		clk ;				// Global/Regional clock 
input		[4:0]	c_delay_in ;			// delay value found on clock line
output		[4:0]	m_delay_out ;			// Master delay control value
output		[4:0]	s_delay_out ;			// Master delay control value
output	reg	[S-1:0]	data_out ;			// Output data
input		[4:0]	bt_val ;			// Calculated bit time value for slave devices
output	reg	[31:0]	results ;			// eye monitor result data	
output	reg	[31:0]	m_delay_1hot ;			// Master delay control value as a one-hot vector	
input		del_mech ;			// changes delay mechanism slightly at higher bit rates

reg	[S-1:0]	mdataouta ;		
reg			mdataoutb ;		
reg	[S-1:0]	mdataoutc ;		
reg	[S-1:0]	sdataouta ;		
reg			sdataoutb ;		
reg	[S-1:0]	sdataoutc ;		
reg			s_ovflw ; 		
reg	[1:0]	m_delay_mux ;				
reg	[1:0]	s_delay_mux ;				
reg			data_mux ;		
reg			dec_run ;			
reg			inc_run ;			
reg			eye_run ;			
reg	[4:0]	s_state ;					
reg	[5:0]	pdcount ;					
reg	[4:0]	m_delay_val_int ;	
reg	[4:0]	s_delay_val_int ;	
reg	[4:0]	s_delay_val_eye ;	
reg			meq_max	;		
reg			meq_min	;		
reg			pd_max	;		
reg			pd_min	;		
reg			delay_change ;		
wire	[S-1:0]	all_high ;		
wire	[S-1:0]	all_low	;		
wire	[7:0]	msxoria	;		
wire	[7:0]	msxorda	;		
reg	[1:0]		action	;		
reg	[1:0]		msxor_cti ;
reg	[1:0]		msxor_ctd ;
reg	[1:0]		msxor_ctix ;
reg	[1:0]		msxor_ctdx ;
wire	[2:0]	msxor_ctiy ;
wire	[2:0]	msxor_ctdy ;
reg	[7:0]		match ;	
reg	[31:0]		shifter ;	
reg	[7:0]		pd_hold ;	
	
assign m_delay_out = m_delay_val_int ;
assign s_delay_out = s_delay_val_int ;
genvar i ;

generate

for (i = 0 ; i <= S-2 ; i = i+1) begin : loop0

assign msxoria[i+1] = ((~s_ovflw & ((mdataouta[i] & ~mdataouta[i+1] & ~sdataouta[i])   | (~mdataouta[i] & mdataouta[i+1] &  sdataouta[i]))) | 
	               ( s_ovflw & ((mdataouta[i] & ~mdataouta[i+1] & ~sdataouta[i+1]) | (~mdataouta[i] & mdataouta[i+1] &  sdataouta[i+1])))) ; // early bits                   
assign msxorda[i+1] = ((~s_ovflw & ((mdataouta[i] & ~mdataouta[i+1] &  sdataouta[i])   | (~mdataouta[i] & mdataouta[i+1] & ~sdataouta[i])))) | 
	               ( s_ovflw & ((mdataouta[i] & ~mdataouta[i+1] &  sdataouta[i+1]) | (~mdataouta[i] & mdataouta[i+1] & ~sdataouta[i+1]))) ;	// late bits
end 
endgenerate

assign msxoria[0] = ((~s_ovflw & ((mdataoutb & ~mdataouta[0] & ~sdataoutb)    | (~mdataoutb & mdataouta[0] &  sdataoutb))) | 			// first early bit
	             ( s_ovflw & ((mdataoutb & ~mdataouta[0] & ~sdataouta[0]) | (~mdataoutb & mdataouta[0] &  sdataouta[0])))) ;
assign msxorda[0] = ((~s_ovflw & ((mdataoutb & ~mdataouta[0] &  sdataoutb)    | (~mdataoutb & mdataouta[0] & ~sdataoutb)))) | 			// first late bit
	             ( s_ovflw & ((mdataoutb & ~mdataouta[0] &  sdataouta[0]) | (~mdataoutb & mdataouta[0] & ~sdataouta[0]))) ;

always @ (posedge clk) begin				// generate number of incs or decs for low 4 bits
	case (msxoria[3:0])
		4'h0    : msxor_cti <= 2'h0 ;
		4'h1    : msxor_cti <= 2'h1 ;
		4'h2    : msxor_cti <= 2'h1 ;
		4'h3    : msxor_cti <= 2'h2 ;
		4'h4    : msxor_cti <= 2'h1 ;
		4'h5    : msxor_cti <= 2'h2 ;
		4'h6    : msxor_cti <= 2'h2 ;
		4'h8    : msxor_cti <= 2'h1 ;
		4'h9    : msxor_cti <= 2'h2 ;
		4'hA    : msxor_cti <= 2'h2 ;
		4'hC    : msxor_cti <= 2'h2 ;
		default : msxor_cti <= 2'h3 ;
	endcase
	case (msxorda[3:0])
		4'h0    : msxor_ctd <= 2'h0 ;
		4'h1    : msxor_ctd <= 2'h1 ;
		4'h2    : msxor_ctd <= 2'h1 ;
		4'h3    : msxor_ctd <= 2'h2 ;
		4'h4    : msxor_ctd <= 2'h1 ;
		4'h5    : msxor_ctd <= 2'h2 ;
		4'h6    : msxor_ctd <= 2'h2 ;
		4'h8    : msxor_ctd <= 2'h1 ;
		4'h9    : msxor_ctd <= 2'h2 ;
		4'hA    : msxor_ctd <= 2'h2 ;
		4'hC    : msxor_ctd <= 2'h2 ;
		default : msxor_ctd <= 2'h3 ;
	endcase
	case (msxoria[7:4])				// generate number of incs or decs for high n bits, max 4
		4'h0    : msxor_ctix <= 2'h0 ;
		4'h1    : msxor_ctix <= 2'h1 ;
		4'h2    : msxor_ctix <= 2'h1 ;
		4'h3    : msxor_ctix <= 2'h2 ;
		4'h4    : msxor_ctix <= 2'h1 ;
		4'h5    : msxor_ctix <= 2'h2 ;
		4'h6    : msxor_ctix <= 2'h2 ;
		4'h8    : msxor_ctix <= 2'h1 ;
		4'h9    : msxor_ctix <= 2'h2 ;
		4'hA    : msxor_ctix <= 2'h2 ;
		4'hC    : msxor_ctix <= 2'h2 ;
		default : msxor_ctix <= 2'h3 ;
	endcase
	case (msxorda[7:4])
		4'h0    : msxor_ctdx <= 2'h0 ;
		4'h1    : msxor_ctdx <= 2'h1 ;
		4'h2    : msxor_ctdx <= 2'h1 ;
		4'h3    : msxor_ctdx <= 2'h2 ;
		4'h4    : msxor_ctdx <= 2'h1 ;
		4'h5    : msxor_ctdx <= 2'h2 ;
		4'h6    : msxor_ctdx <= 2'h2 ;
		4'h8    : msxor_ctdx <= 2'h1 ;
		4'h9    : msxor_ctdx <= 2'h2 ;
		4'hA    : msxor_ctdx <= 2'h2 ;
		4'hC    : msxor_ctdx <= 2'h2 ;
		default : msxor_ctdx <= 2'h3 ;
	endcase
end

assign msxor_ctiy = {1'b0, msxor_cti} + {1'b0, msxor_ctix} ;
assign msxor_ctdy = {1'b0, msxor_ctd} + {1'b0, msxor_ctdx} ;

always @ (posedge clk) begin
	if (msxor_ctiy == msxor_ctdy) begin
		action <= 2'h0 ;
	end
	else if (msxor_ctiy > msxor_ctdy) begin
		action <= 2'h1 ;
	end 
	else begin
		action <= 2'h2 ;
	end
end
		       	       
generate
for (i = 0 ; i <= S-1 ; i = i+1) begin : loop1
assign all_high[i] = 1'b1 ;
assign all_low[i] = 1'b0 ;
end 
endgenerate

always @ (posedge clk) begin
	mdataouta <= m_datain ;
	mdataoutb <= mdataouta[S-1] ;
	sdataouta <= s_datain ;
	sdataoutb <= sdataouta[S-1] ;
end
	
always @ (posedge clk) begin
	if (reset == 1'b1) begin
		s_ovflw <= 1'b0 ;
		pdcount <= 6'b100000 ;
		m_delay_val_int <= c_delay_in ; 			// initial master delay
		s_delay_val_int <= c_delay_in ; 			// initial slave delay
		data_mux <= 1'b0 ;
		m_delay_mux <= 2'b01 ;
		s_delay_mux <= 2'b01 ;
		s_state <= 5'b00000 ;
		inc_run <= 1'b0 ;
		dec_run <= 1'b0 ;
		eye_run <= 1'b0 ;
		s_delay_val_eye <= 5'h00 ;
		shifter <= 32'h00000001 ;
		delay_change <= 1'b0 ;
		results <= 32'h00000000 ;
		pd_hold <= 8'h00 ;
	end
	else begin
		case (m_delay_mux)
			2'b00   : mdataoutc <= {mdataouta[S-2:0], mdataoutb} ;
			2'b10   : mdataoutc <= {m_datain[0],      mdataouta[S-1:1]} ;
			default : mdataoutc <= mdataouta ;
		endcase 
		case (s_delay_mux)  
			2'b00   : sdataoutc <= {sdataouta[S-2:0], sdataoutb} ;
			2'b10   : sdataoutc <= {s_datain[0],      sdataouta[S-1:1]} ;
			default : sdataoutc <= sdataouta ;
		endcase
		if (m_delay_val_int == bt_val) begin
			meq_max <= 1'b1 ;
		end else begin 
			meq_max <= 1'b0 ;
		end 
		if (m_delay_val_int == 5'h00) begin
			meq_min <= 1'b1 ;
		end else begin 
			meq_min <= 1'b0 ;
		end 
		if (pdcount == 6'h3F && pd_max == 1'b0 && delay_change == 1'b0) begin
			pd_max <= 1'b1 ;
		end else begin 
			pd_max <= 1'b0 ;
		end 
		if (pdcount == 6'h00 && pd_min == 1'b0 && delay_change == 1'b0) begin
			pd_min <= 1'b1 ;
		end else begin 
			pd_min <= 1'b0 ;
		end
		if (delay_change == 1'b1 || inc_run == 1'b1 || dec_run == 1'b1 || eye_run == 1'b1) begin
			pd_hold <= 8'hFF ;
			pdcount <= 6'b100000 ; 
		end													// increment filter count
		else if (pd_hold[7] == 1'b1) begin
			pdcount <= 6'b100000 ; 
			pd_hold <= {pd_hold[6:0], 1'b0} ;
		end
		else if (action[0] == 1'b1 && pdcount != 6'b111111) begin 
			pdcount <= pdcount + 6'h01 ; 
		end													// decrement filter count
		else if (action[1] == 1'b1 && pdcount != 6'b000000) begin 
			pdcount <= pdcount - 6'h01 ; 
		end
		if ((enable_phase_detector == 1'b1 && pd_max == 1'b1 && delay_change == 1'b0) || inc_run == 1'b1) begin					// increment delays, check for master delay = max
			delay_change <= 1'b1 ;
			if (meq_max == 1'b0 && inc_run == 1'b0) begin
				m_delay_val_int <= m_delay_val_int + 5'h01 ;
			end 
			else begin											// master is max
				s_state[3:0] <= s_state[3:0] + 4'h1 ;
				case (s_state[3:0]) 
				4'b0000 : begin inc_run <= 1'b1 ; s_delay_val_int <= bt_val ; end			// indicate state machine running and set slave delay to bit time 
				4'b0110 : begin data_mux <= 1'b1 ; m_delay_val_int <= 5'b00000 ; end			// change data mux over to forward slave data and set master delay to zero
				4'b1001 : begin m_delay_mux <= m_delay_mux - 2'h1 ; end 				// change delay mux over to forward with a 1-bit less advance
				4'b1110 : begin data_mux <= 1'b0 ; end 							// change data mux over to forward master data
				4'b1111 : begin s_delay_mux <= m_delay_mux ; inc_run <= 1'b0 ; end			// change delay mux over to forward with a 1-bit less advance
				default : begin inc_run <= 1'b1 ; end
				endcase 
			end
		end
		else if ((enable_phase_detector == 1'b1 && pd_min == 1'b1 && delay_change == 1'b0) || dec_run == 1'b1) begin				// decrement delays, check for master delay = 0
			delay_change <= 1'b1 ;
			if (meq_min == 1'b0 && dec_run == 1'b0) begin
				m_delay_val_int <= m_delay_val_int - 5'h01 ;
			end
			else begin 											// master is zero
				s_state[3:0] <= s_state[3:0] + 4'h1 ;
				case (s_state[3:0]) 
				4'b0000 : begin dec_run <= 1'b1 ; s_delay_val_int <= 5'b00000 ; end			// indicate state machine running and set slave delay to zero 
				4'b0110 : begin data_mux <= 1'b1 ;  m_delay_val_int <= bt_val ;	end			// change data mux over to forward slave data and set master delay to bit time 
				4'b1001 : begin m_delay_mux <= m_delay_mux + 2'h1 ; end  				// change delay mux over to forward with a 1-bit more advance
				4'b1110 : begin data_mux <= 1'b0 ; end 							// change data mux over to forward master data
				4'b1111 : begin s_delay_mux <= m_delay_mux ; dec_run <= 1'b0 ; end			// change delay mux over to forward with a 1-bit less advance
				default : begin dec_run <= 1'b1 ; end
				endcase 
			end
		end
		else if (enable_monitor == 1'b1 && (eye_run == 1'b1 || delay_change == 1'b1)) begin
			delay_change <= 1'b0 ;
			s_state <= s_state + 5'h01 ;
			case (s_state) 
				5'b00000 : begin eye_run <= 1'b1 ; s_delay_val_int <= s_delay_val_eye ; end						// indicate state machine running and set slave delay to monitor value 
				5'b10110 : begin 
				           if (match == 8'hFF) begin results <= results | shifter ; end			//. set or clear result bit
				           else begin results <= results & ~shifter ; end 							 
				           if (s_delay_val_eye == bt_val) begin 					// only monitor active taps, ie as far as btval
				          	shifter <= 32'h00000001 ; s_delay_val_eye <= 5'h00 ; end
				           else begin shifter <= {shifter[30:0], shifter[31]} ; 
				          	s_delay_val_eye <= s_delay_val_eye + 5'h01 ; end			// 
				          	eye_run <= 1'b0 ; s_state <= 5'h00 ; end
				default :  begin eye_run <= 1'b1 ; end
			endcase 
		end
		else begin
			delay_change <= 1'b0 ;
			if (m_delay_val_int >= {1'b0, bt_val[4:1]} &&  del_mech == 1'b0) begin 						// set slave delay to 1/2 bit period beyond or behind the master delay
				s_delay_val_int <= m_delay_val_int - {1'b0, bt_val[4:1]} ;
				s_ovflw <= 1'b0 ;
			end
			else begin
				s_delay_val_int <= m_delay_val_int + {1'b0, bt_val[4:1]} ;
				s_ovflw <= 1'b1 ;
			end 
		end 
		if (enable_phase_detector == 1'b0 && delay_change == 1'b0) begin
			delay_change <= 1'b1 ;
		end
	end
	if (enable_phase_detector == 1'b1) begin
		if (data_mux == 1'b0) begin
			data_out <= mdataoutc ;
		end else begin 
			data_out <= sdataoutc ;
		end
	end
	else begin
		data_out <= m_datain ;	
	end
end

always @ (posedge clk) begin
	if ((mdataouta == sdataouta)) begin
		match <= {match[6:0], 1'b1} ;
	end else begin
		match <= {match[6:0], 1'b0} ;
	end
end

always @ (m_delay_val_int) begin
	case (m_delay_val_int)
	    	5'b00000	: m_delay_1hot <= 32'h00000001 ;
	    	5'b00001	: m_delay_1hot <= 32'h00000002 ;
	    	5'b00010	: m_delay_1hot <= 32'h00000004 ;
	    	5'b00011	: m_delay_1hot <= 32'h00000008 ;
	    	5'b00100	: m_delay_1hot <= 32'h00000010 ;
	    	5'b00101	: m_delay_1hot <= 32'h00000020 ;
	    	5'b00110	: m_delay_1hot <= 32'h00000040 ;
	    	5'b00111	: m_delay_1hot <= 32'h00000080 ;
	    	5'b01000	: m_delay_1hot <= 32'h00000100 ;
	    	5'b01001	: m_delay_1hot <= 32'h00000200 ;
	    	5'b01010	: m_delay_1hot <= 32'h00000400 ;
	    	5'b01011	: m_delay_1hot <= 32'h00000800 ;
	    	5'b01100	: m_delay_1hot <= 32'h00001000 ;
	    	5'b01101	: m_delay_1hot <= 32'h00002000 ;
	    	5'b01110	: m_delay_1hot <= 32'h00004000 ;
	    	5'b01111	: m_delay_1hot <= 32'h00008000 ;
            5'b10000	: m_delay_1hot <= 32'h00010000 ;
            5'b10001	: m_delay_1hot <= 32'h00020000 ;
            5'b10010	: m_delay_1hot <= 32'h00040000 ;
            5'b10011	: m_delay_1hot <= 32'h00080000 ;
            5'b10100	: m_delay_1hot <= 32'h00100000 ;
            5'b10101	: m_delay_1hot <= 32'h00200000 ;
            5'b10110	: m_delay_1hot <= 32'h00400000 ;
            5'b10111	: m_delay_1hot <= 32'h00800000 ;
            5'b11000	: m_delay_1hot <= 32'h01000000 ;
            5'b11001	: m_delay_1hot <= 32'h02000000 ;
            5'b11010	: m_delay_1hot <= 32'h04000000 ;
            5'b11011	: m_delay_1hot <= 32'h08000000 ;
            5'b11100	: m_delay_1hot <= 32'h10000000 ;
            5'b11101	: m_delay_1hot <= 32'h20000000 ;
            5'b11110	: m_delay_1hot <= 32'h40000000 ;
            default		: m_delay_1hot <= 32'h80000000 ; 
         endcase
end
   	
endmodule


//////////////////////////////////////////////////////////////////////////////
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.2
//  \   \        Filename: gearbox_4_to_7.v
//  /   /        Date Last Modified:  21JAN2015
// /___/   /\    Date Created: 5MAR2010
//Device:     7 Series
//Purpose:      multiple 4 to 7 bit gearbox
//Reference:    XAPP585
//Revision History:
//    Rev 1.0 - First created (nicks)
//    Rev 1.1 - reset outputs added
//    Rev 1.2 - Updated format (brandond)
//////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps

module gearbox_4_to_7 (input_clock, output_clock, datain, reset, jog, reset_out, dataout) ;

parameter integer  D = 8 ;           // Parameter to set the number of data lines  

input  input_clock ;        // high speed clock input
input  output_clock ;        // low speed clock input
input  [D*4-1:0] datain ;        // data inputs
input  reset ;            // Reset line
input  jog ;            // jog input, slips by 4 bits
output reg [1:0] reset_out ;        // reset out signal
output reg [D*7-1:0]  dataout ;        // data outputs
                    
reg    [3:0] read_addra ;            
reg    [3:0] read_addrb ;            
reg    [3:0] read_addrc ;            
reg    [3:0] write_addr ;            
reg    read_enable ;    
reg    read_enable_dom_ch ;    
wire   [D*4-1:0] ramouta ;             
wire   [D*4-1:0] ramoutb ;            
wire   [D*4-1:0] ramoutc ;            
reg    local_reset ;    
reg    local_reset_dom_ch ;    
reg    [1:0] mux ;        
wire   [D*4-1:0] dummy ;            
reg    jog_int ;    
reg    rst_int ;    

genvar i ;

always @ (posedge input_clock) begin                // generate local sync reset
    if (reset == 1'b1) begin
        local_reset <= 1'b1 ;
        reset_out[0] <= 1'b1 ;
    end else begin
        local_reset <= 1'b0 ;
        reset_out[0] <= 1'b0 ;
    end
end 

always @ (posedge input_clock) begin                // Gearbox input - 4 bit data at input clock frequency
    if (local_reset == 1'b1) begin
        write_addr <= 4'h0 ;
        read_enable <= 1'b0 ;
    end 
    else begin
        if (write_addr == 4'hD) begin
            write_addr <= 4'h0 ;
        end 
        else begin
            write_addr <= write_addr + 4'h1 ;
        end
        if (write_addr == 4'h3) begin
            read_enable <= 1'b1 ;
        end
    end
end

always @ (posedge output_clock) begin    
    read_enable_dom_ch <= read_enable ;
    local_reset_dom_ch <= local_reset ;
end

always @ (posedge output_clock) begin                // Gearbox output - 10 bit data at output clock frequency
    reset_out[1] <= rst_int ;
    if (local_reset_dom_ch == 1'b1 || read_enable_dom_ch == 1'b0) begin
        rst_int <= 1'b1 ; 
    end
    else begin
        rst_int <= 1'b0 ; 
    end
    if (reset_out[1] == 1'b1) begin
        read_addra <= 4'h0 ;
        read_addrb <= 4'h1 ;
        read_addrc <= 4'h2 ;
        jog_int <= 1'b0 ;
    end
    else begin
        case (jog_int)
        1'b0 : begin
            case (read_addra)
            4'h0    : begin read_addra <= 4'h1 ; read_addrb <= 4'h2 ; read_addrc <= 4'h3 ; mux <= 2'h1 ; end
            4'h1    : begin read_addra <= 4'h3 ; read_addrb <= 4'h4 ; read_addrc <= 4'h5 ; mux <= 2'h2 ; end
            4'h3    : begin read_addra <= 4'h5 ; read_addrb <= 4'h6 ; read_addrc <= 4'h7 ; mux <= 2'h3 ; end
            4'h5    : begin read_addra <= 4'h7 ; read_addrb <= 4'h8 ; read_addrc <= 4'h9 ; mux <= 2'h0 ; end
            4'h7    : begin read_addra <= 4'h8 ; read_addrb <= 4'h9 ; read_addrc <= 4'hA ; mux <= 2'h1 ; end
            4'h8    : begin read_addra <= 4'hA ; read_addrb <= 4'hB ; read_addrc <= 4'hC ; mux <= 2'h2 ; end
            4'hA    : begin read_addra <= 4'hC ; read_addrb <= 4'hD ; read_addrc <= 4'hD ; mux <= 2'h3 ; jog_int <= jog ; end
            default : begin read_addra <= 4'h0 ; read_addrb <= 4'h1 ; read_addrc <= 4'h2 ; mux <= 2'h0 ; end
            endcase 
        end
        1'b1 : begin
            case (read_addra)
            4'h1    : begin read_addra <= 4'h2 ; read_addrb <= 4'h3 ; read_addrc <= 4'h4 ; mux <= 2'h1 ; end
            4'h2    : begin read_addra <= 4'h4 ; read_addrb <= 4'h5 ; read_addrc <= 4'h6 ; mux <= 2'h2 ; end
            4'h4    : begin read_addra <= 4'h6 ; read_addrb <= 4'h7 ; read_addrc <= 4'h8 ; mux <= 2'h3 ; end
            4'h6    : begin read_addra <= 4'h8 ; read_addrb <= 4'h9 ; read_addrc <= 4'hA ; mux <= 2'h0 ; end
            4'h8    : begin read_addra <= 4'h9 ; read_addrb <= 4'hA ; read_addrc <= 4'hB ; mux <= 2'h1 ; end
            4'h9    : begin read_addra <= 4'hB ; read_addrb <= 4'hC ; read_addrc <= 4'hD ; mux <= 2'h2 ; end
            4'hB    : begin read_addra <= 4'hD ; read_addrb <= 4'h0 ; read_addrc <= 4'h1 ; mux <= 2'h3 ; jog_int <= jog ; end
            default : begin read_addra <= 4'h1 ; read_addrb <= 4'h2 ; read_addrc <= 4'h3 ; mux <= 2'h0 ; end
            endcase 
        end
        endcase
    end
end

generate for (i = 0 ; i <= D-1 ; i = i+1)
begin : loop0

always @ (posedge output_clock) begin
    case (mux)
    2'h0    : dataout[7*i+6:7*i] <= {                      ramoutb[4*i+2:4*i+0], ramouta[4*i+3:4*i+0]} ;
    2'h1    : dataout[7*i+6:7*i] <= {ramoutc[4*i+1:4*i+0], ramoutb[4*i+3:4*i+0], ramouta[4*i+3]} ;    
    2'h2    : dataout[7*i+6:7*i] <= {ramoutc[4*i+0],       ramoutb[4*i+3:4*i+0], ramouta[4*i+3:4*i+2]} ; 
    default : dataout[7*i+6:7*i] <= {                      ramoutb[4*i+3:4*i+0], ramouta[4*i+3:4*i+1]} ; 
    endcase 
end 
end
endgenerate 
                     
// Data gearboxes
generate
for (i = 0 ; i <= D*2-1 ; i = i+1)
begin : loop2

RAM32M ram_inst ( 
    .DOA    (ramouta[2*i+1:2*i]), 
    .DOB    (ramoutb[2*i+1:2*i]),
    .DOC    (ramoutc[2*i+1:2*i]), 
    .DOD    (dummy[2*i+1:2*i]),
    .ADDRA  ({1'b0, read_addra}), 
    .ADDRB  ({1'b0, read_addrb}), 
    .ADDRC  ({1'b0, read_addrc}), 
    .ADDRD  ({1'b0, write_addr}),
    .DIA    (datain[2*i+1:2*i]), 
    .DIB    (datain[2*i+1:2*i]),
    .DIC    (datain[2*i+1:2*i]),
    .DID    (dummy[2*i+1:2*i]),
    .WE     (1'b1), 
    .WCLK   (input_clock));

end
endgenerate 

endmodule
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.2
//  \   \        Filename: serdes_1_to_7_slave_idelay_ddr.v
//  /   /        Date Last Modified:  21JAN2015
// /___/   /\    Date Created: 5MAR2010
//Device:     7 Series
//Purpose:      1 to 7 DDR receiver slave data receiver
//        Data formatting is set by the DATA_FORMAT parameter. 
//        PER_CLOCK (default) format receives bits for 0, 1, 2 .. on the same sample edge
//        PER_CHANL format receives bits for 0, 7, 14 ..  on the same sample edge
//Revision History:
//    Rev 1.0 - First created (nicks)
//    Rev 1.1 - PER_CLOCK and PER_CHANL descriptions swapped
//    Rev 1.2 - State machine moved to a new level of hierarchy, eye monitor added, gearbox sync added, updated format
//////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps

module serdes_1_to_7_slave_idelay_ddr (clkin_p, clkin_n, datain_p, datain_n, enable_phase_detector, rxclk, idelay_rdy, reset, pixel_clk, enable_monitor,
                                       rxclk_d4, bitslip_finished, clk_data, rx_data, debug, del_mech, bit_time_value, rst_iserdes, gb_rst_in, eye_info, m_delay_1hot) ;

parameter integer D = 8 ;               // Parameter to set the number of data lines
parameter real    REF_FREQ = 200 ;           // Parameter to set reference frequency used by idelay controller (not currently used - functionality to be added)
parameter         HIGH_PERFORMANCE_MODE = "FALSE";// Parameter to set HIGH_PERFORMANCE_MODE of input delays to reduce jitter
parameter         DIFF_TERM = "FALSE" ;         // Parameter to enable internal differential termination
parameter         DATA_FORMAT = "PER_CLOCK" ;     // Parameter Used to determine method for mapping input parallel word to output serial words
                                          
input  clkin_p ;    // Input from LVDS clock receiver pin
input  clkin_n ;    // Input from LVDS clock receiver pin
input  [D-1:0]  datain_p ;            // Input from LVDS clock data pins
input  [D-1:0]  datain_n ;            // Input from LVDS clock data pins
input  enable_phase_detector ;        // Enables the phase detector logic when high
input  enable_monitor ;        // Enable monitoring function
input  reset ;                // Reset line
input  idelay_rdy ;            // input delays are ready
input  rxclk ;                // Global/BUFIO rx clock network
input  pixel_clk ;            // Global/Regional clock input
input  rxclk_d4 ;            // Global/Regional clock input
output bitslip_finished ;         // bitslipping finished
output [6:0]  clk_data ;             // Clock Data
output [D*7-1:0] rx_data ;             // Received Data
output [10*D+5:0]debug ;                 // debug info
input  del_mech ;            // DCD correct cascade from master
input  [4:0] bit_time_value ;        // Calculated bit time value from 'master'
input  rst_iserdes ;            // reset serdes input
input  [1:0] gb_rst_in ;            // gearbox reset signal in
output [D*32-1:0] eye_info ;             // eye info
output [32*D-1:0] m_delay_1hot ;            // Master delay control value as a one-hot vector

wire   [D*5-1:0] m_delay_val_in ;
wire   [D*5-1:0] s_delay_val_in ;
wire   [3:0] cdataout ;            
reg    [3:0] cdataouta ;            
reg    [3:0] cdataoutb ;            
reg    [3:0] cdataoutc ;            
wire   rx_clk_in ;            
reg    [1:0] bsstate ;                     
reg    bslip ;                     
reg    bslipreq ;                     
reg    bslipr_dom_ch ;                     
reg    [3:0] bcount ;                     
reg    [6*D-1:0] pdcount ;                     
wire   [6:0] clk_iserdes_data ;          
reg    [6:0] clk_iserdes_data_d ;        
reg    enable ;                    
reg    flag1 ;                     
reg    flag2 ;                     
reg    [1:0] state2 ;            
reg    [3:0] state2_count ;            
reg    [5:0] scount ;            
reg    locked_out ;    
reg    locked_out_dom_ch ;    
reg    chfound ;    
reg    chfoundc ;
wire   delay_ready ;
reg    [4:0] c_delay_in ;
reg    local_reset_dom_ch ;
wire   [D-1:0]  rx_data_in_p ;            
wire   [D-1:0]  rx_data_in_n ;            
wire   [D-1:0]  rx_data_in_m ;            
wire   [D-1:0]  rx_data_in_s ;        
wire   [D-1:0]  rx_data_in_md ;            
wire   [D-1:0]  rx_data_in_sd ;    
wire   [(4*D)-1:0] mdataout ;                        
wire   [(4*D)-1:0] mdataoutd ;            
wire   [(4*D)-1:0] sdataout ;                        
wire   [(7*D)-1:0] dataout ;                                      
reg    jog ;        
wire   [(D*6)-1:0] ramouta ;            
wire   [(D*6)-1:0] ramoutb ;            
reg    [2:0] slip_count ;                    
reg    bslip_ack_dom_ch ;        
reg    bslip_ack ;        
reg    [1:0] bstate ;
reg    data_different ;
reg    data_different_dom_ch ;
reg     [D-1:0] s_ovflw ;        
reg     [D-1:0] s_hold ;        
reg    bs_finished ;
reg    not_bs_finished_dom_ch ;
wire    [4:0] bt_val ;  
reg    retry ;
reg    no_clock ;
reg    no_clock_dom_ch ;
reg    [1:0] c_loop_cnt ;  

parameter [D-1:0] RX_SWAP_MASK = 16'h0000 ;    // pinswap mask for input data bits (0 = no swap (default), 1 = swap). Allows inputs to be connected the wrong way round to ease PCB routing.

assign clk_data = clk_iserdes_data ;
assign debug = {s_delay_val_in, m_delay_val_in, bslip, c_delay_in} ;

assign bitslip_finished = bs_finished & ~reset ;
assign bt_val = bit_time_value ;

always @ (posedge rxclk_d4 or posedge reset or posedge retry) begin            // generate local async assert, sync release reset
if (reset == 1'b1 || retry == 1'b1) begin
    local_reset_dom_ch <= 1'b1 ;
end
else begin
    if (idelay_rdy == 1'b0) begin
        local_reset_dom_ch <= 1'b1 ;
    end
    else begin
        local_reset_dom_ch <= 1'b0 ;
    end
end
end

// Bitslip state machine, split over two clock domains
always @ (posedge pixel_clk)
begin
locked_out_dom_ch <= locked_out ;
if (locked_out_dom_ch == 1'b0) begin
    bsstate <= 2 ;
    enable <= 1'b0 ;
    bslipreq <= 1'b0 ;
    bcount <= 4'h0 ;
    jog <= 1'b0 ;
    slip_count <= 3'h0 ;
    bs_finished <= 1'b0 ;
    retry <= 1'b0 ;
end
else begin
       bslip_ack_dom_ch <= bslip_ack ;
    enable <= 1'b1 ;
       if (enable == 1'b1) begin
           if (clk_iserdes_data != 7'b1100001) begin flag1 <= 1'b1 ; end else begin flag1 <= 1'b0 ; end
           if (clk_iserdes_data != 7'b1100011) begin flag2 <= 1'b1 ; end else begin flag2 <= 1'b0 ; end
           if (bsstate == 0) begin
               if (flag1 == 1'b1 && flag2 == 1'b1) begin
                    bslipreq <= 1'b1 ;                    // bitslip needed
                    bsstate <= 1 ;
               end
               else begin
                    bs_finished <= 1'b1 ;                    // bitslip done
               end
           end
           else if (bsstate == 1) begin                        // wait for bitslip ack from other clock domain
                if (bslip_ack_dom_ch == 1'b1) begin
                    bslipreq <= 1'b0 ;                    // bitslip low
                    bcount <= 4'h0 ;
                    slip_count <= slip_count + 3'h1 ;
                    bsstate <= 2 ;
                end
           end
           else if (bsstate == 2) begin                
                bcount <= bcount + 4'h1 ;
                if (bcount == 4'hF) begin
                    if (slip_count == 3'h5) begin
                        jog <= ~jog ;
                        if (jog == 1'b1) begin
                            retry <= 1'b1 ;
                        end
                    end
                    bsstate <= 0 ;
                end
           end
       end
    end
end

always @ (posedge rxclk_d4)
begin
    not_bs_finished_dom_ch <= ~bs_finished ;
    bslipr_dom_ch <= bslipreq ;
    if (locked_out == 1'b0) begin
        bslip <= 1'b0 ;
        bslip_ack <= 1'b0 ;
        bstate <= 0 ;    
    end    
    else if (bstate == 0 && bslipr_dom_ch == 1'b1) begin
        bslip <= 1'b1 ;
        bslip_ack <= 1'b1 ;
        bstate <= 1 ;
    end
    else if (bstate == 1) begin
        bslip <= 1'b0 ;
        bslip_ack <= 1'b1 ;
        bstate <= 2 ;
    end
    else if (bstate == 2 && bslipr_dom_ch == 1'b0) begin
        bslip_ack <= 1'b0 ;
        bstate <= 0 ;
    end        
end

// Clock input 

IBUFGDS #(
    .DIFF_TERM         (DIFF_TERM),
    .IBUF_LOW_PWR        ("FALSE")) 
iob_clk_in (
    .I                (clkin_p),
    .IB               (clkin_n),
    .O                 (rx_clk_in));

genvar i ;
genvar j ;

IDELAYE2 #(
    .REFCLK_FREQUENCY    (REF_FREQ),
    .HIGH_PERFORMANCE_MODE     (HIGH_PERFORMANCE_MODE),
          .IDELAY_VALUE        (1),
          .DELAY_SRC        ("IDATAIN"),
          .IDELAY_TYPE        ("VAR_LOAD"))
    idelay_cm(                   
    .DATAOUT      (rx_clk_in_d),
    .C            (rxclk_d4),
    .CE           (1'b0),
    .INC          (1'b0),
    .DATAIN       (1'b0),
    .IDATAIN      (rx_clk_in),
    .LD           (1'b1),
    .LDPIPEEN     (1'b0),
    .REGRST       (1'b0),
    .CINVCTRL     (1'b0),
    .CNTVALUEIN   (c_delay_in),
    .CNTVALUEOUT  ());
    
ISERDESE2 #(
    .DATA_WIDTH     (4),                 
    .DATA_RATE      ("DDR"),             
    .SERDES_MODE    ("MASTER"),             
    .IOBDELAY       ("IFD"),             
    .INTERFACE_TYPE ("NETWORKING"))         
    iserdes_cm (
    .D             (1'b0),
    .DDLY          (rx_clk_in_d),
    .CE1           (1'b1),
    .CE2           (1'b1),
    .CLK           (rxclk),
    .CLKB          (~rxclk),
    .RST           (local_reset_dom_ch),
    .CLKDIV        (rxclk_d4),
    .CLKDIVP       (1'b0),
    .OCLK          (1'b0),
    .OCLKB         (1'b0),
    .DYNCLKSEL     (1'b0),
    .DYNCLKDIVSEL  (1'b0),
    .SHIFTIN1      (1'b0),
    .SHIFTIN2      (1'b0),
    .BITSLIP       (bslip),
    .O          (),
    .Q8         (),
    .Q7         (),
    .Q6         (),
    .Q5         (),
    .Q4         (cdataout[0]),
    .Q3         (cdataout[1]),
    .Q2         (cdataout[2]),
    .Q1         (cdataout[3]),
    .OFB        (),
    .SHIFTOUT1  (),
    .SHIFTOUT2  ());    

always @ (posedge pixel_clk) begin                            // retiming
    clk_iserdes_data_d <= clk_iserdes_data ;
    if ((clk_iserdes_data != clk_iserdes_data_d) && (clk_iserdes_data != 7'h00) && (clk_iserdes_data != 7'h7F)) begin
        data_different <= 1'b1 ;
    end
    else begin
        data_different <= 1'b0 ;
    end
    if ((clk_iserdes_data == 7'h00) || (clk_iserdes_data == 7'h7F)) begin
        no_clock <= 1'b1 ;
    end
    else begin
        no_clock <= 1'b0 ;
    end
end
    
always @ (posedge rxclk_d4) begin                        // clock delay shift state machine
    if (local_reset_dom_ch == 1'b1) begin
        scount <= 6'h00 ;
        state2 <= 0 ;
        state2_count <= 4'h0 ;
        locked_out <= 1'b0 ;
        chfoundc <= 1'b1 ;
        c_delay_in <= bt_val ;                        // Start the delay line at the current bit period
        c_loop_cnt <= 2'b00 ;    
    end
    else begin
        if (scount[5] == 1'b0) begin
            if (no_clock_dom_ch == 1'b0) begin
                scount <= scount + 6'h01 ;
            end
            else begin
                scount <= 6'h00 ;
            end
        end
        state2_count <= state2_count + 4'h1 ;
        data_different_dom_ch <= data_different ;
        no_clock_dom_ch <= no_clock ;
        if (chfoundc == 1'b1) begin
            chfound <= 1'b0 ;
        end
        else if (chfound == 1'b0 && data_different_dom_ch == 1'b1) begin
            chfound <= 1'b1 ;
        end
        if ((state2_count == 4'hF && scount[5] == 1'b1)) begin
            case(state2)                     
            0    : begin                            // decrement delay and look for a change
                  if (chfound == 1'b1 || (c_loop_cnt == 2'b11 && c_delay_in == 5'h00)) begin  // quit loop if we've been around a few times
                    chfoundc <= 1'b1 ;                // change found
                    state2 <= 1 ;
                  end
                  else begin
                    chfoundc <= 1'b0 ;
                    if (c_delay_in != 5'h00) begin            // check for underflow
                        c_delay_in <= c_delay_in - 5'h01 ;
                    end
                    else begin
                        c_delay_in <= bt_val ;
                        c_loop_cnt <= c_loop_cnt + 2'b01 ;
                    end
                  end
                  end
            1    : begin                            // add half a bit period using input information
                  state2 <= 2 ;
                  if (c_delay_in < {1'b0, bt_val[4:1]}) begin        // choose the lowest delay value to minimise jitter
                       c_delay_in <= c_delay_in + {1'b0, bt_val[4:1]} ;
                  end
                  else begin
                       c_delay_in <= c_delay_in - {1'b0, bt_val[4:1]} ;
                  end
                  end
            default    : begin                            // issue locked out signal
                  locked_out <= 1'b1 ;
                   end
            endcase
        end
    end
end
    
generate for (i = 0 ; i <= D-1 ; i = i+1)
begin : loop3
delay_controller_wrap
 # (.S (4))
    dc_inst (                       
    .m_datain        (mdataout[4*i+3:4*i]),
    .s_datain        (sdataout[4*i+3:4*i]),
    .enable_phase_detector (enable_phase_detector),
    .enable_monitor        (enable_monitor),
    .reset          (not_bs_finished_dom_ch),
    .clk            (rxclk_d4),
    .c_delay_in     (c_delay_in),
    .m_delay_out    (m_delay_val_in[5*i+4:5*i]),
    .s_delay_out    (s_delay_val_in[5*i+4:5*i]),
    .data_out       (mdataoutd[4*i+3:4*i]),
    .bt_val         (bt_val),
    .del_mech       (del_mech), 
    .results        (eye_info[32*i+31:32*i]),
    .m_delay_1hot   (m_delay_1hot[32*i+31:32*i])) ;
end
endgenerate 

always @ (posedge rxclk_d4) begin                            // clock balancing
    if (enable_phase_detector == 1'b1) begin
        cdataouta[3:0] <= cdataout[3:0] ;
        cdataoutb[3:0] <= cdataouta[3:0] ;
        cdataoutc[3:0] <= cdataoutb[3:0] ;
    end
    else begin
        cdataoutc[3:0] <= cdataout[3:0] ;
    end
end

// Data gearbox (includes clock data)

gearbox_4_to_7_slave # (
    .D             (D+1))         
gb0 (                           
    .input_clock    (rxclk_d4),
    .output_clock   (pixel_clk),
    .datain         ({cdataoutc, mdataoutd}),
    .reset          (gb_rst_in),
    .jog            (jog),
    .dataout        ({clk_iserdes_data, dataout})) ;
    
// Data bit Receivers 

generate for (i = 0 ; i <= D-1 ; i = i+1) begin : loop0
for (j = 0 ; j <= 6 ; j = j+1) begin : loop1            // Assign data bits to correct serdes according to required format
    if (DATA_FORMAT == "PER_CLOCK") begin
        assign rx_data[D*j+i] = dataout[7*i+j] ;
    end 
    else begin
        assign rx_data[7*i+j] = dataout[7*i+j] ;
    end
end

IBUFDS_DIFF_OUT #(
    .DIFF_TERM    (DIFF_TERM), 
    .IBUF_LOW_PWR ("FALSE")) 
data_in (
    .I             (datain_p[i]),
    .IB            (datain_n[i]),
    .O             (rx_data_in_p[i]),
    .OB            (rx_data_in_n[i]));

assign rx_data_in_m[i] = rx_data_in_p[i]  ^ RX_SWAP_MASK[i] ;
assign rx_data_in_s[i] = ~rx_data_in_n[i] ^ RX_SWAP_MASK[i] ;

IDELAYE2 #(
    .REFCLK_FREQUENCY      (REF_FREQ),
    .HIGH_PERFORMANCE_MODE (HIGH_PERFORMANCE_MODE),
          .IDELAY_VALUE    (0),
          .DELAY_SRC       ("IDATAIN"),
          .IDELAY_TYPE     ("VAR_LOAD"))
    idelay_m(                   
    .DATAOUT      (rx_data_in_md[i]),
    .C            (rxclk_d4),
    .CE           (1'b0),
    .INC          (1'b0),
    .DATAIN       (1'b0),
    .IDATAIN      (rx_data_in_m[i]),
    .LD           (1'b1),
    .LDPIPEEN     (1'b0),
    .REGRST       (1'b0),
    .CINVCTRL     (1'b0),
    .CNTVALUEIN   (m_delay_val_in[5*i+4:5*i]),
    .CNTVALUEOUT  ());
        
ISERDESE2 #(
    .DATA_WIDTH     (4),             
    .DATA_RATE      ("DDR"),         
    .SERDES_MODE    ("MASTER"),         
    .IOBDELAY       ("IFD"),         
    .INTERFACE_TYPE ("NETWORKING"))     
    iserdes_m (
    .D               (1'b0),
    .DDLY            (rx_data_in_md[i]),
    .CE1             (1'b1),
    .CE2             (1'b1),
    .CLK             (rxclk),
    .CLKB            (~rxclk),
    .RST             (rst_iserdes),
    .CLKDIV          (rxclk_d4),
    .CLKDIVP         (1'b0),
    .OCLK            (1'b0),
    .OCLKB           (1'b0),
    .DYNCLKSEL       (1'b0),
    .DYNCLKDIVSEL    (1'b0),
    .SHIFTIN1        (1'b0),
    .SHIFTIN2        (1'b0),
    .BITSLIP         (bslip),
    .O               (),
    .Q8              (),
    .Q7              (),
    .Q6              (),
    .Q5              (),
    .Q4              (mdataout[4*i+0]),
    .Q3              (mdataout[4*i+1]),
    .Q2              (mdataout[4*i+2]),
    .Q1              (mdataout[4*i+3]),
    .OFB             (),
    .SHIFTOUT1       (),
    .SHIFTOUT2       ());

IDELAYE2 #(
    .REFCLK_FREQUENCY      (REF_FREQ),
    .HIGH_PERFORMANCE_MODE (HIGH_PERFORMANCE_MODE),
          .IDELAY_VALUE    (0),
          .DELAY_SRC       ("IDATAIN"),
          .IDELAY_TYPE     ("VAR_LOAD"))
    idelay_s(                   
    .DATAOUT      (rx_data_in_sd[i]),
    .C            (rxclk_d4),
    .CE           (1'b0),
    .INC          (1'b0),
    .DATAIN       (1'b0),
    .IDATAIN      (rx_data_in_s[i]),
    .LD           (1'b1),
    .LDPIPEEN     (1'b0),
    .REGRST       (1'b0),
    .CINVCTRL     (1'b0),
    .CNTVALUEIN   (s_delay_val_in[5*i+4:5*i]),
    .CNTVALUEOUT  ());
    
ISERDESE2 #(
    .DATA_WIDTH      (4),             
    .DATA_RATE       ("DDR"),         
//    .SERDES_MODE   ("SLAVE"),         
    .IOBDELAY        ("IFD"),         
    .INTERFACE_TYPE  ("NETWORKING"))     
    iserdes_s (
    .D               (1'b0),
    .DDLY            (rx_data_in_sd[i]),
    .CE1             (1'b1),
    .CE2             (1'b1),
    .CLK             (rxclk),
    .CLKB            (~rxclk),
    .RST             (rst_iserdes),
    .CLKDIV          (rxclk_d4),
    .CLKDIVP         (1'b0),
    .OCLK            (1'b0),
    .OCLKB           (1'b0),
    .DYNCLKSEL       (1'b0),
    .DYNCLKDIVSEL    (1'b0),
    .SHIFTIN1        (1'b0),
    .SHIFTIN2        (1'b0),
    .BITSLIP         (bslip),
    .O               (),
    .Q8              (),
    .Q7              (),
    .Q6              (),
    .Q5              (),
    .Q4              (sdataout[4*i+0]),
    .Q3              (sdataout[4*i+1]),
    .Q2              (sdataout[4*i+2]),
    .Q1              (sdataout[4*i+3]),
    .OFB             (),
    .SHIFTOUT1       (),
    .SHIFTOUT2       ());  
end
endgenerate


endmodule

//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2012-2015 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
//////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.2
//  \   \        Filename: gearbox_4_to_7_slave.v
//  /   /        Date Last Modified:  21JAN2015
// /___/   /\    Date Created: 30SEP2010
// \   \  /  \
//  \___\/\___\
// 
//Device: 	7 Series
//Purpose:  	multiple 4 to 7 bit gearbox
//
//Reference:	XAPP585
//    
//Revision History:
//    Rev 1.0 - First created (nicks)
//    Rev 1.2 - Updated format (brandond)
//////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps
module gearbox_4_to_7_slave (input_clock, output_clock, datain, reset, jog, dataout) ;

parameter integer 		D = 8 ;   		// Parameter to set the number of data lines  

input				input_clock ;		// high speed clock input
input				output_clock ;		// low speed clock input
input		[D*4-1:0]	datain ;		// data inputs
input		[1:0]		reset ;			// Reset line
input				jog ;			// jog input, slips by 4 bits
output	reg	[D*7-1:0]	dataout ;		// data outputs
					
reg	[3:0]		read_addra ;			
reg	[3:0]		read_addrb ;			
reg	[3:0]		read_addrc ;			
reg	[3:0]		write_addr ;			
wire	[D*4-1:0]	ramouta ; 			
wire	[D*4-1:0]	ramoutb ;			
wire	[D*4-1:0]	ramoutc ;			
reg	[1:0]		mux ;		
wire	[D*4-1:0]	dummy ;			
reg			jog_int ;	

genvar i ;

always @ (posedge input_clock) begin				// Gearbox input - 4 bit data at input clock frequency
	if (reset[0] == 1'b1) begin
		write_addr <= 4'h0 ;
	end 
	else begin
		if (write_addr == 4'hD) begin
			write_addr <= 4'h0 ;
		end 
		else begin
			write_addr <= write_addr + 4'h1 ;
		end
	end
end

always @ (posedge output_clock) begin				// Gearbox output - 10 bit data at output clock frequency
	if (reset[1] == 1'b1) begin
		read_addra <= 4'h0 ;
		read_addrb <= 4'h1 ;
		read_addrc <= 4'h2 ;
		jog_int <= 1'b0 ;
	end
	else begin
		case (jog_int)
		1'b0 : begin
			case (read_addra)
			4'h0    : begin read_addra <= 4'h1 ; read_addrb <= 4'h2 ; read_addrc <= 4'h3 ; mux <= 2'h1 ; end
			4'h1    : begin read_addra <= 4'h3 ; read_addrb <= 4'h4 ; read_addrc <= 4'h5 ; mux <= 2'h2 ; end
			4'h3    : begin read_addra <= 4'h5 ; read_addrb <= 4'h6 ; read_addrc <= 4'h7 ; mux <= 2'h3 ; end
			4'h5    : begin read_addra <= 4'h7 ; read_addrb <= 4'h8 ; read_addrc <= 4'h9 ; mux <= 2'h0 ; end
			4'h7    : begin read_addra <= 4'h8 ; read_addrb <= 4'h9 ; read_addrc <= 4'hA ; mux <= 2'h1 ; end
			4'h8    : begin read_addra <= 4'hA ; read_addrb <= 4'hB ; read_addrc <= 4'hC ; mux <= 2'h2 ; end
			4'hA    : begin read_addra <= 4'hC ; read_addrb <= 4'hD ; read_addrc <= 4'hD ; mux <= 2'h3 ; jog_int <= jog ; end
			default : begin read_addra <= 4'h0 ; read_addrb <= 4'h1 ; read_addrc <= 4'h2 ; mux <= 2'h0 ; end
			endcase 
		end
		1'b1 : begin
			case (read_addra)
			4'h1    : begin read_addra <= 4'h2 ; read_addrb <= 4'h3 ; read_addrc <= 4'h4 ; mux <= 2'h1 ; end
			4'h2    : begin read_addra <= 4'h4 ; read_addrb <= 4'h5 ; read_addrc <= 4'h6 ; mux <= 2'h2 ; end
			4'h4    : begin read_addra <= 4'h6 ; read_addrb <= 4'h7 ; read_addrc <= 4'h8 ; mux <= 2'h3 ; end
			4'h6    : begin read_addra <= 4'h8 ; read_addrb <= 4'h9 ; read_addrc <= 4'hA ; mux <= 2'h0 ; end
			4'h8    : begin read_addra <= 4'h9 ; read_addrb <= 4'hA ; read_addrc <= 4'hB ; mux <= 2'h1 ; end
			4'h9    : begin read_addra <= 4'hB ; read_addrb <= 4'hC ; read_addrc <= 4'hD ; mux <= 2'h2 ; end
			4'hB    : begin read_addra <= 4'hD ; read_addrb <= 4'h0 ; read_addrc <= 4'h1 ; mux <= 2'h3 ; jog_int <= jog ; end
			default : begin read_addra <= 4'h1 ; read_addrb <= 4'h2 ; read_addrc <= 4'h3 ; mux <= 2'h0 ; end
			endcase 
		end
		endcase
	end
end

generate for (i = 0 ; i <= D-1 ; i = i+1) begin : loop0
always @ (posedge output_clock) begin
	case (mux)
	2'h0    : dataout[7*i+6:7*i] <= {                      ramoutb[4*i+2:4*i+0], ramouta[4*i+3:4*i+0]} ;
	2'h1    : dataout[7*i+6:7*i] <= {ramoutc[4*i+1:4*i+0], ramoutb[4*i+3:4*i+0], ramouta[4*i+3]} ;    
	2'h2    : dataout[7*i+6:7*i] <= {ramoutc[4*i+0],       ramoutb[4*i+3:4*i+0], ramouta[4*i+3:4*i+2]} ; 
	default : dataout[7*i+6:7*i] <= {                      ramoutb[4*i+3:4*i+0], ramouta[4*i+3:4*i+1]} ; 
	endcase 
end 
end
endgenerate 
			     	
// Data gearboxes

generate for (i = 0 ; i <= D*2-1 ; i = i+1) begin : loop2

RAM32M ram_inst ( 
	.DOA	(ramouta[2*i+1:2*i]), 
	.DOB	(ramoutb[2*i+1:2*i]),
	.DOC    (ramoutc[2*i+1:2*i]), 
	.DOD    (dummy[2*i+1:2*i]),
	.ADDRA	({1'b0, read_addra}), 
	.ADDRB	({1'b0, read_addrb}), 
	.ADDRC  ({1'b0, read_addrc}), 
	.ADDRD  ({1'b0, write_addr}),
	.DIA	(datain[2*i+1:2*i]), 
	.DIB	(datain[2*i+1:2*i]),
	.DIC    (datain[2*i+1:2*i]),
	.DID    (dummy[2*i+1:2*i]),
	.WE 	(1'b1), 
	.WCLK	(input_clock));
end
endgenerate 


endmodule



