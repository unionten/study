`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Create Date: 2024/01/29 10:38:37
// Design Name: 
// Module Name: bit_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
//////////////////////////////////////////////////////////////////////////////////

module bit_counter(
input  [C_MAX_DATA_WIDTH-1:0]       DATA_I        , // 分成若干级 - 2选1,2选1
input  [$clog2(C_MAX_DATA_WIDTH):0] VALID_WIDTH_I , // 该逻辑 会占据 70个 LUT
output [$clog2(C_MAX_DATA_WIDTH):0] RESULT_O       

);
parameter C_MAX_DATA_WIDTH   = 80; 
//parameter C_REG_NUM = 0; //0 1 2 3 4

//reg = 0时 环出
//reg = 1时，末端加1级
//reg = 2时，中间加1级


genvar i,j,k;


wire [C_MAX_DATA_WIDTH-1:0]  data_in; 
generate for(i=0;i<C_MAX_DATA_WIDTH;i=i+1)begin
    assign data_in[i] = VALID_WIDTH_I>i ? DATA_I[i] : 1'b0 ;
    //assign data_in[i] = DATA_I[i] ;
    
end
endgenerate


wire [$clog2(C_MAX_DATA_WIDTH):0] result [C_MAX_DATA_WIDTH-1:0];

//assign result[i-1]

generate for(i=0;i<C_MAX_DATA_WIDTH;i=i+1)begin
    if(i==0)begin
        assign result[i] = data_in[i];
    end
    else begin
        assign result[i] = result[i-1] + data_in[i];
    end
end   
endgenerate


assign  RESULT_O = result[C_MAX_DATA_WIDTH-1];


endmodule




