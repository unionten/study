module SD_Dat_tran_block(
    input    wire                   i_clk         ,
    input    wire                   i_rst_n       ,

    input   wire [7:0]              i_initial_done, //[7] : initial done
                                                    //[6](CCS) 0:SDSC 1 : SDHC or SDXC;
                                                    //[5](UHS-II) 0: non UHS-II , 1: UHS-II
                                                    //[4](S18A)) (Switching to 1.8V Accepted) 0: Continues current voltage signaling 1:  Ready for switching signal voltage
                                                    //[3:0] 4'b0001 : Ver1.x ;4'b0010: Ver2.0; 4'b0010: Ver3.0 or later
    input   wire [3:0]             i_speed_mode   ,
    input   wire [15:0]            RCA            ,
    input   wire [119:0]           CSD            ,//[85:76] :CCC

    input   wire                   i_trans_start  ,
    input   wire                   i_trans_sel    ,//[0]:0 read  1 write  [1]:1 start trans
    input   wire [31:0]            i_trans_size   ,//512 byte
    input   wire [31:0]            i_trans_sector , //
    input   wire [31:0]            i_trans_addr   ,

    input   wire [3:0]             i_cmd_tran_reg ,

    output reg                     o_cmd_tran_dval,
    output reg   [5:0]             o_cmd_index    ,
    output reg   [31:0]            o_cmd_argument ,

    output reg   [1:0]             o_trans_busy   ,

    output wire  [7:0]             o_read_data    ,
    input  wire  [7:0]             i_write_data   ,
    output wire  [0:0]             o_read_fifo_en ,
    output wire  [9:0]             o_read_ram_addr,
    output wire  [9:0]             o_write_ram_addr,
    output wire                    o_flag_reading ,
    output wire                    o_fifo_wr_en   ,

    output wire                    o_write_block_start   ,

    output wire                    o_flag_writing ,
    output reg   [2:0]             o_read_status  ,
    output reg   [2:0]             o_write_status ,
    output reg                     o_read_done    ,
    output reg                     o_write_done   ,
    input  wire                    i_wrempty      ,
    input  wire                    i_rdfull       ,

    output wire  [31:0]            o_read_sector_count  ,
    output wire  [31:0]            o_write_sector_count ,

    // inout        [3:0]             b_sd_data      ,
    input    [3:0]                 sd_data_i      ,
    output                         sd_dir_o       ,
    output   [3:0]                 sd_data_o      ,

    output                         read_data_count_db
);

localparam STATE_IDLE          = 5'd0  ;
localparam STATE_WAIT0         = 5'd1  ;
localparam STATE_CMD6_CH       = 5'd2  ;
localparam STATE_CMD6_CH_RESP  = 5'd3  ;
localparam STATE_WAIT_CMD6_CH  = 5'd4  ;
localparam STATE_CMD6_SW       = 5'd5  ;
localparam STATE_CMD6_SW_RESP  = 5'd6  ;
localparam STATE_WAIT_CMD6_SW  = 5'd7  ;
localparam STATE_CMD16         = 5'd8  ;
localparam STATE_CMD16_RESP    = 5'd9  ;
localparam STATE_CMD18         = 5'd12 ;
localparam STATE_CMD18_RESP    = 5'd13 ;
localparam STATE_CMD25         = 5'd16 ;
localparam STATE_CMD25_RESP    = 5'd17 ;
localparam STATE_ACMD23_0      = 5'd18 ;
localparam STATE_ACMD23_RESP_0 = 5'd19 ;
localparam STATE_ACMD23        = 5'd20 ;
localparam STATE_ACMD23_RESP   = 5'd21 ;
localparam STATE_CMD23         = 5'd22 ;
localparam STATE_CMD23_RESP    = 5'd23 ;
localparam STATE_WAIT_READ     = 5'd24 ;
localparam STATE_WAIT_WRITE    = 5'd25 ;
localparam STATE_CMD12         = 5'd26 ;
localparam STATE_CMD12_RESP    = 5'd27 ;
localparam STATE_INACTIVE      = 5'd28 ;
localparam STATE_DONE          = 5'd29 ;


wire  [31:0]            w_sector_count        ;
wire  [31:0]            w_write_sector_count  ;
wire  [31:0]            w_read_sector_count   ;
reg   [31:0]            r_sector_count        ;
reg                     r_trans_wrong         ;
wire  [3:0]             w_read_sd_data        ;
wire  [3:0]             w_write_sd_data       ;

reg                     r_choice_sd_data      ;
wire                    w_read_data_dir       ;
wire                    w_write_data_dir      ;
wire                    w_read_req            ;
wire  [3:0]             write_o_sd_data       ;
wire  [3:0]             read_o_sd_data        ;
reg   [3:0]             r_sd_data_i           ;

reg   [3:0]             r_sd_data             ;
reg                     r_sd_dir;


// assign b_sd_data = r_sd_dir ? r_sd_data : 4'bzzzz;


assign o_read_req           = (Current_state == STATE_WAIT_READ) ? w_read_req : 1'b0;
assign w_sector_count       = i_trans_sel ? w_write_sector_count : w_read_sector_count;
assign o_write_sector_count = r_sector_count;
assign o_read_sector_count  = r_sector_count;

always @ (posedge i_clk or negedge i_rst_n)
  if(~i_rst_n)
    r_sd_data_i <= 4'b0;
  else
    r_sd_data_i <= sd_data_i;
    //sd_data_i <= b_sd_data;

always @ (posedge i_clk or negedge i_rst_n)
  if(~i_rst_n)
    r_sd_data <= 4'hF;
  else if(r_choice_sd_data)
      r_sd_data <= write_o_sd_data;
  else
      r_sd_data <= read_o_sd_data ;

assign sd_data_o = r_sd_data;

always @ (posedge i_clk or negedge i_rst_n)
  if(~i_rst_n)
    r_sd_dir <= 1'b0;
  else if(r_choice_sd_data)
      r_sd_dir <= w_write_data_dir;
  else
      r_sd_dir <= w_read_data_dir ;

assign sd_dir_o = r_sd_dir;

wire  [7:0] w_cmd6_argument;
assign w_cmd6_argument =  (i_speed_mode==0) ? 8'h01 :
                          (i_speed_mode==1) ? 8'h01 :
                          (i_speed_mode==2) ? 8'h01 :
                          (i_speed_mode==3) ? 8'h02 :
                          (i_speed_mode==4) ? 8'h03 : 8'h01;
// wire  [31:0] w_cmd6_argument;
// assign w_cmd6_argument =  (i_speed_mode==0) ? 32'h00FF_FF01 :
                          // (i_speed_mode==1) ? 32'h00FF_FF01 :
                          // (i_speed_mode==2) ? 32'h00FF_FF01 :
                          // (i_speed_mode==3) ? 32'h00FF_FF02 :
                          // (i_speed_mode==4) ? 32'h00FF_FF03 : 32'h00FF_FF01;



wire [2:0] w_read_status ;
wire [2:0] w_write_status;

reg  [9:0] r_trans_size  ;
reg  [1:0] r_start_dval  ;
always @ (posedge i_clk or negedge i_rst_n)
  if(~i_rst_n)
    r_start_dval <= 2'b0;
  else begin
    r_start_dval[0] <= i_trans_start;
    r_start_dval[1] <= r_start_dval[0];
  end

reg [4:0] Current_state;
reg [4:0] Next_state;
always @ (posedge i_clk or negedge i_rst_n)
  if(~i_rst_n)
    Current_state <= STATE_IDLE;
  else
    Current_state <= Next_state;

always @ (*)
  if(~i_rst_n)
    Next_state <= STATE_IDLE;
  else case(Current_state)
    STATE_IDLE         : Next_state <= (i_initial_done[7] & (r_start_dval == 2'b01)) ? STATE_WAIT0 : STATE_IDLE;
    STATE_WAIT0        : Next_state <= CSD[86] ? STATE_CMD6_CH : STATE_CMD16 ;
    STATE_CMD6_CH      : Next_state <= (i_cmd_tran_reg[3]) ? STATE_CMD6_CH_RESP :  STATE_CMD6_CH ;
    STATE_CMD6_CH_RESP : Next_state <= (i_cmd_tran_reg[2:0] == 3'b010) ? STATE_IDLE : (i_cmd_tran_reg[2:0] == 3'b001) ? STATE_INACTIVE : STATE_WAIT_CMD6_CH;
    STATE_WAIT_CMD6_CH : Next_state <= (w_read_status == 3'b011) ? STATE_CMD6_SW : (w_read_status[2:0]  == 3'b010) ? STATE_IDLE : STATE_WAIT_CMD6_CH;
    STATE_CMD6_SW      : Next_state <= (i_cmd_tran_reg[3]) ? STATE_CMD6_SW_RESP : STATE_CMD6_SW ;
    STATE_CMD6_SW_RESP : Next_state <= (i_cmd_tran_reg[2:0] == 3'b010) ? STATE_IDLE : (i_cmd_tran_reg[2:0] == 3'b001) ? STATE_INACTIVE : STATE_WAIT_CMD6_SW;
    STATE_WAIT_CMD6_SW : Next_state <= (w_read_status == 3'b011) ? STATE_CMD16 : (w_read_status == 3'b010) ? STATE_IDLE : STATE_WAIT_CMD6_SW;
    STATE_CMD16        : Next_state <= (i_cmd_tran_reg[3]) ? STATE_CMD16_RESP : STATE_CMD16 ;
    STATE_CMD16_RESP   : Next_state <= (i_cmd_tran_reg[2:0] == 3'b010) ? STATE_IDLE : (i_cmd_tran_reg[2:0] == 3'b001) ? STATE_INACTIVE : STATE_ACMD23_0;
    STATE_CMD18        : Next_state <= (i_cmd_tran_reg[3]) ? STATE_CMD18_RESP : STATE_CMD18 ;
    STATE_CMD18_RESP   : Next_state <= (i_cmd_tran_reg[2:0] == 3'b010) ? STATE_IDLE : (i_cmd_tran_reg[2:0] == 3'b001) ? STATE_INACTIVE :STATE_WAIT_READ;
    STATE_ACMD23_0     : Next_state <= (i_cmd_tran_reg[3]) ? STATE_ACMD23_RESP_0 : STATE_ACMD23_0 ;
    STATE_ACMD23_RESP_0: Next_state <= (i_cmd_tran_reg[2:0] == 3'b010) ? STATE_IDLE : (i_cmd_tran_reg[2:0] == 3'b001) ? STATE_INACTIVE : STATE_ACMD23;
    STATE_ACMD23       : Next_state <= (i_cmd_tran_reg[3]) ? STATE_ACMD23_RESP : STATE_ACMD23 ;
    STATE_ACMD23_RESP  : Next_state <= (i_cmd_tran_reg[2:0] == 3'b010) ? STATE_IDLE : (i_cmd_tran_reg[2:0] == 3'b001) ? STATE_INACTIVE : i_trans_sel ? STATE_CMD25 : STATE_CMD18;
    STATE_CMD23        : Next_state <= (i_cmd_tran_reg[3]) ? STATE_CMD23_RESP : STATE_CMD23 ;
    STATE_CMD23_RESP   : Next_state <= (i_cmd_tran_reg[2:0] == 3'b010) ? STATE_IDLE : (i_cmd_tran_reg[2:0] == 3'b001) ? STATE_INACTIVE :i_trans_sel ? STATE_CMD25 : STATE_CMD18;
    STATE_CMD25        : Next_state <= (i_cmd_tran_reg[3]) ? STATE_CMD25_RESP : STATE_CMD25 ;
    STATE_CMD25_RESP   : Next_state <= (i_cmd_tran_reg[2:0] == 3'b010) ? STATE_IDLE : (i_cmd_tran_reg[2:0] == 3'b001) ? STATE_INACTIVE :STATE_WAIT_WRITE;
    STATE_INACTIVE     : Next_state <= STATE_IDLE;
    STATE_WAIT_READ    : Next_state <= (i_rdfull  || (w_read_status[2:1]  == 2'b01)) ? (i_trans_sector>0) ? STATE_CMD12 : STATE_DONE : STATE_WAIT_READ ;
    STATE_WAIT_WRITE   : Next_state <= (w_write_status[2:1] == 2'b01) ? (i_trans_sector > 0) ? STATE_CMD12 : STATE_DONE : STATE_WAIT_WRITE ;
    STATE_CMD12        : Next_state <= (i_cmd_tran_reg[3]) ? STATE_CMD12_RESP : STATE_CMD12 ;
    STATE_CMD12_RESP   : Next_state <= (i_cmd_tran_reg[2:0] == 3'b010) ? STATE_IDLE : (i_cmd_tran_reg[2:0] == 3'b001) ? STATE_INACTIVE :((r_sd_data_i == 4'b1111)) ? (r_sector_count == i_trans_sector) ? STATE_DONE  : STATE_ACMD23_0 : STATE_CMD12_RESP;
    STATE_DONE         : Next_state <= STATE_IDLE;
    default            :;
  endcase


//   ila_0 sd_cmd_state(
// 	.clk(i_clk), // input wire clk
// 	.probe0({Current_state}), // input wire [255:0]  probe0
// 	.probe1({i_cmd_tran_reg,w_write_status,i_trans_sector,r_sd_data_i}), // input wire [63:0]  probe1
// 	.probe2({r_trans_size,r_trans_sector}), // input wire [63:0]  probe2
// 	.probe3(probe3), // input wire [7:0]  probe3
// 	.probe4(r_write_trans_start), // input wire [0:0]  probe4
// 	.probe5(i_trans_sel), // input wire [0:0]  probe5
// 	.probe6({w_write_sector_count,r_sector_count}) // input wire [255:0]  probe6
// );



always @ (posedge i_clk or negedge i_rst_n)
  if (~i_rst_n)  begin
    r_sector_count  <= 32'h0;
    r_trans_wrong   <= 1'b0;
  end else case(Current_state)
    STATE_IDLE         :begin r_sector_count <= (i_initial_done[7] & (r_start_dval == 2'b01)) ? 0 : r_sector_count;  r_trans_wrong <= 1'b0;end
    STATE_WAIT_READ    :begin r_sector_count <= (w_read_status  == 3'b101) ? r_sector_count + 1 : r_sector_count; r_trans_wrong   <= 1'b0;end
    STATE_WAIT_WRITE   :begin r_sector_count <= (w_write_status == 3'b101) ? r_sector_count + 1 : r_sector_count; r_trans_wrong   <= 1'b0;end
    STATE_CMD12        :begin r_sector_count <= r_sector_count; r_trans_wrong <= (r_sector_count == i_trans_sector) ? 1'b0 : 1'b1;end
    STATE_CMD12_RESP   :begin r_sector_count <= r_sector_count; r_trans_wrong <= (r_sector_count == i_trans_sector) ? 1'b0 : 1'b1; end
    default            :begin r_sector_count <= r_sector_count; r_trans_wrong <= 1'b0;end
  endcase

always @ (posedge i_clk or negedge i_rst_n)
  if (~i_rst_n) begin
    o_read_done  <=1'b0;
    o_write_done <=1'b0;
  end else case(Current_state)
    STATE_WAIT_READ    : begin o_read_done  <= (w_read_status == 3'b101) ? 1'b1 : 1'b0;  o_write_done <= 1'b0;end
    STATE_WAIT_WRITE   : begin o_read_done  <= 1'b0;  o_write_done <= (w_write_status == 3'b101) ? 1'b1 : 1'b0;end
    default            : begin o_read_done  <= 1'b0;  o_write_done <= 1'b0;end
  endcase

always @ (posedge i_clk or negedge i_rst_n)
  if (~i_rst_n)  begin
    o_cmd_tran_dval <= 1'b0;
    o_cmd_index     <= 6'd0;
    o_cmd_argument  <= 32'h0;
  end else case(Current_state)
    STATE_IDLE         :begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= 6'd0;        o_cmd_argument <= 32'h0;          end
    STATE_WAIT0        :begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= 6'd0;        o_cmd_argument <= 32'h0;          end
    STATE_CMD6_CH      :begin o_cmd_tran_dval <= 1'b1; o_cmd_index <= 6'd6;        o_cmd_argument <= {24'h00FFFF,w_cmd6_argument};end//{1'b0,w_cmd6_argument[30:0]};  end
    STATE_CMD6_CH_RESP :begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index; o_cmd_argument <= o_cmd_argument; end
    STATE_WAIT_CMD6_CH :begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index; o_cmd_argument <= o_cmd_argument; end
    STATE_CMD6_SW      :begin o_cmd_tran_dval <= 1'b1; o_cmd_index <= 6'd6;        o_cmd_argument <= {24'h80FFFF,w_cmd6_argument};end//{1'b1,w_cmd6_argument[30:0]};  end
    STATE_CMD6_SW_RESP :begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index; o_cmd_argument <= o_cmd_argument; end
    STATE_WAIT_CMD6_SW :begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index; o_cmd_argument <= o_cmd_argument; end
    STATE_CMD16        :begin o_cmd_tran_dval <= 1'b1; o_cmd_index <= 6'd16;       o_cmd_argument <= 32'd512;   end//i_trans_size;   end
    STATE_CMD16_RESP   :begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index; o_cmd_argument <= o_cmd_argument; end
    STATE_CMD18        :begin o_cmd_tran_dval <= 1'b1; o_cmd_index <= 6'd18;       o_cmd_argument <= i_trans_addr + r_sector_count;   end
    STATE_CMD18_RESP   :begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index; o_cmd_argument <= o_cmd_argument; end
    STATE_CMD25        :begin o_cmd_tran_dval <= 1'b1; o_cmd_index <= 6'd25;       o_cmd_argument <= i_trans_addr + r_sector_count;   end
    STATE_CMD25_RESP   :begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index; o_cmd_argument <= o_cmd_argument; end
    STATE_ACMD23_0     :begin o_cmd_tran_dval <= 1'b1; o_cmd_index <= 6'd55;       o_cmd_argument <= {RCA,16'b0};    end
    STATE_ACMD23_RESP_0:begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index; o_cmd_argument <= o_cmd_argument; end
    STATE_ACMD23       :begin o_cmd_tran_dval <= 1'b1; o_cmd_index <= 6'd23;       o_cmd_argument <= i_trans_sector - r_sector_count; end
    STATE_ACMD23_RESP  :begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index; o_cmd_argument <= o_cmd_argument; end
    STATE_CMD23        :begin o_cmd_tran_dval <= 1'b1; o_cmd_index <= 6'd23;       o_cmd_argument <= i_trans_sector - r_sector_count; end
    STATE_CMD23_RESP   :begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index; o_cmd_argument <= o_cmd_argument; end
    STATE_INACTIVE     :begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= 6'd0;        o_cmd_argument <=  32'h0;         end
    STATE_WAIT_READ    :begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= 6'd0;        o_cmd_argument <=  32'h0;         end
    STATE_WAIT_WRITE   :begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= 6'd0;        o_cmd_argument <=  32'h0;         end
    STATE_CMD12        :begin o_cmd_tran_dval <= 1'b1; o_cmd_index <= 6'd12;       o_cmd_argument <=  32'h0;         end
    STATE_CMD12_RESP   :begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= o_cmd_index; o_cmd_argument <= o_cmd_argument; end
    STATE_DONE         :begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= 6'd0;        o_cmd_argument <=  32'h0;         end
    default            :begin o_cmd_tran_dval <= 1'b0; o_cmd_index <= 6'd0;        o_cmd_argument <=  32'h0;         end
  endcase

always @ (posedge i_clk or negedge i_rst_n)
  if (~i_rst_n) begin
    r_trans_size <= 10'b0;
    r_choice_sd_data <= 1'b0;
  end else case(Current_state)
    STATE_IDLE         : begin r_trans_size <= 10'b0;         r_choice_sd_data <= 1'b0;  end
    STATE_WAIT0        : begin r_trans_size <= r_trans_size;  r_choice_sd_data <= 1'b0;  end
    STATE_CMD6_CH      : begin r_trans_size <= 10'd64;        r_choice_sd_data <= 1'b0;  end
    STATE_CMD6_CH_RESP : begin r_trans_size <= r_trans_size;  r_choice_sd_data <= 1'b0;  end
    STATE_WAIT_CMD6_CH : begin r_trans_size <= r_trans_size;  r_choice_sd_data <= 1'b0;  end
    STATE_CMD6_SW      : begin r_trans_size <= 10'd64;        r_choice_sd_data <= 1'b0;  end
    STATE_CMD6_SW_RESP : begin r_trans_size <= r_trans_size;  r_choice_sd_data <= 1'b0;  end
    STATE_WAIT_CMD6_SW : begin r_trans_size <= r_trans_size;  r_choice_sd_data <= 1'b0;  end
    STATE_CMD16        : begin r_trans_size <= 10'd512 ;/*i_trans_size; */ r_choice_sd_data <= 1'b0;  end
    STATE_CMD16_RESP   : begin r_trans_size <= r_trans_size;  r_choice_sd_data <= 1'b0;  end
    STATE_CMD18        : begin r_trans_size <= 10'd512;       r_choice_sd_data <= 1'b0;  end
    STATE_CMD18_RESP   : begin r_trans_size <= r_trans_size;  r_choice_sd_data <= 1'b0;  end
    STATE_CMD25        : begin r_trans_size <= 10'd512;       r_choice_sd_data <= 1'b1;  end
    STATE_CMD25_RESP   : begin r_trans_size <= r_trans_size;  r_choice_sd_data <= 1'b1;  end
    STATE_CMD23        : begin r_trans_size <= r_trans_size;  r_choice_sd_data <= 1'b0;  end
    STATE_CMD23_RESP   : begin r_trans_size <= r_trans_size;  r_choice_sd_data <= 1'b0;  end
    STATE_INACTIVE     : begin r_trans_size <= r_trans_size;  r_choice_sd_data <= 1'b0;  end
    STATE_WAIT_READ    : begin r_trans_size <= r_trans_size;  r_choice_sd_data <= 1'b0;  end
    STATE_WAIT_WRITE   : begin r_trans_size <= r_trans_size;  r_choice_sd_data <= 1'b1;  end
    STATE_CMD12        : begin r_trans_size <= r_trans_size;  r_choice_sd_data <= 1'b0;  end
    STATE_CMD12_RESP   : begin r_trans_size <= r_trans_size;  r_choice_sd_data <= 1'b0;  end
    STATE_DONE         : begin r_trans_size <= r_trans_size;  r_choice_sd_data <= 1'b0;  end
    default            : begin r_trans_size <= r_trans_size;  r_choice_sd_data <= 1'b0;  end
  endcase

always @ (posedge i_clk or negedge i_rst_n)
  if (~i_rst_n) begin
    o_read_status  <= 3'b0;
    o_write_status <= 3'b0;
  end else case(Current_state)
    STATE_WAIT_CMD6_CH : begin  o_read_status  <= w_read_status; o_write_status <= o_write_status;  end
    STATE_WAIT_CMD6_SW : begin  o_read_status  <= w_read_status; o_write_status <= o_write_status;  end
    STATE_WAIT_READ    : begin  o_read_status  <= w_read_status; o_write_status <= o_write_status;  end
    STATE_WAIT_WRITE   : begin  o_read_status  <= o_read_status; o_write_status <= w_write_status;  end
    default            : begin  o_read_status  <= o_read_status; o_write_status <= o_write_status;  end
  endcase


reg         r_read_trans_start;
reg         r_write_trans_start;
reg [31:0]  r_trans_sector;
reg [31:0]  r_write_trans_sector;

always @ (posedge i_clk or negedge i_rst_n)
  if (~i_rst_n) begin
    r_read_trans_start    <= 1'b0;
    r_write_trans_start   <= 1'b0;
    r_trans_sector        <= 32'b0;
  end else case(Current_state)
    STATE_WAIT_CMD6_CH : begin r_read_trans_start <= 1'b1; r_write_trans_start <= 1'b0; r_trans_sector <= 32'b0;          end
    STATE_WAIT_CMD6_SW : begin r_read_trans_start <= 1'b1; r_write_trans_start <= 1'b0; r_trans_sector <= 32'b0;          end
    STATE_CMD18        : begin r_read_trans_start <= 1'b0; r_write_trans_start <= 1'b0; r_trans_sector <= i_trans_sector - r_sector_count; end
    STATE_CMD18_RESP   : begin r_read_trans_start <= 1'b0; r_write_trans_start <= 1'b0; r_trans_sector <= i_trans_sector - r_sector_count; end
    STATE_CMD25        : begin r_read_trans_start <= 1'b0; r_write_trans_start <= 1'b0; r_trans_sector <= i_trans_sector - r_sector_count; end
    STATE_CMD25_RESP   : begin r_read_trans_start <= 1'b0; r_write_trans_start <= 1'b0; r_trans_sector <= i_trans_sector - r_sector_count; end
    STATE_WAIT_READ    : begin r_read_trans_start <= 1'b1; r_write_trans_start <= 1'b0; r_trans_sector <= r_trans_sector; end
    STATE_WAIT_WRITE   : begin r_read_trans_start <= 1'b0; r_write_trans_start <= 1'b1; r_trans_sector <= r_trans_sector; end
    default            : begin r_read_trans_start <= 1'b0; r_write_trans_start <= 1'b0; r_trans_sector <= 32'b0;          end
  endcase

always @ (posedge i_clk or negedge i_rst_n)
  if (~i_rst_n)
    o_trans_busy <= 2'b0;
  else if(Current_state == STATE_DONE)
    o_trans_busy <= 2'b0;
  else if((Current_state == STATE_IDLE) || (Current_state == STATE_WAIT0))
    o_trans_busy <= {1'b0,o_trans_busy[0]};
  else if(Current_state == STATE_INACTIVE)
    o_trans_busy <= 2'b01;
  else
    o_trans_busy <= 2'b10;



wire w_fifo_wr_en;
SD_Dat_read SD_Dat_read_inst(
  .i_clk            (i_clk                   ),
  .i_rst_n          (i_rst_n & (!r_trans_wrong)),

  .i_trans_start    (r_read_trans_start      ),
  .i_trans_size     (r_trans_size            ),//r_trans_size
  .i_trans_sector   (r_trans_sector          ),//r_trans_sector

  .o_read_data      (o_read_data             ),
  .o_read_ram_addr  (o_read_ram_addr         ),
  .o_flag_reading   (o_flag_reading          ),
  .o_fifo_wr_en     (w_fifo_wr_en            ),
  .o_read_status    (w_read_status           ),

  .o_sector_count   (w_read_sector_count     ),

  .sd_data_dir      (w_read_data_dir         ),
  .i_sd_data        (r_sd_data_i             ),
  .o_sd_data        (read_o_sd_data          ),
  .read_data_count_db (read_data_count_db)
);


assign o_fifo_wr_en = w_fifo_wr_en & (Current_state == STATE_WAIT_READ) ;

// ila_0 sd_tran (
// 	.clk(i_clk), // input wire clk


// 	.probe0(w_read_status), // input wire [7:0]  probe0
// 	.probe1(Current_state), // input wire [7:0]  probe1
// 	.probe2(probe2), // input wire [15:0]  probe2
// 	.probe3(r_trans_sector), // input wire [31:0]  probe3
// 	.probe4(r_read_trans_start), // input wire [0:0]  probe4
// 	.probe5(probe5), // input wire [0:0]  probe5
// 	.probe6(o_flag_reading), // input wire [0:0]  probe6
// 	.probe7({r_start_dval,o_trans_busy}), // input wire [15:0]  probe7
// 	.probe8({r_sector_count,o_read_status,o_read_done}), // input wire [119:0]  probe8
// 	.probe9(probe9) // input wire [255:0]  probe9
// );




// fifo_generator_0 sd_rd_data
// (
//   .rst              (~rst_n         ),                      // input wire rst

//   .wr_clk           (i_clk            ),          // input wire wr_clk
//   .wr_en            (o_flag_reading          ),          // input wire wr_en
//   .din              (o_read_data       ),          // input wire [31 : 0] din

//   .rd_clk           (ddr_clk        ),          // input wire rd_clk
//   .rd_en            (r_ddr_rd_en      ),          // input wire rd_en
//   .dout             (w_ddr_wr_data    ),          // output wire [255 : 0] dout
//   .valid(valid),
//   .full             (),                         // output wire full
//   .empty            (),                         // output wire empty
//   .rd_data_count    (rd_usedw       ),          // output wire [7 : 0] rd_data_count
//   .wr_data_count    (wr_usedw),                 // output wire [10 : 0] wr_data_count
//   .wr_rst_busy      (wr_rst_busy    ),          // output wire wr_rst_busy
//   .rd_rst_busy      (rd_rst_busy    )           // output wire rd_rst_busy
// );








SD_Dat_write SD_Dat_write_inst(
  .i_clk            (i_clk                   ),
  .i_rst_n          (i_rst_n & (!r_trans_wrong)),

  .i_ram_empty      ( i_wrempty              ),

  .i_trans_start    ( r_write_trans_start    ),
  .i_trans_size     ( r_trans_size           ),
  .i_trans_sector   ( r_trans_sector         ),

  .i_write_data     (i_write_data            ),
  .o_read_fifo_en   (o_read_fifo_en          ),
  .o_write_ram_addr (o_write_ram_addr        ),
  .o_flag_writing   (o_flag_writing          ),
  // .o_ram_status   (o_write_ram_status),
  .o_write_status   (w_write_status          ),

  .o_sector_count   (w_write_sector_count    ),

  .sd_data_dir      (w_write_data_dir        ),
  .i_sd_data        (r_sd_data_i             ),
  .o_sd_data        (write_o_sd_data         )
);

assign o_write_block_start = r_write_trans_start;


endmodule


