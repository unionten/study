module Bit_Align_block #(
        parameter TRAN_SPEED = 800,
        parameter SER_FACTOR= 4
)(
      input                                   i_clk,
      input                                   i_rst,
      input                                   i_dpa_req,//[1] cancel [0]:req
      input   [SER_FACTOR-1:0]                i_rx_data,  
      input                                   i_initial_done,
      output reg                              o_bitalign_done,
      
      output wire                             o_bitslip,                                                                     
      output reg  [4:0]                       o_delay_val                                                                                
);



(*mark_debug="ture"*)reg [4:0]             r_delay_val1;
(*mark_debug="ture"*)reg [4:0]             r_delay_val2;
reg [SER_FACTOR-1:0]  r_rx_data;
(*mark_debug="ture"*)wire [2:0]            edge_info;
(*mark_debug="ture"*)reg  [2:0]            r_edge_info;
reg  [2:0]            r_count;

(*mark_debug="ture"*)wire [4:0]            w_delay_val;

assign edge_info[0] = i_rx_data[0] ^ i_rx_data[1];
assign edge_info[1] = i_rx_data[1] ^ i_rx_data[2];
assign edge_info[2] = i_rx_data[2] ^ i_rx_data[3];   

(*mark_debug="ture"*)reg [6:0]  state;
always @ (posedge i_clk)
if(i_rst)
  state <= 4'd0;
else case(state)
  6'd0 : state <= (i_dpa_req&&(i_rx_data==4'hf)) ? 6'd33 : 6'd0;
  6'd1 : state <= ((edge_info==3'b100)||(edge_info==3'b010)) ? 6'd2 : 6'd29;
  6'd29: state <= ((edge_info==3'b100)||(edge_info==3'b010)) ? 6'd2 : 6'd30;
  6'd30: state <= ((edge_info==3'b100)||(edge_info==3'b010)) ? 6'd2 : 6'd31;
  6'd31: state <= ((edge_info==3'b100)||(edge_info==3'b010)) ? 6'd2 : 6'd32;
  6'd32: state <= ((edge_info==3'b100)||(edge_info==3'b010)) ? 6'd2 : 6'd33;
  6'd33: state <= (edge_info==3'b0) ? 6'd33 : 6'd34;
  6'd34: state <= (edge_info==3'b0) ? 6'd34 : 6'd35;
  6'd35: state <= (edge_info==3'b0) ? 6'd35 : 6'd36;
  6'd36: state <= (edge_info==3'b0) ? 6'd36 : 6'd37;
  6'd37: state <= 6'd1;
  6'd2 : state <= 6'd3; //INC
  6'd3 : state <= 6'd4;
  6'd4 : state <= 6'd5;
  6'd5 : state <= 6'd6;
  6'd6 : state <= 6'd7;
  6'd7 : state <= 6'd8 ;
  6'd8 : state <= 6'd9 ;
  6'd9 : state <= 6'd10;
  6'd10: state <= 6'd11;
  6'd11: state <= (edge_info==(r_edge_info>>1)) ? 6'd12 : 6'd2;
  6'd12: state <= 6'd13;//INC
  6'd13: state <= 6'd14;
  6'd14: state <= 6'd15;
  6'd15: state <= 6'd16;
  6'd16: state <= 6'd27;
  6'd17: state <= 6'd18 ;
  6'd18: state <= 6'd19 ;
  6'd19: state <= 6'd20 ;
  6'd20: state <= 6'd21 ;
  6'd21: state <= (edge_info==(r_edge_info>>1)) ? 6'd22 : 6'd12;
  6'd22: state <= 6'd23;
  6'd23: state <= 6'd25;
  6'd25: state <= 6'd26;
  6'd26: state <= 6'd27;
  6'd27: state <= (i_rx_data == 4'b0011) ? 6'd45 : 6'd38;
  6'd38: state <= (i_rx_data == 4'b0011) ? 6'd45 : 6'd39;
  6'd39: state <= (i_rx_data == 4'b0011) ? 6'd45 : 6'd40;
  6'd40: state <= (i_rx_data == 4'b0011) ? 6'd45 : 6'd41;
  6'd41: state <= (i_rx_data == 4'b0011) ? 6'd45 : 6'd42;
  6'd42: state <= 6'd43;
  6'd43: state <= 6'd44;
  6'd44: state <= 6'd27;
  6'd45: state <= (r_count==3'd4) ? 6'd28 : 6'd27;
  6'd28: state <= (i_initial_done||(i_rx_data == 4'b0101)) ? 6'd0 : 6'd28;
  default:state <= 6'd0;
endcase


always @ (posedge i_clk)
if(i_rst)
  r_count <= 3'd0;
else case(state)
  6'd27:  r_count <= (i_rx_data == 4'b0011) ? r_count + 1'd1 : r_count;
  6'd38:  r_count <= (i_rx_data == 4'b0011) ? r_count + 1'd1 : r_count;
  6'd39:  r_count <= (i_rx_data == 4'b0011) ? r_count + 1'd1 : r_count;
  6'd40:  r_count <= (i_rx_data == 4'b0011) ? r_count + 1'd1 : r_count;
  6'd41:  r_count <= (i_rx_data == 4'b0011) ? r_count + 1'd1 : r_count;
  6'd42:  r_count <= 3'd0;
  6'd43:  r_count <= r_count;
  6'd44:  r_count <= r_count; 
  6'd45:  r_count <= r_count;
  6'd28:  r_count <= 3'd0;
  default:r_count <= 3'd0;
endcase



//r_edge_info 
always @ (posedge i_clk)
if(i_rst)
  r_edge_info <= 3'b0;
else case(state)
  6'd0 : r_edge_info <= 3'b0;
  6'd1 : r_edge_info <= edge_info;
  6'd29: r_edge_info <= edge_info;
  6'd30: r_edge_info <= edge_info;
  6'd31: r_edge_info <= edge_info;
  6'd32: r_edge_info <= edge_info;
  6'd11: r_edge_info <= (edge_info==(r_edge_info>>1)) ? edge_info : r_edge_info;
  6'd21: r_edge_info <= (edge_info==(r_edge_info>>1)) ? edge_info : r_edge_info;
  default:  r_edge_info <= r_edge_info;
  endcase    

always @ (posedge i_clk)
if(i_rst) begin
  r_delay_val1 <= 5'd0;
  r_delay_val2 <= 5'd0;
end else case(state)
  6'd0 : begin r_delay_val1 <= r_delay_val1; r_delay_val2 <= r_delay_val2;  end
  6'd11: begin r_delay_val1 <= (edge_info==(r_edge_info>>1))  ? o_delay_val : r_delay_val1; r_delay_val2 <= r_delay_val2;end
  6'd21: begin r_delay_val1 <= r_delay_val1; r_delay_val2 <= (edge_info==(r_edge_info>>1))  ? o_delay_val : r_delay_val2;  end
  default:begin r_delay_val1 <= r_delay_val1; r_delay_val2 <= r_delay_val2;end
endcase  


//o_delay_val
always @ (posedge i_clk)
if(i_rst) 
    o_delay_val <= 5'd0;
else case(state)
    6'd0 : o_delay_val <= o_delay_val;
    6'd1 : o_delay_val <= o_delay_val;
    6'd2 : o_delay_val <= o_delay_val + 1'd1;
    //6'd12: o_delay_val <= (r_delay_val1 > (w_delay_val/2)) ? o_delay_val - (w_delay_val/2) : o_delay_val + (w_delay_val/2) ;
    6'd12: o_delay_val <= (r_delay_val1 >=16) ? o_delay_val - (w_delay_val/2) : o_delay_val + (w_delay_val/2) ;
    6'd33: o_delay_val <= 5'd0;
    6'd22 : o_delay_val <= (r_delay_val1 + r_delay_val2)/2;
    default : o_delay_val <= o_delay_val;
  endcase

always @ (posedge i_clk)
if(i_rst) 
  o_bitalign_done <= 1'b0;
else 
  o_bitalign_done <= (state == 6'd28) ? 1'b1 : 1'b0;//o_bitalign_done;
  

assign   o_bitslip = (state == 6'd42) ? 1'b1 : 1'b0;


//genvar delay_val;
generate 
  case(TRAN_SPEED)
    500  : assign w_delay_val = 5'd26;//ref=200M 
    600  : assign w_delay_val = 5'd22;//ref=200M 
    700  : assign w_delay_val = 5'd28;//ref=300M 
    800  : assign w_delay_val = 5'd24;//ref=300M 
    900  : assign w_delay_val = 5'd21;//ref=300M 
    1000 : assign w_delay_val = 5'd19;//ref=300M 
    default    : assign w_delay_val = 5'd0;
  endcase  
endgenerate  

//generate 
//  if       (TRAN_SPEED > 16'd2030)   assign w_delay_val = 5'hA;  //Ref 300Mhz
//  else if (TRAN_SPEED > 16'd1836)  assign w_delay_val = 5'hB;  //Ref 300Mhz
//  else if (TRAN_SPEED > 16'd1675)  assign w_delay_val = 5'hC;  //Ref 300Mhz
//  else if (TRAN_SPEED > 16'd1541)  assign w_delay_val = 5'hD;  //Ref 300Mhz
//  else if (TRAN_SPEED > 16'd1426)  assign w_delay_val = 5'hE;  //Ref 300Mhz
//  else if (TRAN_SPEED > 16'd1328)  assign w_delay_val = 5'hF;  //Ref 300Mhz
//  else if (TRAN_SPEED > 16'd1242)  assign w_delay_val = 5'h10; //Ref 300Mhz
//  else if (TRAN_SPEED > 16'd1167)  assign w_delay_val = 5'h11; //Ref 300Mhz
//  else if (TRAN_SPEED > 16'd1100)  assign w_delay_val = 5'h12; //Ref 300Mhz
//  else if (TRAN_SPEED > 16'd1040)  assign w_delay_val = 5'h13; //Ref 300Mhz
//  else if (TRAN_SPEED > 16'd987)   assign w_delay_val = 5'h14; //Ref 300Mhz
//  else if (TRAN_SPEED > 16'd939)   assign w_delay_val = 5'h15; //Ref 300Mhz
//  else if (TRAN_SPEED > 16'd895)   assign w_delay_val = 5'h16; //Ref 300Mhz
//  else if (TRAN_SPEED > 16'd855)   assign w_delay_val = 5'h17; //Ref 300Mhz
//  else if (TRAN_SPEED > 16'd819)   assign w_delay_val = 5'h18; //Ref 300Mhz
//  else if (TRAN_SPEED > 16'd785)   assign w_delay_val = 5'h19; //Ref 300Mhz
//  else if (TRAN_SPEED > 16'd754)   assign w_delay_val = 5'h1A; //Ref 300Mhz
//  else if (TRAN_SPEED > 16'd726)   assign w_delay_val = 5'h1B; //Ref 300Mhz
//  else if (TRAN_SPEED > 16'd700)   assign w_delay_val = 5'h1C; //Ref 300Mhz
//  else if (TRAN_SPEED > 16'd675)   assign w_delay_val = 5'h1D; //Ref 300Mhz
//  else if (TRAN_SPEED > 16'd652)   assign w_delay_val = 5'h1E; //Ref 300Mhz
//  else if (TRAN_SPEED > 16'd631)   assign w_delay_val = 5'h1F; //Ref 300Mhz
//  else if (TRAN_SPEED > 16'd597)   assign w_delay_val = 5'h16; 
//  else if (TRAN_SPEED > 16'd570)   assign w_delay_val = 5'h17;
//  else if (TRAN_SPEED > 16'd546)   assign w_delay_val = 5'h18;
//  else if (TRAN_SPEED > 16'd524)   assign w_delay_val = 5'h19;
//  else if (TRAN_SPEED > 16'd503)   assign w_delay_val = 5'h1A;
//  else if (TRAN_SPEED > 16'd484)   assign w_delay_val = 5'h1B;
//  else if (TRAN_SPEED > 16'd466)   assign w_delay_val = 5'h1C;
//  else if (TRAN_SPEED > 16'd450)   assign w_delay_val = 5'h1D;
//  else if (TRAN_SPEED > 16'd435)   assign w_delay_val = 5'h1E;
//  else                              assign w_delay_val = 5'h1F;
//endgenerate    





































//if      (bit_rate_value > 16'h1984) begin bt_val <= 5'h07 ; end
//    else if (bit_rate_value > 16'h1717) begin bt_val <= 5'h08 ; end
//    else if (bit_rate_value > 16'h1514) begin bt_val <= 5'h09 ; end
//    else if (bit_rate_value > 16'h1353) begin bt_val <= 5'h0A ; end
//    else if (bit_rate_value > 16'h1224) begin bt_val <= 5'h0B ; end
//    else if (bit_rate_value > 16'h1117) begin bt_val <= 5'h0C ; end
//    else if (bit_rate_value > 16'h1027) begin bt_val <= 5'h0D ; end
//    else if (bit_rate_value > 16'h0951) begin bt_val <= 5'h0E ; end
//    else if (bit_rate_value > 16'h0885) begin bt_val <= 5'h0F ; end
//    else if (bit_rate_value > 16'h0828) begin bt_val <= 5'h10 ; end
//    else if (bit_rate_value > 16'h0778) begin bt_val <= 5'h11 ; end
//    else if (bit_rate_value > 16'h0733) begin bt_val <= 5'h12 ; end
//    else if (bit_rate_value > 16'h0694) begin bt_val <= 5'h13 ; end
//    else if (bit_rate_value > 16'h0658) begin bt_val <= 5'h14 ; end
//    else if (bit_rate_value > 16'h0626) begin bt_val <= 5'h15 ; end
//    else if (bit_rate_value > 16'h0597) begin bt_val <= 5'h16 ; end
//    else if (bit_rate_value > 16'h0570) begin bt_val <= 5'h17 ; end
//    else if (bit_rate_value > 16'h0546) begin bt_val <= 5'h18 ; end
//    else if (bit_rate_value > 16'h0524) begin bt_val <= 5'h19 ; end
//    else if (bit_rate_value > 16'h0503) begin bt_val <= 5'h1A ; end
//    else if (bit_rate_value > 16'h0484) begin bt_val <= 5'h1B ; end
//    else if (bit_rate_value > 16'h0466) begin bt_val <= 5'h1C ; end
//    else if (bit_rate_value > 16'h0450) begin bt_val <= 5'h1D ; end
//    else if (bit_rate_value > 16'h0435) begin bt_val <= 5'h1E ; end
//    else                                begin bt_val <= 5'h1F ; end  
            


endmodule   


/*module Bit_Align_block #(
        parameter SER_FACTOR= 4
)(
      input                                   i_clk,
      input                                   i_rst,
      input                                   i_dpa_req,//[1] cancel [0]:req
      input   [SER_FACTOR-1:0]                i_rx_data,  
      input                                   i_initial_done,
      output reg                                o_bitalign_done,
      
      output wire                             o_bitslip,                                                                     
      output reg  [4:0]                       o_delay_val                                                                                
);

reg [4:0]             r_delay_val1;
reg [4:0]             r_delay_val2;
reg [SER_FACTOR-1:0]  r_rx_data;
wire [2:0]             edge_info;
reg  [2:0]            r_edge_info;
reg  [2:0]            r_count;

assign edge_info[0] = i_rx_data[0] ^ i_rx_data[1];
assign edge_info[1] = i_rx_data[1] ^ i_rx_data[2];
assign edge_info[2] = i_rx_data[2] ^ i_rx_data[3];   

reg [6:0]  state;
always @ (posedge i_clk)
if(i_rst)
  state <= 4'd0;
else case(state)
  6'd0 : state <= (i_dpa_req&&(i_rx_data==4'hf)) ? 6'd33 : 6'd0;
  //5'd1 : state <= ((i_rx_data==4'b1100)||(i_rx_data==4'b0011) || (i_rx_data==4'b0111) || (i_rx_data==4'b1000))  ?  5'd2 : 5'd20;
  //5'd20: state <= ((i_rx_data==4'b1100)||(i_rx_data==4'b0011) || (i_rx_data==4'b0111) || (i_rx_data==4'b1000))  ?  5'd2 : 5'd21;
  //5'd21: state <= ((i_rx_data==4'b1100)||(i_rx_data==4'b0011) || (i_rx_data==4'b0111) || (i_rx_data==4'b1000))  ?  5'd2 : 5'd22;
  //5'd22: state <= ((i_rx_data==4'b1100)||(i_rx_data==4'b0011) || (i_rx_data==4'b0111) || (i_rx_data==4'b1000))  ?  5'd2 : 5'd23;
  //5'd23: state <= ((i_rx_data==4'b1100)||(i_rx_data==4'b0011) || (i_rx_data==4'b0111) || (i_rx_data==4'b1000))  ?  5'd2 : 5'd24;
  //5'd24: state <= 5'd1;
  6'd1 : state <= ((edge_info==3'b100)||(edge_info==3'b010)) ? 6'd2 : 6'd29;
  6'd29: state <= ((edge_info==3'b100)||(edge_info==3'b010)) ? 6'd2 : 6'd30;
  6'd30: state <= ((edge_info==3'b100)||(edge_info==3'b010)) ? 6'd2 : 6'd31;
  6'd31: state <= ((edge_info==3'b100)||(edge_info==3'b010)) ? 6'd2 : 6'd32;
  6'd32: state <= ((edge_info==3'b100)||(edge_info==3'b010)) ? 6'd2 : 6'd33;
  6'd33: state <= (edge_info==3'b0) ? 6'd33 : 6'd34;
  6'd34: state <= (edge_info==3'b0) ? 6'd34 : 6'd35;
  6'd35: state <= (edge_info==3'b0) ? 6'd35 : 6'd36;
  6'd36: state <= (edge_info==3'b0) ? 6'd36 : 6'd37;
  6'd37: state <= 6'd1;
  6'd2 : state <= 6'd3; //INC
  6'd3 : state <= 6'd4;
  6'd4 : state <= 6'd5;
  6'd5 : state <= 6'd6;
  6'd6 : state <= 6'd7;
  //6'd7 : state <= (edge_info==(r_edge_info<<1)) ? 6'd8 : 6'd12;
  //6'd8 : state <= (edge_info==(r_edge_info<<1)) ? 6'd9 : 6'd12;
  //6'd9 : state <= (edge_info==(r_edge_info<<1)) ? 6'd10 : 6'd12;
  //6'd10: state <= (edge_info==(r_edge_info<<1)) ? 6'd11 : 6'd12;
  6'd7 : state <= 6'd8 ;
  6'd8 : state <= 6'd9 ;
  6'd9 : state <= 6'd10;
  6'd10: state <= 6'd11;
  6'd11: state <= (edge_info==(r_edge_info>>1)) ? 6'd12 : 6'd2;
  6'd12: state <= 6'd13;//INC
  6'd13: state <= 6'd14;
  6'd14: state <= 6'd15;
  6'd15: state <= 6'd16;
  6'd16: state <= 6'd17;
  //6'd17: state <= (edge_info==(r_edge_info<<1)) ? 6'd18 : 6'd22;
  //6'd18: state <= (edge_info==(r_edge_info<<1)) ? 6'd19 : 6'd22;
  //6'd19: state <= (edge_info==(r_edge_info<<1)) ? 6'd20 : 6'd22;
  //6'd20: state <= (edge_info==(r_edge_info<<1)) ? 6'd21 : 6'd22;
  6'd17: state <= 6'd18 ;
  6'd18: state <= 6'd19 ;
  6'd19: state <= 6'd20 ;
  6'd20: state <= 6'd21 ;
  6'd21: state <= (edge_info==(r_edge_info>>1)) ? 6'd22 : 6'd12;
  6'd22: state <= 6'd23;
  6'd23: state <= 6'd25;
  6'd25: state <= 6'd26;
  6'd26: state <= 6'd27;
  6'd27: state <= (i_rx_data == 4'b0011) ? 6'd45 : 6'd38;
  6'd38: state <= (i_rx_data == 4'b0011) ? 6'd45 : 6'd39;
  6'd39: state <= (i_rx_data == 4'b0011) ? 6'd45 : 6'd40;
  6'd40: state <= (i_rx_data == 4'b0011) ? 6'd45 : 6'd41;
  6'd41: state <= (i_rx_data == 4'b0011) ? 6'd45 : 6'd42;
  6'd42: state <= 6'd43;
  6'd43: state <= 6'd44;
  6'd44: state <= 6'd27;
  6'd45: state <= (r_count==3'd4) ? 6'd28 : 6'd27;
  6'd28: state <= i_initial_done ? 6'd0 : 6'd28;
  default:state <= 6'd0;
endcase


always @ (posedge i_clk)
if(i_rst)
  r_count <= 3'd0;
else case(state)
  6'd27:  r_count <= (i_rx_data == 4'b0011) ? r_count + 1'd1 : r_count;
  6'd38:  r_count <= (i_rx_data == 4'b0011) ? r_count + 1'd1 : r_count;
  6'd39:  r_count <= (i_rx_data == 4'b0011) ? r_count + 1'd1 : r_count;
  6'd40:  r_count <= (i_rx_data == 4'b0011) ? r_count + 1'd1 : r_count;
  6'd41:  r_count <= (i_rx_data == 4'b0011) ? r_count + 1'd1 : r_count;
  6'd42:  r_count <= 3'd0;
  6'd43:  r_count <= r_count;
  6'd44:  r_count <= r_count; 
  6'd45:  r_count <= r_count;
  6'd28:  r_count <= 3'd0;
  default:r_count <= 3'd0;
endcase



//r_edge_info 
always @ (posedge i_clk)
if(i_rst)
  r_edge_info <= 3'b0;
else case(state)
  6'd0 : r_edge_info <= 3'b0;
  6'd1 : r_edge_info <= edge_info;
  6'd29: r_edge_info <= edge_info;
  6'd30: r_edge_info <= edge_info;
  6'd31: r_edge_info <= edge_info;
  6'd32: r_edge_info <= edge_info;
  //6'd7 : r_edge_info <= (edge_info==(r_edge_info<<1)) ? edge_info : r_edge_info;
  //6'd8 : r_edge_info <= (edge_info==(r_edge_info<<1)) ? edge_info : r_edge_info;
  //6'd9 : r_edge_info <= (edge_info==(r_edge_info<<1)) ? edge_info : r_edge_info;
  //6'd10: r_edge_info <= (edge_info==(r_edge_info<<1)) ? edge_info : r_edge_info;
  6'd11: r_edge_info <= (edge_info==(r_edge_info>>1)) ? edge_info : r_edge_info;
  //6'd17: r_edge_info <= (edge_info==(r_edge_info<<1)) ? edge_info : r_edge_info;
  //6'd18: r_edge_info <= (edge_info==(r_edge_info<<1)) ? edge_info : r_edge_info;
  //6'd19: r_edge_info <= (edge_info==(r_edge_info<<1)) ? edge_info : r_edge_info;
  //6'd20: r_edge_info <= (edge_info==(r_edge_info<<1)) ? edge_info : r_edge_info;
  6'd21: r_edge_info <= (edge_info==(r_edge_info>>1)) ? edge_info : r_edge_info;
  default:  r_edge_info <= r_edge_info;
  endcase    

always @ (posedge i_clk)
if(i_rst) begin
  r_delay_val1 <= 5'd0;
  r_delay_val2 <= 5'd0;
end else case(state)
  6'd0 : begin r_delay_val1 <= r_delay_val1; r_delay_val2 <= r_delay_val2;  end
  //6'd7 : begin r_delay_val1 <= (edge_info==(r_edge_info<<1))  ? o_delay_val : r_delay_val1; r_delay_val2 <= r_delay_val2;end
  //6'd8 : begin r_delay_val1 <= (edge_info==(r_edge_info<<1))  ? o_delay_val : r_delay_val1; r_delay_val2 <= r_delay_val2;end
  //6'd9 : begin r_delay_val1 <= (edge_info==(r_edge_info<<1))  ? o_delay_val : r_delay_val1; r_delay_val2 <= r_delay_val2;end
  //6'd10: begin r_delay_val1 <= (edge_info==(r_edge_info<<1))  ? o_delay_val : r_delay_val1; r_delay_val2 <= r_delay_val2;end
  6'd11: begin r_delay_val1 <= (edge_info==(r_edge_info>>1))  ? o_delay_val : r_delay_val1; r_delay_val2 <= r_delay_val2;end
  //6'd17: begin r_delay_val1 <= r_delay_val1; r_delay_val2 <= (edge_info==(r_edge_info<<1))  ? o_delay_val : r_delay_val2;  end
  //6'd18: begin r_delay_val1 <= r_delay_val1; r_delay_val2 <= (edge_info==(r_edge_info<<1))  ? o_delay_val : r_delay_val2;  end 
  //6'd19: begin r_delay_val1 <= r_delay_val1; r_delay_val2 <= (edge_info==(r_edge_info<<1))  ? o_delay_val : r_delay_val2;  end
  //6'd20: begin r_delay_val1 <= r_delay_val1; r_delay_val2 <= (edge_info==(r_edge_info<<1))  ? o_delay_val : r_delay_val2;  end
  6'd21: begin r_delay_val1 <= r_delay_val1; r_delay_val2 <= (edge_info==(r_edge_info>>1))  ? o_delay_val : r_delay_val2;  end
  default:begin r_delay_val1 <= r_delay_val1; r_delay_val2 <= r_delay_val2;end
endcase  


//o_delay_val
always @ (posedge i_clk)
if(i_rst) 
    o_delay_val <= 5'd0;
else case(state)
    6'd0 : o_delay_val <= o_delay_val;
    6'd1 : o_delay_val <= o_delay_val;
    6'd2 : o_delay_val <= o_delay_val + 1'd1;
    6'd12: o_delay_val <= o_delay_val + 1'd1;
    6'd33: o_delay_val <= 5'd0;
    6'd22 : o_delay_val <= (r_delay_val1 + r_delay_val2)/2;
    default : o_delay_val <= o_delay_val;
  endcase

always @ (posedge i_clk)
if(i_rst) 
  o_bitalign_done <= 1'b0;
else 
  o_bitalign_done <= (state == 6'd28) ? 1'b1 : o_bitalign_done;
  

assign   o_bitslip = (state == 6'd42) ? 1'b1 : 1'b0;

endmodule   
*/