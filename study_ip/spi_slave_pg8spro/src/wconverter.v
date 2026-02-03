`timescale 1ns / 1ps

`define SINGLE_TO_BI_Nm1To0(a,b,in,out)              for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end 
`define BI_TO_SINGLE_Nm1To0(a,b,in,out)              for(i=1;i<=b;i=i+1)begin assign out[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)] = in[b-i];end 
`define SINGLE_TO_TRI_Nm1To0(a,b,c,in,out)           for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[b-i][c-j] = in[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ];end end 
`define TRI_TO_SINGLE_Nm1To0(a,b,c,in,out)           for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ] = in[b-i][c-j];end end 
`define SINGLE_TO_FOUR_Nm1To0(a,b,c,d,in,out)        for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[b-i][c-j][d-k] = in[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1]; end end end 
`define FOUR_TO_SINGLE_Nm1To0(a,b,c,d,in,out)        for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1] = in[b-i][c-j][d-k]; end end end 



//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/09 12:20:12
// Design Name: 
// Module Name: wconverter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////

module wconverter
#( 
   parameter AWPORT_WIDTH      = 2   ,
   parameter AWLEN_WIDTH       = 16  ,
   parameter AWSIZE_WIDTH      = 16  ,
   parameter IN_WIDTH          = 128 ,
   parameter OUT_WIDTH         = 256  
 )
(
input                      CLK       ,
input                      RSTN      ,
input                      S_WVALID  ,
output                     S_WREADY  ,
input [IN_WIDTH-1:0]       S_WDATA   ,
input [IN_WIDTH/8-1:0]     S_WSTRB   ,
input                      S_WLAST   ,


output                     M_WVALID  ,
input                      M_WREADY  ,
output [OUT_WIDTH-1:0]     M_WDATA   ,
output [OUT_WIDTH/8-1:0]   M_WSTRB   ,
output                     M_WLAST   

);

localparam  SHRINK = IN_WIDTH >= OUT_WIDTH ? IN_WIDTH/OUT_WIDTH : OUT_WIDTH/IN_WIDTH  ;



//位宽从小变大, 则出的valid每2个间隔变为有效
//位宽从大变小，则ready端需要间隔得屏蔽

//位宽从大变小，则ready端必然在每次valid后要 阻塞一次(SHRINK-1)。


//逻辑：一旦右侧来一个 wready，则左侧开始输出，
//                             第一次输出直连右侧，
//                             随后的输出（左侧保持valid，同时记录右侧来的wredy数） ，
//                             随后对左侧的ready做屏蔽(mask)
//                             记满后，即回到开头

//状态机（位宽由大变小）
//1 第一次wvalid和wready有效时把数据直接输出，同时缓存一份移位后的内容，
//2 如果第一次即来了last，则缓存strobe(若strobe第一次只为1，则状态结束，同时打出last)
//3 如果不是last，状态1中，随后拉高右侧额外的valid，每当右侧有wready时，就打出缓存的数据
//4 如果是last，且第一次不只为1，则运行状态3，移位到strbo的缓存为1,时，就打出last

//last的生成逻辑,既有组合逻辑，又有时序逻辑，建议用组合逻辑
//同样的输出的valid也是既有组合逻辑，又有时序逻辑
//
genvar i,j,k;


generate if(IN_WIDTH == OUT_WIDTH)begin : equal ////////////////////////////////////////////////////////////////////////////////////////////

assign  M_WVALID = S_WVALID;
assign  S_WREADY = M_WREADY ;
assign  M_WDATA  = S_WDATA ;
assign  M_WSTRB  = S_WSTRB ;
assign  M_WLAST  = S_WLAST ;

end
else if(IN_WIDTH >= OUT_WIDTH)begin: bigger ////////////////////////////////////////////////////////////////////////////////////////////
reg [7:0] state;
wire l_wr_valid;
wire r_wr_valid;
reg M_WVALID_ex; 
wire  s_wready_mask;
reg [IN_WIDTH-1:0]   M_WDATA_ex;
reg [IN_WIDTH/8-1:0] S_WSTRB_ex;

reg  [OUT_WIDTH-1:0]M_WSTRB_ex ;

wire over_shreshold;
assign over_shreshold = S_WSTRB_bit[1]; //说明超过门限

//可以按照 OUT_WIDTH 位宽决定，计算出一个  0   0   1   1    1    1 -->>  从右向左移动
//可以完全参照从右向左移动的情况，就可以知道具体的值了


wire [OUT_WIDTH/8-1:0] S_WSTRB_m [SHRINK-1:0] ;
`SINGLE_TO_BI_Nm1To0((OUT_WIDTH/8),SHRINK,S_WSTRB,S_WSTRB_m)

wire [SHRINK-1:0] S_WSTRB_bit;

 for(i=0;i<SHRINK;i=i+1)begin
    assign S_WSTRB_bit[i] = S_WSTRB_m[i]>0 ;
end

reg  [OUT_WIDTH-1:0] S_WSTRB_buf;
reg  [SHRINK-1:0] S_WSTRB_bit_buf;
reg  [SHRINK-1:0] S_WSTRB_bit_buf_2;//向右进一步移动一位以提前判断

reg  M_LAST_ex = 0;
reg  last_flag = 0;


always@(posedge CLK)begin
    if(~RSTN)begin
        state <= 0; 
        M_WVALID_ex <= 0;  
        M_LAST_ex <= 0;
        S_WSTRB_bit_buf <= 0;
        S_WSTRB_bit_buf_2 <= 0;
        M_WSTRB_ex <= 0;
        M_WDATA_ex <= 0;
        last_flag <= 0;
    end
    else begin
        case(state)
            0:begin//填入，再移位
                if(l_wr_valid & ~S_WLAST)begin//不为last时，默认strb是填满的
                    S_WSTRB_bit_buf   <= S_WSTRB_bit>>1 ;
                    S_WSTRB_bit_buf_2 <= S_WSTRB_bit>>2 ;
                    if( (S_WSTRB_bit>>1) &  (S_WSTRB_bit>>2)==0 )begin
                            M_LAST_ex  <= 1;//M_LAST_ex 虚拟last
                        end
                        else begin  
                            M_LAST_ex <= 0;
                        end
                    M_WSTRB_ex <= S_WSTRB>>(OUT_WIDTH/8) ;
                    M_WDATA_ex <= S_WDATA>>OUT_WIDTH;
                    M_WVALID_ex <= 1; //因为位宽不同，所以必然拉高
                    state <= 3;
                    last_flag <= 0;
                end
                else if(l_wr_valid & S_WLAST)begin  //假定strobe是满的;  这里，last还要考虑strobe，是否为1111 1110 这样的情况
                    last_flag <= 1;     
                    if(~over_shreshold)begin
                        M_WVALID_ex <= 0;
                        state <= 0;
                    end
                    else if(over_shreshold)begin
                        S_WSTRB_bit_buf   <= S_WSTRB_bit>>1 ;
                        S_WSTRB_bit_buf_2 <= S_WSTRB_bit>>2 ;
                        if( (S_WSTRB_bit>>1) &  (S_WSTRB_bit>>2)==0 )begin
                            M_LAST_ex  <= 1;
                        end
                        else begin  
                            M_LAST_ex <= 0;
                        end
                        M_WSTRB_ex <= S_WSTRB>>(OUT_WIDTH/8) ;
                        M_WDATA_ex <= S_WDATA>>OUT_WIDTH;
                        M_WVALID_ex <= 1;
                        state <= 3;
                    end
                    //strobe 是否超过门限值 如果不超过门限，则直接用strobe作为strobe，同时直接打出last
                    //strobe 如果高于门限，则计算出额外次数，以及最后一次时的strobe
                    
                end
            end
            3:begin //拓展后出LAST情况
                S_WSTRB_bit_buf   <= r_wr_valid  ? S_WSTRB_bit_buf>>1 : S_WSTRB_bit_buf;
                S_WSTRB_bit_buf_2 <= r_wr_valid  ? S_WSTRB_bit_buf_2>>1 : S_WSTRB_bit_buf_2;
                M_WDATA_ex <= r_wr_valid ? M_WDATA_ex >>OUT_WIDTH : M_WDATA_ex;
                M_WSTRB_ex <= r_wr_valid ? M_WSTRB_ex>>(OUT_WIDTH/8) :  M_WSTRB_ex;
                M_LAST_ex <= r_wr_valid  & M_LAST_ex ? 0 : ( S_WSTRB_bit_buf & ~S_WSTRB_bit_buf_2 ? 1 : 0 );
                M_WVALID_ex <= r_wr_valid  & M_LAST_ex ? 0:1;
                state <= r_wr_valid  & M_LAST_ex ? 0 : state;
            end
            default:;
        endcase
    end
end

assign M_WVALID = S_WVALID | M_WVALID_ex  ;
assign M_WLAST =  (l_wr_valid &  S_WLAST & ~over_shreshold) |  (M_LAST_ex & last_flag) ;
assign  M_WSTRB =  ~M_WVALID_ex ? S_WSTRB : M_WSTRB_ex ;
assign M_WDATA =   ~M_WVALID_ex ? S_WDATA : M_WDATA_ex ;


assign l_wr_valid = S_WVALID & S_WREADY;
assign r_wr_valid = M_WVALID & M_WREADY;

assign S_WREADY = M_WVALID_ex ? 0:  M_WREADY ;//注意屏蔽对上的ready


end
//低位宽转高位宽////////////////////////////////////////////////////////////////////////////////////////////
else begin :smaller 

reg  M_WVALID_ex  =0;

//输出只需要移位即可  
 
wire  r_write_valid;
assign r_write_valid = M_WVALID & M_WREADY ;

wire l_write_valid;//已经虚拟化
                       //左侧是真实的写入         这里的话外部已经没有写入了，然后需要人为构造完整数据
assign l_write_valid = (S_WVALID  & S_WREADY) |  (S_WVALID_ex &  S_WREADY) ;

//没到last前，strobe全部填1，last之后strobe全部填0
    reg [7:0] state=0;
    reg [15:0]  cnt=0 ;
    
    reg last_flag=0;

    assign  M_WVALID = l_write_valid & cnt== SHRINK-1;
    
    wire [(IN_WIDTH)/8-1:0] S_WSTRB_w;
    
    reg  [OUT_WIDTH-1-IN_WIDTH:0]  M_WDATA_reg_short=0; 
    reg  [(OUT_WIDTH-IN_WIDTH)/8-1:0]  M_WSTRB_reg_short=0;
    
    assign  M_WDATA  = {S_WDATA,M_WDATA_reg_short} ;
    assign  M_WSTRB  = {last_flag?0:S_WSTRB,M_WSTRB_reg_short} ;

    //1 flag 影响strobe最高位的拼接内容
    //2 flag 影响打入第二级的值
    
    reg S_WREADY_ex =0;
    reg S_WVALID_ex=0;//本逻辑也需要人为构造

    assign S_WREADY = M_WREADY | S_WREADY_ex; //S_WREADY_ex 可以一直给上面 
   // reg last_flag =0;
    //reg [7:0] state;
    always@(posedge CLK)begin
        if(~RSTN)begin
            state <= 0;   
            S_WREADY_ex <= 0;   
            last_flag <= 0;            
        end
        else begin
            case(state)
                0:begin
                    if(M_WREADY)begin
                        //state <= 1;
                        //S_WREADY_ex <= 1;//对上给出虚假的ready(当然是和下级的ready做或的关系)
                        if(S_WVALID)begin
                            state <= 1;
                            S_WREADY_ex <= 1;
                            
                            
                            cnt <= cnt + 1;
                            
                            if(OUT_WIDTH/IN_WIDTH!=2)begin
                            M_WDATA_reg_short <= { S_WDATA,M_WDATA_reg_short[OUT_WIDTH-1-IN_WIDTH:IN_WIDTH] };//>>IN_WIDTH ;
                            M_WSTRB_reg_short <= { S_WSTRB,M_WSTRB_reg_short[(OUT_WIDTH-IN_WIDTH)/8-1:IN_WIDTH/8] };//>>IN_WIDTH/8 ;
                            end
                            else begin
                            M_WDATA_reg_short <= { S_WDATA };
                            M_WSTRB_reg_short <= { S_WSTRB };
                            end
                            
                            
                            if(S_WLAST)begin
                                last_flag <= 1;//flag==1意味着strobe用模拟值（组合逻辑）
                            end 
                            else begin
                                last_flag <= 0;
                            end
                            
                            
                            
                        end
                    end
                    else begin
                        S_WREADY_ex <= 0;
                    end
                end
                1:begin //l_write_valid ()   
                    
                    if(OUT_WIDTH/IN_WIDTH!=2)begin
                    M_WDATA_reg_short <= l_write_valid ? { S_WDATA,M_WDATA_reg_short[OUT_WIDTH-1-IN_WIDTH:IN_WIDTH] }  : M_WDATA_reg_short;//>>IN_WIDTH ;
                    M_WSTRB_reg_short <= l_write_valid ? { last_flag?0:S_WSTRB,M_WSTRB_reg_short[(OUT_WIDTH-IN_WIDTH)/8-1:IN_WIDTH/8] } : M_WSTRB_reg_short;//>>IN_WIDTH/8 ;
                    end
                    else begin
                    M_WDATA_reg_short <= l_write_valid ? { S_WDATA } : M_WDATA_reg_short ;
                    M_WSTRB_reg_short <= l_write_valid ? { S_WSTRB } : M_WSTRB_reg_short ;
                    end           

                         
                    last_flag <= l_write_valid ? (  cnt == SHRINK-1 ? 0 :  S_WLAST ? 1 : last_flag ) : last_flag;
                    cnt <= l_write_valid ? ( cnt == SHRINK-1 ? 0 :  cnt + 1) : cnt;
                    state       <= l_write_valid & (cnt == SHRINK-1) ? 0 :  state ;
                    S_WVALID_ex <= l_write_valid & (cnt == SHRINK-1) ? 0 :  last_flag ? 1 : S_WVALID_ex; //如果上级已经发完，则对下发出虚假的valid
                    S_WREADY_ex <= l_write_valid & (cnt == SHRINK-1) ? 0: 1;
                
                end
                //s端valid由上面决定; 
                default :;
            endcase
        end
    end
    
    assign M_WLAST =  (l_write_valid & ( cnt == SHRINK-1 )) & ( S_WLAST | last_flag )   ; 
    
    
      
end
endgenerate



endmodule



