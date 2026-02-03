`timescale 1ns/1ps

/*
uart_tx
	#(.SYS_CLK_PERIOD(),//
	  .BAUD_RATE(),
	  .OFFSET()//停止位减少的时钟周期
	  )//
(
	.RST_I(),
	.CLK_I(),
	.START_I(),
	.PDATA_I(),
	.FINISH_O(),
	.UART_O(),
	.BUSY_O()
);
*/

//偶校验

module uart_tx(
RST_I,
CLK_I,
START_I,
PDATA_I,
FINISH_O,
UART_O,
BUSY_O
);
/*-------------------------- module parametes -------------------------*/
parameter            SYS_CLK_PERIOD = 50;//ns
parameter            BAUD_RATE = 115200;//
parameter            OFFSET = 2;
parameter            PRIOTY = "EVEN" ; //"NONE" "ODD" "EVEN"

///////////////////////////////////////////////////////////////////////////////
localparam [15:0]    BAUD_DIV = (1.0/(SYS_CLK_PERIOD*1.0/1000000000))/BAUD_RATE;//50MHz-->19200bps  //d2604 

/*------------------------------- inputs ------------------------------*/
input RST_I;
input CLK_I;
input START_I;
input [7:0] PDATA_I;
/*------------------------------- output ------------------------------*/
output FINISH_O;
output UART_O;
output BUSY_O;
reg    FINISH_O,UART_O;
/*--------------------------- internal signals ------------------------*/

reg [4:0]  R_TxCount = 0;
reg [15:0] R_BaudCount = 0;
reg [7:0]  R_din = 0;
reg R_busy = 0;
assign BUSY_O = R_busy || START_I;
        
/*---------------------------- main process ---------------------------*/

always@(posedge CLK_I)begin
	if(RST_I)begin
		UART_O<=1'b1;
		FINISH_O<=1'b0;
		R_TxCount<=4'd0;
		R_din <= 'd0;
		R_busy <= 1'b0;//changed
	end
	else begin                
		case(R_TxCount)
			4'd0:begin
				FINISH_O<=1'b0;
				R_BaudCount<=16'd0;
				UART_O<=1'b1;
				
				if(START_I==1'b1)begin
					R_TxCount<=4'd1;
					R_din <= PDATA_I;
					R_busy <= 1'b1;//changed
				end
			  end
			 4'd1:begin  
				  UART_O<=1'b0;
				  if(R_BaudCount<BAUD_DIV-1'b1)
					  R_BaudCount<=R_BaudCount+1'b1;
				  else begin
					  R_BaudCount<=16'd0;
					  R_TxCount<=R_TxCount+1'b1;
				  end
			 end        
			 4'd2:begin
				  UART_O<=R_din[0];
				  if(R_BaudCount<BAUD_DIV-1'b1)
					  R_BaudCount<=R_BaudCount+1'b1;
				  else begin
					  R_BaudCount<=16'd0;
					  R_TxCount<=R_TxCount+1'b1;
				  end
			 end
				 
			 4'd3:begin
				UART_O<=R_din[1];
				if(R_BaudCount<BAUD_DIV-1'b1)begin
					R_BaudCount<=R_BaudCount+1'b1;
				end
				else begin
				  R_BaudCount<=16'd0;
				  R_TxCount<=R_TxCount+1'b1;
				end
			 end	 
			 4'd4:begin
				UART_O<=R_din[2];
						if(R_BaudCount<BAUD_DIV-1'b1)
						  R_BaudCount<=R_BaudCount+1'b1;
					  else begin
						  R_BaudCount<=16'd0;
						  R_TxCount<=R_TxCount+1'b1;
						end
					 end
					 
			  4'd5:begin
						UART_O<=R_din[3];
						if(R_BaudCount<BAUD_DIV-1'b1)
						  R_BaudCount<=R_BaudCount+1'b1;
					  else begin
						  R_BaudCount<=16'd0;
						  R_TxCount<=R_TxCount+1'b1;
						end
					 end
					 
			  4'd6:begin
						UART_O<=R_din[4];
						if(R_BaudCount<BAUD_DIV-1'b1)
						  R_BaudCount<=R_BaudCount+1'b1;
					  else begin
						  R_BaudCount<=16'd0;
						  R_TxCount<=R_TxCount+1'b1;
						end
					 end
				
			  4'd7:begin
						UART_O<=R_din[5];
						if(R_BaudCount<BAUD_DIV-1'b1)
						  R_BaudCount<=R_BaudCount+1'b1;
					  else begin
						  R_BaudCount<=16'd0;
						  R_TxCount<=R_TxCount+1'b1;
						end
					 end
				
			  4'd8:begin
						UART_O<=R_din[6];
						if(R_BaudCount<BAUD_DIV-1'b1)
						  R_BaudCount<=R_BaudCount+1'b1;
					  else begin
						  R_BaudCount<=16'd0;
						  R_TxCount<=R_TxCount+1'b1;
						end
					 end
				
			   4'd9:begin
						UART_O<=R_din[7];
						if(R_BaudCount<BAUD_DIV-1'b1)
						  R_BaudCount<=R_BaudCount+1'b1;
					  else begin
						  R_BaudCount<=16'd0;
						  R_TxCount<= PRIOTY=="EVEN" ? 10 : PRIOTY=="ODD"  ?  12 : 11 ;
						end
					 end
				4'd10:begin
						UART_O<=R_din[0]^R_din[1]^R_din[2]^R_din[3]^R_din[4]^R_din[5]^R_din[6]^R_din[7];
						if(R_BaudCount<BAUD_DIV-1'b1)
						  R_BaudCount<=R_BaudCount+1'b1;
					  else begin
						  R_BaudCount<=16'd0;
						  R_TxCount<=R_TxCount+1'b1;
						end
					 end   
                4'd12:begin
						UART_O<=~(R_din[0]^R_din[1]^R_din[2]^R_din[3]^R_din[4]^R_din[5]^R_din[6]^R_din[7]);
						if(R_BaudCount<BAUD_DIV-1'b1)
						  R_BaudCount<=R_BaudCount+1'b1;
					  else begin
						  R_BaudCount<=16'd0;
						  R_TxCount<=R_TxCount+1'b1;
						end
					 end
				4'd11:begin
						UART_O<=1'b1;
						
						if(R_BaudCount<BAUD_DIV - OFFSET)
						//if(R_BaudCount<BAUD_DIV/2)//20190911
						  R_BaudCount<=R_BaudCount+1'b1;
					  else begin
						  FINISH_O<=1'b1;
						  R_BaudCount<=16'd0;
						  R_TxCount<=4'd0;
						  R_busy <= 1'b0;//changed
						end
					 end
				default:begin 
					R_TxCount<=4'd0;
					R_busy <= 1'b0;
					UART_O<=1'b1;
					FINISH_O<=1'b0;
					R_din <= 'd0;
				end
		endcase                    
	end
  end
  
endmodule  
