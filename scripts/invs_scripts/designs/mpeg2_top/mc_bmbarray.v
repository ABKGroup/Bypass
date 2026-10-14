// ----------------------------------------------
// File: mc_bmbarray.v
// Module: mc_bmbarray
// Function: data stack array for mc module 
// ----------------------------------------------

module mc_bmbarray( 
   clkdec, 
   rstdec_x, 
   v1_bmb00_a , 
   v1_bmb00_bs, 
   v1_bmb00_d , 
   v1_bmb00_we, 
   w1_bmb00_q ,
   v1_bmb01_a , 
   v1_bmb01_bs, 
   v1_bmb01_d , 
   v1_bmb01_we, 
   w1_bmb01_q ,
   v1_bmb02_a , 
   v1_bmb02_bs, 
   v1_bmb02_d , 
   v1_bmb02_we, 
   w1_bmb02_q
   );

 input        clkdec; 
 input        rstdec_x; 
 input [8:0]  v1_bmb00_a; 
 input        v1_bmb00_bs; 
 input [8:0]  v1_bmb00_d;
 input        v1_bmb00_we; 
 output[8:0]  w1_bmb00_q;
 input [8:0]  v1_bmb01_a; 
 input        v1_bmb01_bs; 
 input [8:0]  v1_bmb01_d;
 input        v1_bmb01_we; 
 output[8:0]  w1_bmb01_q;
 input [8:0]  v1_bmb02_a; 
 input        v1_bmb02_bs; 
 input [8:0]  v1_bmb02_d;
 input        v1_bmb02_we; 
 output[8:0]  w1_bmb02_q;

 reg [8:0]  w1_bmb00[511:0];
 reg [8:0]  w1_bmb01[511:0];
 reg [8:0]  w1_bmb02[511:0];
 integer    i;

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<512;i=i+1)
         w1_bmb00[i] <= 9'h000;       
     else if(!v1_bmb00_bs)    
       if(!v1_bmb00_we)    
         w1_bmb00[v1_bmb00_a]  <= v1_bmb00_d;
 end
 assign  w1_bmb00_q = w1_bmb00[v1_bmb00_a];

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<512;i=i+1)
         w1_bmb01[i] <= 9'h000;       
     else if(!v1_bmb01_bs)    
       if(!v1_bmb01_we)    
         w1_bmb01[v1_bmb01_a]  <= v1_bmb01_d;
 end
 assign  w1_bmb01_q = w1_bmb01[v1_bmb01_a];

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<512;i=i+1)
         w1_bmb02[i] <= 9'h000;       
     else if(!v1_bmb02_bs)    
       if(!v1_bmb02_we)    
         w1_bmb02[v1_bmb02_a]  <= v1_bmb02_d;
 end
 assign  w1_bmb02_q = w1_bmb02[v1_bmb02_a];

endmodule



