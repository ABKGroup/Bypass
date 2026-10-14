// ----------------------------------------------
// File: dc_v.v
// Module: dc_v
// Function:
// ----------------------------------------------

module dc_v ( 
    clkdec, 
    rstdec_x, 
    c_mbpl_dc_r_s, 
    d_dech_cen_r, 
    d_dech_dt_r, 
    d_dech_yen_r, 
    p_hdtvh_dc_r, 
    w1_hsc00_q, 
    w1_hsc01_q, 
    w1_vsc00_q, 
    w1_vsc01_q, 
    v1_hsc00_a, 
    v1_hsc00_bs, 
    v1_hsc00_d, 
    v1_hsc00_we, 
    v1_hsc01_a, 
    v1_hsc01_bs, 
    v1_hsc01_d, 
    v1_hsc01_we, 
    v1_vsc00_a, 
    v1_vsc00_bs, 
    v1_vsc00_d, 
    v1_vsc00_we, 
    v1_vsc01_a, 
    v1_vsc01_bs, 
    v1_vsc01_d, 
    v1_vsc01_we, 
    d_decv_cen_r, 
    d_decv_dt_r, 
    d_decv_yen_r
);

input         clkdec;      
input         rstdec_x;    
input         c_mbpl_dc_r_s; 
input         d_dech_cen_r;  
input  [15:0] d_dech_dt_r;   
input         d_dech_yen_r;  
input         p_hdtvh_dc_r;  
input  [7:0]  w1_hsc00_q;      
input  [7:0]  w1_hsc01_q;      
input  [7:0]  w1_vsc00_q;      
input  [7:0]  w1_vsc01_q;      
output [4:0]  v1_hsc00_a;      
output        v1_hsc00_bs;     
output [7:0]  v1_hsc00_d;      
output        v1_hsc00_we;     
output [4:0]  v1_hsc01_a;      
output        v1_hsc01_bs;     
output [7:0]  v1_hsc01_d;      
output        v1_hsc01_we;     
output [5:0]  v1_vsc00_a;      
output        v1_vsc00_bs;     
output [7:0]  v1_vsc00_d;      
output        v1_vsc00_we;     
output [5:0]  v1_vsc01_a;      
output        v1_vsc01_bs;     
output [7:0]  v1_vsc01_d;      
output        v1_vsc01_we;     
output        d_decv_cen_r; 
output [15:0] d_decv_dt_r;  
output        d_decv_yen_r; 


wire         clkdec;      
wire         rstdec_x;    
wire         c_mbpl_dc_r_s; 
wire         d_dech_cen_r;  
wire [15:0]  d_dech_dt_r;   
wire         d_dech_yen_r;  
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

wire        d_hvmem_cen_r;  
wire        d_hvmem_yen_r;  
wire [15:0] d_sdtv_dout;    
wire        d_vflt_cen_r;   
wire [7:0]  d_vflt_din;     
wire [7:0]  d_vflt_dout;    
wire        d_vflt_yen_r;   


dc_hvscn dc_hvscn( 
    .clkdec         (clkdec), 
    .rstdec_x       (rstdec_x), 
    .d_dech_yen_r  (d_dech_yen_r), 
    .d_dech_cen_r  (d_dech_cen_r), 
    .c_mbpl_dc_r_s (c_mbpl_dc_r_s), 
    .d_dech_dt_r   (d_dech_dt_r), 
    .p_hdtvh_dc_r  (p_hdtvh_dc_r), 
    .w1_vsc00_q      (w1_vsc00_q), 
    .w1_vsc01_q      (w1_vsc01_q), 
    .v1_vsc00_a      (v1_vsc00_a), 
    .v1_vsc00_d      (v1_vsc00_d), 
    .v1_vsc00_bs     (v1_vsc00_bs), 
    .v1_vsc00_we     (v1_vsc00_we), 
    .v1_vsc01_a      (v1_vsc01_a), 
    .v1_vsc01_d      (v1_vsc01_d), 
    .v1_vsc01_bs     (v1_vsc01_bs), 
    .v1_vsc01_we     (v1_vsc01_we), 
    .d_hvmem_yen_r (d_hvmem_yen_r), 
    .d_hvmem_cen_r (d_hvmem_cen_r), 
    .d_sdtv_dout   (d_sdtv_dout), 
    .d_vflt_din    (d_vflt_din)
); 

dc_vhscn dc_vhscn( 
    .clkdec         (clkdec), 
    .rstdec_x       (rstdec_x), 
    .d_vflt_yen_r  (d_vflt_yen_r), 
    .d_vflt_cen_r  (d_vflt_cen_r), 
    .d_hvmem_yen_r (d_hvmem_yen_r), 
    .d_hvmem_cen_r (d_hvmem_cen_r), 
    .d_sdtv_dout   (d_sdtv_dout), 
    .c_mbpl_dc_r_s (c_mbpl_dc_r_s), 
    .d_vflt_dout   (d_vflt_dout), 
    .p_hdtvh_dc_r  (p_hdtvh_dc_r), 
    .w1_hsc00_q      (w1_hsc00_q), 
    .w1_hsc01_q      (w1_hsc01_q), 
    .v1_hsc00_a      (v1_hsc00_a), 
    .v1_hsc00_d      (v1_hsc00_d), 
    .v1_hsc00_bs     (v1_hsc00_bs), 
    .v1_hsc00_we     (v1_hsc00_we), 
    .v1_hsc01_a      (v1_hsc01_a), 
    .v1_hsc01_d      (v1_hsc01_d), 
    .v1_hsc01_bs     (v1_hsc01_bs), 
    .v1_hsc01_we     (v1_hsc01_we), 
    .d_decv_dt_r   (d_decv_dt_r), 
    .d_decv_yen_r  (d_decv_yen_r), 
    .d_decv_cen_r  (d_decv_cen_r)
); 

dc_vtflt dc_vtflt( 
    .clkdec         (clkdec), 
    .rstdec_x       (rstdec_x), 
    .c_mbpl_dc_r_s (c_mbpl_dc_r_s), 
    .d_hvmem_cen_r (d_hvmem_cen_r), 
    .d_hvmem_yen_r (d_hvmem_yen_r), 
    .d_vflt_din    (d_vflt_din), 
    .p_hdtvh_dc_r  (p_hdtvh_dc_r), 
    .d_vflt_cen_r  (d_vflt_cen_r), 
    .d_vflt_dout   (d_vflt_dout), 
    .d_vflt_yen_r  (d_vflt_yen_r)
); 

endmodule
