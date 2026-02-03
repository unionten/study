`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// 
// Create Date: 2024/11/26 11:57:07
// Design Name: 
// Module Name: iic_pass_through
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 

//////////////////////////////////////////////////////////////////////////////////


module iic_pass_through(
input  CLK_I    ,
input  RST_I    ,
inout  S_SCL_IO ,
inout  S_SDA_IO ,
inout  M_SCL_IO ,
inout  M_SDA_IO 

);

// IO - BUF -> s_sda_i -->  m_sda_o --> BUF --> IO
//    ------<- s_sda_o <--  m_sda_i <--------

// in_en = 1 --> data dir is into fpga
wire s_scl_in_en ; 
wire m_scl_in_en ; 
reg s_sda_in_en ; 
reg m_sda_in_en ; 

wire s_sda_i ; 
wire s_sda_o ;
wire s_scl_i ;
wire s_scl_o ;


wire m_sda_i ;
wire m_sda_o ;
wire m_scl_i ;
wire m_scl_o ;


assign S_SDA_IO = s_sda_in_en ? 1'bz : s_sda_o ;
assign s_sda_i  = S_SDA_IO ; 

assign M_SDA_IO = m_sda_in_en ? 1'bz : m_sda_o ;
assign m_sda_i  = M_SDA_IO ;

assign S_SCL_IO = s_scl_in_en ? 1'bz : s_scl_o ;
assign s_scl_i  = S_SCL_IO ; 

assign M_SCL_IO = m_scl_in_en ? 1'bz : m_scl_o ;
assign m_scl_i  = M_SCL_IO ;


assign m_sda_o = s_sda_i ;
assign s_sda_o = m_sda_i ;

assign m_scl_o = s_scl_i ;
assign s_scl_o = m_scl_i ;
    

assign s_scl_in_en = 1 ;
assign m_scl_in_en = 0 ;


reg s_scl_i_reg  = 0;
reg s_sda_i_reg  = 0;
wire s_scl_pos ;
wire s_scl_neg ;
wire s_sda_pos ;
wire s_sda_neg ;
always@(posedge CLK_I)begin
    s_scl_i_reg <= s_scl_i ;
    s_sda_i_reg <= s_sda_i ; 
end 
assign s_scl_pos = ~s_scl_i_reg & s_scl_i  ;
assign s_scl_neg = s_scl_i_reg & ~s_scl_i  ;
assign s_sda_pos = ~s_sda_i_reg & s_sda_i  ;
assign s_sda_neg = s_sda_i_reg & ~s_sda_i  ;

wire start_sig ;
assign start_sig = s_scl_i & s_sda_neg ;

wire stop_sig ;
assign stop_sig =  s_scl_i & s_sda_pos ;


reg [7:0] cnt = 0 ;
reg wrn_rd  = 0;
reg [7:0] state = 0;
always@(posedge CLK_I)begin
    if(RST_I  | stop_sig)begin
        state       <= 0 ;
        s_sda_in_en <= 1 ;
        m_sda_in_en <= 0 ;
        cnt         <= 0 ;   
        wrn_rd      <= 0 ;
    end
    else if(start_sig)begin
        state <= 1 ;
        s_sda_in_en <= 1 ;
        m_sda_in_en <= 0 ;
        cnt         <= 0 ;   
        wrn_rd      <= 0 ;
    end
    else begin
        case(state)
            0:begin
                state <= start_sig ? 1 : 0 ;
            end
            1:begin
                cnt    <= s_scl_pos ? cnt + 1 : cnt ;
                wrn_rd <= s_scl_pos & cnt==7 ? s_sda_i : wrn_rd   ;
                s_sda_in_en <= s_scl_neg & cnt==8 ? 0 : 1 ;
                m_sda_in_en <= s_scl_neg & cnt==8 ? 1 : 0 ;
                state       <= s_scl_neg & cnt==8 ? 2 : state ;
            end
            2:begin//ack from slave always
                state <= s_scl_neg ? 3 : state ; 
                s_sda_in_en <= s_scl_neg  ?  ~wrn_rd  : s_sda_in_en  ; //只维持一个bit期，再把方向切换(根据读写标志)
                m_sda_in_en <= s_scl_neg  ?   wrn_rd  : m_sda_in_en  ;
                cnt <= 0;
            end
            3:begin
                cnt <= s_scl_pos ? cnt + 1 : cnt ;
                s_sda_in_en <= s_scl_neg & cnt==8 ? ~s_sda_in_en : s_sda_in_en ;//维持8个bit，切方向
                m_sda_in_en <= s_scl_neg & cnt==8 ? ~m_sda_in_en : m_sda_in_en ;
                state       <= s_scl_neg & cnt==8 ? 4 : state ;   
            end
            4:begin//ack from master or slave 
                state      <= s_scl_neg ? 3 : state ; 
                s_sda_in_en <= s_scl_neg ?  ~s_sda_in_en : s_sda_in_en ; //维持1个bit，切方向
                m_sda_in_en <= s_scl_neg ?  ~m_sda_in_en : m_sda_in_en ;
                cnt <= 0;
            end
            default:;
        endcase
    end
end


  
    
endmodule




