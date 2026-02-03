`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/18 11:00:55
// Design Name: 
// Module Name: tb_byte_align
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////


module tb_byte_align(

    );
    
parameter C_DATA_WIDTH = 4;

reg  clk ;
reg  rst ;
reg  [C_DATA_WIDTH-1:0] DATA_I ;
wire [C_DATA_WIDTH-1:0] DATA_O ;
reg slip;
reg COMP_TRIG;
always #5 clk = ~clk;


byte_align 
#(.C_DATA_WIDTH (C_DATA_WIDTH),
  .C_FUNCTION       ("COMP" ),//= "COMP" ;// "COMP" , "SLIP"  
  .C_COMP_THRESHOLD (10)//= 100;
  )  // 4 or 8 ,default 4

byte_align_u(
.CLK_I      (clk     ),
.RST_I      (rst     ),
.DATA_I     (DATA_I  ),
.BIT_SLIP_I (slip    ), // 循环
.COMP_VAL_I (8'b10101101        ), //
.COMP_TRIG_I (COMP_TRIG),  // 
.COMP_DONE_O (COMP_DONE),  // ___|————————
.DATA_O     (DATA_O  )

);
    
initial begin
   slip = 0;
   COMP_TRIG = 0;
   DATA_I = 8'b10101100;
   clk = 0;
   rst = 1;
   #500;
   rst = 0;
   #501;
   
   slip = 1;
   #10;
   slip = 0;
   #100;
   
     slip = 1;
   #10;
   slip = 0;
   #100; 
   
     slip = 1;
   #10;
   slip = 0;
   #100; 

   slip = 1;
   #10;
   slip = 0;
   #100;
   

   slip = 1;
   #10;
   slip = 0;
   #100;
   

   slip = 1;
   #10;
   slip = 0;
   #100;
   
   COMP_TRIG = 1;
   #20;
   COMP_TRIG = 0;

   slip = 1;
   #10;
   slip = 0;
   #100;
   

   slip = 1;
   #10;
   slip = 0;
   #100;
   

   slip = 1;
   #10;
   slip = 0;
   #100;
   

   slip = 1;
   #10;
   slip = 0;
   #100;
   
   
   #200;
   DATA_I = 8'b10101100;
   
   #500;
   
   #1000;
      
   COMP_TRIG = 1;
   #20;
   COMP_TRIG = 0;
    #1000;
    
    #4000;
    
    DATA_I = 8'b10101101;
   #4000;
   
   DATA_I = 8'b10101100;
   
      
end


    
endmodule
