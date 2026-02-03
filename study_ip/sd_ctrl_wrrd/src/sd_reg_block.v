`timescale 1ns / 1ps
module sd_reg_block#(
   parameter integer   C_S_DATA_WIDTH    =  32,
   parameter integer   C_S_ADDR_WIDTH    =  16
)(
   input  wire                            i_clk       ,
   input  wire                            i_rst_n     ,

   input  wire                            i_clk_sd    ,
   input  wire                            rst_n_sd    ,

   input  wire                            ddr_clk    ,

   input  wire                            i_sd_cs_n   ,

   input  wire [ 15:0]                    i_RCA       ,
   input  wire [119:0]                    i_CSD       ,
   input  wire [119:0]                    i_CID       ,
   input  wire [ 31:0]                    R1_RESP     ,

   input  wire [ 10:0]                    i_initial_status     ,
   input  wire [  7:0]                    i_trans_status       ,
   input  wire [ 31:0]                    i_read_sector_count  ,
   input  wire [ 31:0]                    i_write_sector_count ,

   input  wire                            i_rburst_done        ,

   output reg                             o_initial_en         ,//
   output wire                             o_trans_start        ,//
   // output reg                             o_trans_start        ,//
   output reg                             o_trans_sel          ,////0:read 1:write

   output wire [  3:0]                    o_speed_mode         ,//
   output wire [ 31:0]                    o_trans_size         ,//
   output wire [ 31:0]                    o_srctor_size        ,//
   output wire [ 31:0]                    o_trans_addr         ,//
   output wire [ 31:0]                    o_ddr_addr           ,//

   output wire                            o_sd_rst             ,
   output wire                            o_sd_rst_axi4        ,
   output reg                             o_sd_power           ,
   output wire  [31:0]                    o_data_type          ,

   output reg                             o_sd_1v8_en          ,
   output reg                             o_sd_3v3_en          ,
   output reg                             o_sd_en_n            ,// 电平转换芯片
   output reg [1:0]                       o_sd_io_dir          ,

   output [1:0]                           o_sd_init_done       ,
   output [0:0]                           o_initial_en_db       ,
   output [1:0]                           o_sd_tran_speed_db       ,

////////////////////////////////////////////////////
// Local Bus User interface
   input   wire                           i_rx_dval            ,
   input   wire  [C_S_ADDR_WIDTH-1:0]     i_rx_addr            ,
   input   wire  [C_S_DATA_WIDTH-1:0]     i_rx_data            ,
   output  reg                            o_rx_done            ,

   input   wire                           i_tx_req             ,
   input   wire  [C_S_ADDR_WIDTH-1:0]     i_tx_addr            ,
   output  reg   [C_S_DATA_WIDTH-1:0]     o_tx_data            ,
   output  reg                            o_tx_dval
);



localparam SD_COMMAND_OFFSET          = 16'h0000 ;
localparam SD_TRANS_SPEED_OFFSET      = 16'h0004 ;
localparam SD_SD_ADDR_OFFSET          = 16'h0008 ;
localparam SD_DDR_ADDR_OFFSET         = 16'h000c ;
localparam SD_TRANS_SECTOR_OFFSET     = 16'h0010 ;
localparam SD_TRANS_SIZE_OFFSET       = 16'h0014 ;
localparam SD_RESET_PS                = 16'h0018 ;
localparam SD_SD_POWER_OFFSET         = 16'h001c ;
localparam SD_CMD_DVAL_OFFSET         = 16'h0020 ;
localparam SD_CMD_INDEX_OFFSET        = 16'h0024 ;
localparam SD_CMD_ARGUMENT_OFFSET     = 16'h0028 ;


localparam SD_LINK_STATUS_OFFSET        = 16'h0020 ;
localparam SD_TRANS_STATUS_OFFSET       = 16'h0024 ;
localparam SD_CARD_SIZE_OFFSET          = 16'h0028 ;
localparam SD_RCA_OFFSET                = 16'h002c ;
localparam SD_CID0_OFFSET               = 16'h0030 ;
localparam SD_CID1_OFFSET               = 16'h0034 ;
localparam SD_CID2_OFFSET               = 16'h0038 ;
localparam SD_CID3_OFFSET               = 16'h003c ;
localparam SD_CSD0_OFFSET               = 16'h0040 ;
localparam SD_CSD1_OFFSET               = 16'h0044 ;
localparam SD_CSD2_OFFSET               = 16'h0048 ;
localparam SD_CSD3_OFFSET               = 16'h004c ;
localparam SD_READ_SECTOR_COUNT_OFFSET  = 16'h0050 ;
localparam SD_WRITE_SECTOR_COUNT_OFFSET = 16'h0054 ;
localparam SD_WRITE_SECTOR_DONE_OFFSET  = 16'h0058 ;
localparam SD_DATA_FILE_TYPE_OFFSET     = 16'h005c ;

localparam SD_SD_R1_RESP_OFFSET         = 16'h012c ;

localparam DEFAULT_BLOCK_SIZE = 1920 * 1080 *4 /512 + 1; //默认2k图像

reg r_rx_dval;
reg r_tx_req;
always @ (posedge i_clk or negedge i_rst_n)
   if(~i_rst_n) begin
      r_rx_dval <= 1'b0;
      r_tx_req  <= 1'b0;
   end else begin
      r_rx_dval <= i_rx_dval;
      r_tx_req  <= i_tx_req;
   end

always @ (posedge i_clk or negedge i_rst_n)
   if(~i_rst_n) begin
      o_rx_done <= 1'b0;
   end else if({r_rx_dval,i_rx_dval} == 2'b01) begin
      o_rx_done <= 1'b1;
   end else begin
      o_rx_done <= 1'b0;
   end

//====================================for clock cross==========================
reg [4:0] r_timely_dval_count ;
reg       r_timely_dval       ;
reg [2:0] r_timely_dval_eage  ;

always @ (posedge i_clk_sd or negedge rst_n_sd)
   if (~rst_n_sd)begin
      r_timely_dval_count <= 5'b0 ;
   end else if(r_timely_dval_count < 5'd15 ) begin
      r_timely_dval_count <= r_timely_dval_count + 1'b1;
   end else begin
      r_timely_dval_count <= 5'b0;
   end

always @ (posedge i_clk_sd or negedge rst_n_sd)
   if (~rst_n_sd)begin
      r_timely_dval <= 1'b0 ;
   end else if((r_timely_dval_count > 5'd2) && (r_timely_dval_count < 5'd9 )) begin
      r_timely_dval <= 1'b1;
   end else begin
      r_timely_dval <= 1'b0;
   end

always @ (posedge i_clk or negedge i_rst_n)
   if (~i_rst_n)begin
      r_timely_dval_eage <= 3'b0 ;
   end else begin
      r_timely_dval_eage[0] <= r_timely_dval;
      r_timely_dval_eage[1] <= r_timely_dval_eage[0];
      r_timely_dval_eage[2] <= r_timely_dval_eage[1];
   end



reg [10:0]    r_initial_status     ;
reg [7:0]     r_trans_status       ;

always @ (posedge i_clk_sd or negedge rst_n_sd)
   if (~rst_n_sd)begin
      r_initial_status      <= 11'b0 ;
      r_trans_status        <= 8'b0  ;
   end else if(r_timely_dval_count == 5'd10) begin
      r_initial_status      <= i_initial_status    ;
      r_trans_status        <= i_trans_status      ;
   end else begin
      r_initial_status      <= r_initial_status    ;
      r_trans_status        <= r_trans_status      ;
   end


reg [10:0]    r_2_initial_status     ;
reg [7:0]     r_2_trans_status       ;

always @ (posedge i_clk or negedge i_rst_n)
   if (~i_rst_n)begin
      r_2_initial_status      <= 11'b0 ;
      r_2_trans_status        <= 8'b0  ;
   end else if(r_timely_dval_eage[2:1] == 2'b01)begin
      r_2_initial_status      <= r_initial_status    ;
      r_2_trans_status        <= r_trans_status      ;
   end else begin
      r_2_initial_status      <= r_2_initial_status    ;
      r_2_trans_status        <= r_2_trans_status      ;
   end


wire [ 15:0]   w_rca_clk;
wire [119:0]   w_csd_clk;
wire [119:0]   w_cid_clk;

wire [ 31:0]   w_r1_resp_clk;

wire [ 31:0]   rd_sector_cnt_clk;
wire [ 31:0]   wr_sector_cnt_clk;

wire           w_rburst_done_clk;




xpm_cdc_array_single #(.DEST_SYNC_FF(4), .WIDTH(15), .SRC_INPUT_REG(0),  .SIM_ASSERT_CHK(1))
   rca_inst     (.src_in(i_RCA), .src_clk(),.dest_clk(i_clk), .dest_out(w_rca_clk));

xpm_cdc_array_single #(.DEST_SYNC_FF(4), .WIDTH(120), .SRC_INPUT_REG(0),  .SIM_ASSERT_CHK(1))
   csd_inst     (.src_in(i_CSD), .src_clk(),.dest_clk(i_clk), .dest_out(w_csd_clk));

xpm_cdc_array_single #(.DEST_SYNC_FF(4), .WIDTH(120), .SRC_INPUT_REG(0),  .SIM_ASSERT_CHK(1))
   cid_inst     (.src_in(i_CID), .src_clk(),.dest_clk(i_clk), .dest_out(w_cid_clk));




xpm_cdc_array_single #(.DEST_SYNC_FF(4), .WIDTH(32), .SRC_INPUT_REG(0),  .SIM_ASSERT_CHK(1))
   r1_resp_inst     (.src_in(R1_RESP), .src_clk(),.dest_clk(i_clk), .dest_out(w_r1_resp_clk));


xpm_cdc_array_single #(.DEST_SYNC_FF(4), .WIDTH(32), .SRC_INPUT_REG(0),  .SIM_ASSERT_CHK(1))
   rd_sector_cnt_inst     (.src_in(i_read_sector_count), .src_clk(),.dest_clk(i_clk), .dest_out(rd_sector_cnt_clk));

xpm_cdc_array_single #(.DEST_SYNC_FF(4), .WIDTH(32), .SRC_INPUT_REG(0),  .SIM_ASSERT_CHK(1))
   wr_sector_cnt_inst     (.src_in(i_write_sector_count), .src_clk(),.dest_clk(i_clk), .dest_out(wr_sector_cnt_clk));

xpm_cdc_array_single #(.DEST_SYNC_FF(4), .WIDTH(1), .SRC_INPUT_REG(0),  .SIM_ASSERT_CHK(1))
   w_rburst_done_inst     (.src_in(i_rburst_done), .src_clk(),.dest_clk(i_clk), .dest_out(w_rburst_done_clk));







// //SD卡电压配置固定成1.8V(实际2.2V）
// assign sd_1v8_en    = 1'b1;
// assign sd_3v3_en    = 1'b0;
// assign sd_en_n      = 1'b0;
// //UH8S 电平转化方向 选择
// assign sd_io_dir[0] =  w_sd_dir;
// assign sd_io_dir[1] =  w_sd_dir;

always @ (posedge i_clk or negedge i_rst_n)
   if(~i_rst_n) begin
      o_sd_1v8_en <= 1'b0;
      o_sd_3v3_en <= 1'b0;
      o_sd_en_n   <= 1'b1;
      o_sd_io_dir <= 2'b00;
   end else begin
      o_sd_1v8_en <= 1'b1;
      o_sd_3v3_en <= 1'b0;
      o_sd_en_n   <= 1'b0;
      o_sd_io_dir <= 2'b00;
   end

reg  [31:0]       r_data_type    ;


always @ (posedge i_clk or negedge i_rst_n)
   if(~i_rst_n) begin
      o_tx_data <= 'b0;
      o_tx_dval <= 1'b0;
   end else if({r_tx_req,i_tx_req}==2'b01)
      case(i_tx_addr)
         SD_LINK_STATUS_OFFSET       : begin o_tx_data <= {i_sd_cs_n,20'b0,r_2_initial_status}; o_tx_dval <= 1'b1; end
         SD_TRANS_STATUS_OFFSET      : begin o_tx_data <= {24'b0,r_2_trans_status};             o_tx_dval <= 1'b1; end
         SD_RCA_OFFSET               : begin o_tx_data <= {16'b0,w_rca_clk};                    o_tx_dval <= 1'b1; end
         SD_CID0_OFFSET              : begin o_tx_data <= {w_cid_clk[23:0],8'b0};               o_tx_dval <= 1'b1; end
         SD_CID1_OFFSET              : begin o_tx_data <= w_cid_clk[55:24];                     o_tx_dval <= 1'b1; end
         SD_CID2_OFFSET              : begin o_tx_data <= w_cid_clk[87:56];                     o_tx_dval <= 1'b1; end
         SD_CID3_OFFSET              : begin o_tx_data <= w_cid_clk[119:88];                    o_tx_dval <= 1'b1; end
         SD_CSD0_OFFSET              : begin o_tx_data <= {w_csd_clk[23:0],8'b0};               o_tx_dval <= 1'b1; end
         SD_CSD1_OFFSET              : begin o_tx_data <= w_csd_clk[55:24];                     o_tx_dval <= 1'b1; end
         SD_CSD2_OFFSET              : begin o_tx_data <= w_csd_clk[87:56];                     o_tx_dval <= 1'b1; end
         SD_CSD3_OFFSET              : begin o_tx_data <= w_csd_clk[119:88];                    o_tx_dval <= 1'b1; end
         SD_SD_R1_RESP_OFFSET        : begin o_tx_data <= w_r1_resp_clk;                        o_tx_dval <= 1'b1; end
         SD_READ_SECTOR_COUNT_OFFSET : begin o_tx_data <= rd_sector_cnt_clk ;                   o_tx_dval <= 1'b1; end
         SD_WRITE_SECTOR_COUNT_OFFSET: begin o_tx_data <= wr_sector_cnt_clk;                    o_tx_dval <= 1'b1; end
         SD_WRITE_SECTOR_DONE_OFFSET : begin o_tx_data <= w_rburst_done_clk;                    o_tx_dval <= 1'b1; end
         default                     : begin o_tx_data <= 0 ;o_tx_dval <= 1'b1; end
      endcase
      else case(i_tx_addr)
         SD_LINK_STATUS_OFFSET       : begin o_tx_data <= {i_sd_cs_n,20'b0,r_2_initial_status}; o_tx_dval <= 1'b0; end
         SD_TRANS_STATUS_OFFSET      : begin o_tx_data <= {24'b0,r_2_trans_status};             o_tx_dval <= 1'b0; end
         SD_RCA_OFFSET               : begin o_tx_data <= {16'b0,w_rca_clk};                    o_tx_dval <= 1'b0; end
         SD_CID0_OFFSET              : begin o_tx_data <= {w_cid_clk[23:0],8'b0};               o_tx_dval <= 1'b0; end
         SD_CID1_OFFSET              : begin o_tx_data <= w_cid_clk[55:24];                     o_tx_dval <= 1'b0; end
         SD_CID2_OFFSET              : begin o_tx_data <= w_cid_clk[87:56];                     o_tx_dval <= 1'b0; end
         SD_CID3_OFFSET              : begin o_tx_data <= w_cid_clk[119:88];                    o_tx_dval <= 1'b0; end
         SD_CSD0_OFFSET              : begin o_tx_data <= {w_csd_clk[23:0],8'b0};               o_tx_dval <= 1'b0; end
         SD_CSD1_OFFSET              : begin o_tx_data <= w_csd_clk[55:24];                     o_tx_dval <= 1'b0; end
         SD_CSD2_OFFSET              : begin o_tx_data <= w_csd_clk[87:56];                     o_tx_dval <= 1'b0; end
         SD_CSD3_OFFSET              : begin o_tx_data <= w_csd_clk[119:88];                    o_tx_dval <= 1'b0; end
         SD_SD_R1_RESP_OFFSET        : begin o_tx_data <= w_r1_resp_clk;                        o_tx_dval <= 1'b0; end
         SD_READ_SECTOR_COUNT_OFFSET : begin o_tx_data <= rd_sector_cnt_clk ;                   o_tx_dval <= 1'b0; end
         SD_WRITE_SECTOR_COUNT_OFFSET: begin o_tx_data <= wr_sector_cnt_clk;                    o_tx_dval <= 1'b0; end
         SD_WRITE_SECTOR_DONE_OFFSET : begin o_tx_data <= w_rburst_done_clk;                    o_tx_dval <= 1'b0; end
         SD_DATA_FILE_TYPE_OFFSET    : begin o_tx_data <= r_data_type      ;                    o_tx_dval <= 1'b0; end
         default                     : begin o_tx_data <= 0 ;o_tx_dval <= 1'b0; end
      endcase



assign o_sd_init_done = {r_2_initial_status[8],r_trans_start};




// ------------------------------------------------------    write reg  ------------------------------------------------------
// wire w_initial_en;
// wire w_trans_start;
// vio_0  port_cfg_inst(
//    .clk        (i_clk),                // input wire clk
//    .probe_out0 (probe_out0), // output wire [1 : 0] probe_out0
//    .probe_out1 (w_initial_en),  // output wire [1 : 0] probe_out0
//    .probe_out2 (probe_out2),  // output wire [3 : 0] probe_out0 w_trans_start
//    .probe_out3 (w_trans_start)  // output wire [0 : 0] probe_out0
// );


reg               r_initial_en   ;
reg               r_trans_start  ;
reg               r_trans_sel    ;
reg  [31:0]       r_trans_size   ;

reg  [31:0]       r_trans_addr   ;
reg               r_ddr_rst      ;
reg  [31:0]       r_ddr_addr     ;
reg   [3:0]       r_speed_mode   ;
reg  [31:0]       r_srctor_size  ;



always @ (posedge i_clk or negedge i_rst_n)
   if(~i_rst_n)begin
      r_initial_en      <=  1'b0;
      r_trans_start     <=  1'b0;
      r_trans_sel       <=  1'b0;

      r_speed_mode      <=  4'b0;
      r_srctor_size     <= DEFAULT_BLOCK_SIZE; // 1920*1080*32/(512*8) + 1;
      r_trans_addr      <= 32'd24832;
      r_ddr_addr        <= 32'h8000_0000;

      r_ddr_rst         <=  1'b1;
      // r_trans_size      <= 32'b0; //unuse
      o_sd_power        <=  1'b0;
      r_data_type       <= 32'h424d;
   end else if(i_rx_dval)begin
      r_initial_en      <= (i_rx_addr == SD_COMMAND_OFFSET           ) ? (i_rx_data[15:0] == 16'd1) ? 1'b1 : 1'b0 : r_initial_en;
      r_trans_sel       <= (i_rx_addr == SD_COMMAND_OFFSET           ) ? (i_rx_data[15:0] == 16'd2) ? 1'b0 : (i_rx_data[15:0] == 16'd3) ? 1'b1 : r_trans_sel : r_trans_sel;
      r_trans_start     <= (i_rx_addr == SD_COMMAND_OFFSET           ) ? (i_rx_data[15:0] == 16'd2) || (i_rx_data[15:0] == 16'd3) ? 1'b1 : 1'b0 : r_trans_start;
      r_speed_mode      <= (i_rx_addr == SD_TRANS_SPEED_OFFSET       ) ? i_rx_data[3:0] : r_speed_mode;

      r_srctor_size     <= (i_rx_addr == SD_TRANS_SECTOR_OFFSET      ) ? i_rx_data : r_srctor_size;
      r_trans_addr      <= (i_rx_addr == SD_SD_ADDR_OFFSET           ) ? i_rx_data : r_trans_addr ;
      r_ddr_addr        <= (i_rx_addr == SD_DDR_ADDR_OFFSET          ) ? i_rx_data : r_ddr_addr ;

      r_ddr_rst         <= (i_rx_addr == SD_RESET_PS                 ) ? i_rx_data[0] : r_ddr_rst ;
      // r_trans_size      <= (i_rx_addr == SD_TRANS_SIZE_OFFSET  ) ? i_rx_data : r_trans_size ;
      o_sd_power        <= (i_rx_addr == SD_SD_POWER_OFFSET          ) ? i_rx_data[0] : o_sd_power ;
      r_data_type       <= (i_rx_addr == SD_DATA_FILE_TYPE_OFFSET    ) ? i_rx_data    : r_data_type ;
   end else begin
      r_initial_en      <= 1'b0;
      r_trans_start     <= 1'b0;
      // r_initial_en      <= w_initial_en;
      // r_trans_start     <= w_trans_start;
      r_ddr_addr        <= r_ddr_addr   ;
      r_trans_sel       <= r_trans_sel  ;
      r_speed_mode      <= r_speed_mode ;
      // r_speed_mode      <= (i_initial_status[9:8] == 2'b11) ? 4'd1 : 4'd0 ; //for debug
      r_srctor_size     <= r_srctor_size;
      r_trans_addr      <= r_trans_addr ;
      r_ddr_rst         <= r_ddr_rst;
      // r_trans_size      <= r_trans_size ;
      o_sd_power        <= o_sd_power   ;
      r_data_type       <= r_data_type;
   end


// assign o_initial_en_db = (i_rx_data[1:0] == w_vio_reg) && i_rx_dval ? 1'b1 : 1'b0 ;
assign o_initial_en_db = (i_rx_data[1:0] == 2) && i_rx_dval ? 1'b1 : 1'b0 ;
// assign o_sd_tran_speed_db = r_speed_mode[1:0];
assign o_sd_tran_speed_db = {r_2_trans_start,o_trans_start};


//==================================for clock cross===============================
reg               r_2_initial_en   ;
reg               r_2_trans_start  ;
reg               r_2_trans_sel    ;

reg  [31:0]       r_2_trans_addr   ;
reg  [31:0]       r_2_ddr_addr     ;

reg   [1:0]       r_initial_edge;
reg   [3:0]       r_trans_start_edge;

always @ (posedge i_clk or negedge i_rst_n) //get intinal edage and start edage
   if (~i_rst_n)begin
      r_initial_edge         <= 2'b0;
      r_trans_start_edge     <= 4'b0;
   end else begin
      r_initial_edge[0]      <= r_initial_en;
      r_initial_edge[1]      <= r_initial_edge[0];
      r_trans_start_edge[0]  <= r_trans_start;
      r_trans_start_edge[1]  <= r_trans_start_edge[0];
      r_trans_start_edge[2]  <= r_trans_start_edge[1];
      r_trans_start_edge[3]  <= r_trans_start_edge[2];
   end

reg [9:0]r_initial_delay_count;
always @ (posedge i_clk or negedge i_rst_n)
   if (~i_rst_n)begin
      r_2_initial_en         <=  1'b0;
      r_initial_delay_count  <= 10'b0;
   end else if(r_initial_edge == 2'b01) begin
      r_2_initial_en         <=  1'b1;
      r_initial_delay_count  <= 10'b0;
   end else begin
      r_2_initial_en         <= (r_initial_delay_count < 10'd800) ?  r_2_initial_en : 1'b0 ;
      r_initial_delay_count  <= (r_initial_delay_count < 10'd800) ? (r_initial_delay_count + 1'b1) : r_initial_delay_count;
   end

reg [1:0] r_initial_en_cross;
always @ (posedge i_clk_sd or negedge rst_n_sd) //intinal enable clock cross
   if (~rst_n_sd)begin
      r_initial_en_cross <= 2'b0 ;
      o_initial_en       <= 1'b0 ;
   end else begin
      r_initial_en_cross[0] <= r_2_initial_en;
      r_initial_en_cross[1] <= r_initial_en_cross[0];
      o_initial_en          <= r_initial_en_cross[1];
   end




reg [15:0]r_start_delay_count;
always @ (posedge i_clk or negedge i_rst_n) //
   if (~i_rst_n)begin
      r_2_trans_start      <=  1'b0 ;
      r_2_trans_sel        <=  1'b0 ;

      r_2_trans_addr       <= 32'b0;
      r_start_delay_count  <= 16'b0;
   // end else if(r_trans_start_edge == 2'b01) begin
   end else if(|r_trans_start_edge) begin
      r_2_trans_start      <= 1'b1 ;
      r_2_trans_sel        <= r_trans_sel   ;

      r_2_trans_addr       <= r_trans_addr  ;
      r_start_delay_count  <= 16'b0;
   end else begin
      r_2_trans_start      <= (r_start_delay_count < 16'd800) ? r_2_trans_start : 1'b0 ;
      r_2_trans_sel        <= r_2_trans_sel   ;
      r_2_trans_addr       <= r_2_trans_addr  ;
      r_start_delay_count  <= (r_start_delay_count < 16'd800) ? (r_start_delay_count + 1'b1) : r_start_delay_count;
   end




reg [5:0] r_trans_start_cross;
// reg [3:0] r_trans_start_cross;
always @ (posedge i_clk_sd or negedge rst_n_sd)
   if (~rst_n_sd)begin
      r_trans_start_cross     <= 6'b0 ;
      // o_trans_start           <= 1'b0 ;
   end else begin
      r_trans_start_cross[0]  <= r_2_trans_start;
      r_trans_start_cross[1]  <= r_trans_start_cross[0];
      r_trans_start_cross[2]  <= r_trans_start_cross[1];
      r_trans_start_cross[3]  <= r_trans_start_cross[2];
      // o_trans_start  <= r_trans_start_cross[3];
      r_trans_start_cross[4]  <= r_trans_start_cross[3];
      r_trans_start_cross[5]  <= r_trans_start_cross[4];
   end

assign o_trans_start = |r_trans_start_cross;

reg  [31:0]      r_trans_addr_3;
always @ (posedge i_clk_sd or negedge rst_n_sd)
   if (~rst_n_sd)begin
      o_trans_sel          <= 1'b0 ;
      r_trans_addr_3       <= 32'b0;
   // end else if(r_trans_start_cross[2:1] == 2'b01) begin
   end else if(r_trans_start_cross[4:3] == 2'b01) begin
      o_trans_sel          <= r_2_trans_sel   ;
      r_trans_addr_3       <= r_2_trans_addr  ;
   end else begin
      o_trans_sel          <= o_trans_sel    ;
      r_trans_addr_3       <= r_trans_addr_3 ;
   end



wire  [3:0]       w_speed_mode_sd;
wire [31:0]       w_srctor_size_sd;

xpm_cdc_array_single #(.DEST_SYNC_FF(4), .WIDTH(32), .SRC_INPUT_REG(0),  .SIM_ASSERT_CHK(1))
   srctor_size_inst     (.src_in(r_srctor_size), .src_clk(),.dest_clk(i_clk_sd), .dest_out(w_srctor_size_sd));

xpm_cdc_array_single #(.DEST_SYNC_FF(4), .WIDTH(4), .SRC_INPUT_REG(0),  .SIM_ASSERT_CHK(1))
   speed_mode_inst     (.src_in(r_speed_mode), .src_clk(),.dest_clk(i_clk_sd), .dest_out(w_speed_mode_sd));


assign o_srctor_size = w_srctor_size_sd;
assign o_speed_mode  = w_speed_mode_sd;
assign o_trans_addr  = r_trans_addr_3;  //AXILITE TO SD_CLK
assign o_trans_size  = 512;             //AXILITE TO SD_CLK

// assign o_trans_addr = (i_CSD[119:118]==2'b0) ? {r_trans_addr[22:0],9'b0} : r_trans_addr;

// assign o_trans_addr = (i_CSD[119:118]==2'b0) ? {r_trans_addr_3[22:0],9'b0} : r_trans_addr_3;

// assign o_sd_rst = r_ddr_rst;


reg [2:0] r_ddr_rst_dly;
always @ (posedge i_clk or negedge i_rst_n)begin
   if(~i_rst_n)begin
      r_ddr_rst_dly <= 3'b111;
   end else begin
      r_ddr_rst_dly[0] <= r_ddr_rst;
      r_ddr_rst_dly[1] <= r_ddr_rst_dly[0];
      r_ddr_rst_dly[2] <= r_ddr_rst_dly[1];
   end
end

xpm_cdc_array_single #(.DEST_SYNC_FF(4), .WIDTH(1), .SRC_INPUT_REG(0),  .SIM_ASSERT_CHK(1))
   sd_rst_inst     (.src_in(&r_ddr_rst_dly), .src_clk(),.dest_clk(i_clk_sd), .dest_out(o_sd_rst));

xpm_cdc_array_single #(.DEST_SYNC_FF(4), .WIDTH(32), .SRC_INPUT_REG(0),  .SIM_ASSERT_CHK(1))
   data_type_inst     (.src_in(r_data_type), .src_clk(),.dest_clk(i_clk_sd), .dest_out(o_data_type));


xpm_cdc_array_single #(.DEST_SYNC_FF(4), .WIDTH(1), .SRC_INPUT_REG(0),  .SIM_ASSERT_CHK(1))
   sd_rst_axi4_inst     (.src_in(&r_ddr_rst_dly), .src_clk(),.dest_clk(ddr_clk), .dest_out(o_sd_rst_axi4));

wire  [31:0]       w_ddr_addr_ddr     ;
xpm_cdc_array_single #(.DEST_SYNC_FF(4), .WIDTH(32), .SRC_INPUT_REG(0),  .SIM_ASSERT_CHK(1))
   ddr_addr_inst     (.src_in(r_ddr_addr), .src_clk(),.dest_clk(ddr_clk), .dest_out(w_ddr_addr_ddr));

// assign o_ddr_addr   = w_ddr_addr_ddr >> 3; //AXILITE TO DDR CLK
assign o_ddr_addr   = w_ddr_addr_ddr; //AXILITE TO DDR CLK




endmodule