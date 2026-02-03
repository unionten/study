`timescale 1ns/1ps
/*
uart_rx
    #(.SYS_CLK_PERIOD(),// = 50;//ns
      .BAUD_RATE(),// = 115200;
      .FINISH_PERIOD_NUM()// = 1;  
    )
    uart_rx_u
(
    .RST_I(),
    .CLK_I(), //SYS_CLK
    .UART_I(),
    .EN_I(),
    .PDATA_O(),
    .FINISH_O()
);
*/


module  uart_rx(
RST_I,
CLK_I, 
UART_I,
EN_I,
PDATA_O,
FINISH_O
);
   //even prioty
parameter            SYS_CLK_PERIOD = 50;//ns
parameter            BAUD_RATE = 115200;//
parameter            FINISH_PERIOD_NUM = 1;  
parameter            PRIOTY = "EVEN" ; //"NONE" "ODD" "EVEN"



localparam [15:0]    BAUD_DIV = (1.0/(SYS_CLK_PERIOD*1.0/1000000000))/BAUD_RATE;//50MHz-->19200bps  //d2604 

input                 RST_I;
input                 CLK_I;
input                 UART_I;
input                 EN_I;
output                FINISH_O;
output     [7:0]      PDATA_O;


reg     [7:0]      PDATA_O = 0;
reg                FINISH_O = 0;
reg                O_error;
reg     [7:0]      R_RxData = 0;
reg     [15:0]     R_BaudCount = 0;

wire    [3:0]      r_rxcount;
reg     [3:0]      R_RxCount = 0;
assign r_rxcount = R_RxCount;

reg                R_even_bit = 0;
reg                R_checksum = 0;
reg                R_check_flag = 0;
reg     [4:0]      R_cusum_count = 0;

reg [31:0] cnt_finish;

always@(posedge CLK_I )begin
	if(RST_I)begin
		FINISH_O        <= 1'b0;
		PDATA_O         <= 8'd0;
		R_RxData        <= 8'd0;
		R_BaudCount     <= 15'd0;
		O_error         <= 1'b0;
		R_RxCount       <= 4'd0;
		R_even_bit      <= 1'b0;
		R_checksum      <= 1'b0;
		R_check_flag    <= 1'b0;
		R_cusum_count   <= 'd0;
	end
	else begin
		if(EN_I)begin
			case(R_RxCount)
				4'd0:begin
					FINISH_O        <=1'b0;    
					O_error         <=1'b0;
					R_BaudCount     <=16'd0;
					R_check_flag    <= 1'b0;
					R_checksum      <= 1'b0;
					R_even_bit      <=1'b0;
					if(UART_I == 1'b0)R_RxCount<=4'd1;
				end
				4'd1:begin
					if(R_BaudCount<BAUD_DIV-1'b1)
						R_BaudCount<=R_BaudCount+1'b1;
					else begin
						R_BaudCount<=16'd0;
						R_RxCount<=R_RxCount+1'b1;
					end
				end
				4'd2:begin
					if(R_BaudCount<BAUD_DIV-1'b1)
						R_BaudCount<=R_BaudCount+1'b1;
					else begin
						R_BaudCount<=16'd0;
						R_RxCount<=R_RxCount+1'b1;
					end
					if(R_BaudCount=={1'b0,BAUD_DIV[15:1]})
						R_RxData[0]<=UART_I;
				end  
				4'd3:begin
					if(R_BaudCount<BAUD_DIV-1'b1)
						R_BaudCount<=R_BaudCount+1'b1;
					else begin
						R_BaudCount<=16'd0;
						R_RxCount<=R_RxCount+1'b1;
					end
					if(R_BaudCount=={1'b0,BAUD_DIV[15:1]})
						R_RxData[1]<=UART_I;
				end  
				4'd4:begin
					if(R_BaudCount<BAUD_DIV-1'b1)
						R_BaudCount<=R_BaudCount+1'b1;
					else begin
						R_BaudCount<=16'd0;
						R_RxCount<=R_RxCount+1'b1;
					end
					if(R_BaudCount=={1'b0,BAUD_DIV[15:1]})
						R_RxData[2]<=UART_I;
				end   
				4'd5:begin
					if(R_BaudCount<BAUD_DIV-1'b1)
						R_BaudCount<=R_BaudCount+1'b1;
					else begin
						R_BaudCount<=16'd0;
						R_RxCount<=R_RxCount+1'b1;
					end
					if(R_BaudCount=={1'b0,BAUD_DIV[15:1]})
						R_RxData[3]<=UART_I;
				end     
				4'd6:begin
					if(R_BaudCount<BAUD_DIV-1'b1)
						R_BaudCount<=R_BaudCount+1'b1;
					else begin
						R_BaudCount<=16'd0;
						R_RxCount<=R_RxCount+1'b1;
					end
					if(R_BaudCount=={1'b0,BAUD_DIV[15:1]})
						R_RxData[4]<=UART_I;
				end
				4'd7:begin
					if(R_BaudCount<BAUD_DIV-1'b1)
						R_BaudCount<=R_BaudCount+1'b1;
					else 
						begin
							R_BaudCount<=16'd0;
							R_RxCount<=R_RxCount+1'b1;
						end
					if(R_BaudCount=={1'b0,BAUD_DIV[15:1]})
						R_RxData[5]<=UART_I;
				end
				4'd8:begin
					if(R_BaudCount<BAUD_DIV-1'b1)
						R_BaudCount<=R_BaudCount+1'b1;
					else begin
						R_BaudCount<=16'd0;
						R_RxCount<=R_RxCount+1'b1;
					end
					if(R_BaudCount=={1'b0,BAUD_DIV[15:1]})
						R_RxData[6]<=UART_I;
				end    
				4'd9:begin
					if(R_BaudCount<BAUD_DIV-1'b1)
						R_BaudCount<=R_BaudCount+1'b1;
					else begin
						R_BaudCount<=16'd0;
						R_RxCount<= PRIOTY=="ODD" ? 13 : PRIOTY=="EVEN" ? 10 :11  ;
					end
					if(R_BaudCount=={1'b0,BAUD_DIV[15:1]})
						R_RxData[7]<=UART_I;
				end
				4'd10:begin    //接收校验位 偶校验
					if(R_BaudCount<BAUD_DIV-1'b1)
						R_BaudCount<=R_BaudCount+1'b1;
					else begin
						R_BaudCount<=16'd0;
						R_RxCount<=R_RxCount+1'b1;
					end
					if(R_BaudCount=={1'b0,BAUD_DIV[15:1]})begin
						R_even_bit<=UART_I;
						R_checksum<=^R_RxData;//首先计算数接收到的数据中1的个数，R_checksum为0表示接收到的数据中含有偶数个1，否则是奇数个1
						if(~(R_checksum^R_even_bit))//对接收到的数据进行偶校验
					//    R_checksum<=~^R_RxData;
					//    if(R_checksum~^R_even_bit)        //对接收到的数据进行奇校验
							R_check_flag<=1;
						else begin
							R_check_flag    <=    0;
							R_cusum_count    <=    R_cusum_count + 1'b1;        //出现校验出错则误码数加1
						end
					end
				end
                4'd13:begin    //接收校验位 偶校验
					if(R_BaudCount<BAUD_DIV-1'b1)
						R_BaudCount<=R_BaudCount+1'b1;
					else begin
						R_BaudCount<=16'd0;
						R_RxCount<=R_RxCount+1'b1;
					end
					if(R_BaudCount=={1'b0,BAUD_DIV[15:1]})begin
						R_even_bit<=UART_I;
						//R_checksum<=^R_RxData;//首先计算数接收到的数据中1的个数，R_checksum为0表示接收到的数据中含有偶数个1，否则是奇数个1
						//if(~(R_checksum^R_even_bit))//对接收到的数据进行偶校验
					    R_checksum<=~^R_RxData;
					    if(R_checksum~^R_even_bit)        //对接收到的数据进行奇校验
							R_check_flag<=1;
						else begin
							R_check_flag    <=    0;
							R_cusum_count    <=    R_cusum_count + 1'b1;        //出现校验出错则误码数加1
						end
					end
				end
                
                
				4'd11:begin
					R_BaudCount<=R_BaudCount+1'b1;
					if(R_BaudCount=={1'b0,BAUD_DIV[15:1]})begin
						R_RxCount<=4'd0;
						if(UART_I==1'b1 && R_check_flag == 1)begin
							PDATA_O<=R_RxData;
							cnt_finish <= FINISH_PERIOD_NUM - 1;
							FINISH_O <= 1;
							R_RxCount<=R_RxCount+1'b1;  
						end
						else O_error<=1'b1;                                        
					end
					else FINISH_O<=1'b0;    
				end 
				4'd12:begin
					if(cnt_finish>0)begin
					   cnt_finish <= cnt_finish - 1;
					end
					else begin
						FINISH_O <= 0;
						R_RxCount <= 0;
					end
				 end
				 default:begin 
					R_RxCount<=4'd0;
					FINISH_O <= 0;
				end
			endcase
	    end
    end
end


endmodule
