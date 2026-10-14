// ----------------------------------------------
// File: mc_ibearray.v
// Module: mc_ibearray
// Function: data stack array for mc module 
// ----------------------------------------------

module mc_ibearray( 
   clkdec, 
   rstdec_x, 
   v1_ibe00_a , 
   v1_ibe00_bs, 
   v1_ibe00_d , 
   v1_ibe00_we, 
   w1_ibe00_q ,
   v1_ibe01_a , 
   v1_ibe01_bs, 
   v1_ibe01_d , 
   v1_ibe01_we, 
   w1_ibe01_q 
   );

 input        clkdec; 
 input        rstdec_x; 
 input [6:0]  v1_ibe00_a; 
 input        v1_ibe00_bs; 
 input [17:0]  v1_ibe00_d;
 input        v1_ibe00_we; 
 output[17:0]  w1_ibe00_q;
 input [6:0]  v1_ibe01_a; 
 input        v1_ibe01_bs; 
 input [17:0]  v1_ibe01_d;
 input        v1_ibe01_we; 
 output[17:0]  w1_ibe01_q;

 reg [17:0]  w1_ibe00[127:0];
 reg [17:0]  w1_ibe01[127:0];
 integer    i;

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<128;i=i+1)
         w1_ibe00[i] <= 18'h00000;       
     else if(!v1_ibe00_bs)    
       if(!v1_ibe00_we)    
         w1_ibe00[v1_ibe00_a]  <= v1_ibe00_d;
 end
 assign  w1_ibe00_q = w1_ibe00[v1_ibe00_a];

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<128;i=i+1)
         w1_ibe01[i] <= 18'h00000;       
     else if(!v1_ibe01_bs)    
       if(!v1_ibe01_we)    
         w1_ibe01[v1_ibe01_a]  <= v1_ibe01_d;
 end
 assign  w1_ibe01_q = w1_ibe01[v1_ibe01_a];

endmodule



