`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/18 13:12:39
// Design Name: 
// Module Name: tb_lvds_data_to_rgb
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


module tb_lvds_data_to_rgb();
 
reg  [111:0]  lvds_data;
lvds_data_to_rgb_4lane 
    #(.PIXEL_NUM(4),
      .MODE("JEIDA_RF"))//"VESA_RF" "JEIDA_RF" "JEIDA_RF" "JEIDA_LF"  
      uut(
      .LVDFS_DATA_I(lvds_data)); //uut_name.hs_m[i]
                                                                                                   
initial begin
    lvds_data = 0;
    #500;
    
    lvds_data = 112'h9999999999999999999999999999999;
    #500;


end
    
    
endmodule
