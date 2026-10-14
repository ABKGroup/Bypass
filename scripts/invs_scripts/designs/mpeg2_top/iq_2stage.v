// ----------------------------------------------
// File: iq_2stage.v
// Module: iq_2stage
// Function:Inverse Quantization top module
// ----------------------------------------------

module iq_2stage(
  clkdec,
  rstdec_x,
  mbintr_reg,
  blkst_flag_reg,
  blklst_flag_reg,
  blken_flag_reg,
  qscale_reg,
  mpegx_reg,
  iqpastdc_reg,
  mtrxout_reg,
  intradc4_reg,
  q_do_r,
  smd2
  );

  input       clkdec;    
  input       rstdec_x;  
  input       mbintr_reg;     
  input       blkst_flag_reg; 
  input       blklst_flag_reg;
  input       blken_flag_reg; 
  input [7:0] qscale_reg;     
  input       mpegx_reg;      
  input [15:0] iqpastdc_reg;  
  input [15:0] mtrxout_reg;   
  input       intradc4_reg;  
  output [11:0] q_do_r;       
  output [11:0] smd2;         

  parameter lmax = 12'h7FF;
  parameter lmin = 12'h800;
  
  reg [4:0]  sft20;
  reg [15:0] addin; 
  reg [15:0] abso;
  reg [14:0] abso_lim;
  reg [14:0] q_scal;
  reg [14:0] mpy2in1_reg;    // input1
  reg [14:0] mpy2in2_reg;    // input2
  reg [4:0]  sft20_reg;      // Sift value
  reg        mpy2sign0_reg;  // Sign Bit
  reg        intradc5_reg;   // IntraDC value
  reg [29:0] sum1_reg;       // Wall result
  reg [29:0] sum2_reg;       // Wall result
  reg [4:0]  sft21_reg;      // sift value
  reg        mpy2sign1_reg;  // Sign Bit
  reg        intradc6_reg;   // Intra DC flag
  reg [29:0] mpy2out1_reg;   // Multiplication result
  reg [4:0]  sft22_reg;      // Sift value
  reg        mpy2sign2_reg;  // Sign Bit
  reg        intradc7_reg;   // Intra DC flag
  reg [28:0] sift1v;
  reg [21:0] sift2v;
  reg [15:0] smd_reg;
  reg        intradc8_reg;
  reg [11:0] lim_reg; 
  reg        intradc9_reg; 
  reg [11:0] m_out;
  reg        ibit_reg;      
  reg [11:0] q_do_r;


  wire [15:0] absin;
  wire        aco;
  wire        absin_sign;
  wire [17:0] b_p8;
  wire [17:0] b_p7;
  wire [17:0] b_p6;
  wire [17:0] b_p5;
  wire [17:0] b_p4;
  wire [17:0] b_p3;
  wire [17:0] b_p2;
  wire [17:0] b_p1;
  wire [17:0] b_p0;
  wire [1:0]  b_c8; 
  wire [1:0]  b_c7;   
  wire [1:0]  b_c6;   
  wire [1:0]  b_c5;   
  wire [1:0]  b_c4;   
  wire [1:0]  b_c3;   
  wire [1:0]  b_c2;   
  wire [1:0]  b_c1;   
  wire        b_c0;         
  wire [29:0] sum1;  
  wire [29:0] sum2;  
  wire [29:0] mpy2out1;
  wire [15:0] lmax_ex; 
  wire [15:0] lmin_ex; 
  wire        obit; 

  wire         co_l;  
  wire         co_m0; 
  wire         co_m1; 
  wire [10:0]  sum_m; 
  wire [9:0]   sum_m0;
  wire [9:0]   sum_m1;
  wire [30:18] sum_h; 
  wire [29:18] sum_h0;
  wire [29:18] sum_h1;
  wire         ci_m;
  wire         co_h_0;
  wire         co_h_1;


  always @(intradc4_reg or qscale_reg)
    if (intradc4_reg == 1'b1)
      sft20 = 5'd0;
    else begin
       if ( qscale_reg == 8'd1 || qscale_reg == 8'd2 )
         sft20 = 5'd3;
       else
         sft20 = 5'd5;
    end

  always @(iqpastdc_reg or intradc4_reg )
    if( intradc4_reg )
      addin = iqpastdc_reg;
    else
      addin = 16'h0000;
  
  assign {aco,absin} = mtrxout_reg + addin;
  assign absin_sign = (mtrxout_reg[15]^addin[15])^aco;
  
  always @(absin or absin_sign)
    if (absin_sign)
      abso = ~absin+1;
    else
      abso = absin;
  
  always @(abso)
    if (abso > 16'h7FFF)
      abso_lim = 15'h7FFF;
    else
      abso_lim = abso[14:0];

  always @(qscale_reg or intradc4_reg)
    if (intradc4_reg == 1'b1)
      q_scal = 15'h0001;
    else
      q_scal = {7'h00,qscale_reg};
  
  always @(posedge clkdec)
    begin
    mpy2in1_reg <= abso_lim;
    mpy2in2_reg <= q_scal;
    sft20_reg <= sft20;
    mpy2sign0_reg <= absin_sign;
    intradc5_reg <= intradc4_reg;
    end
  
 always @(posedge clkdec)
   begin
      sum1_reg <= sum1;
      sum2_reg <= sum2;
   end
  
  always @(posedge clkdec)
    begin
    sft21_reg <= sft20_reg;
    mpy2sign1_reg <= mpy2sign0_reg;
    intradc6_reg <= intradc5_reg;
    end
  
  always @(posedge clkdec)
    begin
    mpy2out1_reg <= mpy2out1;
    sft22_reg <= sft21_reg;
    mpy2sign2_reg <= mpy2sign1_reg;
    intradc7_reg <= intradc6_reg;
    end

  always@( mpy2out1_reg or sft22_reg )
    case(sft22_reg[4:3])
      2'b00: sift1v=mpy2out1_reg[28:0];
      2'b01: sift1v={7'h0,mpy2out1_reg[29:8]};
      2'b10: sift1v={15'h0,mpy2out1_reg[29:16]};
      2'b11: sift1v={23'h0,mpy2out1_reg[29:24]};
    endcase

  always@( sift1v or sft22_reg )
    case(sft22_reg[2:0])
      3'b000: sift2v=sift1v[21:0];
      3'b001: sift2v=sift1v[22:1];
      3'b010: sift2v=sift1v[23:2];
      3'b011: sift2v=sift1v[24:3];
      3'b100: sift2v=sift1v[25:4];
      3'b101: sift2v=sift1v[26:5];
      3'b110: sift2v=sift1v[27:6];
      3'b111: sift2v=sift1v[28:7];
    endcase

  always @(posedge clkdec)
    begin
      intradc8_reg <= intradc7_reg;
    if ( mpy2sign2_reg == 1'b0 )
      if (sift2v > 22'h007FFF )
        smd_reg[15:0] <= 16'h7FFF;
      else
        smd_reg[15:0] <= {1'b0,sift2v[14:0]};
    else
      if (sift2v > 22'h007FFF )
        smd_reg[15:0] <= 16'h8000;
      else
        smd_reg[15:0] <= {1'b1, ~sift2v[14:0]+1};
    end
  
  assign smd2 = smd_reg[11:0];

  assign lmax_ex = {4'h0,lmax};
  assign lmin_ex = {4'hF,lmin};
  
  always @(posedge clkdec)
    begin     
    if (smd_reg[15] == 1'b0)
      if ( smd_reg > lmax_ex )
        lim_reg <= lmax;
      else
        lim_reg <= smd_reg[11:0];
    else
      if (smd_reg < lmin_ex )
        lim_reg <= lmin;
      else
        lim_reg <= smd_reg[11:0];
        intradc9_reg <= intradc8_reg;
    end
  
  assign obit = lim_reg[0] ^ (~blkst_flag_reg & ibit_reg);   

  always @(posedge clkdec or negedge rstdec_x)
    if (!rstdec_x)
      ibit_reg <= 0;
    else if (blken_flag_reg)
      ibit_reg <= obit;
    else
      ibit_reg <= ibit_reg;

  always @(lim_reg or blklst_flag_reg or intradc9_reg or mpegx_reg or obit or mbintr_reg )
    begin
    if (mpegx_reg == 1'b0)
      if ( intradc9_reg == 1'b0 && blklst_flag_reg == 1'b1)
        m_out = {lim_reg[11:1],~(obit^lim_reg[0])};   // MPEG 2 Miss Match Control
      else    
        m_out = lim_reg;
    else
      if ( intradc9_reg == 1'b0 || mbintr_reg == 1'b0 )
        if ( lim_reg[0] == 1'b0)     // MPEG1 Miss Match Control
          if (lim_reg[11] == 1'b1)
            m_out = lim_reg + 1;
          else if (lim_reg  != 12'h000)
            m_out = lim_reg - 1;
          else
            m_out =12'h000;
        else
          m_out = lim_reg;
      else
        m_out = lim_reg;
    end
  
  always@( posedge clkdec )
    q_do_r <= m_out;//mout_reg;
  
 iq_both iq_both(
   .b_x({2'b00,mpy2in1_reg}),
   .b_y({2'b00,mpy2in2_reg}),
   .b_p8(b_p8),
   .b_p7(b_p7),
   .b_p6(b_p6),
   .b_p5(b_p5),
   .b_p4(b_p4),
   .b_p3(b_p3),
   .b_p2(b_p2),
   .b_p1(b_p1),
   .b_p0(b_p0),
   .b_c8(b_c8),
   .b_c7(b_c7),
   .b_c6(b_c6),
   .b_c5(b_c5),
   .b_c4(b_c4),
   .b_c3(b_c3),
   .b_c2(b_c2),
   .b_c1(b_c1),
   .b_c0(b_c0)
   );

 iq_wall iq_wall(
   .b_p0(b_p0),
   .b_p1(b_p1),
   .b_p2(b_p2),
   .b_p3(b_p3),
   .b_p4(b_p4),
   .b_p5(b_p5),
   .b_p6(b_p6),
   .b_p7(b_p7[16:0]),
   .b_p8(b_p8[14:0]),
   .b_cy({b_c8,b_c7,b_c6,b_c5,b_c4,b_c3,b_c2,b_c1,b_c0}),
   .sum1(sum1),
   .sum2(sum2)
   );

  assign {co_l,mpy2out1[7:0]} = sum1_reg[7:0] + sum2_reg[7:0];   
  assign sum_m = sum1_reg[17:8] + sum2_reg[17:8];
  assign {co_m0,sum_m0[9:0]} = sum_m;
  assign {co_m1,sum_m1[9:0]} = sum_m + 1;   
  assign sum_h = sum1_reg[29:18] + sum2_reg[29:18];
  assign {co_h_0,sum_h0[29:18]} = sum_h;
  assign {co_h_1,sum_h1[29:18]} = sum_h + 1;   
  assign mpy2out1[17:8] = co_l ? sum_m1[9:0] : sum_m0[9:0];
  assign ci_m = co_l ? co_m1 : co_m0;
  assign mpy2out1[29:18] = ci_m ? sum_h1[29:18] : sum_h0[29:18];

endmodule

 
