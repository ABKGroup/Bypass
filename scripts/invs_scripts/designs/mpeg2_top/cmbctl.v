// ----------------------------------------------
// File: cmbctl.v
// Module: cmbctl
// Function:
// ----------------------------------------------

module cmbctl (
    clkdec,            
    rstdec_x,          
    v_slclverr_r,      
    v_ferror_r,        
    c_pcpl_r_s,        
    c_mbpl_pos_r_s,    
    c_mbai_r,          
    c_svp_r,           
    c_pctv_mb_r,       
    c_pcth_mb_r,       
    c_shdet_r,         
    c_mbaidet_s,       
    c_mpg1_r,          
    c_pic_notcplt_r,   
    c_skipslc_r_s,     
    c_mb_nferr_r,      
    c_mb_ferr_r,       
    c_mb_fin_r,        
    c_mbv_adr_r,       
    c_mbh_adr_r,       
    c_skpmb_r,         
    c_ccl_r            
  );

    input        clkdec;        
    input        rstdec_x;      
    input        v_slclverr_r;   
    input        v_ferror_r;     
    input        c_pcpl_r_s;     
    input        c_pic_notcplt_r;  
    input        c_mbpl_pos_r_s;   
    input [17:0] c_mbai_r;         
    input [7:0]  c_svp_r;          
    input [6:0]  c_pctv_mb_r;      
    input [6:0]  c_pcth_mb_r;      
    input        c_shdet_r;        
    input        c_mbaidet_s;      
    input        c_mpg1_r;         
    output       c_skipslc_r_s;   
    output [2:0] c_mb_nferr_r;    
    output       c_mb_ferr_r;     
    output       c_mb_fin_r;      
    output [6:0] c_mbv_adr_r;     
    output [6:0] c_mbh_adr_r;     
    output       c_skpmb_r;       
    output       c_ccl_r;         

    wire [6:0]  c_mbv_adr_p1_r;       //Now MB Vertical Position
    wire [6:0]  c_mbh_adr_p1_r;       //Now MB Horizontal Position
    wire [7:0]  c_mbv_adr_nxt_r;      //Next MB Vertical Position
    wire [6:0]  c_mbh_adr_nxt_r;      //Next MB Horizontal Position
    wire        c_mb_nxt_fix_r;       //Next MB Fix
    wire        c_rvs_mbp_r;          //MB Reverse Position Command

    cmnwmbp cmnwmbp(
        .clkdec(clkdec),         
        .rstdec_x(rstdec_x),     
        .c_pcpl_r_s(c_pcpl_r_s),     
        .c_mbpl_pos_r_s(c_mbpl_pos_r_s),
        .c_mbai_r(c_mbai_r[6:0]),  
        .c_svp_r(c_svp_r[6:0]),    
        .c_pctv_mb_r(c_pctv_mb_r), 
        .c_pcth_mb_r(c_pcth_mb_r), 
        .c_rvs_mbp_r(c_rvs_mbp_r), 
        .c_mb_fin_r(c_mb_fin_r),   
        .c_mbv_adr_r(c_mbv_adr_r), 
        .c_mbh_adr_r(c_mbh_adr_r), 
        .c_mbv_adr_p1_r(c_mbv_adr_p1_r),
        .c_mbh_adr_p1_r(c_mbh_adr_p1_r) 
      );
   
    cmnxmbp cmnxmbp(
        .clkdec(clkdec),        
        .rstdec_x(rstdec_x),    
        .c_mbai_r(c_mbai_r),        
        .c_svp_r(c_svp_r),          
        .c_pcth_mb_r(c_pcth_mb_r),  
        .c_shdet_r(c_shdet_r),      
        .c_mbaidet_s(c_mbaidet_s),  
        .c_mbv_adr_nxt_r(c_mbv_adr_nxt_r),
        .c_mbh_adr_nxt_r(c_mbh_adr_nxt_r),
        .c_mb_nxt_fix_r(c_mb_nxt_fix_r)   
      );
   
    cmbfix cmbfix(
        .clkdec(clkdec),        
        .rstdec_x(rstdec_x),    
        .v_slclverr_r(v_slclverr_r),
        .v_ferror_r(v_ferror_r),    
        .c_pcpl_r_s(c_pcpl_r_s),    
        .c_pctv_mb_r(c_pctv_mb_r),  
        .c_pcth_mb_r(c_pcth_mb_r),  
        .c_shdet_r(c_shdet_r),      
        .c_mpg1_r(c_mpg1_r),       
        .c_mbv_adr_p1_r(c_mbv_adr_p1_r),
        .c_mbh_adr_p1_r(c_mbh_adr_p1_r),
        .c_mb_fin_r(c_mb_fin_r),
        .c_mbv_adr_nxt_r(c_mbv_adr_nxt_r),
        .c_mbh_adr_nxt_r(c_mbh_adr_nxt_r),
        .c_pic_notcplt_r(c_pic_notcplt_r),
        .c_mb_nxt_fix_r(c_mb_nxt_fix_r),  
        .c_skipslc_r_s(c_skipslc_r_s),
        .c_mb_nferr_r(c_mb_nferr_r),  
        .c_mb_ferr_r(c_mb_ferr_r),    
        .c_skpmb_r(c_skpmb_r),
        .c_ccl_r(c_ccl_r),    
        .c_rvs_mbp_r(c_rvs_mbp_r)
      );
   
endmodule


