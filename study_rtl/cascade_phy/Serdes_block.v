`timescale 1ns / 1ps

module Serdes_block #(
        parameter MODE      = "Master",
        parameter DAT_OUT   = 8,
        parameter LINE_NUM  = 10,      
        parameter DAT_IN    = 1,
        parameter CMD_OUT   = 2,
        parameter CMD_IN    = 2,
        parameter SER_FACTOR = 4 
)(
      input                            i_clk,  // 
      input                            i_clk_div,
      input                            i_rst,
      
      output [DAT_OUT - 1 : 0]        o_dat,
      output [CMD_OUT - 1 : 0]        o_cmd,
      input  [DAT_OUT*SER_FACTOR-1:0] i_tx_data,
      input  [CMD_OUT*SER_FACTOR-1:0] i_tx_cmd,
      
      input  [DAT_IN - 1 : 0]         i_dat,//串行线
      input  [CMD_IN - 1 : 0]         i_cmd,
      
      output [SER_FACTOR*DAT_IN-1:0]   o_rx_data,
      output [SER_FACTOR*CMD_IN-1:0]   o_rx_cmd  ,
      
      input  [DAT_IN +CMD_IN-1:0]    bitslip,
      input  [LINE_NUM-1:0]   i_tri_dval,
      output [LINE_NUM-1:0]   o_tristate_int
            
    );
//for DATA output S-P 
wire  [LINE_NUM-1:0] w_tristate_int;
  wire  [DAT_IN-1:0]  i_serdes_dat[SER_FACTOR-1:0];

genvar pin_dat_count;
genvar sli_dat_count;
generate 
if (MODE=="Master") begin
for (pin_dat_count = 0; pin_dat_count < DAT_OUT; pin_dat_count = pin_dat_count + 1) begin: dat_out  
  wire  [DAT_OUT-1:0] w_tx_data;
  wire  [DAT_OUT-1:0] o_serdes_dat[0:SER_FACTOR-1];

  wire  [DAT_OUT-1:0] w_dat_dval;
  wire  [DAT_OUT-1:0] w_dat;
  assign w_dat[pin_dat_count] = w_tx_data[pin_dat_count];
  assign o_dat = w_dat[DAT_OUT-1:0];   
  assign w_dat_dval = i_tri_dval[LINE_NUM-1:CMD_OUT];
     // declare the oserdes
     OSERDESE2
       # (
         .DATA_RATE_OQ   ("DDR"),
         .DATA_RATE_TQ   ("DDR"),
         .DATA_WIDTH     (SER_FACTOR),
         .TRISTATE_WIDTH (4),
         .SERDES_MODE    ("MASTER"))
       oserdese2_master (
         .D1             (o_serdes_dat[3][pin_dat_count]),
         .D2             (o_serdes_dat[2][pin_dat_count]),
         .D3             (o_serdes_dat[1][pin_dat_count]),
         .D4             (o_serdes_dat[0][pin_dat_count]),
        //.D5             (o_serdes_dat[3][pin_dat_count]),
        //.D6             (o_serdes_dat[2][pin_dat_count]),
        //.D7             (o_serdes_dat[1][pin_dat_count]),
        //.D8             (o_serdes_dat[0][pin_dat_count]),
          .D5            (),
          .D6            (),
          .D7            (),
          .D8            (),

         .T1             (w_dat_dval[pin_dat_count]),
         .T2             (w_dat_dval[pin_dat_count]),
         .T3             (w_dat_dval[pin_dat_count]),
         .T4             (w_dat_dval[pin_dat_count]),
         .SHIFTIN1       (1'b0),
         .SHIFTIN2       (1'b0),
         .SHIFTOUT1      (),
         .SHIFTOUT2      (),
         .OCE            (1'b1),
         .CLK            (i_clk),
         .CLKDIV         (i_clk_div),
         .OQ             (w_tx_data[pin_dat_count]),
         .TQ             (o_tristate_int[pin_dat_count+CMD_OUT]), // Tri-State control for IOB
         .OFB            (),
         .TFB            (),
         .TBYTEIN        (1'b0),
         .TBYTEOUT       (),
         .TCE            (1'b1),
         .RST            (i_rst));


     
     for (sli_dat_count = 0; sli_dat_count < SER_FACTOR; sli_dat_count = sli_dat_count + 1) begin: dat_slices
        // This places the first data in time on the right
        assign o_serdes_dat[sli_dat_count] =
           i_tx_data[sli_dat_count*DAT_OUT+:DAT_OUT];
        // To place the first data in time on the left, use the
        //   following code, instead
        // assign oserdes_d[slice_count] =
        //    data_out_from_device[slice_count];
     end
    end 
for (pin_dat_count = 0; pin_dat_count < DAT_IN; pin_dat_count = pin_dat_count + 1) begin: dat_in  
    
// declare the iserdes
     ISERDESE2
       # (.DATA_WIDTH       (4),         
          .DATA_RATE        ("DDR"),       
          .SERDES_MODE      ("MASTER"),       
          .IOBDELAY        ("IFD"),       
          .INTERFACE_TYPE   ("NETWORKING"),
          .NUM_CE      (1))  
       iserdese2_master (
         .Q1                (i_serdes_dat[0][pin_dat_count]),
         .Q2                (i_serdes_dat[1][pin_dat_count]),
         .Q3                (i_serdes_dat[2][pin_dat_count]),
         .Q4                (i_serdes_dat[3][pin_dat_count]),
         //.Q5                (i_serdes_dat[4][pin_dat_count]),
         //.Q6                (i_serdes_dat[5][pin_dat_count]),
         //.Q7                (i_serdes_dat[6][pin_dat_count]),
         //.Q8                (i_serdes_dat[7][pin_dat_count]),
         .Q5                (),
         .Q6                (),
         .Q7                (),
         .Q8                (),

         .SHIFTOUT1         (),
         .SHIFTOUT2         (),
         .BITSLIP           (bitslip[pin_dat_count+CMD_OUT]),// 1-bit Invoke Bitslip. This can be used with any DATA_WIDTH, cascaded or not.
                                                             // The amount of BITSLIP is fixed by the DATA_WIDTH selection.
         .CE1               (1'b1),                          // 1-bit Clock enable input
         .CE2               (1'b1),                          // 1-bit Clock enable input
         .CLK               (i_clk),                         // Fast source synchronous clock driven by BUFIO
         .CLKB              (~i_clk),                        // Locally inverted fast 
         .CLKDIV            (i_clk_div),                     // Slow clock from BUFR.
         .CLKDIVP           (1'b0),
         .D                 (1'b0),                          // 1-bit Input signal from IOB
         .DDLY              (i_dat[pin_dat_count]),          // 1-bit Input from Input Delay component 
         .RST               (i_rst),                         // 1-bit Asynchronous reset only.
         .SHIFTIN1          (1'b0),
         .SHIFTIN2          (1'b0),
    // unused connections
         .DYNCLKDIVSEL      (1'b0),
         .DYNCLKSEL         (1'b0),
         .OFB               (1'b0),
         .OCLK              (1'b0),
         .OCLKB             (1'b0),
         .O                 ());                                   // unregistered output of ISERDESE1  
         
     // Concatenate the serdes outputs together. Keep the timesliced
     //   bits together, and placing the earliest bits on the right
     //   ie, if data comes in 0, 1, 2, 3, 4, 5, 6, 7, ...
     //       the output will be 3210, 7654, ...
     ////---------------------------------------------------------
      for (sli_dat_count = 0; sli_dat_count < SER_FACTOR; sli_dat_count = sli_dat_count + 1) begin: bak_dat_slices
        // This places the first data in time on the right
        assign o_rx_data[sli_dat_count*DAT_IN+:DAT_IN] =
          i_serdes_dat[sli_dat_count];
        // To place the first data in time on the left, use the
        //   following code, instead
        // assign data_in_to_device[slice_count*SYS_W+:SYS_W] =
        //   iserdes_q[slice_count];
     end  
   end
 end else begin
   for (pin_dat_count = 0; pin_dat_count < DAT_IN; pin_dat_count = pin_dat_count + 1) begin: dat_out  
     wire  [DAT_IN-1:0] w_tx_data;
    wire  [DAT_IN-1:0] o_serdes_dat[0:SER_FACTOR-1];
    wire  [DAT_IN-1:0] w_dat_dval;
    wire [DAT_IN-1:0]w_dat;
  assign w_dat[pin_dat_count]  = w_tx_data[pin_dat_count];
  assign o_dat = w_dat[DAT_OUT-1:0];   
  assign w_dat_dval = i_tri_dval[LINE_NUM-1:CMD_OUT];
     // declare the oserdes
     OSERDESE2
       # (
         .DATA_RATE_OQ   ("DDR"),
         .DATA_RATE_TQ   ("DDR"),
         .DATA_WIDTH     (SER_FACTOR),
         .TRISTATE_WIDTH (4),
         .SERDES_MODE    ("MASTER"))
       oserdese2_master (
         .D1             (o_serdes_dat[3][pin_dat_count]),
         .D2             (o_serdes_dat[2][pin_dat_count]),
         .D3             (o_serdes_dat[1][pin_dat_count]),
         .D4             (o_serdes_dat[0][pin_dat_count]),
        //.D5             (o_serdes_dat[3][pin_dat_count]),
        //.D6             (o_serdes_dat[2][pin_dat_count]),
        //.D7             (o_serdes_dat[1][pin_dat_count]),
        //.D8             (o_serdes_dat[0][pin_dat_count]),
          .D5              (),
          .D6              (),
          .D7              (),
          .D8              (),

         .T1             (w_dat_dval[pin_dat_count]),
         .T2             (w_dat_dval[pin_dat_count]),
         .T3             (w_dat_dval[pin_dat_count]),
         .T4             (w_dat_dval[pin_dat_count]),
         .SHIFTIN1       (1'b0),
         .SHIFTIN2       (1'b0),
         .SHIFTOUT1      (),
         .SHIFTOUT2      (),
         .OCE            (1'b1),
         .CLK            (i_clk),
         .CLKDIV         (i_clk_div),
         .OQ             (w_tx_data[pin_dat_count]),
         .TQ             (o_tristate_int[pin_dat_count+CMD_OUT]), // Tri-State control for IOB
         .OFB            (),
         .TFB            (),
         .TBYTEIN        (1'b0),
         .TBYTEOUT       (),
         .TCE            (1'b1),
         .RST            (i_rst));


     
     for (sli_dat_count = 0; sli_dat_count < SER_FACTOR; sli_dat_count = sli_dat_count + 1) begin: dat_slices
        // This places the first data in time on the right
        assign o_serdes_dat[sli_dat_count] =
           i_tx_data[sli_dat_count*DAT_OUT+:DAT_OUT];
        // To place the first data in time on the left, use the
        //   following code, instead
        // assign oserdes_d[slice_count] =
        //    data_out_from_device[slice_count];
     end
    end 
for (pin_dat_count = 0; pin_dat_count < DAT_IN; pin_dat_count = pin_dat_count + 1) begin: dat_in  
    
// declare the iserdes
     ISERDESE2
       #  (.DATA_WIDTH       (4),         
          .DATA_RATE        ("DDR"),       
          .SERDES_MODE      ("MASTER"),       
          .IOBDELAY        ("IFD"),       
          .INTERFACE_TYPE   ("NETWORKING"),
          .NUM_CE      (1))  
       iserdese2_master (
         .Q1                (i_serdes_dat[0][pin_dat_count]),
         .Q2                (i_serdes_dat[1][pin_dat_count]),
         .Q3                (i_serdes_dat[2][pin_dat_count]),
         .Q4                (i_serdes_dat[3][pin_dat_count]),
         //.Q5                (i_serdes_dat[4][pin_dat_count]),
         //.Q6                (i_serdes_dat[5][pin_dat_count]),
         //.Q7                (i_serdes_dat[6][pin_dat_count]),
         //.Q8                (i_serdes_dat[7][pin_dat_count]),
         .Q5                (),
         .Q6                (),
         .Q7                (),
         .Q8                (),

         .SHIFTOUT1         (),
         .SHIFTOUT2         (),
         .BITSLIP           (bitslip[pin_dat_count+CMD_OUT]),                             // 1-bit Invoke Bitslip. This can be used with any DATA_WIDTH, cascaded or not.
                                                                   // The amount of BITSLIP is fixed by the DATA_WIDTH selection.
         .CE1               (1'b1),                        // 1-bit Clock enable input
         .CE2               (1'b1),                        // 1-bit Clock enable input
         .CLK               (i_clk),                      // Fast source synchronous clock driven by BUFIO
         .CLKB              (~i_clk),                      // Locally inverted fast 
         .CLKDIV            (i_clk_div),                             // Slow clock from BUFR.
         .CLKDIVP           (1'b0),
         .D                 (1'b0),                                // 1-bit Input signal from IOB
         .DDLY              (i_dat[pin_dat_count]),  // 1-bit Input from Input Delay component 
         .RST               (i_rst),                            // 1-bit Asynchronous reset only.
         .SHIFTIN1          (1'b0),
         .SHIFTIN2          (1'b0),
    // unused connections
         .DYNCLKDIVSEL      (1'b0),
         .DYNCLKSEL         (1'b0),
         .OFB               (1'b0),
         .OCLK              (1'b0),
         .OCLKB             (1'b0),
         .O                 ());                                   // unregistered output of ISERDESE1  
         
     // Concatenate the serdes outputs together. Keep the timesliced
     //   bits together, and placing the earliest bits on the right
     //   ie, if data comes in 0, 1, 2, 3, 4, 5, 6, 7, ...
     //       the output will be 3210, 7654, ...
     ////---------------------------------------------------------
      for (sli_dat_count = 0; sli_dat_count < SER_FACTOR; sli_dat_count = sli_dat_count + 1) begin: bak_dat_slices
        // This places the first data in time on the right
        assign o_rx_data[sli_dat_count*DAT_IN+:DAT_IN] =
          i_serdes_dat[sli_dat_count];
        // To place the first data in time on the left, use the
        //   following code, instead
        // assign data_in_to_device[slice_count*SYS_W+:SYS_W] =
        //   iserdes_q[slice_count];
     end  
   end
 end  

 
endgenerate  

     
    
    

//for CMD output S-P 

wire  [CMD_OUT-1:0] w_tx_cmd;
wire  [CMD_OUT-1:0] o_serdes_cmd[0:SER_FACTOR-1];
wire  [CMD_IN-1:0]  i_serdes_cmd[SER_FACTOR-1:0];
wire  [CMD_OUT-1:0] w_cmd_dval ;
genvar pin_cmd_count;
genvar sli_cmd_count;
generate 
for (pin_cmd_count = 0; pin_cmd_count < CMD_OUT; pin_cmd_count = pin_cmd_count + 1) begin: cmd_out  
  
  assign o_cmd[pin_cmd_count]  = w_tx_cmd[pin_cmd_count];
  assign w_cmd_dval = i_tri_dval[CMD_OUT-1:0];
  // declare the oserdes
    // declare the oserdes
     OSERDESE2
       # (
         .DATA_RATE_OQ   ("DDR"),
         .DATA_RATE_TQ   ("DDR"),
         .DATA_WIDTH     (SER_FACTOR),
         .TRISTATE_WIDTH (4),
         .SERDES_MODE    ("MASTER"))
       oserdese2_master (
         .D1             (o_serdes_cmd[3][pin_cmd_count]),
         .D2             (o_serdes_cmd[2][pin_cmd_count]),
         .D3             (o_serdes_cmd[1][pin_cmd_count]),
         .D4             (o_serdes_cmd[0][pin_cmd_count]),
         .D5              (), 
         .D6              (), 
         .D7              (), 
         .D8              (), 
  
         //.D5             (o_serdes_cmd[3][pin_cmd_count]),
         //.D6             (o_serdes_cmd[2][pin_cmd_count]),
         //.D7             (o_serdes_cmd[1][pin_cmd_count]),
         //.D8             (o_serdes_cmd[0][pin_cmd_count]),
         .T1             (w_cmd_dval[pin_cmd_count]),
         .T2             (w_cmd_dval[pin_cmd_count]),
         .T3             (w_cmd_dval[pin_cmd_count]),
         .T4             (w_cmd_dval[pin_cmd_count]),
         .SHIFTIN1       (1'b0),
         .SHIFTIN2       (1'b0),
         .SHIFTOUT1      (),
         .SHIFTOUT2      (),
         .OCE            (1'b1),
         .CLK            (i_clk),
         .CLKDIV         (i_clk_div),
         .OQ             (w_tx_cmd[pin_cmd_count]),
         .TQ             (o_tristate_int[pin_cmd_count]), // Tri-State control for IOB
         .OFB            (),
         .TFB            (),
         .TBYTEIN        (1'b0),
         .TBYTEOUT       (),
         .TCE            (1'b1),
         .RST            (i_rst));


     
     for (sli_cmd_count = 0; sli_cmd_count < SER_FACTOR; sli_cmd_count = sli_cmd_count + 1) begin: cmd_slices
        // This places the first data in time on the right
        assign o_serdes_cmd[sli_cmd_count] =
           i_tx_cmd[sli_cmd_count*CMD_OUT+:CMD_OUT];
        // To place the first data in time on the left, use the
        //   following code, instead
        // assign oserdes_d[slice_count] =
        //    data_out_from_device[slice_count];
     end
    end 
 for (pin_cmd_count = 0; pin_cmd_count < CMD_IN; pin_cmd_count = pin_cmd_count + 1) begin: cmd_in  
// declare the iserdes

//ISERDESE2 #(
//  .DATA_WIDTH       (SER_FACTOR),         
//  .DATA_RATE        ("DDR"),       
////  .SERDES_MODE      ("MASTER"),       
//  .IOBDELAY        ("IFD"),       
//  .INTERFACE_TYPE   ("NETWORKING"),
//  .NUM_CE      (1))    
//iserdese2_master (
//  .D           (1'b0),
//  .DDLY         (i_cmd[pin_cmd_count]),
//  .CE1         (1'b1),
//  .CE2         (1'b1),
//  .CLK        (i_clk),
//  .CLKB        (~i_clk),
//  .RST         (i_rst),
//  .CLKDIV      (i_clk_div),
//  .CLKDIVP      (1'b0),
//  .OCLK        (1'b0),
//  .OCLKB        (1'b0),
//  .DYNCLKSEL        (1'b0),
//  .DYNCLKDIVSEL      (1'b0),
//  .SHIFTIN1     (1'b0),
//  .SHIFTIN2     (1'b0),
//  .BITSLIP     (bitslip[pin_cmd_count]),
//  .O         (),
//  .Q8       (),
//  .Q7       (),
//  .Q6       (),
//  .Q5       (),
//  .Q4       (i_serdes_cmd[3][pin_cmd_count]),
//  .Q3       (i_serdes_cmd[2][pin_cmd_count]),
//  .Q2       (i_serdes_cmd[1][pin_cmd_count]),
//  .Q1       (i_serdes_cmd[0][pin_cmd_count]),
//  .OFB       (),
//  .SHIFTOUT1     (),
//  .SHIFTOUT2     ());
//  
     ISERDESE2
       #  (.DATA_WIDTH       (4),         
          .DATA_RATE        ("DDR"),       
          .SERDES_MODE      ("MASTER"),       
          .IOBDELAY        ("IFD"),       
          .INTERFACE_TYPE   ("NETWORKING"),
          .NUM_CE      (1))  
       iserdese2_master (
         .Q1                (i_serdes_cmd[0][pin_cmd_count]),
         .Q2                (i_serdes_cmd[1][pin_cmd_count]),
         .Q3                (i_serdes_cmd[2][pin_cmd_count]),
         .Q4                (i_serdes_cmd[3][pin_cmd_count]),
         //.Q5                (i_serdes_dat[4][pin_dat_count]),
         //.Q6                (i_serdes_dat[5][pin_dat_count]),
         //.Q7                (i_serdes_dat[6][pin_dat_count]),
         //.Q8                (i_serdes_dat[7][pin_dat_count]),
         .Q5                (),
         .Q6                (),
         .Q7                (),
         .Q8                (),
         .SHIFTOUT1         (),
         .SHIFTOUT2         (),
         .BITSLIP           (bitslip[pin_cmd_count]),                             // 1-bit Invoke Bitslip. This can be used with any DATA_WIDTH, cascaded or not.
                                                                   // The amount of BITSLIP is fixed by the DATA_WIDTH selection.
         .CE1               (1'b1),                        // 1-bit Clock enable input
         .CE2               (1'b1),                        // 1-bit Clock enable input
         .CLK               (i_clk),                      // Fast source synchronous clock driven by BUFIO
         .CLKB              (~i_clk),                      // Locally inverted fast 
         .CLKDIV            (i_clk_div),                             // Slow clock from BUFR.
         .CLKDIVP           (1'b0),
         .D                 (1'b0),                                // 1-bit Input signal from IOB
         .DDLY              (i_cmd[pin_cmd_count]),  // 1-bit Input from Input Delay component 
         .RST               (i_rst),                            // 1-bit Asynchronous reset only.
         .SHIFTIN1          (1'b0),
         .SHIFTIN2          (1'b0),
    // unused connections
         .DYNCLKDIVSEL      (1'b0),
         .DYNCLKSEL         (1'b0),
         .OFB               (1'b0),
         .OCLK              (1'b0),
         .OCLKB             (1'b0),
         .O                 ());                                   // unregistered output of ISERDESE1  
         
     // Concatenate the serdes outputs together. Keep the timesliced
     //   bits together, and placing the earliest bits on the right
     //   ie, if data comes in 0, 1, 2, 3, 4, 5, 6, 7, ...
     //       the output will be 3210, 7654, ...
     ////---------------------------------------------------------
      for (sli_cmd_count = 0; sli_cmd_count < SER_FACTOR; sli_cmd_count = sli_cmd_count + 1) begin: bak_cmd_slices
        // This places the first data in time on the right
        assign o_rx_cmd[sli_cmd_count*CMD_IN+:CMD_IN] =
          i_serdes_cmd[sli_cmd_count];
        // To place the first data in time on the left, use the
        //   following code, instead
        // assign data_in_to_device[slice_count*SYS_W+:SYS_W] =
        //   iserdes_q[slice_count];
     end  
    end 
endgenerate    


//assign o_tristate_int = {{(CMD_OUT-CMD_IN){1'b0}},w_tristate_int[DAT_IN+CMD_OUT-1:CMD_OUT],{(CMD_OUT-CMD_IN){1'b0}},w_tristate_int[CMD_IN-1:0]} ;
 
endmodule
