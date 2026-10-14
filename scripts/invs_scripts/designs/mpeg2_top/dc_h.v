// ----------------------------------------------
// File: dc_h.v
// Module: dc_h
// Function: 
// ----------------------------------------------

module dc_h ( 
   clkdec, 
   rstdec_x, 
   c_mbpl_dc_r_s, 
   m_deccen_r, 
   m_decdt_r, 
   m_decyen_r, 
   p_hdtvh_dc_r, 
   d_dech_cen_r, 
   d_dech_dt_r, 
   d_dech_yen_r
);

input         clkdec;     
input         rstdec_x;   
input         c_mbpl_dc_r_s;
input         m_deccen_r;   
input  [15:0] m_decdt_r;    
input         m_decyen_r;   
input         p_hdtvh_dc_r; 
output        d_dech_cen_r; 
output [15:0] d_dech_dt_r;  
output        d_dech_yen_r; 

wire         clkdec;      
wire         rstdec_x;    
wire         c_mbpl_dc_r_s; 
wire         m_deccen_r;    
wire [15:0]  m_decdt_r;     
wire         m_decyen_r;    
wire         p_hdtvh_dc_r;  
wire         d_dech_cen_r;  
wire [15:0]  d_dech_dt_r;   
wire         d_dech_yen_r;  

wire        d_b_ff_enb_r; 
wire        d_c1_slct_r;  
wire        d_c_slct_r;   
wire [8:0]  d_coef_0;     
wire [8:0]  d_coef_1;     
wire [8:0]  d_coef_2;     
wire [8:0]  d_coef_3;     
wire [8:0]  d_coef_4;     
wire [8:0]  d_coef_5;     
wire [8:0]  d_coef_6;     
wire [8:0]  d_coef_7;     
wire [8:0]  d_coef_8;     
wire [8:0]  d_coef_9;     
wire [8:0]  d_coef_a;     
wire [8:0]  d_coef_b;     
wire [8:0]  d_coef_c;     
wire [8:0]  d_coef_d;     
wire [8:0]  d_coef_e;     
wire [8:0]  d_coef_f;     
wire [15:0] d_decdt;      
wire        d_decyen_r;   
wire [7:0]  d_f_ff_enb_r; 
wire        d_hdtvh_dc_r; 
wire [2:0]  d_phase;       
wire [7:0]  d_pix_0;       
wire [7:0]  d_pix_1;       
wire [7:0]  d_pix_2;     
wire [7:0]  d_pix_3;     
wire [7:0]  d_pix_4;     
wire [7:0]  d_pix_5;     
wire [7:0]  d_pix_6;     
wire [7:0]  d_pix_7;     
wire [7:0]  d_pix_8;     
wire [7:0]  d_pix_9;     
wire [7:0]  d_pix_a;     
wire [7:0]  d_pix_b;     
wire [7:0]  d_pix_c;     
wire [7:0]  d_pix_d;     
wire [7:0]  d_pix_e;     
wire [7:0]  d_pix_f;     
wire [16:0] d_ppro_0;    
wire [16:0] d_ppro_1;    
wire [16:0] d_ppro_2;    
wire [16:0] d_ppro_3;    
wire [16:0] d_ppro_4;    
wire [16:0] d_ppro_5;    
wire [16:0] d_ppro_6;    
wire [16:0] d_ppro_7;    
wire [16:0] d_ppro_8;    
wire [16:0] d_ppro_9;    
wire [16:0] d_ppro_a;    
wire [16:0] d_ppro_b;    
wire [16:0] d_ppro_c;    
wire [16:0] d_ppro_d;    
wire [16:0] d_ppro_e;    
wire [16:0] d_ppro_f;   
wire [20:0] d_psum;     

dc_hcbnk dc_hcbnk( 
   .clkdec   (clkdec), 
   .rstdec_x (rstdec_x), 
   .d_decyen_r (d_decyen_r), 
   .d_phase    (d_phase), 
   .d_c_slct_r   (d_c_slct_r), 
   .d_coef_0   (d_coef_0), 
   .d_coef_1   (d_coef_1), 
   .d_coef_2   (d_coef_2), 
   .d_coef_3   (d_coef_3), 
   .d_coef_4   (d_coef_4), 
   .d_coef_5   (d_coef_5), 
   .d_coef_6   (d_coef_6), 
   .d_coef_7   (d_coef_7), 
   .d_coef_8   (d_coef_8), 
   .d_coef_9   (d_coef_9), 
   .d_coef_a   (d_coef_a), 
   .d_coef_b   (d_coef_b), 
   .d_coef_c   (d_coef_c), 
   .d_coef_d   (d_coef_d), 
   .d_coef_e   (d_coef_e), 
   .d_coef_f   (d_coef_f)
); 

dc_hmult dc_hmult_f( 
   .clkdec   (clkdec), 
   .rstdec_x (rstdec_x), 
   .d_pix      (d_pix_f), 
   .d_coef     (d_coef_f), 
   .d_ppro     (d_ppro_f)
); 

dc_hmult dc_hmult_e( 
   .clkdec   (clkdec), 
   .rstdec_x (rstdec_x), 
   .d_pix      (d_pix_e), 
   .d_coef     (d_coef_e), 
   .d_ppro     (d_ppro_e)
); 

dc_hmult dc_hmult_d( 
   .clkdec   (clkdec), 
   .rstdec_x (rstdec_x), 
   .d_pix      (d_pix_d), 
   .d_coef     (d_coef_d), 
   .d_ppro     (d_ppro_d)
); 

dc_hmult dc_hmult_c( 
   .clkdec   (clkdec), 
   .rstdec_x (rstdec_x), 
   .d_pix      (d_pix_c), 
   .d_coef     (d_coef_c), 
   .d_ppro     (d_ppro_c)
); 

dc_hmult dc_hmult_b( 
   .clkdec   (clkdec), 
   .rstdec_x (rstdec_x), 
   .d_pix      (d_pix_b), 
   .d_coef     (d_coef_b), 
   .d_ppro     (d_ppro_b)
); 

dc_hmult dc_hmult_a( 
   .clkdec   (clkdec), 
   .rstdec_x (rstdec_x), 
   .d_pix      (d_pix_a), 
   .d_coef     (d_coef_a), 
   .d_ppro     (d_ppro_a)
); 

dc_hmult dc_hmult_9( 
   .clkdec   (clkdec), 
   .rstdec_x (rstdec_x), 
   .d_pix      (d_pix_9), 
   .d_coef     (d_coef_9), 
   .d_ppro     (d_ppro_9)
); 

dc_hmult dc_hmult_8( 
   .clkdec   (clkdec), 
   .rstdec_x (rstdec_x), 
   .d_pix      (d_pix_8), 
   .d_coef     (d_coef_8), 
   .d_ppro     (d_ppro_8)
); 

dc_hmult dc_hmult_7( 
   .clkdec   (clkdec), 
   .rstdec_x (rstdec_x), 
   .d_pix      (d_pix_7), 
   .d_coef     (d_coef_7), 
   .d_ppro     (d_ppro_7)
); 

dc_hmult dc_hmult_6( 
   .clkdec   (clkdec), 
   .rstdec_x (rstdec_x), 
   .d_pix      (d_pix_6), 
   .d_coef     (d_coef_6), 
   .d_ppro     (d_ppro_6)
); 

dc_hmult dc_hmult_5( 
   .clkdec   (clkdec), 
   .rstdec_x (rstdec_x), 
   .d_pix      (d_pix_5), 
   .d_coef     (d_coef_5), 
   .d_ppro     (d_ppro_5)
); 

dc_hmult dc_hmult_4( 
   .clkdec   (clkdec), 
   .rstdec_x (rstdec_x), 
   .d_pix      (d_pix_4), 
   .d_coef     (d_coef_4), 
   .d_ppro     (d_ppro_4)
); 

dc_hmult dc_hmult_3( 
   .clkdec   (clkdec), 
   .rstdec_x (rstdec_x), 
   .d_pix      (d_pix_3), 
   .d_coef     (d_coef_3), 
   .d_ppro     (d_ppro_3)
); 

dc_hmult dc_hmult_2( 
   .clkdec   (clkdec), 
   .rstdec_x (rstdec_x), 
   .d_pix      (d_pix_2), 
   .d_coef     (d_coef_2), 
   .d_ppro     (d_ppro_2)
); 

dc_hmult dc_hmult_1( 
   .clkdec   (clkdec), 
   .rstdec_x (rstdec_x), 
   .d_pix      (d_pix_1), 
   .d_coef     (d_coef_1), 
   .d_ppro     (d_ppro_1)
); 

dc_hmult dc_hmult_0( 
   .clkdec   (clkdec), 
   .rstdec_x (rstdec_x), 
   .d_pix      (d_pix_0), 
   .d_coef     (d_coef_0), 
   .d_ppro     (d_ppro_0)
); 

dc_hpdsm dc_hpdsm( 
   .clkdec   (clkdec), 
   .rstdec_x (rstdec_x), 
   .d_ppro_0   (d_ppro_0), 
   .d_ppro_1   (d_ppro_1), 
   .d_ppro_2   (d_ppro_2), 
   .d_ppro_3   (d_ppro_3), 
   .d_ppro_4   (d_ppro_4), 
   .d_ppro_5   (d_ppro_5), 
   .d_ppro_6   (d_ppro_6), 
   .d_ppro_7   (d_ppro_7), 
   .d_ppro_8   (d_ppro_8), 
   .d_ppro_9   (d_ppro_9), 
   .d_ppro_a   (d_ppro_a), 
   .d_ppro_b   (d_ppro_b), 
   .d_ppro_c   (d_ppro_c), 
   .d_ppro_d   (d_ppro_d), 
   .d_ppro_e   (d_ppro_e), 
   .d_ppro_f   (d_ppro_f), 
   .d_psum     (d_psum)
); 

dc_hrdcp dc_hrdcp( 
   .clkdec     (clkdec), 
   .rstdec_x   (rstdec_x), 
   .d_psum       (d_psum), 
   .d_decdt      (d_decdt), 
   .d_hdtvh_dc_r (d_hdtvh_dc_r), 
   .d_dech_dt_r  (d_dech_dt_r)
); 

dc_htgct dc_htgct( 
   .clkdec      (clkdec), 
   .rstdec_x    (rstdec_x), 
   .p_hdtvh_dc_r  (p_hdtvh_dc_r), 
   .m_decyen_r    (m_decyen_r), 
   .m_deccen_r    (m_deccen_r), 
   .c_mbpl_dc_r_s (c_mbpl_dc_r_s), 
   .d_f_ff_enb_r  (d_f_ff_enb_r), 
   .d_b_ff_enb_r  (d_b_ff_enb_r), 
   .d_phase       (d_phase), 
   .d_c_slct_r      (d_c_slct_r), 
   .d_c1_slct_r     (d_c1_slct_r), 
   .d_decyen_r    (d_decyen_r), 
   .d_hdtvh_dc_r  (d_hdtvh_dc_r), 
   .d_dech_yen_r  (d_dech_yen_r), 
   .d_dech_cen_r  (d_dech_cen_r)
); 

dc_hxpnd dc_hxpnd( 
   .clkdec     (clkdec), 
   .rstdec_x   (rstdec_x), 
   .d_c1_slct_r    (d_c1_slct_r), 
   .m_decdt_r    (m_decdt_r), 
   .d_f_ff_enb_r (d_f_ff_enb_r), 
   .d_b_ff_enb_r (d_b_ff_enb_r), 
   .d_pix_0      (d_pix_0), 
   .d_pix_1      (d_pix_1), 
   .d_pix_2      (d_pix_2), 
   .d_pix_3      (d_pix_3), 
   .d_pix_4      (d_pix_4), 
   .d_pix_5      (d_pix_5), 
   .d_pix_6      (d_pix_6), 
   .d_pix_7      (d_pix_7), 
   .d_pix_8      (d_pix_8), 
   .d_pix_9      (d_pix_9), 
   .d_pix_a      (d_pix_a), 
   .d_pix_b      (d_pix_b), 
   .d_pix_c      (d_pix_c), 
   .d_pix_d      (d_pix_d), 
   .d_pix_e      (d_pix_e), 
   .d_pix_f      (d_pix_f), 
   .d_decdt      (d_decdt)
); 

endmodule

