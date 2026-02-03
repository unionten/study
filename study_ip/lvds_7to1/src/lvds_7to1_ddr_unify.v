
`define REVERSE_OUTGEN(data_in,data_out,BYTE_NUM,BITS_PER_BYTE)                                         generate for(i=0;i<BYTE_NUM;i=i+1)begin assign data_out[i*BITS_PER_BYTE+:BITS_PER_BYTE] = data_in[(BYTE_NUM-1-i)*BITS_PER_BYTE+:BITS_PER_BYTE]; end  endgenerate


//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2012-2015 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
//////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.2
//  \   \        Filename: top5x2_7to1_ddr_tx.v
//  /   /        Date Last Modified:  21JAN2015
// /___/   /\    Date Created: 2SEP2011
// \   \  /  \
//  \___\/\___\
// 
//Device:     7-Series
//Purpose:      DDR top level transmitter example - 2 channels of 5-bits each
//
//Reference:    XAPP585.pdf
//    
//Revision History:
//    Rev 1.0 - First created (nicks)
//    Rev 1.2 - Updated format (brandond)
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////


`timescale 1ps/1ps

module lvds_7to1_ddr_unify #(
        parameter PORT_NUM = 4,
        parameter LANE_NUM = 4 //fixed
)(
   input                           ref_pixel_clk  ,
   input                           resetn         ,   
   
   output                           tx_pixel_clk ,
   output                           tx_pixel_clk_locked,
   input [LANE_NUM*PORT_NUM*7-1:0]  tx_lvds_data  ,
   
      
   output  [PORT_NUM-1:0]          lvds_clk_p ,
   output  [PORT_NUM-1:0]          lvds_clk_n ,
                                                                                 
   output  [LANE_NUM*PORT_NUM-1:0] lvds_data_p ,
   output  [LANE_NUM*PORT_NUM-1:0] lvds_data_n 
  

 );
 
parameter [6:0] TX_CLK_GEN   = 7'b1100011 ;   
 // Transmit a constant to make a 3:4 clock, two ticks in advance of bit0 of the data word


genvar i,j,k;


wire        txclk ;            
wire        txclk_div ;            
wire        not_tx_mmcm_lckd ;    

wire        tx_mmcm_lckd ;

assign not_tx_mmcm_lckd = ~tx_mmcm_lckd ; 
// Clock Input
assign tx_pixel_clk_locked  = tx_mmcm_lckd;

wire                            almost_empty; 
wire [LANE_NUM*PORT_NUM*7-1:0]   rx_data;   
   
wire  [LANE_NUM*PORT_NUM*7-1:0]  rxlvds_data_reverse ;
`REVERSE_OUTGEN(tx_lvds_data,rxlvds_data_reverse,PORT_NUM,28)  
  
  
clock_generator_pll_7_to_1_diff_ddr #(
    .DIFF_TERM         ("TRUE"),
    .PIXEL_CLOCK       ("BUF_G"),
    .INTER_CLOCK       ("BUF_G"),
    .TX_CLOCK          ("BUF_G"),
    .USE_PLL           ("FALSE"),
    .MMCM_MODE         (1),// Parameter to set multiplier for MMCM to get VCO in correct operating range. 1 multiplies input clock by 7, 2 multiplies clock by 14, etc
    .CLKIN_PERIOD      (6.734))
clkgen (                        
    .reset              (~resetn),
    .ref_pixel_clk       (ref_pixel_clk),
    .clk_sel            (0),
    .txclk              (txclk),        //x3.5 ( x7  d2)
    .txclk_div          (txclk_div),    //d2
    .pixel_clk          (tx_pixel_clk), //x1
    .status             (),
    .mmcm_lckd          (tx_mmcm_lckd)) ;
   

n_x_serdes_7_to_1_diff_ddr #(
     .D       (LANE_NUM),
     .N       (PORT_NUM),
     .DATA_FORMAT("PER_CLOCK")) // PER_CLOCK or PER_CHANL data formatting
dataout (                      
    .dataout_p        (lvds_data_p),
    .dataout_n        (lvds_data_n),
    .clkout_p         (lvds_clk_p),
    .clkout_n         (lvds_clk_n),
    .txclk            (txclk),       //x3.5  ____|—|_|—|_|—|_|—|_|—|_|—|_
    .txclk_div        (txclk_div),   //d2    ____|——————————————|___________|——————————
    .pixel_clk        (tx_pixel_clk),//x1    ____|————————|______|——————————
    .reset            (not_tx_mmcm_lckd),
    .clk_pattern      (TX_CLK_GEN),            // Transmit a constant to make the clock
    //.datain           ({tx_lvds_data[27:0],tx_lvds_data[55:28],tx_lvds_data[83:56],tx_lvds_data[111:84]})
    .datain           (rxlvds_data_reverse )
    
    
  );   

      
endmodule



///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2012-2015 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.2
//  \   \        Filename: clock_generator_pll_7_to_1_diff_ddr.v
//  /   /        Date Last Modified:  21JAN2015
// /___/   /\    Date Created: 5JAN2010
// \   \  /  \
//  \___\/\___\
// 
//Device:     7 Series
//Purpose:      DDR MMCM or PLL based clock generator. Takes in a differential clock and multiplies it
//            appropriately 
//Reference:    XAPP585
//    
//Revision History:
//    Rev 1.0 - First created (nicks)
//    Rev 1.1 - Some net names changed to make more sense in Vivado
//    Rev 1.2 - Updated format (brandond)
//////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

module clock_generator_pll_7_to_1_diff_ddr (ref_pixel_clk, clk_sel,txclk, reset, pixel_clk, txclk_div, mmcm_lckd, status) ;

parameter real      CLKIN_PERIOD = 6.000 ;    // clock period (ns) of input clock on clkin_p
parameter           DIFF_TERM = "FALSE" ;     // Parameter to enable internal differential termination
parameter integer   MMCM_MODE = 1 ;           // Parameter to set multiplier for MMCM to get VCO in correct operating range. 1 multiplies input clock by 7, 2 multiplies clock by 14, etc
parameter           TX_CLOCK = "BUFIO" ;      // Parameter to set transmission clock buffer type, BUFIO, BUF_H, BUF_G
parameter           INTER_CLOCK = "BUF_R" ;   // Parameter to set intermediate clock buffer type, BUFR, BUF_H, BUF_G
parameter           PIXEL_CLOCK = "BUF_G" ;   // Parameter to set final clock buffer type, BUF_R, BUF_H, BUF_G
parameter           USE_PLL = "FALSE" ;       // Parameter to enable PLL use rather than MMCM use, note, PLL does not support BUFIO and BUFR

input               reset ;               // reset (active high)
//input            clkin_p, clkin_n ;     // differential clock inputs

input            ref_pixel_clk;
input            clk_sel;
output           txclk ;            // CLK for serdes
output           pixel_clk ;        // Pixel clock output
output           txclk_div ;        // CLKDIV for serdes, and gearbox output = pixel clock / 2
output           mmcm_lckd ;        // Locked output from BUFPLL
output   [6:0]   status ;           // clock status
                    
wire            clkint ;            // clock input from pin
wire            txpllmmcm_x1 ;      // pll generated x1 clock
wire            txpllmmcm_xn ;      // pll generated xn clock

wire txpllmmcm_pixel;
wire clkbf_in;
wire rx_pixel_clk_bufr;


IBUFGDS #(
    .DIFF_TERM        (DIFF_TERM)) 
clk_iob_in (
    .I                (clkin_p),
    .IB               (clkin_n),
    .O                (clkint));

generate
if (USE_PLL == "FALSE") begin : loop8                // use an MMCM
assign status[6] = 1'b1 ; 
     
MMCME2_ADV #(
      .BANDWIDTH            ("OPTIMIZED"),          
      .CLKFBOUT_MULT_F      (7*MMCM_MODE),               
      .CLKFBOUT_PHASE       (0.0),                 
      .CLKIN1_PERIOD        (CLKIN_PERIOD),          
      .CLKIN2_PERIOD        (CLKIN_PERIOD),          
      .CLKOUT0_DIVIDE_F     (2*MMCM_MODE),               
      .CLKOUT0_DUTY_CYCLE   (0.5),                 
      .CLKOUT0_PHASE        (0.0),                 
      .CLKOUT1_DIVIDE       (14*MMCM_MODE),           
      .CLKOUT1_DUTY_CYCLE   (0.5),                 
      .CLKOUT1_PHASE        (0.0),                 
      .CLKOUT2_DIVIDE       (7*MMCM_MODE),           
      .CLKOUT2_DUTY_CYCLE   (0.5),                 
      .CLKOUT2_PHASE        (0.0),                 
      .CLKOUT3_DIVIDE       (8),                   
      .CLKOUT3_DUTY_CYCLE   (0.5),                 
      .CLKOUT3_PHASE        (0.0),                 
      .CLKOUT4_DIVIDE       (8),                   
      .CLKOUT4_DUTY_CYCLE   (0.5),                 
      .CLKOUT4_PHASE        (0.0),                  
      .CLKOUT5_DIVIDE       (8),                   
      .CLKOUT5_DUTY_CYCLE   (0.5),                 
      .CLKOUT5_PHASE        (0.0),                  
      .COMPENSATION         ("ZHOLD"),             
      .DIVCLK_DIVIDE        (1),                    
      .REF_JITTER1          (0.100))                   
tx_mmcme2_adv_inst (
      .CLKFBOUT         (txpllmmcm_x1),                  
      .CLKFBOUTB        (),                      
      .CLKFBSTOPPED     (),                      
      .CLKINSTOPPED     (),                      
      .CLKOUT0          (txpllmmcm_xn),              
      .CLKOUT0B         (),                  
      .CLKOUT1          (txpllmmcm_d2),              
      .CLKOUT1B         (),                  
      .CLKOUT2          (txpllmmcm_pixel),                 
      .CLKOUT2B         (),                  
      .CLKOUT3          (),                      
      .CLKOUT3B         (),                  
      .CLKOUT4          (),                      
      .CLKOUT5          (),                      
      .CLKOUT6          (),                      
      .DO               (),                            
      .DRDY             (),                          
      .PSDONE           (),  
      .PSCLK            (1'b0),  
      .PSEN             (1'b0),  
      .PSINCDEC         (1'b0),  
      .PWRDWN           (1'b0),  
      .LOCKED           (mmcm_lckd),                
      .CLKFBIN          (pixel_clk),            
      .CLKIN1           (ref_pixel_clk),                 
      .CLKIN2           (ref_pixel_clk),                     
      .CLKINSEL         (clk_sel),                     
      .DADDR            (7'h00),                    
      .DCLK             (1'b0),                       
      .DEN              (1'b0),                        
      .DI               (16'h0000),                
      .DWE              (1'b0),                        
      .RST              (reset)) ;                   


 //BUFG    pixel_clk_inst (.I(txpllmmcm_pixel), .O(pixel_clk)) ;
 //BUFR #(.BUFR_DIVIDE("1"),.SIM_DEVICE("7SERIES"))pixel_clk_inst (.I(txpllmmcm_pixel),.CE(1'b1),.O(pixel_clk),.CLR(1'b0)) ;
 //BUFR #(.BUFR_DIVIDE("1"),.SIM_DEVICE("7SERIES"))rx_pixel_clk_inst (.I(ref_pixel_clk),.CE(1'b1),.O(rx_pixel_clk_bufr),.CLR(1'b0)) ;
   
      
   if (PIXEL_CLOCK == "BUF_G") begin                 // Final clock selection
      BUFG    bufg_mmcm_x1 (.I(txpllmmcm_x1), .O(pixel_clk)) ;
      assign status[1:0] = 2'b00 ;
   end
   else if (PIXEL_CLOCK == "BUF_R") begin
      BUFR #(.BUFR_DIVIDE("1"),.SIM_DEVICE("7SERIES"))bufr_mmcm_x1 (.I(txpllmmcm_x1),.CE(1'b1),.O(pixel_clk),.CLR(1'b0)) ;
      assign status[1:0] = 2'b01 ;
   end
   else begin 
      BUFH    bufh_mmcm_x1 (.I(txpllmmcm_x1), .O(pixel_clk)) ;
      assign status[1:0] = 2'b10 ;
   end

   if (INTER_CLOCK == "BUF_G") begin                 // Intermediate clock selection
      BUFG    bufg_mmcm_d2 (.I(txpllmmcm_d2), .O(txclk_div)) ;
      assign status[3:2] = 2'b00 ;
   end
   else if (INTER_CLOCK == "BUF_R") begin
      BUFR #(.BUFR_DIVIDE("1"),.SIM_DEVICE("7SERIES"))bufr_mmcm_d2 (.I(txpllmmcm_d2),.CE(1'b1),.O(txclk_div),.CLR(1'b0)) ;
      assign status[3:2] = 2'b01 ;
   end
   else begin 
      BUFH    bufh_mmcm_d2 (.I(txpllmmcm_d2), .O(txclk_div)) ;
      assign status[3:2] = 2'b10 ;
   end
      
   if (TX_CLOCK == "BUF_G") begin                // Sample clock selection
      BUFG    bufg_mmcm_xn (.I(txpllmmcm_xn), .O(txclk)) ;
      assign status[5:4] = 2'b00 ;
   end
   else if (TX_CLOCK == "BUFIO") begin
      BUFIO      bufio_mmcm_xn (.I (txpllmmcm_xn), .O(txclk)) ;
      assign status[5:4] = 2'b11 ;
   end
   else begin 
      BUFH    bufh_mmcm_xn (.I(txpllmmcm_xn), .O(txclk)) ;
      assign status[5:4] = 2'b10 ;
   end
   
end 
else begin

assign status[6] = 1'b0 ;                     // Use a PLL

PLLE2_ADV #(
      .BANDWIDTH            ("OPTIMIZED"),          
      .CLKFBOUT_MULT        (7*MMCM_MODE),               
      .CLKFBOUT_PHASE       (0.0),                 
      .CLKIN1_PERIOD        (CLKIN_PERIOD),          
      .CLKIN2_PERIOD        (CLKIN_PERIOD),          
      .CLKOUT0_DIVIDE       (2*MMCM_MODE),               
      .CLKOUT0_DUTY_CYCLE   (0.5),                 
      .CLKOUT0_PHASE        (0.0),                 
      .CLKOUT1_DIVIDE       (14*MMCM_MODE),           
      .CLKOUT1_DUTY_CYCLE   (0.5),                 
      .CLKOUT1_PHASE        (0.0),                 
      .CLKOUT2_DIVIDE       (7*MMCM_MODE),           
      .CLKOUT2_DUTY_CYCLE   (0.5),                 
      .CLKOUT2_PHASE        (0.0),                 
      .CLKOUT3_DIVIDE       (8),                   
      .CLKOUT3_DUTY_CYCLE   (0.5),                 
      .CLKOUT3_PHASE        (0.0),                 
      .CLKOUT4_DIVIDE       (8),                   
      .CLKOUT4_DUTY_CYCLE   (0.5),                 
      .CLKOUT4_PHASE        (0.0),                  
      .CLKOUT5_DIVIDE       (8),                   
      .CLKOUT5_DUTY_CYCLE   (0.5),                 
      .CLKOUT5_PHASE        (0.0),                  
      .COMPENSATION         ("ZHOLD"),             
      .DIVCLK_DIVIDE        (1),                    
      .REF_JITTER1          (0.100))                   
tx_mmcme2_adv_inst (
      .CLKFBOUT            (txpllmmcm_x1),                  
      .CLKOUT0             (txpllmmcm_xn),              
      .CLKOUT1             (txpllmmcm_d2),              
      .CLKOUT2             (),                 
      .CLKOUT3             (),                      
      .CLKOUT4             (),                      
      .CLKOUT5             (),                      
      .DO                  (),                            
      .DRDY                (),                          
      .PWRDWN              (1'b0),  
      .LOCKED              (mmcm_lckd),                
      .CLKFBIN             (pixel_clk),            
      .CLKIN1              (clkint),                 
      .CLKIN2              (1'b0),                     
      .CLKINSEL            (1'b1),                     
      .DADDR               (7'h00),                    
      .DCLK                (1'b0),                       
      .DEN                 (1'b0),                        
      .DI                  (16'h0000),                
      .DWE                 (1'b0),                        
      .RST                 (reset)) ;                   

   if (PIXEL_CLOCK == "BUF_G") begin   // Final clock selection
      BUFG    bufg_mmcm_x1 (.I(txpllmmcm_x1), .O(pixel_clk)) ;
      assign status[1:0] = 2'b00 ;
   end
   else if (PIXEL_CLOCK == "BUF_R") begin
      BUFR #(.BUFR_DIVIDE("1"),.SIM_DEVICE("7SERIES"))bufr_mmcm_x1 (.I(txpllmmcm_x1),.CE(1'b1),.O(pixel_clk),.CLR(1'b0)) ;
      assign status[1:0] = 2'b01 ;
   end
   else begin 
      BUFH    bufh_mmcm_x1 (.I(txpllmmcm_x1), .O(pixel_clk)) ;
      assign status[1:0] = 2'b10 ;
   end

   if (INTER_CLOCK == "BUF_G") begin  // Intermediate clock selection
      BUFG    bufg_mmcm_d2 (.I(txpllmmcm_d2), .O(txclk_div)) ;
      assign status[3:2] = 2'b00 ;
   end
   else if (INTER_CLOCK == "BUF_R") begin
      BUFR #(.BUFR_DIVIDE("1"),.SIM_DEVICE("7SERIES"))bufr_mmcm_d2 (.I(txpllmmcm_d2),.CE(1'b1),.O(txclk_div),.CLR(1'b0)) ;
      assign status[3:2] = 2'b01 ;
   end
   else begin 
      BUFH    bufh_mmcm_d2 (.I(txpllmmcm_d2), .O(txclk_div)) ;
      assign status[3:2] = 2'b10 ;
   end
      
   if (TX_CLOCK == "BUF_G") begin    // Sample clock selection
      BUFG    bufg_mmcm_xn (.I(txpllmmcm_xn), .O(txclk)) ;
      assign status[5:4] = 2'b00 ;
   end
   else if (TX_CLOCK == "BUFIO") begin
      BUFIO      bufio_mmcm_xn (.I (txpllmmcm_xn), .O(txclk)) ;
      assign status[5:4] = 2'b11 ;
   end
   else begin 
      BUFH    bufh_mmcm_xn (.I(txpllmmcm_xn), .O(txclk)) ;
      assign status[5:4] = 2'b10 ;
   end
   
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
//  \   \        Filename: n_x_serdes_7_to_1_diff_ddr.v
//  /   /        Date Last Modified:  21JAN2015
// /___/   /\    Date Created: 2SEP2011
// \   \  /  \
//  \___\/\___\
// 
//Device:     7-Series
//Purpose:      N channel wrapper for multiple 7:1 serdes channels
//
//Reference:    XAPP585
//    
//Revision History:
//    Rev 1.0 - First created (nicks)
//    Rev 1.2 - Updated format (brandond)
//////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

module n_x_serdes_7_to_1_diff_ddr (txclk, reset, pixel_clk, txclk_div, datain, clk_pattern, dataout_p, dataout_n, clkout_p, clkout_n) ;

parameter integer   N = 8 ;  // Set the number of channels
parameter integer   D = 6 ;  // Set the number of outputs per channel
parameter           DATA_FORMAT = "PER_CLOCK" ;// Parameter Used to determine method for mapping input parallel word to output serial words
                                           
input     txclk ;                // IO Clock network
input     reset ;                // Reset
input     pixel_clk ;            // clock at pixel rate
input     txclk_div ;            // 1/2 rate clock output for gearbox
input     [(D*N*7)-1:0] datain ;             // Data for output
input     [6:0]        clk_pattern ;         // clock pattern for output
output    [D*N-1:0]    dataout_p ;           // output data
output    [D*N-1:0]    dataout_n ;           // output data
output    [N-1:0]      clkout_p ;            // output clock
output    [N-1:0]      clkout_n ;            // output clock

genvar i ;
genvar j ;

generate
for (i = 0 ; i <= (N-1) ; i = i+1)
begin : loop0

serdes_7_to_1_diff_ddr #(
          .D           (D),
          .DATA_FORMAT (DATA_FORMAT))
dataout (
    .dataout_p       (dataout_p[D*(i+1)-1:D*i]),
    .dataout_n       (dataout_n[D*(i+1)-1:D*i]),
    .clkout_p        (clkout_p[i]),
    .clkout_n        (clkout_n[i]),
    .txclk           (txclk),
    .pixel_clk       (pixel_clk),
    .txclk_div       (txclk_div),
    .reset           (reset),
    .clk_pattern     (clk_pattern),
    .datain          (datain[(D*(i+1)*7)-1:D*i*7]));        
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
//  \   \        Filename: serdes_7_to_1_diff_ddr.v
//  /   /        Date Last Modified:  21JAN2015
// /___/   /\    Date Created: 2SEP2011
// \   \  /  \
//  \___\/\___\
// 
//Device:     7-Series
//Purpose:      DDR D-bit generic 7:1 transmitter module via 14:1 serdes mode
//         Takes in 7*D bits of data and serialises this to D bits
//         data is transmitted LSB first
//        Data formatting is set by the DATA_FORMAT parameter. 
//        PER_CLOCK (default) format transmits bits for 0, 1, 2 ... on the same transmitter clock edge
//        PER_CHANL format transmits bits for 0, 7, 14 .. on the same transmitter clock edge
//        Data inversion can be accomplished via the TX_SWAP_MASK 
//        parameter if required.
//        Also generates clock output
//
//Reference:    XAPP585.pdf
//    
//Revision History:
//    Rev 1.0 - First created (nicks)
//    Rev 1.1 - PER_CLOCK and PER_CHANL descriptions swapped
//    Rev 1.2 - Updated format (brandond)
//////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

module serdes_7_to_1_diff_ddr (txclk, reset, pixel_clk, txclk_div, datain, clk_pattern, dataout_p, dataout_n, clkout_p, clkout_n) ;

parameter integer  D = 16 ;            // Set the number of outputs
parameter          DATA_FORMAT = "PER_CLOCK" ;// Parameter Used to determine method for mapping input parallel word to output serial words
                                            
input     txclk ;                // IO Clock network
input     reset ;                // Reset
input     pixel_clk ;            // clock at pixel rate
input     txclk_div ;            // 1/2 rate clock output for gearbox
input     [(D*7)-1:0]  datain ;  // Data for output
input     [6:0]        clk_pattern ;  // clock pattern for output
output    [D-1:0]      dataout_p ;    // output data
output    [D-1:0]      dataout_n ;    // output data
output             clkout_p ;         // output clock
output             clkout_n ;         // output clock

wire    [D-1:0]       cascade_di ;    
wire    [D-1:0]       cascade_ti ;    
wire    [D-1:0]       tx_data_out ;    
wire    [D*14-1:0]    mdataina ;    
wire    [D*14-1:0]    mdatainb ;    
reg     clockb2 ;
reg     clockb2d_a ;
reg     clockb2d_b ;
reg     sync ;
reg     [D*7-1:0]    holdreg ;    
wire    [14*D-1:0]   dataint ;    
reg                  reset_intr ;
wire    [3:0]        fifo_d0in ;
wire    [3:0]        fifo_d1in ;
wire    [3:0]        fifo_d2in ;
wire    [3:0]        fifo_d3in ;
wire    [3:0]        fifo_d4in ;
wire    [7:0]        fifo_d5in ;
wire    [7:0]        fifo_d6in ;
wire    [3:0]        fifo_d7in ;
wire    [3:0]        fifo_d8in ;
wire    [3:0]        fifo_d9in ;
wire    [7:0]        fifo_d0out ;
wire    [7:0]        fifo_d1out ;
wire    [7:0]        fifo_d2out ;
wire    [7:0]        fifo_d3out ;
wire    [7:0]        fifo_d4out ;
wire    [7:0]        fifo_d5out ;
wire    [7:0]        fifo_d6out ;
wire    [7:0]        fifo_d7out ;
wire    [7:0]        fifo_d8out ;
wire    [7:0]        fifo_d9out ;
reg     fifo_rden ;
reg     fifo_wren ;
reg     fifo_wrend ;
reg     [3:0]        count ;

parameter [D-1:0] TX_SWAP_MASK = 16'h0000 ;        // pinswap mask for output bits (0 = no swap (default), 1 = swap). Allows outputs to be connected the 'wrong way round' to ease PCB routing.

genvar i ;
genvar j ;

initial reset_intr = 1'b1 ;

always @ (posedge txclk_div or posedge reset) begin    // local reset
if (reset == 1'b1) begin
    reset_intr <= 1'b1 ;
    count <= 4'h0 ;
end
else begin
    count <= count + 4'h1 ;
    if (count == 4'hF) begin
        reset_intr <= 1'b0 ;
    end
end
end

// Timing generator

always @ (posedge txclk_div) begin
if (reset == 1'b1) begin
    clockb2 <= 1'b0 ;
end
else begin
    clockb2 <= ~clockb2 ;
end
end

always @ (posedge pixel_clk) begin
    clockb2d_a <= clockb2 ;
    clockb2d_b <= clockb2d_a ;
    sync <= clockb2d_a ^ clockb2d_b ;
    if (sync == 1'b1) begin
        holdreg <= datain ;
    end
end

assign dataint = {datain, holdreg} ;

generate
for (i = 0 ; i <= (D-1) ; i = i+1) begin : loop0

OBUFDS io_data_out (
    .O          (dataout_p[i]),
    .OB         (dataout_n[i]),
    .I          (tx_data_out[i]));

// re-arrange data bits for transmission and invert lines as given by the mask
// NOTE If pin inversion is required (non-zero SWAP MASK) then inverters will occur in fabric, as there are no inverters in the OSERDESE2
// This can be avoided by doing the inversion (if necessary) in the user logic
// TX_SWAP_MASK not available when IN_FIFO is used

for (j = 0 ; j <= 13 ; j = j+1) begin : loop1
    if (DATA_FORMAT == "PER_CLOCK") begin
        assign mdataina[14*i+j] = dataint[D*j+i] ^ TX_SWAP_MASK[i] ;
    end
    else begin
        if (j < 7) begin
            assign mdataina[14*i+j] = dataint[(7*i)+j] ^ TX_SWAP_MASK[i] ;
        end
        else begin
            assign mdataina[14*i+j] = dataint[(7*i)+j-7+D*7] ^ TX_SWAP_MASK[i];
        end
    end
end

OSERDESE2 #(
    .DATA_WIDTH         (14),            // SERDES word width
    .TRISTATE_WIDTH     (1), 
    .DATA_RATE_OQ       ("DDR"),         // <SDR>, DDR
    .DATA_RATE_TQ       ("SDR"),         // <SDR>, DDR
    .SERDES_MODE        ("MASTER"))      // <DEFAULT>, MASTER, SLAVE
oserdes_m (
    .OQ              (tx_data_out[i]),
    .OCE             (1'b1),
    .CLK             (txclk),
    .RST             (reset_intr),
    .CLKDIV          (txclk_div),
    .D8              (mdataina[(14*i)+7]),
    .D7              (mdataina[(14*i)+6]),
    .D6              (mdataina[(14*i)+5]),
    .D5              (mdataina[(14*i)+4]),
    .D4              (mdataina[(14*i)+3]),
    .D3              (mdataina[(14*i)+2]),
    .D2              (mdataina[(14*i)+1]),
    .D1              (mdataina[(14*i)+0]),
    .TQ              (),
    .T1              (1'b0),
    .T2              (1'b0),
    .T3              (1'b0),
    .T4              (1'b0),
    .TCE             (1'b1),
    .TBYTEIN         (1'b0),
    .TBYTEOUT        (),
    .OFB             (),
    .TFB             (),
    .SHIFTOUT1       (),            
    .SHIFTOUT2       (),            
    .SHIFTIN1        (cascade_di[i]),    
    .SHIFTIN2        (cascade_ti[i])) ;    

OSERDESE2 #(
    .DATA_WIDTH         (14),            // SERDES word width.
    .TRISTATE_WIDTH     (1), 
    .DATA_RATE_OQ       ("DDR"),         // <SDR>, DDR
    .DATA_RATE_TQ       ("SDR"),         // <SDR>, DDR
    .SERDES_MODE        ("SLAVE"))       // <DEFAULT>, MASTER, SLAVE
oserdes_s (
    .OQ              (),
    .OCE             (1'b1),
    .CLK             (txclk),
    .RST             (reset_intr),
    .CLKDIV          (txclk_div),
    .D8              (mdataina[(14*i)+13]),
    .D7              (mdataina[(14*i)+12]),
    .D6              (mdataina[(14*i)+11]),
    .D5              (mdataina[(14*i)+10]),
    .D4              (mdataina[(14*i)+9]),
    .D3              (mdataina[(14*i)+8]),
    .D2              (1'b0),
    .D1              (1'b0),
    .TQ              (),
    .T1              (1'b0),
    .T2              (1'b0),
    .T3              (1'b0),
    .T4              (1'b0),
    .TCE             (1'b1),
    .TBYTEIN         (1'b0),
    .TBYTEOUT        (),
    .OFB             (),
    .TFB             (),
    .SHIFTOUT1       (cascade_di[i]),    
    .SHIFTOUT2       (cascade_ti[i]),    
    .SHIFTIN1        (1'b0),            
    .SHIFTIN2        (1'b0)) ;            

end
endgenerate

OBUFDS io_clk_out (
    .O            (clkout_p),
    .OB           (clkout_n),
    .I            (tx_clk_out));

OSERDESE2 #(
    .DATA_WIDTH         (14),            // SERDES word width
    .TRISTATE_WIDTH     (1), 
    .DATA_RATE_OQ       ("DDR"),         // <SDR>, DDR
    .DATA_RATE_TQ       ("SDR"),         // <SDR>, DDR
    .SERDES_MODE        ("MASTER"))      // <DEFAULT>, MASTER, SLAVE
oserdes_cm (
    .OQ              (tx_clk_out),
    .OCE             (1'b1),
    .CLK             (txclk),
    .RST             (reset_intr),
    .CLKDIV          (txclk_div),
    .D8              (clk_pattern[0]),
    .D7              (clk_pattern[6]),
    .D6              (clk_pattern[5]),
    .D5              (clk_pattern[4]),
    .D4              (clk_pattern[3]),
    .D3              (clk_pattern[2]),
    .D2              (clk_pattern[1]),
    .D1              (clk_pattern[0]),
    .TQ              (),
    .T1              (1'b0),
    .T2              (1'b0),
    .T3              (1'b0),
    .T4              (1'b0),
    .TCE             (1'b1),
    .TBYTEIN         (1'b0),
    .TBYTEOUT        (),
    .OFB             (),
    .TFB             (),
    .SHIFTOUT1       (),            
    .SHIFTOUT2       (),            
    .SHIFTIN1        (cascade_cdi),    
    .SHIFTIN2        (cascade_cti)) ;    

OSERDESE2 #(
    .DATA_WIDTH         (14),          // SERDES word width.
    .TRISTATE_WIDTH     (1), 
    .DATA_RATE_OQ       ("DDR"),       // <SDR>, DDR
    .DATA_RATE_TQ       ("SDR"),       // <SDR>, DDR
    .SERDES_MODE        ("SLAVE"))     // <DEFAULT>, MASTER, SLAVE
oserdes_cs (
    .OQ              (),
    .OCE             (1'b1),
    .CLK             (txclk),
    .RST             (reset_intr),
    .CLKDIV          (txclk_div),
    .D8              (clk_pattern[6]),
    .D7              (clk_pattern[5]),
    .D6              (clk_pattern[4]),
    .D5              (clk_pattern[3]),
    .D4              (clk_pattern[2]),
    .D3              (clk_pattern[1]),
    .D2              (1'b0),
    .D1              (1'b0),
    .TQ              (),
    .T1              (1'b0),
    .T2              (1'b0),
    .T3              (1'b0),
    .T4              (1'b0),
    .TCE             (1'b1),
    .TBYTEIN         (1'b0),
    .TBYTEOUT        (),
    .OFB             (),
    .TFB             (),
    .SHIFTOUT1       (cascade_cdi),    
    .SHIFTOUT2       (cascade_cti),    
    .SHIFTIN1        (1'b0),            
    .SHIFTIN2        (1'b0)) ;
        
endmodule
