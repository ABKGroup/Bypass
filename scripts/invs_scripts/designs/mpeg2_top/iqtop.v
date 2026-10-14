// ----------------------------------------------
// File: iqtop.v
// Module: iqtop
// Function:Inverse Quantization top module
// ----------------------------------------------

module iqtop (
     clkdec,       
     rstdec_x,     
     c_mbpl_iq_r_s,  
     c_qmdata_r,     
     c_qmintra_r,    
     c_qmseln_r,     
     c_qmsynn_r_n,   
     p_alterscan_iq_r,
     p_intradcp_iq_r, 
     p_mbtyp_0_iq_r, 
     p_mpg1_iq_r,     
     p_qscale_iq_r,   
     p_shdet_iq_r,    
     v_vdo_r,         
     v_vdoen_r,       
     q_blkstp_r_s, 
     q_do_r       
            );
     input            clkdec;     
     input            rstdec_x;    
     input            c_mbpl_iq_r_s; 
     input      [7:0] c_qmdata_r;    
     input            c_qmintra_r;   
     input            c_qmseln_r;    
     input            c_qmsynn_r_n;  
     input            p_alterscan_iq_r;
     input      [1:0] p_intradcp_iq_r; 
     input            p_mbtyp_0_iq_r;  
     input            p_mpg1_iq_r;  
     input      [6:0] p_qscale_iq_r;
     input            p_shdet_iq_r; 
     input     [11:0] v_vdo_r;      
     input            v_vdoen_r;    
    output            q_blkstp_r_s; 
    output     [11:0] q_do_r;       

      wire            blken_flag_reg; 
      wire            blklst_flag_reg;
      wire            blkst_flag_reg; 
      wire            cbblk_reg;      
      wire            crblk_reg;      
      wire      [1:0] dcprec_reg;     
      wire            icbst_reg;      
      wire            icrst_reg;      
      wire            intradc4_reg;   
      wire            intradc_reg;    
      wire     [15:0] iqpastdc_reg;   
      wire            iyxst_reg;      
      wire            mbintr_reg;     
      wire            mpegx_reg;      
      wire     [15:0] mtrxout_reg;    
      wire            pintr_reg;      
      wire            pmana_reg;      
      wire      [7:0] qscale_reg;     
      wire            slcsf_reg;      
      wire     [11:0] smd2;           
      wire            ybr0_reg;  
      wire     [6:0]  v1_mtx00_a;
      wire            v1_mtx00_bs; 
      wire     [7:0]  v1_mtx00_d;
      wire            v1_mtx00_we;
      wire     [7:0]  w1_mtx00_q;
      wire     [8:0]  v1_zgt00_a; 
      wire            v1_zgt00_bs; 
      wire     [11:0] v1_zgt00_d;
      wire            v1_zgt00_we; 
      wire     [11:0] w1_zgt00_q;
      wire     [8:0]  v1_zgt01_a; 
      wire            v1_zgt01_bs; 
      wire     [11:0] v1_zgt01_d;
      wire            v1_zgt01_we; 
      wire     [11:0] w1_zgt01_q;


iq_1stage  iq_1stage (
     .clkdec(clkdec),
     .dcprec_reg(dcprec_reg),    
     .intradc_reg(intradc_reg),  
     .mbintr_reg(mbintr_reg),    
     .mpegx_reg(mpegx_reg),      
     .pmana_reg(pmana_reg),      
     .qscale_reg(qscale_reg),    
     .w1_mtx00_q(w1_mtx00_q),    
     .w1_zgt00_q(w1_zgt00_q),  
     .w1_zgt01_q(w1_zgt01_q),  
     .intradc4_reg(intradc4_reg),  
     .mtrxout_reg(mtrxout_reg)     
     );

iq_2stage  iq_2stage (
     .blken_flag_reg(blken_flag_reg),  
     .blklst_flag_reg(blklst_flag_reg),
     .blkst_flag_reg(blkst_flag_reg),  
     .clkdec(clkdec),          
     .intradc4_reg(intradc4_reg),      
     .iqpastdc_reg(iqpastdc_reg),      
     .mbintr_reg(mbintr_reg),          
     .mpegx_reg(mpegx_reg),            
     .mtrxout_reg(mtrxout_reg),        
     .qscale_reg(qscale_reg),          
     .rstdec_x(rstdec_x),      
     .smd2(smd2),                      
     .q_do_r(q_do_r)               
     );

iq_pastdc  iq_pastdc (
     .cbblk_reg(cbblk_reg),            
     .clkdec(clkdec),          
     .crblk_reg(crblk_reg),            
     .icbst_reg(icbst_reg),            
     .icrst_reg(icrst_reg),            
     .iyxst_reg(iyxst_reg),            
     .pintr_reg(pintr_reg),            
     .rstdec_x(rstdec_x),      
     .slcsf_reg(slcsf_reg),            
     .smd2(smd2),                    
     .ybr0_reg(ybr0_reg),            
     .iqpastdc_reg(iqpastdc_reg)     
     );

iq_seq  iq_seq (
    .clkdec(clkdec),             
    .rstdec_x(rstdec_x),         
    .c_mbpl_iq_r_s(c_mbpl_iq_r_s),   
    .c_qmdata_r(c_qmdata_r),         
    .c_qmintra_r(c_qmintra_r),       
    .c_qmseln_r(c_qmseln_r),         
    .c_qmsynn_r_n(c_qmsynn_r_n),     
    .p_alterscan_iq_r(p_alterscan_iq_r),
    .p_intradcp_iq_r(p_intradcp_iq_r),
    .p_mbtyp_0_iq_r(p_mbtyp_0_iq_r),  
    .p_mpg1_iq_r(p_mpg1_iq_r),        
    .p_qscale_iq_r(p_qscale_iq_r),    
    .p_shdet_iq_r(p_shdet_iq_r),      
    .v_vdo_r(v_vdo_r),            
    .v_vdoen_r(v_vdoen_r),        
    .blken_flag_reg(blken_flag_reg),  
    .blklst_flag_reg(blklst_flag_reg),
    .blkst_flag_reg(blkst_flag_reg),  
    .cbblk_reg(cbblk_reg),            
    .crblk_reg(crblk_reg),            
    .dcprec_reg(dcprec_reg),          
    .icbst_reg(icbst_reg),            
    .icrst_reg(icrst_reg),            
    .intradc_reg(intradc_reg),        
    .iyxst_reg(iyxst_reg),            
    .mbintr_reg(mbintr_reg),          
    .mpegx_reg(mpegx_reg),            
    .pintr_reg(pintr_reg),            
    .pmana_reg(pmana_reg),            
    .qscale_reg(qscale_reg),          
    .slcsf_reg(slcsf_reg),            
    .v1_mtx00_a(v1_mtx00_a),          
    .v1_mtx00_bs(v1_mtx00_bs),        
    .v1_mtx00_d(v1_mtx00_d),          
    .v1_mtx00_we(v1_mtx00_we),        
    .v1_zgt00_a(v1_zgt00_a),          
    .v1_zgt00_bs(v1_zgt00_bs),        
    .v1_zgt00_d(v1_zgt00_d),          
    .v1_zgt00_we(v1_zgt00_we),        
    .v1_zgt01_a(v1_zgt01_a),          
    .v1_zgt01_bs(v1_zgt01_bs),        
    .v1_zgt01_d(v1_zgt01_d),          
    .v1_zgt01_we(v1_zgt01_we),       
    .q_blkstp_r_s(q_blkstp_r_s), 
    .ybr0_reg(ybr0_reg)              
);

iq_mtxarray idctmtx(
   .clkdec       (clkdec),
   .rstdec_x     (rstdec_x),
   .v1_mtx00_a   (v1_mtx00_a),
   .v1_mtx00_bs  (v1_mtx00_bs),
   .v1_mtx00_d   (v1_mtx00_d),
   .v1_mtx00_we  (v1_mtx00_we),
   .w1_mtx00_q   (w1_mtx00_q)
   );

iq_zgtarray idctzgt(
   .clkdec       (clkdec),
   .rstdec_x     (rstdec_x),
   .v1_zgt00_a   (v1_zgt00_a),
   .v1_zgt00_bs  (v1_zgt00_bs),
   .v1_zgt00_d   (v1_zgt00_d),
   .v1_zgt00_we  (v1_zgt00_we),
   .w1_zgt00_q   (w1_zgt00_q),
   .v1_zgt01_a   (v1_zgt01_a),
   .v1_zgt01_bs  (v1_zgt01_bs),
   .v1_zgt01_d   (v1_zgt01_d),
   .v1_zgt01_we  (v1_zgt01_we),
   .w1_zgt01_q   (w1_zgt01_q)
   );

endmodule

