(* DONT_TOUCH = "yes" *) module SD_Dat_write(
        input    wire                   i_clk,
        input    wire                   i_rst_n,
        input    wire                   i_ram_empty,

        input   wire                   i_trans_start,
        input   wire [9 :0]            i_trans_size,
        input   wire [31:0]            i_trans_sector,

        input  wire  [7:0]             i_write_data,
        output wire  [0:0]             o_read_fifo_en,
        output wire  [9 :0]            o_write_ram_addr,
        output wire                    o_flag_writing,
        output reg   [2:0]             o_write_status,//[2]busy   [1]trans finish [0]trans ok or fail
        // output reg   [1:0]             o_ram_status,

        output wire  [31:0]            o_sector_count,

        output reg                     sd_data_dir ,//0:read  1:write
        input  wire  [3:0]             i_sd_data ,
        output reg   [3:0]             o_sd_data
);

//======================================================================write data===============================================================================//
localparam STATE_WRITE_IDLE      = 4'd0;
// localparam STATE_WRITE_DDR_WAIT  = 4'd1;
localparam STATE_WRITE_WAIT      = 4'd2;
localparam STATE_WRITE_START     = 4'd3;
localparam STATE_WRITE_TRANS     = 4'd4;
localparam STATE_WRITE_CRC       = 4'd5;
localparam STATE_WRITE_CRC_RESP  = 4'd6;
localparam STATE_WRITE_DONE0     = 4'd7;
localparam STATE_WRITE_DONE      = 4'd8;
localparam STATE_WRITE_FAIL      = 4'd9;
localparam STATE_WRITE_FINISH    = 4'd10;


reg  [11:0] r_write_data_count;
reg  [11:0] r_write_ram_addr;
reg  [31:0] r_write_sector_count;
reg  [7:0]  r_write_delay_count;
reg  [3:0]  Current_write_state;
reg  [3:0]  Next_write_state;
reg  [2:0]  r_write_crc_resp;
reg  [3:0]  r_sd_data_delay1;
reg  [3:0]  r_sd_data_delay2;

// assign o_read_fifo_en = (Current_write_state == STATE_WRITE_START) || r_write_ram_addr[0] ? 1'b1 : 1'b0; //old
// assign o_read_fifo_en   = (Current_write_state == STATE_WRITE_WAIT) ? 1'b1 : (Current_write_state == STATE_WRITE_TRANS) & (r_write_ram_addr[0] == 1'b0) ? 1'b1 : 1'b0;

assign o_read_fifo_en   = (Current_write_state == STATE_WRITE_TRANS) & (r_write_ram_addr[0] == 1'b0) || (Current_write_state == STATE_WRITE_START)? 1'b1 : 1'b0; //for uh8s
// assign o_read_fifo_en   = (Current_write_state == STATE_WRITE_TRANS) & (r_write_ram_addr[0] == 1'b0))? 1'b1 : 1'b0; //for uh8s



assign o_write_ram_addr = ((Current_write_state == STATE_WRITE_TRANS)||(Current_write_state == STATE_WRITE_START)||(Current_write_state == STATE_WRITE_WAIT)) ? r_write_ram_addr[9:1] : 10'b0;
// assign o_write_ram_addr = ((Current_write_state == STATE_WRITE_TRANS)||(Current_write_state == STATE_WRITE_START)||(Current_write_state == STATE_WRITE_WAIT)) ? {r_write_sector_count[0],r_write_ram_addr[9:1]} : 10'b0;
assign o_flag_writing   = ((Current_write_state == STATE_WRITE_TRANS)||(Current_write_state == STATE_WRITE_START)||(Current_write_state == STATE_WRITE_WAIT)) ? 1'b1 : 10'b0;
assign o_sector_count   = r_write_sector_count;

reg r_trans_start;
always @ (posedge i_clk or negedge i_rst_n)
if(~i_rst_n)
  r_trans_start <= 1'b0;
else
  r_trans_start <= i_trans_start;


always @ (posedge i_clk or negedge i_rst_n)
if (~i_rst_n)begin
  r_sd_data_delay1 <= 4'hf;
  r_sd_data_delay2 <= 4'hf;
end else begin
  r_sd_data_delay1 <= i_sd_data;
  r_sd_data_delay2 <= r_sd_data_delay1;
end


always @ (posedge i_clk or negedge i_rst_n)
if(~i_rst_n)
  Current_write_state <= STATE_WRITE_IDLE;
else
  Current_write_state <= Next_write_state;

always @ (*)
if(~i_rst_n)
  Next_write_state <= STATE_WRITE_IDLE;
else case(Current_write_state)
  STATE_WRITE_IDLE     : Next_write_state <= ({r_trans_start,i_trans_start}==2'b01) ? STATE_WRITE_WAIT : STATE_WRITE_IDLE;
  STATE_WRITE_WAIT     : Next_write_state <= (r_write_delay_count >= 8'h2)&&(!i_ram_empty) ? STATE_WRITE_START : STATE_WRITE_WAIT;
  STATE_WRITE_START    : Next_write_state <= STATE_WRITE_TRANS;
  STATE_WRITE_TRANS    : Next_write_state <= (r_write_data_count == (i_trans_size+i_trans_size+16)) ? STATE_WRITE_CRC : STATE_WRITE_TRANS;
  STATE_WRITE_CRC      : Next_write_state <= (r_write_delay_count>2)?({r_sd_data_delay1[0],r_sd_data_delay2[0]} == 2'b01) ? STATE_WRITE_CRC_RESP : STATE_WRITE_CRC : STATE_WRITE_CRC;
  STATE_WRITE_CRC_RESP : Next_write_state <= (r_write_data_count>=32'h10) ? (r_write_crc_resp!=3'b010) ? STATE_WRITE_FAIL : STATE_WRITE_DONE0 : STATE_WRITE_CRC_RESP;
  STATE_WRITE_DONE0    : Next_write_state <= STATE_WRITE_DONE;
  STATE_WRITE_DONE     : Next_write_state <= (r_write_sector_count >= i_trans_sector) ? STATE_WRITE_FINISH : r_sd_data_delay1[0] ? STATE_WRITE_WAIT : STATE_WRITE_DONE;
  STATE_WRITE_FAIL     : Next_write_state <= STATE_WRITE_FINISH;
  STATE_WRITE_FINISH   : Next_write_state <= STATE_WRITE_IDLE;
  default              : ;
endcase

always @ (posedge i_clk or negedge i_rst_n)
if(~i_rst_n)begin
  r_write_delay_count  <= 8'b0;
  r_write_sector_count <= 32'b0;
end else case(Current_write_state)
  STATE_WRITE_IDLE     : begin r_write_sector_count <= ({r_trans_start,i_trans_start}==2'b01) ? 0 : r_write_sector_count;      r_write_delay_count <=8'b0; end
  STATE_WRITE_WAIT     : begin r_write_sector_count <= r_write_sector_count;      r_write_delay_count <=r_write_delay_count+1'b1; end
  STATE_WRITE_START    : begin r_write_sector_count <= r_write_sector_count;      r_write_delay_count <=8'b0; end
  STATE_WRITE_TRANS    : begin r_write_sector_count <= r_write_sector_count;      r_write_delay_count <=8'b0; end
  STATE_WRITE_CRC      : begin r_write_sector_count <= r_write_sector_count;      r_write_delay_count <=r_write_delay_count+1'b1; end
  STATE_WRITE_CRC_RESP : begin r_write_sector_count <= r_write_sector_count;      r_write_delay_count <=8'b0; end
  STATE_WRITE_DONE0    : begin r_write_sector_count <= r_write_sector_count+1'b1; r_write_delay_count <=8'b0; end
  STATE_WRITE_DONE     : begin r_write_sector_count <= r_write_sector_count;      r_write_delay_count <=8'b0; end
  STATE_WRITE_FAIL     : begin r_write_sector_count <=r_write_sector_count;       r_write_delay_count <=8'b0; end
  STATE_WRITE_FINISH   : begin r_write_sector_count <=r_write_sector_count;       r_write_delay_count <=8'b0; end
  default              : begin r_write_sector_count <=32'b0;                      r_write_delay_count <=8'b0; end
endcase

always @ (posedge i_clk or negedge i_rst_n)
if(~i_rst_n)begin
  o_sd_data           <= 4'hf;
  r_write_data_count  <= 12'b0;
  r_write_ram_addr    <= 12'b0;
  r_write_crc_resp    <= 3'b0;
end else case(Current_write_state)
  STATE_WRITE_IDLE     : begin o_sd_data <= 4'hf; r_write_data_count <= 12'b0; r_write_crc_resp <= 3'b0; r_write_ram_addr <= 12'b0;end
  STATE_WRITE_WAIT     : begin o_sd_data <= 4'hf; r_write_data_count <= 12'b0; r_write_crc_resp <= 3'b0; r_write_ram_addr <= 12'b0;end
  STATE_WRITE_START    : begin o_sd_data <= 4'h0; r_write_data_count <= 12'b0; r_write_crc_resp <= 3'b0; r_write_ram_addr <= 12'h2;end//for ram delay 2 clk,now dong't use it r_write_ram_addr <= 32'h2;
  STATE_WRITE_TRANS    : begin
                          r_write_crc_resp     <= 3'b0;
                          if (r_write_data_count < (i_trans_size + i_trans_size))begin
                            r_write_ram_addr   <= r_write_ram_addr + 1'b1;
                            r_write_data_count <= r_write_data_count + 1'b1;
                            o_sd_data <= r_write_data_count[0] ? i_write_data[3:0] : i_write_data[7:4];
                          end else if(r_write_data_count < (i_trans_size + i_trans_size + 16)) begin
                            r_write_data_count <= r_write_data_count + 1'b1;
                            r_write_ram_addr   <= r_write_ram_addr ;
                            o_sd_data          <= {r_write_crc_data3[15],r_write_crc_data2[15],r_write_crc_data1[15],r_write_crc_data0[15]};
                          end else begin
                            r_write_data_count <= 32'b0;
                            r_write_ram_addr   <= 12'b0;
                            o_sd_data          <= 4'hf;
                          end
                        end
  STATE_WRITE_CRC      : begin o_sd_data <= 4'hf; r_write_data_count <= 12'b0;r_write_crc_resp <= 3'b0; r_write_ram_addr <= 12'b0;end
  STATE_WRITE_CRC_RESP : begin
                          o_sd_data <= 4'hf;
                          r_write_ram_addr <= 12'b0;
                          if (r_write_data_count < 3)begin
                            r_write_data_count  <= r_write_data_count + 1'b1;
                            r_write_crc_resp    <= {r_write_crc_resp[1:0],r_sd_data_delay1[0]};
                          end  else begin
                            r_write_data_count  <= r_write_data_count + 1'b1;
                            r_write_crc_resp    <= r_write_crc_resp;
                          end
                        end
  STATE_WRITE_DONE0    : begin o_sd_data <= 4'hf; r_write_data_count <= 12'b0; r_write_crc_resp <= 3'b0;r_write_ram_addr <= 12'b0;end
  STATE_WRITE_DONE     : begin o_sd_data <= 4'hf; r_write_data_count <= 12'b0; r_write_crc_resp <= 3'b0;r_write_ram_addr <= 12'b0;end
  STATE_WRITE_FAIL     : begin o_sd_data <= 4'hf; r_write_data_count <= 12'b0; r_write_crc_resp <= 3'b0;r_write_ram_addr <= 12'b0;end
  STATE_WRITE_FINISH   : begin o_sd_data <= 4'hf; r_write_data_count <= 12'b0; r_write_crc_resp <= 3'b0;r_write_ram_addr <= 12'b0;end
  default              : begin o_sd_data <= 4'hf; r_write_data_count <= 12'b0; r_write_crc_resp <= 3'b0;r_write_ram_addr <= 12'b0;end
endcase



// ila_0 sd_write_data(
// 	.clk(i_clk), // input wire clk
// 	.probe0({i_write_data,i_trans_size,r_write_data_count,r_write_ram_addr,r_write_ram_addr[0]}), // input wire [255:0]  probe0
// 	.probe1({Current_write_state,o_read_fifo_en}), // input wire [63:0]  probe1
// 	.probe2(o_write_status), // input wire [63:0]  probe2
// 	.probe3(r_write_ram_addr), // input wire [7:0]  probe3
// 	.probe4(i_sd_data), // input wire [0:0]  probe4
// 	.probe5(i_trans_start), // input wire [0:0]  probe5
// 	.probe6({r_write_sector_count,o_write_status}) // input wire [255:0]  probe6
// );






always @ (posedge i_clk or negedge i_rst_n)
if(~i_rst_n)
  o_write_status <= 3'b0;
else case(Current_write_state)
  STATE_WRITE_IDLE     :  o_write_status <= 3'b0;
  STATE_WRITE_WAIT     :  o_write_status <= 3'b100;
  STATE_WRITE_START    :  o_write_status <= o_write_status;
  STATE_WRITE_TRANS    :  o_write_status <= o_write_status;
  STATE_WRITE_CRC      :  o_write_status <= o_write_status;
  STATE_WRITE_CRC_RESP :  o_write_status <= o_write_status;
  STATE_WRITE_DONE0    :  o_write_status <= 3'b101;
  STATE_WRITE_DONE     :  o_write_status <= 3'b111;
  STATE_WRITE_FAIL     :  o_write_status <= 3'b110;
  STATE_WRITE_FINISH   :  o_write_status <= {2'b01,o_write_status[0]};
  default              :  o_write_status <= o_write_status;
endcase

always @ (posedge i_clk or negedge i_rst_n)
if(~i_rst_n)
  sd_data_dir <= 1'b0;
else case(Current_write_state)
  STATE_WRITE_IDLE     :  sd_data_dir <= 1'b0;
  STATE_WRITE_WAIT     :  sd_data_dir <= 1'b1;
  STATE_WRITE_START    :  sd_data_dir <= 1'b1;
  STATE_WRITE_TRANS    :  sd_data_dir <= 1'b1;
  STATE_WRITE_CRC      :  sd_data_dir <= 1'b0;
  STATE_WRITE_CRC_RESP :  sd_data_dir <= 1'b0;
  STATE_WRITE_DONE0    :  sd_data_dir <= 1'b0;
  STATE_WRITE_DONE     :  sd_data_dir <= 1'b0;
  STATE_WRITE_FAIL     :  sd_data_dir <= 1'b0;
  STATE_WRITE_FINISH   :  sd_data_dir <= 1'b0;
  default              :  sd_data_dir <= 1'b0;
endcase


//=====================================WRITE CRC-16=====================================//
reg [15:0] r_write_crc_data0;
reg [15:0] r_write_crc_data1;
reg [15:0] r_write_crc_data2;
reg [15:0] r_write_crc_data3;
always @ (posedge i_clk or negedge i_rst_n)
if(~i_rst_n)begin
  r_write_crc_data0 <= 16'b0;
  r_write_crc_data1 <= 16'b0;
  r_write_crc_data2 <= 16'b0;
  r_write_crc_data3 <= 16'b0;
end else case(Current_write_state)
  STATE_WRITE_IDLE     : begin r_write_crc_data0 <= 16'b0; r_write_crc_data1 <= 16'b0; r_write_crc_data2 <= 16'b0; r_write_crc_data2 <= 16'b0;r_write_crc_data3 <= 16'b0;end
  STATE_WRITE_WAIT     : begin r_write_crc_data0 <= 16'b0; r_write_crc_data1 <= 16'b0; r_write_crc_data2 <= 16'b0; r_write_crc_data2 <= 16'b0;r_write_crc_data3 <= 16'b0;end
  STATE_WRITE_START    : begin r_write_crc_data0 <= 16'b0; r_write_crc_data1 <= 16'b0; r_write_crc_data2 <= 16'b0; r_write_crc_data2 <= 16'b0;r_write_crc_data3 <= 16'b0;end
  STATE_WRITE_TRANS    : begin
                          if (r_write_data_count < (i_trans_size+i_trans_size))begin
                            r_write_crc_data0[15] <= r_write_crc_data0[14];
                            r_write_crc_data0[14] <= r_write_crc_data0[13];
                            r_write_crc_data0[13] <= r_write_crc_data0[12];
                            r_write_crc_data0[12] <= r_write_crc_data0[11]^(r_write_data_count[0] ? i_write_data[0]:i_write_data[4])^r_write_crc_data0[15];
                            r_write_crc_data0[11] <= r_write_crc_data0[10];
                            r_write_crc_data0[10] <= r_write_crc_data0[9];
                            r_write_crc_data0[9]  <= r_write_crc_data0[8];
                            r_write_crc_data0[8]  <= r_write_crc_data0[7];
                            r_write_crc_data0[7]  <= r_write_crc_data0[6];
                            r_write_crc_data0[6]  <= r_write_crc_data0[5];
                            r_write_crc_data0[5]  <= r_write_crc_data0[4]^(r_write_data_count[0] ? i_write_data[0]:i_write_data[4])^r_write_crc_data0[15];
                            r_write_crc_data0[4]  <= r_write_crc_data0[3];
                            r_write_crc_data0[3]  <= r_write_crc_data0[2];
                            r_write_crc_data0[2]  <= r_write_crc_data0[1];
                            r_write_crc_data0[1]  <= r_write_crc_data0[0];
                            r_write_crc_data0[0]  <= (r_write_data_count[0] ? i_write_data[0]:i_write_data[4])^r_write_crc_data0[15];

                            r_write_crc_data1[15] <= r_write_crc_data1[14];
                            r_write_crc_data1[14] <= r_write_crc_data1[13];
                            r_write_crc_data1[13] <= r_write_crc_data1[12];
                            r_write_crc_data1[12] <= r_write_crc_data1[11]^(r_write_data_count[0] ? i_write_data[1]:i_write_data[5])^r_write_crc_data1[15];
                            r_write_crc_data1[11] <= r_write_crc_data1[10];
                            r_write_crc_data1[10] <= r_write_crc_data1[9];
                            r_write_crc_data1[9]  <= r_write_crc_data1[8];
                            r_write_crc_data1[8]  <= r_write_crc_data1[7];
                            r_write_crc_data1[7]  <= r_write_crc_data1[6];
                            r_write_crc_data1[6]  <= r_write_crc_data1[5];
                            r_write_crc_data1[5]  <= r_write_crc_data1[4]^(r_write_data_count[0] ? i_write_data[1]:i_write_data[5])^r_write_crc_data1[15];
                            r_write_crc_data1[4]  <= r_write_crc_data1[3];
                            r_write_crc_data1[3]  <= r_write_crc_data1[2];
                            r_write_crc_data1[2]  <= r_write_crc_data1[1];
                            r_write_crc_data1[1]  <= r_write_crc_data1[0];
                            r_write_crc_data1[0]  <= (r_write_data_count[0] ? i_write_data[1]:i_write_data[5])^r_write_crc_data1[15];

                            r_write_crc_data2[15] <= r_write_crc_data2[14];
                            r_write_crc_data2[14] <= r_write_crc_data2[13];
                            r_write_crc_data2[13] <= r_write_crc_data2[12];
                            r_write_crc_data2[12] <= r_write_crc_data2[11]^(r_write_data_count[0] ? i_write_data[2]:i_write_data[6])^r_write_crc_data2[15];
                            r_write_crc_data2[11] <= r_write_crc_data2[10];
                            r_write_crc_data2[10] <= r_write_crc_data2[9];
                            r_write_crc_data2[9]  <= r_write_crc_data2[8];
                            r_write_crc_data2[8]  <= r_write_crc_data2[7];
                            r_write_crc_data2[7]  <= r_write_crc_data2[6];
                            r_write_crc_data2[6]  <= r_write_crc_data2[5];
                            r_write_crc_data2[5]  <= r_write_crc_data2[4]^(r_write_data_count[0] ? i_write_data[2]:i_write_data[6])^r_write_crc_data2[15];
                            r_write_crc_data2[4]  <= r_write_crc_data2[3];
                            r_write_crc_data2[3]  <= r_write_crc_data2[2];
                            r_write_crc_data2[2]  <= r_write_crc_data2[1];
                            r_write_crc_data2[1]  <= r_write_crc_data2[0];
                            r_write_crc_data2[0]  <= (r_write_data_count[0] ? i_write_data[2]:i_write_data[6])^r_write_crc_data2[15];

                            r_write_crc_data3[15] <= r_write_crc_data3[14];
                            r_write_crc_data3[14] <= r_write_crc_data3[13];
                            r_write_crc_data3[13] <= r_write_crc_data3[12];
                            r_write_crc_data3[12] <= r_write_crc_data3[11]^(r_write_data_count[0] ? i_write_data[3]:i_write_data[7])^r_write_crc_data3[15];
                            r_write_crc_data3[11] <= r_write_crc_data3[10];
                            r_write_crc_data3[10] <= r_write_crc_data3[9];
                            r_write_crc_data3[9]  <= r_write_crc_data3[8];
                            r_write_crc_data3[8]  <= r_write_crc_data3[7];
                            r_write_crc_data3[7]  <= r_write_crc_data3[6];
                            r_write_crc_data3[6]  <= r_write_crc_data3[5];
                            r_write_crc_data3[5]  <= r_write_crc_data3[4]^(r_write_data_count[0] ? i_write_data[3]:i_write_data[7])^r_write_crc_data3[15];
                            r_write_crc_data3[4]  <= r_write_crc_data3[3];
                            r_write_crc_data3[3]  <= r_write_crc_data3[2];
                            r_write_crc_data3[2]  <= r_write_crc_data3[1];
                            r_write_crc_data3[1]  <= r_write_crc_data3[0];
                            r_write_crc_data3[0]  <= (r_write_data_count[0] ? i_write_data[3]:i_write_data[7])^r_write_crc_data3[15];
                          end else begin
                            r_write_crc_data0 <= {r_write_crc_data0[14:0],1'b1};
                            r_write_crc_data1 <= {r_write_crc_data1[14:0],1'b1};
                            r_write_crc_data2 <= {r_write_crc_data2[14:0],1'b1};
                            r_write_crc_data3 <= {r_write_crc_data3[14:0],1'b1};
                          end
                        end
  STATE_WRITE_CRC      : begin r_write_crc_data0 <= 16'b0; r_write_crc_data1 <= 16'b0; r_write_crc_data2 <= 16'b0; r_write_crc_data2 <= 16'b0;r_write_crc_data3 <= 16'b0;end
  STATE_WRITE_CRC_RESP : begin r_write_crc_data0 <= 16'b0; r_write_crc_data1 <= 16'b0; r_write_crc_data2 <= 16'b0; r_write_crc_data2 <= 16'b0;r_write_crc_data3 <= 16'b0;end
  STATE_WRITE_DONE     : begin r_write_crc_data0 <= 16'b0; r_write_crc_data1 <= 16'b0; r_write_crc_data2 <= 16'b0; r_write_crc_data2 <= 16'b0;r_write_crc_data3 <= 16'b0;end
  STATE_WRITE_FAIL     : begin r_write_crc_data0 <= 16'b0; r_write_crc_data1 <= 16'b0; r_write_crc_data2 <= 16'b0; r_write_crc_data2 <= 16'b0;r_write_crc_data3 <= 16'b0;end
  STATE_WRITE_FINISH   : begin r_write_crc_data0 <= 16'b0; r_write_crc_data1 <= 16'b0; r_write_crc_data2 <= 16'b0; r_write_crc_data2 <= 16'b0;r_write_crc_data3 <= 16'b0;end
  default              : begin r_write_crc_data0 <= 16'b0; r_write_crc_data1 <= 16'b0; r_write_crc_data2 <= 16'b0; r_write_crc_data2 <= 16'b0;r_write_crc_data3 <= 16'b0;end
endcase



endmodule


