`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  AI
// 
// Create Date: 2024/09/03 09:12:11
// Design Name: 
// Module Name: random_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////

// width = 4 --> generate 0 ~ 2^4-2 
// width = N --> generate 0 ~ 2^N-2 
// width  must >= 2
module random_gen
 #(
    parameter WIDTH = 4  // 数据宽度
) (
    input clk,
    input reset,
    output reg [WIDTH-1:0] random_data = {WIDTH{1'b0}}
);
 
reg [WIDTH-1:0] shift_register = {WIDTH{1'b0}};
 
always @(posedge clk) begin
    if (reset) begin
        shift_register <= {WIDTH{1'b0}};  // 初始化移位寄存器为0
        random_data <= {WIDTH{1'b0}};    // 初始化输出为0
    end
    else begin
        // 移位寄存器左移1位，并在最低位插入前一个状态的 同或 结果
        shift_register <= {shift_register[WIDTH-2:0], ~(shift_register[WIDTH-1] ^ shift_register[0])};
        random_data <= shift_register;   // 输出移位寄存器的当前状态
    end
end
 
 
endmodule 
    
    
    
    

