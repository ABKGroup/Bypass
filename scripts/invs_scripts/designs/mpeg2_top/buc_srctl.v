// ----------------------------------------------
// File: buc_srctl.v
// Module: buc_srctl
// Function:
// ----------------------------------------------

module buc_srctl(
  clkdec,
  rstdec_x,
  c_mbpl_uc_r_s,
  c_bfcnt_init_r,
  vrh_read_data_r,
  vrh_read_enable_r,
  f_whdtvh_r,
  f_wprgseq_r,
  f_wpred_forward_buc_r,
  f_wpred_backward_buc_r,
  f_w2pred_forward_r,
  f_w2pred_backward_r,
  f_wmttyp_r,
  f_whvec1y_r,
  f_wvvec1y_r,
  f_whvec2y_r,
  f_wvvec2y_r,
  f_whvec3y_r,
  f_wvvec3y_r,
  f_whvec4y_r,
  f_wvvec4y_r,
  f_whvec1c_r,
  f_wvvec1c_r,
  f_whvec2c_r,
  f_wvvec2c_r,
  f_whvec3c_r,
  f_wvvec3c_r,
  f_whvec4c_r,
  f_wvvec4c_r,
  w1_rfa00_q,
  w1_rfb00_q,
  w1_rfa01_q,
  w1_rfb01_q,
  w1_rfa02_q,
  w1_rfb02_q,
  w1_rfa03_q,
  w1_rfb03_q,
  w1_rfa04_q,
  w1_rfb04_q,
  w1_rfa05_q,
  w1_rfb05_q,
  f_mbpl_buc_d1_r_s,
  f_regwen_r,
  f_ref1dt_r,
  f_ref1yen_r,
  f_ref1cen_r,
  f_ref2dt_r,
  f_ref2yen_r,
  f_ref2cen_r,
  f_hdtvh_r,
  f_prgseq_r,
  f_pred_forward_buc_r,
  f_pred_backward_buc_r,
  f_mttyp_r,
  f_hvec1y_r,
  f_vvec1y_r,
  f_hvec2y_r,
  f_vvec2y_r,
  f_hvec3y_r,
  f_vvec3y_r,
  f_hvec4y_r,
  f_vvec4y_r,
  f_hvec1c_r,
  f_vvec1c_r,
  f_hvec2c_r,
  f_vvec2c_r,
  f_hvec3c_r,
  f_vvec3c_r,
  f_hvec4c_r,
  f_vvec4c_r,
  f_bfud_err_r,
  v1_rfa00_a,
  v1_rfa00_d,
  v1_rfa00_bs,
  v1_rfa00_we,
  v1_rfb00_a,
  v1_rfb00_d,
  v1_rfb00_bs,
  v1_rfb00_we,
  v1_rfa01_a,
  v1_rfa01_d,
  v1_rfa01_bs,
  v1_rfa01_we,
  v1_rfb01_a,
  v1_rfb01_d,
  v1_rfb01_bs,
  v1_rfb01_we,
  v1_rfa02_a,
  v1_rfa02_d,
  v1_rfa02_bs,
  v1_rfa02_we,
  v1_rfb02_a,
  v1_rfb02_d,
  v1_rfb02_bs,
  v1_rfb02_we,
  v1_rfa03_a,
  v1_rfa03_d,
  v1_rfa03_bs,
  v1_rfa03_we,
  v1_rfb03_a,
  v1_rfb03_d,
  v1_rfb03_bs,
  v1_rfb03_we,
  v1_rfa04_a,
  v1_rfa04_d,
  v1_rfa04_bs,
  v1_rfa04_we,
  v1_rfb04_a,
  v1_rfb04_d,
  v1_rfb04_bs,
  v1_rfb04_we,
  v1_rfa05_a,
  v1_rfa05_d,
  v1_rfa05_bs,
  v1_rfa05_we,
  v1_rfb05_a,
  v1_rfb05_d,
  v1_rfb05_bs,
  v1_rfb05_we,
  f_bfcnt_init_r
  );
  
  input         clkdec;          
  input         rstdec_x;        
  input         c_mbpl_uc_r_s;     
  input         c_bfcnt_init_r;    
  input [63:0]  vrh_read_data_r;     
  input         vrh_read_enable_r;   
  input         f_whdtvh_r;        
  input         f_wprgseq_r;       
  input         f_wpred_forward_buc_r;
  input         f_wpred_backward_buc_r;
  input         f_w2pred_forward_r; 
  input         f_w2pred_backward_r;
  input [1:0]   f_wmttyp_r;         
  input [3:0]   f_whvec1y_r;        
  input [2:0]   f_wvvec1y_r;        
  input [3:0]   f_whvec2y_r;        
  input [2:0]   f_wvvec2y_r;        
  input [3:0]   f_whvec3y_r;        
  input [2:0]   f_wvvec3y_r;        
  input [3:0]   f_whvec4y_r;        
  input [2:0]   f_wvvec4y_r;        
  input [2:0]   f_whvec1c_r;        
  input [1:0]   f_wvvec1c_r;        
  input [2:0]   f_whvec2c_r;        
  input [1:0]   f_wvvec2c_r;        
  input [2:0]   f_whvec3c_r;        
  input [1:0]   f_wvvec3c_r;        
  input [2:0]   f_whvec4c_r;        
  input [1:0]   f_wvvec4c_r;        
  input [63:0]  w1_rfa00_q;           
  input [15:0]  w1_rfb00_q;           
  input [63:0]  w1_rfa01_q;           
  input [15:0]  w1_rfb01_q;           
  input [63:0]  w1_rfa02_q;           
  input [15:0]  w1_rfb02_q;           
  input [63:0]  w1_rfa03_q;           
  input [15:0]  w1_rfb03_q;           
  input [63:0]  w1_rfa04_q;           
  input [15:0]  w1_rfb04_q;           
  input [63:0]  w1_rfa05_q;           
  input [15:0]  w1_rfb05_q;           
  input         f_mbpl_buc_d1_r_s;  
  input         f_regwen_r;         
  output [63:0] f_ref1dt_r;         
  output        f_ref1yen_r;        
  output        f_ref1cen_r;        
  output [63:0] f_ref2dt_r;         
  output        f_ref2yen_r;        
  output        f_ref2cen_r;        
  output        f_hdtvh_r;          
  output        f_prgseq_r;         
  output        f_pred_forward_buc_r;
  output        f_pred_backward_buc_r;
  output [1:0]  f_mttyp_r;          
  output [3:0]  f_hvec1y_r;         
  output [2:0]  f_vvec1y_r;         
  output [3:0]  f_hvec2y_r;         
  output [2:0]  f_vvec2y_r;         
  output [3:0]  f_hvec3y_r;         
  output [2:0]  f_vvec3y_r;         
  output [3:0]  f_hvec4y_r;         
  output [2:0]  f_vvec4y_r;         
  output [2:0]  f_hvec1c_r;         
  output [1:0]  f_vvec1c_r;         
  output [2:0]  f_hvec2c_r;         
  output [1:0]  f_vvec2c_r;         
  output [2:0]  f_hvec3c_r;         
  output [1:0]  f_vvec3c_r;         
  output [2:0]  f_hvec4c_r;         
  output [1:0]  f_vvec4c_r;         
  output        f_bfud_err_r;       
  output [5:0]  v1_rfa00_a;           
  output [63:0] v1_rfa00_d;           
  output        v1_rfa00_bs;          
  output        v1_rfa00_we;          
  output [4:0]  v1_rfb00_a;           
  output [15:0] v1_rfb00_d;           
  output        v1_rfb00_bs;          
  output        v1_rfb00_we;          
  output [5:0]  v1_rfa01_a;           
  output [63:0] v1_rfa01_d;           
  output        v1_rfa01_bs;          
  output        v1_rfa01_we;          
  output [4:0]  v1_rfb01_a;           
  output [15:0] v1_rfb01_d;           
  output        v1_rfb01_bs;          
  output        v1_rfb01_we;          
  output [5:0]  v1_rfa02_a;           
  output [63:0] v1_rfa02_d;           
  output        v1_rfa02_bs;          
  output        v1_rfa02_we;          
  output [4:0]  v1_rfb02_a;           
  output [15:0] v1_rfb02_d;           
  output        v1_rfb02_bs;          
  output        v1_rfb02_we;          
  output [5:0]  v1_rfa03_a;           
  output [63:0] v1_rfa03_d;           
  output        v1_rfa03_bs;          
  output        v1_rfa03_we;          
  output [4:0]  v1_rfb03_a;           
  output [15:0] v1_rfb03_d;           
  output        v1_rfb03_bs;          
  output        v1_rfb03_we;          
  output [5:0]  v1_rfa04_a;           
  output [63:0] v1_rfa04_d;           
  output        v1_rfa04_bs;          
  output        v1_rfa04_we;          
  output [4:0]  v1_rfb04_a;           
  output [15:0] v1_rfb04_d;           
  output        v1_rfb04_bs;          
  output        v1_rfb04_we;          
  output [5:0]  v1_rfa05_a;           
  output [63:0] v1_rfa05_d;           
  output        v1_rfa05_bs;          
  output        v1_rfa05_we;          
  output [4:0]  v1_rfb05_a;           
  output [15:0] v1_rfb05_d;           
  output        v1_rfb05_bs;        
  output        v1_rfb05_we;        
  output        f_bfcnt_init_r;   
  

  wire          c_mbpl_uc_r_s;        // MB Pulse(UC Pahse)
  wire          c_bfcnt_init_r;       // Buffer Control Reset Pulse
  wire [63:0]   vrh_read_data_r;      // I/F Read Data
  wire          vrh_read_enable_r;    // I/F Read Data Enable
  wire          f_whdtvh_r;           // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  wire          f_wprgseq_r;          // MB Interlace/Progressive Select[0:Interlace 1:Progressive]
  wire          f_wpred_forward_buc_r;// MB Forward Estimate Valid Flag
  wire          f_wpred_backward_buc_r;// MB Backward Estimate Valid Flag
  wire          f_w2pred_forward_r;   // MB Forward Estimate Valid Flag
  wire          f_w2pred_backward_r;  // MB Backward Estimate Valid Flag
  wire [1:0]    f_wmttyp_r;           // MB Estimate Mode
  wire [3:0]    f_whvec1y_r;          // Horizontal Vector1(Y)
  wire [2:0]    f_wvvec1y_r;          // Vertical Vector1(Y)
  wire [3:0]    f_whvec2y_r;          // Horizontal Vector2(Y)
  wire [2:0]    f_wvvec2y_r;          // Vertical Vector2(Y)
  wire [3:0]    f_whvec3y_r;          // Horizontal Vector3(Y)
  wire [2:0]    f_wvvec3y_r;          // Vertical Vector3(Y)
  wire [3:0]    f_whvec4y_r;          // Horizontal Vector4(Y)
  wire [2:0]    f_wvvec4y_r;          // Vertical Vector4(Y)
  wire [2:0]    f_whvec1c_r;          // Horizontal Vector1(C)
  wire [1:0]    f_wvvec1c_r;          // Vertical Vector1(C)
  wire [2:0]    f_whvec2c_r;          // Horizontal Vector2(C)
  wire [1:0]    f_wvvec2c_r;          // Vertical Vector2(C)
  wire [2:0]    f_whvec3c_r;          // Horizontal Vector3(C)
  wire [1:0]    f_wvvec3c_r;          // Vertical Vector3(C)
  wire [2:0]    f_whvec4c_r;          // Horizontal Vector4(C)
  wire [1:0]    f_wvvec4c_r;          // Vertical Vector4(C)
  wire [63:0]   w1_rfa00_q;           // UC Bus I/F Buffer Memory1-1 Read Data
  wire [15:0]   w1_rfb00_q;           // UC Bus I/F Buffer Memory1-2 Read Data
  wire [63:0]   w1_rfa01_q;           // UC Bus I/F Buffer Memory2-1 Read Data
  wire [15:0]   w1_rfb01_q;           // UC Bus I/F Buffer Memory2-2 Read Data
  wire [63:0]   w1_rfa02_q;           // UC Bus I/F Buffer Memory3-1 Read Data
  wire [15:0]   w1_rfb02_q;           // UC Bus I/F Buffer Memory3-2 Read Data
  wire [63:0]   w1_rfa03_q;           // UC Bus I/F Buffer Memory4-1 Read Data
  wire [15:0]   w1_rfb03_q;           // UC Bus I/F Buffer Memory4-2 Read Data
  wire [63:0]   w1_rfa04_q;           // UC Bus I/F Buffer Memory5-1 Read Data
  wire [15:0]   w1_rfb04_q;           // UC Bus I/F Buffer Memory5-2 Read Data
  wire [63:0]   w1_rfa05_q;           // UC Bus I/F Buffer Memory6-1 Read Data
  wire [15:0]   w1_rfb05_q;           // UC Bus I/F Buffer Memory6-2 Read Data
  wire          f_mbpl_buc_d1_r_s;    // MB Pulse
  wire          f_regwen_r;           // 3-Stage Register Enable
  
  wire          f_mbpl_uc_s;          // MB Pulse
  wire          f_wmttyp_dc;          // f_wmttyp_r Decode(3h)
  wire          f_wadr_rst;           // Write Address Reset
  wire          f_dtr_cnt_dc0;        // SRAM Read Data Counter Decode(0h)
  wire          f_dtr_cnt_dc1;        // SRAM Read Data Counter Decode(1h)
  wire          f_dtr_cnt_dc2;        // SRAM Read Data Counter Decode(2h)
  wire          f_wadr_enb;           // SRAM Write Address Enable
  wire          f_wadr_dc37;          // Write Address Decode(37h)
  wire          f_wadr_dc2f;          // Write Address Decode(2fh)
  wire          f_rad_cnt0_dc37;      // SRAM Read Address Counter0 Decode(37h)
  wire          f_rad_cnt0_dc4b;      // SRAM Read Address Counter0 Decode(4bh)
  wire          f_rad_cnt0_dcd0;      // SRAM Read Address Counter0 Decode(d0h)
  wire          f_rad_cnt0_dc100;     // SRAM Read Address Counter0 Decode(100h)
  wire          f_rad_cnt0_gt24;      // SRAM Read Address Counter0 gt 24h
  wire          f_rad_cnt0_gta0;      // SRAM Read Address Counter0 gt a0h
  wire          f_rad_cnt0_eq40;      // SRAM Read Address Counter0 eq 40h
  wire          f_rad_cnt0_eqa0;      // SRAM Read Address Counter0 eq a0h
  wire          f_rad_cnt0_le4b;      // SRAM Read Address Counter0 le 4bh
  wire          f_rad_cnt0_leff;      // SRAM Read Address Counter0 le ffh
  wire          f_rad_cnt0_le4f;      // SRAM Read Address Counter0 le 4fh
  wire          f_rad_cnt0_le50;      // SRAM Read Address Counter0 le 50h
  wire          f_rad_cnt0_g50l9f;    // SRAM Read Address Counter0 ge 50h le 9fh
  wire          f_rad_cnt0_g51la0;    // SRAM Read Address Counter0 ge 51h le a0h
  wire          f_rad_cnt0_ga0lb7;    // SRAM Read Address Counter0 ge a0h le b7h
  wire          f_rad_cnt0_ga1lb8;    // SRAM Read Address Counter0 ge a1h le b8h
  wire          f_rad_cnt0_gb8lcf;    // SRAM Read Address Counter0 ge b8h le cfh
  wire          f_rad_cnt0_gb9ld0;    // SRAM Read Address Counter0 ge b9h le d0h
  wire          f_rad_cnt0_gd0le7;    // SRAM Read Address Counter0 ge d0h le e7h
  wire          f_rad_cnt0_gd1le8;    // SRAM Read Address Counter0 ge d1h le e8h
  wire          f_rad_cnt0_gee8;      // SRAM Read Address Counter0 ge e8h
  wire          f_rad_cnt0_gee9;      // SRAM Read Address Counter0 ge e9h
  wire          f_rad_cnt0_g12l23;    // SRAM Read Address Counter0 ge 12h le 23h
  wire          f_rad_cnt0_g2el37;    // SRAM Read Address Counter0 ge 2eh le 37h
  wire          f_rad_cnt0_ge42;      // SRAM Read Address Counter0 ge 42h
  wire          f_rad_cnt0_rst;       // SRAM Read Address Counter0 reset
  wire          f_rad_cnt_enb0;       // SRAM Read Address Counter0 Enable
  wire          f_rad_cnt_enb1;       // SRAM Read Address Counter1/2 Enable
  wire          f_srd_enb;            // SRAM Read Enable
  wire          f_dtcnt_ld;           // SRAM Read Counter Load
  wire          f_dtcnt_ldy;          // SRAM Read Counter Load(Y)
  wire          f_dtcnt_ldc;          // SRAM Read Counter Load(C)as
  wire          f_ycsel;              // SRAM Read Data Y/C Select
  wire          f_dtcnt_eq0;          // SRAM Read Counter eq 0h
  wire          f_dtcnt_eq2;          // SRAM Read Counter eq 2h
  wire          f_dtcnt_eq4;          // SRAM Read Counter eq 4h
  wire          f_dtcnt_eq8;          // SRAM Read Counter eq 8h
  wire          f_dtcnt_eq9;          // SRAM Read Counter eq 9h
  wire          f_dtcnt_eqf;          // SRAM Read Counter eq fh
  wire          f_dtcnt_eq11;         // SRAM Read Counter eq 11h
  wire          f_dtcnt_eq1f;         // SRAM Read Counter eq 1fh
  wire          f_dtcnt_lt4;          // SRAM Read Counter lt 4h
  wire          f_dtcnt_lt8;          // SRAM Read Counter lt 8h
  wire          f_dtcnt_lt10;         // SRAM Read Counter lt 10h
  wire          f_rad_cnt_enby;       // SRAM Read Address Counter0 Enable(Y)
  wire          f_rad_cnt_enbc;       // SRAM Read Address Counter0 Enable(C)
  wire          f_dto_enby;           // Data Output Enable(Y)
  wire          f_dto_enbc;           // Data Output Enable(C)
  wire          f_rwcnt_dc0;          // SRAM Read Write Counter Decode(0h)
  wire          f_srdt_sel;           // SRAM Read Data Select
  wire [63:0]   f_rf00dt;             // SRAM1 Read Data
  wire [63:0]   f_rf01dt;             // SRAM2 Read Data
  wire [63:0]   f_rf02dt;             // SRAM3 Read Data
  wire [63:0]   f_rf03dt;             // SRAM4 Read Data
  wire [63:0]   f_rf04dt;             // SRAM5 Read Data
  wire [63:0]   f_rf05dt;             // SRAM6 Read Data
  wire          f_sr1_enb;            // SRAM1 Enable
  wire          f_sr2_enb;            // SRAM2 Enable
  wire          f_sr3_enb;            // SRAM3 Enable
  wire          f_sr4_enb;            // SRAM4 Enable
  wire          f_sr5_enb;            // SRAM5 Enable
  wire          f_sr6_enb;            // SRAM6 Enable
  wire          f_sra1_wr_enb;        // SRAM1-1 Write Enable
  wire          f_srb1_wr_enb;        // SRAM1-2 Write Enable
  wire          f_sra2_wr_enb;        // SRAM2-1 Write Enable
  wire          f_srb2_wr_enb;        // SRAM2-2 Write Enable
  wire          f_sra3_wr_enb;        // SRAM3-1 Write Enable
  wire          f_srb3_wr_enb;        // SRAM3-2 Write Enable
  wire          f_sra4_wr_enb;        // SRAM4-1 Write Enable
  wire          f_srb4_wr_enb;        // SRAM4-2 Write Enable
  wire          f_sra5_wr_enb;        // SRAM5-1 Write Enable
  wire          f_srb5_wr_enb;        // SRAM5-2 Write Enable
  wire          f_sra6_wr_enb;        // SRAM6-1 Write Enable
  wire          f_srb6_wr_enb;        // SRAM6-2 Write Enable
  wire [1:0]    f_hdad_1y_ldt;        // Read Address(HDTV) Control Counter(Y1) Load Data
  wire [1:0]    f_hdad_2y_ldt;        // Read Address(HDTV) Control Counter(Y2) Load Data
  wire [1:0]    f_hdad_3y_ldt;        // Read Address(HDTV) Control Counter(Y3) Load Data
  wire [1:0]    f_hdad_4y_ldt;        // Read Address(HDTV) Control Counter(Y4) Load Data
  wire          f_hdad_1c_ldt;        // Read Address(HDTV) Control Counter(C1) Load Data
  wire          f_hdad_2c_ldt;        // Read Address(HDTV) Control Counter(C2) Load Data
  wire          f_hdad_3c_ldt;        // Read Address(HDTV) Control Counter(C3) Load Data
  wire          f_hdad_4c_ldt;        // Read Address(HDTV) Control Counter(C4) Load Data
  wire          f_hdad_cnt1y_eq7;     // f_hdad_cnt1y_r equal 7h
  wire          f_hdad_cnt2y_eq7;     // f_hdad_cnt2y_r equal 7h
  wire          f_hdad_cnt3y_eq7;     // f_hdad_cnt3y_r equal 7h
  wire          f_hdad_cnt4y_eq7;     // f_hdad_cnt4y_r equal 7h
  wire          f_hdad_cnt1c_eq3;     // f_hdad_cnt1c_r equal 3h
  wire          f_hdad_cnt2c_eq3;     // f_hdad_cnt2c_r equal 3h
  wire          f_hdad_cnt3c_eq3;     // f_hdad_cnt3c_r equal 3h
  wire          f_hdad_cnt4c_eq3;     // f_hdad_cnt4c_r equal 3h
  wire [5:0]    f_hdiad11y;           // HDTV-I Address(Y1-1)
  wire [5:0]    f_hdiad12y;           // HDTV-I Address(Y1-1)
  wire [5:0]    f_hdiad21y;           // HDTV-I Address(Y2-1)
  wire [5:0]    f_hdiad22y;           // HDTV-I Address(Y2-1)
  wire [5:0]    f_hdiad11c;           // HDTV-I Address(C1-1)
  wire [5:0]    f_hdiad12c;           // HDTV-I Address(C1-1)
  wire [5:0]    f_hdiad21c;           // HDTV-I Address(C2-1)
  wire [5:0]    f_hdiad22c;           // HDTV-I Address(C2-1)
  wire [5:0]    f_hdpad11y;           // HDTV-P Address(Y1-1)
  wire [5:0]    f_hdpad12y;           // HDTV-P Address(Y1-1)
  wire [5:0]    f_hdpad21y;           // HDTV-P Address(Y2-1)
  wire [5:0]    f_hdpad22y;           // HDTV-P Address(Y2-1)
  wire [5:0]    f_hdpad11c;           // HDTV-P Address(C1-1)
  wire [5:0]    f_hdpad12c;           // HDTV-P Address(C1-1)
  wire [5:0]    f_hdpad21c;           // HDTV-P Address(C2-1)
  wire [5:0]    f_hdpad22c;           // HDTV-P Address(C2-1)
  wire [5:0]    f_hdiadyft;           // HDTV-I Address(Y/Forward/Top)
  wire [5:0]    f_hdiadyfb;           // HDTV-I Address(Y/Forward/Bottom)
  wire [5:0]    f_hdiadybt;           // HDTV-I Address(Y/Backward/Top)
  wire [5:0]    f_hdiadybb;           // HDTV-I Address(Y/Backward/Bottom)
  wire [5:0]    f_hdiadcft;           // HDTV-I Address(C/Forward/Top)
  wire [5:0]    f_hdiadcfb;           // HDTV-I Address(C/Forward/Bottom)
  wire [5:0]    f_hdiadcbt;           // HDTV-I Address(C/Backward/Top)
  wire [5:0]    f_hdiadcbb;           // HDTV-I Address(C/Backward/Bottom)
  wire [5:0]    f_hdpyft;             // HDTV-P Address(Y/Forward/Top)
  wire [5:0]    f_hdpyfc;             // HDTV-P Address(Y/Forward/Center)
  wire [5:0]    f_hdpyfb;             // HDTV-P Address(Y/Forward/Bottom)
  wire [5:0]    f_hdpybt;             // HDTV-P Address(Y/Backward/Top)
  wire [5:0]    f_hdpybc;             // HDTV-P Address(Y/Backward/Center)
  wire [5:0]    f_hdpybb;             // HDTV-P Address(Y/Backward/Bottom)
  wire [5:0]    f_hdpcft;             // HDTV-P Address(C/Forward/Top)
  wire [5:0]    f_hdpcfc;             // HDTV-P Address(C/Forward/Center)
  wire [5:0]    f_hdpcfb;             // HDTV-P Address(C/Forward/Bottom)
  wire [5:0]    f_hdpcbt;             // HDTV-P Address(C/Backward/Top)
  wire [5:0]    f_hdpcbc;             // HDTV-P Address(C/Backward/Center)
  wire [5:0]    f_hdpcbb;             // HDTV-P Address(C/Backward/Bottom)
  wire [5:0]    f_hdpadyft;           // HDTV-P Address(Y/Forward/Top)
  wire [5:0]    f_hdpadyfb;           // HDTV-P Address(Y/Forward/Bottom)
  wire [5:0]    f_hdpadybt;           // HDTV-P Address(Y/Backward/Top)
  wire [5:0]    f_hdpadybb;           // HDTV-P Address(Y/Backward/Bottom)
  wire [5:0]    f_hdpadcft;           // HDTV-P Address(C/Forward/Top)
  wire [5:0]    f_hdpadcfb;           // HDTV-P Address(C/Forward/Bottom)
  wire [5:0]    f_hdpadcbt;           // HDTV-P Address(C/Backward/Top)
  wire [5:0]    f_hdpadcbb;           // HDTV-P Address(C/Backward/Bottom)
  wire          f_ref1_enb;           // Reference1 Data Output Enable
  wire          f_ref2_enb;           // Reference2 Data Output Enable
  
  reg [63:0]    f_ref1dt_r;           // MB Data1
  reg           f_ref1yen_r;          // MB Dara Enable1(Y)
  reg           f_ref1cen_r;          // MB Dara Enable1(C)
  reg [63:0]    f_ref2dt_r;           // MB Data2          
  reg           f_ref2yen_r;          // MB Dara Enable2(Y)
  reg           f_ref2cen_r;          // MB Dara Enable2(C)
  reg           f_hdtvh_r;            // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  reg           f_prgseq_r;           // MB Interlace/Progressive Select[0:Interlace 1:Progressive]
  reg           f_pred_forward_buc_r; // MB Forward Estimate Valid Flag
  reg           f_pred_backward_buc_r;// MB Backward Estimate Valid Flag
  reg [1:0]     f_mttyp_r;            // MB Estimate Mode
  reg [3:0]     f_hvec1y_r;           // Horizontal Vector1(Y)
  reg [2:0]     f_vvec1y_r;           // Vertical Vector1(Y)
  reg [3:0]     f_hvec2y_r;           // Horizontal Vector2(Y)
  reg [2:0]     f_vvec2y_r;           // Vertical Vector2(Y)
  reg [3:0]     f_hvec3y_r;           // Horizontal Vector3(Y)
  reg [2:0]     f_vvec3y_r;           // Vertical Vector3(Y)
  reg [3:0]     f_hvec4y_r;           // Horizontal Vector4(Y)
  reg [2:0]     f_vvec4y_r;           // Vertical Vector4(Y)
  reg [2:0]     f_hvec1c_r;           // Horizontal Vector1(C)
  reg [1:0]     f_vvec1c_r;           // Vertical Vector1(C)
  reg [2:0]     f_hvec2c_r;           // Horizontal Vector2(C)
  reg [1:0]     f_vvec2c_r;           // Vertical Vector2(C)
  reg [2:0]     f_hvec3c_r;           // Horizontal Vector3(C)
  reg [1:0]     f_vvec3c_r;           // Vertical Vector3(C)
  reg [2:0]     f_hvec4c_r;           // Horizontal Vector4(C)
  reg [1:0]     f_vvec4c_r;           // Vertical Vector4(C)
  reg           f_bfud_err_r;         // UC Buffer Read Underflow Error
  reg [5:0]     v1_rfa00_a;           // UC Bus I/F Buffer1-1 Address
  reg [63:0]    v1_rfa00_d;           // UC Bus I/F Buffer1-1 Write Data
  reg           v1_rfa00_bs;          // UC Bus I/F Buffer1-1 Block Select
  reg           v1_rfa00_we;          // UC Bus I/F Buffer1-1 Write Enable
  reg [4:0]     v1_rfb00_a;           // UC Bus I/F Buffer1-2 Address     
  reg [15:0]    v1_rfb00_d;           // UC Bus I/F Buffer1-2 Write Data  
  reg           v1_rfb00_bs;          // UC Bus I/F Buffer1-2 Block Select
  reg           v1_rfb00_we;          // UC Bus I/F Buffer1-2 Write Enable
  reg [5:0]     v1_rfa01_a;           // UC Bus I/F Buffer2-1 Address     
  reg [63:0]    v1_rfa01_d;           // UC Bus I/F Buffer2-1 Write Data  
  reg           v1_rfa01_bs;          // UC Bus I/F Buffer2-1 Block Select
  reg           v1_rfa01_we;          // UC Bus I/F Buffer2-1 Write Enable
  reg [4:0]     v1_rfb01_a;           // UC Bus I/F Buffer2-2 Address     
  reg [15:0]    v1_rfb01_d;           // UC Bus I/F Buffer2-2 Write Data  
  reg           v1_rfb01_bs;          // UC Bus I/F Buffer2-2 Block Select
  reg           v1_rfb01_we;          // UC Bus I/F Buffer2-2 Write Enable
  reg [5:0]     v1_rfa02_a;           // UC Bus I/F Buffer3-1 Address     
  reg [63:0]    v1_rfa02_d;           // UC Bus I/F Buffer3-1 Write Data  
  reg           v1_rfa02_bs;          // UC Bus I/F Buffer3-1 Block Select
  reg           v1_rfa02_we;          // UC Bus I/F Buffer3-1 Write Enable
  reg [4:0]     v1_rfb02_a;           // UC Bus I/F Buffer3-2 Address     
  reg [15:0]    v1_rfb02_d;           // UC Bus I/F Buffer3-2 Write Data  
  reg           v1_rfb02_bs;          // UC Bus I/F Buffer3-2 Block Select
  reg           v1_rfb02_we;          // UC Bus I/F Buffer3-2 Write Enable
  reg [5:0]     v1_rfa03_a;           // UC Bus I/F Buffer4-1 Address     
  reg [63:0]    v1_rfa03_d;           // UC Bus I/F Buffer4-1 Write Data  
  reg           v1_rfa03_bs;          // UC Bus I/F Buffer4-1 Block Select
  reg           v1_rfa03_we;          // UC Bus I/F Buffer4-1 Write Enable
  reg [4:0]     v1_rfb03_a;           // UC Bus I/F Buffer4-2 Address     
  reg [15:0]    v1_rfb03_d;           // UC Bus I/F Buffer4-2 Write Data  
  reg           v1_rfb03_bs;          // UC Bus I/F Buffer4-2 Block Select
  reg           v1_rfb03_we;          // UC Bus I/F Buffer4-2 Write Enable
  reg [5:0]     v1_rfa04_a;           // UC Bus I/F Buffer5-1 Address     
  reg [63:0]    v1_rfa04_d;           // UC Bus I/F Buffer5-1 Write Data  
  reg           v1_rfa04_bs;          // UC Bus I/F Buffer5-1 Block Select
  reg           v1_rfa04_we;          // UC Bus I/F Buffer5-1 Write Enable
  reg [4:0]     v1_rfb04_a;           // UC Bus I/F Buffer5-2 Address     
  reg [15:0]    v1_rfb04_d;           // UC Bus I/F Buffer5-2 Write Data  
  reg           v1_rfb04_bs;          // UC Bus I/F Buffer5-2 Block Select
  reg           v1_rfb04_we;          // UC Bus I/F Buffer5-2 Write Enable
  reg [5:0]     v1_rfa05_a;           // UC Bus I/F Buffer6-1 Address     
  reg [63:0]    v1_rfa05_d;           // UC Bus I/F Buffer6-1 Write Data  
  reg           v1_rfa05_bs;          // UC Bus I/F Buffer6-1 Block Select
  reg           v1_rfa05_we;          // UC Bus I/F Buffer6-1 Write Enable
  reg [4:0]     v1_rfb05_a;           // UC Bus I/F Buffer6-2 Address     
  reg [15:0]    v1_rfb05_d;           // UC Bus I/F Buffer6-2 Write Data  
  reg           v1_rfb05_bs;          // UC Bus I/F Buffer6-2 Block Select
  reg           v1_rfb05_we;          // UC Bus I/F Buffer6-2 Write Enable
  reg           f_bfcnt_init_r;       // Buffer Control Reset Pulse
  
  reg           f_mbpl_uc_r_s;        // MB Pulse
  reg [63:0]    f_wdt_r;              // SRAM write Data
  reg           f_wf_st_r;            // Forward Buffer Write Enable Set
  reg           f_wb_st_r;            // Backward Buffer Write Enable Set
  reg           f_wf_r;               // Forward Buffer Write Enable
  reg           f_wb_r;               // Backward Buffer Write Enable
  reg           f_read_enable_r;      // SDRAM Read Data Enable
  reg [1:0]     f_dtr_cnt_r;          // SDRAM Read Data Counter
  reg [5:0]     f_wadr_r;             // SRAM Write Address
  reg           f_wfb_d1_r;           // Forward/Backward Buffer non-Write
  reg           f_wnum_en_r_s;        // SRAM Write Field Counter Enable
  reg [2:0]     f_wnum_r;             // SRAM Write Field Counter
  reg [2:0]     f_regwnum_r;          // 3-Stage Register Write Field Counter
  reg [8:0]     f_radr_cnt0_r;        // SRAM Read Address Counter0
  reg [5:0]     f_radr_cnt1_r;        // SRAM Read Address Counter1
  reg [5:0]     f_radr_cnt2_r;        // SRAM Read Address Counter2
  reg [2:0]     f_hdad_cnt1y_r;       // Read Address(HDTV) Control Counter(Y1)
  reg [2:0]     f_hdad_cnt2y_r;       // Read Address(HDTV) Control Counter(Y2)
  reg [2:0]     f_hdad_cnt3y_r;       // Read Address(HDTV) Control Counter(Y3)
  reg [2:0]     f_hdad_cnt4y_r;       // Read Address(HDTV) Control Counter(Y4)
  reg [1:0]     f_hdad_cnt1c_r;       // Read Address(HDTV) Control Counter(C1)
  reg [1:0]     f_hdad_cnt2c_r;       // Read Address(HDTV) Control Counter(C2)
  reg [1:0]     f_hdad_cnt3c_r;       // Read Address(HDTV) Control Counter(C3)
  reg [1:0]     f_hdad_cnt4c_r;       // Read Address(HDTV) Control Counter(C4)
  reg [5:0]     f_radrf_hdtv_r;       // SRAM Read Address(HDTV/Forward)
  reg [5:0]     f_radrb_hdtv_r;       // SRAM Read Address(HDTV/Backward)
  reg [5:0]     f_radr_sdtv_r;        // SRAM Read Address(SDTV)
  reg [5:0]     f_radrf_r;            // SRAM Read Address(Forward)
  reg [5:0]     f_radrb_r;            // SRAM Read Address(Backward)
  reg [4:0]     f_dtcnt_r;            // SRAM Read Data Conter
  reg           f_dto_enby_r;         // Data Output Enable(Y)
  reg           f_dto_enbc_r;         // Data Output Enable(Y)
  reg [3:0]     f_pref1yen_r;         // Pre-Reference Enabel1(Y)
  reg [3:0]     f_pref1cen_r;         // Pre-Reference Enabel1(C)
  reg [3:0]     f_pref2yen_r;         // Pre-Reference Enabel2(Y)
  reg [3:0]     f_pref2cen_r;         // Pre-Reference Enabel2(C)
  reg [1:0]     f_rdf0_r;             // SRAM1 Read Enable
  reg [1:0]     f_rdf1_r;             // SRAM3 Read Enable
  reg [1:0]     f_rdf2_r;             // SRAM5 Read Enable
  reg [1:0]     f_rdb0_r;             // SRAM2 Read Enable
  reg [1:0]     f_rdb1_r;             // SRAM4 Read Enable
  reg [1:0]     f_rdb2_r;             // SRAM6 Read Enable
  reg           f_pmbpl_uc_r_s;       // c_mbpl_uc_r_s 1CLK Delay
  reg           f_rnum_en_r_s;        // Read SRAM Field Counter Enable
  reg [2:0]     f_rnum_r;             // Read SRAM Field Counter
  reg [1:0]     f_rwcnt_r;            // SRAM Read Write Counter
  reg [4:0]     f_srdt_sel_r;         // SRAM Read Data Select
  reg [63:0]    f_rfa00dt_r;          // SRAM1-1 Read Data
  reg [15:0]    f_rfb00dt_r;          // SRAM1-2 Read Data
  reg [63:0]    f_rfa01dt_r;          // SRAM2-1 Read Data
  reg [15:0]    f_rfb01dt_r;          // SRAM2-2 Read Data
  reg [63:0]    f_rfa02dt_r;          // SRAM3-1 Read Data
  reg [15:0]    f_rfb02dt_r;          // SRAM3-2 Read Data
  reg [63:0]    f_rfa03dt_r;          // SRAM4-1 Read Data
  reg [15:0]    f_rfb03dt_r;          // SRAM4-2 Read Data
  reg [63:0]    f_rfa04dt_r;          // SRAM5-1 Read Data
  reg [15:0]    f_rfb04dt_r;          // SRAM5-2 Read Data
  reg [63:0]    f_rfa05dt_r;          // SRAM6-1 Read Data
  reg [15:0]    f_rfb05dt_r;          // SRAM6-2 Read Data
  reg [2:0]     f_cpara_enb_r_s;      // Code Parameter Regisater Enable
  reg           f_hdtvh1_r;           // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  reg           f_prgseq1_r;          // MB Interlace/Progressive Select[0:Interlace 1:Progressive]
  reg           f_pred_forward1_r;    // MB Forward Estimate Valid Flag
  reg           f_pred_backward1_r;   // MB Backward Estimate Valid Flag
  reg [1:0]     f_mttyp1_r;           // MB Estimate Mode
  reg [3:0]     f_hvec1y1_r;          // Horizontal Vector1(Y)
  reg [2:0]     f_vvec1y1_r;          // Vertical Vector1(Y)
  reg [3:0]     f_hvec2y1_r;          // Horizontal Vector2(Y)
  reg [2:0]     f_vvec2y1_r;          // Vertical Vector2(Y)
  reg [3:0]     f_hvec3y1_r;          // Horizontal Vector3(Y)
  reg [2:0]     f_vvec3y1_r;          // Vertical Vector3(Y)
  reg [3:0]     f_hvec4y1_r;          // Horizontal Vector4(Y)
  reg [2:0]     f_vvec4y1_r;          // Vertical Vector4(Y)
  reg [2:0]     f_hvec1c1_r;          // Horizontal Vector1(C)
  reg [1:0]     f_vvec1c1_r;          // Vertical Vector1(C)
  reg [2:0]     f_hvec2c1_r;          // Horizontal Vector2(C)
  reg [1:0]     f_vvec2c1_r;          // Vertical Vector2(C)
  reg [2:0]     f_hvec3c1_r;          // Horizontal Vector3(C)
  reg [1:0]     f_vvec3c1_r;          // Vertical Vector3(C)
  reg [2:0]     f_hvec4c1_r;          // Horizontal Vector4(C)
  reg [1:0]     f_vvec4c1_r;          // Vertical Vector4(C)
  reg           f_hdtvh2_r;           // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  reg           f_prgseq2_r;          // MB Interlace/Progressive Select[0:Interlace 1:Progressive]
  reg           f_pred_forward2_r;    // MB Forward Estimate Valid Flag
  reg           f_pred_backward2_r;   // MB Backward Estimate Valid Flag
  reg [1:0]     f_mttyp2_r;           // MB Estimate Mode
  reg [3:0]     f_hvec1y2_r;          // Horizontal Vector1(Y)
  reg [2:0]     f_vvec1y2_r;          // Vertical Vector1(Y)
  reg [3:0]     f_hvec2y2_r;          // Horizontal Vector2(Y)
  reg [2:0]     f_vvec2y2_r;          // Vertical Vector2(Y)
  reg [3:0]     f_hvec3y2_r;          // Horizontal Vector3(Y)
  reg [2:0]     f_vvec3y2_r;          // Vertical Vector3(Y)
  reg [3:0]     f_hvec4y2_r;          // Horizontal Vector4(Y)
  reg [2:0]     f_vvec4y2_r;          // Vertical Vector4(Y)
  reg [2:0]     f_hvec1c2_r;          // Horizontal Vector1(C)
  reg [1:0]     f_vvec1c2_r;          // Vertical Vector1(C)
  reg [2:0]     f_hvec2c2_r;          // Horizontal Vector2(C)
  reg [1:0]     f_vvec2c2_r;          // Vertical Vector2(C)
  reg [2:0]     f_hvec3c2_r;          // Horizontal Vector3(C)
  reg [1:0]     f_vvec3c2_r;          // Vertical Vector3(C)
  reg [2:0]     f_hvec4c2_r;          // Horizontal Vector4(C)
  reg [1:0]     f_vvec4c2_r;          // Vertical Vector4(C)
  reg           f_hdtvh3_r;           // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  reg           f_prgseq3_r;          // MB Interlace/Progressive Select[0:Interlace 1:Progressive]
  reg           f_pred_forward3_r;    // MB Forward Estimate Valid Flag
  reg           f_pred_backward3_r;   // MB Backward Estimate Valid Flag
  reg [1:0]     f_mttyp3_r;           // MB Estimate Mode
  reg [3:0]     f_hvec1y3_r;          // Horizontal Vector1(Y)
  reg [2:0]     f_vvec1y3_r;          // Vertical Vector1(Y)
  reg [3:0]     f_hvec2y3_r;          // Horizontal Vector2(Y)
  reg [2:0]     f_vvec2y3_r;          // Vertical Vector2(Y)
  reg [3:0]     f_hvec3y3_r;          // Horizontal Vector3(Y)
  reg [2:0]     f_vvec3y3_r;          // Vertical Vector3(Y)
  reg [3:0]     f_hvec4y3_r;          // Horizontal Vector4(Y)
  reg [2:0]     f_vvec4y3_r;          // Vertical Vector4(Y)
  reg [2:0]     f_hvec1c3_r;          // Horizontal Vector1(C)
  reg [1:0]     f_vvec1c3_r;          // Vertical Vector1(C)
  reg [2:0]     f_hvec2c3_r;          // Horizontal Vector2(C)
  reg [1:0]     f_vvec2c3_r;          // Vertical Vector2(C)
  reg [2:0]     f_hvec3c3_r;          // Horizontal Vector3(C)
  reg [1:0]     f_vvec3c3_r;          // Vertical Vector3(C)
  reg [2:0]     f_hvec4c3_r;          // Horizontal Vector4(C)
  reg [1:0]     f_vvec4c3_r;          // Vertical Vector4(C)
  reg [2:0]     f_rnum_d1_r;          // f_rnum_r 1CLK Delay
  reg [2:0]     f_rnum_d2_r;          // f_rnum_r 2CLK Delay
  reg [2:0]     f_rnum_d3_r;          // f_rnum_r 3CLK Delay
  reg [2:0]     f_rnum_d4_r;          // f_rnum_r 4CLK Delay
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_wdt_r <= 64'h0;
    end
    else begin
      f_wdt_r <= vrh_read_data_r;
    end
  end
  
  assign f_wmttyp_dc = (f_wmttyp_r == 2'h3);

  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_wf_st_r <= 1'b0;
    end
    else begin
      f_wf_st_r <= ( f_wpred_forward_buc_r | f_wmttyp_dc ) & f_mbpl_buc_d1_r_s;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_wb_st_r <= 1'b0;
    end
    else begin
      f_wb_st_r <= ( f_wpred_backward_buc_r | f_wmttyp_dc ) & f_mbpl_buc_d1_r_s;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_wf_r <= 1'b0;
    end
    else if ( f_wadr_rst ) begin
      f_wf_r <= 1'b0;
    end
    else if ( f_wf_st_r ) begin
      f_wf_r <= 1'b1;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_wb_r <= 1'b0;
    end
    else if ( f_wadr_rst && !f_wf_r ) begin
      f_wb_r <= 1'b0;
    end
    else if ( f_wb_st_r ) begin
      f_wb_r <= 1'b1;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_read_enable_r <= 1'b0;
      f_bfcnt_init_r  <= 1'b0;
    end
    else begin
      f_read_enable_r <= vrh_read_enable_r;
      f_bfcnt_init_r  <= c_bfcnt_init_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_dtr_cnt_r <= 2'h0;
    end
    else if ( f_bfcnt_init_r ) begin
      f_dtr_cnt_r <= 2'h0;
    end
    else if ( f_read_enable_r ) begin
      if ( (!f_whdtvh_r && f_dtr_cnt_dc2) ||
           (f_whdtvh_r && f_dtr_cnt_dc1) ) begin
        f_dtr_cnt_r <= 2'h0;
      end
      else begin
        f_dtr_cnt_r <= f_dtr_cnt_r + 1'b1;
      end
    end
  end

  assign f_dtr_cnt_dc0 = ( f_dtr_cnt_r == 2'h0 );
  assign f_dtr_cnt_dc1 = ( f_dtr_cnt_r == 2'h1 );
  assign f_dtr_cnt_dc2 = ( f_dtr_cnt_r == 2'h2 );
  assign f_wadr_enb    = ( f_whdtvh_r ) ?
                           ( f_dtr_cnt_dc0 | f_dtr_cnt_dc1 ) :
                           ( f_dtr_cnt_dc0 | f_dtr_cnt_dc2 );
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_wadr_r <= 6'h00;
    end
    else if ( f_bfcnt_init_r ) begin
      f_wadr_r <= 6'h00;
    end
    else if ( f_wadr_rst ) begin
      f_wadr_r <= 6'h00;
    end
    else if ( f_wadr_enb & f_read_enable_r ) begin
      f_wadr_r <= f_wadr_r + 1'b1;
    end
  end

  assign f_wadr_dc37 = ( f_wadr_r == 6'h37 );
  assign f_wadr_dc2f = ( f_wadr_r == 6'h2f );
  assign f_wadr_rst  = ( f_wadr_enb & f_read_enable_r ) & 
                         (((~f_whdtvh_r) & f_wadr_dc37) |
                          (f_whdtvh_r & f_wadr_dc2f));

  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_wfb_d1_r    <= 1'b1;
      f_wnum_en_r_s <= 1'b0;
    end
    else begin
      f_wfb_d1_r <= (~f_wf_r) & (~f_wb_r);
      f_wnum_en_r_s <= (~f_wf_r) & (~f_wb_r) & (~f_wfb_d1_r);
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_wnum_r <= 3'h1;
    end
    else if ( f_bfcnt_init_r ) begin
      f_wnum_r <= 3'h1;
    end
    else if ( f_wnum_en_r_s ) begin
      f_wnum_r <= {f_wnum_r[1:0],f_wnum_r[2]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_regwnum_r <= 3'h1;
    end
    else if ( f_bfcnt_init_r ) begin
      f_regwnum_r <= 3'h1;
    end
    else if ( f_regwen_r ) begin
      f_regwnum_r <= {f_regwnum_r[1:0],f_regwnum_r[2]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_radr_cnt0_r <= 9'h1ff;
    end
    else if ( f_bfcnt_init_r || (f_rad_cnt0_rst && f_dtcnt_ld) ) begin
      f_radr_cnt0_r <= 9'h1ff;
    end
    else if ( f_mbpl_uc_r_s ) begin
      f_radr_cnt0_r <= 9'h000;
    end
    else if ( f_rad_cnt_enb0 ) begin
      f_radr_cnt0_r <= f_radr_cnt0_r + 1'b1;
    end
  end

  assign f_rad_cnt0_dc37   = (f_radr_cnt0_r == 9'h037);
  assign f_rad_cnt0_dc4b   = (f_radr_cnt0_r == 9'h04b);
  assign f_rad_cnt0_dcd0   = (f_radr_cnt0_r == 9'h0d0);
  assign f_rad_cnt0_dc100  = (f_radr_cnt0_r == 9'h100);
  assign f_rad_cnt0_gt24   = (f_radr_cnt0_r >  9'h024);
  assign f_rad_cnt0_gta0   = (f_radr_cnt0_r >  9'h0a0);
  assign f_rad_cnt0_eq40   = (f_radr_cnt0_r == 9'h040);
  assign f_rad_cnt0_eqa0   = (f_radr_cnt0_r == 9'h0a0);
  assign f_rad_cnt0_le4b   = (f_radr_cnt0_r <= 9'h04b);
  assign f_rad_cnt0_leff   = (f_radr_cnt0_r <= 9'h0ff);
  assign f_rad_cnt0_le4f   = (f_radr_cnt0_r <= 9'h04f);
  assign f_rad_cnt0_le50   = (f_radr_cnt0_r <= 9'h050);
  assign f_rad_cnt0_g50l9f = (f_radr_cnt0_r >= 9'h050) & (f_radr_cnt0_r <= 9'h09f);
  assign f_rad_cnt0_g51la0 = (f_radr_cnt0_r >= 9'h051) & (f_radr_cnt0_r <= 9'h0a0);
  assign f_rad_cnt0_ga0lb7 = (f_radr_cnt0_r >= 9'h0a0) & (f_radr_cnt0_r <= 9'h0b7);
  assign f_rad_cnt0_ga1lb8 = (f_radr_cnt0_r >= 9'h0a1) & (f_radr_cnt0_r <= 9'h0b8);
  assign f_rad_cnt0_gb8lcf = (f_radr_cnt0_r >= 9'h0b8) & (f_radr_cnt0_r <= 9'h0cf);
  assign f_rad_cnt0_gb9ld0 = (f_radr_cnt0_r >= 9'h0b9) & (f_radr_cnt0_r <= 9'h0d0);
  assign f_rad_cnt0_gd0le7 = (f_radr_cnt0_r >= 9'h0d0) & (f_radr_cnt0_r <= 9'h0e7);
  assign f_rad_cnt0_gd1le8 = (f_radr_cnt0_r >= 9'h0d1) & (f_radr_cnt0_r <= 9'h0e8);
  assign f_rad_cnt0_gee8   = (f_radr_cnt0_r >= 9'h0e8);
  assign f_rad_cnt0_gee9   = (f_radr_cnt0_r >= 9'h0e9);
  assign f_rad_cnt0_g12l23 = (f_radr_cnt0_r >= 9'h012) & (f_radr_cnt0_r <= 9'h023);
  assign f_rad_cnt0_g2el37 = (f_radr_cnt0_r >= 9'h02e) & (f_radr_cnt0_r <= 9'h037);
  assign f_rad_cnt0_ge42   = (f_radr_cnt0_r >= 9'h042);
  assign f_rad_cnt0_rst  = (f_hdtvh_r) ? f_rad_cnt0_dc100 : f_rad_cnt0_dc4b;
  assign f_rad_cnt_enb1  = (f_prgseq_r) ? f_radr_cnt0_r[1] : ( f_rad_cnt0_g12l23 |
                                                                     f_rad_cnt0_g2el37 |
                                                                     f_rad_cnt0_ge42 );
  assign f_ycsel   = (f_hdtvh_r) ? f_rad_cnt0_gta0 : f_rad_cnt0_gt24;
  assign f_srd_enb = (f_hdtvh_r) ? f_rad_cnt0_leff : f_rad_cnt0_le4b;
  assign f_hdiad11y = {3'b000,f_radr_cnt0_r[1],f_radr_cnt0_r[0],f_radr_cnt0_r[3]};
  assign f_hdiad12y = {3'b001,f_radr_cnt0_r[1],f_radr_cnt0_r[0],f_radr_cnt0_r[3]};
  assign f_hdiad21y = {3'b011,f_radr_cnt0_r[1],f_radr_cnt0_r[0],f_radr_cnt0_r[3]};
  assign f_hdiad22y = {3'b100,f_radr_cnt0_r[1],f_radr_cnt0_r[0],f_radr_cnt0_r[3]};
  assign f_hdiad11c = {4'b0100,f_radr_cnt0_r[0],f_radr_cnt0_r[2]};
  assign f_hdiad12c = {4'b0101,f_radr_cnt0_r[0],f_radr_cnt0_r[2]};
  assign f_hdiad21c = {4'b1010,f_radr_cnt0_r[0],f_radr_cnt0_r[2]};
  assign f_hdiad22c = {4'b1011,f_radr_cnt0_r[0],f_radr_cnt0_r[2]};
  assign f_hdiadyft = (f_hdad_cnt1y_eq7) ? ({6{f_rad_cnt0_le4f}}   & f_hdiad12y) :
                                               ({6{f_rad_cnt0_le4f}}   & f_hdiad11y);
  assign f_hdiadyfb = (f_hdad_cnt2y_eq7) ? ({6{f_rad_cnt0_g50l9f}} & f_hdiad22y) :
                                               ({6{f_rad_cnt0_g50l9f}} & f_hdiad21y);
  assign f_hdiadybt = (f_hdad_cnt3y_eq7) ? ({6{f_rad_cnt0_le4f}}   & f_hdiad12y) :
                                               ({6{f_rad_cnt0_le4f}}   & f_hdiad11y);
  assign f_hdiadybb = (f_hdad_cnt4y_eq7) ? ({6{f_rad_cnt0_g50l9f}} & f_hdiad22y) :
                                               ({6{f_rad_cnt0_g50l9f}} & f_hdiad21y);
  assign f_hdiadcft = (f_hdad_cnt1c_eq3) ? ({6{(f_rad_cnt0_ga0lb7 | f_rad_cnt0_gd0le7)}} & f_hdiad12c) :
                                               ({6{(f_rad_cnt0_ga0lb7 | f_rad_cnt0_gd0le7)}} & f_hdiad11c);
  assign f_hdiadcfb = (f_hdad_cnt2c_eq3) ? ({6{(f_rad_cnt0_gb8lcf | f_rad_cnt0_gee8)}}   & f_hdiad22c) :
                                               ({6{(f_rad_cnt0_gb8lcf | f_rad_cnt0_gee8)}}   & f_hdiad21c);
  assign f_hdiadcbt = (f_hdad_cnt3c_eq3) ? ({6{(f_rad_cnt0_ga0lb7 | f_rad_cnt0_gd0le7)}} & f_hdiad12c) :
                                               ({6{(f_rad_cnt0_ga0lb7 | f_rad_cnt0_gd0le7)}} & f_hdiad11c);
  assign f_hdiadcbb = (f_hdad_cnt4c_eq3) ? ({6{(f_rad_cnt0_gb8lcf | f_rad_cnt0_gee8)}}   & f_hdiad22c) :
                                               ({6{(f_rad_cnt0_gb8lcf | f_rad_cnt0_gee8)}}   & f_hdiad21c);
  assign f_hdpad11y = {1'b0,{2{f_radr_cnt0_r[0]}},1'b0,f_radr_cnt0_r[1],f_radr_cnt0_r[3]};
  assign f_hdpad12y = {1'b0,{2{f_radr_cnt0_r[0]}},1'b1,f_radr_cnt0_r[1],f_radr_cnt0_r[3]};
  assign f_hdpad21y = {f_radr_cnt0_r[0],1'b0,(~f_radr_cnt0_r[0]),1'b0,f_radr_cnt0_r[1],f_radr_cnt0_r[3]};
  assign f_hdpad22y = {f_radr_cnt0_r[0],1'b0,(~f_radr_cnt0_r[0]),1'b1,f_radr_cnt0_r[1],f_radr_cnt0_r[3]};
  assign f_hdpad11c = {f_radr_cnt0_r[0],(~f_radr_cnt0_r[0]),f_radr_cnt0_r[0],2'b00,f_radr_cnt0_r[2]};
  assign f_hdpad12c = {f_radr_cnt0_r[0],(~f_radr_cnt0_r[0]),f_radr_cnt0_r[0],2'b01,f_radr_cnt0_r[2]};
  assign f_hdpad21c = {f_radr_cnt0_r[0],(~f_radr_cnt0_r[0]),f_radr_cnt0_r[0],2'b10,f_radr_cnt0_r[2]};
  assign f_hdpad22c = {f_radr_cnt0_r[0],(~f_radr_cnt0_r[0]),f_radr_cnt0_r[0],2'b11,f_radr_cnt0_r[2]};
  assign f_hdpyft = (f_vvec1y_r[2]) ? f_hdpad12y : f_hdpad11y;
  assign f_hdpyfc = (f_vvec1y_r[2]) ? f_hdpad21y : f_hdpad12y;
  assign f_hdpyfb = (f_vvec1y_r[2]) ? f_hdpad22y : f_hdpad21y;
  assign f_hdpybt = (f_vvec3y_r[2]) ? f_hdpad12y : f_hdpad11y;
  assign f_hdpybc = (f_vvec3y_r[2]) ? f_hdpad21y : f_hdpad12y;
  assign f_hdpybb = (f_vvec3y_r[2]) ? f_hdpad22y : f_hdpad21y;
  assign f_hdpcft = (f_vvec1c_r[1]) ? f_hdpad12c : f_hdpad11c;
  assign f_hdpcfc = (f_vvec1c_r[1]) ? f_hdpad21c : f_hdpad12c;
  assign f_hdpcfb = (f_vvec1c_r[1]) ? f_hdpad22c : f_hdpad21c;
  assign f_hdpcbt = (f_vvec3c_r[1]) ? f_hdpad12c : f_hdpad11c;
  assign f_hdpcbc = (f_vvec3c_r[1]) ? f_hdpad21c : f_hdpad12c;
  assign f_hdpcbb = (f_vvec3c_r[1]) ? f_hdpad22c : f_hdpad21c;
  assign f_hdpadyft = (f_hdad_cnt1y_eq7) ? ({6{f_rad_cnt0_le4f}}   & f_hdpyfc) :
                                               ({6{f_rad_cnt0_le4f}}   & f_hdpyft);
  assign f_hdpadyfb = (f_hdad_cnt2y_eq7) ? ({6{f_rad_cnt0_g50l9f}} & f_hdpyfb) :
                                               ({6{f_rad_cnt0_g50l9f}} & f_hdpyfc);
  assign f_hdpadybt = (f_hdad_cnt3y_eq7) ? ({6{f_rad_cnt0_le4f}}   & f_hdpybc) :
                                               ({6{f_rad_cnt0_le4f}}   & f_hdpybt);
  assign f_hdpadybb = (f_hdad_cnt4y_eq7) ? ({6{f_rad_cnt0_g50l9f}} & f_hdpybb) :
                                               ({6{f_rad_cnt0_g50l9f}} & f_hdpybc);
  assign f_hdpadcft = (f_hdad_cnt1c_eq3) ? ({6{(f_rad_cnt0_ga0lb7 | f_rad_cnt0_gd0le7)}} & f_hdpcfc) :
                                               ({6{(f_rad_cnt0_ga0lb7 | f_rad_cnt0_gd0le7)}} & f_hdpcft);
  assign f_hdpadcfb = (f_hdad_cnt2c_eq3) ? ({6{(f_rad_cnt0_gb8lcf | f_rad_cnt0_gee8)}}   & f_hdpcfb) :
                                               ({6{(f_rad_cnt0_gb8lcf | f_rad_cnt0_gee8)}}   & f_hdpcfc);
  assign f_hdpadcbt = (f_hdad_cnt3c_eq3) ? ({6{(f_rad_cnt0_ga0lb7 | f_rad_cnt0_gd0le7)}} & f_hdpcbc) :
                                               ({6{(f_rad_cnt0_ga0lb7 | f_rad_cnt0_gd0le7)}} & f_hdpcbt);
  assign f_hdpadcbb = (f_hdad_cnt4c_eq3) ? ({6{(f_rad_cnt0_gb8lcf | f_rad_cnt0_gee8)}}   & f_hdpcbb) :
                                               ({6{(f_rad_cnt0_gb8lcf | f_rad_cnt0_gee8)}}   & f_hdpcbc);
  
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_radr_cnt1_r <= 6'h3f;
    end
    else if ( f_bfcnt_init_r ) begin
      f_radr_cnt1_r <= 6'h3f;
    end
    else if( f_mbpl_uc_r_s ) begin
      f_radr_cnt1_r <= 6'h00;
    end
    else if ( f_rad_cnt_enb0 && f_rad_cnt0_dc37 ) begin
      f_radr_cnt1_r <= 6'h12;
    end
    else if ( f_rad_cnt_enb0 && !f_rad_cnt_enb1 ) begin
      f_radr_cnt1_r <= f_radr_cnt1_r + 1'b1;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_radr_cnt2_r <= 6'h3f;
    end
    else if ( f_bfcnt_init_r ) begin
      f_radr_cnt2_r <= 6'h3f;
    end
    else if ( f_mbpl_uc_r_s ) begin
      f_radr_cnt2_r <= 6'h1c;
    end
    else if ( f_rad_cnt_enb0 && f_rad_cnt0_dc37 ) begin
      f_radr_cnt2_r <= 6'h2e;
    end
    else if ( f_rad_cnt_enb0 && f_rad_cnt_enb1 ) begin
      f_radr_cnt2_r <= f_radr_cnt2_r + 1'b1;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_hdad_cnt1y_r <= 3'h7;
    end
    else if ( f_mbpl_uc_r_s ) begin
      f_hdad_cnt1y_r <= {1'b0,f_hdad_1y_ldt};
    end
    else if ( !f_hdad_cnt1y_eq7 &&
              f_rad_cnt0_le50 &&
              f_dtcnt_ld ) begin
      f_hdad_cnt1y_r <= f_hdad_cnt1y_r - 1'b1;
    end
  end

  assign f_hdad_1y_ldt = (f_prgseq_r) ? (~f_vvec1y_r[1:0]) : (~f_vvec1y_r[2:1]);
  assign f_hdad_cnt1y_eq7 = (f_hdad_cnt1y_r == 3'h7);
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_hdad_cnt2y_r <= 3'h7;
    end
    else if ( f_mbpl_uc_r_s ) begin
      f_hdad_cnt2y_r <= {1'b0,f_hdad_2y_ldt};
    end
    else if ( !f_hdad_cnt2y_eq7 &&
              f_rad_cnt0_g51la0 &&
              f_dtcnt_ld ) begin
      f_hdad_cnt2y_r <= f_hdad_cnt2y_r - 1'b1;
    end
  end

  assign f_hdad_2y_ldt = (f_prgseq_r) ? (~f_vvec2y_r[1:0]) : (~f_vvec2y_r[2:1]);
  assign f_hdad_cnt2y_eq7 = (f_hdad_cnt2y_r == 3'h7);
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_hdad_cnt3y_r <= 3'h7;
    end
    else if ( f_mbpl_uc_r_s ) begin
      f_hdad_cnt3y_r <= {1'b0,f_hdad_3y_ldt};
    end
    else if ( !f_hdad_cnt3y_eq7 &&
              f_rad_cnt0_le50 &&
              f_dtcnt_ld ) begin
      f_hdad_cnt3y_r <= f_hdad_cnt3y_r - 1'b1;
    end
  end
  assign f_hdad_3y_ldt = (f_prgseq_r) ? (~f_vvec3y_r[1:0]) : (~f_vvec3y_r[2:1]);
  assign f_hdad_cnt3y_eq7 = (f_hdad_cnt3y_r == 3'h7);
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_hdad_cnt4y_r <= 3'h7;
    end
    else if ( f_mbpl_uc_r_s ) begin
      f_hdad_cnt4y_r <= {1'b0,f_hdad_4y_ldt};
    end
    else if ( !f_hdad_cnt4y_eq7 &&
              f_rad_cnt0_g51la0 &&
              f_dtcnt_ld ) begin
      f_hdad_cnt4y_r <= f_hdad_cnt4y_r - 1'b1;
    end
  end
  assign f_hdad_4y_ldt = (f_prgseq_r) ? (~f_vvec4y_r[1:0]) : (~f_vvec4y_r[2:1]);
  assign f_hdad_cnt4y_eq7 = (f_hdad_cnt4y_r == 3'h7);
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_hdad_cnt1c_r <= 2'h3;
    end
    else if ( f_mbpl_uc_r_s || (f_rad_cnt0_dcd0 && f_dtcnt_ld) ) begin
      f_hdad_cnt1c_r <= {1'b0,f_hdad_1c_ldt};
    end
    else if ( !f_hdad_cnt1c_eq3 &&
              (f_rad_cnt0_ga1lb8 || f_rad_cnt0_gd1le8) &&
              f_dtcnt_ld ) begin
      f_hdad_cnt1c_r <= f_hdad_cnt1c_r - 1'b1;
    end
  end
  assign f_hdad_1c_ldt = (f_prgseq_r) ? (~f_vvec1c_r[0]) : (~f_vvec1c_r[1]);
  assign f_hdad_cnt1c_eq3 = (f_hdad_cnt1c_r == 3'h3);
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_hdad_cnt2c_r <= 2'h3;
    end
    else if ( f_mbpl_uc_r_s || (f_rad_cnt0_dcd0 && f_dtcnt_ld) ) begin
      f_hdad_cnt2c_r <= {1'b0,f_hdad_2c_ldt};
    end
    else if ( !f_hdad_cnt2c_eq3 &&
              (f_rad_cnt0_gb9ld0 || f_rad_cnt0_gee9) &&
              f_dtcnt_ld ) begin
      f_hdad_cnt2c_r <= f_hdad_cnt2c_r - 1'b1;
    end
  end
  assign f_hdad_2c_ldt = (f_prgseq_r) ? (~f_vvec2c_r[0]) : (~f_vvec2c_r[1]);
  assign f_hdad_cnt2c_eq3 = (f_hdad_cnt2c_r == 2'h3);
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_hdad_cnt3c_r <= 2'h3;
    end
    else if ( f_mbpl_uc_r_s || (f_rad_cnt0_dcd0 && f_dtcnt_ld) ) begin
      f_hdad_cnt3c_r <= {1'b0,f_hdad_3c_ldt};
    end
    else if ( !f_hdad_cnt3c_eq3 &&
              (f_rad_cnt0_ga1lb8 || f_rad_cnt0_gd1le8) &&
              f_dtcnt_ld ) begin
      f_hdad_cnt3c_r <= f_hdad_cnt3c_r - 1'b1;
    end
  end
  assign f_hdad_3c_ldt = (f_prgseq_r) ? (~f_vvec3c_r[0]) : (~f_vvec3c_r[1]);
  assign f_hdad_cnt3c_eq3 = (f_hdad_cnt3c_r == 2'h3);
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_hdad_cnt4c_r <= 2'h3;
    end
    else if ( f_mbpl_uc_r_s || (f_rad_cnt0_dcd0 && f_dtcnt_ld) ) begin
      f_hdad_cnt4c_r <= {1'b0,f_hdad_4c_ldt};
    end
    else if ( !f_hdad_cnt4c_eq3 &&
              (f_rad_cnt0_gb9ld0 || f_rad_cnt0_gee9) &&
              f_dtcnt_ld ) begin
      f_hdad_cnt4c_r <= f_hdad_cnt4c_r - 1'b1;
    end
  end
  assign f_hdad_4c_ldt = (f_prgseq_r) ? (~f_vvec4c_r[0]) : (~f_vvec4c_r[1]);
  assign f_hdad_cnt4c_eq3 = (f_hdad_cnt4c_r == 2'h3);
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_radrf_hdtv_r <= 6'h00;
    end
    else if ( f_prgseq_r ) begin
      f_radrf_hdtv_r <= f_hdpadyft |
                          f_hdpadyfb |
                          f_hdpadcft |
                          f_hdpadcfb;
    end
    else begin
      f_radrf_hdtv_r <= f_hdiadyft |
                          f_hdiadyfb |
                          f_hdiadcft |
                          f_hdiadcfb;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_radrb_hdtv_r <= 6'h00;
    end
    else if ( f_prgseq_r ) begin
      f_radrb_hdtv_r <= f_hdpadybt |
                          f_hdpadybb |
                          f_hdpadcbt |
                          f_hdpadcbb;
    end
    else begin
      f_radrb_hdtv_r <= f_hdiadybt |
                          f_hdiadybb |
                          f_hdiadcbt |
                          f_hdiadcbb;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_radr_sdtv_r <= 6'h00;
    end
    else if ( f_rad_cnt_enb1 ) begin
      f_radr_sdtv_r <= f_radr_cnt2_r;
    end
    else begin
      f_radr_sdtv_r <= f_radr_cnt1_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_radrf_r <= 6'h00;
    end
    else if ( f_hdtvh_r ) begin
      f_radrf_r <= f_radrf_hdtv_r;
    end
    else begin
      f_radrf_r <= f_radr_sdtv_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_radrb_r <= 6'h00;
    end
    else if ( f_hdtvh_r ) begin
      f_radrb_r <= f_radrb_hdtv_r;
    end
    else begin
      f_radrb_r <= f_radr_sdtv_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_dtcnt_r <= 5'h1f;
    end
    else if ( f_bfcnt_init_r ) begin
      f_dtcnt_r <= 5'h1f;
    end
    else if ( f_mbpl_uc_r_s ||
              (!f_rad_cnt0_rst && f_dtcnt_ld && !(f_hdtvh_r && f_rad_cnt0_eqa0)) ||
              (f_dtcnt_eq1f && f_hdtvh_r && f_rad_cnt0_eqa0) ) begin
      f_dtcnt_r <= 5'h0;
    end
    else if ( f_dtcnt_r != 5'h1f ) begin
      f_dtcnt_r <= f_dtcnt_r + 1'b1;
    end
  end

  assign f_dtcnt_eq0  = (f_dtcnt_r == 5'h0 );
  assign f_dtcnt_eq2  = (f_dtcnt_r == 5'h2 );
  assign f_dtcnt_eq4  = (f_dtcnt_r == 5'h4 );
  assign f_dtcnt_eq8  = (f_dtcnt_r == 5'h8 );
  assign f_dtcnt_eq9  = (f_dtcnt_r == 5'h9 );
  assign f_dtcnt_eqf  = (f_dtcnt_r == 5'hf );
  assign f_dtcnt_eq11 = (f_dtcnt_r == 5'h11);
  assign f_dtcnt_eq1f = (f_dtcnt_r == 5'h1f);
  assign f_dtcnt_lt4  = (f_dtcnt_r <  5'h4 );
  assign f_dtcnt_lt8  = (f_dtcnt_r <  5'h8 );
  assign f_dtcnt_lt10 = (f_dtcnt_r <  5'h10);
  assign f_rad_cnt_enby = ( f_hdtvh_r ) ? f_dtcnt_lt10 : (f_dtcnt_eq0 | f_dtcnt_eq8);
  assign f_rad_cnt_enbc = ( f_hdtvh_r ) ? f_dtcnt_lt8  : (f_dtcnt_eq0 | f_dtcnt_eq4);
  assign f_rad_cnt_enb0 = ( f_ycsel ) ? f_rad_cnt_enbc : f_rad_cnt_enby;
  assign f_dtcnt_ldy = ( f_hdtvh_r ) ? f_dtcnt_eq11 : f_dtcnt_eq8;
  assign f_dtcnt_ldc = ( f_hdtvh_r ) ? f_dtcnt_eq9  : f_dtcnt_eq4;
  assign f_dtcnt_ld  = ( f_ycsel ) ? f_dtcnt_ldc : f_dtcnt_ldy;
  assign f_dto_enby  = ( f_hdtvh_r ) ? f_dtcnt_lt10 : ( f_dtcnt_eq0 | f_dtcnt_eq4 | f_dtcnt_eq8 );
  assign f_dto_enbc  = ( f_hdtvh_r ) ? f_dtcnt_lt8  : ( f_dtcnt_eq0 | f_dtcnt_eq2 | f_dtcnt_eq4 );
  assign f_srdt_sel  = ( f_ycsel ) ? f_dtcnt_eq4 : f_dtcnt_eq8;
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_dto_enby_r <= 1'b0;
      f_dto_enbc_r <= 1'b0;
    end
    else begin
      f_dto_enby_r <= f_dto_enby;
      f_dto_enbc_r <= f_dto_enbc;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_pref1yen_r <= 4'h0;
      f_pref1cen_r <= 4'h0;
    end
    else begin
      f_pref1yen_r[3:1] <= f_pref1yen_r[2:0];
      f_pref1yen_r[0]   <= ( (f_mttyp_r == 2'h3) |
                               f_pred_forward_buc_r) & (~f_ycsel) & f_dto_enby_r;
      f_pref1cen_r[3:1] <= f_pref1cen_r[2:0];
      f_pref1cen_r[0]   <= ( (f_mttyp_r == 2'h3) |
                               f_pred_forward_buc_r) & f_ycsel & f_dto_enbc_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_pref2yen_r <= 4'h0;
      f_pref2cen_r <= 4'h0;
    end
    else begin
      f_pref2yen_r[3:1] <= f_pref2yen_r[2:0];
      f_pref2yen_r[0]   <= ( (f_mttyp_r == 2'h3) |
                               f_pred_backward_buc_r) & (~f_ycsel) & f_dto_enby_r;
      f_pref2cen_r[3:1] <= f_pref2cen_r[2:0];
      f_pref2cen_r[0]   <= ( (f_mttyp_r == 2'h3) |
                               f_pred_backward_buc_r) & f_ycsel & f_dto_enbc_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_ref1yen_r <= 1'b0;
      f_ref1cen_r <= 1'b0;
      f_ref2yen_r <= 1'b0;
      f_ref2cen_r <= 1'b0;
    end
    else begin
      f_ref1yen_r <= f_pref1yen_r[3];
      f_ref1cen_r <= f_pref1cen_r[3];
      f_ref2yen_r <= f_pref2yen_r[3];
      f_ref2cen_r <= f_pref2cen_r[3];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_rdf0_r <= 2'h0;
      f_rdf1_r <= 2'h0;
      f_rdf2_r <= 2'h0;
    end
    else begin
      f_rdf0_r[1] <= f_rdf0_r[0];
      f_rdf0_r[0] <= f_rnum_r[0] &
                       ((f_mttyp_r == 2'h3) | f_pred_forward_buc_r) &
                       f_srd_enb;
      f_rdf1_r[1] <= f_rdf1_r[0];
      f_rdf1_r[0] <= f_rnum_r[1] &
                       ((f_mttyp_r == 2'h3) | f_pred_forward_buc_r) &
                       f_srd_enb;
      f_rdf2_r[1] <= f_rdf2_r[0];
      f_rdf2_r[0] <= f_rnum_r[2] &
                       ((f_mttyp_r == 2'h3) | f_pred_forward_buc_r) &
                       f_srd_enb;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_rdb0_r <= 2'h0;
      f_rdb1_r <= 2'h0;
      f_rdb2_r <= 2'h0;
    end
    else begin
      f_rdb0_r[1] <= f_rdb0_r[0];
      f_rdb0_r[0] <= f_rnum_r[0] &
                       ((f_mttyp_r == 2'h3) | f_pred_backward_buc_r) &
                       f_srd_enb;
      f_rdb1_r[1] <= f_rdb1_r[0];
      f_rdb1_r[0] <= f_rnum_r[1] &
                       ((f_mttyp_r == 2'h3) | f_pred_backward_buc_r) &
                       f_srd_enb;
      f_rdb2_r[1] <= f_rdb2_r[0];
      f_rdb2_r[0] <= f_rnum_r[2] &
                       ((f_mttyp_r == 2'h3) | f_pred_backward_buc_r) &
                       f_srd_enb;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_pmbpl_uc_r_s <= 1'b0;
      f_rnum_en_r_s  <= 1'b0;
      f_mbpl_uc_r_s  <= 1'b0;
    end
    else begin
      f_pmbpl_uc_r_s <= c_mbpl_uc_r_s;
      f_rnum_en_r_s  <= f_rad_cnt0_rst & f_dtcnt_ld;
      f_mbpl_uc_r_s  <= f_mbpl_uc_s;
    end
  end

  assign f_mbpl_uc_s = f_pmbpl_uc_r_s & (~f_rwcnt_dc0);
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_rnum_r <= 3'h1;
    end
    else if ( f_bfcnt_init_r ) begin
      f_rnum_r <= 3'h1;
    end
    else if ( f_rnum_en_r_s ) begin
      f_rnum_r <= {f_rnum_r[1:0],f_rnum_r[2]};
    end            
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_rnum_d1_r <= 3'h1;
      f_rnum_d2_r <= 3'h1;
      f_rnum_d3_r <= 3'h1;
      f_rnum_d4_r <= 3'h1;
    end
    else begin
      f_rnum_d1_r <= f_rnum_r;
      f_rnum_d2_r <= f_rnum_d1_r;
      f_rnum_d3_r <= f_rnum_d2_r;
      f_rnum_d4_r <= f_rnum_d3_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_rwcnt_r <= 2'h0;
    end
    else if ( f_bfcnt_init_r ) begin
      f_rwcnt_r <= 2'h0;
    end
    else if ( f_rnum_en_r_s && (!f_wnum_en_r_s) ) begin
      f_rwcnt_r <= f_rwcnt_r - 1'b1;
    end
    else if ( (!f_rnum_en_r_s) && f_wnum_en_r_s ) begin
      f_rwcnt_r <= f_rwcnt_r + 1'b1;
    end
  end
  assign f_rwcnt_dc0 = ( f_rwcnt_r == 2'h0 );
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_bfud_err_r <= 1'b0;
    end
    else begin
      f_bfud_err_r <= f_rwcnt_dc0 &
                        f_pmbpl_uc_r_s &
                        (f_w2pred_forward_r | f_w2pred_backward_r);
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_srdt_sel_r <= 5'h00;
    end
    else begin
      f_srdt_sel_r[4:1] <= f_srdt_sel_r[3:0];
      f_srdt_sel_r[0]   <= (~f_hdtvh_r) & f_srdt_sel;
    end
  end
  
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_rfa00dt_r <= 64'h0;
      f_rfb00dt_r <= 16'h0;
      f_rfa01dt_r <= 64'h0;
      f_rfb01dt_r <= 16'h0;
      f_rfa02dt_r <= 64'h0;
      f_rfb02dt_r <= 16'h0;
      f_rfa03dt_r <= 64'h0;
      f_rfb03dt_r <= 16'h0;
      f_rfa04dt_r <= 64'h0;
      f_rfb04dt_r <= 16'h0;
      f_rfa05dt_r <= 64'h0;
      f_rfb05dt_r <= 16'h0;
    end
    else begin
      f_rfa00dt_r <= w1_rfa00_q;
      f_rfb00dt_r <= w1_rfb00_q;
      f_rfa01dt_r <= w1_rfa01_q;
      f_rfb01dt_r <= w1_rfb01_q;
      f_rfa02dt_r <= w1_rfa02_q;
      f_rfb02dt_r <= w1_rfb02_q;
      f_rfa03dt_r <= w1_rfa03_q;
      f_rfb03dt_r <= w1_rfb03_q;
      f_rfa04dt_r <= w1_rfa04_q;
      f_rfb04dt_r <= w1_rfb04_q;
      f_rfa05dt_r <= w1_rfa05_q;
      f_rfb05dt_r <= w1_rfb05_q;
    end
  end
  assign f_rf00dt = ( f_srdt_sel_r[4] ) ? {f_rfb00dt_r,48'h0} : f_rfa00dt_r;
  assign f_rf01dt = ( f_srdt_sel_r[4] ) ? {f_rfb01dt_r,48'h0} : f_rfa01dt_r;
  assign f_rf02dt = ( f_srdt_sel_r[4] ) ? {f_rfb02dt_r,48'h0} : f_rfa02dt_r;
  assign f_rf03dt = ( f_srdt_sel_r[4] ) ? {f_rfb03dt_r,48'h0} : f_rfa03dt_r;
  assign f_rf04dt = ( f_srdt_sel_r[4] ) ? {f_rfb04dt_r,48'h0} : f_rfa04dt_r;
  assign f_rf05dt = ( f_srdt_sel_r[4] ) ? {f_rfb05dt_r,48'h0} : f_rfa05dt_r;
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_ref1dt_r <= 64'h0;
      f_ref2dt_r <= 64'h0;
    end
    else begin
      case ( f_rnum_d4_r )
        3'b001 : begin
          f_ref1dt_r <= f_rf00dt & {64{f_ref1_enb}};
          f_ref2dt_r <= f_rf01dt & {64{f_ref2_enb}};
        end
        3'b010 : begin
          f_ref1dt_r <= f_rf02dt & {64{f_ref1_enb}};
          f_ref2dt_r <= f_rf03dt & {64{f_ref2_enb}};
        end
        3'b100 : begin
          f_ref1dt_r <= f_rf04dt & {64{f_ref1_enb}};
          f_ref2dt_r <= f_rf05dt & {64{f_ref2_enb}};
        end
        default : begin
          f_ref1dt_r <= 64'h0;
          f_ref2dt_r <= 64'h0;
        end
      endcase
    end
  end

  assign f_ref1_enb = f_pref1yen_r[3] | f_pref1cen_r[3];
  assign f_ref2_enb = f_pref2yen_r[3] | f_pref2cen_r[3];
  assign f_sr1_enb = f_wnum_r[0] & f_wf_r;
  assign f_sr2_enb = f_wnum_r[0] & (~f_wf_r) & f_wb_r;
  assign f_sr3_enb = f_wnum_r[1] & f_wf_r;
  assign f_sr4_enb = f_wnum_r[1] & (~f_wf_r) & f_wb_r;
  assign f_sr5_enb = f_wnum_r[2] & f_wf_r;
  assign f_sr6_enb = f_wnum_r[2] & (~f_wf_r) & f_wb_r;
  assign f_sra1_wr_enb = f_read_enable_r & ( f_dtr_cnt_dc0 | f_dtr_cnt_dc1 ) & f_sr1_enb;
  assign f_srb1_wr_enb = f_read_enable_r & f_dtr_cnt_dc2 & f_sr1_enb;
  assign f_sra2_wr_enb = f_read_enable_r & ( f_dtr_cnt_dc0 | f_dtr_cnt_dc1 ) & f_sr2_enb;
  assign f_srb2_wr_enb = f_read_enable_r & f_dtr_cnt_dc2 & f_sr2_enb;
  assign f_sra3_wr_enb = f_read_enable_r & ( f_dtr_cnt_dc0 | f_dtr_cnt_dc1 ) & f_sr3_enb;
  assign f_srb3_wr_enb = f_read_enable_r & f_dtr_cnt_dc2 & f_sr3_enb;
  assign f_sra4_wr_enb = f_read_enable_r & ( f_dtr_cnt_dc0 | f_dtr_cnt_dc1 ) & f_sr4_enb;
  assign f_srb4_wr_enb = f_read_enable_r & f_dtr_cnt_dc2 & f_sr4_enb;
  assign f_sra5_wr_enb = f_read_enable_r & ( f_dtr_cnt_dc0 | f_dtr_cnt_dc1 ) & f_sr5_enb;
  assign f_srb5_wr_enb = f_read_enable_r & f_dtr_cnt_dc2 & f_sr5_enb;
  assign f_sra6_wr_enb = f_read_enable_r & ( f_dtr_cnt_dc0 | f_dtr_cnt_dc1 ) & f_sr6_enb;
  assign f_srb6_wr_enb = f_read_enable_r & f_dtr_cnt_dc2 & f_sr6_enb;

  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      v1_rfa00_d <= 64'h0;
      v1_rfb00_d <= 16'h0;
      v1_rfa01_d <= 64'h0;
      v1_rfb01_d <= 16'h0;
      v1_rfa02_d <= 64'h0;
      v1_rfb02_d <= 16'h0;
      v1_rfa03_d <= 64'h0;
      v1_rfb03_d <= 16'h0;
      v1_rfa04_d <= 64'h0;
      v1_rfb04_d <= 16'h0;
      v1_rfa05_d <= 64'h0;
      v1_rfb05_d <= 16'h0;
    end
    else begin
      v1_rfa00_d <= f_wdt_r        & {64{f_sr1_enb}};
      v1_rfb00_d <= f_wdt_r[63:48] & {16{f_sr1_enb}};
      v1_rfa01_d <= f_wdt_r        & {64{f_sr2_enb}};
      v1_rfb01_d <= f_wdt_r[63:48] & {16{f_sr2_enb}};
      v1_rfa02_d <= f_wdt_r        & {64{f_sr3_enb}};
      v1_rfb02_d <= f_wdt_r[63:48] & {16{f_sr3_enb}};
      v1_rfa03_d <= f_wdt_r        & {64{f_sr4_enb}};
      v1_rfb03_d <= f_wdt_r[63:48] & {16{f_sr4_enb}};
      v1_rfa04_d <= f_wdt_r        & {64{f_sr5_enb}};
      v1_rfb04_d <= f_wdt_r[63:48] & {16{f_sr5_enb}};
      v1_rfa05_d <= f_wdt_r        & {64{f_sr6_enb}};
      v1_rfb05_d <= f_wdt_r[63:48] & {16{f_sr6_enb}};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      v1_rfa00_a <= 6'h00;
    end
    else if ( f_sra1_wr_enb ) begin
      v1_rfa00_a <= f_wadr_r & {6{f_sr1_enb}};
    end
    else begin
      v1_rfa00_a <= f_radrf_r & {6{f_rdf0_r[1]}};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      v1_rfb00_a <= 5'h0;
    end
    else if ( f_srb1_wr_enb ) begin
      v1_rfb00_a <= f_wadr_r[5:1] & {5{f_sr1_enb}};
    end
    else begin
      v1_rfb00_a <= f_radrf_r[5:1] & {5{f_rdf0_r[1]}};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      v1_rfa01_a <= 6'h00;
    end
    else if ( f_sra2_wr_enb ) begin
      v1_rfa01_a <= f_wadr_r & {6{f_sr2_enb}};
    end
    else begin
      v1_rfa01_a <= f_radrb_r & {6{f_rdb0_r[1]}};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      v1_rfb01_a <= 5'h00;
    end
    else if ( f_srb2_wr_enb ) begin
      v1_rfb01_a <= f_wadr_r[5:1] & {5{f_sr2_enb}};
    end
    else begin
      v1_rfb01_a <= f_radrb_r[5:1] & {5{f_rdb0_r[1]}};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      v1_rfa02_a <= 6'h00;
    end
    else if ( f_sra3_wr_enb ) begin
      v1_rfa02_a <= f_wadr_r & {6{f_sr3_enb}};
    end
    else begin
      v1_rfa02_a <= f_radrf_r & {6{f_rdf1_r[1]}};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      v1_rfb02_a <= 5'h00;
    end
    else if ( f_srb3_wr_enb ) begin
      v1_rfb02_a <= f_wadr_r[5:1] & {5{f_sr3_enb}};
    end
    else begin
      v1_rfb02_a <= f_radrf_r[5:1] & {5{f_rdf1_r[1]}};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      v1_rfa03_a <= 6'h00;
    end
    else if ( f_sra4_wr_enb ) begin
      v1_rfa03_a <= f_wadr_r & {6{f_sr4_enb}};
    end
    else begin
      v1_rfa03_a <= f_radrb_r & {6{f_rdb1_r[1]}};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      v1_rfb03_a <= 5'h00;
    end
    else if ( f_srb4_wr_enb ) begin
      v1_rfb03_a <= f_wadr_r[5:1] & {5{f_sr4_enb}};
    end
    else begin
      v1_rfb03_a <= f_radrb_r[5:1] & {5{f_rdb1_r[1]}};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      v1_rfa04_a <= 6'h00;
    end
    else if ( f_sra5_wr_enb ) begin
      v1_rfa04_a <= f_wadr_r & {6{f_sr5_enb}};
    end
    else begin
      v1_rfa04_a <= f_radrf_r & {6{f_rdf2_r[1]}};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      v1_rfb04_a <= 5'h00;
    end
    else if ( f_srb5_wr_enb ) begin
      v1_rfb04_a <= f_wadr_r[5:1] & {5{f_sr5_enb}};
    end
    else begin
      v1_rfb04_a <= f_radrf_r[5:1] & {5{f_rdf2_r[1]}};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      v1_rfa05_a <= 6'h00;
    end
    else if ( f_sra6_wr_enb ) begin
      v1_rfa05_a <= f_wadr_r & {6{f_sr6_enb}};
    end
    else begin
      v1_rfa05_a <= f_radrb_r & {6{f_rdb2_r[1]}};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      v1_rfb05_a <= 5'h00;
    end
    else if ( f_srb6_wr_enb ) begin
      v1_rfb05_a <= f_wadr_r[5:1] & {5{f_sr6_enb}};
    end
    else begin
      v1_rfb05_a <= f_radrb_r[5:1] & {5{f_rdb2_r[1]}};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      v1_rfa00_we <= 1'b0;
      v1_rfa00_bs <= 1'b0;
      v1_rfb00_we <= 1'b0;
      v1_rfb00_bs <= 1'b0;
      v1_rfa01_we <= 1'b0;
      v1_rfa01_bs <= 1'b0;
      v1_rfb01_we <= 1'b0;
      v1_rfb01_bs <= 1'b0;
      v1_rfa02_we <= 1'b0;
      v1_rfa02_bs <= 1'b0;
      v1_rfb02_we <= 1'b0;
      v1_rfb02_bs <= 1'b0;
      v1_rfa03_we <= 1'b0;
      v1_rfa03_bs <= 1'b0;
      v1_rfb03_we <= 1'b0;
      v1_rfb03_bs <= 1'b0;
      v1_rfa04_we <= 1'b0;
      v1_rfa04_bs <= 1'b0;
      v1_rfb04_we <= 1'b0;
      v1_rfb04_bs <= 1'b0;
      v1_rfa05_we <= 1'b0;
      v1_rfa05_bs <= 1'b0;
      v1_rfb05_we <= 1'b0;
      v1_rfb05_bs <= 1'b0;
    end
    else begin
      v1_rfa00_we <= f_sra1_wr_enb;
      v1_rfa00_bs <= f_sra1_wr_enb | f_rdf0_r[1];
      v1_rfb00_we <= f_srb1_wr_enb;
      v1_rfb00_bs <= f_srb1_wr_enb | f_rdf0_r[1];
      v1_rfa01_we <= f_sra2_wr_enb;
      v1_rfa01_bs <= f_sra2_wr_enb | f_rdb0_r[1];
      v1_rfb01_we <= f_srb2_wr_enb;
      v1_rfb01_bs <= f_srb2_wr_enb | f_rdb0_r[1];
      v1_rfa02_we <= f_sra3_wr_enb;
      v1_rfa02_bs <= f_sra3_wr_enb | f_rdf1_r[1];
      v1_rfb02_we <= f_srb3_wr_enb;
      v1_rfb02_bs <= f_srb3_wr_enb | f_rdf1_r[1];
      v1_rfa03_we <= f_sra4_wr_enb;
      v1_rfa03_bs <= f_sra4_wr_enb | f_rdb1_r[1];
      v1_rfb03_we <= f_srb4_wr_enb;
      v1_rfb03_bs <= f_srb4_wr_enb | f_rdb1_r[1];
      v1_rfa04_we <= f_sra5_wr_enb;
      v1_rfa04_bs <= f_sra5_wr_enb | f_rdf2_r[1];
      v1_rfb04_we <= f_srb5_wr_enb;
      v1_rfb04_bs <= f_srb5_wr_enb | f_rdf2_r[1];
      v1_rfa05_we <= f_sra6_wr_enb;
      v1_rfa05_bs <= f_sra6_wr_enb | f_rdb2_r[1];
      v1_rfb05_we <= f_srb6_wr_enb;
      v1_rfb05_bs <= f_srb6_wr_enb | f_rdb2_r[1];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_cpara_enb_r_s <= 3'h0;
    end
    else begin
      f_cpara_enb_r_s <= {3{f_regwen_r}} & f_regwnum_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_hdtvh1_r         <= 1'b0;
      f_prgseq1_r        <= 1'b0;
      f_pred_forward1_r  <= 1'b0;
      f_pred_backward1_r <= 1'b0;
      f_mttyp1_r         <= 2'h0;
      f_hvec1y1_r        <= 4'h0;
      f_vvec1y1_r        <= 3'h0;
      f_hvec2y1_r        <= 4'h0;
      f_vvec2y1_r        <= 3'h0;
      f_hvec3y1_r        <= 4'h0;
      f_vvec3y1_r        <= 3'h0;
      f_hvec4y1_r        <= 4'h0;
      f_vvec4y1_r        <= 3'h0;
      f_hvec1c1_r        <= 3'h0;
      f_vvec1c1_r        <= 2'h0;
      f_hvec2c1_r        <= 3'h0;
      f_vvec2c1_r        <= 2'h0;
      f_hvec3c1_r        <= 3'h0;
      f_vvec3c1_r        <= 2'h0;
      f_hvec4c1_r        <= 3'h0;
      f_vvec4c1_r        <= 2'h0;
    end
    else if ( f_cpara_enb_r_s[0] ) begin
      f_hdtvh1_r         <= f_whdtvh_r;
      f_prgseq1_r        <= f_wprgseq_r;
      f_pred_forward1_r  <= f_wpred_forward_buc_r;
      f_pred_backward1_r <= f_wpred_backward_buc_r;
      f_mttyp1_r         <= f_wmttyp_r;
      f_hvec1y1_r        <= f_whvec1y_r;
      f_vvec1y1_r        <= f_wvvec1y_r;
      f_hvec2y1_r        <= f_whvec2y_r;
      f_vvec2y1_r        <= f_wvvec2y_r;
      f_hvec3y1_r        <= f_whvec3y_r;
      f_vvec3y1_r        <= f_wvvec3y_r;
      f_hvec4y1_r        <= f_whvec4y_r;
      f_vvec4y1_r        <= f_wvvec4y_r;
      f_hvec1c1_r        <= f_whvec1c_r;
      f_vvec1c1_r        <= f_wvvec1c_r;
      f_hvec2c1_r        <= f_whvec2c_r;
      f_vvec2c1_r        <= f_wvvec2c_r;
      f_hvec3c1_r        <= f_whvec3c_r;
      f_vvec3c1_r        <= f_wvvec3c_r;
      f_hvec4c1_r        <= f_whvec4c_r;
      f_vvec4c1_r        <= f_wvvec4c_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_hdtvh2_r         <= 1'b0;
      f_prgseq2_r        <= 1'b0;
      f_pred_forward2_r  <= 1'b0;
      f_pred_backward2_r <= 1'b0;
      f_mttyp2_r         <= 2'h0;
      f_hvec1y2_r        <= 4'h0;
      f_vvec1y2_r        <= 3'h0;
      f_hvec2y2_r        <= 4'h0;
      f_vvec2y2_r        <= 3'h0;
      f_hvec3y2_r        <= 4'h0;
      f_vvec3y2_r        <= 3'h0;
      f_hvec4y2_r        <= 4'h0;
      f_vvec4y2_r        <= 3'h0;
      f_hvec1c2_r        <= 3'h0;
      f_vvec1c2_r        <= 2'h0;
      f_hvec2c2_r        <= 3'h0;
      f_vvec2c2_r        <= 2'h0;
      f_hvec3c2_r        <= 3'h0;
      f_vvec3c2_r        <= 2'h0;
      f_hvec4c2_r        <= 3'h0;
      f_vvec4c2_r        <= 2'h0;
    end
    else if ( f_cpara_enb_r_s[1] ) begin
      f_hdtvh2_r         <= f_whdtvh_r;
      f_prgseq2_r        <= f_wprgseq_r;
      f_pred_forward2_r  <= f_wpred_forward_buc_r;
      f_pred_backward2_r <= f_wpred_backward_buc_r;
      f_mttyp2_r         <= f_wmttyp_r;
      f_hvec1y2_r        <= f_whvec1y_r;
      f_vvec1y2_r        <= f_wvvec1y_r;
      f_hvec2y2_r        <= f_whvec2y_r;
      f_vvec2y2_r        <= f_wvvec2y_r;
      f_hvec3y2_r        <= f_whvec3y_r;
      f_vvec3y2_r        <= f_wvvec3y_r;
      f_hvec4y2_r        <= f_whvec4y_r;
      f_vvec4y2_r        <= f_wvvec4y_r;
      f_hvec1c2_r        <= f_whvec1c_r;
      f_vvec1c2_r        <= f_wvvec1c_r;
      f_hvec2c2_r        <= f_whvec2c_r;
      f_vvec2c2_r        <= f_wvvec2c_r;
      f_hvec3c2_r        <= f_whvec3c_r;
      f_vvec3c2_r        <= f_wvvec3c_r;
      f_hvec4c2_r        <= f_whvec4c_r;
      f_vvec4c2_r        <= f_wvvec4c_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_hdtvh3_r         <= 1'b0;
      f_prgseq3_r        <= 1'b0;
      f_pred_forward3_r  <= 1'b0;
      f_pred_backward3_r <= 1'b0;
      f_mttyp3_r         <= 2'h0;
      f_hvec1y3_r        <= 4'h0;
      f_vvec1y3_r        <= 3'h0;
      f_hvec2y3_r        <= 4'h0;
      f_vvec2y3_r        <= 3'h0;
      f_hvec3y3_r        <= 4'h0;
      f_vvec3y3_r        <= 3'h0;
      f_hvec4y3_r        <= 4'h0;
      f_vvec4y3_r        <= 3'h0;
      f_hvec1c3_r        <= 3'h0;
      f_vvec1c3_r        <= 2'h0;
      f_hvec2c3_r        <= 3'h0;
      f_vvec2c3_r        <= 2'h0;
      f_hvec3c3_r        <= 3'h0;
      f_vvec3c3_r        <= 2'h0;
      f_hvec4c3_r        <= 3'h0;
      f_vvec4c3_r        <= 2'h0;
    end
    else if ( f_cpara_enb_r_s[2] ) begin
      f_hdtvh3_r         <= f_whdtvh_r;
      f_prgseq3_r        <= f_wprgseq_r;
      f_pred_forward3_r  <= f_wpred_forward_buc_r;
      f_pred_backward3_r <= f_wpred_backward_buc_r;
      f_mttyp3_r         <= f_wmttyp_r;
      f_hvec1y3_r        <= f_whvec1y_r;
      f_vvec1y3_r        <= f_wvvec1y_r;
      f_hvec2y3_r        <= f_whvec2y_r;
      f_vvec2y3_r        <= f_wvvec2y_r;
      f_hvec3y3_r        <= f_whvec3y_r;
      f_vvec3y3_r        <= f_wvvec3y_r;
      f_hvec4y3_r        <= f_whvec4y_r;
      f_vvec4y3_r        <= f_wvvec4y_r;
      f_hvec1c3_r        <= f_whvec1c_r;
      f_vvec1c3_r        <= f_wvvec1c_r;
      f_hvec2c3_r        <= f_whvec2c_r;
      f_vvec2c3_r        <= f_wvvec2c_r;
      f_hvec3c3_r        <= f_whvec3c_r;
      f_vvec3c3_r        <= f_wvvec3c_r;
      f_hvec4c3_r        <= f_whvec4c_r;
      f_vvec4c3_r        <= f_wvvec4c_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_hdtvh_r             <= 1'b0;
      f_prgseq_r            <= 1'b0;
      f_pred_forward_buc_r  <= 1'b0;
      f_pred_backward_buc_r <= 1'b0;
      f_mttyp_r             <= 2'h0;
      f_hvec1y_r            <= 4'h0;
      f_vvec1y_r            <= 3'h0;
      f_hvec2y_r            <= 4'h0;
      f_vvec2y_r            <= 3'h0;
      f_hvec3y_r            <= 4'h0;
      f_vvec3y_r            <= 3'h0;
      f_hvec4y_r            <= 4'h0;
      f_vvec4y_r            <= 3'h0;
      f_hvec1c_r            <= 3'h0;
      f_vvec1c_r            <= 2'h0;
      f_hvec2c_r            <= 3'h0;
      f_vvec2c_r            <= 2'h0;
      f_hvec3c_r            <= 3'h0;
      f_vvec3c_r            <= 2'h0;
      f_hvec4c_r            <= 3'h0;
      f_vvec4c_r            <= 2'h0;
    end
    else if ( f_mbpl_uc_s ) begin
      case ( f_rnum_r )
        3'b001 : begin
          f_hdtvh_r             <= f_hdtvh1_r;
          f_prgseq_r            <= f_prgseq1_r;
          f_pred_forward_buc_r  <= f_pred_forward1_r;
          f_pred_backward_buc_r <= f_pred_backward1_r;
          f_mttyp_r             <= f_mttyp1_r;
          f_hvec1y_r            <= f_hvec1y1_r;
          f_vvec1y_r            <= f_vvec1y1_r;
          f_hvec2y_r            <= f_hvec2y1_r;
          f_vvec2y_r            <= f_vvec2y1_r;
          f_hvec3y_r            <= f_hvec3y1_r;
          f_vvec3y_r            <= f_vvec3y1_r;
          f_hvec4y_r            <= f_hvec4y1_r;
          f_vvec4y_r            <= f_vvec4y1_r;
          f_hvec1c_r            <= f_hvec1c1_r;
          f_vvec1c_r            <= f_vvec1c1_r;
          f_hvec2c_r            <= f_hvec2c1_r;
          f_vvec2c_r            <= f_vvec2c1_r;
          f_hvec3c_r            <= f_hvec3c1_r;
          f_vvec3c_r            <= f_vvec3c1_r;
          f_hvec4c_r            <= f_hvec4c1_r;
          f_vvec4c_r            <= f_vvec4c1_r;
        end
        3'b010 : begin
          f_hdtvh_r             <= f_hdtvh2_r;
          f_prgseq_r            <= f_prgseq2_r;
          f_pred_forward_buc_r  <= f_pred_forward2_r;
          f_pred_backward_buc_r <= f_pred_backward2_r;
          f_mttyp_r             <= f_mttyp2_r;
          f_hvec1y_r            <= f_hvec1y2_r;
          f_vvec1y_r            <= f_vvec1y2_r;
          f_hvec2y_r            <= f_hvec2y2_r;
          f_vvec2y_r            <= f_vvec2y2_r;
          f_hvec3y_r            <= f_hvec3y2_r;
          f_vvec3y_r            <= f_vvec3y2_r;
          f_hvec4y_r            <= f_hvec4y2_r;
          f_vvec4y_r            <= f_vvec4y2_r;
          f_hvec1c_r            <= f_hvec1c2_r;
          f_vvec1c_r            <= f_vvec1c2_r;
          f_hvec2c_r            <= f_hvec2c2_r;
          f_vvec2c_r            <= f_vvec2c2_r;
          f_hvec3c_r            <= f_hvec3c2_r;
          f_vvec3c_r            <= f_vvec3c2_r;
          f_hvec4c_r            <= f_hvec4c2_r;
          f_vvec4c_r            <= f_vvec4c2_r;
        end
        3'b100 : begin
          f_hdtvh_r             <= f_hdtvh3_r;
          f_prgseq_r            <= f_prgseq3_r;
          f_pred_forward_buc_r  <= f_pred_forward3_r;
          f_pred_backward_buc_r <= f_pred_backward3_r;
          f_mttyp_r             <= f_mttyp3_r;
          f_hvec1y_r            <= f_hvec1y3_r;
          f_vvec1y_r            <= f_vvec1y3_r;
          f_hvec2y_r            <= f_hvec2y3_r;
          f_vvec2y_r            <= f_vvec2y3_r;
          f_hvec3y_r            <= f_hvec3y3_r;
          f_vvec3y_r            <= f_vvec3y3_r;
          f_hvec4y_r            <= f_hvec4y3_r;
          f_vvec4y_r            <= f_vvec4y3_r;
          f_hvec1c_r            <= f_hvec1c3_r;
          f_vvec1c_r            <= f_vvec1c3_r;
          f_hvec2c_r            <= f_hvec2c3_r;
          f_vvec2c_r            <= f_vvec2c3_r;
          f_hvec3c_r            <= f_hvec3c3_r;
          f_vvec3c_r            <= f_vvec3c3_r;
          f_hvec4c_r            <= f_hvec4c3_r;
          f_vvec4c_r            <= f_vvec4c3_r;
        end
        default : begin
          f_hdtvh_r             <= 1'b0;
          f_prgseq_r            <= 1'b0;
          f_pred_forward_buc_r  <= 1'b0;
          f_pred_backward_buc_r <= 1'b0;
          f_mttyp_r             <= 2'h0;
          f_hvec1y_r            <= 4'h0;
          f_vvec1y_r            <= 3'h0;
          f_hvec2y_r            <= 4'h0;
          f_vvec2y_r            <= 3'h0;
          f_hvec3y_r            <= 4'h0;
          f_vvec3y_r            <= 3'h0;
          f_hvec4y_r            <= 4'h0;
          f_vvec4y_r            <= 3'h0;
          f_hvec1c_r            <= 3'h0;
          f_vvec1c_r            <= 2'h0;
          f_hvec2c_r            <= 3'h0;
          f_vvec2c_r            <= 2'h0;
          f_hvec3c_r            <= 3'h0;
          f_vvec3c_r            <= 2'h0;
          f_hvec4c_r            <= 3'h0;
          f_vvec4c_r            <= 2'h0;
        end
      endcase
    end
  end
  
endmodule
