// ----------------------------------------------
// File: pb_fifo.v
// Module: pb_fifo
// Function: 
// ----------------------------------------------

module pb_fifo
  (
    clkdec,            
    rstdec_x,          
    c_mbpl_psft_r_s,     
    c_pstr_r,            
    c_mpg1_r,            
    c_prgseq_r,          
    c_mbh_adr_r,         
    c_mbv_adr_r,         
    c_dct_typ_r,         
    c_dmvh_r,            
    c_dmvv_r,            
    c_tfst_r,            
    c_shdet_r,           
    c_alterscan_r,       
    c_intradcp_r,        
    n_reffld_num1_r,     
    n_reffld_num2_r,     
    n_reffld_num3_r,     
    n_reffld_num4_r,     
    p_pred_forward_fix_r,
    p_pred_backward_fix_r,
    p_mbtyp_0_fix_r,      
    p_mttyp_fix_r,        
    p_fstfwdvech_fix_r,   
    p_fstfwdvecv_fix_r,   
    p_fstbwdvech_fix_r,   
    p_fstbwdvecv_fix_r,   
    p_sndfwdvech_fix_r,   
    p_sndfwdvecv_fix_r,   
    p_sndbwdvech_fix_r,   
    p_sndbwdvecv_fix_r,   
    p_fldsel1_fix2_r,     
    p_fldsel2_fix2_r,     
    p_fldsel3_fix2_r,     
    p_fldsel4_fix2_r,     
    p_hdtvh_r,            
    c_qscale_r,           
    c_ccl_r,              
    c_skpmb_r,            
    c_mbpl_idct_out_r_s,  
    c_mbpl_mc_r_s,        
    c_mbpl_dc_r_s,        
    c_mbpl_iq_r_s,        
    p_shdet_iq_r,         
    p_hdtvh_buc_r,        
    p_hdtvh_dc_r,         
    p_prgseq_buc_r,       
    p_prgseq_dc_r,        
    p_pstr_buc_r,         
    p_pstr_dc_r,          
    p_pred_forward_buc_r, 
    p_pred_backward_buc_r,
    p_mbtyp_0_iq_r,       
    p_mbtyp_0_buc_r,      
    p_mttyp_buc_r,        
    p_mbh_adr_buc_r,      
    p_mbv_adr_buc_r,      
    p_mbh_adr_dc_r,       
    p_mbv_adr_dc_r,       
    p_dct_typ_mc_r,       
    p_fstfwdvech_buc_r,   
    p_fstfwdvecv_buc_r,   
    p_fstbwdvech_buc_r,   
    p_fstbwdvecv_buc_r,   
    p_sndfwdvech_buc_r,   
    p_sndfwdvecv_buc_r,  
    p_sndbwdvech_buc_r,  
    p_sndbwdvecv_buc_r,  
    p_fldsel1_buc_r,     
    p_fldsel2_buc_r,      
    p_fldsel3_buc_r,     
    p_fldsel4_buc_r,     
    p_dmvh_buc_r,        
    p_dmvv_buc_r,        
    p_tfst_buc_r,        
    p_idct_dis_mc_r,     
    p_mpg1_iq_r,         
    p_intradcp_iq_r,     
    p_alterscan_iq_r,    
    p_reffld_num1_buc_r, 
    p_reffld_num2_buc_r, 
    p_reffld_num3_buc_r, 
    p_reffld_num4_buc_r, 
    p_qscale_iq_r       
  );

    input        clkdec;   
    input        rstdec_x; 
    input        c_mbpl_psft_r_s;      //MB Pulse(Parameter Shift)
    input        c_shdet_r;            //Slice Header Detected
    input        p_mbtyp_0_fix_r;       //MB Type 0(Intra) (CCL Fix)
    input        c_mpg1_r;             //MPEG1 Flag
    input [1:0]  c_intradcp_r;         //Intra DC Precision
    input        c_alterscan_r;        //Alternate Scan Flag
    input [6:0]  c_qscale_r;            //Q-scale
    input        p_pred_forward_fix_r;  //Prediction Forward (CCL Fix)
    input        p_pred_backward_fix_r; //Prediction Backward (CCL Fix)
    input [1:0]  p_mttyp_fix_r;         //Motion Type (CCL Fix)
    input [12:0] p_fstfwdvech_fix_r;    //Mton Vctr 1st Fwd H (CCL Fix)
    input [8:0]  p_fstfwdvecv_fix_r;    //Mton Vctr 1st Fwd V (CCL Fix)
    input [12:0] p_fstbwdvech_fix_r;    //Mton Vctr 1st Bwd H (CCL Fix)
    input [8:0]  p_fstbwdvecv_fix_r;    //Mton Vctr 1st Bwd V (CCL Fix)
    input [12:0] p_sndfwdvech_fix_r;    //Mton Vctr 2nt Fwd H (CCL Fix)
    input [8:0]  p_sndfwdvecv_fix_r;    //Mton Vctr 2nt Fwd V (CCL Fix)
    input [12:0] p_sndbwdvech_fix_r;    //Mton Vctr 2nd Bwd H (CCL Fix)
    input [8:0]  p_sndbwdvecv_fix_r;    //Mton Vctr 2nd Bwd V (CCL Fix)
    input        p_fldsel1_fix2_r;      //Mton Vert Fld Sel 1 (MPEG,CCL Fix)
    input        p_fldsel2_fix2_r;      //Mton Vert Fld Sel 2 (MPEG,CCL Fix)
    input        p_fldsel3_fix2_r;      //Mton Vert Fld Sel 3 (MPEG,CCL Fix)
    input        p_fldsel4_fix2_r;      //Mton Vert Fld Sel 4 (MPEG,CCL Fix)
    input [1:0]  c_dmvh_r;             //DMVector Horizontal
    input [1:0]  c_dmvv_r;             //DMVector Vertical
    input        c_tfst_r;             //Top Field First
    input [3:0]  n_reffld_num1_r;      //Reference Field 1
    input [3:0]  n_reffld_num2_r;      //Reference Field 2
    input [3:0]  n_reffld_num3_r;      //Reference Field 3
    input [3:0]  n_reffld_num4_r;      //Reference Field 4
    input        c_dct_typ_r;          //DCT Type
    input        p_hdtvh_r;             //HDTV Flag
    input        c_prgseq_r;           //Progressive Sequence
    input [1:0]  c_pstr_r;             //Picture Structure
    input [6:0]  c_mbh_adr_r;          //MB Position Now H
    input [6:0]  c_mbv_adr_r;          //MB Position Now V
    input        c_ccl_r;              //Conceal Command
    input        c_skpmb_r;            //Skip MB Command
    input        c_mbpl_idct_out_r_s;  //MB Pulse(Inverce DCT Data Output)
    input        c_mbpl_mc_r_s;        //MB Pulse(Motion Compensation)
    input        c_mbpl_dc_r_s;        //MB Pulse(Down Conversion)
    input        c_mbpl_iq_r_s;        //MB Pulse(Inverce Quantization)
    output        p_shdet_iq_r;          //Slice Header Detected IQ phase
    output        p_mbtyp_0_iq_r;        //MB Type 0(Intra) IQ phase
    output        p_mpg1_iq_r;           //MPEG1 Flag IQ phase
    output [1:0]  p_intradcp_iq_r;       //Intra DC Precision IQ phase
    output        p_alterscan_iq_r;      //Alternate Scan Flag IQ phase
    output [6:0]  p_qscale_iq_r;         //
    output        p_pred_forward_buc_r;  //Prediction Forward BUC phase
    output        p_pred_backward_buc_r; //Prediction Backward BUC phase
    output        p_mbtyp_0_buc_r;       //MB Type 0(Intra) BUC phase
    output [1:0]  p_mttyp_buc_r;         //Motion Type BUC phase
    output [12:0] p_fstfwdvech_buc_r;    //Mton Vctr 1st Fwd H BUC phase
    output [8:0]  p_fstfwdvecv_buc_r;    //Mton Vctr 1st Fwd V BUC phase
    output [12:0] p_fstbwdvech_buc_r;    //Mton Vctr 1st Bwd H BUC phase
    output [8:0]  p_fstbwdvecv_buc_r;    //Mton Vctr 1st Bwd V BUC phase
    output [12:0] p_sndfwdvech_buc_r;    //Mton Vctr 2nt Fwd H BUC phase
    output [8:0]  p_sndfwdvecv_buc_r;    //Mton Vctr 2nt Fwd V BUC phase
    output [12:0] p_sndbwdvech_buc_r;    //Mton Vctr 2nd Bwd H BUC phase
    output [8:0]  p_sndbwdvecv_buc_r;    //Mton Vctr 2nd Bwd V BUC phase
    output        p_fldsel1_buc_r;       //Mton Vert Fld Sel 1 BUC phase
    output        p_fldsel2_buc_r;       //Mton Vert Fld Sel 2 BUC phase
    output        p_fldsel3_buc_r;       //Mton Vert Fld Sel 3 BUC phase
    output        p_fldsel4_buc_r;       //Mton Vert Fld Sel 4 BUC phase
    output [1:0]  p_dmvh_buc_r;          //DMVector Horizontal BUC phase
    output [1:0]  p_dmvv_buc_r;          //DMVector Vertical BUC phase
    output        p_tfst_buc_r;          //Top Field First BUC phase
    output [3:0]  p_reffld_num1_buc_r;   //Reference Field 1 BUC phase
    output [3:0]  p_reffld_num2_buc_r;   //Reference Field 2 BUC phase
    output [3:0]  p_reffld_num3_buc_r;   //Reference Field 3 BUC phase
    output [3:0]  p_reffld_num4_buc_r;   //Reference Field 4 BUC phase
    output        p_dct_typ_mc_r;        //DCT Type MC phase(=IDCT phase)
    output        p_hdtvh_buc_r;         //HDTV Flag BUC phase
    output        p_hdtvh_dc_r;          //HDTV Flag DC phase
    output        p_prgseq_buc_r;        //Progressive Sequence BUC phase
    output        p_prgseq_dc_r;         //Progressive Sequence DC phase
    output [1:0]  p_pstr_buc_r;          //Picture Structure BUC phase
    output [1:0]  p_pstr_dc_r;           //Picture Structure DC phase
    output [6:0]  p_mbh_adr_buc_r;       //MB Position Now H BUC phase
    output [6:0]  p_mbh_adr_dc_r;        //MB Position Now H DC phase
    output [6:0]  p_mbv_adr_buc_r;       //MB Position Now V BUC phase
    output [6:0]  p_mbv_adr_dc_r;        //MB Position Now V DC phase
    output        p_idct_dis_mc_r;       //IDCT Data Disable MC phase

    reg        p_shdet_iq_r;          //Slice Header Detected IQ phase
    reg        p_hdtvh_buc_r;         //HDTV Flag BUC phase
    reg        p_hdtvh_dc_r;          //HDTV Flag DC phase
    reg        p_prgseq_buc_r;        //Progressive Sequence BUC phase
    reg        p_prgseq_dc_r;         //Progressive Sequence DC phase
    reg [1:0]  p_pstr_buc_r;          //Picture Structure BUC phase
    reg [1:0]  p_pstr_dc_r;           //Picture Structure DC phase
    reg        p_pred_forward_buc_r;  //Prediction Forward BUC phase
    reg        p_pred_backward_buc_r; //Prediction Backward BUC phase
    reg        p_mbtyp_0_iq_r;        //MB Type 0(Intra) IQ phase
    reg        p_mbtyp_0_buc_r;       //MB Type 0(Intra) BUC phase
    reg [1:0]  p_mttyp_buc_r;         //Motion Type BUC phase
    reg [6:0]  p_mbh_adr_buc_r;       //MB Position Now H BUC phase
    reg [6:0]  p_mbv_adr_buc_r;       //MB Position Now V BUC phase
    reg [6:0]  p_mbh_adr_dc_r;        //MB Position Now H DC phase
    reg [6:0]  p_mbv_adr_dc_r;        //MB Position Now V DC phase
    reg        p_dct_typ_mc_r;        //DCT Type MC phase(=IDCT phase)
    reg [12:0] p_fstfwdvech_buc_r;    //Mton Vctr 1st Fwd H BUC phase
    reg [8:0]  p_fstfwdvecv_buc_r;    //Mton Vctr 1st Fwd V BUC phase
    reg [12:0] p_fstbwdvech_buc_r;    //Mton Vctr 1st Bwd H BUC phase
    reg [8:0]  p_fstbwdvecv_buc_r;    //Mton Vctr 1st Bwd V BUC phase
    reg [12:0] p_sndfwdvech_buc_r;    //Mton Vctr 2nt Fwd H BUC phase
    reg [8:0]  p_sndfwdvecv_buc_r;    //Mton Vctr 2nt Fwd V BUC phase
    reg [12:0] p_sndbwdvech_buc_r;    //Mton Vctr 2nd Bwd H BUC phase
    reg [8:0]  p_sndbwdvecv_buc_r;    //Mton Vctr 2nd Bwd V BUC phase
    reg        p_fldsel1_buc_r;       //Mton Vert Fld Sel 1 BUC phase
    reg        p_fldsel2_buc_r;       //Mton Vert Fld Sel 2 BUC phase
    reg        p_fldsel3_buc_r;       //Mton Vert Fld Sel 3 BUC phase
    reg        p_fldsel4_buc_r;       //Mton Vert Fld Sel 4 BUC phase
    reg [1:0]  p_dmvh_buc_r;          //DMVector Horizontal BUC phase
    reg [1:0]  p_dmvv_buc_r;          //DMVector Vertical BUC phase
    reg        p_tfst_buc_r;          //Top Field First BUC phase
    reg        p_idct_dis_mc_r;       //IDCT Data Disable MC phase
    reg        p_mpg1_iq_r;           //MPEG1 Flag IQ phase
    reg [1:0]  p_intradcp_iq_r;       //Intra DC Precision IQ phase
    reg        p_alterscan_iq_r;      //Alternate Scan Flag IQ phase
    reg [3:0]  p_reffld_num1_buc_r;   //Reference Field 1 BUC phase
    reg [3:0]  p_reffld_num2_buc_r;   //Reference Field 2 BUC phase
    reg [3:0]  p_reffld_num3_buc_r;   //Reference Field 3 BUC phase
    reg [3:0]  p_reffld_num4_buc_r;   //Reference Field 4 BUC phase
    reg [6:0]  p_qscale_iq_r;         //
    reg        p_mbtyp_0_mc_r;        //MB Type 0(Intra) MC phase
    reg        p_pred_forward_mc_r;   //Prediction Forward MC phase
    reg        p_pred_backward_mc_r;  //Prediction Backward MC phase
    reg        p_dct_typ_1_r;
    reg        p_hdtvh_2_r;
    reg        p_hdtvh_3_r;
    reg        p_prgseq_2_r;
    reg        p_prgseq_3_r;
    reg [1:0]  p_pstr_2_r;
    reg [1:0]  p_pstr_3_r;
    reg [6:0]  p_mbh_adr_2_r;
    reg [6:0]  p_mbh_adr_3_r;
    reg [6:0]  p_mbv_adr_2_r;
    reg [6:0]  p_mbv_adr_3_r;
    reg        p_idct_dis_1_r;
    reg        p_idct_dis_2_r;
    reg        p_pre_idct_dis_mc_r;   //(Pre)IDCT Data Disable MC phase
    reg        p_pre_hdtvh_dc_r;      //(Pre)HDTV Flag DC phase
    reg        p_pre_prgseq_dc_r;     //(Pre)Progressive Sequence DC phase
    reg [1:0]  p_pre_pstr_dc_r;       //(Pre)Picture Structure DC phase
    reg [6:0]  p_pre_mbh_adr_dc_r;    //(Pre)MB Position Now H DC phase
    reg [6:0]  p_pre_mbv_adr_dc_r;    //(Pre)MB Position Now V DC phase
    reg        p_pre_shdet_iq_r;      //(Pre)Slice Header Detected IQ phase
    reg        p_pre_mbtyp_0_iq_r;    //(Pre)MB Type 0(Intra) IQ phase
    reg        p_pre_mpg1_iq_r;       //(Pre)MPEG1 Flag IQ phase
    reg [1:0]  p_pre_intradcp_iq_r;   //(Pre)Intra DC Precision IQ phase
    reg [6:0]  p_pre_qscale_iq_r;     //(Pre)
    reg        p_pred_forward_2_r;    //Prediction Forward UC phase
    reg        p_pred_forward_3_r;    //Prediction Forward MC phase
    reg        p_pred_backward_2_r;   //Prediction Backward UC phase
    reg        p_pred_backward_3_r;   //Prediction Backward MC phase
    reg        p_mbtyp_0_2_r;         //MB Type 0(Intra) UC phase
    reg        p_mbtyp_0_3_r;         //MB Type 0(Intra) MC phase
    reg        p_pre_shdet_iq_2_r;    //(Pre)Slice Header Detected IQ phase Shift


    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)                  
          begin
            p_pre_shdet_iq_r    <= 1'b0;
            p_pre_shdet_iq_2_r  <= 1'b0;  
            p_pre_mbtyp_0_iq_r  <= 1'b0;
            p_pre_mpg1_iq_r     <= 1'b0;
            p_pre_intradcp_iq_r <= 2'b00;
            p_pre_qscale_iq_r   <= 6'b000000;
          end
        else if (c_mbpl_psft_r_s)         
          begin
            p_pre_shdet_iq_r    <= c_shdet_r;
            p_pre_shdet_iq_2_r  <= p_pre_shdet_iq_r;
            p_pre_mbtyp_0_iq_r  <= p_mbtyp_0_fix_r;
            p_pre_mpg1_iq_r     <= c_mpg1_r;
            p_pre_intradcp_iq_r <= c_intradcp_r;
            p_pre_qscale_iq_r   <= c_qscale_r;
          end
        else
          begin
            p_pre_shdet_iq_r    <= p_pre_shdet_iq_r;
            p_pre_shdet_iq_2_r  <= p_pre_shdet_iq_2_r;
            p_pre_mbtyp_0_iq_r  <= p_pre_mbtyp_0_iq_r;
            p_pre_mpg1_iq_r     <= p_pre_mpg1_iq_r;
            p_pre_intradcp_iq_r <= p_pre_intradcp_iq_r;
            p_pre_qscale_iq_r   <= p_pre_qscale_iq_r;
          end
      end

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)       
          begin
            p_pred_forward_buc_r  <= 1'b0;
            p_pred_backward_buc_r <= 1'b0;
            p_mbtyp_0_buc_r       <= 1'b0;
            p_mttyp_buc_r         <= 2'b00;
            p_fstfwdvech_buc_r    <= 13'h0000;
            p_fstfwdvecv_buc_r    <= 9'h000;
            p_fstbwdvech_buc_r    <= 13'h0000;
            p_fstbwdvecv_buc_r    <= 9'h000;
            p_sndfwdvech_buc_r    <= 13'h0000;
            p_sndfwdvecv_buc_r    <= 9'h000;
            p_sndbwdvech_buc_r    <= 13'h0000;
            p_sndbwdvecv_buc_r    <= 9'h000;
            p_fldsel1_buc_r       <= 1'b0;
            p_fldsel2_buc_r       <= 1'b0;
            p_fldsel3_buc_r       <= 1'b0;
            p_fldsel4_buc_r       <= 1'b0;
            p_dmvh_buc_r          <= 2'b00;
            p_dmvv_buc_r          <= 2'b00;
            p_tfst_buc_r          <= 1'b0;
            p_reffld_num1_buc_r   <= 4'h0;
            p_reffld_num2_buc_r   <= 4'h0;
            p_reffld_num3_buc_r   <= 4'h0;
            p_reffld_num4_buc_r   <= 4'h0;
          end
        else if (c_mbpl_psft_r_s) 
          begin
            p_pred_forward_buc_r  <= p_pred_forward_fix_r;
            p_pred_backward_buc_r <= p_pred_backward_fix_r;
            p_mbtyp_0_buc_r       <= p_mbtyp_0_fix_r;
            p_mttyp_buc_r         <= p_mttyp_fix_r;
            p_fstfwdvech_buc_r    <= p_fstfwdvech_fix_r;
            p_fstfwdvecv_buc_r    <= p_fstfwdvecv_fix_r;
            p_fstbwdvech_buc_r    <= p_fstbwdvech_fix_r;
            p_fstbwdvecv_buc_r    <= p_fstbwdvecv_fix_r;
            p_sndfwdvech_buc_r    <= p_sndfwdvech_fix_r;
            p_sndfwdvecv_buc_r    <= p_sndfwdvecv_fix_r;
            p_sndbwdvech_buc_r    <= p_sndbwdvech_fix_r;
            p_sndbwdvecv_buc_r    <= p_sndbwdvecv_fix_r;
            p_fldsel1_buc_r       <= p_fldsel1_fix2_r;
            p_fldsel2_buc_r       <= p_fldsel2_fix2_r;
            p_fldsel3_buc_r       <= p_fldsel3_fix2_r;
            p_fldsel4_buc_r       <= p_fldsel4_fix2_r;
            p_dmvh_buc_r          <= c_dmvh_r;
            p_dmvv_buc_r          <= c_dmvv_r;
            p_tfst_buc_r          <= c_tfst_r;
            p_reffld_num1_buc_r   <= n_reffld_num1_r;
            p_reffld_num2_buc_r   <= n_reffld_num2_r;
            p_reffld_num3_buc_r   <= n_reffld_num3_r;
            p_reffld_num4_buc_r   <= n_reffld_num4_r;
          end
        else
          begin
            p_pred_forward_buc_r  <= p_pred_forward_buc_r;
            p_pred_backward_buc_r <= p_pred_backward_buc_r;
            p_mbtyp_0_buc_r       <= p_mbtyp_0_buc_r;
            p_mttyp_buc_r         <= p_mttyp_buc_r;
            p_fstfwdvech_buc_r    <= p_fstfwdvech_buc_r;
            p_fstfwdvecv_buc_r    <= p_fstfwdvecv_buc_r;
            p_fstbwdvech_buc_r    <= p_fstbwdvech_buc_r;
            p_fstbwdvecv_buc_r    <= p_fstbwdvecv_buc_r;
            p_sndfwdvech_buc_r    <= p_sndfwdvech_buc_r;
            p_sndfwdvecv_buc_r    <= p_sndfwdvecv_buc_r;
            p_sndbwdvech_buc_r    <= p_sndbwdvech_buc_r;
            p_sndbwdvecv_buc_r    <= p_sndbwdvecv_buc_r;
            p_fldsel1_buc_r       <= p_fldsel1_buc_r;
            p_fldsel2_buc_r       <= p_fldsel2_buc_r;
            p_fldsel3_buc_r       <= p_fldsel3_buc_r;
            p_fldsel4_buc_r       <= p_fldsel4_buc_r;
            p_dmvh_buc_r          <= p_dmvh_buc_r;
            p_dmvv_buc_r          <= p_dmvv_buc_r;
            p_tfst_buc_r          <= p_tfst_buc_r;
            p_reffld_num1_buc_r   <= p_reffld_num1_buc_r;
            p_reffld_num2_buc_r   <= p_reffld_num2_buc_r;
            p_reffld_num3_buc_r   <= p_reffld_num3_buc_r;
            p_reffld_num4_buc_r   <= p_reffld_num4_buc_r;
          end
      end

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            p_dct_typ_1_r  <= 1'b0;
          end
        else if (c_mbpl_psft_r_s)   
          begin
            p_dct_typ_1_r  <= c_dct_typ_r;
          end
        else
          begin
            p_dct_typ_1_r  <= p_dct_typ_1_r;
          end
      end

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)    
          begin
            p_hdtvh_buc_r    <= 1'b0;
            p_hdtvh_2_r      <= 1'b0;
            p_hdtvh_3_r      <= 1'b0;
            p_pre_hdtvh_dc_r <= 1'b0;
          end
        else if (c_mbpl_psft_r_s)
          begin
            p_hdtvh_buc_r    <= p_hdtvh_r;
            p_hdtvh_2_r      <= p_hdtvh_buc_r;
            p_hdtvh_3_r      <= p_hdtvh_2_r;
            p_pre_hdtvh_dc_r <= p_hdtvh_3_r;
          end
        else
          begin
            p_hdtvh_buc_r    <= p_hdtvh_buc_r;
            p_hdtvh_2_r      <= p_hdtvh_2_r;
            p_hdtvh_3_r      <= p_hdtvh_3_r;
            p_pre_hdtvh_dc_r <= p_pre_hdtvh_dc_r;
          end
      end

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)             
          begin
            p_prgseq_buc_r    <= 1'b0;
            p_prgseq_2_r      <= 1'b0;
            p_prgseq_3_r      <= 1'b0;
            p_pre_prgseq_dc_r <= 1'b0;
          end
        else if (c_mbpl_psft_r_s)    
          begin
            p_prgseq_buc_r    <= c_prgseq_r;
            p_prgseq_2_r      <= p_prgseq_buc_r;
            p_prgseq_3_r      <= p_prgseq_2_r;
            p_pre_prgseq_dc_r <= p_prgseq_3_r;
          end
        else
          begin
            p_prgseq_buc_r    <= p_prgseq_buc_r;
            p_prgseq_2_r      <= p_prgseq_2_r;
            p_prgseq_3_r      <= p_prgseq_3_r;
            p_pre_prgseq_dc_r <= p_pre_prgseq_dc_r;
          end
      end

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)             
          begin
            p_pstr_buc_r    <= 2'b00;
            p_pstr_2_r      <= 2'b00;
            p_pstr_3_r      <= 2'b00;
            p_pre_pstr_dc_r <= 2'b00;
          end
        else if (c_mbpl_psft_r_s)    
          begin
            p_pstr_buc_r    <= c_pstr_r;
            p_pstr_2_r      <= p_pstr_buc_r;
            p_pstr_3_r      <= p_pstr_2_r;
            p_pre_pstr_dc_r <= p_pstr_3_r;
          end
        else
          begin
            p_pstr_buc_r    <= p_pstr_buc_r;
            p_pstr_2_r      <= p_pstr_2_r;
            p_pstr_3_r      <= p_pstr_3_r;
            p_pre_pstr_dc_r <= p_pre_pstr_dc_r;
          end
      end

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)
          begin
            p_mbh_adr_buc_r    <= 7'h00;
            p_mbh_adr_2_r      <= 7'h00;
            p_mbh_adr_3_r      <= 7'h00;
            p_pre_mbh_adr_dc_r <= 7'h00;
          end
        else if (c_mbpl_psft_r_s)  
          begin
            p_mbh_adr_buc_r    <= c_mbh_adr_r;
            p_mbh_adr_2_r      <= p_mbh_adr_buc_r;
            p_mbh_adr_3_r      <= p_mbh_adr_2_r;
            p_pre_mbh_adr_dc_r <= p_mbh_adr_3_r;
          end
        else
          begin
            p_mbh_adr_buc_r    <= p_mbh_adr_buc_r;
            p_mbh_adr_2_r      <= p_mbh_adr_2_r;
            p_mbh_adr_3_r      <= p_mbh_adr_3_r;
            p_pre_mbh_adr_dc_r <= p_pre_mbh_adr_dc_r;
          end
      end

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)            
          begin
            p_mbv_adr_buc_r    <= 7'h00;
            p_mbv_adr_2_r      <= 7'h00;
            p_mbv_adr_3_r      <= 7'h00;
            p_pre_mbv_adr_dc_r <= 7'h00;
          end
        else if (c_mbpl_psft_r_s)   
          begin
            p_mbv_adr_buc_r    <= c_mbv_adr_r;
            p_mbv_adr_2_r      <= p_mbv_adr_buc_r;
            p_mbv_adr_3_r      <= p_mbv_adr_2_r;
            p_pre_mbv_adr_dc_r <= p_mbv_adr_3_r;
          end
        else
          begin
            p_mbv_adr_buc_r    <= p_mbv_adr_buc_r;
            p_mbv_adr_2_r      <= p_mbv_adr_2_r;
            p_mbv_adr_3_r      <= p_mbv_adr_3_r;
            p_pre_mbv_adr_dc_r <= p_pre_mbv_adr_dc_r;
          end
      end


    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)          
          begin
            p_idct_dis_1_r      <= 1'b0;
            p_idct_dis_2_r      <= 1'b0;
            p_pre_idct_dis_mc_r <= 1'b0;
          end
        else if (c_mbpl_psft_r_s) 
          begin
            p_idct_dis_1_r      <= c_ccl_r | c_skpmb_r;
            p_idct_dis_2_r      <= c_ccl_r & ~p_mbtyp_0_buc_r
                                      | p_idct_dis_1_r;
            p_pre_idct_dis_mc_r <= p_idct_dis_2_r;
          end
        else
          begin
            p_idct_dis_1_r      <= p_idct_dis_1_r;
            p_idct_dis_2_r      <= p_idct_dis_2_r;
            p_pre_idct_dis_mc_r <= p_pre_idct_dis_mc_r;
          end
      end

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)       
          begin
            p_alterscan_iq_r <= 1'b0;
          end
        else
          begin
            p_alterscan_iq_r <= c_alterscan_r;
          end
      end

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)     
          begin
            p_dct_typ_mc_r <= 1'b0;
          end
        else if (c_mbpl_idct_out_r_s)
          begin
            p_dct_typ_mc_r <= p_dct_typ_1_r;
          end
        else
          begin
            p_dct_typ_mc_r <= p_dct_typ_mc_r;
          end
      end

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)       
          begin
            p_pred_forward_2_r  <= 1'b0;
            p_pred_forward_3_r  <= 1'b0;
            p_pred_backward_2_r <= 1'b0;
            p_pred_backward_3_r <= 1'b0;
            p_mbtyp_0_2_r       <= 1'b0;
            p_mbtyp_0_3_r       <= 1'b0;
          end
        else if (c_mbpl_psft_r_s)  
          begin
            p_pred_forward_2_r  <= p_pred_forward_buc_r;
            p_pred_forward_3_r  <= p_pred_forward_2_r;
            p_pred_backward_2_r <= p_pred_backward_buc_r;
            p_pred_backward_3_r <= p_pred_backward_2_r;
            p_mbtyp_0_2_r       <= p_mbtyp_0_buc_r;
            p_mbtyp_0_3_r       <= p_mbtyp_0_2_r;
          end
        else
          begin
            p_pred_forward_2_r  <= p_pred_forward_2_r;
            p_pred_forward_3_r  <= p_pred_forward_3_r;
            p_pred_backward_2_r <= p_pred_backward_2_r;
            p_pred_backward_3_r <= p_pred_backward_3_r;
            p_mbtyp_0_2_r       <= p_mbtyp_0_2_r;
            p_mbtyp_0_3_r       <= p_mbtyp_0_3_r;
          end
      end


    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)     
          begin
            p_idct_dis_mc_r      <= 1'b0;
            p_mbtyp_0_mc_r       <= 1'b0;
            p_pred_forward_mc_r  <= 1'b0;
            p_pred_backward_mc_r <= 1'b0;
          end
        else if (c_mbpl_mc_r_s)
          begin
            p_idct_dis_mc_r      <= p_pre_idct_dis_mc_r;
            p_mbtyp_0_mc_r       <= p_mbtyp_0_3_r;
            p_pred_forward_mc_r  <= p_pred_forward_3_r;
            p_pred_backward_mc_r <= p_pred_backward_3_r;
          end
        else
          begin
            p_idct_dis_mc_r      <= p_idct_dis_mc_r ^ p_mbtyp_0_mc_r ^ p_pred_forward_mc_r ^ p_pred_backward_mc_r;
            p_mbtyp_0_mc_r       <= p_mbtyp_0_mc_r;
            p_pred_forward_mc_r  <= p_pred_forward_mc_r;
            p_pred_backward_mc_r <= p_pred_backward_mc_r;
          end
      end

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)     
          begin
            p_hdtvh_dc_r   <= 1'b0;
            p_prgseq_dc_r  <= 1'b0;
            p_pstr_dc_r    <= 2'b00;
            p_mbh_adr_dc_r <= 7'h00;
            p_mbv_adr_dc_r <= 7'h00;
          end
        else if (c_mbpl_dc_r_s)
          begin
            p_hdtvh_dc_r   <= p_pre_hdtvh_dc_r;
            p_prgseq_dc_r  <= p_pre_prgseq_dc_r;
            p_pstr_dc_r    <= p_pre_pstr_dc_r;
            p_mbh_adr_dc_r <= p_pre_mbh_adr_dc_r;
            p_mbv_adr_dc_r <= p_pre_mbv_adr_dc_r;
          end
        else
          begin
            p_hdtvh_dc_r   <= p_hdtvh_dc_r;
            p_prgseq_dc_r  <= p_prgseq_dc_r;
            p_pstr_dc_r    <= p_pstr_dc_r;
            p_mbh_adr_dc_r <= p_mbh_adr_dc_r;
            p_mbv_adr_dc_r <= p_mbv_adr_dc_r;
          end
      end


    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)     
          begin
            p_shdet_iq_r     <= 1'b0;
            p_mbtyp_0_iq_r   <= 1'b0;
            p_mpg1_iq_r      <= 1'b0;
            p_intradcp_iq_r  <= 2'b00;
            p_qscale_iq_r    <= 6'b000000;
          end
        else if (c_mbpl_iq_r_s)
          begin
            p_shdet_iq_r     <= p_pre_shdet_iq_2_r;
            p_mbtyp_0_iq_r   <= p_pre_mbtyp_0_iq_r;
            p_mpg1_iq_r      <= p_pre_mpg1_iq_r;
            p_intradcp_iq_r  <= p_pre_intradcp_iq_r;
            p_qscale_iq_r    <= p_pre_qscale_iq_r;
          end
        else
          begin
            p_shdet_iq_r     <= p_shdet_iq_r;
            p_mbtyp_0_iq_r   <= p_mbtyp_0_iq_r;
            p_mpg1_iq_r      <= p_mpg1_iq_r;
            p_intradcp_iq_r  <= p_intradcp_iq_r;
            p_qscale_iq_r    <= p_qscale_iq_r;
          end
      end

endmodule

