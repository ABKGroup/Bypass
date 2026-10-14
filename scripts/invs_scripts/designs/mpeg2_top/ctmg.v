// ----------------------------------------------
// File: ctmg.v
// Module: ctmg
// Function:
// ----------------------------------------------

module ctmg (
    clkdec,               //Clock
    rstdec_x,             //Asynchronous Reset(N)
    g_vden_r,             //Video Decoder Enable
    g_pmod_r,             //Picture Period Priority Mode
    g_swrst_r_n,          //Software Reset(N)
    g_pskp_r,             //CPU I/F
    c_pstr_r,             //[1:0] Picture Structure
    c_prgseq_r,           //Progressive Sequence
    c_rfstfld_r,          //Repeat First Field
    c_tfst_r,             //Top Field First
    c_phdet_r,            //Picture Header Detected
    c_mbaidet_s,          //MBAI Detected
    c_mb_fin_r,           //Final MB Position
    c_lwdly_r,            //Low Delay Mode
    c_ccl_r,              //Conceal Command
    c_skpmb_r,            //Skip MB Command
    c_fldpl_cycl_r,       //[21:0] Field Pulse Cycle Period
    c_mbpl_cycl_r,        //[11:0] MB Pulse Cycle Period
    c_auto_rpt_md_r,      //[1:0] Auto Repeat Mode
    g_pcut_r,             //[11:0] TimeOut Cycle Period
    c_pic_codtyp_r,       //[2:0] Picture Coding Type
    c_mbpl_vld_r_s,       //MB Pulse(Variable Length-code Decord)
    c_mbpl_iq_r_s,        //MB Pulse(Inverce Quantization)
    c_mbpl_idct_r_s,      //MB Pulse(Inverce DCT)
    c_mbpl_idct_out_r_s,  //MB Pulse(Inverce DCT Data Output)
    c_mbpl_mcalc_r_s,     //MB Pulse(Motion Vector Calculation)
    c_mbpl_buc_r_s,       //MB Pulse(Bus Operation with Up Conversion)
    c_mbpl_uc_r_s,        //MB Pulse(Up Conversion phase
    c_mbpl_mc_r_s,        //MB Pulse(Motion Compensation)
    c_mbpl_dc_r_s,        //MB Pulse(Down Conversion)
    c_mbpl_psft_r_s,      //MB Pulse(Parameter Shift)
    c_mbpl_pos_r_s,       //MB Pulse(MB Position Renobation)
    c_frmpl_r_s,          //Frame Pulse
    c_fldpl_r_s,          //Field Pulse
    c_pcpl_r_s,           //Picture Processing Start Pulse
    c_skippic_r_s,        //Skip Picture Detect
    c_tmg_ferr_hit_r,     //Fatal Error Hit with Timing
    c_pcpl_tend_r_s,      //Picture Processing Time End Pulse
    c_mbpl_skpmb_r_s,     //MB Pulse(Skip-Macroblock)
    c_idlpl_r_s,          //Video Decoder Idle Pulse
    c_pic_notcplt_r,      //Picture Not Complete
    c_bfcnt_init_r,       //3page Buffer Initial Pulse
    c_pskp_end_r_s,       //
    v1_sd_pichead_s       //
  );

    input        clkdec;              //Clock
    input        rstdec_x;            //Asynchronous Reset(N)
    input        g_vden_r;            //Video Decoder Enable
    input        g_pmod_r;            //Picture Period Priority Mode
    input        g_swrst_r_n;         //Software Reset(N)
    input        g_pskp_r;            //Picture Skip from CPU
    input [1:0]  c_pstr_r;            //Picture Structure
    input        c_prgseq_r;          //Progressive Sequence
    input        c_rfstfld_r;         //Repeat First Field
    input        c_tfst_r;            //Top Field First
    input        c_phdet_r;           //Picture Header Detected
    input        c_mbaidet_s;         //MBAI Detected
    input        c_mb_fin_r;          //Final MB Position
    input        c_lwdly_r;           //Low Delay Mode
    input        c_ccl_r;             //Conceal Command
    input        c_skpmb_r;           //Skip MB Command
    input [21:0] c_fldpl_cycl_r;      //Field Pulse Cycle Period
    input [11:0] c_mbpl_cycl_r;       //[11:0] MB Pulse Cycle Period

    input [1:0]  c_auto_rpt_md_r;     //Auto Repeat Mode
    input [11:0] g_pcut_r;            //TimeOut Cycle Period
    input [2:0]  c_pic_codtyp_r;      //Picture Coding Type

    output       c_mbpl_vld_r_s;      //MB Pulse(Variable Length-code Decord)
    output       c_mbpl_iq_r_s;       //MB Pulse(Inverce Quantization)
    output       c_mbpl_idct_r_s;     //MB Pulse(Inverce DCT)
    output       c_mbpl_idct_out_r_s; //MB Pulse(Inverce DCT Data Output)
    output       c_mbpl_mcalc_r_s;    //MB Pulse(Motion Vector Calculation)
    output       c_mbpl_buc_r_s;      //...(Bus Operation with Up Conversion)
    output       c_mbpl_uc_r_s;       //MB Pulse(Up Conversion phase
    output       c_mbpl_mc_r_s;       //MB Pulse(Motion Compensation)
    output       c_mbpl_dc_r_s;       //MB Pulse(Down Conversion)
    output       c_mbpl_psft_r_s;     //MB Pulse(Parameter Shift)
    output       c_mbpl_pos_r_s;      //MB Pulse(MB Position Renobation)
    output       c_frmpl_r_s;         //Frame Pulse
    output       c_fldpl_r_s;         //Field Pulse
    output       c_pcpl_r_s;          //Picture Processing Start Pulse
    output       c_skippic_r_s;       //Skip Picture Detect
    output       c_tmg_ferr_hit_r;    //Fatal Error Hit with Timing
    output       c_pcpl_tend_r_s;     //Picture Processing Time End Pulse
    output       c_mbpl_skpmb_r_s;    //MB Pulse(Skip-Macroblock)
    output       c_idlpl_r_s;         //Video Decoder Idle Pulse
    output       c_pic_notcplt_r;     //Picture Not Complete
    output       c_bfcnt_init_r;      //3page Buffer Initial Pulse
    output       c_pskp_end_r_s;      //
    output       v1_sd_pichead_s;

    wire         c_inipl_r_s;          //Initial Start Pulse
    wire         c_picend_ena_r;       //Picture End Permission
    wire         c_pcpl_tstrt_r_s;     //Picture Processing Time Start Pulse
    wire         c_auto_rpt_r;         //Auto Repeat Flag
    wire         c_auto_rpt_05_r;      //Auto Repeat Half Frame
    wire         c_auto_rpt_1_r;       //Auto Repeat 1 Frame
    wire         c_auto_rpt_2_r;       //Auto Repeat 2 Frame
    wire [21:0]  c_fldpl_cnt_r;        //Field Pulse Counter
    wire         c_timout_chk_r;       //Time Out Check Flag
    wire         c_mbpl_base_r_s;      //MB Pulse(Base Pulse)
    wire         c_pskp_end_r_s;       //Skip Picture from CPU Pulse


    ctspgen ctspgen(
        .clkdec(clkdec),
        .rstdec_x(rstdec_x),
        .c_phdet_r(c_phdet_r),
        .c_mbaidet_s(c_mbaidet_s),
        .c_picend_ena_r(c_picend_ena_r),
        .c_inipl_r_s(c_inipl_r_s)
      );

    ctutgen ctutgen(
        .clkdec(clkdec),
        .rstdec_x(rstdec_x),
        .g_vden_r(g_vden_r),
        .g_swrst_r_n(g_swrst_r_n),
        .g_pskp_r(g_pskp_r),
        .c_pstr_r(c_pstr_r),
        .c_prgseq_r(c_prgseq_r),
        .c_rfstfld_r(c_rfstfld_r),
        .c_tfst_r(c_tfst_r),      
        .c_lwdly_r(c_lwdly_r),   
        .c_fldpl_cycl_r(c_fldpl_cycl_r),
        .c_inipl_r_s(c_inipl_r_s),      
        .c_picend_ena_r(c_picend_ena_r),
        .c_auto_rpt_r(c_auto_rpt_r),    
        .c_auto_rpt_05_r(c_auto_rpt_05_r),
        .c_auto_rpt_1_r(c_auto_rpt_1_r),  
        .c_auto_rpt_2_r(c_auto_rpt_2_r),  
        .c_pic_codtyp_r(c_pic_codtyp_r),  
        .c_frmpl_r_s(c_frmpl_r_s), 
        .c_fldpl_r_s(c_fldpl_r_s),
        .c_pcpl_r_s(c_pcpl_r_s),  
        .c_pcpl_tstrt_r_s(c_pcpl_tstrt_r_s),
        .c_pcpl_tend_r_s(c_pcpl_tend_r_s),  
        .c_pskp_end_r_s(c_pskp_end_r_s),    
        .c_bfcnt_init_r(c_bfcnt_init_r),
        .c_fldpl_cnt_r(c_fldpl_cnt_r),
        .c_timout_chk_r(c_timout_chk_r),
        .c_idlpl_r_s(c_idlpl_r_s), 
        .v1_sd_pichead_s(v1_sd_pichead_s)
      );

   ctltgen ctltgen(
        .clkdec(clkdec),
        .rstdec_x(rstdec_x),
        .g_swrst_r_n(g_swrst_r_n),
        .c_mbpl_cycl_r(c_mbpl_cycl_r),
        .c_pcpl_r_s(c_pcpl_r_s),
        .c_mbpl_base_r_s(c_mbpl_base_r_s)
      );

    ctpedet ctpedet(
        .clkdec(clkdec),
        .rstdec_x(rstdec_x),
        .g_pmod_r(g_pmod_r),
        .g_swrst_r_n(g_swrst_r_n),
        .c_mb_fin_r(c_mb_fin_r),
        .c_lwdly_r(c_lwdly_r),
        .g_pcut_r(g_pcut_r),
        .c_fldpl_cnt_r(c_fldpl_cnt_r),
        .c_timout_chk_r(c_timout_chk_r),
        .c_pcpl_tend_r_s(c_pcpl_tend_r_s),
        .c_pcpl_r_s(c_pcpl_r_s),
        .c_pskp_end_r_s(c_pskp_end_r_s),
        .c_phdet_r(c_phdet_r),
        .c_skippic_r_s(c_skippic_r_s),
        .c_tmg_ferr_hit_r(c_tmg_ferr_hit_r),
        .c_picend_ena_r(c_picend_ena_r),
        .c_pic_notcplt_r(c_pic_notcplt_r)
      );

    ctplcon ctplcon(
        .clkdec(clkdec),
        .rstdec_x(rstdec_x),
        .g_swrst_r_n(g_swrst_r_n),
        .c_phdet_r(c_phdet_r),
        .c_mb_fin_r(c_mb_fin_r),
        .c_ccl_r(c_ccl_r),
        .c_skpmb_r(c_skpmb_r),
        .c_mbpl_base_r_s(c_mbpl_base_r_s),
        .c_mbaidet_s(c_mbaidet_s),
        .c_pcpl_r_s(c_pcpl_r_s), 
        .c_picend_ena_r(c_picend_ena_r),
        .c_mbpl_vld_r_s(c_mbpl_vld_r_s),
        .c_mbpl_iq_r_s(c_mbpl_iq_r_s),  
        .c_mbpl_idct_r_s(c_mbpl_idct_r_s),
        .c_mbpl_idct_out_r_s(c_mbpl_idct_out_r_s),
        .c_mbpl_mcalc_r_s(c_mbpl_mcalc_r_s),      
        .c_mbpl_buc_r_s(c_mbpl_buc_r_s),          
        .c_mbpl_uc_r_s(c_mbpl_uc_r_s),
        .c_mbpl_mc_r_s(c_mbpl_mc_r_s),
        .c_mbpl_dc_r_s(c_mbpl_dc_r_s),
        .c_mbpl_psft_r_s(c_mbpl_psft_r_s),
        .c_mbpl_pos_r_s(c_mbpl_pos_r_s),  
        .c_mbpl_skpmb_r_s(c_mbpl_skpmb_r_s)
      );

    ctautopd ctautopd(
        .clkdec(clkdec),
        .rstdec_x(rstdec_x),
        .g_swrst_r_n(g_swrst_r_n),
        .c_auto_rpt_md_r(c_auto_rpt_md_r),
        .c_pcpl_r_s(c_pcpl_r_s),
        .c_lwdly_r(c_lwdly_r),  
        .c_auto_rpt_r(c_auto_rpt_r),
        .c_auto_rpt_05_r(c_auto_rpt_05_r),
        .c_auto_rpt_1_r(c_auto_rpt_1_r),
        .c_auto_rpt_2_r(c_auto_rpt_2_r) 
      );

endmodule

