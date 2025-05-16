`timescale 1ns / 1ps

module C_MULT(
	input [31:0] re1,
	input [31:0] re2,
	input [31:0] im1,
	input [31:0] im2,
	
	output [31:0] re_o,
	output [31:0] im_o
	
    );

	wire [31:0] r1r2;
	wire [31:0] i1i2;
	wire [31:0] r1i2;
	wire [31:0] i1r2;

	MULT M0 (.opr1(re1), .opr2(re2), .res(r1r2));
	MULT M1 (.opr1(re1), .opr2(im2), .res(r1i2));
	MULT M2 (.opr1(im1), .opr2(re2), .res(i1r2));
	MULT M3 (.opr1(im1), .opr2(im2), .res(i1i2));
	
	SUB S0 (.opr1(r1r2), .opr2(i1i2), .res(re_o));
	ADD A0 (.opr1(r1i2), .opr2(i1r2), .res(im_o));

endmodule