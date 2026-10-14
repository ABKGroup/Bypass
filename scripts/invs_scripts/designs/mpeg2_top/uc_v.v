// ----------------------------------------------
// File: uc_v.v
// Module: uc_v
// Function:Up Convert Vertical Filter Operation
// ----------------------------------------------

module uc_v(
  clkdec,
  rstdec_x,
  c_mbpl_uc_r_s,
  f_ref1dt_r,
  f_ref1yen_r,
  f_ref1cen_r,
  f_hdtvh_r,
  f_prgseq_r,
  f_pred_forward_buc_r,
  f_mttyp_r,
  f_vvec1y_r,
  f_vvec2y_r,
  f_vvec1c_r,
  f_vvec2c_r,
  u_ref1v_dt_r,
  u_ref1v_yen_r,
  u_ref1v_cen_r,
  u_ref1v_ysngl_r,
  u_ref1v_csngl_r
  );
  
  input         clkdec;        
  input         rstdec_x;      
  input         c_mbpl_uc_r_s;  
  input [63:0]  f_ref1dt_r;     
  input         f_ref1yen_r;    
  input         f_ref1cen_r;    
  input         f_hdtvh_r;      
  input         f_prgseq_r;     
  input         f_pred_forward_buc_r;
  input [1:0]   f_mttyp_r;           
  input [2:0]   f_vvec1y_r;          
  input [2:0]   f_vvec2y_r;          
  input [1:0]   f_vvec1c_r;          
  input [1:0]   f_vvec2c_r;          
  output [15:0] u_ref1v_dt_r;        
  output        u_ref1v_yen_r;     
  output        u_ref1v_cen_r;     
  output        u_ref1v_ysngl_r;   
  output        u_ref1v_csngl_r;   
  
  wire          c_mbpl_uc_r_s;        // MB Pulse UC Phase
  wire [63:0]   f_ref1dt_r;           // MB Reference Data
  wire          f_ref1yen_r;          // MB Reference Data Enable(Y)
  wire          f_ref1cen_r;          // MB Reference Data Enable(C)
  wire          f_hdtvh_r;            // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  wire          f_prgseq_r;           // MB Interlace/Progressive Select[0:Interlace 1:Progressive]
  wire          f_pred_forward_buc_r; // MB Estimate Valid Flag
  wire [1:0]    f_mttyp_r;            // MB Estimate Mode
  wire [2:0]    f_vvec1y_r;           // MB Vertical Vector1(Y)
  wire [2:0]    f_vvec2y_r;           // MB Vertical Vector2(Y)
  wire [1:0]    f_vvec1c_r;           // MB Vertical Vector1(C)
  wire [1:0]    f_vvec2c_r;           // MB Vertical Vector2(C)
  wire [31:0]   u_refdt_r;            // MB Vertical Refetence Data
  wire          u_refyen_r;           // MB Vertical Refetence Data Enable(Y)
  wire          u_refcen_r;           // MB Vertical Refetence Data Enable(C)
  wire [15:0]   u_sdtvdt_r;           // MB SDTV Data
  wire          u_syen_r;             // MB SDTV Data Enable(Y)
  wire          u_scen_r;             // MB SDTV Data Enable(C)
  wire [39:0]   u_coe1_r;             // MB Vertical Coefficient1
  wire [39:0]   u_coe2_r;             // MB Vertical Coefficient2
  wire          u_ysngl_r;            // MB Data Single Flag(Y)
  wire          u_csngl_r;            // MB Data Single Flag(C)
  wire          u_ycdtsel_r;          // MB Data Y/C Select
  wire          u_cdtsel_r;           // MB Data Cb/Cr Select
  wire          u_hdtvh_r;            // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  wire          u_opstp_r;            // MB Estimate Valid Flag
  wire          u_yeni_r;             // MB Data Enable(Y)
  wire          u_ceni_r;             // MB Data Enable(C)
  wire          u_mbpl_r_s;           // MB Pulse
  wire [15:0]   u_dt_r;               // Vertical Filter Data
  wire          u_yen_r;              // Vertical Filter Data Enable(Y)
  wire          u_cen_r;              // Vertical Filter Data Enable(C)
  wire          u_refv_ysngl_r;       // Vertical Data Single Flag(Y)
  wire          u_refv_csngl_r;       // Vertical Data Single Flag(C)
  wire [15:0]   u_ref1v_dt_r;         // MB Data
  wire          u_ref1v_yen_r;        // MB Data Enable(Y)
  wire          u_ref1v_cen_r;        // MB Data Enable(C)
  wire          u_ref1v_ysngl_r;      // MB Data Single Flag(Y)
  wire          u_ref1v_csngl_r;      // MB Data Single Flag(C)
  
  uc_64232 uc_64232(
    .clkdec(clkdec),
    .rstdec_x(rstdec_x),
    .f_ref1dt_r(f_ref1dt_r),
    .u_yeni_r(u_yeni_r),
    .u_ceni_r(u_ceni_r),
    .u_mbpl_r_s(u_mbpl_r_s),
    .u_ycdtsel_r(u_ycdtsel_r),
    .u_cdtsel_r(u_cdtsel_r),
    .u_refdt_r(u_refdt_r),
    .u_refyen_r(u_refyen_r),
    .u_refcen_r(u_refcen_r),
    .u_sdtvdt_r(u_sdtvdt_r),
    .u_syen_r(u_syen_r),
    .u_scen_r(u_scen_r)
    );  
  
  uc_vctrl uc_vctrl(
    .clkdec(clkdec),
    .rstdec_x(rstdec_x),
    .c_mbpl_uc_r_s(c_mbpl_uc_r_s),
    .f_ref1yen_r(f_ref1yen_r),
    .f_ref1cen_r(f_ref1cen_r),
    .f_vvec1y_r(f_vvec1y_r),
    .f_vvec2y_r(f_vvec2y_r),
    .f_vvec1c_r(f_vvec1c_r),
    .f_vvec2c_r(f_vvec2c_r),
    .f_hdtvh_r(f_hdtvh_r),
    .f_prgseq_r(f_prgseq_r),
    .f_pred_forward_buc_r(f_pred_forward_buc_r),
    .f_mttyp_r(f_mttyp_r),
    .u_coe1_r(u_coe1_r),
    .u_coe2_r(u_coe2_r),
    .u_ysngl_r(u_ysngl_r),
    .u_csngl_r(u_csngl_r),
    .u_ycdtsel_r(u_ycdtsel_r),
    .u_cdtsel_r(u_cdtsel_r),
    .u_hdtvh_r(u_hdtvh_r),
    .u_opstp_r(u_opstp_r),
    .u_yeni_r(u_yeni_r),
    .u_ceni_r(u_ceni_r),
    .u_mbpl_r_s(u_mbpl_r_s)
    );
  
  uc_vtflt uc_vtflt(
    .clkdec(clkdec),
    .rstdec_x(rstdec_x),
    .u_refdt_r(u_refdt_r),
    .u_refyen_r(u_refyen_r),
    .u_refcen_r(u_refcen_r),
    .u_coe1_r(u_coe1_r),
    .u_coe2_r(u_coe2_r),
    .u_ysngl_r(u_ysngl_r),
    .u_csngl_r(u_csngl_r),
    .u_opstp_r(u_opstp_r),
    .u_dt_r(u_dt_r),
    .u_yen_r(u_yen_r),
    .u_cen_r(u_cen_r),
    .u_refv_ysngl_r(u_refv_ysngl_r),
    .u_refv_csngl_r(u_refv_csngl_r)
    );
  
  uc_vtsel uc_vtsel(
    .clkdec(clkdec),
    .rstdec_x(rstdec_x),
    .u_dt_r(u_dt_r),
    .u_yen_r(u_yen_r),
    .u_cen_r(u_cen_r),
    .u_refv_ysngl_r(u_refv_ysngl_r),
    .u_refv_csngl_r(u_refv_csngl_r),
    .u_sdtvdt_r(u_sdtvdt_r),
    .u_syen_r(u_syen_r),
    .u_scen_r(u_scen_r),
    .u_hdtvh_r(u_hdtvh_r),
    .u_ref1v_dt_r(u_ref1v_dt_r),
    .u_ref1v_yen_r(u_ref1v_yen_r),
    .u_ref1v_cen_r(u_ref1v_cen_r),
    .u_ref1v_ysngl_r(u_ref1v_ysngl_r),
    .u_ref1v_csngl_r(u_ref1v_csngl_r)
    );
  
endmodule
