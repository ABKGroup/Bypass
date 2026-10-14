// ----------------------------------------------
// File: iq_wall.v
// Module: iq_wall
// Function:Wallace Tree (15x15 multiplier)
// ----------------------------------------------

module iq_wall(
  b_p0,
  b_p1,
  b_p2,
  b_p3,
  b_p4,
  b_p5,
  b_p6,
  b_p7,
  b_p8,
  b_cy,
  sum1,
  sum2
);
   
  input [17:0]  b_p0; 
  input [18:1]  b_p1; 
  input [20:3]  b_p2; 
  input [22:5]  b_p3; 
  input [24:7]  b_p4; 
  input [26:9]  b_p5; 
  input [28:11] b_p6; 
  input [29:13] b_p7; 
  input [29:15] b_p8; 
  input [16:0]  b_cy; 

  output [29:0] sum1; 
  output [29:0] sum2; 

  wire [29:5]  w_s0; 
  wire [29:5]  w_c0; 
  wire [23:7]  w_s1; 
  wire [23:7]  w_c1; 
  wire [18:13] w_s2; 
  wire [18:13] w_c2; 
  wire [27:9]  w_s3; 
  wire [27:9]  w_c3; 
  wire [20:11] w_s4; 
  wire [20:11] w_c4; 
  wire [22:15] w_s5; 
  wire [22:15] w_c5; 
  wire [25:3]  w_s7; 
  wire [25:3]  w_c7; 
  wire [29:1]  w_s8; 
  wire [29:1]  w_c8; 
  parameter  zero = 1'b0;

  // bit0
  assign sum1[0] = b_p0[0];
  assign sum2[0] = b_cy[0];
   
  // bit1
  assign {w_c8[1],w_s8[1]} = F_FADD({b_p0[1],b_p1[1],b_cy[1]});
  assign sum1[1] = zero;
  assign sum2[1] = w_s8[1];
   
  // bit2
  assign {w_c8[2],w_s8[2]} = F_FADD({b_p0[2],b_p1[2],b_cy[2]});
  assign sum1[2] = w_c8[1];
  assign sum2[2] = w_s8[2];
  
  // bit3
  assign {w_c7[3],w_s7[3]} = F_FADD({b_p0[3],b_p1[3],b_p2[3]});
  assign {w_c8[3],w_s8[3]} = F_HADD({w_s7[3],b_cy[3]});
  assign sum1[3] = w_c8[2];
  assign sum2[3] = w_s8[3];
  
  // bit4
  assign {w_c7[4],w_s7[4]} = F_FADD({b_p0[4],b_p1[4],b_p2[4]});
  assign {w_c8[4],w_s8[4]} = F_FADD({w_c7[3],w_s7[4],b_cy[4]});
  assign sum1[4] = w_c8[3];
  assign sum2[4] = w_s8[4];

  // bit5
  assign {w_c0[5],w_s0[5]} = F_FADD({b_p0[5],b_p1[5],b_p2[5]});
  assign {w_c7[5],w_s7[5]} = F_FADD({w_s0[5],b_p3[5],b_cy[5]});
  assign {w_c8[5],w_s8[5]} = F_HADD({w_c7[4],w_s7[5]});
  assign sum1[5] = w_c8[4];
  assign sum2[5] = w_s8[5];

  // bit6
  assign {w_c0[6],w_s0[6]} = F_FADD({b_p0[6],b_p1[6],b_p2[6]});
  assign {w_c7[6],w_s7[6]} = F_FADD({w_c0[5],w_s0[6],b_p3[6]});
  assign {w_c8[6],w_s8[6]} = F_FADD({w_c7[5],w_s7[6],b_cy[6]});
  assign sum1[6] = w_c8[5];
  assign sum2[6] = w_s8[6];

  // bit7
  assign {w_c0[7],w_s0[7]} = F_FADD({b_p0[7],b_p1[7],b_p2[7]});
  assign {w_c1[7],w_s1[7]} = F_FADD({b_p3[7],b_p4[7],b_cy[7]});
  assign {w_c7[7],w_s7[7]} = F_FADD({w_c0[6],w_s0[7],w_s1[7]});
  assign {w_c8[7],w_s8[7]} = F_HADD({w_c7[6],w_s7[7]});
  assign sum1[7] = w_c8[6];
  assign sum2[7] = w_s8[7];

  // bit8
  assign {w_c0[8],w_s0[8]} = F_FADD({b_p0[8],b_p1[8],b_p2[8]});
  assign {w_c1[8],w_s1[8]} = F_FADD({b_p3[8],b_p4[8],b_cy[8]});
  assign {w_c7[8],w_s7[8]} = F_FADD({w_c0[7],w_c1[7],w_s0[8]});
  assign {w_c8[8],w_s8[8]} = F_FADD({w_c7[7],w_s7[8],w_s1[8]});
  assign sum1[8] = w_c8[7];
  assign sum2[8] = w_s8[8];

  // bit9
  assign {w_c0[9],w_s0[9]} = F_FADD({b_p0[9],b_p1[9],b_p2[9]});
  assign {w_c1[9],w_s1[9]} = F_FADD({b_p3[9],b_p4[9],b_p5[9]});
  assign {w_c3[9],w_s3[9]} = F_FADD({w_c0[8],w_c1[8],w_s0[9]});
  assign {w_c7[9],w_s7[9]} = F_FADD({w_s3[9],w_s1[9],b_cy[9]});
  assign {w_c8[9],w_s8[9]} = F_HADD({w_c7[8],w_s7[9]});
  assign sum1[9] = w_c8[8];
  assign sum2[9] = w_s8[9];

  // bit10
  assign {w_c0[10],w_s0[10]} = F_FADD({b_p0[10],b_p1[10],b_p2[10]});
  assign {w_c1[10],w_s1[10]} = F_FADD({b_p3[10],b_p4[10],b_p5[10]});
  assign {w_c3[10],w_s3[10]} = F_FADD({w_c0[9],w_c1[9],w_s0[10]});
  assign {w_c7[10],w_s7[10]} = F_FADD({w_c3[9],w_s3[10],w_s1[10]});
  assign {w_c8[10],w_s8[10]} = F_FADD({w_c7[9],w_s7[10],b_cy[10]});
  assign sum1[10] = w_c8[9];
  assign sum2[10] = w_s8[10];
  
  // bit11
  assign {w_c0[11],w_s0[11]} = F_FADD({b_p0[11],b_p1[11],b_p2[11]});
  assign {w_c1[11],w_s1[11]} = F_FADD({b_p3[11],b_p4[11],b_p5[11]});
  assign {w_c3[11],w_s3[11]} = F_FADD({w_c0[10],w_c1[10],w_s0[11]});
  assign {w_c4[11],w_s4[11]} = F_FADD({w_s1[11],b_p6[11],b_cy[11]});
  assign {w_c7[11],w_s7[11]} = F_FADD({w_c3[10],w_s3[11],w_s4[11]});
  assign {w_c8[11],w_s8[11]} = F_HADD({w_c7[10],w_s7[11]});
  assign sum1[11] = w_c8[10];
  assign sum2[11] = w_s8[11];

  // bit12
  assign {w_c0[12],w_s0[12]} = F_FADD({b_p0[12],b_p1[12],b_p2[12]});
  assign {w_c1[12],w_s1[12]} = F_FADD({b_p3[12],b_p4[12],b_p5[12]});
  assign {w_c3[12],w_s3[12]} = F_FADD({w_c0[11],w_c1[11],w_s0[12]});
  assign {w_c4[12],w_s4[12]} = F_FADD({w_s1[12],b_p6[12],b_cy[12]});
  assign {w_c7[12],w_s7[12]} = F_FADD({w_c3[11],w_c4[11],w_s3[12]});
  assign {w_c8[12],w_s8[12]} = F_FADD({w_c7[11],w_s7[12],w_s4[12]});
  assign sum1[12] = w_c8[11];
  assign sum2[12] = w_s8[12];
  
  // bit13
  assign {w_c0[13],w_s0[13]} = F_FADD({b_p0[13],b_p1[13],b_p2[13]});
  assign {w_c1[13],w_s1[13]} = F_FADD({b_p3[13],b_p4[13],b_p5[13]});
  assign {w_c2[13],w_s2[13]} = F_FADD({b_p6[13],b_p7[13],b_cy[13]});
  assign {w_c3[13],w_s3[13]} = F_FADD({w_c0[12],w_c1[12],w_s0[13]});
  assign {w_c4[13],w_s4[13]} = F_HADD({w_s1[13],w_s2[13]});
  assign {w_c7[13],w_s7[13]} = F_FADD({w_c3[12],w_c4[12],w_s3[13]});
  assign {w_c8[13],w_s8[13]} = F_FADD({w_c7[12],w_s7[13],w_s4[13]});
  assign sum1[13] = w_c8[12];
  assign sum2[13] = w_s8[13];

  // bit14
  assign {w_c0[14],w_s0[14]} = F_FADD({b_p0[14],b_p1[14],b_p2[14]});
  assign {w_c1[14],w_s1[14]} = F_FADD({b_p3[14],b_p4[14],b_p5[14]});
  assign {w_c2[14],w_s2[14]} = F_FADD({b_p6[14],b_p7[14],b_cy[14]});
  assign {w_c3[14],w_s3[14]} = F_FADD({w_c0[13],w_c1[13],w_c2[13]});
  assign {w_c4[14],w_s4[14]} = F_FADD({w_s0[14],w_s1[14],w_s2[14]});
  assign {w_c7[14],w_s7[14]} = F_FADD({w_c3[13],w_c4[13],w_s3[14]});
  assign {w_c8[14],w_s8[14]} = F_FADD({w_c7[13],w_s7[14],w_s4[14]});
  assign sum1[14] = w_c8[13];
  assign sum2[14] = w_s8[14];

  // bit15
  assign {w_c0[15],w_s0[15]} = F_FADD({b_p0[15],b_p1[15],b_p2[15]});
  assign {w_c1[15],w_s1[15]} = F_FADD({b_p3[15],b_p4[15],b_p5[15]});
  assign {w_c2[15],w_s2[15]} = F_FADD({b_p6[15],b_p7[15],b_p8[15]});
  assign {w_c3[15],w_s3[15]} = F_FADD({w_c0[14],w_c1[14],w_c2[14]});
  assign {w_c4[15],w_s4[15]} = F_FADD({w_s0[15],w_s1[15],w_s2[15]});
  assign {w_c5[15],w_s5[15]} = F_FADD({w_c3[14],w_c4[14],w_s3[15]});
  assign {w_c7[15],w_s7[15]} = F_FADD({w_s5[15],w_s4[15],b_cy[15]});
  assign {w_c8[15],w_s8[15]} = F_HADD({w_c7[14],w_s7[15]});
  assign sum1[15] = w_c8[14];
  assign sum2[15] = w_s8[15];

  // bit16
  assign {w_c0[16],w_s0[16]} = F_FADD({b_p0[16],b_p1[16],b_p2[16]});
  assign {w_c1[16],w_s1[16]} = F_FADD({b_p3[16],b_p4[16],b_p5[16]});
  assign {w_c2[16],w_s2[16]} = F_FADD({b_p6[16],b_p7[16],b_p8[16]});
  assign {w_c3[16],w_s3[16]} = F_FADD({w_c0[15],w_c1[15],w_c2[15]});
  assign {w_c4[16],w_s4[16]} = F_FADD({w_s0[16],w_s1[16],w_s2[16]});
  assign {w_c5[16],w_s5[16]} = F_FADD({w_c3[15],w_c4[15],w_s3[16]});
  assign {w_c7[16],w_s7[16]} = F_FADD({w_c5[15],w_s5[16],b_cy[16]});
  assign {w_c8[16],w_s8[16]} = F_FADD({w_c7[15],w_s7[16],w_s4[16]});
  assign sum1[16] = w_c8[15];
  assign sum2[16] = w_s8[16];

  // bit17
  assign {w_c0[17],w_s0[17]} = F_FADD({b_p0[17],b_p1[17],b_p2[17]});
  assign {w_c1[17],w_s1[17]} = F_FADD({b_p3[17],b_p4[17],b_p5[17]});
  assign {w_c2[17],w_s2[17]} = F_FADD({b_p6[17],b_p7[17],b_p8[17]});
  assign {w_c3[17],w_s3[17]} = F_FADD({w_c0[16],w_c1[16],w_c2[16]});
  assign {w_c4[17],w_s4[17]} = F_FADD({w_s0[17],w_s1[17],w_s2[17]});
  assign {w_c5[17],w_s5[17]} = F_FADD({w_c3[16],w_c4[16],w_s3[17]});
  assign {w_c7[17],w_s7[17]} = F_FADD({w_c5[16],w_s5[17],w_s4[17]});
  assign {w_c8[17],w_s8[17]} = F_FADD({w_c7[16],w_s7[17],1'b1});
  assign sum1[17] = w_c8[16];
  assign sum2[17] = w_s8[17];
  
  // bit18
  assign {w_c0[18],w_s0[18]} = F_FADD({b_p1[18],b_p2[18],b_p3[18]});
  assign {w_c1[18],w_s1[18]} = F_FADD({b_p4[18],b_p5[18],b_p6[18]});
  assign {w_c2[18],w_s2[18]} = F_HADD({b_p7[18],b_p8[18]});
  assign {w_c3[18],w_s3[18]} = F_FADD({w_c0[17],w_c1[17],w_c2[17]});
  assign {w_c4[18],w_s4[18]} = F_FADD({w_s0[18],w_s1[18],w_s2[18]});
  assign {w_c5[18],w_s5[18]} = F_FADD({w_c3[17],w_c4[17],w_s3[18]});
  assign {w_c7[18],w_s7[18]} = F_HADD({w_c5[17],w_s5[18]});
  assign {w_c8[18],w_s8[18]} = F_FADD({w_c7[17],w_s7[18],w_s4[18]});
  assign sum1[18] = w_c8[17];
  assign sum2[18] = w_s8[18];
  
  // bit19
  assign {w_c0[19],w_s0[19]} = F_FADD({b_p2[19],b_p3[19],b_p4[19]});
  assign {w_c1[19],w_s1[19]} = F_FADD({b_p5[19],b_p6[19],b_p7[19]});
  assign {w_c3[19],w_s3[19]} = F_FADD({w_c0[18],w_c1[18],b_p8[19]});
  assign {w_c4[19],w_s4[19]} = F_FADD({w_s0[19],w_s1[19],w_c2[18]});
  assign {w_c5[19],w_s5[19]} = F_FADD({w_c3[18],w_c4[18],w_s3[19]});
  assign {w_c7[19],w_s7[19]} = F_FADD({w_c5[18],w_s5[19],w_s4[19]});
  assign {w_c8[19],w_s8[19]} = F_FADD({w_c7[18],w_s7[19],1'b1});
  assign sum1[19] = w_c8[18];
  assign sum2[19] = w_s8[19];
  
  // bit20
  assign {w_c0[20],w_s0[20]} = F_FADD({b_p2[20],b_p3[20],b_p4[20]});
  assign {w_c1[20],w_s1[20]} = F_FADD({b_p5[20],b_p6[20],b_p7[20]});
  assign {w_c3[20],w_s3[20]} = F_FADD({w_c0[19],w_c1[19],b_p8[20]});
  assign {w_c4[20],w_s4[20]} = F_HADD({w_s0[20],w_s1[20]});
  assign {w_c5[20],w_s5[20]} = F_FADD({w_c3[19],w_c4[19],w_s3[20]});
  assign {w_c7[20],w_s7[20]} = F_FADD({w_c5[19],w_s5[20],w_s4[20]});
  assign {w_c8[20],w_s8[20]} = F_HADD({w_c7[19],w_s7[20]});
  assign sum1[20] = w_c8[19];
  assign sum2[20] = w_s8[20];
  
  // bit21
  assign {w_c0[21],w_s0[21]} = F_FADD({b_p3[21],b_p4[21],b_p5[21]});
  assign {w_c1[21],w_s1[21]} = F_FADD({b_p6[21],b_p7[21],b_p8[21]});
  assign {w_c3[21],w_s3[21]} = F_FADD({w_c0[20],w_c1[20],w_s0[21]});
  assign {w_c5[21],w_s5[21]} = F_FADD({w_c3[20],w_c4[20],w_s3[21]});
  assign {w_c7[21],w_s7[21]} = F_FADD({w_c5[20],w_s5[21],1'b1});
  assign {w_c8[21],w_s8[21]} = F_FADD({w_c7[20],w_s7[21],w_s1[21]});
  assign sum1[21] = w_c8[20];
  assign sum2[21] = w_s8[21];
  
  // bit22
  assign {w_c0[22],w_s0[22]} = F_FADD({b_p3[22],b_p4[22],b_p5[22]});
  assign {w_c1[22],w_s1[22]} = F_FADD({b_p6[22],b_p7[22],b_p8[22]});
  assign {w_c3[22],w_s3[22]} = F_FADD({w_c0[21],w_c1[21],w_s0[22]});
  assign {w_c5[22],w_s5[22]} = F_HADD({w_c3[21],w_s3[22]});
  assign {w_c7[22],w_s7[22]} = F_FADD({w_c5[21],w_s5[22],w_s1[22]});
  assign {w_c8[22],w_s8[22]} = F_HADD({w_c7[21],w_s7[22]});
  assign sum1[22] = w_c8[21];
  assign sum2[22] = w_s8[22];
  
  // bit23
  assign {w_c0[23],w_s0[23]} = F_FADD({b_p4[23],b_p5[23],b_p6[23]});
  assign {w_c1[23],w_s1[23]} = F_FADD({b_p7[23],b_p8[23],1'b1});
  assign {w_c3[23],w_s3[23]} = F_FADD({w_c0[22],w_c1[22],w_s0[23]});
  assign {w_c7[23],w_s7[23]} = F_FADD({w_c5[22],w_c3[22],w_s3[23]});
  assign {w_c8[23],w_s8[23]} = F_FADD({w_c7[22],w_s7[23],w_s1[23]});
  assign sum1[23] = w_c8[22];
  assign sum2[23] = w_s8[23];
  
  // bit24
  assign {w_c0[24],w_s0[24]} = F_FADD({b_p4[24],b_p5[24],b_p6[24]});
  assign {w_c3[24],w_s3[24]} = F_FADD({w_c0[23],w_c1[23],w_s0[24]});
  assign {w_c7[24],w_s7[24]} = F_FADD({w_c3[23],w_s3[24],b_p7[24]});
  assign {w_c8[24],w_s8[24]} = F_FADD({w_c7[23],w_s7[24],b_p8[24]});
  assign sum1[24] = w_c8[23];
  assign sum2[24] = w_s8[24];
  
  // bit25
  assign {w_c0[25],w_s0[25]} = F_FADD({b_p5[25],b_p6[25],b_p7[25]});
  assign {w_c3[25],w_s3[25]} = F_FADD({w_c0[24],w_s0[25],b_p8[25]});
  assign {w_c7[25],w_s7[25]} = F_FADD({w_c3[24],w_s3[25],1'b1});
  assign {w_c8[25],w_s8[25]} = F_HADD({w_c7[24],w_s7[25]});
  assign sum1[25] = w_c8[24];
  assign sum2[25] = w_s8[25];

  // bit26
  assign {w_c0[26],w_s0[26]} = F_FADD({b_p5[26],b_p6[26],b_p7[26]});
  assign {w_c3[26],w_s3[26]} = F_FADD({w_c0[25],w_s0[26],b_p8[26]});
  assign {w_c8[26],w_s8[26]} = F_FADD({w_c7[25],w_c3[25],w_s3[26]});
  assign sum1[26] = w_c8[25];
  assign sum2[26] = w_s8[26];
  
  // bit27
  assign {w_c0[27],w_s0[27]} = F_FADD({b_p6[27],b_p7[27],b_p8[27]});
  assign {w_c3[27],w_s3[27]} = F_HADD({w_s0[27],1'b1});
  assign {w_c8[27],w_s8[27]} = F_FADD({w_c0[26],w_s3[27],w_c3[26]});
  assign sum1[27] = w_c8[26];
  assign sum2[27] = w_s8[27];
  
  // bit28
  assign {w_c0[28],w_s0[28]} = F_FADD({b_p6[28],b_p7[28],b_p8[28]});
  assign {w_c8[28],w_s8[28]} = F_FADD({w_c0[27],w_c3[27],w_s0[28]});
  assign sum1[28] = w_c8[27];
  assign sum2[28] = w_s8[28];
  
  // bit29
  assign {w_c0[29],w_s0[29]} = F_FADD({b_p7[29],b_p8[29],1'b1});
  assign {w_c8[29],w_s8[29]} = F_HADD({w_c0[28],w_s0[29]});
  assign sum1[29] = w_c8[28];
  assign sum2[29] = w_s8[29];

  function[1:0] F_FADD;
    input [2:0] a;
    begin
      F_FADD[1] = a[0] & a[1] | a[1] & a[2] | a[2] & a[0];
      F_FADD[0] = ^a;
    end
  endfunction
  
  function[1:0] F_HADD;
    input [1:0] a;
    begin
      F_HADD[1] = &a;
      F_HADD[0] = ^a;
    end
  endfunction

endmodule

