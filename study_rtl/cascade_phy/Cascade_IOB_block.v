`timescale 1ns / 1ps
module Cascade_IOB_block #(
				parameter IOSTANDARD = "DIFF_HSTL_II_18",
				parameter MODE 			 = "Master",
				parameter REF_FREQ   = 200,
				parameter LINE_NUM   = 10,
				parameter DAT_OUT   = 8,
				parameter DAT_IN    = 1,
				parameter CMD_OUT   = 2,
				parameter CMD_IN    = 2
)(		
	input wire 												i_clk,
	//input 												i_rst,
	input wire[DAT_IN+CMD_IN-1:0]   i_delay_ce,
	input wire[DAT_IN+CMD_IN-1:0]   i_delay_inc,
	input wire[DAT_IN+CMD_IN-1:0]   i_delay_ld,
	input wire[(DAT_IN+CMD_IN)*5-1:0]i_delay_val,
	

	inout  wire [DAT_OUT-1:0] 									b_dat_p,
	inout  wire [DAT_OUT-1:0] 									b_dat_n,
	inout  wire [CMD_OUT-1:0] 									b_cmd_p, 
	inout  wire [CMD_OUT-1:0] 									b_cmd_n,
	
	         					
	input  wire [DAT_OUT-1:0] 								i_dat,
	input  wire [CMD_OUT-1:0] 								i_cmd,
	         					
	output wire[DAT_IN-1:0] 							o_dat,
	output wire[CMD_IN-1:0] 							o_cmd,
	
	input wire [LINE_NUM-1:0] i_tristate_int
	
    );

 


wire [DAT_OUT-1:0] w_dat;
wire [CMD_OUT-1:0] w_cmd;


genvar dat_out;
genvar cmd_out;
generate
for (dat_out = 0; dat_out < DAT_OUT; dat_out = dat_out + 1) begin: dat    
IOBUFDS
      #(.IOSTANDARD (IOSTANDARD))
     iobufds_inst
       (.IO         (b_dat_p			 [dat_out]),
        .IOB        (b_dat_n			 [dat_out]),
        .I          (i_dat 				 [dat_out]),
        .O          (w_dat           [dat_out]),
        .T          (i_tristate_int[dat_out + CMD_OUT]));
end
for (cmd_out = 0; cmd_out < CMD_OUT; cmd_out = cmd_out + 1) begin: cmd    
IOBUFDS
      #(.IOSTANDARD (IOSTANDARD))
     iobufds_inst_1
       (.IO         (b_cmd_p			 [cmd_out]),
        .IOB        (b_cmd_n			 [cmd_out]),
        .I          (i_cmd 				 [cmd_out]),
        .O          (w_cmd         [cmd_out]),
        .T          (i_tristate_int[cmd_out]));
end
endgenerate

//assign w_dat = (MODE=="Master") ? w_m_dat[DAT_IN-1:0] : w_s_dat;
//assign w_cmd = (MODE=="Master") ? w_m_cmd[DAT_IN-1:0] : w_s_cmd;           

genvar dat_in;
genvar cmd_in;
generate
for (dat_in = 0; dat_in < DAT_IN; dat_in = dat_in + 1) begin: dat_input
IDELAYE2 #(
	.REFCLK_FREQUENCY	(REF_FREQ),
	.HIGH_PERFORMANCE_MODE 	("FALSE"),
  .IDELAY_VALUE		(1),
  .DELAY_SRC		("IDATAIN"),
  .IDELAY_TYPE	("VAR_LOAD"))
idelay_dat(               	
	.DATAOUT		(o_dat[dat_in]),
	.C					(i_clk),
	.CE					(i_delay_ce[dat_in +CMD_IN ]),
	.INC				(i_delay_inc[dat_in+CMD_IN]),
	.DATAIN			(1'b0),
	.IDATAIN		(w_dat[dat_in]),
	.LD					(i_delay_ld[dat_in+CMD_IN]),
	.LDPIPEEN		(1'b0),
	.REGRST			(1'b1),
	.CINVCTRL		(1'b0),
	//.CNTVALUEIN	(i_delay_val[dat_in+ CMD_IN]),
	.CNTVALUEIN	(i_delay_val[(dat_in+CMD_IN)*5+4:(dat_in+CMD_IN)*5]),
	.CNTVALUEOUT		());
end
for (cmd_in = 0; cmd_in < CMD_IN; cmd_in = cmd_in + 1) begin: cmd_input
IDELAYE2 #(
	.REFCLK_FREQUENCY	(REF_FREQ),
	.HIGH_PERFORMANCE_MODE 	("FALSE"),
  .IDELAY_VALUE		(1),
  .DELAY_SRC		("IDATAIN"),
  .IDELAY_TYPE		("VAR_LOAD"))
idelay_dat(               	
	.DATAOUT		(o_cmd[cmd_in]),
	.C					(i_clk),
	.CE					(i_delay_ce[cmd_in]),
	.INC				(i_delay_inc[cmd_in]),
	.DATAIN			(1'b0),
	.IDATAIN		(w_cmd[cmd_in]),
	.LD					(i_delay_ld[cmd_in]),
	.LDPIPEEN		(1'b0),
	.REGRST			(1'b1),
	.CINVCTRL		(1'b0),
	//.CNTVALUEIN	(i_delay_val[cmd_in]),
	.CNTVALUEIN	(i_delay_val[cmd_in*5+4:cmd_in*5]),
	.CNTVALUEOUT		());
end
endgenerate	
 

endmodule
