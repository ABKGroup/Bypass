// ----------------------------------------------
// File: dc_vhscn.v
// Module: dc_vhscn
// Function:Vartical-Horizon scan convert memory cont.
// ----------------------------------------------

module dc_vhscn (
  clkdec,
  rstdec_x,
  d_vflt_yen_r,
  d_vflt_cen_r,
  d_hvmem_yen_r,
  d_hvmem_cen_r,
  d_sdtv_dout,
  c_mbpl_dc_r_s,
  d_vflt_dout,
  p_hdtvh_dc_r,
  w1_hsc00_q,
  w1_hsc01_q,
  v1_hsc00_a,
  v1_hsc00_d,
  v1_hsc00_bs,
  v1_hsc00_we,
  v1_hsc01_a,
  v1_hsc01_d,
  v1_hsc01_bs,
  v1_hsc01_we,
  d_decv_dt_r,
  d_decv_yen_r,
  d_decv_cen_r
  );

input         clkdec;   
input         rstdec_x; 
input         d_vflt_yen_r; 
input         d_vflt_cen_r; 
input         d_hvmem_yen_r;
input         d_hvmem_cen_r;
input  [15:0] d_sdtv_dout;  
input         c_mbpl_dc_r_s;
input   [7:0] d_vflt_dout;  
input         p_hdtvh_dc_r; 
input   [7:0] w1_hsc00_q;   
input   [7:0] w1_hsc01_q;   
output  [4:0] v1_hsc00_a;   
output  [7:0] v1_hsc00_d;   
output        v1_hsc00_bs;  
output        v1_hsc00_we;  
output  [4:0] v1_hsc01_a;   
output  [7:0] v1_hsc01_d;   
output        v1_hsc01_bs;  
output        v1_hsc01_we;  
output [15:0] d_decv_dt_r;  
output        d_decv_yen_r; 
output        d_decv_cen_r; 

wire          clkdec;  
wire          rstdec_x;
wire          d_vflt_yen_r;   // Y-enb
wire          d_vflt_cen_r;   // C-enb
wire          c_mbpl_dc_r_s;  // MB pulse
wire    [7:0] d_vflt_dout;    // V-flt data
wire          p_hdtvh_dc_r;   // HDTV mode
wire          d_hvmem_yen_r;  // Y-enb
wire          d_hvmem_cen_r;  // C-enb
wire   [15:0] d_sdtv_dout;    // data-in @ SDTV
wire    [7:0] w1_hsc00_q;     // scan-mem0 dout
wire    [7:0] w1_hsc01_q;     // scan-mem1 dout
wire    [4:0] v1_hsc00_a;     // scan-mem0 adrs
wire    [7:0] v1_hsc00_d;     // scan-mem0 din
wire    [4:0] v1_hsc01_a;     // scan-mem1 adrs
wire    [7:0] v1_hsc01_d;     // scan-mem1 din
wire          w_radenb;       // read adrs cnt enb
wire          w_wadenb;       // write adrs cnt enb
wire          w_lcntenb1;     // line cnt enb
wire          w_lcntenb_s;    // line cnt enb

reg           v1_hsc00_bs;    // scan-mem0 BS
reg           v1_hsc00_we;    // scan-mem0 WE
reg           v1_hsc01_bs;    // scan-mem1 BS
reg           v1_hsc01_we;    // scan-mem1 WE
reg    [15:0] d_decv_dt_r;    // DC pixcel out
reg           d_decv_yen_r;   // DC Y-enb
reg           d_decv_cen_r;   // DC C-enb
reg           d_hdtv_yen_r;   // Y-enb @ HDTV
reg           d_hdtv_cen_r;   // C-enb @ HDTV
reg           hdtvh_r;          // HDTV mode
reg     [7:0] r_hdtv_dout;      // dout @ HDTV
reg           r_vc1mbpldc_r_s;  // MB pulse
reg     [7:0] w1hsc00_q;        // scan-mem0 dout
reg     [7:0] w1hsc01_q;        // scan-mem1 dout
reg           r_vflt_yen_r;     // Y-enb
reg           r_vflt_cen_r;     // C-enb
reg     [4:0] r_rad;            // read adrs cnt
reg     [5:0] r_wad;            // write adrs cnt
reg     [6:0] r_lcnt;           // line cnt
reg     [7:0] r_vflt_dout;      // V-flt data
reg           w_lcntenb;        // line cnt enb
reg           r_lcntenb1;       // line cnt enb
reg           w_ce1h_r;         // ce1 set
reg           w_ce1l_r;         // ce1 reset
reg           w_ce2h_r;         // ce2 set
reg           w_ce2l_r;         // ce2 reset
reg           w_we1h_r;         // we1 set
reg           w_we1l_r;         // we1 reset
reg           w_we2h_r;         // we2 set
reg           w_we2l_r;         // we2 reset
reg           r_dwadenb_r;      // write adrs cnt enb
reg     [4:0] w_hsc00_a;       // scan-mem0 adrs
reg     [7:0] w_hsc00_d;       // scan-mem0 din
reg     [4:0] w_hsc01_a;       // scan-mem0 adrs
reg     [7:0] w_hsc01_d;       // scan-mem0 din
reg     [4:0] yen_dly_r;       // 
reg     [4:0] cen_dly_r;       // 

assign v1_hsc00_a = (v1_hsc00_bs) ? w_hsc00_a : 5'd0;
assign v1_hsc01_a = (v1_hsc01_bs) ? w_hsc01_a : 5'd0;
assign v1_hsc00_d = (v1_hsc00_bs) ? w_hsc00_d : 8'd0;
assign v1_hsc01_d = (v1_hsc01_bs) ? w_hsc01_d : 8'd0;
assign w_lcntenb1 = r_vflt_yen_r & (r_lcnt == 7'd0) & (r_wad == 6'd0);
assign w_wadenb = (hdtvh_r & r_vflt_yen_r) | (hdtvh_r & r_vflt_cen_r)
                 |((r_lcnt > 7'd31) && (r_lcnt < 7'd65));
assign w_radenb = ((r_lcnt == 7'd7) && (w_lcntenb == 1'b1)) ||
                  ((r_lcnt > 7'd7)  && (r_lcnt < 7'd12)) ||
                  ((r_lcnt > 7'd15) && (r_lcnt < 7'd24)) ||
                  ((r_lcnt > 7'd31) && (r_lcnt < 7'd65));

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_dwadenb_r  <= 1'd0;
      end
    else
      begin
        r_dwadenb_r <= w_wadenb;
      end
  end

always @(w_wadenb or r_dwadenb_r or r_lcnt or r_rad) 
  begin
    if (r_lcnt < 7'd16)
      begin
        w_lcntenb = ~w_wadenb & r_dwadenb_r;
      end
    else if (r_lcnt < 7'd32)
      begin
        w_lcntenb = w_wadenb & ~r_dwadenb_r;
      end
    else
      begin
        w_lcntenb = (r_rad[0]==1'b0);
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_vflt_dout     <= 8'd0;
        hdtvh_r         <= 1'b0;
        r_vc1mbpldc_r_s <= 1'b0;
        r_vflt_yen_r    <= 1'b0;
        r_vflt_cen_r    <= 1'b0;
        w1hsc00_q       <= 8'd0;
        w1hsc01_q       <= 8'd0;
      end
    else
      begin
        r_vflt_dout     <= d_vflt_dout;
        hdtvh_r         <= p_hdtvh_dc_r;
        r_vc1mbpldc_r_s <= c_mbpl_dc_r_s;
        r_vflt_yen_r    <= d_vflt_yen_r;
        r_vflt_cen_r    <= d_vflt_cen_r;
        w1hsc00_q       <= w1_hsc00_q;
        w1hsc01_q       <= w1_hsc01_q;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_lcntenb1  <= 1'b0;
      end
    else
      begin
        r_lcntenb1  <= w_lcntenb1;
      end
  end

assign w_lcntenb_s = w_lcntenb1 & (~r_lcntenb1);

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_wad <= 6'd0;
      end
    else if (r_vc1mbpldc_r_s == 1'b1)
      begin
        r_wad <= 6'd0;
      end
    else if (w_wadenb == 1'b1)
      begin
        r_wad <= r_wad + 1'b1;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_rad <= 5'b0_0000;
      end
    else if (r_vc1mbpldc_r_s == 1'b1)
      begin
        r_rad <= 5'b0_0000;
      end
    else if (w_radenb == 1'b1)
      begin
        r_rad <= r_rad + 1'b1;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_lcnt <= 7'd0;
      end
    else if (r_vc1mbpldc_r_s == 1'b1)
      begin
        r_lcnt <= 7'd0;
      end
    else if (w_lcntenb == 1'b1)
      begin
        r_lcnt <= r_lcnt + 1'b1;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        w_hsc00_a <= 5'd0;
        w_hsc01_a <= 5'd0;
      end
    else if (hdtvh_r == 1'b1)
      begin
        if (r_lcnt < 7'd8)
          begin
            w_hsc00_a <= {r_wad[1:0],r_wad[4:2]};
            w_hsc01_a <= 5'd0;
          end
        else if (r_lcnt < 7'd12)
          begin
            w_hsc00_a <= r_rad[4:0];
            w_hsc01_a <= {r_wad[1:0],r_wad[4:2]};
          end
        else if (r_lcnt < 7'd16)
          begin
            w_hsc00_a <= 5'd0;
            w_hsc01_a <= {r_wad[1:0],r_wad[4:2]};
          end
        else if (r_lcnt < 7'd24)
          begin
            w_hsc00_a <= {r_wad[3],r_wad[0],r_wad[4],r_wad[2:1]};
            w_hsc01_a <= r_rad[4:0];
          end
        else if (r_lcnt < 7'd32)
          begin
            w_hsc00_a <= {r_wad[3],r_wad[0],r_wad[4],r_wad[2:1]};
            w_hsc01_a <= 5'd0;
          end
        else if (r_lcnt < 7'd49)
          begin
            w_hsc00_a <= {r_wad[4:3],r_wad[0],r_wad[2:1]};
            w_hsc01_a <= 5'd0;
          end
        else
          begin
            w_hsc00_a <= 5'd0;
            w_hsc01_a <= 5'd0;
          end
      end
    else // SDTV
      begin
        w_hsc00_a <= 5'd0;
        w_hsc01_a <= 5'd0;
      end
  end

always @(hdtvh_r or w_lcntenb_s or r_lcnt or w_lcntenb)
  begin
    if (hdtvh_r == 1'b1) // HDTV mode
      begin
        if ((w_lcntenb_s == 1'b1) ||
            ((r_lcnt == 7'd15) && (w_lcntenb == 1'b1)))
          begin
            w_ce1h_r = 1'b1;
          end
        else
          begin
            w_ce1h_r = 1'b0;
          end
      end
    else
      begin
        w_ce1h_r = 1'b0;
      end
  end

always @(hdtvh_r or r_lcnt or w_lcntenb )
  begin
    if (hdtvh_r == 1'b1) // HDTV mode
      begin
        if (((r_lcnt == 7'd11) && (w_lcntenb == 1'b1)) ||
            ((r_lcnt == 7'd48) && (w_lcntenb == 1'b1)))
          begin
            w_ce1l_r = 1'b1;
          end
        else
          begin
            w_ce1l_r = 1'b0;
          end
      end
    else
      begin
        w_ce1l_r = 1'b0;
      end
  end

always @(hdtvh_r or r_lcnt or w_lcntenb )
  begin
    if (hdtvh_r == 1'b1) // HDTV mode
      begin
        if ((r_lcnt == 7'd7) && (w_lcntenb == 1'b1))
          begin
            w_ce2h_r = 1'b1;
          end
        else
          begin
            w_ce2h_r = 1'b0;
          end
      end
    else
      begin
        w_ce2h_r = 1'b0;
      end
  end

always @(hdtvh_r or r_lcnt or w_lcntenb)
  begin
    if (hdtvh_r == 1'b1) // HDTV mode
      begin
        if ((r_lcnt == 7'd23) && (w_lcntenb == 1'b1))
          begin
            w_ce2l_r = 1'b1;
          end
        else
          begin
            w_ce2l_r = 1'b0;
          end
      end
    else
      begin
        w_ce2l_r = 1'b0;
      end
  end

always @(hdtvh_r or w_lcntenb_s or r_lcnt or w_lcntenb)
  begin
    if (hdtvh_r == 1'b1) // HDTV mode
      begin
        if ( (w_lcntenb_s == 1'b1) ||
            ((r_lcnt == 7'd15) && (w_lcntenb == 1'b1)) )
          begin
            w_we1h_r = 1'b1;
          end
        else
          begin
            w_we1h_r = 1'b0;
          end
      end
    else
      begin
        w_we1h_r = 1'b0;
      end
  end

always @(hdtvh_r or r_lcnt or w_lcntenb)
  begin
    if (hdtvh_r == 1'b1) // HDTV mode
      begin
        if ( ((r_lcnt == 7'd7) && (w_lcntenb == 1'b1)) ||
             ((r_lcnt == 7'd32) && (w_lcntenb == 1'b1)) )
          begin
            w_we1l_r = 1'b1;
          end
        else
          begin
            w_we1l_r = 1'b0;
          end
      end
    else
      begin
        w_we1l_r = 1'b0;
      end
  end

always @(hdtvh_r or r_lcnt or w_lcntenb)
  begin
    if (hdtvh_r == 1'b1) // HDTV mode
      begin
        if ((r_lcnt == 7'd7) && (w_lcntenb == 1'b1))
          begin
            w_we2h_r = 1'b1;
          end
        else
          begin
            w_we2h_r = 1'b0;
          end
      end
    else
      begin
        w_we2h_r = 1'b0;
      end
  end

always @(hdtvh_r or r_lcnt or w_lcntenb )
  begin
    if (hdtvh_r == 1'b1) // HDTV mode
      begin
        if ((r_lcnt == 7'd15) && (w_lcntenb == 1'b1))
          begin
            w_we2l_r = 1'b1;
          end
        else
          begin
            w_we2l_r = 1'b0;
          end
      end
    else
      begin
        w_we2l_r = 1'b0;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        v1_hsc00_bs <= 1'b0;
      end
    else if (w_ce1h_r == 1'b1)
      begin
        v1_hsc00_bs <= 1'b1;
      end
    else if (w_ce1l_r == 1'b1)
      begin
        v1_hsc00_bs <= 1'b0;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        v1_hsc00_we <= 1'b0;
      end
    else if (w_we1h_r == 1'b1)
      begin
        v1_hsc00_we <= 1'b1;
      end
    else if (w_we1l_r == 1'b1)
      begin
        v1_hsc00_we <= 1'b0;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        v1_hsc01_bs <= 1'b0;
      end
    else if (w_ce2h_r == 1'b1)
      begin
        v1_hsc01_bs <= 1'b1;
      end
    else if (w_ce2l_r == 1'b1)
      begin
        v1_hsc01_bs <= 1'b0;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        v1_hsc01_we <= 1'b0;
      end
    else if (w_we2h_r == 1'b1)
      begin
        v1_hsc01_we <= 1'b1;
      end
    else if (w_we2l_r == 1'b1)
      begin
        v1_hsc01_we <= 1'b0;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        w_hsc00_d <= 8'd0;
        w_hsc01_d <= 8'd0;
      end
    else if ( hdtvh_r == 1'b1 ) // HDTV mode
      begin
        w_hsc00_d <= r_vflt_dout;
        w_hsc01_d <= r_vflt_dout;
      end
    else // SDTV
      begin
        w_hsc00_d <= 8'd0;
        w_hsc01_d <= 8'd0;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_hdtv_dout <= 8'd0;
      end
    else if ( hdtvh_r == 1'b1 ) // HDTV mode
      begin
        if ((r_lcnt > 7'd7) && (r_lcnt < 7'd13) && (yen_dly_r[1] == 1'b1))
          begin
            r_hdtv_dout <= w1hsc00_q;
          end
        else if ((r_lcnt > 7'd15) && (r_lcnt < 7'd26) && (yen_dly_r[4] == 1'b1) && d_hdtv_yen_r )
          begin
            r_hdtv_dout <= w1hsc01_q;
          end
        else if ((r_lcnt > 7'd32) && (r_lcnt < 7'd51) && (cen_dly_r[4] == 1'b1) && d_hdtv_cen_r )
          begin
            r_hdtv_dout <= w1hsc00_q;
          end
        else
          begin
            r_hdtv_dout <= 8'd0;
          end
      end
    else
      begin
        r_hdtv_dout <= 8'd0;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        d_decv_yen_r <= 1'b0;
      end
    else if ( hdtvh_r == 1'b1 ) // HDTV mode
      begin
        d_decv_yen_r <= yen_dly_r[2];
      end
    else
      begin
        d_decv_yen_r <= d_hvmem_yen_r;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        d_decv_cen_r <= 1'b0;
      end
    else if ( hdtvh_r == 1'b1 ) // HDTV mode
      begin
        d_decv_cen_r <= cen_dly_r[2];
      end
    else
      begin
        d_decv_cen_r <= d_hvmem_cen_r;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        d_hdtv_yen_r <= 1'b0;
      end
    else if ( hdtvh_r == 1'b1 ) // HDTV mode
      begin
        if ((r_lcnt > 7'd7) && (r_lcnt < 7'd33))
          begin
            d_hdtv_yen_r <= 1'b1;
          end
        else
          begin
            d_hdtv_yen_r <= 1'b0;
          end
      end
    else
      begin
        d_hdtv_yen_r <= d_hvmem_yen_r;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        d_hdtv_cen_r <= 1'b0;
      end
    else if ( hdtvh_r == 1'b1 ) // HDTV mode
      begin
        if ((r_lcnt > 7'd32) && (r_lcnt < 7'd64))
          begin
            d_hdtv_cen_r <= 1'b1;
          end
        else
          begin
            d_hdtv_cen_r <= 1'b0;
          end
      end
    else
      begin
        d_hdtv_cen_r <= d_hvmem_cen_r;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        d_decv_dt_r <= 16'd0;
      end
    else if ( hdtvh_r == 1'b1 ) // HDTV mode
      begin
        d_decv_dt_r <= {r_hdtv_dout,8'd0};
      end
    else
      begin
        d_decv_dt_r <= d_sdtv_dout;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        yen_dly_r <= 5'd0;
        cen_dly_r <= 5'd0;
      end
    else if (r_lcnt < 7'd32) // Y-enb
      begin
        yen_dly_r <= {yen_dly_r[3:0],(~v1_hsc00_we & v1_hsc00_bs)
                                   | (~v1_hsc01_we & v1_hsc01_bs)};
        cen_dly_r <= 5'd0;
      end
    else
      begin
        yen_dly_r <= 5'd0;
        cen_dly_r <= {cen_dly_r[3:0],(~v1_hsc00_we & v1_hsc00_bs)};
      end
  end

endmodule

