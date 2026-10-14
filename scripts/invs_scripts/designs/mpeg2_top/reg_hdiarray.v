// ----------------------------------------------
// File: reg_hdiarray.v
// Module: reg_hdiarray
// Function: data stack array for breg module 
// ----------------------------------------------

module reg_hdiarray( 
   clkbus, 
   rstbus_x, 
   v1_hdi00_a , 
   v1_hdi00_bs, 
   v1_hdi00_d , 
   v1_hdi00_we, 
   w1_hdi00_q 
   );

 input        clkbus; 
 input        rstbus_x; 
 input [5:0]  v1_hdi00_a; 
 input        v1_hdi00_bs; 
 input [31:0] v1_hdi00_d;
 input        v1_hdi00_we; 
 output[31:0] w1_hdi00_q;

 reg  [31:0]  w1_hdi00[63:0];

 integer      i;

 always @(posedge clkbus or negedge rstbus_x) begin
     if (!rstbus_x)
       for(i=0;i<64;i=i+1)
         w1_hdi00[i] <= 32'h00000000;       
     else if(!v1_hdi00_bs)    
       if(!v1_hdi00_we)    
         w1_hdi00[v1_hdi00_a]  <= v1_hdi00_d;
 end
 assign w1_hdi00_q = w1_hdi00[v1_hdi00_a];

endmodule



