// ----------------------------------------------
// File: uctop.v
// Module: uctop
// Function:Up Convert Top
// ----------------------------------------------

module uctop( 
   clkdec, 
   rstdec_x, 
   c_mbpl_uc_r_s, 
   f_hdtvh_r, 
   f_hvec1c_r, 
   f_hvec1y_r, 
   f_hvec2c_r, 
   f_hvec2y_r, 
   f_hvec3c_r, 
   f_hvec3y_r, 
   f_hvec4c_r, 
   f_hvec4y_r, 
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
   f_vvec1c_r, 
   f_vvec1y_r, 
   f_vvec2c_r, 
   f_vvec2y_r, 
   f_vvec3c_r, 
   f_vvec3y_r, 
   f_vvec4c_r, 
   f_vvec4y_r, 
   u_ref1cen_r, 
   u_ref1dt_r, 
   u_ref1yen_r, 
   u_ref2cen_r, 
   u_ref2dt_r, 
   u_ref2yen_r
);


input         clkdec;
input         rstdec_x;
input         c_mbpl_uc_r_s;
input         f_hdtvh_r;
input  [2:0]  f_hvec1c_r;
input  [3:0]  f_hvec1y_r;
input  [2:0]  f_hvec2c_r;
input  [3:0]  f_hvec2y_r;
input  [2:0]  f_hvec3c_r;
input  [3:0]  f_hvec3y_r;
input  [2:0]  f_hvec4c_r;
input  [3:0]  f_hvec4y_r;
input  [1:0]  f_mttyp_r;
input         f_pred_backward_buc_r;
input         f_pred_forward_buc_r;
input         f_prgseq_r;
input         f_ref1cen_r;
input  [63:0] f_ref1dt_r;
input         f_ref1yen_r;
input         f_ref2cen_r;
input  [63:0] f_ref2dt_r;
input         f_ref2yen_r;
input  [1:0]  f_vvec1c_r;
input  [2:0]  f_vvec1y_r;
input  [1:0]  f_vvec2c_r;
input  [2:0]  f_vvec2y_r;
input  [1:0]  f_vvec3c_r;
input  [2:0]  f_vvec3y_r;
input  [1:0]  f_vvec4c_r;
input  [2:0]  f_vvec4y_r;
output        u_ref1cen_r;
output [15:0] u_ref1dt_r;
output        u_ref1yen_r;
output        u_ref2cen_r;
output [15:0] u_ref2dt_r;
output        u_ref2yen_r;


wire         clkdec;
wire         rstdec_x;
wire         c_mbpl_uc_r_s;
wire         f_hdtvh_r;
wire [2:0]   f_hvec1c_r;
wire [3:0]   f_hvec1y_r;
wire [2:0]   f_hvec2c_r;
wire [3:0]   f_hvec2y_r;
wire [2:0]   f_hvec3c_r;
wire [3:0]   f_hvec3y_r;
wire [2:0]   f_hvec4c_r;
wire [3:0]   f_hvec4y_r;
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
wire [1:0]   f_vvec1c_r;
wire [2:0]   f_vvec1y_r;
wire [1:0]   f_vvec2c_r;
wire [2:0]   f_vvec2y_r;
wire [1:0]   f_vvec3c_r;
wire [2:0]   f_vvec3y_r;
wire [1:0]   f_vvec4c_r;
wire [2:0]   f_vvec4y_r;
wire         u_ref1cen_r;
wire [15:0]  u_ref1dt_r;
wire         u_ref1yen_r;
wire         u_ref2cen_r;
wire [15:0]  u_ref2dt_r;
wire         u_ref2yen_r;

wire        u_ref1v_cen_r;
wire        u_ref1v_csngl_r;
wire [15:0] u_ref1v_dt_r;
wire        u_ref1v_yen_r;
wire        u_ref1v_ysngl_r;
wire        u_ref2v_cen_r;
wire        u_ref2v_csngl_r;
wire [15:0] u_ref2v_dt_r;
wire        u_ref2v_yen_r;
wire        u_ref2v_ysngl_r;


uc_h uc_h0( 
   .clkdec               (clkdec), 
   .rstdec_x             (rstdec_x), 
   .c_mbpl_uc_r_s        (c_mbpl_uc_r_s), 
   .u_ref1v_dt_r         (u_ref1v_dt_r), 
   .u_ref1v_yen_r        (u_ref1v_yen_r), 
   .u_ref1v_cen_r        (u_ref1v_cen_r), 
   .u_ref1v_ysngl_r      (u_ref1v_ysngl_r), 
   .u_ref1v_csngl_r      (u_ref1v_csngl_r), 
   .f_hdtvh_r            (f_hdtvh_r), 
   .f_pred_forward_buc_r (f_pred_forward_buc_r), 
   .f_mttyp_r            (f_mttyp_r), 
   .f_hvec1y_r           (f_hvec1y_r), 
   .f_hvec2y_r           (f_hvec2y_r), 
   .f_hvec1c_r           (f_hvec1c_r), 
   .f_hvec2c_r           (f_hvec2c_r), 
   .u_ref1dt_r           (u_ref1dt_r), 
   .u_ref1yen_r          (u_ref1yen_r), 
   .u_ref1cen_r          (u_ref1cen_r)
); 

uc_h uc_h1( 
   .clkdec               (clkdec), 
   .rstdec_x             (rstdec_x), 
   .c_mbpl_uc_r_s        (c_mbpl_uc_r_s), 
   .u_ref1v_dt_r         (u_ref2v_dt_r), 
   .u_ref1v_yen_r        (u_ref2v_yen_r), 
   .u_ref1v_cen_r        (u_ref2v_cen_r), 
   .u_ref1v_ysngl_r      (u_ref2v_ysngl_r), 
   .u_ref1v_csngl_r      (u_ref2v_csngl_r), 
   .f_hdtvh_r            (f_hdtvh_r), 
   .f_pred_forward_buc_r (f_pred_backward_buc_r), 
   .f_mttyp_r            (f_mttyp_r), 
   .f_hvec1y_r           (f_hvec3y_r), 
   .f_hvec2y_r           (f_hvec4y_r), 
   .f_hvec1c_r           (f_hvec3c_r), 
   .f_hvec2c_r           (f_hvec4c_r), 
   .u_ref1dt_r           (u_ref2dt_r), 
   .u_ref1yen_r          (u_ref2yen_r), 
   .u_ref1cen_r          (u_ref2cen_r)
); 

uc_v uc_v0( 
   .clkdec               (clkdec), 
   .rstdec_x             (rstdec_x), 
   .c_mbpl_uc_r_s        (c_mbpl_uc_r_s), 
   .f_ref1dt_r           (f_ref1dt_r), 
   .f_ref1yen_r          (f_ref1yen_r), 
   .f_ref1cen_r          (f_ref1cen_r), 
   .f_hdtvh_r            (f_hdtvh_r), 
   .f_prgseq_r           (f_prgseq_r), 
   .f_pred_forward_buc_r (f_pred_forward_buc_r), 
   .f_mttyp_r            (f_mttyp_r), 
   .f_vvec1y_r           (f_vvec1y_r), 
   .f_vvec2y_r           (f_vvec2y_r), 
   .f_vvec1c_r           (f_vvec1c_r), 
   .f_vvec2c_r           (f_vvec2c_r), 
   .u_ref1v_dt_r         (u_ref1v_dt_r), 
   .u_ref1v_yen_r        (u_ref1v_yen_r), 
   .u_ref1v_cen_r        (u_ref1v_cen_r), 
   .u_ref1v_ysngl_r      (u_ref1v_ysngl_r), 
   .u_ref1v_csngl_r      (u_ref1v_csngl_r)
); 

uc_v uc_v1( 
   .clkdec               (clkdec), 
   .rstdec_x             (rstdec_x), 
   .c_mbpl_uc_r_s        (c_mbpl_uc_r_s), 
   .f_ref1dt_r           (f_ref2dt_r), 
   .f_ref1yen_r          (f_ref2yen_r), 
   .f_ref1cen_r          (f_ref2cen_r), 
   .f_hdtvh_r            (f_hdtvh_r), 
   .f_prgseq_r           (f_prgseq_r), 
   .f_pred_forward_buc_r (f_pred_backward_buc_r), 
   .f_mttyp_r            (f_mttyp_r), 
   .f_vvec1y_r           (f_vvec3y_r), 
   .f_vvec2y_r           (f_vvec4y_r), 
   .f_vvec1c_r           (f_vvec3c_r), 
   .f_vvec2c_r           (f_vvec4c_r), 
   .u_ref1v_dt_r         (u_ref2v_dt_r), 
   .u_ref1v_yen_r        (u_ref2v_yen_r), 
   .u_ref1v_cen_r        (u_ref2v_cen_r), 
   .u_ref1v_ysngl_r      (u_ref2v_ysngl_r), 
   .u_ref1v_csngl_r      (u_ref2v_csngl_r)
); 

endmodule
