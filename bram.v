`timescale 1ns / 1ps

module bram1
#(parameter N = 4096)
(
    input clk,
    input wr_en,
    
    input [$clog2(N)- 1:0] address_1,
    input [$clog2(N)- 1:0] address_2,
    
    input [$clog2(N)- 1:0] address_w,
    input [63:0] data_in_1,
    
    output [63:0] data_out_1,
    output [63:0] data_out_2   
);
    reg [63:0] memory [0:N-1];
    initial 
        $readmemb("new_sample.mem", memory);
    
    reg [$clog2(N)- 1:0] read_address_1;
    reg [$clog2(N)- 1:0] read_address_2;
    
    always @(posedge clk) begin
        if(wr_en) begin
            memory[address_w] <= data_in_1;
        end
        read_address_1 <= address_1;
        read_address_2 <= address_2; 
   end  
   
   assign data_out_1 = memory[read_address_1];
   assign data_out_2 = memory[read_address_2];     
endmodule