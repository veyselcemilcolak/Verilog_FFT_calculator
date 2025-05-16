`timescale 1ns / 1ps

module MULT(
		input [31:0] opr1,
		input [31:0] opr2,
		
		output reg [31:0] res
    );
		
		localparam usual = 2'b00;
		localparam zero  = 2'b01;
		localparam inf   = 2'b10;
		localparam nan   = 2'b11;
		
		reg [1:0] in1_status;
		reg [1:0] in2_status;
		reg [1:0] out_status;	
		
		reg        sign1    ;
		reg        sign2    ;
		reg [7 :0]  exp1    ;
		reg [7 :0]  exp2    ;
		reg [22:0] frac1    ;
		reg [22:0] frac2    ;
		
		reg [23:0] num1 ;
		reg [23:0] num2 ;
	
		
		reg [47:0] res_tmp;
		reg        res_sgn;
		

		reg [7:0]  res_exp;

		
		reg signed [12:0] tmp_exp;
		
		reg [22:0] res_frac;
		reg [22:0] tmp_frac;

		
		always @(*)begin
		
				sign1 = opr1[31]   ;
				sign2 = opr2[31]   ;
				exp1  = opr1[30:23];
				exp2  = opr2[30:23];
				frac1 = opr1[22:0] ;
				frac2 = opr2[22:0] ;
				
				res_sgn = sign1^sign2;
				
				if(exp1 == 8'd255) begin
					if(frac1 == 23'd0) begin
						in1_status = inf;
					end else begin
						in1_status = nan;
					end
				end else if((exp1 == 8'd0)&&(frac1 == 23'd0)) begin
					in1_status = zero;
				end else begin
					in1_status = usual;
				end
				
				if(exp2 == 8'd255) begin
					if(frac2 == 23'd0) begin
						in2_status = inf;
					end else begin
						in2_status = nan;
					end
				end else if((exp2 == 8'd0)&&(frac2 == 23'd0)) begin
					in2_status = zero;
				end else begin
					in2_status = usual;
				end		
				
				if((in1_status == nan)||(in2_status==nan)) begin
					out_status = nan;
				end else if ((in1_status == inf)||(in2_status == inf)) begin
					out_status = inf;
				end else if ((in1_status == zero)||(in2_status == zero)) begin
					out_status = zero;
				end else begin
					num1 = {1'b1,frac1};
					num2 = {1'b1,frac2};
					
					res_tmp  = num1*num2;

					
					if (res_tmp[47]) begin
						tmp_frac = res_tmp[46:24];
					end
					else begin
						tmp_frac = res_tmp[45:23];
					end			
					
					tmp_exp = exp1 + exp2 + res_tmp[47] -7'd127;
					
					if (tmp_exp > 254) begin
						out_status = inf;
					end else if (tmp_exp ==0) begin
						if(tmp_frac==23'd0) begin
							out_status = zero;
						end else begin
							out_status = usual;
						end
					end else if (tmp_exp <0) begin
						out_status = zero;
					end else begin
						out_status = usual;
					end
					
					
				end
				
				
				
				case (out_status)
				usual: begin
					res_exp  = tmp_exp [7:0];
					res_frac = tmp_frac;
				end
				zero: begin
					res_exp  = 8'd0;
					res_frac = 23'd0;
				end
				inf: begin
					res_exp  = 8'd255;
					res_frac = 23'd0;
				end
				nan: begin
					res_exp  = 8'd255;
					res_frac = {15'd0,8'd15};
				end
				endcase
				
				
				res = {res_sgn, res_exp, res_frac};
		
		end

endmodule