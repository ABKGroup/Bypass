// ----------------------------------------------
// File: uc_64232.v
// Module: uc_64232
// Function:Up Convert 64Bits to 32Bits
//          Vertical Data Packing
// ----------------------------------------------

module uc_64232(
  clkdec,
  rstdec_x,
  f_ref1dt_r,
  u_yeni_r,
  u_ceni_r,
  u_mbpl_r_s,
  u_ycdtsel_r,
  u_cdtsel_r,
  u_refdt_r,
  u_refyen_r,
  u_refcen_r,
  u_sdtvdt_r,
  u_syen_r,
  u_scen_r
  );
  
  input         clkdec;         
  input         rstdec_x;       
  input [63:0]  f_ref1dt_r;     
  input         u_yeni_r;       
  input         u_ceni_r;       
  input         u_mbpl_r_s;     
  input         u_ycdtsel_r;    
  input         u_cdtsel_r;     
  output [31:0] u_refdt_r;      
  output        u_refyen_r;     
  output        u_refcen_r;     
  output [15:0] u_sdtvdt_r;     
  output        u_syen_r;       
  output        u_scen_r;       
  
  wire          clkdec;         
  wire          rstdec_x;       
  wire [63:0]   f_ref1dt_r;           // MB Data from SDRAM I/F
  wire          u_yeni_r;             // MB Data Enable(Y)
  wire          u_ceni_r;             // MB Data Enable(C)
  wire          u_mbpl_r_s;           // MB Pulse
  wire          u_ycdtsel_r;          // Y/C Data Select
  wire          u_cdtsel_r;           // Cb/Cr Data Select
  wire          u_syenp;              // MB SDTV Data Enable(Y)
  wire          u_scenp;              // MB SDTV Data Enable(C)
  wire          u_vff2enp_s;          // Data Latch2 Pre-Enable

  reg [31:0]    u_refdt_r;            // MB Vertical Refetence Data
  reg           u_refyen_r;           // MB Vertical Refetence Data Enable(Y)
  reg           u_refcen_r;           // MB Vertical Refetence Data Enable(C)
  reg [15:0]    u_sdtvdt_r;           // MB SDTV Data
  reg           u_syen_r;             // MB SDTV Data Enable(Y)
  reg           u_scen_r;             // MB SDTV Data Enable(C)
  reg [63:0]    u_dt_r;               // MB Data
  reg [31:0]    u_dt_d1_r;            // MB Data 1CLK Delay
  reg [31:0]    u_dt_d2_r;            // MB Data 2CLK Delay
  reg [2:0]     u_vdt_cnt_r;          // MB Data Counter
  reg [1:0]     u_vdt_cnt_d1_r;       // MB Data Counter 1CLK Delay
  reg [6:0]     u_yeni_d_r;           // MB Data Enable(Y) Shift Register
  reg [4:0]     u_ceni_d_r;           // MB Data Enable(C) Shift Register
  reg           u_vcnt_dc0_r_s,       // MB Data Counter Decode 0h
                u_vcnt_dc1_r_s,       // MB Data Counter Decode 1h
                u_vcnt_dc2_r_s,       // MB Data Counter Decode 2h
                u_vcnt_dc3_r_s;       // MB Data Counter Decode 3h
  reg [31:0]    u_vdt0_r,             // MB Latch Data0
                u_vdt1_r,             // MB Latch Data1
                u_vdt2_r,             // MB Latch Data2
                u_vdt3_r;             // MB Latch Data3
  reg [1:0]     u_vff2enp_r_s,        // MB Data Latch2 Pre-Enable
                u_vff2en_r_s;         // MB Data Latch2 Enable
  reg [31:0]    u_vdt0_d1_r,          // MB Latch2 Data0
                u_vdt1_d1_r,          // MB Latch2 Data1
                u_vdt2_d1_r,          // MB Latch2 Data2
                u_vdt3_d1_r;          // MB Latch2 Data3
  reg [1:0]     u_vsel2_cnt_r;        // MB Data Select Counter
  reg [63:0]    u_svdt_r;             // MB SDTV Data Latch
  reg [1:0]     u_sdcnt_r;            // MB SDTV Data Output Counter
  reg [5:0]     u_sycnt_r,            // MB SDTV Data Counter(Y)
                u_sccnt_r;            // MB SDTV Data Counter(C)
  reg           u_syenp_r,            // MB SDTV Data Enable(Y)
                u_scenp_r;            // MB SDTV Data Enable(C)
  reg           u_mbpl_d1_r_s;        // u_mbpl_r_s 1CLK Delay
  
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_dt_r        <= 64'b0;
      u_mbpl_d1_r_s <= 1'b0;
    end
    else begin
      u_dt_r        <= f_ref1dt_r;
      u_mbpl_d1_r_s <= u_mbpl_r_s;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_dt_d1_r <= 32'b0;
    end
    else if( u_vdt_cnt_r[2] ) begin
      u_dt_d1_r <= u_dt_r[31:0];
    end
    else begin
      u_dt_d1_r <= u_dt_r[63:32];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_dt_d2_r <= 32'b0;
    end
    else if( u_ycdtsel_r ) begin
      if( u_cdtsel_r ) begin
        u_dt_d2_r <= {u_dt_d1_r[23:16],
                        u_dt_d1_r[7:0],
                        u_dt_d1_r[31:24],
                        u_dt_d1_r[15:8]};
      end
      else begin
        u_dt_d2_r <= {u_dt_d1_r[31:24],
                        u_dt_d1_r[15:8],
                        u_dt_d1_r[23:16],
                        u_dt_d1_r[7:0]};
      end
    end
    else begin
      u_dt_d2_r <= u_dt_d1_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vdt_cnt_r <= 3'h0;
    end
    else if( !u_yeni_r && !u_ceni_r ) begin
      u_vdt_cnt_r <= 3'h0;
    end
    else if( u_yeni_r ) begin
      u_vdt_cnt_r <= u_vdt_cnt_r + 1'b1;
    end
    else if( u_ceni_r ) begin
      if( u_vdt_cnt_r == 3'h5 ) begin
        u_vdt_cnt_r <= 3'h0;
      end
      else if( u_vdt_cnt_r == 3'h1 ) begin
        u_vdt_cnt_r <= 3'h4;
      end
      else begin
        u_vdt_cnt_r <= u_vdt_cnt_r + 1'b1;
      end
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vdt_cnt_d1_r <= 2'b00;
    end
    else begin
      u_vdt_cnt_d1_r <= u_vdt_cnt_r[1:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_yeni_d_r <= 7'b0;
      u_ceni_d_r <= 5'b0;
    end
    else begin
      u_yeni_d_r <= {u_yeni_d_r[5:0],u_yeni_r};
      u_ceni_d_r <= {u_ceni_d_r[3:0],u_ceni_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vcnt_dc0_r_s <= 1'b0;
    end
    else if( (u_yeni_d_r[0] || u_ceni_d_r[0]) && 
             (u_vdt_cnt_d1_r[1:0] == 2'h0) ) begin
      u_vcnt_dc0_r_s <= 1'b1;
    end
    else begin
      u_vcnt_dc0_r_s <= 1'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vcnt_dc1_r_s <= 1'b0;
    end
    else if( (u_yeni_d_r[0] || u_ceni_d_r[0]) && 
             (u_vdt_cnt_d1_r[1:0] == 2'h1) ) begin
      u_vcnt_dc1_r_s <= 1'b1;
    end
    else begin
      u_vcnt_dc1_r_s <= 1'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vcnt_dc2_r_s <= 1'b0;
    end
    else if( (u_yeni_d_r[0] || u_ceni_d_r[0]) && 
             (u_vdt_cnt_d1_r[1:0] == 2'h2) ) begin
      u_vcnt_dc2_r_s <= 1'b1;
    end
    else begin
      u_vcnt_dc2_r_s <= 1'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vcnt_dc3_r_s <= 1'b0;
    end
    else if( (u_yeni_d_r[0] || u_ceni_d_r[0]) && 
             (u_vdt_cnt_d1_r[1:0] == 2'h3) ) begin
      u_vcnt_dc3_r_s <= 1'b1;
    end
    else begin
      u_vcnt_dc3_r_s <= 1'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vdt0_r <= 32'b0;
    end
    else if( u_vcnt_dc0_r_s ) begin
      u_vdt0_r <= u_dt_d2_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vdt1_r <= 32'b0;
    end
    else if( u_vcnt_dc1_r_s ) begin
      u_vdt1_r <= u_dt_d2_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vdt2_r <= 32'b0;
    end
    else if( u_vcnt_dc2_r_s ) begin
      u_vdt2_r <= u_dt_d2_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vdt3_r <= 32'b0;
    end
    else if( u_vcnt_dc3_r_s ) begin
      u_vdt3_r <= u_dt_d2_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vff2enp_r_s <= 2'b0;
    end
    else begin
      u_vff2enp_r_s <= {u_vff2enp_r_s[0],(~u_ceni_d_r[1])&u_vcnt_dc0_r_s};
    end
  end

  assign u_vff2enp_s = u_ceni_d_r[1] ? u_vcnt_dc0_r_s : u_vff2enp_r_s[1];
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vff2en_r_s <= 2'b0;
    end
    else begin
      u_vff2en_r_s <= {u_vff2en_r_s[0],u_vff2enp_s};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vdt0_d1_r <= 32'b0;
      u_vdt1_d1_r <= 32'b0;
      u_vdt2_d1_r <= 32'b0;
      u_vdt3_d1_r <= 32'b0;
    end
    else if( u_vff2en_r_s[1] ) begin
      u_vdt0_d1_r <= u_vdt0_r;
      u_vdt1_d1_r <= u_vdt1_r;
      u_vdt2_d1_r <= u_vdt2_r;
      u_vdt3_d1_r <= u_vdt3_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vsel2_cnt_r <= 2'h3;
    end
    else if( u_vff2en_r_s[1] )begin
      u_vsel2_cnt_r <= 2'b0;
    end
    else if( u_vsel2_cnt_r != 2'h3 ) begin
      u_vsel2_cnt_r <= u_vsel2_cnt_r + 1'b1;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_refdt_r <= 32'b0;
    end
    else begin
      case( u_vsel2_cnt_r )
        2'b00 : u_refdt_r <= {u_vdt0_d1_r[31:24],
                               u_vdt1_d1_r[31:24],
                               u_vdt2_d1_r[31:24],
                               u_vdt3_d1_r[31:24]};
        2'b01 : u_refdt_r <= {u_vdt0_d1_r[23:16],
                               u_vdt1_d1_r[23:16],
                               u_vdt2_d1_r[23:16],
                               u_vdt3_d1_r[23:16]};
        2'b10 : u_refdt_r <= {u_vdt0_d1_r[15:8],
                               u_vdt1_d1_r[15:8],
                               u_vdt2_d1_r[15:8],
                               u_vdt3_d1_r[15:8]};
        2'b11 : u_refdt_r <= {u_vdt0_d1_r[7:0],
                               u_vdt1_d1_r[7:0],
                               u_vdt2_d1_r[7:0],
                               u_vdt3_d1_r[7:0]};
      endcase
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_refyen_r <= 1'b0;
      u_refcen_r <= 1'b0;
    end
    else begin
      u_refyen_r <= u_yeni_d_r[6];
      u_refcen_r <= u_ceni_d_r[4];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_svdt_r <= 64'b0;
    end
    else if( u_yeni_r || u_ceni_r ) begin
      if( !u_ceni_r ) begin
    u_svdt_r <= u_dt_r;
      end
      else if( (u_sccnt_r >= 6'h1D) & (u_sccnt_r <= 6'h3A) ) begin
        u_svdt_r <= {u_dt_r[55:48],
                       u_dt_r[39:32],
                       u_dt_r[23:16],
                       u_dt_r[7:0],
                       u_dt_r[63:56],
                       u_dt_r[47:40],
                       u_dt_r[31:24],
                       u_dt_r[15:8]};
      end
      else begin
        u_svdt_r <= {u_dt_r[63:56],
                       u_dt_r[47:40],
                       u_dt_r[31:24],
                       u_dt_r[15:8],
                       u_dt_r[55:48],
                       u_dt_r[39:32],
                       u_dt_r[23:16],
                       u_dt_r[7:0]};
      end
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_sycnt_r <= 6'h3F;
    end
    else if( u_mbpl_d1_r_s ) begin
      u_sycnt_r <= 6'h3F;
    end
    else if( u_yeni_r ) begin
      u_sycnt_r <= u_sycnt_r + 1'b1;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_sccnt_r <= 6'h3F;
    end
    else if( u_mbpl_d1_r_s ) begin
      u_sccnt_r <= 6'h3F;
    end
    else if( u_ceni_r ) begin
      u_sccnt_r <= u_sccnt_r + 1'b1;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_syenp_r <= 1'b0;
      u_syen_r <= 1'b0;
    end
    else begin
      u_syenp_r <= u_syenp;
      u_syen_r <= u_syenp_r;
    end
  end
  assign u_syenp = (u_sycnt_r < 6'h35) | u_yeni_r;
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_scenp_r <= 1'b0;
      u_scen_r <= 1'b0;
    end
   else begin
      u_scenp_r <= u_scenp;
      u_scen_r <= u_scenp_r;
    end
  end
  assign u_scenp = (u_sccnt_r < 6'h3B) | u_ceni_r;
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_sdcnt_r <= 2'h3;
    end
    else if( u_yeni_r || u_ceni_r ) begin
      u_sdcnt_r <= 2'h0;
    end
    else if( u_sdcnt_r != 2'h3 ) begin
      u_sdcnt_r <= u_sdcnt_r + 1'b1;
    end
  end

  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_sdtvdt_r <= 16'b0;
    end
    else begin
      case ( u_sdcnt_r )
        2'b00 : u_sdtvdt_r <= u_svdt_r[63:48];
        2'b01 : u_sdtvdt_r <= u_svdt_r[47:32];
        2'b10 : u_sdtvdt_r <= u_svdt_r[31:16];
        2'b11 : u_sdtvdt_r <= u_svdt_r[15:0];
      endcase
    end
  end
  
endmodule
