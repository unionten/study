module SD_Dat_read(
        input    wire                   i_clk,
        input    wire                   i_rst_n,

        input   wire                    i_trans_start,
        input   wire [9 :0]             i_trans_size,
        input   wire [31:0]             i_trans_sector,

        output reg   [7:0]              o_read_data,
        output reg   [9:0]              o_read_ram_addr,
        output wire                     o_flag_reading,
        output reg                      o_fifo_wr_en,
        // output reg   [1:0]             o_ram_status,//2'b00 L&H can't read 2'b01 Low_addr can read  2'b10  Heigh_addr can read
        // output reg                     o_read_req,
        output reg   [2:0]              o_read_status,//[2]busy   [1]trans finish [0]trans ok or fail

        output wire  [31:0]             o_sector_count,

        output wire                     sd_data_dir ,//0:read  1:write
        input  wire  [3:0]              i_sd_data ,
        output wire  [3:0]              o_sd_data,
        output                          read_data_count_db
);


//=====================================================read data====================================================================//
localparam STATE_READ_IDLE   = 3'd0;
localparam STATE_READ_WAIT   = 3'd1;
localparam STATE_READ_TRANS  = 3'd2;
localparam STATE_READ_CRC    = 3'd3;
localparam STATE_READ_DONE0  = 3'd4;
localparam STATE_READ_DONE   = 3'd5;
localparam STATE_READ_FAIL   = 3'd6;
localparam STATE_READ_FINISH = 3'd7;

// (* keep = "true" *)reg [11:0] r_read_data_count;
reg [11:0] r_read_data_count;
reg [31:0] r_read_sector_count;
reg [4:0]  r_read_crc_count;
reg [2:0]  Current_read_state;
reg [2:0]  Next_read_state;
reg        r_read_crc_check;
reg [3:0]  r_sd_data_delay1;
reg [3:0]  r_sd_data_delay2;

assign sd_data_dir = 1'b0;
assign o_sd_data   = 4'hf;

assign o_flag_reading  = (Current_read_state == STATE_READ_TRANS) ? 1'b1 : 1'b0;
assign o_sector_count  = r_read_sector_count;

// reg r_fifo_rd_en;
always @ (posedge i_clk or negedge i_rst_n)
if (~i_rst_n)begin
  o_read_ram_addr <= 10'b0;
  o_fifo_wr_en    <= 1'b0;
end else begin
  // o_read_ram_addr <= {r_read_sector_count[0],r_read_data_count[9:1]};
  o_read_ram_addr <= r_read_data_count[9:1];
  o_fifo_wr_en    <= r_read_data_count[0];
end

always @ (posedge i_clk or negedge i_rst_n)
if (~i_rst_n)begin
  r_sd_data_delay1 <= 4'hf;
  r_sd_data_delay2 <= 4'hf;
end else begin
  r_sd_data_delay1 <= i_sd_data;
  r_sd_data_delay2 <= r_sd_data_delay1;
end

reg r_trans_start;
always @ (posedge i_clk or negedge i_rst_n)
if(~i_rst_n)
  r_trans_start <= 1'b0;
else
  r_trans_start <= i_trans_start;

always @ (posedge i_clk or negedge i_rst_n)
if(~i_rst_n)
  Current_read_state <= STATE_READ_IDLE;
else
  Current_read_state <= Next_read_state;

always @ (*)
if(~i_rst_n)
  Next_read_state <= STATE_READ_IDLE;
else case(Current_read_state)
  STATE_READ_IDLE  : Next_read_state <= ({r_trans_start,i_trans_start} == 2'b01) ? STATE_READ_WAIT : STATE_READ_IDLE;
  STATE_READ_WAIT  : Next_read_state <= (r_sd_data_delay2 != 4'hf) ? STATE_READ_TRANS : STATE_READ_WAIT;
  STATE_READ_TRANS : Next_read_state <= (r_read_data_count == (i_trans_size + i_trans_size)) ? STATE_READ_CRC : STATE_READ_TRANS;
  STATE_READ_CRC   : Next_read_state <= (r_read_crc_count>16) ? r_read_crc_check ? STATE_READ_DONE0 : STATE_READ_FAIL : STATE_READ_CRC;
  STATE_READ_DONE0 : Next_read_state <= STATE_READ_DONE;
  STATE_READ_DONE  : Next_read_state <= (r_read_sector_count >= i_trans_sector) ? STATE_READ_FINISH : STATE_READ_WAIT;
  STATE_READ_FAIL  : Next_read_state <= STATE_READ_FINISH;
  STATE_READ_FINISH: Next_read_state <= STATE_READ_IDLE;
  default          : ;
endcase

always @ (posedge i_clk or negedge i_rst_n)
if(~i_rst_n)begin
  o_read_data         <= 8'b0;
  r_read_data_count   <= 12'b0;
  r_read_crc_count    <= 5'b0;
  r_read_sector_count <= 32'b0;
end else case(Current_read_state)
  STATE_READ_IDLE  : begin o_read_data <= 8'b0; r_read_data_count <= 12'b0; r_read_crc_count <= 5'b0;r_read_sector_count <= ({r_trans_start,i_trans_start} == 2'b01) ? 32'b0 : r_read_sector_count;end
  STATE_READ_WAIT  : begin
                        r_read_data_count <= 12'b0;
                        r_read_crc_count <= 5'b0;
                        r_read_sector_count <= r_read_sector_count;
                        // o_read_data <= 8'b0;
                        if(r_sd_data_delay2 != 4'hf)begin
                          o_read_data <= {o_read_data[3:0],r_sd_data_delay1};
                        end else begin
                          o_read_data <= 8'b0;
                        end
                      end
  STATE_READ_TRANS : begin
                        r_read_crc_count <= 5'b0;
                        r_read_sector_count <= r_read_sector_count;
                        o_read_data <= {o_read_data[3:0],r_sd_data_delay2} ;

                        if (r_read_data_count < (i_trans_size + i_trans_size))begin
                          r_read_data_count <= r_read_data_count + 1'b1;
                          // o_read_data <= r_read_data_count[0] ? {o_read_data[7:4],r_sd_data_delay2} : {r_sd_data_delay2,o_read_data[3:0]};
                        end else begin
                          r_read_data_count <= 12'b0;
                          // o_read_data       <= 8'b0;
                        end
                      end
  STATE_READ_CRC   : begin o_read_data <= 8'b0; r_read_data_count<=12'b0; r_read_crc_count <= r_read_crc_count + 1'b1;r_read_sector_count <= r_read_sector_count;       end
  STATE_READ_DONE0 : begin o_read_data <= 8'b0; r_read_data_count<=12'b0; r_read_crc_count <= 5'b0;                   r_read_sector_count <= r_read_sector_count + 1'b1;end
  STATE_READ_DONE  : begin o_read_data <= 8'b0; r_read_data_count<=12'b0; r_read_crc_count <= 5'b0;                   r_read_sector_count <= r_read_sector_count;       end
  STATE_READ_FAIL  : begin o_read_data <= 8'b0; r_read_data_count<=12'b0; r_read_crc_count <= 5'b0;                   r_read_sector_count <= r_read_sector_count;       end
  STATE_READ_FINISH: begin o_read_data <= 8'b0; r_read_data_count<=12'b0; r_read_crc_count <= 5'b0;                   r_read_sector_count <= r_read_sector_count;       end
  default          : begin o_read_data <= 8'b0; r_read_data_count<=12'b0; r_read_crc_count <= 5'b0;                   r_read_sector_count <= 32'b0; end
endcase

always @ (posedge i_clk or negedge i_rst_n)
  if(~i_rst_n)
    o_read_status <= 3'b0;
  else case(Current_read_state)
    STATE_READ_IDLE  :o_read_status <= 3'b0;
    STATE_READ_WAIT  :o_read_status <= 3'b100;
    STATE_READ_TRANS :o_read_status <= o_read_status;
    STATE_READ_CRC   :o_read_status <= o_read_status;
    STATE_READ_DONE0 :o_read_status <= o_read_status;
    STATE_READ_DONE  :o_read_status <= 3'b101;
    STATE_READ_FAIL  :o_read_status <= 3'b110;
    STATE_READ_FINISH:o_read_status <= {2'b01,o_read_status[0]};
    default          :o_read_status <= o_read_status;
  endcase




assign read_data_count_db = r_read_data_count[0];


// ila_0 read_ila (
// 	.clk(i_clk), // input wire clk
// 	.probe0({o_read_status,Current_read_state}), // input wire [7:0]  probe0
// 	.probe1(o_read_data), // input wire [7:0]  probe1
// 	.probe2(o_read_ram_addr), // input wire [15:0]  probe2
// 	.probe3(i_sd_data), // input wire [7:0]  probe3
// 	.probe4(i_trans_start), // input wire [0:0]  probe4
// 	.probe5(o_flag_reading), // input wire [0:0]  probe5
// 	.probe6(read_data_count_db), // input wire [0:0]  probe6
// 	.probe7(r_read_data_count), // input wire [15:0]  probe7
// 	.probe8({r_sd_data_delay1,r_sd_data_delay2,o_fifo_wr_en}), // input wire [119:0]  probe8
// 	.probe9({i_trans_size,i_rst_n,r_read_sector_count,i_trans_sector}) // input wire [119:0]  probe9
// );




// always @ (posedge i_clk or negedge i_rst_n)
// if(~i_rst_n)
  // o_ram_status <= 2'b0;
// else case(Current_read_state)
  // STATE_READ_IDLE  : o_ram_status <= ({r_trans_start,i_trans_start}==2'b01) ? 2'b00 : o_ram_status;
  // STATE_READ_WAIT  : o_ram_status <= o_ram_status;
  // STATE_READ_TRANS : o_ram_status <= o_ram_status;
  // STATE_READ_CRC   : o_ram_status <= o_ram_status;
  // STATE_READ_DONE0 : o_ram_status <= r_read_sector_count[0] ? 2'b10 : 2'b01;
  // STATE_READ_DONE  : o_ram_status <= o_ram_status;
  // STATE_READ_FAIL  : o_ram_status <= o_ram_status;
  // STATE_READ_FINISH: o_ram_status <= o_ram_status;
  // default          : o_ram_status <= 2'b00;
// endcase

// always @ (posedge i_clk or negedge i_rst_n)
// if(~i_rst_n)
  // o_read_req <= 1'b0;
// else case(Current_read_state)
  // STATE_READ_IDLE  : o_read_req <= 1'b0;
  // STATE_READ_WAIT  : o_read_req <= 1'b0;
  // STATE_READ_TRANS : o_read_req <= 1'b0;
  // STATE_READ_CRC   : o_read_req <= 1'b0;
  // STATE_READ_DONE0 : o_read_req <= 1'b0;
  // STATE_READ_DONE  : o_read_req <= 1'b1;
  // STATE_READ_FAIL  : o_read_req <= 1'b0;
  // STATE_READ_FINISH: o_read_req <= 1'b0;
  // default          : o_read_req <= 1'b0;
// endcase

//=========READ CRC-16=========//
reg [15:0] r_read_crc_data0;
reg [15:0] r_read_crc_data1;
reg [15:0] r_read_crc_data2;
reg [15:0] r_read_crc_data3;
always @ (posedge i_clk or negedge i_rst_n)
  if(~i_rst_n)begin
    r_read_crc_check <=  1'b0;
    r_read_crc_data0 <= 16'b0;
    r_read_crc_data1 <= 16'b0;
    r_read_crc_data2 <= 16'b0;
    r_read_crc_data3 <= 16'b0;
  end else case(Current_read_state)
    STATE_READ_IDLE  : begin r_read_crc_check <= 1'b0; r_read_crc_data0 <= 16'b0; r_read_crc_data1 <= 16'b0; r_read_crc_data2 <= 16'b0; r_read_crc_data3 <= 16'b0;end
    STATE_READ_WAIT  : begin r_read_crc_check <= 1'b0; r_read_crc_data0 <= 16'b0; r_read_crc_data1 <= 16'b0; r_read_crc_data2 <= 16'b0; r_read_crc_data3 <= 16'b0;end
    STATE_READ_TRANS : begin
                        r_read_crc_check <= 1'b1;
                        if (r_read_data_count < (i_trans_size + i_trans_size))begin
                          //sd_data[0]line crc check                                                              //sd_data[1]line crc check
                          r_read_crc_data0[15] <= r_read_crc_data0[14];                                           r_read_crc_data1[15] <= r_read_crc_data1[14];
                          r_read_crc_data0[14] <= r_read_crc_data0[13];                                           r_read_crc_data1[14] <= r_read_crc_data1[13];
                          r_read_crc_data0[13] <= r_read_crc_data0[12];                                           r_read_crc_data1[13] <= r_read_crc_data1[12];
                          r_read_crc_data0[12] <= r_read_crc_data0[11]^r_sd_data_delay2[0]^r_read_crc_data0[15];  r_read_crc_data1[12] <= r_read_crc_data1[11]^r_sd_data_delay2[1]^r_read_crc_data1[15];
                          r_read_crc_data0[11] <= r_read_crc_data0[10];                                           r_read_crc_data1[11] <= r_read_crc_data1[10];
                          r_read_crc_data0[10] <= r_read_crc_data0[9];                                            r_read_crc_data1[10] <= r_read_crc_data1[9];
                          r_read_crc_data0[9]  <= r_read_crc_data0[8];                                            r_read_crc_data1[9]  <= r_read_crc_data1[8];
                          r_read_crc_data0[8]  <= r_read_crc_data0[7];                                            r_read_crc_data1[8]  <= r_read_crc_data1[7];
                          r_read_crc_data0[7]  <= r_read_crc_data0[6];                                            r_read_crc_data1[7]  <= r_read_crc_data1[6];
                          r_read_crc_data0[6]  <= r_read_crc_data0[5];                                            r_read_crc_data1[6]  <= r_read_crc_data1[5];
                          r_read_crc_data0[5]  <= r_read_crc_data0[4]^r_sd_data_delay2[0]^r_read_crc_data0[15];   r_read_crc_data1[5]  <= r_read_crc_data1[4]^r_sd_data_delay2[1]^r_read_crc_data1[15];
                          r_read_crc_data0[4]  <= r_read_crc_data0[3];                                            r_read_crc_data1[4]  <= r_read_crc_data1[3];
                          r_read_crc_data0[3]  <= r_read_crc_data0[2];                                            r_read_crc_data1[3]  <= r_read_crc_data1[2];
                          r_read_crc_data0[2]  <= r_read_crc_data0[1];                                            r_read_crc_data1[2]  <= r_read_crc_data1[1];
                          r_read_crc_data0[1]  <= r_read_crc_data0[0];                                            r_read_crc_data1[1]  <= r_read_crc_data1[0];
                          r_read_crc_data0[0]  <= r_sd_data_delay2[0]^r_read_crc_data0[15];                       r_read_crc_data1[0]  <= r_sd_data_delay2[1]^r_read_crc_data1[15];
                          //sd_data[2]line crc check                                                              //sd_data[3]line crc check
                          r_read_crc_data2[15] <= r_read_crc_data2[14];                                           r_read_crc_data3[15] <= r_read_crc_data3[14];
                          r_read_crc_data2[14] <= r_read_crc_data2[13];                                           r_read_crc_data3[14] <= r_read_crc_data3[13];
                          r_read_crc_data2[13] <= r_read_crc_data2[12];                                           r_read_crc_data3[13] <= r_read_crc_data3[12];
                          r_read_crc_data2[12] <= r_read_crc_data2[11]^r_sd_data_delay2[2]^r_read_crc_data2[15];  r_read_crc_data3[12] <= r_read_crc_data3[11]^r_sd_data_delay2[3]^r_read_crc_data3[15];
                          r_read_crc_data2[11] <= r_read_crc_data2[10];                                           r_read_crc_data3[11] <= r_read_crc_data3[10];
                          r_read_crc_data2[10] <= r_read_crc_data2[9];                                            r_read_crc_data3[10] <= r_read_crc_data3[9];
                          r_read_crc_data2[9]  <= r_read_crc_data2[8];                                            r_read_crc_data3[9]  <= r_read_crc_data3[8];
                          r_read_crc_data2[8]  <= r_read_crc_data2[7];                                            r_read_crc_data3[8]  <= r_read_crc_data3[7];
                          r_read_crc_data2[7]  <= r_read_crc_data2[6];                                            r_read_crc_data3[7]  <= r_read_crc_data3[6];
                          r_read_crc_data2[6]  <= r_read_crc_data2[5];                                            r_read_crc_data3[6]  <= r_read_crc_data3[5];
                          r_read_crc_data2[5]  <= r_read_crc_data2[4]^r_sd_data_delay2[2]^r_read_crc_data2[15];   r_read_crc_data3[5]  <= r_read_crc_data3[4]^r_sd_data_delay2[3]^r_read_crc_data3[15];
                          r_read_crc_data2[4]  <= r_read_crc_data2[3];                                            r_read_crc_data3[4]  <= r_read_crc_data3[3];
                          r_read_crc_data2[3]  <= r_read_crc_data2[2];                                            r_read_crc_data3[3]  <= r_read_crc_data3[2];
                          r_read_crc_data2[2]  <= r_read_crc_data2[1];                                            r_read_crc_data3[2]  <= r_read_crc_data3[1];
                          r_read_crc_data2[1]  <= r_read_crc_data2[0];                                            r_read_crc_data3[1]  <= r_read_crc_data3[0];
                          r_read_crc_data2[0]  <= r_sd_data_delay2[2]^r_read_crc_data2[15];                       r_read_crc_data3[0]  <= r_sd_data_delay2[3]^r_read_crc_data3[15];

                        end else begin
                          r_read_crc_data0  <= {r_read_crc_data0[14:0],1'b1};
                          r_read_crc_data1  <= {r_read_crc_data1[14:0],1'b1};
                          r_read_crc_data2  <= {r_read_crc_data2[14:0],1'b1};
                          r_read_crc_data3  <= {r_read_crc_data3[14:0],1'b1};
                        end
                      end
    STATE_READ_CRC   : begin
                        r_read_crc_check <= (r_read_crc_data0[15] == r_sd_data_delay2[0]) &&
                                            (r_read_crc_data1[15] == r_sd_data_delay2[1]) &&
                                            (r_read_crc_data2[15] == r_sd_data_delay2[2]) &&
                                            (r_read_crc_data3[15] == r_sd_data_delay2[3]) ? (r_read_crc_check & 1'b1) : 1'b0;
                        r_read_crc_data0 <= {r_read_crc_data0[14:0],1'b1};
                        r_read_crc_data1 <= {r_read_crc_data1[14:0],1'b1};
                        r_read_crc_data2 <= {r_read_crc_data2[14:0],1'b1};
                        r_read_crc_data3 <= {r_read_crc_data3[14:0],1'b1};
                      end
    STATE_READ_DONE  : begin  r_read_crc_check <= 1'b0; r_read_crc_data0 <= 16'b0; r_read_crc_data1 <= 16'b0; r_read_crc_data2 <= 16'b0; r_read_crc_data3 <= 16'b0;end
    STATE_READ_FAIL  : begin  r_read_crc_check <= 1'b0; r_read_crc_data0 <= 16'b0; r_read_crc_data1 <= 16'b0; r_read_crc_data2 <= 16'b0; r_read_crc_data3 <= 16'b0;end
    STATE_READ_FINISH: begin  r_read_crc_check <= 1'b0; r_read_crc_data0 <= 16'b0; r_read_crc_data1 <= 16'b0; r_read_crc_data2 <= 16'b0; r_read_crc_data3 <= 16'b0;end
    default          : begin  r_read_crc_check <= 1'b0; r_read_crc_data0 <= 16'b0; r_read_crc_data1 <= 16'b0; r_read_crc_data2 <= 16'b0; r_read_crc_data3 <= 16'b0;end
  endcase





// ila_0 read_sd_state_inst (
// 	.clk(i_clk), // input wire clk
// 	.probe0({r_trans_start}), // input wire [511:0]  probe0
// 	.probe1(o_read_status), // input wire [31:0]  probe1
// 	.probe2(r_read_sector_count), // input wire [31:0]  probe2
// 	.probe3(i_trans_sector), // input wire [31:0]  probe3
// 	.probe4(i_trans_size), // input wire [31:0]  probe4
// 	.probe5(r_read_data_count), // input wire [15:0]  probe5
// 	.probe6(Current_read_state), // input wire [7:0]  probe6
// 	.probe7(o_read_data), // input wire [7:0]  probe7
// 	.probe8(r_read_crc_check) // input wire [0:0]  probe8
// );





endmodule


