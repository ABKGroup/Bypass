// ----------------------------------------------
// File: uc_hdtdep.v
// Module: uc_hdtdep
// Function:Up Convert Horizontal Filater Data
// ----------------------------------------------

module uc_hdtdep(
  clkdec,
  rstdec_x,  
  u_vyen_d1_r,
  u_vcen_d1_r,
  u_ref1v_dt_r,
  u_hff2en_r_s,
  u_hdt_sl1_r,
  u_hdt_sl2_r,
  u_hdt_sl3_r,
  u_hdt_msk_r,
  u_refhdt1_r,
  u_refhdt2_r,
  u_sdtvdth_r
  );
  
  input         clkdec;         
  input         rstdec_x;       
  input         u_vyen_d1_r;    
  input         u_vcen_d1_r;    
  input [15:0]  u_ref1v_dt_r;   
  input         u_hff2en_r_s;   
  input         u_hdt_sl1_r;    
  input         u_hdt_sl2_r;    
  input         u_hdt_sl3_r;    
  input         u_hdt_msk_r;    
  output [63:0] u_refhdt1_r;    
  output [63:0] u_refhdt2_r;    
  output [15:0] u_sdtvdth_r;    

  wire          u_vyen_d1_r;          // MB Data Enable(Y)
  wire          u_vcen_d1_r;          // MB Data Eneble(C)
  wire [15:0]   u_ref1v_dt_r;         // MB Data
  wire          u_hff2en_r_s;         // MB Data Latch Enable
  wire          u_hdt_sl1_r;          // MB Data Select1
  wire          u_hdt_sl2_r;          // MB Data Select2
  wire          u_hdt_sl3_r;          // MB Data Select3
  wire          u_hdt_msk_r;          // Output Data Lower Byte Dummy Mask

  reg [63:0]    u_refhdt1_r;          // MB Horizontal Filter Data1
  reg [63:0]    u_refhdt2_r;          // MB Horizontal Filter Data2
  reg [15:0]    u_sdtvdth_r;          // MB STDV Data
  reg [15:0]    u_sdtvdth_d1_r;       // MB STDV Data
  reg [3:0]     u_hdt_cnt;            // Horizontal Data Counter
  reg           u_hcnt_dc0_r_s,       // Horizontal Data Counter Decode(0h)
                u_hcnt_dc1_r_s,       // Horizontal Data Counter Decode(1h)
                u_hcnt_dc2_r_s,       // Horizontal Data Counter Decode(2h)
                u_hcnt_dc3_r_s,       // Horizontal Data Counter Decode(3h)
                u_hcnt_dc4_r_s,       // Horizontal Data Counter Decode(4h)
                u_hcnt_dc5_r_s,       // Horizontal Data Counter Decode(5h)
                u_hcnt_dc6_r_s,       // Horizontal Data Counter Decode(6h)
                u_hcnt_dc7_r_s,       // Horizontal Data Counter Decode(7h)
                u_hcnt_dc8_r_s,       // Horizontal Data Counter Decode(8h)
                u_hcnt_dc9_r_s,       // Horizontal Data Counter Decode(9h)
                u_hcnt_dca_r_s,       // Horizontal Data Counter Decode(ah)
                u_hcnt_dcb_r_s,       // Horizontal Data Counter Decode(bh)
                u_hcnt_dcc_r_s,       // Horizontal Data Counter Decode(ch)
                u_hcnt_dcd_r_s,       // Horizontal Data Counter Decode(dh)
                u_hcnt_dce_r_s,       // Horizontal Data Counter Decode(eh)
                u_hcnt_dcf_r_s;       // Horizontal Data Counter Decode(fh)
  reg [7:0]     u_hdtl0_f1_r,         // Horizontal Data Pixel 0 Left
                u_hdtl1_f1_r,         // Horizontal Data Pixel 1 Left
                u_hdtl2_f1_r,         // Horizontal Data Pixel 2 Left
                u_hdtl3_f1_r,         // Horizontal Data Pixel 3 Left
                u_hdtl4_f1_r,         // Horizontal Data Pixel 4 Left
                u_hdtl5_f1_r,         // Horizontal Data Pixel 5 Left
                u_hdtl6_f1_r,         // Horizontal Data Pixel 6 Left
                u_hdtl7_f1_r;         // Horizontal Data Pixel 7 Left
  reg [7:0]     u_hdtl8_f1_r,         // Horizontal Data Pixel 8 Left
                u_hdtl9_f1_r,         // Horizontal Data Pixel 9 Left
                u_hdtla_f1_r,         // Horizontal Data Pixel a Left
                u_hdtlb_f1_r,         // Horizontal Data Pixel b Left
                u_hdtlc_f1_r,         // Horizontal Data Pixel c Left
                u_hdtld_f1_r,         // Horizontal Data Pixel d Left
                u_hdtle_f1_r,         // Horizontal Data Pixel e Left
                u_hdtlf_f1_r;         // Horizontal Data Pixel f Left
  reg [7:0]     u_hdtr0_f1_r,         // Horizontal Data Pixel 0 Right
                u_hdtr1_f1_r,         // Horizontal Data Pixel 1 Right
                u_hdtr2_f1_r,         // Horizontal Data Pixel 2 Right
                u_hdtr3_f1_r,         // Horizontal Data Pixel 3 Right
                u_hdtr4_f1_r,         // Horizontal Data Pixel 4 Right
                u_hdtr5_f1_r,         // Horizontal Data Pixel 5 Right
                u_hdtr6_f1_r,         // Horizontal Data Pixel 6 Right
                u_hdtr7_f1_r;         // Horizontal Data Pixel 7 Right
  reg [7:0]     u_hdtr8_f1_r,         // Horizontal Data Pixel 8 Right
                u_hdtr9_f1_r,         // Horizontal Data Pixel 9 Right
                u_hdtra_f1_r,         // Horizontal Data Pixel a Right
                u_hdtrb_f1_r,         // Horizontal Data Pixel b Right
                u_hdtrc_f1_r,         // Horizontal Data Pixel c Right
                u_hdtrd_f1_r,         // Horizontal Data Pixel d Right
                u_hdtre_f1_r,         // Horizontal Data Pixel e Right
                u_hdtrf_f1_r;         // Horizontal Data Pixel f Right
  reg [7:0]     u_hdtl0_r,            // Horizontal Data Pixel 0 Left
                u_hdtl1_r,            // Horizontal Data Pixel 1 Left
                u_hdtl2_r,            // Horizontal Data Pixel 2 Left
                u_hdtl3_r,            // Horizontal Data Pixel 3 Left
                u_hdtl4_r,            // Horizontal Data Pixel 4 Left
                u_hdtl5_r,            // Horizontal Data Pixel 5 Left
                u_hdtl6_r,            // Horizontal Data Pixel 6 Left
                u_hdtl7_r;            // Horizontal Data Pixel 7 Left
  reg [7:0]     u_hdtl8_r,            // Horizontal Data Pixel 8 Left
                u_hdtl9_r,            // Horizontal Data Pixel 9 Left
                u_hdtla_r,            // Horizontal Data Pixel a Left
                u_hdtlb_r,            // Horizontal Data Pixel b Left
                u_hdtlc_r,            // Horizontal Data Pixel c Left
                u_hdtld_r,            // Horizontal Data Pixel d Left
                u_hdtle_r,            // Horizontal Data Pixel e Left
                u_hdtlf_r;            // Horizontal Data Pixel f Left
  reg [7:0]     u_hdtr0_r,            // Horizontal Data Pixel 0 Right
                u_hdtr1_r,            // Horizontal Data Pixel 1 Right
                u_hdtr2_r,            // Horizontal Data Pixel 2 Right
                u_hdtr3_r,            // Horizontal Data Pixel 3 Right
                u_hdtr4_r,            // Horizontal Data Pixel 4 Right
                u_hdtr5_r,            // Horizontal Data Pixel 5 Right
                u_hdtr6_r,            // Horizontal Data Pixel 6 Right
                u_hdtr7_r;            // Horizontal Data Pixel 7 Right
  reg [7:0]     u_hdtr8_r,            // Horizontal Data Pixel 8 Right
                u_hdtr9_r,            // Horizontal Data Pixel 9 Right
                u_hdtra_r,            // Horizontal Data Pixel a Right
                u_hdtrb_r,            // Horizontal Data Pixel b Right
                u_hdtrc_r,            // Horizontal Data Pixel c Right
                u_hdtrd_r,            // Horizontal Data Pixel d Right
                u_hdtre_r,            // Horizontal Data Pixel e Right
                u_hdtrf_r;            // Horizontal Data Pixel f Right
  reg [63:0]    u_hdtlu_r,            // Horizontal Data Left Upper
                u_hdtll_r,            // Horizontal Data Left Lower
                u_hdtru_r,            // Horizontal Data Right Upper
                u_hdtrl_r;            // Horizontal Data Right Lower
  reg [63:0]    u_hsldtu1_r,          // Horizontal Data Upper1
                u_hsldtl1_r,          // Horizontal Data Lower1
                u_hsldtu2_r,          // Horizontal Data Upper2
                u_hsldtl2_r;          // Horizontal Data Lower2
  
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_sdtvdth_r    <= 16'b0;
      u_sdtvdth_d1_r <= 16'b0;
    end
    else begin
      u_sdtvdth_r    <= u_ref1v_dt_r;
      u_sdtvdth_d1_r <= u_sdtvdth_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdt_cnt <= 4'h0;
    end
    else if( !(u_vyen_d1_r || u_vcen_d1_r) ) begin
      u_hdt_cnt <= 4'h0;
    end
    else if( u_vcen_d1_r && ( u_hdt_cnt == 4'hb ) ) begin
      u_hdt_cnt <= 4'h0;
    end
    else if( u_vcen_d1_r && ( u_hdt_cnt == 4'h3 ) ) begin
      u_hdt_cnt <= 4'h8;
    end
    else begin
      u_hdt_cnt <= u_hdt_cnt + 1'b1;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hcnt_dc0_r_s <= 1'b0;
    end
    else if( u_vyen_d1_r || u_vcen_d1_r ) begin
      u_hcnt_dc0_r_s <= ( u_hdt_cnt == 4'h0 );
    end
    else begin
      u_hcnt_dc0_r_s <= 1'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hcnt_dc1_r_s <= 1'b0;
    end
    else if( u_vyen_d1_r || u_vcen_d1_r ) begin
      u_hcnt_dc1_r_s <= ( u_hdt_cnt == 4'h1 );
    end
    else begin
      u_hcnt_dc1_r_s <= 1'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hcnt_dc2_r_s <= 1'b0;
    end
    else if( u_vyen_d1_r || u_vcen_d1_r ) begin
      u_hcnt_dc2_r_s <= ( u_hdt_cnt == 4'h2 );
    end
    else begin
      u_hcnt_dc2_r_s <= 1'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hcnt_dc3_r_s <= 1'b0;
    end
    else if( u_vyen_d1_r || u_vcen_d1_r ) begin
      u_hcnt_dc3_r_s <= ( u_hdt_cnt == 4'h3 );
    end
    else begin
      u_hcnt_dc3_r_s <= 1'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hcnt_dc4_r_s <= 1'b0;
    end
    else if( u_vyen_d1_r || u_vcen_d1_r ) begin
      u_hcnt_dc4_r_s <= ( u_hdt_cnt == 4'h4 );
    end
    else begin
      u_hcnt_dc4_r_s <= 1'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hcnt_dc5_r_s <= 1'b0;
    end
    else if( u_vyen_d1_r || u_vcen_d1_r ) begin
      u_hcnt_dc5_r_s <= ( u_hdt_cnt == 4'h5 );
    end
    else begin
      u_hcnt_dc5_r_s <= 1'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hcnt_dc6_r_s <= 1'b0;
    end
    else if( u_vyen_d1_r || u_vcen_d1_r ) begin
      u_hcnt_dc6_r_s <= ( u_hdt_cnt == 4'h6 );
    end
    else begin
      u_hcnt_dc6_r_s <= 1'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hcnt_dc7_r_s <= 1'b0;
    end
    else if( u_vyen_d1_r || u_vcen_d1_r ) begin
      u_hcnt_dc7_r_s <= ( u_hdt_cnt == 4'h7 );
    end
    else begin
      u_hcnt_dc7_r_s <= 1'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hcnt_dc8_r_s <= 1'b0;
    end
    else if( u_vyen_d1_r || u_vcen_d1_r ) begin
      u_hcnt_dc8_r_s <= ( u_hdt_cnt == 4'h8 );
    end
    else begin
      u_hcnt_dc8_r_s <= 1'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hcnt_dc9_r_s <= 1'b0;
    end
    else if( u_vyen_d1_r || u_vcen_d1_r ) begin
      u_hcnt_dc9_r_s <= ( u_hdt_cnt == 4'h9 );
    end
    else begin
      u_hcnt_dc9_r_s <= 1'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hcnt_dca_r_s <= 1'b0;
    end
    else if( u_vyen_d1_r || u_vcen_d1_r ) begin
      u_hcnt_dca_r_s <= ( u_hdt_cnt == 4'ha );
    end
    else begin
      u_hcnt_dca_r_s <= 1'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hcnt_dcb_r_s <= 1'b0;
    end
    else if( u_vyen_d1_r || u_vcen_d1_r ) begin
      u_hcnt_dcb_r_s <= ( u_hdt_cnt == 4'hb );
    end
    else begin
      u_hcnt_dcb_r_s <= 1'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hcnt_dcc_r_s <= 1'b0;
    end
    else if( u_vyen_d1_r || u_vcen_d1_r ) begin
      u_hcnt_dcc_r_s <= ( u_hdt_cnt == 4'hc );
    end
    else begin
      u_hcnt_dcc_r_s <= 1'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hcnt_dcd_r_s <= 1'b0;
    end
    else if( u_vyen_d1_r || u_vcen_d1_r ) begin
      u_hcnt_dcd_r_s <= ( u_hdt_cnt == 4'hd );
    end
    else begin
      u_hcnt_dcd_r_s <= 1'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hcnt_dce_r_s <= 1'b0;
    end
    else if( u_vyen_d1_r || u_vcen_d1_r ) begin
      u_hcnt_dce_r_s <= ( u_hdt_cnt == 4'he );
    end
    else begin
      u_hcnt_dce_r_s <= 1'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hcnt_dcf_r_s <= 1'b0;
    end
    else if( u_vyen_d1_r || u_vcen_d1_r ) begin
      u_hcnt_dcf_r_s <= ( u_hdt_cnt == 4'hf );
    end
    else begin
      u_hcnt_dcf_r_s <= 1'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdtl0_f1_r <= 8'b0;
      u_hdtl8_f1_r <= 8'b0;
    end
    else if( u_hcnt_dc0_r_s ) begin
      u_hdtl0_f1_r <= u_sdtvdth_d1_r[15:8];
      u_hdtl8_f1_r <= u_sdtvdth_d1_r[7:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdtl1_f1_r <= 8'b0;
      u_hdtl9_f1_r <= 8'b0;
    end
    else if( u_hcnt_dc1_r_s ) begin
      u_hdtl1_f1_r <= u_sdtvdth_d1_r[15:8];
      u_hdtl9_f1_r <= u_sdtvdth_d1_r[7:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdtl2_f1_r <= 8'b0;
      u_hdtla_f1_r <= 8'b0;
    end
    else if( u_hcnt_dc2_r_s ) begin
      u_hdtl2_f1_r <= u_sdtvdth_d1_r[15:8];
      u_hdtla_f1_r <= u_sdtvdth_d1_r[7:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdtl3_f1_r <= 8'b0;
      u_hdtlb_f1_r <= 8'b0;
    end
    else if( u_hcnt_dc3_r_s ) begin
      u_hdtl3_f1_r <= u_sdtvdth_d1_r[15:8];
      u_hdtlb_f1_r <= u_sdtvdth_d1_r[7:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdtl4_f1_r <= 8'b0;
      u_hdtlc_f1_r <= 8'b0;
    end
    else if( u_hcnt_dc4_r_s ) begin
      u_hdtl4_f1_r <= u_sdtvdth_d1_r[15:8];
      u_hdtlc_f1_r <= u_sdtvdth_d1_r[7:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdtl5_f1_r <= 8'b0;
      u_hdtld_f1_r <= 8'b0;
    end
    else if( u_hcnt_dc5_r_s ) begin
      u_hdtl5_f1_r <= u_sdtvdth_d1_r[15:8];
      u_hdtld_f1_r <= u_sdtvdth_d1_r[7:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdtl6_f1_r <= 8'b0;
      u_hdtle_f1_r <= 8'b0;
    end
    else if( u_hcnt_dc6_r_s ) begin
      u_hdtl6_f1_r <= u_sdtvdth_d1_r[15:8];
      u_hdtle_f1_r <= u_sdtvdth_d1_r[7:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdtl7_f1_r <= 8'b0;
      u_hdtlf_f1_r <= 8'b0;
    end
    else if( u_hcnt_dc7_r_s ) begin
      u_hdtl7_f1_r <= u_sdtvdth_d1_r[15:8];
      u_hdtlf_f1_r <= u_sdtvdth_d1_r[7:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdtr0_f1_r <= 8'b0;
      u_hdtr8_f1_r <= 8'b0;
    end
    else if( u_hcnt_dc8_r_s ) begin
      u_hdtr0_f1_r <= u_sdtvdth_d1_r[15:8];
      u_hdtr8_f1_r <= u_sdtvdth_d1_r[7:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdtr1_f1_r <= 8'b0;
      u_hdtr9_f1_r <= 8'b0;
    end
    else if( u_hcnt_dc9_r_s ) begin
      u_hdtr1_f1_r <= u_sdtvdth_d1_r[15:8];
      u_hdtr9_f1_r <= u_sdtvdth_d1_r[7:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdtr2_f1_r <= 8'b0;
      u_hdtra_f1_r <= 8'b0;
    end
    else if( u_hcnt_dca_r_s ) begin
      u_hdtr2_f1_r <= u_sdtvdth_d1_r[15:8];
      u_hdtra_f1_r <= u_sdtvdth_d1_r[7:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdtr3_f1_r <= 8'b0;
      u_hdtrb_f1_r <= 8'b0;
    end
    else if( u_hcnt_dcb_r_s ) begin
      u_hdtr3_f1_r <= u_sdtvdth_d1_r[15:8];
      u_hdtrb_f1_r <= u_sdtvdth_d1_r[7:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdtr4_f1_r <= 8'b0;
      u_hdtrc_f1_r <= 8'b0;
    end
    else if( u_hcnt_dcc_r_s ) begin
      u_hdtr4_f1_r <= u_sdtvdth_d1_r[15:8];
      u_hdtrc_f1_r <= u_sdtvdth_d1_r[7:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdtr5_f1_r <= 8'b0;
      u_hdtrd_f1_r <= 8'b0;
    end
    else if( u_hcnt_dcd_r_s ) begin
      u_hdtr5_f1_r <= u_sdtvdth_d1_r[15:8];
      u_hdtrd_f1_r <= u_sdtvdth_d1_r[7:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdtr6_f1_r <= 8'b0;
      u_hdtre_f1_r <= 8'b0;
    end
    else if( u_hcnt_dce_r_s ) begin
      u_hdtr6_f1_r <= u_sdtvdth_d1_r[15:8];
      u_hdtre_f1_r <= u_sdtvdth_d1_r[7:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdtr7_f1_r <= 8'b0;
      u_hdtrf_f1_r <= 8'b0;
    end
    else if( u_hcnt_dcf_r_s ) begin
      u_hdtr7_f1_r <= u_sdtvdth_d1_r[15:8];
      u_hdtrf_f1_r <= u_sdtvdth_d1_r[7:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdtl0_r <= 8'b0;
      u_hdtl1_r <= 8'b0;
      u_hdtl2_r <= 8'b0;
      u_hdtl3_r <= 8'b0;
      u_hdtl4_r <= 8'b0;
      u_hdtl5_r <= 8'b0;
      u_hdtl6_r <= 8'b0;
      u_hdtl7_r <= 8'b0;
      u_hdtl8_r <= 8'b0;
      u_hdtl9_r <= 8'b0;
      u_hdtla_r <= 8'b0;
      u_hdtlb_r <= 8'b0;
      u_hdtlc_r <= 8'b0;
      u_hdtld_r <= 8'b0;
      u_hdtle_r <= 8'b0;
      u_hdtlf_r <= 8'b0;
      u_hdtr0_r <= 8'b0;
      u_hdtr1_r <= 8'b0;
      u_hdtr2_r <= 8'b0;
      u_hdtr3_r <= 8'b0;
      u_hdtr4_r <= 8'b0;
      u_hdtr5_r <= 8'b0;
      u_hdtr6_r <= 8'b0;
      u_hdtr7_r <= 8'b0;
      u_hdtr8_r <= 8'b0;
      u_hdtr9_r <= 8'b0;
      u_hdtra_r <= 8'b0;
      u_hdtrb_r <= 8'b0;
      u_hdtrc_r <= 8'b0;
      u_hdtrd_r <= 8'b0;
      u_hdtre_r <= 8'b0;
      u_hdtrf_r <= 8'b0;
    end
    else if( u_hff2en_r_s ) begin
      u_hdtl0_r <= u_hdtl0_f1_r;
      u_hdtl1_r <= u_hdtl1_f1_r;
      u_hdtl2_r <= u_hdtl2_f1_r;
      u_hdtl3_r <= u_hdtl3_f1_r;
      u_hdtl4_r <= u_hdtl4_f1_r;
      u_hdtl5_r <= u_hdtl5_f1_r;
      u_hdtl6_r <= u_hdtl6_f1_r;
      u_hdtl7_r <= u_hdtl7_f1_r;
      u_hdtl8_r <= u_hdtl8_f1_r;
      u_hdtl9_r <= u_hdtl9_f1_r;
      u_hdtla_r <= u_hdtla_f1_r;
      u_hdtlb_r <= u_hdtlb_f1_r;
      u_hdtlc_r <= u_hdtlc_f1_r;
      u_hdtld_r <= u_hdtld_f1_r;
      u_hdtle_r <= u_hdtle_f1_r;
      u_hdtlf_r <= u_hdtlf_f1_r;
      u_hdtr0_r <= u_hdtr0_f1_r;
      u_hdtr1_r <= u_hdtr1_f1_r;
      u_hdtr2_r <= u_hdtr2_f1_r;
      u_hdtr3_r <= u_hdtr3_f1_r;
      u_hdtr4_r <= u_hdtr4_f1_r;
      u_hdtr5_r <= u_hdtr5_f1_r;
      u_hdtr6_r <= u_hdtr6_f1_r;
      u_hdtr7_r <= u_hdtr7_f1_r;
      u_hdtr8_r <= u_hdtr8_f1_r;
      u_hdtr9_r <= u_hdtr9_f1_r;
      u_hdtra_r <= u_hdtra_f1_r;
      u_hdtrb_r <= u_hdtrb_f1_r;
      u_hdtrc_r <= u_hdtrc_f1_r;
      u_hdtrd_r <= u_hdtrd_f1_r;
      u_hdtre_r <= u_hdtre_f1_r;
      u_hdtrf_r <= u_hdtrf_f1_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdtlu_r <= 64'b0;
      u_hdtll_r <= 64'b0;
      u_hdtru_r <= 64'b0;
      u_hdtrl_r <= 64'b0;
    end
    else begin
      u_hdtlu_r <= {u_hdtl0_r,u_hdtl1_r,u_hdtl2_r,u_hdtl3_r,
                      u_hdtl4_r,u_hdtl5_r,u_hdtl6_r,u_hdtl7_r};
      u_hdtll_r <= {u_hdtl8_r,u_hdtl9_r,u_hdtla_r,u_hdtlb_r,
                      u_hdtlc_r,u_hdtld_r,u_hdtle_r,u_hdtlf_r};
      u_hdtru_r <= {u_hdtr0_r,u_hdtr1_r,u_hdtr2_r,u_hdtr3_r,
                      u_hdtr4_r,u_hdtr5_r,u_hdtr6_r,u_hdtr7_r};
      u_hdtrl_r <= {u_hdtr8_r,u_hdtr9_r,u_hdtra_r,u_hdtrb_r,
                      u_hdtrc_r,u_hdtrd_r,u_hdtre_r,u_hdtrf_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hsldtu1_r <= 64'b0;
      u_hsldtl1_r <= 64'b0;
    end
    else if ( !u_hdt_sl1_r ) begin
      u_hsldtu1_r <= u_hdtlu_r;
      u_hsldtl1_r <= u_hdtll_r;
    end
    else begin
      u_hsldtu1_r <= u_hdtru_r;
      u_hsldtl1_r <= u_hdtrl_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hsldtu2_r <= 64'b0;
      u_hsldtl2_r <= 64'b0;
    end
    else if ( !u_hdt_sl2_r ) begin
      u_hsldtu2_r <= {64{u_hdt_msk_r}} & u_hdtlu_r;
      u_hsldtl2_r <= {64{u_hdt_msk_r}} & u_hdtll_r;
    end
    else begin
      u_hsldtu2_r <= {64{u_hdt_msk_r}} & u_hdtru_r;
      u_hsldtl2_r <= {64{u_hdt_msk_r}} & u_hdtrl_r;
    end
  end
  
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_refhdt1_r <= 64'b0;
      u_refhdt2_r <= 64'b0;
    end
    else if ( !u_hdt_sl3_r ) begin
      u_refhdt1_r <= u_hsldtu1_r;
      u_refhdt2_r <= u_hsldtu2_r;
    end
    else begin
      u_refhdt1_r <= u_hsldtl1_r;
      u_refhdt2_r <= u_hsldtl2_r;
    end
  end
  
  
endmodule
