// ----------------------------------------------
// File: dctop.v
// Module: dctop
// Function: 
// ----------------------------------------------

module dctop ( 
    clkdec, 
    rstdec_x, 
    c_mbpl_dc_r_s, 
    m_deccen_r, 
    m_decdt_r, 
    m_decyen_r, 
    p_hdtvh_dc_r, 
    d_decv_cen_r, 
    d_decv_dt_r, 
    d_decv_yen_r
);


input         clkdec;      
input         rstdec_x;    
input         c_mbpl_dc_r_s; 
input         m_deccen_r;    
input  [15:0] m_decdt_r;     
input         m_decyen_r;    
input         p_hdtvh_dc_r;  
output        d_decv_cen_r;  
output [15:0] d_decv_dt_r;   
output        d_decv_yen_r;  

wire         clkdec;       
wire         rstdec_x;     
wire         c_mbpl_dc_r_s;  
wire         m_deccen_r;     
wire [15:0]  m_decdt_r;      
wire         m_decyen_r;     
wire         p_hdtvh_dc_r;   
wire [7:0]   w1_hsc00_q;       
wire [7:0]   w1_hsc01_q;       
wire [7:0]   w1_vsc00_q;       
wire [7:0]   w1_vsc01_q;       
wire [4:0]   v1_hsc00_a;       
wire         v1_hsc00_bs;      
wire [7:0]   v1_hsc00_d;       
wire         v1_hsc00_we;      
wire [4:0]   v1_hsc01_a;       
wire         v1_hsc01_bs;      
wire [7:0]   v1_hsc01_d;       
wire         v1_hsc01_we;      
wire [5:0]   v1_vsc00_a;       
wire         v1_vsc00_bs;      
wire [7:0]   v1_vsc00_d;       
wire         v1_vsc00_we;      
wire [5:0]   v1_vsc01_a;       
wire         v1_vsc01_bs;      
wire [7:0]   v1_vsc01_d;       
wire         v1_vsc01_we;      
wire         d_decv_cen_r;   
wire [15:0]  d_decv_dt_r;    
wire         d_decv_yen_r;   
wire        d_dech_cen_r; 
wire [15:0] d_dech_dt_r;  
wire        d_dech_yen_r; 


dc_h dc_h( 
    .clkdec        (clkdec), 
    .rstdec_x      (rstdec_x), 
    .c_mbpl_dc_r_s (c_mbpl_dc_r_s), 
    .m_deccen_r    (m_deccen_r), 
    .m_decdt_r     (m_decdt_r), 
    .m_decyen_r    (m_decyen_r), 
    .p_hdtvh_dc_r  (p_hdtvh_dc_r), 
    .d_dech_cen_r  (d_dech_cen_r), 
    .d_dech_dt_r   (d_dech_dt_r), 
    .d_dech_yen_r  (d_dech_yen_r)
); 

dc_v dc_v( 
    .clkdec          (clkdec), 
    .rstdec_x        (rstdec_x), 
    .c_mbpl_dc_r_s   (c_mbpl_dc_r_s), 
    .d_dech_cen_r    (d_dech_cen_r), 
    .d_dech_dt_r     (d_dech_dt_r), 
    .d_dech_yen_r    (d_dech_yen_r), 
    .p_hdtvh_dc_r    (p_hdtvh_dc_r), 
    .w1_hsc00_q      (w1_hsc00_q), 
    .w1_hsc01_q      (w1_hsc01_q), 
    .w1_vsc00_q      (w1_vsc00_q), 
    .w1_vsc01_q      (w1_vsc01_q), 
    .v1_hsc00_a      (v1_hsc00_a), 
    .v1_hsc00_bs     (v1_hsc00_bs), 
    .v1_hsc00_d      (v1_hsc00_d), 
    .v1_hsc00_we     (v1_hsc00_we), 
    .v1_hsc01_a      (v1_hsc01_a), 
    .v1_hsc01_bs     (v1_hsc01_bs), 
    .v1_hsc01_d      (v1_hsc01_d), 
    .v1_hsc01_we     (v1_hsc01_we), 
    .v1_vsc00_a      (v1_vsc00_a), 
    .v1_vsc00_bs     (v1_vsc00_bs), 
    .v1_vsc00_d      (v1_vsc00_d), 
    .v1_vsc00_we     (v1_vsc00_we), 
    .v1_vsc01_a      (v1_vsc01_a), 
    .v1_vsc01_bs     (v1_vsc01_bs), 
    .v1_vsc01_d      (v1_vsc01_d), 
    .v1_vsc01_we     (v1_vsc01_we), 
    .d_decv_cen_r    (d_decv_cen_r), 
    .d_decv_dt_r     (d_decv_dt_r), 
    .d_decv_yen_r    (d_decv_yen_r)
); 

dc_hscarray dchsc(
   .clkdec       (clkdec),
   .rstdec_x     (rstdec_x),
   .v1_hsc00_a   (v1_hsc00_a),
   .v1_hsc00_bs  (v1_hsc00_bs),
   .v1_hsc00_d   (v1_hsc00_d),
   .v1_hsc00_we  (v1_hsc00_we),
   .w1_hsc00_q   (w1_hsc00_q),
   .v1_hsc01_a   (v1_hsc01_a),
   .v1_hsc01_bs  (v1_hsc01_bs),
   .v1_hsc01_d   (v1_hsc01_d),
   .v1_hsc01_we  (v1_hsc01_we),
   .w1_hsc01_q   (w1_hsc01_q)
   );

dc_vscarray dcvsc(
   .clkdec       (clkdec),
   .rstdec_x     (rstdec_x),
   .v1_vsc00_a   (v1_vsc00_a),
   .v1_vsc00_bs  (v1_vsc00_bs),
   .v1_vsc00_d   (v1_vsc00_d),
   .v1_vsc00_we  (v1_vsc00_we),
   .w1_vsc00_q   (w1_vsc00_q),
   .v1_vsc01_a   (v1_vsc01_a),
   .v1_vsc01_bs  (v1_vsc01_bs),
   .v1_vsc01_d   (v1_vsc01_d),
   .v1_vsc01_we  (v1_vsc01_we),
   .w1_vsc01_q   (w1_vsc01_q)
   );

endmodule

