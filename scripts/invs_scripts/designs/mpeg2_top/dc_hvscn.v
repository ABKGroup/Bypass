// ----------------------------------------------
// File: dc_hvscn.v
// Module: dc_hvscn
// Function:Horizon-Vartical scan convert memory cont
// ----------------------------------------------

module dc_hvscn (
  clkdec,
  rstdec_x,
  d_dech_yen_r,
  d_dech_cen_r,
  c_mbpl_dc_r_s,
  d_dech_dt_r,
  p_hdtvh_dc_r,
  w1_vsc00_q,
  w1_vsc01_q,
  v1_vsc00_a,
  v1_vsc00_d,
  v1_vsc00_bs,
  v1_vsc00_we,
  v1_vsc01_a,
  v1_vsc01_d,
  v1_vsc01_bs,
  v1_vsc01_we,
  d_hvmem_yen_r,
  d_hvmem_cen_r,
  d_sdtv_dout,
  d_vflt_din
  );

input         clkdec;     
input         rstdec_x;   
input         d_dech_yen_r; 
input         d_dech_cen_r; 
input         c_mbpl_dc_r_s;
input  [15:0] d_dech_dt_r;  
input         p_hdtvh_dc_r; 
input   [7:0] w1_vsc00_q;     
input   [7:0] w1_vsc01_q;     
output  [5:0] v1_vsc00_a;     
output  [7:0] v1_vsc00_d;     
output        v1_vsc00_bs;    
output        v1_vsc00_we;    
output  [5:0] v1_vsc01_a;     
output  [7:0] v1_vsc01_d;     
output        v1_vsc01_bs;    
output        v1_vsc01_we;    
output        d_hvmem_yen_r; 
output        d_hvmem_cen_r; 
output [15:0] d_sdtv_dout;   
output  [7:0] d_vflt_din;    

wire          clkdec;     
wire          rstdec_x;   
wire          d_dech_yen_r;    // Y enb
wire          d_dech_cen_r;    // C enb
wire          c_mbpl_dc_r_s;   // MB pluse
wire   [15:0] d_dech_dt_r;     // H-filter in
wire          p_hdtvh_dc_r;    // HDTV mode
wire    [7:0] w1_vsc00_q;      // Scan-mem-0 in
wire    [7:0] w1_vsc01_q;      // Scan-mem-1 in
wire    [5:0] v1_vsc00_a;      // Scan-mem-0 Adrs
wire    [7:0] v1_vsc00_d;      // Scan-mem-0 Dout
wire    [5:0] v1_vsc01_a;      // Scan-mem-1 Adrs
wire    [7:0] v1_vsc01_d;      // Scan-mem-1 Dout
wire          w_radenb;        // read adrs count enb
wire          w_lcntenb;       // line count enb
wire          w_lcntenb1;      // line count enb
wire          w_lcntenb_s;     // line count enb

reg           v1_vsc00_bs;     // Scan-mem-0 BlockSelect
reg           v1_vsc00_we;     // Scan-mem-0 WR
reg           v1_vsc01_bs;     // Scan-mem-1 BlockSelect
reg           v1_vsc01_we;     // Scan-mem-1 WR
reg           d_hvmem_yen_r;   // Y enb
reg           d_hvmem_cen_r;   // C enb
reg     [7:0] d_vflt_din;      // V-filter in
reg    [15:0] d_sdtv_dout;     // SDTV mode out
reg           r_hdtvh_r;       // HDTV mode
reg           r_vc1mbpldc_r_s; // MB pulse
reg     [7:0] rw1_vsc00_q;     // Scan-mem-0 in
reg     [7:0] rw1_vsc01_q;     // Scan-mem-0 in
reg           r_dech_yen_r;    // Y enb
reg           r_dech_cen_r;    // C enb
reg     [5:0] r_rad;           // read adrs counter
reg     [5:0] r_lcnt;          // line counter
reg    [15:0] r_dech_dt_r;     // H-filter in
reg    [15:0] r_dech_dt1_r;    // H-filter in
reg           r_lcntenb1;      // line count enb
reg           w_ce1h_r;        //
reg           w_ce1l_r;        //
reg           w_ce2h_r;        //
reg           w_ce2l_r;        //
reg           w_we1h_r;        //
reg           w_we1l_r;        //
reg           w_we2h_r;        //
reg           w_we2l_r;        //
reg           r_cen_r;         //
reg           d_vflt_0_sel_r;  //
reg           d_vflt_1_sel_r;  //
reg     [5:0] w_vsc00_a;       // Scan-mem-0 Adrs
reg     [7:0] w_vsc00_d;       // Scan-mem-0 Dout
reg     [5:0] w_vsc01_a;       // Scan-mem-1 Adrs
reg     [7:0] w_vsc01_d;       // Scan-mem-1 Dout

assign v1_vsc00_a = (v1_vsc00_bs) ? w_vsc00_a : 6'd0;
assign v1_vsc01_a = (v1_vsc01_bs) ? w_vsc01_a : 6'd0;
assign v1_vsc00_d = (v1_vsc00_bs) ? w_vsc00_d : 8'd0;
assign v1_vsc01_d = (v1_vsc01_bs) ? w_vsc01_d : 8'd0;
assign w_lcntenb1 = (r_hdtvh_r == 1'b1) ? r_dech_yen_r : r_dech_cen_r;
assign w_radenb = ((r_lcnt > 6'd0) && (r_lcnt < 6'd33)) || (w_lcntenb1 == 1'b1);
assign w_lcntenb = (r_rad[2:0]==3'b111) ? 1'b1 : 1'b0;

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_dech_dt_r     <= 16'd0;
        r_dech_dt1_r    <= 16'd0;
        r_hdtvh_r       <= 1'b0;
        r_vc1mbpldc_r_s <= 1'b0;
        r_dech_yen_r    <= 1'b0;
        r_dech_cen_r    <= 1'b0;
        rw1_vsc00_q     <= 8'd0;
        rw1_vsc01_q     <= 8'd0;
        r_cen_r         <= 1'b0;
      end
    else
      begin
        r_dech_dt1_r    <= d_dech_dt_r;
        r_dech_dt_r     <= r_dech_dt1_r;
        r_hdtvh_r       <= p_hdtvh_dc_r;
        r_vc1mbpldc_r_s <= c_mbpl_dc_r_s;
        r_dech_yen_r    <= d_dech_yen_r;
        r_dech_cen_r    <= d_dech_cen_r;
        rw1_vsc00_q     <= w1_vsc00_q;
        rw1_vsc01_q     <= w1_vsc01_q;
        r_cen_r         <= r_dech_cen_r;
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
        r_rad <= 6'd0;
      end
    else if (r_vc1mbpldc_r_s == 1'b1)
      begin
        r_rad <= 6'd0;
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
        r_lcnt <= 6'd0;
      end
    else if (r_vc1mbpldc_r_s == 1'b1)
      begin
        r_lcnt <= 6'd0;
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
        w_vsc00_a <= 6'd0;
        w_vsc01_a <= 6'd0;
      end
    else if (r_hdtvh_r == 1'b1) // HDTV mode
      begin
        if (r_lcnt < 6'd8)
          begin
            w_vsc00_a <= r_rad[5:0];
            w_vsc01_a <= 6'd0;
          end
        else if (r_lcnt < 6'd16)
          begin
            w_vsc00_a <= {r_rad[2:0],r_rad[5:3]};
            w_vsc01_a <= r_rad[5:0];
          end
        else if (r_lcnt < 6'd24)
          begin
            w_vsc00_a <= {r_rad[4:2],r_rad[5],r_rad[1:0]};
            w_vsc01_a <= {r_rad[2:0],r_rad[5:3]};
          end
        else if (r_lcnt < 6'd32)
          begin
            w_vsc00_a <= {r_rad[4],r_rad[1:0],r_rad[5],r_rad[3:2]};
            w_vsc01_a <= 6'd0;
          end
        else
          begin
            w_vsc00_a <= 6'd0;
            w_vsc01_a <= 6'd0;
          end
      end
    else // SDTV
      begin
        if (r_lcnt < 6'd8)
          begin
            w_vsc00_a <= r_rad[5:0];
            w_vsc01_a <= r_rad[5:0];
          end
        else if (r_lcnt < 6'd16)
          begin
            w_vsc00_a <= { r_rad[0],r_rad[5:1]};
            w_vsc01_a <= {~r_rad[0],r_rad[5:1]};
          end
        else
          begin
            w_vsc00_a <= 6'd0;
            w_vsc01_a <= 6'd0;
          end
      end
  end

always @(r_hdtvh_r or w_lcntenb_s)
  begin
    if (r_hdtvh_r == 1'b1) // HDTV mode
      begin
        if (w_lcntenb_s == 1'b1)
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
        if (w_lcntenb_s == 1'b1)
          begin
            w_ce1h_r = 1'b1;
          end
        else
          begin
            w_ce1h_r = 1'b0;
          end
      end
  end

always @(r_lcnt or r_hdtvh_r or r_rad)
  begin
    if (r_hdtvh_r == 1'b1) // HDTV mode
      begin
        if ((r_lcnt == 6'd32) && (r_rad == 6'd0))
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
        if (r_lcnt == 6'd16)
          begin
            w_ce1l_r = 1'b1;
          end
        else
          begin
            w_ce1l_r = 1'b0;
          end
      end
  end

always @(r_lcnt or r_hdtvh_r or r_dech_cen_r or r_cen_r or r_rad)
  begin
    if (r_hdtvh_r == 1'b1) // HDTV mode
      begin
        if ((r_lcnt == 6'd8) && (r_rad == 6'd0))
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
        if ((r_dech_cen_r == 1'b1) && (r_cen_r == 1'b0))
          begin
            w_ce2h_r = 1'b1;
          end
        else
          begin
            w_ce2h_r = 1'b0;
          end
      end
  end

always @(r_lcnt or r_hdtvh_r or r_rad)
  begin
    if (r_hdtvh_r == 1'b1) // HDTV mode
      begin
        if ((r_lcnt == 6'd24) && (r_rad == 6'd0))
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
        if (r_lcnt == 6'd16)
          begin
            w_ce2l_r = 1'b1;
          end
        else
          begin
            w_ce2l_r = 1'b0;
          end
      end
  end

always @(r_lcnt or r_hdtvh_r or w_lcntenb_s or r_dech_cen_r or r_cen_r or r_rad)
  begin
    if (r_hdtvh_r == 1'b1) // HDTV mode
      begin
        if ( (w_lcntenb_s == 1'b1) || // Y-WR
            ((r_lcnt == 6'd16) && (r_rad == 6'd0)) ) // C-WR
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
        if ((r_dech_cen_r == 1'b1) && (r_cen_r == 1'b0))
          begin
            w_we1h_r = 1'b1;
          end
        else
          begin
            w_we1h_r = 1'b0;
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x) 
      begin
        w_we1l_r <= 1'b0;
      end
    else if (r_hdtvh_r == 1'b1) // HDTV mode
      begin
        if ( ((r_lcnt == 6'd7) && (w_lcntenb == 1'b1)) || //Y-WR end
             ((r_lcnt == 6'd23) && (w_lcntenb == 1'b1)) ) //C-WR end
          begin
            w_we1l_r <= 1'b1;
          end
        else
          begin
            w_we1l_r <= 1'b0;
          end
      end
    else
      begin
        if ((r_lcnt == 6'd7) && (w_lcntenb == 1'b1))
          begin
            w_we1l_r <= 1'b1;
          end
        else
          begin
            w_we1l_r <= 1'b0;
          end
      end
  end

always @(r_lcnt or r_hdtvh_r or r_dech_cen_r or r_cen_r or r_rad)
  begin
    if (r_hdtvh_r == 1'b1)
      begin
        if ((r_lcnt == 6'd8) && (r_rad == 6'd0))
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
        if ((r_dech_cen_r == 1'b1) && (r_cen_r == 1'b0))
          begin
            w_we2h_r = 1'b1;
          end
        else
          begin
            w_we2h_r = 1'b0;
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        w_we2l_r <= 1'b0;
      end
    else if (r_hdtvh_r == 1'b1)
      begin
        if ((r_lcnt == 6'd15) && (w_lcntenb == 1'b1))
          begin
            w_we2l_r <= 1'b1;
          end
        else
          begin
            w_we2l_r <= 1'b0;
          end
      end
    else
      begin
        if ((r_lcnt == 6'd7) && (w_lcntenb == 1'b1))
          begin
            w_we2l_r <= 1'b1;
          end
        else
          begin
            w_we2l_r <= 1'b0;
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        v1_vsc00_bs <= 1'b0;
      end
    else if (w_ce1h_r == 1'b1)
      begin
        v1_vsc00_bs <= 1'b1;
      end
    else if (w_ce1l_r == 1'b1)
      begin
        v1_vsc00_bs <= 1'b0;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        v1_vsc00_we <= 1'b0;
      end
    else if (w_we1h_r == 1'b1)
      begin
        v1_vsc00_we <= 1'b1;
      end
    else if (w_we1l_r == 1'b1)
      begin
        v1_vsc00_we <= 1'b0;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        v1_vsc01_bs <= 1'b0;
      end
    else if (w_ce2h_r == 1'b1)
      begin
        v1_vsc01_bs <= 1'b1;
      end
    else if (w_ce2l_r == 1'b1)
      begin
        v1_vsc01_bs <= 1'b0;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x) 
      begin
        v1_vsc01_we <= 1'b0;
      end
    else if (w_we2h_r == 1'b1)
      begin
        v1_vsc01_we <= 1'b1;
      end
    else if (w_we2l_r == 1'b1)
      begin
        v1_vsc01_we <= 1'b0;
      end
  end


always @(r_hdtvh_r or r_dech_dt_r or v1_vsc00_a) 
  begin
    if ( r_hdtvh_r == 1'b1 )
      begin
        w_vsc00_d = r_dech_dt_r[15:8];
        w_vsc01_d = r_dech_dt_r[15:8];
      end
    else // SDTV
      begin
        if (v1_vsc00_a < 6'd32)
          begin
            w_vsc00_d = r_dech_dt_r[15:8];
            w_vsc01_d = r_dech_dt_r[7:0];
          end
        else
          begin
            w_vsc00_d = r_dech_dt_r[7:0];
            w_vsc01_d = r_dech_dt_r[15:8];
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x) 
      begin
        d_sdtv_dout <= 16'd0;
      end
    else if ( r_hdtvh_r == 1'b1 ) // HDTV mode
      begin
        d_sdtv_dout <= 16'd0;
      end
    else
      begin
        if (r_dech_yen_r == 1'b1)
          begin
            d_sdtv_dout <= r_dech_dt1_r;
          end
        else if (r_dech_cen_r == 1'b1)
          begin
            d_sdtv_dout <= 16'd0;
          end
        else
          begin
            if (((r_lcnt > 6'd15 ) && (r_rad > 6'd2)) || (r_lcnt == 6'd0))
              begin
                d_sdtv_dout <= 16'd0;
              end
            else if (r_rad[0] == 1'b1)
              begin
                d_sdtv_dout <= {rw1_vsc00_q,rw1_vsc01_q};
              end
            else
              begin
                d_sdtv_dout <= {rw1_vsc01_q,rw1_vsc00_q};
              end
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        d_vflt_0_sel_r <= 1'b0;
        d_vflt_1_sel_r <= 1'b0;
      end
    else if (r_rad==6'd2)
      begin
        if (r_lcnt == 6'd8)
          begin
            d_vflt_0_sel_r <= 1'b1;
            d_vflt_1_sel_r <= 1'b0;
          end
        else if (r_lcnt == 6'd16)
          begin
            d_vflt_0_sel_r <= 1'b0;
            d_vflt_1_sel_r <= 1'b1;
          end
        else if (r_lcnt == 6'd24)
          begin
            d_vflt_0_sel_r <= 1'b1;
            d_vflt_1_sel_r <= 1'b0;
          end
        else if (r_lcnt > 6'd31)
          begin
            d_vflt_0_sel_r <= 1'b0;
            d_vflt_1_sel_r <= 1'b0;
          end
        else
          begin
            d_vflt_0_sel_r <= 1'b0;
            d_vflt_1_sel_r <= 1'b0;
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        d_vflt_din <= 8'd0;
      end
    else if ( r_hdtvh_r == 1'b0 ) // SDTV mode
      begin
        d_vflt_din <= 8'd0;
      end
    else
      begin
        if (d_vflt_0_sel_r == 1'b1)
          begin
            d_vflt_din <= rw1_vsc00_q;
          end
        else if (d_vflt_1_sel_r == 1'b1)
          begin
            d_vflt_din <= rw1_vsc01_q;
          end
        else
          begin
            d_vflt_din <= 8'd0;
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        d_hvmem_yen_r <= 1'b0;
      end
    else if ( r_hdtvh_r == 1'b0 ) // SDTV mode
      begin
        d_hvmem_yen_r <= r_dech_yen_r;
      end
    else
      begin
        if ((r_lcnt==6'd8) && (r_rad==6'd3))
          begin
            d_hvmem_yen_r <= 1'b1;
          end
        else if ((r_lcnt==6'd24) && (r_rad==6'd3))
          begin
            d_hvmem_yen_r <= 1'b0;
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        d_hvmem_cen_r <= 1'b0;
      end
    else if ( r_hdtvh_r == 1'b0 ) // SDTV mode
      begin
        if ((r_lcnt==6'd8)&&(r_rad==6'd3))
          begin
            d_hvmem_cen_r <= 1'b1;
          end
        else if ((r_lcnt==6'd16)&&(r_rad==6'd3))
          begin
            d_hvmem_cen_r <= 1'b0;
          end
      end
    else
      begin
        if ((r_lcnt==6'd24) && (r_rad==6'd3))
          begin
            d_hvmem_cen_r <= 1'b1;
          end
        else if ((r_lcnt==6'd32) && (r_rad==6'd3))
          begin
            d_hvmem_cen_r <= 1'b0;
          end
      end
  end
endmodule

