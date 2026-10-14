// ----------------------------------------------
// File: regtop.v
// Module: regtop
// Function: CPU I/F
// ----------------------------------------------

module  regtop(
  clkbus,
  rstbus_x,
  mb_hpb_ms2_n,
  mb_hpb_read_n,
  mb_hpb_write_n,
  mb_hpb_a,
  mb_hpb_wd,
  mr_dmaack8_n,
  sc_dmaack8_n,
  v_paramadr_r,
  v_paramdata_r,
  v_vldstatus_r,
  v_vldmstatus_r,
  v_seqstrt_r,
  v_sqxstrt_r,
  v_sdxstrt_r,
  v_ud0strt_r,
  v_gopstrt_r,
  v_ud1strt_r,
  v_picstrt_r,
  v_pcxstrt_r,
  v_cpxstrt_r,
  v_pdxstrt_r,
  v_qmxstrt_r,
  v_ud2strt_r,
  v_atscdet_r,
  v_slicestart_r,
  v_ferror_r,
  v_nferror_r,
  v_sferror_r,
  v_slclverr_r,
  v_vscdet_ferror_r,
  v_vdoen_r,
  v_qmseli_r,
  v_qmseln_r,
  c_pcpl_r_s,
  c_pcpl_tend_r_s,
  c_idlpl_r_s,
  c_pskp_end_r_s,
  c_mb_ferr_r,
  c_mb_nferr_r,
  c_tmg_ferr_hit_r,
  c_fld_mismatch_r,
  c_mbh_adr_r,
  c_mbv_adr_r,
  n_decfld_num1_r,
  n_decfld_num2_r,
  n_reffld_num1_r,
  n_reffld_num2_r,
  n_reffld_num3_r,
  n_reffld_num4_r,
  v1_dspfld_num1,
  v1_dspfld_num2,
  b_bfov_err_r,
  f_bfud_err_r,
  f_vec_err_r,
  vwh_response_error_r_s,
  vrh_response_error_r_s,
  v1_hpb_rd,
  v1_hpb_wait_n,
  v1_int18_n,
  v1_int23_n,
  v1_dmareq8_n,

  g_vden_r,
  g_vsts_r,
  g_pskp_r,
  g_init_vld_r_s,
  g_swrst_r_n,
  g_pmod_r,
  g_pcut_r,
  g_mbc_en_r,
  g_mbc_r,
  g_fcyc_en_r,
  g_fcyc_r,
  g_hsdc_r,
  g_vsdc_r,
  g_hs60p_r,
  g_vs60p_r,
  g_pini_r,
  g_chg_slp_r,
  g_bmod_r,
  g_vldmode_r,
  g_field_start_add_r,
  g_field_offset_r,
  g_cbcr_offset_r,
  g_line_offset_r
);

`include "para.h"

input    clkbus;  
input    rstbus_x;  
input    mb_hpb_ms2_n;  
input    mb_hpb_read_n;  
input    mb_hpb_write_n;  
input  [8:2]  mb_hpb_a;  
input  [31:0]  mb_hpb_wd;  
input    mr_dmaack8_n;  
input    sc_dmaack8_n;  
input  [7:0]  v_paramadr_r;  
input  [24:0]  v_paramdata_r;  
input  [7:0]  v_vldstatus_r;  
input  [3:0]  v_vldmstatus_r;  
input    v_seqstrt_r;  
input    v_sqxstrt_r;  
input    v_sdxstrt_r;  
input    v_ud0strt_r;  
input    v_gopstrt_r;  
input    v_ud1strt_r;  
input    v_picstrt_r;  
input    v_pcxstrt_r;  
input    v_cpxstrt_r;  
input    v_pdxstrt_r;  
input    v_qmxstrt_r;  
input    v_ud2strt_r;  
input    v_atscdet_r;  
input    v_slicestart_r;  
input    v_ferror_r;  
input    v_nferror_r;  
input    v_sferror_r;  
input    v_slclverr_r;  
input    v_vscdet_ferror_r;
input    v_vdoen_r;    
input    v_qmseli_r;  
input    v_qmseln_r;  
input    c_pcpl_r_s;    
input    c_pcpl_tend_r_s;  
input    c_idlpl_r_s;    
input    c_pskp_end_r_s;    
input    c_mb_ferr_r;    
input  [2:0]  c_mb_nferr_r;    
input    c_tmg_ferr_hit_r;  
input    c_fld_mismatch_r;  
input  [6:0]  c_mbh_adr_r;    
input  [6:0]  c_mbv_adr_r;    
input  [3:0]  n_decfld_num1_r;  
input  [3:0]  n_decfld_num2_r;  
input  [3:0]  n_reffld_num1_r;  
input  [3:0]  n_reffld_num2_r;  
input  [3:0]  n_reffld_num3_r;  
input  [3:0]  n_reffld_num4_r;  
input  [3:0]  v1_dspfld_num1;    
input  [3:0]  v1_dspfld_num2;    
input    b_bfov_err_r;    
input    f_bfud_err_r;    
input    f_vec_err_r;    
input    vwh_response_error_r_s;  
input    vrh_response_error_r_s;  
output  [31:0]  v1_hpb_rd;    
output    v1_hpb_wait_n;    
output    v1_int18_n;    
output    v1_int23_n;    
output    v1_dmareq8_n;    
output    g_vden_r;    
output    g_vsts_r;    
output    g_pskp_r;    
output    g_init_vld_r_s;    
output    g_swrst_r_n;    
output    g_pmod_r;    
output  [11:0]  g_pcut_r;    
output    g_mbc_en_r;    
output  [11:0]  g_mbc_r;    
output    g_fcyc_en_r;    
output  [17:0]  g_fcyc_r;    
output  [6:0]  g_hsdc_r;    
output  [6:0]  g_vsdc_r;    
output  [6:0]  g_hs60p_r;    
output  [6:0]  g_vs60p_r;    
output    g_pini_r;    
output    g_chg_slp_r;    
output    g_bmod_r;    
output  [1:0]  g_vldmode_r;    
output  [31:10]  g_field_start_add_r;  
output  [11:0]  g_field_offset_r;  
output  [11:0]  g_cbcr_offset_r;  
output    g_line_offset_r;  

reg  [31:0]  v1_hpb_rd;    // HPB Read Data
reg    v1_hpb_wait_n;    // HPB Wait Signal
reg    v1_hdi00_bs;    // HDI SRAM Block Select
reg    v1_hdi00_we;    // HDI SRAM Write Enable
reg  [5:0]  v1_hdi00_a;    // HDI SRAM Address
reg  [31:0]  v1_hdi00_d;    // HDI SRAM Write Data
wire  [31:0]  w1_hdi00_q;    // HDI SRAM read Data
reg    g_vden_r;    // VDEC Enable
reg    g_pskp_r;    // Picture Skip
reg    g_init_vld_r_s;    // VDEC Start
reg    g_swrst_r_n;    // VDEC Initialization (S/W Reset)
reg    g_pini_r;    // PCNT Initialization (S/W Reset)
reg    g_init_breg_s;    // Initialize BREG Block (S/W Reset)
reg  [2:0]  g_init_cnt_r;    // 8 Counter for Initialization
reg  [6:0]  g_hsdc_r;    // Horizontal Size for Down Conversion
reg  [6:0]  g_vsdc_r;    // Vertical Size for Down Conversion
reg  [6:0]  g_hs60p_r;    // Horizontal Size for 60fps Decoding
reg  [6:0]  g_vs60p_r;    // Vertical Size for 60fps Decoding
reg  [11:0]  g_pcut_r;    // Picture Processing Cut Cycle
reg    g_mbc_en_r;    // MB Cycle Enbale
reg  [11:0]  g_mbc_r;    // MB Cycle Count
reg    g_fcyc_en_r;    // Field Cycle Enbale
reg  [17:0]  g_fcyc_r;    // Field Cycle Count
reg    g_amod_r;    // ATSC Mode
reg    g_mmod_r;    // MPEG2 Mode
reg    g_pmod_r;    // Picture Processing Mode
reg    g_dmod_r;    // Debug Mode
reg    g_bmod_r;    // B-Picture Mask Mode
reg    g_imod_r;    // Initialization Mode
reg    g_mpeg_r;    // MPEG Processing Mode
reg    g_vsts_r;    // VDEC Status
reg  [3:0]  g_decfld_num1_r;  // Decoding Plane (Top Field)
reg  [3:0]  g_decfld_num2_r;  // Decoding Plane (Bottom Field)
reg  [3:0]  g_reffld_num1_r;  // Reference Plane (Forward-Top Field)
reg  [3:0]  g_reffld_num2_r;  // Reference Plane (Forward-Bottom Field)
reg  [3:0]  g_reffld_num3_r;  // Reference Plane (Backward-Top Field)
reg  [3:0]  g_reffld_num4_r;  // Reference Plane (Backward-Bottom Field)
reg  [3:0]  g_dspfld_num1_r;  // Display Plane (Top Field)
reg  [3:0]  g_dspfld_num2_r;  // Display Plane (Bottom Field)
reg    g_icdc_r;    // BDC Overflow Error Control
reg    g_icuc_r;    // BUC Underflow Error Control
reg    g_icsw_r;    // SHwy Write Error Control
reg    g_icsr_r;    // SHwy Read Error Control
reg    g_icfp_r;    // Fatal Error (Picture) Control
reg    g_icfb_r;    // Fatal Error (Block) Control
reg    g_icnf_r;    // Non-Fatal Error Control
reg    g_icpi_r;    // Picture Processing End Control
reg    g_icph_r;    // Picture Header Processing End Control
reg    g_icsh_r;    // Sequence Header Detection Control
reg    g_isdc_r;    // BDC Overflow Error Status
reg    g_isuc_r;    // BUC Underflow Error Status
reg    g_issw_r;    // SHwy Write Error Status
reg    g_issr_r;    // SHwy Read Error Status
reg    g_isfp_r;    // Fatal Error (Picture) Status
reg    g_isfb_r;    // Fatal Error (Block) Status
reg    g_isnf_r;    // Non-Fatal Error Status
reg    g_ispi_r;    // Picture Processing End Status
reg    g_isph_r;    // Picture Header Processing End Status
reg    g_issh_r;    // Sequence Header Detection Status

wire  [10:0]  g_fpst_r;    // Fatal Error (Picture) Status
reg    g_fpst11_r;    // Fatal Error (Parameter Overwrite) Status
reg    g_fpst10_r;    // Fatal Error (Field Pair) Status
reg    g_fpst09_r;    // Fatal Error (Shin-Fatal) Status
reg    g_fpst08_r;    // Fatal Error (Start Code Detection) Status
reg    g_fpst07_r;    // Fatal Error (Quantiser Matrix) Status
reg    g_fpst06_r;    // Fatal Error (Picture Structure) Status
reg    g_fpst05_r;    // Fatal Error (Intra DC Precision) Status
reg    g_fpst04_r;    // Fatal Error (MPEG2 f_code) Status
reg    g_fpst03_r;    // Fatal Error (MPEG1 f_code) Status
reg    g_fpst02_r;    // Fatal Error (Picture Coding Type) Status
reg    g_fpst01_r;    // Fatal Error (Image Size) Status

wire  [10:0]  g_fbst_r;    // Fatal Error (Block) Status
reg    g_fbst11_r;    // Fatal Error (Start Code Detection) Status
reg    g_fbst10_r;    // Fatal Error (Picture Time) Status
reg    g_fbst09_r;    // Fatal Error (Block Layer) Status
reg    g_fbst08_r;    // Fatal Error (Code Block Pattern 420) Status
reg    g_fbst07_r;    // Fatal Error (Motion Vector) Status
reg    g_fbst06_r;    // Fatal Error (Quantiser Scale Code) Status
reg    g_fbst05_r;    // Fatal Error (Motion Type) Status
reg    g_fbst04_r;    // Fatal Error (MacroBlock Type) Status
reg    g_fbst03_r;    // Fatal Error (MB Position) Status
reg    g_fbst02_r;    // Fatal Error (MacroBlock Address Increment) Status
reg    g_fbst01_r;    // Fatal Error (Quantiser Scale Code) Status

wire  [24:0]  g_nfst_r;    // Non-Fatal Error Status
reg    g_nfst25_r;    // Non-Fatal Error (Motion Vector) Status
reg    g_nfst24_r;    // Non-Fatal Error (DCT Coefficient) Status
reg    g_nfst23_r;    // Non-Fatal Error (Marker Bit 5) Status
reg    g_nfst22_r;    // Non-Fatal Error (Slice Division) Status
reg    g_nfst21_r;    // Non-Fatal Error (MB Position) Status
reg    g_nfst20_r;    // Non-Fatal Error (Image Not Complete) Status
reg    g_nfst19_r;    // Non-Fatal Error (Copyright Number) Status
reg    g_nfst18_r;    // Non-Fatal Error (Copyright) Status
reg    g_nfst17_r;    // Non-Fatal Error (Marker Bit 4) Status
reg    g_nfst16_r;    // Non-Fatal Error (Picture Parameter) Status
reg    g_nfst15_r;    // Non-Fatal Error (MPEG2 f_code) Status
reg    g_nfst14_r;    // Non-Fatal Error (MPEG1 f_code) Status
reg    g_nfst13_r;    // Non-Fatal Error (Full Pel Vector) Status
reg    g_nfst12_r;    // Non-Fatal Error (Marker Bit 3) Status
reg    g_nfst11_r;    // Non-Fatal Error (Marker Bit 2) Status
reg    g_nfst10_r;    // Non-Fatal Error (Frame Rate Extention) Status
reg    g_nfst09_r;    // Non-Fatal Error (VBV Buffer Size Extension) Status
reg    g_nfst08_r;    // Non-Fatal Error (Bit Rate Extension) Status
reg    g_nfst07_r;    // Non-Fatal Error (Extension Size) Status
reg    g_nfst06_r;    // Non-Fatal Error (Chroma Format) Status
reg    g_nfst05_r;    // Non-Fatal Error (Profile And Level Indication) Status
reg    g_nfst04_r;    // Non-Fatal Error (Intra Quantiser Matrix) Status
reg    g_nfst03_r;    // Non-Fatal Error (Marker Bit 1) Status
reg    g_nfst02_r;    // Non-Fatal Error (Bit Rate Value) Status
reg    g_nfst01_r;    // Non-Fatal Error (Display Parameter) Status
reg    g_dcnt_r;    // DMA Control
reg    g_dsts_r;    // DMA Status
reg  [31:10]  g_field_start_add_r;  // Field Memory Start Address
reg  [11:0]  g_field_offset_r;  // Field Offset
reg  [11:0]  g_cbcr_offset_r;  // Color Offset
reg    g_line_offset_r;  // Line Offset
reg    g_hclr_r_s;    // Header Detection Flag Clear
reg    g_shd_r;    // Sequence Header Detection Flag
reg    g_sed_r;    // Sequence Extension Detection Flag
reg    g_sded_r;    // Sequence Display Extension Detection Flag
reg    g_ud0d_r;    // User_Data(0) Detection Flag
reg    g_ghd_r;    // GOP Header Detection Flag
reg    g_ud1d_r;    // User_Data(1) Detection Flag
reg    g_phd_r;    // Picture Header Detection Flag
reg    g_pced_r;    // Picture Coding Extension Detection Flag
reg    g_ced_r;    // Copyright Extension Detection Flag
reg    g_pded_r;    // Picture Display Extension Detection Flag
reg    g_qme_r;    // Quantiser Matrix Extension Detection Flag
reg    g_ud2d_r;    // User_Data(2) Detection Flag
reg    g_add_r;    // AT Data Detection Flag
reg  [12:0]  g_hdflag_r;    // Header Detection Flag
reg  [11:0]  g_hsv_r;    // Horizontal Size Value
reg  [11:0]  g_vsv_r;    // Vertical Size Value
reg  [3:0]  g_ari_r;    // Aspect Ratio Information
reg  [3:0]  g_frc_r;    // Frame Rate Code
reg  [17:0]  g_brv_r;    // Bit Rate Value
reg  [9:0]  g_vbsv_r;    // VBV Buffer Size Value
reg    g_cpf_r;    // Constrained Parameters Flag
reg  [7:0]  g_pali_r;    // Profile And Level Indication
reg    g_ps_r;      // Progressive Sequence
reg  [1:0]  g_cf_r;      // Chroma Format
reg    g_ld_r;      // Low Delay
reg  [2:0]  g_vf_r;      // Video Format
reg    g_cd_r;      // Color Description
reg  [7:0]  g_cp_r;      // Color Promaries
reg  [7:0]  g_tc_r;      // Transfer Characteristics
reg  [7:0]  g_mc_r;      // Matrix Coefficient
reg  [13:0]  g_dhs_r;    // Display Horizontal Size
reg  [13:0]  g_dvs_r;    // Display Vertical Size
reg  [23:0]  g_tmc_r;    // Time Code
reg    g_cg_r;      // Closed GOP
reg    g_bl_r;      // Broken Link
reg  [9:0]  g_tr_r;      // Temporal Reference
reg  [2:0]  g_pct_r;    // Picture Coding Type
reg  [15:0]  g_vd_r;      // VBV Delay
reg  [1:0]  g_pis_r;    // Picture Structure
reg    g_tff_r;    // Top Field First
reg    g_rff_r;    // Repeat First Field
reg    g_pf_r;      // Progressive Frame
reg    g_cdf_r;    // Composite Display Flag
reg    g_va_r;      // V_Axis
reg  [2:0]  g_fs_r;      // Field Sequence
reg    g_sc_r;      // Sub Carrier
reg  [6:0]  g_ba_r;      // Burst Amplitude
reg  [7:0]  g_scp_r;    // Sub Carrier Phase
reg  [1:0]  g_nfco_r;  // Number of Frame Centre Offsets
reg  [15:0]  g_fcho0_r;  // Frame Centre Horizontal Offset 0
reg  [15:0]  g_fcvo0_r;  // Frame Centre Vertical Offset 0
reg  [15:0]  g_fcho1_r;  // Frame Centre Horizontal Offset 1
reg  [15:0]  g_fcvo1_r;  // Frame Centre Vertical Offset 1
reg  [15:0]  g_fcho2_r;  // Frame Centre Horizontal Offset 2
reg  [15:0]  g_fcvo2_r;  // Frame Centre Vertical Offset 2
reg  [6:0]  g_udb0_r;  // User Data (0) Byte Count
reg    g_udb0_wen_r;  // User Data (0) Write Enable
reg  [6:0]  g_udb1_r;  // User Data (1) Byte Count
reg    g_udb1_wen_r;  // User Data (1) Write Enable
reg  [6:0]  g_udb2_r;  // User Data (2) Byte Count
reg    g_udb2_wen_r;  // User Data (2) Write Enable
wire  [6:0]  g_udb_d;  // User Dara Byte Count
reg  [6:0]  g_udb_r;  // User Data Byte Count
reg  [6:0]  g_udb_cpu_r;  // User Data Byte Count
reg  [31:0]  g_usrd_d;  // User Data
reg  [31:8]  g_usrd_r;  // User Data
reg  [6:0]  g_adb_r;  // ATSC Data Byte Count
reg  [6:0]  g_adb_cpu_r;  // ATSC Data Byte Count
reg  [31:0]  g_atscd_d;  // ATSC Data
reg  [31:8]  g_atscd_r;  // ATSC Data
reg    g_ms_r_n;  // HPB Module Select
reg    g_read_r_n;  // HPB Read Signal
reg    g_write_r_n;  // HPB Write Signal
reg  [8:2]  g_a_r;    // HPB Address
reg  [31:0]  g_wd_r;    // HPB Write Data
wire    g_mem_area;  // SRAM Area
reg    g_cpu_we_s;  // CPU Write Enable
reg    g_cpu_re_s;  // CPU Read Enable
reg    g_cpu_memr;  // SRAM Read (CPU)
reg    g_cpu_memw;  // SRAM Write (CPU)
reg    g_vld_memw;  // SRAM Write (VLD)
reg    g_rd_en_r;  // SRAM Read Data Enable
reg    g_rd_en2_r;  // SRAM Read Data Enable
reg    g_memr_ok_r;  // SRAM Read OK
reg  [31:0]  g_mem_rd_r;  // SRAM Read Data
reg  [31:0]  g_mem_rd2_r;  // SRAM Read Data
reg    g_dack32_r_n;  // DMA Acknowledge from M32R
reg    g_dacksh_r_n;  // DMA Acknowledge from SH3 Register
reg    g_chg_hsv;  // Flag If Horizontal Size Value were Changed
reg    g_chg_vsv;  // Flag If Vertical Size Value were Changed
reg    g_chg_ari;  // Flag If Aspect Ratio Information were Changed
reg    g_chg_frc;  // Flag If Frame Rate Code were Changed
reg    g_chg_ps;  // Flag If Progressive Sequence were Changed
reg    g_chg_dhs;  // Flag If Display Horizontal Size were Changed
reg    g_chg_dvs;  // Flag If Display Vertical Size were Changed
wire    g_chg_slp_d;  // Flag If Sequence Level Parameter were Changed
reg    g_chg_slp_r;  // Flag If Sequence Level Parameter were Changed
wire    v1_int18_d_n;    // Register Input
wire    v1_int23_d_n;    // Register Input
reg    v1_int18_n;    // Register Output
reg    v1_int23_n;    // Register Output
reg    v1_dmareq8_n;    // DMA Request
wire    g_pich_end;    // Picture Header Read End
reg  [7:0]  g_paramadr_r;    // Parameter Address
reg  [24:0]  g_paramdata_r;    // Parameter Data
reg  [7:0]  g_vldstatus_r;    // VLD Status
reg  [3:0]  g_vldmstatus_r;    // VLD Status (MB Layer)
reg    g_seqstrt_r;    // Sequence Header Detection
reg    g_sqxstrt_r;    // Sequence Extention Detection
reg    g_sdxstrt_r;    // Sequence Dsiplay Extention Detection
reg    g_ud0strt_r;    // User_data(0) Detection
reg    g_gopstrt_r;    // GOP Header Detection
reg    g_ud1strt_r;    // User_data(1) Detection
reg    g_picstrt_r;    // Picture Header Detection
reg    g_pcxstrt_r;    // Picture Coding Extension Detection
reg    g_cpxstrt_r;    // Copyright Extension Detection
reg    g_pdxstrt_r;    // Picture Display Extension Detection
reg    g_qmxstrt_r;    // Quantiser Matrix Extension Detection
reg    g_ud2strt_r;    // User_data(2) Detection
reg    g_atscdet_r;    // AT Data Detection
reg    g_slicestart_r;    // Slice Header Start
reg    g_ferror_r;    // Fatal Error Detection
reg    g_nferror_r;    // Non-Fatal Error Detection
reg    g_sferror_r;    // Shin-Fatal Error Detection
reg    g_slclverr_r;    // Error Layer (Below a Slice)
reg    g_vscdet_ferror_r;  // Start Code Detection Error
reg    g_vdoen_r;    // Quantiser Index Data Enable
reg    g_qmseli_r;    // Intra Quantiser Matrix
reg    g_qmseln_r;    // Non-Intra Quantiser Matrix
reg    g_bfov_err_r;    // Buffer Overflow Error (BDC)
reg    g_bfud_err_r;    // Buffer Underflow Error (BUC)
reg    g_vec_err_r;    // Motion Vector Error
reg    g_w_response_error_r;  // Error Responce from SHwy Write Port
reg    g_r_response_error_r;  // Error Responce from SHwy Read Port
reg    g_phdet_r;    // Picture Header Detection
reg    g_pcpl_r;    // Picture Start Pulse
reg    g_pcpl_tend_r;    // Picture End Pulse
reg    g_idlpl_r;    // Idle Start Pulse
reg    g_pskp_end_r;    // Picture Skip End Pulse
reg    g_mb_ferr_r;    // MB Fatal Error
reg  [2:0]  g_mb_nferr_r;    // MB Non-Fatal Error
reg    g_tmg_ferr_hit_r;  // Picture Time Over Error
reg    g_fld_mismatch_r;  // Field Pair Error Detection
reg  [6:0]  g_mbh_adr_r;    // Current MB Address X
reg  [6:0]  g_mbv_adr_r;    // Current MB Address Y
reg    g_prev_efbst_r;    // Error Status (Fatal Block) of Previous Cycle
reg    g_prev_enfst_r;    // Error Status (Non-Fatal) of Previous Cycle
reg  [6:0]  g_embh_adr_r;    // Error MB Address X
reg  [6:0]  g_embv_adr_r;    // Error MB Address Y

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0) begin
    g_ms_r_n    <= 1'b1;
    g_read_r_n    <= 1'b1;
    g_write_r_n    <= 1'b1;
    g_a_r      <= 7'h0;
    g_wd_r    <= 32'h0;
    g_dack32_r_n    <= 1'b1;
    g_dacksh_r_n    <= 1'b1;
    g_mem_rd_r    <= 32'h0;
    g_paramadr_r    <= 8'h0;
    g_paramdata_r    <= 25'h0;
    g_vldstatus_r    <= 8'h0;
    g_vldmstatus_r  <= 4'h0;
    g_seqstrt_r    <= 1'b0;
    g_sqxstrt_r    <= 1'b0;
    g_sdxstrt_r    <= 1'b0;
    g_ud0strt_r    <= 1'b0;
    g_gopstrt_r    <= 1'b0;
    g_ud1strt_r    <= 1'b0;
    g_picstrt_r    <= 1'b0;
    g_pcxstrt_r    <= 1'b0;
    g_cpxstrt_r    <= 1'b0;
    g_pdxstrt_r    <= 1'b0;
    g_qmxstrt_r    <= 1'b0;
    g_ud2strt_r    <= 1'b0;
    g_atscdet_r    <= 1'b0;
    g_slicestart_r  <= 1'b0;
    g_ferror_r    <= 1'b0;
    g_nferror_r    <= 1'b0;
    g_sferror_r    <= 1'b0;
    g_slclverr_r    <= 1'b0;
    g_vscdet_ferror_r  <= 1'b0;
    g_vdoen_r    <= 1'b0;
    g_qmseli_r    <= 1'b0;
    g_qmseln_r    <= 1'b0;
    g_decfld_num1_r  <= 4'h0;
    g_decfld_num2_r  <= 4'h0;
    g_reffld_num1_r  <= 4'h0;
    g_reffld_num2_r  <= 4'h0;
    g_reffld_num3_r  <= 4'h0;
    g_reffld_num4_r  <= 4'h0;
    g_dspfld_num1_r  <= 4'h0;
    g_dspfld_num2_r  <= 4'h0;
    g_bfov_err_r    <= 1'b0;
    g_bfud_err_r    <= 1'b0;
    g_vec_err_r    <= 1'b0;
    g_w_response_error_r  <= 1'b0;
    g_r_response_error_r  <= 1'b0;
    g_pcpl_r    <= 1'b0;
    g_pcpl_tend_r    <= 1'b0;
    g_idlpl_r    <= 1'b0;
    g_pskp_end_r    <= 1'b0;
    g_mb_ferr_r    <= 1'b0;
    g_mb_nferr_r    <= 3'h0;
    g_tmg_ferr_hit_r  <= 1'b0;
    g_fld_mismatch_r  <= 1'b0;
    g_mbh_adr_r    <= 7'h0;
    g_mbv_adr_r    <= 7'h0;
  end
  else begin
    g_ms_r_n    <= ~mb_hpb_ms2_n;
    g_read_r_n    <= mb_hpb_read_n;
    g_write_r_n    <= ~mb_hpb_write_n;
    g_a_r      <= mb_hpb_a;
    g_wd_r    <= mb_hpb_wd;
    g_dack32_r_n    <= mr_dmaack8_n;
    g_dacksh_r_n    <= sc_dmaack8_n;
    g_mem_rd_r    <= w1_hdi00_q;
    g_paramadr_r    <= v_paramadr_r;
    g_paramdata_r    <= v_paramdata_r;
    g_vldstatus_r    <= v_vldstatus_r;
    g_vldmstatus_r  <= v_vldmstatus_r;
    g_seqstrt_r    <= v_seqstrt_r;
    g_sqxstrt_r    <= v_sqxstrt_r;
    g_sdxstrt_r    <= v_sdxstrt_r;
    g_ud0strt_r    <= v_ud0strt_r;
    g_gopstrt_r    <= v_gopstrt_r;
    g_ud1strt_r    <= v_ud1strt_r;
    g_picstrt_r    <= v_picstrt_r;
    g_pcxstrt_r    <= v_pcxstrt_r;
    g_cpxstrt_r    <= v_cpxstrt_r;
    g_pdxstrt_r    <= v_pdxstrt_r;
    g_qmxstrt_r    <= v_qmxstrt_r;
    g_ud2strt_r    <= v_ud2strt_r;
    g_atscdet_r    <= v_atscdet_r;
    g_slicestart_r  <= v_slicestart_r;
    g_ferror_r    <= v_ferror_r;
    g_nferror_r    <= v_nferror_r;
    g_sferror_r    <= v_sferror_r;
    g_slclverr_r    <= v_slclverr_r;
    g_vscdet_ferror_r  <= v_vscdet_ferror_r;
    g_vdoen_r    <= v_vdoen_r;
    g_qmseli_r    <= v_qmseli_r;
    g_qmseln_r    <= v_qmseln_r;
    g_decfld_num1_r  <= n_decfld_num1_r;
    g_decfld_num2_r  <= n_decfld_num2_r;
    g_reffld_num1_r  <= n_reffld_num1_r;
    g_reffld_num2_r  <= n_reffld_num2_r;
    g_reffld_num3_r  <= n_reffld_num3_r;
    g_reffld_num4_r  <= n_reffld_num4_r;
    g_dspfld_num1_r  <= v1_dspfld_num1;
    g_dspfld_num2_r  <= v1_dspfld_num2;
    g_bfov_err_r    <= b_bfov_err_r;
    g_bfud_err_r    <= f_bfud_err_r;
    g_vec_err_r    <= f_vec_err_r;
    g_w_response_error_r  <= vwh_response_error_r_s;
    g_r_response_error_r  <= vrh_response_error_r_s;
    g_pcpl_r    <= c_pcpl_r_s;
    g_pcpl_tend_r    <= c_pcpl_tend_r_s;
    g_idlpl_r    <= c_idlpl_r_s;
    g_pskp_end_r    <= c_pskp_end_r_s;
    g_mb_ferr_r    <= c_mb_ferr_r;
    g_mb_nferr_r    <= c_mb_nferr_r;
    g_tmg_ferr_hit_r  <= c_tmg_ferr_hit_r;
    g_fld_mismatch_r  <= c_fld_mismatch_r;
    g_mbh_adr_r    <= c_mbh_adr_r;
    g_mbv_adr_r    <= c_mbv_adr_r;
  end
end

assign  g_mem_area = g_a_r[8];

always @(g_ms_r_n or g_write_r_n) begin
  if(g_ms_r_n == 1'b0 && g_write_r_n == 1'b0)
    g_cpu_we_s = 1'b1;
  else
    g_cpu_we_s = 1'b0;
end

always @(g_ms_r_n or g_read_r_n) begin
  if(g_ms_r_n == 1'b0 && g_read_r_n == 1'b0)
    g_cpu_re_s = 1'b1;
  else
    g_cpu_re_s = 1'b0;
end

always @(g_cpu_re_s or g_mem_area or g_a_r      or g_memr_ok_r) begin
  if(g_cpu_re_s == 1'b1 && g_mem_area == 1'b1) begin
    if(g_a_r == P_CPU_A_VDUDBYT || g_a_r == P_CPU_A_VDADBYT)
      g_cpu_memr = 1'b0;
    else if(g_memr_ok_r == 1'b1)
      g_cpu_memr = 1'b0;
    else
      g_cpu_memr = 1'b1;
  end
  else
    g_cpu_memr = 1'b0;
end

always @(g_cpu_we_s or g_mem_area or g_dmod_r) begin
  if(g_cpu_we_s == 1'b1 && g_mem_area == 1'b1 && g_dmod_r   == 1'b1)
    g_cpu_memw = 1'b1;
  else
    g_cpu_memw = 1'b0;
end

always @(g_paramadr_r) begin
  case(g_paramadr_r)
    P_VLD_A_CPYE0:  g_vld_memw = 1'b1;
    P_VLD_A_CPYE1:  g_vld_memw = 1'b1;
    P_VLD_A_CPYE2:  g_vld_memw = 1'b1;
    P_VLD_A_CPYE3:  g_vld_memw = 1'b1;
    P_VLD_A_USRD0:  g_vld_memw = 1'b1;
    P_VLD_A_USRD1:  g_vld_memw = 1'b1;
    P_VLD_A_USRD2:  g_vld_memw = 1'b1;
    P_VLD_A_ATSCD:  g_vld_memw = 1'b1;
    default:  g_vld_memw = 1'b0;
  endcase
end

assign  g_chg_slp_d  = g_chg_hsv | g_chg_vsv | g_chg_ari | g_chg_frc | g_chg_ps  | g_chg_dhs | g_chg_dvs;

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_chg_slp_r <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_chg_slp_r <= 1'b0;
  else if(g_chg_hsv == 1'b1 || g_chg_vsv == 1'b1)
    g_chg_slp_r <= 1'b1;
  else if(g_seqstrt_r == 1'b1)
    g_chg_slp_r <= 1'b0;
  else if(g_pcpl_r == 1'b1)
    g_chg_slp_r <= 1'b0;
  else
    g_chg_slp_r  <= g_chg_slp_r | g_chg_slp_d;
end

assign  g_pich_end  = g_phdet_r & g_slicestart_r;

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_phdet_r <= 1'b0;
  else if(g_picstrt_r == 1'b1)
    g_phdet_r <= 1'b1;
  else if(g_slicestart_r == 1'b1)
    g_phdet_r <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_vden_r <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDCNT0)
    g_vden_r <= g_wd_r[24];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_pskp_r <= 1'b0;
  else if(g_pskp_end_r == 1'b1)
    g_pskp_r <= 1'b0;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDCNT0 &&
    g_wd_r[16] == 1'b1)
    g_pskp_r <= 1'b1;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_init_vld_r_s  <= 1'b0;
  else if(g_init_cnt_r == 3'b000)
    g_init_vld_r_s  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r      == P_CPU_A_VDCNT0 &&
    g_wd_r[8]  == 1'b1 && g_wd_r[24] == 1'b1)
    g_init_vld_r_s  <= 1'b1;
  else if(g_init_vld_r_s == 1'b1)
    g_init_vld_r_s  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_swrst_r_n <= 1'b1;
  else if(g_init_breg_s == 1'b1)
    g_swrst_r_n <= 1'b0;
  else if(g_init_cnt_r == 3'b000)
    g_swrst_r_n <= 1'b1;
end

always @(g_cpu_we_s or g_a_r or g_wd_r) begin
  if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDCNT0 &&
     g_wd_r[0]  == 1'b1)
    g_init_breg_s = 1'b1;
  else
    g_init_breg_s = 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_init_cnt_r <= 3'b111;
  else if(g_init_breg_s == 1'b1)
    g_init_cnt_r <= 3'b111;
  else if(g_init_cnt_r == 3'b000)
    g_init_cnt_r <= 3'b000;
  else    
    g_init_cnt_r <= g_init_cnt_r - 1'b1;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_pini_r <= 1'b0;
  else if(g_init_breg_s == 1'b1 && g_imod_r == 1'b1)
    g_pini_r <= 1'b1;
  else if(g_init_cnt_r == 3'b000)
    g_pini_r <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_hsdc_r <= 7'h3c;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDCNT1)
    g_hsdc_r <= g_wd_r[14:8];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_vsdc_r <= 7'h24;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDCNT1)
    g_vsdc_r <= g_wd_r[6:0];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_hs60p_r <= 7'h50;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDCNT1)
    g_hs60p_r <= g_wd_r[30:24];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_vs60p_r <= 7'h2d;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDCNT1)
    g_vs60p_r <= g_wd_r[22:16];
end


always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_pcut_r <= 12'h400;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDCNT2)
    g_pcut_r <= g_wd_r[27:16];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_mbc_en_r <= 1'b0;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDCNT2)
    g_mbc_en_r <= g_wd_r[15];
end
 
always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_mbc_r  <= 12'h0;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDCNT2)
    g_mbc_r  <= g_wd_r[11:0];
end


always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fcyc_en_r <= 1'b0;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDCNT3)
    g_fcyc_en_r <= g_wd_r[31];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fcyc_r <= 18'h0;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDCNT3)
    g_fcyc_r <= g_wd_r[17:0];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0) begin
    g_amod_r <= 1'b0;
    g_mmod_r <= 1'b0;
    g_pmod_r <= 1'b0;
    g_dmod_r <= 1'b0;
    g_bmod_r <= 1'b0;
    g_imod_r <= 1'b0;
  end
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDMOD0) begin
    g_amod_r <= g_wd_r[25];
    g_mmod_r <= g_wd_r[24];
    g_pmod_r <= g_wd_r[16];
    g_dmod_r <= g_wd_r[8];
    g_bmod_r <= g_wd_r[1];
    g_imod_r <= g_wd_r[0];
  end
end

assign  g_vldmode_r  = {g_mmod_r,g_amod_r};

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_vsts_r <= 1'b0;
  else if(g_idlpl_r == 1'b1 && g_vden_r == 1'b0)
    g_vsts_r <= 1'b0;
  else if(g_init_vld_r_s == 1'b1)
    g_vsts_r <= 1'b1;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_mpeg_r <= 1'b0;
  else if(g_paramadr_r == P_VLD_A_MPEG1)
    g_mpeg_r <= g_paramdata_r[24];
end


always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0) begin
    g_icdc_r <= 1'b0;
    g_icuc_r <= 1'b0;
    g_icsw_r <= 1'b0;
    g_icsr_r <= 1'b0;
    g_icfp_r <= 1'b0;
    g_icfb_r <= 1'b0;
    g_icnf_r <= 1'b0;
    g_icpi_r <= 1'b0;
    g_icph_r <= 1'b0;
    g_icsh_r <= 1'b0;
  end
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICNT) begin
    g_icdc_r <= g_wd_r[11];
    g_icuc_r <= g_wd_r[10];
    g_icsw_r <= g_wd_r[9];
    g_icsr_r <= g_wd_r[8];
    g_icfp_r <= g_wd_r[18];
    g_icfb_r <= g_wd_r[17];
    g_icnf_r <= g_wd_r[16];
    g_icpi_r <= g_wd_r[2];
    g_icph_r <= g_wd_r[1];
    g_icsh_r <= g_wd_r[0];
  end
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_isfp_r  <= 1'b0;
  else if(g_icfp_r == 1'b1) begin
    if(g_ferror_r == 1'b1 && g_paramadr_r == P_VLD_A_SEQH0)
      g_isfp_r  <= 1'b1;
    else if(g_ferror_r == 1'b1 && g_paramadr_r == P_VLD_A_PICH1)
      g_isfp_r  <= 1'b1;
    else if(g_ferror_r == 1'b1 &&
      (g_paramadr_r == P_VLD_A_PICH4 ||
       g_paramadr_r == P_VLD_A_PICH6))
      g_isfp_r  <= 1'b1;
    else if(g_ferror_r == 1'b1 &&
      (g_paramadr_r == P_VLD_A_PICCE0 ||
        g_paramadr_r == P_VLD_A_PICCE1 ||
        g_paramadr_r == P_VLD_A_PICCE2 ||
        g_paramadr_r == P_VLD_A_PICCE3))
      g_isfp_r  <= 1'b1;
    else if(g_ferror_r == 1'b1 && g_paramadr_r == P_VLD_A_PICCE4)
      g_isfp_r  <= 1'b1;
    else if(g_ferror_r == 1'b1 && g_paramadr_r == P_VLD_A_PICCE5)
      g_isfp_r  <= 1'b1;
    else if( g_ferror_r == 1'b1 &&
      (g_qmseli_r == 1'b1 || g_qmseln_r == 1'b1))
      g_isfp_r  <= 1'b1;
    else if(g_vscdet_ferror_r == 1'b1 && g_slclverr_r == 1'b0)
      g_isfp_r  <= 1'b1;
    else if(g_sferror_r == 1'b1)
      g_isfp_r  <= 1'b1;
    else if(g_fld_mismatch_r == 1'b1)
      g_isfp_r  <= 1'b1;
    else if(g_pich_end == 1'b1 &&
      (g_isph_r  == 1'b1 || g_dsts_r == 1'b1))
      g_isfp_r  <= 1'b1;
    else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
      g_wd_r[18] == 1'b1)
      g_isfp_r  <= 1'b0;
    else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDISTS &&
      g_dmod_r   == 1'b1)
      g_isfp_r  <= g_wd_r[18];
  end
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[18] == 1'b1)
    g_isfp_r  <= 1'b0;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDISTS &&
    g_dmod_r   == 1'b1)
    g_isfp_r  <= g_wd_r[18];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_isfb_r  <= 1'b0;
  else if(g_icfb_r == 1'b1) begin
    if(g_vscdet_ferror_r == 1'b1 && g_slclverr_r == 1'b1)
      g_isfb_r  <= 1'b1;
    else if(g_tmg_ferr_hit_r == 1'b1)
      g_isfb_r  <= 1'b1;
    else if(g_ferror_r == 1'b1 && g_vdoen_r == 1'b1)
      g_isfb_r  <= 1'b1;
    else if(g_ferror_r == 1'b1 && g_paramadr_r == P_VLD_A_MB55)
      g_isfb_r  <= 1'b1;
    else if(g_ferror_r == 1'b1 &&
      (g_paramadr_r == P_VLD_A_MB61 ||
       g_paramadr_r == P_VLD_A_MB64 ||
       g_paramadr_r == P_VLD_A_MB69 ||
       g_paramadr_r == P_VLD_A_MB6C ||
       g_paramadr_r == P_VLD_A_MB71 ||
       g_paramadr_r == P_VLD_A_MB74 ||
       g_paramadr_r == P_VLD_A_MB79 ||
       g_paramadr_r == P_VLD_A_MB7C))
      g_isfb_r  <= 1'b1;
    else if(g_ferror_r == 1'b1 && g_paramadr_r == P_VLD_A_MB54)
      g_isfb_r  <= 1'b1;
    else if(g_ferror_r == 1'b1 && g_paramadr_r == P_VLD_A_MB52)
      g_isfb_r  <= 1'b1;
    else if(g_ferror_r == 1'b1 && g_paramadr_r == P_VLD_A_MB51)
      g_isfb_r  <= 1'b1;
    else if(g_mb_ferr_r == 1'b1)
      g_isfb_r  <= 1'b1;
    else if(g_ferror_r == 1'b1 && g_paramadr_r == P_VLD_A_MB50)
      g_isfb_r  <= 1'b1;
    else if(g_ferror_r == 1'b1 && g_paramadr_r == P_VLD_A_SLC0D)
      g_isfb_r  <= 1'b1;
    else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
      g_wd_r[17] == 1'b1)
      g_isfb_r  <= 1'b0;
    else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDISTS &&
      g_dmod_r   == 1'b1)
      g_isfb_r  <= g_wd_r[17];
  end
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[17] == 1'b1)
    g_isfb_r  <= 1'b0;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDISTS &&
    g_dmod_r   == 1'b1)
    g_isfb_r  <= g_wd_r[17];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_isnf_r  <= 1'b0;
  else if(g_icnf_r == 1'b1) begin
    if(g_nferror_r == 1'b1 && g_paramadr_r == P_VLD_A_SEQH1)
      g_isnf_r  <= 1'b1;
    else if(g_nferror_r == 1'b1 && g_paramadr_r == P_VLD_A_SEQH2)
      g_isnf_r  <= 1'b1;
    else if(g_nferror_r == 1'b1 && g_paramadr_r == P_VLD_A_SEQH3)
      g_isnf_r  <= 1'b1;
    else if(g_nferror_r == 1'b1 && g_qmseli_r  == 1'b1)
      g_isnf_r  <= 1'b1;
    else if(g_nferror_r == 1'b1 && g_paramadr_r == P_VLD_A_SEQE0)
      g_isnf_r  <= 1'b1;
    else if(g_nferror_r == 1'b1 && g_paramadr_r == P_VLD_A_SEQE2)
      g_isnf_r  <= 1'b1;
    else if(g_nferror_r == 1'b1 &&
      (g_paramadr_r == P_VLD_A_SEQE3 ||
       g_paramadr_r == P_VLD_A_SEQE4))
      g_isnf_r  <= 1'b1;
    else if(g_nferror_r == 1'b1 && g_paramadr_r == P_VLD_A_SEQE5)
      g_isnf_r  <= 1'b1;
    else if(g_nferror_r == 1'b1 && g_paramadr_r == P_VLD_A_SEQE6)
      g_isnf_r  <= 1'b1;
    else if(g_nferror_r == 1'b1 && g_paramadr_r == P_VLD_A_SEQE8)
      g_isnf_r  <= 1'b1;
    else if(g_nferror_r == 1'b1 && g_paramadr_r == P_VLD_A_SEQDE6)
      g_isnf_r  <= 1'b1;
    else if(g_nferror_r == 1'b1 && g_paramadr_r == P_VLD_A_GOPH0)
      g_isnf_r  <= 1'b1;
    else if(g_nferror_r == 1'b1 &&
      (g_paramadr_r == P_VLD_A_PICH3 ||
       g_paramadr_r == P_VLD_A_PICH5))
      g_isnf_r  <= 1'b1;
    else if(g_nferror_r == 1'b1 &&
      (g_paramadr_r == P_VLD_A_PICH4 ||
       g_paramadr_r == P_VLD_A_PICH6))
      g_isnf_r  <= 1'b1;
    else if(g_nferror_r == 1'b1 &&
      (g_paramadr_r == P_VLD_A_PICCE0 ||
       g_paramadr_r == P_VLD_A_PICCE1 ||
       g_paramadr_r == P_VLD_A_PICCE2 ||
       g_paramadr_r == P_VLD_A_PICCE3))
      g_isnf_r  <= 1'b1;
    else if(g_nferror_r == 1'b1 &&
      (g_paramadr_r == P_VLD_A_PICCE5 ||
       g_paramadr_r == P_VLD_A_PICCE6))
      g_isnf_r  <= 1'b1;
    else if(g_nferror_r == 1'b1 &&
      (g_paramadr_r == P_VLD_A_PICDE0 ||
       g_paramadr_r == P_VLD_A_PICDE1 ||
       g_paramadr_r == P_VLD_A_PICDE2 ||
       g_paramadr_r == P_VLD_A_PICDE3 ||
       g_paramadr_r == P_VLD_A_PICDE4 ||
       g_paramadr_r == P_VLD_A_PICDE5))
      g_isnf_r  <= 1'b1;
    else if(g_nferror_r == 1'b1 && g_paramadr_r == P_VLD_A_CPYE0)
      g_isnf_r  <= 1'b1;
    else if(g_nferror_r == 1'b1 &&
      (g_paramadr_r == P_VLD_A_CPYE1 ||
       g_paramadr_r == P_VLD_A_CPYE2 ||
       g_paramadr_r == P_VLD_A_CPYE3))
      g_isnf_r  <= 1'b1;
    else if(g_mb_nferr_r[2] == 1'b1)
      g_isnf_r  <= 1'b1;
    else if(g_mb_nferr_r[1] == 1'b1)
      g_isnf_r  <= 1'b1;
    else if(g_mb_nferr_r[0] == 1'b1)
      g_isnf_r  <= 1'b1;
    else if(g_nferror_r == 1'b1 &&
      (g_paramadr_r == P_VLD_A_MB61 ||
       g_paramadr_r == P_VLD_A_MB62 ||
       g_paramadr_r == P_VLD_A_MB64 ||
       g_paramadr_r == P_VLD_A_MB65 ||
       g_paramadr_r == P_VLD_A_MB69 ||
       g_paramadr_r == P_VLD_A_MB6A ||
       g_paramadr_r == P_VLD_A_MB6C ||
       g_paramadr_r == P_VLD_A_MB6D ||
       g_paramadr_r == P_VLD_A_MB71 ||
       g_paramadr_r == P_VLD_A_MB72 ||
       g_paramadr_r == P_VLD_A_MB74 ||
       g_paramadr_r == P_VLD_A_MB75 ||
       g_paramadr_r == P_VLD_A_MB79 ||
       g_paramadr_r == P_VLD_A_MB7A ||
       g_paramadr_r == P_VLD_A_MB7C ||
       g_paramadr_r == P_VLD_A_MB7D))
      g_isnf_r  <= 1'b1;
    else if(g_nferror_r == 1'b1 && g_vdoen_r == 1'b1)
      g_isnf_r  <= 1'b1;
    else if(g_vec_err_r == 1'b1)
      g_isnf_r  <= 1'b1;
    else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
      g_wd_r[16] == 1'b1)
      g_isnf_r  <= 1'b0;
    else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDISTS &&
      g_dmod_r   == 1'b1)
      g_isnf_r  <= g_wd_r[16];
  end
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_isnf_r  <= 1'b0;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDISTS &&
    g_dmod_r   == 1'b1)
    g_isnf_r  <= g_wd_r[16];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_isdc_r  <= 1'b0;
  else if(g_bfov_err_r == 1'b1 && g_icdc_r == 1'b1)
    g_isdc_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[11] == 1'b1)
    g_isdc_r  <= 1'b0;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDISTS &&
    g_dmod_r   == 1'b1)
    g_isdc_r  <= g_wd_r[11];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_isuc_r  <= 1'b0;
  else if(g_bfud_err_r == 1'b1 && g_icuc_r == 1'b1)
    g_isuc_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[10] == 1'b1)
    g_isuc_r  <= 1'b0;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDISTS &&
    g_dmod_r   == 1'b1)
    g_isuc_r  <= g_wd_r[10];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_issw_r  <= 1'b0;
  else if(g_w_response_error_r == 1'b1 && g_icsw_r == 1'b1)
    g_issw_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[9]  == 1'b1)
    g_issw_r  <= 1'b0;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDISTS &&
    g_dmod_r   == 1'b1)
    g_issw_r  <= g_wd_r[9];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_issr_r  <= 1'b0;
  else if(g_r_response_error_r == 1'b1 && g_icsr_r == 1'b1)
    g_issr_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[8]  == 1'b1)
    g_issr_r  <= 1'b0;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDISTS &&
    g_dmod_r   == 1'b1)
    g_issr_r  <= g_wd_r[8];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_ispi_r  <= 1'b0;
  else if(g_pcpl_tend_r == 1'b1 && g_icpi_r == 1'b1)
    g_ispi_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[2]  == 1'b1)
    g_ispi_r  <= 1'b0;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDISTS &&
    g_dmod_r   == 1'b1)
    g_ispi_r  <= g_wd_r[2];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_isph_r  <= 1'b0;
  else if(g_pich_end == 1'b1 && g_icph_r == 1'b1)
    g_isph_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[1]  == 1'b1)
    g_isph_r  <= 1'b0;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDISTS &&
    g_dmod_r   == 1'b1)
    g_isph_r  <= g_wd_r[1];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_issh_r  <= 1'b0;
  else if(g_chg_slp_r == 1'b1 && g_pich_end == 1'b1 &&
    g_icsh_r    == 1'b1)
    g_issh_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[0]  == 1'b1)
    g_issh_r  <= 1'b0;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDISTS &&
    g_dmod_r   == 1'b1)
    g_issh_r  <= g_wd_r[0];
end

assign  v1_int18_d_n  = !(g_isfp_r | g_isfb_r | g_isnf_r | g_isdc_r |
          g_isuc_r | g_issw_r | g_issr_r);

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    v1_int18_n  <= 1'b1;
  else
    v1_int18_n  <= v1_int18_d_n;
end

assign  v1_int23_d_n  = !(g_ispi_r | g_isph_r | g_issh_r);
always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    v1_int23_n  <= 1'b1;
  else
    v1_int23_n  <= v1_int23_d_n;
end


always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fpst11_r  <= 1'b0;
  else if(g_pich_end == 1'b1 &&
    (g_isph_r  == 1'b1 || g_dsts_r == 1'b1))
    g_fpst11_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[18] == 1'b1)
    g_fpst11_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fpst10_r  <= 1'b0;
  else if(g_fld_mismatch_r == 1'b1)
    g_fpst10_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[18] == 1'b1)
    g_fpst10_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fpst09_r  <= 1'b0;
  else if(g_sferror_r == 1'b1)
    g_fpst09_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[18] == 1'b1)
    g_fpst09_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fpst08_r  <= 1'b0;
  else if(g_vscdet_ferror_r == 1'b1 && g_slclverr_r == 1'b0)
    g_fpst08_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[18] == 1'b1)
    g_fpst08_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fpst07_r  <= 1'b0;
  else if( g_ferror_r == 1'b1 &&
    (g_qmseli_r == 1'b1 || g_qmseln_r == 1'b1))
    g_fpst07_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[18] == 1'b1)
    g_fpst07_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fpst06_r  <= 1'b0;
  else if(g_ferror_r == 1'b1 && g_paramadr_r == P_VLD_A_PICCE5)
    g_fpst06_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[18] == 1'b1)
    g_fpst06_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fpst05_r  <= 1'b0;
  else if(g_ferror_r == 1'b1 && g_paramadr_r == P_VLD_A_PICCE4)
    g_fpst05_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[18] == 1'b1)
    g_fpst05_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fpst04_r  <= 1'b0;
  else if(g_ferror_r == 1'b1 &&
    (g_paramadr_r == P_VLD_A_PICCE0 ||
     g_paramadr_r == P_VLD_A_PICCE1 ||
     g_paramadr_r == P_VLD_A_PICCE2 ||
     g_paramadr_r == P_VLD_A_PICCE3))
    g_fpst04_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[18] == 1'b1)
    g_fpst04_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fpst03_r  <= 1'b0;
  else if(g_ferror_r == 1'b1 &&
    (g_paramadr_r == P_VLD_A_PICH4 ||
     g_paramadr_r == P_VLD_A_PICH6))
    g_fpst03_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[18] == 1'b1)
    g_fpst03_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fpst02_r  <= 1'b0;
  else if(g_ferror_r == 1'b1 && g_paramadr_r == P_VLD_A_PICH1)
    g_fpst02_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[18] == 1'b1)
    g_fpst02_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fpst01_r  <= 1'b0;
  else if(g_ferror_r == 1'b1 && g_paramadr_r == P_VLD_A_SEQH0)
    g_fpst01_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[18] == 1'b1)
    g_fpst01_r  <= 1'b0;
end

assign  g_fpst_r  = {g_fpst11_r,g_fpst10_r,g_fpst09_r,g_fpst08_r,
         g_fpst07_r,g_fpst06_r,g_fpst05_r,g_fpst04_r,
         g_fpst03_r,g_fpst02_r,g_fpst01_r};


always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fbst11_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_fbst11_r  <= 1'b0;
  else if(g_vscdet_ferror_r == 1'b1 && g_slclverr_r == 1'b1)
    g_fbst11_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[17] == 1'b1)
    g_fbst11_r  <= 1'b0;
  else if(g_pcpl_tend_r == 1'b1)
    g_fbst11_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fbst10_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_fbst10_r  <= 1'b0;
  else if(g_tmg_ferr_hit_r == 1'b1)
    g_fbst10_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[17] == 1'b1)
    g_fbst10_r  <= 1'b0;
  else if(g_pcpl_tend_r == 1'b1)
    g_fbst10_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fbst09_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_fbst09_r  <= 1'b0;
  else if(g_ferror_r == 1'b1 && g_vdoen_r == 1'b1)
    g_fbst09_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[17] == 1'b1)
    g_fbst09_r  <= 1'b0;
  else if(g_pcpl_tend_r == 1'b1)
    g_fbst09_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fbst08_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_fbst08_r  <= 1'b0;
  else if(g_ferror_r == 1'b1 && g_paramadr_r == P_VLD_A_MB55)
    g_fbst08_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[17] == 1'b1)
    g_fbst08_r  <= 1'b0;
  else if(g_pcpl_tend_r == 1'b1)
    g_fbst08_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fbst07_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_fbst07_r  <= 1'b0;
  else if(g_ferror_r == 1'b1 &&
    (g_paramadr_r == P_VLD_A_MB61 ||
     g_paramadr_r == P_VLD_A_MB64 ||
     g_paramadr_r == P_VLD_A_MB69 ||
     g_paramadr_r == P_VLD_A_MB6C ||
     g_paramadr_r == P_VLD_A_MB71 ||
     g_paramadr_r == P_VLD_A_MB74 ||
     g_paramadr_r == P_VLD_A_MB79 ||
     g_paramadr_r == P_VLD_A_MB7C))
    g_fbst07_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[17] == 1'b1)
    g_fbst07_r  <= 1'b0;
  else if(g_pcpl_tend_r == 1'b1)
    g_fbst07_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fbst06_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_fbst06_r  <= 1'b0;
  else if(g_ferror_r == 1'b1 && g_paramadr_r == P_VLD_A_MB54)
    g_fbst06_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[17] == 1'b1)
    g_fbst06_r  <= 1'b0;
  else if(g_pcpl_tend_r == 1'b1)
    g_fbst06_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fbst05_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_fbst05_r  <= 1'b0;
  else if(g_ferror_r == 1'b1 && g_paramadr_r == P_VLD_A_MB52)
    g_fbst05_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[17] == 1'b1)
    g_fbst05_r  <= 1'b0;
  else if(g_pcpl_tend_r == 1'b1)
    g_fbst05_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fbst04_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_fbst04_r  <= 1'b0;
  else if(g_ferror_r == 1'b1 && g_paramadr_r == P_VLD_A_MB51)
    g_fbst04_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[17] == 1'b1)
    g_fbst04_r  <= 1'b0;
  else if(g_pcpl_tend_r == 1'b1)
    g_fbst04_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fbst03_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_fbst03_r  <= 1'b0;
  else if(g_mb_ferr_r == 1'b1)
    g_fbst03_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[17] == 1'b1)
    g_fbst03_r  <= 1'b0;
  else if(g_pcpl_tend_r == 1'b1)
    g_fbst03_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fbst02_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_fbst02_r  <= 1'b0;
  else if(g_ferror_r == 1'b1 && g_paramadr_r == P_VLD_A_MB50)
    g_fbst02_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[17] == 1'b1)
    g_fbst02_r  <= 1'b0;
  else if(g_pcpl_tend_r == 1'b1)
    g_fbst02_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fbst01_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_fbst01_r  <= 1'b0;
  else if(g_ferror_r == 1'b1 && g_paramadr_r == P_VLD_A_SLC0D)
    g_fbst01_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[17] == 1'b1)
    g_fbst01_r  <= 1'b0;
  else if(g_pcpl_tend_r == 1'b1)
    g_fbst01_r  <= 1'b0;
end

assign  g_fbst_r  = {g_fbst11_r,g_fbst10_r,g_fbst09_r,g_fbst08_r,
         g_fbst07_r,g_fbst06_r,g_fbst05_r,g_fbst04_r,
         g_fbst03_r,g_fbst02_r,g_fbst01_r};


always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst25_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst25_r  <= 1'b0;
  else if(g_vec_err_r == 1'b1)
    g_nfst25_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst25_r  <= 1'b0;
  else if(g_pcpl_tend_r == 1'b1)
    g_nfst25_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst24_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst24_r  <= 1'b0;
  else if(g_nferror_r == 1'b1 && g_vdoen_r == 1'b1)
    g_nfst24_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst24_r  <= 1'b0;
  else if(g_pcpl_tend_r == 1'b1)
    g_nfst24_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst23_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst23_r  <= 1'b0;
  else if(g_nferror_r == 1'b1 &&
    (g_paramadr_r == P_VLD_A_MB61 ||
     g_paramadr_r == P_VLD_A_MB62 ||
     g_paramadr_r == P_VLD_A_MB64 ||
     g_paramadr_r == P_VLD_A_MB65 ||
     g_paramadr_r == P_VLD_A_MB69 ||
     g_paramadr_r == P_VLD_A_MB6A ||
     g_paramadr_r == P_VLD_A_MB6C ||
     g_paramadr_r == P_VLD_A_MB6D ||
     g_paramadr_r == P_VLD_A_MB71 ||
     g_paramadr_r == P_VLD_A_MB72 ||
     g_paramadr_r == P_VLD_A_MB74 ||
     g_paramadr_r == P_VLD_A_MB75 ||
     g_paramadr_r == P_VLD_A_MB79 ||
     g_paramadr_r == P_VLD_A_MB7A ||
     g_paramadr_r == P_VLD_A_MB7C ||
     g_paramadr_r == P_VLD_A_MB7D))
    g_nfst23_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst23_r  <= 1'b0;
  else if(g_pcpl_tend_r == 1'b1)
    g_nfst23_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst22_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst22_r  <= 1'b0;
  else if(g_mb_nferr_r[2] == 1'b1)
    g_nfst22_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst22_r  <= 1'b0;
  else if(g_pcpl_tend_r == 1'b1)
    g_nfst22_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst21_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst21_r  <= 1'b0;
  else if(g_mb_nferr_r[1] == 1'b1)
    g_nfst21_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst21_r  <= 1'b0;
  else if(g_pcpl_tend_r == 1'b1)
    g_nfst21_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst20_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst20_r  <= 1'b0;
  else if(g_mb_nferr_r[0] == 1'b1)
    g_nfst20_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst20_r  <= 1'b0;
  else if(g_pcpl_tend_r == 1'b1)
    g_nfst20_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst19_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst19_r  <= 1'b0;
  else if(g_nferror_r == 1'b1 &&
    (g_paramadr_r == P_VLD_A_CPYE1 ||
     g_paramadr_r == P_VLD_A_CPYE2 ||
     g_paramadr_r == P_VLD_A_CPYE3))
    g_nfst19_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst19_r  <= 1'b0;
  else if(g_seqstrt_r == 1'b1 || g_gopstrt_r == 1'b1 ||
    g_picstrt_r == 1'b1)
    g_nfst19_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst18_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst18_r  <= 1'b0;
  else if(g_nferror_r == 1'b1 && g_paramadr_r == P_VLD_A_CPYE0)
    g_nfst18_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst18_r  <= 1'b0;
  else if(g_seqstrt_r == 1'b1 || g_gopstrt_r == 1'b1 ||
    g_picstrt_r == 1'b1)
    g_nfst18_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst17_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst17_r  <= 1'b0;
  else if(g_nferror_r == 1'b1 &&
    (g_paramadr_r == P_VLD_A_PICDE0 ||
     g_paramadr_r == P_VLD_A_PICDE1 ||
     g_paramadr_r == P_VLD_A_PICDE2 ||
     g_paramadr_r == P_VLD_A_PICDE3 ||
     g_paramadr_r == P_VLD_A_PICDE4 ||
     g_paramadr_r == P_VLD_A_PICDE5))
    g_nfst17_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst17_r  <= 1'b0;
  else if(g_seqstrt_r == 1'b1 || g_gopstrt_r == 1'b1 ||
    g_picstrt_r == 1'b1)
    g_nfst17_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst16_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst16_r  <= 1'b0;
  else if(g_nferror_r == 1'b1 &&
    (g_paramadr_r == P_VLD_A_PICCE5 ||
     g_paramadr_r == P_VLD_A_PICCE6))
    g_nfst16_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst16_r  <= 1'b0;
  else if(g_seqstrt_r == 1'b1 || g_gopstrt_r == 1'b1 ||
    g_picstrt_r == 1'b1)
    g_nfst16_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst15_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst15_r  <= 1'b0;
  else if(g_nferror_r == 1'b1 &&
    (g_paramadr_r == P_VLD_A_PICCE0 ||
     g_paramadr_r == P_VLD_A_PICCE1 ||
     g_paramadr_r == P_VLD_A_PICCE2 ||
     g_paramadr_r == P_VLD_A_PICCE3))
    g_nfst15_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst15_r  <= 1'b0;
  else if(g_seqstrt_r == 1'b1 || g_gopstrt_r == 1'b1 ||
    g_picstrt_r == 1'b1)
    g_nfst15_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst14_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst14_r  <= 1'b0;
  else if(g_nferror_r == 1'b1 &&
    (g_paramadr_r == P_VLD_A_PICH4 ||
     g_paramadr_r == P_VLD_A_PICH6))
    g_nfst14_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst14_r  <= 1'b0;
  else if(g_seqstrt_r == 1'b1 || g_gopstrt_r == 1'b1 ||
    g_picstrt_r == 1'b1)
    g_nfst14_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst13_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst13_r  <= 1'b0;
  else if(g_nferror_r == 1'b1 &&
    (g_paramadr_r == P_VLD_A_PICH3 ||
     g_paramadr_r == P_VLD_A_PICH5))
    g_nfst13_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst13_r  <= 1'b0;
  else if(g_seqstrt_r == 1'b1 || g_gopstrt_r == 1'b1 ||
    g_picstrt_r == 1'b1)
    g_nfst13_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst12_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst12_r  <= 1'b0;
  else if(g_nferror_r == 1'b1 && g_paramadr_r == P_VLD_A_GOPH0)
    g_nfst12_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst12_r  <= 1'b0;
  else if(g_seqstrt_r == 1'b1 || g_gopstrt_r == 1'b1)
    g_nfst12_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst11_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst11_r  <= 1'b0;
  else if(g_nferror_r == 1'b1 && g_paramadr_r == P_VLD_A_SEQDE6)
    g_nfst11_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst11_r  <= 1'b0;
  else if(g_seqstrt_r == 1'b1)
    g_nfst11_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst10_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst10_r  <= 1'b0;
  else if(g_nferror_r == 1'b1 && g_paramadr_r == P_VLD_A_SEQE8)
    g_nfst10_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst10_r  <= 1'b0;
  else if(g_seqstrt_r == 1'b1)
    g_nfst10_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst09_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst09_r  <= 1'b0;
  else if(g_nferror_r == 1'b1 && g_paramadr_r == P_VLD_A_SEQE6)
    g_nfst09_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst09_r  <= 1'b0;
  else if(g_seqstrt_r == 1'b1)
    g_nfst09_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst08_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst08_r  <= 1'b0;
  else if(g_nferror_r == 1'b1 && g_paramadr_r == P_VLD_A_SEQE5)
    g_nfst08_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst08_r  <= 1'b0;
  else if(g_seqstrt_r == 1'b1)
    g_nfst08_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst07_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst07_r  <= 1'b0;
  else if(g_nferror_r == 1'b1 &&
    (g_paramadr_r == P_VLD_A_SEQE3 ||
     g_paramadr_r == P_VLD_A_SEQE4))
    g_nfst07_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst07_r  <= 1'b0;
  else if(g_seqstrt_r == 1'b1)
    g_nfst07_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst06_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst06_r  <= 1'b0;
  else if(g_nferror_r == 1'b1 && g_paramadr_r == P_VLD_A_SEQE2)
    g_nfst06_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst06_r  <= 1'b0;
  else if(g_seqstrt_r == 1'b1)
    g_nfst06_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst05_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst05_r  <= 1'b0;
  else if(g_nferror_r == 1'b1 && g_paramadr_r == P_VLD_A_SEQE0)
    g_nfst05_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst05_r  <= 1'b0;
  else if(g_seqstrt_r == 1'b1)
    g_nfst05_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst04_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst04_r  <= 1'b0;
  else if(g_nferror_r == 1'b1 && g_qmseli_r  == 1'b1)
    g_nfst04_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst04_r  <= 1'b0;
  else if(g_seqstrt_r == 1'b1 || g_qmxstrt_r == 1'b1)
    g_nfst04_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst03_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst03_r  <= 1'b0;
  else if(g_nferror_r == 1'b1 && g_paramadr_r == P_VLD_A_SEQH3)
    g_nfst03_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst03_r  <= 1'b0;
  else if(g_seqstrt_r == 1'b1)
    g_nfst03_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst02_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst02_r  <= 1'b0;
  else if(g_nferror_r == 1'b1 && g_paramadr_r == P_VLD_A_SEQH2)
    g_nfst02_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst02_r  <= 1'b0;
  else if(g_seqstrt_r == 1'b1)
    g_nfst02_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfst01_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_nfst01_r  <= 1'b0;
  else if(g_nferror_r == 1'b1 && g_paramadr_r == P_VLD_A_SEQH1)
    g_nfst01_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_nfst01_r  <= 1'b0;
  else if(g_seqstrt_r == 1'b1)
    g_nfst01_r  <= 1'b0;
end

assign  g_nfst_r  = {g_nfst25_r,g_nfst24_r,g_nfst23_r,g_nfst22_r,
         g_nfst21_r,g_nfst20_r,g_nfst19_r,g_nfst18_r,
         g_nfst17_r,g_nfst16_r,g_nfst15_r,g_nfst14_r,
         g_nfst13_r,g_nfst12_r,g_nfst11_r,g_nfst10_r,
         g_nfst09_r,g_nfst08_r,g_nfst07_r,g_nfst06_r,
         g_nfst05_r,g_nfst04_r,g_nfst03_r,g_nfst02_r,
         g_nfst01_r};

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_prev_efbst_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_prev_efbst_r  <= 1'b0;
  else if(g_fbst_r == 11'h0)
    g_prev_efbst_r  <= 1'b0;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[17] == 1'b1)
    g_prev_efbst_r  <= 1'b0;
  else if(g_pcpl_tend_r == 1'b1)
    g_prev_efbst_r  <= 1'b0;
  else
    g_prev_efbst_r  <= 1'b1;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_prev_enfst_r  <= 1'b0;
  else if(g_init_breg_s == 1'b1)
    g_prev_enfst_r  <= 1'b0;
  else if(g_nfst_r[24:19] == 6'h0)
    g_prev_enfst_r  <= 1'b0;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR &&
    g_wd_r[16] == 1'b1)
    g_prev_enfst_r  <= 1'b0;
  else if(g_pcpl_tend_r == 1'b1)
    g_prev_enfst_r  <= 1'b0;
  else
    g_prev_enfst_r  <= 1'b1;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0) begin
    g_embh_adr_r  <= 7'h0;
    g_embv_adr_r  <= 7'h0;
  end
  else if(g_init_breg_s == 1'b1) begin
    g_embh_adr_r  <= 7'h0;
    g_embv_adr_r  <= 7'h0;
  end 
  else if(g_fbst_r == 11'h0 && g_nfst_r[24:19] == 6'h0) begin
    g_embh_adr_r  <= 7'h0;
    g_embv_adr_r  <= 7'h0;
  end
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDICLR) begin
    if(g_wd_r[17:16] == 2'b11) begin
      g_embh_adr_r  <= 7'h0;
      g_embv_adr_r  <= 7'h0;
    end
    else if(g_wd_r[17] == 1'b1 && g_prev_enfst_r == 1'b0) begin
      g_embh_adr_r  <= 7'h0;
      g_embv_adr_r  <= 7'h0;
    end
    else if(g_wd_r[16] == 1'b1 && g_prev_efbst_r == 1'b0) begin
      g_embh_adr_r  <= 7'h0;
      g_embv_adr_r  <= 7'h0;
    end
  end
  else if(g_pcpl_tend_r == 1'b1) begin
    g_embh_adr_r  <= 7'h0;
    g_embv_adr_r  <= 7'h0;
  end
  else if(g_prev_efbst_r == 1'b0 && g_prev_enfst_r == 1'b0) begin
    g_embh_adr_r  <= g_mbh_adr_r;
    g_embv_adr_r  <= g_mbv_adr_r;
  end
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_dcnt_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDDCNT)
    g_dcnt_r  <= g_wd_r[0];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_dsts_r  <= 1'b0;
  else if(g_pich_end == 1'b1 && g_dcnt_r == 1'b1)
    g_dsts_r  <= 1'b1;
  else if(g_dack32_r_n == 1'b0 || g_dacksh_r_n == 1'b0)
    g_dsts_r  <= 1'b0;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDDSTS &&
    g_dmod_r   == 1'b1)
    g_dsts_r  <= g_wd_r[0];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    v1_dmareq8_n  <= 1'b1;
  else
    v1_dmareq8_n  <= !g_dsts_r;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_field_start_add_r  <= 22'h1000;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDSDFMA)
    g_field_start_add_r  <= g_wd_r[31:10];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_field_offset_r  <= 12'h40;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDSDFOS)
    g_field_offset_r  <= g_wd_r[11:0];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_cbcr_offset_r  <= 12'h20;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDSDCOS)
    g_cbcr_offset_r  <= g_wd_r[11:0];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_line_offset_r  <= 1'b1;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDSDLOS)
      // CPU Write
    g_line_offset_r  <= g_wd_r[0];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_hclr_r_s  <= 1'b0;
  else if(g_cpu_we_s == 1'b1 && g_a_r == P_CPU_A_VDHCLR &&
    g_wd_r[0]  == 1'b1)
    g_hclr_r_s  <= 1'b1;
  else if(g_hclr_r_s == 1'b1)
    g_hclr_r_s  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_shd_r  <= 1'b0;
  else if(g_seqstrt_r == 1'b1)
    g_shd_r  <= 1'b1;
  else if(g_pich_end == 1'b1)
    g_shd_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_sed_r  <= 1'b0;
  else if(g_sqxstrt_r == 1'b1)
    g_sed_r  <= 1'b1;
  else if(g_seqstrt_r == 1'b1)
    g_sed_r  <= 1'b0;
  else if(g_pich_end == 1'b1)
    g_sed_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_sded_r  <= 1'b0;
  else if(g_sdxstrt_r == 1'b1)
    g_sded_r  <= 1'b1;
  else if(g_seqstrt_r == 1'b1)
    g_sded_r  <= 1'b0;
  else if(g_pich_end == 1'b1)
    g_sded_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_ud0d_r  <= 1'b0;
  else if(g_ud0strt_r == 1'b1)
    g_ud0d_r  <= 1'b1;
  else if(g_seqstrt_r == 1'b1)
    g_ud0d_r  <= 1'b0;
  else if(g_pich_end == 1'b1)
    g_ud0d_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_ghd_r  <= 1'b0;
  else if(g_gopstrt_r == 1'b1)
    g_ghd_r  <= 1'b1;
  else if(g_seqstrt_r == 1'b1)
    g_ghd_r  <= 1'b0;
  else if(g_pich_end == 1'b1)
    g_ghd_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_ud1d_r  <= 1'b0;
  else if(g_ud1strt_r == 1'b1)
    g_ud1d_r  <= 1'b1;
  else if(g_seqstrt_r == 1'b1 || g_gopstrt_r == 1'b1)
    g_ud1d_r  <= 1'b0;
  else if(g_pich_end == 1'b1)
    g_ud1d_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_phd_r  <= 1'b0;
  else if(g_picstrt_r == 1'b1)
    g_phd_r  <= 1'b1;
  else if(g_pich_end == 1'b1)
    g_phd_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_pced_r  <= 1'b0;
  else if(g_pcxstrt_r == 1'b1)
    g_pced_r  <= 1'b1;
  else if(g_picstrt_r == 1'b1)
    g_pced_r  <= 1'b0;
  else if(g_pich_end == 1'b1)
    g_pced_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_ced_r  <= 1'b0;
  else if(g_cpxstrt_r == 1'b1)
    g_ced_r  <= 1'b1;
  else if(g_picstrt_r == 1'b1)
    g_ced_r  <= 1'b0;
  else if(g_pich_end == 1'b1)
    g_ced_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_pded_r  <= 1'b0;
  else if(g_pdxstrt_r == 1'b1)
    g_pded_r  <= 1'b1;
  else if(g_picstrt_r == 1'b1)
    g_pded_r  <= 1'b0;
  else if(g_pich_end == 1'b1)
    g_pded_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_qme_r  <= 1'b0;
  else if(g_qmxstrt_r == 1'b1)
    g_qme_r  <= 1'b1;
  else if(g_picstrt_r == 1'b1)
    g_qme_r  <= 1'b0;
  else if(g_pich_end == 1'b1)
    g_qme_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_ud2d_r  <= 1'b0;
  else if(g_ud2strt_r == 1'b1)
    g_ud2d_r  <= 1'b1;
  else if(g_picstrt_r == 1'b1)
    g_ud2d_r  <= 1'b0;
  else if(g_pich_end == 1'b1)
    g_ud2d_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_add_r  <= 1'b0;
  else if(g_atscdet_r == 1'b1)
    g_add_r  <= 1'b1;
  else if(g_picstrt_r == 1'b1)
    g_add_r  <= 1'b0;
  else if(g_pich_end == 1'b1)
    g_add_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_hdflag_r  <= 13'h0;
  else if(g_pich_end == 1'b1)
    g_hdflag_r  <= {g_add_r,g_ud2d_r,g_pded_r,g_ced_r,
            g_qme_r,g_pced_r,g_phd_r,
            g_ud1d_r,g_ghd_r,
            g_ud0d_r,g_sded_r,g_sed_r,g_shd_r};
  else if(g_hclr_r_s == 1'b1)
    g_hdflag_r  <= 13'h0;
end


always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_hsv_r  <= 12'h0;
  else if(g_paramadr_r == P_VLD_A_SEQH0) begin
    if(g_ferror_r == 1'b1)
      g_hsv_r  <= 12'h0;
    else
      g_hsv_r  <= g_paramdata_r[24:13];
  end
end

always @(g_paramadr_r or g_paramdata_r or g_hsv_r) begin
  if(g_paramadr_r == P_VLD_A_SEQH0 &&
     g_hsv_r      != g_paramdata_r[24:13])
    g_chg_hsv  = 1'b1;
  else
    g_chg_hsv  = 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_vsv_r  <= 12'h0;
  else if(g_paramadr_r == P_VLD_A_SEQH0) begin
    if(g_ferror_r == 1'b1)
      g_vsv_r  <= 12'h0;
    else
      g_vsv_r  <= g_paramdata_r[12:1];
  end
end

always @(g_paramadr_r or g_paramdata_r or g_vsv_r) begin
  if(g_paramadr_r == P_VLD_A_SEQH0 &&
     g_vsv_r      != g_paramdata_r[12:1])
    g_chg_vsv  = 1'b1;
  else
    g_chg_vsv  = 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_ari_r  <= 4'h0;
  else if(g_paramadr_r == P_VLD_A_SEQH1)
    g_ari_r  <= g_paramdata_r[24:21];
end

always @(g_paramadr_r or g_paramdata_r or g_ari_r) begin
  if(g_paramadr_r == P_VLD_A_SEQH1 &&
     g_ari_r      != g_paramdata_r[24:21])
    g_chg_ari  = 1'b1;
  else
    g_chg_ari  = 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_frc_r  <= 4'h0;
  else if(g_paramadr_r == P_VLD_A_SEQH1)
    g_frc_r  <= g_paramdata_r[20:17];
end

always @(g_paramadr_r or g_paramdata_r or g_frc_r) begin
  if(g_paramadr_r == P_VLD_A_SEQH1 &&
     g_frc_r      != g_paramdata_r[20:17])
    g_chg_frc  = 1'b1;
  else
    g_chg_frc  = 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_brv_r  <= 18'h0;
  else if(g_paramadr_r == P_VLD_A_SEQH2)
    g_brv_r  <= g_paramdata_r[24:7];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_vbsv_r  <= 10'h0;
  else if(g_paramadr_r == P_VLD_A_SEQH3)
    g_vbsv_r  <= g_paramdata_r[23:14];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_cpf_r  <= 1'b0;
  else if(g_paramadr_r == P_VLD_A_SEQH4)
    g_cpf_r  <= g_paramdata_r[24];
end


always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_pali_r  <= 8'h0;
  else if(g_paramadr_r == P_VLD_A_SEQE0)
    g_pali_r  <= g_paramdata_r[24:17];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_ps_r  <= 1'b0;
  else if(g_paramadr_r == P_VLD_A_SEQE1)
    g_ps_r  <= g_paramdata_r[24];
end

always @(g_paramadr_r or g_paramdata_r or g_ps_r) begin
  if(g_paramadr_r == P_VLD_A_SEQE1 &&
     g_ps_r       != g_paramdata_r[24])
    g_chg_ps  = 1'b1;
  else
    g_chg_ps  = 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_cf_r  <= 2'h0;
  else if(g_paramadr_r == P_VLD_A_SEQE2)
    g_cf_r  <= g_paramdata_r[24:23];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_ld_r  <= 1'b0;
  else if(g_paramadr_r == P_VLD_A_SEQE7)
    g_ld_r  <= g_paramdata_r[24];
end


always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_vf_r  <= 3'h0;
  else if(g_paramadr_r == P_VLD_A_SEQDE0)
    g_vf_r  <= g_paramdata_r[24:22];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_cd_r  <= 1'b0;
  else if(g_paramadr_r == P_VLD_A_SEQDE1)
    g_cd_r  <= g_paramdata_r[24];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_cp_r  <= 8'h0;
  else if(g_paramadr_r == P_VLD_A_SEQDE2)
    g_cp_r  <= g_paramdata_r[24:17];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_tc_r  <= 8'h0;
  else if(g_paramadr_r == P_VLD_A_SEQDE3)
    g_tc_r  <= g_paramdata_r[24:17];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_mc_r  <= 8'h0;
  else if(g_paramadr_r == P_VLD_A_SEQDE4)
    g_mc_r  <= g_paramdata_r[24:17];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_dhs_r  <= 14'h0;
  else if(g_paramadr_r == P_VLD_A_SEQDE5)
    g_dhs_r  <= g_paramdata_r[24:11];
end

always @(g_paramadr_r or g_paramdata_r or g_dhs_r) begin
  if(g_paramadr_r == P_VLD_A_SEQDE5 &&
     g_dhs_r      != g_paramdata_r[24:11])
    g_chg_dhs  = 1'b1;
  else
    g_chg_dhs  = 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_dvs_r  <= 14'h0;
  else if(g_paramadr_r == P_VLD_A_SEQDE6)
    g_dvs_r  <= g_paramdata_r[23:10];
end

always @(g_paramadr_r or g_paramdata_r or g_dvs_r) begin
  if(g_paramadr_r == P_VLD_A_SEQDE6 &&
     g_dvs_r      != g_paramdata_r[23:10])
    g_chg_dvs  = 1'b1;
  else
    g_chg_dvs  = 1'b0;
end


always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_tmc_r  <= 24'h0;
  else if(g_paramadr_r == P_VLD_A_GOPH0)
    g_tmc_r  <= {g_paramdata_r[24:13],g_paramdata_r[11:0]};
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_cg_r  <= 1'b0;
  else if(g_paramadr_r == P_VLD_A_GOPH1)
    g_cg_r  <= g_paramdata_r[24];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_bl_r  <= 1'b0;
  else if(g_paramadr_r == P_VLD_A_GOPH1)
    g_bl_r  <= g_paramdata_r[23];
end


always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_tr_r  <= 10'h0;
  else if(g_paramadr_r == P_VLD_A_PICH0)
    g_tr_r  <= g_paramdata_r[24:15];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_pct_r  <= 3'h0;
  else if(g_paramadr_r == P_VLD_A_PICH1)
    g_pct_r  <= g_paramdata_r[24:22];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_vd_r  <= 16'h0;
  else if(g_paramadr_r == P_VLD_A_PICH2)
    g_vd_r  <= g_paramdata_r[24:9];
end


always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_pis_r  <= 2'h0;
  else if(g_paramadr_r == P_VLD_A_PICCE5)
    g_pis_r  <= g_paramdata_r[24:23];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_tff_r  <= 1'b0;
  else if(g_paramadr_r == P_VLD_A_PICCE6)
    g_tff_r  <= g_paramdata_r[24];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_rff_r  <= 1'b0;
  else if(g_paramadr_r == P_VLD_A_PICCE6)
    g_rff_r  <= g_paramdata_r[18];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_pf_r  <= 1'b0;
  else if(g_paramadr_r == P_VLD_A_PICCE6)
    g_pf_r  <= g_paramdata_r[16];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_cdf_r  <= 1'b0;
  else if(g_paramadr_r == P_VLD_A_PICCE7)
    g_cdf_r  <= g_paramdata_r[24];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_va_r  <= 1'b0;
  else if(g_paramadr_r == P_VLD_A_PICCE8)
    g_va_r  <= g_paramdata_r[24];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fs_r  <= 3'h0;
  else if(g_paramadr_r == P_VLD_A_PICCE8)
    g_fs_r  <= g_paramdata_r[23:21];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_sc_r  <= 1'b0;
  else if(g_paramadr_r == P_VLD_A_PICCE8)
    g_sc_r  <= g_paramdata_r[20];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_ba_r  <= 7'h0;
  else if(g_paramadr_r == P_VLD_A_PICCE8)
    g_ba_r  <= g_paramdata_r[19:13];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_scp_r  <= 8'h0;
  else if(g_paramadr_r == P_VLD_A_PICCE8)
    g_scp_r  <= g_paramdata_r[12:5];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_nfco_r  <= 2'h0;
  else if(g_paramadr_r == P_VLD_A_PICDE6)
    g_nfco_r  <= g_paramdata_r[24:23];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fcho0_r  <= 16'h0;
  else if(g_paramadr_r == P_VLD_A_PICDE0)
    g_fcho0_r  <= g_paramdata_r[24:9];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fcvo0_r  <= 16'h0;
  else if(g_paramadr_r == P_VLD_A_PICDE1)
    g_fcvo0_r  <= g_paramdata_r[24:9];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fcho1_r  <= 16'h0;
  else if(g_paramadr_r == P_VLD_A_PICDE2)
    g_fcho1_r  <= g_paramdata_r[24:9];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fcvo1_r  <= 16'h0;
  else if(g_paramadr_r == P_VLD_A_PICDE3)
    g_fcvo1_r  <= g_paramdata_r[24:9];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fcho2_r  <= 16'h0;
  else if(g_paramadr_r == P_VLD_A_PICDE4)
    g_fcho2_r  <= g_paramdata_r[24:9];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_fcvo2_r  <= 16'h0;
  else if(g_paramadr_r == P_VLD_A_PICDE5)
    g_fcvo2_r  <= g_paramdata_r[24:9];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0) begin
    g_udb0_r  <= 7'h0;
    g_udb0_wen_r  <= 1'b0;
  end
  else if(g_pich_end == 1'b1) begin
    g_udb0_r  <= 7'h0;
    g_udb0_wen_r  <= 1'b0;
  end
  else if(g_seqstrt_r == 1'b1) begin
    g_udb0_r  <= 7'h0;
    g_udb0_wen_r  <= 1'b1;
  end
  else if(g_udb_d == P_MAX_UD_BYTE) begin
    g_udb0_r  <= g_udb0_r;
    g_udb0_wen_r  <= 1'b0;
  end
  else if(g_paramadr_r == P_VLD_A_USRD0) begin
    g_udb0_r  <= g_udb0_r + 1'b1;
    g_udb0_wen_r  <= 1'b1;
  end
  else begin
    g_udb0_r  <= g_udb0_r;
    g_udb0_wen_r  <= 1'b0;
  end
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0) begin
    g_udb1_r  <= 7'h0;
    g_udb1_wen_r  <= 1'b0;
  end
  else if(g_pich_end == 1'b1) begin
    g_udb1_r  <= 7'h0;
    g_udb1_wen_r  <= 1'b0;
  end
  else if(g_seqstrt_r == 1'b1 || g_gopstrt_r == 1'b1) begin
    g_udb1_r  <= 7'h0;
    g_udb1_wen_r  <= 1'b1;
  end
  else if(g_udb_d == P_MAX_UD_BYTE) begin
    g_udb1_r  <= g_udb1_r;
    g_udb1_wen_r  <= 1'b0;
  end
  else if(g_paramadr_r == P_VLD_A_USRD1) begin
    g_udb1_r  <= g_udb1_r + 1'b1;
    g_udb1_wen_r  <= 1'b1;
  end
  else begin
    g_udb1_r  <= g_udb1_r;
    g_udb1_wen_r  <= 1'b0;
  end
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0) begin
    g_udb2_r  <= 7'h0;
    g_udb2_wen_r  <= 1'b0;
  end
  else if(g_pich_end == 1'b1) begin
    g_udb2_r  <= 7'h0;
    g_udb2_wen_r  <= 1'b0;
  end
  else if(g_seqstrt_r == 1'b1 || g_gopstrt_r == 1'b1 ||
    g_picstrt_r == 1'b1) begin
    g_udb2_r  <= 7'h0;
    g_udb2_wen_r  <= 1'b1;
  end
  else if(g_udb_d == P_MAX_UD_BYTE) begin
    g_udb2_r  <= g_udb2_r;
    g_udb2_wen_r  <= 1'b0;
  end
  else if(g_paramadr_r == P_VLD_A_USRD2) begin
    g_udb2_r  <= g_udb2_r + 1'b1;
    g_udb2_wen_r  <= 1'b1;
  end
  else begin
    g_udb2_r  <= g_udb2_r;
    g_udb2_wen_r  <= 1'b0;
  end
end

assign  g_udb_d  = g_udb0_r + g_udb1_r + g_udb2_r;

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_udb_r  <= 7'h0;
  else if(g_pich_end == 1'b1)
    g_udb_r  <= 7'h0;
  else if(g_udb0_wen_r == 1'b1 || g_udb1_wen_r == 1'b1 ||
    g_udb2_wen_r == 1'b1)
    g_udb_r  <= g_udb_d;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_udb_cpu_r  <= 7'h0;
  else if(g_pich_end == 1'b1)
    g_udb_cpu_r  <= g_udb_r;
  else if(g_hclr_r_s == 1'b1)
    g_udb_cpu_r  <= 7'h0;
  else if(g_cpu_we_s == 1'b1 && g_dmod_r == 1'b1 &&
    g_a_r      == P_CPU_A_VDUDBYT)
    g_udb_cpu_r  <= g_wd_r[6:0];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_adb_r  <= 7'h0;
  else if(g_pich_end == 1'b1)
    g_adb_r  <= 7'h0;
  else if(g_seqstrt_r == 1'b1 || g_gopstrt_r == 1'b1 ||
    g_picstrt_r == 1'b1)
    g_adb_r  <= 7'h0;
  else if(g_adb_r == P_MAX_AD_BYTE)
    g_adb_r  <= g_adb_r;
  else if(g_paramadr_r == P_VLD_A_ATSCD)
    g_adb_r  <= g_adb_r + 1'b1;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_adb_cpu_r  <= 7'h0;
  else if(g_pich_end == 1'b1)
    g_adb_cpu_r  <= g_adb_r;
  else if(g_hclr_r_s == 1'b1)
    g_adb_cpu_r  <= 7'h0;
  else if(g_cpu_we_s == 1'b1 && g_dmod_r == 1'b1 &&
    g_a_r      == P_CPU_A_VDADBYT)
    g_adb_cpu_r  <= g_wd_r[6:0];
end

always @(g_udb_d or g_usrd_r or g_paramdata_r) begin
  case(g_udb_d[1:0])
    2'b00:  g_usrd_d  = {                  g_paramdata_r[24:17],24'h0};
    2'b01:  g_usrd_d  = {g_usrd_r[31:24],g_paramdata_r[24:17],16'h0};
    2'b10:  g_usrd_d  = {g_usrd_r[31:16],g_paramdata_r[24:17],8'h0};
    default: g_usrd_d = {g_usrd_r[31:8], g_paramdata_r[24:17]};
  endcase
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_usrd_r  <= 24'h0;
  else if(g_paramadr_r == P_VLD_A_USRD0 ||
    g_paramadr_r == P_VLD_A_USRD1 ||
    g_paramadr_r == P_VLD_A_USRD2)
    g_usrd_r  <= g_usrd_d[31:8];
end

always @(g_adb_r or g_atscd_r or g_paramdata_r) begin
  case(g_adb_r[1:0])
    2'b00:  g_atscd_d  = {                 g_paramdata_r[24:17],24'h0};
    2'b01:  g_atscd_d  = {g_atscd_r[31:24],g_paramdata_r[24:17],16'h0};
    2'b10:  g_atscd_d  = {g_atscd_r[31:16],g_paramdata_r[24:17],8'h0};
    default: g_atscd_d = {g_atscd_r[31:8], g_paramdata_r[24:17]};
  endcase
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_atscd_r  <= 24'h0;
  else if(g_paramadr_r == P_VLD_A_ATSCD)
    g_atscd_r  <= g_atscd_d[31:8];
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0) begin
    v1_hdi00_bs  <= 1'b0;
    v1_hdi00_we  <= 1'b0;
    v1_hdi00_a  <= 6'h0;
    v1_hdi00_d  <= 32'h0;
  end
  else if(g_vld_memw == 1'b1) begin
    case(g_paramadr_r)
      P_VLD_A_CPYE0: begin
        v1_hdi00_bs  <= 1'b1;
        v1_hdi00_we  <= 1'b1;
        v1_hdi00_a  <= P_MEM_A_VDCPYE0;
        v1_hdi00_d  <= {15'h0,g_paramdata_r[24],
                 7'h0,g_paramdata_r[15],
                      g_paramdata_r[23:16]};
      end
      P_VLD_A_CPYE1: begin
        v1_hdi00_bs  <= 1'b1;
        v1_hdi00_we  <= 1'b1;
        v1_hdi00_a  <= P_MEM_A_VDCPYE1;
        v1_hdi00_d  <= {12'h0,g_paramdata_r[24:5]};
      end
      P_VLD_A_CPYE2: begin
        v1_hdi00_bs  <= 1'b1;
        v1_hdi00_we  <= 1'b1;
        v1_hdi00_a  <= P_MEM_A_VDCPYE2;
        v1_hdi00_d  <= {10'h0,g_paramdata_r[24:3]};
      end
      P_VLD_A_CPYE3: begin
        v1_hdi00_bs  <= 1'b1;
        v1_hdi00_we  <= 1'b1;
        v1_hdi00_a  <= P_MEM_A_VDCPYE3;
        v1_hdi00_d  <= {10'h0,g_paramdata_r[24:3]};
      end
      P_VLD_A_USRD0,
      P_VLD_A_USRD1,
      P_VLD_A_USRD2: begin
        if(g_udb_d == P_MAX_UD_BYTE) begin
            // Buffer Overflow
          v1_hdi00_bs  <= 1'b0;
          v1_hdi00_we  <= 1'b0;
          v1_hdi00_a  <= 6'h0;
          v1_hdi00_d  <= 32'h0;
        end
        else begin
          v1_hdi00_bs  <= 1'b1;
          v1_hdi00_we  <= 1'b1;
          v1_hdi00_a  <= {1'b1,g_udb_d[6:2]} + 1'b1;
          v1_hdi00_d  <= g_usrd_d;
        end
      end
      P_VLD_A_ATSCD: begin
        if(g_adb_r == P_MAX_AD_BYTE) begin
            // Buffer Overflow
          v1_hdi00_bs  <= 1'b0;
          v1_hdi00_we  <= 1'b0;
          v1_hdi00_a  <= 6'h0;
          v1_hdi00_d  <= 32'h0;
        end
        else begin
          v1_hdi00_bs  <= 1'b1;
          v1_hdi00_we  <= 1'b1;
          v1_hdi00_a  <= {1'b0,g_adb_r[6:2]} + 1'b1;
          v1_hdi00_d  <= g_atscd_d;
        end
      end
      default: begin
        v1_hdi00_bs  <= 1'b0;
        v1_hdi00_we  <= 1'b0;
        v1_hdi00_a  <= 6'h0;
        v1_hdi00_d  <= 32'h0;
      end
    endcase
  end
  else if(g_cpu_memr == 1'b1) begin
    v1_hdi00_bs  <= 1'b1;
    v1_hdi00_we  <= 1'b0;
    v1_hdi00_a  <= g_a_r[7:2];
    v1_hdi00_d  <= 32'h0;
  end
  else if(g_cpu_memw == 1'b1) begin
    v1_hdi00_bs  <= 1'b1;
    v1_hdi00_we  <= 1'b1;
    v1_hdi00_a  <= g_a_r[7:2];
    v1_hdi00_d  <= g_wd_r;
  end
  else begin
    v1_hdi00_bs  <= 1'b0;
    v1_hdi00_we  <= 1'b0;
    v1_hdi00_a  <= 6'h0;
    v1_hdi00_d  <= 32'h0;
  end
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_memr_ok_r  <= 1'b0;
  else if(g_cpu_memr == 1'b1 && g_vld_memw == 1'b0)
      // CPU Read
    g_memr_ok_r  <= 1'b1;
  else 
    g_memr_ok_r  <= 1'b0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0) begin
    g_rd_en_r  <= 1'b0;
    g_rd_en2_r  <= 1'b0;
  end
  else begin
    g_rd_en_r  <= v1_hdi00_bs & !v1_hdi00_we;
    g_rd_en2_r  <= g_rd_en_r;
  end
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    g_mem_rd2_r  <= 32'h0;
  else if(g_rd_en2_r == 1'b1)
    g_mem_rd2_r  <= g_mem_rd_r;
  else
    g_mem_rd2_r  <= 32'h0;
end

always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    v1_hpb_rd  <= 32'h0;
  else if(g_memr_ok_r == 1'b1 
)
    v1_hpb_rd  <= g_mem_rd2_r;
  else if(g_cpu_re_s == 1'b1) begin
    case(g_a_r)
      P_CPU_A_VDCNT0:  v1_hpb_rd <= { 7'h0, g_vden_r,
                   7'h0, g_pskp_r,
                   7'h0, g_init_vld_r_s,
                   7'h0,~g_swrst_r_n};
      P_CPU_A_VDCNT1:  v1_hpb_rd <= { 1'h0, g_hsdc_r,
                   1'h0, g_vsdc_r,
                   1'h0, g_hs60p_r,
                   1'h0, g_vs60p_r};
      P_CPU_A_VDCNT2:  v1_hpb_rd <= { 4'h0, g_pcut_r,
                              g_mbc_en_r,
                         3'h0, g_mbc_r};
      P_CPU_A_VDCNT3:  v1_hpb_rd <= {        g_fcyc_en_r,
                   13'h0, g_fcyc_r};
      P_CPU_A_VDMOD0:  v1_hpb_rd <= { 6'h0, g_amod_r,
                         g_mmod_r,
                               7'h0, g_pmod_r,
                   7'h0, g_dmod_r,
                   6'h0, g_bmod_r,
                               g_imod_r};
      P_CPU_A_VDSTS0:  v1_hpb_rd <= {15'h0, g_mpeg_r,
                  15'h0, g_vsts_r};
      P_CPU_A_VDSTS1:  v1_hpb_rd <= {       g_reffld_num1_r,
                         g_reffld_num2_r,
                          g_reffld_num3_r,
                         g_reffld_num4_r,
                                g_dspfld_num1_r,
                         g_dspfld_num2_r,
                         g_decfld_num1_r,
                         g_decfld_num2_r};
      P_CPU_A_VDICNT:  v1_hpb_rd <= {13'h0, g_icfp_r,
                         g_icfb_r,
                            g_icnf_r,
                   4'h0, g_icdc_r,
                         g_icuc_r,
                               g_icsw_r,
                               g_icsr_r,
                         5'h0, g_icpi_r,
                            g_icph_r,
                         g_icsh_r};
      P_CPU_A_VDISTS:  v1_hpb_rd <= {13'h0, g_isfp_r,
                         g_isfb_r,
                         g_isnf_r,
                          4'h0, g_isdc_r,
                         g_isuc_r,
                         g_issw_r,
                         g_issr_r,
                   5'h0, g_ispi_r,
                         g_isph_r,
                         g_issh_r};
      P_CPU_A_VDESTS0: v1_hpb_rd  <= {21'h0, g_fpst_r};
      P_CPU_A_VDESTS1: v1_hpb_rd  <= {21'h0, g_fbst_r};
      P_CPU_A_VDESTS2: v1_hpb_rd  <= { 7'h0, g_nfst_r};
      P_CPU_A_VDESTS3: v1_hpb_rd  <= {17'h0, g_embh_adr_r,
                   1'h0, g_embv_adr_r};
      P_CPU_A_VDDCNT:  v1_hpb_rd  <= {31'h0, g_dcnt_r};
      P_CPU_A_VDDSTS:  v1_hpb_rd  <= {31'h0, g_dsts_r};
      P_CPU_A_VDVSTS0:v1_hpb_rd  <= { 1'h0, g_mbh_adr_r,
                   1'h0, g_mbv_adr_r,
                         4'h0, g_vldstatus_r,
                               g_vldmstatus_r};
      P_CPU_A_VDSDFMA: v1_hpb_rd  <= {g_field_start_add_r,10'h0};
      P_CPU_A_VDSDFOS: v1_hpb_rd  <= {20'h0, g_field_offset_r};
      P_CPU_A_VDSDCOS: v1_hpb_rd  <= {20'h0, g_cbcr_offset_r};
      P_CPU_A_VDSDLOS: v1_hpb_rd  <= {31'h0, g_line_offset_r};
      P_CPU_A_VDHCLR:   v1_hpb_rd  <= {31'h0, g_hclr_r_s};
      P_CPU_A_VDHDET:   v1_hpb_rd  <= {19'h0, g_hdflag_r};
      P_CPU_A_VDSEQH0: v1_hpb_rd  <= { 4'h0, g_hsv_r,
                         4'h0, g_vsv_r};
      P_CPU_A_VDSEQH1: v1_hpb_rd  <= {       g_ari_r,
                   g_frc_r,
                         6'h0, g_brv_r};
      P_CPU_A_VDSEQH2: v1_hpb_rd  <= {15'h0, g_cpf_r,
                         6'h0, g_vbsv_r};
      P_CPU_A_VDSEQE:   v1_hpb_rd  <= { 7'h0, g_ps_r,
                         6'h0, g_cf_r,
                         7'h0, g_ld_r,
                               g_pali_r};
      P_CPU_A_VDSEQDE0: v1_hpb_rd  <= { 1'h0, g_vf_r,
                   3'h0, g_cd_r,
                   g_cp_r,
                   g_tc_r,
                   g_mc_r};
      P_CPU_A_VDSEQDE1: v1_hpb_rd  <= { 2'h0, g_dhs_r,
                   2'h0, g_dvs_r};
      P_CPU_A_VDGOPH:  v1_hpb_rd  <= { 3'h0, g_cg_r,
                         3'h0, g_bl_r,
                   g_tmc_r};
      P_CPU_A_VDPICH:  v1_hpb_rd  <= { 1'h0, g_pct_r,
                   2'h0, g_tr_r,
                   g_vd_r};
      P_CPU_A_VDPICCE0: v1_hpb_rd  <= { 6'h0, g_pis_r,
                   7'h0, g_tff_r,
                         7'h0, g_rff_r,
                   7'h0, g_pf_r};
      P_CPU_A_VDPICCE1: v1_hpb_rd  <= { 3'h0, g_cdf_r,
                   3'h0, g_va_r,
                         1'h0, g_fs_r,
                   3'h0, g_sc_r,
                   1'h0, g_ba_r,
                   g_scp_r};
      P_CPU_A_VDPICDE0: v1_hpb_rd  <= {30'h0, g_nfco_r};
      P_CPU_A_VDPICDE1: v1_hpb_rd  <= {       g_fcho0_r,
                   g_fcvo0_r};
      P_CPU_A_VDPICDE2: v1_hpb_rd  <= {       g_fcho1_r,
                   g_fcvo1_r};
      P_CPU_A_VDPICDE3: v1_hpb_rd  <= {       g_fcho2_r,
                   g_fcvo2_r};
      P_CPU_A_VDUDBYT: v1_hpb_rd  <= {25'h0, g_udb_cpu_r};
      P_CPU_A_VDADBYT: v1_hpb_rd  <= {25'h0, g_adb_cpu_r};
      default:   v1_hpb_rd  <= 32'h0;
    endcase
  end
  else
    v1_hpb_rd  <= 32'h0;
end


always @(posedge clkbus or negedge rstbus_x) begin
  if(rstbus_x == 1'b0)
    v1_hpb_wait_n  <= 1'b1;
  else if(g_cpu_memr == 1'b1 && g_vld_memw == 1'b1)
    v1_hpb_wait_n  <= 1'b0;
  else if(g_cpu_memr == 1'b1 && g_vld_memw == 1'b0 &&
    g_memr_ok_r == 1'b0)
    v1_hpb_wait_n  <= 1'b0;
  else if(g_memr_ok_r == 1'b1 // && vg1_sync_r == 1'b1
)
    v1_hpb_wait_n  <= 1'b1;
end


reg_hdiarray dchdi(
   .clkbus       (clkbus),
   .rstbus_x     (rstbus_x),
   .v1_hdi00_a   (v1_hdi00_a),
   .v1_hdi00_bs  (v1_hdi00_bs),
   .v1_hdi00_d   (v1_hdi00_d),
   .v1_hdi00_we  (v1_hdi00_we),
   .w1_hdi00_q   (w1_hdi00_q)
   );


endmodule


