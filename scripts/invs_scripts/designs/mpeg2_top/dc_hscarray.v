// ----------------------------------------------
// File: dc_hscarray.v
// Module: dc_hscarray
// Function: data stack array for dc module 
// ----------------------------------------------

module dc_hscarray ( 
   clkdec, 
   rstdec_x, 
   v1_hsc00_a , 
   v1_hsc00_bs, 
   v1_hsc00_d , 
   v1_hsc00_we, 
   w1_hsc00_q ,
   v1_hsc01_a , 
   v1_hsc01_bs, 
   v1_hsc01_d , 
   v1_hsc01_we, 
   w1_hsc01_q 
   );

 input        clkdec; 
 input        rstdec_x; 
 input [4:0]  v1_hsc00_a; 
 input        v1_hsc00_bs; 
 input [7:0]  v1_hsc00_d;
 input        v1_hsc00_we; 
 output[7:0]  w1_hsc00_q;
 input [4:0]  v1_hsc01_a; 
 input        v1_hsc01_bs; 
 input [7:0]  v1_hsc01_d;
 input        v1_hsc01_we; 
 output[7:0]  w1_hsc01_q;

 reg [7:0]  w1_hsc00[31:0];
 reg [7:0]  w1_hsc01[31:0];
 integer    i,j;

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<32;i=i+1)
         w1_hsc00[i] <= 8'h00;       
     else begin
       if(!v1_hsc00_bs && !v1_hsc00_we) begin
         w1_hsc00[v1_hsc00_a]  <= v1_hsc00_d;
       end
     end
 end
 assign  w1_hsc00_q = w1_hsc00[v1_hsc00_a];

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(j=0;j<32;j=j+1)
         w1_hsc01[j] <= 8'h00;       
     else begin
       if( !v1_hsc01_bs && !v1_hsc01_we ) begin
         w1_hsc01[v1_hsc01_a]  <= v1_hsc01_d;
       end
     end
 end
 assign  w1_hsc01_q = w1_hsc01[v1_hsc01_a];

endmodule



