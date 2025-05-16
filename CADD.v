`timescale 1ns / 1ps

module C_ADD(
	input [31:0] re1,
	input [31:0] re2,
	input [31:0] im1,
	input [31:0] im2,
	
	output [31:0] re_o,
	output [31:0] im_o
	
    );

ADD A0 (.opr1(re1),.opr2(re2),.res(re_o));
ADD A1 (.opr1(im1),.opr2(im2),.res(im_o));


endmodule
