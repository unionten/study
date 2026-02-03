`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/25 23:08:25
// Design Name: 
// Module Name: uart_to_iic
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


module uart_to_iic(
input   CLK_I         , 
input   RSTN_I        ,
input   WR_EN_I       ,
input   [6:0] WR_DEV_ADDR_I ,
input   WR_WRRD_I     ,
input   [7:0] WR_REG_ADDR_I  ,
input   [7:0] WR_REG_DATA_I  ,
output  UART_O ,
output  SDA_O ,
input   SDA_I ,
output  SDA_T ,
output  SCL_O ,
input   SCL_I ,
output  SCL_T ,
output  IIC_EN_O  

 );
    

parameter  SYS_CLK_PRD_NS = 10 ;
parameter  BAUD_RATE = 9600 ;



wire rd_rst_empty ;
wire rd_empty;
wire [15:0] rd_data_count ;


wire [6:0] fifo_dev_addr ;
wire       fifo_wr_wrrd     ;
wire [7:0] fifo_reg_addr ;
wire [7:0] fifo_reg_data ;


fifo_async_xpm  
    #(.C_WR_WIDTH             (24    ),// ratio must be 1:1, 1:2, 1:4, 1:8,
      .C_WR_DEPTH             (512   ),// must>=16 ; actual depth = C_WR_DEPTH - 1;  must be power of 2
      .C_RD_WIDTH             (24    ),
      .C_WR_COUNT_WIDTH       (12    ),
      .C_RD_COUNT_WIDTH       (12    ),
      .C_RD_PROG_EMPTY_THRESH (16    ),
      .C_WR_PROG_FULL_THRESH  (500   ),
      .C_RD_MODE              ("std" ), //"std" "fwft"  
      .C_DBG_COUNT_WIDTH      (16   )
     )
    fifo_async_xpm_u(
    .WR_RST_I         (~RSTN_I   ),
    .WR_CLK_I         (CLK_I     ),
    .WR_EN_I          (WR_EN_I   ),
    .WR_EN_VALID_O    (),
    .WR_EN_NAMES_O    (),
    .WR_EN_ACCUS_O    (),
    .WR_DATA_I        ({WR_DEV_ADDR_I,WR_WRRD_I,  WR_REG_ADDR_I, WR_REG_DATA_I} ),
    .WR_FULL_O        (),
    .WR_DATA_COUNT_O  (),
    .WR_PROG_FULL_O   (),
    .WR_RST_BUSY_O    (),
    .WR_ERR_O         (),

    .RD_RST_I         (~RSTN_I   ), 
    .RD_CLK_I         (CLK_I     ),
    .RD_EN_I          (fifo_rd  ),
    .RD_EN_NAMES_O    (),
    .RD_EN_ACCUS_O    (),
    .RD_DATA_VALID_O  (),
    .RD_DATA_O        ({fifo_dev_addr,fifo_wr_wrrd,  fifo_reg_addr, fifo_reg_data}),
    .RD_EMPTY_O       (rd_empty      ),
    .RD_DATA_COUNT_O  (rd_data_count ),
    .RD_PROG_EMPTY_O  (),
    .RD_RST_BUSY_O    (rd_rst_busy   ),
    .RD_ERR_O         ()
    
    );



reg [7:0] state = 0;
reg fifo_rd = 0;
reg iic_wr=0;
reg iic_rd=0;
reg [6:0]  iic_wr_dev_addr=0;
reg [7:0]  iic_wr_reg_addr=0;
reg [7:0]  iic_wr_reg_data=0;
wire [7:0] iic_rd_reg_data;

reg [79:0] uart_data =0 ;
reg uart_trig=0 ;

wire err ;

wire [7:0] iic_wr_dev_addr_hex_h ;
wire [7:0] iic_wr_dev_addr_hex_l ;
wire [7:0] iic_wr_reg_addr_hex_h ;
wire [7:0] iic_wr_reg_addr_hex_l ;
wire [7:0] iic_wr_reg_data_hex_h ;
wire [7:0] iic_wr_reg_data_hex_l ;
wire [7:0] iic_rd_reg_data_hex_h ;
wire [7:0] iic_rd_reg_data_hex_l ;




always@(posedge CLK_I)begin
    if(~RSTN_I)begin
        state  <= 0;
        fifo_rd <= 0;
        uart_trig <= 0;
        uart_data <= 0;    
    end
    else begin
        case(state)
            0: begin
                uart_trig <= 0;
                iic_wr   <= 0;
                iic_rd   <= 0;
                if((~rd_rst_busy)  && (~rd_empty)  && (rd_data_count>0)  )begin
                    state <= 1;
                end    
            end
            1:begin
                fifo_rd <= 1;
                state  <= 2;
            end
            2:begin
                fifo_rd <= 0;
                state  <= 3 ;
            end
            3:begin
                if(~fifo_wr_wrrd)begin //写
                    iic_wr <= 1 ;
                    iic_wr_dev_addr <= fifo_dev_addr ;
                    iic_wr_reg_addr <= fifo_reg_addr ;
                    iic_wr_reg_data <= fifo_reg_data ;
                    state  <= 4; 
                end
                else begin//读
                    iic_rd <= 1 ;
                    iic_wr_dev_addr <= fifo_dev_addr ;
                    iic_wr_reg_addr <= fifo_reg_addr ;

                    state  <= 5; 
                end
            end
            4:begin
                iic_wr <= 0 ;
                state <= ~IIC_EN_O ? 0 : state ;
                uart_data <= ~IIC_EN_O  ?   {8'd87,{err==0 ?8'd83: 8'd70}, iic_wr_dev_addr_hex_h,iic_wr_dev_addr_hex_l , iic_wr_reg_addr_hex_h,iic_wr_reg_addr_hex_l, iic_wr_reg_data_hex_h,iic_wr_reg_data_hex_l, 8'd32,8'd32 } : 8'hff ;
                uart_trig <= ~IIC_EN_O  ? 1 : 0 ;
                
            end
            5:begin
                iic_rd <= 0;
                state <= ~IIC_EN_O ? 0 : state ;
                uart_data <= ~IIC_EN_O  ? { 8'd114,{err==0 ?8'd83: 8'd70}, iic_wr_dev_addr_hex_h,iic_wr_dev_addr_hex_l, iic_wr_reg_addr_hex_h,iic_wr_reg_addr_hex_l, iic_rd_reg_data_hex_h,iic_rd_reg_data_hex_l,8'd32,8'd32 } : 8'hff ;
                uart_trig <= ~IIC_EN_O  ? 1 : 0 ;
            end
            default:;
            
            
        endcase
    end
end

// WR dd rr dd [][] 
// RD dd rr dd  [][] 


iic_master_en #(.MAX_BYTE_NUM( 1 )) // 【must >= 1】
    iic_ctrl_u(
    .RST_I          (~RSTN_I),      //do not need to rst
    .CLK_I          (CLK_I  ),      
    .DIV_CNT_I      (2000   ),      //[11:0] 【 must >= 4 】
    .WRITE_REQ_I    (iic_wr ),      //prior to READ_REQ_I
    .READ_REQ_I     (iic_rd ),      
    .DEV_ADDR_I     (iic_wr_dev_addr ),      //[6:0] dev addr 【注意只有7位】
    .REG_ADDR_I     (iic_wr_reg_addr ),      //[15:0] first send high byte , when  IS_ADDR_2BYTE_I == 1
    .IS_ADDR_2BYTE_I(0 ),      //
    .PDATA_I        (iic_wr_reg_data  ),      //[MAX_BYTE_NUM*8-1:0] PDATA_I = {0000000000 low byte(first send)......high byte}
    .RD_FINISH_O    (iic_rd_finish    ),      //read finish pulse
    .WR_FINISH_O    (iic_wr_finish    ),      
    .PDATA_O        (iic_rd_reg_data  ),      //[MAX_BYTE_NUM*8-1:0] PDATA_O = {0000000000 low byte......high byte}
    .BYTE_NUM_I     (1    ),      //[f_Data2W(MAX_BYTE_NUM)-1:0]  【must >= 0, 新版本支持0字节】
    .SDA_I          (SDA_I  ),      
    .SDA_O          (SDA_O  ),      
    .SDA_T          (SDA_T  ),      
    .SCL_I          (SCL_I  ),      
    .SCL_O          (SCL_O  ),      
    .SCL_T          (SCL_T  ),      
    .BUSY_O         (IIC_EN_O   ),      
    .ERROR_O        (err        )       
    );




hex2ascii  hex2ascii_u( 
    .hex   ({0,iic_wr_dev_addr[6:4]}),  // 4-bit input hex (0-F)  
    .ascii ( iic_wr_dev_addr_hex_h ) // 8-bit ASCII output  
);  

hex2ascii  hex2ascii_u1( 
    .hex   (iic_wr_dev_addr[3:0] ),  // 4-bit input hex (0-F)  
    .ascii (iic_wr_dev_addr_hex_l  ) // 8-bit ASCII output  
);  

hex2ascii  hex2ascii_u2( 
    .hex   (iic_wr_reg_addr[7:4] ),  // 4-bit input hex (0-F)  
    .ascii (iic_wr_reg_addr_hex_h) // 8-bit ASCII output  
);  


hex2ascii  hex2ascii_u3( 
    .hex   (iic_wr_reg_addr[3:0 ]),  // 4-bit input hex (0-F)  
    .ascii (iic_wr_reg_addr_hex_l) // 8-bit ASCII output  
);  

hex2ascii  hex2ascii_u4( 
    .hex   (iic_wr_reg_data[7:4]),  // 4-bit input hex (0-F)  
    .ascii (iic_wr_reg_data_hex_h) // 8-bit ASCII output  
);  

hex2ascii  hex2ascii_u5( 
    .hex   (iic_wr_reg_data[3:0]),  // 4-bit input hex (0-F)  
    .ascii (iic_wr_reg_data_hex_l) // 8-bit ASCII output  
);  
  

hex2ascii  hex2ascii_u6( 
    .hex   (iic_rd_reg_data[7:4]),  // 4-bit input hex (0-F)  
    .ascii (iic_rd_reg_data_hex_h) // 8-bit ASCII output  
);  

hex2ascii  hex2ascii_u7( 
    .hex   (iic_rd_reg_data[3:0]),  // 4-bit input hex (0-F)  
    .ascii (iic_rd_reg_data_hex_l) // 8-bit ASCII output  
);  
  



uart_tx_wrapper
	#(.SYS_CLK_PERIOD(SYS_CLK_PRD_NS  ),// = 50;//ns
	  .BAUD_RATE(BAUD_RATE   ),// = 115200;//
	  .BYTE_NUM(10),// = 9;
	  .FINISH_PERIOD_NUM(2)// = 1;
	  )
	uart_tx_wrapper_inst
   (
	.CLK_I(CLK_I  ),//50M
	.RST_I(~RSTN_I),
	.DATA_I( uart_data   ),//[BYTE_NUM*8-1:0] 
	.START_I(uart_trig  ),//START2UARTTXWRP_O
	.SDATA_O (UART_O ),//接串口
	.BUSY_O  (),
	.FINISH_O()
    ); 
  
    
    
endmodule
