`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:13:44 07/02/2021 
// Design Name: 
// Module Name:    SUB 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module SUB(
		input [31:0] opr1,
		input [31:0] opr2,
		
		output [31:0] res
    );

	wire [31:0] min_opr2;
	
	assign min_opr2 = {~opr2[31],opr2[30:0]};
	
	ADD ADD0 (.opr1(opr1), .opr2(min_opr2), .res(res));
endmodule

