// ----------------------------------------------
// File: idct_trparray.v
// Module: idct_trparray
// Function: data stack array for dc module 
// ----------------------------------------------

module idct_trparray( 
   clkdec, 
   rstdec_x, 
   v1_trp00_a , 
   v1_trp00_bs, 
   v1_trp00_d , 
   v1_trp00_we, 
   w1_trp00_q ,
   v1_trp01_a , 
   v1_trp01_bs, 
   v1_trp01_d , 
   v1_trp01_we, 
   w1_trp01_q 
   );

 input        clkdec; 
 input        rstdec_x; 
 input [5:0]  v1_trp00_a; 
 input        v1_trp00_bs; 
 input [15:0] v1_trp00_d;
 input        v1_trp00_we; 
 output[15:0] w1_trp00_q;
 input [5:0]  v1_trp01_a; 
 input        v1_trp01_bs; 
 input [15:0] v1_trp01_d;
 input        v1_trp01_we; 
 output[15:0] w1_trp01_q;

 reg [15:0]  w1_trp00[63:0];
 reg [15:0]  w1_trp01[63:0];
 integer    i;

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<64;i=i+1)
         w1_trp00[i] <= 16'h0000;       
     else if(!v1_trp00_bs)    
       if(!v1_trp00_we)    
         w1_trp00[v1_trp00_a]  <= v1_trp00_d;
 end
 assign  w1_trp00_q = w1_trp00[v1_trp00_a];

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<64;i=i+1)
         w1_trp01[i] <= 16'h0000;       
     else if(!v1_trp01_bs)    
       if(!v1_trp01_we)    
         w1_trp01[v1_trp01_a]  <= v1_trp01_d;
 end
 assign  w1_trp01_q = w1_trp01[v1_trp01_a];

endmodule



