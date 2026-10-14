// ----------------------------------------------
// File: uc_hctrl.v
// Module: uc_hctrl
// Function:Up Convert Horizontal Filater Control
// ----------------------------------------------

module uc_hctrl(
  clkdec,
  rstdec_x,
  c_mbpl_uc_r_s,
  u_ref1v_yen_r,
  u_ref1v_cen_r,
  u_ref1v_ysngl_r,
  u_ref1v_csngl_r,
  f_hdtvh_r,
  f_pred_forward_buc_r,
  f_mttyp_r,
  f_hvec1y_r,
  f_hvec2y_r,
  f_hvec1c_r,
  f_hvec2c_r,
  u_vyen_d1_r,
  u_vcen_d1_r,
  u_hff2en_r_s,
  u_hdt_sl1_r,
  u_hdt_sl2_r,
  u_hdt_sl3_r,
  u_hdt_msk_r,
  u_hcoe1_r,
  u_hcoe2_r,
  u_hopstp_r,
  u_hdtvhh_r,
  u_hyen_r,
  u_hcen_r
  );
  
  input         clkdec;          
  input         rstdec_x;        
  input         c_mbpl_uc_r_s;      
  input         u_ref1v_yen_r;      
  input         u_ref1v_cen_r;      
  input         u_ref1v_ysngl_r;    
  input         u_ref1v_csngl_r;    
  input         f_hdtvh_r;          
  input         f_pred_forward_buc_r;
  input [1:0]   f_mttyp_r;           
  input [3:0]   f_hvec1y_r;         
  input [3:0]   f_hvec2y_r;         
  input [2:0]   f_hvec1c_r;         
  input [2:0]   f_hvec2c_r;         
  output        u_vyen_d1_r;        
  output        u_vcen_d1_r;        
  output        u_hff2en_r_s;       
  output        u_hdt_sl1_r;        
  output        u_hdt_sl2_r;        
  output        u_hdt_sl3_r;        
  output        u_hdt_msk_r;        
  output [79:0] u_hcoe1_r;          
  output [79:0] u_hcoe2_r;          
  output        u_hopstp_r;         
  output        u_hdtvhh_r;         
  output        u_hyen_r;           
  output        u_hcen_r;           
  
  wire          c_mbpl_uc_r_s;        // MB Pulse(UC)
  wire          u_ref1v_yen_r;        // MB Data Enable(Y)
  wire          u_ref1v_cen_r;        // MB Data Enable(C)
  wire          u_ref1v_ysngl_r;      // MB Data Single Flag(Y)
  wire          u_ref1v_csngl_r;      // MB Data Single Flag(C)
  wire          f_hdtvh_r;            // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  wire          f_pred_forward_buc_r; // MB Estimate Valid Flag
  wire [1:0]    f_mttyp_r;            // MB Estimate Mode
  wire [3:0]    f_hvec1y_r;           // MB Horizontal Vector(Y) Top-Field
  wire [3:0]    f_hvec2y_r;           // MB Horizontal Vector(Y) Bottom-Field
  wire [2:0]    f_hvec1c_r;           // MB Horizontal Vector(C) Top-Field
  wire [2:0]    f_hvec2c_r;           // MB Horizontal Vector(C) Bottom-Field
  wire          u_vyen_neg_s;         // MB Data Enable(Y) Negedge
  wire          u_vcen_neg_s;         // MB Data Enable(C) Negedge
  wire          u_hslcnt0_ld_s;       // MB Data Select Counter0 Load
  wire          u_hsl2_dec_s;         // MB Data Select Counter2 Decode
  wire          u_hdt_msk;            // Output Data Lower Byte Dummy Mask
  wire          u_hdt_sl1;            // MB Data Select1
  wire [3:0]    u_hvy;                // MB Horizontal Vector(Y)
  wire [2:0]    u_hvc;                // MB Horizontal Vector(C)
  
  reg           u_vyen_d1_r;          // u_ref1v_yen_r 1CLK Delay
  reg           u_vcen_d1_r;          // u_ref1v_cen_r 1CLK Delay
  reg           u_hff2en_r_s;         // MB Data Latch Enable
  reg           u_hdt_sl1_r;          // MB Data Select1
  reg           u_hdt_sl2_r;          // MB Data Select2
  reg           u_hdt_sl3_r;          // MB Data Select3
  reg           u_hdt_msk_r;          // Output Data Lower Byte Dummy Mask
  reg [79:0]    u_hcoe1_r;            // MB Horizontal Coefficient1
  reg [79:0]    u_hcoe2_r;            // MB Horizontal Coefficient2
  reg           u_hopstp_r;           // MB Estimate Valid Flag
  reg           u_hdtvhh_r;           // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  reg           u_hyen_r;             // MB Data Enable(HDTV/Y)
  reg           u_hcen_r;             // MB Data Enable(HDTV/C)
  reg           u_mbplh_r_s;
  reg           u_mbplh_d1_r_s;       // u_mbplh_r_s 1CLK Delay
  reg           u_vyen_d2_r;          // u_ref1v_yen_r 2CLK Delay
  reg           u_vcen_d2_r;          // u_ref1v_cen_r 2CLK Delay
  reg           u_mbplh_neg_r_s;      // MB Pulse Negedge
  reg           u_vyen_pos_r_s;       // MB Data Enable(Y) Posedge
  reg           u_vcen_pos_r_s;       // MB Data Enable(C) Posedge
  reg [3:0]     u_hlny_cnt_r;         // MB Data Line Counter(Y)
  reg [3:0]     u_hlnc_cnt_r;         // MB Data Line Counter(C)
  reg [3:0]     u_hv1y_r,             // MB Horizontal Vector(Y) Top-Field
                u_hv2y_r;             // MB Horizontal Vector(Y) Bottom-Field
  reg [2:0]     u_hv1c_r,             // MB Horizontal Vector(C) Top-Field
                u_hv2c_r;             // MB Horizontal Vector(C) Bottom-Field
  reg           u_hdtvh_r;            // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  reg           u_pred_forward_buc_r; // MB Estimate Valid Flag
  reg [1:0]     u_mttyp_buc_r;        // MB Estimate Mode
  reg [3:0]     u_hvec1y_r,           // MB Horizontal Vector(Y) Top-Field
                u_hvec2y_r;           // MB Horizontal Vector(Y) Bottom-Field
  reg [2:0]     u_hvec1c_r,           // MB Horizontal Vector(C) Top-Field
                u_hvec2c_r;           // MB Horizontal Vector(C) Bottom-Field
  reg           u_hsl_pcoe_r;         // MB Coefficient Select
  reg [9:0]     u_hsl_coe_r;          // MB Coefficient Select
  reg [4:0]     u_hslcnt0_r,          // MB Coefficient Select Counter0
                u_hslcnt1_r;          // MB Coefficient Select Counter1
  reg [3:0]     u_hslcnt1_d1_r;       // u_hslcnt1_r 1CLK Delay
  reg           u_hdt_sl3_f1_r;       // MB Data Select3
  reg [79:0]    u_hycoe1_r,           // MB Coefficient1(Y)
                u_hycoe2_r;           // MB Coefficient2(Y)
  reg [79:0]    u_hccoe1_r,           // MB Coefficient1(C)
                u_hccoe2_r;           // MB Coefficient2(C)
  reg           u_v_ysngl_d1_r,       // u_ref1v_ysngl_r 1CLK Delay
                u_v_csngl_d1_r;       // u_ref1v_csngl_r 1CLK Delay
  reg           u_hysngl_r,           // MB Data Single Flag(Y)
                u_hcsngl_r;           // MB Data Single Flag(C)
  reg           u_hysngl_d1_r,        // u_hysngl_r Data Phase
                u_hcsngl_d1_r;        // u_hcsngl_r Data Phase
  reg [1:0]     u_phyen_r,            // Pre MB Data Enable(Y)
                u_phcen_r;            // Pre MB Data Enable(C)
  
  
  parameter   P_HY_0_0 =10'h133, P_HY_0_1 =10'h3b4, P_HY_0_2 =10'h02a, P_HY_0_3 =10'h3e5, P_HY_0_4 =10'h012, P_HY_0_5 =10'h3f4, P_HY_0_6 =10'h006, P_HY_0_7 =10'h3fe; 
  parameter   P_HY_1_0 =10'h0b9, P_HY_1_1 =10'h064, P_HY_1_2 =10'h3d2, P_HY_1_3 =10'h01d, P_HY_1_4 =10'h3ed, P_HY_1_5 =10'h00c, P_HY_1_6 =10'h3f9, P_HY_1_7 =10'h002; 
  parameter   P_HY_2_0 =10'h02c, P_HY_2_1 =10'h0f9, P_HY_2_2 =10'h3c7, P_HY_2_3 =10'h020, P_HY_2_4 =10'h3ec, P_HY_2_5 =10'h00d, P_HY_2_6 =10'h3f9, P_HY_2_7 =10'h002; 
  parameter   P_HY_3_0 =10'h3eb, P_HY_3_1 =10'h0d8, P_HY_3_2 =10'h056, P_HY_3_3 =10'h3da, P_HY_3_4 =10'h016, P_HY_3_5 =10'h3f2, P_HY_3_6 =10'h007, P_HY_3_7 =10'h3fe; 
  parameter   P_HY_4_0 =10'h3f4, P_HY_4_1 =10'h03f, P_HY_4_2 =10'h0ee, P_HY_4_3 =10'h3ce, P_HY_4_4 =10'h01a, P_HY_4_5 =10'h3f1, P_HY_4_6 =10'h008, P_HY_4_7 =10'h3fe; 
  parameter   P_HY_5_0 =10'h008, P_HY_5_1 =10'h3de, P_HY_5_2 =10'h0df, P_HY_5_3 =10'h050, P_HY_5_4 =10'h3df, P_HY_5_5 =10'h012, P_HY_5_6 =10'h3f7, P_HY_5_7 =10'h003; 
  parameter   P_HY_6_0 =10'h006, P_HY_6_1 =10'h3e9, P_HY_6_2 =10'h046, P_HY_6_3 =10'h0ea, P_HY_6_4 =10'h3d3, P_HY_6_5 =10'h016, P_HY_6_6 =10'h3f5, P_HY_6_7 =10'h003; 
  parameter   P_HY_7_0 =10'h3fb, P_HY_7_1 =10'h011, P_HY_7_2 =10'h3d7, P_HY_7_3 =10'h0e5, P_HY_7_4 =10'h04b, P_HY_7_5 =10'h3e4, P_HY_7_6 =10'h00d, P_HY_7_7 =10'h3fc; 
  parameter   P_HY_8_0 =10'h3fc, P_HY_8_1 =10'h00d, P_HY_8_2 =10'h3e4, P_HY_8_3 =10'h04b, P_HY_8_4 =10'h0e5, P_HY_8_5 =10'h3d7, P_HY_8_6 =10'h011, P_HY_8_7 =10'h3fb; 
  parameter   P_HY_9_0 =10'h003, P_HY_9_1 =10'h3f5, P_HY_9_2 =10'h016, P_HY_9_3 =10'h3d3, P_HY_9_4 =10'h0ea, P_HY_9_5 =10'h046, P_HY_9_6 =10'h3e9, P_HY_9_7 =10'h006; 
  parameter   P_HY_A_0 =10'h003, P_HY_A_1 =10'h3f7, P_HY_A_2 =10'h012, P_HY_A_3 =10'h3df, P_HY_A_4 =10'h050, P_HY_A_5 =10'h0df, P_HY_A_6 =10'h3de, P_HY_A_7 =10'h008; 
  parameter   P_HY_B_0 =10'h3fe, P_HY_B_1 =10'h008, P_HY_B_2 =10'h3f1, P_HY_B_3 =10'h01a, P_HY_B_4 =10'h3ce, P_HY_B_5 =10'h0ee, P_HY_B_6 =10'h03f, P_HY_B_7 =10'h3f4; 
  parameter   P_HY_C_0 =10'h3fe, P_HY_C_1 =10'h007, P_HY_C_2 =10'h3f2, P_HY_C_3 =10'h016, P_HY_C_4 =10'h3da, P_HY_C_5 =10'h056, P_HY_C_6 =10'h0d8, P_HY_C_7 =10'h3eb; 
  parameter   P_HY_D_0 =10'h002, P_HY_D_1 =10'h3f9, P_HY_D_2 =10'h00d, P_HY_D_3 =10'h3ec, P_HY_D_4 =10'h020, P_HY_D_5 =10'h3c7, P_HY_D_6 =10'h0f9, P_HY_D_7 =10'h02c; 
  parameter   P_HY_E_0 =10'h002, P_HY_E_1 =10'h3f9, P_HY_E_2 =10'h00c, P_HY_E_3 =10'h3ed, P_HY_E_4 =10'h01d, P_HY_E_5 =10'h3d2, P_HY_E_6 =10'h064, P_HY_E_7 =10'h0b9; 
  parameter   P_HY_F_0 =10'h3fe, P_HY_F_1 =10'h006, P_HY_F_2 =10'h3f4, P_HY_F_3 =10'h012, P_HY_F_4 =10'h3e5, P_HY_F_5 =10'h02a, P_HY_F_6 =10'h3b4, P_HY_F_7 =10'h133; 
  parameter   P_HC_0_0 =10'h130, P_HC_0_1 =10'h3bb, P_HC_0_2 =10'h01e, P_HC_0_3 =10'h3f7; 
  parameter   P_HC_1_0 =10'h0bc, P_HC_1_1 =10'h05d, P_HC_1_2 =10'h3de, P_HC_1_3 =10'h009; 
  parameter   P_HC_2_0 =10'h02f, P_HC_2_1 =10'h0f2, P_HC_2_2 =10'h3d4, P_HC_2_3 =10'h00b; 
  parameter   P_HC_3_0 =10'h3e9, P_HC_3_1 =10'h0de, P_HC_3_2 =10'h048, P_HC_3_3 =10'h3f1; 
  parameter   P_HC_4_0 =10'h3f1, P_HC_4_1 =10'h048, P_HC_4_2 =10'h0de, P_HC_4_3 =10'h3e9; 
  parameter   P_HC_5_0 =10'h00b, P_HC_5_1 =10'h3d4, P_HC_5_2 =10'h0f2, P_HC_5_3 =10'h02f; 
  parameter   P_HC_6_0 =10'h009, P_HC_6_1 =10'h3de, P_HC_6_2 =10'h05d, P_HC_6_3 =10'h0bc; 
  parameter   P_HC_7_0 =10'h3f7, P_HC_7_1 =10'h01e, P_HC_7_2 =10'h3bb, P_HC_7_3 =10'h130; 
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_mbplh_r_s    <= 1'b0;
      u_mbplh_d1_r_s <= 1'b0;
      u_vyen_d1_r    <= 1'b0;
      u_vyen_d2_r    <= 1'b0;
      u_vcen_d1_r    <= 1'b0;
      u_vcen_d2_r    <= 1'b0;
    end
    else begin
      u_mbplh_r_s    <= c_mbpl_uc_r_s;
      u_mbplh_d1_r_s <= u_mbplh_r_s;
      u_vyen_d1_r    <= u_ref1v_yen_r;
      u_vyen_d2_r    <= u_vyen_d1_r;
      u_vcen_d1_r    <= u_ref1v_cen_r;
      u_vcen_d2_r    <= u_vcen_d1_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_mbplh_neg_r_s <= 1'b0;
    end
    else begin
      u_mbplh_neg_r_s <= (~u_mbplh_r_s) & u_mbplh_d1_r_s;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vyen_pos_r_s <= 1'b0;
    end
    else begin
      u_vyen_pos_r_s <= u_vyen_d1_r & (~u_vyen_d2_r);
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vcen_pos_r_s <= 1'b0;
    end
    else begin
      u_vcen_pos_r_s <= u_vcen_d1_r & (~u_vcen_d2_r);
    end
  end
  assign u_vyen_neg_s = (~u_vyen_d1_r) & u_vyen_d2_r;
  assign u_vcen_neg_s = (~u_vcen_d1_r) & u_vcen_d2_r;
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hff2en_r_s <= 1'b0;
    end
    else begin
      u_hff2en_r_s <= u_vyen_neg_s | u_vcen_neg_s ;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hlny_cnt_r <= 4'h0;
    end
    else if( u_mbplh_r_s ) begin
      u_hlny_cnt_r <= 4'h0;
    end
    else if( u_vyen_neg_s ) begin
      u_hlny_cnt_r <= u_hlny_cnt_r + 1'b1;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hlnc_cnt_r <= 4'h0;
    end
    else if( u_mbplh_r_s ) begin
      u_hlnc_cnt_r <= 4'h0;
    end
    else if( u_vcen_neg_s ) begin
      u_hlnc_cnt_r <= u_hlnc_cnt_r + 1'b1;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdtvh_r            <= 1'b0;
      u_pred_forward_buc_r <= 1'b0;
      u_hvec1y_r           <= 4'b0;
      u_hvec2y_r           <= 4'b0;
      u_hvec1c_r           <= 3'b0;
      u_hvec2c_r           <= 3'b0;
      u_mttyp_buc_r        <= 2'b0;
    end
    else begin
      u_hdtvh_r            <= f_hdtvh_r;
      u_pred_forward_buc_r <= f_pred_forward_buc_r;
      u_hvec1y_r           <= f_hvec1y_r;
      u_hvec2y_r           <= f_hvec2y_r;
      u_hvec1c_r           <= f_hvec1c_r;
      u_hvec2c_r           <= f_hvec2c_r;
      u_mttyp_buc_r        <= f_mttyp_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdtvhh_r <= 1'b0;
      u_hopstp_r <= 1'b0;
      u_hv1y_r   <= 4'b0;
      u_hv2y_r   <= 4'b0;
      u_hv1c_r   <= 3'b0;
      u_hv2c_r   <= 3'b0;
    end
    else if( u_mbplh_neg_r_s ) begin
      u_hdtvhh_r <= u_hdtvh_r;
      u_hopstp_r <= u_pred_forward_buc_r | (u_mttyp_buc_r == 2'h3);
      u_hv1y_r   <= u_hvec1y_r;
      u_hv2y_r   <= u_hvec2y_r;
      u_hv1c_r   <= u_hvec1c_r;
      u_hv2c_r   <= u_hvec2c_r;
    end
  end
  
  assign u_hvy = ( u_hlny_cnt_r > 4'h5 ) ? u_hv2y_r : u_hv1y_r;
  assign u_hvc = (((u_hlnc_cnt_r > 4'h3) && (u_hlnc_cnt_r < 4'h7)) ||
                    (u_hlnc_cnt_r > 4'h9)) ? u_hv2c_r : u_hv1c_r;
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hsl_pcoe_r <= 1'b0;
    end
    else if( u_mbplh_r_s ) begin
      u_hsl_pcoe_r <= 1'b0;
    end
    else if( u_vcen_pos_r_s ) begin
      u_hsl_pcoe_r <= 1'b1;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hsl_coe_r <= 10'b0;
    end
    else begin
      u_hsl_coe_r <= {u_hsl_coe_r[8:0],u_hsl_pcoe_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hslcnt0_r <= 5'h1f;
    end
    else if( u_hff2en_r_s ) begin
      u_hslcnt0_r <= 5'b0;
    end
    else if( u_hslcnt0_ld_s ) begin
      u_hslcnt0_r <= 5'h10;
    end
    else if( u_hslcnt0_r != 5'h1f ) begin
      u_hslcnt0_r <= u_hslcnt0_r + 1'b1;
    end
  end
  assign u_hslcnt0_ld_s = u_hsl_coe_r[7] ? ( u_hslcnt0_r == 5'h4 ) : ( u_hslcnt0_r == 5'h8 );
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hslcnt1_r <= 5'h1f;
    end
    else if( u_hff2en_r_s || u_hslcnt0_ld_s ) begin
      if( u_hsl_coe_r[6] ) begin
        u_hslcnt1_r <= {1'b0,u_hvc} ;
      end
      else begin
        u_hslcnt1_r <= {1'b0,u_hvy} ;
      end
    end
    else if( u_hslcnt1_r[4:1] != 4'hf ) begin
      u_hslcnt1_r <= u_hslcnt1_r + 2'b10;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hslcnt1_d1_r <= 4'b0;
    end
    else begin
      u_hslcnt1_d1_r <= u_hslcnt1_r[3:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdt_sl1_r <= 1'b0;
    end
    else begin
      u_hdt_sl1_r <= u_hdt_sl1;
    end
  end
  assign u_hdt_sl1 = (u_hsl_coe_r[7]) ? u_hslcnt1_r[3] : u_hslcnt1_r[4];
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdt_sl2_r <= 1'b0;
    end
    else begin
      u_hdt_sl2_r <= u_hdt_sl1 | u_hsl2_dec_s;
    end
  end
  assign u_hsl2_dec_s = u_hsl_coe_r[7] ? (u_hslcnt1_r == 5'h07) : (u_hslcnt1_r == 5'h0f);
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdt_sl3_f1_r <= 1'b0;
      u_hdt_sl3_r    <= 1'b0;
    end
    else begin
      u_hdt_sl3_f1_r <= u_hslcnt0_r[4];
      u_hdt_sl3_r    <= u_hdt_sl3_f1_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdt_msk_r <= 1'b0;
    end
    else begin
      u_hdt_msk_r <= u_hdt_msk;
    end
  end
  assign u_hdt_msk = u_hsl_coe_r[7] ? ( u_hslcnt0_r[3:0] != 4'h4 ) : ( u_hslcnt0_r[3:0] != 4'h8 );
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hycoe1_r <= 80'b0;
      u_hycoe2_r <= 80'b0;
    end
    else begin
       case( u_hslcnt1_d1_r )
         4'h0 : begin
           u_hycoe1_r <= {P_HY_0_0, P_HY_0_1, P_HY_0_2, P_HY_0_3,
                            P_HY_0_4, P_HY_0_5, P_HY_0_6, P_HY_0_7};
           u_hycoe2_r <= {P_HY_1_0, P_HY_1_1, P_HY_1_2, P_HY_1_3,
                            P_HY_1_4, P_HY_1_5, P_HY_1_6, P_HY_1_7};
         end
         4'h1 : begin
           u_hycoe1_r <= {P_HY_1_0, P_HY_1_1, P_HY_1_2, P_HY_1_3,
                            P_HY_1_4, P_HY_1_5, P_HY_1_6, P_HY_1_7};
           u_hycoe2_r <= {P_HY_2_0, P_HY_2_1, P_HY_2_2, P_HY_2_3,
                            P_HY_2_4, P_HY_2_5, P_HY_2_6, P_HY_2_7};
         end
         4'h2 : begin
           u_hycoe1_r <= {P_HY_2_0, P_HY_2_1, P_HY_2_2, P_HY_2_3,
                            P_HY_2_4, P_HY_2_5, P_HY_2_6, P_HY_2_7};
           u_hycoe2_r <= {P_HY_3_0, P_HY_3_1, P_HY_3_2, P_HY_3_3,
                            P_HY_3_4, P_HY_3_5, P_HY_3_6, P_HY_3_7};
         end
         4'h3 : begin
           u_hycoe1_r <= {P_HY_3_0, P_HY_3_1, P_HY_3_2, P_HY_3_3,
                            P_HY_3_4, P_HY_3_5, P_HY_3_6, P_HY_3_7};
           u_hycoe2_r <= {P_HY_4_0, P_HY_4_1, P_HY_4_2, P_HY_4_3,
                            P_HY_4_4, P_HY_4_5, P_HY_4_6, P_HY_4_7};
         end
         4'h4 : begin
           u_hycoe1_r <= {P_HY_4_0, P_HY_4_1, P_HY_4_2, P_HY_4_3,
                            P_HY_4_4, P_HY_4_5, P_HY_4_6, P_HY_4_7};
           u_hycoe2_r <= {P_HY_5_0, P_HY_5_1, P_HY_5_2, P_HY_5_3,
                            P_HY_5_4, P_HY_5_5, P_HY_5_6, P_HY_5_7};
         end
         4'h5 : begin
           u_hycoe1_r <= {P_HY_5_0, P_HY_5_1, P_HY_5_2, P_HY_5_3,
                            P_HY_5_4, P_HY_5_5, P_HY_5_6, P_HY_5_7};
           u_hycoe2_r <= {P_HY_6_0, P_HY_6_1, P_HY_6_2, P_HY_6_3,
                            P_HY_6_4, P_HY_6_5, P_HY_6_6, P_HY_6_7};
         end
         4'h6 : begin
           u_hycoe1_r <= {P_HY_6_0, P_HY_6_1, P_HY_6_2, P_HY_6_3,
                            P_HY_6_4, P_HY_6_5, P_HY_6_6, P_HY_6_7};
           u_hycoe2_r <= {P_HY_7_0, P_HY_7_1, P_HY_7_2, P_HY_7_3,
                            P_HY_7_4, P_HY_7_5, P_HY_7_6, P_HY_7_7};
         end
         4'h7 : begin
           u_hycoe1_r <= {P_HY_7_0, P_HY_7_1, P_HY_7_2, P_HY_7_3,
                            P_HY_7_4, P_HY_7_5, P_HY_7_6, P_HY_7_7};
           u_hycoe2_r <= {P_HY_8_0, P_HY_8_1, P_HY_8_2, P_HY_8_3,
                            P_HY_8_4, P_HY_8_5, P_HY_8_6, P_HY_8_7};
         end
         4'h8 : begin
           u_hycoe1_r <= {P_HY_8_0, P_HY_8_1, P_HY_8_2, P_HY_8_3,
                            P_HY_8_4, P_HY_8_5, P_HY_8_6, P_HY_8_7};
           u_hycoe2_r <= {P_HY_9_0, P_HY_9_1, P_HY_9_2, P_HY_9_3,
                            P_HY_9_4, P_HY_9_5, P_HY_9_6, P_HY_9_7};
         end
         4'h9 : begin
           u_hycoe1_r <= {P_HY_9_0, P_HY_9_1, P_HY_9_2, P_HY_9_3,
                            P_HY_9_4, P_HY_9_5, P_HY_9_6, P_HY_9_7};
           u_hycoe2_r <= {P_HY_A_0, P_HY_A_1, P_HY_A_2, P_HY_A_3,
                            P_HY_A_4, P_HY_A_5, P_HY_A_6, P_HY_A_7};
         end
         4'ha : begin
           u_hycoe1_r <= {P_HY_A_0, P_HY_A_1, P_HY_A_2, P_HY_A_3,
                            P_HY_A_4, P_HY_A_5, P_HY_A_6, P_HY_A_7};
           u_hycoe2_r <= {P_HY_B_0, P_HY_B_1, P_HY_B_2, P_HY_B_3,
                            P_HY_B_4, P_HY_B_5, P_HY_B_6, P_HY_B_7};
         end
         4'hb : begin
           u_hycoe1_r <= {P_HY_B_0, P_HY_B_1, P_HY_B_2, P_HY_B_3,
                            P_HY_B_4, P_HY_B_5, P_HY_B_6, P_HY_B_7};
           u_hycoe2_r <= {P_HY_C_0, P_HY_C_1, P_HY_C_2, P_HY_C_3,
                            P_HY_C_4, P_HY_C_5, P_HY_C_6, P_HY_C_7};
         end
         4'hc : begin
           u_hycoe1_r <= {P_HY_C_0, P_HY_C_1, P_HY_C_2, P_HY_C_3,
                            P_HY_C_4, P_HY_C_5, P_HY_C_6, P_HY_C_7};
           u_hycoe2_r <= {P_HY_D_0, P_HY_D_1, P_HY_D_2, P_HY_D_3,
                            P_HY_D_4, P_HY_D_5, P_HY_D_6, P_HY_D_7};
         end
         4'hd : begin
           u_hycoe1_r <= {P_HY_D_0, P_HY_D_1, P_HY_D_2, P_HY_D_3,
                            P_HY_D_4, P_HY_D_5, P_HY_D_6, P_HY_D_7};
           u_hycoe2_r <= {P_HY_E_0, P_HY_E_1, P_HY_E_2, P_HY_E_3,
                            P_HY_E_4, P_HY_E_5, P_HY_E_6, P_HY_E_7};
         end
         4'he : begin
           u_hycoe1_r <= {P_HY_E_0, P_HY_E_1, P_HY_E_2, P_HY_E_3,
                            P_HY_E_4, P_HY_E_5, P_HY_E_6, P_HY_E_7};
           u_hycoe2_r <= {P_HY_F_0, P_HY_F_1, P_HY_F_2, P_HY_F_3,
                            P_HY_F_4, P_HY_F_5, P_HY_F_6, P_HY_F_7};
         end
         4'hf : begin
           u_hycoe1_r <= {P_HY_F_0, P_HY_F_1, P_HY_F_2, P_HY_F_3,
                            P_HY_F_4, P_HY_F_5, P_HY_F_6, P_HY_F_7};
           u_hycoe2_r <= {P_HY_0_0, P_HY_0_1, P_HY_0_2, P_HY_0_3,
                            P_HY_0_4, P_HY_0_5, P_HY_0_6, P_HY_0_7};
         end
       endcase
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hccoe1_r <= 80'b0;
      u_hccoe2_r <= 80'b0;
    end
    else begin
       case( u_hslcnt1_d1_r[2:0] )
         3'h0 : begin
           u_hccoe1_r <= {P_HC_0_0, P_HC_0_1, P_HC_0_2, P_HC_0_3,40'b0};
           u_hccoe2_r <= {P_HC_1_0, P_HC_1_1, P_HC_1_2, P_HC_1_3,40'b0};
         end
         3'h1 : begin
           u_hccoe1_r <= {P_HC_1_0, P_HC_1_1, P_HC_1_2, P_HC_1_3,40'b0};
           u_hccoe2_r <= {P_HC_2_0, P_HC_2_1, P_HC_2_2, P_HC_2_3,40'b0};
         end
         3'h2 : begin
           u_hccoe1_r <= {P_HC_2_0, P_HC_2_1, P_HC_2_2, P_HC_2_3,40'b0};
           u_hccoe2_r <= {P_HC_3_0, P_HC_3_1, P_HC_3_2, P_HC_3_3,40'b0};
         end
         3'h3 : begin
           u_hccoe1_r <= {P_HC_3_0, P_HC_3_1, P_HC_3_2, P_HC_3_3,40'b0};
           u_hccoe2_r <= {P_HC_4_0, P_HC_4_1, P_HC_4_2, P_HC_4_3,40'b0};
         end
         3'h4 : begin
           u_hccoe1_r <= {P_HC_4_0, P_HC_4_1, P_HC_4_2, P_HC_4_3,40'b0};
           u_hccoe2_r <= {P_HC_5_0, P_HC_5_1, P_HC_5_2, P_HC_5_3,40'b0};
         end
         3'h5 : begin
           u_hccoe1_r <= {P_HC_5_0, P_HC_5_1, P_HC_5_2, P_HC_5_3,40'b0};
           u_hccoe2_r <= {P_HC_6_0, P_HC_6_1, P_HC_6_2, P_HC_6_3,40'b0};
         end
         3'h6 : begin
           u_hccoe1_r <= {P_HC_6_0, P_HC_6_1, P_HC_6_2, P_HC_6_3,40'b0};
           u_hccoe2_r <= {P_HC_7_0, P_HC_7_1, P_HC_7_2, P_HC_7_3,40'b0};
         end
         3'h7 : begin
           u_hccoe1_r <= {P_HC_7_0, P_HC_7_1, P_HC_7_2, P_HC_7_3,40'b0};
           u_hccoe2_r <= {P_HC_0_0, P_HC_0_1, P_HC_0_2, P_HC_0_3,40'b0};
         end
       endcase
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hcoe1_r <= 80'b0;
      u_hcoe2_r <= 80'b0;
    end
    else if( !u_hsl_coe_r[9] ) begin
      u_hcoe1_r <= u_hycoe1_r;
      u_hcoe2_r <= u_hycoe2_r;
    end
    else begin
      u_hcoe1_r <= u_hccoe1_r;
      u_hcoe2_r <= u_hccoe2_r;
    end
  end

  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_v_ysngl_d1_r <= 1'b0;
      u_v_csngl_d1_r <= 1'b0;
    end
    else begin
      u_v_ysngl_d1_r <= u_ref1v_ysngl_r;
      u_v_csngl_d1_r <= u_ref1v_csngl_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hysngl_r <= 1'b0;
    end
    else if( u_vyen_pos_r_s ) begin
      u_hysngl_r <= u_v_ysngl_d1_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hcsngl_r <= 1'b0;
    end
    else if( u_vcen_pos_r_s ) begin
      u_hcsngl_r <= u_v_csngl_d1_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hysngl_d1_r <= 1'b0;
      u_hcsngl_d1_r <= 1'b0;
    end
    else if( u_hff2en_r_s ) begin
      u_hysngl_d1_r <= u_hysngl_r;
      u_hcsngl_d1_r <= u_hcsngl_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_phyen_r <= 2'b0;
    end
    else begin
      u_phyen_r[1] <= u_phyen_r[0];
      u_phyen_r[0] <= u_hopstp_r &
                        (~u_hsl_coe_r[7]) &
                        (u_hslcnt0_r[3:0] < 4'h9) &
                        ((~u_hslcnt0_r[4]) | ( u_hslcnt0_r[4] & (~u_hysngl_d1_r) ));
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_phcen_r <= 2'b0;
    end
    else begin
      u_phcen_r[1] <= u_phcen_r[0];
      u_phcen_r[0] <= u_hopstp_r &
                        u_hsl_coe_r[7] &
                        (u_hslcnt0_r[3:0] < 4'h5) &
                        ((~u_hslcnt0_r[4]) | ( u_hslcnt0_r[4] & (~u_hcsngl_d1_r) ));
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hyen_r <= 1'b0;
      u_hcen_r <= 1'b0;
    end
    else begin
      u_hyen_r <= u_phyen_r[1];
      u_hcen_r <= u_phcen_r[1];
    end
  end
  
endmodule
