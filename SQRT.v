`timescale 1ns / 1ps

module SQRT(
		input wire [31:0] in,
		output reg [31:0] out
    );
	 
	localparam [31:0] sqrt_2 = 32'b00111111101101010000010011110011;
	wire in_zero;
	wire in_nan;
	wire in_inf;
	wire in_neg;
	
	assign in_zero = (in[30:0] == 31'd0);
	assign in_inf = (in[30:23] == 8'hff) && (in[22:0] == 23'd0);
	assign in_nan = (in[30:23] == 8'hff) && (in[22:0] != 23'd0);
	assign in_neg = in[31];
	
	wire odd_exp;
	assign odd_exp = ~in[23];
	
	reg signed [7:0] temp_exp;
	reg [22:0] temp_mant;
	reg [31:0] temp_out;
	wire [31:0] mult_out;
	
	always @* begin
		temp_exp = in[30:23];
		temp_exp = temp_exp - 8'd127;
		temp_exp = temp_exp>>>1;
		temp_exp = temp_exp + 8'd127;
		temp_out = {1'b0, temp_exp, temp_mant};

		if(in_zero || in_nan)
			out = in;
		else if (in_inf && in_neg)
			out={1'b0, 8'hff, 23'd15};
		else if (in_inf && ~in_neg)
			out = in;
		else if(in_neg)
			out = {1'b0, 8'hff, 23'd15};
		else if(odd_exp)
			out = mult_out;
		else
			out = temp_out;
	end
	
	MULT mult0 (.opr1(temp_out), .opr2(sqrt_2), .res(mult_out));
	
	always @* begin
		case(in[22:18])
			 0 : temp_mant = 23'b00000000000000000000000;
			 1 : temp_mant = 23'b00000011111110000010000;
			 2 : temp_mant = 23'b00000111111000001111011;
			 3 : temp_mant = 23'b00001011101110110011000;
			 4 : temp_mant = 23'b00001111100001110110110;
			 5 : temp_mant = 23'b00010011010001100100000;
			 6 : temp_mant = 23'b00010110111110000011010;
			 7 : temp_mant = 23'b00011010100111011100100;
			 8 : temp_mant = 23'b00011110001101110111101;
			 9 : temp_mant = 23'b00100001110001011011100;
			10 : temp_mant = 23'b00100101010010001110110;
			11 : temp_mant = 23'b00101000110000010111110;
			12 : temp_mant = 23'b00101100001011111100011;
			13 : temp_mant = 23'b00101111100101000010001;
			14 : temp_mant = 23'b00110010111011101110100;
			15 : temp_mant = 23'b00110110010000000110010;
			16 : temp_mant = 23'b00111001100010001110001;
			17 : temp_mant = 23'b00111100110010001010101;
			18 : temp_mant = 23'b01000000000000000000000;
			19 : temp_mant = 23'b01000011001011110010010;
			20 : temp_mant = 23'b01000110010101100101011;
			21 : temp_mant = 23'b01001001011101011100111;
			22 : temp_mant = 23'b01001100100011011100001;
			23 : temp_mant = 23'b01001111100111100110110;
			24 : temp_mant = 23'b01010010101001111111101;
			25 : temp_mant = 23'b01010101101010101010000;
			26 : temp_mant = 23'b01011000101001101000101;
			27 : temp_mant = 23'b01011011100110111110011;
			28 : temp_mant = 23'b01011110100010101101111;
			29 : temp_mant = 23'b01100001011100111001100;
			30 : temp_mant = 23'b01100100010101100100000;
			31 : temp_mant = 23'b01100111001100101111100;
		endcase
	end


endmodule
