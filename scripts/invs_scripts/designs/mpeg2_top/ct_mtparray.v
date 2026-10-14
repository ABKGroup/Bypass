// ----------------------------------------------
// File: ct_mtparray.v
// Module: ct_mtparray
// Function: data stack array for cntrl module 
// ----------------------------------------------

module ct_mtparray ( 
   clkdec, 
   rstdec_x, 
   v1_mtp00_a, 
   v1_mtp00_bs, 
   v1_mtp00_d, 
   v1_mtp00_we, 
   w1_mtp00_q
   );

 input        clkdec; 
 input        rstdec_x; 
 input [6:0]  v1_mtp00_a; 
 input        v1_mtp00_bs; 
 input [7:0]  v1_mtp00_d;
 input        v1_mtp00_we; 
 output[7:0]  w1_mtp00_q;

 reg [7:0]  w1_mtp00[127:0];
 integer    i;


 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<128;i=i+1)
         w1_mtp00[i] <= 8'h0;       
     else if(!v1_mtp00_bs)    
       if(!v1_mtp00_we)    
         w1_mtp00[v1_mtp00_a]  <= v1_mtp00_d;
 end
 assign  w1_mtp00_q = w1_mtp00[v1_mtp00_a];

endmodule



