// ----------------------------------------------
// File: bdc_rcnarray.v
// Module: bdc_rcnarray
// Function: data stack array for dc module 
// ----------------------------------------------

module bdc_rcnarray( 
  clkdec, 
  rstdec_x, 
  v1_rcn00_a , 
  v1_rcn00_bs, 
  v1_rcn00_d , 
  v1_rcn00_we, 
  w1_rcn00_q ,
  v1_rcn01_a , 
  v1_rcn01_bs, 
  v1_rcn01_d , 
  v1_rcn01_we, 
  w1_rcn01_q ,
  v1_rcn02_a , 
  v1_rcn02_bs, 
  v1_rcn02_d , 
  v1_rcn02_we, 
  w1_rcn02_q 
);

 input        clkdec; 
 input        rstdec_x; 
 input [5:0]  v1_rcn00_a; 
 input        v1_rcn00_bs; 
 input [63:0] v1_rcn00_d;
 input        v1_rcn00_we; 
 output[63:0] w1_rcn00_q;
 input [5:0]  v1_rcn01_a; 
 input        v1_rcn01_bs; 
 input [63:0] v1_rcn01_d;
 input        v1_rcn01_we; 
 output[63:0] w1_rcn01_q;
 input [5:0]  v1_rcn02_a; 
 input        v1_rcn02_bs; 
 input [63:0] v1_rcn02_d;
 input        v1_rcn02_we; 
 output[63:0] w1_rcn02_q;

 reg  [63:0]  w1_rcn00[63:0];
 reg  [63:0]  w1_rcn01[63:0];
 reg  [63:0]  w1_rcn02[63:0];
 integer i;

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<64;i=i+1)
         w1_rcn00[i] <= 64'h00000000;       
     else if(!v1_rcn00_bs)    
       if(!v1_rcn00_we)
         w1_rcn00[v1_rcn00_a]  <= v1_rcn00_d;
 end
 assign w1_rcn00_q = w1_rcn00[v1_rcn00_a];

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<64;i=i+1)
         w1_rcn01[i] <= 64'h00000000;       
     else if(!v1_rcn01_bs)    
       if(!v1_rcn01_we)    
         w1_rcn01[v1_rcn01_a]  <= v1_rcn01_d;
 end
 assign w1_rcn01_q = w1_rcn01[v1_rcn01_a];

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<64;i=i+1)
         w1_rcn02[i] <= 64'h00000000;       
     else if(!v1_rcn02_bs)    
       if(!v1_rcn02_we)    
         w1_rcn02[v1_rcn02_a]  <= v1_rcn02_d;
 end
 assign w1_rcn02_q = w1_rcn02[v1_rcn02_a];


endmodule



