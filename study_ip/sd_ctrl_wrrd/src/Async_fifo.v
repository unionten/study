module Async_fifo #(
		parameter WR_DEPTH        = 1024,
		parameter WR_WIDTH 			  = 256,
    parameter RD_WIDTH 			  = 256,
		parameter WR_COUNT_WIDTH  = 10,
		parameter RD_COUNT_WIDTH  = 10,
		parameter READ_MODE       = "fwft"


)(
	input  							 			 wr_clk ,
	input  [WR_WIDTH-1:0]			 wr_data,
	input  										 wrreq	,
	output [WR_COUNT_WIDTH-1:0]wr_usedw,
	output 										 wr_rst_busy,
	output 										 rd_rst_busy,

	input  										 rd_clk ,
	output [RD_WIDTH-1:0]			 rd_data,
	input  							 			 rdreq  ,
  output [RD_COUNT_WIDTH-1:0]rd_usedw  ,
  output                    data_valid,
	input  										 fifo_reset,
	output  										 overflow,
	output  										 empty,
	output  										 full

);

// fifo_generator_0 xpm_fifo_async_inst (
//   .rst	 				 (fifo_reset),
//   .wr_clk				 (wr_clk),
//   .rd_clk				 (rd_clk),
//   .din	 				 (wr_data),
//   .wr_en 				 (wrreq),
//   .rd_en 				 (rdreq),
//   .dout	 				 (rd_data),
//   .full	 				 (),
//   .empty 				 (),
//   .rd_data_count (rd_usedw),
//   .wr_data_count (wr_usedw),
//   .wr_rst_busy	 (wr_rst_busy),
//   .rd_rst_busy	 ()
// );
localparam FIFO_READ_LATENCY = (READ_MODE == "fwft") ? 0 : 2;

xpm_fifo_async #(
    .CDC_SYNC_STAGES		  (2					),      // DECIMAL
    .DOUT_RESET_VALUE		  ("0"				),    	// String
    .ECC_MODE				      ("no_ecc"			),      // String
    .FIFO_MEMORY_TYPE		  ("block"			), 		// String  "auto"- Allow Vivado Synthesis to choose  "block"- Block RAM FIFO  "distributed"- Distributed RAM FIFO
    .FIFO_READ_LATENCY		(FIFO_READ_LATENCY					),     	// DECIMAL If READ_MODE = "fwft", then the only applicable value is 0.
    .FIFO_WRITE_DEPTH		  (WR_DEPTH			),   	// DECIMAL
    .FULL_RESET_VALUE		  (0					),      // DECIMAL
    .PROG_EMPTY_THRESH		(10				),    	// DECIMAL
    .PROG_FULL_THRESH		  (10				),     	// DECIMAL
    .RD_DATA_COUNT_WIDTH	(RD_COUNT_WIDTH		),   	// DECIMAL
    .READ_DATA_WIDTH		  (RD_WIDTH				),      // DECIMAL /   128    ////////////////////////////////////////////
    // .READ_MODE				    ("std"				),      // String //fwft / std
    .READ_MODE				    (READ_MODE				),      // String //fwft / std
    .RELATED_CLOCKS			  (0					),      // DECIMAL
    .SIM_ASSERT_CHK			  (0					),      // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .USE_ADV_FEATURES		  ("1C06"				), 		// String
    .WAKEUP_TIME			    (0					),      // DECIMAL
    .WRITE_DATA_WIDTH		  (WR_WIDTH	),     	// DECIMAL
    .WR_DATA_COUNT_WIDTH	(WR_COUNT_WIDTH		)    	// DECIMAL
)
xpm_fifo_async_inst
(
	  .rst					    (fifo_reset			),   //vs_cdc
	  .wr_clk					  (wr_clk		),
	  .din					    (wr_data			),  //o_wrdata
	  .wr_en					  (wrreq			),  //o_wrreq
    .rd_clk					  (rd_clk			),
    .rd_en					  (rdreq			),  //i_de
    .dout					    (rd_data		), //fifo_rddata
	  .data_valid				(data_valid),
	  .full					    (full),
    .almost_full			(),
    .almost_empty			(),
    .dbiterr				  (),
    .empty					  (empty),
    .overflow				  (overflow),
    .prog_empty				(),
    .prog_full				(			),
    .rd_data_count		(rd_usedw		), //rd_data_count
    .rd_rst_busy			(rd_rst_busy		), //rd_rst_busy
    .sbiterr				  (),
    .underflow				(),
    .wr_ack					  (),
    .wr_data_count		(wr_usedw		),//wr_data_count
    .wr_rst_busy			(wr_rst_busy		),
    .injectdbiterr		(),
    .injectsbiterr		(),
    .sleep					  (0)
);

//xpm_fifo_async #(
//  .CDC_SYNC_STAGES      (3)             ,
//  .FIFO_MEMORY_TYPE     ("auto")    		,
//  .FIFO_WRITE_DEPTH     (WR_DEPTH)      ,
//  .WRITE_DATA_WIDTH     (WR_WIDTH)      ,
//  .FULL_RESET_VALUE     (1)             ,
//	.RD_DATA_COUNT_WIDTH	(RD_COUNT_WIDTH),
//	.WR_DATA_COUNT_WIDTH	(WR_COUNT_WIDTH),
//  .PROG_FULL_THRESH			(WR_DEPTH-16)		,
//  .READ_MODE            ("fwft")        ,
//  .FIFO_READ_LATENCY    (0)             ,
//  .READ_DATA_WIDTH      (RD_WIDTH)  		,
//  .USE_ADV_FEATURES     ("1F1F")
//)
//xpm_fifo_async_inst (
//  .sleep            		(1'b0				 ),
//  .rst              		(fifo_reset	 ),
//  .wr_clk           		(wr_clk			 ),
//  .wr_en            		(wrreq	 		 ),
//  .din              		(wr_data 		 ),
//  .full             		(					   ),
//  .prog_full        		(					   ),
//  .wr_data_count    		(wr_usedw		 ),
//  .overflow         		(					   ),
//  .wr_rst_busy      		(wr_rst_busy ),
//  .almost_full      		(					   ),
//  .wr_ack           		(					   ),
//  .rd_clk           		(rd_clk      ),
//  .rd_en            		(rdreq	 		 ),
//  .dout             		(rd_data 		 ),
//  .empty            		(			 			 ),
//  .prog_empty       		(					   ),
//  .rd_data_count    		(rd_usedw		 ),
//  .underflow        		(					   ),
//  .rd_rst_busy      		(					   ),
//  .almost_empty     		(						 ),
//  .data_valid       		(						 ),
//  .injectsbiterr    		(1'b0				 ),
//  .injectdbiterr    		(1'b0				 ),
//  .sbiterr          		(						 ),
//  .dbiterr          		(						 )
//);







endmodule