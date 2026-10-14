// ----------------------------------------------
// File: dc_vpdsm.v
// Module: dc_vpdsm
// Function: sum up percial products
//           latency is 3
// ----------------------------------------------

module dc_vpdsm ( 
   clkdec, 
   rstdec_x, 
   d_ppro_0, 
   d_ppro_1, 
   d_ppro_2, 
   d_ppro_3, 
   d_ppro_4, 
   d_ppro_5, 
   d_ppro_6, 
   d_ppro_7, 
   d_psum
);

input         clkdec;   
input         rstdec_x; 
input  [16:0] d_ppro_0;   // partial product 0
input  [16:0] d_ppro_1;   // partial product 1
input  [16:0] d_ppro_2;   // partial product 2
input  [16:0] d_ppro_3;   // partial product 3
input  [16:0] d_ppro_4;   // partial product 4
input  [16:0] d_ppro_5;   // partial product 5
input  [16:0] d_ppro_6;   // partial product 6
input  [16:0] d_ppro_7;   // partial product 7
output [19:0] d_psum;     // sum out

wire          clkdec;     // clk
wire          rstdec_x;   // reset
wire   [16:0] d_ppro_0;   // partial product 0
wire   [16:0] d_ppro_1;   // partial product 1
wire   [16:0] d_ppro_2;   // partial product 2
wire   [16:0] d_ppro_3;   // partial product 3
wire   [16:0] d_ppro_4;   // partial product 4
wire   [16:0] d_ppro_5;   // partial product 5
wire   [16:0] d_ppro_6;   // partial product 6
wire   [16:0] d_ppro_7;   // partial product 7
reg    [19:0] d_psum;     // sum out
reg    [17:0] r_s00;      // sum 0(stage 0)
reg    [17:0] r_s01;      // sum 1(stage 0)
reg    [17:0] r_s02;      // sum 2(stage 0)
reg    [17:0] r_s03;      // sum 3(stage 0)
reg    [18:0] r_s10;      // sum 0(stage 1)
reg    [18:0] r_s11;      // sum 1(stage 1)

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_s00    <= 18'd0;
        r_s01    <= 18'd0;
        r_s02    <= 18'd0;
        r_s03    <= 18'd0;
      end
    else
      begin
        r_s00    <= {d_ppro_0[16],d_ppro_0} + {d_ppro_1[16],d_ppro_1};
        r_s01    <= {d_ppro_2[16],d_ppro_2} + {d_ppro_3[16],d_ppro_3};
        r_s02    <= {d_ppro_4[16],d_ppro_4} + {d_ppro_5[16],d_ppro_5};
        r_s03    <= {d_ppro_6[16],d_ppro_6} + {d_ppro_7[16],d_ppro_7};
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_s10    <= 19'd0;
        r_s11    <= 19'd0;
      end
    else
      begin
        r_s10    <= {r_s00[17],r_s00} + {r_s01[17],r_s01};
        r_s11    <= {r_s02[17],r_s02} + {r_s03[17],r_s03};
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        d_psum    <= 20'd0;
      end
    else
      begin
        d_psum    <= {r_s10[18],r_s10} + {r_s11[18],r_s11};
      end
  end
endmodule

