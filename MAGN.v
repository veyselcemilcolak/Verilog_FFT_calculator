`timescale 1ns / 1ps
module MAGN( input [31:0] re, input [31:0] im , output [31:0] magDB);
	 
	 wire [31:0] re2;
	 wire [31:0] im2;
	 wire [31:0] mag2;
	 wire [31:0] mag;
	 
	 MULT MR (.opr1(re), .opr2(re), .res(re2));
	 MULT MI (.opr1(im), .opr2(im), .res(im2));	

	 ADD  A0 (.opr1(re2),.opr2(im2), .res(mag2));
	 
	 SQRT S0 (.in(mag2),.out(mag));
	 
	 DB   DB0 (.in(mag), .out(magDB));


endmodule