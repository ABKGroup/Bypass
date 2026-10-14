// ----------------------------------------------
// File: iq_zgtarray.v
// Module: iq_zgtarray
// Function: data stack array for dc module 
// ----------------------------------------------

module iq_zgtarray( 
   clkdec, 
   rstdec_x, 
   v1_zgt00_a , 
   v1_zgt00_bs, 
   v1_zgt00_d , 
   v1_zgt00_we, 
   w1_zgt00_q ,
   v1_zgt01_a , 
   v1_zgt01_bs, 
   v1_zgt01_d , 
   v1_zgt01_we, 
   w1_zgt01_q 
   );

 input        clkdec; 
 input        rstdec_x; 
 input [8:0]  v1_zgt00_a; 
 input        v1_zgt00_bs; 
 input [11:0] v1_zgt00_d;
 input        v1_zgt00_we; 
 output[11:0] w1_zgt00_q;
 input [8:0]  v1_zgt01_a; 
 input        v1_zgt01_bs; 
 input [11:0] v1_zgt01_d;
 input        v1_zgt01_we; 
 output[11:0] w1_zgt01_q;

 reg [11:0]  w1_zgt00[511:0];
 reg [11:0]  w1_zgt01[511:0];
 integer    i;

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<512;i=i+1)
         w1_zgt00[i] <= 11'h000;       
     else if(!v1_zgt00_bs && !v1_zgt00_we)    
       w1_zgt00[v1_zgt00_a]  <= v1_zgt00_d;
 end
 assign  w1_zgt00_q = w1_zgt00[v1_zgt00_a];

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<512;i=i+1)
         w1_zgt01[i] <= 11'h000;       
     else if(!v1_zgt01_bs && !v1_zgt01_we)    
       w1_zgt01[v1_zgt01_a]  <= v1_zgt01_d;
 end

 assign  w1_zgt01_q = w1_zgt01[v1_zgt01_a];

endmodule



