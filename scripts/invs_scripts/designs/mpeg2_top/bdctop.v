// ----------------------------------------------
// File: bdctop.v
// Module: bdctop
// Function:Inverse BDC TOP
// ----------------------------------------------

module bdctop( 
   clkdec, 
   rstdec_x, 
   c_bfcnt_init_r, 
   c_mbpl_dc_r_s, 
   d_decv_cen_r, 
   d_decv_dt_r, 
   d_decv_yen_r, 
   n_decfld_num1_r, 
   n_decfld_num2_r, 
   p_hdtvh_dc_r, 
   p_mbh_adr_dc_r, 
   p_mbv_adr_dc_r, 
   p_prgseq_dc_r, 
   p_pstr_dc_r, 
   vwh_acceptance_r, 
   vwh_data_wait, 
   b_addressx_r, 
   b_addressy_r, 
   b_bfov_err_r, 
   b_byte_num_r, 
   b_field_num_r, 
   b_line_num_r, 
   b_request_r, 
   b_write_data, 
   b_write_enable_r
);

input         clkdec;
input         rstdec_x;
input         c_bfcnt_init_r;
input         c_mbpl_dc_r_s;
input         d_decv_cen_r;
input  [15:0] d_decv_dt_r;
input         d_decv_yen_r;
input  [3:0]  n_decfld_num1_r;
input  [3:0]  n_decfld_num2_r;
input         p_hdtvh_dc_r;
input  [6:0]  p_mbh_adr_dc_r;
input  [6:0]  p_mbv_adr_dc_r;
input         p_prgseq_dc_r;
input  [1:0]  p_pstr_dc_r;
input         vwh_acceptance_r;
input         vwh_data_wait;
output [7:0]  b_addressx_r;
output [8:0]  b_addressy_r;
output        b_bfov_err_r;
output [1:0]  b_byte_num_r;
output [3:0]  b_field_num_r;
output [2:0]  b_line_num_r;
output        b_request_r;
output [63:0] b_write_data;
output        b_write_enable_r;


wire         clkdec;
wire         rstdec_x;
wire         c_bfcnt_init_r;
wire         c_mbpl_dc_r_s;
wire         d_decv_cen_r;
wire [15:0]  d_decv_dt_r;
wire         d_decv_yen_r;
wire [3:0]   n_decfld_num1_r;
wire [3:0]   n_decfld_num2_r;
wire         p_hdtvh_dc_r;
wire [6:0]   p_mbh_adr_dc_r;
wire [6:0]   p_mbv_adr_dc_r;
wire         p_prgseq_dc_r;
wire [1:0]   p_pstr_dc_r;
wire         vwh_acceptance_r;
wire         vwh_data_wait;
wire [63:0]  w1_rcn00_q;
wire [63:0]  w1_rcn01_q;
wire [63:0]  w1_rcn02_q;
wire [5:0]   v1_rcn00_a;
wire         v1_rcn00_bs;
wire [63:0]  v1_rcn00_d;
wire         v1_rcn00_we;
wire [5:0]   v1_rcn01_a;
wire         v1_rcn01_bs;
wire [63:0]  v1_rcn01_d;
wire         v1_rcn01_we;
wire [5:0]   v1_rcn02_a;
wire         v1_rcn02_bs;
wire [63:0]  v1_rcn02_d;
wire         v1_rcn02_we;
wire [7:0]   b_addressx_r;
wire [8:0]   b_addressy_r;
wire         b_bfov_err_r;
wire [1:0]   b_byte_num_r;
wire [3:0]   b_field_num_r;
wire [2:0]   b_line_num_r;
wire         b_request_r;
wire [63:0]  b_write_data;
wire         b_write_enable_r;

wire       b_bfcnt_init_r;
wire       b_dtflg0_r;
wire       b_dtflg1_r;
wire       b_dtflg2_r;
wire [3:0] b_fld_numb_r;
wire [3:0] b_fld_numt_r;
wire       b_hdtvh_r;
wire [7:0] b_mbh_adr_r;
wire       b_mbpl_r_s;
wire [8:0] b_mbvb_adr_r;
wire [8:0] b_mbvt_adr_r;
wire       b_prgseq_r;
wire       b_rdhdtvh_r;
wire       b_rdreq0;
wire       b_rdreq1;
wire       b_rdreq2;


bdc_ifoctl bdc_ifoctl( 
   .clkdec           (clkdec), 
   .rstdec_x         (rstdec_x), 
   .vwh_acceptance_r (vwh_acceptance_r), 
   .vwh_data_wait    (vwh_data_wait), 
   .w1_rcn00_q       (w1_rcn00_q), 
   .w1_rcn01_q       (w1_rcn01_q), 
   .w1_rcn02_q       (w1_rcn02_q), 
   .b_dtflg0_r       (b_dtflg0_r), 
   .b_dtflg1_r       (b_dtflg1_r), 
   .b_dtflg2_r       (b_dtflg2_r), 
   .b_hdtvh_r        (b_hdtvh_r), 
   .b_fld_numt_r     (b_fld_numt_r), 
   .b_fld_numb_r     (b_fld_numb_r), 
   .b_mbh_adr_r      (b_mbh_adr_r), 
   .b_mbvt_adr_r     (b_mbvt_adr_r), 
   .b_mbvb_adr_r     (b_mbvb_adr_r), 
   .b_bfcnt_init_r   (b_bfcnt_init_r), 
   .b_request_r      (b_request_r), 
   .b_field_num_r    (b_field_num_r), 
   .b_addressx_r     (b_addressx_r), 
   .b_addressy_r     (b_addressy_r), 
   .b_byte_num_r     (b_byte_num_r), 
   .b_line_num_r     (b_line_num_r), 
   .b_write_data     (b_write_data), 
   .b_write_enable_r (b_write_enable_r), 
   .b_rdhdtvh_r      (b_rdhdtvh_r), 
   .b_rdreq0         (b_rdreq0), 
   .b_rdreq1         (b_rdreq1), 
   .b_rdreq2         (b_rdreq2)
); 

bdc_sdictl bdc_sdictl( 
   .clkdec          (clkdec), 
   .rstdec_x        (rstdec_x), 
   .p_hdtvh_dc_r    (p_hdtvh_dc_r), 
   .p_prgseq_dc_r   (p_prgseq_dc_r), 
   .p_pstr_dc_r     (p_pstr_dc_r), 
   .n_decfld_num1_r (n_decfld_num1_r), 
   .n_decfld_num2_r (n_decfld_num2_r), 
   .p_mbh_adr_dc_r  (p_mbh_adr_dc_r), 
   .p_mbv_adr_dc_r  (p_mbv_adr_dc_r), 
   .b_mbpl_r_s      (b_mbpl_r_s), 
   .b_hdtvh_r       (b_hdtvh_r), 
   .b_prgseq_r      (b_prgseq_r), 
   .b_fld_numt_r    (b_fld_numt_r), 
   .b_fld_numb_r    (b_fld_numb_r), 
   .b_mbh_adr_r     (b_mbh_adr_r), 
   .b_mbvt_adr_r    (b_mbvt_adr_r), 
   .b_mbvb_adr_r    (b_mbvb_adr_r)
); 

bdc_srctl bdc_srctl( 
   .clkdec         (clkdec), 
   .rstdec_x       (rstdec_x), 
   .vwh_data_wait  (vwh_data_wait), 
   .c_mbpl_dc_r_s  (c_mbpl_dc_r_s), 
   .c_bfcnt_init_r (c_bfcnt_init_r), 
   .d_decv_dt_r    (d_decv_dt_r), 
   .d_decv_yen_r   (d_decv_yen_r), 
   .d_decv_cen_r   (d_decv_cen_r), 
   .b_hdtvh_r      (b_hdtvh_r), 
   .b_prgseq_r     (b_prgseq_r), 
   .b_rdreq0       (b_rdreq0), 
   .b_rdreq1       (b_rdreq1), 
   .b_rdreq2       (b_rdreq2), 
   .b_rdhdtvh_r    (b_rdhdtvh_r), 
   .b_bfov_err_r   (b_bfov_err_r), 
   .v1_rcn00_a       (v1_rcn00_a), 
   .v1_rcn00_d       (v1_rcn00_d), 
   .v1_rcn00_bs      (v1_rcn00_bs), 
   .v1_rcn00_we      (v1_rcn00_we), 
   .v1_rcn01_a       (v1_rcn01_a), 
   .v1_rcn01_d       (v1_rcn01_d), 
   .v1_rcn01_bs      (v1_rcn01_bs), 
   .v1_rcn01_we      (v1_rcn01_we), 
   .v1_rcn02_a       (v1_rcn02_a), 
   .v1_rcn02_d       (v1_rcn02_d), 
   .v1_rcn02_bs      (v1_rcn02_bs), 
   .v1_rcn02_we      (v1_rcn02_we), 
   .b_mbpl_r_s     (b_mbpl_r_s), 
   .b_dtflg0_r     (b_dtflg0_r), 
   .b_dtflg1_r     (b_dtflg1_r), 
   .b_dtflg2_r     (b_dtflg2_r), 
   .b_bfcnt_init_r (b_bfcnt_init_r)
); 

bdc_rcnarray bdcrcn(
   .clkdec       (clkdec),
   .rstdec_x     (rstdec_x),
   .v1_rcn00_a   (v1_rcn00_a),
   .v1_rcn00_bs  (v1_rcn00_bs),
   .v1_rcn00_d   (v1_rcn00_d),
   .v1_rcn00_we  (v1_rcn00_we),
   .w1_rcn00_q   (w1_rcn00_q),
   .v1_rcn01_a   (v1_rcn01_a),
   .v1_rcn01_bs  (v1_rcn01_bs),
   .v1_rcn01_d   (v1_rcn01_d),
   .v1_rcn01_we  (v1_rcn01_we),
   .w1_rcn01_q   (w1_rcn01_q),
   .v1_rcn02_a   (v1_rcn02_a),
   .v1_rcn02_bs  (v1_rcn02_bs),
   .v1_rcn02_d   (v1_rcn02_d),
   .v1_rcn02_we  (v1_rcn02_we),
   .w1_rcn02_q   (w1_rcn02_q)
   );


endmodule
