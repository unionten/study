`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/18 15:20:34
// Design Name: 
// Module Name: tb_mmcme2_drp_unify
//////////////////////////////////////////////////////////////////////////////////


module tb_mmcme2_drp_unify(

    );

reg clk;
reg rst;
reg sstep;
reg [7:0] state;


always #5 clk = ~clk;
 
mmcme2_drp_top  uut( 
        .SSTEP(sstep),
        .STATE(state),
        .RST(rst),
        .CLKIN(clk),
        .SRDY(srdy),
 		.LOCKED_OUT(locked),
        .CLK0OUT(clock)
    );  
    
initial begin
rst = 1;
sstep = 0;
state = 0;
clk = 0;
#500;
rst = 0;
#8000;

////////////////////

sstep = 1;
state = 0;
#11;
sstep = 0;
#10000;



sstep = 1;
state = 1;
#11;
sstep = 0;
#10000;




sstep = 1;
state = 2;
#11;
sstep = 0;
#10000;




sstep = 1;
state = 3;
#11;
sstep = 0;
#10000;




sstep = 1;
state = 4;
#11;
sstep = 0;
#10000;


end

    
endmodule
