// ----------------------------------------------
// File: mc_vcsl.v
// Module: mc_vcsl
// Function:vectol caluclation and select
// ----------------------------------------------

module mc_vcsl(
  c_mbpl_mcalc_r_s,
  c_mbpl_psft_r_s,
  c_mbpl_uc_r_s,
  c_mbpl_dc_r_s,
  c_mbpl_mc_r_s,
  c_mbpl_idct_out_r_s,
  p_fstfwdvech_buc_r,
  p_fstfwdvecv_buc_r,
  p_fstbwdvech_buc_r,
  p_fstbwdvecv_buc_r,
  p_sndfwdvech_buc_r,
  p_sndfwdvecv_buc_r,
  p_sndbwdvech_buc_r,
  p_sndbwdvecv_buc_r,
  p_mttyp_buc_r,
  p_prgseq_buc_r,
  p_pstr_buc_r,
  p_tfst_buc_r,
  p_dmvh_buc_r,
  p_dmvv_buc_r,
  m_mbpl_uc_r_s,
  u_ref1yen_r,
  u_ref1cen_r,
  u_ref2yen_r,
  u_ref2cen_r,
  m_mbpl_dc_r_s,
  m_mbpl_mc_r_s,
  m_mbpl_idct_out_r_s,
  m_frm_inter_mc_r,
  m_frm_prog_mc_r,
  m_frm_pred_over_mc_r,
  m_frm_inter_uc_r,
  m_frm_prog_uc_r,
  m_frm_pred_over_uc_r,
  m_frm_fidp_r,
  m_half_hpelf_r,
  m_half_vpelf_r,
  m_line17_cutf_r,
  m_half_hpelb_r,
  m_half_vpelb_r,
  m_line17_cutb_r,
  m_motion_dp_r,
  m_hvec1y_r,
  m_vvec1y_r,
  m_hvec2y_r,
  m_vvec2y_r,
  m_hvec3y_r,
  m_vvec3y_r,
  m_hvec4y_r,
  m_vvec4y_r,
  m_hvec1c_r,
  m_vvec1c_r,
  m_hvec2c_r,
  m_vvec2c_r,
  m_hvec3c_r,
  m_vvec3c_r,
  m_hvec4c_r,
  m_vvec4c_r,
  clkdec,
  m_ref1yen_r,
  m_ref1cen_r,
  m_ref2yen_r,
  m_ref2cen_r,
  rstdec_x
);
    input        c_mbpl_mcalc_r_s;
    input        c_mbpl_psft_r_s;
    input        c_mbpl_uc_r_s;
    input        c_mbpl_dc_r_s;
    input        c_mbpl_mc_r_s;
    input        c_mbpl_idct_out_r_s;
    input [12:0] p_fstfwdvech_buc_r;
    input [8:0]  p_fstfwdvecv_buc_r;
    input [12:0] p_fstbwdvech_buc_r;
    input [8:0]  p_fstbwdvecv_buc_r;
    input [12:0] p_sndfwdvech_buc_r;
    input [8:0]  p_sndfwdvecv_buc_r;
    input [12:0] p_sndbwdvech_buc_r;
    input [8:0]  p_sndbwdvecv_buc_r;
    input [1:0]  p_mttyp_buc_r;
    input        p_prgseq_buc_r;
    input [1:0]  p_pstr_buc_r;
    input        p_tfst_buc_r;
    input [1:0]  p_dmvh_buc_r;
    input [1:0]  p_dmvv_buc_r;
    input        u_ref1yen_r;
    input        u_ref1cen_r;
    input        u_ref2yen_r;
    input        u_ref2cen_r;
    input        clkdec;
    input        rstdec_x;
    output        m_mbpl_uc_r_s;
    output        m_mbpl_dc_r_s;
    output        m_mbpl_mc_r_s;
    output        m_mbpl_idct_out_r_s;
    output        m_frm_inter_mc_r;
    output        m_frm_prog_mc_r;
    output        m_frm_pred_over_mc_r;
    output        m_frm_inter_uc_r;
    output        m_frm_prog_uc_r;
    output        m_frm_pred_over_uc_r;
    output        m_frm_fidp_r;
    output        m_half_hpelf_r;
    output        m_half_vpelf_r;
    output        m_line17_cutf_r;
    output        m_half_hpelb_r;
    output        m_half_vpelb_r;
    output        m_line17_cutb_r;
    output        m_motion_dp_r;
    output [11:0] m_hvec1y_r;
    output [7:0]  m_vvec1y_r;
    output [11:0] m_hvec2y_r;
    output [7:0]  m_vvec2y_r;
    output [11:0] m_hvec3y_r;
    output [7:0]  m_vvec3y_r;
    output [11:0] m_hvec4y_r;
    output [7:0]  m_vvec4y_r;
    output [10:0] m_hvec1c_r;
    output [6:0]  m_vvec1c_r;
    output [10:0] m_hvec2c_r;
    output [6:0]  m_vvec2c_r;
    output [10:0] m_hvec3c_r;
    output [6:0]  m_vvec3c_r;
    output [10:0] m_hvec4c_r;
    output [6:0]  m_vvec4c_r;
    output        m_ref1yen_r;
    output        m_ref1cen_r;
    output        m_ref2yen_r;
    output        m_ref2cen_r;

    reg m_mbpl_uc_r_s;
    reg m_mbpl_dc_r_s;
    reg m_mbpl_mc_r_s;
    reg m_mbpl_idct_out_r_s;
    reg m_frm_inter_mc_r;
    reg m_frm_prog_mc_r;
    reg m_frm_pred_over_mc_r;
    reg m_frm_inter_uc_r;
    reg m_frm_prog_uc_r;
    reg m_frm_pred_over_uc_r;
    reg m_frm_fidp_r;
    reg m_half_hpelf_r;
    reg m_half_vpelf_r;
    reg m_line17_cutf_r;
    reg m_half_hpelb_r;
    reg m_half_vpelb_r;
    reg m_line17_cutb_r;
    reg m_motion_dp_r;
    reg [11:0] m_hvec1y_r;
    reg [7:0] m_vvec1y_r;
    reg [11:0] m_hvec2y_r;
    reg [7:0] m_vvec2y_r;
    reg [11:0] m_hvec3y_r;
    reg [7:0] m_vvec3y_r;
    reg [11:0] m_hvec4y_r;
    reg [7:0] m_vvec4y_r;
    reg [10:0] m_hvec1c_r;
    reg [6:0] m_vvec1c_r;
    reg [10:0] m_hvec2c_r;
    reg [6:0] m_vvec2c_r;
    reg [10:0] m_hvec3c_r;
    reg [6:0] m_vvec3c_r;
    reg [10:0] m_hvec4c_r;
    reg [6:0] m_vvec4c_r;

    reg [11:0] m_hvec1y_0_r;
    reg [7:0] m_vvec1y_0_r;
    reg [11:0] m_hvec2y_0_r;
    reg [7:0] m_vvec2y_0_r;
    reg [11:0] m_hvec3y_0_r;
    reg [7:0] m_vvec3y_0_r;
    reg [11:0] m_hvec4y_0_r;
    reg [7:0] m_vvec4y_0_r;
    reg [10:0] m_hvec1c_0_r;
    reg [6:0] m_vvec1c_0_r;
    reg [10:0] m_hvec2c_0_r;
    reg [6:0] m_vvec2c_0_r;
    reg [10:0] m_hvec3c_0_r;
    reg [6:0] m_vvec3c_0_r;
    reg [10:0] m_hvec4c_0_r;
    reg [6:0] m_vvec4c_0_r;

    reg m_ref1yen_r;
    reg m_ref1cen_r;
    reg m_ref2yen_r;
    reg m_ref2cen_r;

    reg ff_mbpl_psft_r;
    reg ff_mbpl_uc_r;
    reg ff_mbpl_dc_r;
    reg ff_mbpl_mc_r;
    reg ff_mbpl_idct_out_r;
    reg [12:0] ff_fstfwdvech_buc_r;
    reg [8:0] ff_fstfwdvecv_buc_r;
    reg [12:0] ff_sndfwdvech_buc_r;
    reg [8:0] ff_sndfwdvecv_buc_r;
    reg [12:0] ff_fstbwdvech_buc_r;
    reg [8:0] ff_fstbwdvecv_buc_r;
    reg [12:0] ff_sndbwdvech_buc_r;
    reg [8:0] ff_sndbwdvecv_buc_r;
    reg [1:0] ff_mttyp_mc_r;
    reg ff_prgseq_mc_r;
    reg [1:0] ff_pstr_buc_r;
    reg ff_tfst_buc_r;
    reg [1:0] ff_dmvh_buc_r;
    reg [1:0] ff_dmvv_buc_r;
    reg ff_ref1yen_r;
    reg ff_ref1cen_r;
    reg ff_ref2yen_r;
    reg ff_ref2cen_r;

    reg [2:0] sel_r;
    
    wire [11:0] vct_mcy00;
    wire [7:0] vct_mcy01;
    wire [11:0] vct_mcy02;
    wire [7:0] vct_mcy03;
    wire [11:0] vct_mcy04;
    wire [7:0] vct_mcy05;
    wire [11:0] vct_mcy06;
    wire [7:0] vct_mcy07;
    
    wire [11:0] vct_mcy10;
    wire [7:0] vct_mcy11;
    wire [11:0] vct_mcy12;
    wire [7:0] vct_mcy13;
    wire [11:0] vct_mcy14;
    wire [7:0] vct_mcy15;
    wire [11:0] vct_mcy16;
    wire [7:0] vct_mcy17;
    
    wire [11:0] vct_mcy20;
    wire [7:0] vct_mcy21;
    wire [11:0] vct_mcy22;
    wire [7:0] vct_mcy23;
    wire [11:0] vct_mcy24;
    wire [7:0] vct_mcy25;
    wire [11:0] vct_mcy26;
    wire [7:0] vct_mcy27;
    
    wire [11:0] vct_mcy30;
    wire [7:0] vct_mcy31;
    wire [11:0] vct_mcy32;
    wire [7:0] vct_mcy33;
    wire [11:0] vct_mcy34;
    wire [7:0] vct_mcy35;
    wire [11:0] vct_mcy36;
    wire [7:0] vct_mcy37;
    
    wire [11:0] vct_mcy40;
    wire [7:0] vct_mcy41;
    wire [11:0] vct_mcy42;
    wire [7:0] vct_mcy43;
    wire [11:0] vct_mcy44;
    wire [7:0] vct_mcy45;
    wire [11:0] vct_mcy46;
    wire [7:0] vct_mcy47;
    
    wire [11:0] vct_mcy50;
    wire [7:0] vct_mcy51;
    wire [11:0] vct_mcy52;
    wire [7:0] vct_mcy53;
    wire [11:0] vct_mcy54;
    wire [7:0] vct_mcy55;
    wire [11:0] vct_mcy56;
    wire [7:0] vct_mcy57;

    wire [14:0] node_calc_mul_mch;
    wire [13:0] node_div_mul_mch;
    wire [13:0] node_vct_mul_mch;
    wire [11:0] node_ans_mul_mch;
    wire [13:0] node_ffvech_ext;
    wire [13:0] node_div_nor_mch;
    wire [13:0] node_vct_nor_mch;
    wire [11:0] node_ans_nor_mch;
    wire [13:0] node_dmv_horizontal;
    wire [11:0] node_ans_mul_mch_pl;
    wire [11:0] node_ans_mul_mch_nl;

    wire [10:0] node_calc_mul_mcv;
    wire [9:0] node_div_mul_mcv;
    wire [9:0] node_vctp_mul_mcv;
    wire [9:0] node_vctm_mul_mcv;
    wire [7:0] node_ansp_mul_mcv;
    wire [7:0] node_ansm_mul_mcv;
    wire [9:0] node_ffvecv_ext;
    wire [9:0] node_div_nor_mcv;
    wire [9:0] node_vctp_nor_mcv;
    wire [9:0] node_vctm_nor_mcv;
    wire [7:0] node_ansp_nor_mcv;
    wire [7:0] node_ansm_nor_mcv;
    wire [9:0] node_dmv_vertical;
    wire [7:0] node_ansp_mul_mcv_pl;
    wire [7:0] node_ansp_mul_mcv_nl;
    wire [7:0] node_ansm_mul_mcv_pl;
    wire [7:0] node_ansm_mul_mcv_nl;
    wire [7:0] node_ansp_nor_mcv_pl;
    wire [7:0] node_ansp_nor_mcv_nl;
    wire [7:0] node_ansm_nor_mcv_pl;
    wire [7:0] node_ansm_nor_mcv_nl;

    wire [11:0] node_vc000_cal;
    wire [7:0] node_vc001_cal;
    wire [11:0] node_vc010_cal;
    wire [7:0] node_vc011_cal;
    wire [11:0] node_vc100_cal;
    wire [7:0] node_vc101_cal;
    wire [11:0] node_vc110_cal;
    wire [7:0] node_vc111_cal;

    wire [10:0] vct_mcc00;
    wire [6:0] vct_mcc01;
    wire [10:0] vct_mcc02;
    wire [6:0] vct_mcc03;
    wire [10:0] vct_mcc04;
    wire [6:0] vct_mcc05;
    wire [10:0] vct_mcc06;
    wire [6:0] vct_mcc07;
    wire [10:0] vct_mcc10;
    wire [6:0] vct_mcc11;
    wire [10:0] vct_mcc12;
    wire [6:0] vct_mcc13;
    wire [10:0] vct_mcc14;
    wire [6:0] vct_mcc15;
    wire [10:0] vct_mcc16;
    wire [6:0] vct_mcc17;
    wire [10:0] vct_mcc20;
    wire [6:0] vct_mcc21;
    wire [10:0] vct_mcc22;
    wire [6:0] vct_mcc23;
    wire [10:0] vct_mcc24;
    wire [6:0] vct_mcc25;
    wire [10:0] vct_mcc26;
    wire [6:0] vct_mcc27;
    wire [10:0] vct_mcc30;
    wire [6:0] vct_mcc31;
    wire [10:0] vct_mcc32;
    wire [6:0] vct_mcc33;
    wire [10:0] vct_mcc34;
    wire [6:0] vct_mcc35;
    wire [10:0] vct_mcc36;
    wire [6:0] vct_mcc37;
    wire [10:0] vct_mcc40;
    wire [6:0] vct_mcc41;
    wire [10:0] vct_mcc42;
    wire [6:0] vct_mcc43;
    wire [10:0] vct_mcc44;
    wire [6:0] vct_mcc45;
    wire [10:0] vct_mcc46;
    wire [6:0] vct_mcc47;
    wire [10:0] vct_mcc50;
    wire [6:0] vct_mcc51;
    wire [10:0] vct_mcc52;
    wire [6:0] vct_mcc53;
    wire [10:0] vct_mcc54;
    wire [6:0] vct_mcc55;
    wire [10:0] vct_mcc56;
    wire [6:0] vct_mcc57;
    
    wire [12:0] node_rev_mul_mcch;
    wire [11:0] node_ans_mul_mcch;
    wire [11:0] node_rev_nor_mcch;
    wire [10:0] node_ans_nor_mcch;
    wire [8:0] node_revp_mul_mccv;
    wire [8:0] node_revm_mul_mccv;
    wire [6:0] node_ansp_mul_mccv;
    wire [6:0] node_ansm_mul_mccv;
    wire [8:0] node_revp_nor_mccv;
    wire [8:0] node_revm_nor_mccv;
    wire [6:0] node_ansp_nor_mccv;
    wire [6:0] node_ansm_nor_mccv;
    wire [11:0] node_ans_mul_mcch_pl;
    wire [11:0] node_ans_mul_mcch_nl;
    wire [6:0] node_ansp_mul_mccv_pl;
    wire [6:0] node_ansp_mul_mccv_nl;
    wire [6:0] node_ansm_mul_mccv_pl;
    wire [6:0] node_ansm_mul_mccv_nl;
    wire [6:0] node_ansp_nor_mccv_pl;
    wire [6:0] node_ansp_nor_mccv_nl;
    wire [6:0] node_ansm_nor_mccv_pl;
    wire [6:0] node_ansm_nor_mccv_nl;
    
    wire node_hpelfty;
    wire node_hpelfby;
    wire node_hpelbty;
    wire node_hpelbby;
    wire node_vpelfty;
    wire node_vpelfby;
    wire node_vpelbty;
    wire node_vpelbby;
    wire node_cutfty;
    wire node_cutfby;
    wire node_cutbty;
    wire node_cutbby;
    wire node_hpelbty_pl;
    wire node_hpelbty_nl;
    wire node_hpelbby_pl;
    wire node_hpelbby_nl_nl;
    wire node_hpelbby_nl;
    wire node_vpelbty_pl;
    wire node_vpelbty_nl_pl;
    wire node_vpelbty_nl;
    wire node_vpelbby_pl;
    wire node_vpelbby_nl_pl;
    wire node_vpelbby_nl_nl;
    wire node_vpelbby_nl;

    wire node_hpelftc;
    wire node_hpelfbc;
    wire node_hpelbtc;
    wire node_hpelbbc;
    wire node_vpelftc;
    wire node_vpelfbc;
    wire node_vpelbtc;
    wire node_vpelbbc;
    wire node_cutftc;
    wire node_cutfbc;
    wire node_cutbtc;
    wire node_cutbbc;
    wire node_hpelbtc_pl;
    wire node_hpelbtc_nl;
    wire node_hpelbbc_pl;
    wire node_hpelbbc_nl_nl;
    wire node_hpelbbc_nl;
    wire node_vpelbtc_pl;
    wire node_vpelbtc_nl_pl;
    wire node_vpelbtc_nl;
    wire node_vpelbbc_pl;
    wire node_vpelbbc_nl_pl;
    wire node_vpelbbc_nl_nl;
    wire node_vpelbbc_nl;

    reg [8:0] cnt_uc_r;
    reg [8:0] cnt_mc_r;

    reg ff_uc_hpelfty_r;
    reg ff_uc_hpelfby_r;
    reg ff_uc_hpelbty_r;
    reg ff_uc_hpelbby_r;
    reg ff_uc_vpelfty_r;
    reg ff_uc_vpelfby_r;
    reg ff_uc_vpelbty_r;
    reg ff_uc_vpelbby_r;
    reg ff_uc_cutfty_r;
    reg ff_uc_cutfby_r;
    reg ff_uc_cutbty_r;
    reg ff_uc_cutbby_r;
    reg ff_uc_hpelftc_r;
    reg ff_uc_hpelfbc_r;
    reg ff_uc_hpelbtc_r;
    reg ff_uc_hpelbbc_r;
    reg ff_uc_vpelftc_r;
    reg ff_uc_vpelfbc_r;
    reg ff_uc_vpelbtc_r;
    reg ff_uc_vpelbbc_r;
    reg ff_uc_cutftc_r;
    reg ff_uc_cutfbc_r;
    reg ff_uc_cutbtc_r;
    reg ff_uc_cutbbc_r;

    reg ff_ps_hpelfty_r;
    reg ff_ps_hpelfby_r;
    reg ff_ps_hpelbty_r;
    reg ff_ps_hpelbby_r;
    reg ff_ps_vpelfty_r;
    reg ff_ps_vpelfby_r;
    reg ff_ps_vpelbty_r;
    reg ff_ps_vpelbby_r;
    reg ff_ps_cutfty_r;
    reg ff_ps_cutfby_r;
    reg ff_ps_cutbty_r;
    reg ff_ps_cutbby_r;
    reg ff_ps_hpelftc_r;
    reg ff_ps_hpelfbc_r;
    reg ff_ps_hpelbtc_r;
    reg ff_ps_hpelbbc_r;
    reg ff_ps_vpelftc_r;
    reg ff_ps_vpelfbc_r;
    reg ff_ps_vpelbtc_r;
    reg ff_ps_vpelbbc_r;
    reg ff_ps_cutftc_r;
    reg ff_ps_cutfbc_r;
    reg ff_ps_cutbtc_r;
    reg ff_ps_cutbbc_r;

    reg ff_mc_vpelfty_r;
    reg ff_mc_vpelfby_r;
    reg ff_mc_vpelbty_r;
    reg ff_mc_vpelbby_r;
    reg ff_mc_cutfty_r;
    reg ff_mc_cutfby_r;
    reg ff_mc_cutbty_r;
    reg ff_mc_cutbby_r;
    reg ff_mc_vpelftc_r;
    reg ff_mc_vpelfbc_r;
    reg ff_mc_vpelbtc_r;
    reg ff_mc_vpelbbc_r;
    reg ff_mc_cutftc_r;
    reg ff_mc_cutfbc_r;
    reg ff_mc_cutbtc_r;
    reg ff_mc_cutbbc_r;

    reg ff_sel_vpelfty_r;
    reg ff_sel_vpelfby_r;
    reg ff_sel_vpelbty_r;
    reg ff_sel_vpelbby_r;
    reg ff_sel_cutfty_r;
    reg ff_sel_cutfby_r;
    reg ff_sel_cutbty_r;
    reg ff_sel_cutbby_r;
    reg ff_sel_vpelftc_r;
    reg ff_sel_vpelfbc_r;
    reg ff_sel_vpelbtc_r;
    reg ff_sel_vpelbbc_r;
    reg ff_sel_cutftc_r;
    reg ff_sel_cutfbc_r;
    reg ff_sel_cutbtc_r;
    reg ff_sel_cutbbc_r;

    reg ff_frm_inter_uc_r;
    reg ff_frm_prog_uc_r;
    reg ff_frm_pred_over_uc_r;
    reg ff_frm_inter_mc_r;
    reg ff_frm_prog_mc_r;
    reg ff_frm_pred_over_mc_r;

    reg ff_frm_fidp0_r;
    reg ff_frm_fidp1_r;
    reg ff_frm_fidp2_r;

    reg ff_motion_dp0_r;
    reg ff_motion_dp1_r;
    reg ff_motion_dp2_r;
    
    reg [2:0] ff_ref1yen_dly_r;
    reg [2:0] ff_ref1cen_dly_r;
    reg [2:0] ff_ref2yen_dly_r;
    reg [2:0] ff_ref2cen_dly_r;
    
always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
    begin
        ff_fstfwdvech_buc_r <= 0;
        ff_fstfwdvecv_buc_r <= 0;
        ff_sndfwdvech_buc_r <= 0;
        ff_sndfwdvecv_buc_r <= 0;
        ff_fstbwdvech_buc_r <= 0;
        ff_fstbwdvecv_buc_r <= 0;
        ff_sndbwdvech_buc_r <= 0;
        ff_sndbwdvecv_buc_r <= 0;
        ff_mttyp_mc_r <= 0;
        ff_prgseq_mc_r <= 0;
        ff_pstr_buc_r <= 0;
        ff_tfst_buc_r <= 0;
        ff_dmvh_buc_r <= 0;
        ff_dmvv_buc_r <= 0;
    end
    else
    begin
        if(c_mbpl_mcalc_r_s)
        begin
            ff_fstfwdvech_buc_r <= p_fstfwdvech_buc_r;
            ff_fstfwdvecv_buc_r <= p_fstfwdvecv_buc_r;
            ff_fstbwdvech_buc_r <= p_fstbwdvech_buc_r;
            ff_fstbwdvecv_buc_r <= p_fstbwdvecv_buc_r;
            ff_sndfwdvech_buc_r <= p_sndfwdvech_buc_r;
            ff_sndfwdvecv_buc_r <= p_sndfwdvecv_buc_r;
            ff_sndbwdvech_buc_r <= p_sndbwdvech_buc_r;
            ff_sndbwdvecv_buc_r <= p_sndbwdvecv_buc_r;
            ff_mttyp_mc_r <= p_mttyp_buc_r;
            ff_prgseq_mc_r <= p_prgseq_buc_r;
            ff_pstr_buc_r <= p_pstr_buc_r;
            ff_tfst_buc_r <= p_tfst_buc_r;
            ff_dmvh_buc_r <= p_dmvh_buc_r;
            ff_dmvv_buc_r <= p_dmvv_buc_r;
        end
    end
end

always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
    begin
        ff_mbpl_psft_r <= 0;
        ff_mbpl_uc_r <= 0;
        ff_mbpl_dc_r <= 0;
        ff_mbpl_mc_r <= 0;
        ff_mbpl_idct_out_r <= 0;
        ff_ref1yen_r <= 0;
        ff_ref1cen_r <= 0;
        ff_ref2yen_r <= 0;
        ff_ref2cen_r <= 0;
        ff_ref1yen_dly_r <= 3'h0;
        ff_ref1cen_dly_r <= 3'h0;
        ff_ref2yen_dly_r <= 3'h0;
        ff_ref2cen_dly_r <= 3'h0;
    end
    else
    begin
        ff_mbpl_psft_r <= c_mbpl_psft_r_s;
        ff_mbpl_uc_r <= c_mbpl_uc_r_s;
        ff_mbpl_dc_r <= c_mbpl_dc_r_s;
        ff_mbpl_mc_r <= c_mbpl_mc_r_s;
        ff_mbpl_idct_out_r <= c_mbpl_idct_out_r_s;
        ff_ref1yen_r <= ff_ref1yen_dly_r[2] ;
        ff_ref1cen_r <= ff_ref1cen_dly_r[2] ;
        ff_ref2yen_r <= ff_ref2yen_dly_r[2] ;
        ff_ref2cen_r <= ff_ref2cen_dly_r[2] ;
        ff_ref1yen_dly_r <= {ff_ref1yen_dly_r[1:0],u_ref1yen_r};
        ff_ref1cen_dly_r <= {ff_ref1cen_dly_r[1:0],u_ref1cen_r};
        ff_ref2yen_dly_r <= {ff_ref2yen_dly_r[1:0],u_ref2yen_r};
        ff_ref2cen_dly_r <= {ff_ref2cen_dly_r[1:0],u_ref2cen_r};
    end
end


always @(ff_pstr_buc_r or ff_mttyp_mc_r)
begin
   if(ff_pstr_buc_r == 2'd3 && ff_mttyp_mc_r == 2'd2)
   begin
      sel_r = 3'd0;
   end
   else
   begin
      if(ff_pstr_buc_r == 2'd3 && ff_mttyp_mc_r == 2'd1)
      begin
         sel_r = 3'd2;
      end
      else
      begin
         if(ff_mttyp_mc_r == 2'd1)
         begin
            sel_r = 3'd1;
         end
         else
         begin
            if(ff_mttyp_mc_r == 2'd2)
            begin
               sel_r = 3'd3;
            end
            else
            begin
               if(ff_pstr_buc_r == 2'd3 && ff_mttyp_mc_r == 2'd3)
               begin
                  sel_r = 3'd4;
               end
               else
               begin
                  sel_r = 3'd5;
               end
            end
         end
      end
   end
end


assign  vct_mcy00 = ff_fstfwdvech_buc_r[12:1];
assign  vct_mcy01 = {ff_fstfwdvecv_buc_r[8],ff_fstfwdvecv_buc_r[8:2]};
assign  vct_mcy02 = ff_fstfwdvech_buc_r[12:1];
assign  vct_mcy03 = {ff_fstfwdvecv_buc_r[8],ff_fstfwdvecv_buc_r[8:2]};
assign  vct_mcy04 = ff_fstbwdvech_buc_r[12:1];
assign  vct_mcy05 = {ff_fstbwdvecv_buc_r[8],ff_fstbwdvecv_buc_r[8:2]};
assign  vct_mcy06 = ff_fstbwdvech_buc_r[12:1];
assign  vct_mcy07 = {ff_fstbwdvecv_buc_r[8],ff_fstbwdvecv_buc_r[8:2]};

assign  vct_mcy10 = ff_fstfwdvech_buc_r[12:1];
assign  vct_mcy11 = ff_fstfwdvecv_buc_r[8:1];
assign  vct_mcy12 = ff_fstfwdvech_buc_r[12:1];
assign  vct_mcy13 = ff_fstfwdvecv_buc_r[8:1];
assign  vct_mcy14 = ff_fstbwdvech_buc_r[12:1];
assign  vct_mcy15 = ff_fstbwdvecv_buc_r[8:1];
assign  vct_mcy16 = ff_fstbwdvech_buc_r[12:1];
assign  vct_mcy17 = ff_fstbwdvecv_buc_r[8:1];

assign  vct_mcy20 = ff_fstfwdvech_buc_r[12:1];
assign  vct_mcy21 = ff_fstfwdvecv_buc_r[8:1];
assign  vct_mcy22 = ff_sndfwdvech_buc_r[12:1];
assign  vct_mcy23 = ff_sndfwdvecv_buc_r[8:1];
assign  vct_mcy24 = ff_fstbwdvech_buc_r[12:1];
assign  vct_mcy25 = ff_fstbwdvecv_buc_r[8:1];
assign  vct_mcy26 = ff_sndbwdvech_buc_r[12:1];
assign  vct_mcy27 = ff_sndbwdvecv_buc_r[8:1];

assign  vct_mcy30 = ff_fstfwdvech_buc_r[12:1];
assign  vct_mcy31 = ff_fstfwdvecv_buc_r[8:1];
assign  vct_mcy32 = ff_sndfwdvech_buc_r[12:1];
assign  vct_mcy33 = ff_sndfwdvecv_buc_r[8:1];
assign  vct_mcy34 = ff_fstbwdvech_buc_r[12:1];
assign  vct_mcy35 = ff_fstbwdvecv_buc_r[8:1];
assign  vct_mcy36 = ff_sndbwdvech_buc_r[12:1];
assign  vct_mcy37 = ff_sndbwdvecv_buc_r[8:1];

assign node_calc_mul_mch = {ff_fstfwdvech_buc_r[12],ff_fstfwdvech_buc_r[12:0], 1'b0}
                         + {ff_fstfwdvech_buc_r[12],ff_fstfwdvech_buc_r[12],ff_fstfwdvech_buc_r[12:0]};
assign node_div_mul_mch  = (node_calc_mul_mch[14]) ? node_calc_mul_mch[14:1] : (node_calc_mul_mch[14:1]+{13'h0000,node_calc_mul_mch[0]});
assign node_dmv_horizontal = (ff_dmvh_buc_r == 2'd3) ? 14'h3fff : {13'h0000,ff_dmvh_buc_r[0]};
assign node_vct_mul_mch  = node_div_mul_mch + node_dmv_horizontal;
assign node_ans_mul_mch_pl  = (node_vct_mul_mch[12:0]<13'h1000) ? 12'h800 : node_vct_mul_mch[12:1];
assign node_ans_mul_mch_nl  = (node_vct_mul_mch[12:0]>13'h0fff) ? 12'h7ff : node_vct_mul_mch[12:1];
assign node_ans_mul_mch  = (node_vct_mul_mch[13]) ? node_ans_mul_mch_pl : node_ans_mul_mch_nl ;

assign node_ffvech_ext = {ff_fstfwdvech_buc_r[12], ff_fstfwdvech_buc_r};
assign node_div_nor_mch  = node_ffvech_ext[13] ? node_ffvech_ext[13:1]
: (node_ffvech_ext[13:1]+(node_ffvech_ext[0]? 1'b1: 1'b0));
assign node_vct_nor_mch  = node_div_nor_mch + node_dmv_horizontal[12:0];
assign node_ans_nor_mch  = node_vct_nor_mch[12:1];

assign node_calc_mul_mcv = {ff_fstfwdvecv_buc_r[8], ff_fstfwdvecv_buc_r[8:0], 1'b0}
                         + {ff_fstfwdvecv_buc_r[8], ff_fstfwdvecv_buc_r[8], ff_fstfwdvecv_buc_r[8:0]};
assign node_div_mul_mcv  = node_calc_mul_mcv[10] ? node_calc_mul_mcv[10:1] : (node_calc_mul_mcv[10:1]+{9'h000,node_calc_mul_mcv[0]});
assign node_dmv_vertical = (ff_dmvv_buc_r == 2'd3) ? 10'h3ff : {9'h000,ff_dmvv_buc_r[0]};
assign node_vctp_mul_mcv  = node_div_mul_mcv + node_dmv_vertical + 10'd1;
assign node_vctm_mul_mcv  = node_div_mul_mcv + node_dmv_vertical - 10'd1;
assign node_ansp_mul_mcv_pl  = (node_vctp_mul_mcv[8:0]<9'h100) ? 8'h80 : node_vctp_mul_mcv[8:1];
assign node_ansp_mul_mcv_nl  = (node_vctp_mul_mcv[8:0]>9'h0ff) ? 8'h7f : node_vctp_mul_mcv[8:1];
assign node_ansp_mul_mcv  = node_vctp_mul_mcv[9] ? node_ansp_mul_mcv_pl : node_ansp_mul_mcv_nl;
assign node_ansm_mul_mcv_pl  = (node_vctm_mul_mcv[8:0]<9'h100) ? 8'h80 : node_vctm_mul_mcv[8:1];
assign node_ansm_mul_mcv_nl  = (node_vctm_mul_mcv[8:0]>9'h0ff) ? 8'h7f : node_vctm_mul_mcv[8:1];
assign node_ansm_mul_mcv  = node_vctm_mul_mcv[9] ? node_ansm_mul_mcv_pl : node_ansm_mul_mcv_nl;

assign node_ffvecv_ext = {ff_fstfwdvecv_buc_r[8], ff_fstfwdvecv_buc_r};
assign node_div_nor_mcv  = node_ffvecv_ext[9] ? {1'b1, node_ffvecv_ext[9:1]}
                                              : ({1'b0, node_ffvecv_ext[9:1]} + {9'h000,node_ffvecv_ext[0]});
assign node_vctp_nor_mcv  = node_div_nor_mcv + node_dmv_vertical[9:0] + 10'd1;
assign node_vctm_nor_mcv  = node_div_nor_mcv + node_dmv_vertical[9:0] - 10'd1;
assign node_ansp_nor_mcv_pl  = (node_vctp_nor_mcv[8:0]<9'h100) ? 8'h80 : node_vctp_nor_mcv[8:1];
assign node_ansp_nor_mcv_nl  = (node_vctp_nor_mcv[8:0]>9'h0ff) ? 8'h7f : node_vctp_nor_mcv[8:1];
assign node_ansp_nor_mcv  = node_vctp_nor_mcv[9] ? node_ansp_nor_mcv_pl
                                                 : node_ansp_nor_mcv_nl;
assign node_ansm_nor_mcv_pl  = (node_vctm_nor_mcv[8:0]<9'h100) ? 8'h80 : node_vctm_nor_mcv[8:1];
assign node_ansm_nor_mcv_nl  = (node_vctm_nor_mcv[8:0]>9'h0ff) ? 8'h7f : node_vctm_nor_mcv[8:1];
assign node_ansm_nor_mcv  = node_vctm_nor_mcv[9] ? node_ansm_nor_mcv_pl
                                                 : node_ansm_nor_mcv_nl;

assign  vct_mcy40 = ff_fstfwdvech_buc_r[12:1];
assign  vct_mcy41 = ff_fstfwdvecv_buc_r[8:1];
assign  vct_mcy42 = ff_fstfwdvech_buc_r[12:1];
assign  vct_mcy43 = ff_fstfwdvecv_buc_r[8:1];
assign  vct_mcy44 = (ff_tfst_buc_r) ? node_ans_nor_mch : node_ans_mul_mch ;
assign  vct_mcy45 = (ff_tfst_buc_r) ? node_ansm_nor_mcv : node_ansm_mul_mcv ;
assign  vct_mcy46 = (ff_tfst_buc_r) ? node_ans_mul_mch : node_ans_nor_mch ;
assign  vct_mcy47 = (ff_tfst_buc_r) ? node_ansp_mul_mcv : node_ansp_nor_mcv ;

assign  vct_mcy50 = ff_fstfwdvech_buc_r[12:1];
assign  vct_mcy51 = ff_fstfwdvecv_buc_r[8:1];
assign  vct_mcy52 = ff_fstfwdvech_buc_r[12:1];
assign  vct_mcy53 = ff_fstfwdvecv_buc_r[8:1];
assign  vct_mcy54 = node_ans_nor_mch ;
assign  vct_mcy55 = (ff_pstr_buc_r==2'b01) ? node_ansm_nor_mcv : node_ansp_nor_mcv ;
assign  vct_mcy56 = node_ans_nor_mch ;
assign  vct_mcy57 = (ff_pstr_buc_r==2'b01) ? node_ansm_nor_mcv : node_ansp_nor_mcv ;


assign node_vc000_cal = ((ff_fstfwdvech_buc_r[12]) ?
(ff_fstfwdvech_buc_r[12:1] + (ff_fstfwdvech_buc_r[0]? 1'b1: 1'b0)) : ff_fstfwdvech_buc_r[12:1]);
assign node_vc001_cal = ((ff_fstfwdvecv_buc_r[8]) ? (ff_fstfwdvecv_buc_r[8:1] + (ff_fstfwdvecv_buc_r[0]? 1'b1: 1'b0)) : ff_fstfwdvecv_buc_r[8:1]);
assign node_vc010_cal = ((ff_fstbwdvech_buc_r[12]) ? (ff_fstbwdvech_buc_r[12:1] + (ff_fstbwdvech_buc_r[0]? 1'b1: 1'b0)) : ff_fstbwdvech_buc_r[12:1]);
assign node_vc011_cal = ((ff_fstbwdvecv_buc_r[8]) ? (ff_fstbwdvecv_buc_r[8:1] + (ff_fstbwdvecv_buc_r[0]? 1'b1: 1'b0)) : ff_fstbwdvecv_buc_r[8:1]);
assign node_vc100_cal = ((ff_sndfwdvech_buc_r[12]) ? (ff_sndfwdvech_buc_r[12:1] + (ff_sndfwdvech_buc_r[0]? 1'b1: 1'b0)) : ff_sndfwdvech_buc_r[12:1]);
assign node_vc101_cal = ((ff_sndfwdvecv_buc_r[8]) ? (ff_sndfwdvecv_buc_r[8:1] + (ff_sndfwdvecv_buc_r[0]? 1'b1: 1'b0)) : ff_sndfwdvecv_buc_r[8:1]);
assign node_vc110_cal = ((ff_sndbwdvech_buc_r[12]) ? (ff_sndbwdvech_buc_r[12:1] + (ff_sndbwdvech_buc_r[0]? 1'b1: 1'b0)) : ff_sndbwdvech_buc_r[12:1]);
assign node_vc111_cal = ((ff_sndbwdvecv_buc_r[8]) ? (ff_sndbwdvecv_buc_r[8:1] + (ff_sndbwdvecv_buc_r[0]? 1'b1: 1'b0)) : ff_sndbwdvecv_buc_r[8:1]);

assign  vct_mcc00 = node_vc000_cal[11:1];
assign  vct_mcc01 = {node_vc001_cal[7],node_vc001_cal[7:2]};
assign  vct_mcc02 = node_vc000_cal[11:1];
assign  vct_mcc03 = {node_vc001_cal[7],node_vc001_cal[7:2]};
assign  vct_mcc04 = node_vc010_cal[11:1];
assign  vct_mcc05 = {node_vc011_cal[7],node_vc011_cal[7:2]};
assign  vct_mcc06 = node_vc010_cal[11:1];
assign  vct_mcc07 = {node_vc011_cal[7],node_vc011_cal[7:2]};

assign  vct_mcc10 = node_vc000_cal[11:1];
assign  vct_mcc11 = node_vc001_cal[7:1];
assign  vct_mcc12 = node_vc000_cal[11:1];
assign  vct_mcc13 = node_vc001_cal[7:1];
assign  vct_mcc14 = node_vc010_cal[11:1];
assign  vct_mcc15 = node_vc011_cal[7:1];
assign  vct_mcc16 = node_vc010_cal[11:1];
assign  vct_mcc17 = node_vc011_cal[7:1];

assign  vct_mcc20 = node_vc000_cal[11:1];
assign  vct_mcc21 = node_vc001_cal[7:1];
assign  vct_mcc22 = node_vc100_cal[11:1];
assign  vct_mcc23 = node_vc101_cal[7:1];
assign  vct_mcc24 = node_vc010_cal[11:1];
assign  vct_mcc25 = node_vc011_cal[7:1];
assign  vct_mcc26 = node_vc110_cal[11:1];
assign  vct_mcc27 = node_vc111_cal[7:1];

assign  vct_mcc30 = node_vc000_cal[11:1];
assign  vct_mcc31 = node_vc001_cal[7:1];
assign  vct_mcc32 = node_vc100_cal[11:1];
assign  vct_mcc33 = node_vc101_cal[7:1];
assign  vct_mcc34 = node_vc010_cal[11:1];
assign  vct_mcc35 = node_vc011_cal[7:1];
assign  vct_mcc36 = node_vc110_cal[11:1];
assign  vct_mcc37 = node_vc111_cal[7:1];

assign node_rev_mul_mcch  = node_vct_mul_mch[13] ? (node_vct_mul_mch[13:1] + {12'h000,node_vct_mul_mch[0]})
                                                 : node_vct_mul_mch[13:1];
assign node_ans_mul_mcch_pl  = (node_rev_mul_mcch[11:0]<12'h800) ? 11'h400 : node_rev_mul_mcch[11:1];
assign node_ans_mul_mcch_nl  = (node_rev_mul_mcch[11:0]>12'h7ff) ? 11'h3ff : node_rev_mul_mcch[11:1];
assign node_ans_mul_mcch  = node_rev_mul_mcch[12] ? node_ans_mul_mcch_pl : node_ans_mul_mcch_nl;

assign node_rev_nor_mcch  = node_vct_nor_mch[12] ? (node_vct_nor_mch[12:1] + {11'h000,node_vct_nor_mch[0]}) 
                                                 : node_vct_nor_mch[12:1];
assign node_ans_nor_mcch  = node_rev_nor_mcch[11:1];


assign node_revp_mul_mccv  = node_vctp_mul_mcv[9] ? (node_vctp_mul_mcv[9:1] + {8'h00,node_vctp_mul_mcv[0]})
                                                  : node_vctp_mul_mcv[9:1];
assign node_revm_mul_mccv  = node_vctm_mul_mcv[9] ? (node_vctm_mul_mcv[9:1] + {8'h00,node_vctm_mul_mcv[0]}) 
                                                  : node_vctm_mul_mcv[9:1];
assign node_ansp_mul_mccv_pl  = (node_revp_mul_mccv[7:0]<8'h80) ? 7'h40 : node_revp_mul_mccv[7:1];
assign node_ansp_mul_mccv_nl  = (node_revp_mul_mccv[7:0]>8'h7f) ? 7'h3f : node_revp_mul_mccv[7:1];
assign node_ansp_mul_mccv  = node_revp_mul_mccv[8] ? node_ansp_mul_mccv_pl : node_ansp_mul_mccv_nl;
assign node_ansm_mul_mccv_pl  = (node_revm_mul_mccv[7:0]<8'h80) ? 7'h40 : node_revm_mul_mccv[7:1];
assign node_ansm_mul_mccv_nl  = (node_revm_mul_mccv[7:0]>8'h7f) ? 7'h3f : node_revm_mul_mccv[7:1];
assign node_ansm_mul_mccv  = node_revm_mul_mccv[8] ? node_ansm_mul_mccv_pl : node_ansm_mul_mccv_nl;

assign node_revp_nor_mccv = node_vctp_nor_mcv[9] ? (node_vctp_nor_mcv[9:1] + {8'h00,node_vctp_nor_mcv[0]}) 
                                                 : node_vctp_nor_mcv[9:1];
assign node_revm_nor_mccv = node_vctm_nor_mcv[9] ? (node_vctm_nor_mcv[9:1] + {8'h00,node_vctm_nor_mcv[0]})
                                                 : node_vctm_nor_mcv[9:1];
assign node_ansp_nor_mccv_pl = (node_revp_nor_mccv[7:0]<8'h80) ? 7'h40 : node_revp_nor_mccv[7:1];
assign node_ansp_nor_mccv_nl = (node_revp_nor_mccv[7:0]>8'h7f) ? 7'h3f : node_revp_nor_mccv[7:1];
assign node_ansp_nor_mccv = node_revp_nor_mccv[8] ? node_ansp_nor_mccv_pl : node_ansp_nor_mccv_nl;
assign node_ansm_nor_mccv_pl = (node_revm_nor_mccv[7:0]<8'h80) ? 7'h40 : node_revm_nor_mccv[7:1];
assign node_ansm_nor_mccv_nl = (node_revm_nor_mccv[7:0]>8'h7f) ? 7'h3f : node_revm_nor_mccv[7:1];
assign node_ansm_nor_mccv = node_revm_nor_mccv[8] ? node_ansm_nor_mccv_pl : node_ansm_nor_mccv_nl;

assign  vct_mcc40 = node_vc000_cal[11:1];
assign  vct_mcc41 = node_vc001_cal[7:1];
assign  vct_mcc42 = node_vc000_cal[11:1];
assign  vct_mcc43 = node_vc001_cal[7:1];
assign  vct_mcc44 = (ff_tfst_buc_r) ? node_ans_nor_mcch  : node_ans_mul_mcch;
assign  vct_mcc45 = (ff_tfst_buc_r) ? node_ansm_nor_mccv : node_ansm_mul_mccv;
assign  vct_mcc46 = (ff_tfst_buc_r) ? node_ans_mul_mcch  : node_ans_nor_mcch;
assign  vct_mcc47 = (ff_tfst_buc_r) ? node_ansp_mul_mccv : node_ansp_nor_mccv;

assign  vct_mcc50 = node_vc000_cal[11:1];
assign  vct_mcc51 = node_vc001_cal[7:1];
assign  vct_mcc52 = node_vc000_cal[11:1];
assign  vct_mcc53 = node_vc001_cal[7:1];
assign  vct_mcc54 = node_ans_nor_mcch ;
assign  vct_mcc55 = (ff_pstr_buc_r==2'b01) ? node_ansm_nor_mccv : node_ansp_nor_mccv;
assign  vct_mcc56 = node_ans_nor_mcch ;
assign  vct_mcc57 = (ff_pstr_buc_r==2'b01) ? node_ansm_nor_mccv : node_ansp_nor_mccv;


always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
     begin
        m_hvec1y_0_r <= 0;
        m_vvec1y_0_r <= 0;
        m_hvec2y_0_r <= 0;
        m_vvec2y_0_r <= 0;
        m_hvec3y_0_r <= 0;
        m_vvec3y_0_r <= 0;
        m_hvec4y_0_r <= 0;
        m_vvec4y_0_r <= 0;
    end
    else
    begin
        if(sel_r == 3'd0)
        begin
            m_hvec1y_0_r <= vct_mcy00;
            m_vvec1y_0_r <= vct_mcy01;
            m_hvec2y_0_r <= vct_mcy02;
            m_vvec2y_0_r <= vct_mcy03;
            m_hvec3y_0_r <= vct_mcy04;
            m_vvec3y_0_r <= vct_mcy05;
            m_hvec4y_0_r <= vct_mcy06;
            m_vvec4y_0_r <= vct_mcy07;
        end
        else if(sel_r == 3'd1)
        begin
            m_hvec1y_0_r <= vct_mcy10;
            m_vvec1y_0_r <= vct_mcy11;
            m_hvec2y_0_r <= vct_mcy12;
            m_vvec2y_0_r <= vct_mcy13;
            m_hvec3y_0_r <= vct_mcy14;
            m_vvec3y_0_r <= vct_mcy15;
            m_hvec4y_0_r <= vct_mcy16;
            m_vvec4y_0_r <= vct_mcy17;
        end
        else if(sel_r == 3'd2)
        begin
            m_hvec1y_0_r <= vct_mcy20;
            m_vvec1y_0_r <= vct_mcy21;
            m_hvec2y_0_r <= vct_mcy22;
            m_vvec2y_0_r <= vct_mcy23;
            m_hvec3y_0_r <= vct_mcy24;
            m_vvec3y_0_r <= vct_mcy25;
            m_hvec4y_0_r <= vct_mcy26;
            m_vvec4y_0_r <= vct_mcy27;
        end
        else if(sel_r == 3'd3)
        begin
            m_hvec1y_0_r <= vct_mcy30;
            m_vvec1y_0_r <= vct_mcy31;
            m_hvec2y_0_r <= vct_mcy32;
            m_vvec2y_0_r <= vct_mcy33;
            m_hvec3y_0_r <= vct_mcy34;
            m_vvec3y_0_r <= vct_mcy35;
            m_hvec4y_0_r <= vct_mcy36;
            m_vvec4y_0_r <= vct_mcy37;
        end
        else if(sel_r == 3'd4)
        begin
            m_hvec1y_0_r <= vct_mcy40;
            m_vvec1y_0_r <= vct_mcy41;
            m_hvec2y_0_r <= vct_mcy42;
            m_vvec2y_0_r <= vct_mcy43;
            m_hvec3y_0_r <= vct_mcy44;
            m_vvec3y_0_r <= vct_mcy45;
            m_hvec4y_0_r <= vct_mcy46;
            m_vvec4y_0_r <= vct_mcy47;
        end
        else
        begin
            m_hvec1y_0_r <= vct_mcy50;
            m_vvec1y_0_r <= vct_mcy51;
            m_hvec2y_0_r <= vct_mcy52;
            m_vvec2y_0_r <= vct_mcy53;
            m_hvec3y_0_r <= vct_mcy54;
            m_vvec3y_0_r <= vct_mcy55;
            m_hvec4y_0_r <= vct_mcy56;
            m_vvec4y_0_r <= vct_mcy57;
        end
    end
end



always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
    begin
        m_hvec1c_0_r <= 0;
        m_vvec1c_0_r <= 0;
        m_hvec2c_0_r <= 0;
        m_vvec2c_0_r <= 0;
        m_hvec3c_0_r <= 0;
        m_vvec3c_0_r <= 0;
        m_hvec4c_0_r <= 0;
        m_vvec4c_0_r <= 0;
    end
    else
    begin
        if(sel_r == 3'd0)
        begin
            m_hvec1c_0_r <= vct_mcc00;
            m_vvec1c_0_r <= vct_mcc01;
            m_hvec2c_0_r <= vct_mcc02;
            m_vvec2c_0_r <= vct_mcc03;
            m_hvec3c_0_r <= vct_mcc04;
            m_vvec3c_0_r <= vct_mcc05;
            m_hvec4c_0_r <= vct_mcc06;
            m_vvec4c_0_r <= vct_mcc07;
        end
        else if(sel_r == 3'd1)
        begin
            m_hvec1c_0_r <= vct_mcc10;
            m_vvec1c_0_r <= vct_mcc11;
            m_hvec2c_0_r <= vct_mcc12;
            m_vvec2c_0_r <= vct_mcc13;
            m_hvec3c_0_r <= vct_mcc14;
            m_vvec3c_0_r <= vct_mcc15;
            m_hvec4c_0_r <= vct_mcc16;
            m_vvec4c_0_r <= vct_mcc17;
        end
        else if(sel_r == 3'd2)
        begin
            m_hvec1c_0_r <= vct_mcc20;
            m_vvec1c_0_r <= vct_mcc21;
            m_hvec2c_0_r <= vct_mcc22;
            m_vvec2c_0_r <= vct_mcc23;
            m_hvec3c_0_r <= vct_mcc24;
            m_vvec3c_0_r <= vct_mcc25;
            m_hvec4c_0_r <= vct_mcc26;
            m_vvec4c_0_r <= vct_mcc27;
        end
        else if(sel_r == 3'd3)
        begin
            m_hvec1c_0_r <= vct_mcc30;
            m_vvec1c_0_r <= vct_mcc31;
            m_hvec2c_0_r <= vct_mcc32;
            m_vvec2c_0_r <= vct_mcc33;
            m_hvec3c_0_r <= vct_mcc34;
            m_vvec3c_0_r <= vct_mcc35;
            m_hvec4c_0_r <= vct_mcc36;
            m_vvec4c_0_r <= vct_mcc37;
        end
        else if(sel_r == 3'd4)
        begin
            m_hvec1c_0_r <= vct_mcc40;
            m_vvec1c_0_r <= vct_mcc41;
            m_hvec2c_0_r <= vct_mcc42;
            m_vvec2c_0_r <= vct_mcc43;
            m_hvec3c_0_r <= vct_mcc44;
            m_vvec3c_0_r <= vct_mcc45;
            m_hvec4c_0_r <= vct_mcc46;
            m_vvec4c_0_r <= vct_mcc47;
        end
        else
        begin
            m_hvec1c_0_r <= vct_mcc50;
            m_vvec1c_0_r <= vct_mcc51;
            m_hvec2c_0_r <= vct_mcc52;
            m_vvec2c_0_r <= vct_mcc53;
            m_hvec3c_0_r <= vct_mcc54;
            m_vvec3c_0_r <= vct_mcc55;
            m_hvec4c_0_r <= vct_mcc56;
            m_vvec4c_0_r <= vct_mcc57;
        end
    end
end
        
always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
    begin
        m_hvec1y_r <= 0;
        m_vvec1y_r <= 0;
        m_hvec2y_r <= 0;
        m_vvec2y_r <= 0;
        m_hvec3y_r <= 0;
        m_vvec3y_r <= 0;
        m_hvec4y_r <= 0;
        m_vvec4y_r <= 0;
    end
    else
    begin
        m_hvec1y_r <= m_hvec1y_0_r;
        m_vvec1y_r <= m_vvec1y_0_r;
        m_hvec2y_r <= m_hvec2y_0_r;
        m_vvec2y_r <= m_vvec2y_0_r;
        m_hvec3y_r <= m_hvec3y_0_r;
        m_vvec3y_r <= m_vvec3y_0_r;
        m_hvec4y_r <= m_hvec4y_0_r;
        m_vvec4y_r <= m_vvec4y_0_r;
    end
end

always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
    begin
        m_hvec1c_r <= 0;
        m_vvec1c_r <= 0;
        m_hvec2c_r <= 0;
        m_vvec2c_r <= 0;
        m_hvec3c_r <= 0;
        m_vvec3c_r <= 0;
        m_hvec4c_r <= 0;
        m_vvec4c_r <= 0;
    end
    else
    begin
        m_hvec1c_r <= m_hvec1c_0_r;
        m_vvec1c_r <= m_vvec1c_0_r;
        m_hvec2c_r <= m_hvec2c_0_r;
        m_vvec2c_r <= m_vvec2c_0_r;
        m_hvec3c_r <= m_hvec3c_0_r;
        m_vvec3c_r <= m_vvec3c_0_r;
        m_hvec4c_r <= m_hvec4c_0_r;
        m_vvec4c_r <= m_vvec4c_0_r;
    end
end

always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
    begin
        ff_frm_inter_uc_r <= 0;
    end
    else
    begin
       if(ff_mbpl_psft_r)
       begin
          if(ff_pstr_buc_r == 2'd3 && ff_mttyp_mc_r == 2'd2 && !ff_prgseq_mc_r)
          begin
             ff_frm_inter_uc_r <= 1;
          end
          else
          begin
             ff_frm_inter_uc_r <= 0;
          end
       end
    end
end
        
always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
    begin
        ff_frm_prog_uc_r <= 0;
    end
    else if(ff_mbpl_psft_r)
    begin
        if(ff_pstr_buc_r == 2'd3 && ff_mttyp_mc_r == 2'd2 && ff_prgseq_mc_r)
        begin
            ff_frm_prog_uc_r <= 1;
        end
        else
        begin
            ff_frm_prog_uc_r <= 0;
        end
    end
end


always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
    begin
        ff_frm_pred_over_uc_r <= 0;
    end
    else
    begin
       if(ff_mbpl_psft_r)
       begin
          if(ff_pstr_buc_r == 2'd3 && ff_mttyp_mc_r == 2'd2)
          begin
             ff_frm_pred_over_uc_r <= 0;
          end
          else
          begin
             ff_frm_pred_over_uc_r <= 1;
          end
       end
    end
end

always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
    begin
        ff_frm_fidp0_r <= 0;
    end
    else
    begin
       if(ff_mbpl_psft_r)
       begin
         if(ff_pstr_buc_r == 2'd3 && ff_mttyp_mc_r[0])
         begin
             ff_frm_fidp0_r <= 1;
         end
         else
         begin
             ff_frm_fidp0_r <= 0;
         end
       end
    end
end

always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
    begin
        ff_motion_dp0_r <= 0;
    end
    else
    begin
       if(ff_mbpl_psft_r)
       begin
         if(ff_mttyp_mc_r == 2'd3) 
         begin
             ff_motion_dp0_r <= 1;
         end
         else
         begin
             ff_motion_dp0_r <= 0;
         end
       end
    end
end

always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
    begin
        m_frm_inter_uc_r <= 0;
        m_frm_prog_uc_r <= 0;
        m_frm_pred_over_uc_r <= 0;
        ff_frm_fidp1_r <= 0;
        ff_motion_dp1_r <= 0;
    end 
    else
    begin
       if(ff_mbpl_uc_r)
       begin
          m_frm_inter_uc_r <= ff_frm_inter_uc_r;
          m_frm_prog_uc_r <= ff_frm_prog_uc_r;
          m_frm_pred_over_uc_r <= ff_frm_pred_over_uc_r;
          ff_frm_fidp1_r <= ff_frm_fidp0_r;
          ff_motion_dp1_r <= ff_motion_dp0_r;
       end
    end
end

always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
    begin
        ff_frm_inter_mc_r <= 0;
        ff_frm_prog_mc_r <= 0;
        ff_frm_pred_over_mc_r <= 0;
        ff_frm_fidp2_r <= 0;
        ff_motion_dp2_r <= 0;
    end 
    else
    begin
       if(ff_mbpl_psft_r)
       begin
          ff_frm_inter_mc_r <= m_frm_inter_uc_r;
          ff_frm_prog_mc_r <= m_frm_prog_uc_r;
          ff_frm_pred_over_mc_r <= m_frm_pred_over_uc_r;
          ff_frm_fidp2_r <= ff_frm_fidp1_r;
          ff_motion_dp2_r <= ff_motion_dp1_r;
       end
    end
end

always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
    begin
        m_frm_inter_mc_r <= 0;
        m_frm_prog_mc_r <= 0;
        m_frm_pred_over_mc_r <= 0;
        m_frm_fidp_r <= 0;
        m_motion_dp_r <= 0;
    end 
    else
    begin
       if(ff_mbpl_mc_r)
       begin
          m_frm_inter_mc_r <= ff_frm_inter_mc_r;
          m_frm_prog_mc_r <= ff_frm_prog_mc_r;
          m_frm_pred_over_mc_r <= ff_frm_pred_over_mc_r;
          m_frm_fidp_r <= ff_frm_fidp2_r;
          m_motion_dp_r <= ff_motion_dp2_r;
       end
    end
end

always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
    begin
        m_mbpl_uc_r_s <= 0;
        m_mbpl_dc_r_s <= 0;
        m_mbpl_mc_r_s <= 0;
        m_mbpl_idct_out_r_s <= 0;
        m_ref1yen_r <= 0;
        m_ref1cen_r <= 0;
        m_ref2yen_r <= 0;
        m_ref2cen_r <= 0;
    end
    else
    begin
        m_mbpl_uc_r_s <= ff_mbpl_uc_r;
        m_mbpl_dc_r_s <= ff_mbpl_dc_r;
        m_mbpl_mc_r_s <= ff_mbpl_mc_r;
        m_mbpl_idct_out_r_s <= ff_mbpl_idct_out_r;
        m_ref1yen_r <= ff_ref1yen_r;
        m_ref1cen_r <= ff_ref1cen_r;
        m_ref2yen_r <= ff_ref2yen_r;
        m_ref2cen_r <= ff_ref2cen_r;
    end
end

assign node_hpelfty = ff_fstfwdvech_buc_r[0];
assign node_hpelfby = (sel_r == 3'd2 || sel_r == 3'd3) ? ff_sndfwdvech_buc_r[0] : ff_fstfwdvech_buc_r[0];
assign node_hpelbty_pl = (ff_tfst_buc_r) ? node_vct_nor_mch[0] : node_vct_mul_mch[0];
assign node_hpelbty_nl = (sel_r == 3'd5) ? node_vct_nor_mch[0] : ff_fstbwdvech_buc_r[0];
assign node_hpelbty = (sel_r == 3'd4) ? node_hpelbty_pl : node_hpelbty_nl;
assign node_hpelbby_pl = (ff_tfst_buc_r) ? node_vct_mul_mch[0] : node_vct_nor_mch[0];
assign node_hpelbby_nl_nl = (sel_r == 3'd2 || sel_r == 3'd3) ? ff_sndbwdvech_buc_r[0] : ff_fstbwdvech_buc_r[0];
assign node_hpelbby_nl = (sel_r == 3'd5) ? node_vct_nor_mch[0] : node_hpelbby_nl_nl;
assign node_hpelbby = (sel_r == 3'd4) ? node_hpelbby_pl : node_hpelbby_nl;
assign node_vpelfty = ff_fstfwdvecv_buc_r[0];
assign node_vpelfby = (sel_r == 3'd2 || sel_r == 3'd3) ? ff_sndfwdvecv_buc_r[0] : ff_fstfwdvecv_buc_r[0];
assign node_vpelbty_pl = (ff_tfst_buc_r) ? node_vctm_nor_mcv[0] : node_vctm_mul_mcv[0];
assign node_vpelbty_nl_pl = (ff_tfst_buc_r) ? node_vctm_nor_mcv[0] : node_vctp_nor_mcv[0];
assign node_vpelbty_nl = (sel_r == 3'd5) ? node_vpelbty_nl_pl : ff_fstbwdvecv_buc_r[0];
assign node_vpelbty = (sel_r == 3'd4) ? node_vpelbty_pl : node_vpelbty_nl;
assign node_vpelbby_pl = (ff_tfst_buc_r) ? node_vctp_mul_mcv[0] : node_vctm_nor_mcv[0];
assign node_vpelbby_nl_pl = (ff_tfst_buc_r) ? node_vctm_nor_mcv[0] : node_vctp_nor_mcv[0];
assign node_vpelbby_nl_nl = (sel_r == 3'd2 || sel_r == 3'd3) ? ff_sndbwdvecv_buc_r[0] : ff_fstbwdvecv_buc_r[0];
assign node_vpelbby_nl = (sel_r == 3'd5) ? node_vpelbby_nl_pl : node_vpelbby_nl_nl ;
assign node_vpelbby = (sel_r == 3'd4) ? node_vpelbby_pl : node_vpelbby_nl;
assign node_cutfty = (sel_r == 3'd0) ? ff_fstfwdvecv_buc_r[1] : 0;
assign node_cutfby = (sel_r == 3'd0) ? ff_fstfwdvecv_buc_r[1] : 0;
assign node_cutbty = (sel_r == 3'd0) ? ff_fstbwdvecv_buc_r[1] : 0;
assign node_cutbby = (sel_r == 3'd0) ? ff_fstbwdvecv_buc_r[1] : 0;

assign node_hpelftc = node_vc000_cal[0];
assign node_hpelfbc = (sel_r == 3'd2 || sel_r == 3'd3) ? node_vc100_cal[0]:node_vc000_cal[0];
assign node_hpelbtc_pl = (ff_tfst_buc_r) ? node_rev_nor_mcch[0] : node_rev_mul_mcch[0];
assign node_hpelbtc_nl = (sel_r == 3'd5) ? node_ans_nor_mcch[0] :node_vc010_cal[0];
assign node_hpelbtc = (sel_r == 3'd4) ? node_hpelbtc_pl : node_hpelbtc_nl;
assign node_hpelbbc_pl = (ff_tfst_buc_r) ? node_rev_mul_mcch[0] : node_rev_nor_mcch[0];
assign node_hpelbbc_nl_nl = (sel_r == 3'd2 || sel_r == 3'd3) ? node_vc110_cal[0]:node_vc010_cal[0];
assign node_hpelbbc_nl = (sel_r == 3'd5) ? node_ans_nor_mcch[0] : node_hpelbbc_nl_nl;
assign node_hpelbbc = (sel_r == 3'd4) ? node_hpelbbc_pl : node_hpelbbc_nl;
assign node_vpelftc = node_vc001_cal[0];
assign node_vpelfbc = (sel_r == 3'd2 || sel_r == 3'd3) ? node_vc101_cal[0]:node_vc001_cal[0];
assign node_vpelbtc_pl = (ff_tfst_buc_r) ? node_revm_nor_mccv[0] : node_revm_mul_mccv[0];
assign node_vpelbtc_nl_pl = (ff_tfst_buc_r) ? node_revm_nor_mccv[0] : node_revp_nor_mccv[0];
assign node_vpelbtc_nl = (sel_r == 3'd5) ? node_vpelbtc_nl_pl : node_vc011_cal[0];
assign node_vpelbtc = (sel_r == 3'd4) ? node_vpelbtc_pl : node_vpelbtc_nl;
assign node_vpelbbc_pl = (ff_tfst_buc_r) ? node_revp_mul_mccv[0] : node_revm_nor_mccv[0];
assign node_vpelbbc_nl_pl = (ff_tfst_buc_r) ? node_revm_nor_mccv[0] : node_revp_nor_mccv[0];
assign node_vpelbbc_nl_nl = (sel_r == 3'd2 || sel_r == 3'd3) ? node_vc111_cal[0]:node_vc011_cal[0];
assign node_vpelbbc_nl = (sel_r == 3'd5) ? node_vpelbbc_nl_pl : node_vpelbbc_nl_nl;
assign node_vpelbbc = (sel_r == 3'd4) ? node_vpelbbc_pl : node_vpelbbc_nl;
assign node_cutftc = (sel_r == 3'd0) ? node_vc001_cal[1] : 0;
assign node_cutfbc = (sel_r == 3'd0) ? node_vc001_cal[1] : 0;
assign node_cutbtc = (sel_r == 3'd0) ? node_vc011_cal[1] : 0;
assign node_cutbbc = (sel_r == 3'd0) ? node_vc011_cal[1] : 0;

always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
    begin
        cnt_uc_r <= 9'b1_1111_1111;
    end
    else
    begin
        if(ff_mbpl_uc_r)
        begin
            cnt_uc_r <= 9'b1_1111_1111;
        end
        else if(ff_ref1yen_dly_r[0] || ff_ref1cen_dly_r[0] || ff_ref2yen_dly_r[0] || ff_ref2cen_dly_r[0])
        begin
            cnt_uc_r <= cnt_uc_r + 9'b0_0000_0001;
        end
    end
end

always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
    begin
        cnt_mc_r <= 9'b1_1111_1111;
    end
    else
    begin
        if(ff_mbpl_mc_r)
        begin
            cnt_mc_r <= 9'b0_0000_0000;
        end
        else if ( cnt_mc_r != 9'b1_1111_1111 )
        begin
            cnt_mc_r <= cnt_mc_r + 9'b0_0000_0001;
        end
    end
end

always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
    begin
        ff_uc_hpelfty_r <= 0;
        ff_uc_hpelfby_r <= 0;
        ff_uc_hpelbty_r <= 0;
        ff_uc_hpelbby_r <= 0;
        ff_uc_vpelfty_r <= 0;
        ff_uc_vpelfby_r <= 0;
        ff_uc_vpelbty_r <= 0;
        ff_uc_vpelbby_r <= 0;
        ff_uc_cutfty_r <= 0;
        ff_uc_cutfby_r <= 0;
        ff_uc_cutbty_r <= 0;
        ff_uc_cutbby_r <= 0;
        ff_uc_hpelftc_r <= 0;
        ff_uc_hpelfbc_r <= 0;
        ff_uc_hpelbtc_r <= 0;
        ff_uc_hpelbbc_r <= 0;
        ff_uc_vpelftc_r <= 0;
        ff_uc_vpelfbc_r <= 0;
        ff_uc_vpelbtc_r <= 0;
        ff_uc_vpelbbc_r <= 0;
        ff_uc_cutftc_r <= 0;
        ff_uc_cutfbc_r <= 0;
        ff_uc_cutbtc_r <= 0;
        ff_uc_cutbbc_r <= 0;
    end
    else if(ff_mbpl_psft_r)
    begin
        ff_uc_hpelfty_r <= node_hpelfty;
        ff_uc_hpelfby_r <= node_hpelfby;
        ff_uc_hpelbty_r <= node_hpelbty;
        ff_uc_hpelbby_r <= node_hpelbby;
        ff_uc_vpelfty_r <= node_vpelfty;
        ff_uc_vpelfby_r <= node_vpelfby;
        ff_uc_vpelbty_r <= node_vpelbty;
        ff_uc_vpelbby_r <= node_vpelbby;
        ff_uc_cutfty_r <= node_cutfty;
        ff_uc_cutfby_r <= node_cutfby;
        ff_uc_cutbty_r <= node_cutbty;
        ff_uc_cutbby_r <= node_cutbby;
        ff_uc_hpelftc_r <= node_hpelftc;
        ff_uc_hpelfbc_r <= node_hpelfbc;
        ff_uc_hpelbtc_r <= node_hpelbtc;
        ff_uc_hpelbbc_r <= node_hpelbbc;
        ff_uc_vpelftc_r <= node_vpelftc;
        ff_uc_vpelfbc_r <= node_vpelfbc;
        ff_uc_vpelbtc_r <= node_vpelbtc;
        ff_uc_vpelbbc_r <= node_vpelbbc;
        ff_uc_cutftc_r <= node_cutftc;
        ff_uc_cutfbc_r <= node_cutfbc;
        ff_uc_cutbtc_r <= node_cutbtc;
        ff_uc_cutbbc_r <= node_cutbbc;
    end
end

always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
    begin
        ff_ps_hpelfty_r <= 0;
        ff_ps_hpelfby_r <= 0;
        ff_ps_hpelbty_r <= 0;
        ff_ps_hpelbby_r <= 0;
        ff_ps_vpelfty_r <= 0;
        ff_ps_vpelfby_r <= 0;
        ff_ps_vpelbty_r <= 0;
        ff_ps_vpelbby_r <= 0;
        ff_ps_cutfty_r <= 0;
        ff_ps_cutfby_r <= 0;
        ff_ps_cutbty_r <= 0;
        ff_ps_cutbby_r <= 0;
        ff_ps_hpelftc_r <= 0;
        ff_ps_hpelfbc_r <= 0;
        ff_ps_hpelbtc_r <= 0;
        ff_ps_hpelbbc_r <= 0;
        ff_ps_vpelftc_r <= 0;
        ff_ps_vpelfbc_r <= 0;
        ff_ps_vpelbtc_r <= 0;
        ff_ps_vpelbbc_r <= 0;
        ff_ps_cutftc_r <= 0;
        ff_ps_cutfbc_r <= 0;
        ff_ps_cutbtc_r <= 0;
        ff_ps_cutbbc_r <= 0;
    end
    else if(ff_mbpl_uc_r)
    begin
        ff_ps_hpelfty_r <= ff_uc_hpelfty_r;
        ff_ps_hpelfby_r <= ff_uc_hpelfby_r;
        ff_ps_hpelbty_r <= ff_uc_hpelbty_r;
        ff_ps_hpelbby_r <= ff_uc_hpelbby_r;
        ff_ps_vpelfty_r <= ff_uc_vpelfty_r;
        ff_ps_vpelfby_r <= ff_uc_vpelfby_r;
        ff_ps_vpelbty_r <= ff_uc_vpelbty_r;
        ff_ps_vpelbby_r <= ff_uc_vpelbby_r;
        ff_ps_cutfty_r <= ff_uc_cutfty_r;
        ff_ps_cutfby_r <= ff_uc_cutfby_r;
        ff_ps_cutbty_r <= ff_uc_cutbty_r;
        ff_ps_cutbby_r <= ff_uc_cutbby_r;
        ff_ps_hpelftc_r <= ff_uc_hpelftc_r;
        ff_ps_hpelfbc_r <= ff_uc_hpelfbc_r;
        ff_ps_hpelbtc_r <= ff_uc_hpelbtc_r;
        ff_ps_hpelbbc_r <= ff_uc_hpelbbc_r;
        ff_ps_vpelftc_r <= ff_uc_vpelftc_r;
        ff_ps_vpelfbc_r <= ff_uc_vpelfbc_r;
        ff_ps_vpelbtc_r <= ff_uc_vpelbtc_r;
        ff_ps_vpelbbc_r <= ff_uc_vpelbbc_r;
        ff_ps_cutftc_r <= ff_uc_cutftc_r;
        ff_ps_cutfbc_r <= ff_uc_cutfbc_r;
        ff_ps_cutbtc_r <= ff_uc_cutbtc_r;
        ff_ps_cutbbc_r <= ff_uc_cutbbc_r;
    end
end

always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
    begin
         m_half_hpelf_r <= 0;
         m_half_hpelb_r <= 0;
    end
    else
    begin
         if(!m_frm_pred_over_uc_r)
         begin
             if(cnt_uc_r <= 9'd161)
             begin
                 m_half_hpelf_r <= ff_ps_hpelfty_r;
                 m_half_hpelb_r <= ff_ps_hpelbty_r;
             end
             else if(cnt_uc_r <= 9'd261)
             begin
                 m_half_hpelf_r <= ff_ps_hpelftc_r;
                 m_half_hpelb_r <= ff_ps_hpelbtc_r;
             end
             else
             begin
                 m_half_hpelf_r <= 0;
                 m_half_hpelb_r <= 0;
             end
         end
         else
         begin
             if(cnt_uc_r <= 9'd80)
             begin
                 m_half_hpelf_r <= ff_ps_hpelfty_r;
                 m_half_hpelb_r <= ff_ps_hpelbty_r;
             end
             else if(cnt_uc_r <= 9'd161)
             begin
                 m_half_hpelf_r <= ff_ps_hpelfby_r;
                 m_half_hpelb_r <= ff_ps_hpelbby_r;
             end
             else if(cnt_uc_r <= 9'd186)
             begin
                 m_half_hpelf_r <= ff_ps_hpelftc_r;
                 m_half_hpelb_r <= ff_ps_hpelbtc_r;
             end
             else if(cnt_uc_r <= 9'd211)
             begin
                 m_half_hpelf_r <= ff_ps_hpelfbc_r;
                 m_half_hpelb_r <= ff_ps_hpelbbc_r;
             end
             else if(cnt_uc_r <= 9'd236)
             begin
                 m_half_hpelf_r <= ff_ps_hpelftc_r;
                 m_half_hpelb_r <= ff_ps_hpelbtc_r;
             end
             else if(cnt_uc_r <= 9'd261)
             begin
                 m_half_hpelf_r <= ff_ps_hpelfbc_r;
                 m_half_hpelb_r <= ff_ps_hpelbbc_r;
             end
             else
             begin
                 m_half_hpelf_r <= 0;
                 m_half_hpelb_r <= 0;
             end
         end
    end
end

always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
    begin
        ff_mc_vpelfty_r <= 0;
        ff_mc_vpelfby_r <= 0;
        ff_mc_vpelbty_r <= 0;
        ff_mc_vpelbby_r <= 0;
        ff_mc_cutfty_r <= 0;
        ff_mc_cutfby_r <= 0;
        ff_mc_cutbty_r <= 0;
        ff_mc_cutbby_r <= 0;
        ff_mc_vpelftc_r <= 0;
        ff_mc_vpelfbc_r <= 0;
        ff_mc_vpelbtc_r <= 0;
        ff_mc_vpelbbc_r <= 0;
        ff_mc_cutftc_r <= 0;
        ff_mc_cutfbc_r <= 0;
        ff_mc_cutbtc_r <= 0;
        ff_mc_cutbbc_r <= 0;
    end
    else if(ff_mbpl_psft_r)
    begin
        ff_mc_vpelfty_r <= ff_ps_vpelfty_r;
        ff_mc_vpelfby_r <= ff_ps_vpelfby_r;
        ff_mc_vpelbty_r <= ff_ps_vpelbty_r;
        ff_mc_vpelbby_r <= ff_ps_vpelbby_r;
        ff_mc_cutfty_r <= ff_ps_cutfty_r;
        ff_mc_cutfby_r <= ff_ps_cutfby_r;
        ff_mc_cutbty_r <= ff_ps_cutbty_r;
        ff_mc_cutbby_r <= ff_ps_cutbby_r;
        ff_mc_vpelftc_r <= ff_ps_vpelftc_r;
        ff_mc_vpelfbc_r <= ff_ps_vpelfbc_r;
        ff_mc_vpelbtc_r <= ff_ps_vpelbtc_r;
        ff_mc_vpelbbc_r <= ff_ps_vpelbbc_r;
        ff_mc_cutftc_r <= ff_ps_cutftc_r;
        ff_mc_cutfbc_r <= ff_ps_cutfbc_r;
        ff_mc_cutbtc_r <= ff_ps_cutbtc_r;
        ff_mc_cutbbc_r <= ff_ps_cutbbc_r;
    end
end

always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
    begin
        ff_sel_vpelfty_r <= 0;
        ff_sel_vpelfby_r <= 0;
        ff_sel_vpelbty_r <= 0;
        ff_sel_vpelbby_r <= 0;
        ff_sel_cutfty_r <= 0;
        ff_sel_cutfby_r <= 0;
        ff_sel_cutbty_r <= 0;
        ff_sel_cutbby_r <= 0;
        ff_sel_vpelftc_r <= 0;
        ff_sel_vpelfbc_r <= 0;
        ff_sel_vpelbtc_r <= 0;
        ff_sel_vpelbbc_r <= 0;
        ff_sel_cutftc_r <= 0;
        ff_sel_cutfbc_r <= 0;
        ff_sel_cutbtc_r <= 0;
        ff_sel_cutbbc_r <= 0;
    end
    else if(ff_mbpl_mc_r)
    begin
        ff_sel_vpelfty_r <= ff_mc_vpelfty_r;
        ff_sel_vpelfby_r <= ff_mc_vpelfby_r;
        ff_sel_vpelbty_r <= ff_mc_vpelbty_r;
        ff_sel_vpelbby_r <= ff_mc_vpelbby_r;
        ff_sel_cutfty_r <= ff_mc_cutfty_r;
        ff_sel_cutfby_r <= ff_mc_cutfby_r;
        ff_sel_cutbty_r <= ff_mc_cutbty_r;
        ff_sel_cutbby_r <= ff_mc_cutbby_r;
        ff_sel_vpelftc_r <= ff_mc_vpelftc_r;
        ff_sel_vpelfbc_r <= ff_mc_vpelfbc_r;
        ff_sel_vpelbtc_r <= ff_mc_vpelbtc_r;
        ff_sel_vpelbbc_r <= ff_mc_vpelbbc_r;
        ff_sel_cutftc_r <= ff_mc_cutftc_r;
        ff_sel_cutfbc_r <= ff_mc_cutfbc_r;
        ff_sel_cutbtc_r <= ff_mc_cutbtc_r;
        ff_sel_cutbbc_r <= ff_mc_cutbbc_r;
    end
end

always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
    begin
         m_half_vpelf_r <= 0;
         m_half_vpelb_r <= 0;
    end
    else
    begin
         if(!m_frm_pred_over_mc_r)
         begin
             if(cnt_mc_r <= 9'd255)
             begin
                 m_half_vpelf_r <= ff_sel_vpelfty_r;
                 m_half_vpelb_r <= ff_sel_vpelbty_r;
             end
             else if(cnt_mc_r <= 9'd383)
             begin
                 m_half_vpelf_r <= ff_sel_vpelftc_r;
                 m_half_vpelb_r <= ff_sel_vpelbtc_r;
             end
             else
             begin
                 m_half_vpelf_r <= 0;
                 m_half_vpelb_r <= 0;
             end
         end
         else
         begin
             if(cnt_mc_r <= 9'd127)
             begin
                 m_half_vpelf_r <= ff_sel_vpelfty_r;
                 m_half_vpelb_r <= ff_sel_vpelbty_r;
             end
             else if(cnt_mc_r <= 9'd255)
             begin
                 m_half_vpelf_r <= ff_sel_vpelfby_r;
                 m_half_vpelb_r <= ff_sel_vpelbby_r;
             end
             else if(cnt_mc_r <= 9'd287)
             begin
                 m_half_vpelf_r <= ff_sel_vpelftc_r;
                 m_half_vpelb_r <= ff_sel_vpelbtc_r;
             end
             else if(cnt_mc_r <= 9'd319)
             begin
                 m_half_vpelf_r <= ff_sel_vpelfbc_r;
                 m_half_vpelb_r <= ff_sel_vpelbbc_r;
             end
             else if(cnt_mc_r <= 9'd351)
             begin
                 m_half_vpelf_r <= ff_sel_vpelftc_r;
                 m_half_vpelb_r <= ff_sel_vpelbtc_r;
             end
             else if(cnt_mc_r <= 9'd383)
             begin
                 m_half_vpelf_r <= ff_sel_vpelfbc_r;
                 m_half_vpelb_r <= ff_sel_vpelbbc_r;
             end
             else
             begin
                 m_half_vpelf_r <= 0;
                 m_half_vpelb_r <= 0;
             end
         end
    end
end


always @(posedge clkdec or negedge rstdec_x)
begin
    if(!rstdec_x)
    begin
         m_line17_cutf_r <= 0;
         m_line17_cutb_r <= 0;
    end
    else
    begin
         if(cnt_mc_r <= 9'd255)
         begin
             m_line17_cutf_r <= ff_sel_cutfty_r ^ ff_sel_cutfby_r;
             m_line17_cutb_r <= ff_sel_cutbty_r ^ ff_sel_cutbby_r;
         end
         else if(cnt_mc_r <= 9'd383)
         begin
             m_line17_cutf_r <= ff_sel_cutftc_r ^ ff_sel_cutfbc_r;
             m_line17_cutb_r <= ff_sel_cutbtc_r ^ ff_sel_cutbbc_r;
         end
         else
         begin
             m_line17_cutf_r <= 0;
             m_line17_cutb_r <= 0;
         end
    end
end
endmodule

