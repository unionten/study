`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2021/06/24 13:11:47
// Module Name: handshake_sync
//////////////////////////////////////////////////////////////////////////////////
//handshake_sync #(.C_DATA_WIDTH(32)) hs_u0(
//    .SRC_CLK_I        (),
//    .SRC_RST_I        (),
//    .SRC_DATA_I       (),//[C_DATA_WIDTH-1:0]
//    .SRC_SYNC_PULSE_I (),
//    .SRC_SYNC_FINISH_O(),
//    .DST_CLK_I        (),
//    .DST_DATA_O       (),//[C_DATA_WIDTH-1:0]
//    .DST_SYNC_FINISH_O());

module handshake_2016
#( parameter C_DATA_WIDTH = 32 )
(
input   SRC_CLK_I,
input   SRC_RST_I,
input   [C_DATA_WIDTH-1:0] SRC_DATA_I,
input   SRC_SYNC_PULSE_I,
output  SRC_SYNC_FINISH_O,
/////////////////////////////////////
input   DST_CLK_I,
output  [C_DATA_WIDTH-1:0] DST_DATA_O,
output  DST_SYNC_FINISH_O
);
//////////////////////////////////////////////////////////////////////////////////
reg  [C_DATA_WIDTH-1:0] Data_src;
reg  Sync_flag = 0;
wire sync_finish;
always @(posedge SRC_CLK_I) begin
    if(SRC_RST_I) begin
    	Data_src  <= 0; 
        Sync_flag <= 0;
    end 
    else if(SRC_SYNC_PULSE_I) begin
    	Data_src  <= SRC_DATA_I;
        Sync_flag <= 1;
    end	
    else if(sync_finish)begin
       if(sync_finish)Sync_flag <= 0;//reset after sync finish
    end
end
xpm_cdc_handshake #(
    .DEST_EXT_HSK   (0), 
    .DEST_SYNC_FF   (4), 
    //.INIT_SYNC_FF   (0), 
    .SIM_ASSERT_CHK (0), 
    .SRC_SYNC_FF    (4), 
    .WIDTH     (C_DATA_WIDTH))
    r_mode_sync_u0(
    .src_clk  (SRC_CLK_I  ),
    .src_in   (Data_src   ),
    .src_send (Sync_flag  ),
    .src_rcv  (sync_finish),//syn finish flag in sender
    .dest_clk (DST_CLK_I  ),
    .dest_req (DST_SYNC_FINISH_O),
    .dest_ack (), // optional; required when DEST_EXT_HSK = 1
    .dest_out (DST_DATA_O));
assign SRC_SYNC_FINISH_O = sync_finish;
     

endmodule
