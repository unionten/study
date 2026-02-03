`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module tb_delay_reg_en_unify(

    );

reg clk =0; 
reg [7:0] datain= 0;
wire [23:0] dataout;


delay_reg_en_unify  
    #(.WIDTH(8),
      .LEN(1))
    delay_reg_en_unify_u(  
    .CLK_I(clk),
    .IN_I(datain),
    .OUT_NEW2OLD_O(dataout));



always #20 clk = ~clk;  
    
initial begin
    #10;
    datain = 8'haa;
    #40
    
    datain = 8'hbb;
    #40
    
    datain = 8'hcc;
    #40
    
    datain = 8'hdd;
    #40
    
    datain = 8'h22;
    

end
    
    
endmodule
