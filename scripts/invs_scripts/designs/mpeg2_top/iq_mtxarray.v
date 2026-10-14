// ----------------------------------------------
// File: iq_mtxarray.v
// Module: iq_mtxarray
// Function: data stack array for dc module 
// ----------------------------------------------

module iq_mtxarray( 
   clkdec, 
   rstdec_x, 
   v1_mtx00_a , 
   v1_mtx00_bs, 
   v1_mtx00_d , 
   v1_mtx00_we, 
   w1_mtx00_q 
   );

 input        clkdec; 
 input        rstdec_x; 
 input [6:0]  v1_mtx00_a; 
 input        v1_mtx00_bs; 
 input [7:0] v1_mtx00_d;
 input        v1_mtx00_we; 
 output[7:0] w1_mtx00_q;

 reg [7:0]  w1_mtx00[127:0];
 integer  i;

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<128;i=i+1)
         w1_mtx00[i] <= 8'h00;       
     else if(!v1_mtx00_bs && !v1_mtx00_we)    
       w1_mtx00[v1_mtx00_a]  <= v1_mtx00_d;
 end
 assign  w1_mtx00_q = w1_mtx00[v1_mtx00_a];

endmodule



