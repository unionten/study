`timescale 1ns / 1ps
module SD_CTRL#(
    parameter integer   S_AXI_DATA_WIDTH   	= 32	,
    parameter integer   S_AXI_ADDR_WIDTH    = 20	,
    parameter integer   C_M_AXI_ID_WIDTH		= 1		,
    parameter integer   C_M_AXI_ADDR_WIDTH	= 32	,
    parameter integer   C_M_AXI_DATA_WIDTH	= 256	,  
    // parameter           READ_BURST_LENGTH   = 16  ,
    parameter           READ_BURST_LENGTH   = 8   ,
    parameter           WRITE_BURST_LENGTH  = 8   ,
    parameter           DEBUG_READ_SD_EN	  = 0   ,
    parameter           DEBUG_WRITE_SD_EN	  = 0   ,
    parameter           BPC                 = 10

)(
  input    wire                                 i_clk_100M         ,
  // input 			                                  sys_clk_p       ,
  // input 			                                  sys_clk_n       ,

  // input    wire                                 i_clk100M     ,
  input    wire                                 rst_n_i         ,
  // input    wire                                 i_rst_n       ,

  //SD_PIN
  input  wire                                   i_sd_cs_n     ,
  output wire                                   o_sd_clk      ,

  // inout  wire                                   b_sd_cmd      ,
  output                                        sd_cmd_dir_o      ,
  output                                        sd_cmd_o        ,
  input  wire                                   sd_cmd_i        ,

  // inout  wire  [3:0]                            b_sd_data     ,
  input        [3:0]                            sd_data_i      ,
  output                                        sd_dir_o       ,
  output       [3:0]                            sd_data_o      ,


  //for debug
  // output wire                                o_sd_cs_n_db     ,
  // output wire                                o_sd_clk_db      ,
  // inout  wire                                b_sd_cmd_db      ,
  // output wire  [3:0]                         b_sd_data_db     ,
  // output                                     sd_cmd_dir_db    ,

  // output wire                                o_sd_power    ,
  output                                        sd_1v8_en       ,
  output                                        sd_3v3_en       ,
  output                                        sd_en_n         ,// 电平转换芯片

  output [1:0]                                  sd_io_dir       ,

  //------------------------------------ AXI LITE -------------------------------//
	input	 wire 									                S_AXI_ACLK		  ,
	input	 wire 									                S_AXI_ARESETN		,
	output wire    									              S_AXI_AWREADY		,
	input	 wire [S_AXI_ADDR_WIDTH-1:0]	     	    S_AXI_AWADDR	  ,
	input	 wire 									                S_AXI_AWVALID		,
	input	 wire [ 2:0]							              S_AXI_AWPROT		,
	output wire 									                S_AXI_WREADY		,
	input	 wire [S_AXI_DATA_WIDTH-1:0]	     	    S_AXI_WDATA			,
	input	 wire [(S_AXI_DATA_WIDTH/8)-1 :0]	 	    S_AXI_WSTRB			,
	input	 wire									                  S_AXI_WVALID		,
	output wire [ 1:0]							              S_AXI_BRESP			,
	output wire 									                S_AXI_BVALID		,
	input	 wire 									                S_AXI_BREADY		,
	output wire 									                S_AXI_ARREADY		,
	input	 wire [S_AXI_ADDR_WIDTH-1:0]			      S_AXI_ARADDR		,
	input	 wire 									                S_AXI_ARVALID		,
	input  wire [ 2:0]							              S_AXI_ARPROT		,
	output wire [ 1:0]							              S_AXI_RRESP			,
	output wire 									                S_AXI_RVALID		,
	output wire [S_AXI_DATA_WIDTH-1:0]			      S_AXI_RDATA			,
	input	 wire 									                S_AXI_RREADY		,

  //------------------------------------ AXI 4  -------------------------------//
  input  wire  								                  M_AXI4_ACLK		  ,
  input  wire  								                  M_AXI4_ARESETN	,

  output wire [C_M_AXI_ID_WIDTH   - 1 : 0] 	    M_AXI4_AWID		  ,
  output wire [C_M_AXI_ADDR_WIDTH - 1 : 0] 	    M_AXI4_AWADDR	  ,
  output wire [7 : 0] 						              M_AXI4_AWLEN	  ,
  output wire [2 : 0] 						              M_AXI4_AWSIZE	  ,
  output wire [1 : 0] 						              M_AXI4_AWBURST	,
  output wire  								                  M_AXI4_AWLOCK	  ,
  output wire [3 : 0] 						              M_AXI4_AWCACHE	,
  output wire [2 : 0] 						              M_AXI4_AWPROT	  ,
  output wire [3 : 0] 						              M_AXI4_AWQOS	  ,
  output wire  								                  M_AXI4_AWVALID	,
  input  wire  								                  M_AXI4_AWREADY	,

  //output wire [C_M00_AXI_AWUSER_WIDTH-1 : 0] M_AXI4_AWUSER	,

  output wire  								                  M_AXI4_WID		,
  output wire [C_M_AXI_DATA_WIDTH-1 : 0] 		    M_AXI4_WDATA	,
  output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] 	    M_AXI4_WSTRB	,
  output wire  								                  M_AXI4_WLAST	,
  //output wire [C_M_AXI_WUSER_WIDTH-1 : 0] 	  M_AXI4_WUSER	,
  output wire  								                  M_AXI4_WVALID	,
  input wire  								                  M_AXI4_WREADY	,

  input wire [C_M_AXI_ID_WIDTH-1 : 0] 		      M_AXI4_BID		,
  input wire [1 : 0] 							              M_AXI4_BRESP	,
  //input wire [C_M_AXI_BUSER_WIDTH-1 : 0] 	M_AXI4_BUSER	,
  input wire  								                  M_AXI4_BVALID	,
  output wire  								                  M_AXI4_BREADY ,




  input               										      M_AXI4_ARREADY      ,

  output  [C_M_AXI_ID_WIDTH - 1:0]      			  M_AXI4_ARID         ,
  output  [C_M_AXI_ADDR_WIDTH-1:0]              M_AXI4_ARADDR       ,
  output  [ 7:0]      										      M_AXI4_ARLEN        ,
  output  [ 2:0]      										      M_AXI4_ARSIZE       ,
  output  [ 1:0]      										      M_AXI4_ARBURST      ,
  output  [ 0:0]      										      M_AXI4_ARLOCK       ,
  output  [ 3:0]      										      M_AXI4_ARCACHE      ,
  output  [ 2:0]      										      M_AXI4_ARPROT       ,
  output              										      M_AXI4_ARVALID      ,
  output  [ 3:0]      										      M_AXI4_ARQOS        ,
  output  [ 3:0]      										      M_AXI4_ARREGION     ,
  input   [ 3:0]      										      M_AXI4_RID          ,
  input   [ 1:0]      										      M_AXI4_RRESP        ,
  input               										      M_AXI4_RVALID       ,
  input   [C_M_AXI_DATA_WIDTH-1:0]     	        M_AXI4_RDATA        ,
  input               										      M_AXI4_RLAST        ,
  output             											      M_AXI4_RREADY











    );




wire [3:0]      w_sd_data;

assign o_sd_cs_n_db  = sdclk_div;

assign b_sd_data_db  =  sd_data_i ;
assign sd_cmd_dir_db = sd_cmd_dir_o;


wire sd_cmd_o;
assign b_sd_cmd_db = sd_cmd_dir_db ? sd_cmd_o : 1'bz;





// -----------------------------------------------------------------------------------




wire             w_sd_rst_n_axi4        ;

wire             w_initial_en           ;
wire [3:0]       w_speed_mode           ; //0: 25M 1:50M 2:100M 3:200M
wire             w_trans_start          ;
wire             w_trans_sel            ;
wire [31:0]      w_trans_size           ;
wire [31:0]      w_srctor_size          ;
wire [31:0]      w_wr_srctor_size       ;
wire [31:0]      w_srctor_size_sel      ;

wire [31:0]      w_trans_addr           ;
wire [31:0]      w_trans_addr_sel       ;
wire [31:0]      w_read_addr            ;

wire             w_sd_rst_n             ;
wire [31:0]      w_ddr_addr             ;

wire  [10:0]      w_initial_status      ;
wire  [7:0]       w_trans_status        ;
wire  [2:0]       w_write_status        ;
wire  [2:0]       w_read_status         ;

wire              w_sd_dir              ;
wire              sdclk_div             ;

wire              w_init_cmd_tran_dval  ;
wire  [ 5:0]      w_init_cmd_index      ;
wire  [31:0]      w_init_cmd_argument   ;

wire              w_flag_reading        ;
wire              w_fifo_wr_en          ;
wire              w_flag_writing        ;
wire [31:0]       w_read_sector_count   ;
wire [31:0]       w_write_sector_count  ;

wire [ 9:0]       w_read_addr_sd        ;
wire [ 7:0]       w_read_data_sd        ;
wire [ 9:0]       w_read_addr_m         ;
wire              w_ram_read_en_m       ;

wire [ 9:0]       w_write_addr_sd       ;
wire [ 7:0]       w_write_data_sd       ;
wire [ 0:0]       w_read_fifo_en        ;
wire [ 0:0]       w_sd_read_start       ;
wire [ 9:0]       w_write_addr_m        ;

wire              w_ram_write_en_m      ;
wire [1:0]        w_trans_busy          ;



wire  [31:0]      R1_RESP               ;
wire  [119:0]     R2_RESP               ;
wire  [31:0]      R3_RESP               ;
wire  [31:0]      R6_RESP               ;
wire  [11:0]      R7_RESP               ;
wire  [15:0]      w_RCA                 ;
wire  [119:0]     w_CSD                 ;
wire  [119:0]     w_CID                 ;
wire  [3:0]       w_cmd_tran_reg        ; //1000 done ,1001 no response ,1010 CRC err
wire              w_sd_power            ;

//SD卡电压配置固定成1.8V(实际2.2V）
assign sd_1v8_en    = 1'b1;
assign sd_3v3_en    = 1'b0;
// 重启 sd 卡断电
// assign sd_en_n      = 1'b0;
assign sd_en_n      = w_sd_power;
//UH8S 电平转化方向 选择
assign sd_io_dir[0] =  sd_dir_o;
assign sd_io_dir[1] =  sd_dir_o;
// assign sd_io_dir[0] =  w_sd_dir;
// assign sd_io_dir[1] =  w_sd_dir;


wire w_clk200M;
wire locked;
clk_wiz_0 clk_100m(
  .clk_out1   (w_clk200M  ),
  //.resetn     (rst_n_i    ), //KU
  .reset      (~rst_n_i ), //K7
  .locked     (locked     ),
  .clk_in1    (i_clk_100M )
);

assign i_rst_n = locked;


wire  [263:0]                         DMA_CFG_DAT   ;
reg   [63:0]                          o_crc_out     ;
wire                                  DMA_DONE      ;
wire                                  OP_DONE       ;

wire                                  w_rx_dval     ;
wire [S_AXI_ADDR_WIDTH-1:0]           w_rx_addr     ;
wire [S_AXI_DATA_WIDTH-1:0]           w_rx_data     ;
wire                                  w_rx_done     ;

wire                                  w_tx_req      ;
wire [S_AXI_ADDR_WIDTH-1:0]           w_tx_addr     ;
wire [S_AXI_DATA_WIDTH-1:0]           w_tx_data     ;
wire                                  w_tx_dval     ;
wire                                  w_DMA_DONE    ;

wire                                  w_cmd_tran_dval       ;
wire  [ 5:0]                          w_cmd_index           ;
wire  [31:0]                          w_cmd_argument        ;
wire                                  w_trans_cmd_tran_dval ;
wire  [ 5:0]                          w_trans_cmd_index     ;
wire  [31:0]                          w_trans_cmd_argument  ;
wire                                  w_rburst_done         ;
wire                                  w_write_block_start   ;
// wire i_clk = i_clk100M;
wire [31:0]                           w_data_type           ;

sd_reg_block#(
    .C_S_DATA_WIDTH       (S_AXI_DATA_WIDTH     ),
    .C_S_ADDR_WIDTH       (S_AXI_ADDR_WIDTH     )
)sd_reg_block_inst(
    .i_clk                (S_AXI_ACLK           ),
    .i_rst_n              (S_AXI_ARESETN        ),

    .i_clk_sd             (sdclk_div            ),
    .rst_n_sd             (i_rst_n              ),

    .ddr_clk              (M_AXI4_ACLK          ),

    .i_sd_cs_n            (i_sd_cs_n            ),
    .i_RCA                (w_RCA                ),//sdclk_div
    .i_CSD                (w_CSD                ),//sdclk_div
    .i_CID                (w_CID                ),//sdclk_div
    .R1_RESP              (R1_RESP              ),//sdclk_div
    .i_initial_status     (w_initial_status     ),//sdclk_div
    .i_trans_status       (w_trans_status       ),//sdclk_div
    .i_read_sector_count  (w_read_sector_count  ),//sdclk_div
    .i_write_sector_count (w_write_sector_count ),//sdclk_div

    .i_rburst_done        (w_rburst_done        ),
    .o_initial_en         (w_initial_en         ),//w_initial_en
    .o_trans_start        (w_trans_start        ),//w_trans_start
    .o_trans_sel          (w_trans_sel          ),//w_trans_sel //0:read 1:write
    .o_speed_mode         (w_speed_mode         ),//w_speed_mode
    .o_trans_size         (w_trans_size         ),
    .o_srctor_size        (w_srctor_size        ),
    .o_trans_addr         (w_trans_addr         ),
    .o_sd_rst             (w_sd_rst_n           ),

    .o_sd_rst_axi4        (w_sd_rst_n_axi4      ),

    .o_ddr_addr           (w_ddr_addr           ),
    .o_sd_power           (w_sd_power           ),

    .o_data_type          (w_data_type          ),

    .i_rx_dval            (w_rx_dval            ),
    .i_rx_addr            (w_rx_addr            ),
    .i_rx_data            (w_rx_data            ),
    // .o_rx_done         (w_rx_done            ),

    .i_tx_req             (w_tx_req             ),
    .i_tx_addr            (w_tx_addr            ),
    .o_tx_data            (w_tx_data            ),
    .o_tx_dval            (w_tx_dval            )
);

SD_Initial_block SD_Initial_block_inst(
    .i_clk            (sdclk_div              ),
    .w_clk100M        (w_clk200M              ),
    .i_rst_n          (i_rst_n                ),
    .i_initial_en     (w_initial_en           ),
    .o_initial_status (w_initial_status[10:8] ),
    .o_initial_done   (w_initial_status[7:0]  ),
    .o_cmd_tran_dval  (w_init_cmd_tran_dval   ),
    .o_cmd_index      (w_init_cmd_index       ),
    .o_cmd_argument   (w_init_cmd_argument    ),
    .i_cmd_tran_reg   (w_cmd_tran_reg         ),
    .RCA              (w_RCA                  ),
    .CSD              (w_CSD                  ),
    .CID              (w_CID                  ),
    .R1_RESP          (R1_RESP                ),
    .R2_RESP          (R2_RESP                ),
    .R3_RESP          (R3_RESP                ),
    .R6_RESP          (R6_RESP                ),
    .R7_RESP          (R7_RESP                )
);


assign  w_cmd_tran_dval = ~ w_trans_busy[1] ? w_init_cmd_tran_dval : w_trans_cmd_tran_dval ;
assign  w_cmd_index     = ~ w_trans_busy[1] ? w_init_cmd_index     : w_trans_cmd_index     ;
assign  w_cmd_argument  = ~ w_trans_busy[1] ? w_init_cmd_argument  : w_trans_cmd_argument  ;

assign w_trans_start_sel =  w_trans_sel ? w_sd_read_start : w_trans_start ; ////w_trans_sel //0:read sd 1:write sd
assign w_srctor_size_sel =  w_trans_sel ? w_wr_srctor_size : w_srctor_size;
assign w_trans_addr_sel  =  w_trans_sel ? w_read_addr : w_trans_addr;

SD_Cmd_tran_Block SD_Cmd_tran_Block_inst(
  .i_clk                (sdclk_div      ),  //FOD 200Khz
  .w_clk100M            (w_clk200M      ),
  .i_rst_n              (i_rst_n & w_sd_rst_n),

  .sd_cmd_o             (sd_cmd_o       ),
  .sd_cmd_dir           (sd_cmd_dir_o   ),
  .sd_cmd_i             (sd_cmd_i       ),

  .i_cmd_tran_dval      (w_cmd_tran_dval),
  .i_cmd_index          (w_cmd_index    ),
  .i_cmd_argument       (w_cmd_argument ),
  .o_cmd_tran_reg       (w_cmd_tran_reg ),//1000 done ,1001 no response ,1010 CRC err
  .R1_RESP              (R1_RESP        ),
  .R2_RESP              (R2_RESP        ),
  .R3_RESP              (R3_RESP        ),
  .R6_RESP              (R6_RESP        ),
  .R7_RESP              (R7_RESP        )
);

SD_Dat_tran_block SD_Dat_tran_block_inst(
  .i_clk                (sdclk_div            ),
  .i_rst_n              (i_rst_n  & w_sd_rst_n),
  .i_initial_done       (w_initial_status[7:0]),
  .i_speed_mode         (w_speed_mode         ),
  .RCA                  (w_RCA                ),
  .CSD                  (w_CSD                ),

  .i_trans_start        (w_trans_start_sel    ),//w_trans_start
  .i_trans_sel          (w_trans_sel          ),//[0]:0 read  1 write
  .i_trans_size         (w_trans_size         ),
  .i_trans_sector       (w_srctor_size_sel    ), //w_srctor_size
  .i_trans_addr         (w_trans_addr_sel     ),//w_trans_addr

  .i_cmd_tran_reg       (w_cmd_tran_reg),

  .o_cmd_tran_dval      ( w_trans_cmd_tran_dval),
  .o_cmd_index          ( w_trans_cmd_index    ),
  .o_cmd_argument       ( w_trans_cmd_argument ),

  .o_trans_busy         ( w_trans_busy        ),

  .o_flag_writing       (w_flag_writing       ),
  .i_write_data         (w_write_data_sd      ),
  // .o_sd_read_start      (w_sd_read_start      ),//SD  read data from fifo
  .o_read_fifo_en       (w_read_fifo_en       ),
  .o_read_ram_addr      (w_read_addr_sd       ),

  .o_write_block_start  (w_write_block_start  ),

  .o_write_ram_addr     (w_write_addr_sd      ),//unuse
  .o_flag_reading       (w_flag_reading       ),//start read data
  .o_fifo_wr_en         (w_fifo_wr_en         ),//data valid
  .o_read_data          (w_read_data_sd       ),
  .o_read_status        (w_read_status        ),//read status

  .o_write_status       (w_write_status       ),
  .o_read_sector_count  (w_read_sector_count  ),
  .o_write_sector_count (w_write_sector_count ),
  .o_read_done          (w_read_done          ),
  .o_write_done         (w_write_done         ),
  .sd_data_i            (sd_data_i            ),
  .sd_dir_o             (sd_dir_o             ),
  .sd_data_o            (sd_data_o            ),
  .read_data_count_db   (read_data_count_db   )
);



wire                              w_fdma_wareq   ;
wire                              w_fdma_wready  ;
wire                              w_fdma_wbusy   ;
wire [C_M_AXI_DATA_WIDTH  -1 :0]  w_fdma_wdata   ;

bmp_data_transfer #(
  // .READ_BURST_LENGTH    (READ_BURST_LENGTH        ),
  .READ_BURST_LENGTH    (512*8/C_M_AXI_DATA_WIDTH ),
  .WRITE_BURST_LENGTH   (WRITE_BURST_LENGTH       ),
  .C_M_AXI_ID_WIDTH		  (C_M_AXI_ID_WIDTH         ),
  .C_M_AXI_ADDR_WIDTH 	(C_M_AXI_ADDR_WIDTH       ),
  .C_M_AXI_DATA_WIDTH 	(C_M_AXI_DATA_WIDTH       ),
  .DEBUG_WRITE_SD_EN 	  (DEBUG_WRITE_SD_EN        ),
  .DEBUG_READ_SD_EN 	  (DEBUG_READ_SD_EN         ),
  .BPC                  (BPC                      )

)bmp_data_transfer_inst (
  .clk                  (sdclk_div                ),
  // .rst_n             (i_rst_n & (!w_read_status[1]) & w_sd_rst_n),
  .rst_n                (i_rst_n & w_sd_rst_n     ),

  .i_read_status        (w_read_status            ),//read status
  .i_sd_rd_data         (w_read_data_sd           ),
  .i_sd_reading         (w_flag_reading           ), //data valid
  .i_fifo_wr_en         (w_fifo_wr_en             ),

  .i_data_type          (w_data_type              ),
  .ddr_clk		 	        (M_AXI4_ACLK			        ),
	.ddr_rst_n		        (M_AXI4_ARESETN	& w_sd_rst_n_axi4	),
	// .ddr_rst_n		      (M_AXI4_ARESETN	),
	.ddr_wready	          (w_fdma_wready			      ),// 写入DDR数据有效

	.ddr_wareq            (w_fdma_wareq			        ),//启动AXI4
	.ddr_busy		          (w_fdma_wbusy			        ),
	.axi_awready	        (M_AXI4_AWREADY & M_AXI4_AWVALID),  //AXI_SLAVE 确认地址有效
	.axi_wready 	        (M_AXI4_WREADY			      ),              //AXI_SLAVE 确认可以接收数据
  .ddr_wr_data          (w_fdma_wdata			        ),               //  to ddr

  //for test
	// .ddr_clk		        (sdclk_div			  ),
	// .ddr_rst_n	        (i_rst_n			    ),
	// .ddr_wready		    (w_fdma_wready		),// 写入DDR数据有效
	// .ddr_wareq         (w_fdma_wareq			),//启动AXI4
	// .ddr_busy			    (w_fdma_wbusy			),
	// .axi_awready	      (1),//AXI_SLAVE 确认地址有效
	// .axi_wready 	      (1),//AXI_SLAVE 确认可以接收数据
  // .ddr_wr_data       (w_fdma_wdata			) //  to ddr

  .o_sd_read_start      (w_sd_read_start     ),//SD  read data from fifo
  .i_start_read_ddr     (w_trans_start & w_trans_sel),//ddr write to fifo
  .i_start_read_ddr_addr(w_ddr_addr          ), //ddr write to fifo from ddr address
  .i_bmp_byte_size      (w_srctor_size       ),
  .o_srctor_size        (w_wr_srctor_size    ),

  .i_write_block_start  (w_write_block_start ),

  .i_trans_addr         (w_trans_addr        ),//w_trans_addr
  .o_trans_addr         (w_read_addr         ),//w_trans_addr

  .i_read_fifo_en       (w_read_fifo_en      ),
  .i_flag_writing       (w_flag_writing      ),
  .i_write_status       (w_write_status      ),
  .o_write_data         (w_write_data_sd     ),
  .i_trans_busy         (w_trans_busy        ),

  .o_rburst_done        (w_rburst_done       ),
  //read_ddr_interface
  .m_axi4_arready     	(M_AXI4_ARREADY      ),
  .m_axi4_arid        	(M_AXI4_ARID         ),
  .m_axi4_araddr      	(M_AXI4_ARADDR       ),
  .m_axi4_arlen       	(M_AXI4_ARLEN        ),
  .m_axi4_arsize      	(M_AXI4_ARSIZE       ),
  .m_axi4_arburst     	(M_AXI4_ARBURST      ),
  .m_axi4_arlock      	(M_AXI4_ARLOCK       ),
  .m_axi4_arcache     	(M_AXI4_ARCACHE      ),
  .m_axi4_arprot      	(M_AXI4_ARPROT       ),
  .m_axi4_arvalid     	(M_AXI4_ARVALID      ),
  .m_axi4_arqos       	(M_AXI4_ARQOS        ),
  .m_axi4_arregion    	(M_AXI4_ARREGION     ),
  .m_axi4_rid         	(M_AXI4_RID          ),
  .m_axi4_rresp       	(M_AXI4_RRESP        ),
  .m_axi4_rvalid      	(M_AXI4_RVALID       ),
  .m_axi4_rdata       	(M_AXI4_RDATA        ),
  .m_axi4_rlast       	(M_AXI4_RLAST        ),
  .m_axi4_rready      	(M_AXI4_RREADY       )

);





generate
  if(DEBUG_READ_SD_EN==1)begin
      ila_0 read_sd_inst (
          .clk(M_AXI4_ACLK), // input wire clk
          .probe0(M_AXI4_WDATA[255:0]), // input wire [255:0]  probe0
          .probe1({bmp_data_transfer_inst.ddr_busy,bmp_data_transfer_inst.ddr_wareq,M_AXI4_WREADY,M_AXI4_WVALID}), // input wire [31:0]  probe1
          .probe2(bmp_data_transfer_inst.r_data_cnt), // input wire [31:0]  probe2
          .probe3(M_AXI4_AWADDR),// input wire [31:0]  probe3
          .probe4(bmp_data_transfer_inst.r_burst_cnt_db), // input wire [31:0]  probe4
          .probe5({bmp_data_transfer_inst.rd_rst_busy,bmp_data_transfer_inst.overflow,bmp_data_transfer_inst.rd_usedw[7:0]}), // input wire [15:0]  probe5
          .probe6(bmp_data_transfer_inst.wr_state), // input wire [7:0]  probe6
          .probe7({bmp_data_transfer_inst.full,bmp_data_transfer_inst.w_data_empty}), // input wire [7:0]  probe7
          .probe8(bmp_data_transfer_inst.w_file_tpye_valid_axi4) // input wire [0:0]  probe8
      );

      ila_1 sd_rd_inst (
	      .clk    (sdclk_div), // input wire clk
        .probe0 ({w_trans_addr_sel,w_data_type}), // input wire [63:0]  probe0
	      .probe1 ({w_srctor_size_sel}), // input wire [31:0]  probe1
	      .probe2 ({w_read_status,bmp_data_transfer_inst.w_file_tpye_valid,w_trans_start_sel,w_fifo_wr_en}), // input wire [15:0]  probe2
	      .probe3 (w_read_data_sd), // input wire [7:0]  probe3
	      .probe4 (w_flag_reading), // input wire [0:0]  probe4
	      .probe5 (bmp_data_transfer_inst.r_bmp_file_type) // input wire [0:0]  probe5
      );

  end
endgenerate



axi4_master # (
	.M_AXI_ID_WIDTH		(C_M_AXI_ID_WIDTH   ),
	.M_AXI_ID			    (0),
	.M_AXI_ADDR_WIDTH	(C_M_AXI_ADDR_WIDTH	),
	.M_AXI_DATA_WIDTH	(C_M_AXI_DATA_WIDTH	)
)axi4_master_inst(
	.i_ddr_addr_h		(0	                  ),
	.i_ddr_addr_l		(w_ddr_addr	          ),

	.fdma_wlen			(WRITE_BURST_LENGTH		),  //突发长度
	// .fdma_wsize       	(w_fdma_wsize		), 	//w_fdma_wsize FDMA_WSIZE_NUM
	.fdma_cnt				(fdma_cnt             ),
	.fdma_waddr     (0		                ),
	.fdma_wdata			(w_fdma_wdata		      ),	//w_fdma_wdata
	// .fdma_wstrb			(32'hffffffff		      ),	//计算显示像素的位置生成STRB
	.fdma_wstrb			({C_M_AXI_DATA_WIDTH/8{1'b1}}),	//计算显示像素的位置生成STRB
	.fdma_wend			(w_fdma_wend		      ),

	.fdma_wareq     (w_fdma_wareq		      ),
	.fdma_wbusy     (w_fdma_wbusy		      ),

	.fdma_wvalid    (w_fdma_wvalid		    ),
	.fdma_wready		(w_fdma_wready		    ),

	.M_AXI_ACLK			(M_AXI4_ACLK		      ),
	.M_AXI_ARESETN	(M_AXI4_ARESETN	      ),
  .i_ddr_addr_rst (w_sd_rst_n_axi4      ),//复位内部的起始地址
	.M_AXI_AWID			(M_AXI4_AWID		      ),
	.M_AXI_AWADDR		(M_AXI4_AWADDR		    ),
	.M_AXI_AWLEN		(M_AXI4_AWLEN		      ),
	.M_AXI_AWSIZE		(M_AXI4_AWSIZE		    ),
	.M_AXI_AWBURST	(M_AXI4_AWBURST		    ),
	.M_AXI_AWLOCK		(M_AXI4_AWLOCK		    ),
	.M_AXI_AWCACHE	(M_AXI4_AWCACHE		    ),
	.M_AXI_AWPROT		(M_AXI4_AWPROT		    ),
	.M_AXI_AWQOS		(M_AXI4_AWQOS		      ),
	.M_AXI_AWVALID	(M_AXI4_AWVALID		    ),
	.M_AXI_AWREADY	(M_AXI4_AWREADY		    ),

	.M_AXI_WID			(M_AXI4_WID			      ),
	.M_AXI_WDATA		(M_AXI4_WDATA		      ),
	.M_AXI_WSTRB		(M_AXI4_WSTRB		      ),//M_AXI4_WSTRB
	.M_AXI_WLAST		(M_AXI4_WLAST		      ),
	.M_AXI_WVALID		(M_AXI4_WVALID		    ),
	.M_AXI_WREADY		(M_AXI4_WREADY		    ),
	.M_AXI_BID			(M_AXI4_BID			      ),
	.M_AXI_BRESP		(M_AXI4_BRESP		      ),
	.M_AXI_BVALID		(M_AXI4_BVALID		    ),
	.M_AXI_BREADY		(M_AXI4_BREADY		    )
);

AXI_Lite_Slave#	 (
  .C_S_AXI_DATA_WIDTH   (S_AXI_DATA_WIDTH),
  .C_S_AXI_ADDR_WIDTH   (S_AXI_ADDR_WIDTH)
)AXI_Lite_Slave_inst(
  .S_AXI_ACLK		        (S_AXI_ACLK			),
  .S_AXI_ARESETN	      (S_AXI_ARESETN	),
  .S_AXI_AWREADY	      (S_AXI_AWREADY	),
  .S_AXI_AWADDR	        (S_AXI_AWADDR		),
  .S_AXI_AWVALID	      (S_AXI_AWVALID	),
  .S_AXI_AWPROT	        (S_AXI_AWPROT		),
  .S_AXI_WREADY	        (S_AXI_WREADY		),
  .S_AXI_WDATA	        (S_AXI_WDATA		),
  .S_AXI_WSTRB	        (S_AXI_WSTRB		),
  .S_AXI_WVALID	        (S_AXI_WVALID		),
  .S_AXI_BRESP	        (S_AXI_BRESP		),
  .S_AXI_BVALID	        (S_AXI_BVALID		),
  .S_AXI_BREADY	        (S_AXI_BREADY		),
  .S_AXI_ARREADY	      (S_AXI_ARREADY	),
  .S_AXI_ARADDR	        (S_AXI_ARADDR		),
  .S_AXI_ARVALID	      (S_AXI_ARVALID	),
  .S_AXI_ARPROT	        (S_AXI_ARPROT		),
  .S_AXI_RRESP	        (S_AXI_RRESP		),
  .S_AXI_RVALID	        (S_AXI_RVALID		),
  .S_AXI_RDATA	        (S_AXI_RDATA		),
  .S_AXI_RREADY	        (S_AXI_RREADY		),

  .o_rx_dval		        (w_rx_dval			),
  .o_rx_addr		        (w_rx_addr			),
  .o_rx_data		        (w_rx_data			),
  .o_tx_req 		        (w_tx_req 			),
  .o_tx_addr		        (w_tx_addr			),
  .i_tx_data		        (w_tx_data			),
  .i_tx_dval		        (w_tx_dval			)
);




  sdio_clk_gen  sdio_clk_gen_inst(
    .i_clk100M    (w_clk200M    ),
    .i_rst_n      (i_rst_n      ),
    .i_speed_mode (w_speed_mode ),
    .sdclk_div_o  (sdclk_div    ),
    .o_sd_clk     (o_sd_clk     ),
    .o_sd_clk_db  (o_sd_clk_db  )//o_sd_clk_db
  );

  assign w_trans_status = {w_trans_busy,w_write_status,w_read_status};

endmodule