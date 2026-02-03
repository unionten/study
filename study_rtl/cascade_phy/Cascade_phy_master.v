`timescale 1ns / 1ps
module Cascade_phy_master #(
    parameter MODE       = "Master",
    parameter IOSTANDARD = "DIFF_HSTL_II_18",
    parameter LINE_NUM   = 5,
    parameter TRAN_SPEED = 800,
    parameter REF_FREQ   = 200,
    parameter DAT_OUT    = 8,
    parameter DAT_IN     = 4,
    parameter CMD_OUT    = 2,
    parameter CMD_IN     = 1,
    parameter SER_FACTOR = 4 
)(
  input   i_clk,
  input   i_clk_div,
  input   i_rst,
  
  inout   [DAT_OUT-1:0]          b_dat_p,
  inout   [DAT_OUT-1:0]          b_dat_n,
  inout   [CMD_OUT-1:0]          b_cmd_p, 
  inout   [CMD_OUT-1:0]          b_cmd_n,
  

  input   [DAT_OUT*SER_FACTOR-1:0]  i_tx_data,  
  input   [LINE_NUM-1:0]            i_tri_dval,  
  output  [SER_FACTOR-1:0]          o_rx_data,  
  
  input   [CMD_OUT*SER_FACTOR-1:0]  i_tx_cmd,
  output  [CMD_OUT*SER_FACTOR-1:0]  o_rx_cmd,
        

  input                             i_hot_plug,
  input                             i_data_retrain,
  input                             i_cmd_retrain,
  output  [3:0]                     o_initial_done
        
    );
    

(*KEEP="ture"*)wire  [DAT_IN-1:0]              w_rx_dat;  
(*KEEP="ture"*)wire  [CMD_IN-1:0]              w_rx_cmd;  
                             
(*KEEP="ture"*)wire  [DAT_OUT-1:0]             w_tx_dat; 
(*KEEP="ture"*)wire  [CMD_OUT-1:0]             w_tx_cmd;
(*KEEP="ture"*)wire  [DAT_OUT+CMD_OUT-1:0]     w_tristate_int;
(*KEEP="ture"*)wire  [DAT_IN + CMD_IN-1:0]     bitslip;
(*KEEP="ture"*)wire  [DAT_OUT*SER_FACTOR-1:0]  w_tx_data;
(*KEEP="ture"*)wire  [CMD_OUT*SER_FACTOR-1:0]  w_tx_cmd_dat;      
(*KEEP="ture"*)wire  [SER_FACTOR*DAT_IN-1:0]   w_rx_data;
(*KEEP="ture"*)wire  [SER_FACTOR*CMD_IN-1:0]   w_rx_cmd_dat;
(*KEEP="ture"*)wire  [DAT_OUT+CMD_OUT-1:0]     w_tri_dval;
(*KEEP="ture"*)wire  [(DAT_IN + CMD_IN)*5-1:0] w_delay_val;

(*KEEP="ture"*)wire  [DAT_OUT+CMD_OUT-1:0]     w_tri_dval_int;

(*KEEP="ture"*)wire  [DAT_OUT*SER_FACTOR-1:0]  w_tx_pattern;     
(*KEEP="ture"*)wire  [CMD_OUT*SER_FACTOR-1:0]  w_tx_cmd_pattern; 
(*KEEP="ture"*)reg     r_hot_plug; 
(*KEEP="ture"*)reg     r_initial_req; 
always@(posedge i_clk)
 begin
  r_hot_plug   <= ~i_hot_plug;
  r_initial_req<= i_hot_plug;
 end
Serdes_block #(
        .MODE       ("Master"),
        .DAT_OUT   (DAT_OUT),
        .DAT_IN    (DAT_IN),
        .CMD_OUT   (CMD_OUT),
        .CMD_IN    (CMD_IN),
        .LINE_NUM  (LINE_NUM),
        .SER_FACTOR (SER_FACTOR) 
)
Serdes_block_inst(
      .i_clk          (i_clk),  
      .i_clk_div      (i_clk_div),
      .i_rst          (i_rst),
      .o_dat          (w_tx_dat),
      .o_cmd          (w_tx_cmd),
      .i_tx_data      (w_tx_pattern),
      .i_tx_cmd       (w_tx_cmd_pattern),
      .i_dat          (w_rx_dat),
      .i_cmd          (w_rx_cmd),      
      .o_rx_data      (w_rx_data),
      .o_rx_cmd       (w_rx_cmd_dat),
      .bitslip        (bitslip),
      .i_tri_dval     (w_tri_dval),
      .o_tristate_int (w_tristate_int)
            
    );
    

    
Cascade_IOB_block #(
        .IOSTANDARD (IOSTANDARD),
        .MODE       ("Master"),
        .LINE_NUM  (LINE_NUM),
        .DAT_OUT   (DAT_OUT),
        .REF_FREQ   (REF_FREQ),
        .DAT_IN    (DAT_IN),
        .CMD_OUT   (CMD_OUT),
        .CMD_IN    (CMD_IN)
)
Cascade_IOB_block_inst(    
        .i_clk      (i_clk_div),
        .i_delay_ce ({(DAT_IN+CMD_IN){1'b0}}),
        .i_delay_inc({(DAT_IN+CMD_IN){1'b0}}),
        .i_delay_ld ({(DAT_IN+CMD_IN){1'b1}}),
        .i_delay_val(w_delay_val),
        .b_dat_p(b_dat_p),
        .b_dat_n(b_dat_n),
        .b_cmd_p(b_cmd_p), 
        .b_cmd_n(b_cmd_n),
        .i_dat  (w_tx_dat),
        .i_cmd  (w_tx_cmd),
        .o_dat  (w_rx_dat),
        .o_cmd  (w_rx_cmd),
        .i_tristate_int(w_tristate_int)
  
    );  
    
Cascade_initial_block#(
        .MODE      ("Master"),
        .TRAN_SPEED(TRAN_SPEED),
        .LINE_NUM  (LINE_NUM),
        .DAT_OUT   (DAT_OUT),
        .DAT_IN    (DAT_IN),
        .CMD_OUT   (CMD_OUT),
        .CMD_IN    (CMD_IN),
        .SER_FACTOR(SER_FACTOR)
)
Cascade_initial_block_inst(
      .i_clk          (i_clk_div),
      .i_rst          (i_rst),
      .i_initial_req  (r_initial_req),//(i_hot_plug),//[1] cancel [0]:req
      .i_hot_plug     (r_hot_plug),//(~i_hot_plug),
      .i_rx_data      (w_rx_data),
      .i_rx_cmd       (w_rx_cmd_dat),
      .o_tx_data      (w_tx_data),
      .o_tx_cmd       (w_tx_cmd_dat),
      .o_tri_dval     (w_tri_dval_int),
      .o_rx_data      (o_rx_data),
      .o_initial_done (o_initial_done),
      .o_delay_val    (w_delay_val),
      .i_data_retrain (i_data_retrain),
      .i_cmd_retrain  (i_cmd_retrain),
      .o_bitslip      (bitslip)                                                                            
    );    




assign w_tx_pattern     = o_initial_done[2] ? i_tx_data : w_tx_data;
assign w_tri_dval       = o_initial_done[2] ? i_tri_dval : w_tri_dval_int;

assign w_tx_cmd_pattern = o_initial_done[2] ? i_tx_cmd : w_tx_cmd_dat;
assign o_rx_cmd          = w_rx_cmd_dat;
 

            
    
endmodule

