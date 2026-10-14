// ----------------------------------------------
// File: mc_hp.v
// Module: mc_hp
// Function:
// ----------------------------------------------

module mc_hp( 
   clkdec, 
   rstdec_x, 
   m_frm_inter_mc_r, 
   m_frm_inter_uc_r, 
   m_frm_pred_over_mc_r, 
   m_frm_pred_over_uc_r, 
   m_frm_prog_mc_r, 
   m_frm_prog_uc_r, 
   m_half_hpelf_r, 
   m_half_vpelf_r, 
   m_line17_cutf_r, 
   m_mbpl_mc_r_s, 
   m_mbpl_uc_r_s, 
   m_ref1cen_r, 
   m_ref1yen_r, 
   p_pred_forward_buc_r, 
   u_ref1dt_r, 
   w1_ife00_q, 
   w1_ife01_q, 
   w1_ifo00_q, 
   w1_ifo01_q, 
   v1_ife00_a, 
   v1_ife00_bs, 
   v1_ife00_d, 
   v1_ife00_we, 
   v1_ife01_a, 
   v1_ife01_bs, 
   v1_ife01_d, 
   v1_ife01_we, 
   v1_ifo00_a, 
   v1_ifo00_bs, 
   v1_ifo00_d, 
   v1_ifo00_we, 
   v1_ifo01_a, 
   v1_ifo01_bs, 
   v1_ifo01_d, 
   v1_ifo01_we, 
   m_halfvdt_r,
   m_motion_dp_r
);


input         clkdec;
input         rstdec_x;
input         m_frm_inter_mc_r;
input         m_frm_inter_uc_r;
input         m_frm_pred_over_mc_r;
input         m_frm_pred_over_uc_r;
input         m_frm_prog_mc_r;
input         m_frm_prog_uc_r;
input         m_half_hpelf_r;
input         m_half_vpelf_r;
input         m_line17_cutf_r;
input         m_mbpl_mc_r_s;
input         m_mbpl_uc_r_s;
input         m_ref1cen_r;
input         m_ref1yen_r;
input         p_pred_forward_buc_r;
input         m_motion_dp_r;
input  [15:0] u_ref1dt_r;
input  [17:0] w1_ife00_q;
input  [17:0] w1_ife01_q;
input  [17:0] w1_ifo00_q;
input  [17:0] w1_ifo01_q;
output [6:0]  v1_ife00_a;
output        v1_ife00_bs;
output [17:0] v1_ife00_d;
output        v1_ife00_we;
output [6:0]  v1_ife01_a;
output        v1_ife01_bs;
output [17:0] v1_ife01_d;
output        v1_ife01_we;
output [6:0]  v1_ifo00_a;
output        v1_ifo00_bs;
output [17:0] v1_ifo00_d;
output        v1_ifo00_we;
output [6:0]  v1_ifo01_a;
output        v1_ifo01_bs;
output [17:0] v1_ifo01_d;
output        v1_ifo01_we;
output [7:0]  m_halfvdt_r;


wire         clkdec;
wire         rstdec_x;
wire         m_frm_inter_mc_r;
wire         m_frm_inter_uc_r;
wire         m_frm_pred_over_mc_r;
wire         m_frm_pred_over_uc_r;
wire         m_frm_prog_mc_r;
wire         m_frm_prog_uc_r;
wire         m_half_hpelf_r;
wire         m_half_vpelf_r;
wire         m_line17_cutf_r;
wire         m_mbpl_mc_r_s;
wire         m_mbpl_uc_r_s;
wire         m_ref1cen_r;
wire         m_ref1yen_r;
wire         p_pred_forward_buc_r;
wire [15:0]  u_ref1dt_r;
wire [17:0]  w1_ife00_q;
wire [17:0]  w1_ife01_q;
wire [17:0]  w1_ifo00_q;
wire [17:0]  w1_ifo01_q;
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
wire [7:0]   m_halfvdt_r;

wire [17:0] m_halfhdt_r;
wire        m_line_sel_r;
wire [8:0]  m_scan_even_r;
wire [8:0]  m_scan_odd_r;


mc_fifr mc_fifr( 
   .clkdec               (clkdec), 
   .rstdec_x             (rstdec_x), 
   .m_halfhdt_r          (m_halfhdt_r), 
   .m_mbpl_mc_r_s        (m_mbpl_mc_r_s), 
   .m_mbpl_uc_r_s        (m_mbpl_uc_r_s), 
   .m_ref1yen_r          (m_ref1yen_r), 
   .m_ref1cen_r          (m_ref1cen_r), 
   .m_frm_inter_uc_r     (m_frm_inter_uc_r), 
   .m_frm_prog_uc_r      (m_frm_prog_uc_r), 
   .m_frm_pred_over_uc_r (m_frm_pred_over_uc_r), 
   .m_frm_inter_mc_r     (m_frm_inter_mc_r), 
   .m_frm_prog_mc_r      (m_frm_prog_mc_r), 
   .m_frm_pred_over_mc_r (m_frm_pred_over_mc_r), 
   .m_line17_cutf_r      (m_line17_cutf_r), 
   .p_pred_forward_buc_r (p_pred_forward_buc_r), 
   .m_scan_even_r        (m_scan_even_r), 
   .m_scan_odd_r         (m_scan_odd_r), 
   .m_line_sel_r         (m_line_sel_r), 
   .m_motion_dp_r         (m_motion_dp_r),
   .v1_ife00_a             (v1_ife00_a), 
   .v1_ife00_d             (v1_ife00_d), 
   .w1_ife00_q             (w1_ife00_q), 
   .v1_ife00_bs            (v1_ife00_bs), 
   .v1_ife00_we            (v1_ife00_we), 
   .v1_ife01_a             (v1_ife01_a), 
   .v1_ife01_d             (v1_ife01_d), 
   .w1_ife01_q             (w1_ife01_q), 
   .v1_ife01_bs            (v1_ife01_bs), 
   .v1_ife01_we            (v1_ife01_we), 
   .v1_ifo00_a             (v1_ifo00_a), 
   .v1_ifo00_d             (v1_ifo00_d), 
   .w1_ifo00_q             (w1_ifo00_q), 
   .v1_ifo00_bs            (v1_ifo00_bs), 
   .v1_ifo00_we            (v1_ifo00_we), 
   .v1_ifo01_a             (v1_ifo01_a), 
   .v1_ifo01_d             (v1_ifo01_d), 
   .w1_ifo01_q             (w1_ifo01_q), 
   .v1_ifo01_bs            (v1_ifo01_bs), 
   .v1_ifo01_we            (v1_ifo01_we)
); 

mc_hph mc_hph( 
   .clkdec         (clkdec), 
   .rstdec_x       (rstdec_x), 
   .m_half_hpelf_r (m_half_hpelf_r), 
   .u_ref1dt_r     (u_ref1dt_r), 
   .m_halfhdt_r    (m_halfhdt_r)
); 

mc_hpv mc_hpv( 
   .clkdec         (clkdec), 
   .rstdec_x       (rstdec_x), 
   .m_half_vpelf_r (m_half_vpelf_r), 
   .m_line_sel_r   (m_line_sel_r), 
   .m_scan_even_r  (m_scan_even_r), 
   .m_scan_odd_r   (m_scan_odd_r), 
   .m_halfvdt_r    (m_halfvdt_r)
); 

endmodule
