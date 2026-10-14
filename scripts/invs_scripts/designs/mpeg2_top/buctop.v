// ----------------------------------------------
// File: buctop.v
// Module: buctop
// Function:Media Bus I/F Top
// ----------------------------------------------

module buctop( 
   clkdec, 
   rstdec_x, 
   c_bfcnt_init_r, 
   c_mbpl_buc_r_s, 
   c_mbpl_uc_r_s, 
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
   m_vvec4y_r, 
   c_pcth_mb_r, 
   c_pctv_mb_r, 
   p_fldsel1_buc_r, 
   p_fldsel2_buc_r, 
   p_fldsel3_buc_r, 
   p_fldsel4_buc_r, 
   p_hdtvh_buc_r, 
   p_mbh_adr_buc_r, 
   p_mbv_adr_buc_r, 
   p_mttyp_buc_r, 
   p_pred_backward_buc_r, 
   p_pred_forward_buc_r, 
   p_prgseq_buc_r, 
   p_pstr_buc_r, 
   p_reffld_num1_buc_r, 
   p_reffld_num2_buc_r, 
   p_reffld_num3_buc_r, 
   p_reffld_num4_buc_r, 
   vrh_acceptance_r, 
   vrh_read_data_r, 
   vrh_read_enable_r, 
   f_addressx_r, 
   f_addressy_r, 
   f_bfud_err_r, 
   f_byte_num_r, 
   f_field_num_r, 
   f_hdtvh_r, 
   f_hvec1c_r, 
   f_hvec1y_r, 
   f_hvec2c_r, 
   f_hvec2y_r, 
   f_hvec3c_r, 
   f_hvec3y_r, 
   f_hvec4c_r, 
   f_hvec4y_r, 
   f_line_num_r, 
   f_mttyp_r, 
   f_pred_backward_buc_r, 
   f_pred_forward_buc_r, 
   f_prgseq_r, 
   f_ref1cen_r, 
   f_ref1dt_r, 
   f_ref1yen_r, 
   f_ref2cen_r, 
   f_ref2dt_r, 
   f_ref2yen_r, 
   f_request_r, 
   f_vec_err_r, 
   f_vvec1c_r, 
   f_vvec1y_r, 
   f_vvec2c_r, 
   f_vvec2y_r, 
   f_vvec3c_r, 
   f_vvec3y_r, 
   f_vvec4c_r, 
   f_vvec4y_r
);


input         clkdec;
input         rstdec_x;
input         c_bfcnt_init_r;
input         c_mbpl_buc_r_s;
input         c_mbpl_uc_r_s;
input  [10:0] m_hvec1c_r;
input  [11:0] m_hvec1y_r;
input  [10:0] m_hvec2c_r;
input  [11:0] m_hvec2y_r;
input  [10:0] m_hvec3c_r;
input  [11:0] m_hvec3y_r;
input  [10:0] m_hvec4c_r;
input  [11:0] m_hvec4y_r;
input  [6:0]  m_vvec1c_r;
input  [7:0]  m_vvec1y_r;
input  [6:0]  m_vvec2c_r;
input  [7:0]  m_vvec2y_r;
input  [6:0]  m_vvec3c_r;
input  [7:0]  m_vvec3y_r;
input  [6:0]  m_vvec4c_r;
input  [7:0]  m_vvec4y_r;
input  [6:0]  c_pcth_mb_r;
input  [6:0]  c_pctv_mb_r;
input         p_fldsel1_buc_r;
input         p_fldsel2_buc_r;
input         p_fldsel3_buc_r;
input         p_fldsel4_buc_r;
input         p_hdtvh_buc_r;
input  [6:0]  p_mbh_adr_buc_r;
input  [6:0]  p_mbv_adr_buc_r;
input  [1:0]  p_mttyp_buc_r;
input         p_pred_backward_buc_r;
input         p_pred_forward_buc_r;
input         p_prgseq_buc_r;
input  [1:0]  p_pstr_buc_r;
input  [3:0]  p_reffld_num1_buc_r;
input  [3:0]  p_reffld_num2_buc_r;
input  [3:0]  p_reffld_num3_buc_r;
input  [3:0]  p_reffld_num4_buc_r;
input         vrh_acceptance_r;
input  [63:0] vrh_read_data_r;
input         vrh_read_enable_r;
output [10:0] f_addressx_r;
output [9:0]  f_addressy_r;
output        f_bfud_err_r;
output [1:0]  f_byte_num_r;
output [3:0]  f_field_num_r;
output        f_hdtvh_r;
output [2:0]  f_hvec1c_r;
output [3:0]  f_hvec1y_r;
output [2:0]  f_hvec2c_r;
output [3:0]  f_hvec2y_r;
output [2:0]  f_hvec3c_r;
output [3:0]  f_hvec3y_r;
output [2:0]  f_hvec4c_r;
output [3:0]  f_hvec4y_r;
output [2:0]  f_line_num_r;
output [1:0]  f_mttyp_r;
output        f_pred_backward_buc_r;
output        f_pred_forward_buc_r;
output        f_prgseq_r;
output        f_ref1cen_r;
output [63:0] f_ref1dt_r;
output        f_ref1yen_r;
output        f_ref2cen_r;
output [63:0] f_ref2dt_r;
output        f_ref2yen_r;
output        f_request_r;
output        f_vec_err_r;
output [1:0]  f_vvec1c_r;
output [2:0]  f_vvec1y_r;
output [1:0]  f_vvec2c_r;
output [2:0]  f_vvec2y_r;
output [1:0]  f_vvec3c_r;
output [2:0]  f_vvec3y_r;
output [1:0]  f_vvec4c_r;
output [2:0]  f_vvec4y_r;


wire         clkdec;
wire         rstdec_x;
wire         c_bfcnt_init_r;
wire         c_mbpl_buc_r_s;
wire         c_mbpl_uc_r_s;
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
wire [6:0]   c_pcth_mb_r;
wire [6:0]   c_pctv_mb_r;
wire         p_fldsel1_buc_r;
wire         p_fldsel2_buc_r;
wire         p_fldsel3_buc_r;
wire         p_fldsel4_buc_r;
wire         p_hdtvh_buc_r;
wire [6:0]   p_mbh_adr_buc_r;
wire [6:0]   p_mbv_adr_buc_r;
wire [1:0]   p_mttyp_buc_r;
wire         p_pred_backward_buc_r;
wire         p_pred_forward_buc_r;
wire         p_prgseq_buc_r;
wire [1:0]   p_pstr_buc_r;
wire [3:0]   p_reffld_num1_buc_r;
wire [3:0]   p_reffld_num2_buc_r;
wire [3:0]   p_reffld_num3_buc_r;
wire [3:0]   p_reffld_num4_buc_r;
wire         vrh_acceptance_r;
wire [63:0]  vrh_read_data_r;
wire         vrh_read_enable_r;
wire [63:0]  w1_rfa00_q;
wire [63:0]  w1_rfa01_q;
wire [63:0]  w1_rfa02_q;
wire [63:0]  w1_rfa03_q;
wire [63:0]  w1_rfa04_q;
wire [63:0]  w1_rfa05_q;
wire [15:0]  w1_rfb00_q;
wire [15:0]  w1_rfb01_q;
wire [15:0]  w1_rfb02_q;
wire [15:0]  w1_rfb03_q;
wire [15:0]  w1_rfb04_q;
wire [15:0]  w1_rfb05_q;
wire [5:0]   v1_rfa00_a;
wire         v1_rfa00_bs;
wire [63:0]  v1_rfa00_d;
wire         v1_rfa00_we;
wire [5:0]   v1_rfa01_a;
wire         v1_rfa01_bs;
wire [63:0]  v1_rfa01_d;
wire         v1_rfa01_we;
wire [5:0]   v1_rfa02_a;
wire         v1_rfa02_bs;
wire [63:0]  v1_rfa02_d;
wire         v1_rfa02_we;
wire [5:0]   v1_rfa03_a;
wire         v1_rfa03_bs;
wire [63:0]  v1_rfa03_d;
wire         v1_rfa03_we;
wire [5:0]   v1_rfa04_a;
wire         v1_rfa04_bs;
wire [63:0]  v1_rfa04_d;
wire         v1_rfa04_we;
wire [5:0]   v1_rfa05_a;
wire         v1_rfa05_bs;
wire [63:0]  v1_rfa05_d;
wire         v1_rfa05_we;
wire [4:0]   v1_rfb00_a;
wire         v1_rfb00_bs;
wire [15:0]  v1_rfb00_d;
wire         v1_rfb00_we;
wire [4:0]   v1_rfb01_a;
wire         v1_rfb01_bs;
wire [15:0]  v1_rfb01_d;
wire         v1_rfb01_we;
wire [4:0]   v1_rfb02_a;
wire         v1_rfb02_bs;
wire [15:0]  v1_rfb02_d;
wire         v1_rfb02_we;
wire [4:0]   v1_rfb03_a;
wire         v1_rfb03_bs;
wire [15:0]  v1_rfb03_d;
wire         v1_rfb03_we;
wire [4:0]   v1_rfb04_a;
wire         v1_rfb04_bs;
wire [15:0]  v1_rfb04_d;
wire         v1_rfb04_we;
wire [4:0]   v1_rfb05_a;
wire         v1_rfb05_bs;
wire [15:0]  v1_rfb05_d;
wire         v1_rfb05_we;
wire [10:0]  f_addressx_r;
wire [9:0]   f_addressy_r;
wire         f_bfud_err_r;
wire [1:0]   f_byte_num_r;
wire [3:0]   f_field_num_r;
wire         f_hdtvh_r;
wire [2:0]   f_hvec1c_r;
wire [3:0]   f_hvec1y_r;
wire [2:0]   f_hvec2c_r;
wire [3:0]   f_hvec2y_r;
wire [2:0]   f_hvec3c_r;
wire [3:0]   f_hvec3y_r;
wire [2:0]   f_hvec4c_r;
wire [3:0]   f_hvec4y_r;
wire [2:0]   f_line_num_r;
wire [1:0]   f_mttyp_r;
wire         f_pred_backward_buc_r;
wire         f_pred_forward_buc_r;
wire         f_prgseq_r;
wire         f_ref1cen_r;
wire [63:0]  f_ref1dt_r;
wire         f_ref1yen_r;
wire         f_ref2cen_r;
wire [63:0]  f_ref2dt_r;
wire         f_ref2yen_r;
wire         f_request_r;
wire         f_vec_err_r;
wire [1:0]   f_vvec1c_r;
wire [2:0]   f_vvec1y_r;
wire [1:0]   f_vvec2c_r;
wire [2:0]   f_vvec2y_r;
wire [1:0]   f_vvec3c_r;
wire [2:0]   f_vvec3y_r;
wire [1:0]   f_vvec4c_r;
wire [2:0]   f_vvec4y_r;

wire       f_bfcnt_init_r;
wire       f_mbpl_buc_d1_r_s;
wire       f_whdtvh_r;
wire [2:0] f_whvec1c_r;
wire [3:0] f_whvec1y_r;
wire [2:0] f_whvec2c_r;
wire [3:0] f_whvec2y_r;
wire [2:0] f_whvec3c_r;
wire [3:0] f_whvec3y_r;
wire [2:0] f_whvec4c_r;
wire [3:0] f_whvec4y_r;
wire [1:0] f_wmttyp_r;
wire       f_wpred_backward_buc_r;
wire       f_wpred_forward_buc_r;
wire       f_w2pred_backward_r;
wire       f_w2pred_forward_r;
wire       f_wprgseq_r;
wire [1:0] f_wvvec1c_r;
wire [2:0] f_wvvec1y_r;
wire [1:0] f_wvvec2c_r;
wire [2:0] f_wvvec2y_r;
wire [1:0] f_wvvec3c_r;
wire [2:0] f_wvvec3y_r;
wire [1:0] f_wvvec4c_r;
wire [2:0] f_wvvec4y_r;
wire       f_regwen_r;


buc_ifictl buc_ifictl( 
   .clkdec                   (clkdec), 
   .rstdec_x                 (rstdec_x), 
   .c_mbpl_buc_r_s         (c_mbpl_buc_r_s), 
   .c_pcth_mb_r            (c_pcth_mb_r), 
   .c_pctv_mb_r            (c_pctv_mb_r), 
   .p_hdtvh_buc_r          (p_hdtvh_buc_r), 
   .p_prgseq_buc_r         (p_prgseq_buc_r), 
   .p_pstr_buc_r           (p_pstr_buc_r), 
   .p_pred_forward_buc_r   (p_pred_forward_buc_r), 
   .p_pred_backward_buc_r  (p_pred_backward_buc_r), 
   .p_mttyp_buc_r          (p_mttyp_buc_r), 
   .p_fldsel1_buc_r        (p_fldsel1_buc_r), 
   .p_fldsel2_buc_r        (p_fldsel2_buc_r), 
   .p_fldsel3_buc_r        (p_fldsel3_buc_r), 
   .p_fldsel4_buc_r        (p_fldsel4_buc_r), 
   .m_hvec1y_r             (m_hvec1y_r), 
   .m_vvec1y_r             (m_vvec1y_r), 
   .m_hvec2y_r             (m_hvec2y_r), 
   .m_vvec2y_r             (m_vvec2y_r), 
   .m_hvec3y_r             (m_hvec3y_r), 
   .m_vvec3y_r             (m_vvec3y_r), 
   .m_hvec4y_r             (m_hvec4y_r), 
   .m_vvec4y_r             (m_vvec4y_r), 
   .m_hvec1c_r             (m_hvec1c_r), 
   .m_vvec1c_r             (m_vvec1c_r), 
   .m_hvec2c_r             (m_hvec2c_r), 
   .m_vvec2c_r             (m_vvec2c_r), 
   .m_hvec3c_r             (m_hvec3c_r), 
   .m_vvec3c_r             (m_vvec3c_r), 
   .m_hvec4c_r             (m_hvec4c_r), 
   .m_vvec4c_r             (m_vvec4c_r), 
   .p_reffld_num1_buc_r    (p_reffld_num1_buc_r), 
   .p_reffld_num2_buc_r    (p_reffld_num2_buc_r), 
   .p_reffld_num3_buc_r    (p_reffld_num3_buc_r), 
   .p_reffld_num4_buc_r    (p_reffld_num4_buc_r), 
   .p_mbh_adr_buc_r        (p_mbh_adr_buc_r), 
   .p_mbv_adr_buc_r        (p_mbv_adr_buc_r), 
   .vrh_acceptance_r         (vrh_acceptance_r), 
   .f_bfcnt_init_r         (f_bfcnt_init_r), 
   .f_vec_err_r            (f_vec_err_r), 
   .f_request_r            (f_request_r), 
   .f_field_num_r          (f_field_num_r), 
   .f_addressx_r           (f_addressx_r), 
   .f_addressy_r           (f_addressy_r), 
   .f_byte_num_r           (f_byte_num_r), 
   .f_line_num_r           (f_line_num_r), 
   .f_whdtvh_r             (f_whdtvh_r), 
   .f_wprgseq_r            (f_wprgseq_r), 
   .f_wpred_forward_buc_r  (f_wpred_forward_buc_r), 
   .f_wpred_backward_buc_r (f_wpred_backward_buc_r), 
   .f_w2pred_forward_r     (f_w2pred_forward_r), 
   .f_w2pred_backward_r    (f_w2pred_backward_r), 
   .f_wmttyp_r             (f_wmttyp_r), 
   .f_whvec1y_r            (f_whvec1y_r), 
   .f_wvvec1y_r            (f_wvvec1y_r), 
   .f_whvec2y_r            (f_whvec2y_r), 
   .f_wvvec2y_r            (f_wvvec2y_r), 
   .f_whvec3y_r            (f_whvec3y_r), 
   .f_wvvec3y_r            (f_wvvec3y_r), 
   .f_whvec4y_r            (f_whvec4y_r), 
   .f_wvvec4y_r            (f_wvvec4y_r), 
   .f_whvec1c_r            (f_whvec1c_r), 
   .f_wvvec1c_r            (f_wvvec1c_r), 
   .f_whvec2c_r            (f_whvec2c_r), 
   .f_wvvec2c_r            (f_wvvec2c_r), 
   .f_whvec3c_r            (f_whvec3c_r), 
   .f_wvvec3c_r            (f_wvvec3c_r), 
   .f_whvec4c_r            (f_whvec4c_r), 
   .f_wvvec4c_r            (f_wvvec4c_r), 
   .f_mbpl_buc_d1_r_s      (f_mbpl_buc_d1_r_s),
   .f_regwen_r             (f_regwen_r)
); 

buc_srctl buc_srctl( 
   .clkdec                   (clkdec), 
   .rstdec_x                 (rstdec_x), 
   .c_mbpl_uc_r_s          (c_mbpl_uc_r_s), 
   .c_bfcnt_init_r         (c_bfcnt_init_r), 
   .vrh_read_data_r          (vrh_read_data_r), 
   .vrh_read_enable_r        (vrh_read_enable_r), 
   .f_whdtvh_r             (f_whdtvh_r), 
   .f_wprgseq_r            (f_wprgseq_r), 
   .f_wpred_forward_buc_r  (f_wpred_forward_buc_r), 
   .f_wpred_backward_buc_r (f_wpred_backward_buc_r), 
   .f_w2pred_forward_r     (f_w2pred_forward_r), 
   .f_w2pred_backward_r    (f_w2pred_backward_r), 
   .f_wmttyp_r             (f_wmttyp_r), 
   .f_whvec1y_r            (f_whvec1y_r), 
   .f_wvvec1y_r            (f_wvvec1y_r), 
   .f_whvec2y_r            (f_whvec2y_r), 
   .f_wvvec2y_r            (f_wvvec2y_r), 
   .f_whvec3y_r            (f_whvec3y_r), 
   .f_wvvec3y_r            (f_wvvec3y_r), 
   .f_whvec4y_r            (f_whvec4y_r), 
   .f_wvvec4y_r            (f_wvvec4y_r), 
   .f_whvec1c_r            (f_whvec1c_r), 
   .f_wvvec1c_r            (f_wvvec1c_r), 
   .f_whvec2c_r            (f_whvec2c_r), 
   .f_wvvec2c_r            (f_wvvec2c_r), 
   .f_whvec3c_r            (f_whvec3c_r), 
   .f_wvvec3c_r            (f_wvvec3c_r), 
   .f_whvec4c_r            (f_whvec4c_r), 
   .f_wvvec4c_r            (f_wvvec4c_r), 
   .w1_rfa00_q               (w1_rfa00_q), 
   .w1_rfb00_q               (w1_rfb00_q), 
   .w1_rfa01_q               (w1_rfa01_q), 
   .w1_rfb01_q               (w1_rfb01_q), 
   .w1_rfa02_q               (w1_rfa02_q), 
   .w1_rfb02_q               (w1_rfb02_q), 
   .w1_rfa03_q               (w1_rfa03_q), 
   .w1_rfb03_q               (w1_rfb03_q), 
   .w1_rfa04_q               (w1_rfa04_q), 
   .w1_rfb04_q               (w1_rfb04_q), 
   .w1_rfa05_q               (w1_rfa05_q), 
   .w1_rfb05_q               (w1_rfb05_q), 
   .f_mbpl_buc_d1_r_s      (f_mbpl_buc_d1_r_s), 
   .f_regwen_r             (f_regwen_r),
   .f_ref1dt_r             (f_ref1dt_r), 
   .f_ref1yen_r            (f_ref1yen_r), 
   .f_ref1cen_r            (f_ref1cen_r), 
   .f_ref2dt_r             (f_ref2dt_r), 
   .f_ref2yen_r            (f_ref2yen_r), 
   .f_ref2cen_r            (f_ref2cen_r), 
   .f_hdtvh_r              (f_hdtvh_r), 
   .f_prgseq_r             (f_prgseq_r), 
   .f_pred_forward_buc_r   (f_pred_forward_buc_r), 
   .f_pred_backward_buc_r  (f_pred_backward_buc_r), 
   .f_mttyp_r              (f_mttyp_r), 
   .f_hvec1y_r             (f_hvec1y_r), 
   .f_vvec1y_r             (f_vvec1y_r), 
   .f_hvec2y_r             (f_hvec2y_r), 
   .f_vvec2y_r             (f_vvec2y_r), 
   .f_hvec3y_r             (f_hvec3y_r), 
   .f_vvec3y_r             (f_vvec3y_r), 
   .f_hvec4y_r             (f_hvec4y_r), 
   .f_vvec4y_r             (f_vvec4y_r), 
   .f_hvec1c_r             (f_hvec1c_r), 
   .f_vvec1c_r             (f_vvec1c_r), 
   .f_hvec2c_r             (f_hvec2c_r), 
   .f_vvec2c_r             (f_vvec2c_r), 
   .f_hvec3c_r             (f_hvec3c_r), 
   .f_vvec3c_r             (f_vvec3c_r), 
   .f_hvec4c_r             (f_hvec4c_r), 
   .f_vvec4c_r             (f_vvec4c_r), 
   .f_bfud_err_r           (f_bfud_err_r), 
   .v1_rfa00_a               (v1_rfa00_a), 
   .v1_rfa00_d               (v1_rfa00_d), 
   .v1_rfa00_bs              (v1_rfa00_bs), 
   .v1_rfa00_we              (v1_rfa00_we), 
   .v1_rfb00_a               (v1_rfb00_a), 
   .v1_rfb00_d               (v1_rfb00_d), 
   .v1_rfb00_bs              (v1_rfb00_bs), 
   .v1_rfb00_we              (v1_rfb00_we), 
   .v1_rfa01_a               (v1_rfa01_a), 
   .v1_rfa01_d               (v1_rfa01_d), 
   .v1_rfa01_bs              (v1_rfa01_bs), 
   .v1_rfa01_we              (v1_rfa01_we), 
   .v1_rfb01_a               (v1_rfb01_a), 
   .v1_rfb01_d               (v1_rfb01_d), 
   .v1_rfb01_bs              (v1_rfb01_bs), 
   .v1_rfb01_we              (v1_rfb01_we), 
   .v1_rfa02_a               (v1_rfa02_a), 
   .v1_rfa02_d               (v1_rfa02_d), 
   .v1_rfa02_bs              (v1_rfa02_bs), 
   .v1_rfa02_we              (v1_rfa02_we), 
   .v1_rfb02_a               (v1_rfb02_a), 
   .v1_rfb02_d               (v1_rfb02_d), 
   .v1_rfb02_bs              (v1_rfb02_bs), 
   .v1_rfb02_we              (v1_rfb02_we), 
   .v1_rfa03_a               (v1_rfa03_a), 
   .v1_rfa03_d               (v1_rfa03_d), 
   .v1_rfa03_bs              (v1_rfa03_bs), 
   .v1_rfa03_we              (v1_rfa03_we), 
   .v1_rfb03_a               (v1_rfb03_a), 
   .v1_rfb03_d               (v1_rfb03_d), 
   .v1_rfb03_bs              (v1_rfb03_bs), 
   .v1_rfb03_we              (v1_rfb03_we), 
   .v1_rfa04_a               (v1_rfa04_a), 
   .v1_rfa04_d               (v1_rfa04_d), 
   .v1_rfa04_bs              (v1_rfa04_bs), 
   .v1_rfa04_we              (v1_rfa04_we), 
   .v1_rfb04_a               (v1_rfb04_a), 
   .v1_rfb04_d               (v1_rfb04_d), 
   .v1_rfb04_bs              (v1_rfb04_bs), 
   .v1_rfb04_we              (v1_rfb04_we), 
   .v1_rfa05_a               (v1_rfa05_a), 
   .v1_rfa05_d               (v1_rfa05_d), 
   .v1_rfa05_bs              (v1_rfa05_bs), 
   .v1_rfa05_we              (v1_rfa05_we), 
   .v1_rfb05_a               (v1_rfb05_a), 
   .v1_rfb05_d               (v1_rfb05_d), 
   .v1_rfb05_bs              (v1_rfb05_bs), 
   .v1_rfb05_we              (v1_rfb05_we), 
   .f_bfcnt_init_r         (f_bfcnt_init_r)
); 

buc_rfaarray bucrfa(
   .clkdec       (clkdec),
   .rstdec_x     (rstdec_x),
   .v1_rfa00_a   (v1_rfa00_a),
   .v1_rfa00_bs  (v1_rfa00_bs),
   .v1_rfa00_d   (v1_rfa00_d),
   .v1_rfa00_we  (v1_rfa00_we),
   .w1_rfa00_q   (w1_rfa00_q),
   .v1_rfa01_a   (v1_rfa01_a),
   .v1_rfa01_bs  (v1_rfa01_bs),
   .v1_rfa01_d   (v1_rfa01_d),
   .v1_rfa01_we  (v1_rfa01_we),
   .w1_rfa01_q   (w1_rfa01_q),
   .v1_rfa02_a   (v1_rfa02_a),
   .v1_rfa02_bs  (v1_rfa02_bs),
   .v1_rfa02_d   (v1_rfa02_d),
   .v1_rfa02_we  (v1_rfa02_we),
   .w1_rfa02_q   (w1_rfa02_q),
   .v1_rfa03_a   (v1_rfa03_a),
   .v1_rfa03_bs  (v1_rfa03_bs),
   .v1_rfa03_d   (v1_rfa03_d),
   .v1_rfa03_we  (v1_rfa03_we),
   .w1_rfa03_q   (w1_rfa03_q),
   .v1_rfa04_a   (v1_rfa04_a),
   .v1_rfa04_bs  (v1_rfa04_bs),
   .v1_rfa04_d   (v1_rfa04_d),
   .v1_rfa04_we  (v1_rfa04_we),
   .w1_rfa04_q   (w1_rfa04_q),
   .v1_rfa05_a   (v1_rfa05_a),
   .v1_rfa05_bs  (v1_rfa05_bs),
   .v1_rfa05_d   (v1_rfa05_d),
   .v1_rfa05_we  (v1_rfa05_we),
   .w1_rfa05_q   (w1_rfa05_q)
   );

buc_rfbarray bucrfb(
   .clkdec       (clkdec),
   .rstdec_x     (rstdec_x),
   .v1_rfb00_a   (v1_rfb00_a),
   .v1_rfb00_bs  (v1_rfb00_bs),
   .v1_rfb00_d   (v1_rfb00_d),
   .v1_rfb00_we  (v1_rfb00_we),
   .w1_rfb00_q   (w1_rfb00_q),
   .v1_rfb01_a   (v1_rfb01_a),
   .v1_rfb01_bs  (v1_rfb01_bs),
   .v1_rfb01_d   (v1_rfb01_d),
   .v1_rfb01_we  (v1_rfb01_we),
   .w1_rfb01_q   (w1_rfb01_q),
   .v1_rfb02_a   (v1_rfb02_a),
   .v1_rfb02_bs  (v1_rfb02_bs),
   .v1_rfb02_d   (v1_rfb02_d),
   .v1_rfb02_we  (v1_rfb02_we),
   .w1_rfb02_q   (w1_rfb02_q),
   .v1_rfb03_a   (v1_rfb03_a),
   .v1_rfb03_bs  (v1_rfb03_bs),
   .v1_rfb03_d   (v1_rfb03_d),
   .v1_rfb03_we  (v1_rfb03_we),
   .w1_rfb03_q   (w1_rfb03_q),
   .v1_rfb04_a   (v1_rfb04_a),
   .v1_rfb04_bs  (v1_rfb04_bs),
   .v1_rfb04_d   (v1_rfb04_d),
   .v1_rfb04_we  (v1_rfb04_we),
   .w1_rfb04_q   (w1_rfb04_q),
   .v1_rfb05_a   (v1_rfb05_a),
   .v1_rfb05_bs  (v1_rfb05_bs),
   .v1_rfb05_d   (v1_rfb05_d),
   .v1_rfb05_we  (v1_rfb05_we),
   .w1_rfb05_q   (w1_rfb05_q)
   );

endmodule
