`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:29:00 03/12/2020
// Design Name:   pulse_rst_loop
// Module Name:   C:/project/_ISE_STANDARD_MODULE_/rtl/src/timer/pulse_rst_loop/tb.v
// Project Name:  standard
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: pulse_rst_loop
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_pulse_rst_loop_fhsl;

	// Inputs

	reg CLK_I;
    reg rst;

	// Outputs
	wire PULSE_O;

	// Instantiate the Unit Under Test (UUT)
	pulse_rst_loop_fhsl
        #(.CLK_PERIOD_TIME(20),
          .FIRST_DELAY_TIME(20),
          .HIGH_TIME(20),
          .TOTAL_TIME(40))
    
    
    
	yyyy
	(
		.RST_I(rst), 
		.CLK_I(CLK_I), 
		.PULSE_O(PULSE_O)
	);

	initial begin
		// Initialize Inputs
		CLK_I = 0;
        rst = 1;

		// Wait 100 ns for global reset to finish
		#55;
        rst = 0;
		// Add stimulus here

	end
	
	always #10 CLK_I = ~CLK_I;
      
endmodule

