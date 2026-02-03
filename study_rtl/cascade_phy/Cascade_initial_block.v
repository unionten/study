`timescale 1ns / 1ps
module Cascade_initial_block #(
        parameter MODE      = "Slave",
        parameter TRAN_SPEED = 800,
        parameter LINE_NUM  = 10,
        parameter DAT_OUT   = 8,
        parameter DAT_IN    = 8,
        parameter CMD_OUT   = 2,
        parameter CMD_IN    = 2,
        parameter SER_FACTOR= 4
)(
      input                                     i_clk,
      input                                     i_rst,
      input                                     i_initial_req,//[1] cancel [0]:req
      input        [DAT_IN*SER_FACTOR-1:0]      i_rx_data,
      input        [CMD_IN*SER_FACTOR-1:0]      i_rx_cmd,
      
      output  wire [DAT_OUT*SER_FACTOR-1:0]     o_tx_data,
      output  wire [CMD_OUT*SER_FACTOR-1:0]     o_tx_cmd,
      output  wire [LINE_NUM-1:0]               o_tri_dval,

      output  wire [3:0]                        o_initial_done,
      output  wire [SER_FACTOR-1:0]             o_rx_data,           

      output  wire [(CMD_IN+DAT_IN)*5-1:0]      o_delay_val,
      input                                     i_hot_plug,
      input                                     i_data_retrain,
      input                                     i_cmd_retrain,
      output  wire [CMD_IN+DAT_IN-1:0]          o_bitslip 
    );


       
//(*KEEP = "TURE" *) wire i_hot_plug;
(*KEEP="ture"*)wire [DAT_IN*SER_FACTOR-1:0]       w_rx_data;
(*KEEP="ture"*)wire [CMD_IN*SER_FACTOR-1:0]       w_rx_cmd;                
(*KEEP="ture"*)wire [SER_FACTOR-1:0]              w_tx_data;
(*KEEP="ture"*)wire [SER_FACTOR-1:0]              w_tx_cmd;
(*KEEP="ture"*)wire [DAT_IN+CMD_IN-1:0]           w_dpa_dval;
(*KEEP="ture"*)wire [DAT_IN+CMD_IN-1:0]           w_dpa_done;            
(*KEEP="ture"*)wire [LINE_NUM-1:0]                w_tri_dval;         
(*KEEP="ture"*)wire [3:0]                         w_initial_done;      
(*KEEP="ture"*)wire [(CMD_IN+DAT_IN)*5-1:0]       w_delay_val;      
(*KEEP="ture"*)wire [CMD_IN+DAT_IN-1:0]           w_bitslip ;   

(*KEEP="ture"*)wire [SER_FACTOR-1:0]              w_train_data;    
(*KEEP="ture"*)wire [SER_FACTOR-1:0]              w_train_cmd;    

assign o_rx_data = w_rx_data[3:0];
Cascade_train_block #(
        .MODE      (MODE),
        .LINE_NUM  (LINE_NUM),
        .DAT_OUT   (DAT_OUT),
        .DAT_IN    (DAT_IN),
        .CMD_OUT   (CMD_OUT),
        .CMD_IN    (CMD_IN),
        .SER_FACTOR(SER_FACTOR)
)
Cascade_train_block_inst(
      .i_clk         (i_clk),
      .i_rst         (i_rst),
      .i_initial_req (i_initial_req),
      .i_rx_cmd      (w_train_cmd),
      .i_rx_data     (w_train_data),
      
      .o_tx_cmd      (w_tx_cmd),
      .o_tx_data     (w_tx_data),
      .o_tri_dval    (w_tri_dval),
      .o_dpa_dval    (w_dpa_dval),
      .i_dpa_done    (w_dpa_done),
      .i_hot_plug    (i_hot_plug),
      .i_data_retrain(i_data_retrain),
      .i_cmd_retrain (i_cmd_retrain),
      .o_train_done  (w_initial_done)
);   


genvar data;
generate if (MODE=="Master") begin
  assign w_train_data  = w_rx_data[3:0];    
  assign w_train_cmd   = w_rx_cmd[7:4];
end else begin
  assign w_train_data  = w_rx_data[7:4];    
  assign w_train_cmd   = w_rx_cmd[3:0];
end
endgenerate        


genvar dat_in;
genvar dat_out;
generate for(dat_in = 0; dat_in < DAT_IN; dat_in= dat_in+1) begin :DPA_dat
  assign w_rx_data[dat_in*4+3:dat_in*4] = {i_rx_data[DAT_IN*3+dat_in],i_rx_data[DAT_IN*2+dat_in],i_rx_data[DAT_IN*1+dat_in],i_rx_data[DAT_IN*0+dat_in]};
  Bit_Align_block #(
        .TRAN_SPEED(TRAN_SPEED),
        .SER_FACTOR(SER_FACTOR)
)
Bit_Align_block_dat(
      .i_clk(i_clk),
      .i_rst(i_rst),
      .i_dpa_req(w_dpa_dval[dat_in+CMD_IN]),//[1] cancel [0]:req
      .i_rx_data(w_rx_data[dat_in*4+3:dat_in*4]),
      .i_initial_done(w_initial_done[2]),  
      .o_bitalign_done(w_dpa_done[dat_in+CMD_IN]),
      
      .o_bitslip(w_bitslip[dat_in+CMD_IN]),                                                                     
      .o_delay_val(w_delay_val[(dat_in+CMD_IN)*5+4:(dat_in+CMD_IN)*5])                                                                                
);
end
for(dat_out = 0; dat_out < DAT_OUT; dat_out= dat_out+1) begin :DPA_out
  assign o_tx_data[DAT_OUT*3+dat_out] = w_tx_data[3];
  assign o_tx_data[DAT_OUT*2+dat_out] = w_tx_data[2];
  assign o_tx_data[DAT_OUT*1+dat_out] = w_tx_data[1];
  assign o_tx_data[DAT_OUT*0+dat_out] = w_tx_data[0];
end  
endgenerate


genvar cmd_in;
genvar cmd_out;
generate for(cmd_in = 0; cmd_in < CMD_IN ; cmd_in = cmd_in+1) begin :DPA_cmd
  assign w_rx_cmd[cmd_in*4+3:cmd_in*4] = {i_rx_cmd[CMD_IN*3+cmd_in],i_rx_cmd[CMD_IN*2+cmd_in],i_rx_cmd[CMD_IN*1+cmd_in],i_rx_cmd[CMD_IN*0+cmd_in]};
  Bit_Align_block #(        
        .TRAN_SPEED(TRAN_SPEED),
        .SER_FACTOR(SER_FACTOR)
)
Bit_Align_block_cmd(
      .i_clk(i_clk),
      .i_rst(i_rst),
      .i_dpa_req(w_dpa_dval[cmd_in]),//[1] cancel [0]:req
      .i_rx_data(w_rx_cmd[cmd_in*4+3:cmd_in*4]),  
      .i_initial_done(w_initial_done[2]),  
      .o_bitalign_done(w_dpa_done[cmd_in]),
      
      .o_bitslip(w_bitslip[cmd_in]),                                                                     
      .o_delay_val(w_delay_val[cmd_in*5+4:cmd_in*5])                                                                                
);
end
for(cmd_out = 0; cmd_out < CMD_OUT ; cmd_out = cmd_out+1) begin :DPA_cmd_out
  assign o_tx_cmd[CMD_OUT*3+cmd_out] = w_tx_cmd[3];
  assign o_tx_cmd[CMD_OUT*2+cmd_out] = w_tx_cmd[2];
  assign o_tx_cmd[CMD_OUT*1+cmd_out] = w_tx_cmd[1];
  assign o_tx_cmd[CMD_OUT*0+cmd_out] = w_tx_cmd[0];
end  
endgenerate

assign o_tri_dval    =   w_tri_dval;                    
assign o_initial_done=   w_initial_done;                  
assign o_delay_val   =   w_delay_val;
assign o_bitslip     =   w_bitslip;  

    

  
  
    
    
endmodule
