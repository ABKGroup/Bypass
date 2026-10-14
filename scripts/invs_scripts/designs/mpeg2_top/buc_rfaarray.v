// ----------------------------------------------
// File: buc_rfaarray.v
// Module: buc_rfaarray
// Function: data stack array for dc module 
// ----------------------------------------------

module buc_rfaarray( 
   clkdec, 
   rstdec_x, 
   v1_rfa00_a , 
   v1_rfa00_bs, 
   v1_rfa00_d , 
   v1_rfa00_we, 
   w1_rfa00_q ,
   v1_rfa01_a , 
   v1_rfa01_bs, 
   v1_rfa01_d , 
   v1_rfa01_we, 
   w1_rfa01_q ,
   v1_rfa02_a , 
   v1_rfa02_bs, 
   v1_rfa02_d , 
   v1_rfa02_we, 
   w1_rfa02_q ,
   v1_rfa03_a , 
   v1_rfa03_bs, 
   v1_rfa03_d , 
   v1_rfa03_we, 
   w1_rfa03_q ,
   v1_rfa04_a , 
   v1_rfa04_bs, 
   v1_rfa04_d , 
   v1_rfa04_we, 
   w1_rfa04_q ,
   v1_rfa05_a , 
   v1_rfa05_bs, 
   v1_rfa05_d , 
   v1_rfa05_we, 
   w1_rfa05_q 
   );

 input        clkdec; 
 input        rstdec_x; 
 input [5:0]  v1_rfa00_a; 
 input        v1_rfa00_bs; 
 input [63:0] v1_rfa00_d;
 input        v1_rfa00_we; 
 output[63:0] w1_rfa00_q;
 input [5:0]  v1_rfa01_a; 
 input        v1_rfa01_bs; 
 input [63:0] v1_rfa01_d;
 input        v1_rfa01_we; 
 output[63:0] w1_rfa01_q;
 input [5:0]  v1_rfa02_a; 
 input        v1_rfa02_bs; 
 input [63:0] v1_rfa02_d;
 input        v1_rfa02_we; 
 output[63:0] w1_rfa02_q;
 input [5:0]  v1_rfa03_a; 
 input        v1_rfa03_bs; 
 input [63:0] v1_rfa03_d;
 input        v1_rfa03_we; 
 output[63:0] w1_rfa03_q;
 input [5:0]  v1_rfa04_a; 
 input        v1_rfa04_bs; 
 input [63:0] v1_rfa04_d;
 input        v1_rfa04_we; 
 output[63:0] w1_rfa04_q;
 input [5:0]  v1_rfa05_a; 
 input        v1_rfa05_bs; 
 input [63:0] v1_rfa05_d;
 input        v1_rfa05_we; 
 output[63:0] w1_rfa05_q;

 reg [63:0]  w1_rfa00[63:0];
 reg [63:0]  w1_rfa01[63:0];
 reg [63:0]  w1_rfa02[63:0];
 reg [63:0]  w1_rfa03[63:0];
 reg [63:0]  w1_rfa04[63:0];
 reg [63:0]  w1_rfa05[63:0];
 integer    i;


 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<64;i=i+1)
         w1_rfa00[i] <= 64'h00000000;       
     else if(!v1_rfa00_bs)    
       if(!v1_rfa00_we)    
         w1_rfa00[v1_rfa00_a]  <= v1_rfa00_d;
 end
 assign  w1_rfa00_q = w1_rfa00[v1_rfa00_a];

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<64;i=i+1)
         w1_rfa01[i] <= 64'h00000000;       
     else if(!v1_rfa01_bs)    
       if(!v1_rfa01_we)    
         w1_rfa01[v1_rfa01_a]  <= v1_rfa01_d;
 end
 assign  w1_rfa01_q = w1_rfa01[v1_rfa01_a];

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<64;i=i+1)
         w1_rfa02[i] <= 64'h00000000;       
     else if(!v1_rfa02_bs)    
       if(!v1_rfa02_we)    
         w1_rfa02[v1_rfa02_a]  <= v1_rfa02_d;
 end
 assign  w1_rfa02_q = w1_rfa02[v1_rfa02_a];

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<64;i=i+1)
         w1_rfa03[i] <= 64'h00000000;       
     else if(!v1_rfa03_bs)    
       if(!v1_rfa03_we)    
         w1_rfa03[v1_rfa03_a]  <= v1_rfa03_d;
 end
 assign  w1_rfa03_q = w1_rfa03[v1_rfa03_a];

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<64;i=i+1)
         w1_rfa04[i] <= 64'h00000000;       
     else if(!v1_rfa04_bs)    
       if(!v1_rfa04_we)    
         w1_rfa04[v1_rfa04_a]  <= v1_rfa04_d;
 end
 assign  w1_rfa04_q = w1_rfa04[v1_rfa04_a];

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<64;i=i+1)
         w1_rfa05[i] <= 64'h00000000;       
     else if(!v1_rfa05_bs)    
       if(!v1_rfa05_we)    
         w1_rfa05[v1_rfa05_a]  <= v1_rfa05_d;
 end
 assign  w1_rfa05_q = w1_rfa05[v1_rfa05_a];


endmodule



