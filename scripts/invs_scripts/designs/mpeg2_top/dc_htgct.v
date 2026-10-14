// ----------------------------------------------
// File: dc_htgct.v
// Module: dc_htgct
// Function:timing controle for horizon filter
// ----------------------------------------------

module dc_htgct ( 
   clkdec, 
   rstdec_x, 
   p_hdtvh_dc_r, 
   m_decyen_r, 
   m_deccen_r, 
   c_mbpl_dc_r_s, 
   d_f_ff_enb_r, 
   d_b_ff_enb_r, 
   d_phase, 
   d_c_slct_r, 
   d_c1_slct_r, 
   d_decyen_r, 
   d_hdtvh_dc_r, 
   d_dech_yen_r,
   d_dech_cen_r
);

input        clkdec;     
input        rstdec_x;   
input        p_hdtvh_dc_r; 
input        m_decyen_r;   
input        m_deccen_r;   
input        c_mbpl_dc_r_s;
output [7:0] d_f_ff_enb_r; 
output       d_b_ff_enb_r; 
output [2:0] d_phase;      
output       d_c_slct_r;   
output       d_c1_slct_r;  
output       d_decyen_r;   
output       d_hdtvh_dc_r; 
output       d_dech_yen_r; 
output       d_dech_cen_r; 

wire         clkdec;     
wire         rstdec_x;   
wire         p_hdtvh_dc_r;  // HDTV mode
wire         m_decyen_r;    // Y-composit enb
wire         m_deccen_r;    // C-composit enb
wire         c_mbpl_dc_r_s; // MB pulse
wire         w_pcnt_enb;    // pixcel(phase) count enable
wire         w_pcnt_ld;     // pixcel(phase) count load
wire         w_lcnt_enb;    // line count enable
reg          d_hdtvh_dc_r;  // HDTV mode
reg          d_dech_yen_r;  // Y-composit enb
reg          d_dech_cen_r;  // C-composit enb
reg   [19:0] sfr_yen;       // dlySFR @Y-composit
reg   [19:0] sfr_cen;       // dlySFR @Y-composit
reg          d_decyen_r;    // Y-composit enb
reg          d_deccen_r;    // C-composit enb
reg          d_mbpl_dc_r;   // MB pulse
reg    [7:0] r_dly1;        // dly for count enb
reg    [15:0] r_dly2;       // dly for count enb
reg    [2:0] r_pcnt;        // pixcel(phase) count
reg    [5:0] r_lcnt;        // line count
reg          r_b_ff_enb_r;  // back-side F/F enable
reg          d_c_slct_r;    // C-composit enable
reg          d_c1_slct_r;   // C-composit enable
reg    [7:0] d_f_ff_enb_r;  // front-side F/F enable
reg          d_b_ff_enb_r;  // back-side F/F enable
reg    [2:0] d_phase;       // phase of filter

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        d_decyen_r      <= 1'b0;
        d_deccen_r      <= 1'b0;
        d_mbpl_dc_r     <= 1'b0;
        d_hdtvh_dc_r    <= 1'b0;
      end
    else
      begin
        d_decyen_r      <= m_decyen_r;
        d_deccen_r      <= m_deccen_r;
        d_mbpl_dc_r     <= c_mbpl_dc_r_s;
        d_hdtvh_dc_r    <= p_hdtvh_dc_r;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x) 
      begin
        d_dech_yen_r <= 1'b0;
        d_dech_cen_r <= 1'b0;
      end
    else
      begin
        d_dech_yen_r <= (d_hdtvh_dc_r) ? sfr_yen[19] :sfr_yen[0];   // adjust
        d_dech_cen_r <= (d_hdtvh_dc_r) ? sfr_cen[19] :sfr_cen[0]; 
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        sfr_yen <= 20'd0;
        sfr_cen <= 20'd0;
      end
    else
      begin
        sfr_yen <= {sfr_yen[18:0],d_decyen_r};
        sfr_cen <= {sfr_cen[18:0],d_deccen_r};
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_dly1 <= 8'd0;
        r_dly2 <= 16'd0;
      end
    else
      begin
        r_dly1 <= {r_dly1[6:0],d_deccen_r | d_decyen_r};
        r_dly2 <= {r_dly2[14:0],d_deccen_r};
      end
  end

assign w_pcnt_enb = d_deccen_r | d_decyen_r | r_dly1[7];
assign w_pcnt_ld  = d_mbpl_dc_r | (r_dly2[15] & (r_pcnt[1:0]==2'b11));
assign w_lcnt_enb = (d_deccen_r) ? (r_pcnt[1:0]==2'b11) : (r_pcnt[2:0]==3'b111);

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_pcnt <= 3'd0;
      end
    else if (w_pcnt_ld == 1'b1)
      begin
        r_pcnt <= 3'd0;
      end
    else if (w_pcnt_enb == 1'b1)
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
    else if (d_mbpl_dc_r == 1'b1)
      begin
        r_lcnt <= 6'd0;
      end
    else if (w_lcnt_enb == 1'b1)
      begin
        r_lcnt <= r_lcnt + 1'b1;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_b_ff_enb_r <= 1'b0;
      end
    else if (r_lcnt < 6'd17)
      begin
        r_b_ff_enb_r <= (r_pcnt == 3'b111);
      end
    else
      begin
        r_b_ff_enb_r <= (r_pcnt[1:0] == 2'b11);
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
        d_b_ff_enb_r <= r_b_ff_enb_r;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        d_c_slct_r <= 1'b0;
      end
    else
      begin
        d_c_slct_r <= r_dly2[15];
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        d_c1_slct_r <= 1'b0;
      end
    else
      begin
        d_c1_slct_r <= d_deccen_r | r_dly2[15];
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
        if (d_c1_slct_r==1'b1)
          begin
            case (r_pcnt)
              3'b000  : d_f_ff_enb_r <= 8'b00000001;
              3'b001  : d_f_ff_enb_r <= 8'b00000010;
              3'b010  : d_f_ff_enb_r <= 8'b00000100;
              3'b011  : d_f_ff_enb_r <= 8'b00001000;
              3'b100  : d_f_ff_enb_r <= 8'b00000001;
              3'b101  : d_f_ff_enb_r <= 8'b00000010;
              3'b110  : d_f_ff_enb_r <= 8'b00000100;
              3'b111  : d_f_ff_enb_r <= 8'b00001000;
            endcase
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
  end
endmodule
