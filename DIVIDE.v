`timescale 1ns / 1ps

module DIVIDE(
		input wire [31:0] opr1,   //opr1 / opr2
		input wire [31:0] opr2,
		output wire [31:0] res
    );
	
	reg [22:0] opr2_inv;
	
	always @* begin
		case(opr2[22:18])
			0: opr2_inv =  23'b00000000000000000000000;
			1: opr2_inv = 	23'b11110000011111000010000;
			2: opr2_inv =	23'b11100001111000011110001;
			3: opr2_inv =	23'b11010100000111010100001;
			4: opr2_inv =	23'b11000111000111000111001;
			5: opr2_inv =	23'b10111010110011111001001;
			6: opr2_inv =	23'b10101111001010000110110;
			7: opr2_inv =	23'b10100100000110100100001;
			8: opr2_inv =	23'b10011001100110011001101;
			9: opr2_inv =	23'b10001111100111000001100;
			10: opr2_inv =	23'b10000110000110000110001;
			11: opr2_inv =	23'b01111101000001011111010;
			12: opr2_inv =	23'b01110100010111010001100;
			13: opr2_inv =	23'b01101100000101101100001;
			14: opr2_inv =	23'b01100100001011001000011;
			15: opr2_inv =	23'b01011100100110001000001;
			16: opr2_inv =	23'b01010101010101010101011;
			17: opr2_inv =	23'b01001110010111100000101;
			18: opr2_inv =	23'b01000111101011100001010;
			19: opr2_inv =	23'b01000001010000010100001;
			20: opr2_inv =	23'b00111011000100111011001;
			21: opr2_inv =	23'b00110101001000011101000;
			22: opr2_inv =	23'b00101111011010000100110;
			23: opr2_inv =	23'b00101001111001000001001;
			24: opr2_inv =	23'b00100100100100100100101;
			25: opr2_inv =	23'b00011111011100000100100;
			26: opr2_inv =	23'b00011010011110111001011;
			27: opr2_inv =	23'b00010101101100011110011;
			28: opr2_inv =	23'b00010001000100010001001;
			29: opr2_inv =	23'b00001100100101110001010;
			30: opr2_inv =	23'b00001000010000100001000;
			31: opr2_inv =	23'b00000100000100000100001;
		endcase
	end
	
	wire exp_offset;
	assign exp_offset = (opr2[22:18]!= 0);
	
	wire nan;
	assign nan = ( (opr2[30:23] == 8'hff) && (opr2[22:0] != 23'd0) );
	
	wire opr2_zero, opr2_inf;
	assign opr2_zero = (opr2[30:0] == 31'd0);
	assign opr2_inf = (opr2[30:23] == 8'hff) && (opr2[22:0] == 23'd0);
	
	reg [31:0] opr2_temp;
	reg [7:0] opr2_temp_exp;
	
	always @* begin
		opr2_temp_exp = (8'd254 - opr2[30:23] - exp_offset);
		opr2_temp = {opr2[31], opr2_temp_exp, opr2_inv};
		if(nan)
			opr2_temp = opr2;
		else if(opr2_zero)
			opr2_temp = {opr2[31], 8'hff, 23'd0};
		else if(opr2_inf)
			opr2_temp = {opr2[31], 31'd0};
	end
	
	
	MULT mult0(.opr1(opr1), .opr2(opr2_temp), .res(res));
	
endmodule
