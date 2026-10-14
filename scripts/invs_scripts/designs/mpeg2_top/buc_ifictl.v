// ----------------------------------------------
// File: buc_ifictl.v
// Module: buc_ifictl
// Function:Inverse Quantization top module
// ----------------------------------------------

module buc_ifictl(
  clkdec,
  rstdec_x,  
  c_mbpl_buc_r_s,
  c_pcth_mb_r,
  c_pctv_mb_r,
  p_hdtvh_buc_r,
  p_prgseq_buc_r,
  p_pstr_buc_r,
  p_pred_forward_buc_r,
  p_pred_backward_buc_r,
  p_mttyp_buc_r,
  p_fldsel1_buc_r,
  p_fldsel2_buc_r,
  p_fldsel3_buc_r,
  p_fldsel4_buc_r,
  m_hvec1y_r,
  m_vvec1y_r,
  m_hvec2y_r,
  m_vvec2y_r,
  m_hvec3y_r,
  m_vvec3y_r,
  m_hvec4y_r,
  m_vvec4y_r,
  m_hvec1c_r,
  m_vvec1c_r,
  m_hvec2c_r,
  m_vvec2c_r,
  m_hvec3c_r,
  m_vvec3c_r,
  m_hvec4c_r,
  m_vvec4c_r,
  p_reffld_num1_buc_r,
  p_reffld_num2_buc_r,
  p_reffld_num3_buc_r,
  p_reffld_num4_buc_r,
  p_mbh_adr_buc_r,
  p_mbv_adr_buc_r,
  vrh_acceptance_r,
  f_bfcnt_init_r,  
  f_vec_err_r,
  f_request_r,
  f_field_num_r,
  f_addressx_r,
  f_addressy_r,
  f_byte_num_r,
  f_line_num_r,
  f_whdtvh_r,
  f_wprgseq_r,
  f_wpred_forward_buc_r,
  f_wpred_backward_buc_r,
  f_w2pred_forward_r,
  f_w2pred_backward_r,
  f_wmttyp_r,
  f_whvec1y_r,
  f_wvvec1y_r,
  f_whvec2y_r,
  f_wvvec2y_r,
  f_whvec3y_r,
  f_wvvec3y_r,
  f_whvec4y_r,
  f_wvvec4y_r,
  f_whvec1c_r,
  f_wvvec1c_r,
  f_whvec2c_r,
  f_wvvec2c_r,
  f_whvec3c_r,
  f_wvvec3c_r,
  f_whvec4c_r,
  f_wvvec4c_r,
  f_mbpl_buc_d1_r_s,
  f_regwen_r
  );
  
  input         clkdec;           
  input         rstdec_x;         
  input         c_mbpl_buc_r_s;     
  input [6:0]   c_pcth_mb_r;        
  input [6:0]   c_pctv_mb_r;        
  input         p_hdtvh_buc_r;      
  input         p_prgseq_buc_r;     
  input [1:0]   p_pstr_buc_r;       
  input         p_pred_forward_buc_r;
  input         p_pred_backward_buc_r;
  input [1:0]   p_mttyp_buc_r;     
  input         p_fldsel1_buc_r;   
  input         p_fldsel2_buc_r;   
  input         p_fldsel3_buc_r;   
  input         p_fldsel4_buc_r;   
  input [11:0]  m_hvec1y_r;        
  input [7:0]   m_vvec1y_r;        
  input [11:0]  m_hvec2y_r;        
  input [7:0]   m_vvec2y_r;        
  input [11:0]  m_hvec3y_r;        
  input [7:0]   m_vvec3y_r;        
  input [11:0]  m_hvec4y_r;        
  input [7:0]   m_vvec4y_r;        
  input [10:0]  m_hvec1c_r;        
  input [6:0]   m_vvec1c_r;        
  input [10:0]  m_hvec2c_r;          
  input [6:0]   m_vvec2c_r;          
  input [10:0]  m_hvec3c_r;          
  input [6:0]   m_vvec3c_r;          
  input [10:0]  m_hvec4c_r;          
  input [6:0]   m_vvec4c_r;          
  input [3:0]   p_reffld_num1_buc_r; 
  input [3:0]   p_reffld_num2_buc_r; 
  input [3:0]   p_reffld_num3_buc_r; 
  input [3:0]   p_reffld_num4_buc_r; 
  input [6:0]   p_mbh_adr_buc_r;     
  input [6:0]   p_mbv_adr_buc_r;     
  input         vrh_acceptance_r;      
  input         f_bfcnt_init_r;      
  output        f_vec_err_r;         
  output        f_request_r;         
  output [3:0]  f_field_num_r;       
  output [10:0] f_addressx_r;       
  output [9:0]  f_addressy_r;       
  output [1:0]  f_byte_num_r;       
  output [2:0]  f_line_num_r;       
  output        f_whdtvh_r;         
  output        f_wprgseq_r;        
  output        f_wpred_forward_buc_r;
  output        f_wpred_backward_buc_r;
  output        f_w2pred_forward_r;  
  output        f_w2pred_backward_r; 
  output [1:0]  f_wmttyp_r;          
  output [3:0]  f_whvec1y_r;         
  output [2:0]  f_wvvec1y_r;         
  output [3:0]  f_whvec2y_r;         
  output [2:0]  f_wvvec2y_r;        
  output [3:0]  f_whvec3y_r;        
  output [2:0]  f_wvvec3y_r;        
  output [3:0]  f_whvec4y_r;        
  output [2:0]  f_wvvec4y_r;       
  output [2:0]  f_whvec1c_r;       
  output [1:0]  f_wvvec1c_r;       
  output [2:0]  f_whvec2c_r;       
  output [1:0]  f_wvvec2c_r;       
  output [2:0]  f_whvec3c_r;       
  output [1:0]  f_wvvec3c_r;       
  output [2:0]  f_whvec4c_r;       
  output [1:0]  f_wvvec4c_r;       
  output        f_mbpl_buc_d1_r_s; 
  output        f_regwen_r;        
  
  wire          clkdec;       
  wire          rstdec_x;     
  wire          c_mbpl_buc_r_s;       // MB Pulse(SDRAM Read Phase)
  wire [6:0]    c_pcth_mb_r;          // Display Horizontal MB Number
  wire [6:0]    c_pctv_mb_r;          // Display Vertical MB Number
  wire          p_hdtvh_buc_r;        // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  wire          p_prgseq_buc_r;       // MB Interlace/Progressive Select[0:Interlace 1:Progressive]
  wire [1:0]    p_pstr_buc_r;         // Picture Stracture
  wire          p_pred_forward_buc_r; // MB Forward Estimate Valid Flag
  wire          p_pred_backward_buc_r;// MB Backward Estimate Valid Flag
  wire [1:0]    p_mttyp_buc_r;        // MB Estimate Mode
  wire          p_fldsel1_buc_r;      // Reference Field Select1
  wire          p_fldsel2_buc_r;      // Reference Field Select2
  wire          p_fldsel3_buc_r;      // Reference Field Select3
  wire          p_fldsel4_buc_r;      // Reference Field Select4
  wire [11:0]   m_hvec1y_r;           // Horizontal Vector1(Y)
  wire [7:0]    m_vvec1y_r;           // Vertical Vector1(Y)
  wire [11:0]   m_hvec2y_r;           // Horizontal Vector2(Y)
  wire [7:0]    m_vvec2y_r;           // Vertical Vector2(Y)
  wire [11:0]   m_hvec3y_r;           // Horizontal Vector3(Y)
  wire [7:0]    m_vvec3y_r;           // Vertical Vector3(Y)
  wire [11:0]   m_hvec4y_r;           // Horizontal Vector4(Y)
  wire [7:0]    m_vvec4y_r;           // Vertical Vector4(Y)
  wire [10:0]   m_hvec1c_r;           // Horizontal Vector1(C)
  wire [6:0]    m_vvec1c_r;           // Vertical Vector1(C)
  wire [10:0]   m_hvec2c_r;           // Horizontal Vector2(C)
  wire [6:0]    m_vvec2c_r;           // Vertical Vector2(C)
  wire [10:0]   m_hvec3c_r;           // Horizontal Vector3(C)
  wire [6:0]    m_vvec3c_r;           // Vertical Vector3(C)
  wire [10:0]   m_hvec4c_r;           // Horizontal Vector4(C)
  wire [6:0]    m_vvec4c_r;           // Vertical Vector4(C)
  wire [3:0]    p_reffld_num1_buc_r;  // Reference Field Number1
  wire [3:0]    p_reffld_num2_buc_r;  // Reference Field Number2
  wire [3:0]    p_reffld_num3_buc_r;  // Reference Field Number3
  wire [3:0]    p_reffld_num4_buc_r;  // Reference Field Number4
  wire [6:0]    p_mbh_adr_buc_r;      // MB Horizontal Address
  wire [6:0]    p_mbv_adr_buc_r;      // MB Vertical Address
  wire          vrh_acceptance_r;     // Request Permission
  wire          f_bfcnt_init_r;       // Buffer Control Reset Pulse
  
  wire [3:0]    f_fldnum_sel1;        // Selected Field Number By f_fldsel1_r
  wire [3:0]    f_fldnum_sel2;        // Selected Field Number By f_fldsel2_r
  wire [3:0]    f_fldnum_sel3;        // Selected Field Number By f_fldsel3_r
  wire [3:0]    f_fldnum_sel4;        // Selected Field Number By f_fldsel4_r
  wire [3:0]    f_fldnum_pstr2;       // Selected Field Number By f_pstr_r == 2h
  wire [3:0]    f_fldnum_pstr1;       // Selected Field Number By f_pstr_r == 1h
  wire          f_fb_sel;             // ~f_wpred_forward_buc_r & f_wpred_backward_buc_r
  wire [3:0]    f_fldnum_fb1;         // Selected Field Number By forward/backward
  wire [3:0]    f_fldnum_fb2;         // Selected Field Number By forward/backward
  wire [3:0]    f_fldnum_fb3;         // Selected Field Number By forward/backward
  wire [3:0]    f_fldnum_fb4;         // Selected Field Number By forward/backward
  wire [3:0]    f_fldnum_fb5;         // Selected Field Number By forward/backward
  wire [11:0]   f_had1y;              // Horizontal Address1(Y)
  wire [11:0]   f_had2y;              // Horizontal Address2(Y)
  wire [11:0]   f_had3y;              // Horizontal Address3(Y)
  wire [11:0]   f_had4y;              // Horizontal Address4(Y)
  wire [10:0]   f_had1c;              // Horizontal Address1(C)
  wire [10:0]   f_had2c;              // Horizontal Address2(C)
  wire [10:0]   f_had3c;              // Horizontal Address3(C)
  wire [10:0]   f_had4c;              // Horizontal Address4(C)
  wire          f_had1_uf;            // Horizontal Address1(Y/C) Underflow
  wire          f_had2_uf;            // Horizontal Address2(Y/C) Underflow
  wire          f_had3_uf;            // Horizontal Address3(Y/C) Underflow
  wire          f_had4_uf;            // Horizontal Address4(Y/C) Underflow
  wire          f_had1_of;            // Horizontal Address1(Y/C) Overflow
  wire          f_had2_of;            // Horizontal Address2(Y/C) Overflow
  wire          f_had3_of;            // Horizontal Address3(Y/C) Overflow
  wire          f_had4_of;            // Horizontal Address4(Y/C) Overflow
  wire [10:0]   f_mbv_sl_adry;        // Selected Vertical MB Address(Y)
  wire [9:0]    f_mbv_sl_adrc;        // Selected Vertical MB Address(C)
  wire [11:0]   f_vad1y;              // Vertical Address1(Y)
  wire [11:0]   f_vad2y;              // Vertical Address2(Y)
  wire [11:0]   f_vad3y;              // Vertical Address3(Y)
  wire [11:0]   f_vad4y;              // Vertical Address4(Y)
  wire [10:0]   f_vad1c;              // Vertical Address1(Y)
  wire [10:0]   f_vad2c;              // Vertical Address2(Y)
  wire [10:0]   f_vad3c;              // Vertical Address3(Y)
  wire [10:0]   f_vad4c;              // Vertical Address4(Y)
  wire [11:0]   f_vad2y_pl;           // Vertical Address2(Y)
  wire [11:0]   f_vad4y_pl;           // Vertical Address4(Y)
  wire [10:0]   f_vad2c_pl;           // Vertical Address2(Y)
  wire [10:0]   f_vad4c_pl;           // Vertical Address4(Y)
  wire          f_vad1_uf;            // Vertical Address1(Y/C) Underflow
  wire          f_vad2_uf;            // Vertical Address2(Y/C) Underflow
  wire          f_vad3_uf;            // Vertical Address3(Y/C) Underflow
  wire          f_vad4_uf;            // Vertical Address4(Y/C) Underflow
  wire          f_vad1_of;            // Vertical Address1(Y/C) Overflow
  wire          f_vad2_of;            // Vertical Address1(Y/C) Overflow
  wire          f_vad3_of;            // Vertical Address1(Y/C) Overflow
  wire          f_vad4_of;            // Vertical Address1(Y/C) Overflow
  wire          f_acc;                // Request Permission
  wire          f_req_s;              // f_acceptance Posedge
  wire [10:0]   f_vad2_org_pl;        // Vertical Address Screen out of Range
  wire          f_ifsel1_gt;          // f_ifsel_r[1] Gating
  wire          f_vec3_ey_sel;        // Selected Vector Error for h/vvector Y-3
  wire          f_vec3_ec_sel;        // Selected Vector Error for h/vvector C-3
  wire          f_vec4_ey_sel;        // Selected Vector Error for h/vvector Y-3
  wire          f_vec4_ec_sel;        // Selected Vector Error for h/vvector C-3
  wire          f_vec1_err;           // Vector Error1
  wire          f_vec2_err;           // Vector Error2
  wire          f_vec3_err;           // Vector Error3
  wire          f_vec4_err;           // Vector Error4
  wire          f_ifsel_dc0;          // f_ifsel_r decode(0h)
  
  reg           f_vec_err_r;          // Vector Error
  reg           f_request_r;          // I/F Read Request
  reg [3:0]     f_field_num_r;        // Field Number
  reg [10:0]    f_addressx_r;         // Field Horizontal Address
  reg [9:0]     f_addressy_r;         // Field Vertical Address
  reg [1:0]     f_byte_num_r;         // Byte Number/1 Line
  reg [2:0]     f_line_num_r;         // Line Number/1 Block
  reg           f_whdtvh_r;           // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  reg           f_wprgseq_r;          // MB Interlace/Progressive Select[0:Interlace 1:Progressive]
  reg           f_wpred_forward_buc_r;// MB Forward Estimate Valid Flag
  reg           f_wpred_backward_buc_r;// MB Backward Estimate Valid Flag
  reg           f_w2pred_forward_r;   // MB Forward Estimate Valid Flag
  reg           f_w2pred_backward_r;  // MB Backward Estimate Valid Flag
  reg [1:0]     f_wmttyp_r;           // MB Estimate Mode
  reg [3:0]     f_whvec1y_r;          // Horizontal Vector1(Y)
  reg [2:0]     f_wvvec1y_r;          // Vertical Vector1(Y)
  reg [3:0]     f_whvec2y_r;          // Horizontal Vector2(Y)
  reg [2:0]     f_wvvec2y_r;          // Vertical Vector2(Y)
  reg [3:0]     f_whvec3y_r;          // Horizontal Vector3(Y)
  reg [2:0]     f_wvvec3y_r;          // Vertical Vector3(Y)
  reg [3:0]     f_whvec4y_r;          // Horizontal Vector4(Y)
  reg [2:0]     f_wvvec4y_r;          // Vertical Vector4(Y)
  reg [2:0]     f_whvec1c_r;          // Horizontal Vector1(C)
  reg [1:0]     f_wvvec1c_r;          // Vertical Vector1(C)
  reg [2:0]     f_whvec2c_r;          // Horizontal Vector2(C)
  reg [1:0]     f_wvvec2c_r;          // Vertical Vector2(C)
  reg [2:0]     f_whvec3c_r;          // Horizontal Vector3(C)
  reg [1:0]     f_wvvec3c_r;          // Vertical Vector3(C)
  reg [2:0]     f_whvec4c_r;          // Horizontal Vector4(C)
  reg [1:0]     f_wvvec4c_r;          // Vertical Vector4(C)  
  reg           f_mbpl_buc_d1_r_s;    // MB Pulse
  reg           f_regwen_r;           // 3-Stage Register Enable
  
  reg           f_pmbpl_buc_r_s;      // MB Pulse
  reg           f_mbpl_buc_r_s;       // MB Pulse
  reg [6:0]     f_disph_mb_buc_r;     // Display Horizontal MB Number
  reg [6:0]     f_dispv_mb_buc_r;     // Display Vertical MB Number
  reg           f_hdtvh_buc_r;        // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  reg           f_prgseq_buc_r;       // MB Interlace/Progressive Select[0:Interlace 1:Progressive]
  reg [1:0]     f_pstr_buc_r;         // Picture Stracture
  reg           f_pred_forward_buc_r; // MB Forward Estimate Valid Flag
  reg           f_pred_backward_buc_r;// MB Backward Estimate Valid Flag
  reg [1:0]     f_mttyp_buc_r;        // MB Estimate Mode
  reg           f_fldsel1_buc_r;      // Reference Field Select1
  reg           f_fldsel2_buc_r;      // Reference Field Select2
  reg           f_fldsel3_buc_r;      // Reference Field Select3
  reg           f_fldsel4_buc_r;      // Reference Field Select4
  reg [11:0]    f_hvc1y_r;            // Horizontal Vector1(Y)
  reg [7:0]     f_vvc1y_r;            // Vertical Vector1(Y)
  reg [11:0]    f_hvc2y_r;            // Horizontal Vector2(Y)
  reg [7:0]     f_vvc2y_r;            // Vertical Vector2(Y)
  reg [11:0]    f_hvc3y_r;            // Horizontal Vector3(Y)
  reg [7:0]     f_vvc3y_r;            // Vertical Vector3(Y)
  reg [11:0]    f_hvc4y_r;            // Horizontal Vector4(Y)
  reg [7:0]     f_vvc4y_r;            // Vertical Vector4(Y)
  reg [10:0]    f_hvc1c_r;            // Horizontal Vector1(C)
  reg [6:0]     f_vvc1c_r;            // Vertical Vector1(C)
  reg [10:0]    f_hvc2c_r;            // Horizontal Vector2(C)
  reg [6:0]     f_vvc2c_r;            // Vertical Vector2(C)
  reg [10:0]    f_hvc3c_r;            // Horizontal Vector3(C)
  reg [6:0]     f_vvc3c_r;            // Vertical Vector3(C)
  reg [10:0]    f_hvc4c_r;            // Horizontal Vector4(C)
  reg [6:0]     f_vvc4c_r;            // Vertical Vector4(C)
  reg [3:0]     f_reffld_num1_buc_r;  // Reference Field Number1
  reg [3:0]     f_reffld_num2_buc_r;  // Reference Field Number2
  reg [3:0]     f_reffld_num3_buc_r;  // Reference Field Number3
  reg [3:0]     f_reffld_num4_buc_r;  // Reference Field Number4
  reg [6:0]     f_mbh_adr_buc_r;      // MB Horizontal Address
  reg [6:0]     f_mbv_adr_buc_r;      // MB Vertical Address
  reg [6:0]     f_disph_mb_r;         // Display Horizontal MB Number
  reg [6:0]     f_dispv_mb_r;         // Display Vertical MB Number
  reg [1:0]     f_pstr_r;             // Picture Stracture
  reg           f_fldsel1_r;          // Reference Field Select1
  reg           f_fldsel2_r;          // Reference Field Select2
  reg           f_fldsel3_r;          // Reference Field Select3
  reg           f_fldsel4_r;          // Reference Field Select4
  reg [11:0]    f_hv1y_r;             // Horizontal Vector1(Y)
  reg [7:0]     f_vv1y_r;             // Vertical Vector1(Y)
  reg [11:0]    f_hv2y_r;             // Horizontal Vector2(Y)
  reg [7:0]     f_vv2y_r;             // Vertical Vector2(Y)
  reg [11:0]    f_hv3y_r;             // Horizontal Vector3(Y)
  reg [7:0]     f_vv3y_r;             // Vertical Vector3(Y)
  reg [11:0]    f_hv4y_r;             // Horizontal Vector4(Y)
  reg [7:0]     f_vv4y_r;             // Vertical Vector4(Y)
  reg [10:0]    f_hv1c_r;             // Horizontal Vector1(C)
  reg [6:0]     f_vv1c_r;             // Vertical Vector1(C)
  reg [10:0]    f_hv2c_r;             // Horizontal Vector2(C)
  reg [6:0]     f_vv2c_r;             // Vertical Vector2(C)
  reg [10:0]    f_hv3c_r;             // Horizontal Vector3(C)
  reg [6:0]     f_vv3c_r;             // Vertical Vector3(C)
  reg [10:0]    f_hv4c_r;             // Horizontal Vector4(C)
  reg [6:0]     f_vv4c_r;             // Vertical Vector4(C)
  reg [3:0]     f_fld_num1_r;         // Reference Field Number1
  reg [3:0]     f_fld_num2_r;         // Reference Field Number2
  reg [3:0]     f_fld_num3_r;         // Reference Field Number3
  reg [3:0]     f_fld_num4_r;         // Reference Field Number4
  reg [6:0]     f_mbh_adr_r;          // MB Horizontal Address
  reg [6:0]     f_mbv_adr_r;          // MB Vertical Address
  reg [10:0]    f_disph_r;            // Dislay Horizontal Size
  reg [9:0]     f_dispv_r;            // Dislay Horizontal Size
  reg [3:0]     f_fld00_r;            // Field Number1 at Field Stracture
  reg [3:0]     f_fld01_r;            // Field Number1 at Frame Stracture
  reg [3:0]     f_fld10_r;            // Field Number2 at Field Stracture
  reg [3:0]     f_fld11_r;            // Field Number2 at Frame Stracture
  reg [3:0]     f_fld20_r;            // Field Number3 at Field Stracture
  reg [3:0]     f_fld21_r;            // Field Number3 at Frame Stracture
  reg [3:0]     f_fld30_r;            // Field Number4 at Field Stracture
  reg [3:0]     f_fld31_r;            // Field Number4 at Frame Stracture
  reg [3:0]     f_fnum0_r;            // Output Field1
  reg [3:0]     f_fnum1_r;            // Output Field2
  reg [3:0]     f_fnum2_r;            // Output Field3
  reg [3:0]     f_fnum3_r;            // Output Field4
  reg [11:0]    f_hadr1y_r;           // Horizontal Address1(Y)
  reg [11:0]    f_hadr2y_r;           // Horizontal Address2(Y)
  reg [11:0]    f_hadr3y_r;           // Horizontal Address3(Y)
  reg [11:0]    f_hadr4y_r;           // Horizontal Address4(Y)
  reg [11:0]    f_hadr1c_r;           // Horizontal Address1(C)
  reg [11:0]    f_hadr2c_r;           // Horizontal Address2(C)
  reg [11:0]    f_hadr3c_r;           // Horizontal Address3(C)
  reg [11:0]    f_hadr4c_r;           // Horizontal Address4(C)
  reg [11:0]    f_hadr1yc_r;          // Horizontal Address1(Y/C)
  reg [11:0]    f_hadr2yc_r;          // Horizontal Address2(Y/C)
  reg [11:0]    f_hadr3yc_r;          // Horizontal Address3(Y/C)
  reg [11:0]    f_hadr4yc_r;          // Horizontal Address4(Y/C)
  reg [10:0]    f_phadr1_r;           // Horizontal Address1(Y/C)
  reg [10:0]    f_phadr2_r;           // Horizontal Address2(Y/C)
  reg [10:0]    f_phadr3_r;           // Horizontal Address3(Y/C)
  reg [10:0]    f_phadr4_r;           // Horizontal Address4(Y/C)
  reg [10:0]    f_hadr1_r;            // Horizontal Address1(Y/C)
  reg [10:0]    f_hadr2_r;            // Horizontal Address2(Y/C)
  reg [10:0]    f_hadr3_r;            // Horizontal Address3(Y/C)
  reg [10:0]    f_hadr4_r;            // Horizontal Address4(Y/C)
  reg [10:0]    f_vadr1y_r;           // Vertical Address1(Y)
  reg [10:0]    f_vadr2y_r;           // Vertical Address2(Y)
  reg [10:0]    f_vadr3y_r;           // Vertical Address3(Y)
  reg [10:0]    f_vadr4y_r;           // Vertical Address4(Y)
  reg [10:0]    f_vadr1c_r;           // Vertical Address1(C)
  reg [10:0]    f_vadr2c_r;           // Vertical Address2(C)
  reg [10:0]    f_vadr3c_r;           // Vertical Address3(C)
  reg [10:0]    f_vadr4c_r;           // Vertical Address4(C)
  reg [10:0]    f_vadr1yc_r;          // Vertical Address1(Y/C)
  reg [10:0]    f_vadr2yc_r;          // Vertical Address2(Y/C)
  reg [10:0]    f_vadr3yc_r;          // Vertical Address3(Y/C)
  reg [10:0]    f_vadr4yc_r;          // Vertical Address4(Y/C)
  reg [9:0]     f_pvadr1_r;           // Vertical Address1(Y/C)
  reg [9:0]     f_pvadr2_r;           // Vertical Address2(Y/C)
  reg [9:0]     f_pvadr3_r;           // Vertical Address3(Y/C)
  reg [9:0]     f_pvadr4_r;           // Vertical Address4(Y/C)
  reg [9:0]     f_vadr1_r;            // Vertical Address1(Y/C)
  reg [9:0]     f_vadr2_r;            // Vertical Address2(Y/C)
  reg [9:0]     f_vadr3_r;            // Vertical Address3(Y/C)
  reg [9:0]     f_vadr4_r;            // Vertical Address4(Y/C)
  reg           f_vec1_err_r;         // Vertical Address1 Error
  reg           f_vec2_err_r;         // Vertical Address2 Error
  reg           f_vec3_err_r;         // Vertical Address3 Error
  reg           f_vec4_err_r;         // Vertical Address4 Error
  reg [3:0]     f_req_cnt_r;          // I/F Read Request Counter
  reg           f_req_cnt_ld3_r;      // I/F Read Request Counter Load(3h)
  reg           f_req_cnt_ld7_r;      // I/F Read Request Counter Load(7h)
  reg [2:0]     f_recnt_dc_r;         // I/F Read Request Counter not equal fh
  reg           f_acceptance_r;       // Request Permission
  reg           f_acc_d1_r;           // f_acc 1CLK Delay
  reg [1:0]     f_ifsel_r;            // I/F Output Parameter Select
  reg [10:0]    f_hadr_org_r;         // Horizontal Address Screen Out of Range
  reg [9:0]     f_vadr_org1_r;        // Vertical Address1 Screen Out of Range
  reg [9:0]     f_vadr_org2_r;        // Vertical Address2 Screen Out of Range
  reg           f_vec1_ey_r;          // Vector Error Y-1
  reg           f_vec1_ec_r;          // Vector Error C-1
  reg           f_vec2_ey_r;          // Vector Error Y-2
  reg           f_vec2_ec_r;          // Vector Error C-2
  reg           f_vec3_ey_r;          // Vector Error Y-3
  reg           f_vec3_ec_r;          // Vector Error C-3
  reg           f_vec4_ey_r;          // Vector Error Y-4
  reg           f_vec4_ec_r;          // Vector Error C-4
  reg           f_regwen_f1_r;        // 3-Stage Register Enable
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_pmbpl_buc_r_s       <= 1'b0;
      f_mbpl_buc_r_s        <= 1'b0;
      f_mbpl_buc_d1_r_s     <= 1'b0;
      f_disph_mb_buc_r      <= 7'h00;
      f_dispv_mb_buc_r      <= 7'h00;
      f_hdtvh_buc_r         <= 1'b0;
      f_prgseq_buc_r        <= 1'b0;
      f_pstr_buc_r          <= 2'h0;
      f_pred_forward_buc_r  <= 1'b0;
      f_pred_backward_buc_r <= 1'b0;
      f_mttyp_buc_r         <= 2'h0;
      f_fldsel1_buc_r       <= 1'b0;
      f_fldsel2_buc_r       <= 1'b0;
      f_fldsel3_buc_r       <= 1'b0;
      f_fldsel4_buc_r       <= 1'b0;
      f_hvc1y_r             <= 12'h000;
      f_vvc1y_r             <= 8'h00;
      f_hvc2y_r             <= 12'h000;
      f_vvc2y_r             <= 8'h00;
      f_hvc3y_r             <= 12'h000;
      f_vvc3y_r             <= 8'h00;
      f_hvc4y_r             <= 12'h000;
      f_vvc4y_r             <= 8'h00;
      f_hvc1c_r             <= 11'h000;
      f_vvc1c_r             <= 7'h00;
      f_hvc2c_r             <= 11'h000;
      f_vvc2c_r             <= 7'h00;
      f_hvc3c_r             <= 11'h000;
      f_vvc3c_r             <= 7'h00;
      f_hvc4c_r             <= 11'h000;
      f_vvc4c_r             <= 7'h00;
      f_reffld_num1_buc_r   <= 4'h0;
      f_reffld_num2_buc_r   <= 4'h0;
      f_reffld_num3_buc_r   <= 4'h0;
      f_reffld_num4_buc_r   <= 4'h0;
      f_mbh_adr_buc_r       <= 7'h00;
      f_mbv_adr_buc_r       <= 7'h00;
    end
    else begin
      f_pmbpl_buc_r_s       <= c_mbpl_buc_r_s;
      f_mbpl_buc_r_s        <= f_pmbpl_buc_r_s;
      f_mbpl_buc_d1_r_s     <= f_mbpl_buc_r_s;
      f_disph_mb_buc_r      <= c_pcth_mb_r;
      f_dispv_mb_buc_r      <= c_pctv_mb_r;
      f_hdtvh_buc_r         <= p_hdtvh_buc_r;
      f_prgseq_buc_r        <= p_prgseq_buc_r;
      f_pstr_buc_r          <= p_pstr_buc_r;
      f_pred_forward_buc_r  <= p_pred_forward_buc_r;
      f_pred_backward_buc_r <= p_pred_backward_buc_r;
      f_mttyp_buc_r         <= p_mttyp_buc_r;
      f_fldsel1_buc_r       <= p_fldsel1_buc_r;
      f_fldsel2_buc_r       <= p_fldsel2_buc_r;
      f_fldsel3_buc_r       <= p_fldsel3_buc_r;
      f_fldsel4_buc_r       <= p_fldsel4_buc_r;
      f_hvc1y_r             <= m_hvec1y_r;
      f_vvc1y_r             <= m_vvec1y_r;
      f_hvc2y_r             <= m_hvec2y_r;
      f_vvc2y_r             <= m_vvec2y_r;
      f_hvc3y_r             <= m_hvec3y_r;
      f_vvc3y_r             <= m_vvec3y_r;
      f_hvc4y_r             <= m_hvec4y_r;
      f_vvc4y_r             <= m_vvec4y_r;
      f_hvc1c_r             <= m_hvec1c_r;
      f_vvc1c_r             <= m_vvec1c_r;
      f_hvc2c_r             <= m_hvec2c_r;
      f_vvc2c_r             <= m_vvec2c_r;
      f_hvc3c_r             <= m_hvec3c_r;
      f_vvc3c_r             <= m_vvec3c_r;
      f_hvc4c_r             <= m_hvec4c_r;
      f_vvc4c_r             <= m_vvec4c_r;
      f_reffld_num1_buc_r   <= p_reffld_num1_buc_r;
      f_reffld_num2_buc_r   <= p_reffld_num2_buc_r;
      f_reffld_num3_buc_r   <= p_reffld_num3_buc_r;
      f_reffld_num4_buc_r   <= p_reffld_num4_buc_r;
      f_mbh_adr_buc_r       <= p_mbh_adr_buc_r;
      f_mbv_adr_buc_r       <= p_mbv_adr_buc_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_disph_mb_r           <= 7'h00;
      f_dispv_mb_r           <= 7'h00;
      f_whdtvh_r             <= 1'b0;
      f_wprgseq_r            <= 1'b0;
      f_pstr_r               <= 2'h0;
      f_wpred_forward_buc_r  <= 1'b0;
      f_wpred_backward_buc_r <= 1'b0;
      f_w2pred_forward_r     <= 1'b0;
      f_w2pred_backward_r    <= 1'b0;
      f_wmttyp_r             <= 2'h0;
      f_fldsel1_r            <= 1'b0;
      f_fldsel2_r            <= 1'b0;
      f_fldsel3_r            <= 1'b0;
      f_fldsel4_r            <= 1'b0;
      f_hv1y_r               <= 12'h000;
      f_vv1y_r               <= 8'h00;
      f_hv2y_r               <= 12'h000;
      f_vv2y_r               <= 8'h00;
      f_hv3y_r               <= 12'h000;
      f_vv3y_r               <= 8'h00;
      f_hv4y_r               <= 12'h000;
      f_vv4y_r               <= 8'h00;
      f_hv1c_r               <= 11'h000;
      f_vv1c_r               <= 7'h00;
      f_hv2c_r               <= 11'h000;
      f_vv2c_r               <= 7'h00;
      f_hv3c_r               <= 11'h000;
      f_vv3c_r               <= 7'h00;
      f_hv4c_r               <= 11'h000;
      f_vv4c_r               <= 7'h00;
      f_fld_num1_r           <= 4'h0;
      f_fld_num2_r           <= 4'h0;
      f_fld_num3_r           <= 4'h0;
      f_fld_num4_r           <= 4'h0;
      f_mbh_adr_r            <= 7'h00;
      f_mbv_adr_r            <= 7'h00;
    end
    else if ( f_mbpl_buc_r_s ) begin
      f_disph_mb_r           <= f_disph_mb_buc_r;
      f_dispv_mb_r           <= f_dispv_mb_buc_r;
      f_whdtvh_r             <= f_hdtvh_buc_r;
      f_wprgseq_r            <= f_prgseq_buc_r;
      f_pstr_r               <= f_pstr_buc_r;
      f_wpred_forward_buc_r  <= f_pred_forward_buc_r;
      f_wpred_backward_buc_r <= f_pred_backward_buc_r;
      f_w2pred_forward_r     <= f_wpred_forward_buc_r;
      f_w2pred_backward_r    <= f_wpred_backward_buc_r;
      f_wmttyp_r             <= f_mttyp_buc_r;
      f_fldsel1_r            <= f_fldsel1_buc_r;
      f_fldsel2_r            <= f_fldsel2_buc_r;
      f_fldsel3_r            <= f_fldsel3_buc_r;
      f_fldsel4_r            <= f_fldsel4_buc_r;
      f_hv1y_r               <= f_hvc1y_r;
      f_vv1y_r               <= f_vvc1y_r;
      f_hv2y_r               <= f_hvc2y_r;
      f_vv2y_r               <= f_vvc2y_r;
      f_hv3y_r               <= f_hvc3y_r;
      f_vv3y_r               <= f_vvc3y_r;
      f_hv4y_r               <= f_hvc4y_r;
      f_vv4y_r               <= f_vvc4y_r;
      f_hv1c_r               <= f_hvc1c_r;
      f_vv1c_r               <= f_vvc1c_r;
      f_hv2c_r               <= f_hvc2c_r;
      f_vv2c_r               <= f_vvc2c_r;
      f_hv3c_r               <= f_hvc3c_r;
      f_vv3c_r               <= f_vvc3c_r;
      f_hv4c_r               <= f_hvc4c_r;
      f_vv4c_r               <= f_vvc4c_r;
      f_fld_num1_r           <= f_reffld_num1_buc_r;
      f_fld_num2_r           <= f_reffld_num2_buc_r;
      f_fld_num3_r           <= f_reffld_num3_buc_r;
      f_fld_num4_r           <= f_reffld_num4_buc_r;
      f_mbh_adr_r            <= f_mbh_adr_buc_r;
      f_mbv_adr_r            <= f_mbv_adr_buc_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_disph_r <= 11'h00;
    end
    else begin
      f_disph_r <= {f_disph_mb_r,4'h0} - 5'h10;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_dispv_r <= 10'h000;
    end
    else if ( f_pstr_r != 2'h3 ) begin
      f_dispv_r <= {f_dispv_mb_r[5:0],4'h0} - 5'h10;
    end
    else begin
      f_dispv_r <= {f_dispv_mb_r,3'h0} - 4'h8;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_whvec1y_r <= 4'h0;
      f_wvvec1y_r <= 3'h0;
      f_whvec2y_r <= 4'h0;
      f_wvvec2y_r <= 3'h0;
      f_whvec3y_r <= 4'h0;
      f_wvvec3y_r <= 3'h0;
      f_whvec4y_r <= 4'h0;
      f_wvvec4y_r <= 3'h0;
      f_whvec1c_r <= 3'h0;
      f_wvvec1c_r <= 2'h0;
      f_whvec2c_r <= 3'h0;
      f_wvvec2c_r <= 2'h0;
      f_whvec3c_r <= 3'h0;
      f_wvvec3c_r <= 2'h0;
      f_whvec4c_r <= 3'h0;
      f_wvvec4c_r <= 2'h0;
    end
    else begin
      f_whvec1y_r <= {4{(~f_vec1_ey_r)}}   & f_hv1y_r[3:0];
      f_wvvec1y_r <= {3{(~f_vec1_ey_r)}}   & f_vv1y_r[2:0];
      f_whvec2y_r <= {4{(~f_vec2_ey_r)}}   & f_hv2y_r[3:0];
      f_wvvec2y_r <= {3{(~f_vec2_ey_r)}}   & f_vv2y_r[2:0];
      f_whvec3y_r <= {4{(~f_vec3_ey_sel)}} & f_hv3y_r[3:0];
      f_wvvec3y_r <= {3{(~f_vec3_ey_sel)}} & f_vv3y_r[2:0];
      f_whvec4y_r <= {4{(~f_vec4_ey_sel)}} & f_hv4y_r[3:0];
      f_wvvec4y_r <= {3{(~f_vec4_ey_sel)}} & f_vv4y_r[2:0];
      f_whvec1c_r <= {3{(~f_vec1_ec_r)}}   & f_hv1c_r[2:0];
      f_wvvec1c_r <= {2{(~f_vec1_ec_r)}}   & f_vv1c_r[1:0];
      f_whvec2c_r <= {3{(~f_vec2_ec_r)}}   & f_hv2c_r[2:0];
      f_wvvec2c_r <= {2{(~f_vec2_ec_r)}}   & f_vv2c_r[1:0];
      f_whvec3c_r <= {3{(~f_vec3_ec_sel)}} & f_hv3c_r[2:0];
      f_wvvec3c_r <= {2{(~f_vec3_ec_sel)}} & f_vv3c_r[1:0];
      f_whvec4c_r <= {3{(~f_vec4_ec_sel)}} & f_hv4c_r[2:0];
      f_wvvec4c_r <= {2{(~f_vec4_ec_sel)}} & f_vv4c_r[1:0];
    end
  end
  
  assign f_fldnum_sel1  = ( f_fldsel1_r ) ? f_fld_num2_r : f_fld_num1_r;
  assign f_fldnum_sel2  = ( f_fldsel2_r ) ? f_fld_num2_r : f_fld_num1_r;
  assign f_fldnum_sel3  = ( f_fldsel3_r ) ? f_fld_num4_r : f_fld_num3_r;
  assign f_fldnum_sel4  = ( f_fldsel4_r ) ? f_fld_num4_r : f_fld_num3_r;
  assign f_fldnum_pstr2 = ( f_pstr_r == 2'h2 ) ? f_fld_num2_r : f_fld_num1_r;
  assign f_fldnum_pstr1 = ( f_pstr_r == 2'h1 ) ? f_fld_num4_r : f_fld_num3_r;
  assign f_fb_sel       = (~f_wpred_forward_buc_r) & f_wpred_backward_buc_r;
  assign f_fldnum_fb1   = ( f_fb_sel ) ? f_fldnum_sel3 : f_fldnum_sel1;
  assign f_fldnum_fb2   = ( f_fb_sel ) ? f_fld_num3_r : f_fld_num1_r;
  assign f_fldnum_fb3   = ( f_fb_sel ) ? f_fldnum_sel4 : f_fldnum_sel2;
  assign f_fldnum_fb4   = ( f_fb_sel ) ? f_fld_num4_r : f_fld_num2_r;
  assign f_fldnum_fb5   = ( f_fb_sel ) ? f_fldnum_sel4 : f_fldnum_sel3;

  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_fld00_r <= 4'h0;
      f_fld01_r <= 4'h0;
      f_fld10_r <= 4'h0;
      f_fld11_r <= 4'h0;
      f_fld20_r <= 4'h0;
      f_fld21_r <= 4'h0;
      f_fld30_r <= 4'h0;
      f_fld31_r <= 4'h0;
    end
    else begin
      case ( f_wmttyp_r )
        2'h1 : begin
          f_fld00_r <= f_fldnum_fb1;
          f_fld01_r <= f_fldnum_fb1;
          f_fld10_r <= f_fldnum_fb1;
          f_fld11_r <= f_fldnum_fb3;
          f_fld20_r <= f_fldnum_sel3;
          f_fld21_r <= f_fldnum_sel3;
          f_fld30_r <= f_fldnum_fb5;
          f_fld31_r <= f_fldnum_sel4;
        end
        2'h2 : begin
          f_fld00_r <= f_fldnum_fb1;
          f_fld01_r <= f_fldnum_fb2;
          f_fld10_r <= f_fldnum_fb3;
          f_fld11_r <= f_fldnum_fb4;
          f_fld20_r <= f_fldnum_sel3;
          f_fld21_r <= f_fld_num3_r;
          f_fld30_r <= f_fldnum_fb5;
          f_fld31_r <= f_fld_num4_r;
        end
        2'h3 : begin
          f_fld00_r <= f_fldnum_pstr2;
          f_fld01_r <= f_fld_num1_r;
          f_fld10_r <= f_fldnum_pstr2;
          f_fld11_r <= f_fld_num2_r;
          f_fld20_r <= f_fldnum_pstr1;
          f_fld21_r <= f_fld_num2_r;
          f_fld30_r <= f_fldnum_pstr1;
          f_fld31_r <= f_fld_num1_r;
        end
        default : begin
          f_fld00_r <= 4'h0;
          f_fld01_r <= 4'h0;
          f_fld10_r <= 4'h0;
          f_fld11_r <= 4'h0;
          f_fld20_r <= 4'h0;
          f_fld21_r <= 4'h0;
          f_fld30_r <= 4'h0;
          f_fld31_r <= 4'h0;
        end
      endcase
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_fnum0_r <= 4'h0;
      f_fnum1_r <= 4'h0;
      f_fnum2_r <= 4'h0;
      f_fnum3_r <= 4'h0;
    end
    else if ( f_pstr_r == 2'h3 ) begin
      f_fnum0_r <= f_fld01_r;
      f_fnum1_r <= f_fld11_r;
      f_fnum2_r <= f_fld21_r;
      f_fnum3_r <= f_fld31_r;
    end
    else begin
      f_fnum0_r <= f_fld00_r;
      f_fnum1_r <= f_fld10_r;
      f_fnum2_r <= f_fld20_r;
      f_fnum3_r <= f_fld30_r;
    end
  end
  
  assign f_had1y = f_hv1y_r + {1'b0,f_mbh_adr_r,4'h0};
  assign f_had2y = f_hv2y_r + {1'b0,f_mbh_adr_r,4'h0};
  assign f_had3y = f_hv3y_r + {1'b0,f_mbh_adr_r,4'h0};
  assign f_had4y = f_hv4y_r + {1'b0,f_mbh_adr_r,4'h0};
  assign f_had1c = f_hv1c_r + {1'b0,f_mbh_adr_r,3'h0};
  assign f_had2c = f_hv2c_r + {1'b0,f_mbh_adr_r,3'h0};
  assign f_had3c = f_hv3c_r + {1'b0,f_mbh_adr_r,3'h0};
  assign f_had4c = f_hv4c_r + {1'b0,f_mbh_adr_r,3'h0};

  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_hadr1y_r <= 12'h000;
      f_hadr2y_r <= 12'h000;
      f_hadr3y_r <= 12'h000;
      f_hadr4y_r <= 12'h000;
      f_hadr1c_r <= 12'h000;
      f_hadr2c_r <= 12'h000;
      f_hadr3c_r <= 12'h000;
      f_hadr4c_r <= 12'h000;
      f_hadr_org_r <= 11'h00;
    end
    else begin
      f_hadr1y_r <= f_had1y;
      f_hadr2y_r <= f_had2y;
      f_hadr3y_r <= f_had3y;
      f_hadr4y_r <= f_had4y;
      f_hadr1c_r <= {f_had1c,1'b0};
      f_hadr2c_r <= {f_had2c,1'b0};
      f_hadr3c_r <= {f_had3c,1'b0};
      f_hadr4c_r <= {f_had4c,1'b0};
      f_hadr_org_r <= {f_mbh_adr_r,4'h0};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_hadr1yc_r <= 12'h000;
      f_hadr2yc_r <= 12'h000;
    end
    else if ( f_req_cnt_r[0] ) begin
      if( f_fb_sel ) begin
        f_hadr1yc_r <= f_hadr3y_r;
        f_hadr2yc_r <= f_hadr4y_r;
      end
      else begin
        f_hadr1yc_r <= f_hadr1y_r;
        f_hadr2yc_r <= f_hadr2y_r;
      end
    end
    else begin
      if( f_fb_sel ) begin
        f_hadr1yc_r <= f_hadr3c_r;
        f_hadr2yc_r <= f_hadr4c_r;
      end
      else begin
        f_hadr1yc_r <= f_hadr1c_r;
        f_hadr2yc_r <= f_hadr2c_r;
      end
    end
  end

  assign f_had1_uf = f_hadr1yc_r[11];
  assign f_had2_uf = f_hadr2yc_r[11];
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_hadr3yc_r <= 12'h000;
      f_hadr4yc_r <= 12'h000;
    end
    else if ( f_req_cnt_r[0] ) begin
      f_hadr3yc_r <= f_hadr3y_r;
      f_hadr4yc_r <= f_hadr4y_r;
    end
    else begin
      f_hadr3yc_r <= f_hadr3c_r;
      f_hadr4yc_r <= f_hadr4c_r;
    end
  end

  assign f_had3_uf = f_hadr3yc_r[11];
  assign f_had4_uf = f_hadr4yc_r[11];

  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_phadr1_r <= 11'h000;
      f_phadr2_r <= 11'h000;
      f_phadr3_r <= 11'h000;
      f_phadr4_r <= 11'h000;
    end
    else begin
      f_phadr1_r <= f_hadr1yc_r[10:0];
      f_phadr2_r <= f_hadr2yc_r[10:0];
      f_phadr3_r <= f_hadr3yc_r[10:0];
      f_phadr4_r <= f_hadr4yc_r[10:0];
    end
  end

  assign f_had1_of = ( f_disph_r < f_phadr1_r ) ;
  assign f_had2_of = ( f_disph_r < f_phadr2_r ) ;
  assign f_had3_of = ( f_disph_r < f_phadr3_r ) ;
  assign f_had4_of = ( f_disph_r < f_phadr4_r ) ;
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_hadr1_r <= 11'h000;
    end
    else if ( f_whdtvh_r ) begin
      if ( f_vec1_err ) begin
        f_hadr1_r <= {1'b0,f_hadr_org_r[10:1]};
      end
      else begin
        f_hadr1_r <= {1'b0,f_phadr1_r[10:4],3'h0};
      end
    end
    else begin
      if ( f_vec1_err ) begin
        f_hadr1_r <= f_hadr_org_r;
      end
      else begin
        f_hadr1_r <= f_phadr1_r;
      end
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_hadr2_r <= 11'h000;
    end
    else if ( f_whdtvh_r ) begin
      if ( f_vec2_err ) begin
        f_hadr2_r <= {1'b0,f_hadr_org_r[10:1]};
      end
      else begin
        f_hadr2_r <= {1'b0,f_phadr2_r[10:4],3'h0};
      end
    end
    else begin
      if ( f_vec2_err ) begin
        f_hadr2_r <= f_hadr_org_r;
      end
      else begin
        f_hadr2_r <= f_phadr2_r;
      end
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_hadr3_r <= 11'h000;
    end
    else if ( f_whdtvh_r ) begin
      if ( f_vec3_err ) begin
        f_hadr3_r <= {1'b0,f_hadr_org_r[10:1]};
      end
      else begin
        f_hadr3_r <= {1'b0,f_phadr3_r[10:4],3'h0};
      end
    end
    else begin
      if ( f_vec3_err ) begin
        f_hadr3_r <= f_hadr_org_r;
      end
      else begin
        f_hadr3_r <= f_phadr3_r;
      end
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_hadr4_r <= 11'h000;
    end
    else if ( f_whdtvh_r ) begin
      if ( f_vec4_err ) begin
        f_hadr4_r <= {1'b0,f_hadr_org_r[10:1]};
      end
      else begin
        f_hadr4_r <= {1'b0,f_phadr4_r[10:4],3'h0};
      end
    end
    else begin
      if ( f_vec4_err ) begin
        f_hadr4_r <= f_hadr_org_r;
      end
      else begin
        f_hadr4_r <= f_phadr4_r;
      end
    end
  end
  
  assign f_mbv_sl_adry = ( (f_pstr_r == 2'h1) || (f_pstr_r == 2'h2) ) ?
                           {f_mbv_adr_r,4'h0} : {1'b0,f_mbv_adr_r,3'h0};
  assign f_mbv_sl_adrc = ( (f_pstr_r == 2'h1) || (f_pstr_r == 2'h2) ) ?
                           {1'b0,f_mbv_adr_r,3'h0} : {2'h0,f_mbv_adr_r,2'h0};
  assign f_vad1y = {1'b0,f_mbv_sl_adry} + {{4{f_vv1y_r[7]}},f_vv1y_r};
  assign f_vad2y = {1'b0,f_mbv_sl_adry} + {{4{f_vv2y_r[7]}},f_vv2y_r};
  assign f_vad3y = {1'b0,f_mbv_sl_adry} + {{4{f_vv3y_r[7]}},f_vv3y_r};
  assign f_vad4y = {1'b0,f_mbv_sl_adry} + {{4{f_vv4y_r[7]}},f_vv4y_r};
  assign f_vad1c = {1'b0,f_mbv_sl_adrc} + {{4{f_vv1c_r[6]}},f_vv1c_r};
  assign f_vad2c = {1'b0,f_mbv_sl_adrc} + {{4{f_vv2c_r[6]}},f_vv2c_r};
  assign f_vad3c = {1'b0,f_mbv_sl_adrc} + {{4{f_vv3c_r[6]}},f_vv3c_r};
  assign f_vad4c = {1'b0,f_mbv_sl_adrc} + {{4{f_vv4c_r[6]}},f_vv4c_r};
  assign f_vad2y_pl = ( (f_pstr_r == 2'h1) || (f_pstr_r == 2'h2) ) ?
                        ( f_vad2y + 12'h008 ) : f_vad2y ;
  assign f_vad4y_pl = ( (f_pstr_r == 2'h1) || (f_pstr_r == 2'h2) ) ?
                        ( f_vad4y + 12'h008 ) : f_vad4y ;
  assign f_vad2c_pl = ( (f_pstr_r == 2'h1) || (f_pstr_r == 2'h2) ) ?
                        ( f_vad2c + 12'h004 ) : f_vad2c ;
  assign f_vad4c_pl = ( (f_pstr_r == 2'h1) || (f_pstr_r == 2'h2) ) ?
                        ( f_vad4c + 12'h004 ) : f_vad4c ;
  assign f_vad2_org_pl = ( (f_pstr_r == 2'h1) || (f_pstr_r == 2'h2) ) ?
                           ( f_mbv_sl_adry + 11'h008 ) : f_mbv_sl_adry ;

  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_vadr1y_r <= 11'h000;
      f_vadr2y_r <= 11'h000;
      f_vadr3y_r <= 11'h000;
      f_vadr4y_r <= 11'h000;
      f_vadr1c_r <= 11'h000;
      f_vadr2c_r <= 11'h000;
      f_vadr3c_r <= 11'h000;
      f_vadr4c_r <= 11'h000;
      f_vadr_org1_r <= 10'h000;
      f_vadr_org2_r <= 10'h000;
    end
    else begin
      f_vadr1y_r <= f_vad1y[10:0];
      f_vadr2y_r <= f_vad2y_pl[10:0];
      f_vadr3y_r <= f_vad3y[10:0];
      f_vadr4y_r <= f_vad4y_pl[10:0];
      f_vadr1c_r <= {f_vad1c[9:0],1'b0};
      f_vadr2c_r <= {f_vad2c_pl[9:0],1'b0};
      f_vadr3c_r <= {f_vad3c[9:0],1'b0};
      f_vadr4c_r <= {f_vad4c_pl[9:0],1'b0};
      f_vadr_org1_r <= f_mbv_sl_adry[9:0];
      f_vadr_org2_r <= f_vad2_org_pl[9:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_vadr1yc_r <= 11'h000;
      f_vadr2yc_r <= 11'h000;
    end
    else if ( f_req_cnt_r[0] ) begin
      if( f_fb_sel ) begin
        f_vadr1yc_r <= f_vadr3y_r;
        f_vadr2yc_r <= f_vadr4y_r;
      end
      else begin
        f_vadr1yc_r <= f_vadr1y_r;
        f_vadr2yc_r <= f_vadr2y_r;
      end
    end
    else begin
      if( f_fb_sel ) begin
        f_vadr1yc_r <= f_vadr3c_r;
        f_vadr2yc_r <= f_vadr4c_r;
      end
      else begin
        f_vadr1yc_r <= f_vadr1c_r;
        f_vadr2yc_r <= f_vadr2c_r;
      end
    end
  end

  assign f_vad1_uf  = f_vadr1yc_r[10];
  assign f_vad2_uf  = f_vadr2yc_r[10];
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_vadr3yc_r <= 11'h000;
      f_vadr4yc_r <= 11'h000;
    end
    else if ( f_req_cnt_r[0] ) begin
      f_vadr3yc_r <= f_vadr3y_r;
      f_vadr4yc_r <= f_vadr4y_r;
    end
    else begin
      f_vadr3yc_r <= f_vadr3c_r;
      f_vadr4yc_r <= f_vadr4c_r;
    end
  end

  assign f_vad3_uf  = f_vadr3yc_r[10];
  assign f_vad4_uf  = f_vadr4yc_r[10];
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_pvadr1_r <= 10'h000;
      f_pvadr2_r <= 10'h000;
      f_pvadr3_r <= 10'h000;
      f_pvadr4_r <= 10'h000;
    end
    else begin
      f_pvadr1_r <= f_vadr1yc_r[9:0];
      f_pvadr2_r <= f_vadr2yc_r[9:0];
      f_pvadr3_r <= f_vadr3yc_r[9:0];
      f_pvadr4_r <= f_vadr4yc_r[9:0];
    end
  end

  assign f_vad1_of = ( f_dispv_r < f_pvadr1_r );
  assign f_vad2_of = ( f_dispv_r < f_pvadr2_r );
  assign f_vad3_of = ( f_dispv_r < f_pvadr3_r );
  assign f_vad4_of = ( f_dispv_r < f_pvadr4_r );
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_vadr1_r <= 10'h000;
    end
    else if ( f_whdtvh_r ) begin
      if ( f_vec1_err ) begin
        if( f_req_cnt_r[0] ) begin
          f_vadr1_r <= {1'b0,f_vadr_org1_r[9:1]};
        end
        else begin
          f_vadr1_r <= {2'h0,f_vadr_org1_r[9:2]};
        end
      end
      else begin
        if( f_req_cnt_r[0] ) begin
          f_vadr1_r <= {1'b0,f_pvadr1_r[9:3],2'h0};
        end
        else begin
          f_vadr1_r <= {2'h0,f_pvadr1_r[9:3],1'b0};
        end
      end
    end
    else begin
      if ( f_vec1_err ) begin
        if ( f_req_cnt_r[0] ) begin
          f_vadr1_r <= f_vadr_org1_r;
        end
        else begin
          f_vadr1_r <= {1'b0,f_vadr_org1_r[9:1]};
        end
      end
      else begin
        if ( f_req_cnt_r[0] ) begin
          f_vadr1_r <= f_pvadr1_r;
        end
        else begin
          f_vadr1_r <= {1'b0,f_pvadr1_r[9:1]};
        end
      end
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_vadr2_r <= 10'h000;
    end
    else if ( f_whdtvh_r ) begin
      if ( f_vec2_err ) begin
        if ( f_req_cnt_r[0] ) begin
          f_vadr2_r <= {1'b0,f_vadr_org2_r[9:1]};
        end
        else begin
          f_vadr2_r <= {2'h0,f_vadr_org2_r[9:2]};
        end
      end
      else begin
        if ( f_req_cnt_r[0] ) begin
          f_vadr2_r <= {1'b0,f_pvadr2_r[9:3],2'h0};
        end
        else begin
          f_vadr2_r <= {2'h0,f_pvadr2_r[9:3],1'b0};
        end
      end
    end
    else begin
      if ( f_vec2_err ) begin
        if ( f_req_cnt_r[0] ) begin
          f_vadr2_r <= f_vadr_org2_r;
        end
        else begin
          f_vadr2_r <= {1'b0,f_vadr_org2_r[9:1]};
        end
      end
      else begin
        if ( f_req_cnt_r[0] ) begin
          f_vadr2_r <= f_pvadr2_r;
        end
        else begin
          f_vadr2_r <= {1'b0,f_pvadr2_r[9:1]};
        end
      end
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_vadr3_r <= 10'h000;
    end
    else if ( f_whdtvh_r ) begin
      if ( f_vec3_err ) begin
        if ( f_req_cnt_r[0] ) begin
          f_vadr3_r <= {1'b0,f_vadr_org1_r[9:1]};
        end
        else begin
          f_vadr3_r <= {2'h0,f_vadr_org1_r[9:2]};
        end
      end
      else begin
        if ( f_req_cnt_r[0] ) begin
          f_vadr3_r <= {1'b0,f_pvadr3_r[9:3],2'h0};
        end
        else begin
          f_vadr3_r <= {2'h0,f_pvadr3_r[9:3],1'b0};
        end
      end
    end
    else begin
      if ( f_vec3_err ) begin
        if ( f_req_cnt_r[0] ) begin
          f_vadr3_r <= f_vadr_org1_r;
        end
        else begin
          f_vadr3_r <= {1'b0,f_vadr_org1_r[9:1]};
        end
      end
      else begin
        if ( f_req_cnt_r[0] ) begin
          f_vadr3_r <= f_pvadr3_r;
        end
        else begin
          f_vadr3_r <= {1'b0,f_pvadr3_r[9:1]};
        end
      end
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_vadr4_r <= 10'h000;
    end
    else if ( f_whdtvh_r ) begin
      if ( f_vec4_err ) begin
        if ( f_req_cnt_r[0] ) begin
          f_vadr4_r <= {1'b0,f_vadr_org2_r[9:1]};
        end
        else begin
          f_vadr4_r <= {2'h0,f_vadr_org2_r[9:2]};
        end
      end
      else begin
        if ( f_req_cnt_r[0] ) begin
          f_vadr4_r <= {1'b0,f_pvadr4_r[9:3],2'h0};
        end
        else begin
          f_vadr4_r <= {2'h0,f_pvadr4_r[9:3],1'b0};
        end
      end
    end
    else begin
      if ( f_vec4_err ) begin
        if ( f_req_cnt_r[0] ) begin
          f_vadr4_r <= f_vadr_org2_r;
        end
        else begin
          f_vadr4_r <= {1'b0,f_vadr_org2_r[9:1]};
        end
      end
      else begin
        if ( f_req_cnt_r[0] ) begin
          f_vadr4_r <= f_pvadr4_r;
        end
        else begin
          f_vadr4_r <= {1'b0,f_pvadr4_r[9:1]};
        end
      end
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_vec1_err_r <= 1'b0;
      f_vec2_err_r <= 1'b0;
      f_vec3_err_r <= 1'b0;
      f_vec4_err_r <= 1'b0;
    end
    else begin
      f_vec1_err_r <= f_vec1_err;
      f_vec2_err_r <= f_vec2_err;
      f_vec3_err_r <= f_vec3_err;
      f_vec4_err_r <= f_vec4_err;
    end
  end

  assign f_vec1_err = f_had1_uf | f_had1_of | f_vad1_uf | f_vad1_of;
  assign f_vec2_err = f_had2_uf | f_had2_of | f_vad2_uf | f_vad2_of;
  assign f_vec3_err = f_had3_uf | f_had3_of | f_vad3_uf | f_vad3_of;
  assign f_vec4_err = f_had4_uf | f_had4_of | f_vad4_uf | f_vad4_of;
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_vec1_ey_r <= 1'b0;
      f_vec2_ey_r <= 1'b0;
      f_vec3_ey_r <= 1'b0;
      f_vec4_ey_r <= 1'b0;
    end
    else if( f_req_s && f_req_cnt_r[0] ) begin
      f_vec1_ey_r <= f_vec1_err_r;
      f_vec2_ey_r <= f_vec2_err_r;
      f_vec3_ey_r <= f_vec3_err_r;
      f_vec4_ey_r <= f_vec4_err_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_vec1_ec_r <= 1'b0;
      f_vec2_ec_r <= 1'b0;
      f_vec3_ec_r <= 1'b0;
      f_vec4_ec_r <= 1'b0;
    end
    else if( f_req_s && !f_req_cnt_r[0] ) begin
      f_vec1_ec_r <= f_vec1_err_r;
      f_vec2_ec_r <= f_vec2_err_r;
      f_vec3_ec_r <= f_vec3_err_r;
      f_vec4_ec_r <= f_vec4_err_r;
    end
  end

  assign f_vec3_ey_sel = (f_fb_sel) ? f_vec1_ey_r : f_vec3_ey_r;
  assign f_vec3_ec_sel = (f_fb_sel) ? f_vec1_ec_r : f_vec3_ec_r;
  assign f_vec4_ey_sel = (f_fb_sel) ? f_vec2_ey_r : f_vec4_ey_r;
  assign f_vec4_ec_sel = (f_fb_sel) ? f_vec2_ec_r : f_vec4_ec_r;
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_req_cnt_r <= 4'hf;
    end
    else if ( f_bfcnt_init_r ) begin
      f_req_cnt_r <= 4'hf;
    end
    else if ( f_req_cnt_ld7_r ) begin
      f_req_cnt_r <= 4'h7;
    end
    else if ( f_req_cnt_ld3_r ) begin
      f_req_cnt_r <= 4'h3;
    end
    else if ( f_req_s ) begin
      f_req_cnt_r <= f_req_cnt_r - 1'b1;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_req_cnt_ld7_r <= 1'h0;
    end
    else if ( (f_wmttyp_r == 2'h3) ||
              (f_wpred_forward_buc_r && f_wpred_backward_buc_r) ) begin
      f_req_cnt_ld7_r <= f_mbpl_buc_d1_r_s ;
    end
    else begin
      f_req_cnt_ld7_r <= 1'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_req_cnt_ld3_r <= 1'h0;
    end
    else if ( (f_pstr_r != 2'h3) ||
              (f_wpred_forward_buc_r || f_wpred_backward_buc_r) ) begin
      f_req_cnt_ld3_r <= f_mbpl_buc_d1_r_s ;
    end
    else begin
      f_req_cnt_ld3_r <= 1'h0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_recnt_dc_r <= 3'h0;
    end
    else begin
      f_recnt_dc_r[2:1] <= f_recnt_dc_r[1:0];
      f_recnt_dc_r[0]   <= ( f_req_cnt_r != 4'hf );
    end
  end
  

  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_acceptance_r <= 1'b0;
      f_acc_d1_r     <= 1'b0;
      f_request_r    <= 1'b0;
    end
    else begin
      f_acceptance_r <= vrh_acceptance_r;
      f_acc_d1_r     <= f_acc;
      f_request_r    <= f_req_s;
    end
  end

  assign f_acc = f_acceptance_r & f_recnt_dc_r[2];
  assign f_req_s = f_acc & (~f_acc_d1_r);
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_ifsel_r <= 2'h0;
    end
    else begin
      f_ifsel_r[1] <= f_ifsel1_gt & (~f_req_cnt_r[2]);
      f_ifsel_r[0] <= (~f_req_cnt_r[1]);
    end
  end

  assign f_ifsel1_gt = (f_wmttyp_r == 2'h3) | (f_wpred_forward_buc_r & f_wpred_backward_buc_r);
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_addressx_r  <= 11'h000;
      f_addressy_r  <= 10'h000;
      f_field_num_r <= 4'h0;
    end
    else begin
      case ( f_ifsel_r )
        2'b00 : begin
          f_addressx_r  <= f_hadr1_r;
          f_addressy_r  <= f_vadr1_r;
          f_field_num_r <= f_fnum0_r;
        end
        2'b01 : begin
          f_addressx_r <= f_hadr2_r;
          f_addressy_r <= f_vadr2_r;
          f_field_num_r <= f_fnum1_r;
        end
        2'b10 : begin
          f_addressx_r <= f_hadr3_r;
          f_addressy_r <= f_vadr3_r;
          f_field_num_r <= f_fnum2_r;
        end
        2'b11 : begin
          f_addressx_r <= f_hadr4_r;
          f_addressy_r <= f_vadr4_r;
          f_field_num_r <= f_fnum3_r;
        end
      endcase
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_line_num_r <= 3'h0;
    end
    else if ( f_req_cnt_r[0] ) begin
      if ( f_whdtvh_r ) begin
        f_line_num_r <= 3'h4;
      end
      else begin
        f_line_num_r <= 3'h5;
      end
    end
    else begin
      if ( f_whdtvh_r ) begin
        f_line_num_r <= 3'h2;
      end
      else begin
        f_line_num_r <= 3'h3;
      end
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_byte_num_r <= 2'h0;
    end
    else if ( f_whdtvh_r ) begin
      f_byte_num_r <= 2'h1;
    end
    else begin
      f_byte_num_r <= 2'h2;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_vec_err_r <= 1'b0;
    end
    else begin
      case ( f_ifsel_r )
        2'b00 : f_vec_err_r <= f_vec1_err_r & f_req_s;
        2'b01 : f_vec_err_r <= f_vec2_err_r & f_req_s;
        2'b10 : f_vec_err_r <= f_vec3_err_r & f_req_s;
        2'b11 : f_vec_err_r <= f_vec4_err_r & f_req_s;
      endcase
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_regwen_f1_r <= 1'b0;
    end
    else begin
      f_regwen_f1_r <= f_ifsel_dc0 &
                         (~f_req_cnt_r[0]) &
                         f_req_s;
    end
  end

  assign f_ifsel_dc0 = (f_ifsel_r == 2'h0);
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      f_regwen_r <= 1'b0;
    end
    else begin
      f_regwen_r <= f_regwen_f1_r;
    end
  end
  
endmodule
