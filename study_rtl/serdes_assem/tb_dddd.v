`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/21 17:30:59
// Design Name: 
// Module Name: tb_dddd
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


module tb_dddd(

    );
    
    
//////////////////////////////////////////////////////////////////////////////////

 test  yyy(
.num_in          (6),          //[4:0]  
.bytes_in1       (533),        //[12:0] 
.bytes_in2       (545),        //[12:0] 
.data_in1        (1025),         //[12:0] 
.data_in2        (1025),         //[12:0] 
.strb_out        (),         // [7:0] 
.beats_out       (),        // [9:0] 
.last_num_out    (),     // [6:0] 
.data_align_out1 (), // [15:0]
.data_align_out2 ()  // [15:0]

    );
       
    
    
    
    
    
endmodule
