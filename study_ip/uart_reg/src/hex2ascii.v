module hex2ascii( 
    input  wire [3:0] hex,  // 4-bit input hex (0-F)  
    output reg  [7:0] ascii  // 8-bit ASCII output  
);  
  
always @(*) begin  
    case(hex)  
        4'b0000: ascii = 8'h30;  // '0'  
        4'b0001: ascii = 8'h31;  // '1'  
        4'b0010: ascii = 8'h32;  // '2'  
        4'b0011: ascii = 8'h33;  // '3'  
        4'b0100: ascii = 8'h34;  // '4'  
        4'b0101: ascii = 8'h35;  // '5'  
        4'b0110: ascii = 8'h36;  // '6'  
        4'b0111: ascii = 8'h37;  // '7'  
        4'b1000: ascii = 8'h38;  // '8'  
        4'b1001: ascii = 8'h39;  // '9'  
        10: ascii = 8'h41; // 'A'  
        11: ascii = 8'h42; // 'B'  
        12: ascii = 8'h43; // 'C'  
        13: ascii = 8'h44; // 'D'  
        14: ascii = 8'h45; // 'E'  
        15: ascii = 8'h46; // 'F' 
        default: ascii = 8'h00;  // Invalid input  
    endcase  
end  


endmodule