`timescale 1ns / 1ps

module W_fac_ram
#(parameter N = 4096)
(
    input clk,   
    input [$clog2(N)- 1:0] read_address,
    
    output [63:0] data_out  
);
    reg [63:0] memory [0:N-1];  //{32bit im, 32 bit reel}
    initial
        $readmemb("wfactors.mem", memory);
    
    reg [$clog2(N)- 1:0] read_address_int;
    
    always @(posedge clk) begin
        read_address_int <= read_address;
   end  
   
   assign data_out = memory[read_address_int];   
endmodule