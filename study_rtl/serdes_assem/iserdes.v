`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/19 09:33:34
// Design Name: 
// Module Name: iserdes
// Project Name: 
//////////////////////////////////////////////////////////////////////////////////
/*
iserdes  
   #(.C_DEVICE     ("KUP" ),
     .C_DATA_RATE  ("DDR" ),
     .C_DATA_WIDTH (4     ) )
    iserdes_u(
    .CLK_I     (),
    .CLKDIV_I  (),
    .BITSLIP_I (), //bitslip是在两次结果之间的位移
    .RST_I     (),  
    .D_I       (),
    .Q_O       () 
    );
*/


module iserdes(

input  CLK_I     ,
input  CLKDIV_I  ,
input  BITSLIP_I , //no use for  KU, KUP
input  RST_I     ,  
input        D_I ,
output [7:0] Q_O


    );

parameter C_DEVICE     =  "K7" ;//"KU" "KUP" "A7" "K7"
parameter C_DATA_RATE  =  "DDR";
parameter C_DATA_WIDTH = 8;


  
//A7  K7

//The only valid clocking arrangements for the ISERDESE2 block using the networking interface type are:
// CLK driven by BUFIO, CLKDIV driven by BUFR（除以X）；
// CLK driven by MMCM or PLL, CLKDIV driven by CLKOUT[0:6] of same MMCM or PLL
//
//   IOBDELAY       Combinatorial Output(O)   Registered Output (Q1-Q8)
//     NONE            D                        D
//     IBUF            DDLY                     D
//     IFD             D                        DDLY
//     BOTH            DDLY                     DDLY
// E2   BITSLIP input performing a bitslip operation synchronous to CLKDIV

wire [7:0] Q_i;
   //ISERDES3 说明
   
   //DDR  1:8  8  Q7,Q6,Q5,Q4,Q3,Q2,Q1,Q0
   //DDR  1:4  4              Q3,Q2,Q1,Q0
   //SDR  1:8  X      
   //SDR  1:4  8     Q6,   Q4,   Q2,   Q0
   //SDR  1:2  4                 Q2,   Q0
   
assign Q_O =  (C_DEVICE=="A7" | C_DEVICE=="K7")| C_DATA_RATE=="DDR" ? Q_i :  {0,Q_i[6],Q_i[4],Q_i[2],Q_i[0] } ; 

generate if(C_DEVICE=="A7" | C_DEVICE=="K7")begin
   ISERDESE2 #(
      .DATA_RATE(C_DATA_RATE),           // DDR, SDR
      .DATA_WIDTH(C_DATA_WIDTH),              // Parallel data width (2-8,10,14)
      .DYN_CLKDIV_INV_EN("FALSE"), //默认 FALSE Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
      .DYN_CLK_INV_EN("FALSE"),    //默认 FALSE Enable DYNCLKINVSEL inversion (FALSE, TRUE)
      // INIT_Q1 - INIT_Q4: Initial value on the Q outputs (0/1)
      .INIT_Q1(1'b0),
      .INIT_Q2(1'b0),
      .INIT_Q3(1'b0),
      .INIT_Q4(1'b0),
      .INTERFACE_TYPE("NETWORKING"),   //普通应用:NETWORKING //MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
      .IOBDELAY("IFD"),           // NONE, BOTH, IBUF, IFD   （选择输入源）
      .NUM_CE(1),                  // 时钟使能脚,为1时,CE2不使用(CE2是在memory时，控制CLKFB);
      .OFB_USED("FALSE"),          // Select OFB path (FALSE, TRUE) 默认用 FALSE
      .SERDES_MODE("MASTER"),      // MASTER, SLAVE 不拓展时用 MASTER
      // SRVAL_Q1 - SRVAL_Q4: Q output values when SR is used (0/1)
      .SRVAL_Q1(1'b0),
      .SRVAL_Q2(1'b0),
      .SRVAL_Q3(1'b0),
      .SRVAL_Q4(1'b0)
   )
   ISERDESE2_inst (//
      .O(    ),                       // 1-bit output: Combinatorial output 直接环出
      // Q1 - Q8: 1-bit (each) output: Registered data outputs
      .Q1(Q_i[7]),     //for example, the least significant bit A of the word
                   //FEDCBA is placed at the D1 input of an OSERDESE2, but the same bit
                   //A emerges from the ISERDESE2 block at the Q8 output.
      .Q2(Q_i[6]),
      .Q3(Q_i[5]),
      .Q4(Q_i[4]),
      .Q5(Q_i[3]),
      .Q6(Q_i[2]),
      .Q7(Q_i[1]),
      .Q8(Q_i[0]),
      // SHIFTOUT1, SHIFTOUT2: 1-bit (each) output: Data width expansion output ports
      .SHIFTOUT1(),
      .SHIFTOUT2(),
      .BITSLIP(BITSLIP_I),           // 1-bit input: The BITSLIP pin performs a Bitslip operation synchronous to
                                   // CLKDIV when asserted (active High). Subsequently, the data seen on the Q1
                                   // to Q8 output ports will shift, as in a barrel-shifter operation, one
                                   // position every time Bitslip is invoked (DDR operation is different from
                                   // SDR). 和CLKDIV同步
                                   //SDR模式下的bitslip和DDR模式下的bitslit操作不同
      //bitslip的移位需要并不是立刻生效的

      // CE1, CE2: 1-bit (each) input: Data register clock enable inputs
      .CE1(1),//针对CLKDIV的使能信号  连接内部serdes的时钟使能 CE1使能ISERDESE2的前1/2的CLKDIV周期,CE2使能ISERDESE2的后1/2的CLKDIV周期
      .CE2(1),//???
      .CLKDIVP(0),           // 1-bit input: TBD //只在MIG时用,其他接地
      // Clocks: 1-bit (each) input: ISERDESE2 clock input ports
      .CLK(CLK_I),                   // 1-bit input: High-speed clock 高速时钟输入---
      .CLKB(~CLK_I),     //注意此处          // 1-bit input: High-speed secondary clock 第二高速时钟,普通情况下为CLK的反相,在特殊情况下连接到相移后的时钟
      .CLKDIV(CLKDIV_I),             // 1-bit input: Divided clock -驱动串转并,BITSLIP模块,CE模块
      .OCLK(0),                 // 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY" 
      // Dynamic Clock Inversions: 1-bit (each) input: Dynamic clock inversion pins to switch clock polarity
      .DYNCLKDIVSEL(0), // 1-bit input: Dynamic CLKDIV inversion翻转
      .DYNCLKSEL(0),       // 1-bit input: Dynamic CLK/CLKB inversion  翻转
      // Input Data: 1-bit (each) input: ISERDESE2 data input ports 
      .D(  ),                       // 1-bit input: Data input - 高速串行数据-连io资源
      .DDLY(D_I),                 // 1-bit input: Serial data from IDELAYE2 - 高速串行数据-连IDELAYE2
      .OFB(0),                   // 1-bit input: Data feedback from OSERDESE2 从oserdes的反馈?
      .OCLKB(0),               // 1-bit input: High speed negative edge output clock 只在MEMORY时有效
      .RST(RST_I),                   // 1-bit input: Active high asynchronous reset
      // SHIFTIN1, SHIFTIN2: 1-bit (each) input: Data width expansion input ports
      .SHIFTIN1(0),//非级联模式,要么不连接,要么连接到gnd
      .SHIFTIN2(0)
   );   
    
end
else if(C_DEVICE=="KU" | C_DEVICE=="KUP" )begin
   //DDR  1:8  8  Q7,Q6,Q5,Q4,Q3,Q2,Q1,Q0
   //DDR  1:4  4              Q3,Q2,Q1,Q0
   //SDR  1:8  X      
   //SDR  1:4  8     Q6,   Q4,   Q2,   Q0
   //SDR  1:2  4                 Q2,   Q0
   
   ISERDESE3 #(
      .DATA_WIDTH(C_DATA_WIDTH),            // Parallel data width (4,8)
      .FIFO_ENABLE("FALSE"),     // Enables the use of the FIFO   (是否使用内部fifo)
      .FIFO_SYNC_MODE("FALSE"),  // Always set to FALSE. TRUE is reserved for later use.
      .IS_CLK_B_INVERTED(1'b0),  // Optional inversion for CLK_B
      .IS_CLK_INVERTED(1'b0),    // Optional inversion for CLK
      .IS_RST_INVERTED(1'b0),    // Optional inversion for RST
      .SIM_DEVICE(C_DEVICE=="KU" ? "ULTRASCALE" : "ULTRASCALE_PLUS" )  // Set the device version for simulation functionality (ULTRASCALE)
   )
   ISERDESE3_inst (
      .FIFO_EMPTY( ),           // 1-bit output: FIFO empty flag
      .INTERNAL_DIVCLK( ), // 1-bit output: Internally divided down clock used when FIFO is
                                         // disabled (do not connect)   Reserved

      .Q({Q_i[7],Q_i[6],Q_i[5],Q_i[4],Q_i[3],Q_i[2],Q_i[1],Q_i[0]}),                             // 8-bit registered output
      .CLK(CLK_I),                         // 1-bit input: High-speed clock
      .CLKDIV(CLKDIV_I),                   // 1-bit input: Divided Clock
      .CLK_B(~CLK_I),                     // 1-bit input: Inversion of High-speed clock CLK (必须来自同一个global buffer)
      .D(D_I),                             // 1-bit input: Serial Data Input
      .FIFO_RD_CLK(0),         // 1-bit input: FIFO read clock
      .FIFO_RD_EN(0),           // 1-bit input: Enables reading the FIFO when asserted
      .RST(RST_I)                          // 1-bit input: Asynchronous Reset
   );



end

endgenerate
  

  
    
endmodule




