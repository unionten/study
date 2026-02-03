`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:58:45 05/14/2019
// Design Name:   uart_tx_wrapper
// Module Name:   C:/project/_ISE_STANDARD_MODULE_/rtl/src/uart_tx_wrapper/tb_uart_tx_wrapper.v
// Project Name:  standard
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: uart_tx_wrapper
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_uart_tx_wrapper;

	// Inputs
	reg CLK_I;
	reg RST_I;
	reg [8*8-1:0] DATA_I;
	reg START_I;

	// Outputs
	wire SDATA_O;
	wire FINISH_O;
	
	// Instantiate the Unit Under Test (UUT)
	uart_tx_wrapper 
		#(
        .SYS_CLK_PERIOD (20), 
        .BAUD_RATE( 1152000 ),
        .BYTE_NUM(8),
        .FINISH_PERIOD_NUM(20)   
          
          
		)
		uart_tx_wrapper_inst (
		.CLK_I(CLK_I), 
		.RST_I(RST_I), 
		.DATA_I(DATA_I), 
		.START_I(START_I), 
		.SDATA_O(SDATA_O),
		.FINISH_O(FINISH_O)
	);

	initial begin
		// Initialize Inputs
		CLK_I = 0;
		RST_I = 1;
		DATA_I = 0;
		START_I = 0;
        
        #300;
        RST_I = 0;


		#(3000);
        
		DATA_I = 88'hAABBCCDD11223344556677;
		START_I = 1;
		#20;
		START_I = 0;
		
		// #(6500000);
		// DATA_I = 88'h1122334455AABBCCDD6677;
		// START_I = 1;
		// #20;
		// START_I = 0;
		
		#(6500000);
		$stop;

	end
	
	always #10 CLK_I = ~CLK_I;
      
endmodule

