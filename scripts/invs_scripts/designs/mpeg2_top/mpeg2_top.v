// ----------------------------------------------
// File: model_top.v
// Module: model_top
// Function:
// ----------------------------------------------

module mpeg2_top(
   //clkdec,
   //clkbus,
   clk,
   rstdec_x,
   rstbus_x,
   wbb_stb_i,
   wbb_we_i,
   wbb_adr_i,
   wbb_dat_i,
   wbb_dat_o,
   wbb_ack_o,
   v1_int18_n,
   v1_int23_n,
   v1_dmareq8_n,
   mr_dmaack8_n,
   sc_dmaack8_n,
   y1_bs_wait_n,
   v1_bs_req_n,
   v1_sd_pichead_s,
   y1_bs_data,
   v1_dspfld_num1,
   v1_dspfld_sc1,
   v1_dspfld_num2,
   v1_dspfld_sc2,
   v1_dsp_ps,
   vmem_wen,           
   vmem_we,           
   vmem_we_n,           
   vmem_ren,           
   vmem_add,           
   vmem_data_out,   
   vmem_data_in,
   v_mode_mpeg1,
   vmem_ch
);

//input             clkdec;
//input             clkbus;
input             clk;
input             rstdec_x;
input             rstbus_x;
input             wbb_stb_i;
input             wbb_we_i;
input  [8:2]      wbb_adr_i;
input  [31:0]     wbb_dat_i;
output [31:0]     wbb_dat_o;
output            wbb_ack_o;
output            v1_int18_n;
output            v1_int23_n;
output            v1_dmareq8_n;
input             mr_dmaack8_n;
input             sc_dmaack8_n;
input             y1_bs_wait_n;
output            v1_bs_req_n;
output            v1_sd_pichead_s;
input  [31:0]     y1_bs_data;
output [3:0]      v1_dspfld_num1;
output            v1_dspfld_sc1;
output [3:0]      v1_dspfld_num2;
output            v1_dspfld_sc2;
output            v1_dsp_ps;
output            vmem_wen;
output [3:0]      vmem_we;
output [3:0]      vmem_we_n;
output            vmem_ren;
output [25:0]     vmem_add;
output [31:0]     vmem_data_out;
input  [31:0]     vmem_data_in;
input             v_mode_mpeg1;
input             vmem_ch;
//wire            clkdec;
//wire            clkbus;
wire            clk;
wire            rstdec_x;
wire            rstbus_x;
wire            mb_hpb_ms2_n;
wire            mb_hpb_read_n;
wire            mb_hpb_write_n;
wire [8:2]      mb_hpb_a;
wire [31:0]     mb_hpb_wd;
wire [31:0]     v1_hpb_rd;
wire            v1_hpb_wait_n;
wire            v1_int18_n;
wire            v1_int23_n;
wire            v1_dmareq8_n;
wire            mr_dmaack8_n;
wire            sc_dmaack8_n;
wire            y1_bs_wait_n;
wire            v1_bs_req_n;
wire            v1_sd_pichead_s;
wire [31:0]     y1_bs_data;
wire [3:0]      v1_dspfld_num1;
wire            v1_dspfld_sc1;
wire [3:0]      v1_dspfld_num2;
wire            v1_dspfld_sc2;
wire            v1_dsp_ps;
wire            vh_1_ph_req;
wire            ph_vh_1_gnt;
wire [31:0]     vh_1_ph_add;
wire [31:0]     ph_vh_1_r_data;
wire            ph_vh_1_r_enable;
wire            vh_2_ph_req;
wire            ph_vh_2_gnt;
wire [31:0]     vh_2_ph_add;
wire [31:0]     vh_2_ph_data;
wire            ph_vh_1_r_en;

wire [11:0]     g_mbc_r;
wire            g_mbc_en_r;
wire [11:0]     g_pcut_r;
wire [6:0]      g_hs60p_r;
wire            g_pmod_r;
wire            g_bmod_r;
wire            g_pskp_r;
wire            g_swrst_r_n;
wire            g_vden_r;
wire [6:0]      g_vs60p_r;
wire            g_fcyc_en_r;
wire [17:0]     g_fcyc_r;
wire [2:0]      n_pic_codtyp_reffld1_r;
wire [2:0]      n_pic_codtyp_reffld2_r;
wire [2:0]      n_pic_codtyp_reffld3_r;
wire [2:0]      n_pic_codtyp_reffld4_r;
wire            v_ferror_r;
wire            v_mbadet_r;
wire [7:0]      v_paramadr_r;
wire [24:0]     v_paramdata_r;
wire            v_picstrt_r;
wire [7:0]      v_qmdata_r;
wire            v_qmseli_r;
wire            v_qmseln_r;
wire            v_qmsyni_r_n;
wire            v_qmsynn_r_n;
wire            v_seqstrt_r;
wire            v_slclverr_r;
wire            v_slicestart_r;
wire            p_hdtvh_r;
wire            c_alterscan_r;
wire            c_brklnk_r;
wire            c_crs_gop_r;
wire            c_dct_typ_r;
wire [1:0]      c_dmvh_r;
wire [1:0]      c_dmvv_r;
wire            c_fldpl_r_s;
wire            c_fldsel1_fix1_r;
wire            c_fldsel2_fix1_r;
wire            c_fldsel3_fix1_r;
wire            c_fldsel4_fix1_r;
wire            c_frmpl_r_s;
wire [11:0]     c_hsval_r;
wire            c_idlpl_r_s;
wire [1:0]      c_intradcp_r;
wire            c_mb_ferr_r;
wire [2:0]      c_mb_nferr_r;
wire [6:0]      c_mbh_adr_r;
wire            c_mbpl_buc_r_s;
wire            c_mbpl_dc_r_s;
wire            c_mbpl_idct_out_r_s;
wire            c_mbpl_idct_r_s;
wire            c_mbpl_iq_r_s;
wire            c_mbpl_mc_r_s;
wire            c_mbpl_mcalc_r_s;
wire            c_mbpl_psft_r_s;
wire            c_mbpl_skpmb_r_s;
wire            c_mbpl_uc_r_s;
wire            c_mbpl_vld_r_s;
wire            c_mbtyp_0_r;
wire [6:0]      c_mbv_adr_r;
wire            c_pcpl_r_s;
wire            c_pcpl_tend_r_s;
wire            c_pred_backward_r;
wire            c_pred_forward_r;
wire [7:0]      c_qmdata_r;
wire            c_qmintra_r;
wire            c_qmseln_r;
wire            c_qmsynn_r_n;
wire [6:0]      c_qscale_r;
wire            c_skippic_r_s;
wire            c_skipslc_r_s;
wire            c_tmg_ferr_hit_r;
wire [11:0]     c_vsval_r;
wire            c_bfcnt_init_r;
wire [1:0]      c_auto_rpt_md_r;
wire            c_ccl_r;
wire            c_lwdly_r;
wire            c_mpg1_r;
wire [6:0]      c_pcth_mb_r;
wire [6:0]      c_pctv_mb_r;
wire [2:0]      c_pic_codtyp_r;
wire            c_prgseq_r;
wire [1:0]      c_pstr_r;
wire            c_rfstfld_r;
wire            c_shdet_r;
wire            c_skpmb_r;
wire            c_tfst_r;
wire            c_pskp_end_r_s;
wire            c_first_proc_r;
wire            p_dct_typ_mc_r;
wire [1:0]      p_dmvh_buc_r;
wire [1:0]      p_dmvv_buc_r;
wire [12:0]     p_fstbwdvech_buc_r;
wire [8:0]      p_fstbwdvecv_buc_r;
wire [12:0]     p_fstfwdvech_buc_r;
wire [8:0]      p_fstfwdvecv_buc_r;
wire            p_idct_dis_mc_r;
wire            p_mbtyp_0_buc_r;
wire [1:0]      p_mttyp_buc_r;
wire            p_pred_backward_buc_r;
wire            p_pred_forward_buc_r;
wire            p_prgseq_buc_r;
wire [1:0]      p_pstr_buc_r;
wire [12:0]     p_sndbwdvech_buc_r;
wire [8:0]      p_sndbwdvecv_buc_r;
wire [12:0]     p_sndfwdvech_buc_r;
wire [8:0]      p_sndfwdvecv_buc_r;
wire            p_tfst_buc_r;
wire [8:0]      t_idcto_r;
wire            u_ref1cen_r;
wire [15:0]     u_ref1dt_r;
wire            u_ref1yen_r;
wire            u_ref2cen_r;
wire [15:0]     u_ref2dt_r;
wire            u_ref2yen_r;
wire            m_deccen_r;
wire [15:0]     m_decdt_r;
wire            m_decyen_r;
wire [10:0]     m_hvec1c_r;
wire [11:0]     m_hvec1y_r;
wire [10:0]     m_hvec2c_r;
wire [11:0]     m_hvec2y_r;
wire [10:0]     m_hvec3c_r;
wire [11:0]     m_hvec3y_r;
wire [10:0]     m_hvec4c_r;
wire [11:0]     m_hvec4y_r;
wire [6:0]      m_vvec1c_r;
wire [7:0]      m_vvec1y_r;
wire [6:0]      m_vvec2c_r;
wire [7:0]      m_vvec2y_r;
wire [6:0]      m_vvec3c_r;
wire [7:0]      m_vvec3y_r;
wire [6:0]      m_vvec4c_r;
wire [7:0]      m_vvec4y_r;
wire            f_hdtvh_r;
wire [2:0]      f_hvec1c_r;
wire [3:0]      f_hvec1y_r;
wire [2:0]      f_hvec2c_r;
wire [3:0]      f_hvec2y_r;
wire [2:0]      f_hvec3c_r;
wire [3:0]      f_hvec3y_r;
wire [2:0]      f_hvec4c_r;
wire [3:0]      f_hvec4y_r;
wire [1:0]      f_mttyp_r;
wire            f_pred_backward_buc_r;
wire            f_pred_forward_buc_r;
wire            f_prgseq_r;
wire            f_ref1cen_r;
wire [63:0]     f_ref1dt_r;
wire            f_ref1yen_r;
wire            f_ref2cen_r;
wire [63:0]     f_ref2dt_r;
wire            f_ref2yen_r;
wire [1:0]      f_vvec1c_r;
wire [2:0]      f_vvec1y_r;
wire [1:0]      f_vvec2c_r;
wire [2:0]      f_vvec2y_r;
wire [1:0]      f_vvec3c_r;
wire [2:0]      f_vvec3y_r;
wire [1:0]      f_vvec4c_r;
wire [2:0]      f_vvec4y_r;
wire            p_hdtvh_dc_r;
wire            d_decv_cen_r;
wire [15:0]     d_decv_dt_r;
wire            d_decv_yen_r;
wire            p_fldsel1_buc_r;
wire            p_fldsel2_buc_r;
wire            p_fldsel3_buc_r;
wire            p_fldsel4_buc_r;
wire            p_hdtvh_buc_r;
wire [6:0]      p_mbh_adr_buc_r;
wire [6:0]      p_mbv_adr_buc_r;
wire [3:0]      p_reffld_num1_buc_r;
wire [3:0]      p_reffld_num2_buc_r;
wire [3:0]      p_reffld_num3_buc_r;
wire [3:0]      p_reffld_num4_buc_r;
wire            vrh_acceptance_r;
wire [63:0]     vrh_read_data_r;
wire [10:0]     f_addressx_r;
wire [9:0]      f_addressy_r;
wire            f_bfud_err_r;
wire [1:0]      f_byte_num_r;
wire [3:0]      f_field_num_r;
wire [2:0]      f_line_num_r;
wire            f_request_r;
wire            f_vec_err_r;
wire [3:0]      n_decfld_num1_r;
wire [3:0]      n_decfld_num2_r;
wire [6:0]      p_mbh_adr_dc_r;
wire [6:0]      p_mbv_adr_dc_r;
wire            p_prgseq_dc_r;
wire [1:0]      p_pstr_dc_r;
wire            vwh_acceptance_r;
wire            vwh_data_wait;
wire [7:0]      b_addressx_r;
wire [8:0]      b_addressy_r;
wire            b_bfov_err_r;
wire [1:0]      b_byte_num_r;
wire [3:0]      b_field_num_r;
wire [2:0]      b_line_num_r;
wire            b_request_r;
wire [63:0]     b_write_data;
wire            b_write_enable_r;
wire [12:0]     v_fstfwdvech_r;
wire [8:0]      v_fstfwdvecv_r;
wire [12:0]     v_fstbwdvech_r;
wire [8:0]      v_fstbwdvecv_r;
wire [12:0]     v_sndfwdvech_r;
wire [8:0]      v_sndfwdvecv_r;
wire [12:0]     v_sndbwdvech_r;
wire [8:0]      v_sndbwdvecv_r;
wire [3:0]      n_reffld_num1_r;
wire [3:0]      n_reffld_num2_r;
wire [3:0]      n_reffld_num3_r;
wire [3:0]      n_reffld_num4_r;
wire [6:0]      g_hsdc_r;
wire [6:0]      g_vsdc_r;
wire [1:0]      v_motion_type_r;
wire            p_shdet_iq_r;
wire            p_mbtyp_0_iq_r;
wire            p_mpg1_iq_r;
wire [1:0]      p_intradcp_iq_r;
wire            p_alterscan_iq_r;
wire [6:0]      p_qscale_iq_r;
wire            v_vdoen_r;
wire [11:0]     v_vdo_r;
wire [7:0]      v_vldstatus_r;
wire [3:0]      v_vldmstatus_r;
wire            v_sqxstrt_r;
wire            v_sdxstrt_r;
wire            v_ud0strt_r;
wire            v_gopstrt_r;
wire            v_ud1strt_r;
wire            v_pcxstrt_r;
wire            v_qmxstrt_r;
wire            v_cpxstrt_r;
wire            v_pdxstrt_r;
wire            v_ud2strt_r;
wire            v_atscdet_r;
wire            v_vscdet_ferror_r;
wire            v_nferror_r;
wire            v_sferror_r;
wire            g_init_vld_r_s;
wire [1:0]      g_vldmode_r;
wire            q_blkstp_r_s;
wire [11:0]     q_do_r;
wire [31:10]    g_field_start_add_r;
wire [11:0]     g_field_offset_r;
wire [11:0]     g_cbcr_offset_r;
wire            g_line_offset_r;
wire            g_vsts_r;
wire            g_pini_r;
wire            g_chg_slp_r;

wire [31:0]     wbb_dat_o;
wire            wbb_ack_o;
wire [31:0]     y1_bs_data_r;

assign  mb_hpb_ms2_n    = wbb_stb_i;
assign  mb_hpb_read_n   = wbb_we_i;
assign  mb_hpb_write_n  = wbb_we_i;
assign  mb_hpb_a        = wbb_adr_i;
assign  mb_hpb_wd       = wbb_dat_i;
assign  wbb_dat_o       = v1_hpb_rd;
assign  wbb_ack_o       = v1_hpb_wait_n;


cntrltop cntrltop(
  .clkdec                       (clk),
  .rstdec_x                     (rstdec_x),
  .g_mbc_r                      (g_mbc_r),
  .g_mbc_en_r                   (g_mbc_en_r),
  .g_pcut_r                     (g_pcut_r),
  .g_hs60p_r                    (g_hs60p_r),
  .g_pmod_r                     (g_pmod_r),
  .g_pskp_r                     (g_pskp_r),
  .g_swrst_r_n                  (g_swrst_r_n),
  .g_vden_r                     (g_vden_r),
  .g_vs60p_r                    (g_vs60p_r),
  .g_fcyc_en_r                  (g_fcyc_en_r),
  .g_fcyc_r                     (g_fcyc_r),
  .n_pic_codtyp_reffld1_r       (n_pic_codtyp_reffld1_r),
  .n_pic_codtyp_reffld2_r       (n_pic_codtyp_reffld2_r),
  .n_pic_codtyp_reffld3_r       (n_pic_codtyp_reffld3_r),
  .n_pic_codtyp_reffld4_r       (n_pic_codtyp_reffld4_r),
  .v_ferror_r                   (v_ferror_r),
  .v_mbadet_r                   (v_mbadet_r),
  .v_paramadr_r                 (v_paramadr_r),
  .v_paramdata_r                (v_paramdata_r[24:1]),
  .v_picstrt_r                  (v_picstrt_r),
  .v_qmdata_r                   (v_qmdata_r),
  .v_qmseli_r                   (v_qmseli_r),
  .v_qmseln_r                   (v_qmseln_r),
  .v_qmsyni_r_n                 (v_qmsyni_r_n),
  .v_qmsynn_r_n                 (v_qmsynn_r_n),
  .v_seqstrt_r                  (v_seqstrt_r),
  .v_slclverr_r                 (v_slclverr_r),
  .v_slicestart_r               (v_slicestart_r),
  .p_hdtvh_r                    (p_hdtvh_r),
  .c_alterscan_r                (c_alterscan_r),
  .c_brklnk_r                   (c_brklnk_r),
  .c_crs_gop_r                  (c_crs_gop_r),
  .c_dct_typ_r                  (c_dct_typ_r),
  .c_dmvh_r                     (c_dmvh_r),
  .c_dmvv_r                     (c_dmvv_r),
  .c_fldpl_r_s                  (c_fldpl_r_s),
  .c_fldsel1_fix1_r             (c_fldsel1_fix1_r),
  .c_fldsel2_fix1_r             (c_fldsel2_fix1_r),
  .c_fldsel3_fix1_r             (c_fldsel3_fix1_r),
  .c_fldsel4_fix1_r             (c_fldsel4_fix1_r),
  .c_frmpl_r_s                  (c_frmpl_r_s),
  .c_hsval_r                    (c_hsval_r),
  .c_idlpl_r_s                  (c_idlpl_r_s),
  .c_intradcp_r                 (c_intradcp_r),
  .c_mb_ferr_r                  (c_mb_ferr_r),
  .c_mb_nferr_r                 (c_mb_nferr_r),
  .c_mbh_adr_r                  (c_mbh_adr_r),
  .c_mbpl_buc_r_s               (c_mbpl_buc_r_s),
  .c_mbpl_dc_r_s                (c_mbpl_dc_r_s),
  .c_mbpl_idct_out_r_s          (c_mbpl_idct_out_r_s),
  .c_mbpl_idct_r_s              (c_mbpl_idct_r_s),
  .c_mbpl_iq_r_s                (c_mbpl_iq_r_s),
  .c_mbpl_mc_r_s                (c_mbpl_mc_r_s),
  .c_mbpl_mcalc_r_s             (c_mbpl_mcalc_r_s),
  .c_mbpl_psft_r_s              (c_mbpl_psft_r_s),
  .c_mbpl_skpmb_r_s             (c_mbpl_skpmb_r_s),
  .c_mbpl_uc_r_s                (c_mbpl_uc_r_s),
  .c_mbpl_vld_r_s               (c_mbpl_vld_r_s),
  .c_mbtyp_0_r                  (c_mbtyp_0_r),
  .c_mbv_adr_r                  (c_mbv_adr_r),
  .c_pcpl_r_s                   (c_pcpl_r_s),
  .c_pcpl_tend_r_s              (c_pcpl_tend_r_s),
  .c_pred_backward_r            (c_pred_backward_r),
  .c_pred_forward_r             (c_pred_forward_r),
  .c_qmdata_r                   (c_qmdata_r),
  .c_qmintra_r                  (c_qmintra_r),
  .c_qmseln_r                   (c_qmseln_r),
  .c_qmsynn_r_n                 (c_qmsynn_r_n),
  .c_qscale_r                   (c_qscale_r),
  .c_skippic_r_s                (c_skippic_r_s),
  .c_skipslc_r_s                (c_skipslc_r_s),
  .c_tmg_ferr_hit_r             (c_tmg_ferr_hit_r),
  .c_vsval_r                    (c_vsval_r),
  .c_bfcnt_init_r               (c_bfcnt_init_r),
  .c_auto_rpt_md_r              (c_auto_rpt_md_r),
  .c_ccl_r                      (c_ccl_r),
  .c_lwdly_r                    (c_lwdly_r),
  .c_mpg1_r                     (c_mpg1_r),
  .c_pcth_mb_r                  (c_pcth_mb_r),
  .c_pctv_mb_r                  (c_pctv_mb_r),
  .c_pic_codtyp_r               (c_pic_codtyp_r),
  .c_prgseq_r                   (c_prgseq_r),
  .c_pstr_r                     (c_pstr_r),
  .c_rfstfld_r                  (c_rfstfld_r),
  .c_shdet_r                    (c_shdet_r),
  .c_skpmb_r                    (c_skpmb_r),
  .c_tfst_r                     (c_tfst_r),
  .c_pskp_end_r_s               (c_pskp_end_r_s),
  .c_first_proc_r               (c_first_proc_r),
  .v1_sd_pichead_s              (v1_sd_pichead_s),
  .v_mode_mpeg1                 (v_mode_mpeg1)
);

mctop mctop(
  .clkdec                       (clk),
  .rstdec_x                     (rstdec_x),
  .c_mbpl_dc_r_s                (c_mbpl_dc_r_s),
  .c_mbpl_idct_out_r_s          (c_mbpl_idct_out_r_s),
  .c_mbpl_mc_r_s                (c_mbpl_mc_r_s),
  .c_mbpl_mcalc_r_s             (c_mbpl_mcalc_r_s),
  .c_mbpl_psft_r_s              (c_mbpl_psft_r_s),
  .c_mbpl_uc_r_s                (c_mbpl_uc_r_s),
  .p_dct_typ_mc_r               (p_dct_typ_mc_r),
  .p_dmvh_buc_r                 (p_dmvh_buc_r),
  .p_dmvv_buc_r                 (p_dmvv_buc_r),
  .p_fstbwdvech_buc_r           (p_fstbwdvech_buc_r),
  .p_fstbwdvecv_buc_r           (p_fstbwdvecv_buc_r),
  .p_fstfwdvech_buc_r           (p_fstfwdvech_buc_r),
  .p_fstfwdvecv_buc_r           (p_fstfwdvecv_buc_r),
  .p_idct_dis_mc_r              (p_idct_dis_mc_r),
  .p_mbtyp_0_buc_r              (p_mbtyp_0_buc_r),
  .p_mttyp_buc_r                (p_mttyp_buc_r),
  .p_pred_backward_buc_r        (p_pred_backward_buc_r),
  .p_pred_forward_buc_r         (p_pred_forward_buc_r),
  .p_prgseq_buc_r               (p_prgseq_buc_r),
  .p_pstr_buc_r                 (p_pstr_buc_r),
  .p_sndbwdvech_buc_r           (p_sndbwdvech_buc_r),
  .p_sndbwdvecv_buc_r           (p_sndbwdvecv_buc_r),
  .p_sndfwdvech_buc_r           (p_sndfwdvech_buc_r),
  .p_sndfwdvecv_buc_r           (p_sndfwdvecv_buc_r),
  .p_tfst_buc_r                 (p_tfst_buc_r),
  .t_idcto_r                    (t_idcto_r),
  .u_ref1cen_r                  (u_ref1cen_r),
  .u_ref1dt_r                   (u_ref1dt_r),
  .u_ref1yen_r                  (u_ref1yen_r),
  .u_ref2cen_r                  (u_ref2cen_r),
  .u_ref2dt_r                   (u_ref2dt_r),
  .u_ref2yen_r                  (u_ref2yen_r),
  .m_deccen_r                   (m_deccen_r),
  .m_decdt_r                    (m_decdt_r),
  .m_decyen_r                   (m_decyen_r),
  .m_hvec1c_r                   (m_hvec1c_r),
  .m_hvec1y_r                   (m_hvec1y_r),
  .m_hvec2c_r                   (m_hvec2c_r),
  .m_hvec2y_r                   (m_hvec2y_r),
  .m_hvec3c_r                   (m_hvec3c_r),
  .m_hvec3y_r                   (m_hvec3y_r),
  .m_hvec4c_r                   (m_hvec4c_r),
  .m_hvec4y_r                   (m_hvec4y_r),
  .m_vvec1c_r                   (m_vvec1c_r),
  .m_vvec1y_r                   (m_vvec1y_r),
  .m_vvec2c_r                   (m_vvec2c_r),
  .m_vvec2y_r                   (m_vvec2y_r),
  .m_vvec3c_r                   (m_vvec3c_r),
  .m_vvec3y_r                   (m_vvec3y_r),
  .m_vvec4c_r                   (m_vvec4c_r),
  .m_vvec4y_r                   (m_vvec4y_r)
);

uctop uctop(
  .clkdec                       (clk),
  .rstdec_x                     (rstdec_x),
  .c_mbpl_uc_r_s                (c_mbpl_uc_r_s),
  .f_hdtvh_r                    (f_hdtvh_r),
  .f_hvec1c_r                   (f_hvec1c_r),
  .f_hvec1y_r                   (f_hvec1y_r),
  .f_hvec2c_r                   (f_hvec2c_r),
  .f_hvec2y_r                   (f_hvec2y_r),
  .f_hvec3c_r                   (f_hvec3c_r),
  .f_hvec3y_r                   (f_hvec3y_r),
  .f_hvec4c_r                   (f_hvec4c_r),
  .f_hvec4y_r                   (f_hvec4y_r),
  .f_mttyp_r                    (f_mttyp_r),
  .f_pred_backward_buc_r        (f_pred_backward_buc_r),
  .f_pred_forward_buc_r         (f_pred_forward_buc_r),
  .f_prgseq_r                   (f_prgseq_r),
  .f_ref1cen_r                  (f_ref1cen_r),
  .f_ref1dt_r                   (f_ref1dt_r),
  .f_ref1yen_r                  (f_ref1yen_r),
  .f_ref2cen_r                  (f_ref2cen_r),
  .f_ref2dt_r                   (f_ref2dt_r),
  .f_ref2yen_r                  (f_ref2yen_r),
  .f_vvec1c_r                   (f_vvec1c_r),
  .f_vvec1y_r                   (f_vvec1y_r),
  .f_vvec2c_r                   (f_vvec2c_r),
  .f_vvec2y_r                   (f_vvec2y_r),
  .f_vvec3c_r                   (f_vvec3c_r),
  .f_vvec3y_r                   (f_vvec3y_r),
  .f_vvec4c_r                   (f_vvec4c_r),
  .f_vvec4y_r                   (f_vvec4y_r),
  .u_ref1cen_r                  (u_ref1cen_r),
  .u_ref1dt_r                   (u_ref1dt_r),
  .u_ref1yen_r                  (u_ref1yen_r),
  .u_ref2cen_r                  (u_ref2cen_r),
  .u_ref2dt_r                   (u_ref2dt_r),
  .u_ref2yen_r                  (u_ref2yen_r)
);

dctop dctop(
  .clkdec                       (clk),
  .rstdec_x                     (rstdec_x),
  .c_mbpl_dc_r_s                (c_mbpl_dc_r_s),
  .m_deccen_r                   (m_deccen_r),
  .m_decdt_r                    (m_decdt_r),
  .m_decyen_r                   (m_decyen_r),
  .p_hdtvh_dc_r                 (p_hdtvh_dc_r),
  .d_decv_cen_r                 (d_decv_cen_r),
  .d_decv_dt_r                  (d_decv_dt_r),
  .d_decv_yen_r                 (d_decv_yen_r)
);

buctop buctop(
  .clkdec                       (clk),
  .rstdec_x                     (rstdec_x),
  .c_bfcnt_init_r               (c_bfcnt_init_r),
  .c_mbpl_buc_r_s               (c_mbpl_buc_r_s),
  .c_mbpl_uc_r_s                (c_mbpl_uc_r_s),
  .m_hvec1c_r                   (m_hvec1c_r),
  .m_hvec1y_r                   (m_hvec1y_r),
  .m_hvec2c_r                   (m_hvec2c_r),
  .m_hvec2y_r                   (m_hvec2y_r),
  .m_hvec3c_r                   (m_hvec3c_r),
  .m_hvec3y_r                   (m_hvec3y_r),
  .m_hvec4c_r                   (m_hvec4c_r),
  .m_hvec4y_r                   (m_hvec4y_r),
  .m_vvec1c_r                   (m_vvec1c_r),
  .m_vvec1y_r                   (m_vvec1y_r),
  .m_vvec2c_r                   (m_vvec2c_r),
  .m_vvec2y_r                   (m_vvec2y_r),
  .m_vvec3c_r                   (m_vvec3c_r),
  .m_vvec3y_r                   (m_vvec3y_r),
  .m_vvec4c_r                   (m_vvec4c_r),
  .m_vvec4y_r                   (m_vvec4y_r),
  .c_pcth_mb_r                  (c_pcth_mb_r),
  .c_pctv_mb_r                  (c_pctv_mb_r),
  .p_fldsel1_buc_r              (p_fldsel1_buc_r),
  .p_fldsel2_buc_r              (p_fldsel2_buc_r),
  .p_fldsel3_buc_r              (p_fldsel3_buc_r),
  .p_fldsel4_buc_r              (p_fldsel4_buc_r),
  .p_hdtvh_buc_r                (p_hdtvh_buc_r),
  .p_mbh_adr_buc_r              (p_mbh_adr_buc_r),
  .p_mbv_adr_buc_r              (p_mbv_adr_buc_r),
  .p_mttyp_buc_r                (p_mttyp_buc_r),
  .p_pred_backward_buc_r        (p_pred_backward_buc_r),
  .p_pred_forward_buc_r         (p_pred_forward_buc_r),
  .p_prgseq_buc_r               (p_prgseq_buc_r),
  .p_pstr_buc_r                 (p_pstr_buc_r),
  .p_reffld_num1_buc_r          (p_reffld_num1_buc_r),
  .p_reffld_num2_buc_r          (p_reffld_num2_buc_r),
  .p_reffld_num3_buc_r          (p_reffld_num3_buc_r),
  .p_reffld_num4_buc_r          (p_reffld_num4_buc_r),
  .vrh_acceptance_r             (vrh_acceptance_r),
  .vrh_read_data_r              (vrh_read_data_r),
  .vrh_read_enable_r            (ph_vh_1_r_en),
  .f_addressx_r                 (f_addressx_r),
  .f_addressy_r                 (f_addressy_r),
  .f_bfud_err_r                 (f_bfud_err_r),
  .f_byte_num_r                 (f_byte_num_r),
  .f_field_num_r                (f_field_num_r),
  .f_hdtvh_r                    (f_hdtvh_r),
  .f_hvec1c_r                   (f_hvec1c_r),
  .f_hvec1y_r                   (f_hvec1y_r),
  .f_hvec2c_r                   (f_hvec2c_r),
  .f_hvec2y_r                   (f_hvec2y_r),
  .f_hvec3c_r                   (f_hvec3c_r),
  .f_hvec3y_r                   (f_hvec3y_r),
  .f_hvec4c_r                   (f_hvec4c_r),
  .f_hvec4y_r                   (f_hvec4y_r),
  .f_line_num_r                 (f_line_num_r),
  .f_mttyp_r                    (f_mttyp_r),
  .f_pred_backward_buc_r        (f_pred_backward_buc_r),
  .f_pred_forward_buc_r         (f_pred_forward_buc_r),
  .f_prgseq_r                   (f_prgseq_r),
  .f_ref1cen_r                  (f_ref1cen_r),
  .f_ref1dt_r                   (f_ref1dt_r),
  .f_ref1yen_r                  (f_ref1yen_r),
  .f_ref2cen_r                  (f_ref2cen_r),
  .f_ref2dt_r                   (f_ref2dt_r),
  .f_ref2yen_r                  (f_ref2yen_r),
  .f_request_r                  (f_request_r),
  .f_vec_err_r                  (f_vec_err_r),
  .f_vvec1c_r                   (f_vvec1c_r),
  .f_vvec1y_r                   (f_vvec1y_r),
  .f_vvec2c_r                   (f_vvec2c_r),
  .f_vvec2y_r                   (f_vvec2y_r),
  .f_vvec3c_r                   (f_vvec3c_r),
  .f_vvec3y_r                   (f_vvec3y_r),
  .f_vvec4c_r                   (f_vvec4c_r),
  .f_vvec4y_r                   (f_vvec4y_r)
);

bdctop bdctop(
  .clkdec                       (clk),
  .rstdec_x                     (rstdec_x),
  .c_bfcnt_init_r               (c_bfcnt_init_r),
  .c_mbpl_dc_r_s                (c_mbpl_dc_r_s),
  .d_decv_cen_r                 (d_decv_cen_r),
  .d_decv_dt_r                  (d_decv_dt_r),
  .d_decv_yen_r                 (d_decv_yen_r),
  .n_decfld_num1_r              (n_decfld_num1_r),
  .n_decfld_num2_r              (n_decfld_num2_r),
  .p_hdtvh_dc_r                 (p_hdtvh_dc_r),
  .p_mbh_adr_dc_r               (p_mbh_adr_dc_r),
  .p_mbv_adr_dc_r               (p_mbv_adr_dc_r),
  .p_prgseq_dc_r                (p_prgseq_dc_r),
  .p_pstr_dc_r                  (p_pstr_dc_r),
  .vwh_acceptance_r             (vwh_acceptance_r),
  .vwh_data_wait                (vwh_data_wait),
  .b_addressx_r                 (b_addressx_r),
  .b_addressy_r                 (b_addressy_r),
  .b_bfov_err_r                 (b_bfov_err_r),
  .b_byte_num_r                 (b_byte_num_r),
  .b_field_num_r                (b_field_num_r),
  .b_line_num_r                 (b_line_num_r),
  .b_request_r                  (b_request_r),
  .b_write_data                 (b_write_data),
  .b_write_enable_r             (b_write_enable_r)
);

pbuftop pbuftop(
  .clkdec                       (clk),
  .rstdec_x                     (rstdec_x),
  .v_fstfwdvech_r               (v_fstfwdvech_r),
  .v_fstfwdvecv_r               (v_fstfwdvecv_r),
  .v_fstbwdvech_r               (v_fstbwdvech_r),
  .v_fstbwdvecv_r               (v_fstbwdvecv_r),
  .v_sndfwdvech_r               (v_sndfwdvech_r),
  .v_sndfwdvecv_r               (v_sndfwdvecv_r),
  .v_sndbwdvech_r               (v_sndbwdvech_r),
  .v_sndbwdvecv_r               (v_sndbwdvecv_r),
  .c_mbpl_psft_r_s              (c_mbpl_psft_r_s),
  .c_ccl_r                      (c_ccl_r),
  .c_pred_forward_r             (c_pred_forward_r),
  .c_pred_backward_r            (c_pred_backward_r),
  .c_mbtyp_0_r                  (c_mbtyp_0_r),
  .c_pstr_r                     (c_pstr_r),
  .c_fldsel1_fix1_r             (c_fldsel1_fix1_r),
  .c_fldsel2_fix1_r             (c_fldsel2_fix1_r),
  .c_fldsel3_fix1_r             (c_fldsel3_fix1_r),
  .c_fldsel4_fix1_r             (c_fldsel4_fix1_r),
  .c_hsval_r                    (c_hsval_r),
  .c_vsval_r                    (c_vsval_r),
  .c_mpg1_r                     (c_mpg1_r),
  .c_prgseq_r                   (c_prgseq_r),
  .c_mbh_adr_r                  (c_mbh_adr_r),
  .c_mbv_adr_r                  (c_mbv_adr_r),
  .c_dct_typ_r                  (c_dct_typ_r),
  .c_dmvh_r                     (c_dmvh_r),
  .c_dmvv_r                     (c_dmvv_r),
  .c_tfst_r                     (c_tfst_r),
  .c_shdet_r                    (c_shdet_r),
  .c_alterscan_r                (c_alterscan_r),
  .c_intradcp_r                 (c_intradcp_r),
  .n_reffld_num1_r              (n_reffld_num1_r),
  .n_reffld_num2_r              (n_reffld_num2_r),
  .n_reffld_num3_r              (n_reffld_num3_r),
  .n_reffld_num4_r              (n_reffld_num4_r),
  .c_skpmb_r                    (c_skpmb_r),
  .g_hsdc_r                     (g_hsdc_r),
  .g_vsdc_r                     (g_vsdc_r),
  .c_qscale_r                   (c_qscale_r),
  .n_pic_codtyp_reffld1_r       (n_pic_codtyp_reffld1_r),
  .n_pic_codtyp_reffld2_r       (n_pic_codtyp_reffld2_r),
  .n_pic_codtyp_reffld3_r       (n_pic_codtyp_reffld3_r),
  .n_pic_codtyp_reffld4_r       (n_pic_codtyp_reffld4_r),
  .c_pic_codtyp_r               (c_pic_codtyp_r),
  .v_motion_type_r              (v_motion_type_r),
  .c_mbpl_idct_out_r_s          (c_mbpl_idct_out_r_s), 
  .c_mbpl_mc_r_s                (c_mbpl_mc_r_s),       
  .c_mbpl_dc_r_s                (c_mbpl_dc_r_s),       
  .c_mbpl_iq_r_s                (c_mbpl_iq_r_s),       
  .p_shdet_iq_r                 (p_shdet_iq_r),
  .p_hdtvh_buc_r                (p_hdtvh_buc_r),
  .p_hdtvh_dc_r                 (p_hdtvh_dc_r),
  .p_prgseq_buc_r               (p_prgseq_buc_r),
  .p_prgseq_dc_r                (p_prgseq_dc_r),
  .p_pstr_buc_r                 (p_pstr_buc_r),
  .p_pstr_dc_r                  (p_pstr_dc_r),
  .p_pred_forward_buc_r         (p_pred_forward_buc_r),
  .p_pred_backward_buc_r        (p_pred_backward_buc_r),
  .p_mbtyp_0_iq_r               (p_mbtyp_0_iq_r),
  .p_mbtyp_0_buc_r              (p_mbtyp_0_buc_r),
  .p_mttyp_buc_r                (p_mttyp_buc_r),
  .p_mbh_adr_buc_r              (p_mbh_adr_buc_r),
  .p_mbv_adr_buc_r              (p_mbv_adr_buc_r),
  .p_mbh_adr_dc_r               (p_mbh_adr_dc_r),
  .p_mbv_adr_dc_r               (p_mbv_adr_dc_r),
  .p_dct_typ_mc_r               (p_dct_typ_mc_r),
  .p_fstfwdvech_buc_r           (p_fstfwdvech_buc_r),
  .p_fstfwdvecv_buc_r           (p_fstfwdvecv_buc_r),
  .p_fstbwdvech_buc_r           (p_fstbwdvech_buc_r),
  .p_fstbwdvecv_buc_r           (p_fstbwdvecv_buc_r),
  .p_sndfwdvech_buc_r           (p_sndfwdvech_buc_r),
  .p_sndfwdvecv_buc_r           (p_sndfwdvecv_buc_r),
  .p_sndbwdvech_buc_r           (p_sndbwdvech_buc_r),
  .p_sndbwdvecv_buc_r           (p_sndbwdvecv_buc_r),
  .p_fldsel1_buc_r              (p_fldsel1_buc_r),
  .p_fldsel2_buc_r              (p_fldsel2_buc_r),
  .p_fldsel3_buc_r              (p_fldsel3_buc_r),
  .p_fldsel4_buc_r              (p_fldsel4_buc_r),
  .p_dmvh_buc_r                 (p_dmvh_buc_r),
  .p_dmvv_buc_r                 (p_dmvv_buc_r),
  .p_tfst_buc_r                 (p_tfst_buc_r),
  .p_idct_dis_mc_r              (p_idct_dis_mc_r),
  .p_mpg1_iq_r                  (p_mpg1_iq_r),
  .p_intradcp_iq_r              (p_intradcp_iq_r),
  .p_alterscan_iq_r             (p_alterscan_iq_r),
  .p_reffld_num1_buc_r          (p_reffld_num1_buc_r),
  .p_reffld_num2_buc_r          (p_reffld_num2_buc_r),
  .p_reffld_num3_buc_r          (p_reffld_num3_buc_r),
  .p_reffld_num4_buc_r          (p_reffld_num4_buc_r),
  .p_qscale_iq_r                (p_qscale_iq_r),
  .p_hdtvh_r                    (p_hdtvh_r)
);

vldtop vldtop(
  .v_paramadr_r                 (v_paramadr_r),
  .v_paramdata_r                (v_paramdata_r),
  .v_vdoen_r                    (v_vdoen_r),
  .v_vdo_r                      (v_vdo_r),
  .v_vldstatus_r                (v_vldstatus_r),
  .v_vldmstatus_r               (v_vldmstatus_r),
  .v_seqstrt_r                  (v_seqstrt_r),
  .v_sqxstrt_r                  (v_sqxstrt_r),
  .v_sdxstrt_r                  (v_sdxstrt_r),
  .v_ud0strt_r                  (v_ud0strt_r),
  .v_gopstrt_r                  (v_gopstrt_r),
  .v_ud1strt_r                  (v_ud1strt_r),
  .v_picstrt_r                  (v_picstrt_r),
  .v_pcxstrt_r                  (v_pcxstrt_r),
  .v_qmxstrt_r                  (v_qmxstrt_r),
  .v_cpxstrt_r                  (v_cpxstrt_r),
  .v_pdxstrt_r                  (v_pdxstrt_r),
  .v_ud2strt_r                  (v_ud2strt_r),
  .v_atscdet_r                  (v_atscdet_r),
  .v_slicestart_r               (v_slicestart_r),
  .v_mbadet_r                   (v_mbadet_r),
  .v_qmsyni_r_n                 (v_qmsyni_r_n),
  .v_qmseli_r                   (v_qmseli_r),
  .v_qmsynn_r_n                 (v_qmsynn_r_n),
  .v_qmseln_r                   (v_qmseln_r),
  .v_qmdata_r                   (v_qmdata_r),
  .v_motion_type_r              (v_motion_type_r),
  .v_fstfwdvech_r               (v_fstfwdvech_r),
  .v_fstfwdvecv_r               (v_fstfwdvecv_r),
  .v_fstbwdvech_r               (v_fstbwdvech_r),
  .v_fstbwdvecv_r               (v_fstbwdvecv_r),
  .v_sndfwdvech_r               (v_sndfwdvech_r),
  .v_sndfwdvecv_r               (v_sndfwdvecv_r),
  .v_sndbwdvech_r               (v_sndbwdvech_r),
  .v_sndbwdvecv_r               (v_sndbwdvecv_r),
  .v_ferror_r                   (v_ferror_r),
  .v_vscdet_ferror_r            (v_vscdet_ferror_r),
  .v_nferror_r                  (v_nferror_r),
  .v_sferror_r                  (v_sferror_r),
  .v_slclverr_r                 (v_slclverr_r),
  .v1_bs_req_n                  (v1_bs_req_n),
  .clkdec                       (clk),
  .rstdec_x                     (rstdec_x),
  .g_swrst_r_n                  (g_swrst_r_n),
  .y1_bs_wait_n                 (y1_bs_wait_n),
  .g_init_vld_r_s               (g_init_vld_r_s),
  .c_mbpl_vld_r_s               (c_mbpl_vld_r_s),
  .c_mbpl_skpmb_r_s             (c_mbpl_skpmb_r_s),
  .c_skipslc_r_s                (c_skipslc_r_s),
  .c_skippic_r_s                (c_skippic_r_s),
  .y1_bs_data                   (y1_bs_data),
  .g_vldmode_r                  (g_vldmode_r),
  .v_mode_mpeg1                 (v_mode_mpeg1),
  .y1_bs_data_r                 (y1_bs_data_r)  
);

idcttop idcttop(
  .clkdec                       (clk),
  .rstdec_x                     (rstdec_x),
  .c_mbpl_idct_r_s              (c_mbpl_idct_r_s),
  .q_blkstp_r_s                 (q_blkstp_r_s),
  .q_do_r                       (q_do_r),
  .t_idcto_r                    (t_idcto_r)
);

iqtop iqtop(
  .q_blkstp_r_s                 (q_blkstp_r_s),
  .q_do_r                       (q_do_r),
  .clkdec                       (clk),
  .rstdec_x                     (rstdec_x),
  .c_mbpl_iq_r_s                (c_mbpl_iq_r_s),
  .c_qmdata_r                   (c_qmdata_r),
  .c_qmintra_r                  (c_qmintra_r),
  .c_qmseln_r                   (c_qmseln_r),
  .c_qmsynn_r_n                 (c_qmsynn_r_n),
  .p_alterscan_iq_r             (p_alterscan_iq_r),
  .p_intradcp_iq_r              (p_intradcp_iq_r),
  .p_mbtyp_0_iq_r               (p_mbtyp_0_iq_r),
  .p_mpg1_iq_r                  (p_mpg1_iq_r),
  .p_qscale_iq_r                (p_qscale_iq_r),
  .p_shdet_iq_r                 (p_shdet_iq_r),
  .v_vdo_r                      (v_vdo_r),
  .v_vdoen_r                    (v_vdoen_r)
);

busrtop busrtop(
  .clkdec                       (clk),
  .rstdec_x                     (rstdec_x),
  .g_field_start_add_r          (g_field_start_add_r),
  .g_field_offset_r             (g_field_offset_r),
  .g_cbcr_offset_r              (g_cbcr_offset_r),
  .g_line_offset_r              (g_line_offset_r),
  .f_field_num_r                (f_field_num_r),
  .f_addressx_r                 (f_addressx_r),
  .f_addressy_r                 (f_addressy_r),
  .f_request_r                  (f_request_r),
  .f_byte_num_r                 (f_byte_num_r),
  .f_line_num_r                 (f_line_num_r),
  .ph_vh_1_gnt                  (ph_vh_1_gnt),
  .ph_vh_1_r_data               (ph_vh_1_r_data),
  .ph_vh_1_r_enable             (ph_vh_1_r_enable),
  .vrh_acceptance_r             (vrh_acceptance_r),
  .vh_1_ph_req                  (vh_1_ph_req),
  .vh_1_ph_add                  (vh_1_ph_add),
  .vrh_read_data_r              (vrh_read_data_r)
);

buswtop buswtop(
  .clkdec                       (clk),
  .rstdec_x                     (rstdec_x),
  .g_field_start_add_r          (g_field_start_add_r),
  .g_field_offset_r             (g_field_offset_r),
  .g_cbcr_offset_r              (g_cbcr_offset_r),
  .g_line_offset_r              (g_line_offset_r),
  .vwh_acceptance_r             (vwh_acceptance_r),
  .b_request_r                  (b_request_r),
  .b_field_num_r                (b_field_num_r),
  .b_addressx_r                 (b_addressx_r),
  .b_addressy_r                 (b_addressy_r),
  .b_byte_num_r                 (b_byte_num_r),
  .b_line_num_r                 (b_line_num_r),
  .vwh_data_wait                (vwh_data_wait),
  .b_write_enable_r             (b_write_enable_r),
  .b_write_data                 (b_write_data),
  .vh_2_ph_req                  (vh_2_ph_req),
  .ph_vh_2_gnt                  (ph_vh_2_gnt),
  .vh_2_ph_add                  (vh_2_ph_add),
  .vh_2_ph_data                 (vh_2_ph_data)
);

regtop regtop(
  .clkbus                       (clk),
  .rstbus_x                     (rstbus_x),
  .mb_hpb_ms2_n                 (mb_hpb_ms2_n),
  .mb_hpb_read_n                (mb_hpb_read_n),
  .mb_hpb_write_n               (mb_hpb_write_n),
  .mb_hpb_a                     (mb_hpb_a),
  .mb_hpb_wd                    (mb_hpb_wd),
  .mr_dmaack8_n                 (mr_dmaack8_n),
  .sc_dmaack8_n                 (sc_dmaack8_n),
  .v_paramadr_r                 (v_paramadr_r),
  .v_paramdata_r                (v_paramdata_r),
  .v_vldstatus_r                (v_vldstatus_r),
  .v_vldmstatus_r               (v_vldmstatus_r),
  .v_seqstrt_r                  (v_seqstrt_r),
  .v_sqxstrt_r                  (v_sqxstrt_r),
  .v_sdxstrt_r                  (v_sdxstrt_r),
  .v_ud0strt_r                  (v_ud0strt_r),
  .v_gopstrt_r                  (v_gopstrt_r),
  .v_ud1strt_r                  (v_ud1strt_r),
  .v_picstrt_r                  (v_picstrt_r),
  .v_pcxstrt_r                  (v_pcxstrt_r),
  .v_cpxstrt_r                  (v_cpxstrt_r),
  .v_pdxstrt_r                  (v_pdxstrt_r),
  .v_qmxstrt_r                  (v_qmxstrt_r),
  .v_ud2strt_r                  (v_ud2strt_r),
  .v_atscdet_r                  (v_atscdet_r),
  .v_slicestart_r               (v_slicestart_r),
  .v_ferror_r                   (v_ferror_r),
  .v_nferror_r                  (v_nferror_r),
  .v_sferror_r                  (v_sferror_r),
  .v_slclverr_r                 (v_slclverr_r),
  .v_vscdet_ferror_r            (v_vscdet_ferror_r),
  .v_vdoen_r                    (v_vdoen_r),
  .v_qmseli_r                   (v_qmseli_r),
  .v_qmseln_r                   (v_qmseln_r),
  .c_pcpl_r_s                   (c_pcpl_r_s),
  .c_pcpl_tend_r_s              (c_pcpl_tend_r_s),
  .c_idlpl_r_s                  (c_idlpl_r_s),
  .c_pskp_end_r_s               (c_pskp_end_r_s),
  .c_mb_ferr_r                  (c_mb_ferr_r),
  .c_mb_nferr_r                 (c_mb_nferr_r),
  .c_tmg_ferr_hit_r             (c_tmg_ferr_hit_r),
  .c_fld_mismatch_r             (c_first_proc_r),
  .c_mbh_adr_r                  (c_mbh_adr_r),
  .c_mbv_adr_r                  (c_mbv_adr_r),
  .n_decfld_num1_r              (n_decfld_num1_r),
  .n_decfld_num2_r              (n_decfld_num2_r),
  .n_reffld_num1_r              (n_reffld_num1_r),
  .n_reffld_num2_r              (n_reffld_num2_r),
  .n_reffld_num3_r              (n_reffld_num3_r),
  .n_reffld_num4_r              (n_reffld_num4_r),
  .v1_dspfld_num1               (v1_dspfld_num1),
  .v1_dspfld_num2               (v1_dspfld_num2),
  .b_bfov_err_r                 (b_bfov_err_r),
  .f_bfud_err_r                 (f_bfud_err_r),
  .f_vec_err_r                  (f_vec_err_r),
  .vwh_response_error_r_s       (1'b0),
  .vrh_response_error_r_s       (1'b0),
  .v1_hpb_rd                    (v1_hpb_rd),
  .v1_hpb_wait_n                (v1_hpb_wait_n),
  .v1_int18_n                   (v1_int18_n),
  .v1_int23_n                   (v1_int23_n),
  .v1_dmareq8_n                 (v1_dmareq8_n),
  .g_vden_r                     (g_vden_r),
  .g_vsts_r                     (g_vsts_r),
  .g_pskp_r                     (g_pskp_r),
  .g_init_vld_r_s               (g_init_vld_r_s),
  .g_swrst_r_n                  (g_swrst_r_n),
  .g_pmod_r                     (g_pmod_r),
  .g_pcut_r                     (g_pcut_r),
  .g_mbc_en_r                   (g_mbc_en_r),
  .g_mbc_r                      (g_mbc_r),
  .g_fcyc_en_r                  (g_fcyc_en_r),
  .g_fcyc_r                     (g_fcyc_r),
  .g_hsdc_r                     (g_hsdc_r),
  .g_vsdc_r                     (g_vsdc_r),
  .g_hs60p_r                    (g_hs60p_r),
  .g_vs60p_r                    (g_vs60p_r),
  .g_pini_r                     (g_pini_r),
  .g_chg_slp_r                  (g_chg_slp_r),
  .g_bmod_r                     (g_bmod_r),
  .g_vldmode_r                  (g_vldmode_r),
  .g_field_start_add_r          (g_field_start_add_r),
  .g_field_offset_r             (g_field_offset_r),
  .g_cbcr_offset_r              (g_cbcr_offset_r),
  .g_line_offset_r              (g_line_offset_r)
);

pcnttop pcnttop(
  .clkdec                       (clk),
  .rstdec_x                     (rstdec_x),
  .c_frmpl_r_s                  (c_frmpl_r_s),
  .c_fldpl_r_s                  (c_fldpl_r_s),
  .c_pcpl_r_s                   (c_pcpl_r_s),
  .c_prgseq_r                   (c_prgseq_r),
  .c_pstr_r                     (c_pstr_r),
  .c_pic_codtyp_r               (c_pic_codtyp_r),
  .c_first_top_r                (c_tfst_r),
  .c_first_proc_r               (c_first_proc_r),
  .c_brklnk_r                   (c_brklnk_r),
  .c_crs_gop_r                  (c_crs_gop_r),
  .c_lwdly_r                    (c_lwdly_r),
  .g_pini_r                     (g_pini_r),
  .g_bmod_r                     (g_bmod_r),
  .g_chg_slp_r                  (g_chg_slp_r),
  .v1_dspfld_num1               (v1_dspfld_num1),
  .v1_dspfld_num2               (v1_dspfld_num2),
  .v1_dspfld_sc1                (v1_dspfld_sc1),
  .v1_dspfld_sc2                (v1_dspfld_sc2),
  .v1_dsp_ps                    (v1_dsp_ps),
  .n_decfld_num1_r              (n_decfld_num1_r),
  .n_decfld_num2_r              (n_decfld_num2_r),
  .n_reffld_num1_r              (n_reffld_num1_r),
  .n_reffld_num2_r              (n_reffld_num2_r),
  .n_reffld_num3_r              (n_reffld_num3_r),
  .n_reffld_num4_r              (n_reffld_num4_r),
  .n_pic_codtyp_reffld1_r       (n_pic_codtyp_reffld1_r),
  .n_pic_codtyp_reffld2_r       (n_pic_codtyp_reffld2_r),
  .n_pic_codtyp_reffld3_r       (n_pic_codtyp_reffld3_r),
  .n_pic_codtyp_reffld4_r       (n_pic_codtyp_reffld4_r)
);

busiftop busiftop(
  .clkdec                       (clk),   
  .rstdec_x                     (rstdec_x), 
  .ph_vh_1_gnt                  (ph_vh_1_gnt),
  .ph_vh_1_r_data               (ph_vh_1_r_data),
  .ph_vh_1_r_enable             (ph_vh_1_r_enable),
  .vh_1_ph_req                  (vh_1_ph_req),
  .vh_1_ph_add                  (vh_1_ph_add),
  .ph_vh_1_r_en                 (ph_vh_1_r_en),
  .ph_vh_2_gnt                  (ph_vh_2_gnt),       
  .vh_2_ph_req                  (vh_2_ph_req),           
  .vh_2_ph_add                  (vh_2_ph_add),           
  .vh_2_ph_data                 (vh_2_ph_data),          
  .vmem_we                      (vmem_we),           
  .vmem_we_n                    (vmem_we_n),           
  .vmem_wen                     (vmem_wen),           
  .vmem_ren                     (vmem_ren),           
  .vmem_add                     (vmem_add),           
  .vmem_data_out                (vmem_data_out),
  .vmem_data_in                 (vmem_data_in),
  .vmem_ch                      (vmem_ch),
  .v_bs_da                      (y1_bs_data_r) 
  );

endmodule







