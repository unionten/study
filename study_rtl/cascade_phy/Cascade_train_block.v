module Cascade_train_block #(
        parameter MODE        = "Master",
        parameter LINE_NUM  = 10,
        parameter DAT_OUT   = 8,
        parameter DAT_IN    = 1,
        parameter CMD_OUT   = 2,
        parameter CMD_IN    = 2,
        parameter SER_FACTOR= 4
)(
      input                                                i_clk,
      input                                                i_rst,
      input                                                i_initial_req,
      input          [SER_FACTOR-1:0]                      i_rx_cmd,
      input          [SER_FACTOR-1:0]                      i_rx_data,
      
      output  reg    [SER_FACTOR-1:0]                      o_tx_cmd,
      output  reg    [SER_FACTOR-1:0]                      o_tx_data,
      output  reg    [LINE_NUM-1:0]                        o_tri_dval,
      output  reg    [CMD_IN+DAT_IN-1:0]                   o_dpa_dval,
      input          [CMD_IN+DAT_IN-1:0]                   i_dpa_done,
      input   wire                                         i_hot_plug,
      input   wire                                         i_data_retrain,
      input   wire                                         i_cmd_retrain,
      output  reg    [3:0]                                 o_train_done
);

reg [19:0] r_pattern;
reg [9:0]  r_cnt;
reg [23:0] r_cnt_dely;
reg [1:0]  r_data_retrain;
reg [1:0]  r_cmd_retrain;
reg [1:0]  r_retrain_flag;//[0]:cmd [1]:data

always @ (posedge i_clk)
if(i_rst)begin
  r_data_retrain <= 2'b0;
end else begin
  r_data_retrain[0] <= i_data_retrain;   
  r_data_retrain[1] <= r_data_retrain[0];   
end
always @ (posedge i_clk)
if(i_rst)begin
  r_cmd_retrain <= 2'b0;
end else begin
  r_cmd_retrain[0] <= i_cmd_retrain;   
  r_cmd_retrain[1] <= r_cmd_retrain[0];   
end

//(*KEEP = "TURE" *) wire i_hot_plug;

/*
//  Master :   
//            1st : CMD in put o_tri_dval: 10'b00000000_11
//            2nd : DAT output 
*/

generate
(*KEEP="ture"*)reg r_cmd_bak_test_n;
(*KEEP="ture"*)reg r_dat_bak_test_n;

(*KEEP="ture"*)reg [19:0] STATE;
if(MODE=="Master") begin
localparam IDLE          = 20'b0000_0000_0000_0000_0000;
localparam WAIT0         = 20'b0000_0000_0000_0000_0001;
localparam CMD_BAK       = 20'b0000_0000_0000_0000_0010;
localparam CMD_BAK_WAIT  = 20'b0000_0000_0000_0000_0100;
localparam DAT_TRAN      = 20'b0000_0000_0000_0000_1000;
localparam DAT_TRAN_WAIT = 20'b0000_0000_0000_0001_0000;
localparam CMD_TRAN      = 20'b0000_0000_0000_0010_0000;
localparam CMD_TRAN_WAIT = 20'b0000_0000_0000_0100_0000;
localparam DAT_TRAN_DONE = 20'b0000_0000_0000_1000_0000;
localparam DAT_BAK       = 20'b0000_0000_0001_0000_0000;
localparam DAT_BAK_WAIT  = 20'b0000_0000_0010_0000_0000;
localparam WAIT1         = 20'b0000_0000_0100_0000_0000;
localparam DONE          = 20'b0000_0000_1000_0000_0000;
localparam LINK0         = 20'b0000_0001_0000_0000_0000;
localparam LINK1         = 20'b0000_0010_0000_0000_0000;
localparam CMD_BAK_TEST  = 20'b0000_0100_0000_0000_0000;
localparam CMD_BAK_TEST1 = 20'b0000_1000_0000_0000_0000;
localparam CMD_TRAN_TEST = 20'b0001_0000_0000_0000_0000;
localparam DAT_BAK_TEST  = 20'b0010_0000_0000_0000_0000;
localparam DAT_BAK_TEST1 = 20'b0100_0000_0000_0000_0000;
localparam DAT_TRAN_TEST = 20'b1000_0000_0000_0000_0000;

always @ (posedge i_clk)
if(i_rst||i_initial_req)
  STATE <= IDLE;
else case(STATE)
   IDLE            : STATE<= i_hot_plug ? LINK0 : IDLE;
   LINK0           : STATE<= (r_cnt==10'd1000) ? LINK1 : LINK0;
   LINK1           : STATE<= WAIT0;
   WAIT0           : STATE<= (r_cnt==5'd20) ? (r_retrain_flag[1] ? DAT_BAK : CMD_BAK) : WAIT0 ;
   
   CMD_BAK         : STATE<= CMD_BAK_WAIT;
   CMD_BAK_WAIT    : STATE<= (i_dpa_done[(CMD_IN-1):0]==4'b0110) ? CMD_BAK_TEST : CMD_BAK_WAIT;
   CMD_BAK_TEST    : STATE<= ((r_cnt_dely>24'd20)&&(i_rx_cmd==4'hf)) ? CMD_BAK_TEST1 : CMD_BAK_TEST;
   CMD_BAK_TEST1   : STATE<= (r_cnt==5'd20) ? (r_cmd_bak_test_n ? CMD_BAK : CMD_TRAN) : CMD_BAK_TEST1;
   
   CMD_TRAN        : STATE<= CMD_TRAN_WAIT;
   CMD_TRAN_WAIT   : STATE<= (i_rx_data[3:0]==4'hF) ? CMD_TRAN_TEST : CMD_TRAN_WAIT;
   CMD_TRAN_TEST   : STATE<= (r_cnt_dely<24'd15000000) ? ((r_cnt_dely>=24'd14999980)&&(i_rx_cmd[3:0]==4'hF)) ? (r_retrain_flag[0] ? WAIT1 : DAT_BAK) : CMD_TRAN_TEST : CMD_TRAN ;

   DAT_BAK         : STATE<= DAT_BAK_WAIT;
   DAT_BAK_WAIT    : STATE<= (i_dpa_done[(DAT_IN+CMD_IN-1): CMD_IN]==1'b1) ? DAT_BAK_TEST : DAT_BAK_WAIT;
   DAT_BAK_TEST    : STATE<= ((r_cnt_dely>24'd20)&(i_rx_data==4'hf)) ? DAT_BAK_TEST1 : DAT_BAK_TEST;
   DAT_BAK_TEST1   : STATE<= (r_cnt==5'd20) ? (r_dat_bak_test_n ? DAT_BAK : DAT_TRAN) : DAT_BAK_TEST1;
   
   DAT_TRAN        : STATE<= DAT_TRAN_WAIT;
   DAT_TRAN_WAIT   : STATE<= (i_rx_cmd==4'hA) ? DAT_TRAN_TEST : DAT_TRAN_WAIT;
   DAT_TRAN_TEST   : STATE<= (r_cnt_dely<24'd15000000) ? ((r_cnt_dely>=24'd14999980)&&(i_rx_cmd[3:0]==4'hA)) ? DAT_TRAN_DONE : DAT_TRAN_TEST : DAT_TRAN ;
   
   DAT_TRAN_DONE   : STATE<= (r_cnt==4'd10) ? WAIT1 : DAT_TRAN_DONE;
   WAIT1           : STATE<= (r_cnt==5'd20) ? DONE : WAIT1;
   DONE            : STATE<= ((r_data_retrain==2'b01)||(r_cmd_retrain==2'b01)) ? IDLE : DONE;
   default         : STATE<= IDLE;
  endcase
  
  always @ (posedge i_clk)
if(i_rst||i_initial_req) begin
  o_tx_cmd  <= 4'h0;
  o_tx_data <= 4'h0;
  r_pattern <= 20'h003FF;
  r_retrain_flag <= 2'b0;
  r_cnt_dely     <= 24'b0;
end else case(STATE)
  IDLE            :begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= 4'h0;
                      r_pattern <= 20'h003FF;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end 
  LINK0          :begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= 4'h0;
                      r_pattern <= 20'h003FF;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end 
  LINK1           :  begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= 4'h0;
                      r_pattern <= 20'h003FF;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end     
  WAIT0           :  begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= 4'h0;
                      r_pattern <= 20'h003FF;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end                 
  CMD_BAK         :begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= 4'h0;
                      r_pattern <= 20'h003FF;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end  
  CMD_BAK_WAIT     :begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= (i_dpa_done[(CMD_IN-1):0]==4'b0110) ? 4'hF : 4'h0;
                      r_pattern <= 20'hA5A5A;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end  
  CMD_BAK_TEST     :begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= (r_cnt_dely<24'd20) ? 4'hF : 4'h0;
                      r_pattern <= (i_rx_cmd!=4'hf) ? (i_rx_cmd==4'hA) ? 20'h5A5A5 : 20'hA5A5A : r_pattern;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= r_cnt_dely+1'b1;
                    end  
  CMD_BAK_TEST1    :begin
                      o_tx_cmd  <= r_cmd_bak_test_n ? 4'h0 : 4'hf;
                      o_tx_data <= 4'h0;
                      r_pattern <= 20'h003FF;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end  
  CMD_TRAN         :begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= 4'h0;
                      r_pattern <= 20'h003FF;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end  
  CMD_TRAN_WAIT    :begin
                      o_tx_cmd  <= r_pattern[19:16];
                      o_tx_data <= 4'h0;
                      r_pattern <= {r_pattern[15:0],r_pattern[19:16]};
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end   
  CMD_TRAN_TEST    :begin
                      o_tx_cmd  <= (r_cnt_dely>=24'd14999980) ? 4'hF : r_cnt_dely[0] ? 4'hA : 4'h5;
                      o_tx_data <= 4'h0;
                      r_pattern <= 20'hA5A5A;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= r_cnt_dely + 1'b1;
                    end  
  DAT_BAK          :begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= 4'h0;
                      r_pattern <= 20'h003FF;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end 
  DAT_BAK_WAIT     :begin
                      o_tx_cmd  <= (i_dpa_done[(DAT_IN+CMD_IN-1) : CMD_IN]==1'b1) ? 4'hA : 4'h0;
                      o_tx_data <= 4'h0;
                      r_pattern <= 20'h003FF;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end
  DAT_BAK_TEST     :begin
                      o_tx_cmd  <= (r_cnt_dely<24'd20) ? 4'hA : 4'h0;
                      o_tx_data <= 4'h0;
                      r_pattern <= (i_rx_data!=4'hf) ? (i_rx_data==4'hA) ? 20'h5A5A5 : 20'hA5A5A : r_pattern;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= r_cnt_dely+1'b1;
                    end
  DAT_BAK_TEST1   :begin
                      o_tx_cmd  <= r_dat_bak_test_n ? 4'h0 : 4'hA;
                      o_tx_data <= 4'h0;
                      r_pattern <= 20'h003FF;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end 
  DAT_TRAN         :begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= 4'hF;
                      r_pattern <= 20'h003FF;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end  
  DAT_TRAN_WAIT    :begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= r_pattern[19:16];
                      r_pattern <= {r_pattern[15:0],r_pattern[19:16]};
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end  
  DAT_TRAN_TEST    :begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= (r_cnt_dely>=24'd14999980) ? 4'hF : r_cnt_dely[0] ? 4'hA : 4'h5;
                      r_pattern <= {r_pattern[15:0],r_pattern[19:16]};
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= r_cnt_dely+1'b1;
                    end  
  DAT_TRAN_DONE   :begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= 4'h0;
                      r_pattern <= 20'h003FF;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end               
  WAIT1           :begin
                      o_tx_cmd  <= 4'hF;
                      o_tx_data <= 4'hF;
                      r_pattern <= 20'h003FF;
                      r_retrain_flag <= 2'b0;
                      r_cnt_dely <= 24'b0;
                    end                     
  DONE             :begin
                      o_tx_cmd  <= 4'hF;
                      o_tx_data <= 4'hF;
                      r_pattern <= 20'h003FF;
                      r_retrain_flag <= (r_data_retrain==2'b01) ? 2'b10 : (r_cmd_retrain==2'b01) ? 2'b01 : r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end 
                  
  default          :begin
                      o_tx_cmd  <= 4'hF;
                      o_tx_data <= 4'hF;
                      r_pattern <= 20'h003FF;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end
  endcase
  
always @ (posedge i_clk)
if(i_rst||i_initial_req) begin
  o_tri_dval    <= {8'b0,5'b10110};
  o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
  o_train_done <= {i_hot_plug,3'b0};
end else case(STATE)
  IDLE          :begin
                    o_tri_dval    <= {8'b0,5'b10110};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end  
  LINK0          :begin
                    o_tri_dval    <= {8'b0,5'b10110};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end  
  LINK1         :begin
                    o_tri_dval    <= {8'b0,5'b10110};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end        
  WAIT0         :begin
                    o_tri_dval    <= {8'b0,5'b10110};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end              
  CMD_BAK       :begin
                    o_tri_dval    <= {8'b0,5'b10110};
                    o_dpa_dval    <= {{DAT_IN{1'b0}},4'b0110};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1],1'b0};
                end   
  CMD_BAK_WAIT   :begin
                    o_tri_dval    <= {8'b0,5'b10110};
                    o_dpa_dval    <= o_dpa_dval;
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end   
  CMD_BAK_TEST   :begin
                    o_tri_dval    <= {8'b0,5'b10110};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end   
  CMD_BAK_TEST1  :begin
                    o_tri_dval    <= {8'b0,5'b10110};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end              
  CMD_TRAN       :begin
                    o_tri_dval    <= {8'b0,5'b10110};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end  
  CMD_TRAN_WAIT  :begin
                    o_tri_dval    <= {8'b0,5'b10110};
                    o_dpa_dval    <= o_dpa_dval;
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end 
  CMD_TRAN_TEST  :begin
                    o_tri_dval    <= {8'b0,5'b10110};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end  
  DAT_BAK        :begin
                    o_tri_dval    <= {8'b0,5'b10110};                    
                    o_dpa_dval    <= {8'b0,1'b1,{CMD_IN{1'b0}}};
                    o_train_done <= {i_hot_plug,1'b0,1'b0,o_train_done[0]};
                end 
  DAT_BAK_WAIT   :begin
                    o_tri_dval    <= {8'b0,5'b10110};
                    o_dpa_dval    <= o_dpa_dval;
                    o_train_done <= {i_hot_plug,1'b0,1'b0,o_train_done[0]};
                end 
  DAT_BAK_TEST   :begin
                    o_tri_dval    <= {8'b0,5'b10110};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,1'b0,o_train_done[0]};
                end 
  DAT_BAK_TEST1  :begin
                    o_tri_dval    <= {8'b0,5'b10110};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,1'b0,o_train_done[0]};
                end 
  DAT_TRAN       :begin
                    o_tri_dval    <= {8'b0,5'b10110};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,1'b0,o_train_done[0]};
                end 
  DAT_TRAN_WAIT  :begin
                    o_tri_dval    <= {8'b0,5'b10110};
                    o_dpa_dval    <= o_dpa_dval;
                    o_train_done <= {i_hot_plug,1'b0,1'b0,o_train_done[0]};
                end 
  DAT_TRAN_TEST  :begin
                    o_tri_dval    <= {8'b0,5'b10110};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,1'b0,o_train_done[0]};
                end 
  DAT_TRAN_DONE  :   begin
                    o_tri_dval    <= {8'b0,5'b10110};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,1'b0,o_train_done[0]};
                end  
  WAIT1          :begin
                    o_tri_dval    <= {8'b0,5'b10110};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end             
  DONE           :begin
                    o_tri_dval    <= {8'b0,5'b10110};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= (r_data_retrain==2'b01)? {i_hot_plug,1'b1,1'b0,o_train_done[0]} : (r_cmd_retrain==2'b01) ? {i_hot_plug,1'b1,o_train_done[1],1'b0} : {i_hot_plug,3'b111};
                end   
  default        :begin
                    o_tri_dval    <= {8'b0,5'b10110};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end  
  endcase  

always @ (posedge i_clk)
if(i_rst)
  r_cnt <= 10'd0;
else  
  r_cnt <= ((STATE==DAT_TRAN_DONE)||(STATE==WAIT0)||(STATE==WAIT1)||(STATE==CMD_BAK_TEST1)||(STATE==DAT_BAK_TEST1)||((STATE==LINK0)&&i_hot_plug)) ? r_cnt + 1 : 10'd0;   

always @ (posedge i_clk)
if(i_rst)
  r_cmd_bak_test_n <= 1'd0;
else if((STATE==CMD_BAK_TEST)&&(r_cnt_dely>24'd20))
  if (i_rx_cmd!=4'hf)
    r_cmd_bak_test_n <= (i_rx_cmd!=r_pattern[19:16]) ? 1'b1 : r_cmd_bak_test_n; 
  else  
    r_cmd_bak_test_n <= r_cmd_bak_test_n; 
else if(STATE==CMD_BAK_TEST1)
  r_cmd_bak_test_n <= r_cmd_bak_test_n;   
else
  r_cmd_bak_test_n <= 1'b0;   
  
always @ (posedge i_clk)
if(i_rst)
  r_dat_bak_test_n <= 1'd0;
else if((STATE==DAT_BAK_TEST)&&(r_cnt_dely>24'd20))
  if (i_rx_data!=4'hf)
    r_dat_bak_test_n <= (i_rx_data!=r_pattern[19:16]) ? 1'b1 : r_dat_bak_test_n; 
  else  
    r_dat_bak_test_n <= r_dat_bak_test_n; 
else if(STATE==DAT_BAK_TEST1)
  r_dat_bak_test_n <= r_dat_bak_test_n;   
else
  r_dat_bak_test_n <= 1'b0;   
  
end else begin
localparam  IDLE          = 20'b0000_0000_0000_0000_0000;  
localparam  CMD_TRAN      = 20'b0000_0000_0000_0000_0001;  
localparam  CMD_TRAN_WAIT = 20'b0000_0000_0000_0000_0010;    
localparam  DAT_BAK       = 20'b0000_0000_0000_0000_0100;    
localparam  DAT_BAK_WAIT  = 20'b0000_0000_0000_0000_1000; 
localparam  DAT_BAK_DONE  = 20'b0000_0000_0000_0001_0000;  
localparam  CMD_BAK       = 20'b0000_0000_0000_0010_0000;    
localparam  CMD_BAK_WAIT  = 20'b0000_0000_0000_0100_0000;    
localparam  DAT_TRAN      = 20'b0000_0000_0000_1000_0000;    
localparam  DAT_TRAN_WAIT = 20'b0000_0000_0001_0000_0000; 
localparam  WAIT          = 20'b0000_0000_0010_0000_0000;    
localparam  DONE          = 20'b0000_0000_0100_0000_0000; 
localparam  LINK0         = 20'b0000_0001_0000_0000_0000;
localparam  LINK1         = 20'b0000_0010_0000_0000_0000;   
localparam  CMD_BAK_TEST  = 20'b0000_0100_0000_0000_0000;
localparam  CMD_BAK_TEST1 = 20'b0000_1000_0000_0000_0000;
localparam  CMD_TRAN_TEST = 20'b0001_0000_0000_0000_0000;
localparam  DAT_BAK_TEST  = 20'b0010_0000_0000_0000_0000;
localparam  DAT_BAK_TEST1 = 20'b0100_0000_0000_0000_0000;
localparam  DAT_TRAN_TEST = 20'b1000_0000_0000_0000_0000;


  always @ (posedge i_clk)
if(i_rst||i_initial_req)
  STATE <= IDLE;
else case(STATE)
   IDLE           : STATE <= i_hot_plug ? LINK0 : IDLE;
   LINK0          : STATE <= (r_cnt==10'd1000) ? LINK1 : LINK0;
   LINK1          : STATE <= r_retrain_flag[1] ? DAT_TRAN : CMD_TRAN;
   
   CMD_TRAN       : STATE <= CMD_TRAN_WAIT;
   CMD_TRAN_WAIT  : STATE <= (i_rx_data[3:0]==4'hF) ? CMD_TRAN_TEST : CMD_TRAN_WAIT;
   CMD_TRAN_TEST  : STATE <= (r_cnt_dely<24'd15000000) ? ((r_cnt_dely>24'd14999980)&&(i_rx_cmd[3:0]==4'hF)) ? CMD_BAK : CMD_TRAN_TEST : CMD_TRAN;
   
   CMD_BAK        : STATE <= CMD_BAK_WAIT;
   CMD_BAK_WAIT   : STATE <= (i_dpa_done[(CMD_IN-1):0]==4'b1001) ? CMD_BAK_TEST : CMD_BAK_WAIT;
   CMD_BAK_TEST   : STATE <= ((r_cnt_dely>24'd20)&(i_rx_cmd==4'hf)) ? CMD_BAK_TEST1 : CMD_BAK_TEST;
   CMD_BAK_TEST1  : STATE <= (r_cnt==5'd20) ? (r_cmd_bak_test_n ? CMD_BAK : (r_retrain_flag[0] ? WAIT : DAT_TRAN)) : CMD_BAK_TEST1;                         
   
   DAT_TRAN       : STATE <= DAT_TRAN_WAIT;
   DAT_TRAN_WAIT  : STATE <= (i_rx_cmd== 4'hA) ? DAT_TRAN_TEST : DAT_TRAN_WAIT;
   DAT_TRAN_TEST  : STATE <= (r_cnt_dely<24'd15000000) ? ((r_cnt_dely>24'd14999980)&&(i_rx_cmd[3:0]==4'hA)) ? DAT_BAK : DAT_TRAN_TEST : DAT_TRAN;
   
   DAT_BAK        : STATE <= DAT_BAK_WAIT;
   DAT_BAK_WAIT   : STATE <= (i_dpa_done[(DAT_IN+CMD_IN-1) : CMD_IN]==9'b1111_1111_0) ? DAT_BAK_TEST : DAT_BAK_WAIT;
   DAT_BAK_TEST   : STATE <= ((r_cnt_dely>24'd20)&(i_rx_data==4'hf)) ? DAT_BAK_TEST1 : DAT_BAK_TEST;
   DAT_BAK_TEST1  : STATE <= (r_cnt==10'd20) ? (r_dat_bak_test_n ? DAT_BAK : DAT_BAK_DONE) : DAT_BAK_TEST1;
   
   DAT_BAK_DONE   : STATE <= (r_cnt==10'd30) ? WAIT : DAT_BAK_DONE;
   WAIT           : STATE <= (r_cnt==10'd40) ? DONE : WAIT; 
   DONE           : STATE <= ((r_data_retrain==2'b01)||(r_cmd_retrain==2'b01)) ? IDLE : DONE;

   default        : STATE<= IDLE;
  endcase
  always @ (posedge i_clk)
if(i_rst||i_initial_req) begin
  o_tx_cmd  <= 4'h0;
  o_tx_data <= 4'h0;
  r_pattern <= 20'h003FF;
  r_retrain_flag <= 2'b0;
  r_cnt_dely <= 24'b0;
end else case(STATE)
  IDLE            :begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= 4'h0;
                      r_pattern <= 20'h003FF;
                      //r_pattern <= 20'h33333;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end 
  LINK0            :begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= 4'h0;
                      r_pattern <= 20'h003FF;
                      //r_pattern <= 20'h33333;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end 
  LINK1            :begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= 4'h0;
                      r_pattern <= 20'h003FF;
                      //r_pattern <= 20'h33333;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end                                         
  CMD_TRAN         :begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= 4'h0;
                      r_pattern <= 20'h003FF;
                      //r_pattern <= 20'h33333;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end  
  CMD_TRAN_WAIT    :begin
                      o_tx_cmd  <= r_pattern[19:16];
                      o_tx_data <= 4'h0;
                      r_pattern <= {r_pattern[15:0],r_pattern[19:16]};
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end 
  CMD_TRAN_TEST    :begin
                      o_tx_cmd  <= (r_cnt_dely>=24'd14999980) ? 4'hF : r_cnt_dely[0] ? 4'hA : 4'h5;
                      o_tx_data <= 4'h0;
                      r_pattern <= r_cnt_dely[0] ? 20'hA5A5A : 20'h5A5A5;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= r_cnt_dely + 1'b1;
                    end   
  CMD_BAK         :begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= 4'h0;
                      r_pattern <= 20'h003FF;
                      //r_pattern <= 20'h33333;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end  
  CMD_BAK_WAIT     :begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= (i_dpa_done[CMD_IN-1:0]==4'b1001) ? 4'hF : 4'h0;
                      r_pattern <= 20'h003FF;
                      //r_pattern <= 20'h33333;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end 
  CMD_BAK_TEST     :begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= (r_cnt_dely<24'd20) ? 4'hF : 4'h0;
                      r_pattern <= (i_rx_cmd!=4'hf) ? (i_rx_cmd==4'hA) ? 20'h5A5A5 : 20'hA5A5A : r_pattern;
                      //r_pattern <= 20'h33333;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= r_cnt_dely + 1'b1;
                    end 
  CMD_BAK_TEST1    :begin
                      o_tx_cmd  <= r_cmd_bak_test_n ? 4'h0 : 4'hf;
                      o_tx_data <= 4'h0;
                      r_pattern <= 20'h003FF;
                      //r_pattern <= 20'h33333;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end                              
  DAT_TRAN         :begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= 4'hA;
                      r_pattern <= 20'h003FF;
                      //r_pattern <= 20'h33333;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end  
  DAT_TRAN_WAIT    :begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= r_pattern[19:16];
                      r_pattern <= {r_pattern[15:0],r_pattern[19:16]};
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end   
  DAT_TRAN_TEST    :begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= (r_cnt_dely>=24'd14999980) ? 4'hF : r_cnt_dely[0] ? 4'hA : 4'h5;
                      r_pattern <= {r_pattern[15:0],r_pattern[19:16]};
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= r_cnt_dely+1'b1;
                    end    
  DAT_BAK          :begin
                      o_tx_cmd  <= r_pattern[19:16];
                      o_tx_data <= 4'h0;
                      r_pattern <= 20'h003FF;
                      //r_pattern <= 20'h33333;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end 
  DAT_BAK_WAIT     :begin
                      o_tx_cmd  <= (i_dpa_done[(DAT_IN+CMD_IN-1) : CMD_IN]==9'b1111_1111_0) ? 4'hA : r_pattern[19:16];
                      o_tx_data <= 4'h0;
                      r_pattern <= {r_pattern[15:0],r_pattern[19:16]};
                      //r_pattern <= 20'h33333;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end 
  DAT_BAK_TEST     :begin
                      o_tx_cmd  <= (r_cnt_dely<24'd20) ? 4'hA : 4'h0;
                      o_tx_data <= 4'h0;
                      r_pattern <= (i_rx_data!=4'hf) ? (i_rx_data==4'hA) ? 20'h5A5A5 : 20'hA5A5A : r_pattern;
                      //r_pattern <= 20'h33333;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= r_cnt_dely + 24'b1;
                    end 
  DAT_BAK_TEST1    :begin
                      o_tx_cmd  <= r_dat_bak_test_n ? 4'h0 : 4'hA;
                      o_tx_data <= 4'h0;
                      r_pattern <= {r_pattern[15:0],r_pattern[19:16]};
                      //r_pattern <= 20'h33333;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end                          
  DAT_BAK_DONE    :begin
                      o_tx_cmd  <= 4'h0;
                      o_tx_data <= 4'h0;
                      r_pattern <= 20'h003FF;
                      //r_pattern <= 20'h33333;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end 
  WAIT            :begin  
                      o_tx_cmd  <= 4'hF;
                      o_tx_data <= 4'hF;
                      r_pattern <= 20'h003FF;
                      //r_pattern <= 20'h33333;
                      r_retrain_flag <= 2'b0;
                      r_cnt_dely <= 24'b0;
                    end                 
  DONE             :begin
                      o_tx_cmd  <= 4'hF;
                      o_tx_data <= 4'hF;
                      r_pattern <= 20'h003FF;
                      //r_pattern <= 20'h33333;
                      r_retrain_flag <= (r_data_retrain==2'b01) ? 2'b10 : (r_cmd_retrain==2'b01) ? 2'b01 : r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end 
  default          :begin
                      o_tx_cmd  <= 4'hF;
                      o_tx_data <= 4'hF;
                      r_pattern <= 20'h003FF;
                      //r_pattern <= 20'h33333;
                      r_retrain_flag <= r_retrain_flag;
                      r_cnt_dely <= 24'b0;
                    end
  endcase




  always @ (posedge i_clk)
if(i_rst||i_initial_req) begin
  o_tri_dval    <={8'b1111_1111,5'b01001};
  o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
  o_train_done <= {i_hot_plug,3'b0};
end else case(STATE)
  IDLE          :begin
                    o_tri_dval    <={8'b1111_1111,5'b01001};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end  
  LINK0         :  begin
                    o_tri_dval    <={8'b1111_1111,5'b01001};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end
  LINK1         :  begin
                    o_tri_dval    <={8'b1111_1111,5'b01001};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end                                    
  CMD_TRAN       :begin
                    o_tri_dval    <={8'b1111_1111,5'b01001};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1],1'b0};
                end  
  CMD_TRAN_WAIT  :begin
                    o_tri_dval    <={8'b1111_1111,5'b01001};
                    o_dpa_dval    <= o_dpa_dval;
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end   
  CMD_TRAN_TEST  :begin
                    o_tri_dval    <={8'b1111_1111,5'b01001};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end 
  CMD_BAK       :begin
                    o_tri_dval    <={8'b1111_1111,5'b01001};                    
                    o_dpa_dval    <= {{DAT_IN{1'b0}},4'b1001};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end   
  CMD_BAK_WAIT   :begin
                    o_tri_dval    <={8'b1111_1111,5'b01001};
                    o_dpa_dval    <= o_dpa_dval;
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                 end
  CMD_BAK_TEST   :begin
                    o_tri_dval    <={8'b1111_1111,5'b01001};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end  
  CMD_BAK_TEST1  :begin
                    o_tri_dval    <={8'b1111_1111,5'b01001};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end  
  DAT_TRAN       :begin
                    o_tri_dval    <={8'b1111_1111,5'b01001};
                    o_dpa_dval    <= {{DAT_IN{1'b0}},{CMD_IN{1'b0}}};
                    o_train_done <= {i_hot_plug,1'b0,1'b0,o_train_done[0]};
                end 
  DAT_TRAN_WAIT  :begin
                    o_tri_dval    <={8'b1111_1111,5'b01001};
                    o_dpa_dval    <= o_dpa_dval;
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end 
  DAT_TRAN_TEST  :begin
                    o_tri_dval    <={8'b1111_1111,5'b01001};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end 
  DAT_BAK        :begin
                    o_tri_dval    <= {8'b1111_1111,5'b01001};
                    o_dpa_dval    <= {8'b1111_1111,5'b0};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end 
  DAT_BAK_WAIT   :begin
                    o_tri_dval    <={8'b1111_1111,5'b01001};
                    o_dpa_dval    <= o_dpa_dval;
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end 
  DAT_BAK_TEST   :begin
                    o_tri_dval    <={8'b1111_1111,5'b01001};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end 
  DAT_BAK_TEST1   :begin
                    o_tri_dval    <={8'b1111_1111,5'b01001};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end 
  DAT_BAK_DONE  :begin
                    o_tri_dval    <={8'b1111_1111,5'b01001};
                    o_dpa_dval    <= o_dpa_dval;
                    o_train_done <= {i_hot_plug,1'b0,1'b0,o_train_done[0]};
                end               
  WAIT          :begin
                    o_tri_dval    <={8'b1111_1111,5'b01001};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end  
  DONE           :begin
                    o_tri_dval    <={8'b1111_1111,5'b01001};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= (r_data_retrain==2'b01)? {i_hot_plug,1'b1,1'b0,o_train_done[0]} : (r_cmd_retrain==2'b01) ? {i_hot_plug,1'b1,o_train_done[1],1'b0} : {i_hot_plug,3'b111};
                end   
  default        :begin
                    o_tri_dval    <= {8'b1111_1111,5'b01001};
                    o_dpa_dval    <= {(CMD_IN+DAT_IN){1'b0}};
                    o_train_done <= {i_hot_plug,1'b0,o_train_done[1:0]};
                end  
  endcase  
  
  always @ (posedge i_clk)
if(i_rst)
  r_cnt <= 10'd0;
else  
  r_cnt <= ((STATE==DAT_BAK_DONE)||(STATE==WAIT)||(STATE==CMD_BAK_TEST1)||(STATE==DAT_BAK_TEST1)||((STATE==LINK0)&&i_hot_plug)) ? r_cnt + 1 : 10'd0;   
 
always @ (posedge i_clk)
if(i_rst)
  r_cmd_bak_test_n <= 1'd0;
else if((STATE==CMD_BAK_TEST)&&(r_cnt_dely>24'd20))
  if (i_rx_cmd!=4'hf)
    r_cmd_bak_test_n <= (i_rx_cmd!=r_pattern[19:16]) ? 1'b1 : r_cmd_bak_test_n; 
  else  
    r_cmd_bak_test_n <= r_cmd_bak_test_n; 
else if(STATE==CMD_BAK_TEST1)
  r_cmd_bak_test_n <= r_cmd_bak_test_n;   
else
  r_cmd_bak_test_n <= 1'b0;   
  
always @ (posedge i_clk)
if(i_rst)
  r_dat_bak_test_n <= 1'd0;
else if((STATE==DAT_BAK_TEST)&&(r_cnt_dely>24'd20))
  if (i_rx_data!=4'hf)
    r_dat_bak_test_n <= (i_rx_data!=r_pattern[19:16]) ? 1'b1 : r_dat_bak_test_n; 
  else  
    r_dat_bak_test_n <= r_dat_bak_test_n; 
else if(STATE==DAT_BAK_TEST1)
  r_dat_bak_test_n <= r_dat_bak_test_n;   
else
  r_dat_bak_test_n <= 1'b0; 


  
end //generate "if"'s end
endgenerate    
  
             
  
endmodule                   

  
