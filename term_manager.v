`timescale 1ns / 1ps

module term_manager
    #(parameter N = 16,
    parameter LEVEL = $clog2(N) )
    (
    input clk,
    input fft_start, 
    
    output [LEVEL-1:0] w_index,      
    output [LEVEL-1:0] mult_data_index,    
    output [LEVEL-1:0] const_data_index,
    
    output reg [LEVEL-1:0] write_index, 
    
    output reg wr_en_1 = 0,     //initial bram write enable
    output reg wr_en_2 = /*1*/ 0,    //other                              //////////////////////////
    output reg fft_busy=0, 
    output reg fft_done=0
    );
    /////////
//    reg clk = 0;
//    always #5 clk = ~clk;
//    reg fft_start = 0;
//    initial begin
//        #1000 fft_start = 1;
//        #400 fft_start = 0;
//    end
//    /////////
    
    function [LEVEL-1:0] reverse_bit_order;
        input [LEVEL-1:0] data_in; 
        integer i;
        begin
            for(i=0;i<LEVEL; i=i+1)
               reverse_bit_order[i] = data_in[LEVEL-1-i];
        end
    endfunction
    
    reg [$clog2(LEVEL)-1:0] stage_index = 0;
    reg [LEVEL-1:0] sample_index = 0;
    reg [LEVEL-1:0] const_index_temp;  
    reg [LEVEL-1:0] mult_index_temp;   
    
    always @(posedge clk) begin
        write_index <= sample_index;
    end
    
    always @(posedge clk) begin
        if(fft_start)
            fft_busy <= 1;
        if(fft_done)
            fft_busy <= 0;
    end
            
    
    wire fft_start_int;
    assign fft_start_int = fft_start;
    
    always@(posedge clk) begin
        if(fft_start_int) begin
            wr_en_1 <= 0;
            wr_en_2 <= 1;
        end
        else begin
            if(write_index==N-1) begin
                if(fft_done) begin               //check 
                    wr_en_1 <= 0;
                    wr_en_2 <= 0;
                end
                else begin  
                    wr_en_1 <= ~wr_en_1;
                    wr_en_2 <= ~wr_en_2;
                end
            end
        end
    end
    
    always @(posedge clk) begin
        if(fft_start_int) begin
            sample_index <=0;
            stage_index <=0;
            fft_done <= 0;  
        end
        else begin
            if(fft_busy) begin
                if(sample_index == (N-1) ) begin
                    sample_index <=0;
                    stage_index <= stage_index + 1;
                    if(stage_index==LEVEL-1)
                        fft_done <= 1;
                end
                else begin
                    sample_index <= sample_index + 1;
                end
            end
        end
    end
    
    reg [LEVEL-1:0] w_index_int = 0;
    reg [LEVEL-1:0] w_index_offset = {1'b1, {(LEVEL-1){1'b0}} };
    
    always @(posedge clk) begin
        if(fft_start_int) begin
            w_index_offset <= {1'b1, {(LEVEL-1){1'b0}} };
        end                        ///may be comb
        else begin 
            if(sample_index == (N-1) ) 
                w_index_offset <= w_index_offset>>1 ;
        end     
    end
    
    always @(posedge clk) begin
        if(fft_start_int)
            w_index_int <= 0;
        else
            w_index_int <= w_index_int + w_index_offset;
    end
    
    assign w_index = w_index_int;
    //assign w_index = ( N>>(stage_index+1) ) * sample_index[stage_index:0];
    
    always @* begin
        const_index_temp =  sample_index;
        const_index_temp[stage_index] =0;
        if(stage_index==0)
            const_index_temp = reverse_bit_order(const_index_temp);
    end
    
    assign const_data_index = const_index_temp;
        
    always @* begin
        mult_index_temp = sample_index; 
        mult_index_temp[stage_index] = 1;
        if(stage_index==0)
            mult_index_temp = reverse_bit_order(mult_index_temp);
    end
   
    assign mult_data_index = mult_index_temp;
    
    
    
    
endmodule
