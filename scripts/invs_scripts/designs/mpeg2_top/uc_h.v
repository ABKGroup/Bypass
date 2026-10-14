// ----------------------------------------------
// File: uc_h.v
// Module: uc_h
// Function:Up Up Convert Horizontal Filter
// ----------------------------------------------

module uc_h(
  clkdec,
  rstdec_x,
  c_mbpl_uc_r_s,
  u_ref1v_dt_r,
  u_ref1v_yen_r,
  u_ref1v_cen_r,
  u_ref1v_ysngl_r,
  u_ref1v_csngl_r,
  f_hdtvh_r,
  f_pred_forward_buc_r,
  f_mttyp_r,
  f_hvec1y_r,
  f_hvec2y_r,
  f_hvec1c_r,
  f_hvec2c_r,
  u_ref1dt_r,
  u_ref1yen_r,
  u_ref1cen_r
  );
  
  input         clkdec;         
  input         rstdec_x;       
  input         c_mbpl_uc_r_s;    
  input [15:0]  u_ref1v_dt_r;     
  input         u_ref1v_yen_r;    
  input         u_ref1v_cen_r;    
  input         u_ref1v_ysngl_r;  
  input         u_ref1v_csngl_r;  
  input         f_hdtvh_r;        
  input         f_pred_forward_buc_r;
  input [1:0]   f_mttyp_r;        
  input [3:0]   f_hvec1y_r;       
  input [3:0]   f_hvec2y_r;       
  input [2:0]   f_hvec1c_r;       
  input [2:0]   f_hvec2c_r;       
  output [15:0] u_ref1dt_r;       
  output        u_ref1yen_r;      
  output        u_ref1cen_r;      

  wire          c_mbpl_uc_r_s;        // MB Pulse
  wire [15:0]   u_ref1v_dt_r;         // MB Data
  wire          u_ref1v_yen_r;        // MB Data Enable(Y)
  wire          u_ref1v_cen_r;        // MB Data Enable(C)
  wire          u_ref1v_ysngl_r;      // MB Data Single Flag(Y)
  wire          u_ref1v_csngl_r;      // MB Data Single Flag(C)
  wire          f_hdtvh_r;            // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  wire          f_pred_forward_buc_r; // MB Estimate Valid Flag
  wire [1:0]    f_mttyp_r;            // MB Estimate Mode
  wire [3:0]    f_hvec1y_r;           // MB Horizontal Vector(Y) Top-Field
  wire [3:0]    f_hvec2y_r;           // MB Horizontal Vector(Y) Bottom-Field
  wire [2:0]    f_hvec1c_r;           // MB Horizontal Vector(C) Top-Field
  wire [2:0]    f_hvec2c_r;           // MB Horizontal Vector(C) Bottom-Field
  wire [63:0]   u_refhdt1_r;          // MB Horizontal Filter Data1
  wire [63:0]   u_refhdt2_r;          // MB Horizontal Filter Data2
  wire [15:0]   u_sdtvdth_r;          // MB STDV Data
  wire          u_vyen_d1_r;          // u_ref1v_yen_r 1CLK Delay
  wire          u_vcen_d1_r;          // u_ref1v_cen_r 1CLK Delay
  wire          u_hff2en_r_s;         // MB Data Latch Enable
  wire          u_hdt_sl1_r;          // MB Data Select1
  wire          u_hdt_sl2_r;          // MB Data Select2
  wire          u_hdt_sl3_r;          // MB Data Select3
  wire          u_hdt_msk_r;          // Output Data Lower Byte Dummy Mask
  wire [79:0]   u_hcoe1_r;            // MB Horizontal Coefficient1
  wire [79:0]   u_hcoe2_r;            // MB Horizontal Coefficient2
  wire          u_hopstp_r;           // MB Estimate Valid Flag
  wire          u_hdtvhh_r;           // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  wire          u_hyen_r;             // MB Data Enable(HDTV/Y)
  wire          u_hcen_r;             // MB Data Enable(HDTV/C)
  wire [15:0]   u_hdt_r;              // MB Data
  wire [15:0]   u_ref1dt_r;           // MB Data
  wire          u_ref1yen_r;          // MB Data Enable(Y)
  wire          u_ref1cen_r;          // MB Data Enable(C)
  
  uc_hdtdep uc_hdtdep(
    .clkdec(clkdec),
    .rstdec_x(rstdec_x),
    .u_vyen_d1_r(u_vyen_d1_r),
    .u_vcen_d1_r(u_vcen_d1_r),
    .u_ref1v_dt_r(u_ref1v_dt_r),
    .u_hff2en_r_s(u_hff2en_r_s),
    .u_hdt_sl1_r(u_hdt_sl1_r),
    .u_hdt_sl2_r(u_hdt_sl2_r),
    .u_hdt_sl3_r(u_hdt_sl3_r),
    .u_hdt_msk_r(u_hdt_msk_r),
    .u_refhdt1_r(u_refhdt1_r),
    .u_refhdt2_r(u_refhdt2_r),
    .u_sdtvdth_r(u_sdtvdth_r)
    );
  
  uc_hctrl uc_hctrl(
    .clkdec(clkdec),
    .rstdec_x(rstdec_x),
    .c_mbpl_uc_r_s(c_mbpl_uc_r_s),
    .u_ref1v_yen_r(u_ref1v_yen_r),
    .u_ref1v_cen_r(u_ref1v_cen_r),
    .u_ref1v_ysngl_r(u_ref1v_ysngl_r),
    .u_ref1v_csngl_r(u_ref1v_csngl_r),
    .f_hdtvh_r(f_hdtvh_r),
    .f_pred_forward_buc_r(f_pred_forward_buc_r),
    .f_mttyp_r(f_mttyp_r),
    .f_hvec1y_r(f_hvec1y_r),
    .f_hvec2y_r(f_hvec2y_r),
    .f_hvec1c_r(f_hvec1c_r),
    .f_hvec2c_r(f_hvec2c_r),
    .u_vyen_d1_r(u_vyen_d1_r),
    .u_vcen_d1_r(u_vcen_d1_r),
    .u_hff2en_r_s(u_hff2en_r_s),
    .u_hdt_sl1_r(u_hdt_sl1_r),
    .u_hdt_sl2_r(u_hdt_sl2_r),
    .u_hdt_sl3_r(u_hdt_sl3_r),
    .u_hdt_msk_r(u_hdt_msk_r),
    .u_hcoe1_r(u_hcoe1_r),
    .u_hcoe2_r(u_hcoe2_r),
    .u_hopstp_r(u_hopstp_r),
    .u_hdtvhh_r(u_hdtvhh_r),
    .u_hyen_r(u_hyen_r),
    .u_hcen_r(u_hcen_r)
    );
  
  uc_hlflt uc_hlflt(
    .clkdec(clkdec),
    .rstdec_x(rstdec_x),
    .u_refhdt1_r(u_refhdt1_r),
    .u_refhdt2_r(u_refhdt2_r),
    .u_hcoe1_r(u_hcoe1_r),
    .u_hcoe2_r(u_hcoe2_r),
    .u_hopstp_r(u_hopstp_r),
    .u_hdt_r(u_hdt_r)
    );
  
  uc_hlsel uc_hlsel(
    .clkdec(clkdec),
    .rstdec_x(rstdec_x),
    .u_vyen_d1_r(u_vyen_d1_r),
    .u_vcen_d1_r(u_vcen_d1_r),
    .u_hyen_r(u_hyen_r),
    .u_hcen_r(u_hcen_r),
    .u_hdt_r(u_hdt_r),
    .u_sdtvdth_r(u_sdtvdth_r),
    .u_hdtvhh_r(u_hdtvhh_r),
    .u_hopstp_r(u_hopstp_r),
    .u_ref1dt_r(u_ref1dt_r),
    .u_ref1yen_r(u_ref1yen_r),
    .u_ref1cen_r(u_ref1cen_r)
    );
  
endmodule
