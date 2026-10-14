// ----------------------------------------------
// File: dc_vtflt.v
// Module: dc_vtflt
// Function:
// ----------------------------------------------

module dc_vtflt ( 
    clkdec, 
    rstdec_x, 
    c_mbpl_dc_r_s, 
    d_hvmem_cen_r, 
    d_hvmem_yen_r, 
    d_vflt_din, 
    p_hdtvh_dc_r, 
    d_vflt_cen_r, 
    d_vflt_dout, 
    d_vflt_yen_r
);

input        clkdec;      
input        rstdec_x;    
input        c_mbpl_dc_r_s; 
input        d_hvmem_cen_r; 
input        d_hvmem_yen_r; 
input  [7:0] d_vflt_din;    
input        p_hdtvh_dc_r;  
output       d_vflt_cen_r;  
output [7:0] d_vflt_dout;   
output       d_vflt_yen_r;  

wire         clkdec;      
wire         rstdec_x;    
wire         c_mbpl_dc_r_s; 
wire         d_hvmem_cen_r; 
wire         d_hvmem_yen_r; 
wire [7:0]   d_vflt_din;    
wire         p_hdtvh_dc_r;  
wire         d_vflt_cen_r;  
wire [7:0]   d_vflt_dout;   
wire         d_vflt_yen_r;  

wire        d_b_ff_enb_r;   
wire        d_c1_slct;      
wire        d_c_slct;       
wire [8:0]  d_coef_0;       
wire [8:0]  d_coef_1;       
wire [8:0]  d_coef_2;       
wire [8:0]  d_coef_3;       
wire [8:0]  d_coef_4;       
wire [8:0]  d_coef_5;       
wire [8:0]  d_coef_6;       
wire [8:0]  d_coef_7;       
wire        d_decyen_r;     
wire [7:0]  d_f_ff_enb_r;   
wire [2:0]  d_phase;        
wire [7:0]  d_pix_0;        
wire [7:0]  d_pix_1;        
wire [7:0]  d_pix_2;        
wire [7:0]  d_pix_3;        
wire [7:0]  d_pix_4;        
wire [7:0]  d_pix_5;        
wire [7:0]  d_pix_6;        
wire [7:0]  d_pix_7;        
wire [16:0] d_ppro_0;       
wire [16:0] d_ppro_1;       
wire [16:0] d_ppro_2;       
wire [16:0] d_ppro_3;       
wire [16:0] d_ppro_4;       
wire [16:0] d_ppro_5;       
wire [16:0] d_ppro_6;       
wire [16:0] d_ppro_7;       
wire [19:0] d_psum;         


dc_hmult dc_hmult_0( 
    .clkdec       (clkdec), 
    .rstdec_x     (rstdec_x), 
    .d_pix      (d_pix_0), 
    .d_coef     (d_coef_0), 
    .d_ppro     (d_ppro_0)
); 

dc_hmult dc_hmult_1( 
    .clkdec       (clkdec), 
    .rstdec_x     (rstdec_x), 
    .d_pix      (d_pix_1), 
    .d_coef     (d_coef_1), 
    .d_ppro     (d_ppro_1)
); 

dc_hmult dc_hmult_2( 
    .clkdec       (clkdec), 
    .rstdec_x     (rstdec_x), 
    .d_pix      (d_pix_2), 
    .d_coef     (d_coef_2), 
    .d_ppro     (d_ppro_2)
); 

dc_hmult dc_hmult_3( 
    .clkdec   (clkdec), 
    .rstdec_x (rstdec_x), 
    .d_pix      (d_pix_3), 
    .d_coef     (d_coef_3), 
    .d_ppro     (d_ppro_3)
); 

dc_hmult dc_hmult_4( 
    .clkdec       (clkdec), 
    .rstdec_x     (rstdec_x), 
    .d_pix      (d_pix_4), 
    .d_coef     (d_coef_4), 
    .d_ppro     (d_ppro_4)
); 

dc_hmult dc_hmult_5( 
    .clkdec       (clkdec), 
    .rstdec_x     (rstdec_x), 
    .d_pix      (d_pix_5), 
    .d_coef     (d_coef_5), 
    .d_ppro     (d_ppro_5)
); 

dc_hmult dc_hmult_6( 
    .clkdec       (clkdec), 
    .rstdec_x     (rstdec_x), 
    .d_pix      (d_pix_6), 
    .d_coef     (d_coef_6), 
    .d_ppro     (d_ppro_6)
); 

dc_hmult dc_hmult_7( 
    .clkdec       (clkdec), 
    .rstdec_x     (rstdec_x), 
    .d_pix      (d_pix_7), 
    .d_coef     (d_coef_7), 
    .d_ppro     (d_ppro_7)
); 

dc_vcbnk dc_vcbnk( 
    .clkdec       (clkdec), 
    .rstdec_x     (rstdec_x), 
    .d_decyen_r (d_decyen_r), 
    .d_phase    (d_phase), 
    .d_c1_slct  (d_c1_slct), 
    .d_coef_0   (d_coef_0), 
    .d_coef_1   (d_coef_1), 
    .d_coef_2   (d_coef_2), 
    .d_coef_3   (d_coef_3), 
    .d_coef_4   (d_coef_4), 
    .d_coef_5   (d_coef_5), 
    .d_coef_6   (d_coef_6), 
    .d_coef_7   (d_coef_7)
); 

dc_vpdsm dc_vpdsm( 
    .clkdec       (clkdec), 
    .rstdec_x     (rstdec_x), 
    .d_ppro_0   (d_ppro_0), 
    .d_ppro_1   (d_ppro_1), 
    .d_ppro_2   (d_ppro_2), 
    .d_ppro_3   (d_ppro_3), 
    .d_ppro_4   (d_ppro_4), 
    .d_ppro_5   (d_ppro_5), 
    .d_ppro_6   (d_ppro_6), 
    .d_ppro_7   (d_ppro_7), 
    .d_psum     (d_psum)
); 

dc_vrdcp dc_vrdcp( 
    .clkdec        (clkdec), 
    .rstdec_x      (rstdec_x), 
    .d_psum      (d_psum), 
    .d_vflt_dout (d_vflt_dout)
); 

dc_vtgct dc_vtgct( 
    .clkdec          (clkdec), 
    .rstdec_x        (rstdec_x), 
    .d_hvmem_yen_r (d_hvmem_yen_r), 
    .d_hvmem_cen_r (d_hvmem_cen_r), 
    .p_hdtvh_dc_r  (p_hdtvh_dc_r), 
    .c_mbpl_dc_r_s (c_mbpl_dc_r_s), 
    .d_f_ff_enb_r  (d_f_ff_enb_r), 
    .d_b_ff_enb_r  (d_b_ff_enb_r), 
    .d_phase       (d_phase), 
    .d_c_slct      (d_c_slct), 
    .d_c1_slct     (d_c1_slct), 
    .d_decyen_r    (d_decyen_r), 
    .d_vflt_yen_r  (d_vflt_yen_r), 
    .d_vflt_cen_r  (d_vflt_cen_r)
); 

dc_vxpnd dc_vxpnd( 
    .clkdec         (clkdec), 
    .rstdec_x       (rstdec_x), 
    .d_c_slct     (d_c_slct), 
    .d_vflt_din   (d_vflt_din), 
    .d_f_ff_enb_r (d_f_ff_enb_r), 
    .d_b_ff_enb_r (d_b_ff_enb_r), 
    .d_pix_0      (d_pix_0), 
    .d_pix_1      (d_pix_1), 
    .d_pix_2      (d_pix_2), 
    .d_pix_3      (d_pix_3), 
    .d_pix_4      (d_pix_4), 
    .d_pix_5      (d_pix_5), 
    .d_pix_6      (d_pix_6), 
    .d_pix_7      (d_pix_7)
); 

endmodule

