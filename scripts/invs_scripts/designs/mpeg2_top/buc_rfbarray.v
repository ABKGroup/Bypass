// ----------------------------------------------
// File: buc_rfbarray.v
// Module: buc_rfbarray
// Function: data stack array for dc module 
// ----------------------------------------------

module buc_rfbarray( 
   clkdec, 
   rstdec_x, 
   v1_rfb00_a , 
   v1_rfb00_bs, 
   v1_rfb00_d , 
   v1_rfb00_we, 
   w1_rfb00_q ,
   v1_rfb01_a , 
   v1_rfb01_bs, 
   v1_rfb01_d , 
   v1_rfb01_we, 
   w1_rfb01_q ,
   v1_rfb02_a , 
   v1_rfb02_bs, 
   v1_rfb02_d , 
   v1_rfb02_we, 
   w1_rfb02_q ,
   v1_rfb03_a , 
   v1_rfb03_bs, 
   v1_rfb03_d , 
   v1_rfb03_we, 
   w1_rfb03_q ,
   v1_rfb04_a , 
   v1_rfb04_bs, 
   v1_rfb04_d , 
   v1_rfb04_we, 
   w1_rfb04_q ,
   v1_rfb05_a , 
   v1_rfb05_bs, 
   v1_rfb05_d , 
   v1_rfb05_we, 
   w1_rfb05_q 
   );

 input        clkdec; 
 input        rstdec_x; 
 input [4:0]  v1_rfb00_a; 
 input        v1_rfb00_bs; 
 input [15:0] v1_rfb00_d;
 input        v1_rfb00_we; 
 output[15:0] w1_rfb00_q;
 input [4:0]  v1_rfb01_a; 
 input        v1_rfb01_bs; 
 input [15:0] v1_rfb01_d;
 input        v1_rfb01_we; 
 output[15:0] w1_rfb01_q;
 input [4:0]  v1_rfb02_a; 
 input        v1_rfb02_bs; 
 input [15:0] v1_rfb02_d;
 input        v1_rfb02_we; 
 output[15:0] w1_rfb02_q;
 input [4:0]  v1_rfb03_a; 
 input        v1_rfb03_bs; 
 input [15:0] v1_rfb03_d;
 input        v1_rfb03_we; 
 output[15:0] w1_rfb03_q;
 input [4:0]  v1_rfb04_a; 
 input        v1_rfb04_bs; 
 input [15:0] v1_rfb04_d;
 input        v1_rfb04_we; 
 output[15:0] w1_rfb04_q;
 input [4:0]  v1_rfb05_a; 
 input        v1_rfb05_bs; 
 input [15:0] v1_rfb05_d;
 input        v1_rfb05_we; 
 output[15:0] w1_rfb05_q;

 reg [15:0]  w1_rfb00[31:0];
 reg [15:0]  w1_rfb01[31:0];
 reg [15:0]  w1_rfb02[31:0];
 reg [15:0]  w1_rfb03[31:0];
 reg [15:0]  w1_rfb04[31:0];
 reg [15:0]  w1_rfb05[31:0];
 integer    i;

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<32;i=i+1)
         w1_rfb00[i] <= 16'h0000;       
     else if(!v1_rfb00_bs)    
       if(!v1_rfb00_we)    
         w1_rfb00[v1_rfb00_a]  <= v1_rfb00_d;
 end
 assign  w1_rfb00_q = w1_rfb00[v1_rfb00_a];

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<32;i=i+1)
         w1_rfb01[i] <= 16'h0000;       
     else if(!v1_rfb01_bs)    
       if(!v1_rfb01_we)    
         w1_rfb01[v1_rfb01_a]  <= v1_rfb01_d;
 end
 assign  w1_rfb01_q = w1_rfb01[v1_rfb01_a];

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<32;i=i+1)
         w1_rfb02[i] <= 16'h0000;       
     else if(!v1_rfb02_bs)    
       if(!v1_rfb02_we)    
         w1_rfb02[v1_rfb02_a]  <= v1_rfb02_d;
 end
 assign  w1_rfb02_q = w1_rfb02[v1_rfb02_a];

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<32;i=i+1)
         w1_rfb03[i] <= 16'h0000;       
     else if(!v1_rfb03_bs)    
       if(!v1_rfb03_we)    
         w1_rfb03[v1_rfb03_a]  <= v1_rfb03_d;
 end
 assign  w1_rfb03_q = w1_rfb03[v1_rfb03_a];

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<32;i=i+1)
         w1_rfb04[i] <= 16'h0000;       
     else if(!v1_rfb04_bs)    
       if(!v1_rfb04_we)    
         w1_rfb04[v1_rfb04_a]  <= v1_rfb04_d;
 end
 assign  w1_rfb04_q = w1_rfb04[v1_rfb04_a];

 always @(posedge clkdec or negedge rstdec_x) begin
     if (!rstdec_x)
       for(i=0;i<32;i=i+1)
         w1_rfb05[i] <= 16'h0000;       
     else if(!v1_rfb05_bs)    
       if(!v1_rfb05_we)    
         w1_rfb05[v1_rfb05_a]  <= v1_rfb05_d;
 end
 assign  w1_rfb05_q = w1_rfb05[v1_rfb05_a];

endmodule



