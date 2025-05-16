`timescale 1ns / 1ps

module SINGLE_FFT
    #(parameter N=4096)
    (
    input clk,
    input fft_start,
    input read_en,
   input [$clog2(N)-1:0]read_addr1,
    input [$clog2(N)-1:0]read_addr2,
    output fft_busy_o,
    output fft_done_o,
    output [63:0]data_out
    
    );
      localparam LEVEL = $clog2(N);
    
//   ////   FOR SIMULATION    /////
//    reg clk=0;                   
//    always #5 clk=~clk;
//    reg fft_start = 0;
//    //////////////////////////

    
  
    
    wire [63:0] wfac;
    wire [31:0] wfac_real;
    wire [31:0] wfac_im;
    assign wfac_im = wfac[63:32];
    assign wfac_real = wfac[31:0];
    
    wire [LEVEL-1:0] wfac_index; 
    W_fac_ram #(.N(N)) wfacram (.clk(clk), .read_address(wfac_index),.data_out(wfac));
    
         
    wire [LEVEL-1:0] mult_data_index; 
    wire [LEVEL-1:0] const_data_index;
    wire [LEVEL-1:0] write_index;
    wire wr_en_1;     //initial bram write enable
    wire wr_en_2;    //other
    wire fft_done;
    wire fft_busy;
    term_manager #(.N(N)) term_manager0 (
         .clk(clk),
         .fft_start(fft_start), 
         .w_index(wfac_index),
         .mult_data_index(mult_data_index),
         .const_data_index(const_data_index),
         .write_index(write_index),
         .wr_en_1(wr_en_1),
         .wr_en_2(wr_en_2),
         .fft_busy(fft_busy),
         .fft_done(fft_done)
          ) ;
          
     wire [63:0] bram1_const , bram1_mult;
     wire [31:0] bram1_const_real, bram1_const_im, bram1_mult_real, bram1_mult_im;
     assign bram1_const_im = bram1_const[63:32];
     assign bram1_const_real = bram1_const[31:0];
     assign bram1_mult_im = bram1_mult[63:32];
     assign bram1_mult_real = bram1_mult[31:0];
     
     wire [63:0] write_data;  
     wire [31:0] write_data_real, write_data_im;
     assign write_data_im = write_data[63:32];
     assign write_data_real = write_data[31:0];
     reg [LEVEL-1:0] rd_addr_1;
     reg [LEVEL-1:0] rd_addr_2;
     bram1 #(.N(N)) bram_1  
        (
         .clk(clk),
         .wr_en(wr_en_1),
         .address_1(rd_addr_1),
         .address_2(rd_addr_2),
         .address_w(write_index),
         .data_in_1(write_data),
         .data_out_1(bram1_const),
         .data_out_2(bram1_mult)   
        );
     always @* begin
        rd_addr_1 = const_data_index;
        rd_addr_2 = mult_data_index;
        if(read_en && fft_done) begin
            rd_addr_1 = read_addr1 ;
            rd_addr_2 = read_addr2;
        end
     end
     
     wire [63:0] bram2_const , bram2_mult; 
     wire [31:0] bram2_const_real, bram2_const_im, bram2_mult_real, bram2_mult_im;
     
     assign bram2_const_real = bram2_const[31:0];
     assign bram2_const_im = bram2_const[63:32]; 
     assign bram2_mult_real = bram2_mult[31:0];
     assign bram2_mult_im = bram2_mult[63:32]; 
     
     bram2 #(.N(N)) bram_2  
        (
         .clk(clk),
         .wr_en(wr_en_2),
         .address_1(const_data_index),
         .address_2(mult_data_index),
         .address_w(write_index),
         .data_in_1(write_data),
         .data_out_1(bram2_const),
         .data_out_2(bram2_mult)   
        );
     
     reg [63:0] data_const_to_process;
     wire [31:0] data_const_to_process_real, data_const_to_process_im;
     assign data_const_to_process_real = data_const_to_process[31:0];
     assign  data_const_to_process_im = data_const_to_process[63:32];
     
     reg [63:0] data_mult_to_process;
     wire [31:0] data_mult_to_process_real, data_mult_to_process_im;
     assign  data_mult_to_process_real = data_mult_to_process[31:0];
     assign data_mult_to_process_im = data_mult_to_process[63:32];
     
     
     //MUXing outputs
     always @* begin
        if(wr_en_2) begin
            data_const_to_process = bram1_const;
            data_mult_to_process = bram1_mult;
        end
        else begin
            data_const_to_process = bram2_const;
            data_mult_to_process = bram2_mult;
        end
     end  
     
     wire [63:0] data_int_process;
     wire [31:0] data_int_process_real, data_int_process_im;
     assign data_int_process_real = data_int_process[31:0];
     assign data_int_process_im = data_int_process[63:32];
     
     C_MULT complex_mult0(
        .re1(data_mult_to_process[31:0]),
	    .re2(wfac[31:0]),
	    .im1(data_mult_to_process[63:32]),
	    .im2(wfac[63:32]),
	    .re_o(data_int_process[31:0]),
	    .im_o(data_int_process[63:32])
	 );
	 
	 C_ADD complex_add0(
	    .re1(data_const_to_process[31:0]),
	    .re2(data_int_process[31:0]),
	    .im1(data_const_to_process[63:32]),
	    .im2(data_int_process[63:32]),
	    .re_o(write_data[31:0]),
        .im_o(write_data[63:32])
	
    );
    
    assign fft_busy_o = fft_busy;
    assign fft_done_o = fft_done;
    assign data_out = write_data;
    
//    //////////// SIMULATION ////////
//        integer fp_real, fp_im, bin_real, bin_in;

//    reg [LEVEL+20:0]count=0;
//    always @(posedge clk)
//        count<= count+1;
    
    
//    initial begin
//        #40 fft_start = 1;
//        #10 fft_start = 0;
//    end
//    initial begin
//        $dumpfile("fft_in_600_50.vcd");
//        $dumpvars();
//		fp_real = $fopen("fft_real.txt","w");
//        fp_im = $fopen("fft_imag.txt","w");
//        bin_real = $fopen("fft_real_bin.txt","w");
//        bin_in = $fopen("fft_imag_bin.txt","w");
        
//        #5;
	
//        while(( count<50000)) begin
//            #10;
//                $fwrite(fp_real, "%d\n",write_data[31:0]);
//                $fwrite(fp_im, "%d\n",write_data[63:32]);
//                $fwrite(bin_real, "%b\n",write_data[31:0]);
//                $fwrite(bin_in, "%b\n",write_data[63:32]);
            
//        end
       
//    end
            
//    /////////////////////////////
	
endmodule
