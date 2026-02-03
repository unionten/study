`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2022/06/20 13:08:56
// Design Name: 
// Module Name: oserdes_gen
//////////////////////////////////////////////////////////////////////////////////
//SERDES支持SDR和DDR两个模式。
//SDR模式支持2、3、4、5、6、7、8bit位宽；
//DDR模式支持4、6、8bit位宽  [10或14bit位宽需要两个模块级联]。
//【除级联外，都仿真通过】
//【注意：三态控制需要额外处理】
//
//  oserdes_gen
//      #(.SER_FACTOR     (4    ),  //
//        .UNIT_NUM       (10   ),  //
//        .DATA_RATE_TYPE ("SDR"),  //"SDR"  "DDR"
//        .INIT_OQ        (1'b0 ),  //1'b0  1'b1   
//        .INIT_TQ        (1'b0 ),  //1'b0  1'b1
//        .SRVAL_OQ       (1'b0 ),  //1'b0  1'b1
//        .SRVAL_TQ       (1'b0 ))  //1'b0  1'b1 
//      oserdes_gen_u ( 
//      .RST_I      (),       
//      .CLK_HIGH_I (),  
//      .CLK_DIV_O  (),   
//      .PDATA_I    (),   //先发高单元(每单元低位先出) 
//      .PTRI_I     (),   //每个unit中只有低4位有效   
//      .START_I    (),     
//      .O          (),
//      .T          ()
//      );
//      
module oserdes_gen
#(
parameter SER_FACTOR       = 4,
parameter UNIT_NUM         = 10,
parameter DATA_RATE_TYPE   = "DDR",    //"SDR" "DDR"
parameter INIT_OQ          = 1'b0 ,    //1'b0 1'b1
parameter INIT_TQ          = 1'b0 , 
parameter SRVAL_OQ         = 1'b0 , 
parameter SRVAL_TQ         = 1'b0 
)
(
RST_I       ,
CLK_HIGH_I  ,
CLK_DIV_O   ,
PDATA_I     ,
PTRI_I      ,
START_I     ,
O           ,
T           
);

input RST_I;
input CLK_HIGH_I;
output reg CLK_DIV_O;
input [SER_FACTOR*UNIT_NUM-1:0] PDATA_I;
input [SER_FACTOR*UNIT_NUM-1:0] PTRI_I;//每个unit中只有低4位有效
input START_I;
output O;
output T;

///////////////////////////////////////////////////////////////////////////////
localparam CLK_DIV_NUM = DATA_RATE_TYPE == "SDR" ?  SER_FACTOR : SER_FACTOR/2 ;

reg [7:0] counter = 0;
always@(posedge CLK_HIGH_I)begin
	if(counter<(CLK_DIV_NUM/2))begin
		counter <= counter + 1;
		CLK_DIV_O <= 0;
	end
	else if(counter<(CLK_DIV_NUM-1))begin
		counter <= counter + 1;
		CLK_DIV_O <= 1;
	end
    else begin
        counter <= 0;
        CLK_DIV_O <= 1;
    end
end

   OSERDESE2 #(
      .DATA_RATE_OQ(DATA_RATE_TYPE),   // DDR, SDR
      .DATA_RATE_TQ(DATA_RATE_TYPE),   // DDR, BUF, SDR
      .DATA_WIDTH(SER_FACTOR),         // Parallel data width (2-8,10,14) 
      .INIT_OQ(INIT_OQ),         // Initial value of OQ output (1'b0,1'b1)
      .INIT_TQ(INIT_TQ),         // Initial value of TQ output (1'b0,1'b1)
      .SERDES_MODE("MASTER"), // MASTER, SLAVE
      .SRVAL_OQ(SRVAL_OQ),        // OQ output value when SR is used (1'b0,1'b1)
      .SRVAL_TQ(SRVAL_TQ),        // TQ output value when SR is used (1'b0,1'b1)
      .TBYTE_CTL("FALSE"),    // Enable tristate byte operation (FALSE, TRUE)
      .TBYTE_SRC("FALSE"),    // Tristate byte source (FALSE, TRUE)
      .TRISTATE_WIDTH(4)      // 3-state converter width (1,4)
   )
   OSERDESE2_inst (
      .OFB(   ),             // 1-bit output: Feedback path for data OFB可以连接ODELAY
      .OQ(O),               // 1-bit output: Data path output OQ连接FPGA输出,但是不能连接ODELAY
      // SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
      .SHIFTOUT1( ),
      .SHIFTOUT2( ),
      .TBYTEOUT( ),   // 1-bit output: Byte group tristate
      .TFB( ),             // 1-bit output: 3-state control
      .TQ(T),               // 1-bit output: 3-state control
      .CLK(CLK_HIGH_I),             // 1-bit input: High speed clock 高速时钟 驱动并串转换的串行边
      .CLKDIV(CLK_DIV_O),       // 1-bit input: Divided clock 分频的时钟(没说几分频),驱动并串转换的并行边
      // D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
      .D1(D[0]),
      .D2(D[1]),
      .D3(D[2]),
      .D4(D[3]),
      .D5(D[4]),
      .D6(D[5]),
      .D7(D[6]),
      .D8(D[7]),
      .OCE(1),             // 1-bit input: Output data clock enable 数据路径的时钟使能
      .RST(RST_I),             // 1-bit input: Reset
      // SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
      .SHIFTIN1(0),
      .SHIFTIN2(0),
      // T1 - T4: 1-bit (each) input: Parallel 3-state inputs
      .T1(T[0]),//0:正常输出  1:高阻态
      .T2(T[1]),
      .T3(T[2]),
      .T4(T[3]),
      .TBYTEIN(0),     // 1-bit input: Byte group tristate
      .TCE(1)              // 1-bit input: 3-state clock enable  确实有效
      );  

reg start_buf;
wire start_pos;
always@(posedge CLK_DIV_O)begin
    if(RST_I)begin
        start_buf <= 1;
    end
    else begin
        start_buf <= START_I;
    end
end
assign start_pos = START_I & ~start_buf;
    
      
reg [7:0]  D;  
reg [3:0]  T;
reg [SER_FACTOR*UNIT_NUM-1:0] pdata_r ;
reg [SER_FACTOR*UNIT_NUM-1:0] pdata_tri_r;
reg [7:0] state;
reg [15:0] cnt;
always@(posedge CLK_DIV_O)begin
    if(RST_I)begin
        D <= 0;
        state <=0;
        cnt <= 0;
        pdata_r <= 0;
        pdata_tri_r <= 0;
    end
    else begin
        case(state)   
            0:begin
                state   <= start_pos ? 1 : 0;
                pdata_r <=  start_pos ? PDATA_I : 0;
                pdata_tri_r <= start_pos ? PTRI_I : 0;
                D   <= {8{INIT_OQ}};
                T   <= {4{INIT_TQ}};
                cnt <= 0;
            end
            1:begin
                D       <= pdata_r[SER_FACTOR*UNIT_NUM-1:SER_FACTOR*UNIT_NUM-SER_FACTOR];
                T       <= pdata_tri_r[SER_FACTOR*UNIT_NUM-1:SER_FACTOR*UNIT_NUM-SER_FACTOR];
                pdata_r <= pdata_r<<SER_FACTOR;
                pdata_tri_r <= pdata_tri_r<<SER_FACTOR;
                cnt     <= cnt + 1;
                state   <= ((cnt+1) == UNIT_NUM ) ? 0 : 1;
            end
            default:;            
        endcase
    end
end

endmodule
