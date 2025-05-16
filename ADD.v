`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:54:30 07/06/2021 
// Design Name: 
// Module Name:    ADD 
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
module ADD(

  input [31:0] opr1,
  input [31:0] opr2,
  
  output reg [31:0] res);

 

  localparam usual = 2'b00;
  localparam zero = 2'b01;
  localparam inf = 2'b10;
  localparam nan = 2'b11;

 

  reg [1:0] in1_status;
  reg [1:0] in2_status;
  reg [1:0] out_status;

  

  reg sign1 ;
  reg sign2 ;
  reg [7 :0] exp1 ;
  reg [7 :0] exp2 ;
  reg [22:0] frac1 ;
  reg [22:0] frac2 ;
 

  reg [23:0] num1 ;
  reg [23:0] num2 ;

 

  reg [24:0] res_tmp;
  reg res_sgn;
  reg [7:0] res_exp;
  reg signed [9:0] tmp_exp;
  reg [5:0] loc;

  reg [22:0] res_frac;
  reg [22:0] tmp_frac;
  reg high;
  reg eq;
 

  always @(*) begin

 

    sign1 = opr1[31] ;
    sign2 = opr2[31] ;
    exp1 = opr1[30:23];
    exp2 = opr2[30:23];
    frac1 = opr1[22:0] ;
    frac2 = opr2[22:0] ;

   

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
     res_sgn = 1'b0;
    end else if ((in1_status == inf)^(in2_status == inf)) begin
     out_status = inf;
     if (in1_status == inf) begin
      res_sgn = sign1;
     end else begin
      res_sgn = sign2;
     end
    end else if ((in1_status == inf)&&(in2_status == inf)) begin
     if (sign1==sign2) begin
      out_status = inf;
      res_sgn = sign1;
     end else begin
      out_status = nan;
      res_sgn = 1'b0;
	  end
    end else begin
   
       if(exp2>exp1) begin
        num1 = ({1'b1,frac1})>>(exp2-exp1);
        num2 = {1'b1,frac2};
        high = 0;
        eq = 0;
       end else if(exp1>exp2) begin
        num2 = ({1'b1,frac2})>>(exp1-exp2);
        num1 = {1'b1,frac1};
        high = 1;
        eq = 0;
       end else begin
         if (frac1>frac2) begin
           num1 = {1'b1,frac1};
           num2 = {1'b1,frac2};
           high = 1;
           eq = 0;
         end else if (frac2>frac1) begin
           num1 = {1'b1,frac1};
           num2 = {1'b1,frac2};
           high = 0;
           eq = 0;
         end else begin
           num1 = {1'b1,frac1};
           num2 = {1'b1,frac2};
           high = 0;
           eq = 1;
         end
       end  

     
       if (sign1==sign2) begin
         res_sgn = sign1;
         res_tmp = num1+num2;
       end else begin
         if(eq)begin
//           out_status = zero;
			   res_sgn = 1'b0;
			   res_tmp = 25'd0;   /////////////////
         end else if (high) begin
           res_sgn = sign1;
           res_tmp = num1-num2;
         end else begin
           res_sgn = sign2;
           res_tmp = num2-num1;          
         end
       end



        if (res_tmp[24]) begin
         loc = 0;
        end else if (res_tmp[23]) begin
         loc = 1;
        end else if (res_tmp[22]) begin
         loc = 2;
        end else if (res_tmp[21]) begin
         loc = 3;
        end else if (res_tmp[20]) begin
         loc = 4;
        end else if (res_tmp[19]) begin
         loc = 5;
        end else if (res_tmp[18]) begin
         loc = 6;
        end else if (res_tmp[17]) begin
         loc = 7;
        end else if (res_tmp[16]) begin
         loc = 8;
        end else if (res_tmp[15]) begin
         loc = 9;
        end else if (res_tmp[14]) begin
         loc = 10;
        end else if (res_tmp[13]) begin
         loc = 11;
        end else if (res_tmp[12]) begin
         loc = 12;
        end else if (res_tmp[11]) begin
         loc = 13;
        end else if (res_tmp[10]) begin
         loc = 14;
        end else if (res_tmp[9]) begin
         loc = 15;
        end else if (res_tmp[8]) begin
         loc = 16;
        end else if (res_tmp[7]) begin
         loc = 17;
        end else if (res_tmp[6]) begin
         loc = 18;
        end else if (res_tmp[5]) begin
         loc = 19;
        end else if (res_tmp[4]) begin
         loc = 20;
        end else if (res_tmp[3]) begin
         loc = 21;
        end else if (res_tmp[2]) begin
         loc = 22;
        end else if (res_tmp[1]) begin
         loc = 23;
        end else if (res_tmp[0]) begin
         loc = 24;
        end else begin
         loc = 25;
        end

       

        res_tmp = res_tmp << loc; // Dikkat: loc kadar kuvvet arttýrdým, exp kýsmýný loc kadar azalt.
        tmp_frac = res_tmp[23:1]; //lsb discarded, add 1 to exp.
    

        if (exp1>exp2) begin
               tmp_exp = exp1 + 1'b1 - loc;
        end else begin
               tmp_exp = exp2 + 1'b1 - loc;
        end

       

        if (loc ==6'd25) begin
			out_status = zero;
        end else if (tmp_exp > 254) begin
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
     res_exp = tmp_exp [7:0];
     res_frac = tmp_frac;
    end
    zero: begin
     res_exp = 8'd0;
     res_frac = 23'd0;
    end
    inf: begin
     res_exp = 8'd255;
     res_frac = 23'd0;
    end
    nan: begin
     res_exp = 8'd255;
     res_frac = {15'd0,8'd15};
    end
    endcase

    res = {res_sgn, res_exp, res_frac};

  end

endmodule