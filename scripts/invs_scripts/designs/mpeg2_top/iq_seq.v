// ----------------------------------------------
// File: iq_seq.v
// Module: iq_seq
// Function:Control of Inverse Quantization
// ----------------------------------------------

module iq_seq(
  clkdec,
  rstdec_x,
  p_mpg1_iq_r,
  c_mbpl_iq_r_s,
  p_intradcp_iq_r,
  p_alterscan_iq_r,
  p_shdet_iq_r,
  p_mbtyp_0_iq_r,
  p_qscale_iq_r,
  c_qmsynn_r_n,
  v_vdoen_r,
  c_qmseln_r,
  c_qmintra_r,
  v_vdo_r,
  c_qmdata_r,
            
  q_blkstp_r_s,
  mpegx_reg,
  mbintr_reg,
  dcprec_reg,
  qscale_reg,

  intradc_reg,
  blkst_flag_reg,
  blklst_flag_reg,
  blken_flag_reg,
  slcsf_reg,
  iyxst_reg,
  icbst_reg,
  icrst_reg,
  ybr0_reg,
  cbblk_reg,
  crblk_reg,
  pintr_reg,
  pmana_reg,
  v1_zgt00_bs,
  v1_zgt01_bs,
  v1_zgt00_a,
  v1_zgt01_a,
  v1_zgt00_we,
  v1_zgt01_we,
  v1_zgt00_d,
  v1_zgt01_d,
  v1_mtx00_bs,
  v1_mtx00_we,
  v1_mtx00_a,
  v1_mtx00_d
  );

  input       clkdec;       
  input       rstdec_x;     
  input       p_mpg1_iq_r;           // 0:MPEG2,1:MPEG1
  input       c_mbpl_iq_r_s;         // MB sync 
  input [1:0] p_intradcp_iq_r;       // Intra DC Precision   
  input       p_alterscan_iq_r;      // scan type 0:zigzag 1:alternate
  input       p_shdet_iq_r;          // Slice Home,Intra DC DPCM Reset
  input       p_mbtyp_0_iq_r;        // 0:inter,1:intra
  input [6:0] p_qscale_iq_r;         // Q Scale
  input       c_qmsynn_r_n;          // picture synchronized signal
  input       v_vdoen_r;             // vld data enable
  input       c_qmseln_r;            // ctrl data enable
  input       c_qmintra_r;           // 0:inter 1:intra 
  input [11:0] v_vdo_r;              // vld data
  input [7:0] c_qmdata_r;            // crrl data
  
  output       q_blkstp_r_s;
  output       mpegx_reg;              // 0:MPEG2,1:MPEG1
  output       mbintr_reg;             // 0:inter,1:intra  
  output [1:0] dcprec_reg;             // Intra DC Precision
  output [7:0] qscale_reg;             // Q Scale

  output       intradc_reg;            // Intra DC Flag. 1:DC,0:AC
  output       blkst_flag_reg;         // mismatch cont- mask cont
  output       blklst_flag_reg;        // mismatch cont1
  output       blken_flag_reg;         // mismatch cont2
  output       slcsf_reg;              // Slice Home,Intra DC DPCM Reset
  output       iyxst_reg;              // DPCM:IQ Yx DC latch enable
  output       icbst_reg;              // DPCM:IQ CBx DC latch enable
  output       icrst_reg;              // DPCM:IQ CRx DC latch enable
  output       ybr0_reg;               // DPCM:Y0,CB0,CR0 Flag   
  output       cbblk_reg;              // DPCM:CBx Cycle Flag
  output       crblk_reg;              // DPCM:CRx Cycle Flag
  output       pintr_reg;              // DPCM:Inter/Intra before 1MB
  output       pmana_reg;              // page control

  output       v1_zgt00_bs;            // zzt00 memory block selct 
  output       v1_zgt01_bs;            // zzt01 memory block selct
  output [8:0] v1_zgt00_a;             // zzt00 memory address
  output [8:0] v1_zgt01_a;             // zzt01 memory address
  output       v1_zgt00_we;            // zzt00 0:read 1:write
  output       v1_zgt01_we;            // zzt01 0:read 1:write
  output [11:0] v1_zgt00_d;            // zzt00 output data 
  output [11:0] v1_zgt01_d;            // zzt01 output data
  output       v1_mtx00_bs;            // mtx00 memory block selct
  output       v1_mtx00_we;            // mtx00 0:read 1:write
  output [6:0] v1_mtx00_a;             // mtx00 memory address
  output [7:0] v1_mtx00_d;             // mtx00 output data
  

  reg        mpegx_reg;                // 0:MPEG2,1:MPEG1
  reg        mbintr_reg;               // 0:inter,1:intra
  reg [1:0]  dcprec_reg;               // Intra DC Precision
  reg        slcsf_reg;                // Slice Home,Intra DC DPCM Reset
  reg [6:0]  qscale0_reg;              // Q Scale
  reg        scntp_reg;                // scan type 0:zigzag 1:alternate
  reg        mbsync_reg;               // macro block synchronized signal
  reg        intradc_reg;              // Intra DC Flag. 1:DC,0:AC
  reg        blkst_flag_reg;           // mismatch cont- mask cont
  reg        blklst_flag_reg;          // mismatch cont1
  reg        blken_flag_reg;           // mismatch cont2
  
  
  reg        iyxst_reg;           // DPCM:IQ Yx DC latch enable
  reg        icbst_reg;           // DPCM:IQ CBx DC latch enable
  reg        icrst_reg;           // DPCM:IQ CRx DC latch enable

  reg        ybr0_reg;            // DPCM:Y0,CB0,CR0 Flag   
  reg        cbblk_reg;           // DPCM:CBx Cycle Flag
  reg        crblk_reg;           // DPCM:CRx Cycle Flag
  reg        pintr_reg;           // DPCM:Inter/Intra before 1MB
  reg        psync_reg;           // picture synchronized signal
  reg        pmana_reg;           // page control
  reg        vld_den_reg;         // vld data enable  
  reg        ctr_den_reg;         // ctrl data enable
  reg [11:0] vld_d_reg;
  reg [7:0]  ctr_d_reg;
  reg [11:0] v1_zgt00_d;
  reg [11:0] v1_zgt01_d;
  reg [7:0]  v1_mtx00_d;
  reg        ctr_mbintr_reg;
  reg        q_blkstp_r_s;
  reg [8:0]  seq_count_reg;       // Operation Counter
  reg        qiq_run_reg;
  reg        read_bs;             //read enable
  reg [8:0]  vld_cnt_reg;
  reg        scan_type;
  reg [5:0]  write_addr;          //write address
  reg        v1_zgt00_bs;
  reg        v1_zgt01_bs;
  reg [8:0]  v1_zgt00_a;
  reg [8:0]  v1_zgt01_a;
  reg        v1_zgt00_we;
  reg        v1_zgt01_we;
  reg [5:0]  mtx_cnt_reg;
  reg [5:0]  write_addr2;         //write address
  reg        v1_mtx00_bs;
  reg        v1_mtx00_we;
  reg [6:0]  v1_mtx00_a;

  wire [7:0] qscale_reg;          // Q Scale
  
  
  always @(posedge clkdec)
    begin
      mbsync_reg <= c_mbpl_iq_r_s;
      mpegx_reg <= p_mpg1_iq_r;
      mbintr_reg <= p_mbtyp_0_iq_r;
      qscale0_reg <= p_qscale_iq_r;
      dcprec_reg <= p_intradcp_iq_r;
      scntp_reg <= p_alterscan_iq_r;
      psync_reg <= c_qmsynn_r_n;
    end

  assign qscale_reg = {1'b0,qscale0_reg};
    
  always @(posedge clkdec or negedge rstdec_x)
    if (!rstdec_x) begin
      slcsf_reg <= 0;
      pintr_reg <= 0;
    end
    else if (mbsync_reg == 1'b1) begin
      slcsf_reg <= p_shdet_iq_r;
      pintr_reg <= mbintr_reg;
    end
    else begin
      slcsf_reg <= slcsf_reg;
      pintr_reg <= pintr_reg;
    end

   always@( posedge clkdec or negedge rstdec_x )
    if(!rstdec_x)
      pmana_reg <= 1'b1;
    else
      if( !psync_reg )
        pmana_reg <= 1'b1;
      else if( mbsync_reg )
        pmana_reg <= ~pmana_reg;
      else
        pmana_reg <= pmana_reg;
  
  always @(posedge clkdec or negedge rstdec_x)
    if (!rstdec_x)
      seq_count_reg <= 9'h000;
    else begin
    if (mbsync_reg)
      seq_count_reg <= 9'h000;
    else
      seq_count_reg <= seq_count_reg + 1;
    end

  always @(posedge clkdec or negedge rstdec_x)
    if (!rstdec_x)
      qiq_run_reg <= 1'b0;
    else
      if (mbsync_reg)
        qiq_run_reg <= 1'b1;
      else if (seq_count_reg == 9'd396)
        qiq_run_reg <= 1'b0;
      else
        qiq_run_reg <= qiq_run_reg;

  always @(posedge clkdec)
  if (seq_count_reg[5:0] == 6'd2 && mbintr_reg == 1'b1 && qiq_run_reg == 1'b1)
    intradc_reg <= 1'b1;
  else
    intradc_reg <= 1'b0;

  always @(posedge clkdec)
  if (seq_count_reg[5:0] == 6'd12 && qiq_run_reg == 1'b1)
    blkst_flag_reg <= 1'b1;
  else
    blkst_flag_reg <= 1'b0;

  always @(posedge clkdec)
  if (seq_count_reg[5:0] == 6'd11 && mpegx_reg == 1'b0 && qiq_run_reg == 1'b1)
    blklst_flag_reg <= 1'b1;
  else
    blklst_flag_reg <= 1'b0;
  
  always @(posedge clkdec)
    if (seq_count_reg[5:0] == 6'd11 && seq_count_reg[8] == 1'b0 && qiq_run_reg == 1'b1)
      iyxst_reg <= 1'b1;
    else
      iyxst_reg <= 1'b0;

  always @(posedge clkdec)
    if (seq_count_reg == 9'd267  && qiq_run_reg == 1'b1)  // Cb0
      icbst_reg <= 1'b1;
    else
      icbst_reg <= 1'b0;

  always @(posedge clkdec)
    if (seq_count_reg == 9'd331 && qiq_run_reg == 1'b1)  // Cr0
      icrst_reg <= 1'b1;
    else
      icrst_reg <= 1'b0;

  always @(posedge clkdec)
    if ((seq_count_reg == 9'd6 || seq_count_reg == 9'd262 || seq_count_reg == 9'd326 ) && qiq_run_reg )
      ybr0_reg <= 1'b1;
    else
      ybr0_reg <= 1'b0;
 
  always @(posedge clkdec)
    if (9'd261 < seq_count_reg && seq_count_reg[8:0] < 9'd326 && qiq_run_reg)
      cbblk_reg <= 1'b1;
    else
      cbblk_reg <= 1'b0;

  always @(posedge clkdec)
    if ( 9'd325 < seq_count_reg && qiq_run_reg == 1'b1 )
      crblk_reg <= 1'b1;
    else
      crblk_reg <= 1'b0;

  always @(posedge clkdec or negedge rstdec_x)
    if (!rstdec_x) begin
      blken_flag_reg <= 1'b0;
    end
    else begin
      if (seq_count_reg == 9'd12 && qiq_run_reg == 1'b1 ) begin
        blken_flag_reg <= 1'b1;
      end
      else if (seq_count_reg == 9'd402 ) begin
        blken_flag_reg <= 1'b0;
      end
      else begin
        blken_flag_reg <= blken_flag_reg;
      end
    end

  always@( seq_count_reg or qiq_run_reg or qiq_run_reg )
    if( 9'd0 <= seq_count_reg && seq_count_reg <= 9'd383 && qiq_run_reg )
      read_bs = 1'b1;
    else
      read_bs = 1'b0;

  always@( posedge clkdec )
    begin
      vld_den_reg <= v_vdoen_r;
      ctr_den_reg <= c_qmseln_r;
      vld_d_reg <= v_vdo_r;
      ctr_d_reg <= c_qmdata_r;
      ctr_mbintr_reg <= c_qmintra_r;
    end

  always@( posedge clkdec or negedge rstdec_x )
    if( !rstdec_x )
      vld_cnt_reg <= 9'd0;
    else
      if( mbsync_reg )
        vld_cnt_reg <= 9'd0;
      else if( vld_den_reg )
        vld_cnt_reg <= vld_cnt_reg + 9'd1;
      else
        vld_cnt_reg <= vld_cnt_reg;

  always@( scntp_reg or mpegx_reg )
    if( mpegx_reg )
      scan_type = 1'b1;
    else
      scan_type = ~scntp_reg;
  
  always@( vld_cnt_reg or scan_type )
  if( scan_type )            //zigzag
    case( vld_cnt_reg[5:0] )
      6'd0 : write_addr = 6'd0;
      6'd1 : write_addr = 6'd1;
      6'd2 : write_addr = 6'd8;
      6'd3 : write_addr = 6'd16;
      6'd4 : write_addr = 6'd9;
      6'd5 : write_addr = 6'd2;
      6'd6 : write_addr = 6'd3;
      6'd7 : write_addr = 6'd10;
      6'd8 : write_addr = 6'd17; 
      6'd9 : write_addr = 6'd24;
      6'd10 : write_addr = 6'd32;
      6'd11 : write_addr = 6'd25;
      6'd12 : write_addr = 6'd18; 
      6'd13 : write_addr = 6'd11; 
      6'd14 : write_addr = 6'd4; 
      6'd15 : write_addr = 6'd5; 
      6'd16 : write_addr = 6'd12; 
      6'd17 : write_addr = 6'd19; 
      6'd18 : write_addr = 6'd26;
      6'd19 : write_addr = 6'd33; 
      6'd20 : write_addr = 6'd40; 
      6'd21 : write_addr = 6'd48; 
      6'd22 : write_addr = 6'd41; 
      6'd23 : write_addr = 6'd34; 
      6'd24 : write_addr = 6'd27; 
      6'd25 : write_addr = 6'd20; 
      6'd26 : write_addr = 6'd13; 
      6'd27 : write_addr = 6'd6; 
      6'd28 : write_addr = 6'd7;
      6'd29 : write_addr = 6'd14;      
      6'd30 : write_addr = 6'd21; 
      6'd31 : write_addr = 6'd28; 
      6'd32 : write_addr = 6'd35; 
      6'd33 : write_addr = 6'd42; 
      6'd34 : write_addr = 6'd49; 
      6'd35 : write_addr = 6'd56; 
      6'd36 : write_addr = 6'd57; 
      6'd37 : write_addr = 6'd50; 
      6'd38 : write_addr = 6'd43; 
      6'd39 : write_addr = 6'd36; 
      6'd40 : write_addr = 6'd29; 
      6'd41 : write_addr = 6'd22; 
      6'd42 : write_addr = 6'd15; 
      6'd43 : write_addr = 6'd23; 
      6'd44 : write_addr = 6'd30; 
      6'd45 : write_addr = 6'd37; 
      6'd46 : write_addr = 6'd44; 
      6'd47 : write_addr = 6'd51; 
      6'd48 : write_addr = 6'd58; 
      6'd49 : write_addr = 6'd59; 
      6'd50 : write_addr = 6'd52; 
      6'd51 : write_addr = 6'd45; 
      6'd52 : write_addr = 6'd38; 
      6'd53 : write_addr = 6'd31; 
      6'd54 : write_addr = 6'd39; 
      6'd55 : write_addr = 6'd46; 
      6'd56 : write_addr = 6'd53; 
      6'd57 : write_addr = 6'd60; 
      6'd58 : write_addr = 6'd61; 
      6'd59 : write_addr = 6'd54; 
      6'd60 : write_addr = 6'd47;
      6'd61 : write_addr = 6'd55;
      6'd62 : write_addr = 6'd62;
      6'd63 : write_addr = 6'd63;
    endcase
  else  //alternate
    case( vld_cnt_reg[5:0] )
      6'd0 : write_addr = 6'd0;
      6'd1 : write_addr = 6'd8;
      6'd2 : write_addr = 6'd16;
      6'd3 : write_addr = 6'd24;
      6'd4 : write_addr = 6'd1;
      6'd5 : write_addr = 6'd9;
      6'd6 : write_addr = 6'd2;
      6'd7 : write_addr = 6'd10;
      6'd8 : write_addr = 6'd17; 
      6'd9 : write_addr = 6'd25; 
      6'd10 : write_addr = 6'd32; 
      6'd11 : write_addr = 6'd40; 
      6'd12 : write_addr = 6'd48; 
      6'd13 : write_addr = 6'd56; 
      6'd14 : write_addr = 6'd57; 
      6'd15 : write_addr = 6'd49; 
      6'd16 : write_addr = 6'd41; 
      6'd17 : write_addr = 6'd33; 
      6'd18 : write_addr = 6'd26; 
      6'd19 : write_addr = 6'd18; 
      6'd20 : write_addr = 6'd3; 
      6'd21 : write_addr = 6'd11; 
      6'd22 : write_addr = 6'd4; 
      6'd23 : write_addr = 6'd12; 
      6'd24 : write_addr = 6'd19; 
      6'd25 : write_addr = 6'd27; 
      6'd26 : write_addr = 6'd34; 
      6'd27 : write_addr = 6'd42; 
      6'd28 : write_addr = 6'd50; 
      6'd29 : write_addr = 6'd58; 
      6'd30 : write_addr = 6'd35; 
      6'd31 : write_addr = 6'd43; 
      6'd32 : write_addr = 6'd51; 
      6'd33 : write_addr = 6'd59; 
      6'd34 : write_addr = 6'd20; 
      6'd35 : write_addr = 6'd28; 
      6'd36 : write_addr = 6'd5; 
      6'd37 : write_addr = 6'd13; 
      6'd38 : write_addr = 6'd6; 
      6'd39 : write_addr = 6'd14; 
      6'd40 : write_addr = 6'd21; 
      6'd41 : write_addr = 6'd29; 
      6'd42 : write_addr = 6'd36; 
      6'd43 : write_addr = 6'd44; 
      6'd44 : write_addr = 6'd52; 
      6'd45 : write_addr = 6'd60; 
      6'd46 : write_addr = 6'd37; 
      6'd47 : write_addr = 6'd45; 
      6'd48 : write_addr = 6'd53; 
      6'd49 : write_addr = 6'd61; 
      6'd50 : write_addr = 6'd22; 
      6'd51 : write_addr = 6'd30; 
      6'd52 : write_addr = 6'd7; 
      6'd53 : write_addr = 6'd15; 
      6'd54 : write_addr = 6'd23; 
      6'd55 : write_addr = 6'd31; 
      6'd56 : write_addr = 6'd38; 
      6'd57 : write_addr = 6'd46; 
      6'd58 : write_addr = 6'd54; 
      6'd59 : write_addr = 6'd62; 
      6'd60 : write_addr = 6'd39;
      6'd61 : write_addr = 6'd47;
      6'd62 : write_addr = 6'd55;
      6'd63 : write_addr = 6'd63;
    endcase

  always@( posedge clkdec )
    if( pmana_reg )
      begin
        v1_zgt00_bs <= vld_den_reg;
        v1_zgt00_a <= {vld_cnt_reg[8:6],write_addr};
        v1_zgt00_we <= 1'b1;
        v1_zgt01_bs <= read_bs;
        v1_zgt01_a <= seq_count_reg;
        v1_zgt01_we <= 1'b0;
      end
    else
      begin
        v1_zgt00_bs <= read_bs;
        v1_zgt00_a <= seq_count_reg;
        v1_zgt00_we <= 1'b0;
        v1_zgt01_bs <= vld_den_reg;
        v1_zgt01_a <= {vld_cnt_reg[8:6],write_addr};
        v1_zgt01_we <= 1'b1;
      end

  always@( posedge clkdec )
    begin
      v1_zgt00_d <= vld_d_reg;
      v1_zgt01_d <= vld_d_reg;
    end
  
  always@( posedge clkdec or negedge rstdec_x )
    if( !rstdec_x )
      mtx_cnt_reg <= 6'd0;
    else
      if( !psync_reg )
        mtx_cnt_reg <= 6'd0;
      else if( ctr_den_reg )
        mtx_cnt_reg <= mtx_cnt_reg + 6'd1;
      else
        mtx_cnt_reg <= mtx_cnt_reg;

  always@( mtx_cnt_reg)
    case( mtx_cnt_reg )
      6'd0 : write_addr2 = 6'd0;
      6'd1 : write_addr2 = 6'd1;
      6'd2 : write_addr2 = 6'd8;
      6'd3 : write_addr2 = 6'd16;
      6'd4 : write_addr2 = 6'd9;
      6'd5 : write_addr2 = 6'd2;
      6'd6 : write_addr2 = 6'd3;
      6'd7 : write_addr2 = 6'd10;
      6'd8 : write_addr2 = 6'd17; 
      6'd9 : write_addr2 = 6'd24;
      6'd10 : write_addr2 = 6'd32;
      6'd11 : write_addr2 = 6'd25;
      6'd12 : write_addr2 = 6'd18; 
      6'd13 : write_addr2 = 6'd11; 
      6'd14 : write_addr2 = 6'd4; 
      6'd15 : write_addr2 = 6'd5; 
      6'd16 : write_addr2 = 6'd12; 
      6'd17 : write_addr2 = 6'd19; 
      6'd18 : write_addr2 = 6'd26;
      6'd19 : write_addr2 = 6'd33; 
      6'd20 : write_addr2 = 6'd40; 
      6'd21 : write_addr2 = 6'd48; 
      6'd22 : write_addr2 = 6'd41; 
      6'd23 : write_addr2 = 6'd34; 
      6'd24 : write_addr2 = 6'd27; 
      6'd25 : write_addr2 = 6'd20; 
      6'd26 : write_addr2 = 6'd13; 
      6'd27 : write_addr2 = 6'd6; 
      6'd28 : write_addr2 = 6'd7;
      6'd29 : write_addr2 = 6'd14;      
      6'd30 : write_addr2 = 6'd21; 
      6'd31 : write_addr2 = 6'd28; 
      6'd32 : write_addr2 = 6'd35; 
      6'd33 : write_addr2 = 6'd42; 
      6'd34 : write_addr2 = 6'd49; 
      6'd35 : write_addr2 = 6'd56; 
      6'd36 : write_addr2 = 6'd57; 
      6'd37 : write_addr2 = 6'd50; 
      6'd38 : write_addr2 = 6'd43; 
      6'd39 : write_addr2 = 6'd36; 
      6'd40 : write_addr2 = 6'd29; 
      6'd41 : write_addr2 = 6'd22; 
      6'd42 : write_addr2 = 6'd15; 
      6'd43 : write_addr2 = 6'd23; 
      6'd44 : write_addr2 = 6'd30; 
      6'd45 : write_addr2 = 6'd37; 
      6'd46 : write_addr2 = 6'd44; 
      6'd47 : write_addr2 = 6'd51; 
      6'd48 : write_addr2 = 6'd58; 
      6'd49 : write_addr2 = 6'd59; 
      6'd50 : write_addr2 = 6'd52; 
      6'd51 : write_addr2 = 6'd45; 
      6'd52 : write_addr2 = 6'd38; 
      6'd53 : write_addr2 = 6'd31; 
      6'd54 : write_addr2 = 6'd39; 
      6'd55 : write_addr2 = 6'd46; 
      6'd56 : write_addr2 = 6'd53; 
      6'd57 : write_addr2 = 6'd60; 
      6'd58 : write_addr2 = 6'd61; 
      6'd59 : write_addr2 = 6'd54; 
      6'd60 : write_addr2 = 6'd47;
      6'd61 : write_addr2 = 6'd55;
      6'd62 : write_addr2 = 6'd62;
      6'd63 : write_addr2 = 6'd63;
    endcase

  always@( posedge clkdec )
    begin
      v1_mtx00_bs <= ctr_den_reg | read_bs;
      v1_mtx00_we <= ctr_den_reg;
      v1_mtx00_d <= ctr_d_reg;
    end

  always@( posedge clkdec )
    if( ctr_den_reg )
      v1_mtx00_a <= {ctr_mbintr_reg,write_addr2};
    else
      v1_mtx00_a <= {mbintr_reg,seq_count_reg[5:0]};

always@( posedge clkdec )
  if( seq_count_reg[5:0] == 6'd13 && qiq_run_reg )
    q_blkstp_r_s <= 1'b1;
  else
    q_blkstp_r_s <= 1'b0;     
  
endmodule


