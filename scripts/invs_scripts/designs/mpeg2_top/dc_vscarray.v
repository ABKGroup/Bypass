// ----------------------------------------------
// File: dc_vscarray.v
// Module: dc_vscarray
// Function: data stack array for dc module 
// ----------------------------------------------

module dc_vscarray ( 
   clkdec, 
   rstdec_x, 
   v1_vsc00_a , 
   v1_vsc00_bs, 
   v1_vsc00_d , 
   v1_vsc00_we, 
   w1_vsc00_q ,
   v1_vsc01_a , 
   v1_vsc01_bs, 
   v1_vsc01_d , 
   v1_vsc01_we, 
   w1_vsc01_q 
   );

 input        clkdec; 
 input        rstdec_x; 
 input [5:0]  v1_vsc00_a; 
 input        v1_vsc00_bs; 
 input [7:0]  v1_vsc00_d;
 input        v1_vsc00_we; 
 output[7:0]  w1_vsc00_q;
 input [5:0]  v1_vsc01_a; 
 input        v1_vsc01_bs; 
 input [7:0]  v1_vsc01_d;
 input        v1_vsc01_we; 
 output[7:0]  w1_vsc01_q;

 reg [7:0]  w1_vsc00[63:0];
 reg [7:0]  w1_vsc01[63:0];
 integer    i, j;

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<64;i=i+1)
         w1_vsc00[i] <= 8'h00;       
     else begin
       if(!v1_vsc00_bs && !v1_vsc00_we) begin
         w1_vsc00[v1_vsc00_a]  <= v1_vsc00_d;
       end
     end
 end
 assign  w1_vsc00_q = w1_vsc00[v1_vsc00_a];

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(j=0;j<64;j=j+1)
         w1_vsc01[j] <= 8'h00;       
     else begin
       if(!v1_vsc01_bs && !v1_vsc01_we) begin
         w1_vsc01[v1_vsc01_a]  <= v1_vsc01_d;
       end
     end
 end
 assign  w1_vsc01_q = w1_vsc01[v1_vsc01_a];

endmodule



