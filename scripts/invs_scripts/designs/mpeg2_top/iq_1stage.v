// ----------------------------------------------
// File: iq_1stage.v
// Module: iq_1stage
// Function:The 1st stage of Inverse quantization operation
// ----------------------------------------------

module iq_1stage(
  clkdec,
  w1_zgt00_q,
  w1_zgt01_q,
  w1_mtx00_q,
  mbintr_reg,
  intradc_reg,
  dcprec_reg,
  qscale_reg,
  pmana_reg,
  mpegx_reg,
  mtrxout_reg,
  intradc4_reg
  );

  input        clkdec;      
  input [11:0] w1_zgt00_q;       // Quantum result
  input [11:0] w1_zgt01_q;       // Quautum result
  input [7:0]  w1_mtx00_q;       // Q Matrix
  input        mbintr_reg;       // 0:inter,1:intra
  input        intradc_reg;      // Intra DC Flag. 1:DC,0:AC
  input [1:0]  dcprec_reg;       // Intra DC Precision
  input [7:0]  qscale_reg;       // Q Scale
  input        pmana_reg;        // page management
  input        mpegx_reg;        // 0:MPEG2,1:MPEG1
  output [15:0] mtrxout_reg;     // matrix out
  output        intradc4_reg;    // IntraDC flag

  reg [11:0] v_dcmd_reg;         // Quantum value
  reg [12:0] mpy1in1;            // Input to multiplexer
  reg [12:0] mpy1in1_reg;        // Input to maltiplexer through rach
  reg        mpy1sign0_reg;             // Sign Bit
  reg        intradc_reg0_reg;          // Intra DC frag
  reg [7:0]  v_qmd_reg;
  reg [14:0] dcpr;
  reg [14:0] mpy1in2_reg;
  reg [4:0]  sft10_reg;

  reg [29:0] sum1_reg;           // Wall result
  reg [29:0] sum2_reg;           // Wall result

  reg        mpy1sign1_reg;      // Sign Bit
  reg        intradc_reg1_reg;   // Intra DC flag
  reg [4:0]  sft11_reg;          // Sift value
  reg [27:0] mpy1out1_reg;       // Multiplication result
  reg [4:0]  sft12_reg;          // Sift value
  reg        intradc_reg2_reg;   // Intra DC flag
  reg        mpy1sign2_reg;      // Sign Bit
  reg [26:0] sift1v;             // Sift operation result 1
  reg [19:0] sift2v;             // Sift operation result2
  reg [18:0] mpy1out2_reg;       // Sift operation result
  reg        intradc_reg3_reg;   // Intra DC flag
  reg        mpy1sign3_reg;      // Sing Bit
  reg [14:0] lim;
  reg [15:0] mtrxout_reg;
  reg        intradc4_reg;

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
  wire b_c0;                
  wire [29:0] sum1;         
  wire [29:0] sum2;         
  wire [29:0] mpy1out1;     
  wire [18:0] round;
  wire        co_l;
  wire        co_m0;
  wire        co_m1;
  wire [10:0] sum_m; 
  wire [9:0]  sum_m0;
  wire [9:0]  sum_m1;
  wire [30:18] sum_h; 
  wire [29:18] sum_h0;
  wire [29:18] sum_h1;
  wire        ci_h;  
  wire        ci_m;  
  wire        co_h_0;
  wire        co_h_1;
  
  always @(posedge clkdec )
    if( pmana_reg )
      v_dcmd_reg <= w1_zgt01_q;
    else
      v_dcmd_reg <= w1_zgt00_q;

  always @(mbintr_reg or intradc_reg or v_dcmd_reg)
    case ({mbintr_reg,intradc_reg})
      2'b11 :mpy1in1 = {v_dcmd_reg[11],v_dcmd_reg[11:0]}; // intra DC,din
      2'b10 :mpy1in1 = {v_dcmd_reg[11:0],1'b0};           // intra AC,2*din
      default:                                        // inter,2*din+Sign(din)
        if ( v_dcmd_reg[11] == 1'b1 )
          mpy1in1[12:0] = {v_dcmd_reg[11:0],1'b0}-1;
        else if ( v_dcmd_reg == 12'h000 )
          mpy1in1[12:0] = {v_dcmd_reg[11:0],1'b0};
        else
          mpy1in1[12:0] = {v_dcmd_reg[11:0],1'b0}+1;
    endcase

  always @(posedge clkdec)
    begin
       if (mpy1in1[12] == 1'b1) begin
           mpy1in1_reg <= ~mpy1in1+1;
           mpy1sign0_reg <= 1;
          end
       else begin
         mpy1in1_reg <= mpy1in1;
         mpy1sign0_reg <= 0;
       end
       intradc_reg0_reg <= intradc_reg;
    end

  always @(posedge clkdec )
    v_qmd_reg <= w1_mtx00_q;
  
  always @(dcprec_reg or mpegx_reg)
    if( mpegx_reg )
      dcpr = 15'h0008;
    else
      case(dcprec_reg)
        2'b00:dcpr = 15'h0008;
        2'b01:dcpr = 15'h0004;
        2'b10:dcpr = 15'h0002;
        2'b11:dcpr = 15'h0001;
      endcase

  always @(posedge clkdec)
    begin
       if (intradc_reg == 1'b1)
         mpy1in2_reg <= dcpr;                     // Intra DC
       else begin                             
         mpy1in2_reg <= {7'h00,v_qmd_reg[7:0]};   // Intra AC,Inter
       end
    end
   
  always @(posedge clkdec)
    begin
      if (intradc_reg == 1'b1)
        sft10_reg <= 5'd0;                       // IQ,Intra DC
      else begin                                 // IQ,IntraAC,Inter
        if (qscale_reg == 8'h01 || qscale_reg == 8'h02)
          sft10_reg <= 5'd2;
        else
          sft10_reg <= 5'd0;
      end
    end

   
  always @(posedge clkdec)
    begin
       sum1_reg <= sum1;
       sum2_reg <= sum2;
    end
   
  assign {co_l,mpy1out1[7:0]} = sum1_reg[7:0] + sum2_reg[7:0];
  assign sum_m = sum1_reg[17:8] + sum2_reg[17:8];
  assign {co_m0,sum_m0[9:0]} = sum_m;
  assign {co_m1,sum_m1[9:0]} = sum_m + 1;   
  assign sum_h = sum1_reg[29:18] + sum2_reg[29:18];
  assign {co_h_0,sum_h0[29:18]} = sum_h;
  assign {co_h_1,sum_h1[29:18]} = sum_h + 1;   
  assign ci_h = co_l ? co_h_1 : co_h_0;
  assign mpy1out1[17:8] = ci_h ? sum_m1[9:0] : sum_m0[9:0];
  assign ci_m = co_l ? co_m1 : co_m0;
  assign mpy1out1[29:18] = ci_m ? sum_h1[29:18] : sum_h0[29:18];

  always @(posedge clkdec)
    begin
       mpy1sign1_reg <= mpy1sign0_reg;
       intradc_reg1_reg <= intradc_reg0_reg;
       sft11_reg <= sft10_reg;
    end

  always @(posedge clkdec)
     begin
       mpy1out1_reg <= mpy1out1[27:0];
       sft12_reg <= sft11_reg;
       intradc_reg2_reg <= intradc_reg1_reg;
       mpy1sign2_reg <= mpy1sign1_reg;
     end

  always@( mpy1out1_reg or sft12_reg )
    case( sft12_reg[4:3] )
      2'b00: sift1v=mpy1out1_reg[26:0];
      2'b01: sift1v={7'h0,mpy1out1_reg[27:8]};
      2'b10: sift1v={15'h0,mpy1out1_reg[27:16]};
      2'b11: sift1v={23'h0,mpy1out1_reg[27:24]};
    endcase

  always@( sift1v or sft12_reg )
    case(sft12_reg[2:0])
      3'b000: sift2v=sift1v[19:0];
      3'b001: sift2v=sift1v[20:1];
      3'b010: sift2v=sift1v[21:2];
      3'b011: sift2v=sift1v[22:3];
      3'b100: sift2v=sift1v[23:4];
      3'b101: sift2v=sift1v[24:5];
      3'b110: sift2v=sift1v[25:6];
      3'b111: sift2v=sift1v[26:7];
    endcase

  always @(posedge clkdec)
    begin
      mpy1out2_reg <= sift2v[18:0];
      intradc_reg3_reg <= intradc_reg2_reg;
      mpy1sign3_reg <= mpy1sign2_reg;
    end

  assign round = mpy1out2_reg;

  always @(intradc_reg3_reg or round)
    if (intradc_reg3_reg == 1'b1)
      if (round > 19'h007FF)
        lim = 15'h07FF;
      else
        lim = round[14:0];
    else
      if (round > 19'h07FFF)
        lim = 15'h7FFF;
      else
        lim = round[14:0];

  always @(posedge clkdec)
    begin
      if (mpy1sign3_reg == 1'b0)
        mtrxout_reg <= {1'b0,lim};
      else
        mtrxout_reg <= {1'b1,~lim+1};
        intradc4_reg <= intradc_reg3_reg;
    end

  iq_both iq_both(
    .b_x({4'b0000,mpy1in1_reg}),
    .b_y({2'b00,mpy1in2_reg}),
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

endmodule


