// `timescale 1ns / 1ps
// module sdio_clk_gen(
//     input               i_clk100M       ,
//     input               i_rst_n         ,
//     input [3:0]         i_speed_mode    ,
//     output              sdclk_div_o     ,
//     output              o_sd_clk        ,
//     output              o_sd_clk_db
// );

// reg [8:0 ]r_clk_div_count;
// reg [3:0 ]r_speed_mode;
// reg       r_sd_clk;
// reg       sdclk_div;//div from i_clk(100M)

// always @ (posedge i_clk100M or negedge i_rst_n)
//     if(~i_rst_n)begin
//         r_speed_mode <= 4'b0;
//     end else
//         r_speed_mode <= i_speed_mode;

// always @ (posedge i_clk100M or negedge i_rst_n)
//     if(~i_rst_n)begin
//         sdclk_div          <= 1'b0;
//         r_clk_div_count    <= 9'b0;
//     end else
//         case(r_speed_mode)
//             4'd0 :
//                 begin//200k clk
//                     sdclk_div       <= (r_clk_div_count >= 9'd499) ? (~sdclk_div) : sdclk_div;
//                     r_clk_div_count <= (r_clk_div_count >= 9'd499) ? 9'b0 : r_clk_div_count + 1;
//                 end
//             4'd1 :
//                 begin//25M clk
//                     sdclk_div       <= (r_clk_div_count >= 9'd3) ? (~sdclk_div) : sdclk_div;
//                     r_clk_div_count <= (r_clk_div_count >= 9'd3) ? 9'b0 : r_clk_div_count + 1;
//                 end
//             4'd2 :
//                 begin//50M clk
//                     sdclk_div       <= (r_clk_div_count >= 9'd1) ? (~sdclk_div) : sdclk_div;
//                     r_clk_div_count <= (r_clk_div_count >= 9'd1) ? 9'b0 : r_clk_div_count + 1;
//                 end
//             4'd3 :
//                 begin//100M clk
//                     sdclk_div       <= ~sdclk_div;
//                     r_clk_div_count <= 9'b0;
//                 end
//             4'd4 :
//                 begin//100M clk
//                     sdclk_div       <= ~sdclk_div;
//                     r_clk_div_count <= 9'b0;
//                 end
//             default :
//                 begin//50M clk
//                     sdclk_div       <= (r_clk_div_count >= 9'd1) ? (~sdclk_div) : sdclk_div;
//                     r_clk_div_count <= (r_clk_div_count >= 9'd1) ? 9'b0 : r_clk_div_count + 1;
//                 end
//         endcase
//         // assign o_sd_clk = ~sdclk_div;


// // assign sdclk_div_o = sdclk_div;

// BUFG BUFG_inst (
//     .O(sdclk_div_o), // 1-bit output: Clock output.
//     .I(sdclk_div)  // 1-bit input: Clock input.
// );

// // BUFG BUFG_inst (
// //     .O(o_sd_clk), // 1-bit output: Clock output.
// //     .I(~sdclk_div)  // 1-bit input: Clock input.
// // );

// ODDRE1 #(
//     .IS_C_INVERTED(1'b0),      // Optional inversion for C
//     .IS_D1_INVERTED(1'b0),     // Unsupported, do not use
//     .IS_D2_INVERTED(1'b0),     // Unsupported, do not use
//     .SIM_DEVICE("ULTRASCALE"), // Set the device version for simulation functionality (ULTRASCALE)
//     .SRVAL(1'b1)               // Initializes the ODDRE1 Flip-Flops to the specified value (1'b0, 1'b1)
// )
// ODDRE1_inst (
//     .Q(o_sd_clk),   // 1-bit output: Data output to IOB
//     .C(sdclk_div),   // 1-bit input: High-speed clock input
//     .D1(1'b0), // 1-bit input: Parallel data input 1
//     .D2(1'b1), // 1-bit input: Parallel data input 2
//     .SR(1'b0)  // 1-bit input: Active-High Async Reset
// );

// // ddio  sdclk_out_inst(
// //   .datain_h (1'b0),
// //   .datain_l (1'b1),
// //   .outclock (sdclk_div),
// //   .dataout  (o_sd_clk));


// //for debug
// // BUFG BUFG_db_inst (
// //     .O(o_sd_clk_db), // 1-bit output: Clock output.
// //     .I(~sdclk_div)  // 1-bit input: Clock input.
// // );

// ODDRE1 #(
//   .IS_C_INVERTED(1'b0),      // Optional inversion for C
//   .IS_D1_INVERTED(1'b0),     // Unsupported, do not use
//   .IS_D2_INVERTED(1'b0),     // Unsupported, do not use
//   .SIM_DEVICE("ULTRASCALE"), // Set the device version for simulation functionality (ULTRASCALE)
//   .SRVAL(1'b1)               // Initializes the ODDRE1 Flip-Flops to the specified value (1'b0, 1'b1)
// )
// ODDRE2_inst (
//     .Q(o_sd_clk_db),   // 1-bit output: Data output to IOB
//     .C(sdclk_div),   // 1-bit input: High-speed clock input
//     .D1(1'b0), // 1-bit input: Parallel data input 1
//     .D2(1'b1), // 1-bit input: Parallel data input 2
//     .SR(1'b0)  // 1-bit input: Active-High Async Reset
// );





// ODELAYE3 #(
//     .CASCADE("NONE"),          // Cascade setting (MASTER, NONE, SLAVE_END, SLAVE_MIDDLE)
//     .DELAY_FORMAT("TIME"),     // (COUNT, TIME)
//     .DELAY_TYPE("FIXED"),      // Set the type of tap delay line (FIXED, VARIABLE, VAR_LOAD)
//     .DELAY_VALUE(0),           // Output delay tap setting
//     .IS_CLK_INVERTED(1'b0),    // Optional inversion for CLK
//     .IS_RST_INVERTED(1'b0),    // Optional inversion for RST
//     .REFCLK_FREQUENCY(300.0),  // IDELAYCTRL clock input frequency in MHz (200.0-800.0).
//     .SIM_DEVICE("ULTRASCALE"), // Set the device version for simulation functionality (ULTRASCALE)
//     .UPDATE_MODE("ASYNC")      // Determines when updates to the delay will take effect (ASYNC, MANUAL, SYNC)
//  )
//  ODELAYE3_inst (
//     .CASC_OUT(CASC_OUT),       // 1-bit output: Cascade delay output to IDELAY input cascade
//     .CNTVALUEOUT(CNTVALUEOUT), // 9-bit output: Counter value output
//     .DATAOUT(DATAOUT),         // 1-bit output: Delayed data from ODATAIN input port
//     .CASC_IN(CASC_IN),         // 1-bit input: Cascade delay input from slave IDELAY CASCADE_OUT
//     .CASC_RETURN(CASC_RETURN), // 1-bit input: Cascade delay returning from slave IDELAY DATAOUT
//     .CE(CE),                   // 1-bit input: Active-High enable increment/decrement input
//     .CLK(CLK),                 // 1-bit input: Clock input
//     .CNTVALUEIN(CNTVALUEIN),   // 9-bit input: Counter value input
//     .EN_VTC(EN_VTC),           // 1-bit input: Keep delay constant over VT
//     .INC(INC),                 // 1-bit input: Increment/Decrement tap delay input
//     .LOAD(LOAD),               // 1-bit input: Load DELAY_VALUE input
//     .ODATAIN(ODATAIN),         // 1-bit input: Data input
//     .RST(RST)                  // 1-bit input: Asynchronous Reset to the DELAY_VALUE
//  );




// endmodule

`timescale 1ns / 1ps
module sdio_clk_gen(
    input               i_clk100M       ,
    input               i_rst_n         ,
    input [3:0]         i_speed_mode    ,
    output              sdclk_div_o     ,
    output              o_sd_clk        ,
    output              o_sd_clk_db
);

reg [15:0]r_clk_div_count;
reg [15:0]w_clk_div_count;
reg [3:0 ]r_speed_mode;
reg       r_sd_clk;
reg       sdclk_div;//div from i_clk(100M)
reg       w_sdclk_div;//div from i_clk(100M)

always @ (posedge i_clk100M or negedge i_rst_n)
    if(~i_rst_n)begin
        r_speed_mode <= 4'b0;
    end else
        r_speed_mode <= i_speed_mode;

always @ (posedge i_clk100M or negedge i_rst_n)
    if(~i_rst_n)begin
        sdclk_div          <= 1'b1;
        w_sdclk_div          <= 1'b1;
        r_clk_div_count    <= 16'b0;
        w_clk_div_count    <= 16'b0;
    end else
        case(r_speed_mode)
            4'd0 :
                begin//200k clk
                    sdclk_div       <= (r_clk_div_count >= 9'd499) ? (~sdclk_div) : sdclk_div;
                    r_clk_div_count <= (r_clk_div_count >= 9'd499) ? 9'b0 : r_clk_div_count + 1;
                    w_sdclk_div       <= (w_clk_div_count >= 16'd249) & (w_clk_div_count < 16'd750) ? 1 : 0;
                    w_clk_div_count <= (w_clk_div_count >= 16'd999) ? 9'b0 : w_clk_div_count + 1;
                end
            4'd1 :
                begin//25M clk
                    sdclk_div       <= (r_clk_div_count >= 9'd3) ? (~sdclk_div) : sdclk_div;
                    r_clk_div_count <= (r_clk_div_count >= 9'd3) ? 9'b0 : r_clk_div_count + 1;
                    w_sdclk_div       <= (w_clk_div_count >= 16'd2) & (w_clk_div_count < 16'd6) ? 1 : 0;
                    w_clk_div_count <= (w_clk_div_count >= 16'd7) ? 9'b0 : w_clk_div_count + 1;
                end
            4'd2 :
                begin//50M clk
                    sdclk_div       <= (r_clk_div_count >= 9'd1) ? (~sdclk_div) : sdclk_div;
                    r_clk_div_count <= (r_clk_div_count >= 9'd1) ? 9'b0 : r_clk_div_count + 1;
                end
            4'd3 :
                begin//100M clk
                    sdclk_div       <= ~sdclk_div;
                    r_clk_div_count <= 9'b0;
                end
            4'd4 :
                begin//100M clk
                    sdclk_div       <= ~sdclk_div;
                    r_clk_div_count <= 9'b0;
                end
            default :
                begin//50M clk
                    sdclk_div       <= (r_clk_div_count >= 9'd1) ? (~sdclk_div) : sdclk_div;
                    r_clk_div_count <= (r_clk_div_count >= 9'd1) ? 9'b0 : r_clk_div_count + 1;
                end
        endcase
        // assign o_sd_clk = ~sdclk_div;


// assign sdclk_div_o = sdclk_div;

BUFG BUFG_inst (
    .O(sdclk_div_o), // 1-bit output: Clock output.
    .I(sdclk_div)  // 1-bit input: Clock input.
);



// ODDRE1 #(
//     .IS_C_INVERTED(1'b0),      // Optional inversion for C
//     .IS_D1_INVERTED(1'b0),     // Unsupported, do not use
//     .IS_D2_INVERTED(1'b0),     // Unsupported, do not use
//     .SIM_DEVICE("ULTRASCALE"), // Set the device version for simulation functionality (ULTRASCALE)
//     .SRVAL(1'b1)               // Initializes the ODDRE1 Flip-Flops to the specified value (1'b0, 1'b1)
// )
// sclk_inst (
//     .Q(sdclk_div_o),   // 1-bit output: Data output to IOB
//     .C(sdclk_div),   // 1-bit input: High-speed clock input
//     .D1(1'b1), // 1-bit input: Parallel data input 1
//     .D2(1'b0), // 1-bit input: Parallel data input 2
//     .SR(1'b0)  // 1-bit input: Active-High Async Reset
// );


wire w_sd_clk;



// IOBUF IOBUF_inst (
//     .O(),   // 1-bit output: Buffer output
//     .I(w_sd_clk),   // 1-bit input: Buffer input
//     .IO(o_sd_clk), // 1-bit inout: Buffer inout (connect directly to top-level port)
//     .T(0)    // 1-bit input: 3-state enable input
//  );



// KU
//ODDRE1 #(
//    .IS_C_INVERTED(1'b0),      // Optional inversion for C
//    .IS_D1_INVERTED(1'b0),     // Unsupported, do not use
//    .IS_D2_INVERTED(1'b0),     // Unsupported, do not use
//    .SIM_DEVICE("ULTRASCALE"), // Set the device version for simulation functionality (ULTRASCALE)
//    .SRVAL(1'b1)               // Initializes the ODDRE1 Flip-Flops to the specified value (1'b0, 1'b1)
//)
//ODDRE1_inst (
//    .Q(o_sd_clk),   // 1-bit output: Data output to IOB
//    .C(sdclk_div),   // 1-bit input: High-speed clock input
//    .D1(1'b1), // 1-bit input: Parallel data input 1
//    .D2(1'b0), // 1-bit input: Parallel data input 2
//    .SR(1'b0)  // 1-bit input: Active-High Async Reset
//);



//K7
   ODDR #(
      .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
      .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) ODDR_inst (
      .Q(o_sd_clk),   // 1-bit DDR output
      .C(sdclk_div),   // 1-bit clock input
      .CE(1), // 1-bit clock enable input
      .D1(1), // 1-bit data input (positive edge)
      .D2(0), // 1-bit data input (negative edge)
      .R(0),   // 1-bit reset
      .S(0)    // 1-bit set
   );







// ddio  sdclk_out_inst(
//   .datain_h (1'b0),
//   .datain_l (1'b1),
//   .outclock (sdclk_div),
//   .dataout  (o_sd_clk));


//for debug
// BUFG BUFG_db_inst (
//     .O(o_sd_clk_db), // 1-bit output: Clock output.
//     .I(~sdclk_div)  // 1-bit input: Clock input.
// );


//KU
//ODDRE1 #(
//  .IS_C_INVERTED(1'b0),      // Optional inversion for C
//  .IS_D1_INVERTED(1'b0),     // Unsupported, do not use
//  .IS_D2_INVERTED(1'b0),     // Unsupported, do not use
//  .SIM_DEVICE("ULTRASCALE"), // Set the device version for simulation functionality (ULTRASCALE)
//  .SRVAL(1'b1)               // Initializes the ODDRE1 Flip-Flops to the specified value (1'b0, 1'b1)
//)
//ODDRE2_inst (
//    .Q(o_sd_clk_db),   // 1-bit output: Data output to IOB
//    .C(sdclk_div),   // 1-bit input: High-speed clock input
//    .D1(1'b1), // 1-bit input: Parallel data input 1
//    .D2(1'b0), // 1-bit input: Parallel data input 2
//    .SR(1'b0)  // 1-bit input: Active-High Async Reset
//);
//


//K7
   ODDR #(
      .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
      .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) ODDR_inst2 (
      .Q(o_sd_clk_db),   // 1-bit DDR output
      .C(sdclk_div),   // 1-bit clock input
      .CE(1), // 1-bit clock enable input
      .D1(1), // 1-bit data input (positive edge)
      .D2(0), // 1-bit data input (negative edge)
      .R(0),   // 1-bit reset
      .S(0)    // 1-bit set
   );















endmodule
