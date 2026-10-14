// ----------------------------------------------
// File: bdc_srctl.v
// Module: bdc_srctl
// Function:
// ----------------------------------------------

module bdc_srctl(
  clkdec,
  rstdec_x,
  vwh_data_wait,
  c_mbpl_dc_r_s,
  c_bfcnt_init_r,
  d_decv_dt_r,
  d_decv_yen_r,
  d_decv_cen_r,
  b_hdtvh_r,
  b_prgseq_r,
  b_rdreq0,
  b_rdreq1,
  b_rdreq2,
  b_rdhdtvh_r,
  b_bfov_err_r,
  v1_rcn00_a,
  v1_rcn00_d,
  v1_rcn00_bs,
  v1_rcn00_we,
  v1_rcn01_a,
  v1_rcn01_d,
  v1_rcn01_bs,
  v1_rcn01_we,
  v1_rcn02_a,
  v1_rcn02_d,
  v1_rcn02_bs,
  v1_rcn02_we,
  b_mbpl_r_s,
  b_dtflg0_r,
  b_dtflg1_r,
  b_dtflg2_r,
  b_bfcnt_init_r
  );
  
  input         clkdec;      
  input         rstdec_x;    
  input         vwh_data_wait;   
  input         c_mbpl_dc_r_s; 
  input         c_bfcnt_init_r;
  input [15:0]  d_decv_dt_r;   
  input         d_decv_yen_r;  
  input         d_decv_cen_r;   
  input         b_hdtvh_r;      
  input         b_prgseq_r;     
  input         b_rdreq0;       
  input         b_rdreq1;       
  input         b_rdreq2;       
  input         b_rdhdtvh_r;    
  
  output        b_bfov_err_r;   
  output [5:0]  v1_rcn00_a;       
  output [63:0] v1_rcn00_d;       
  output        v1_rcn00_bs;      
  output        v1_rcn00_we;      
  output [5:0]  v1_rcn01_a;       
  output [63:0] v1_rcn01_d;       
  output        v1_rcn01_bs;      
  output        v1_rcn01_we;   
  output [5:0]  v1_rcn02_a;    
  output [63:0] v1_rcn02_d;    
  output        v1_rcn02_bs;   
  output        v1_rcn02_we;   
  output        b_mbpl_r_s;  
  output        b_dtflg0_r;  
  output        b_dtflg1_r;  
  output        b_dtflg2_r;  
  output        b_bfcnt_init_r;  
  
  wire          clkdec;    
  wire          rstdec_x;  
  wire          c_mbpl_dc_r_s;        // MB Pulse(DC Pahse)
  wire          c_bfcnt_init_r;       // Buffer Control Reset Pulse
  wire [15:0]   d_decv_dt_r;          // MB Data
  wire          d_decv_yen_r;         // MB Data Enable(Y)
  wire          d_decv_cen_r;         // MB Data Enable(C)
  wire          b_hdtvh_r;            // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  wire          b_prgseq_r;           // MB Interlace/Progressive Select[0:Interlace 1:Progressive]
  wire          b_rdreq0;             // SRAM1 Read Request
  wire          b_rdreq1;             // SRAM2 Read Request
  wire          b_rdreq2;             // SRAM3 Read Request
  wire          b_rdhdtvh_r;          // SRAM Data HDTV/SDTV Select[0:SDTV 1:HDTV]
  
  wire [5:0]    v1_rcn00_a;           // DC Bus I/F Buffer Memory1 Address
  wire [5:0]    v1_rcn01_a;           // DC Bus I/F Buffer Memory2 Address
  wire [5:0]    v1_rcn02_a;           // DC Bus I/F Buffer Memory3 Address
  
  wire          b_dtc_dc7_s;          // Write Data Counter Decode(7h)
  wire          b_wadr_dc;            // Write Address Decode
  wire          b_radr0_dc;           // Read Address Decode
  wire          b_radr1_dc;           // Read Address Decode
  wire          b_radr2_dc;           // Read Address Decode
  
  reg           b_bfov_err_r;         // DC Write SRAM Overwrite Error
  reg [63:0]    v1_rcn00_d;           // DC Bus I/F Buffer Memory1 Write Data
  reg           v1_rcn00_bs;          // DC Bus I/F Buffer Memory1 Block Select
  reg           v1_rcn00_we;          // DC Bus I/F Buffer Memory1 Write Enable
  reg [63:0]    v1_rcn01_d;           // DC Bus I/F Buffer Memory2 Write Data
  reg           v1_rcn01_bs;          // DC Bus I/F Buffer Memory2 Block Select
  reg           v1_rcn01_we;          // DC Bus I/F Buffer Memory2 Write Enable
  reg [63:0]    v1_rcn02_d;           // DC Bus I/F Buffer Memory3 Write Data
  reg           v1_rcn02_bs;          // DC Bus I/F Buffer Memory3 Block Select
  reg           v1_rcn02_we;          // DC Bus I/F Buffer Memory3 Write Enable
  reg           b_mbpl_r_s;           // MB Pulse
  reg           b_dtflg0_r;           // DC Bus I/F Buffer Memory1 Write End Flug
  reg           b_dtflg1_r;           // DC Bus I/F Buffer Memory2 Write End Flug
  reg           b_dtflg2_r;           // DC Bus I/F Buffer Memory3 Write End Flug
  reg           b_bfcnt_init_r;       // Buffer Control Reset Pulse
  reg [127:0]   b_dt_r;               // Input Data Shift Register
  reg [127:0]   b_dtln_r;             // Input Data Select
  reg [63:0]    b_wdt_r;              // Write Data Select
  reg           b_decv_yen_r;         // MB Data Enable(Y)
  reg           b_decv_cen_r;         // MB Data Enable(C)
  reg           b_pmbpl_r_s;          // MB Pulse
  reg [2:0]     b_dtcnt_r;            // Write Data Counter
  reg           b_dt_dc7_r_s;         // b_dtc_dc7_s 1CLK Delay
  reg           b_dt_dc7d1_r_s;       // b_dtc_dc7_s 2CLK Delay
  reg           b_wenb_r;             // Write Data Enable
  reg [2:0]     b_wnum_r;             // SRAM Write Field Counter(3-1 JS)
  reg [5:0]     b_wadr_cnt_r;         // Write Address Counter
  reg           b_rdreq0_d1_r;        // b_rdreq0 1CLK Delay
  reg           b_rdreq1_d1_r;        // b_rdreq1 1CLK Delay
  reg           b_rdreq2_d1_r;        // b_rdreq2 1CLK Delay
  reg [5:0]     b_radr0_r;            // SRAM1 Read Address
  reg [5:0]     b_radr1_r;            // SRAM1 Read Address
  reg [5:0]     b_radr2_r;            // SRAM1 Read Address
  reg [5:0]     b_wadr_d1_r;          // b_wadr_r 1CLK Delay
  reg [5:0]     b_wadr_r;             // Write Address
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_dt_r <= 128'h0;
    end
    else begin
      b_dt_r[127:112] <= b_dt_r[111:96];
      b_dt_r[111:96]  <= b_dt_r[95:80];
      b_dt_r[95:80]   <= b_dt_r[79:64];
      b_dt_r[79:64]   <= b_dt_r[63:48];
      b_dt_r[63:48]   <= b_dt_r[47:32];
      b_dt_r[47:32]   <= b_dt_r[31:16];
      b_dt_r[31:16]   <= b_dt_r[15:0];
      b_dt_r[15:0]    <= d_decv_dt_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_dtln_r <= 128'h0;
    end
    else if( b_dtc_dc7_s ) begin
      if ( !b_hdtvh_r )begin
        b_dtln_r <= b_dt_r;
      end
      else begin
        b_dtln_r[127:64] <= {b_dt_r[127:120],b_dt_r[111:104],
                               b_dt_r[95:88],b_dt_r[79:72],
                               b_dt_r[63:56],b_dt_r[47:40],
                               b_dt_r[31:24],b_dt_r[15:8]};
        b_dtln_r[63:0]   <= {b_dt_r[119:112],b_dt_r[103:96],
                               b_dt_r[87:80],b_dt_r[71:64],
                               b_dt_r[55:48],b_dt_r[39:32],
                               b_dt_r[23:16],b_dt_r[7:0]};
      end
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_wdt_r <= 64'h0;
    end
    else if( b_dt_dc7d1_r_s && !b_hdtvh_r ) begin
      b_wdt_r <= b_dtln_r[63:0];
    end
    else begin
      b_wdt_r <= b_dtln_r[127:64];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_pmbpl_r_s    <= 1'b0;
      b_mbpl_r_s     <= 1'b0;
      b_bfcnt_init_r <= 1'b0;
      b_decv_yen_r   <= 1'b0;
      b_decv_cen_r   <= 1'b0;
    end
    else begin
      b_pmbpl_r_s    <= c_mbpl_dc_r_s;
      b_mbpl_r_s     <= b_pmbpl_r_s;
      b_bfcnt_init_r <= c_bfcnt_init_r;
      b_decv_yen_r   <= d_decv_yen_r;
      b_decv_cen_r   <= d_decv_cen_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_dtcnt_r <= 3'b0;
    end
    else if ( b_pmbpl_r_s || b_bfcnt_init_r ) begin
      b_dtcnt_r <= 3'b0;
    end
    else if ( b_decv_yen_r || b_decv_cen_r ) begin
      b_dtcnt_r <= b_dtcnt_r + 1'b1;
    end
  end
  assign b_dtc_dc7_s = (b_dtcnt_r == 3'h7);
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_dt_dc7_r_s   <= 1'b0;
      b_dt_dc7d1_r_s <= 1'b0;
    end
    else begin
      b_dt_dc7_r_s   <= b_dtc_dc7_s;
      b_dt_dc7d1_r_s <= b_dt_dc7_r_s;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_wenb_r <= 1'b0;
    end
    else begin
      b_wenb_r <= b_dt_dc7_r_s | ((~b_hdtvh_r) & b_dt_dc7d1_r_s) ;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_wnum_r <= 3'h0;
    end
    else if ( b_bfcnt_init_r ) begin
      b_wnum_r <= 3'h0;
    end
    else if ( b_pmbpl_r_s ) begin
      if ( b_wnum_r == 3'h0 ) begin
        b_wnum_r <= 3'h1;
      end
      else begin
        b_wnum_r <= {b_wnum_r[1:0],b_wnum_r[2]};
      end
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_wadr_cnt_r <= 6'h00;
    end
    else if ( b_pmbpl_r_s || b_bfcnt_init_r ) begin
      b_wadr_cnt_r <= 6'h00;
    end
    else if ( b_wenb_r ) begin
      if( !b_hdtvh_r ) begin
        b_wadr_cnt_r <= b_wadr_cnt_r + 1'b1;
      end
      else begin
        if ( b_wadr_cnt_r == 6'h06 ) begin
          b_wadr_cnt_r <= 6'h10;
        end
        else if ( b_wadr_cnt_r == 6'h16 ) begin
          b_wadr_cnt_r <= 6'h20;
        end
        else if ( b_wadr_cnt_r == 6'h22 ) begin
          b_wadr_cnt_r <= 6'h28;
        end
        else begin
          b_wadr_cnt_r <= b_wadr_cnt_r + 2'b10;
        end
      end
    end
  end
  
  always @( b_wadr_cnt_r or b_prgseq_r or b_hdtvh_r ) begin
    if( !b_prgseq_r ) begin
      case(b_wadr_cnt_r[5:4])
        2'b01 : b_wadr_r = {b_wadr_cnt_r[3],
                               {2{(~b_wadr_cnt_r[3])}},
                               b_wadr_cnt_r[2:0]};
        2'b10 : b_wadr_r = {b_wadr_cnt_r[3],
                               (~b_wadr_cnt_r[3]),
                               b_wadr_cnt_r[3:0]};
        default : b_wadr_r = b_wadr_cnt_r;
      endcase
    end
    else if ( !b_hdtvh_r ) begin
      case(b_wadr_cnt_r[5:4])
        2'b00 : b_wadr_r = {b_wadr_cnt_r[5],
                              {2{b_wadr_cnt_r[1]}},
                              b_wadr_cnt_r[3:2],
                              b_wadr_cnt_r[0]};
        2'b01 : b_wadr_r = {b_wadr_cnt_r[1],
                              b_wadr_cnt_r[5],
                              (~b_wadr_cnt_r[1]),
                              b_wadr_cnt_r[3:2],
                              b_wadr_cnt_r[0]};
        2'b10 : b_wadr_r = {b_wadr_cnt_r[1],
                              (~b_wadr_cnt_r[1]),
                              b_wadr_cnt_r[1],
                              b_wadr_cnt_r[3:2],
                              b_wadr_cnt_r[0]};
        default : b_wadr_r = b_wadr_cnt_r;
      endcase
    end
    else begin
      case(b_wadr_cnt_r[5:4])
        2'b00 : b_wadr_r = {b_wadr_cnt_r[5],
                              {2{b_wadr_cnt_r[1]}},
                              b_wadr_cnt_r[3:2],
                              b_wadr_cnt_r[0]};
        2'b01 : b_wadr_r = {b_wadr_cnt_r[5],
                              {2{b_wadr_cnt_r[1]}},
                              b_wadr_cnt_r[4],
                              b_wadr_cnt_r[2],
                              b_wadr_cnt_r[0]};
        2'b10 : b_wadr_r = {b_wadr_cnt_r[1],
                              (~b_wadr_cnt_r[1]),
                              b_wadr_cnt_r[1],
                              b_wadr_cnt_r[4:3],
                              b_wadr_cnt_r[0]};
        default : b_wadr_r = b_wadr_cnt_r;
      endcase
    end
  end

  assign b_wadr_dc = b_hdtvh_r ? ( b_wadr_r == 6'h2a ) : ( b_wadr_r == 6'h2f );
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_dtflg0_r <= 1'b0;
    end
    else if ( b_radr0_dc ) begin
      b_dtflg0_r <= 1'b0;
    end
    else if ( b_wadr_dc && b_wnum_r[0] && b_wenb_r ) begin
      b_dtflg0_r <= 1'b1;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_dtflg1_r <= 1'b0;
    end
    else if ( b_radr1_dc ) begin
      b_dtflg1_r <= 1'b0;
    end
    else if ( b_wadr_dc && b_wnum_r[1] && b_wenb_r ) begin
      b_dtflg1_r <= 1'b1;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_dtflg2_r <= 1'b0;
    end
    else if ( b_radr2_dc ) begin
      b_dtflg2_r <= 1'b0;
    end
    else if ( b_wadr_dc && b_wnum_r[2] && b_wenb_r ) begin
      b_dtflg2_r <= 1'b1;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_bfov_err_r <= 1'b0;
    end
    else begin
      b_bfov_err_r <= b_mbpl_r_s & (( b_wnum_r[0] & b_dtflg0_r ) | 
                                        ( b_wnum_r[1] & b_dtflg1_r ) | 
                                        ( b_wnum_r[2] & b_dtflg2_r ));
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_rdreq0_d1_r <= 1'b0;
      b_rdreq1_d1_r <= 1'b0;
      b_rdreq2_d1_r <= 1'b0;
    end
    else begin
      b_rdreq0_d1_r <= b_rdreq0;
      b_rdreq1_d1_r <= b_rdreq1;
      b_rdreq2_d1_r <= b_rdreq2;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_radr0_r <= 6'h00;
    end
    else if ( b_bfcnt_init_r || b_radr0_dc || !b_dtflg0_r ) begin
      b_radr0_r <= 6'h00;
    end
    else if ( !vwh_data_wait && b_rdreq0_d1_r ) begin
      if ( !b_rdhdtvh_r ) begin
        b_radr0_r <= b_radr0_r + 1'b1;
      end
      else begin
        if ( b_radr0_r == 6'h06 ) begin
          b_radr0_r <= 6'h10;
        end
        else if ( b_radr0_r == 6'h12 ) begin
          b_radr0_r <= 6'h18;
        end
        else if ( b_radr0_r == 6'h1E ) begin
          b_radr0_r <= 6'h28;
        end
        else begin
          b_radr0_r <= b_radr0_r + 2'b10;
        end
      end
    end
  end

  assign b_radr0_dc = b_rdhdtvh_r ? ( b_radr0_r == 6'h2a ) : ( b_radr0_r == 6'h2f );
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_radr1_r <= 6'h00;
    end
    else if ( b_bfcnt_init_r || b_radr1_dc || !b_dtflg1_r ) begin
      b_radr1_r <= 6'h00;
    end
    else if ( !vwh_data_wait && b_rdreq1_d1_r) begin
      if ( !b_rdhdtvh_r ) begin
        b_radr1_r <= b_radr1_r + 1'b1;
      end
      else begin
        if ( b_radr1_r == 6'h06 ) begin
          b_radr1_r <= 6'h10;
        end
        else if ( b_radr1_r == 6'h12 ) begin
          b_radr1_r <= 6'h18;
        end
        else if ( b_radr1_r == 6'h1e ) begin
          b_radr1_r <= 6'h28;
        end
        else begin
          b_radr1_r <= b_radr1_r + 2'b10;
        end
      end
    end
  end

  assign b_radr1_dc = b_rdhdtvh_r ? ( b_radr1_r == 6'h2a ) : ( b_radr1_r == 6'h2f );
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_radr2_r <= 6'h00;
    end
    else if ( b_bfcnt_init_r || b_radr2_dc || !b_dtflg2_r ) begin
      b_radr2_r <= 6'h00;
    end
    else if ( !vwh_data_wait && b_rdreq2_d1_r ) begin
      if ( !b_rdhdtvh_r ) begin
        b_radr2_r <= b_radr2_r + 1'b1;
      end
      else begin
        if ( b_radr2_r == 6'h06 ) begin
          b_radr2_r <= 6'h10;
        end
        else if ( b_radr2_r == 6'h12 ) begin
          b_radr2_r <= 6'h18;
        end
        else if ( b_radr2_r == 6'h1e ) begin
          b_radr2_r <= 6'h28;
        end
        else begin
          b_radr2_r <= b_radr2_r + 2'b10;
        end
      end
    end
  end

  assign b_radr2_dc = b_rdhdtvh_r ? ( b_radr2_r == 6'h2a ) : ( b_radr2_r == 6'h2f );
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_wadr_d1_r <= 6'h00;
    end
    else begin
      b_wadr_d1_r <= b_wadr_r;
    end
  end

  assign v1_rcn00_a = (v1_rcn00_we) ? b_wadr_d1_r : b_radr0_r;
  assign v1_rcn01_a = (v1_rcn01_we) ? b_wadr_d1_r : b_radr1_r;
  assign v1_rcn02_a = (v1_rcn02_we) ? b_wadr_d1_r : b_radr2_r;
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      v1_rcn00_d <= 64'h0000_0000;
    end
    else begin
      v1_rcn00_d <= b_wdt_r & {64{b_wnum_r[0]}};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      v1_rcn01_d <= 64'h0000_0000;
    end
    else begin
      v1_rcn01_d <= b_wdt_r & {64{b_wnum_r[1]}};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      v1_rcn02_d <= 64'h0000_0000;
    end
    else begin
      v1_rcn02_d <= b_wdt_r & {64{b_wnum_r[2]}};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      v1_rcn00_we <= 1'b0;
    end
    else begin
      v1_rcn00_we <= b_wenb_r & b_wnum_r[0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      v1_rcn01_we <= 1'b0;
    end
    else begin
      v1_rcn01_we <= b_wenb_r & b_wnum_r[1];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      v1_rcn02_we <= 1'b0;
    end
    else begin
      v1_rcn02_we <= b_wenb_r & b_wnum_r[2];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      v1_rcn00_bs <= 1'b0;
    end
    else begin
      v1_rcn00_bs <= b_rdreq0 | (b_wenb_r & b_wnum_r[0]);
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      v1_rcn01_bs <= 1'b0;
    end
    else begin
      v1_rcn01_bs <= b_rdreq1 | (b_wenb_r & b_wnum_r[1]);
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      v1_rcn02_bs <= 1'b0;
    end
    else begin
      v1_rcn02_bs <= b_rdreq2 | (b_wenb_r & b_wnum_r[2]);
    end
  end
  
  
endmodule
