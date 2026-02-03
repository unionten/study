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
module lvds_7to1_ddr_unify_image_gen #(
    parameter PORT_NUM = 4,
    parameter LANE_NUM = 4,
    localparam [6:0] TX_CLK_GEN = 7'b1100011  
)(
pixel_clk_div2_mult7,
pixel_clk_div2,
pixel_clk,
pixel_clk_locked,
in_lvds_data         ,//[LANE_NUM*PORT_NUM*7-1:0] ~pixel_clk
lvds_clk_p           ,//[PORT_NUM-1:0]
lvds_clk_n           ,//[PORT_NUM-1:0] 
lvds_data_p          ,//[LANE_NUM*PORT_NUM-1:0]
lvds_data_n           //[LANE_NUM*PORT_NUM-1:0]
);
//////////////////////////////////////////////////////////////////////////////
input  pixel_clk_div2_mult7;
input  pixel_clk_div2;
input  pixel_clk;
input pixel_clk_locked;
input [LANE_NUM*PORT_NUM*7-1:0] in_lvds_data       ;
output  [PORT_NUM-1:0]          lvds_clk_p           ;
output  [PORT_NUM-1:0]          lvds_clk_n           ; 
output  [LANE_NUM*PORT_NUM-1:0] lvds_data_p          ;
output  [LANE_NUM*PORT_NUM-1:0] lvds_data_n          ;
//////////////////////////////////////////////////////////////////////////////             
            
n_x_serdes_7_to_1_diff_ddr_image_gen #(
     .D       (LANE_NUM),
     .N       (PORT_NUM),
     .DATA_FORMAT("PER_CLOCK")) // PER_CLOCK or PER_CHANL data formatting
    dataout (                      
    .dataout_p        (lvds_data_p),
    .dataout_n        (lvds_data_n),
    .clkout_p         (lvds_clk_p),
    .clkout_n         (lvds_clk_n),
    .txclk            (pixel_clk_div2_mult7),
    .txclk_div        (pixel_clk_div2),
    .pixel_clk        (pixel_clk),//~datain
    .reset            (~pixel_clk_locked),
    .clk_pattern      (TX_CLK_GEN),            // Transmit a constant to make the clock
    .datain           ({in_lvds_data[27:0],in_lvds_data[55:28],in_lvds_data[83:56],in_lvds_data[111:84]}));   
   
endmodule


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
module n_x_serdes_7_to_1_diff_ddr_image_gen (txclk, reset, pixel_clk, txclk_div, datain, clk_pattern, dataout_p, dataout_n, clkout_p, clkout_n) ;

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

serdes_7_to_1_diff_ddr_image_gen #(
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
module serdes_7_to_1_diff_ddr_image_gen (txclk, reset, pixel_clk, txclk_div, datain, clk_pattern, dataout_p, dataout_n, clkout_p, clkout_n) ;

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

parameter [D-1:0] TX_SWAP_MASK = 16'h0000 ; // pinswap mask for output bits (0 = no swap (default), 1 = swap). Allows outputs to be connected the 'wrong way round' to ease PCB routing.

genvar i ;
genvar j ;

initial reset_intr = 1'b1 ;

always @ (posedge txclk_div or posedge reset) begin// local reset
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

generate for (i = 0 ; i <= (D-1) ; i = i+1) begin : loop0

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
