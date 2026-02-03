

module tpg_phiyo(
	vid_clk_in   ,
	sys_rst_n    , // active low
	hs_out       ,
	vs_out       ,
	vid_de       ,
	hpixel       , 
	hfporch      , 
	hbporch      , 
	hpwidth      , 
	vpixel       , 
	vfporch      , 
	vbporch      , 
	vpwidth      ,
	active_h_cnt ,
	active_v_cnt
  );
input           vid_clk_in;
input           sys_rst_n;
input 	[15:0] 	hpixel;
input 	[15:0] 	hfporch;
input 	[15:0] 	hbporch;
input 	[15:0] 	hpwidth;
input 	[15:0] 	vpixel;
input 	[15:0] 	vfporch;
input 	[15:0] 	vbporch;
input 	[15:0] 	vpwidth;

output          hs_out;
output          vs_out;
output          vid_de;
output  [15:0]  active_h_cnt;
output  [15:0]  active_v_cnt;

// ======================================================
// reg/wire/localparam signal define
// ======================================================
reg     [15:0]   TOTAL_HPIXEL=0;
reg     [15:0]   TOTAL_VPIXEL=0;
reg     [15:0]   TOTAL_HPIXEL_m1=0;
reg     [15:0]   TOTAL_VPIXEL_m1=0;

reg     [15:0]  active_hpxl_cnt=0;

reg     [15:0]  active_vpxl_cnt=0;

reg     [15:0]  active_h_cnt=0;
reg     [15:0]  active_v_cnt=0;

reg     [15:0]  hs_start_0=0;
reg     [15:0]  hs_end_0=0;  
reg     [15:0]  vs_start_0=0;
reg     [15:0]  vs_end_0=0;  

reg             vout_hsync=0;
reg             vout_vsync=0;
reg             data_en=0;

//wire       hs_out;
//wire       vs_out;
reg        vid_de_pf=0;

reg        hs_out=0;
reg        vs_out=0;
reg        vid_de=0;
reg        vid_de_1=0;
//assign hs_out = vout_hsync;
//assign vs_out = vout_vsync;

wire reset_logic_n ;
// ======================================================
// instantiation
// ======================================================
// no

// ======================================================
// RTL
// ======================================================
//参数为0时自复位
assign reset_logic_n = (hpixel == 14'd0 || hfporch == 14'd0 || hbporch == 14'd0 || hpwidth == 14'd0 ||
                     vpixel == 14'd0 || vfporch == 14'd0 || vbporch == 14'd0 || vpwidth == 14'd0 
							) ? 1'b0 : sys_rst_n;


reg [15:0]hbporch_hpwidth=0;
reg [15:0]hbporch_hpwidth_hpixel=0;
reg [15:0]vbporch_vpwidth_1=0;
reg [15:0]vbporch_vpwidth_vpixel_1=0;
reg [15:0]hpixel_hfporch=0;
reg [15:0]vpixel_vfporch=0;
reg [15:0]vbporch_vpwidth=0;

always @(posedge vid_clk_in)
begin 
	hbporch_hpwidth         <=hbporch + hpwidth             ;
  hbporch_hpwidth_hpixel  <=hbporch + hpwidth + hpixel    ;
  vbporch_vpwidth_1       <=vbporch + vpwidth + 1         ;
  vbporch_vpwidth_vpixel_1<=vbporch + vpwidth + vpixel + 1;
  hpixel_hfporch          <=hpixel + hfporch              ;
  vpixel_vfporch          <=vpixel + vfporch              ;
  vbporch_vpwidth         <=vbporch + vpwidth             ;
end 	
	
// -----------------------------------------------
// 
// -----------------------------------------------

reg vout_hsync_ss;
reg vout_vsync_ss;



always @(posedge vid_clk_in)
begin
    vout_hsync_ss <=  vout_hsync;
    vout_vsync_ss <=  vout_vsync;

	hs_out <= vout_hsync_ss;
	vs_out <= vout_vsync_ss;
    
    
    
    
    vid_de_1 <= vid_de_pf;
	vid_de <= vid_de_1;
end

// -----------------------------------------------
// 
// -----------------------------------------------
always @(posedge vid_clk_in)
begin
   if((active_hpxl_cnt > hbporch_hpwidth) & (active_hpxl_cnt <= hbporch_hpwidth_hpixel) & 
			 (active_vpxl_cnt > vbporch_vpwidth_1) & (active_vpxl_cnt <= vbporch_vpwidth_vpixel_1))
	   begin
		  vid_de_pf <= 1;
		  active_h_cnt <= active_h_cnt + 1;
	   end
	else
		begin
		  vid_de_pf <= 0;
		  active_h_cnt <= 0;
		end
end  

// -----------------------------------------------
// 
// -----------------------------------------------
always @(posedge vid_clk_in)
begin
   if((active_vpxl_cnt > vbporch_vpwidth_1) & (active_vpxl_cnt <= vbporch_vpwidth_vpixel_1))
	  begin
		 if(active_hpxl_cnt == 1)
			 active_v_cnt <= active_v_cnt + 1;
	  end
	else
	  begin
		 active_v_cnt <= 0;
	  end
end

// -----------------------------------------------
// 
// -----------------------------------------------
always @ (posedge vid_clk_in)
begin
	hs_start_0 <= 16'd1;
	hs_end_0   <= hpwidth + 1;
	vs_start_0 <= 16'd1;
	vs_end_0   <= vpwidth + 16'd1;
end

// -----------------------------------------------
// 
// -----------------------------------------------
always @(posedge  vid_clk_in)
begin
   TOTAL_HPIXEL <= (hpixel_hfporch) + (hbporch_hpwidth);
   TOTAL_VPIXEL <= (vpixel_vfporch) + (vbporch_vpwidth);
   TOTAL_HPIXEL_m1 <= TOTAL_HPIXEL - 1'b1;
   TOTAL_VPIXEL_m1 <= TOTAL_VPIXEL - 1'b1;
end

// -----------------------------------------------
// vpxl
// -----------------------------------------------
always @(posedge vid_clk_in or negedge reset_logic_n) 
begin
   if (reset_logic_n == 1'b0) 
       begin
   		active_vpxl_cnt <= 16'd1;
   	 end
   else
	  begin 
		 if (active_hpxl_cnt == 16'd1) 
			 begin
				if (active_vpxl_cnt < TOTAL_VPIXEL) 
					 begin
							active_vpxl_cnt <= active_vpxl_cnt + 1'b1;	
					 end
				else 
					 begin
							active_vpxl_cnt <= 16'd1;
					 end
		    end
	  end	
end     

// -----------------------------------------------
// hpxl
// -----------------------------------------------
always @(posedge vid_clk_in or negedge reset_logic_n)
begin
    if(reset_logic_n == 1'b0)
	       begin
	       	   active_hpxl_cnt <= 16'd1;
	       end
	   else if(active_hpxl_cnt == TOTAL_HPIXEL)
	       begin
	       	   active_hpxl_cnt <= 16'd1;
	       end
	   else
	       begin
	       	   active_hpxl_cnt <= active_hpxl_cnt + 16'd1;
	       end
end  

// -----------------------------------------------
// hs
// -----------------------------------------------	      	  
always @ (posedge vid_clk_in or negedge reset_logic_n)
begin
	 if(reset_logic_n == 1'b0)
        vout_hsync <= 1'b0;  
    else if(active_hpxl_cnt == hs_start_0)
        vout_hsync <= 1'b1;
    else if(active_hpxl_cnt == hs_end_0)
        vout_hsync <= 1'b0;
    else
        vout_hsync <= vout_hsync;		  
end

// -----------------------------------------------
// vs
// -----------------------------------------------
always @ (posedge vid_clk_in or negedge reset_logic_n)
begin
	 if(reset_logic_n == 1'b0)
        vout_vsync <= 1'b0;  
    else if((active_vpxl_cnt == vs_start_0) && (active_hpxl_cnt == hs_start_0))
        vout_vsync <= 1'b1;
    else if((active_vpxl_cnt == vs_end_0) && (active_hpxl_cnt == hs_start_0))
        vout_vsync <= 1'b0;
    else
        vout_vsync <= vout_vsync;		  
end  


endmodule

