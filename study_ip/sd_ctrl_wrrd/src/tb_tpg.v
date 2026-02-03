`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/13 16:40:49
// Design Name: 
// Module Name: tb_tpg
//////////////////////////////////////////////////////////////////////////////////
module tb_tpg(

    );
reg clk;
reg rst;
reg vs_align_pulse;
reg de_align_pulse;


wire [15:0] active_h_cnt ;
wire [15:0] active_v_cnt ;



test222   yuuuu(

.pixel_clk (clk),
.vs_align_pos (vs_align_pulse)
);









//tpg_vs_align 
//
//uut(
//.PIXEL_CLK_I(clk),
//.RESETN_I   (~rst),
//.VS_ALIGN   (vs_align_pulse),
//.HS_O       (hs),
//.VS_O       (vs),
//.DE_O       (de),
//.HACTIVE_I  (16), 
//.HFP_I      (4), 
//.HBP_I      (4), 
//.HSYNC_I    (4), 
//.VACTIVE_I  (10), 
//.VFP_I      (2), 
//.VBP_I      (2), 
//.VSYNC_I    (2),
//
//.TOTAL_X_O  (),   //输出-辅助信息(DE_O低时为0)   复位时为0
//.TOTAL_Y_O  (),   //输出-辅助信息(DE_O低时为0)   复位时为0
//.ACTIVE_X_O (active_h_cnt ),   //输出-辅助信息(DE_O低时为0)   复位时为0
//.ACTIVE_Y_O (active_v_cnt )    //输出-辅助信息(DE_O低时为0)   复位时为0  
//
//
//
//
//); 
//



 TPG tggg(
	.vid_clk_in   (clk),
	.sys_rst_n    (~rst), // active low
	.hs_out       (hs_1),
	.vs_out       (vs_1),
	.vid_de       (de_1),
	.hpixel       (50  ), 
	.hfporch      (8   ), 
	.hbporch      (8   ), 
	.hpwidth      (8   ), 
	.vpixel       (50  ), 
	.vfporch      (4   ), 
	.vbporch      (4   ), 
	.vpwidth      (4   ),
	.active_h_cnt (  ),
	.active_v_cnt (  )
  );




    
always #2.5 clk = ~clk;

initial begin
    vs_align_pulse = 0;
    de_align_pulse = 0;
    rst = 0;
    clk = 0;
    #4500;
    rst = 1;
    #20;
    rst = 0;
  
end
  

initial begin
    vs_align_pulse = 0;
    #26150;
    vs_align_pulse = 1;
    #40;
    vs_align_pulse = 0;
    
    #4000;
    //vs_align_pulse = 1;
    #40;
    //vs_align_pulse = 0;
    
end



initial begin
    #28431 ;
    vs_align_pulse = 1;
    #40;
    vs_align_pulse = 0;
    #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
    #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
    #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
    #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
    #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
    #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
    #2000000;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
        #200;
    vs_align_pulse =1;
    #20;
    vs_align_pulse = 0;
    
    

end





initial begin
    de_align_pulse = 0;
    #2777;
    de_align_pulse = 1;
    #10;
    de_align_pulse = 0;
end




endmodule
