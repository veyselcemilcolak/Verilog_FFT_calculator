`timescale 1ns / 1ps

module arctan(input [31:0] x, output [31:0] arctanx);

 

  localparam usual = 2'b00;

  localparam zero  = 2'b01;

  localparam inf   = 2'b10;

  localparam nan   = 2'b11;

 

  wire        in_sgn      ;

  wire [30:0] in_exp_frac ;

  wire [7:0]  in_exp      ;
  
  wire [22:0] in_frac     ;
   

  reg [1:0] in_status ;

  reg [1:0] out_status;

  

  wire [31:0] absx ;

  wire [31:0] x2   ;

  wire [31:0] x3   ;

  wire [31:0] recip; 

 

  wire [31:0] coe_h_recip,coe_h_const;

  wire [31:0] coe_mid23,coe_mid22,coe_mid21,coe_mid20;

  wire [31:0] coe_mid12,coe_mid11,coe_mid10;

  wire [31:0] coe_low3,coe_low1; 

  

  assign coe_h_recip = 32'hBF800000;

  assign coe_h_const = 32'h3FC90FDB;

  assign coe_mid23   = 32'h3CDFA440;

  assign coe_mid22   = 32'hBE87FCB9;

  assign coe_mid21   = 32'h3F70EBEE;

  assign coe_mid20   = 32'h3D989375; 

  assign coe_mid12   = 32'hBE9BB2FF; 

  assign coe_mid11   = 32'h3F8C9518;

  assign coe_mid10   = 32'hBC16BB99;
  
  wire [31:0] low3,low1;
  assign low3        = 32'hBEAAAAAB;

  assign low1        = 32'h3F800000;

 

  wire [31:0] h_recip;

  wire [31:0] mid23,mid22,mid21;

  wire [31:0] mid12,mid11;

  

 

  wire [31:0] h_est, m2_est, m1_est, low_est;

 

  wire [31:0] a,b,c;


  wire       out_sgn     ;

  reg [30:0] out_exp_frac;
  
 

  assign in_sgn       = x[31]   ;

  assign in_exp_frac  = x[30:0] ;

  assign in_exp       = x[30:23];
  
  assign in_frac      = x[22:0];
 

 

  assign out_sgn = in_sgn;

  assign absx = {1'b0,in_exp_frac};

 

  

  MULT M0(.opr1(absx),.opr2(absx),.res(x2));

  MULT M1(.opr1(x2),.opr2(absx),.res(x3));

  DIVIDE D0 (.opr1(32'h3F800000),.opr2(absx),.res(recip));

 

  MULT M2(.opr1(recip),.opr2(coe_h_recip),.res(h_recip));

 

  MULT M3(.opr1(x3),.opr2(coe_mid23),.res(mid23));

  MULT M4(.opr1(x2),.opr2(coe_mid22),.res(mid22));

  MULT M5(.opr1(absx),.opr2(coe_mid21),.res(mid21));

  MULT M6(.opr1(x2),.opr2(coe_mid12),.res(mid12));

  MULT M7(.opr1(absx),.opr2(coe_mid11),.res(mid11));

  MULT M8(.opr1(x3),.opr2(coe_low3),.res(low3));

  MULT M9(.opr1(absx),.opr2(coe_low1),.res(low1));

 

  ADD A0 (.opr1(h_recip),.opr2(coe_h_const),.res(h_est));

  ADD A1 (.opr1(mid23),.opr2(mid22),.res(a));

  ADD A2 (.opr1(a),.opr2(mid21),.res(b));

  ADD A3 (.opr1(b),.opr2(coe_mid20),.res(m2_est));

  ADD A4 (.opr1(mid12),.opr2(mid11),.res(c));

  ADD A5 (.opr1(c),.opr2(coe_mid10),.res(m1_est));

  ADD A6 (.opr1(low3),.opr2(low1),.res(low_est));

 

  assign arctanx = {out_sgn,out_exp_frac};

 

  always @(*) begin

    

    if(in_exp == 8'd255) begin

      if(in_frac == 23'd0) begin

      in_status = inf;

     end else begin

      in_status = nan;

     end

    end else if((in_exp == 8'd0)&&(in_frac == 23'd0)) begin

     in_status = zero;

    end else begin

     in_status = usual;

    end

   

    if (in_status == nan) begin

                  out_exp_frac = in_exp_frac;

    end else if (in_status == inf ) begin

      out_exp_frac = coe_h_const[30:0];

    end else if (in_status == zero) begin 

                  out_exp_frac = in_exp_frac;

    end else begin

      if (in_exp>8'd128)begin

        out_exp_frac = h_est[30:0];

      end else if (in_exp >8'd126) begin

        out_exp_frac = m2_est[30:0];

      end else if (in_exp >8'd125) begin

        out_exp_frac = m1_est[30:0];

      end else begin

        out_exp_frac = low_est[30:0];       

      end

    end

   

    

  end

 

  

  

endmodule