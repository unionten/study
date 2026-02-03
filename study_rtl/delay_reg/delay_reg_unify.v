`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//in: _____|‾‾‾‾‾‾‾‾|_____
//out:__________|‾‾‾‾‾‾‾‾|_____
//机械延迟--利用寄存器

module delay_reg_unify(
RST_I,
CLK_I,
IN_I,
OUT_O
);
parameter WIDTH = 1;
parameter LEN   = 2;//must > = 1

input RST_I;
input CLK_I;
input  [WIDTH-1:0] IN_I;
output [WIDTH-1:0] OUT_O;

wire [WIDTH-1:0] D [1:LEN+1];//1 ~ LEN+1

genvar i;
generate 
	for(i=1;i<=LEN;i=i+1)begin
		if(LEN>1)begin
			if(i==1)begin
				reg_array_inst_TEJSKFw
					#(.WIDTH(WIDTH))
				reg_inst_array_u
				(   .RST_I(RST_I),
					.CLK_I(CLK_I),
					.IN_I(IN_I),
					.OUT_O(D[2])
				);
			end
			else if(i==LEN)begin
				reg_array_inst_TEJSKFw
					#(.WIDTH(WIDTH))
				reg_inst_array_u
				(   .RST_I(RST_I),
					.CLK_I(CLK_I),
					.IN_I(D[i]),
					.OUT_O(OUT_O)
				);
			end
			else if(i<=LEN-1)begin
				reg_array_inst_TEJSKFw
					#(.WIDTH(WIDTH))
				reg_inst_array_u
				(   .RST_I(RST_I),
					.CLK_I(CLK_I),
					.IN_I(D[i]),
					.OUT_O(D[i+1])
				);
			end
		end
		else if(LEN==1)begin
			reg_array_inst_TEJSKFw
					#(.WIDTH(WIDTH))
				reg_inst_array_u
				(   .RST_I(RST_I),
					.CLK_I(CLK_I),
					.IN_I(IN_I),
					.OUT_O(OUT_O)
				);
		end
			
	end
endgenerate

endmodule


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

/*
reg_array_inst_TEJSKFw
	#(.WIDTH())
	reg_array_inst_u
(
	.CLK_I(),
	.IN_I(),
	.OUT_O()
);
*/

module reg_array_inst_TEJSKFw(
RST_I,
CLK_I,
IN_I,
OUT_O
);
parameter WIDTH = 8;
///////////////////////////////////////////////////////////////////////////////
input RST_I;
input CLK_I;
input [WIDTH-1:0] IN_I;
output [WIDTH-1:0] OUT_O;

reg [WIDTH-1:0] OUT_O;

always@(posedge CLK_I)begin
    if(RST_I)OUT_O <= 0;
	else OUT_O <= IN_I;
end

endmodule
