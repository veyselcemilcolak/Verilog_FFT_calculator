`timescale 1ns / 1ps
module phase (input[31:0] re, input [31:0] im, output reg[31:0] angle );

  

  wire [31:0] regn14angle;

  wire [31:0] regn23angle;

 

  wire [31:0] slope;

 

  DIVIDE DO (.opr1(im), .opr2(re), .res(slope));

 

  arctan a (.x(slope), .arctanx(regn14angle));

 

  ADD A0 (.opr1(regn14angle), .opr2(32'h40490FDB), .res(regn23angle));

 

  always @(*) begin

    if(re[31])begin

      angle = regn23angle;

    end else begin

      angle = regn14angle;

    end

  end

 

endmodule