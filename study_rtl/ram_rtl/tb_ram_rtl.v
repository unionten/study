`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/12 13:27:42
// Design Name: 
// Module Name: tb_ram_rtl
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

module tb_ram_rtl(

);


reg clka;
reg clkb;
reg enb;
reg wea;
reg [7:0] addrb ;

wire [7:0] doutb ;
ram_rtl   
#(
  .WR_DATA_WIDTH   (8  ),
  .WR_DATA_DEPTH   (64 ),
  .RD_DATA_WIDTH   (8 ), //测试可用
  .INIT_FILE_PATH  ( "G:/_0_MY_RTL_/6_fifo/2_ram/version2/ram_rtl/ram_init_file.txt") ,
  .RD_MODE         ("fwft" ) //"std" "fwft"
  ) 
ram_rtl_u (
.clka   (clka   ), 
.wea    (wea    ),
.addra  (2  ),
.dina   (2342   ),
.clkb   (clkb   ),
.enb    (enb    ),
.addrb  (addrb  ),
.doutb  (doutb )

);
   

blk_mem_gen_0   blk_mem_gen_0_u
   (
    .clka   (clka) , //: IN STD_LOGIC;
    .ena    (1) , //: IN STD_LOGIC;
    .wea    (0  ) , //: IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    .addra  (7) , //: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    .dina   (44) , //: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    .douta  () , //: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    .clkb   (clkb) , //: IN STD_LOGIC;
    .enb    (0    ) , //: IN STD_LOGIC;
    .web    (0 ) , //: IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    .addrb  (0) , //: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    .dinb   (11) , //: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    .doutb  ()   //: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
  
  
  
   
always #5 clka = ~clka;
always #5 clkb = ~clkb;

initial begin
addrb = 8;
clka = 0;
clkb = 0;
wea = 0;
enb = 0;

#496;

wea = 1;
addrb = 6;
#10;
wea = 0;


#1000;
addrb = 15;
enb = 1;
addrb = 7;
#11;
enb = 0;


end 
    
    
    
    
    
    
    
    
    
    
    
    
endmodule
