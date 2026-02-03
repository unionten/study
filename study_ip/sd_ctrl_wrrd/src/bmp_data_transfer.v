`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/01/04 09:50:47
// Design Name:
// Module Name: bmp_data_transfer
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module bmp_data_transfer#(
    parameter           READ_BURST_LENGTH   = 16    , //一个block 512byte   burst_len = 512 * 8 /256 = 16
    parameter           WRITE_BURST_LENGTH  = 8     ,
    parameter integer   C_M_AXI_ID_WIDTH    = 1		,
    parameter integer   C_M_AXI_ADDR_WIDTH	= 32	,
    parameter integer   C_M_AXI_DATA_WIDTH	= 256   ,
    parameter           DEBUG_READ_SD_EN	= 0     ,
    parameter           DEBUG_WRITE_SD_EN	= 0     ,
    parameter           BPC                 = 10
)(
    input                               clk                 ,  //时钟信号
    input                               rst_n               ,  //复位信号,低电平有效

    input [7:0]                         i_sd_rd_data        ,
    input                               i_sd_reading        ,
    input                               i_fifo_wr_en        ,
    input   [2:0]                       i_read_status       ,

    input   [31:0]                      i_data_type         ,

    // ------------------------------  ddr  ---------------------------//
    input                               ddr_clk             ,
    input                               ddr_rst_n           ,
    output                              ddr_wready          ,
    output                              ddr_wareq           ,
    input                               ddr_busy            ,

    input                               axi_awready         ,
    input                               axi_wready          ,
    output  [C_M_AXI_DATA_WIDTH-1:0]    ddr_wr_data         ,//DDR写数据




    // -----------------------------read ddr -------------------------//
    output                              o_sd_read_start         ,
    output  [7:0]                       o_write_data            ,

    input                               i_start_read_ddr        ,
    input   [C_M_AXI_ADDR_WIDTH- 1:0]   i_start_read_ddr_addr   ,
    input   [31:0]                      i_bmp_byte_size         ,
    output  reg [31:0]                  o_srctor_size           ,

    output                              o_rburst_done       ,
    input   [31:0]                      i_trans_addr        ,
    output   [31:0]                     o_trans_addr        ,

    input                               i_write_block_start ,

    input                               i_read_fifo_en      ,
    input                               i_flag_writing      ,
    input   [2:0]                       i_write_status      ,
    input   [1:0]                       i_trans_busy        ,

    input               				m_axi4_arready      ,
    output  [C_M_AXI_ID_WIDTH - 1:0]    m_axi4_arid         ,
    output  [C_M_AXI_ADDR_WIDTH-1:0]    m_axi4_araddr       ,
    output  [ 7:0]      				m_axi4_arlen        ,
    output  [ 2:0]      				m_axi4_arsize       ,
    output  [ 1:0]      				m_axi4_arburst      ,
    output  [ 0:0]      				m_axi4_arlock       ,
    output  [ 3:0]      				m_axi4_arcache      ,
    output  [ 2:0]      				m_axi4_arprot       ,
    output              				m_axi4_arvalid      ,
    output  [ 3:0]      				m_axi4_arqos        ,
    output  [ 3:0]      				m_axi4_arregion     ,
    input   [ 3:0]      				m_axi4_rid          ,
    input   [ 1:0]      				m_axi4_rresp        ,
    input               				m_axi4_rvalid       ,
    input   [C_M_AXI_DATA_WIDTH-1:0]    m_axi4_rdata        ,
    input               				m_axi4_rlast        ,
    output             					m_axi4_rready







);

function integer clogb2 (input integer bit_depth);
	begin
		for(clogb2 = 0; bit_depth > 0; clogb2 = clogb2 + 1)
			bit_depth = bit_depth >> 1;
	end
endfunction



localparam BMP_FILE         = 32'h424d;
localparam AUDIO_DATA       = 32'h52494646; //RIFF
localparam CFG_DATA         = 32'h4346;
localparam SD_DATA_SHIFT_CNT    = C_M_AXI_DATA_WIDTH / 32;



// bmp文件头地址hex 字节长度（byte）            描述
//      00	          2	            固定头文件字段，内容为0x424D
//      02	          4	            bmp文件大小（little endian）
//      06	          2	            预留字段
//      08	          2	            预留字段
//      0A	          4	            图片信息的开始位置
//      0E	          4	            位图信息数据头的大小 40bytes
//      12	          4	            图像宽度（little endian）
//      16	          4	            图像高度（little endian）
//      1A	          2	            色彩平面的数量，默认为1
//      1C	          2	            每像素用多少bit表示
//      1E	          4	            图片采用的压缩方式，通常不压缩即BL_RGB，对应值0
//      22	          4	            图片大小（原始位图数据大小）对于不压缩的图片，默认为0
//      26	          4	            横向分辨率（像素/米）
//      2A	          4	            纵向分辨率（像素/米）
//      2E	          4	            调试板中颜色数量，默认为0
//      32	          4	            重要颜色的数量，默认为0



reg [31:0] r_bmp_data_addr;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin  //缺少文件读完成信号 每次读完一个bmp文件需要重置清零
        r_bmp_data_addr <= 32'd0;
    end else if(i_fifo_wr_en)begin
        r_bmp_data_addr <= r_bmp_data_addr + 1'b1;
    end else if(i_read_status[1] == 1'b1)begin
        r_bmp_data_addr <= 32'd0;
    end
end


//判断是否是BMP文件
//判断文件头 BMP --->> 16'h424D
reg  [15: 0] r_bmp_file_type;

wire [ 2: 0] w_file_tpye_valid;
wire [ 2: 0] w_file_tpye_valid_tmp;
// [0] bmp    BMP_FILE 424d
// [1] audio
// [2] cfg    4346

always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin
        r_bmp_file_type <= 32'd0;
    end else if((r_bmp_data_addr >= 32'h0) & (r_bmp_data_addr <= 32'h1) & i_fifo_wr_en)begin
        r_bmp_file_type <= {r_bmp_file_type[7:0],i_sd_rd_data};
    end else if(i_read_status[1] == 1'b1)begin
        r_bmp_file_type <= 32'd0;
    end
end

// assign w_file_tpye_valid = (r_bmp_file_type == BMP_FILE) ? 1'b1 : 1'b0;


reg r_sd_reading;// delay 1 cycle for last bytes to wr fifo;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin
        r_sd_reading <= 1'b0;
    end else begin
        r_sd_reading <= i_sd_reading;
    end
end

// assign w_file_tpye_valid[0] =   r_sd_reading && (i_data_type == BMP_FILE  ) ? (r_bmp_file_type == BMP_FILE) : 1'b0;
assign w_file_tpye_valid[0] =   (r_bmp_file_type == BMP_FILE);
assign w_file_tpye_valid[1] =   r_sd_reading && (i_data_type == AUDIO_DATA) ? 1'b1 : 1'b0;
assign w_file_tpye_valid[2] =   r_sd_reading && (i_data_type == CFG_DATA  ) ? 1'b1 : 1'b0;

assign w_file_tpye_valid_tmp[0] =   i_sd_reading && (i_data_type == BMP_FILE  ) ? 1'b1 : 1'b0;
assign w_file_tpye_valid_tmp[1] =   i_sd_reading && (i_data_type == AUDIO_DATA) ? 1'b1 : 1'b0;
assign w_file_tpye_valid_tmp[2] =   i_sd_reading && (i_data_type == CFG_DATA  ) ? 1'b1 : 1'b0;



//提取像素数据的有效起始位置
//bmp文件的起始位置 A~D
reg [31:0] r_data_addr;
reg [ 0:0] r_data_addr_latch;
always @(posedge clk or negedge rst_n) begin
    if((~rst_n) || (~w_file_tpye_valid[0]))begin
        r_data_addr <= 32'd0;
        r_data_addr_latch <= 1'd0;
    end else if((r_bmp_data_addr >= 32'hA) & (r_bmp_data_addr <= 32'hD) & i_fifo_wr_en)begin
        r_data_addr <= {i_sd_rd_data,r_data_addr[31:8]};
        r_data_addr_latch <= (r_bmp_data_addr == 32'hd);
    end
end

//提取像素数据的存储位宽
reg [7:0] r_pixel_width;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin
        r_pixel_width <= 8'd0;
    end else if((r_bmp_data_addr == 32'h1c) & i_fifo_wr_en & w_file_tpye_valid[0])begin
        r_pixel_width <= i_sd_rd_data;
    end
    else if(|w_file_tpye_valid[2:1])begin
        r_pixel_width <= 8'd8;
    end
end

//像素有效数据
reg [ 0:0] r_data_addr_valid;
always @(posedge clk or negedge rst_n) begin
    if((~rst_n) || (~w_file_tpye_valid[0]))begin
        r_data_addr_valid <= 1'b0;
    end else if(r_bmp_data_addr >= r_data_addr)begin
        r_data_addr_valid <= r_data_addr_latch;
    end
end


//图像的横向分辨率
reg [15:0] r_h_active;
always @(posedge clk or negedge rst_n) begin
    if((~rst_n) || (~w_file_tpye_valid[0]))begin
        r_h_active <= 16'd0;
    end else if((r_bmp_data_addr >= 32'h12) & (r_bmp_data_addr <= 32'h13) & i_fifo_wr_en)begin
        r_h_active <= {i_sd_rd_data,r_h_active[15:8]};
    end
end

//重新排列BMP的有效数据
//32bit: B G R 00 B G R 00
//24bit: B G R B G R B G R

reg [31:0] r_rgb_data;
reg [15:0] r_rgb_data_tmp;
reg [ 7:0] r_val_en_cnt;
reg [ 0:0] r_fifo_wr_en;
reg        r_pixel_parity;
always @(posedge clk or negedge rst_n) begin
    if((~rst_n) || (w_file_tpye_valid == 3'b0))begin
        r_rgb_data      <= 32'd0;
        r_rgb_data_tmp  <= 16'd0;
        r_val_en_cnt    <=  8'd0;
        r_fifo_wr_en    <=  1'd0;
        r_pixel_parity  <=  1'd0;
    end else if(r_data_addr_valid || w_file_tpye_valid[2])begin
        r_fifo_wr_en    <= 1'b0;

        case(r_pixel_width)
            8'd32:begin
                if(i_fifo_wr_en)begin
                    r_val_en_cnt    <= r_val_en_cnt + 1;
                    r_rgb_data_tmp  <= {i_sd_rd_data,r_rgb_data_tmp[15:8]}; //  B,8'd0 -> g,b
                    if(r_val_en_cnt == 8'd2)begin
                        r_rgb_data      <= {r_rgb_data[31:16],r_rgb_data_tmp};
                    end else if(r_val_en_cnt == r_pixel_width[7:3])begin
                        r_rgb_data      <= {8'b0,r_rgb_data_tmp[7:0],r_rgb_data[15:0]};
                        r_fifo_wr_en    <= 1'b1;
                        // r_pixel_parity  <= ~ r_pixel_parity;
                        r_val_en_cnt    <= 8'd1;
                    end
                end
            end

        8'd24:begin
                if(i_fifo_wr_en)begin
                    r_val_en_cnt    <= r_val_en_cnt + 1;
                    r_rgb_data_tmp  <= {i_sd_rd_data,r_rgb_data_tmp[15:8]}; //  B,8'd0 -> g,b
                    if(r_val_en_cnt == 8'd2)begin
                        r_rgb_data      <= {r_rgb_data[31:16],r_rgb_data_tmp};
                    end else if(r_val_en_cnt == r_pixel_width[7:3])begin
                        r_rgb_data      <= {8'b0,r_rgb_data_tmp[15:0],r_rgb_data[7:0]};
                        r_fifo_wr_en    <= 1'b1;
                        r_pixel_parity  <= ~ r_pixel_parity;
                        r_val_en_cnt    <= 8'd1;
                    end
                end
            end

        8'd8:begin
            if(i_fifo_wr_en)begin
                r_rgb_data <= {i_sd_rd_data,r_rgb_data[31:8]};
                r_val_en_cnt    <= r_val_en_cnt + 1;
                if(r_val_en_cnt == 3)begin
                    r_rgb_data <= {i_sd_rd_data,r_rgb_data[31:8]};
                    r_fifo_wr_en    <= 1'b1;
                    r_val_en_cnt    <= 8'd0;
                end
            end
        end


            default:begin
                r_rgb_data      <= 32'd0;
                r_rgb_data_tmp  <= 16'd0;
                r_val_en_cnt    <=  8'd0;
                r_fifo_wr_en    <=  1'd0;
                r_pixel_parity  <=  1'd0;
            end
        endcase
    end
end









wire [31:0] r_rgb_data_bpc ;
generate
    if(BPC == 10)begin
        assign r_rgb_data_bpc = r_pixel_width == 8'd8 ? r_rgb_data : {2'b0,r_rgb_data[23:16],2'b0,r_rgb_data[15:8],2'b0,r_rgb_data[7:0],2'b0};
    end else begin //BPC = 8
        assign r_rgb_data_bpc = r_rgb_data;
    end
endgenerate




reg [C_M_AXI_DATA_WIDTH - 1 : 0] r_data_tmp;
reg                              r_data_tmp_valid;
reg [15:0]                       r_data_tmp_cnt;
always @(posedge clk or negedge rst_n) begin
    if((~rst_n))begin
        r_data_tmp_cnt      <= 16'd0;
        r_data_tmp          <=   'b0;
        r_data_tmp_valid    <=  1'b0;
    end else if(r_fifo_wr_en)begin
        r_data_tmp          <= {r_rgb_data_bpc,r_data_tmp[C_M_AXI_DATA_WIDTH - 1 : 32]};
        r_data_tmp_valid    <= (r_data_tmp_cnt == SD_DATA_SHIFT_CNT - 1) ? 1'b1: 1'b0;
        r_data_tmp_cnt      <= (r_data_tmp_cnt == SD_DATA_SHIFT_CNT - 1) ? 16'd0 : r_data_tmp_cnt + 1;
    end else begin
        r_data_tmp_valid    <=  1'b0;
        r_data_tmp_cnt      <= r_data_tmp_cnt;
        r_data_tmp          <= r_data_tmp;
    end
end

wire w_data_tmp_valid;
assign w_data_tmp_valid =  r_fifo_wr_en ? (r_data_tmp_cnt == SD_DATA_SHIFT_CNT - 1) ? 1'b1 : 1'b0 : 1'b0;


reg [15:0] r_data_num_cnt;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin
        r_data_num_cnt <= 16'd0;
    end else if(r_sd_reading)begin
        r_data_num_cnt <= i_fifo_wr_en + r_data_num_cnt;
    end else begin
        r_data_num_cnt <= 0;
    end
end


// ila_0 bm_read (
// 	.clk(clk), // input wire clk
// 	.probe0(r_data_tmp[255:0]), // input wire [255:0]  probe0
// 	.probe1(r_rgb_data), // input wire [31:0]  probe1
// 	.probe2({wr_usedw,r_rgb_data_tmp}), // input wire [31:0]  probe2
// 	.probe3({r_pixel_width,r_val_en_cnt,r_fifo_wr_en,r_sd_reading}), // input wire [31:0]  probe3
// 	.probe4({i_sd_rd_data,r_data_num_cnt,i_read_status}), // input wire [31:0]  probe4
// 	.probe5(r_data_tmp_cnt), // input wire [15:0]  probe5
// 	.probe6({r_data_addr_valid,w_data_tmp_valid,r_data_tmp_valid,i_fifo_wr_en}), // input wire [7:0]  probe6
// 	.probe7(w_file_tpye_valid) // input wire [7:0]  probe7
// );




localparam WR_DDR_DEPTH         = C_M_AXI_DATA_WIDTH == 512 ? 512 : C_M_AXI_DATA_WIDTH == 256 ? 256 : 128;
localparam WR_DDR_COUNT_WIDTH   = clogb2(WR_DDR_DEPTH) ;




wire [11:0]                      rd_usedw;
wire [7:0]                      wr_usedw;
wire                            rd_rst_busy;
reg                             r_ddr_rd_en;
wire                            w_ddr_rd_en;
wire [C_M_AXI_DATA_WIDTH-1:0]   w_ddr_wr_data;
wire                            valid;

// fifo_generator_0 sd_rd_data
// (
//     .rst              ((~rst_n)         ),          // input wire rst
//     .wr_clk           (clk              ),          // input wire wr_clk
//     .wr_en            (r_fifo_wr_en     ),          // input wire wr_en
//     .din              (r_rgb_data       ),          // input wire [31 : 0] din

//     .rd_clk           (ddr_clk          ),          // input wire rd_clk
//     .rd_en            (w_ddr_rd_en      ),          // input wire rd_en
//     .dout             (w_ddr_wr_data    ),          // output wire [255 : 0] dout
//     .valid            (valid),
//     .full             (),                           // output wire full
//     .empty            (),                           // output wire empty
//     .rd_data_count    (rd_usedw         ),          // output wire [7 : 0] rd_data_count
//     .wr_data_count    (wr_usedw         ),          // output wire [10 : 0] wr_data_count
//     .wr_rst_busy      (wr_rst_busy      ),          // output wire wr_rst_busy
//     .rd_rst_busy      (rd_rst_busy      )           // output wire rd_rst_busy
// );
wire w_data_empty;
wire full;

Async_fifo #(
	.WR_DEPTH       	(WR_DDR_DEPTH			),
	.WR_WIDTH 			(C_M_AXI_DATA_WIDTH     ),
    .RD_WIDTH 			(C_M_AXI_DATA_WIDTH     ),
	.WR_COUNT_WIDTH 	(WR_DDR_COUNT_WIDTH 	),
	.RD_COUNT_WIDTH 	(WR_DDR_COUNT_WIDTH 	),
    .READ_MODE 	        ("fwft" 	            )
)sd_rd_data(
    .fifo_reset       	((~rst_n)   		    ),

	.wr_clk           	(clk  		            ),
	.wr_data          	(r_data_tmp             ),
	.wrreq	          	(r_data_tmp_valid	    ),


	.rd_clk           	(ddr_clk	  		    ),
    .rdreq            	(w_ddr_rd_en    	    ),
	.rd_data          	(ddr_wr_data	        ),
    .data_valid         (valid                  ),
	.overflow			(overflow),
    .full				(full),
	.empty				(w_data_empty           ),
	.rd_usedw         	(rd_usedw   	        ),
	.wr_usedw         	(wr_usedw	  	        ),
    .wr_rst_busy      	(wr_rst_busy		    ),
	.rd_rst_busy      	(rd_rst_busy		    )
);


reg [15:0] r_h_active_cnt;
reg [15:0] r_v_cnt;
reg [ 0:0] r_deal_data_flag;
/*
always @(posedge ddr_clk or negedge ddr_rst_n) begin
    if(!ddr_rst_n) begin
        r_h_active_cnt      <= 16'd0;
        r_v_cnt             <= 0;
        // r_deal_data_flag    <= 0;
    end else if(valid)begin
        r_h_active_cnt      <= r_h_active_cnt == (w_h_active_axi4 - ((w_h_active_axi4[2:0] == 0) ? 8 : w_h_active_axi4[2:0])) ? 16'd0 : r_h_active_cnt + 8;
        r_v_cnt             <= w_h_active_axi4[2:0] == 0 ? 1'b0 : (r_h_active_cnt ==  w_h_active_axi4 - 8 - w_h_active_axi4[2:0]) ? r_v_cnt + 1 : r_v_cnt;
        r_deal_data_flag    <= w_h_active_axi4[2:0] == 0 ? 1'b0 : (r_h_active_cnt ==  w_h_active_axi4 - 8 - w_h_active_axi4[2:0]) ? 1 : 0;
    end
end
*/

// assign r_deal_data_flag  = w_h_active_axi4[2:0] == 0 ? 1'b0 : (r_h_active_cnt ==  w_h_active_axi4 - 8 - w_h_active_axi4[2:0]) ? 1 : 0;





// ila_0 read_state (
// 	.clk(ddr_clk), // input wire clk
// 	.probe0(ddr_wr_data), // input wire [255:0]  probe0
// 	.probe1({w_ddr_wareq,rd_usedw,r_rd_rst_busy,r_ddr_wareq1,wr_state}), // input wire [31:0]  probe1
// 	.probe2({r_axi_awready,r_ddr_wareq,axi_wready,w_ddr_rd_en,w_file_tpye_valid_axi4,ddr_rst_n,ddr_busy,rd_rst_busy,ddr_wready,r_ddr_wareq0}), // input wire [31:0]  probe2
// 	.probe3(r_data_cnt), // input wire [15:0]  probe3
// 	.probe4(valid) // input wire [0:0]  probe4
// );





//第一次复位时 rd_usedw = 256产生无效的w_ddr_wareq;
wire w_file_tpye_valid_axi4;
xpm_cdc_array_single #(.DEST_SYNC_FF(4), .INIT_SYNC_FF(0),.SIM_ASSERT_CHK(1),.SRC_INPUT_REG(0), .WIDTH(1))
    // w_file_tpye_valid_inst (.dest_out(w_file_tpye_valid_axi4), .dest_clk(ddr_clk), .src_clk(),   .src_in(|w_file_tpye_valid));
    w_file_tpye_valid_inst (.dest_out(w_file_tpye_valid_axi4), .dest_clk(ddr_clk), .src_clk(),   .src_in(|w_file_tpye_valid_tmp));

wire w_ddr_wareq;
assign w_ddr_wareq = (rd_rst_busy || ddr_busy || (~ddr_rst_n)) ? 1'b0 : (rd_usedw >= WRITE_BURST_LENGTH) && w_file_tpye_valid_axi4;
// assign w_ddr_wareq = (rd_rst_busy || ddr_busy) ? 1'b0 : (rd_usedw >= WRITE_BURST_LENGTH - 1) && w_file_tpye_valid_axi4;


//消除FIFO 复位后 rd_rst_busy 保持为高的状态
reg [7:0] r_rd_rst_busy;
always @(posedge ddr_clk or negedge ddr_rst_n) begin
    if(!ddr_rst_n) begin
        r_rd_rst_busy <= 8'b1111_1111;
    end else begin
        r_rd_rst_busy[0] <= rd_rst_busy;
        r_rd_rst_busy[1] <= r_rd_rst_busy[0];
        r_rd_rst_busy[2] <= r_rd_rst_busy[1];
        r_rd_rst_busy[3] <= r_rd_rst_busy[2];
        r_rd_rst_busy[4] <= r_rd_rst_busy[3];
        r_rd_rst_busy[5] <= r_rd_rst_busy[4];
        r_rd_rst_busy[6] <= r_rd_rst_busy[5];
        r_rd_rst_busy[7] <= r_rd_rst_busy[6];
    end
end



reg r_axi_awready;
reg r_ddr_wareq;
reg r_ddr_wareq0;
reg r_ddr_wareq1;
always @(posedge ddr_clk or negedge ddr_rst_n) begin
    if(!ddr_rst_n) begin
        r_ddr_wareq0    <= 1'b0;
        r_ddr_wareq1    <= 1'b0;
        r_axi_awready   <= 1'b0;
    // end else if(~r_rd_rst_busy[7])begin
    end else if((r_rd_rst_busy == 8'b0000_0000) && ((wr_state == 4'b0000) || (wr_state == 4'b1000)))begin
        r_ddr_wareq0    <= w_ddr_wareq;
        r_ddr_wareq1    <= r_ddr_wareq0;
        r_axi_awready   <= axi_awready;
    end else begin
        r_axi_awready   <= axi_awready;
        r_ddr_wareq0    <= 1'b0;
        r_ddr_wareq1    <= 1'b0;
    end
end




// assign ddr_wareq = w_ddr_wareq & (~r_ddr_wareq);


reg [31:0] r_burst_cnt_db;
always @(posedge ddr_clk or negedge ddr_rst_n) begin
    if(!ddr_rst_n) begin
        r_burst_cnt_db <= 32'd0;
    end else if(r_ddr_wareq)begin
        r_burst_cnt_db <= r_burst_cnt_db + 1;
    end
end


(* KEEP="TRUE"*)reg [ 3:0] wr_state;
(* KEEP="TRUE"*)reg [15:0] r_data_cnt;

always @(posedge ddr_clk or negedge ddr_rst_n) begin
    if(!ddr_rst_n) begin
        wr_state    <=  4'b0;
        r_ddr_wareq <=  1'b0;
        r_ddr_rd_en <=  1'b0;
        r_data_cnt  <= 16'd0;
    end else begin
        case(wr_state)
            4'b0000:begin
                if(r_ddr_wareq0)begin
                    r_ddr_wareq <= 1'b1;
                    wr_state    <= 4'b0001;
                end else begin
                    r_ddr_wareq <=  1'b0;
                    wr_state    <= wr_state;
                    r_data_cnt  <= 16'd0;
                    r_ddr_rd_en <=  1'b0;
                end
            end

            4'b0001:begin
                r_ddr_wareq <= 1'b0;
                // if(r_axi_awready)begin
                if(axi_awready)begin
                    r_data_cnt  <= 16'd0;
                    wr_state    <=  4'b0010;
                end else begin
                    wr_state    <= wr_state;
                end
            end

            4'b0010:begin
                // if((axi_wready) & (r_data_cnt <= WRITE_BURST_LENGTH - 1) & valid)begin
                //     r_ddr_rd_en <= 1'b1;
                //     wr_state   <= 4'b0100;
                // end else begin
                //     r_ddr_rd_en <= 1'b0;
                //     wr_state   <= wr_state;
                // end

                if((axi_wready) & (r_data_cnt == WRITE_BURST_LENGTH - 1) & valid)begin
                    wr_state   <= 4'b0100;
                end else begin
                    wr_state   <= wr_state;
                end

                if((axi_wready) & (r_data_cnt < WRITE_BURST_LENGTH - 1) & valid)begin
                    r_data_cnt <= r_data_cnt + 1;
                end else if(r_data_cnt == WRITE_BURST_LENGTH - 1)begin
                    r_data_cnt <= 0;
                end else begin
                    r_data_cnt <= r_data_cnt;
                end

                // if((axi_wready) & (r_data_cnt <= WRITE_BURST_LENGTH - 1) & valid)begin
                //     r_data_cnt <= r_data_cnt + 1;
                //     // wr_state   <= wr_state;
                // end else if(r_data_cnt == WRITE_BURST_LENGTH)begin
                //     r_data_cnt <= 0;
                //     // wr_state   <= 4'b0100;
                // end else begin
                //     r_data_cnt <= r_data_cnt;
                //     // wr_state   <= wr_state;
                // end
            end

            4'b0100:begin
                r_data_cnt  <= 0;
                wr_state    <= 4'b1000;
                r_ddr_rd_en <= 1'b0;
                r_ddr_wareq <= 1'b0;
            end

            4'b1000:begin
                r_data_cnt  <= 0;
                wr_state    <= 4'b0000;
                r_ddr_rd_en <= 1'b0;
                r_ddr_wareq <= 1'b0;
            end

            default:begin
                r_data_cnt  <= 0;
                wr_state    <= 4'b0000;
                r_ddr_rd_en <= 1'b0;
                r_ddr_wareq <= 1'b0;
            end
        endcase
    end
end


assign ddr_wareq    = r_ddr_wareq;

// assign w_ddr_rd_en = axi_wready & (r_data_cnt <= WRITE_BURST_LENGTH - 1) & (wr_state == 4'b0010) & (r_data_cnt >= 1)  || (wr_state == 4'b0100);
assign w_ddr_rd_en = axi_wready & (wr_state == 4'b0010) & (r_data_cnt <= WRITE_BURST_LENGTH - 1) ;
assign ddr_wready  = axi_wready & (wr_state == 4'b0010) & valid ;











// ila_0 wr_ddr_inst (
// 	.clk    (ddr_clk    ), // input wire clk
// 	.probe0 (ddr_wr_data[255:0] ), // input wire [255:0]  probe0
// 	// .probe1 (probe1 ), // input wire [31:0]  probe1
// 	.probe2 (wr_state ), // input wire [31:0]  probe2
// 	.probe3 (r_data_cnt ), // input wire [31:0]  probe3
// 	.probe4 ({r_burst_cnt_db} ), // input wire [31:0]  probe4
// 	.probe5 ({axi_wready,ddr_wready} ), // input wire [15:0]  probe5
// 	.probe6 (w_file_tpye_valid_axi4 ), // input wire [7:0]  probe6
// 	.probe7 ({w_ddr_rd_en,valid,rd_usedw,rd_rst_busy,r_ddr_wareq0} ) // input wire [7:0]  probe7
// );



// assign ddr_wr_data = (C_M_AXI_DATA_WIDTH == 256) ?  {   w_ddr_wr_data[ 31:  0],w_ddr_wr_data[ 63: 32],w_ddr_wr_data[ 95: 64],w_ddr_wr_data[127: 96],
//                                                         w_ddr_wr_data[159:128],w_ddr_wr_data[191:160],w_ddr_wr_data[223:192],w_ddr_wr_data[255:224]} :
//                                                     {   w_ddr_wr_data[ 31:  0],w_ddr_wr_data[ 63: 32],w_ddr_wr_data[ 95: 64],w_ddr_wr_data[127: 96],
//                                                         w_ddr_wr_data[159:128],w_ddr_wr_data[191:160],w_ddr_wr_data[223:192],w_ddr_wr_data[255:224],
//                                                         w_ddr_wr_data[287:256],w_ddr_wr_data[319:288],w_ddr_wr_data[351:320],w_ddr_wr_data[383:352],
//                                                         w_ddr_wr_data[415:353],w_ddr_wr_data[447:416],w_ddr_wr_data[479:448],w_ddr_wr_data[511:480]};
// assign ddr_wr_data = w_ddr_wr_data;



// ila_0 wr_ddr (
//     .clk(ddr_clk), // input wire clk
//     .probe0(ddr_wr_data[255:0]), // input wire [255:0]  probe0
//     .probe1(axi_wready), // input wire [31:0]  probe1
//     .probe2(ddr_busy), // input wire [31:0]  probe2
//     .probe3({rd_usedw,w_ddr_wareq,rd_rst_busy}), // input wire [31:0]  probe3
//     .probe4(r_ddr_wareq0), // input wire [31:0]  probe4
//     .probe5(r_data_cnt), // input wire [15:0]  probe5
//     .probe6({ddr_wready,w_ddr_rd_en,ddr_wareq,r_ddr_rd_en}), // input wire [7:0]  probe6
//     .probe7(wr_state) // input wire [7:0]  probe7
// );



// assign ddr_wr_data = {  w_ddr_wr_data[ 31:  0],w_ddr_wr_data[ 63: 32],w_ddr_wr_data[ 95: 64],w_ddr_wr_data[127: 96],
//                         w_ddr_wr_data[159:128],w_ddr_wr_data[191:160],w_ddr_wr_data[223:192],w_ddr_wr_data[255:224]};

/*
wire w_ddr_wareq;
assign w_ddr_wareq = (rd_rst_busy || ddr_busy) ? 1'b0 : (rd_usedw >= (WRITE_BURST_LENGTH));

reg r_axi_awready;
reg r_ddr_wareq;
reg r_ddr_wareq0;
reg r_ddr_wareq1;
always @(posedge ddr_clk or negedge ddr_rst_n) begin
    if(!ddr_rst_n) begin
        r_ddr_wareq0 <= 1'b0;
        r_ddr_wareq1 <= 1'b0;
        r_axi_awready <= 0;
    end else begin
        r_ddr_wareq0 <= w_ddr_wareq;
        r_ddr_wareq1 <= r_ddr_wareq0;
        r_axi_awready <= axi_awready;
    end
end

// assign ddr_wareq = w_ddr_wareq & (~r_ddr_wareq);


(* KEEP="TRUE"*)reg [3:0] wr_state;
(* KEEP="TRUE"*) reg [15:0] r_data_cnt;
always @(posedge ddr_clk or negedge ddr_rst_n) begin
    if(!ddr_rst_n) begin
        wr_state <= 4'b0;
        r_ddr_wareq <= 1'b0;
        r_ddr_rd_en <= 1'b0;
        r_data_cnt <= 16'd0;
        //ddr_wready <= 0;
        //ddr_wr_data <= 0;
    end else begin
        case(wr_state)
            4'b0000:begin
                //ddr_wready <= 1'b0;
                //ddr_wr_data <= 0;
                if(r_ddr_wareq1)begin
                    r_ddr_wareq <= 1'b1;
                    wr_state       <= 4'b0001;
                end else begin
                    r_ddr_wareq <= 1'b0;
                    wr_state       <= wr_state;
                    r_data_cnt  <= 16'd0;
                    r_ddr_rd_en <= 1'b0;

                end
            end

            4'b0001:begin
                r_ddr_wareq <= 1'b0;
                if(r_axi_awready)begin
                    r_data_cnt  <= 16'd0;
                    wr_state       <= 4'b0010;
                end else begin
                    wr_state       <= wr_state;

                end
            end

            4'b0010:begin
                if((axi_wready) & (r_data_cnt <= WRITE_BURST_LENGTH))begin
                    r_ddr_rd_en <= 1'b1;
                end else begin
                    r_ddr_rd_en <= 1'b0;
                end

                if((axi_wready) & (r_data_cnt <= WRITE_BURST_LENGTH))begin
                    r_data_cnt <= r_data_cnt + 1;
                    wr_state       <= wr_state;
                end else if(r_data_cnt == WRITE_BURST_LENGTH + 1)begin
                    r_data_cnt <= 0;
                    wr_state      <= 4'b0100;
                end else begin
                    r_data_cnt <= r_data_cnt;
                    wr_state       <= wr_state;
                end
            end

            4'b0100:begin
                r_data_cnt  <= 0;
                wr_state       <= 4'b1000;
                r_ddr_rd_en <= 1'b0;
                //ddr_wready <= 1'b0;
                //ddr_wr_data <= 0;
            end

            4'b1000:begin
                wr_state       <= 4'b0000;
            end

            default:wr_state <= 4'b0000;
        endcase
    end
end

assign ddr_wareq = r_ddr_wareq;

assign ddr_wready  = valid;
assign ddr_wr_data = {w_ddr_wr_data[31:0],w_ddr_wr_data[63:32],w_ddr_wr_data[95:64],w_ddr_wr_data[127:96],
                                    w_ddr_wr_data[159:128],w_ddr_wr_data[191:160],w_ddr_wr_data[223:192],w_ddr_wr_data[255:224]};

*/





//------------------------ Read DDR ----------------------------------//

localparam BURST_SIZE = (C_M_AXI_DATA_WIDTH == 512) ?   READ_BURST_LENGTH * 64 :
                        (C_M_AXI_DATA_WIDTH == 256) ?   READ_BURST_LENGTH * 32 :
                                                        READ_BURST_LENGTH * 16 ;


(*ram_style="distributed"*)
reg [C_M_AXI_DATA_WIDTH - 1:0] 	r_sd_rd_fifo[0:READ_BURST_LENGTH * 2 - 1]	; //SD读出fifo
reg [15:0] 						r_rd_cnt							    ; //循环读出寄存器

reg [3:0] 					    rd_state 	        ;
reg [C_M_AXI_ADDR_WIDTH-1:0]    rd_araddr	        ;
reg [31:0] 					    burst_times_cnt		;
reg 			 			    rd_rready	        ;
reg							    rd_done		        ;


// rd_state
// 0 IDLE
// 1 WAIT_START_TRANFER AND CALU TRANSFER TIMES()
// 2 START_AXI
// 3 START_TRANSFER
// 4 BURTS_DONE
// 5 CALU_BURST_DONE ?
// 6 reset_all_state
wire [31:0] w_total_rd_burst_sd;
wire [31:0] w_total_rd_burst;

// assign w_total_rd_burst = i_bmp_byte_size / 256 / BURST_LEN;
// assign w_total_rd_burst_sd = ( i_bmp_byte_size[3:0] == 0 ) ? (i_bmp_byte_size >> 9) : (i_bmp_byte_size >> 9) + 1;
assign w_total_rd_burst_sd = ( i_bmp_byte_size[3:0] == 0 ) ? (i_bmp_byte_size >> 9) : (i_bmp_byte_size >> 9) + 1;
// assign w_total_rd_burst_sd = i_bmp_byte_size;


xpm_cdc_array_single #(.DEST_SYNC_FF(4), .INIT_SYNC_FF(0),.SIM_ASSERT_CHK(1),.SRC_INPUT_REG(0), .WIDTH(32))
    total_rd_burst_inst (.dest_out(w_total_rd_burst), .dest_clk(ddr_clk), .src_clk(),   .src_in(w_total_rd_burst_sd));

wire w_start_read_ddr;
xpm_cdc_array_single #(.DEST_SYNC_FF(4), .INIT_SYNC_FF(0),.SIM_ASSERT_CHK(1),.SRC_INPUT_REG(0), .WIDTH(1))
    w_start_read_ddr_inst (.dest_out(w_start_read_ddr), .dest_clk(ddr_clk), .src_clk(),   .src_in(i_start_read_ddr));


reg [31:0] r_total_rd_burst;
always @(posedge ddr_clk or negedge ddr_rst_n) begin
    if(~ddr_rst_n) begin
        r_total_rd_burst <= 32'd0;
    end else begin
        r_total_rd_burst <= w_total_rd_burst;
    end
end

wire w_fifo_empty;

always @(posedge ddr_clk or negedge ddr_rst_n) begin
    if(~ddr_rst_n) begin
        rd_state            <=     0;
        rd_araddr           <=   'b0;
        burst_times_cnt     <= 32'd0;
        rd_done             <=  1'b0;
        rd_rready           <=  1'd1;
    end else case(rd_state)
        4'd0:begin
            rd_state        <=  w_start_read_ddr ? 4'd1 : 4'd0;
            rd_araddr       <=  i_start_read_ddr_addr;
            burst_times_cnt <= 32'd0;
            rd_rready       <=  1'd1;
            rd_done         <=  1'b0;
        end

        4'd1:begin
            rd_state        <=  w_fifo_empty ? 4'd2 : 4'd1;
            rd_araddr       <=  rd_araddr;
            burst_times_cnt <=  burst_times_cnt;
            rd_rready       <=  1'd0;
            rd_done         <=  1'b0;
        end

        4'd2:begin //2->3 地址握手完成
            rd_state        <=  m_axi4_arready ? 4'd3 : 4'd2;
            rd_araddr       <=  rd_araddr;
            burst_times_cnt <=  burst_times_cnt;
            rd_rready       <=  1'd0;
            rd_done         <=  1'b0;
        end

        4'd3:begin //一次burst 传输结束
            rd_state  		<= (m_axi4_rlast && m_axi4_rvalid) ? 4'd4 : 4'd3;
            rd_araddr 		<= rd_araddr;
            burst_times_cnt <= (m_axi4_rlast && m_axi4_rvalid) ? burst_times_cnt + 1'b1 : burst_times_cnt;
			rd_rready 		<= 1'b1;
			rd_done   		<= 1'b0;
        end

        4'd4:begin
			rd_state  		<= (burst_times_cnt == r_total_rd_burst) ? 4'd5 : 4'd1;
			rd_araddr 		<= rd_araddr + BURST_SIZE;
			burst_times_cnt <= burst_times_cnt;
			rd_rready 		<= 1'b0;
			rd_done   		<= 1'b0;
        end

		4'd5 : begin
            rd_state  		<= 4'd0;
			burst_times_cnt	<= burst_times_cnt;
			rd_araddr 		<= rd_araddr;
			rd_rready 		<= 1'b0;
			rd_done   		<= 1'b1;
		end

        default :begin
            rd_state  	    <= 4'd0;
            rd_araddr 	    <= rd_araddr;
            burst_times_cnt <= burst_times_cnt;
            rd_rready 	    <= 1'b0;
            rd_done   	    <= 1'b1;
        end
    endcase
end

reg r_rburst_done;
always @(posedge ddr_clk or negedge ddr_rst_n) begin
    if(~ddr_rst_n) begin
        r_rburst_done <= 1'b0;
    end else if(w_start_read_ddr)begin
        r_rburst_done <= 1'b0;
    end else if(burst_times_cnt == r_total_rd_burst)begin
        r_rburst_done <= 1'b1;
    end
end

reg [3:0] r_rburst_done_reg;
always @(posedge ddr_clk or negedge ddr_rst_n) begin
    if(~ddr_rst_n) begin
        r_rburst_done_reg <= 4'b0;
    end else begin
        r_rburst_done_reg[0] <= r_rburst_done;
        r_rburst_done_reg[1] <= r_rburst_done_reg[0];
        r_rburst_done_reg[2] <= r_rburst_done_reg[1];
        r_rburst_done_reg[3] <= r_rburst_done_reg[2];
    end
end


reg [C_M_AXI_DATA_WIDTH-1:0]    r_ddr_data_tmp;
reg                             r_wr_fifo_en;
wire                            w_wr_fifo_en;
always @(posedge ddr_clk or negedge ddr_rst_n) begin
    if(~ddr_rst_n) begin
		r_ddr_data_tmp  <=   'b0;
		r_wr_fifo_en    <=  1'b0;
	end else begin
		r_ddr_data_tmp  <= rd_rready && m_axi4_rvalid ? m_axi4_rdata : r_ddr_data_tmp;
        r_wr_fifo_en    <= rd_rready && m_axi4_rvalid;
	end
end







assign m_axi4_arid      = 0;
assign m_axi4_arlen     = READ_BURST_LENGTH - 1;
assign m_axi4_arsize    = (C_M_AXI_DATA_WIDTH == 512) ? 3'b110 : (C_M_AXI_DATA_WIDTH == 256) ? 3'b101 : 3'b100; //
assign m_axi4_arburst   = 2'b01	 	; // Burst address
assign m_axi4_arlock    = 1'b0	 	;
assign m_axi4_arcache   = 4'b0011	; //
assign m_axi4_arprot    = 3'b000 	;
assign m_axi4_arqos     = 4'b0000	;
assign m_axi4_arregion  = 4'b0000	;

assign m_axi4_rready    = rd_rready;
assign m_axi4_arvalid   = (rd_state == 5'd2) ? 1'b1 : 1'b0;
assign m_axi4_araddr    = rd_araddr;

assign w_wr_fifo_en = rd_rready && m_axi4_rvalid;


wire        w_empty;
wire        w_empty_axi4;
wire        w_write_status_nobusy;


xpm_cdc_array_single #(.DEST_SYNC_FF(4), .INIT_SYNC_FF(0),.SIM_ASSERT_CHK(1),.SRC_INPUT_REG(0), .WIDTH(1))
    fifo_empty_axi4_inst (.dest_out(w_empty_axi4), .dest_clk(ddr_clk), .src_clk(),   .src_in(w_empty));

xpm_cdc_array_single #(.DEST_SYNC_FF(4), .INIT_SYNC_FF(0),.SIM_ASSERT_CHK(1),.SRC_INPUT_REG(0), .WIDTH(1))
    w_write_status_nobusy_inst (.dest_out(w_write_status_nobusy), .dest_clk(ddr_clk), .src_clk(),   .src_in(|i_trans_busy));

wire [3:0]  rd_fifo_state_axi;
xpm_cdc_array_single #(.DEST_SYNC_FF(4), .INIT_SYNC_FF(0),.SIM_ASSERT_CHK(1),.SRC_INPUT_REG(0), .WIDTH(4))
    rd_fifo_state_axi_inst (.dest_out(rd_fifo_state_axi), .dest_clk(ddr_clk), .src_clk(),   .src_in(rd_fifo_state));

// assign w_fifo_empty = ((ddr_rst_n == 1) & (wr_data_count <= 16 - 1)) & (~w_write_status_nobusy) ? 1'b1 : 1'b0;
assign w_fifo_empty = ((ddr_rst_n == 1) & (wr_data_count <= READ_BURST_LENGTH - 1)) ? 1'b1 : 1'b0;


//确保慢时钟域采集到burst完成信号

wire w_burst_rlast;
assign w_burst_rlast = (m_axi4_rlast && m_axi4_rvalid);

reg [4:0] r_burst_rlast;
always @(posedge ddr_clk or negedge ddr_rst_n) begin
    if(~ddr_rst_n)begin
        r_burst_rlast <= 5'b0;
    end else if(rd_fifo_state_axi < 2)begin
        r_burst_rlast[0] <= w_burst_rlast;
        r_burst_rlast[1] <= r_burst_rlast[0];
        r_burst_rlast[2] <= r_burst_rlast[1];
        r_burst_rlast[3] <= r_burst_rlast[2];
        r_burst_rlast[4] <= r_burst_rlast[3];
    end else begin
        r_burst_rlast <= 5'b0;
    end
end


wire [C_M_AXI_DATA_WIDTH-1:0]    w_rd_fifo_data;
wire            w_rd_en;
wire [4:0]      rd_data_count;
wire [4:0]      wr_data_count;

// fifo_generator_1 sd_read_distributed_ram
// (
//   .rst              (!ddr_rst_n         ),  // input wire rst
//   .wr_clk           (ddr_clk            ),  // input wire wr_clk
//   .rd_clk           (clk                ),  // input wire rd_clk

//   .din              (r_ddr_data_tmp     ),  // input wire [255 : 0] din
//   .wr_en            (r_wr_fifo_en       ),  // input wire wr_en

//   .rd_en            (w_rd_en            ),  // input wire rd_en
//   .dout             (w_rd_fifo_data     ),  // output wire [255 : 0] dout

//   .full             (w_full             ),  // output wire full
//   .empty            (w_empty            ),  // output wire empty
//   .rd_data_count    (rd_data_count      ),  // output wire [4 : 0] rd_data_count
//   .wr_data_count    (wr_data_count      )   // output wire [4 : 0] wr_data_count
// );


localparam SD_RD_DEPTH         = C_M_AXI_DATA_WIDTH == 512 ? 64  : C_M_AXI_DATA_WIDTH == 256 ? 32 : 16;
localparam RD_WIDTH            = C_M_AXI_DATA_WIDTH == 512 ? 512 : C_M_AXI_DATA_WIDTH == 256 ? 256 : C_M_AXI_DATA_WIDTH/2;
localparam SD_RD_COUNT_WIDTH   = clogb2(SD_RD_DEPTH) ;
Async_fifo #(
	.WR_DEPTH       	(SD_RD_DEPTH			),
	.WR_WIDTH 			(C_M_AXI_DATA_WIDTH     ),
    // .RD_WIDTH 			(RD_WIDTH               ),
    .RD_WIDTH 			(C_M_AXI_DATA_WIDTH     ),
	.WR_COUNT_WIDTH 	(SD_RD_COUNT_WIDTH 	    ),
	.RD_COUNT_WIDTH 	(SD_RD_COUNT_WIDTH 	    ),
    .READ_MODE 	        ("fwft" 	            )
)sd_read_ram(
    .fifo_reset       	(~ddr_rst_n   		    ),

	.wr_clk           	(ddr_clk  		        ),
	.wr_data          	(r_ddr_data_tmp	        ),
	.wrreq	          	(r_wr_fifo_en	  	    ),
	// .wr_rst_busy      	(wr_rst_busy		),
	// .rd_rst_busy      	(rd_rst_busy		),

	.rd_clk           	(clk	  		        ),
    .rdreq            	(w_rd_en    	        ),
	.rd_data          	(w_rd_fifo_data	        ),

	// .overflow			(overflow),
    .full				(w_full                 ),
	.empty				(w_empty                ),
	.rd_usedw         	(rd_data_count   	    ),
	.wr_usedw         	(wr_data_count	  	    )
);




//8bit数据，总的位移次数
localparam SHIFT_CNT    = C_M_AXI_DATA_WIDTH >> 3; // 读出数据256位每次位移发出8位，底层接口每次发送4位
// localparam SHIFT_CNT    = C_M_AXI_DATA_WIDTH == 512 ? C_M_AXI_DATA_WIDTH/2 >> 3 : C_M_AXI_DATA_WIDTH >> 3; // 读出数据256位每次位移发出8位，底层接口每次发送4位
// localparam SHIFT_CNT    = 256 >> 3; // 读出数据256位每次位移发出8位，底层接口每次发送4位


wire w_burst_rlast_sd;
wire w_start_read_ddr_sd;
wire w_rburst_done;
wire [31:0] w_srctor_size;
wire [31:0] w_bmp_byte_size;
xpm_cdc_array_single #(.DEST_SYNC_FF(4), .INIT_SYNC_FF(0),.SIM_ASSERT_CHK(1),.SRC_INPUT_REG(0), .WIDTH(1))
    burst_rlast_sd_inst (.dest_out(w_burst_rlast_sd), .dest_clk(clk), .src_clk(),   .src_in(|r_burst_rlast));

xpm_cdc_array_single #(.DEST_SYNC_FF(4), .INIT_SYNC_FF(0),.SIM_ASSERT_CHK(1),.SRC_INPUT_REG(0), .WIDTH(1))
    w_start_read_ddr_sd_inst (.dest_out(w_start_read_ddr_sd), .dest_clk(clk), .src_clk(),   .src_in(w_start_read_ddr));

xpm_cdc_array_single #(.DEST_SYNC_FF(4), .INIT_SYNC_FF(0),.SIM_ASSERT_CHK(1),.SRC_INPUT_REG(0), .WIDTH(1))
    w_rburst_done_inst (.dest_out(w_rburst_done), .dest_clk(clk), .src_clk(),   .src_in(|r_rburst_done_reg));

xpm_cdc_array_single #(.DEST_SYNC_FF(4), .WIDTH(32), .SRC_INPUT_REG(0),  .SIM_ASSERT_CHK(1))
    w_total_srctor_size_inst     (.src_in(w_total_rd_burst_sd), .src_clk(),.dest_clk(clk), .dest_out(w_srctor_size));

xpm_cdc_array_single #(.DEST_SYNC_FF(4), .WIDTH(32), .SRC_INPUT_REG(0),  .SIM_ASSERT_CHK(1))
    w_bmp_byte_size_inst     (.src_in(i_bmp_byte_size), .src_clk(),.dest_clk(clk), .dest_out(w_bmp_byte_size));

reg                                 r_read_fifo_en  ;
reg [3:0]                           rd_fifo_state   ;

reg [7:0]                           r_shift_cnt     ; // SHIFT_CNT计数器
reg                                 r_sd_read_start ;
// reg [C_M_AXI_DATA_WIDTH - 1 : 0]    r_write_data    ;
reg [C_M_AXI_DATA_WIDTH - 1 : 0]    r_write_data    ;
reg                                 r_rd_fifo_done  ;
reg [7:0]                           r_rd_num_cnt    ;
reg [31:0]                          r_trans_addr    ;

wire [31:0] w_rd_num_total;
assign w_rd_num_total =  ( w_bmp_byte_size[3:0] == 0 ) ? (w_bmp_byte_size >> 5) : (w_bmp_byte_size >> 5) + 1;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin
        r_read_fifo_en  <=  1'b0;
        rd_fifo_state   <=  4'b0;
        r_shift_cnt     <=  8'd0;
        r_sd_read_start <=  1'b0;
        r_write_data    <=   'b0;
        r_rd_fifo_done  <=  1'b0;
        r_rd_num_cnt    <=  8'b0;
        r_trans_addr    <= 32'b0;
    end else case(rd_fifo_state)
        4'd0:begin
            r_read_fifo_en  <= 1'b0;
            rd_fifo_state   <= w_start_read_ddr_sd ? 1 : 0;
            r_shift_cnt     <= 8'd0;
            r_sd_read_start <= 1'b0;
            r_write_data    <=  'b0;
            r_rd_fifo_done  <= 1'b0;
            r_rd_num_cnt    <= 8'b0;
            r_trans_addr    <= w_start_read_ddr_sd ? i_trans_addr : r_trans_addr;
        end


        // 4'd1: begin //fifo 中有一次burst长度时 发起SD卡写操作
        //     r_read_fifo_en  <= 1'b0;
        //     rd_fifo_state   <= w_burst_rlast_sd ? 4'd2 : 4'd1;
        //     r_shift_cnt     <= 8'd0;
        //     r_sd_read_start <= w_burst_rlast_sd ? 1'b1 : 1'b0;
        //     r_write_data    <=  'b0;
        //     r_rd_fifo_done  <= 1'b0;
        //     r_rd_num_cnt    <= w_burst_rlast_sd ? r_rd_num_cnt + 1 : r_rd_num_cnt;
        //     r_trans_addr    <= w_start_read_ddr_sd ? i_trans_addr : r_trans_addr;
        // end

        4'd1: begin //fifo 中有一次burst长度时 发起SD卡写操作
            r_read_fifo_en  <= 1'b0;
            rd_fifo_state   <= (rd_data_count >= READ_BURST_LENGTH - 1) ? 4'd2 : 4'd1;
            r_shift_cnt     <= 8'd0;
            r_sd_read_start <= (rd_data_count >= READ_BURST_LENGTH - 1) ? 1'b1 : 1'b0;
            r_write_data    <= r_write_data ;
            r_rd_fifo_done  <= 1'b0;
            r_rd_num_cnt    <= (rd_data_count >= READ_BURST_LENGTH - 1) ? r_rd_num_cnt + 1 : r_rd_num_cnt;
            // r_trans_addr    <= w_start_read_ddr_sd ? i_trans_addr : r_trans_addr;
            r_trans_addr    <= r_trans_addr;
        end

        4'd2:begin //开始读取FIFO 内数据
            r_read_fifo_en  <= 1'b0;
            rd_fifo_state   <= 4'd5;
            r_shift_cnt     <= 8'd0;
            r_sd_read_start <= 1'b0;
           // r_write_data    <=  'b0;
           r_write_data    <= w_rd_fifo_data;
           
            r_rd_fifo_done  <= 1'b0;
            r_rd_num_cnt    <= r_rd_num_cnt;
            r_trans_addr    <= r_trans_addr;
        end

        4'd5:begin //等待SD 驱动指令发送完成开始传输
            r_read_fifo_en  <= 1'b0;
            rd_fifo_state   <= i_read_fifo_en ? 4'd3 : 4'd5;
            r_shift_cnt     <= 8'd0;
            r_sd_read_start <= 1'b0;
            // r_write_data    <= r_write_data;
            r_write_data    <= w_rd_fifo_data;
            r_rd_fifo_done  <= 1'b0;
            r_rd_num_cnt    <= r_rd_num_cnt;
            r_trans_addr    <= i_read_fifo_en ? (r_trans_addr + 1) : r_trans_addr;//更新下一个扇区地址
        end

        4'd3:begin // DATA TRANS  2 cycle shift send 8bits data
            r_read_fifo_en  <= 1'b0;
            // rd_fifo_state   <= (r_rd_num_cnt == w_rd_num_total) & (r_shift_cnt == SHIFT_CNT - 1) & (i_read_fifo_en == 0) ? 4'd4 : 4'd3;
            rd_fifo_state   <= (r_rd_num_cnt == READ_BURST_LENGTH) & (r_shift_cnt == SHIFT_CNT - 1) & (i_read_fifo_en == 0) ? 4'd4 : 4'd3;




            r_shift_cnt     <= (r_shift_cnt == SHIFT_CNT - 1) & (i_read_fifo_en == 0) ? 8'd0 : (i_read_fifo_en == 0) ? (r_shift_cnt + 1) : r_shift_cnt;
            // r_shift_cnt     <= (r_shift_cnt < SHIFT_CNT - 1) & (i_read_fifo_en == 0) ? (r_shift_cnt + 1) : (r_rd_num_cnt == READ_BURST_LENGTH) ? r_shift_cnt : 0;
            r_sd_read_start <= 1'b0;
            // r_write_data    <= (r_shift_cnt == SHIFT_CNT - 1) & (i_read_fifo_en == 0) ? w_rd_fifo_data : (i_read_fifo_en == 0) ? {8'd0,r_write_data[C_M_AXI_DATA_WIDTH - 1 : 8]} : r_write_data;
            r_write_data    <= (r_shift_cnt == SHIFT_CNT - 1) & (i_read_fifo_en == 0) ? w_rd_fifo_data : (i_read_fifo_en == 0) ? {8'd0,r_write_data[C_M_AXI_DATA_WIDTH - 1 : 8]} : r_write_data;
            r_rd_fifo_done  <= 1'b0;
            // r_rd_num_cnt    <= (i_read_fifo_en == 1) ? r_rd_num_cnt : (r_shift_cnt == SHIFT_CNT - 1) & (r_rd_num_cnt == w_rd_num_total) ? 8'b0 : (r_shift_cnt == SHIFT_CNT - 1) ? (r_rd_num_cnt + 1) : r_rd_num_cnt;
            r_rd_num_cnt    <= (i_read_fifo_en == 1) ? r_rd_num_cnt : (r_shift_cnt == SHIFT_CNT - 1) & (r_rd_num_cnt == READ_BURST_LENGTH) ? 8'b0 : (r_shift_cnt == SHIFT_CNT - 1) ? (r_rd_num_cnt + 1) : r_rd_num_cnt;
            r_trans_addr    <= r_trans_addr;
        end

        4'd4:begin // wait write block done
            r_read_fifo_en  <= 1'b0;
            // rd_fifo_state   <= (i_trans_busy == 2'b0) & (i_write_status == 3'b011) & (w_rburst_done == 1'b0) ? 4'd1 : ((i_write_status == 3'b010) || w_rburst_done) ? 4'd0 : rd_fifo_state;
            // rd_fifo_state   <= (i_trans_busy == 2'b10) & (i_write_status == 3'b111) ? 4'd2 : ((i_write_status == 3'b010) || w_rburst_done) ? 4'd0 : rd_fifo_state;
            // rd_fifo_state   <= (i_trans_busy == 2'b10) & (i_write_status == 3'b111) ? 4'd1 : ((i_write_status == 3'b010) || w_rburst_done) ? 4'd0 : rd_fifo_state;
            rd_fifo_state   <= (i_trans_busy == 2'b10) & (i_write_status == 3'b101) ? 4'd1 : ((i_write_status == 3'b010) || w_rburst_done && (rd_data_count == 0)) ? 4'd0 : rd_fifo_state;
            
            r_shift_cnt     <= 8'd0;
            r_sd_read_start <= 1'b0;
            //r_write_data    <=  'b0;
            
            r_write_data <=  (i_trans_busy == 2'b10) & (i_write_status == 3'b111) ?  w_rd_fifo_data  : ((i_write_status == 3'b010) || w_rburst_done && (rd_data_count == 0)) ? 512'b0 : r_write_data;
            
            r_rd_fifo_done  <= 1'b1;
            // r_rd_num_cnt    <= (i_trans_busy == 2'b0) ? r_rd_num_cnt : (i_write_status == 3'b010) ? 8'd0 : r_rd_num_cnt;
            r_rd_num_cnt    <= (i_flag_writing == 0) ? 0 : r_rd_num_cnt;
            r_trans_addr    <= r_trans_addr;
        end

        default :begin
            r_read_fifo_en  <=  1'b0;
            rd_fifo_state   <=  4'd1;
            r_shift_cnt     <=  8'd0;
            r_sd_read_start <=  1'b0;
            r_write_data    <=   'b0;
            r_rd_fifo_done  <=  1'b0;
            r_rd_num_cnt    <=  8'b0;
            r_trans_addr    <= 32'b0;
        end
    endcase
end

assign o_sd_read_start = r_sd_read_start;
assign o_write_data = (rd_fifo_state == 4'd3) ? r_write_data[7:0] : 0;
// assign o_write_data = (rd_fifo_state == 4'd3) ? 8'h12 : 0;

assign w_rd_en      = ((i_read_fifo_en == 1) & (r_shift_cnt == SHIFT_CNT - 1)) || r_read_fifo_en;
assign o_trans_addr = r_trans_addr;

assign o_rburst_done = w_rburst_done;


always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin
        o_srctor_size <= 32'd0;
    end else begin
        // o_srctor_size <= vio_srctor_size_en ? 32'd20 : w_srctor_size;
        // o_srctor_size <= w_bmp_byte_size ;
        o_srctor_size <= w_srctor_size ;
    end
end



generate
    if(DEBUG_WRITE_SD_EN==1)begin
        ila_0 wr_sd (
	    .clk(clk), // input wire clk
	    .probe0(r_write_data[255:0]), // input wire [255:0]  probe0
	    .probe1(r_trans_addr), // input wire [31:0]  probe1
	    .probe2({rd_data_count,wr_data_count,o_write_data}), // input wire [31:0]  probe2
	    .probe3({i_write_status,i_trans_busy,i_flag_writing,i_read_fifo_en}), // input wire [31:0]  probe3
	    .probe4({w_bmp_byte_size[15:0],w_srctor_size[15:0]}), // input wire [31:0]  probe4
	    .probe5({r_rd_fifo_done,w_rburst_done,r_rd_num_cnt}), // input wire [15:0]  probe5
	    .probe6(r_shift_cnt), // input wire [7:0]  probe6
	    .probe7({rd_fifo_state,i_read_fifo_en,w_rd_en,r_sd_read_start}) // input wire [7:0]  probe7
    );

    end
endgenerate





// assign o_srctor_size = w_srctor_size;





// reg [31:0] r_burst_cnt;
// always @(posedge clk or negedge rst_n) begin
//     if(~rst_n)begin
//         r_burst_cnt <= 0;
//     end else if(w_burst_rlast_sd)begin
//         r_burst_cnt <= r_burst_cnt + 1;
//     end
// end


endmodule



