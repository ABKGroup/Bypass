// ----------------------------------------------
// File: mc_iboarray.v
// Module: mc_iboarray
// Function: data stack array for mc module 
// ----------------------------------------------

module mc_iboarray( 
   clkdec, 
   rstdec_x, 
   v1_ibo00_a , 
   v1_ibo00_bs, 
   v1_ibo00_d , 
   v1_ibo00_we, 
   w1_ibo00_q ,
   v1_ibo01_a , 
   v1_ibo01_bs, 
   v1_ibo01_d , 
   v1_ibo01_we, 
   w1_ibo01_q 
   );

 input        clkdec; 
 input        rstdec_x; 
 input [6:0]  v1_ibo00_a; 
 input        v1_ibo00_bs; 
 input [17:0]  v1_ibo00_d;
 input        v1_ibo00_we; 
 output[17:0]  w1_ibo00_q;
 input [6:0]  v1_ibo01_a; 
 input        v1_ibo01_bs; 
 input [17:0]  v1_ibo01_d;
 input        v1_ibo01_we; 
 output[17:0]  w1_ibo01_q;

 reg [17:0]  w1_ibo00[127:0];
 reg [17:0]  w1_ibo01[127:0];
 integer    i;

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<128;i=i+1)
         w1_ibo00[i] <= 18'h00000;       
     else if(!v1_ibo00_bs)    
       if(!v1_ibo00_we)    
         w1_ibo00[v1_ibo00_a]  <= v1_ibo00_d;
 end
 assign  w1_ibo00_q = w1_ibo00[v1_ibo00_a];

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<128;i=i+1)
         w1_ibo01[i] <= 18'h00000;       
     else if(!v1_ibo01_bs)    
       if(!v1_ibo01_we)    
         w1_ibo01[v1_ibo01_a]  <= v1_ibo01_d;
 end
 assign  w1_ibo01_q = w1_ibo01[v1_ibo01_a];

endmodule



