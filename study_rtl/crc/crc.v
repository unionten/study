`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2021/11/26 16:28:40
// Design Name: 
// Module Name: crc16_xmodem_lut
//////////////////////////////////////////////////////////////////////////////////
module crc16_xmodem_lut(
input   RST_I,
input   CLK_I,
input   CRC_RST_I,
input   DATA_VALID_I,
input   [7:0] DATA_I,
output  [15:0] CHECKSUM_O
);
localparam [15:0] CRC16_INI_VALUE = 16'h0000;

assign CHECKSUM_O = current_crc;

reg [15:0] current_crc;
always@(posedge CLK_I)begin
    if(RST_I | CRC_RST_I)begin
        current_crc <= CRC16_INI_VALUE;
    end
    else begin
        if(DATA_VALID_I)begin
            current_crc <= new_crc;
        end
        else begin
            current_crc <= current_crc;
        end
    end
end

wire [7:0] rom_in;
assign rom_in = current_crc[15:8] ^ DATA_I[7:0];
reg [15:0] rom_out;
wire [15:0] new_crc;
assign new_crc = rom_out ^ {current_crc[7:0] ,8'b0};

//table https://www.cnblogs.com/21vicky21/archive/2010/11/08/2002931.html
always@(*)begin
    case(rom_in)
    8'd0  : rom_out = 16'h0000;
    8'd1  : rom_out = 16'h1021;
    8'd2  : rom_out = 16'h2042;
    8'd3  : rom_out = 16'h3063;
    8'd4  : rom_out = 16'h4084;
    8'd5  : rom_out = 16'h50A5;
    8'd6  : rom_out = 16'h60C6;
    8'd7  : rom_out = 16'h70E7;
    8'd8  : rom_out = 16'h8108;
    8'd9  : rom_out = 16'h9129;
    8'd10 : rom_out = 16'hA14A;
    8'd11 : rom_out = 16'hB16B;
    8'd12 : rom_out = 16'hC18C;
    8'd13 : rom_out = 16'hD1AD;
    8'd14 : rom_out = 16'hE1CE;
    8'd15 : rom_out = 16'hF1EF;
    8'd16 : rom_out = 16'h1231;
    8'd17 : rom_out = 16'h0210;
    8'd18 : rom_out = 16'h3273;
    8'd19 : rom_out = 16'h2252;
    8'd20 : rom_out = 16'h52B5;
    8'd21 : rom_out = 16'h4294;
    8'd22 : rom_out = 16'h72F7;
    8'd23 : rom_out = 16'h62D6;
    8'd24 : rom_out = 16'h9339;
    8'd25 : rom_out = 16'h8318;
    8'd26 : rom_out = 16'hB37B;
    8'd27 : rom_out = 16'hA35A;
    8'd28 : rom_out = 16'hD3BD;
    8'd29 : rom_out = 16'hC39C;
    8'd30 : rom_out = 16'hF3FF;
    8'd31 : rom_out = 16'hE3DE;
    8'd32 : rom_out = 16'h2462;
    8'd33 : rom_out = 16'h3443;
    8'd34 : rom_out = 16'h0420;
    8'd35 : rom_out = 16'h1401;
    8'd36 : rom_out = 16'h64E6;
    8'd37 : rom_out = 16'h74C7;
    8'd38 : rom_out = 16'h44A4;
    8'd39 : rom_out = 16'h5485;
    8'd40 : rom_out = 16'hA56A;
    8'd41 : rom_out = 16'hB54B;
    8'd42 : rom_out = 16'h8528;
    8'd43 : rom_out = 16'h9509;
    8'd44 : rom_out = 16'hE5EE;
    8'd45 : rom_out = 16'hF5CF;
    8'd46 : rom_out = 16'hC5AC;
    8'd47 : rom_out = 16'hD58D;
    8'd48 : rom_out = 16'h3653;
    8'd49 : rom_out = 16'h2672;
    8'd50 : rom_out = 16'h1611;
    8'd51 : rom_out = 16'h0630;
    8'd52 : rom_out = 16'h76D7;
    8'd53 : rom_out = 16'h66F6;
    8'd54 : rom_out = 16'h5695;
    8'd55 : rom_out = 16'h46B4;
    8'd56 : rom_out = 16'hB75B;
    8'd57 : rom_out = 16'hA77A;
    8'd58 : rom_out = 16'h9719;
    8'd59 : rom_out = 16'h8738;
    8'd60 : rom_out = 16'hF7DF;
    8'd61 : rom_out = 16'hE7FE;
    8'd62 : rom_out = 16'hD79D;
    8'd63 : rom_out = 16'hC7BC;
    8'd64 : rom_out = 16'h48C4;
    8'd65 : rom_out = 16'h58E5;
    8'd66 : rom_out = 16'h6886;
    8'd67 : rom_out = 16'h78A7;
    8'd68 : rom_out = 16'h0840;
    8'd69 : rom_out = 16'h1861;
    8'd70 : rom_out = 16'h2802;
    8'd71 : rom_out = 16'h3823;
    8'd72 : rom_out = 16'hC9CC;
    8'd73 : rom_out = 16'hD9ED;
    8'd74 : rom_out = 16'hE98E;
    8'd75 : rom_out = 16'hF9AF;
    8'd76 : rom_out = 16'h8948;
    8'd77 : rom_out = 16'h9969;
    8'd78 : rom_out = 16'hA90A;
    8'd79 : rom_out = 16'hB92B;
    8'd80 : rom_out = 16'h5AF5;
    8'd81 : rom_out = 16'h4AD4;
    8'd82 : rom_out = 16'h7AB7;
    8'd83 : rom_out = 16'h6A96;
    8'd84 : rom_out = 16'h1A71;
    8'd85 : rom_out = 16'h0A50;
    8'd86 : rom_out = 16'h3A33;
    8'd87 : rom_out = 16'h2A12;
    8'd88 : rom_out = 16'hDBFD;
    8'd89 : rom_out = 16'hCBDC;
    8'd90 : rom_out = 16'hFBBF;
    8'd91 : rom_out = 16'hEB9E;
    8'd92 : rom_out = 16'h9B79;
    8'd93 : rom_out = 16'h8B58;
    8'd94 : rom_out = 16'hBB3B;
    8'd95 : rom_out = 16'hAB1A;
    8'd96 : rom_out = 16'h6CA6;
    8'd97 : rom_out = 16'h7C87;
    8'd98 : rom_out = 16'h4CE4;
    8'd99 : rom_out = 16'h5CC5;
    8'd100: rom_out = 16'h2C22;
    8'd101: rom_out = 16'h3C03;
    8'd102: rom_out = 16'h0C60;
    8'd103: rom_out = 16'h1C41;
    8'd104: rom_out = 16'hEDAE;
    8'd105: rom_out = 16'hFD8F;
    8'd106: rom_out = 16'hCDEC;
    8'd107: rom_out = 16'hDDCD;
    8'd108: rom_out = 16'hAD2A;
    8'd109: rom_out = 16'hBD0B;
    8'd110: rom_out = 16'h8D68;
    8'd111: rom_out = 16'h9D49;
    8'd112: rom_out = 16'h7E97;
    8'd113: rom_out = 16'h6EB6;
    8'd114: rom_out = 16'h5ED5;
    8'd115: rom_out = 16'h4EF4;
    8'd116: rom_out = 16'h3E13;
    8'd117: rom_out = 16'h2E32;
    8'd118: rom_out = 16'h1E51;
    8'd119: rom_out = 16'h0E70;
    8'd120: rom_out = 16'hFF9F;
    8'd121: rom_out = 16'hEFBE;
    8'd122: rom_out = 16'hDFDD;
    8'd123: rom_out = 16'hCFFC;
    8'd124: rom_out = 16'hBF1B;
    8'd125: rom_out = 16'hAF3A;
    8'd126: rom_out = 16'h9F59;
    8'd127: rom_out = 16'h8F78;
    8'd128: rom_out = 16'h9188;
    8'd129: rom_out = 16'h81A9;
    8'd130: rom_out = 16'hB1CA;
    8'd131: rom_out = 16'hA1EB;
    8'd132: rom_out = 16'hD10C;
    8'd133: rom_out = 16'hC12D;
    8'd134: rom_out = 16'hF14E;
    8'd135: rom_out = 16'hE16F;
    8'd136: rom_out = 16'h1080;
    8'd137: rom_out = 16'h00A1;
    8'd138: rom_out = 16'h30C2;
    8'd139: rom_out = 16'h20E3;
    8'd140: rom_out = 16'h5004;
    8'd141: rom_out = 16'h4025;
    8'd142: rom_out = 16'h7046;
    8'd143: rom_out = 16'h6067;
    8'd144: rom_out = 16'h83B9;
    8'd145: rom_out = 16'h9398;
    8'd146: rom_out = 16'hA3FB;
    8'd147: rom_out = 16'hB3DA;
    8'd148: rom_out = 16'hC33D;
    8'd149: rom_out = 16'hD31C;
    8'd150: rom_out = 16'hE37F;
    8'd151: rom_out = 16'hF35E;
    8'd152: rom_out = 16'h02B1;
    8'd153: rom_out = 16'h1290;
    8'd154: rom_out = 16'h22F3;
    8'd155: rom_out = 16'h32D2;
    8'd156: rom_out = 16'h4235;
    8'd157: rom_out = 16'h5214;
    8'd158: rom_out = 16'h6277;
    8'd159: rom_out = 16'h7256;
    8'd160: rom_out = 16'hB5EA;
    8'd161: rom_out = 16'hA5CB;
    8'd162: rom_out = 16'h95A8;
    8'd163: rom_out = 16'h8589;
    8'd164: rom_out = 16'hF56E;
    8'd165: rom_out = 16'hE54F;
    8'd166: rom_out = 16'hD52C;
    8'd167: rom_out = 16'hC50D;
    8'd168: rom_out = 16'h34E2;
    8'd169: rom_out = 16'h24C3;
    8'd170: rom_out = 16'h14A0;
    8'd171: rom_out = 16'h0481;
    8'd172: rom_out = 16'h7466;
    8'd173: rom_out = 16'h6447;
    8'd174: rom_out = 16'h5424;
    8'd175: rom_out = 16'h4405;
    8'd176: rom_out = 16'hA7DB;
    8'd177: rom_out = 16'hB7FA;
    8'd178: rom_out = 16'h8799;
    8'd179: rom_out = 16'h97B8;
    8'd180: rom_out = 16'hE75F;
    8'd181: rom_out = 16'hF77E;
    8'd182: rom_out = 16'hC71D;
    8'd183: rom_out = 16'hD73C;
    8'd184: rom_out = 16'h26D3;
    8'd185: rom_out = 16'h36F2;
    8'd186: rom_out = 16'h0691;
    8'd187: rom_out = 16'h16B0;
    8'd188: rom_out = 16'h6657;
    8'd189: rom_out = 16'h7676;
    8'd190: rom_out = 16'h4615;
    8'd191: rom_out = 16'h5634;
    8'd192: rom_out = 16'hD94C;
    8'd193: rom_out = 16'hC96D;
    8'd194: rom_out = 16'hF90E;
    8'd195: rom_out = 16'hE92F;
    8'd196: rom_out = 16'h99C8;
    8'd197: rom_out = 16'h89E9;
    8'd198: rom_out = 16'hB98A;
    8'd199: rom_out = 16'hA9AB;
    8'd200: rom_out = 16'h5844;
    8'd201: rom_out = 16'h4865;
    8'd202: rom_out = 16'h7806;
    8'd203: rom_out = 16'h6827;
    8'd204: rom_out = 16'h18C0;
    8'd205: rom_out = 16'h08E1;
    8'd206: rom_out = 16'h3882;
    8'd207: rom_out = 16'h28A3;
    8'd208: rom_out = 16'hCB7D;
    8'd209: rom_out = 16'hDB5C;
    8'd210: rom_out = 16'hEB3F;
    8'd211: rom_out = 16'hFB1E;
    8'd212: rom_out = 16'h8BF9;
    8'd213: rom_out = 16'h9BD8;
    8'd214: rom_out = 16'hABBB;
    8'd215: rom_out = 16'hBB9A;
    8'd216: rom_out = 16'h4A75;
    8'd217: rom_out = 16'h5A54;
    8'd218: rom_out = 16'h6A37;
    8'd219: rom_out = 16'h7A16;
    8'd220: rom_out = 16'h0AF1;
    8'd221: rom_out = 16'h1AD0;
    8'd222: rom_out = 16'h2AB3;
    8'd223: rom_out = 16'h3A92;
    8'd224: rom_out = 16'hFD2E;
    8'd225: rom_out = 16'hED0F;
    8'd226: rom_out = 16'hDD6C;
    8'd227: rom_out = 16'hCD4D;
    8'd228: rom_out = 16'hBDAA;
    8'd229: rom_out = 16'hAD8B;
    8'd230: rom_out = 16'h9DE8;
    8'd231: rom_out = 16'h8DC9;
    8'd232: rom_out = 16'h7C26;
    8'd233: rom_out = 16'h6C07;
    8'd234: rom_out = 16'h5C64;
    8'd235: rom_out = 16'h4C45;
    8'd236: rom_out = 16'h3CA2;
    8'd237: rom_out = 16'h2C83;
    8'd238: rom_out = 16'h1CE0;
    8'd239: rom_out = 16'h0CC1;
    8'd240: rom_out = 16'hEF1F;
    8'd241: rom_out = 16'hFF3E;
    8'd242: rom_out = 16'hCF5D;
    8'd243: rom_out = 16'hDF7C;
    8'd244: rom_out = 16'hAF9B;
    8'd245: rom_out = 16'hBFBA;
    8'd246: rom_out = 16'h8FD9;
    8'd247: rom_out = 16'h9FF8;
    8'd248: rom_out = 16'h6E17;
    8'd249: rom_out = 16'h7E36;
    8'd250: rom_out = 16'h4E55;
    8'd251: rom_out = 16'h5E74;
    8'd252: rom_out = 16'h2E93;
    8'd253: rom_out = 16'h3EB2;
    8'd254: rom_out = 16'h0ED1;
    8'd255: rom_out = 16'h1EF0;
    default:rom_out = 0; 
endcase
end

 
endmodule
