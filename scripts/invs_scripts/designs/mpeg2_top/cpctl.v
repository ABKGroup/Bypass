// ----------------------------------------------
// File: cpctl.v
// Module: cpctl
// Function:
// ----------------------------------------------

module cpctl (
    clkdec,      
    rstdec_x,    
    v_paramadr_r,         
    v_paramdata_r,        
    v_picstrt_r,          
    v_slicestart_r,       
    v_mbadet_r,           
    v_qmsyni_r_n,         
    v_qmseli_r,           
    v_qmsynn_r_n,         
    v_qmseln_r,           
    v_qmdata_r,           
    v_ferror_r,           
    c_mbpl_vld_r_s,       
    c_pcpl_r_s,           
    c_skpmb_r,            
    n_pic_codtyp_reffld1_r,
    n_pic_codtyp_reffld2_r,
    n_pic_codtyp_reffld3_r,
    n_pic_codtyp_reffld4_r,
    v_seqstrt_r,     
    p_hdtvh_r,       
    g_hs60p_r,       
    g_vs60p_r,       
    g_mbc_r,         
    g_mbc_en_r,      
    w1_mtp00_q,      
    g_fcyc_en_r,     
    g_fcyc_r,        
    c_mbpl_psft_r_s, 
    c_qmsynn_r_n,        
    c_qmdata_r,          
    c_qmseln_r,          
    c_qmintra_r,         
    c_lwdly_r,           
    c_rfstfld_r,         
    c_fldpl_cycl_r,      
    c_auto_rpt_md_r,     
    c_prgseq_r,          
    c_tfst_r,            
    c_phdet_r,           
    c_mbaidet_s,         
    c_mbai_r,            
    c_svp_r,             
    c_pcth_mb_r,         
    c_pctv_mb_r,         
    c_shdet_r,           
    c_hsval_r,           
    c_vsval_r,           
    c_pstr_r,            
    c_dct_typ_r,         
    c_dmvh_r,            
    c_dmvv_r,            
    c_mpg1_r,            
    c_intradcp_r,        
    c_alterscan_r,       
    c_pred_forward_r,    
    c_pred_backward_r,   
    c_fldsel1_fix1_r,    
    c_fldsel2_fix1_r,    
    c_fldsel3_fix1_r,    
    c_fldsel4_fix1_r,    
    c_pic_codtyp_r,      
    c_brklnk_r,          
    c_crs_gop_r,         
    c_mbtyp_0_r,         
    c_qscale_r,          
    c_mbpl_cycl_r,       
    v1_mtp00_bs,         
    v1_mtp00_we,         
    v1_mtp00_a,          
    v1_mtp00_d,
    v_mode_mpeg1           
  );

//input
    input         clkdec;     
    input         rstdec_x;   
    input [7:0]   v_paramadr_r; 
    input [24:1]  v_paramdata_r;
    input         v_picstrt_r;  
    input         v_slicestart_r;
    input         v_mbadet_r;    
    input         v_qmsyni_r_n;  
    input         v_qmseli_r;    
    input         v_qmsynn_r_n;  
    input         v_qmseln_r;    
    input [7:0]   v_qmdata_r;    
    input         v_ferror_r;    
    input         c_mbpl_vld_r_s;
    input         c_pcpl_r_s;    
    input         c_skpmb_r;     
    input [2:0]   n_pic_codtyp_reffld1_r;
    input [2:0]   n_pic_codtyp_reffld2_r;
    input [2:0]   n_pic_codtyp_reffld3_r;
    input [2:0]   n_pic_codtyp_reffld4_r;
    input         v_seqstrt_r;  
    input [6:0]   g_hs60p_r;    
    input [6:0]   g_vs60p_r;
    input [11:0]  g_mbc_r;  
    input         g_mbc_en_r;
    input [7:0]   w1_mtp00_q;  
    input         p_hdtvh_r;  
    input         g_fcyc_en_r; 
    input  [17:0] g_fcyc_r;    
    input         c_mbpl_psft_r_s;
    output        c_qmsynn_r_n;  
    output [7:0]  c_qmdata_r;    
    output        c_qmseln_r;    
    output        c_qmintra_r;   
    output        c_lwdly_r;     
    output        c_rfstfld_r;   
    output [21:0] c_fldpl_cycl_r;
    output [1:0]  c_auto_rpt_md_r;
    output        c_prgseq_r;     
    output        c_tfst_r;       
    output        c_phdet_r;      
    output        c_mbaidet_s;    
    output [17:0] c_mbai_r;       
    output [7:0]  c_svp_r;        
    output [6:0]  c_pcth_mb_r;    
    output [6:0]  c_pctv_mb_r;    
    output        c_shdet_r;      
    output [11:0] c_hsval_r;      
    output [11:0] c_vsval_r;      
    output [1:0]  c_pstr_r;       
    output        c_dct_typ_r;   
    output [1:0]  c_dmvh_r;      
    output [1:0]  c_dmvv_r;      
    output        c_mpg1_r;          
    output [1:0]  c_intradcp_r;      
    output        c_alterscan_r;     
    output        c_pred_forward_r;  
    output        c_pred_backward_r; 
    output        c_fldsel1_fix1_r;  
    output        c_fldsel2_fix1_r;  
    output        c_fldsel3_fix1_r;  
    output        c_fldsel4_fix1_r;  
    output [2:0]  c_pic_codtyp_r;     
    output        c_brklnk_r;         
    output        c_crs_gop_r;        
    output [11:0] c_mbpl_cycl_r;      
    output        c_mbtyp_0_r;        
    output [6:0]  c_qscale_r;         
    output        v1_mtp00_bs;          
    output        v1_mtp00_we;          
    output [6:0]  v1_mtp00_a;           
    output [7:0]  v1_mtp00_d;           
    input         v_mode_mpeg1;

    wire [2:0]    c_frate_r;      //Frame Rate Code
    wire          c_mbtyp_2_r;    //MB Type 2(MotionForward,Backward)
    wire          c_mbtyp_1_r;    //MB Type 1(MotionForward,Backward)
    wire          c_fldsel1_r;    //Mton Vert Fld Sel 1(Dec Direct Data)
    wire          c_fldsel2_r;    //Mton Vert Fld Sel 2(Dec Direct Data)
    wire          c_fldsel3_r;    //Mton Vert Fld Sel 3(Dec Direct Data)
    wire          c_fldsel4_r;    //Mton Vert Fld Sel 4(Dec Direct Data)
    wire          c_seqhdet_r;    //Sequence Header Detected
    wire [4:0]    c_qsc_r;        //Quantizer Scale Code
    wire          c_qst_r;        //Q Scale Type


    cpif cpif(
        .clkdec(clkdec),            
        .rstdec_x(rstdec_x),        
        .v_paramadr_r(v_paramadr_r),    
        .v_paramdata_r(v_paramdata_r),  
        .c_mbpl_psft_r_s(c_mbpl_psft_r_s),
        .c_lwdly_r(c_lwdly_r),        
        .c_rfstfld_r(c_rfstfld_r),    
        .c_prgseq_r(c_prgseq_r),      
        .c_tfst_r(c_tfst_r),          
        .c_mbai_r(c_mbai_r),          
        .c_svp_r(c_svp_r),            
        .c_hsval_r(c_hsval_r),        
        .c_vsval_r(c_vsval_r),        
        .c_pstr_r(c_pstr_r),          
        .c_mbtyp_0_r(c_mbtyp_0_r),    
        .c_dct_typ_r(c_dct_typ_r),  
        .c_dmvh_r(c_dmvh_r),           
        .c_dmvv_r(c_dmvv_r),           
        .c_qsc_r(c_qsc_r),             
        .c_mpg1_r(c_mpg1_r),           
        .c_intradcp_r(c_intradcp_r),   
        .c_qst_r(c_qst_r),             
        .c_alterscan_r(c_alterscan_r), 
        .c_pic_codtyp_r(c_pic_codtyp_r),
        .c_brklnk_r(c_brklnk_r),        
        .c_crs_gop_r(c_crs_gop_r),      
        .c_frate_r(c_frate_r),          
        .c_mbtyp_2_r(c_mbtyp_2_r),      
        .c_mbtyp_1_r(c_mbtyp_1_r),      
        .c_fldsel1_r(c_fldsel1_r),      
        .c_fldsel2_r(c_fldsel2_r),      
        .c_fldsel3_r(c_fldsel3_r),      
        .c_fldsel4_r(c_fldsel4_r), 
        .v_mode_mpeg1(v_mode_mpeg1)
      );

    cpop cpop(
        .clkdec(clkdec),          
        .rstdec_x(rstdec_x),      
        .v_picstrt_r(v_picstrt_r),        
        .v_slicestart_r(v_slicestart_r),  
        .v_mbadet_r(v_mbadet_r),          
        .c_mbpl_vld_r_s(c_mbpl_vld_r_s),  
        .c_skpmb_r(c_skpmb_r),            
        .n_pic_codtyp_reffld1_r(n_pic_codtyp_reffld1_r),
        .n_pic_codtyp_reffld2_r(n_pic_codtyp_reffld2_r),
        .n_pic_codtyp_reffld3_r(n_pic_codtyp_reffld3_r),
        .n_pic_codtyp_reffld4_r(n_pic_codtyp_reffld4_r),
        .c_hsval_r(c_hsval_r),   
        .c_vsval_r(c_vsval_r),
        .c_pstr_r(c_pstr_r),          
        .c_mbtyp_0_r(c_mbtyp_0_r),    
        .c_pic_codtyp_r(c_pic_codtyp_r),
        .c_frate_r(c_frate_r),          
        .c_mbtyp_2_r(c_mbtyp_2_r),   
        .c_mbtyp_1_r(c_mbtyp_1_r),   
        .c_fldsel1_r(c_fldsel1_r),   
        .c_fldsel2_r(c_fldsel2_r),   
        .c_fldsel3_r(c_fldsel3_r),   
        .c_fldsel4_r(c_fldsel4_r),   
        .v_seqstrt_r(v_seqstrt_r), 
        .g_hs60p_r(g_hs60p_r),     
        .g_vs60p_r(g_vs60p_r),     
        .c_qsc_r(c_qsc_r),         
        .c_qst_r(c_qst_r),         
        .c_prgseq_r(c_prgseq_r),   
        .p_hdtvh_r(p_hdtvh_r),     
        .g_mbc_r(g_mbc_r),         
        .g_mbc_en_r(g_mbc_en_r),   
        .g_fcyc_en_r(g_fcyc_en_r), 
        .g_fcyc_r(g_fcyc_r),
        .c_fldpl_cycl_r(c_fldpl_cycl_r),  
        .c_auto_rpt_md_r(c_auto_rpt_md_r),
        .c_phdet_r(c_phdet_r),            
        .c_mbaidet_s(c_mbaidet_s),        
        .c_pcth_mb_r(c_pcth_mb_r),        
        .c_pctv_mb_r(c_pctv_mb_r),        
        .c_shdet_r(c_shdet_r),                
        .c_pred_forward_r(c_pred_forward_r),  
        .c_pred_backward_r(c_pred_backward_r),
        .c_fldsel1_fix1_r(c_fldsel1_fix1_r),  
        .c_fldsel2_fix1_r(c_fldsel2_fix1_r),  
        .c_fldsel3_fix1_r(c_fldsel3_fix1_r),  
        .c_fldsel4_fix1_r(c_fldsel4_fix1_r),  
        .c_seqhdet_r(c_seqhdet_r),            
        .c_mbpl_cycl_r(c_mbpl_cycl_r),  
        .c_qscale_r(c_qscale_r)         
      );

    ctqmt ctqmt(
        .clkdec(clkdec),       
        .rstdec_x(rstdec_x),   
        .v_qmsyni_r_n(v_qmsyni_r_n),
        .v_qmsynn_r_n(v_qmsynn_r_n),
        .v_ferror_r(v_ferror_r),    
        .v_qmseli_r(v_qmseli_r),    
        .v_qmseln_r(v_qmseln_r),    
        .v_qmdata_r(v_qmdata_r),    
        .c_pcpl_r_s(c_pcpl_r_s),    
        .w1_mtp00_q(w1_mtp00_q),        
        .c_seqhdet_r(c_seqhdet_r),  
        .c_qmsynn_r_n(c_qmsynn_r_n),
        .c_qmdata_r(c_qmdata_r),    
        .c_qmseln_r(c_qmseln_r),    
        .c_qmintra_r(c_qmintra_r),  
        .v1_mtp00_bs(v1_mtp00_bs),  
        .v1_mtp00_we(v1_mtp00_we),  
        .v1_mtp00_a(v1_mtp00_a),    
        .v1_mtp00_d(v1_mtp00_d)     
      );

endmodule

