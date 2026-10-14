// ----------------------------------------------
// File: cntrltop.v
// Module: cntrltop
// Function:
// ----------------------------------------------

module cntrltop( 
   clkdec, 
   rstdec_x, 
   g_mbc_r, 
   g_mbc_en_r, 
   g_pcut_r, 
   g_hs60p_r, 
   g_pmod_r, 
   g_pskp_r, 
   g_swrst_r_n, 
   g_vden_r, 
   g_vs60p_r, 
   g_fcyc_en_r,
   g_fcyc_r,
   n_pic_codtyp_reffld1_r, 
   n_pic_codtyp_reffld2_r, 
   n_pic_codtyp_reffld3_r, 
   n_pic_codtyp_reffld4_r, 
   v_ferror_r, 
   v_mbadet_r, 
   v_paramadr_r, 
   v_paramdata_r, 
   v_picstrt_r, 
   v_qmdata_r, 
   v_qmseli_r, 
   v_qmseln_r, 
   v_qmsyni_r_n, 
   v_qmsynn_r_n, 
   v_seqstrt_r, 
   v_slclverr_r, 
   v_slicestart_r, 
   p_hdtvh_r,
   c_alterscan_r, 
   c_brklnk_r, 
   c_crs_gop_r, 
   c_dct_typ_r, 
   c_dmvh_r, 
   c_dmvv_r, 
   c_fldpl_r_s, 
   c_fldsel1_fix1_r, 
   c_fldsel2_fix1_r, 
   c_fldsel3_fix1_r, 
   c_fldsel4_fix1_r, 
   c_frmpl_r_s, 
   c_hsval_r, 
   c_idlpl_r_s, 
   c_intradcp_r, 
   c_mb_ferr_r, 
   c_mb_nferr_r, 
   c_mbh_adr_r, 
   c_mbpl_buc_r_s, 
   c_mbpl_dc_r_s, 
   c_mbpl_idct_out_r_s, 
   c_mbpl_idct_r_s, 
   c_mbpl_iq_r_s, 
   c_mbpl_mc_r_s, 
   c_mbpl_mcalc_r_s, 
   c_mbpl_psft_r_s, 
   c_mbpl_skpmb_r_s, 
   c_mbpl_uc_r_s, 
   c_mbpl_vld_r_s, 
   c_mbtyp_0_r, 
   c_mbv_adr_r, 
   c_pcpl_r_s, 
   c_pcpl_tend_r_s, 
   c_pred_backward_r, 
   c_pred_forward_r, 
   c_qmdata_r, 
   c_qmintra_r, 
   c_qmseln_r, 
   c_qmsynn_r_n, 
   c_qscale_r, 
   c_skippic_r_s, 
   c_skipslc_r_s, 
   c_tmg_ferr_hit_r, 
   c_vsval_r,
   c_bfcnt_init_r,
   c_auto_rpt_md_r,
   c_ccl_r,
   c_lwdly_r,
   c_mpg1_r,
   c_pcth_mb_r,
   c_pctv_mb_r,
   c_pic_codtyp_r,
   c_prgseq_r,
   c_pstr_r,
   c_rfstfld_r,
   c_shdet_r,
   c_skpmb_r,
   c_tfst_r,
   c_pskp_end_r_s,
   c_first_proc_r,
   v1_sd_pichead_s,
   v_mode_mpeg1
);

input         clkdec;
input         rstdec_x;
input  [11:0] g_mbc_r; 
input         g_mbc_en_r;
input  [11:0] g_pcut_r;
input  [6:0]  g_hs60p_r;
input         g_pmod_r;
input         g_pskp_r;
input         g_swrst_r_n;
input         g_vden_r;
input  [6:0]  g_vs60p_r;
input         g_fcyc_en_r;
input  [17:0] g_fcyc_r;

input  [2:0]  n_pic_codtyp_reffld1_r;
input  [2:0]  n_pic_codtyp_reffld2_r;
input  [2:0]  n_pic_codtyp_reffld3_r;
input  [2:0]  n_pic_codtyp_reffld4_r;
input         v_ferror_r;
input         v_mbadet_r;
input  [7:0]  v_paramadr_r;
input  [24:1] v_paramdata_r;
input         v_picstrt_r;
input  [7:0]  v_qmdata_r;
input         v_qmseli_r;
input         v_qmseln_r;
input         v_qmsyni_r_n;
input         v_qmsynn_r_n;
input         v_seqstrt_r;
input         v_slclverr_r;
input         v_slicestart_r;
input         p_hdtvh_r;

output        c_alterscan_r;
output        c_brklnk_r;
output        c_crs_gop_r;
output        c_dct_typ_r;
output [1:0]  c_dmvh_r;
output [1:0]  c_dmvv_r;
output        c_fldpl_r_s;
output        c_fldsel1_fix1_r;
output        c_fldsel2_fix1_r;
output        c_fldsel3_fix1_r;
output        c_fldsel4_fix1_r;
output        c_frmpl_r_s;
output [11:0] c_hsval_r;
output        c_idlpl_r_s;
output [1:0]  c_intradcp_r;
output        c_mb_ferr_r;
output [2:0]  c_mb_nferr_r;
output [6:0]  c_mbh_adr_r;
output        c_mbpl_buc_r_s;
output        c_mbpl_dc_r_s;
output        c_mbpl_idct_out_r_s;
output        c_mbpl_idct_r_s;
output        c_mbpl_iq_r_s;
output        c_mbpl_mc_r_s;
output        c_mbpl_mcalc_r_s;
output        c_mbpl_psft_r_s;
output        c_mbpl_skpmb_r_s;
output        c_mbpl_uc_r_s;
output        c_mbpl_vld_r_s;
output        c_mbtyp_0_r;
output [6:0]  c_mbv_adr_r;
output        c_pcpl_r_s;
output        c_pcpl_tend_r_s;
output        c_pred_backward_r;
output        c_pred_forward_r;
output [7:0]  c_qmdata_r;
output        c_qmintra_r;
output        c_qmseln_r;
output        c_qmsynn_r_n;
output [6:0]  c_qscale_r;
output        c_skippic_r_s;
output        c_skipslc_r_s;
output        c_tmg_ferr_hit_r;
output [11:0] c_vsval_r;
output        c_bfcnt_init_r;

output [1:0]  c_auto_rpt_md_r;
output        c_ccl_r;
output        c_lwdly_r;
output        c_mpg1_r;
output [6:0]  c_pcth_mb_r;
output [6:0]  c_pctv_mb_r;
output [2:0]  c_pic_codtyp_r;
output        c_prgseq_r;
output [1:0]  c_pstr_r;
output        c_rfstfld_r;
output        c_shdet_r;
output        c_skpmb_r;
output        c_tfst_r;
output        c_pskp_end_r_s;
output        c_first_proc_r;
output        v1_sd_pichead_s;
input         v_mode_mpeg1;

wire         clkdec;
wire         rstdec_x;
wire [7:0]   w1_mtp00_q;
wire [11:0]  c_mbpl_cycl_r;
wire [11:0]  g_pcut_r;
wire [6:0]   g_hs60p_r;
wire         g_pmod_r;
wire         g_pskp_r;
wire         g_swrst_r_n;
wire         g_vden_r;
wire [6:0]   g_vs60p_r;
wire [2:0]   n_pic_codtyp_reffld1_r;
wire [2:0]   n_pic_codtyp_reffld2_r;
wire [2:0]   n_pic_codtyp_reffld3_r;
wire [2:0]   n_pic_codtyp_reffld4_r;
wire         v_ferror_r;
wire         v_mbadet_r;
wire [7:0]   v_paramadr_r;
wire [24:1]  v_paramdata_r;
wire         v_picstrt_r;
wire [7:0]   v_qmdata_r;
wire         v_qmseli_r;
wire         v_qmseln_r;
wire         v_qmsyni_r_n;
wire         v_qmsynn_r_n;
wire         v_seqstrt_r;
wire         v_slclverr_r;
wire         v_slicestart_r;
wire [6:0]   v1_mtp00_a;
wire         v1_mtp00_bs;
wire [7:0]   v1_mtp00_d;
wire         v1_mtp00_we;
wire         c_alterscan_r;
wire         c_brklnk_r;
wire         c_crs_gop_r;
wire         c_dct_typ_r;
wire [1:0]   c_dmvh_r;
wire [1:0]   c_dmvv_r;
wire         c_fldpl_r_s;
wire         c_fldsel1_fix1_r;
wire         c_fldsel2_fix1_r;
wire         c_fldsel3_fix1_r;
wire         c_fldsel4_fix1_r;
wire         c_frmpl_r_s;
wire [11:0]  c_hsval_r;
wire         c_idlpl_r_s;
wire [1:0]   c_intradcp_r;
wire         c_mb_ferr_r;
wire [2:0]   c_mb_nferr_r;
wire [6:0]   c_mbh_adr_r;
wire         c_mbpl_buc_r_s;
wire         c_mbpl_dc_r_s;
wire         c_mbpl_idct_out_r_s;
wire         c_mbpl_idct_r_s;
wire         c_mbpl_iq_r_s;
wire         c_mbpl_mc_r_s;
wire         c_mbpl_mcalc_r_s;
wire         c_mbpl_pos_r_s;
wire         c_mbpl_psft_r_s;
wire         c_mbpl_skpmb_r_s;
wire         c_mbpl_uc_r_s;
wire         c_mbpl_vld_r_s;
wire         c_mbtyp_0_r;
wire [6:0]   c_mbv_adr_r;
wire         c_pcpl_r_s;
wire         c_pcpl_tend_r_s;
wire         c_pred_backward_r;
wire         c_pred_forward_r;
wire [7:0]   c_qmdata_r;
wire         c_qmintra_r;
wire         c_qmseln_r;
wire         c_qmsynn_r_n;
wire [6:0]   c_qscale_r;
wire         c_skippic_r_s;
wire         c_skipslc_r_s;
wire         c_tmg_ferr_hit_r;
wire [11:0]  c_vsval_r;

wire [21:0] c_fldpl_cycl_r;
wire        c_mb_fin_r;
wire [17:0] c_mbai_r;
wire        c_mbaidet_s;
wire        c_phdet_r;
wire [7:0]  c_svp_r;
wire        c_pic_notcplt_r;

wire [1:0]  c_auto_rpt_md_r;
wire        c_ccl_r;
wire        c_lwdly_r;
wire        c_mpg1_r;
wire [6:0]  c_pcth_mb_r;
wire [6:0]  c_pctv_mb_r;
wire [2:0]  c_pic_codtyp_r;
wire        c_prgseq_r;
wire [1:0]  c_pstr_r;
wire        c_rfstfld_r;
wire        c_shdet_r;
wire        c_skpmb_r;
wire        c_tfst_r;

assign  c_first_proc_r = 1'b0;

cmbctl cmbctl( 
   .clkdec         (clkdec), 
   .rstdec_x       (rstdec_x), 
   .v_slclverr_r   (v_slclverr_r), 
   .v_ferror_r     (v_ferror_r), 
   .c_pcpl_r_s     (c_pcpl_r_s), 
   .c_mbpl_pos_r_s (c_mbpl_pos_r_s), 
   .c_mbai_r       (c_mbai_r), 
   .c_svp_r        (c_svp_r), 
   .c_pctv_mb_r    (c_pctv_mb_r), 
   .c_pcth_mb_r    (c_pcth_mb_r), 
   .c_shdet_r      (c_shdet_r), 
   .c_mbaidet_s    (c_mbaidet_s), 
   .c_mpg1_r       (c_mpg1_r), 
   .c_pic_notcplt_r(c_pic_notcplt_r),
   .c_skipslc_r_s  (c_skipslc_r_s), 
   .c_mb_nferr_r   (c_mb_nferr_r[2:0]), 
   .c_mb_ferr_r    (c_mb_ferr_r), 
   .c_mb_fin_r     (c_mb_fin_r), 
   .c_mbv_adr_r    (c_mbv_adr_r), 
   .c_mbh_adr_r    (c_mbh_adr_r), 
   .c_skpmb_r      (c_skpmb_r), 
   .c_ccl_r        (c_ccl_r)
); 

cpctl cpctl( 
   .clkdec                 (clkdec), 
   .rstdec_x               (rstdec_x), 
   .v_paramadr_r           (v_paramadr_r), 
   .v_paramdata_r          (v_paramdata_r), 
   .v_picstrt_r            (v_picstrt_r), 
   .v_slicestart_r         (v_slicestart_r), 
   .v_mbadet_r             (v_mbadet_r), 
   .v_qmsyni_r_n           (v_qmsyni_r_n), 
   .v_qmseli_r             (v_qmseli_r), 
   .v_qmsynn_r_n           (v_qmsynn_r_n), 
   .v_qmseln_r             (v_qmseln_r), 
   .v_qmdata_r             (v_qmdata_r), 
   .v_ferror_r             (v_ferror_r), 
   .c_mbpl_vld_r_s         (c_mbpl_vld_r_s), 
   .c_pcpl_r_s             (c_pcpl_r_s), 
   .c_skpmb_r              (c_skpmb_r), 
   .n_pic_codtyp_reffld1_r (n_pic_codtyp_reffld1_r), 
   .n_pic_codtyp_reffld2_r (n_pic_codtyp_reffld2_r), 
   .n_pic_codtyp_reffld3_r (n_pic_codtyp_reffld3_r), 
   .n_pic_codtyp_reffld4_r (n_pic_codtyp_reffld4_r), 
   .v_seqstrt_r            (v_seqstrt_r), 
   .g_hs60p_r              (g_hs60p_r), 
   .g_vs60p_r              (g_vs60p_r), 
   .g_mbc_r                (g_mbc_r), 
   .g_mbc_en_r             (g_mbc_en_r), 
   .g_fcyc_en_r            (g_fcyc_en_r),
   .g_fcyc_r               (g_fcyc_r),
   .w1_mtp00_q             (w1_mtp00_q), 
   .p_hdtvh_r              (p_hdtvh_r), 
   .c_mbpl_psft_r_s        (c_mbpl_psft_r_s),
   .c_qmsynn_r_n           (c_qmsynn_r_n), 
   .c_qmdata_r             (c_qmdata_r), 
   .c_qmseln_r             (c_qmseln_r), 
   .c_qmintra_r            (c_qmintra_r), 
   .c_lwdly_r              (c_lwdly_r), 
   .c_rfstfld_r            (c_rfstfld_r), 
   .c_fldpl_cycl_r         (c_fldpl_cycl_r), 
   .c_auto_rpt_md_r        (c_auto_rpt_md_r), 
   .c_prgseq_r             (c_prgseq_r), 
   .c_tfst_r               (c_tfst_r), 
   .c_phdet_r              (c_phdet_r), 
   .c_mbaidet_s            (c_mbaidet_s), 
   .c_mbai_r               (c_mbai_r), 
   .c_svp_r                (c_svp_r), 
   .c_pcth_mb_r            (c_pcth_mb_r), 
   .c_pctv_mb_r            (c_pctv_mb_r), 
   .c_shdet_r              (c_shdet_r), 
   .c_hsval_r              (c_hsval_r), 
   .c_vsval_r              (c_vsval_r), 
   .c_pstr_r               (c_pstr_r), 
   .c_dct_typ_r            (c_dct_typ_r), 
   .c_dmvh_r               (c_dmvh_r), 
   .c_dmvv_r               (c_dmvv_r), 
   .c_mpg1_r               (c_mpg1_r), 
   .c_intradcp_r           (c_intradcp_r), 
   .c_alterscan_r          (c_alterscan_r), 
   .c_pred_forward_r       (c_pred_forward_r), 
   .c_pred_backward_r      (c_pred_backward_r), 
   .c_fldsel1_fix1_r       (c_fldsel1_fix1_r), 
   .c_fldsel2_fix1_r       (c_fldsel2_fix1_r), 
   .c_fldsel3_fix1_r       (c_fldsel3_fix1_r), 
   .c_fldsel4_fix1_r       (c_fldsel4_fix1_r), 
   .c_pic_codtyp_r         (c_pic_codtyp_r), 
   .c_brklnk_r             (c_brklnk_r), 
   .c_crs_gop_r            (c_crs_gop_r), 
   .c_mbtyp_0_r            (c_mbtyp_0_r), 
   .c_qscale_r             (c_qscale_r), 
   .c_mbpl_cycl_r          (c_mbpl_cycl_r), 
   .v1_mtp00_bs            (v1_mtp00_bs), 
   .v1_mtp00_we            (v1_mtp00_we), 
   .v1_mtp00_a             (v1_mtp00_a), 
   .v1_mtp00_d             (v1_mtp00_d),
   .v_mode_mpeg1           (v_mode_mpeg1)           

); 

ctmg ctmg( 
   .clkdec              (clkdec), 
   .rstdec_x            (rstdec_x), 
   .g_vden_r            (g_vden_r), 
   .g_pmod_r            (g_pmod_r), 
   .g_swrst_r_n         (g_swrst_r_n), 
   .g_pskp_r            (g_pskp_r), 
   .c_pstr_r            (c_pstr_r), 
   .c_prgseq_r          (c_prgseq_r), 
   .c_rfstfld_r         (c_rfstfld_r), 
   .c_tfst_r            (c_tfst_r), 
   .c_phdet_r           (c_phdet_r), 
   .c_mbaidet_s         (c_mbaidet_s), 
   .c_mb_fin_r          (c_mb_fin_r), 
   .c_lwdly_r           (c_lwdly_r), 
   .c_ccl_r             (c_ccl_r), 
   .c_skpmb_r           (c_skpmb_r), 
   .c_fldpl_cycl_r      (c_fldpl_cycl_r), 
   .c_mbpl_cycl_r       (c_mbpl_cycl_r), 
   .c_auto_rpt_md_r     (c_auto_rpt_md_r), 
   .g_pcut_r            (g_pcut_r), 
   .c_pic_codtyp_r      (c_pic_codtyp_r), 
   .c_mbpl_vld_r_s      (c_mbpl_vld_r_s), 
   .c_mbpl_iq_r_s       (c_mbpl_iq_r_s), 
   .c_mbpl_idct_r_s     (c_mbpl_idct_r_s), 
   .c_mbpl_idct_out_r_s (c_mbpl_idct_out_r_s), 
   .c_mbpl_mcalc_r_s    (c_mbpl_mcalc_r_s), 
   .c_mbpl_buc_r_s      (c_mbpl_buc_r_s), 
   .c_mbpl_uc_r_s       (c_mbpl_uc_r_s), 
   .c_mbpl_mc_r_s       (c_mbpl_mc_r_s), 
   .c_mbpl_dc_r_s       (c_mbpl_dc_r_s), 
   .c_mbpl_psft_r_s     (c_mbpl_psft_r_s), 
   .c_mbpl_pos_r_s      (c_mbpl_pos_r_s), 
   .c_frmpl_r_s         (c_frmpl_r_s), 
   .c_fldpl_r_s         (c_fldpl_r_s), 
   .c_pcpl_r_s          (c_pcpl_r_s), 
   .c_skippic_r_s       (c_skippic_r_s), 
   .c_tmg_ferr_hit_r    (c_tmg_ferr_hit_r), 
   .c_pcpl_tend_r_s     (c_pcpl_tend_r_s), 
   .c_mbpl_skpmb_r_s    (c_mbpl_skpmb_r_s), 
   .c_idlpl_r_s         (c_idlpl_r_s),
   .c_bfcnt_init_r      (c_bfcnt_init_r),
   .c_pic_notcplt_r     (c_pic_notcplt_r),
   .c_pskp_end_r_s      (c_pskp_end_r_s),
   .v1_sd_pichead_s     (v1_sd_pichead_s)
); 

ct_mtparray ctmem(
   .clkdec(clkdec),
   .rstdec_x(rstdec_x),
   .v1_mtp00_a(v1_mtp00_a),
   .v1_mtp00_bs(v1_mtp00_bs),
   .v1_mtp00_d(v1_mtp00_d),
   .v1_mtp00_we(v1_mtp00_we),
   .w1_mtp00_q(w1_mtp00_q)
   );

endmodule

