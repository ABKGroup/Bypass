// ----------------------------------------------
// File: mc_ritarray.v
// Module: mc_ritarray
// Function: data stack array for mc module 
// ----------------------------------------------

module mc_ritarray( 
   clkdec, 
   rstdec_x, 
   v1_rit00_a , 
   v1_rit00_bs, 
   v1_rit00_d , 
   v1_rit00_we, 
   w1_rit00_q ,
   v1_rit01_a , 
   v1_rit01_bs, 
   v1_rit01_d , 
   v1_rit01_we, 
   w1_rit01_q 
   );

 input        clkdec; 
 input        rstdec_x; 
 input [7:0]  v1_rit00_a; 
 input        v1_rit00_bs; 
 input [15:0]  v1_rit00_d;
 input        v1_rit00_we; 
 output[15:0]  w1_rit00_q;
 input [7:0]  v1_rit01_a; 
 input        v1_rit01_bs; 
 input [15:0]  v1_rit01_d;
 input        v1_rit01_we; 
 output[15:0]  w1_rit01_q;

 reg [15:0]  w1_rit00[255:0];
 reg [15:0]  w1_rit01[255:0];
 integer    i;

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<256;i=i+1)
         w1_rit00[i] <= 16'h0000;
     else if(!v1_rit00_bs)    
       if(!v1_rit00_we)    
         w1_rit00[v1_rit00_a]  <= v1_rit00_d;
 end
 assign  w1_rit00_q = w1_rit00[v1_rit00_a];

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<256;i=i+1)
         w1_rit01[i] <= 16'h0000;
     else if(!v1_rit01_bs)    
       if(!v1_rit01_we)    
         w1_rit01[v1_rit01_a]  <= v1_rit01_d;
 end
 assign  w1_rit01_q = w1_rit01[v1_rit01_a];

endmodule



