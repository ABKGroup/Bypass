// ----------------------------------------------
// File: dc_hpdsm.v
// Module: dc_hpdsm
// Function: sum up percial products
//           latency is 4
// ----------------------------------------------

module dc_hpdsm ( 
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
   d_ppro_8, 
   d_ppro_9, 
   d_ppro_a, 
   d_ppro_b, 
   d_ppro_c, 
   d_ppro_d, 
   d_ppro_e, 
   d_ppro_f, 
   d_psum
);

input         clkdec;  
input         rstdec_x;
input  [16:0] d_ppro_0;
input  [16:0] d_ppro_1;
input  [16:0] d_ppro_2;
input  [16:0] d_ppro_3;
input  [16:0] d_ppro_4;
input  [16:0] d_ppro_5;
input  [16:0] d_ppro_6;
input  [16:0] d_ppro_7;
input  [16:0] d_ppro_8;
input  [16:0] d_ppro_9;
input  [16:0] d_ppro_a;
input  [16:0] d_ppro_b;
input  [16:0] d_ppro_c;
input  [16:0] d_ppro_d;
input  [16:0] d_ppro_e;
input  [16:0] d_ppro_f;
output [20:0] d_psum;  

wire        clkdec;    
wire        rstdec_x;  
wire [16:0] d_ppro_0;     //pertial product0
wire [16:0] d_ppro_1;     //pertial product1
wire [16:0] d_ppro_2;     //pertial product2
wire [16:0] d_ppro_3;     //pertial product3
wire [16:0] d_ppro_4;     //pertial product4
wire [16:0] d_ppro_5;     //pertial product5
wire [16:0] d_ppro_6;     //pertial product6
wire [16:0] d_ppro_7;     //pertial product7
wire [16:0] d_ppro_8;     //pertial product8
wire [16:0] d_ppro_9;     //pertial product9
wire [16:0] d_ppro_a;     //pertial producta
wire [16:0] d_ppro_b;     //pertial productb
wire [16:0] d_ppro_c;     //pertial productc
wire [16:0] d_ppro_d;     //pertial productd
wire [16:0] d_ppro_e;     //pertial producte
wire [16:0] d_ppro_f;     //pertial productf
reg  [20:0] d_psum;       //sum out
reg  [17:0] r_s00;          //stage-0 sum0
reg  [17:0] r_s01;          //stage-0 sum1
reg  [17:0] r_s02;          //stage-0 sum2
reg  [17:0] r_s03;          //stage-0 sum3
reg  [17:0] r_s04;          //stage-0 sum4
reg  [17:0] r_s05;          //stage-0 sum5
reg  [17:0] r_s06;          //stage-0 sum6
reg  [17:0] r_s07;          //stage-0 sum7
reg  [18:0] r_s10;          //stage-1 sum0
reg  [18:0] r_s11;          //stage-1 sum1
reg  [18:0] r_s12;          //stage-1 sum2
reg  [18:0] r_s13;          //stage-1 sum3
reg  [19:0] r_s20;          //stage-2 sum0
reg  [19:0] r_s21;          //stage-2 sum1

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_s00    <= 18'd0;
        r_s01    <= 18'd0;
        r_s02    <= 18'd0;
        r_s03    <= 18'd0;
        r_s04    <= 18'd0;
        r_s05    <= 18'd0;
        r_s06    <= 18'd0;
        r_s07    <= 18'd0;
      end
    else
      begin
        r_s00    <= {d_ppro_0[16],d_ppro_0} + {d_ppro_1[16],d_ppro_1};
        r_s01    <= {d_ppro_2[16],d_ppro_2} + {d_ppro_3[16],d_ppro_3};
        r_s02    <= {d_ppro_4[16],d_ppro_4} + {d_ppro_5[16],d_ppro_5};
        r_s03    <= {d_ppro_6[16],d_ppro_6} + {d_ppro_7[16],d_ppro_7};
        r_s04    <= {d_ppro_8[16],d_ppro_8} + {d_ppro_9[16],d_ppro_9};
        r_s05    <= {d_ppro_a[16],d_ppro_a} + {d_ppro_b[16],d_ppro_b};
        r_s06    <= {d_ppro_c[16],d_ppro_c} + {d_ppro_d[16],d_ppro_d};
        r_s07    <= {d_ppro_e[16],d_ppro_e} + {d_ppro_f[16],d_ppro_f};
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x) 
      begin
        r_s10    <= 19'd0;
        r_s11    <= 19'd0;
        r_s12    <= 19'd0;
        r_s13    <= 19'd0;
      end
    else
      begin
        r_s10    <= {r_s00[17],r_s00} + {r_s01[17],r_s01};
        r_s11    <= {r_s02[17],r_s02} + {r_s03[17],r_s03};
        r_s12    <= {r_s04[17],r_s04} + {r_s05[17],r_s05};
        r_s13    <= {r_s06[17],r_s06} + {r_s07[17],r_s07};
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_s20    <= 20'd0;
        r_s21    <= 20'd0;
      end
    else
      begin
        r_s20    <= {r_s10[18],r_s10} + {r_s11[18],r_s11};
        r_s21    <= {r_s12[18],r_s12} + {r_s13[18],r_s13};
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        d_psum    <= 21'd0;
      end
    else
      begin
        d_psum    <= {r_s20[19],r_s20} + {r_s21[19],r_s21};
      end
  end
endmodule

