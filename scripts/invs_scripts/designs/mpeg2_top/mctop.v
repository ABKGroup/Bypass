// ----------------------------------------------
// File: mctop.v
// Module: mctop
// Function: Motion Compensation top module
// ----------------------------------------------

module mctop( 
   clkdec, 
   rstdec_x, 
   c_mbpl_dc_r_s, 
   c_mbpl_idct_out_r_s, 
   c_mbpl_mc_r_s, 
   c_mbpl_mcalc_r_s, 
   c_mbpl_psft_r_s, 
   c_mbpl_uc_r_s, 
   p_dct_typ_mc_r, 
   p_dmvh_buc_r, 
   p_dmvv_buc_r, 
   p_fstbwdvech_buc_r, 
   p_fstbwdvecv_buc_r, 
   p_fstfwdvech_buc_r, 
   p_fstfwdvecv_buc_r, 
   p_idct_dis_mc_r, 
   p_mbtyp_0_buc_r, 
   p_mttyp_buc_r, 
   p_pred_backward_buc_r, 
   p_pred_forward_buc_r, 
   p_prgseq_buc_r, 
   p_pstr_buc_r, 
   p_sndbwdvech_buc_r, 
   p_sndbwdvecv_buc_r, 
   p_sndfwdvech_buc_r, 
   p_sndfwdvecv_buc_r, 
   p_tfst_buc_r, 
   t_idcto_r, 
   u_ref1cen_r, 
   u_ref1dt_r, 
   u_ref1yen_r, 
   u_ref2cen_r, 
   u_ref2dt_r, 
   u_ref2yen_r, 
   m_deccen_r, 
   m_decdt_r, 
   m_decyen_r, 
   m_hvec1c_r, 
   m_hvec1y_r, 
   m_hvec2c_r, 
   m_hvec2y_r, 
   m_hvec3c_r, 
   m_hvec3y_r, 
   m_hvec4c_r, 
   m_hvec4y_r, 
   m_vvec1c_r, 
   m_vvec1y_r, 
   m_vvec2c_r, 
   m_vvec2y_r, 
   m_vvec3c_r, 
   m_vvec3y_r, 
   m_vvec4c_r, 
   m_vvec4y_r
);


input         clkdec;
input         rstdec_x;
input         c_mbpl_dc_r_s;
input         c_mbpl_idct_out_r_s;
input         c_mbpl_mc_r_s;
input         c_mbpl_mcalc_r_s;
input         c_mbpl_psft_r_s;
input         c_mbpl_uc_r_s;
input         p_dct_typ_mc_r;
input  [1:0]  p_dmvh_buc_r;
input  [1:0]  p_dmvv_buc_r;
input  [12:0] p_fstbwdvech_buc_r;
input  [8:0]  p_fstbwdvecv_buc_r;
input  [12:0] p_fstfwdvech_buc_r;
input  [8:0]  p_fstfwdvecv_buc_r;
input         p_idct_dis_mc_r;
input         p_mbtyp_0_buc_r;
input  [1:0]  p_mttyp_buc_r;
input         p_pred_backward_buc_r;
input         p_pred_forward_buc_r;
input         p_prgseq_buc_r;
input  [1:0]  p_pstr_buc_r;
input  [12:0] p_sndbwdvech_buc_r;
input  [8:0]  p_sndbwdvecv_buc_r;
input  [12:0] p_sndfwdvech_buc_r;
input  [8:0]  p_sndfwdvecv_buc_r;
input         p_tfst_buc_r;
input  [8:0]  t_idcto_r;
input         u_ref1cen_r;
input  [15:0] u_ref1dt_r;
input         u_ref1yen_r;
input         u_ref2cen_r;
input  [15:0] u_ref2dt_r;
input         u_ref2yen_r;
output        m_deccen_r;
output [15:0] m_decdt_r;
output        m_decyen_r;
output [10:0] m_hvec1c_r;
output [11:0] m_hvec1y_r;
output [10:0] m_hvec2c_r;
output [11:0] m_hvec2y_r;
output [10:0] m_hvec3c_r;
output [11:0] m_hvec3y_r;
output [10:0] m_hvec4c_r;
output [11:0] m_hvec4y_r;
output [6:0]  m_vvec1c_r;
output [7:0]  m_vvec1y_r;
output [6:0]  m_vvec2c_r;
output [7:0]  m_vvec2y_r;
output [6:0]  m_vvec3c_r;
output [7:0]  m_vvec3y_r;
output [6:0]  m_vvec4c_r;
output [7:0]  m_vvec4y_r;


wire         clkdec;
wire         rstdec_x;
wire         c_mbpl_dc_r_s;
wire         c_mbpl_idct_out_r_s;
wire         c_mbpl_mc_r_s;
wire         c_mbpl_mcalc_r_s;
wire         c_mbpl_psft_r_s;
wire         c_mbpl_uc_r_s;
wire         p_dct_typ_mc_r;
wire [1:0]   p_dmvh_buc_r;
wire [1:0]   p_dmvv_buc_r;
wire [12:0]  p_fstbwdvech_buc_r;
wire [8:0]   p_fstbwdvecv_buc_r;
wire [12:0]  p_fstfwdvech_buc_r;
wire [8:0]   p_fstfwdvecv_buc_r;
wire         p_idct_dis_mc_r;
wire         p_mbtyp_0_buc_r;
wire [1:0]   p_mttyp_buc_r;
wire         p_pred_backward_buc_r;
wire         p_pred_forward_buc_r;
wire         p_prgseq_buc_r;
wire [1:0]   p_pstr_buc_r;
wire [12:0]  p_sndbwdvech_buc_r;
wire [8:0]   p_sndbwdvecv_buc_r;
wire [12:0]  p_sndfwdvech_buc_r;
wire [8:0]   p_sndfwdvecv_buc_r;
wire         p_tfst_buc_r;
wire [8:0]   t_idcto_r;
wire         u_ref1cen_r;
wire [15:0]  u_ref1dt_r;
wire         u_ref1yen_r;
wire         u_ref2cen_r;
wire [15:0]  u_ref2dt_r;
wire         u_ref2yen_r;
wire [8:0]   w1_bmb00_q;
wire [8:0]   w1_bmb01_q;
wire [8:0]   w1_bmb02_q;
wire [17:0]  w1_ibe00_q;
wire [17:0]  w1_ibe01_q;
wire [17:0]  w1_ibo00_q;
wire [17:0]  w1_ibo01_q;
wire [17:0]  w1_ife00_q;
wire [17:0]  w1_ife01_q;
wire [17:0]  w1_ifo00_q;
wire [17:0]  w1_ifo01_q;
wire [15:0]  w1_rit00_q;
wire [15:0]  w1_rit01_q;
wire [8:0]   v1_bmb00_a;
wire         v1_bmb00_bs;
wire [8:0]   v1_bmb00_d;
wire         v1_bmb00_we;
wire [8:0]   v1_bmb01_a;
wire         v1_bmb01_bs;
wire [8:0]   v1_bmb01_d;
wire         v1_bmb01_we;
wire [8:0]   v1_bmb02_a;
wire         v1_bmb02_bs;
wire [8:0]   v1_bmb02_d;
wire         v1_bmb02_we;
wire [6:0]   v1_ibe00_a;
wire         v1_ibe00_bs;
wire [17:0]  v1_ibe00_d;
wire         v1_ibe00_we;
wire [6:0]   v1_ibe01_a;
wire         v1_ibe01_bs;
wire [17:0]  v1_ibe01_d;
wire         v1_ibe01_we;
wire [6:0]   v1_ibo00_a;
wire         v1_ibo00_bs;
wire [17:0]  v1_ibo00_d;
wire         v1_ibo00_we;
wire [6:0]   v1_ibo01_a;
wire         v1_ibo01_bs;
wire [17:0]  v1_ibo01_d;
wire         v1_ibo01_we;
wire [6:0]   v1_ife00_a;
wire         v1_ife00_bs;
wire [17:0]  v1_ife00_d;
wire         v1_ife00_we;
wire [6:0]   v1_ife01_a;
wire         v1_ife01_bs;
wire [17:0]  v1_ife01_d;
wire         v1_ife01_we;
wire [6:0]   v1_ifo00_a;
wire         v1_ifo00_bs;
wire [17:0]  v1_ifo00_d;
wire         v1_ifo00_we;
wire [6:0]   v1_ifo01_a;
wire         v1_ifo01_bs;
wire [17:0]  v1_ifo01_d;
wire         v1_ifo01_we;
wire [7:0]   v1_rit00_a;
wire         v1_rit00_bs;
wire [15:0]  v1_rit00_d;
wire         v1_rit00_we;
wire [7:0]   v1_rit01_a;
wire         v1_rit01_bs;
wire [15:0]  v1_rit01_d;
wire         v1_rit01_we;
wire         m_deccen_r;
wire [15:0]  m_decdt_r;
wire         m_decyen_r;
wire [10:0]  m_hvec1c_r;
wire [11:0]  m_hvec1y_r;
wire [10:0]  m_hvec2c_r;
wire [11:0]  m_hvec2y_r;
wire [10:0]  m_hvec3c_r;
wire [11:0]  m_hvec3y_r;
wire [10:0]  m_hvec4c_r;
wire [11:0]  m_hvec4y_r;
wire [6:0]   m_vvec1c_r;
wire [7:0]   m_vvec1y_r;
wire [6:0]   m_vvec2c_r;
wire [7:0]   m_vvec2y_r;
wire [6:0]   m_vvec3c_r;
wire [7:0]   m_vvec3y_r;
wire [6:0]   m_vvec4c_r;
wire [7:0]   m_vvec4y_r;

wire [7:0] m_backward_data_r;
wire [7:0] m_calc_dat_r;
wire [7:0] m_forward_data_r;
wire       m_frm_fidp_r;
wire       m_frm_inter_mc_r;
wire       m_frm_inter_uc_r;
wire       m_frm_pred_over_mc_r;
wire       m_frm_pred_over_uc_r;
wire       m_frm_prog_mc_r;
wire       m_frm_prog_uc_r;
wire       m_half_hpelb_r;
wire       m_half_hpelf_r;
wire       m_half_vpelb_r;
wire       m_half_vpelf_r;
wire       m_line17_cutb_r;
wire       m_line17_cutf_r;
wire       m_mbpl_dc_r_s;
wire       m_mbpl_idct_out_r_s;
wire       m_mbpl_mc_r_s;
wire       m_mbpl_uc_r_s;
wire       m_motion_dp_r;
wire [8:0] m_pred_dat_r;
wire       m_ref1cen_r;
wire       m_ref1yen_r;
wire       m_ref2cen_r;
wire       m_ref2yen_r;


mc_bkmb mc_bkmb( 
   .m_mbpl_idct_out_r_s (m_mbpl_idct_out_r_s), 
   .m_mbpl_mc_r_s       (m_mbpl_mc_r_s), 
   .m_frm_fidp_r        (m_frm_fidp_r), 
   .p_dct_typ_mc_r      (p_dct_typ_mc_r), 
   .t_idcto_r           (t_idcto_r), 
   .p_idct_dis_mc_r     (p_idct_dis_mc_r), 
   .m_pred_dat_r        (m_pred_dat_r), 
   .v1_bmb00_a            (v1_bmb00_a), 
   .v1_bmb00_d            (v1_bmb00_d), 
   .w1_bmb00_q            (w1_bmb00_q), 
   .v1_bmb00_bs           (v1_bmb00_bs), 
   .v1_bmb00_we           (v1_bmb00_we), 
   .v1_bmb01_a            (v1_bmb01_a), 
   .v1_bmb01_d            (v1_bmb01_d), 
   .w1_bmb01_q            (w1_bmb01_q), 
   .v1_bmb01_bs           (v1_bmb01_bs), 
   .v1_bmb01_we           (v1_bmb01_we), 
   .v1_bmb02_a            (v1_bmb02_a), 
   .v1_bmb02_d            (v1_bmb02_d), 
   .w1_bmb02_q            (w1_bmb02_q), 
   .v1_bmb02_bs           (v1_bmb02_bs), 
   .v1_bmb02_we           (v1_bmb02_we), 
   .rstdec_x          (rstdec_x), 
   .clkdec            (clkdec)
); 

mc_fbdp mc_fbdp( 
   .clkdec              (clkdec), 
   .rstdec_x            (rstdec_x), 
   .p_pred_forward_buc_r  (p_pred_forward_buc_r), 
   .p_pred_backward_buc_r (p_pred_backward_buc_r), 
   .p_mbtyp_0_buc_r       (p_mbtyp_0_buc_r), 
   .m_forward_data_r      (m_forward_data_r), 
   .m_backward_data_r     (m_backward_data_r), 
   .m_pred_dat_r          (m_pred_dat_r), 
   .m_calc_dat_r          (m_calc_dat_r), 
   .m_motion_dp_r         (m_motion_dp_r)
); 

mc_frfi mc_frfi( 
   .clkdec             (clkdec), 
   .rstdec_x           (rstdec_x), 
   .m_mbpl_dc_r_s        (m_mbpl_dc_r_s), 
   .m_mbpl_mc_r_s        (m_mbpl_mc_r_s), 
   .m_frm_inter_mc_r     (m_frm_inter_mc_r), 
   .m_frm_prog_mc_r      (m_frm_prog_mc_r), 
   .m_frm_prog_over_mc_r (m_frm_pred_over_mc_r), 
   .m_decdt_r            (m_decdt_r), 
   .m_decyen_r           (m_decyen_r), 
   .m_deccen_r           (m_deccen_r), 
   .m_calc_dat_r         (m_calc_dat_r), 
   .v1_rit00_a             (v1_rit00_a), 
   .v1_rit00_d             (v1_rit00_d), 
   .w1_rit00_q             (w1_rit00_q), 
   .v1_rit00_bs            (v1_rit00_bs), 
   .v1_rit00_we            (v1_rit00_we), 
   .v1_rit01_a             (v1_rit01_a), 
   .v1_rit01_d             (v1_rit01_d), 
   .w1_rit01_q             (w1_rit01_q), 
   .v1_rit01_bs            (v1_rit01_bs), 
   .v1_rit01_we            (v1_rit01_we)
); 

mc_hp mc_hp0( 
   .clkdec             (clkdec), 
   .rstdec_x           (rstdec_x), 
   .m_frm_inter_mc_r     (m_frm_inter_mc_r), 
   .m_frm_inter_uc_r     (m_frm_inter_uc_r), 
   .m_frm_pred_over_mc_r (m_frm_pred_over_mc_r), 
   .m_frm_pred_over_uc_r (m_frm_pred_over_uc_r), 
   .m_frm_prog_mc_r      (m_frm_prog_mc_r), 
   .m_frm_prog_uc_r      (m_frm_prog_uc_r), 
   .m_half_hpelf_r       (m_half_hpelf_r), 
   .m_half_vpelf_r       (m_half_vpelf_r), 
   .m_line17_cutf_r      (m_line17_cutf_r), 
   .m_mbpl_mc_r_s        (m_mbpl_mc_r_s), 
   .m_mbpl_uc_r_s        (m_mbpl_uc_r_s), 
   .m_ref1cen_r          (m_ref1cen_r), 
   .m_ref1yen_r          (m_ref1yen_r), 
   .p_pred_forward_buc_r (p_pred_forward_buc_r), 
   .u_ref1dt_r           (u_ref1dt_r), 
   .w1_ife00_q             (w1_ife00_q), 
   .w1_ife01_q             (w1_ife01_q), 
   .w1_ifo00_q             (w1_ifo00_q), 
   .w1_ifo01_q             (w1_ifo01_q), 
   .v1_ife00_a             (v1_ife00_a), 
   .v1_ife00_bs            (v1_ife00_bs), 
   .v1_ife00_d             (v1_ife00_d), 
   .v1_ife00_we            (v1_ife00_we), 
   .v1_ife01_a             (v1_ife01_a), 
   .v1_ife01_bs            (v1_ife01_bs), 
   .v1_ife01_d             (v1_ife01_d), 
   .v1_ife01_we            (v1_ife01_we), 
   .v1_ifo00_a             (v1_ifo00_a), 
   .v1_ifo00_bs            (v1_ifo00_bs), 
   .v1_ifo00_d             (v1_ifo00_d), 
   .v1_ifo00_we            (v1_ifo00_we), 
   .v1_ifo01_a             (v1_ifo01_a), 
   .v1_ifo01_bs            (v1_ifo01_bs), 
   .v1_ifo01_d             (v1_ifo01_d), 
   .v1_ifo01_we            (v1_ifo01_we), 
   .m_halfvdt_r          (m_forward_data_r),
   .m_motion_dp_r        (m_motion_dp_r)
); 

mc_hp mc_hp1( 
   .clkdec             (clkdec), 
   .rstdec_x           (rstdec_x), 
   .m_frm_inter_mc_r     (m_frm_inter_mc_r), 
   .m_frm_inter_uc_r     (m_frm_inter_uc_r), 
   .m_frm_pred_over_mc_r (m_frm_pred_over_mc_r), 
   .m_frm_pred_over_uc_r (m_frm_pred_over_uc_r), 
   .m_frm_prog_mc_r      (m_frm_prog_mc_r), 
   .m_frm_prog_uc_r      (m_frm_prog_uc_r), 
   .m_half_hpelf_r       (m_half_hpelb_r), 
   .m_half_vpelf_r       (m_half_vpelb_r), 
   .m_line17_cutf_r      (m_line17_cutb_r), 
   .m_mbpl_mc_r_s        (m_mbpl_mc_r_s), 
   .m_mbpl_uc_r_s        (m_mbpl_uc_r_s), 
   .m_ref1cen_r          (m_ref2cen_r), 
   .m_ref1yen_r          (m_ref2yen_r), 
   .p_pred_forward_buc_r (p_pred_backward_buc_r), 
   .u_ref1dt_r           (u_ref2dt_r), 
   .w1_ife00_q             (w1_ibe00_q), 
   .w1_ife01_q             (w1_ibe01_q), 
   .w1_ifo00_q             (w1_ibo00_q), 
   .w1_ifo01_q             (w1_ibo01_q), 
   .v1_ife00_a             (v1_ibe00_a), 
   .v1_ife00_bs            (v1_ibe00_bs), 
   .v1_ife00_d             (v1_ibe00_d), 
   .v1_ife00_we            (v1_ibe00_we), 
   .v1_ife01_a             (v1_ibe01_a), 
   .v1_ife01_bs            (v1_ibe01_bs), 
   .v1_ife01_d             (v1_ibe01_d), 
   .v1_ife01_we            (v1_ibe01_we), 
   .v1_ifo00_a             (v1_ibo00_a), 
   .v1_ifo00_bs            (v1_ibo00_bs), 
   .v1_ifo00_d             (v1_ibo00_d), 
   .v1_ifo00_we            (v1_ibo00_we), 
   .v1_ifo01_a             (v1_ibo01_a), 
   .v1_ifo01_bs            (v1_ibo01_bs), 
   .v1_ifo01_d             (v1_ibo01_d), 
   .v1_ifo01_we            (v1_ibo01_we), 
   .m_halfvdt_r          (m_backward_data_r),
   .m_motion_dp_r        (m_motion_dp_r)
); 

mc_vcsl mc_vcsl( 
   .c_mbpl_mcalc_r_s     (c_mbpl_mcalc_r_s), 
   .c_mbpl_psft_r_s      (c_mbpl_psft_r_s), 
   .c_mbpl_uc_r_s        (c_mbpl_uc_r_s), 
   .c_mbpl_dc_r_s        (c_mbpl_dc_r_s), 
   .c_mbpl_mc_r_s        (c_mbpl_mc_r_s), 
   .c_mbpl_idct_out_r_s  (c_mbpl_idct_out_r_s), 
   .p_fstfwdvech_buc_r   (p_fstfwdvech_buc_r), 
   .p_fstfwdvecv_buc_r   (p_fstfwdvecv_buc_r), 
   .p_fstbwdvech_buc_r   (p_fstbwdvech_buc_r), 
   .p_fstbwdvecv_buc_r   (p_fstbwdvecv_buc_r), 
   .p_sndfwdvech_buc_r   (p_sndfwdvech_buc_r), 
   .p_sndfwdvecv_buc_r   (p_sndfwdvecv_buc_r), 
   .p_sndbwdvech_buc_r   (p_sndbwdvech_buc_r), 
   .p_sndbwdvecv_buc_r   (p_sndbwdvecv_buc_r), 
   .p_mttyp_buc_r        (p_mttyp_buc_r), 
   .p_prgseq_buc_r       (p_prgseq_buc_r), 
   .p_pstr_buc_r         (p_pstr_buc_r), 
   .p_tfst_buc_r         (p_tfst_buc_r), 
   .p_dmvh_buc_r         (p_dmvh_buc_r), 
   .p_dmvv_buc_r         (p_dmvv_buc_r), 
   .m_mbpl_uc_r_s        (m_mbpl_uc_r_s), 
   .u_ref1yen_r          (u_ref1yen_r), 
   .u_ref1cen_r          (u_ref1cen_r), 
   .u_ref2yen_r          (u_ref2yen_r), 
   .u_ref2cen_r          (u_ref2cen_r), 
   .m_mbpl_dc_r_s        (m_mbpl_dc_r_s), 
   .m_mbpl_mc_r_s        (m_mbpl_mc_r_s), 
   .m_mbpl_idct_out_r_s  (m_mbpl_idct_out_r_s), 
   .m_frm_inter_mc_r     (m_frm_inter_mc_r), 
   .m_frm_prog_mc_r      (m_frm_prog_mc_r), 
   .m_frm_pred_over_mc_r (m_frm_pred_over_mc_r), 
   .m_frm_inter_uc_r     (m_frm_inter_uc_r), 
   .m_frm_prog_uc_r      (m_frm_prog_uc_r), 
   .m_frm_pred_over_uc_r (m_frm_pred_over_uc_r), 
   .m_frm_fidp_r         (m_frm_fidp_r), 
   .m_half_hpelf_r       (m_half_hpelf_r), 
   .m_half_vpelf_r       (m_half_vpelf_r), 
   .m_line17_cutf_r      (m_line17_cutf_r), 
   .m_half_hpelb_r       (m_half_hpelb_r), 
   .m_half_vpelb_r       (m_half_vpelb_r), 
   .m_line17_cutb_r      (m_line17_cutb_r), 
   .m_motion_dp_r        (m_motion_dp_r), 
   .m_hvec1y_r           (m_hvec1y_r), 
   .m_vvec1y_r           (m_vvec1y_r), 
   .m_hvec2y_r           (m_hvec2y_r), 
   .m_vvec2y_r           (m_vvec2y_r), 
   .m_hvec3y_r           (m_hvec3y_r), 
   .m_vvec3y_r           (m_vvec3y_r), 
   .m_hvec4y_r           (m_hvec4y_r), 
   .m_vvec4y_r           (m_vvec4y_r), 
   .m_hvec1c_r           (m_hvec1c_r), 
   .m_vvec1c_r           (m_vvec1c_r), 
   .m_hvec2c_r           (m_hvec2c_r), 
   .m_vvec2c_r           (m_vvec2c_r), 
   .m_hvec3c_r           (m_hvec3c_r), 
   .m_vvec3c_r           (m_vvec3c_r), 
   .m_hvec4c_r           (m_hvec4c_r), 
   .m_vvec4c_r           (m_vvec4c_r), 
   .clkdec             (clkdec), 
   .m_ref1yen_r          (m_ref1yen_r), 
   .m_ref1cen_r          (m_ref1cen_r), 
   .m_ref2yen_r          (m_ref2yen_r), 
   .m_ref2cen_r          (m_ref2cen_r), 
   .rstdec_x           (rstdec_x)
); 

mc_bmbarray mcbmb( 
   .clkdec       (clkdec), 
   .rstdec_x     (rstdec_x), 
   .v1_bmb00_a   (v1_bmb00_a), 
   .v1_bmb00_bs  (v1_bmb00_bs), 
   .v1_bmb00_d   (v1_bmb00_d), 
   .v1_bmb00_we  (v1_bmb00_we), 
   .w1_bmb00_q   (w1_bmb00_q),
   .v1_bmb01_a   (v1_bmb01_a), 
   .v1_bmb01_bs  (v1_bmb01_bs), 
   .v1_bmb01_d   (v1_bmb01_d), 
   .v1_bmb01_we  (v1_bmb01_we), 
   .w1_bmb01_q   (w1_bmb01_q),
   .v1_bmb02_a   (v1_bmb02_a), 
   .v1_bmb02_bs  (v1_bmb02_bs), 
   .v1_bmb02_d   (v1_bmb02_d), 
   .v1_bmb02_we  (v1_bmb02_we), 
   .w1_bmb02_q   (w1_bmb02_q)
   );

mc_ibearray mcibe( 
   .clkdec       (clkdec), 
   .rstdec_x     (rstdec_x), 
   .v1_ibe00_a   (v1_ibe00_a), 
   .v1_ibe00_bs  (v1_ibe00_bs), 
   .v1_ibe00_d   (v1_ibe00_d), 
   .v1_ibe00_we  (v1_ibe00_we), 
   .w1_ibe00_q   (w1_ibe00_q),
   .v1_ibe01_a   (v1_ibe01_a), 
   .v1_ibe01_bs  (v1_ibe01_bs), 
   .v1_ibe01_d   (v1_ibe01_d), 
   .v1_ibe01_we  (v1_ibe01_we), 
   .w1_ibe01_q   (w1_ibe01_q)
   );

mc_ibearray mcibo( 
   .clkdec       (clkdec), 
   .rstdec_x     (rstdec_x), 
   .v1_ibe00_a   (v1_ibo00_a), 
   .v1_ibe00_bs  (v1_ibo00_bs), 
   .v1_ibe00_d   (v1_ibo00_d), 
   .v1_ibe00_we  (v1_ibo00_we), 
   .w1_ibe00_q   (w1_ibo00_q),
   .v1_ibe01_a   (v1_ibo01_a), 
   .v1_ibe01_bs  (v1_ibo01_bs), 
   .v1_ibe01_d   (v1_ibo01_d), 
   .v1_ibe01_we  (v1_ibo01_we), 
   .w1_ibe01_q   (w1_ibo01_q)
   );

mc_ibearray mcife( 
   .clkdec       (clkdec), 
   .rstdec_x     (rstdec_x), 
   .v1_ibe00_a   (v1_ife00_a), 
   .v1_ibe00_bs  (v1_ife00_bs), 
   .v1_ibe00_d   (v1_ife00_d), 
   .v1_ibe00_we  (v1_ife00_we), 
   .w1_ibe00_q   (w1_ife00_q),
   .v1_ibe01_a   (v1_ife01_a), 
   .v1_ibe01_bs  (v1_ife01_bs), 
   .v1_ibe01_d   (v1_ife01_d), 
   .v1_ibe01_we  (v1_ife01_we), 
   .w1_ibe01_q   (w1_ife01_q)
   );

mc_ibearray mcifo( 
   .clkdec       (clkdec), 
   .rstdec_x     (rstdec_x), 
   .v1_ibe00_a   (v1_ifo00_a), 
   .v1_ibe00_bs  (v1_ifo00_bs), 
   .v1_ibe00_d   (v1_ifo00_d), 
   .v1_ibe00_we  (v1_ifo00_we), 
   .w1_ibe00_q   (w1_ifo00_q),
   .v1_ibe01_a   (v1_ifo01_a), 
   .v1_ibe01_bs  (v1_ifo01_bs), 
   .v1_ibe01_d   (v1_ifo01_d), 
   .v1_ibe01_we  (v1_ifo01_we), 
   .w1_ibe01_q   (w1_ifo01_q)
   );

mc_ritarray mcrit( 
   .clkdec       (clkdec), 
   .rstdec_x     (rstdec_x), 
   .v1_rit00_a   (v1_rit00_a), 
   .v1_rit00_bs  (v1_rit00_bs), 
   .v1_rit00_d   (v1_rit00_d), 
   .v1_rit00_we  (v1_rit00_we), 
   .w1_rit00_q   (w1_rit00_q),
   .v1_rit01_a   (v1_rit01_a), 
   .v1_rit01_bs  (v1_rit01_bs), 
   .v1_rit01_d   (v1_rit01_d), 
   .v1_rit01_we  (v1_rit01_we), 
   .w1_rit01_q   (w1_rit01_q)
   );

endmodule

