`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date:    08:59:53 05/08/2019 
// Module Name:    uart_tx_wrapper 
//////////////////////////////////////////////////////////////////////////////////

/* uart_tx_wrapper
	#(.SYS_CLK_PERIOD(),// = 50;//ns
	  .BAUD_RATE(),// = 115200;//
	  .BYTE_NUM(),// = 9;
	  .FINISH_PERIOD_NUM()// = 1;
	  )
	uart_tx_wrapper_inst
(
	.CLK_I(),//50M
	.RST_I(),
	.DATA_I(),//[BYTE_NUM*8-1:0] 
	.START_I(),//START2UARTTXWRP_O
	.SDATA_O(),//接串口
	.BUSY_O(),
	.FINISH_O()
); */


module uart_tx_wrapper(
CLK_I,//50M
RST_I,
DATA_I,
START_I,//START2UARTTXWRP_O
SDATA_O,//接串口
BUSY_O,
FINISH_O
);
parameter SYS_CLK_PERIOD = 50;//ns
parameter BAUD_RATE = 115200;//
parameter BYTE_NUM = 9;
parameter FINISH_PERIOD_NUM = 1;
///////////////////////////////////////////////////////////////////////////////
localparam BAUD_DIV = (1.0/(SYS_CLK_PERIOD*1.0/1000000000))/BAUD_RATE;//50MHz-->19200bps  //d2604 
//parameter BAUD_DIV = 2604;//50M/19200


input CLK_I;//50M
input RST_I;
input [BYTE_NUM*8-1:0] DATA_I;
input START_I;//START2UARTTXWRP_O
output SDATA_O;//接串口
output BUSY_O;
output reg FINISH_O = 0;
wire obusy;
reg Busy_o = 0;
assign BUSY_O = START_I | Busy_o | obusy;

reg [9:0] i;
reg [BYTE_NUM*8-1:0] Data_i;
reg [7:0] State = 0;
reg Start2uarttx;
reg [7:0] Din2uarttx;
wire dvalid;

reg [31:0] cnt_finish;
uart_tx 
	#(.SYS_CLK_PERIOD(SYS_CLK_PERIOD),//
	  .BAUD_RATE(BAUD_RATE))//
	uart_tx_u(
	.RST_I(RST_I),
	.CLK_I(CLK_I),
	.START_I(Start2uarttx),
	.PDATA_I(Din2uarttx),
	.FINISH_O(dvalid),
	.UART_O(SDATA_O),
	.BUSY_O(obusy)
);

always@(posedge CLK_I)begin
	if(RST_I)begin
		State <= 0;
		Busy_o <= 0;
	end
	else begin
		case(State)
			0:begin
				Start2uarttx <= 0; 
				if(START_I == 1)begin
					i <= BYTE_NUM;
					Data_i <= DATA_I;
					State <= 1;
					Busy_o <= 1;
				end
				else begin
					State <= State;
					Busy_o <= 0;
				end
			end
			1:begin
				if(obusy==0)begin
					
					if(i>0)begin
						Start2uarttx <= 1;
						Din2uarttx <= Data_i[BYTE_NUM*8-1:BYTE_NUM*8-8];
						Data_i <= Data_i<<8 ;
						i <= i - 1;
					end
					
					if(i > 0)begin
						State <= 1;
					end
					else begin
						cnt_finish <= FINISH_PERIOD_NUM - 1;
						FINISH_O <= 1;
						State <= 2;
					end
				end
				else begin
					Start2uarttx <= 0;
				end
			end
			2:begin
				if(cnt_finish>0)begin
					cnt_finish <= cnt_finish - 1;
				end
				else begin
					FINISH_O <= 0;
					State <= 0;
				end
			end
			default:begin
				Start2uarttx <= 0;
				State <= 0;
				Busy_o <= 0;
			end		
		endcase
	end
end

endmodule
