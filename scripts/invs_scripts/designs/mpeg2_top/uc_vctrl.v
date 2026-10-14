// ----------------------------------------------
// File: uc_vctrl.v
// Module: uc_vctrl
// Function:Up Convert Vertical Filter Operation
// ----------------------------------------------

module uc_vctrl(
  clkdec,
  rstdec_x,
  c_mbpl_uc_r_s,
  f_ref1yen_r,
  f_ref1cen_r,
  f_vvec1y_r,
  f_vvec2y_r,
  f_vvec1c_r,
  f_vvec2c_r,
  f_hdtvh_r,
  f_prgseq_r,
  f_pred_forward_buc_r,
  f_mttyp_r,
  u_coe1_r,
  u_coe2_r,
  u_ysngl_r,
  u_csngl_r,
  u_ycdtsel_r,
  u_cdtsel_r,
  u_hdtvh_r,
  u_opstp_r,
  u_yeni_r,
  u_ceni_r,
  u_mbpl_r_s
  );
  
  input         clkdec;          
  input         rstdec_x;        
  input         c_mbpl_uc_r_s;   
  input         f_ref1yen_r;     
  input         f_ref1cen_r;     
  input [2:0]   f_vvec1y_r;      
  input [2:0]   f_vvec2y_r;      
  input [1:0]   f_vvec1c_r;      
  input [1:0]   f_vvec2c_r;      
  input         f_hdtvh_r;       
  input         f_prgseq_r;      
  input         f_pred_forward_buc_r;
  input [1:0]   f_mttyp_r;      
  output [39:0] u_coe1_r;       
  output [39:0] u_coe2_r;       
  output        u_ysngl_r;      
  output        u_csngl_r;      
  output        u_ycdtsel_r;    
  output        u_cdtsel_r;     
  output        u_hdtvh_r;      
  output        u_opstp_r;      
  output        u_yeni_r;       
  output        u_ceni_r;       
  output        u_mbpl_r_s;     
    
  wire          c_mbpl_uc_r_s;        // MB Pulse
  wire          f_ref1yen_r;          // MB Data Enable(Y)
  wire          f_ref1cen_r;          // MB Data Enable(C)
  wire [2:0]    f_vvec1y_r;           // MB Vertical Vector1(Y)
  wire [2:0]    f_vvec2y_r;           // MB Vertical Vector2(Y)
  wire [1:0]    f_vvec1c_r;           // MB Vertical Vector1(C)
  wire [1:0]    f_vvec2c_r;           // MB Vertical Vector2(C)
  wire          f_hdtvh_r;            // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  wire          f_prgseq_r;           // MB Interlace/Progressive Select[0:Interlace 1:Progressive]
  wire          f_pred_forward_buc_r; // MB Estimate Valid Flag
  wire [1:0]    f_mttyp_r;            // MB Estimate Mode
  wire          u_yeni_neg_s,         // u_yeni Negedge
                u_ceni_neg_s;         // u_ceni Negedge
  wire          u_mp_neg_s;           // MB Pulse Negedge

  reg [39:0]    u_coe1_r;             // MB Vertical Coefficient1
  reg [39:0]    u_coe2_r;             // MB Vertical Coefficient2
  reg           u_ysngl_r;            // MB Data Single Flag(Y)
  reg           u_csngl_r;            // MB Data Single Flag(C)
  reg           u_ycdtsel_r;          // MB Data Y/C Select
  reg           u_cdtsel_r;           // MB Data Cb/Cr Select
  reg           u_hdtvh_r;            // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  reg           u_opstp_r;            // MB Estimate Valid Flag
  reg           u_yeni_r;             // MB Data Enable(Y)
  reg           u_ceni_r;             // MB Data Enable(C)
  reg           u_mbpl_r_s;           // MB Pulse
  reg [6:0]     u_mbpl_uc_dly_r_s;    // MB Pulse Shift Register
  reg           u_mbpl_d1_r_s;        // MB Pulse 1CLK Delay
  reg           u_mp_neg_r_s;         // MB Pulse Negedge
  reg           u_mp_negd1_r_s;       // u_mp_neg_r_s 1CLK Delay
  reg [2:0]     u_vv1y_r,             // MB Vertical Vector1(Y)
                u_vv1y_d1_r,          // u_vv1y_r 1CLK Delay
                u_vv1y_reg_r;         // MB Vertical Vector1(Y)
  reg [2:0]     u_vv2y_r,             // MB Vertical Vector2(Y)
                u_vv2y_d1_r,          // u_vv2y_r 1CLK Delay
                u_vv2y_reg_r;         // MB Vertical Vector2(Y)
  reg [1:0]     u_vv1c_r,             // MB Vertical Vector1(C)
                u_vv1c_d1_r,          // u_vv1c_r 1CLK Delay
                u_vv1c_reg_r;         // MB Vertical Vector1(C)
  reg [1:0]     u_vv2c_r,             // MB Vertical Vector2(C)
                u_vv2c_d1_r,          // u_vv2c_r 1CLK Delay
                u_vv2c_reg_r;         // MB Vertical Vector2(C)
  reg           u_hd_r,               // HDTV/SDTV Select[0:SDTV 1:HDTV]
                u_vprg_r,             // MB Interlace/Progressive Select[0:Interlace 1:Progressive]
                u_vprg_d1_r,          // u_vprg_r 1CLK Delay
                u_pred_r;             // MB Interlace/Progressive Select[0:Interlace 1:Progressive]
  reg [1:0]     u_mttyp_buc_r;        // MB Estimate Mode
  reg           u_yeni_d1_r,          // u_yeni_r 1CLK Delay
                u_ceni_d1_r,          // u_ceni_r 1CLK Delay
                u_yeni_neg_r_s,       // u_yeni_r Negedge
                u_ceni_neg_r_s;       // u_ceni_r Negedge
  reg [3:0]     u_ycnt_r,             // MB Data Line Counter(Y)
                u_ccnt_r;             // MB Data Line Counter(C)
  reg [3:0]     u_v1_cu_r_s,          // Vector1 Count Up
                u_v2_cu_r_s;          // Vector2 Count Up
  reg           u_v3_cu_r_s,          // Vector3 Count Up
                u_v4_cu_r_s,          // Vector4 Count Up
                u_vc_ld_r_s;          // C Vector Load
  reg [3:0]     u_vvec1_r,            // Vector Counter1
                u_vvec2_r;            // Vector Counter2
  reg [2:0]     u_vvec3_r,            // Vector Counter3
                u_vvec4_r;            // Vector Counter4
  reg [4:0]     u_ytbsel_r;           // Y Top/Bottom Select[0:Top 1:Bottom]
  reg [5:0]     u_ycsel_r;            // Y/C Select[0:Y 1:C]
  reg           u_ctbsel_r;           // C Top/Bottom Select[0:Top 1:Bottom]
  reg [1:0]     u_ctbsel_dly_r;       // u_ctbsel_r Delay
  reg [2:0]     u_yvec_ad_r;          // Y Vector Coefficient Address
  reg [1:0]     u_cvec_ad_r;          // C Vector Coefficient Address
  reg [39:0]    u_ycoe1_r,            // Y Coefficient1
                u_ycoe2_r,            // Y Coefficient2
                u_ccoe1_r,            // C Coefficient1
                u_ccoe2_r;            // C Coefficient2
  reg           u_ycmp1_r,            // Y Vector Compare1
                u_ycmp2_r,            // Y Vector Compare2
                u_ycmp3_r,            // Y Vector Compare3
                u_ycmp4_r,            // Y Vector Compare4
                u_ccmp1_r,            // C Vector Compare1
                u_ccmp2_r,            // C Vector Compare2
                u_ccmp3_r,            // C Vector Compare3
                u_ccmp4_r;            // C Vector Compare4
  reg           u_ytsngl_r,           // Y(Top) Single Flag
                u_ybsngl_r,           // Y(Bottom) Single Flag
                u_ctsngl_r,           // C(Top) Single Flag
                u_cbsngl_r;           // C(Bottom) Single Flag
  
  

  parameter   P_VY_0_0 =10'h130, 
              P_VY_0_1 =10'h3bb, 
              P_VY_0_2 =10'h01e, 
              P_VY_0_3 =10'h3f7,
              P_VY_1_0 =10'h0bc, 
              P_VY_1_1 =10'h05d, 
              P_VY_1_2 =10'h3de, 
              P_VY_1_3 =10'h009, 
              P_VY_2_0 =10'h02f, 
              P_VY_2_1 =10'h0f2, 
              P_VY_2_2 =10'h3d4, 
              P_VY_2_3 =10'h00b, 
              P_VY_3_0 =10'h3e9, 
              P_VY_3_1 =10'h0de, 
              P_VY_3_2 =10'h048, 
              P_VY_3_3 =10'h3f1, 
              P_VY_4_0 =10'h3f1, 
              P_VY_4_1 =10'h048, 
              P_VY_4_2 =10'h0de, 
              P_VY_4_3 =10'h3e9, 
              P_VY_5_0 =10'h00b, 
              P_VY_5_1 =10'h3d4, 
              P_VY_5_2 =10'h0f2, 
              P_VY_5_3 =10'h02f, 
              P_VY_6_0 =10'h009, 
              P_VY_6_1 =10'h3de, 
              P_VY_6_2 =10'h05d, 
              P_VY_6_3 =10'h0bc, 
              P_VY_7_0 =10'h3f7, 
              P_VY_7_1 =10'h01e, 
              P_VY_7_2 =10'h3bb, 
              P_VY_7_3 =10'h130; 
  parameter   P_VC_0_0 =10'h127, 
              P_VC_0_1 =10'h3d9, 
              P_VC_1_0 =10'h0c5, 
              P_VC_1_1 =10'h03b, 
              P_VC_2_0 =10'h03b, 
              P_VC_2_1 =10'h0c5, 
              P_VC_3_0 =10'h3d9, 
              P_VC_3_1 =10'h127;
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_mbpl_uc_dly_r_s <= 7'h00;
      u_mbpl_r_s        <= 1'b0;
      u_mbpl_d1_r_s     <= 1'b0;
      u_mp_negd1_r_s    <= 1'b0;
    end
    else begin
      u_mbpl_uc_dly_r_s <= {u_mbpl_uc_dly_r_s[5:0],c_mbpl_uc_r_s};
      u_mbpl_r_s        <= u_mbpl_uc_dly_r_s[6];
      u_mbpl_d1_r_s     <= u_mbpl_r_s;
      u_mp_negd1_r_s    <= u_mp_neg_r_s;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_mp_neg_r_s <= 1'b0;
    end
    else begin
      u_mp_neg_r_s <= u_mp_neg_s;
    end
  end
  assign u_mp_neg_s = (~u_mbpl_r_s) & u_mbpl_d1_r_s;
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hd_r   <= 1'b0;
      u_vprg_r <= 1'b0;
      u_pred_r <= 1'b0;
      u_mttyp_buc_r <= 2'b0;
    end
    else begin
      u_hd_r   <= f_hdtvh_r;
      u_vprg_r <= f_prgseq_r;
      u_pred_r <= f_pred_forward_buc_r;
      u_mttyp_buc_r <= f_mttyp_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdtvh_r   <= 1'b0;
      u_vprg_d1_r <= 1'b0;
      u_opstp_r   <= 1'b0;
    end
    else if ( u_mp_neg_s ) begin
      u_hdtvh_r   <= u_hd_r;
      u_vprg_d1_r <= u_vprg_r;
      u_opstp_r   <= (u_mttyp_buc_r == 2'h3) | u_pred_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vv1y_r <= 3'b0;
      u_vv2y_r <= 3'b0;
      u_vv1c_r <= 2'b0;
      u_vv2c_r <= 2'b0;
    end
    else begin
      u_vv1y_r <= f_vvec1y_r;
      u_vv2y_r <= f_vvec2y_r;
      u_vv1c_r <= f_vvec1c_r;
      u_vv2c_r <= f_vvec2c_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vv1y_d1_r <= 3'b0;
      u_vv2y_d1_r <= 3'b0;
      u_vv1c_d1_r <= 3'b0;
      u_vv2c_d1_r <= 3'b0;
    end
    else if( !u_vprg_d1_r ) begin
      u_vv1y_d1_r <= u_vv1y_r;
      u_vv2y_d1_r <= u_vv2y_r;
      u_vv1c_d1_r <= u_vv1c_r;
      u_vv2c_d1_r <= u_vv2c_r;
    end
    else begin
      u_vv1y_d1_r <= {u_vv1y_r[1:0],1'b0};
      u_vv2y_d1_r <= {u_vv2y_r[1:0],1'b1};
      u_vv1c_d1_r <= {u_vv1c_r[0],1'b0};
      u_vv2c_d1_r <= {u_vv2c_r[0],1'b1};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_yeni_r    <= 1'b0;
      u_ceni_r    <= 1'b0;
      u_yeni_d1_r <= 1'b0;
      u_ceni_d1_r <= 1'b0;
      u_yeni_neg_r_s <= 1'b0;
      u_ceni_neg_r_s <= 1'b0;
    end
    else begin
      u_yeni_r    <= f_ref1yen_r;
      u_ceni_r    <= f_ref1cen_r;
      u_yeni_d1_r <= u_yeni_r;
      u_ceni_d1_r <= u_ceni_r;
      u_yeni_neg_r_s <= u_yeni_neg_s ;
      u_ceni_neg_r_s <= u_ceni_neg_s ;
    end
  end

  assign u_yeni_neg_s = (~u_yeni_r) & u_yeni_d1_r;
  assign u_ceni_neg_s = (~u_ceni_r) & u_ceni_d1_r;
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ycnt_r <= 4'hf;
    end
    else if( u_mbpl_d1_r_s ) begin
      u_ycnt_r <= 4'h0;
    end
    else if( u_yeni_neg_r_s ) begin
      u_ycnt_r <= u_ycnt_r + 1'b1;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ccnt_r <= 4'hf;
    end
    else if( u_mbpl_d1_r_s ) begin
      u_ccnt_r <= 4'h0;
    end
    else if( u_ceni_neg_r_s ) begin
      u_ccnt_r <= u_ccnt_r + 1'b1;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_v1_cu_r_s <= 4'h0;
      u_v2_cu_r_s <= 4'h0;
    end
    else begin
      u_v1_cu_r_s[3:1] <= u_v1_cu_r_s[2:0];
      u_v1_cu_r_s[0]   <= u_yeni_neg_r_s & (~(u_ycnt_r > 4'h4));
      u_v2_cu_r_s[3:1] <= u_v2_cu_r_s[2:0];
      u_v2_cu_r_s[0]   <= u_yeni_neg_r_s & (u_ycnt_r > 4'h4);
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_v3_cu_r_s <= 1'b0;
      u_v4_cu_r_s <= 1'b0;
      u_vc_ld_r_s <= 1'b0;
    end
    else begin
      u_v3_cu_r_s <= u_ceni_neg_r_s & (~(((u_ccnt_r > 4'h2) & (u_ccnt_r < 4'h6)) | (u_ccnt_r > 4'h8)));
      u_v4_cu_r_s <= u_ceni_neg_r_s & (((u_ccnt_r > 4'h2) & (u_ccnt_r < 4'h6)) | (u_ccnt_r > 4'h8));
      u_vc_ld_r_s <= u_ceni_neg_r_s & (u_ccnt_r == 4'h5);
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vv1y_reg_r <= 3'b0;
      u_vv2y_reg_r <= 3'b0;
      u_vv1c_reg_r <= 3'b0;
      u_vv2c_reg_r <= 3'b0;
    end
    else if( u_mp_negd1_r_s ) begin
      u_vv1y_reg_r <= u_vv1y_d1_r;
      u_vv2y_reg_r <= u_vv2y_d1_r;
      u_vv1c_reg_r <= u_vv1c_d1_r;
      u_vv2c_reg_r <= u_vv2c_d1_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vvec1_r <= 4'b0;
    end
    else if( u_mp_negd1_r_s ) begin
      u_vvec1_r <= {1'b0,u_vv1y_d1_r};
    end
    else if( u_vvec1_r == 4'h7 && u_v1_cu_r_s[3] ) begin
      u_vvec1_r <= 4'h8;
    end
    else if( u_v1_cu_r_s[3] ) begin
      u_vvec1_r <= u_vvec1_r + 2'b10;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vvec2_r <= 4'b0;
    end
    else if( u_mp_negd1_r_s ) begin
      u_vvec2_r <= {1'b0,u_vv2y_d1_r};
    end
    else if( u_vvec2_r == 4'h7 && u_v2_cu_r_s[3] ) begin
      u_vvec2_r <= 4'h8;
    end
    else if( u_v2_cu_r_s[3] ) begin
      u_vvec2_r <= u_vvec2_r + 2'b10;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vvec3_r <= 3'b0;
    end
    else if( u_mp_negd1_r_s || u_vc_ld_r_s ) begin
      u_vvec3_r <= {1'b0,u_vv1c_d1_r};
    end
    else if( u_vvec3_r == 3'h3 && u_v3_cu_r_s ) begin
      u_vvec3_r <= 3'h4;
    end
    else if( u_v3_cu_r_s ) begin
      u_vvec3_r <= u_vvec3_r + 2'b10;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vvec4_r <= 3'b0;
    end
    else if( u_mp_negd1_r_s || u_vc_ld_r_s ) begin
      u_vvec4_r <= {1'b0,u_vv2c_d1_r};
    end
    else if( u_vvec4_r == 3'h3 && u_v4_cu_r_s ) begin
      u_vvec4_r <= 3'h4;
    end
    else if( u_v4_cu_r_s ) begin
      u_vvec4_r <= u_vvec4_r + 2'b10;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ytbsel_r <= 5'h0;
    end
    else begin
      u_ytbsel_r[4:1] <= u_ytbsel_r[3:0];
      u_ytbsel_r[0]   <= ( u_ycnt_r > 4'h4 );
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ycdtsel_r <= 1'b0;
    end
    else begin
      u_ycdtsel_r <= (u_ycnt_r == 4'ha );
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ycsel_r <= 6'b0;
    end
    else begin
      u_ycsel_r <= {u_ycsel_r[5:0],u_ycdtsel_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ctbsel_r <= 1'b0;
    end
    else begin
      u_ctbsel_r <= ((u_ccnt_r > 4'h2 && u_ccnt_r < 4'h6) || u_ccnt_r > 4'h8);
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ctbsel_dly_r <= 2'h0;
    end
    else begin
      u_ctbsel_dly_r <= {u_ctbsel_dly_r[0],u_ctbsel_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_cdtsel_r <= 1'b0;
    end
    else begin
      u_cdtsel_r <= (u_ccnt_r > 4'h5);
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_yvec_ad_r <= 3'h0;
    end
    else if( !u_ytbsel_r[4] ) begin
      u_yvec_ad_r <= u_vvec1_r[2:0];
    end
    else begin
      u_yvec_ad_r <= u_vvec2_r[2:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_cvec_ad_r <= 2'h0;
    end
    else if( !u_ctbsel_r ) begin
      u_cvec_ad_r <= u_vvec3_r[1:0];
    end
    else begin
      u_cvec_ad_r <= u_vvec4_r[1:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ycoe1_r <= 40'h0;
      u_ycoe2_r <= 40'h0;
    end
    else begin
      case( u_yvec_ad_r )
        3'h0 : begin
          u_ycoe1_r <= {P_VY_0_0,P_VY_0_1,P_VY_0_2,P_VY_0_3};
          u_ycoe2_r <= {P_VY_1_0,P_VY_1_1,P_VY_1_2,P_VY_1_3};
        end
        3'h1 : begin
          u_ycoe1_r <= {P_VY_1_0,P_VY_1_1,P_VY_1_2,P_VY_1_3};
          u_ycoe2_r <= {P_VY_2_0,P_VY_2_1,P_VY_2_2,P_VY_2_3};
        end
        3'h2 : begin
          u_ycoe1_r <= {P_VY_2_0,P_VY_2_1,P_VY_2_2,P_VY_2_3};
          u_ycoe2_r <= {P_VY_3_0,P_VY_3_1,P_VY_3_2,P_VY_3_3};
        end
        3'h3 : begin
          u_ycoe1_r <= {P_VY_3_0,P_VY_3_1,P_VY_3_2,P_VY_3_3};
          u_ycoe2_r <= {P_VY_4_0,P_VY_4_1,P_VY_4_2,P_VY_4_3};
        end
        3'h4 : begin
          u_ycoe1_r <= {P_VY_4_0,P_VY_4_1,P_VY_4_2,P_VY_4_3};
          u_ycoe2_r <= {P_VY_5_0,P_VY_5_1,P_VY_5_2,P_VY_5_3};
        end
        3'h5 : begin
          u_ycoe1_r <= {P_VY_5_0,P_VY_5_1,P_VY_5_2,P_VY_5_3};
          u_ycoe2_r <= {P_VY_6_0,P_VY_6_1,P_VY_6_2,P_VY_6_3};
        end
        3'h6 : begin
          u_ycoe1_r <= {P_VY_6_0,P_VY_6_1,P_VY_6_2,P_VY_6_3};
          u_ycoe2_r <= {P_VY_7_0,P_VY_7_1,P_VY_7_2,P_VY_7_3};
        end
        3'h7 : begin
          u_ycoe1_r <= {P_VY_7_0,P_VY_7_1,P_VY_7_2,P_VY_7_3};
          u_ycoe2_r <= 40'h0;
        end
      endcase
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ccoe1_r <= 40'h0;
      u_ccoe2_r <= 40'h0;
    end
    else begin
      case( u_cvec_ad_r )
        2'b00 : begin
          u_ccoe1_r <= {P_VC_0_0,P_VC_0_1,20'h0};
          u_ccoe2_r <= {P_VC_1_0,P_VC_1_1,20'h0};
        end
        2'b01 : begin
          u_ccoe1_r <= {P_VC_1_0,P_VC_1_1,20'h0};
          u_ccoe2_r <= {P_VC_2_0,P_VC_2_1,20'h0};
        end
        2'b10 : begin
          u_ccoe1_r <= {P_VC_2_0,P_VC_2_1,20'h0};
          u_ccoe2_r <= {P_VC_3_0,P_VC_3_1,20'h0};
        end
        2'b11 : begin
          u_ccoe1_r <= {P_VC_3_0,P_VC_3_1,20'h0};
          u_ccoe2_r <= 40'h0;
        end
      endcase
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_coe1_r <= 40'h0;
      u_coe2_r <= 40'h0;
    end
    else if( !u_ycsel_r[5] ) begin
      u_coe1_r <= u_ycoe1_r;
      u_coe2_r <= u_ycoe2_r;
    end
    else begin
      u_coe1_r <= u_ccoe1_r;
      u_coe2_r <= u_ccoe2_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ycmp1_r <= 1'b0;
      u_ycmp2_r <= 1'b0;
      u_ycmp3_r <= 1'b0;
      u_ycmp4_r <= 1'b0;
    end
    else begin
      u_ycmp1_r <= ((u_vvec1_r[2:0] == u_vv1y_reg_r) && u_vvec1_r[3]);
      u_ycmp2_r <= (u_vvec1_r == 4'h7);
      u_ycmp3_r <= ((u_vvec2_r[2:0] == u_vv2y_reg_r) && u_vvec2_r[3]);
      u_ycmp4_r <= (u_vvec2_r == 4'h7);
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ccmp1_r <= 1'b0;
      u_ccmp2_r <= 1'b0;
      u_ccmp3_r <= 1'b0;
      u_ccmp4_r <= 1'b0;
    end
    else begin
      u_ccmp1_r <= ((u_vvec3_r[1:0] == u_vv1c_reg_r) && u_vvec3_r[2]);
      u_ccmp2_r <= (u_vvec3_r == 3'h3);
      u_ccmp3_r <= ((u_vvec4_r[1:0] == u_vv2c_reg_r) && u_vvec4_r[2]);
      u_ccmp4_r <= (u_vvec4_r == 3'h3);
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ytsngl_r <= 1'b0;
    end
    else if( !u_vv1y_reg_r[0] ) begin
      u_ytsngl_r <= u_ycmp1_r;
    end
    else begin
      u_ytsngl_r <= u_ycmp2_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ybsngl_r <= 1'b0;
    end
    else if( !u_vv2y_reg_r[0] ) begin
      u_ybsngl_r <= u_ycmp3_r;
    end
    else begin
      u_ybsngl_r <= u_ycmp4_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ctsngl_r <= 1'b0;
    end
    else if( !u_vv1c_reg_r[0] ) begin
      u_ctsngl_r <= u_ccmp1_r;
    end
    else begin
      u_ctsngl_r <= u_ccmp2_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_cbsngl_r <= 1'b0;
    end
    else if( !u_vv2c_reg_r[0] ) begin
      u_cbsngl_r <= u_ccmp3_r;
    end
    else begin
      u_cbsngl_r <= u_ccmp4_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ysngl_r <= 1'b0;
    end
    else if( !u_ytbsel_r[4] ) begin
      u_ysngl_r <= u_ytsngl_r;
    end
    else begin
      u_ysngl_r <= u_ybsngl_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_csngl_r <= 1'b0;
    end
    else if( !u_ctbsel_dly_r[1] ) begin
      u_csngl_r <= u_ctsngl_r;
    end
    else begin
      u_csngl_r <= u_cbsngl_r;
    end
  end
  
endmodule
