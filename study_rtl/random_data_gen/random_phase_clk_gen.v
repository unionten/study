`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  yzhu
// 
// Create Date: 2024/09/03 09:40:12
// Design Name: 
// Module Name: random_phase_clk_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
//////////////////////////////////////////////////////////////////////////////////


module random_phase_clk_gen(
input  CLK_I,
input  RST_I,
output reg RAN_PHA_CLK_O = 0

    );
parameter DIV_NUM = 4; // must >= 4


reg [$clog2(DIV_NUM)-1:0] base_cnt = 0;
wire [$clog2(DIV_NUM)-1:0] random_data ; //0 ~ DIV_NUM-2
reg  clk_en = 0;

random_gen  
  #(.WIDTH ($clog2(DIV_NUM))) 
  random_gen_u
   (
    .clk        (CLK_I),
    .reset      (RST_I),
    .en         (clk_en) ,
    .random_data(random_data) //0 ~ DIV_NUM-2
  ); 


always@(posedge CLK_I)begin
    if(RST_I)begin
        base_cnt <= 0;
    end
    else begin
        base_cnt <= base_cnt + 1;
    end
end


always@(posedge CLK_I)begin
    if(RST_I)begin
        clk_en <= 0;
    end
    else begin
        clk_en <= base_cnt==DIV_NUM-2 ? 1 : 0 ;
    end
end




always@(posedge CLK_I)begin
    if(RST_I)begin
        RAN_PHA_CLK_O <= 0;
    end
    else begin
        RAN_PHA_CLK_O <= base_cnt==(DIV_NUM-1) ? 1 : random_data==base_cnt ?0 : RAN_PHA_CLK_O; 

    end
end
    
    
endmodule
