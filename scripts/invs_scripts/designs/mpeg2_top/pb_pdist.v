// ----------------------------------------------
// File: pb_pdist.v
// Module: pb_pdist
// Function: 
// ----------------------------------------------

module pb_pdist
  (
    clkdec,             //Clock
    rstdec_x,           //Asynchronous Reset(N)
    v_fstfwdvech_r,       //[12:0]Mton Vctr 1st Fwd H
    v_fstfwdvecv_r,       //[8:0] Mton Vctr 1st Fwd V
    v_fstbwdvech_r,       //[12:0]Mton Vctr 1st Bwd H
    v_fstbwdvecv_r,       //[8:0] Mton Vctr 1st Bwd V
    v_sndfwdvech_r,       //[12:0]Mton Vctr 2nt Fwd H
    v_sndfwdvecv_r,       //[8:0] Mton Vctr 2nt Fwd V
    v_sndbwdvech_r,       //[12:0]Mton Vctr 2nd Bwd H
    v_sndbwdvecv_r,       //[8:0] Mton Vctr 2nd Bwd V
    c_mbpl_psft_r_s,      //MB Pulse(Parameter Shift)
    c_ccl_r,              //Conceal Command
    v_motion_type_r,      //[1:0]Motion Type
    c_pred_forward_r,     //Prediction Forward
    c_pred_backward_r,    //Prediction Backward
    c_mbtyp_0_r,          //MB Type 0(Intra)
    c_pstr_r,             //[1:0]Picture Structure
    c_fldsel1_fix1_r,     //Mton Vert Fld Sel 1(MPEG Fix)
    c_fldsel2_fix1_r,     //Mton Vert Fld Sel 2(MPEG Fix)
    c_fldsel3_fix1_r,     //Mton Vert Fld Sel 3(MPEG Fix)
    c_fldsel4_fix1_r,     //Mton Vert Fld Sel 4(MPEG Fix)
    c_hsval_r,            //[11:0]Horizontal Size Value
    c_vsval_r,            //[11:0]Vertical Size Value
    c_mpg1_r,             //MPEG1 Flag
    c_prgseq_r,           //Progressive Sequence
    c_mbh_adr_r,          //[6:0]MB Position Now H
    c_mbv_adr_r,          //[6:0]MB Position Now V
    c_dct_typ_r,          //DCT Type
    c_dmvh_r,             //[1:0]DMVector Horizontal
    c_dmvv_r,             //[1:0]DMVector Vertical
    c_tfst_r,             //Top Field First
    c_shdet_r,            //Slice Header Detected
    c_alterscan_r,        //Alternate Scan Flag
    c_intradcp_r,         //Intra DC Precision
    n_reffld_num1_r,      //[3:0]Reference Field 1
    n_reffld_num2_r,      //[3:0]Reference Field 2
    n_reffld_num3_r,      //[3:0]Reference Field 3
    n_reffld_num4_r,      //[3:0]Reference Field 4
    c_skpmb_r,            //Skip MB Command
    g_hsdc_r,             //[6:0]
    g_vsdc_r,             //[6:0]
    c_qscale_r,           //[6:0]
    n_pic_codtyp_reffld1_r, //[2:0]
    n_pic_codtyp_reffld2_r, //[2:0]
    n_pic_codtyp_reffld3_r, //[2:0]
    n_pic_codtyp_reffld4_r, //[2:0]
    c_pic_codtyp_r,         //[2:0]
    c_mbpl_idct_out_r_s,   //MB Pulse(Inverce DCT Data Output)
    c_mbpl_mc_r_s,         //MB Pulse(Motion Compensation)
    c_mbpl_dc_r_s,         //MB Pulse(Down Conversion)
    c_mbpl_iq_r_s,         //MB Pulse(Inverce Quantization)
    p_shdet_iq_r,          //Slice Header Detected IQ phase
    p_hdtvh_buc_r,         //HDTV Flag BUC phase
    p_hdtvh_dc_r,          //HDTV Flag DC phase
    p_prgseq_buc_r,        //Progressive Sequence BUC phase
    p_prgseq_dc_r,         //Progressive Sequence DC phase
    p_pstr_buc_r,          //[1:0]Picture Structure BUC phase
    p_pstr_dc_r,           //[1:0]Picture Structure DC phase
    p_pred_forward_buc_r,  //Prediction Forward BUC phase
    p_pred_backward_buc_r, //Prediction Backward BUC phase
    p_mbtyp_0_iq_r,        //MB Type 0(Intra) IQ phase
    p_mbtyp_0_buc_r,       //MB Type 0(Intra) BUC phase
    p_mttyp_buc_r,         //[1:0]Motion Type BUC phase
    p_mbh_adr_buc_r,       //[6:0]MB Position Now H BUC phase
    p_mbv_adr_buc_r,       //[6:0]MB Position Now V BUC phase
    p_mbh_adr_dc_r,        //[6:0]MB Position Now H DC phase
    p_mbv_adr_dc_r,        //[6:0]MB Position Now V DC phase
    p_dct_typ_mc_r,        //DCT Type MC phase
    p_fstfwdvech_buc_r,    //[12:0]Mton Vctr 1st Fwd H BUC phase
    p_fstfwdvecv_buc_r,    //[8:0] Mton Vctr 1st Fwd V BUC phase
    p_fstbwdvech_buc_r,    //[12:0]Mton Vctr 1st Bwd H BUC phase
    p_fstbwdvecv_buc_r,    //[8:0] Mton Vctr 1st Bwd V BUC phase
    p_sndfwdvech_buc_r,    //[12:0]Mton Vctr 2nt Fwd H BUC phase
    p_sndfwdvecv_buc_r,    //[8:0] Mton Vctr 2nt Fwd V BUC phase
    p_sndbwdvech_buc_r,    //[12:0]Mton Vctr 2nd Bwd H BUC phase
    p_sndbwdvecv_buc_r,    //[8:0] Mton Vctr 2nd Bwd V BUC phase
    p_fldsel1_buc_r,       //Mton Vert Fld Sel 1 BUC phase
    p_fldsel2_buc_r,       //Mton Vert Fld Sel 2 BUC phase
    p_fldsel3_buc_r,       //Mton Vert Fld Sel 3 BUC phase
    p_fldsel4_buc_r,       //Mton Vert Fld Sel 4 BUC phase
    p_dmvh_buc_r,          //[1:0]DMVector Horizontal BUC phase
    p_dmvv_buc_r,          //[1:0]DMVector Vertical BUC phase
    p_tfst_buc_r,          //Top Field First BUC phase
    p_idct_dis_mc_r,       //IDCT Data Disable MC phase
    p_mpg1_iq_r,           //MPEG1 Flag IQ phase
    p_intradcp_iq_r,       //Intra DC Precision IQ phase
    p_alterscan_iq_r,      //Alternate Scan Flag IQ phase
    p_reffld_num1_buc_r,   //[3:0]Reference Field 1 BUC phase
    p_reffld_num2_buc_r,   //[3:0]Reference Field 2 BUC phase
    p_reffld_num3_buc_r,   //[3:0]Reference Field 3 BUC phase
    p_reffld_num4_buc_r,   //[3:0]Reference Field 4 BUC phase
    p_qscale_iq_r,         //[6:0]
    p_hdtvh_r              //HDTV Flag
  );

    input        clkdec;           
    input        rstdec_x;         
    input [12:0] v_fstfwdvech_r;     
    input [8:0]  v_fstfwdvecv_r;     
    input [12:0] v_fstbwdvech_r;     
    input [8:0]  v_fstbwdvecv_r;     
    input [12:0] v_sndfwdvech_r;     
    input [8:0]  v_sndfwdvecv_r;     
    input [12:0] v_sndbwdvech_r;     
    input [8:0]  v_sndbwdvecv_r;     
    input        c_mbpl_psft_r_s;    
    input        c_ccl_r;            
    input [1:0]  v_motion_type_r;    
    input        c_pred_forward_r;   
    input        c_pred_backward_r;  
    input        c_mbtyp_0_r;        
    input [1:0]  c_pstr_r;           
    input        c_fldsel1_fix1_r;   
    input        c_fldsel2_fix1_r;   
    input        c_fldsel3_fix1_r;   
    input        c_fldsel4_fix1_r;   
    input [11:0] c_hsval_r;          
    input [11:0] c_vsval_r;          
    input        c_mpg1_r;           
    input        c_prgseq_r;         
    input [6:0]  c_mbh_adr_r;        
    input [6:0]  c_mbv_adr_r;        
    input        c_dct_typ_r;        
    input [1:0]  c_dmvh_r;           
    input [1:0]  c_dmvv_r;           
    input        c_tfst_r;          
    input        c_shdet_r;         
    input        c_alterscan_r;     
    input [1:0]  c_intradcp_r;      
    input [3:0]  n_reffld_num1_r;   
    input [3:0]  n_reffld_num2_r;   
    input [3:0]  n_reffld_num3_r;   
    input [3:0]  n_reffld_num4_r;   
    input        c_skpmb_r;         
    input [6:0] g_hsdc_r;           
    input [6:0] g_vsdc_r;           
    input [6:0]  c_qscale_r;         
    input [2:0]  n_pic_codtyp_reffld1_r;
    input [2:0]  n_pic_codtyp_reffld2_r;
    input [2:0]  n_pic_codtyp_reffld3_r;
    input [2:0]  n_pic_codtyp_reffld4_r;
    input [2:0]  c_pic_codtyp_r;       
    input        c_mbpl_idct_out_r_s;  
    input        c_mbpl_mc_r_s;        
    input        c_mbpl_dc_r_s;        
    input        c_mbpl_iq_r_s;        
    output        p_shdet_iq_r;        
    output        p_hdtvh_buc_r;       
    output        p_hdtvh_dc_r;        
    output        p_prgseq_buc_r;      
    output        p_prgseq_dc_r;       
    output [1:0]  p_pstr_buc_r;        
    output [1:0]  p_pstr_dc_r;         
    output        p_pred_forward_buc_r;
    output        p_pred_backward_buc_r;
    output        p_mbtyp_0_iq_r;       
    output        p_mbtyp_0_buc_r;      
    output [1:0]  p_mttyp_buc_r;        
    output [6:0]  p_mbh_adr_buc_r;      
    output [6:0]  p_mbv_adr_buc_r;      
    output [6:0]  p_mbh_adr_dc_r;       
    output [6:0]  p_mbv_adr_dc_r;       
    output        p_dct_typ_mc_r;       
    output [12:0] p_fstfwdvech_buc_r;   
    output [8:0]  p_fstfwdvecv_buc_r;   
    output [12:0] p_fstbwdvech_buc_r;   
    output [8:0]  p_fstbwdvecv_buc_r;   
    output [12:0] p_sndfwdvech_buc_r;   
    output [8:0]  p_sndfwdvecv_buc_r;   
    output [12:0] p_sndbwdvech_buc_r;   
    output [8:0]  p_sndbwdvecv_buc_r;   
    output        p_fldsel1_buc_r;      
    output        p_fldsel2_buc_r;      
    output        p_fldsel3_buc_r;      
    output        p_fldsel4_buc_r;      
    output [1:0]  p_dmvh_buc_r;         
    output [1:0]  p_dmvv_buc_r;         
    output        p_tfst_buc_r;         
    output        p_idct_dis_mc_r;      
    output        p_mpg1_iq_r;          
    output [1:0]  p_intradcp_iq_r;      
    output        p_alterscan_iq_r;     
    output [3:0]  p_reffld_num1_buc_r;  
    output [3:0]  p_reffld_num2_buc_r;  
    output [3:0]  p_reffld_num3_buc_r;  
    output [3:0]  p_reffld_num4_buc_r;  
    output [6:0]  p_qscale_iq_r;        
    output        p_hdtvh_r;            

    wire           p_pred_forward_fix_r;  //Prediction Forward (CCL Fix)
    wire           p_pred_backward_fix_r; //Prediction Backward (CCL Fix)
    wire           p_mbtyp_0_fix_r;       //MB Type 0(Intra) (CCL Fix)
    wire [1:0]     p_mttyp_fix_r;         //Motion Type (CCL Fix)
    wire [12:0]    p_fstfwdvech_fix_r;    //Mton Vctr 1st Fwd H (CCL Fix)
    wire [8:0]     p_fstfwdvecv_fix_r;    //Mton Vctr 1st Fwd V (CCL Fix)
    wire [12:0]    p_fstbwdvech_fix_r;    //Mton Vctr 1st Bwd H (CCL Fix)
    wire [8:0]     p_fstbwdvecv_fix_r;    //Mton Vctr 1st Bwd V (CCL Fix)
    wire [12:0]    p_sndfwdvech_fix_r;    //Mton Vctr 2nt Fwd H (CCL Fix)
    wire [8:0]     p_sndfwdvecv_fix_r;    //Mton Vctr 2nt Fwd V (CCL Fix)
    wire [12:0]    p_sndbwdvech_fix_r;    //Mton Vctr 2nd Bwd H (CCL Fix)
    wire [8:0]     p_sndbwdvecv_fix_r;    //Mton Vctr 2nd Bwd V (CCL Fix)
    wire           p_fldsel1_fix2_r;      //Mton Vert Fld Sel 1 (MPEG,CCL Fix)
    wire           p_fldsel2_fix2_r;      //Mton Vert Fld Sel 2 (MPEG,CCL Fix)
    wire           p_fldsel3_fix2_r;      //Mton Vert Fld Sel 3 (MPEG,CCL Fix)
    wire           p_fldsel4_fix2_r;      //Mton Vert Fld Sel 4 (MPEG,CCL Fix)
    wire           p_hdtvh_r;             //HDTV Flag

    pb_pccl pb_pccl
      (
        .clkdec(clkdec),                 
        .rstdec_x(rstdec_x),             
        .v_fstfwdvech_r(v_fstfwdvech_r),     
        .v_fstfwdvecv_r(v_fstfwdvecv_r),     
        .v_fstbwdvech_r(v_fstbwdvech_r),     
        .v_fstbwdvecv_r(v_fstbwdvecv_r),     
        .v_sndfwdvech_r(v_sndfwdvech_r),     
        .v_sndfwdvecv_r(v_sndfwdvecv_r),     
        .v_sndbwdvech_r(v_sndbwdvech_r),     
        .v_sndbwdvecv_r(v_sndbwdvecv_r),     
        .c_ccl_r(c_ccl_r),                   
        .v_motion_type_r(v_motion_type_r),   
        .c_pred_forward_r(c_pred_forward_r),  
        .c_pred_backward_r(c_pred_backward_r),
        .c_mbtyp_0_r(c_mbtyp_0_r),            
        .c_pstr_r(c_pstr_r),                  
        .c_fldsel1_fix1_r(c_fldsel1_fix1_r),  
        .c_fldsel2_fix1_r(c_fldsel2_fix1_r),  
        .c_fldsel3_fix1_r(c_fldsel3_fix1_r),  
        .c_fldsel4_fix1_r(c_fldsel4_fix1_r),  
        .c_hsval_r(c_hsval_r),                
        .c_vsval_r(c_vsval_r),                
        .g_hsdc_r(g_hsdc_r),                  
        .g_vsdc_r(g_vsdc_r),                  
        .c_pic_codtyp_r(c_pic_codtyp_r),      
        .n_pic_codtyp_reffld1_r(n_pic_codtyp_reffld1_r),
        .n_pic_codtyp_reffld2_r(n_pic_codtyp_reffld2_r),
        .n_pic_codtyp_reffld3_r(n_pic_codtyp_reffld3_r),
        .n_pic_codtyp_reffld4_r(n_pic_codtyp_reffld4_r),
        .p_pred_forward_fix_r(p_pred_forward_fix_r),  
        .p_pred_backward_fix_r(p_pred_backward_fix_r),
        .p_mbtyp_0_fix_r(p_mbtyp_0_fix_r),            
        .p_mttyp_fix_r(p_mttyp_fix_r),                
        .p_fstfwdvech_fix_r(p_fstfwdvech_fix_r),      
        .p_fstfwdvecv_fix_r(p_fstfwdvecv_fix_r),      
        .p_fstbwdvech_fix_r(p_fstbwdvech_fix_r),      
        .p_fstbwdvecv_fix_r(p_fstbwdvecv_fix_r),      
        .p_sndfwdvech_fix_r(p_sndfwdvech_fix_r),      
        .p_sndfwdvecv_fix_r(p_sndfwdvecv_fix_r),      
        .p_sndbwdvech_fix_r(p_sndbwdvech_fix_r),      
        .p_sndbwdvecv_fix_r(p_sndbwdvecv_fix_r),      
        .p_fldsel1_fix2_r(p_fldsel1_fix2_r),          
        .p_fldsel2_fix2_r(p_fldsel2_fix2_r),          
        .p_fldsel3_fix2_r(p_fldsel3_fix2_r),          
        .p_fldsel4_fix2_r(p_fldsel4_fix2_r),          
        .p_hdtvh_r(p_hdtvh_r)                        
      );

    pb_fifo pb_fifo
      (
        .clkdec(clkdec),                 
        .rstdec_x(rstdec_x),             
        .c_mbpl_psft_r_s(c_mbpl_psft_r_s),   
        .c_pstr_r(c_pstr_r),                 
        .c_mpg1_r(c_mpg1_r),                  
        .c_prgseq_r(c_prgseq_r),              
        .c_mbh_adr_r(c_mbh_adr_r),            
        .c_mbv_adr_r(c_mbv_adr_r),            
        .c_dct_typ_r(c_dct_typ_r),            
        .c_dmvh_r(c_dmvh_r),                  
        .c_dmvv_r(c_dmvv_r),                  
        .c_tfst_r(c_tfst_r),                  
        .c_shdet_r(c_shdet_r),                
        .c_alterscan_r(c_alterscan_r),        
        .c_intradcp_r(c_intradcp_r),          
        .n_reffld_num1_r(n_reffld_num1_r),    
        .n_reffld_num2_r(n_reffld_num2_r),    
        .n_reffld_num3_r(n_reffld_num3_r),    
        .n_reffld_num4_r(n_reffld_num4_r),    
        .p_pred_forward_fix_r(p_pred_forward_fix_r),  
        .p_pred_backward_fix_r(p_pred_backward_fix_r),
        .p_mbtyp_0_fix_r(p_mbtyp_0_fix_r),         
        .p_mttyp_fix_r(p_mttyp_fix_r),             
        .p_fstfwdvech_fix_r(p_fstfwdvech_fix_r),   
        .p_fstfwdvecv_fix_r(p_fstfwdvecv_fix_r),   
        .p_fstbwdvech_fix_r(p_fstbwdvech_fix_r),   
        .p_fstbwdvecv_fix_r(p_fstbwdvecv_fix_r),   
        .p_sndfwdvech_fix_r(p_sndfwdvech_fix_r),   
        .p_sndfwdvecv_fix_r(p_sndfwdvecv_fix_r),   
        .p_sndbwdvech_fix_r(p_sndbwdvech_fix_r),   
        .p_sndbwdvecv_fix_r(p_sndbwdvecv_fix_r),   
        .p_fldsel1_fix2_r(p_fldsel1_fix2_r),        
        .p_fldsel2_fix2_r(p_fldsel2_fix2_r),        
        .p_fldsel3_fix2_r(p_fldsel3_fix2_r),        
        .p_fldsel4_fix2_r(p_fldsel4_fix2_r),        
        .p_hdtvh_r(p_hdtvh_r),                      
        .c_qscale_r(c_qscale_r),                    
        .c_ccl_r(c_ccl_r),                       
        .c_skpmb_r(c_skpmb_r),                   
        .c_mbpl_idct_out_r_s(c_mbpl_idct_out_r_s), 
        .c_mbpl_mc_r_s(c_mbpl_mc_r_s),             
        .c_mbpl_dc_r_s(c_mbpl_dc_r_s),             
        .c_mbpl_iq_r_s(c_mbpl_iq_r_s),             
        .p_shdet_iq_r(p_shdet_iq_r),                   
        .p_hdtvh_buc_r(p_hdtvh_buc_r),                 
        .p_hdtvh_dc_r(p_hdtvh_dc_r),                   
        .p_prgseq_buc_r(p_prgseq_buc_r),               
        .p_prgseq_dc_r(p_prgseq_dc_r),                 
        .p_pstr_buc_r(p_pstr_buc_r),                   
        .p_pstr_dc_r(p_pstr_dc_r),                     
        .p_pred_forward_buc_r(p_pred_forward_buc_r),   
        .p_pred_backward_buc_r(p_pred_backward_buc_r), 
        .p_mbtyp_0_iq_r(p_mbtyp_0_iq_r),             
        .p_mbtyp_0_buc_r(p_mbtyp_0_buc_r),           
        .p_mttyp_buc_r(p_mttyp_buc_r),               
        .p_mbh_adr_buc_r(p_mbh_adr_buc_r),           
        .p_mbv_adr_buc_r(p_mbv_adr_buc_r),           
        .p_mbh_adr_dc_r(p_mbh_adr_dc_r),             
        .p_mbv_adr_dc_r(p_mbv_adr_dc_r),             
        .p_dct_typ_mc_r(p_dct_typ_mc_r),             
        .p_fstfwdvech_buc_r(p_fstfwdvech_buc_r),     
        .p_fstfwdvecv_buc_r(p_fstfwdvecv_buc_r),     
        .p_fstbwdvech_buc_r(p_fstbwdvech_buc_r),     
        .p_fstbwdvecv_buc_r(p_fstbwdvecv_buc_r),     
        .p_sndfwdvech_buc_r(p_sndfwdvech_buc_r),     
        .p_sndfwdvecv_buc_r(p_sndfwdvecv_buc_r),     
        .p_sndbwdvech_buc_r(p_sndbwdvech_buc_r),     
        .p_sndbwdvecv_buc_r(p_sndbwdvecv_buc_r),     
        .p_fldsel1_buc_r(p_fldsel1_buc_r),           
        .p_fldsel2_buc_r(p_fldsel2_buc_r),           
        .p_fldsel3_buc_r(p_fldsel3_buc_r),           
        .p_fldsel4_buc_r(p_fldsel4_buc_r),           
        .p_dmvh_buc_r(p_dmvh_buc_r),                 
        .p_dmvv_buc_r(p_dmvv_buc_r),                 
        .p_tfst_buc_r(p_tfst_buc_r),                 
        .p_idct_dis_mc_r(p_idct_dis_mc_r),           
        .p_mpg1_iq_r(p_mpg1_iq_r),                   
        .p_intradcp_iq_r(p_intradcp_iq_r),           
        .p_alterscan_iq_r(p_alterscan_iq_r),         
        .p_reffld_num1_buc_r(p_reffld_num1_buc_r),   
        .p_reffld_num2_buc_r(p_reffld_num2_buc_r),   
        .p_reffld_num3_buc_r(p_reffld_num3_buc_r),   
        .p_reffld_num4_buc_r(p_reffld_num4_buc_r),   
        .p_qscale_iq_r(p_qscale_iq_r)
      );

endmodule
