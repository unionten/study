`timescale 1ns / 1ps
`define CMD_WR  8'd0
`define CMD_RD  8'd1
`define CMD_SE  8'd2
`define CMD_BE  8'd3

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/17 11:51:46
// Design Name: 
// Module Name: tb_flash
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


module tb_flash(

    );

reg clk;
reg rst;


reg [7:0] CMD_I;
reg START_I ;       
 




 
flash  
    #(.C_MAX_BYTE_NUM      (2), 
      .C_CLK_DIV           (2), 
      .C_INIT_ADDR         (24'hFF0000), 
      .C_INIT_ENABLE       (1), 
      .C_INIT_BYTE_NUM     (2),
      .C_INIT_DELAY_CLK_NUM(0), 
      .C_INIT_TIMES        (1) ,
      .C_CS_BEGIN_PROTECT_DELAY_SYS_CLK_NUM (0),// <=65535 
      .C_CS_END_PROTECT_DELAY_SYS_CLK_NUM   (0),// <=65535 
      .C_BUSY_PROTECT_DELAY_SYS_CLK_NUM     (0)// <=65535 
      
      )
    uut(
    .SYS_RST_I        (rst),
    .SYS_CLK_I        (clk),//quick clk
    .FLASH_CLK_O  (FLASH_CLK_O  ),
    .FLASH_CS_O   (FLASH_CS_O   ),//flash clk
    .FLASH_D0_O   (FLASH_D0_O   ),
    .FLASH_D1_I   (0   ),
    .FLASH_WP_O   (FLASH_WP_O   ),
    .FLASH_HOLD_O (FLASH_HOLD_O ),
    .CMD_I        (CMD_I      ),
    .START_I      (START_I    ),
    .ADDR_I       (32'hFF0000     ),
    .BYTE_NUM_I   (2          ),
    .PDATA_I      (16'haabb    ), 
    .PDATA_O      (), 
    .BUSY_O       (),
    .FINISH_O     () 
    
    );

always #5 clk = ~clk ;

initial begin
clk = 0;
rst = 1;
CMD_I = 0;
START_I = 0;

#500;
rst = 0;
#20000;

CMD_I = `CMD_WR ;
START_I = 1;
#20;
START_I = 0;






end

  
endmodule


