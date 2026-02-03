`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//in: _____|‾‾‾‾‾‾‾‾|_____
//out:__________|‾‾‾‾‾‾‾‾|_____
//机械延迟--利用寄存器
//out格式：最新打入 ...... 最先打入
module delay_reg_en_unify(
CLK_I,
IN_I,
OUT_NEW2OLD_O,
);
parameter WIDTH = 1;
parameter LEN   = 2;//must > = 1

input CLK_I;
input  [WIDTH-1:0]     IN_I;
output [WIDTH*LEN-1:0] OUT_NEW2OLD_O;

wire [WIDTH-1:0] D [1:LEN+1];//1 ~ LEN+1

genvar i;
//IN -reg1- D2 -reg2- D3 -... D LEN   -regLEN-  OUT(D LEN+1)
generate 
    for(i=0;i<LEN;i=i+1)begin
        assign OUT_NEW2OLD_O[WIDTH*i+:WIDTH] = D[LEN+1-i]; 
    end
endgenerate

generate 
	for(i=1;i<=LEN;i=i+1)begin:loop2//LEN个reg
		if(LEN>1)begin
			if(i==1)begin
				reg_array_inst_THPFDFOSJ
					#(.WIDTH(WIDTH))
				reg_inst_array_u
				(
					.CLK_I(CLK_I),
					.IN_I(IN_I),
					.OUT_O(D[2])
				);
			end
			else if(i==LEN)begin
				reg_array_inst_THPFDFOSJ
					#(.WIDTH(WIDTH))
				reg_inst_array_u
				(
					.CLK_I(CLK_I),
					.IN_I(D[i]),
					.OUT_O(D[i+1])
				);
			end
			else if(i<=LEN-1)begin
				reg_array_inst_THPFDFOSJ
					#(.WIDTH(WIDTH))
				reg_inst_array_u
				(
					.CLK_I(CLK_I),
					.IN_I(D[i]),
					.OUT_O(D[i+1])
				);
			end
		end
		else if(LEN==1)begin
			reg_array_inst_THPFDFOSJ
					#(.WIDTH(WIDTH))
				reg_inst_array_u
				(
					.CLK_I(CLK_I),
					.IN_I(IN_I),
					.OUT_O(D[i+1])
				);
		end
			
	end
endgenerate

endmodule


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module reg_array_inst_THPFDFOSJ(
CLK_I,
IN_I,
OUT_O
);
parameter WIDTH = 8;
///////////////////////////////////////////////////////////////////////////////
input CLK_I;
input [WIDTH-1:0] IN_I;
output [WIDTH-1:0] OUT_O;

reg [WIDTH-1:0] OUT_O = 0;

always@(posedge CLK_I)begin
	OUT_O <= IN_I;
end

endmodule


