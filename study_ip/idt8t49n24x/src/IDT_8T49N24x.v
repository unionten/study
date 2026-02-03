

`timescale 1ns / 1ps
module IDT_8T49N24x#(
parameter	 CLK_DIV  = 16'd999 ,
parameter [0:0] ILA_ENABLE  =  0 
)
( 
input        		 clk_i				,
input        		 rst_n				,

input 	[7:0]        q1_lnk_rate  ,
input 				 i_q1_phy_rst	,
output reg 			 q1_cfg_done	,
input   [7:0]		 q0_lnk_rate  ,
input  					 i_q0_phy_rst ,
output reg  		 q0_cfg_done	,
 								
input						 sda_i		 ,
output					 sda_o		 ,
output 					 iic_scl_o ,
output reg			 init_done ,

output reg   		 cfg_done
);


 parameter   DEVID   				 =  8'hF8; 
 


(*keep="true"*)reg q1_phy_rst_reg;
(*keep="true"*)reg q1_phy_rst   ;

always @(posedge clk_i) q1_phy_rst_reg <= i_q1_phy_rst;
always @(posedge clk_i) q1_phy_rst <= (TS_S==4) ? 1'b0 : q1_phy_rst ? 1'b1 : ((q1_phy_rst_reg)  & !i_q1_phy_rst);

(*keep="true"*)reg q0_phy_rst_reg;
(*keep="true"*)reg q0_phy_rst    ;

always @(posedge clk_i) q0_phy_rst_reg <= i_q0_phy_rst;
always @(posedge clk_i) q0_phy_rst <= (TS_S==8) ? 1'b0 : q0_phy_rst ? 1'b1 : ((q0_phy_rst_reg)  & !i_q0_phy_rst);
//if(rx_cfg_done) rx_phy_rst <= 1'b0;
//else 
	




reg  [8 :0] rst_cnt = 9'd0;
always@(posedge clk_i) begin
    if(!rst_n)
        rst_cnt <= 9'd0;
    else if(!rst_cnt[8]) 
        rst_cnt <= rst_cnt + 1'b1;
end

(*keep="true"*)reg  iic_en;
(*keep="true"*)wire iic_busy;   
(*keep="true"*)reg  [71:0] wr_data;
(*keep="true"*)reg  [3 :0] TS_S = 4'd0;
(*keep="true"*)reg  [8 :0] byte_cnt = 9'd0;
(*keep="true"*)reg  [23:0] REG_DATA;

(*keep="true"*)reg  [23:0] Q0_DATA;
(*keep="true"*)reg  [23:0] Q1_DATA;
(*keep="true"*)reg  [63:0] REG_DATA_1;
(*keep="true"*)wire [9 :0] REG_SIZE;
(*keep="true"*)reg  [9 :0] REG_INDEX;
(*keep="true"*)wire [9 :0] RECFG_INDEX; 


wire  [7:0] wr_cnt = 4;

uii2c#
(
.WMEN_LEN(9),
.RMEN_LEN(1),
.CLK_DIV(CLK_DIV)//499 for 50M 999 for 100M
)
uii2c_inst
(
.clk_i(clk_i),
//.iic_scl(SCL),
//.iic_sda(SDA),
.sda_i		 (sda_i),
.sda_o		 (sda_o),
.iic_scl_o (iic_scl_o),

.wr_data(wr_data),
.wr_cnt(wr_cnt),//write data max len = 4BYTES
.rd_data(),   //read not used
.rd_cnt(8'd0),//read not used
.iic_mode(1'b0),
.iic_en(iic_en),
.iic_busy(iic_busy)
); 


always@(posedge clk_i)
if(!rst_n) init_done   <= 1'b0;
else if((TS_S==3)&((REG_INDEX == REG_SIZE))) init_done <= 1'b1;
	

assign	REG_SIZE = 791; 
assign RECFG_INDEX = 2;
//state machine write one byte and then read one byte
always@(posedge clk_i) begin
    if((!rst_cnt[8]))begin
        REG_INDEX   <= 9'd0;
        iic_en  	  <= 1'b0;
        wr_data 	  <= 32'd0;
        cfg_done    <= 1'b0;
				q1_cfg_done <= 1'b0;
				q0_cfg_done <= 1'b0;
        TS_S        <= 4'd0;    
    end
    else begin
        case(TS_S)
        0:if(cfg_done == 1'b0)begin 
						
						
            TS_S <= 2'd1;			
					end 	
        1:if(!iic_busy)begin//write data
            iic_en  <= 1'b1; 
						wr_data[7  :0] <= DEVID ;	
						wr_data[15 :8] <= REG_DATA[15:8];   
						wr_data[23:16] <= REG_DATA[7: 0];   
						wr_data[31:24] <= REG_DATA[23 : 16];
        end
        else 
            TS_S    <= 2'd2;
        2:begin
            iic_en  <= 1'b0; 
            if(!iic_busy)begin 
							REG_INDEX<= REG_INDEX + 1'b1;
							TS_S    <= 2'd3;
            end
        end
        3:begin
            if(REG_INDEX == REG_SIZE)begin	
						TS_S      <= q1_phy_rst ? 4'd4 : q0_phy_rst ? 4'd8 : 4'd3;
						cfg_done  <= q1_phy_rst ? 1'd0 : q0_phy_rst ? 1'd0 : 1'b1;
						
						
						REG_INDEX <= q1_phy_rst ? 0 : q0_phy_rst ? 0 : REG_INDEX;
						end else
						TS_S 	<= 2'd0;
        end 
				
				 4://if(cfg_done == 1'b0)begin 
						
						
            TS_S 			<= 5;			
					//end 	
        5:if(!iic_busy)begin//write data
            iic_en  <= 1'b1; 
						wr_data[7  :0] <= DEVID ;	
						wr_data[15 :8] <= Q1_DATA[15:8];   
						wr_data[23:16] <= Q1_DATA[7: 0];   
						wr_data[31:24] <= Q1_DATA[23 : 16];
        end
        else 
            TS_S    <= 6;
        6:begin
            iic_en  <= 1'b0; 
            if(!iic_busy)begin 
							REG_INDEX<= REG_INDEX + 1'b1;
							TS_S    <= 7;
            end
        end
        7:begin
            if(REG_INDEX == RECFG_INDEX)begin	
						TS_S        <= q1_phy_rst ? 4'd4 : q0_phy_rst ? 4'd8 : 4'd11;
						cfg_done    <= q1_phy_rst ? 1'd0 : q0_phy_rst ? 1'd0 : 1'b1;
						q1_cfg_done <= i_q1_phy_rst ? 1'd0 : 1'd1;						
						q0_cfg_done <= i_q0_phy_rst? 1'd0 : q0_cfg_done;
						
						REG_INDEX        <= q1_phy_rst ? 0 : q0_phy_rst ? 0 : REG_INDEX;
					end else 
						TS_S 	<= 4;
        end 
				
					 8://if(cfg_done == 1'b0)begin 
						
						
            TS_S 			<= 9;			
					//end 	
        9:if(!iic_busy)begin//write data
            iic_en  <= 1'b1; 
						wr_data[7  :0] <= DEVID ;	
						wr_data[15 :8] <= Q0_DATA[15:8];   
						wr_data[23:16] <= Q0_DATA[7: 0];   
						wr_data[31:24] <= Q0_DATA[23 : 16];
        end
        else 
            TS_S    <= 10;
        10:begin
            iic_en  <= 1'b0; 
            if(!iic_busy)begin 
							REG_INDEX<= REG_INDEX + 1'b1;
								TS_S    <= 11;
							
            end
						
        end
        11:begin
            if(REG_INDEX == RECFG_INDEX)begin	
						TS_S        <= q1_phy_rst ? 4'd4 : q0_phy_rst ? 4'd8 : 4'd11;
						cfg_done    <= q1_phy_rst ? 1'd0 : q0_phy_rst ? 1'd0 : 1'b1;
						q1_cfg_done <= i_q1_phy_rst ? 1'd0 : q1_cfg_done;
						q0_cfg_done <= i_q0_phy_rst ? 1'd0 : 1'd1;
						REG_INDEX   <= q1_phy_rst ? 0 : q0_phy_rst ? 0 : REG_INDEX;	
					end else 
						TS_S 	<= 8;
        end 
				
				
    endcase
   end
end

////Q0 RX
//always@(*)
//case(REG_INDEX)
// 0 : Q0_DATA <= 24'h0E0039;
// 1 : Q0_DATA <= (q0_lnk_rate==8'd30) ? 24'h02003F : (q0_lnk_rate==8'd20) ? 24'h01003F : (q0_lnk_rate==8'd10) ?  24'h01003F : 24'h00003F;
// 2 : Q0_DATA <= (q0_lnk_rate==8'd30) ? 24'h010041 : (q0_lnk_rate==8'd20) ? 24'h010041 : (q0_lnk_rate==8'd10) ?  24'h020041 : 24'h040041;
// 3 : Q0_DATA <= 24'h0F0039;
//default:;
//endcase 
//
////Q1 RX
//always@(*)
//case(REG_INDEX)
// 0 : Q1_DATA <= 24'h0B0039;
// 1 : Q1_DATA <= (q1_lnk_rate==8'd30) ? 24'h000045 : (q1_lnk_rate==8'd20) ? 24'h000045 : (q1_lnk_rate==8'd10) ?  24'h000045 : 24'h000045;
// 2 : Q1_DATA <= (q1_lnk_rate==8'd30) ? 24'h040047 : (q1_lnk_rate==8'd20) ? 24'h060047 : (q1_lnk_rate==8'd10) ?  24'h0C0047 : 24'h140047;
// 3 : Q1_DATA <= 24'h0F0039;
//default:;
//endcase 

//Q0 RX
always@(*)
case(REG_INDEX)
 0 : Q0_DATA <= (q0_lnk_rate==8'd30) ? 24'h02003F : (q0_lnk_rate==8'd20) ? 24'h01003F : (q0_lnk_rate==8'd10) ?  24'h01003F : (q0_lnk_rate==8'd06) ? 24'h00003F : 24'h01003F;
 1 : Q0_DATA <= (q0_lnk_rate==8'd30) ? 24'h010041 : (q0_lnk_rate==8'd20) ? 24'h010041 : (q0_lnk_rate==8'd10) ?  24'h020041 : (q0_lnk_rate==8'd06) ? 24'h040041 : 24'h010041;
default:;                                                                                                                                                      
endcase                                                                                                                                                        
                                                                                                                                                               
//Q1 RX                                                                                                                                                        
always@(*)                                                                                                                                                     
case(REG_INDEX)                                                                                                                                                
 0 : Q1_DATA <= (q1_lnk_rate==8'd30) ? 24'h000045 : (q1_lnk_rate==8'd20) ? 24'h000045 : (q1_lnk_rate==8'd10) ?  24'h000045 : (q0_lnk_rate==8'd06) ? 24'h000045 : 24'h000045;
 1 : Q1_DATA <= (q1_lnk_rate==8'd30) ? 24'h040047 : (q1_lnk_rate==8'd20) ? 24'h060047 : (q1_lnk_rate==8'd10) ?  24'h0C0047 : (q0_lnk_rate==8'd06) ? 24'h140047 : 24'h060047;

default:;
endcase 


always@(*)
case(REG_INDEX)
 00*10+0 : REG_DATA <= 24'h090000;
 00*10+1 : REG_DATA <= 24'h500001;
 00*10+2 : REG_DATA <= 24'h000002;
 00*10+3 : REG_DATA <= 24'h600003;
 00*10+4 : REG_DATA <= 24'h600004;
 00*10+5 : REG_DATA <= 24'h010005;
 00*10+6 : REG_DATA <= 24'h7c0006;
 00*10+7 : REG_DATA <= 24'h010007;
 00*10+8 : REG_DATA <= 24'h030008;
 00*10+9 : REG_DATA <= 24'h000009;
 01*10+0 : REG_DATA <= 24'h31000A;
 01*10+1 : REG_DATA <= 24'h00000B;
 01*10+2 : REG_DATA <= 24'h00000C;
 01*10+3 : REG_DATA <= 24'h01000D;
 01*10+4 : REG_DATA <= 24'h00000E;
 01*10+5 : REG_DATA <= 24'h00000F;
 01*10+6 : REG_DATA <= 24'h010010;
 01*10+7 : REG_DATA <= 24'h070011;
 01*10+8 : REG_DATA <= 24'h000012;
 01*10+9 : REG_DATA <= 24'h000013;
 02*10+0 : REG_DATA <= 24'h070014;
 02*10+1 : REG_DATA <= 24'h000015;
 02*10+2 : REG_DATA <= 24'h000016;
 02*10+3 : REG_DATA <= 24'h770017;
 02*10+4 : REG_DATA <= 24'h6d0018;
 02*10+5 : REG_DATA <= 24'h000019;
 02*10+6 : REG_DATA <= 24'h00001A;
 02*10+7 : REG_DATA <= 24'h00001B;
 02*10+8 : REG_DATA <= 24'h00001C;
 02*10+9 : REG_DATA <= 24'h00001D;
 03*10+0 : REG_DATA <= 24'h00001E;
 03*10+1 : REG_DATA <= 24'hff001F;
 03*10+2 : REG_DATA <= 24'hff0020;
 03*10+3 : REG_DATA <= 24'hff0021;
 03*10+4 : REG_DATA <= 24'hff0022;
 03*10+5 : REG_DATA <= 24'h030023;
 03*10+6 : REG_DATA <= 24'h3f0024;
 03*10+7 : REG_DATA <= 24'h000025;
 03*10+8 : REG_DATA <= 24'h290026;
 03*10+9 : REG_DATA <= 24'h000027;
 04*10+0 : REG_DATA <= 24'h150028;
 04*10+1 : REG_DATA <= 24'h0f0029;
 04*10+2 : REG_DATA <= 24'h1d002A;
 04*10+3 : REG_DATA <= 24'h00002B;
 04*10+4 : REG_DATA <= 24'h01002C;
 04*10+5 : REG_DATA <= 24'h00002D;
 04*10+6 : REG_DATA <= 24'h00002E;
 04*10+7 : REG_DATA <= 24'hd0002F;
 04*10+8 : REG_DATA <= 24'h000030;
 04*10+9 : REG_DATA <= 24'h000031;
 05*10+0 : REG_DATA <= 24'h000032;
 05*10+1 : REG_DATA <= 24'h000033;
 05*10+2 : REG_DATA <= 24'h000034;
 05*10+3 : REG_DATA <= 24'h000035;
 05*10+4 : REG_DATA <= 24'h080036;
 05*10+5 : REG_DATA <= 24'h000037;
 05*10+6 : REG_DATA <= 24'h000038;
 05*10+7 : REG_DATA <= 24'h0f0039;
 05*10+8 : REG_DATA <= 24'h00003A;
 05*10+9 : REG_DATA <= 24'h00003B;
 06*10+0 : REG_DATA <= 24'h00003C;
 06*10+1 : REG_DATA <= 24'h44003D;
 06*10+2 : REG_DATA <= 24'h44003E;
 
 // 06*10+3 : REG_DATA <= 24'h02003F;
 // 06*10+4 : REG_DATA <= 24'h000040;
 // 06*10+5 : REG_DATA <= 24'h010041;
  
  //06*10+3 : REG_DATA <= 24'h01003F; //270M
  //06*10+4 : REG_DATA <= 24'h000040;
  //06*10+5 : REG_DATA <= 24'h010041;
  
  
  06*10+3 : REG_DATA <= 24'h01003F; //135M
  06*10+4 : REG_DATA <= 24'h000040;
  06*10+5 : REG_DATA <= 24'h020041;
  

 06*10+6 : REG_DATA <= 24'h000042;
 06*10+7 : REG_DATA <= 24'h000043;
 06*10+8 : REG_DATA <= 24'h060044;
 06*10+9 : REG_DATA <= 24'h000045;
 07*10+0 : REG_DATA <= 24'h000046;
 07*10+1 : REG_DATA <= 24'h060047;
 
 
 //06*10+9 : REG_DATA <= 24'h000045;
 //07*10+0 : REG_DATA <= 24'h000046;
 //07*10+1 : REG_DATA <= 24'h040047;
 
 
 
 
 
 07*10+2 : REG_DATA <= 24'h000048;
 07*10+3 : REG_DATA <= 24'h000049;
 07*10+4 : REG_DATA <= 24'h06004A;
 07*10+5 : REG_DATA <= 24'h00004B;
 07*10+6 : REG_DATA <= 24'h00004C;
 07*10+7 : REG_DATA <= 24'h00004D;
 07*10+8 : REG_DATA <= 24'h00004E;
 07*10+9 : REG_DATA <= 24'h00004F;
 08*10+0 : REG_DATA <= 24'h000050;
 08*10+1 : REG_DATA <= 24'h000051;
 08*10+2 : REG_DATA <= 24'h000052;
 08*10+3 : REG_DATA <= 24'h000053;
 08*10+4 : REG_DATA <= 24'h000054;
 08*10+5 : REG_DATA <= 24'h000055;
 08*10+6 : REG_DATA <= 24'h000056;
 08*10+7 : REG_DATA <= 24'h000057;
 08*10+8 : REG_DATA <= 24'h000058;
 08*10+9 : REG_DATA <= 24'h000059;
 09*10+0 : REG_DATA <= 24'h00005A;
 09*10+1 : REG_DATA <= 24'h00005B;
 09*10+2 : REG_DATA <= 24'h00005C;
 09*10+3 : REG_DATA <= 24'h00005D;
 09*10+4 : REG_DATA <= 24'h00005E;
 09*10+5 : REG_DATA <= 24'h00005F;
 09*10+6 : REG_DATA <= 24'h000060;
 09*10+7 : REG_DATA <= 24'h000061;
 09*10+8 : REG_DATA <= 24'h000062;
 09*10+9 : REG_DATA <= 24'h000063;
 10*10+0 : REG_DATA <= 24'h000064;
 10*10+1 : REG_DATA <= 24'h000065;
 10*10+2 : REG_DATA <= 24'h000066;
 10*10+3 : REG_DATA <= 24'h000067;
 10*10+4 : REG_DATA <= 24'he60068;
 10*10+5 : REG_DATA <= 24'h0a0069;
 10*10+6 : REG_DATA <= 24'h2b006A;
 10*10+7 : REG_DATA <= 24'h20006B;
 10*10+8 : REG_DATA <= 24'h00006C;
 10*10+9 : REG_DATA <= 24'h00006D;
 11*10+0 : REG_DATA <= 24'h00006E;
 11*10+1 : REG_DATA <= 24'h00006F;
 11*10+2 : REG_DATA <= 24'h000070;
 11*10+3 : REG_DATA <= 24'h000071;
 11*10+4 : REG_DATA <= 24'h000072;
 11*10+5 : REG_DATA <= 24'h000073;
 11*10+6 : REG_DATA <= 24'h000074;
 11*10+7 : REG_DATA <= 24'h000075;
 11*10+8 : REG_DATA <= 24'h000076;
 11*10+9 : REG_DATA <= 24'h000077;
 12*10+0 : REG_DATA <= 24'h000078;
 12*10+1 : REG_DATA <= 24'h000079;
 12*10+2 : REG_DATA <= 24'h27007A;
 12*10+3 : REG_DATA <= 24'hcc007B;
 12*10+4 : REG_DATA <= 24'h00007C;
 12*10+5 : REG_DATA <= 24'h00007D;
 12*10+6 : REG_DATA <= 24'h00007E;
 12*10+7 : REG_DATA <= 24'h00007F;
 12*10+8 : REG_DATA <= 24'h000080;
 12*10+9 : REG_DATA <= 24'h000081;
 13*10+0 : REG_DATA <= 24'h000082;
 13*10+1 : REG_DATA <= 24'h000083;
 13*10+2 : REG_DATA <= 24'h000084;
 13*10+3 : REG_DATA <= 24'h000085;
 13*10+4 : REG_DATA <= 24'h000086;
 13*10+5 : REG_DATA <= 24'h000087;
 13*10+6 : REG_DATA <= 24'h000088;
 13*10+7 : REG_DATA <= 24'h000089;
 13*10+8 : REG_DATA <= 24'h00008A;
 13*10+9 : REG_DATA <= 24'h00008B;
 14*10+0 : REG_DATA <= 24'h00008C;
 14*10+1 : REG_DATA <= 24'h00008D;
 14*10+2 : REG_DATA <= 24'h00008E;
 14*10+3 : REG_DATA <= 24'h00008F;
 14*10+4 : REG_DATA <= 24'h000090;
 14*10+5 : REG_DATA <= 24'h000091;
 14*10+6 : REG_DATA <= 24'h000092;
 14*10+7 : REG_DATA <= 24'h000093;
 14*10+8 : REG_DATA <= 24'h000094;
 14*10+9 : REG_DATA <= 24'h000095;
 15*10+0 : REG_DATA <= 24'h000096;
 15*10+1 : REG_DATA <= 24'h000097;
 15*10+2 : REG_DATA <= 24'h000098;
 15*10+3 : REG_DATA <= 24'h000099;
 15*10+4 : REG_DATA <= 24'h00009A;
 15*10+5 : REG_DATA <= 24'h00009B;
 15*10+6 : REG_DATA <= 24'h00009C;
 15*10+7 : REG_DATA <= 24'h00009D;
 15*10+8 : REG_DATA <= 24'h00009E;
 15*10+9 : REG_DATA <= 24'h00009F;
 16*10+0 : REG_DATA <= 24'h0000A0;
 16*10+1 : REG_DATA <= 24'h0000A1;
 16*10+2 : REG_DATA <= 24'h0000A2;
 16*10+3 : REG_DATA <= 24'h0000A3;
 16*10+4 : REG_DATA <= 24'h0000A4;
 16*10+5 : REG_DATA <= 24'h0000A5;
 16*10+6 : REG_DATA <= 24'h0000A6;
 16*10+7 : REG_DATA <= 24'h0000A7;
 16*10+8 : REG_DATA <= 24'h0000A8;
 16*10+9 : REG_DATA <= 24'h0000A9;
 17*10+0 : REG_DATA <= 24'h0000AA;
 17*10+1 : REG_DATA <= 24'h0000AB;
 17*10+2 : REG_DATA <= 24'h0000AC;
 17*10+3 : REG_DATA <= 24'h0000AD;
 17*10+4 : REG_DATA <= 24'h0000AE;
 17*10+5 : REG_DATA <= 24'h0000AF;
 17*10+6 : REG_DATA <= 24'h0000B0;
 17*10+7 : REG_DATA <= 24'h0000B1;
 17*10+8 : REG_DATA <= 24'h0000B2;
 17*10+9 : REG_DATA <= 24'h0000B3;
 18*10+0 : REG_DATA <= 24'h0000B4;
 18*10+1 : REG_DATA <= 24'h0000B5;
 18*10+2 : REG_DATA <= 24'h0000B6;
 18*10+3 : REG_DATA <= 24'h0000B7;
 18*10+4 : REG_DATA <= 24'h0000B8;
 18*10+5 : REG_DATA <= 24'h0000B9;
 18*10+6 : REG_DATA <= 24'h0000BA;
 18*10+7 : REG_DATA <= 24'h0000BB;
 18*10+8 : REG_DATA <= 24'h0000BC;
 18*10+9 : REG_DATA <= 24'h0000BD;
 19*10+0 : REG_DATA <= 24'h0000BE;
 19*10+1 : REG_DATA <= 24'h0000BF;
 19*10+2 : REG_DATA <= 24'h0000C0;
 19*10+3 : REG_DATA <= 24'h0000C1;
 19*10+4 : REG_DATA <= 24'h0000C2;
 19*10+5 : REG_DATA <= 24'h0000C3;
 19*10+6 : REG_DATA <= 24'h0000C4;
 19*10+7 : REG_DATA <= 24'h0000C5;
 19*10+8 : REG_DATA <= 24'h0000C6;
 19*10+9 : REG_DATA <= 24'h0000C7;
 20*10+0 : REG_DATA <= 24'h0000C8;
 20*10+1 : REG_DATA <= 24'h0000C9;
 20*10+2 : REG_DATA <= 24'h0000CA;
 20*10+3 : REG_DATA <= 24'h0000CB;
 20*10+4 : REG_DATA <= 24'h0000CC;
 20*10+5 : REG_DATA <= 24'h0000CD;
 20*10+6 : REG_DATA <= 24'h0000CE;
 20*10+7 : REG_DATA <= 24'h0000CF;
 20*10+8 : REG_DATA <= 24'h0000D0;
 20*10+9 : REG_DATA <= 24'h0000D1;
 21*10+0 : REG_DATA <= 24'h0000D2;
 21*10+1 : REG_DATA <= 24'h0000D3;
 21*10+2 : REG_DATA <= 24'h0000D4;
 21*10+3 : REG_DATA <= 24'h0000D5;
 21*10+4 : REG_DATA <= 24'h0000D6;
 21*10+5 : REG_DATA <= 24'h0000D7;
 21*10+6 : REG_DATA <= 24'h0000D8;
 21*10+7 : REG_DATA <= 24'h0000D9;
 21*10+8 : REG_DATA <= 24'h0000DA;
 21*10+9 : REG_DATA <= 24'h0000DB;
 22*10+0 : REG_DATA <= 24'h0000DC;
 22*10+1 : REG_DATA <= 24'h0000DD;
 22*10+2 : REG_DATA <= 24'h0000DE;
 22*10+3 : REG_DATA <= 24'h0000DF;
 22*10+4 : REG_DATA <= 24'h0000E0;
 22*10+5 : REG_DATA <= 24'h0000E1;
 22*10+6 : REG_DATA <= 24'h0000E2;
 22*10+7 : REG_DATA <= 24'h0000E3;
 22*10+8 : REG_DATA <= 24'h0000E4;
 22*10+9 : REG_DATA <= 24'h0000E5;
 23*10+0 : REG_DATA <= 24'h0000E6;
 23*10+1 : REG_DATA <= 24'h0000E7;
 23*10+2 : REG_DATA <= 24'h0000E8;
 23*10+3 : REG_DATA <= 24'h0000E9;
 23*10+4 : REG_DATA <= 24'h0000EA;
 23*10+5 : REG_DATA <= 24'h0000EB;
 23*10+6 : REG_DATA <= 24'h0000EC;
 23*10+7 : REG_DATA <= 24'h0000ED;
 23*10+8 : REG_DATA <= 24'h0000EE;
 23*10+9 : REG_DATA <= 24'h0000EF;
 24*10+0 : REG_DATA <= 24'h0000F0;
 24*10+1 : REG_DATA <= 24'h0000F1;
 24*10+2 : REG_DATA <= 24'h0000F2;
 24*10+3 : REG_DATA <= 24'h0000F3;
 24*10+4 : REG_DATA <= 24'h0000F4;
 24*10+5 : REG_DATA <= 24'h0000F5;
 24*10+6 : REG_DATA <= 24'h0000F6;
 24*10+7 : REG_DATA <= 24'h0000F7;
 24*10+8 : REG_DATA <= 24'h0000F8;
 24*10+9 : REG_DATA <= 24'h0000F9;
 25*10+0 : REG_DATA <= 24'h0000FA;
 25*10+1 : REG_DATA <= 24'h0000FB;
 25*10+2 : REG_DATA <= 24'h0000FC;
 25*10+3 : REG_DATA <= 24'h0000FD;
 25*10+4 : REG_DATA <= 24'h0000FE;
 25*10+5 : REG_DATA <= 24'h0000FF;
 25*10+6 : REG_DATA <= 24'h000100;
 25*10+7 : REG_DATA <= 24'h000101;
 25*10+8 : REG_DATA <= 24'h000102;
 25*10+9 : REG_DATA <= 24'h000103;
 26*10+0 : REG_DATA <= 24'h000104;
 26*10+1 : REG_DATA <= 24'h000105;
 26*10+2 : REG_DATA <= 24'h000106;
 26*10+3 : REG_DATA <= 24'h000107;
 26*10+4 : REG_DATA <= 24'h000108;
 26*10+5 : REG_DATA <= 24'h000109;
 26*10+6 : REG_DATA <= 24'h00010A;
 26*10+7 : REG_DATA <= 24'h00010B;
 26*10+8 : REG_DATA <= 24'h00010C;
 26*10+9 : REG_DATA <= 24'h00010D;
 27*10+0 : REG_DATA <= 24'h00010E;
 27*10+1 : REG_DATA <= 24'h00010F;
 27*10+2 : REG_DATA <= 24'h000110;
 27*10+3 : REG_DATA <= 24'h000111;
 27*10+4 : REG_DATA <= 24'h000112;
 27*10+5 : REG_DATA <= 24'h000113;
 27*10+6 : REG_DATA <= 24'h000114;
 27*10+7 : REG_DATA <= 24'h000115;
 27*10+8 : REG_DATA <= 24'h000116;
 27*10+9 : REG_DATA <= 24'h000117;
 28*10+0 : REG_DATA <= 24'h000118;
 28*10+1 : REG_DATA <= 24'h000119;
 28*10+2 : REG_DATA <= 24'h00011A;
 28*10+3 : REG_DATA <= 24'h00011B;
 28*10+4 : REG_DATA <= 24'h00011C;
 28*10+5 : REG_DATA <= 24'h00011D;
 28*10+6 : REG_DATA <= 24'h00011E;
 28*10+7 : REG_DATA <= 24'h00011F;
 28*10+8 : REG_DATA <= 24'h000120;
 28*10+9 : REG_DATA <= 24'h000121;
 29*10+0 : REG_DATA <= 24'h000122;
 29*10+1 : REG_DATA <= 24'h000123;
 29*10+2 : REG_DATA <= 24'h000124;
 29*10+3 : REG_DATA <= 24'h000125;
 29*10+4 : REG_DATA <= 24'h000126;
 29*10+5 : REG_DATA <= 24'h000127;
 29*10+6 : REG_DATA <= 24'h000128;
 29*10+7 : REG_DATA <= 24'h000129;
 29*10+8 : REG_DATA <= 24'h00012A;
 29*10+9 : REG_DATA <= 24'h00012B;
 30*10+0 : REG_DATA <= 24'h00012C;
 30*10+1 : REG_DATA <= 24'h00012D;
 30*10+2 : REG_DATA <= 24'h00012E;
 30*10+3 : REG_DATA <= 24'h00012F;
 30*10+4 : REG_DATA <= 24'h000130;
 30*10+5 : REG_DATA <= 24'h000131;
 30*10+6 : REG_DATA <= 24'h000132;
 30*10+7 : REG_DATA <= 24'h000133;
 30*10+8 : REG_DATA <= 24'h000134;
 30*10+9 : REG_DATA <= 24'h000135;
 31*10+0 : REG_DATA <= 24'h000136;
 31*10+1 : REG_DATA <= 24'h000137;
 31*10+2 : REG_DATA <= 24'h000138;
 31*10+3 : REG_DATA <= 24'h000139;
 31*10+4 : REG_DATA <= 24'h00013A;
 31*10+5 : REG_DATA <= 24'h00013B;
 31*10+6 : REG_DATA <= 24'h00013C;
 31*10+7 : REG_DATA <= 24'h00013D;
 31*10+8 : REG_DATA <= 24'h00013E;
 31*10+9 : REG_DATA <= 24'h00013F;
 32*10+0 : REG_DATA <= 24'h000140;
 32*10+1 : REG_DATA <= 24'h000141;
 32*10+2 : REG_DATA <= 24'h000142;
 32*10+3 : REG_DATA <= 24'h000143;
 32*10+4 : REG_DATA <= 24'h000144;
 32*10+5 : REG_DATA <= 24'h000145;
 32*10+6 : REG_DATA <= 24'h000146;
 32*10+7 : REG_DATA <= 24'h000147;
 32*10+8 : REG_DATA <= 24'h000148;
 32*10+9 : REG_DATA <= 24'h000149;
 33*10+0 : REG_DATA <= 24'h00014A;
 33*10+1 : REG_DATA <= 24'h00014B;
 33*10+2 : REG_DATA <= 24'h00014C;
 33*10+3 : REG_DATA <= 24'h00014D;
 33*10+4 : REG_DATA <= 24'h00014E;
 33*10+5 : REG_DATA <= 24'h00014F;
 33*10+6 : REG_DATA <= 24'h000150;
 33*10+7 : REG_DATA <= 24'h000151;
 33*10+8 : REG_DATA <= 24'h000152;
 33*10+9 : REG_DATA <= 24'h000153;
 34*10+0 : REG_DATA <= 24'h000154;
 34*10+1 : REG_DATA <= 24'h000155;
 34*10+2 : REG_DATA <= 24'h000156;
 34*10+3 : REG_DATA <= 24'h000157;
 34*10+4 : REG_DATA <= 24'h000158;
 34*10+5 : REG_DATA <= 24'h000159;
 34*10+6 : REG_DATA <= 24'h00015A;
 34*10+7 : REG_DATA <= 24'h00015B;
 34*10+8 : REG_DATA <= 24'h00015C;
 34*10+9 : REG_DATA <= 24'h00015D;
 35*10+0 : REG_DATA <= 24'h00015E;
 35*10+1 : REG_DATA <= 24'h00015F;
 35*10+2 : REG_DATA <= 24'h000160;
 35*10+3 : REG_DATA <= 24'h000161;
 35*10+4 : REG_DATA <= 24'h000162;
 35*10+5 : REG_DATA <= 24'h000163;
 35*10+6 : REG_DATA <= 24'h000164;
 35*10+7 : REG_DATA <= 24'h000165;
 35*10+8 : REG_DATA <= 24'h000166;
 35*10+9 : REG_DATA <= 24'h000167;
 36*10+0 : REG_DATA <= 24'h000168;
 36*10+1 : REG_DATA <= 24'h000169;
 36*10+2 : REG_DATA <= 24'h00016A;
 36*10+3 : REG_DATA <= 24'h00016B;
 36*10+4 : REG_DATA <= 24'h00016C;
 36*10+5 : REG_DATA <= 24'h00016D;
 36*10+6 : REG_DATA <= 24'h00016E;
 36*10+7 : REG_DATA <= 24'h00016F;
 36*10+8 : REG_DATA <= 24'h000170;
 36*10+9 : REG_DATA <= 24'h000171;
 37*10+0 : REG_DATA <= 24'h000172;
 37*10+1 : REG_DATA <= 24'h000173;
 37*10+2 : REG_DATA <= 24'h000174;
 37*10+3 : REG_DATA <= 24'h000175;
 37*10+4 : REG_DATA <= 24'h000176;
 37*10+5 : REG_DATA <= 24'h000177;
 37*10+6 : REG_DATA <= 24'h000178;
 37*10+7 : REG_DATA <= 24'h000179;
 37*10+8 : REG_DATA <= 24'h00017A;
 37*10+9 : REG_DATA <= 24'h00017B;
 38*10+0 : REG_DATA <= 24'h00017C;
 38*10+1 : REG_DATA <= 24'h00017D;
 38*10+2 : REG_DATA <= 24'h00017E;
 38*10+3 : REG_DATA <= 24'h00017F;
 38*10+4 : REG_DATA <= 24'h000180;
 38*10+5 : REG_DATA <= 24'h000181;
 38*10+6 : REG_DATA <= 24'h000182;
 38*10+7 : REG_DATA <= 24'h000183;
 38*10+8 : REG_DATA <= 24'h000184;
 38*10+9 : REG_DATA <= 24'h000185;
 39*10+0 : REG_DATA <= 24'h000186;
 39*10+1 : REG_DATA <= 24'h000187;
 39*10+2 : REG_DATA <= 24'h000188;
 39*10+3 : REG_DATA <= 24'h000189;
 39*10+4 : REG_DATA <= 24'h00018A;
 39*10+5 : REG_DATA <= 24'h00018B;
 39*10+6 : REG_DATA <= 24'h00018C;
 39*10+7 : REG_DATA <= 24'h00018D;
 39*10+8 : REG_DATA <= 24'h00018E;
 39*10+9 : REG_DATA <= 24'h00018F;
 40*10+0 : REG_DATA <= 24'h000190;
 40*10+1 : REG_DATA <= 24'h000191;
 40*10+2 : REG_DATA <= 24'h000192;
 40*10+3 : REG_DATA <= 24'h000193;
 40*10+4 : REG_DATA <= 24'h000194;
 40*10+5 : REG_DATA <= 24'h000195;
 40*10+6 : REG_DATA <= 24'h000196;
 40*10+7 : REG_DATA <= 24'h000197;
 40*10+8 : REG_DATA <= 24'h000198;
 40*10+9 : REG_DATA <= 24'h000199;
 41*10+0 : REG_DATA <= 24'h00019A;
 41*10+1 : REG_DATA <= 24'h00019B;
 41*10+2 : REG_DATA <= 24'h00019C;
 41*10+3 : REG_DATA <= 24'h00019D;
 41*10+4 : REG_DATA <= 24'h00019E;
 41*10+5 : REG_DATA <= 24'h00019F;
 41*10+6 : REG_DATA <= 24'h0001A0;
 41*10+7 : REG_DATA <= 24'h0001A1;
 41*10+8 : REG_DATA <= 24'h0001A2;
 41*10+9 : REG_DATA <= 24'h0001A3;
 42*10+0 : REG_DATA <= 24'h0001A4;
 42*10+1 : REG_DATA <= 24'h0001A5;
 42*10+2 : REG_DATA <= 24'h0001A6;
 42*10+3 : REG_DATA <= 24'h0001A7;
 42*10+4 : REG_DATA <= 24'h0001A8;
 42*10+5 : REG_DATA <= 24'h0001A9;
 42*10+6 : REG_DATA <= 24'h0001AA;
 42*10+7 : REG_DATA <= 24'h0001AB;
 42*10+8 : REG_DATA <= 24'h0001AC;
 42*10+9 : REG_DATA <= 24'h0001AD;
 43*10+0 : REG_DATA <= 24'h0001AE;
 43*10+1 : REG_DATA <= 24'h0001AF;
 43*10+2 : REG_DATA <= 24'h0001B0;
 43*10+3 : REG_DATA <= 24'h0001B1;
 43*10+4 : REG_DATA <= 24'h0001B2;
 43*10+5 : REG_DATA <= 24'h0001B3;
 43*10+6 : REG_DATA <= 24'h0001B4;
 43*10+7 : REG_DATA <= 24'h0001B5;
 43*10+8 : REG_DATA <= 24'h0001B6;
 43*10+9 : REG_DATA <= 24'h0001B7;
 44*10+0 : REG_DATA <= 24'h0001B8;
 44*10+1 : REG_DATA <= 24'h0001B9;
 44*10+2 : REG_DATA <= 24'h0001BA;
 44*10+3 : REG_DATA <= 24'h0001BB;
 44*10+4 : REG_DATA <= 24'h0001BC;
 44*10+5 : REG_DATA <= 24'h0001BD;
 44*10+6 : REG_DATA <= 24'h0001BE;
 44*10+7 : REG_DATA <= 24'h0001BF;
 44*10+8 : REG_DATA <= 24'h0001C0;
 44*10+9 : REG_DATA <= 24'h0001C1;
 45*10+0 : REG_DATA <= 24'h0001C2;
 45*10+1 : REG_DATA <= 24'h0001C3;
 45*10+2 : REG_DATA <= 24'h0001C4;
 45*10+3 : REG_DATA <= 24'h0001C5;
 45*10+4 : REG_DATA <= 24'h0001C6;
 45*10+5 : REG_DATA <= 24'h0001C7;
 45*10+6 : REG_DATA <= 24'h0001C8;
 45*10+7 : REG_DATA <= 24'h0001C9;
 45*10+8 : REG_DATA <= 24'h0001CA;
 45*10+9 : REG_DATA <= 24'h0001CB;
 46*10+0 : REG_DATA <= 24'h0001CC;
 46*10+1 : REG_DATA <= 24'h0001CD;
 46*10+2 : REG_DATA <= 24'h0001CE;
 46*10+3 : REG_DATA <= 24'h0001CF;
 46*10+4 : REG_DATA <= 24'h0001D0;
 46*10+5 : REG_DATA <= 24'h0001D1;
 46*10+6 : REG_DATA <= 24'h0001D2;
 46*10+7 : REG_DATA <= 24'h0001D3;
 46*10+8 : REG_DATA <= 24'h0001D4;
 46*10+9 : REG_DATA <= 24'h0001D5;
 47*10+0 : REG_DATA <= 24'h0001D6;
 47*10+1 : REG_DATA <= 24'h0001D7;
 47*10+2 : REG_DATA <= 24'h0001D8;
 47*10+3 : REG_DATA <= 24'h0001D9;
 47*10+4 : REG_DATA <= 24'h0001DA;
 47*10+5 : REG_DATA <= 24'h0001DB;
 47*10+6 : REG_DATA <= 24'h0001DC;
 47*10+7 : REG_DATA <= 24'h0001DD;
 47*10+8 : REG_DATA <= 24'h0001DE;
 47*10+9 : REG_DATA <= 24'h0001DF;
 48*10+0 : REG_DATA <= 24'h0001E0;
 48*10+1 : REG_DATA <= 24'h0001E1;
 48*10+2 : REG_DATA <= 24'h0001E2;
 48*10+3 : REG_DATA <= 24'h0001E3;
 48*10+4 : REG_DATA <= 24'h0001E4;
 48*10+5 : REG_DATA <= 24'h0001E5;
 48*10+6 : REG_DATA <= 24'h0001E6;
 48*10+7 : REG_DATA <= 24'h0001E7;
 48*10+8 : REG_DATA <= 24'h0001E8;
 48*10+9 : REG_DATA <= 24'h0001E9;
 49*10+0 : REG_DATA <= 24'h0001EA;
 49*10+1 : REG_DATA <= 24'h0001EB;
 49*10+2 : REG_DATA <= 24'h0001EC;
 49*10+3 : REG_DATA <= 24'h0001ED;
 49*10+4 : REG_DATA <= 24'h0001EE;
 49*10+5 : REG_DATA <= 24'h0001EF;
 49*10+6 : REG_DATA <= 24'h0001F0;
 49*10+7 : REG_DATA <= 24'h0001F1;
 49*10+8 : REG_DATA <= 24'h0001F2;
 49*10+9 : REG_DATA <= 24'h0001F3;
 50*10+0 : REG_DATA <= 24'h0001F4;
 50*10+1 : REG_DATA <= 24'h0001F5;
 50*10+2 : REG_DATA <= 24'h0001F6;
 50*10+3 : REG_DATA <= 24'h0001F7;
 50*10+4 : REG_DATA <= 24'h0001F8;
 50*10+5 : REG_DATA <= 24'h0001F9;
 50*10+6 : REG_DATA <= 24'h0001FA;
 50*10+7 : REG_DATA <= 24'h0001FB;
 50*10+8 : REG_DATA <= 24'h0001FC;
 50*10+9 : REG_DATA <= 24'h0001FD;
 51*10+0 : REG_DATA <= 24'h0001FE;
 51*10+1 : REG_DATA <= 24'h0001FF;
 51*10+2 : REG_DATA <= 24'h000200;
 51*10+3 : REG_DATA <= 24'h000201;
 51*10+4 : REG_DATA <= 24'h000202;
 51*10+5 : REG_DATA <= 24'h000203;
 51*10+6 : REG_DATA <= 24'h000204;
 51*10+7 : REG_DATA <= 24'h000205;
 51*10+8 : REG_DATA <= 24'h000206;
 51*10+9 : REG_DATA <= 24'h000207;
 52*10+0 : REG_DATA <= 24'h000208;
 52*10+1 : REG_DATA <= 24'h000209;
 52*10+2 : REG_DATA <= 24'h00020A;
 52*10+3 : REG_DATA <= 24'h00020B;
 52*10+4 : REG_DATA <= 24'h00020C;
 52*10+5 : REG_DATA <= 24'h00020D;
 52*10+6 : REG_DATA <= 24'h00020E;
 52*10+7 : REG_DATA <= 24'h00020F;
 52*10+8 : REG_DATA <= 24'h000210;
 52*10+9 : REG_DATA <= 24'h000211;
 53*10+0 : REG_DATA <= 24'h000212;
 53*10+1 : REG_DATA <= 24'h000213;
 53*10+2 : REG_DATA <= 24'h000214;
 53*10+3 : REG_DATA <= 24'h000215;
 53*10+4 : REG_DATA <= 24'h000216;
 53*10+5 : REG_DATA <= 24'h000217;
 53*10+6 : REG_DATA <= 24'h000218;
 53*10+7 : REG_DATA <= 24'h000219;
 53*10+8 : REG_DATA <= 24'h00021A;
 53*10+9 : REG_DATA <= 24'h00021B;
 54*10+0 : REG_DATA <= 24'h00021C;
 54*10+1 : REG_DATA <= 24'h00021D;
 54*10+2 : REG_DATA <= 24'h00021E;
 54*10+3 : REG_DATA <= 24'h00021F;
 54*10+4 : REG_DATA <= 24'h000220;
 54*10+5 : REG_DATA <= 24'h000221;
 54*10+6 : REG_DATA <= 24'h000222;
 54*10+7 : REG_DATA <= 24'h000223;
 54*10+8 : REG_DATA <= 24'h000224;
 54*10+9 : REG_DATA <= 24'h000225;
 55*10+0 : REG_DATA <= 24'h000226;
 55*10+1 : REG_DATA <= 24'h000227;
 55*10+2 : REG_DATA <= 24'h000228;
 55*10+3 : REG_DATA <= 24'h000229;
 55*10+4 : REG_DATA <= 24'h00022A;
 55*10+5 : REG_DATA <= 24'h00022B;
 55*10+6 : REG_DATA <= 24'h00022C;
 55*10+7 : REG_DATA <= 24'h00022D;
 55*10+8 : REG_DATA <= 24'h00022E;
 55*10+9 : REG_DATA <= 24'h00022F;
 56*10+0 : REG_DATA <= 24'h000230;
 56*10+1 : REG_DATA <= 24'h000231;
 56*10+2 : REG_DATA <= 24'h000232;
 56*10+3 : REG_DATA <= 24'h000233;
 56*10+4 : REG_DATA <= 24'h000234;
 56*10+5 : REG_DATA <= 24'h000235;
 56*10+6 : REG_DATA <= 24'h000236;
 56*10+7 : REG_DATA <= 24'h000237;
 56*10+8 : REG_DATA <= 24'h000238;
 56*10+9 : REG_DATA <= 24'h000239;
 57*10+0 : REG_DATA <= 24'h00023A;
 57*10+1 : REG_DATA <= 24'h00023B;
 57*10+2 : REG_DATA <= 24'h00023C;
 57*10+3 : REG_DATA <= 24'h00023D;
 57*10+4 : REG_DATA <= 24'h00023E;
 57*10+5 : REG_DATA <= 24'h00023F;
 57*10+6 : REG_DATA <= 24'h000240;
 57*10+7 : REG_DATA <= 24'h000241;
 57*10+8 : REG_DATA <= 24'h000242;
 57*10+9 : REG_DATA <= 24'h000243;
 58*10+0 : REG_DATA <= 24'h000244;
 58*10+1 : REG_DATA <= 24'h000245;
 58*10+2 : REG_DATA <= 24'h000246;
 58*10+3 : REG_DATA <= 24'h000247;
 58*10+4 : REG_DATA <= 24'h000248;
 58*10+5 : REG_DATA <= 24'h000249;
 58*10+6 : REG_DATA <= 24'h00024A;
 58*10+7 : REG_DATA <= 24'h00024B;
 58*10+8 : REG_DATA <= 24'h00024C;
 58*10+9 : REG_DATA <= 24'h00024D;
 59*10+0 : REG_DATA <= 24'h00024E;
 59*10+1 : REG_DATA <= 24'h00024F;
 59*10+2 : REG_DATA <= 24'h000250;
 59*10+3 : REG_DATA <= 24'h000251;
 59*10+4 : REG_DATA <= 24'h000252;
 59*10+5 : REG_DATA <= 24'h000253;
 59*10+6 : REG_DATA <= 24'h000254;
 59*10+7 : REG_DATA <= 24'h000255;
 59*10+8 : REG_DATA <= 24'h000256;
 59*10+9 : REG_DATA <= 24'h000257;
 60*10+0 : REG_DATA <= 24'h000258;
 60*10+1 : REG_DATA <= 24'h000259;
 60*10+2 : REG_DATA <= 24'h00025A;
 60*10+3 : REG_DATA <= 24'h00025B;
 60*10+4 : REG_DATA <= 24'h00025C;
 60*10+5 : REG_DATA <= 24'h00025D;
 60*10+6 : REG_DATA <= 24'h00025E;
 60*10+7 : REG_DATA <= 24'h00025F;
 60*10+8 : REG_DATA <= 24'h000260;
 60*10+9 : REG_DATA <= 24'h000261;
 61*10+0 : REG_DATA <= 24'h000262;
 61*10+1 : REG_DATA <= 24'h000263;
 61*10+2 : REG_DATA <= 24'h000264;
 61*10+3 : REG_DATA <= 24'h000265;
 61*10+4 : REG_DATA <= 24'h000266;
 61*10+5 : REG_DATA <= 24'h000267;
 61*10+6 : REG_DATA <= 24'h000268;
 61*10+7 : REG_DATA <= 24'h000269;
 61*10+8 : REG_DATA <= 24'h00026A;
 61*10+9 : REG_DATA <= 24'h00026B;
 62*10+0 : REG_DATA <= 24'h00026C;
 62*10+1 : REG_DATA <= 24'h00026D;
 62*10+2 : REG_DATA <= 24'h00026E;
 62*10+3 : REG_DATA <= 24'h00026F;
 62*10+4 : REG_DATA <= 24'h000270;
 62*10+5 : REG_DATA <= 24'h000271;
 62*10+6 : REG_DATA <= 24'h000272;
 62*10+7 : REG_DATA <= 24'h000273;
 62*10+8 : REG_DATA <= 24'h000274;
 62*10+9 : REG_DATA <= 24'h000275;
 63*10+0 : REG_DATA <= 24'h000276;
 63*10+1 : REG_DATA <= 24'h000277;
 63*10+2 : REG_DATA <= 24'h000278;
 63*10+3 : REG_DATA <= 24'h000279;
 63*10+4 : REG_DATA <= 24'h00027A;
 63*10+5 : REG_DATA <= 24'h00027B;
 63*10+6 : REG_DATA <= 24'h00027C;
 63*10+7 : REG_DATA <= 24'h00027D;
 63*10+8 : REG_DATA <= 24'h00027E;
 63*10+9 : REG_DATA <= 24'h00027F;
 64*10+0 : REG_DATA <= 24'h000280;
 64*10+1 : REG_DATA <= 24'h000281;
 64*10+2 : REG_DATA <= 24'h000282;
 64*10+3 : REG_DATA <= 24'h000283;
 64*10+4 : REG_DATA <= 24'h000284;
 64*10+5 : REG_DATA <= 24'h000285;
 64*10+6 : REG_DATA <= 24'h000286;
 64*10+7 : REG_DATA <= 24'h000287;
 64*10+8 : REG_DATA <= 24'h000288;
 64*10+9 : REG_DATA <= 24'h000289;
 65*10+0 : REG_DATA <= 24'h00028A;
 65*10+1 : REG_DATA <= 24'h00028B;
 65*10+2 : REG_DATA <= 24'h00028C;
 65*10+3 : REG_DATA <= 24'h00028D;
 65*10+4 : REG_DATA <= 24'h00028E;
 65*10+5 : REG_DATA <= 24'h00028F;
 65*10+6 : REG_DATA <= 24'h000290;
 65*10+7 : REG_DATA <= 24'h000291;
 65*10+8 : REG_DATA <= 24'h000292;
 65*10+9 : REG_DATA <= 24'h000293;
 66*10+0 : REG_DATA <= 24'h000294;
 66*10+1 : REG_DATA <= 24'h000295;
 66*10+2 : REG_DATA <= 24'h000296;
 66*10+3 : REG_DATA <= 24'h000297;
 66*10+4 : REG_DATA <= 24'h000298;
 66*10+5 : REG_DATA <= 24'h000299;
 66*10+6 : REG_DATA <= 24'h00029A;
 66*10+7 : REG_DATA <= 24'h00029B;
 66*10+8 : REG_DATA <= 24'h00029C;
 66*10+9 : REG_DATA <= 24'h00029D;
 67*10+0 : REG_DATA <= 24'h00029E;
 67*10+1 : REG_DATA <= 24'h00029F;
 67*10+2 : REG_DATA <= 24'h0002A0;
 67*10+3 : REG_DATA <= 24'h0002A1;
 67*10+4 : REG_DATA <= 24'h0002A2;
 67*10+5 : REG_DATA <= 24'h0002A3;
 67*10+6 : REG_DATA <= 24'h0002A4;
 67*10+7 : REG_DATA <= 24'h0002A5;
 67*10+8 : REG_DATA <= 24'h0002A6;
 67*10+9 : REG_DATA <= 24'h0002A7;
 68*10+0 : REG_DATA <= 24'h0002A8;
 68*10+1 : REG_DATA <= 24'h0002A9;
 68*10+2 : REG_DATA <= 24'h0002AA;
 68*10+3 : REG_DATA <= 24'h0002AB;
 68*10+4 : REG_DATA <= 24'h0002AC;
 68*10+5 : REG_DATA <= 24'h0002AD;
 68*10+6 : REG_DATA <= 24'h0002AE;
 68*10+7 : REG_DATA <= 24'h0002AF;
 68*10+8 : REG_DATA <= 24'h0002B0;
 68*10+9 : REG_DATA <= 24'h0002B1;
 69*10+0 : REG_DATA <= 24'h0002B2;
 69*10+1 : REG_DATA <= 24'h0002B3;
 69*10+2 : REG_DATA <= 24'h0002B4;
 69*10+3 : REG_DATA <= 24'h0002B5;
 69*10+4 : REG_DATA <= 24'h0002B6;
 69*10+5 : REG_DATA <= 24'h0002B7;
 69*10+6 : REG_DATA <= 24'h0002B8;
 69*10+7 : REG_DATA <= 24'h0002B9;
 69*10+8 : REG_DATA <= 24'h0002BA;
 69*10+9 : REG_DATA <= 24'h0002BB;
 70*10+0 : REG_DATA <= 24'h0002BC;
 70*10+1 : REG_DATA <= 24'h0002BD;
 70*10+2 : REG_DATA <= 24'h0002BE;
 70*10+3 : REG_DATA <= 24'h0002BF;
 70*10+4 : REG_DATA <= 24'h0002C0;
 70*10+5 : REG_DATA <= 24'h0002C1;
 70*10+6 : REG_DATA <= 24'h0002C2;
 70*10+7 : REG_DATA <= 24'h0002C3;
 70*10+8 : REG_DATA <= 24'h0002C4;
 70*10+9 : REG_DATA <= 24'h0002C5;
 71*10+0 : REG_DATA <= 24'h0002C6;
 71*10+1 : REG_DATA <= 24'h0002C7;
 71*10+2 : REG_DATA <= 24'h0002C8;
 71*10+3 : REG_DATA <= 24'h0002C9;
 71*10+4 : REG_DATA <= 24'h0002CA;
 71*10+5 : REG_DATA <= 24'h0002CB;
 71*10+6 : REG_DATA <= 24'h0002CC;
 71*10+7 : REG_DATA <= 24'h0002CD;
 71*10+8 : REG_DATA <= 24'h0002CE;
 71*10+9 : REG_DATA <= 24'h0002CF;
 72*10+0 : REG_DATA <= 24'h0002D0;
 72*10+1 : REG_DATA <= 24'h0002D1;
 72*10+2 : REG_DATA <= 24'h0002D2;
 72*10+3 : REG_DATA <= 24'h0002D3;
 72*10+4 : REG_DATA <= 24'h0002D4;
 72*10+5 : REG_DATA <= 24'h0002D5;
 72*10+6 : REG_DATA <= 24'h0002D6;
 72*10+7 : REG_DATA <= 24'h0002D7;
 72*10+8 : REG_DATA <= 24'h0002D8;
 72*10+9 : REG_DATA <= 24'h0002D9;
 73*10+0 : REG_DATA <= 24'h0002DA;
 73*10+1 : REG_DATA <= 24'h0002DB;
 73*10+2 : REG_DATA <= 24'h0002DC;
 73*10+3 : REG_DATA <= 24'h0002DD;
 73*10+4 : REG_DATA <= 24'h0002DE;
 73*10+5 : REG_DATA <= 24'h0002DF;
 73*10+6 : REG_DATA <= 24'h0002E0;
 73*10+7 : REG_DATA <= 24'h0002E1;
 73*10+8 : REG_DATA <= 24'h0002E2;
 73*10+9 : REG_DATA <= 24'h0002E3;
 74*10+0 : REG_DATA <= 24'h0002E4;
 74*10+1 : REG_DATA <= 24'h0002E5;
 74*10+2 : REG_DATA <= 24'h0002E6;
 74*10+3 : REG_DATA <= 24'h0002E7;
 74*10+4 : REG_DATA <= 24'h0002E8;
 74*10+5 : REG_DATA <= 24'h0002E9;
 74*10+6 : REG_DATA <= 24'h0002EA;
 74*10+7 : REG_DATA <= 24'h0002EB;
 74*10+8 : REG_DATA <= 24'h0002EC;
 74*10+9 : REG_DATA <= 24'h0002ED;
 75*10+0 : REG_DATA <= 24'h0002EE;
 75*10+1 : REG_DATA <= 24'h0002EF;
 75*10+2 : REG_DATA <= 24'h0002F0;
 75*10+3 : REG_DATA <= 24'h0002F1;
 75*10+4 : REG_DATA <= 24'h0002F2;
 75*10+5 : REG_DATA <= 24'h0002F3;
 75*10+6 : REG_DATA <= 24'h0002F4;
 75*10+7 : REG_DATA <= 24'h0002F5;
 75*10+8 : REG_DATA <= 24'h0002F6;
 75*10+9 : REG_DATA <= 24'h0002F7;
 76*10+0 : REG_DATA <= 24'h0002F8;
 76*10+1 : REG_DATA <= 24'h0002F9;
 76*10+2 : REG_DATA <= 24'h0002FA;
 76*10+3 : REG_DATA <= 24'h0002FB;
 76*10+4 : REG_DATA <= 24'h0002FC;
 76*10+5 : REG_DATA <= 24'h0002FD;
 76*10+6 : REG_DATA <= 24'h0002FE;
 76*10+7 : REG_DATA <= 24'h0002FF;
 76*10+8 : REG_DATA <= 24'h000300;
 76*10+9 : REG_DATA <= 24'h000301;
 77*10+0 : REG_DATA <= 24'h000302;
 77*10+1 : REG_DATA <= 24'h000303;
 77*10+2 : REG_DATA <= 24'h850304;
 77*10+3 : REG_DATA <= 24'h000305;
 77*10+4 : REG_DATA <= 24'h000306;
 77*10+5 : REG_DATA <= 24'h9c0307;
 77*10+6 : REG_DATA <= 24'h010308;
 77*10+7 : REG_DATA <= 24'hd40309;
 77*10+8 : REG_DATA <= 24'h02030A;
 77*10+9 : REG_DATA <= 24'h71030B;
 78*10+0 : REG_DATA <= 24'h00030C;
 78*10+1 : REG_DATA <= 24'h00030D;
 78*10+2 : REG_DATA <= 24'h00030E;
 78*10+3 : REG_DATA <= 24'h00030F;
 78*10+4 : REG_DATA <= 24'h000310;
 78*10+5 : REG_DATA <= 24'h830311;
 78*10+6 : REG_DATA <= 24'h000312;
 78*10+7 : REG_DATA <= 24'h100313;
 78*10+8 : REG_DATA <= 24'h020314;
 78*10+9 : REG_DATA <= 24'h080315;
 79*10+0 : REG_DATA <= 24'h8c0316;
 default:;
endcase



generate if(ILA_ENABLE)begin
    ila_0  
    ila_0_u
    (
    .clk     (clk_i      ) ,
    .probe0  (init_done  ) ,
    .probe1  (cfg_done   ) ,
    .probe2  ({q1_cfg_done,q0_cfg_done}    ) ,
    .probe3  ({i_q0_phy_rst,i_q1_phy_rst}  ) ,
    .probe4  (q1_lnk_rate   ) ,
    .probe5  (q0_lnk_rate   ) ,
    .probe6  (REG_INDEX     ) ,//10
    .probe7  (TS_S          )  //4
    
    
    );


end
endgenerate






endmodule



module uii2c#
(
parameter WMEN_LEN = 8'd0,
parameter RMEN_LEN = 8'd0,
parameter CLK_DIV  = 16'd499
)
(
input  clk_i,
//inout  iic_scl,
//inout  iic_sda,
input											sda_i,
output										sda_o,
output 										iic_scl_o,

			
input  [WMEN_LEN*8-1'b1:0]wr_data,//write data
input  [7:0]wr_cnt,//write data lenth include device address 
output reg [RMEN_LEN*8-1'b1:0]rd_data,//read data 
input  [7:0]rd_cnt,//read data lenth
input  iic_en,//iic_en == 1 enable iic transmit
input  iic_mode,//iic_mode = 1 random read iic_mode = 0 current read or page read
output reg iic_busy,//iic controller busy
output reg sda_dg//for ila debug
);

parameter IDLE    = 4'd0;
parameter START   = 4'd1;
parameter W_WAIT  = 4'd2;
parameter W_ACK   = 4'd3;
parameter R_WAIT  = 4'd4;  
parameter R_ACK  = 4'd5; 
parameter STOP1   = 4'd6;  
parameter STOP2   = 4'd7;   

reg [2:0] IIC_S = 4'd0;
//generate  scl
reg [15:0] clkdiv = 16'd0;   
reg scl_clk = 1'b0;
reg iic_scl_o;
reg iic_scl_t;



 
always@(posedge clk_i)
    if(clkdiv < CLK_DIV)    
        clkdiv <= clkdiv + 1'b1;
    else begin
        clkdiv <= 16'd0; 
        scl_clk <= !scl_clk;
    end

parameter OFFSET = CLK_DIV - CLK_DIV/4;        
wire scl_offset  = (clkdiv == OFFSET);//scl delay output to fit timing
     
//reg iic_busy = 1'b0;
//reg iic_scl = 1'b0;
reg scl_r = 1'b1;
reg sda_o = 1'b0;    
reg [7:0] sda_r = 8'd0;
reg [7:0] sda_i_r = 8'd0;
reg [7:0] wcnt = 8'd0;
reg [7:0] rcnt = 8'd0;
reg [2:0] bcnt = 3'd0;
reg rd_en = 1'b0;
//reg [RMEN_LEN*8-1'b1:0] rd_data = 0;
wire       sda_i;

initial begin 
	iic_busy = 1'b0;
  iic_scl_o = 1'b0;
	rd_data = 0;
	sda_dg = 1'b1;
end 

always @(posedge clk_i) iic_scl_o <=  scl_offset ?  scl_r : iic_scl_o;       






//scl output
always @(*) begin
    if(IIC_S == IDLE || IIC_S == STOP1 || IIC_S == STOP2)
        scl_r <= 1'b1;
    else 
        scl_r <= ~scl_clk;
end   
//sda output 
always @(*) begin
    if(IIC_S == START || IIC_S == STOP1 || (IIC_S == R_ACK && (rcnt != rd_cnt)))
        sda_o <= 1'b0;
    else if(IIC_S == W_WAIT)
        sda_o <= sda_r[7]; 
    else  sda_o <= 1'b1;
end   
//sda output shift
always @(negedge scl_clk) begin
    if(IIC_S == W_ACK || IIC_S == START)begin
        sda_r <= wr_data[(wcnt*8) +: 8];
        if( rd_en ) sda_r <= {wr_data[7:1],1'b1};
    end
    else if(IIC_S == W_WAIT)
        sda_r <= {sda_r[6:0],1'b1};
    else 
        sda_r <= sda_r;
end
//sda input shift   
always @(posedge scl_clk) begin
    if(IIC_S == R_WAIT ||IIC_S == W_ACK ) begin
        sda_i_r <= {sda_i_r[6:0],sda_i};
    end
    else if(IIC_S == R_ACK)
        rd_data[((rcnt-1'b1)*8) +: 8] <= sda_i_r[7:0];
    else if(IIC_S == IDLE)begin
        sda_i_r <= 8'd0;
    end 
end

reg iic_sda_r = 1'b1;
//reg sda_dg = 1'b1;
always @(posedge scl_clk) iic_sda_r <= sda_i;
always @(posedge clk_i) sda_dg <= sda_i;

//iic state machine
always @(negedge scl_clk)begin
        case(IIC_S) //sda = 1 scl =1
        IDLE:     //idle wait iic_en == 1'b1 start trasmit   rd_en == 1'b1 restart 
        if(iic_en == 1'b1 || rd_en == 1'b1)begin 
           iic_busy <= 1'b1;        
           IIC_S  <= START;
        end
        else begin
           iic_busy <= 1'b0;
           wcnt <= 8'd0;
           rcnt <= 8'd0;
           rd_en <= 1'b0;
        end
        START:begin //sda = 0  then scl_clk =0 scl =0 generate start
           bcnt <= 3'd7;          
           IIC_S  <= W_WAIT;
        end           
        W_WAIT:   //write data 
        begin
           if(bcnt > 3'd0)
               bcnt  <= bcnt - 1'b1; 
           else begin
               wcnt <= wcnt + 1'b1; 
               IIC_S  <= W_ACK;
           end
        end 
        W_ACK:   //write data ack
        begin 
           if(wcnt < wr_cnt)begin 
              bcnt <= 3'd7;
              IIC_S <= W_WAIT;
           end
           else if(rd_cnt > 3'd0)begin// read data
              if(rd_en == 1'b0 && iic_mode == 1'b1)begin 
                  rd_en <= 1'b1;
                  IIC_S <= IDLE;  
              end
              else 
                  IIC_S <= R_WAIT;
              bcnt <= 3'd7;
           end
           else
              IIC_S <= STOP1; 
              if(iic_sda_r == 1'b1)
              IIC_S <= STOP1;
        end  
        R_WAIT:   //read data
        begin
           rd_en <= 1'b0;
           bcnt  <= bcnt - 1'b1; 
           if(bcnt == 3'd0)begin
              rcnt <= (rcnt < rd_cnt) ? (rcnt + 1'b1) : rcnt;
              IIC_S  <= R_ACK;
           end
        end
        R_ACK:   //read date ack
        begin
           bcnt <= 3'd7;
           IIC_S <= (rcnt < rd_cnt) ? R_WAIT : STOP1; 
        end  
        STOP1://sda = 0 scl = 1
            IIC_S <= STOP2;
        STOP2://sda = 1 scl = 1
            IIC_S <= IDLE;          
        default:
            IIC_S <= IDLE;
    endcase
end

endmodule
