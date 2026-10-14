// ----------------------------------------------
// File: dc_vtgct.v
// Module: dc_vtgct
// Function:
// ----------------------------------------------

module dc_vtgct ( 
   clkdec, 
   rstdec_x, 
   d_hvmem_yen_r, 
   d_hvmem_cen_r, 
   p_hdtvh_dc_r, 
   c_mbpl_dc_r_s, 
   d_f_ff_enb_r, 
   d_b_ff_enb_r, 
   d_phase, 
   d_c_slct, 
   d_c1_slct, 
   d_decyen_r, 
   d_vflt_yen_r, 
   d_vflt_cen_r
);

input        clkdec;  
input        rstdec_x;
input        d_hvmem_yen_r;
input        d_hvmem_cen_r;
input        p_hdtvh_dc_r; 
input        c_mbpl_dc_r_s;
output [7:0] d_f_ff_enb_r; 
output       d_b_ff_enb_r; 
output [2:0] d_phase;      
output       d_c_slct;     
output       d_c1_slct;    
output       d_decyen_r;   
output       d_vflt_yen_r; 
output       d_vflt_cen_r; 

wire        clkdec;    
wire        rstdec_x;  
wire        d_hvmem_yen_r;     // Y-enb
wire        d_hvmem_cen_r;     // C-enb
wire        p_hdtvh_dc_r;      // HDTV mode
wire        c_mbpl_dc_r_s;     // MB pulse
wire        rvfltyen_set;      // Y-enb(vflt) set
wire        rvfltcen_set;      // C-enb(vflt) set
wire        wpcnt_enb;         // pixcel cnt enb
wire        wpcnt_ld;          // pixcel cnt ld
wire        wlcnt_enb;         // line cnt enb

reg  [7:0]  d_f_ff_enb_r;      // front-ff enb
reg         d_b_ff_enb_r;      // back-ff enb
reg  [2:0]  d_phase;           // coef phase
reg         d_c_slct;          // composit sele
reg         d_c1_slct;         // composit sele
reg         d_decyen_r;        // Y-enb
reg         d_deccen_r;        // C-enb
reg         d_vflt_yen_r;      // Y-enb(vflt)
reg         d_vflt_cen_r;      // C-enb(vflt)
reg  [9:0]  r_vflt_yen_dly;    // dly for Y-enb(vflt)
reg  [9:0]  r_vflt_cen_dly;    // dly for C-enb(vflt)
reg  [2:0]  vflt_yen_set_dly;  // dly for yen_set
reg         vflt_cen_set_dly_r;// dly for cen_set
reg  [7:0]  r_dly1;            // enb delay
reg  [7:0]  r_dly2;            // enb delay
reg  [2:0]  r_pcnt;            // pixcel cnt
reg  [5:0]  r_lcnt;            // line cnt
reg         rbff_enb_r;        // back-ff enb
reg         rvc1mbpldc_r_s;    // MB pulse
reg         r_hdtvh_r;         // HDTV mode

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        d_decyen_r    <= 1'b0;
        d_deccen_r    <= 1'b0;
        rvc1mbpldc_r_s  <= 1'b0;
        r_hdtvh_r       <= 1'b0;
      end
    else
      begin
        d_decyen_r    <= d_hvmem_yen_r;
        d_deccen_r    <= d_hvmem_cen_r;
        rvc1mbpldc_r_s  <= c_mbpl_dc_r_s;
        r_hdtvh_r       <= p_hdtvh_dc_r;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_dly1 <= 8'd0;
        r_dly2 <= 8'd0;
      end
    else
      begin
        r_dly1 <= {r_dly1[6:0],d_deccen_r | d_decyen_r};
        r_dly2 <= {r_dly2[6:0],d_deccen_r};
      end
  end

assign wpcnt_enb = d_deccen_r | d_decyen_r | r_dly1[7];
assign wpcnt_ld  = rvc1mbpldc_r_s |
                   ((d_deccen_r | r_dly2[7]) & (r_pcnt[1:0]==2'b11));
assign wlcnt_enb = (d_deccen_r | r_dly2[7]) ?
                   (r_pcnt[1:0]==2'b11) : (r_pcnt[2:0]==3'b111);

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_pcnt <= 3'd0;
      end
    else if ((wpcnt_ld == 1'b1) || (r_hdtvh_r == 1'b0))
      begin
        r_pcnt <= 3'd0;
      end
    else if (wpcnt_enb == 1'b1)
      begin
        r_pcnt <= r_pcnt + 1'b1;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_lcnt <= 6'd0;
      end
    else if ((rvc1mbpldc_r_s == 1'b1) || (r_hdtvh_r == 1'b0))
      begin
        r_lcnt <= 6'd0;
      end
    else if (wlcnt_enb == 1'b1)
      begin
        r_lcnt <= r_lcnt + 1'b1;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        rbff_enb_r <= 1'b0;
      end
    else if (r_lcnt < 6'd17)
      begin
        rbff_enb_r <= (r_pcnt == 3'b111);
      end
    else
      begin
        rbff_enb_r <= (r_pcnt[1:0] == 2'b11);
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x) 
      begin
        d_b_ff_enb_r <= 1'b0;
      end
    else
      begin
        d_b_ff_enb_r <= rbff_enb_r;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        d_c_slct  <= 1'b0;
        d_c1_slct <= 1'b0;
      end
    else
      begin
        d_c_slct  <= d_deccen_r | r_dly2[7];
        d_c1_slct <= r_dly2[7];
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        d_phase   <= 3'd0;
      end
    else
      begin
        d_phase   <= r_pcnt;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        d_f_ff_enb_r<= 8'd0;
      end
    else
      begin
        case (r_pcnt)
          3'b000  : d_f_ff_enb_r <= 8'b00000001;
          3'b001  : d_f_ff_enb_r <= 8'b00000010;
          3'b010  : d_f_ff_enb_r <= 8'b00000100;
          3'b011  : d_f_ff_enb_r <= 8'b00001000;
          3'b100  : d_f_ff_enb_r <= 8'b00010000;
          3'b101  : d_f_ff_enb_r <= 8'b00100000;
          3'b110  : d_f_ff_enb_r <= 8'b01000000;
          3'b111  : d_f_ff_enb_r <= 8'b10000000;
        endcase
      end
  end

assign rvfltyen_set = ((r_lcnt > 6'd0) && (r_lcnt < 6'd17) && (rbff_enb_r == 1'b1))
                      ? 1'b1 : 1'b0;
assign rvfltcen_set = ((r_lcnt > 6'd17) && (r_lcnt < 6'd34) && (rbff_enb_r == 1'b1))
                      ? 1'b1 : 1'b0;

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        vflt_cen_set_dly_r <= 1'b0;
      end
    else
      begin
        vflt_cen_set_dly_r <= rvfltcen_set;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        vflt_yen_set_dly <= 3'd0;
      end
    else
      begin
        vflt_yen_set_dly <= {vflt_yen_set_dly[1:0],rvfltyen_set};
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_vflt_yen_dly <= 10'd0;
      end
    else
      begin
        r_vflt_yen_dly <= {r_vflt_yen_dly[8:0],
                           rvfltyen_set |
                           vflt_yen_set_dly[2] |
                           vflt_yen_set_dly[1] |
                           vflt_yen_set_dly[0]};
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x) 
      begin
        d_vflt_yen_r <= 1'b0;
      end
    else
      begin
        d_vflt_yen_r <= r_vflt_yen_dly[9];
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_vflt_cen_dly <= 10'd0;
      end
    else
      begin
        r_vflt_cen_dly <= {r_vflt_cen_dly[8:0],
                           rvfltcen_set | vflt_cen_set_dly_r};
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        d_vflt_cen_r <= 1'b0;
      end
    else
      begin
        d_vflt_cen_r <= r_vflt_cen_dly[9];
      end
  end
endmodule

