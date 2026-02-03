module ascii2hex( 
    input  wire [7:0] ascii,  // 4-bit input hex (0-F)  
    output reg  [3:0] hex     // 8-bit ASCII output  
);  
  
always @(*) begin  
    case(ascii)  

        8'h30 : hex = 4'b0000 ;  // '0'  
        8'h31 : hex = 4'b0001 ;  // '1'  
        8'h32 : hex = 4'b0010 ;  // '2'  
        8'h33 : hex = 4'b0011 ;  // '3'  
        8'h34 : hex = 4'b0100 ;  // '4'  
        8'h35 : hex = 4'b0101 ;  // '5'  
        8'h36 : hex = 4'b0110 ;  // '6'  
        8'h37 : hex = 4'b0111 ;  // '7'  
        8'h38 : hex = 4'b1000 ;  // '8'  
        8'h39 : hex = 4'b1001 ;  // '9'  

        8'd65: hex = 4'hA;
        8'd66: hex = 4'hB;
        8'd67: hex = 4'hC;
        8'd68: hex = 4'hD;
        8'd69: hex = 4'hE; 
        8'd70: hex = 4'hF;
        
        8'd97:  hex = 4'hA;
        8'd98:  hex = 4'hB;
        8'd99:  hex = 4'hC;
        8'd100: hex = 4'hD;
        8'd101: hex = 4'hE; 
        8'd102: hex = 4'hF;
        

        
       
        default: hex = 8'h00;  // Invalid input  
    endcase  
end  


endmodule