// ----------------------------------------------
// File: vldtop.v
// Module: vldtop
// Function:
// ----------------------------------------------

module vldtop(
                  // output
                  v_paramadr_r,   // parameter address
                  v_paramdata_r,  // parameter data
                  v_vdoen_r,    // q-index data enable
                  v_vdo_r,        // q-index data
                  v_vldstatus_r,  // vld status
                  v_vldmstatus_r, // vld status (macroblock)
                  v_seqstrt_r,    // sequence_header start
                  v_sqxstrt_r,    // sequence_extension start
                  v_sdxstrt_r,    // sequence_display_extension start
                  v_ud0strt_r,    // user_data0 start
                  v_gopstrt_r,    // group_of_pictures start
                  v_ud1strt_r,    // user_data1 start
                  v_picstrt_r,    // picture_header start
                  v_pcxstrt_r,    // picture_coding_extension start
                  v_qmxstrt_r,    // quant_matrix_extension start
                  v_cpxstrt_r,    // copyright_extension start
                  v_pdxstrt_r,    // picture_display_extension start
                  v_ud2strt_r,    // usr_data2 start
                  v_atscdet_r,    // ATSC identifier detected
                  v_slicestart_r, // slice header start
                  v_mbadet_r,     // MBA detected
                  v_qmsyni_r_n,   // intra q-matrix sync
                  v_qmseli_r,     // intra q-matrix select
                  v_qmsynn_r_n,   // non-intra q-matrix sync
                  v_qmseln_r,     // non-intra q-matrix select
                  v_qmdata_r,     // q-matrix data
                  v_motion_type_r, // motion_type
                  v_fstfwdvech_r,  // 1st forward vector horizontal
                  v_fstfwdvecv_r,  // 1st forward vector vertical
                  v_fstbwdvech_r,  // 1st backward vector horizontal
                  v_fstbwdvecv_r,  // 1st backward vector vertical
                  v_sndfwdvech_r,  // 2nd forward vector horizontal
                  v_sndfwdvecv_r,  // 2nd forward vector vertical
                  v_sndbwdvech_r,  // 2nd backward vector horizontal
                  v_sndbwdvecv_r,  // 2nd backward vector vertical
                  v_ferror_r,      // fatal error
                  v_vscdet_ferror_r,
                  v_nferror_r,     // non fatal error
                  v_sferror_r,     // upper irregal header detection error
                  v_slclverr_r,      // fatal error within a slice
                  v1_bs_req_n,       // bitstream update request
                  // input
                  clkdec,         // clock
                  rstdec_x,       // reset
                  g_swrst_r_n,      // S/W reset
                  y1_bs_wait_n,       // vld temporary wait
                  g_init_vld_r_s,   // vld initial start
                  c_mbpl_vld_r_s,   // MB start
                  c_mbpl_skpmb_r_s, // skipped MB
                  c_skipslc_r_s,    // slice skip
                  c_skippic_r_s,    // picture skip
                  y1_bs_data,         // bitstream
                  g_vldmode_r,       // vld operation mode
                  v_mode_mpeg1,
                  y1_bs_data_r  
                );

  // output
  output [7:0]  v_paramadr_r;   // parameter address
  output [24:0] v_paramdata_r;  // pagrameter data
  output        v_vdoen_r;      // q-index data enable
  output [11:0] v_vdo_r;        // q-index data
  output [7:0]  v_vldstatus_r;  // vld status
  output [3:0]  v_vldmstatus_r; // vld status (macroblock)
  output        v_seqstrt_r;    // sequence_header start
  output        v_sqxstrt_r;    // sequence_extension start
  output        v_sdxstrt_r;    // sequence_display_extension start
  output        v_ud0strt_r;    // user_data0 start
  output        v_gopstrt_r;    // group_of_pictures start
  output        v_ud1strt_r;    // user_data1 start
  output        v_picstrt_r;    // picture_header start
  output        v_pcxstrt_r;    // picture_coding_extension start
  output        v_qmxstrt_r;    // quant_matrix_extension start
  output        v_cpxstrt_r;    // copyright_extension start
  output        v_pdxstrt_r;    // picture_display_extension start
  output        v_ud2strt_r;    // usr_data2 start
  output        v_atscdet_r;    // ATSC identifier detected
  output        v_slicestart_r; // slice header start
  output        v_mbadet_r;     // MBA detected
  output        v_qmsyni_r_n;   // intra q-matrix sync
  output        v_qmseli_r;     // intra q-matrix select
  output        v_qmsynn_r_n;   // non-intra q-matrix sync
  output        v_qmseln_r;     // non-intra q-matrix select
  output [7:0]  v_qmdata_r;     // q-matrix data
  output [1:0]  v_motion_type_r; // motion_type
  output [12:0] v_fstfwdvech_r;  // 1st forward vector horizontal
  output [8:0]  v_fstfwdvecv_r;  // 1st forward vector vertical
  output [12:0] v_fstbwdvech_r;  // 1st backward vector horizontal
  output [8:0]  v_fstbwdvecv_r;  // 1st backward vector vertical
  output [12:0] v_sndfwdvech_r;  // 2nd forward vector horizontal
  output [8:0]  v_sndfwdvecv_r;  // 2nd forward vector vertical
  output [12:0] v_sndbwdvech_r;  // 2nd backward vector horizontal
  output [8:0]  v_sndbwdvecv_r;  // 2nd backward vector vertical
  output        v_ferror_r;      // fatal error
  output        v_vscdet_ferror_r;
  output        v_nferror_r;     // non fatal error
  output        v_sferror_r;     // upper irregal header detection error
  output        v_slclverr_r;      // fatal error within a slice
  output        v1_bs_req_n;       // bitstream update request
  // input
  input         clkdec;         // clock
  input         rstdec_x;       // reset
  input         g_swrst_r_n;      // S/W reset
  input         y1_bs_wait_n;       // vld temporary wait
  input         g_init_vld_r_s;   // vld initial start
  input         c_mbpl_vld_r_s;   // MB start
  input         c_mbpl_skpmb_r_s; // skipped MB
  input         c_skipslc_r_s;    // slice skip
  input         c_skippic_r_s;    // picture skip
  input [31:0]  y1_bs_data;         // bitstream
  input [1:0]   g_vldmode_r;      // vld operation mode
  input         v_mode_mpeg1;
  output [31:0] y1_bs_data_r;

  wire [31:0]   y1_bs_data;         // bitstream
  wire [1:0]    g_vldmode_r;      // vld operation mode
  wire [1:0]    v_motion_type_r;  // motion_type
  wire [12:0]   v_fstfwdvech_r;   // 1st forward vector horizontal
  wire [8:0]    v_fstfwdvecv_r;   // 1st forward vector vertical
  wire [12:0]   v_fstbwdvech_r;   // 1st backward vector horizontal
  wire [8:0]    v_fstbwdvecv_r;   // 1st backward vector vertical
  wire [12:0]   v_sndfwdvech_r;   // 2nd forward vector horizontal
  wire [8:0]    v_sndfwdvecv_r;   // 2nd forward vector vertical
  wire [12:0]   v_sndbwdvech_r;   // 2nd backward vector horizontal
  wire [8:0]    v_sndbwdvecv_r;   // 2nd backward vector vertical
  wire [7:0]    v_paramadr_r;     // parameter address
  wire [24:0]   v_paramdata_r;    // parameter data
  wire [1:0]    v_mbmot_type_r;   // motion_type
  wire [11:0]   v_vdo_r;        // q-index data
  wire [7:0]    v_vldstatus_r;  // vld status
  wire [3:0]    v_vldmstatus_r; // vld status (macroblock)
  wire [7:0]    v_qmdata_r;     // q-matrix data
  wire [31:0]   y1_bs_data_r;  
  wire          v_mbhend_r_s;

vld_syndec vld_syndec(
     .v_mbhend_r_s(v_mbhend_r_s),
     .v_paramadr_r(v_paramadr_r),
     .v_paramdata_r(v_paramdata_r),
     .v_mbmot_type_r(v_mbmot_type_r),
     .v_vdoen_r(v_vdoen_r),
     .v_vdo_r(v_vdo_r),
     .v_vldstatus_r(v_vldstatus_r),
     .v_vldmstatus_r(v_vldmstatus_r),
     .v_seqstrt_r(v_seqstrt_r),
     .v_sqxstrt_r(v_sqxstrt_r),
     .v_sdxstrt_r(v_sdxstrt_r),
     .v_ud0strt_r(v_ud0strt_r),
     .v_gopstrt_r(v_gopstrt_r),
     .v_ud1strt_r(v_ud1strt_r),
     .v_picstrt_r(v_picstrt_r),
     .v_pcxstrt_r(v_pcxstrt_r),
     .v_qmxstrt_r(v_qmxstrt_r),
     .v_cpxstrt_r(v_cpxstrt_r),
     .v_pdxstrt_r(v_pdxstrt_r),
     .v_ud2strt_r(v_ud2strt_r),
     .v_atscdet_r(v_atscdet_r),
     .v_slicestart_r(v_slicestart_r),
     .v_mbadet_r(v_mbadet_r),
     .v_qmsyni_r_n(v_qmsyni_r_n),
     .v_qmseli_r(v_qmseli_r),
     .v_qmsynn_r_n(v_qmsynn_r_n),
     .v_qmseln_r(v_qmseln_r),
     .v_qmdata_r(v_qmdata_r),
     .v_ferror_r(v_ferror_r),
     .v_nferror_r(v_nferror_r),
     .v_vscdet_ferror_r(v_vscdet_ferror_r),
     .v_sferror_r(v_sferror_r),
     .v_slclverr_r(v_slclverr_r),
     .v1_bs_req_n(v1_bs_req_n),
     .clkdec(clkdec),
     .rstdec_x(rstdec_x),
     .g_swrst_r_n(g_swrst_r_n),
     .y1_bs_wait_n(y1_bs_wait_n),
     .g_init_vld_r_s(g_init_vld_r_s),
     .c_mbpl_vld_r_s(c_mbpl_vld_r_s),
     .c_skipslc_r_s(c_skipslc_r_s),
     .c_skippic_r_s(c_skippic_r_s),
     .y1_bs_data(y1_bs_data),
     .g_vldmode_r(g_vldmode_r),
     .y1_bs_data_r(y1_bs_data_r)     
     );

vld_motvec vld_motvec(
     .v_motion_type_r(v_motion_type_r),
     .v_fstfwdvech_r(v_fstfwdvech_r),
     .v_fstfwdvecv_r(v_fstfwdvecv_r),
     .v_fstbwdvech_r(v_fstbwdvech_r),
     .v_fstbwdvecv_r(v_fstbwdvecv_r),
     .v_sndfwdvech_r(v_sndfwdvech_r),
     .v_sndfwdvecv_r(v_sndfwdvecv_r),
     .v_sndbwdvech_r(v_sndbwdvech_r),
     .v_sndbwdvecv_r(v_sndbwdvecv_r),
     .clkdec(clkdec),
     .rstdec_x(rstdec_x),
     .g_swrst_r_n(g_swrst_r_n),
     .v_slicestart_r_s(v_slicestart_r),
     .c_mbpl_skpmb_r_s(c_mbpl_skpmb_r_s),
     .v_mbhend_r_s(v_mbhend_r_s),
     .v_paramadr_r(v_paramadr_r),
     .v_paramdata_r(v_paramdata_r[24:17]),
     .v_mbmot_type_r(v_mbmot_type_r),
     .c_mbpl_vld_r_s(c_mbpl_vld_r_s),
     .v_mode_mpeg1(v_mode_mpeg1)
     );

endmodule
