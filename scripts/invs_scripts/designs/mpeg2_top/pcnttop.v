// ----------------------------------------------
// File: pcnttop.v
// Module: pcnttop
// Function:Field Memory Control & Display I/F
// ----------------------------------------------

module  pcnttop(
  clkdec,
  rstdec_x,
  c_frmpl_r_s,
  c_fldpl_r_s,
  c_pcpl_r_s,
  c_prgseq_r,
  c_pstr_r,
  c_pic_codtyp_r,
  c_first_top_r,
  c_first_proc_r,
  c_brklnk_r,
  c_crs_gop_r,
  c_lwdly_r,
  g_pini_r,
  g_bmod_r,
  g_chg_slp_r,
  v1_dspfld_num1,
  v1_dspfld_num2,
  v1_dspfld_sc1,
  v1_dspfld_sc2,
  v1_dsp_ps,
  n_decfld_num1_r,
  n_decfld_num2_r,
  n_reffld_num1_r,
  n_reffld_num2_r,
  n_reffld_num3_r,
  n_reffld_num4_r,
  n_pic_codtyp_reffld1_r,
  n_pic_codtyp_reffld2_r,
  n_pic_codtyp_reffld3_r,
  n_pic_codtyp_reffld4_r
);

input    clkdec;      // System Clock
input    rstdec_x;    // System Reset
input    c_frmpl_r_s;    // Frame Pulse
input    c_fldpl_r_s;    // Field Pulse
input    c_pcpl_r_s;    // Picture Processing Start
input    c_prgseq_r;    // Progressive Sequence
input  [1:0]  c_pstr_r;    // Picture Structure
input  [2:0]  c_pic_codtyp_r;    // Picture Coding Type
input    c_first_top_r;    // Top Field First
input    c_first_proc_r;    // First Field
input    c_brklnk_r;    // Broken Link
input    c_crs_gop_r;    // Closed GOP
input    c_lwdly_r;    // Low Delay
input    g_pini_r;    // PCNT Initialization (R/W Reset)
input    g_bmod_r;    // B-Picture Mask Mode
input    g_chg_slp_r;    // Flag If Sequence Level Parameter were Changed
output  [3:0]  v1_dspfld_num1;    // Display Plane (Top Field)
output  [3:0]  v1_dspfld_num2;    // Display Plane (Bottom Field)
output    v1_dspfld_sc1;    // Sequence Change (Top Field)
output    v1_dspfld_sc2;    // Sequence Change (Bottom Field)
output    v1_dsp_ps;    // Progressive Sequence
output  [3:0]  n_decfld_num1_r;  // Decoding Plane (Top Field)
output  [3:0]  n_decfld_num2_r;  // Decoding Plane (Bottom Field)
output  [3:0]  n_reffld_num1_r;  // Reference Plane (Forward-Top Field)
output  [3:0]  n_reffld_num2_r;  // Reference Plane (Forward-Bottom Field)
output  [3:0]  n_reffld_num3_r;  // Reference Plane (Backward-Top Field)
output  [3:0]  n_reffld_num4_r;  // Reference Plane (Backward-Bottom Field)
output  [2:0]  n_pic_codtyp_reffld1_r;  // Reference Picture Coding Type (Forward-Top Field)
output  [2:0]  n_pic_codtyp_reffld2_r;  // Reference Picture Coding Type (Forward-Bottom Field)
output  [2:0]  n_pic_codtyp_reffld3_r;  // Reference Picture Coding Type (Backward-Top Field)
output  [2:0]  n_pic_codtyp_reffld4_r;  // Reference Picture Coding Type (Backward-Bottom Field)


reg    n_frmpl_r_s;    // Frame Pulse
reg    n_fldpl_r_s;    // Field Pulse
reg    n_pcpl_r_s;    // Picture Processing Start
reg    n_prgseq_r;    // Progressive Sequence
reg  [1:0]  n_pstr_r;    // Picture Structure
reg  [2:0]  n_pic_codtyp_r;    // Picture Coding Type
reg    n_first_top_r;    // Top Field First
reg    n_first_proc_r;    // First Field
reg    n_brklnk_r;    // Broken Link
reg    n_crs_gop_r;    // Closed GOP
reg    n_lwdly_r;    // Low Delay
reg    n_pini_r;    // PCNT Initialization (R/W Reset)
reg    n_bmod_r;    // B-Picture Mask Mode
reg    n_chg_slp_r;    // Flag If Sequence Level Parameter were Changed
reg    n_sta_fr_s;    // Frame Start Pulse 
reg    n_sta_1f_s;    // First Field Start Pulse 
reg    n_sta_2f_s;    // Second Field Start Pulse 
reg    n_sta_tf_s;    // Top Field Start Pulse
reg    n_sta_bf_s;    // Bottom Field Start Pulse
reg    n_fld_mis_ip_s;    // Field Pair Mismatch (IP-Picture)
reg    n_fld_mis_b_s;    // Field Pair Mismatch (B-Picture)
reg    n_pct_isb;    // Flag if Picure Coding Type is B-Picture
reg    n_prev_1f_ip_r;    // Flag if Previous Field is First Field (IP-Picture)
reg    n_prev_1f_b_r;    // Flag if Previous Field is First Field (B-Picture)
reg    n_mask_bpic;    // B-Picture Mask Flag
reg    n_fld_mis_i_bmsk_s;  // Field Pair Mismatch (B-Picture Masked by I-Picture)
reg  [1:0]  n_dec_ip_d;    // Decoding Plane Counter (IP-Picture)
reg  [1:0]  n_dec_ip_r;    // Decoding Plane Counter (IP-Picture)
reg  [1:0]  n_dec_b_d;    // Decoding Plane Counter (B-Picture)
reg  [1:0]  n_dec_b_r;    // Decoding Plane Counter (B-Picture)
reg    n_dec_pct_r;    // Decoding Picture Coding Type
reg  [2:0]  n_dec_tf_r;    // Decoding Plane (Top Field)
reg  [2:0]  n_dec_bf_r;    // Decoding Plane (Bottom Field)
reg  [1:0]  n_ref_btf_r;    // Reference Plane (Backward-Top Field)
reg  [1:0]  n_ref_bbf_r;    // Reference Plane (Backward-Bottom Field)
reg  [1:0]  n_ref_ftf_r;    // Reference Plane (Forward-Top Field)
reg  [1:0]  n_ref_fbf_r;    // Reference Plane (Forward-Bottom Field)
reg    n_ref_sw_ftf_r;    // Reference Plane Switch Flag (Forward-Top Field)
reg    n_ref_sw_fbf_r;    // Reference Plane Switch Flag (Forward-Bottom Field)
reg  [1:0]  n_reffld_ftf_r;    // Reference Plane (Forward-Top Field)
reg  [1:0]  n_reffld_fbf_r;    // Reference Plane (Forward-Bottom Field)
reg  [2:0]  n_pic_codtyp_reffld3_r;  // Reference Picture Coding Type (Backward-Top Field)
reg  [2:0]  n_pic_codtyp_reffld4_r;  // Reference Picture Coding Type (Backward-Bottom Field)
reg  [2:0]  n_pic_codtyp_reffld1__r;// Reference Picture Coding Type (Forward-Top Field)
reg  [2:0]  n_pic_codtyp_reffld2__r;// Reference Picture Coding Type (Forward-Bottom Field)
reg  [2:0]  n_pic_codtyp_reffld1_r;  // Reference Picture Coding Type (Forward-Top Field)
reg  [2:0]  n_pic_codtyp_reffld2_r;  // Reference Picture Coding Type (Forward-Bottom Field)
reg  [1:0]  n_dsp_nx1_1f_num_r;  // Display Plane (First Field)
reg    n_dsp_nx1_1f_sc_r;  // Sequence Change (First Field)
reg  [2:0]  n_dsp_nx1_tf_num_r;  // Display Plane (Top Field)
reg  [2:0]  n_dsp_nx1_bf_num_r;  // Display Plane (Bottom Field)
reg    n_dsp_nx1_sc_r;    // Sequence Change
reg    n_dsp_nx1_ps_r;    // Progressive Sequence
reg    n_dsp_nx1_tff_r;  // Top Field First
reg  [1:0]  n_dsp_nx2_1f_num_r;  // Display Plane (First Field)
reg    n_dsp_nx2_1f_sc_r;  // Sequence Change (First Field)
reg  [2:0]  n_dsp_nx2_tf_num_r;  // Display Plane (Top Field)
reg  [2:0]  n_dsp_nx2_bf_num_r;  // Display Plane (Bottom Field)
reg  [2:0]  n_dsp_nx2_2f_num_r;  // Display Plane (Second Field)
reg    n_dsp_nx2_sc_r;    // Sequence Change
reg    n_dsp_nx2_ps_r;    // Progressive Sequence
reg    n_dsp_nx2_tff_r;  // Top Field First
reg  [2:0]  n_dspfld_num1;    // Display Plane (Top Field)
reg  [2:0]  n_dspfld_num2;    // Display Plane (Bottom Field)
reg    v1_dspfld_sc1;    // Sequence Change (Top Field)
reg    v1_dspfld_sc2;    // Sequence Change (Bottom Field)
reg    v1_dsp_ps;    // Progressive Sequence
reg    n_dsp_tff_r;    // Top Field First
reg    n_dsp_tf_trg_r;    // Display Plane Trigger (Top Field)
reg    n_dsp_bf_trg_r;    // Display Plane Trigger (Bottom Field)
reg    n_dsp_2f_mask_r;  // Display Plane Trigger Mask (Second Field)
wire  [2:0]  n_dsp_tf_sc_dec_cnt;  // Decrement Value of n_dsp_tf_sc_cnt_r
wire  [2:0]  n_dsp_bf_sc_dec_cnt;  // Decrement Value of n_dsp_bf_sc_cnt_r
reg  [2:0]  n_dsp_tf_sc_cnt_r;  // Counter for Asert Cycle of Sequence Change Flag
reg  [2:0]  n_dsp_bf_sc_cnt_r;  // Counter for Asert Cycle of Sequence Change Flag


always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0) begin
    n_frmpl_r_s    <= 1'b0;
    n_fldpl_r_s    <= 1'b0;
    n_pcpl_r_s    <= 1'b0;
    n_prgseq_r    <= 1'b0;
    n_pstr_r    <= 2'h0;
    n_pic_codtyp_r  <= 3'h0;
    n_first_top_r    <= 1'b0;
    n_first_proc_r  <= 1'b0;
    n_brklnk_r    <= 1'b0;
    n_crs_gop_r    <= 1'b0;
    n_lwdly_r    <= 1'b0;
    n_pini_r    <= 1'b0;
    n_bmod_r    <= 1'b0;
    n_chg_slp_r    <= 1'b0;
  end
  else begin
    n_frmpl_r_s    <= c_frmpl_r_s;
    n_fldpl_r_s    <= c_fldpl_r_s;
    n_pcpl_r_s    <= c_pcpl_r_s;
    n_prgseq_r    <= c_prgseq_r;
    n_pstr_r    <= c_pstr_r;
    n_pic_codtyp_r  <= c_pic_codtyp_r;
    n_first_top_r    <= c_first_top_r;
    n_first_proc_r  <= c_first_proc_r;
    n_brklnk_r    <= c_brklnk_r;
    n_crs_gop_r    <= c_crs_gop_r;
    n_lwdly_r    <= c_lwdly_r;
    n_pini_r    <= g_pini_r;
    n_bmod_r    <= g_bmod_r;
    n_chg_slp_r    <= g_chg_slp_r;
  end
end

always @(n_pcpl_r_s     or n_prgseq_r     or n_pstr_r or
   n_first_proc_r or n_prev_1f_ip_r or n_prev_1f_b_r) begin
  if(n_pcpl_r_s == 1'b1) begin
    if(n_prgseq_r == 1'b1 || n_pstr_r == 2'b11) begin
      n_sta_fr_s    = 1'b1;
      n_sta_1f_s    = 1'b0;
      n_sta_2f_s    = 1'b0;
      n_sta_tf_s    = 1'b0;
      n_sta_bf_s    = 1'b0;
      if(n_prev_1f_ip_r == 1'b1)
        n_fld_mis_ip_s  = 1'b1;
      else
        n_fld_mis_ip_s  = 1'b0;
      if(n_prev_1f_b_r == 1'b1)
        n_fld_mis_b_s    = 1'b1;
      else
        n_fld_mis_b_s    = 1'b0;
    end
    else if(n_first_proc_r == 1'b1) begin
      n_sta_fr_s    = 1'b0;
      n_sta_1f_s    = 1'b1;
      n_sta_2f_s    = 1'b0;
      if(n_pstr_r == 2'b01)
        n_sta_tf_s    = 1'b1;
      else  
        n_sta_tf_s    = 1'b0;
      if(n_pstr_r == 2'b10)
        n_sta_bf_s    = 1'b1;
      else  
        n_sta_bf_s    = 1'b0;
      if(n_prev_1f_ip_r == 1'b1)
        n_fld_mis_ip_s  = 1'b1;
      else
        n_fld_mis_ip_s  = 1'b0;
      if(n_prev_1f_b_r == 1'b1)
        n_fld_mis_b_s    = 1'b1;
      else
        n_fld_mis_b_s    = 1'b0;
    end
    else begin
      n_sta_fr_s    = 1'b0;
      n_sta_1f_s    = 1'b0;
      n_sta_2f_s    = 1'b1;
      if(n_pstr_r == 2'b01)
        n_sta_tf_s    = 1'b1;
      else  
        n_sta_tf_s    = 1'b0;
      if(n_pstr_r == 2'b10)
        n_sta_bf_s    = 1'b1;
      else
        n_sta_bf_s    = 1'b0;
      n_fld_mis_ip_s  = 1'b0;
      n_fld_mis_b_s    = 1'b0;
    end
  end
  else begin
    n_sta_fr_s    = 1'b0;
    n_sta_1f_s    = 1'b0;
    n_sta_2f_s    = 1'b0;
    n_sta_tf_s    = 1'b0;
    n_sta_bf_s    = 1'b0;
    n_fld_mis_ip_s  = 1'b0;
    n_fld_mis_b_s    = 1'b0;
  end
end

always @(n_pic_codtyp_r) begin
  if(n_pic_codtyp_r == 3'b011)
    n_pct_isb  = 1'b1;
  else
    n_pct_isb  = 1'b0;
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0) begin
    n_prev_1f_ip_r  <= 1'b0;
    n_prev_1f_b_r    <= 1'b0;
  end
  else if(n_pini_r == 1'b1) begin
    n_prev_1f_ip_r  <= 1'b0;
    n_prev_1f_b_r    <= 1'b0;
  end 
  else if(n_pcpl_r_s == 1'b1) begin
    if(n_prgseq_r == 1'b1 || n_pstr_r == 2'b11) begin
      if(n_pct_isb == 1'b1)
        n_prev_1f_b_r    <= 1'b0;
      else
        n_prev_1f_ip_r  <= 1'b0;
    end
    else if(n_first_proc_r == 1'b1) begin
      if(n_pct_isb == 1'b1)
        n_prev_1f_b_r    <= 1'b1;
      else  
        n_prev_1f_ip_r  <= 1'b1;
    end
    else begin
      if(n_pct_isb == 1'b1)
        n_prev_1f_b_r    <= 1'b0;
      else
        n_prev_1f_ip_r  <= 1'b0;
    end
  end
end

always @(n_bmod_r or n_brklnk_r or n_crs_gop_r) begin
  if(n_bmod_r   == 1'b0 &&
     n_brklnk_r == 1'b1 && n_crs_gop_r == 1'b0)
    n_mask_bpic  = 1'b1;
  else
    n_mask_bpic  = 1'b0;
end

always @(n_fld_mis_ip_s or n_mask_bpic or n_pct_isb) begin
  if(n_fld_mis_ip_s == 1'b1 && n_mask_bpic == 1'b1 &&
     n_pct_isb      == 1'b1)
    n_fld_mis_i_bmsk_s  = 1'b1;
  else
    n_fld_mis_i_bmsk_s  = 1'b0;
end


always @(n_pini_r  or n_sta_fr_s or n_sta_1f_s or
   n_pct_isb or n_dec_ip_r or n_fld_mis_ip_s) begin
  if(n_pini_r == 1'b1)
    n_dec_ip_d  = 2'h3;
  else if(n_sta_fr_s == 1'b1 || n_sta_1f_s == 1'b1) begin
    if(n_pct_isb == 1'b1)
      n_dec_ip_d  = n_dec_ip_r;
    else begin
      if(n_fld_mis_ip_s == 1'b1)
        n_dec_ip_d  = n_dec_ip_r;
      else 
        n_dec_ip_d  = n_dec_ip_r + 1'b1;
    end
  end
  else
    n_dec_ip_d  = n_dec_ip_r;
end
always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dec_ip_r  <= 2'h3;
  else
    n_dec_ip_r  <= n_dec_ip_d;
end


always @(n_pini_r  or n_sta_fr_s or n_sta_1f_s or
   n_pct_isb or n_dec_b_r  or n_fld_mis_b_s) begin
  if(n_pini_r == 1'b1)
    n_dec_b_d  = 2'h2;
  else if(n_sta_fr_s == 1'b1 || n_sta_1f_s == 1'b1) begin
    if(n_pct_isb == 1'b1) begin
      if(n_fld_mis_b_s == 1'b1) 
        n_dec_b_d  = n_dec_b_r;
      else if(n_dec_b_r == 2'b10)
        n_dec_b_d  = 2'h0;
      else
        n_dec_b_d  = n_dec_b_r + 1'b1;
    end
    else
      n_dec_b_d  = n_dec_b_r;
  end
  else
    n_dec_b_d  = n_dec_b_r;
end
always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dec_b_r  <= 2'h2;
  else
    n_dec_b_r  <= n_dec_b_d;
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dec_pct_r  <= 1'b0;
  else if(n_pini_r == 1'b1)
    n_dec_pct_r  <= 1'b0;
  else if(n_sta_fr_s == 1'b1 || n_sta_1f_s == 1'b1) begin
    if(n_pct_isb == 1'b1)
      n_dec_pct_r  <= 1'b1;
    else  
      n_dec_pct_r  <= 1'b0;
  end
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dec_tf_r  <= 3'h3;
  else if(n_pini_r == 1'b1)
    n_dec_tf_r  <= 3'h3;
  else if(n_dec_pct_r == 1'b1)
    n_dec_tf_r  <= {1'b1,n_dec_b_r};
  else  
    n_dec_tf_r  <= {1'b0,n_dec_ip_r};
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dec_bf_r  <= 3'h3;
  else if(n_pini_r == 1'b1)
    n_dec_bf_r  <= 3'h3;
  else if(n_dec_pct_r == 1'b1)
    n_dec_bf_r  <= {1'b1,n_dec_b_r};
  else
    n_dec_bf_r  <= {1'b0,n_dec_ip_r};
end

wire mask_trg ;
assign mask_trg = n_dsp_2f_mask_r ^ n_dsp_bf_trg_r ^ n_dsp_tf_trg_r ;

assign  n_decfld_num1_r  = {n_dec_tf_r, mask_trg};
assign  n_decfld_num2_r  = {n_dec_bf_r, mask_trg};


always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_ref_btf_r  <= 2'h0;
  else if(n_pini_r == 1'b1)
    n_ref_btf_r  <= 2'h0;
  else if(n_sta_fr_s == 1'b1 || n_sta_tf_s == 1'b1) begin
    if(n_pct_isb == 1'b0 && n_fld_mis_ip_s == 1'b0)
      n_ref_btf_r  <= n_dec_ip_d;
  end
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_ref_bbf_r  <= 2'h0;
  else if(n_pini_r == 1'b1)
    n_ref_bbf_r  <= 2'h0;
  else if(n_sta_fr_s == 1'b1 || n_sta_bf_s == 1'b1) begin
    if(n_pct_isb == 1'b0 && n_fld_mis_ip_s == 1'b0)
      n_ref_bbf_r  <= n_dec_ip_d;
  end
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_ref_ftf_r  <= 2'h0;
  else if(n_pini_r == 1'b1)
    n_ref_ftf_r  <= 2'h0;
  else if(n_sta_fr_s == 1'b1 || n_sta_1f_s == 1'b1) begin
    if(n_pct_isb == 1'b0 && n_fld_mis_ip_s == 1'b0)
      n_ref_ftf_r  <= n_ref_btf_r;
  end
end


always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_ref_fbf_r  <= 2'h0;
  else if(n_pini_r == 1'b1)
    n_ref_fbf_r  <= 2'h0;
  else if(n_sta_fr_s == 1'b1 || n_sta_1f_s == 1'b1) begin
    if(n_pct_isb == 1'b0 && n_fld_mis_ip_s == 1'b0)
      n_ref_fbf_r  <= n_ref_bbf_r;
  end
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_ref_sw_ftf_r  <= 1'b0;
  else if(n_pini_r == 1'b1)
    n_ref_sw_ftf_r  <= 1'b0;
  else if(n_sta_fr_s == 1'b1)
    n_ref_sw_ftf_r  <= 1'b0;
  else if(n_sta_1f_s == 1'b1)
    n_ref_sw_ftf_r  <= 1'b0;
  else if(n_sta_2f_s == 1'b1) begin
    if(n_pct_isb == 1'b0 && n_pstr_r == 2'b10)
      n_ref_sw_ftf_r  <= 1'b1;
    else
      n_ref_sw_ftf_r  <= 1'b0;
  end
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_ref_sw_fbf_r  <= 1'b0;
  else if(n_pini_r == 1'b1)
    n_ref_sw_fbf_r  <= 1'b0;
  else if(n_sta_fr_s == 1'b1)
    n_ref_sw_fbf_r  <= 1'b0;
  else if(n_sta_1f_s == 1'b1)
    n_ref_sw_fbf_r  <= 1'b0;
  else if(n_sta_2f_s == 1'b1) begin
    if(n_pct_isb == 1'b0 && n_pstr_r == 2'b01)
      n_ref_sw_fbf_r  <= 1'b1;
    else
      n_ref_sw_fbf_r  <= 1'b0;
  end
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_reffld_ftf_r  <= 2'h0;
  else if(n_pini_r == 1'b1)
    n_reffld_ftf_r  <= 2'h0;
  else if(n_ref_sw_ftf_r == 1'b1)
    n_reffld_ftf_r  <= n_ref_btf_r;
  else
    n_reffld_ftf_r  <= n_ref_ftf_r;
end
assign  n_reffld_num1_r  = {mask_trg,n_reffld_ftf_r,mask_trg};


always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_reffld_fbf_r  <= 2'h0;
  else if(n_pini_r == 1'b1)
    n_reffld_fbf_r  <= 2'h0;
  else if(n_ref_sw_fbf_r == 1'b1)
    n_reffld_fbf_r  <= n_ref_bbf_r;
  else
    n_reffld_fbf_r  <= n_ref_fbf_r;
end

assign  n_reffld_num2_r  = {mask_trg,n_reffld_fbf_r,mask_trg};
assign  n_reffld_num3_r  = {mask_trg,n_ref_btf_r,mask_trg};
assign  n_reffld_num4_r  = {mask_trg,n_ref_bbf_r,mask_trg};

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_pic_codtyp_reffld3_r  <= 3'h0;
  else if(n_pini_r == 1'b1)
    n_pic_codtyp_reffld3_r  <= 3'h0;
  else if(n_sta_fr_s == 1'b1 || n_sta_tf_s == 1'b1) begin
    if(n_pct_isb == 1'b0 && n_fld_mis_ip_s == 1'b0)
      n_pic_codtyp_reffld3_r  <= n_pic_codtyp_r;
  end
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_pic_codtyp_reffld4_r  <= 3'h0;
  else if(n_pini_r == 1'b1)
    n_pic_codtyp_reffld4_r  <= 3'h0;
  else if(n_sta_fr_s == 1'b1 || n_sta_bf_s == 1'b1) begin
    if(n_pct_isb == 1'b0 && n_fld_mis_ip_s == 1'b0)
      n_pic_codtyp_reffld4_r  <= n_pic_codtyp_r;
  end
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_pic_codtyp_reffld1__r  <= 3'h0;
  else if(n_pini_r == 1'b1)
    n_pic_codtyp_reffld1__r  <= 3'h0;
  else if(n_sta_fr_s == 1'b1 || n_sta_1f_s == 1'b1) begin
    if(n_pct_isb == 1'b0 && n_fld_mis_ip_s == 1'b0)
      n_pic_codtyp_reffld1__r  <= n_pic_codtyp_reffld3_r;
  end
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_pic_codtyp_reffld2__r  <= 3'h0;
  else if(n_pini_r == 1'b1)
    n_pic_codtyp_reffld2__r  <= 3'h0;
  else if(n_sta_fr_s == 1'b1 || n_sta_1f_s == 1'b1) begin
    if(n_pct_isb == 1'b0 && n_fld_mis_ip_s == 1'b0)
      n_pic_codtyp_reffld2__r  <= n_pic_codtyp_reffld4_r;
  end
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_pic_codtyp_reffld1_r  <= 3'h0;
  else if(n_pini_r == 1'b1)
    n_pic_codtyp_reffld1_r  <= 3'h0;
  else if(n_ref_sw_ftf_r == 1'b1)
    n_pic_codtyp_reffld1_r  <= n_pic_codtyp_reffld3_r;
  else
    n_pic_codtyp_reffld1_r  <= n_pic_codtyp_reffld1__r;
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_pic_codtyp_reffld2_r  <= 3'h0;
  else if(n_pini_r == 1'b1)
    n_pic_codtyp_reffld2_r  <= 3'h0;
  else if(n_ref_sw_fbf_r == 1'b1)
    n_pic_codtyp_reffld2_r  <= n_pic_codtyp_reffld4_r;
  else
    n_pic_codtyp_reffld2_r  <= n_pic_codtyp_reffld2__r;
end


always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dsp_nx1_1f_num_r  <= 2'h0;
  else if(n_pini_r == 1'b1)
    n_dsp_nx1_1f_num_r  <= 2'h0;
  else if(n_sta_1f_s == 1'b1 && n_pct_isb == 1'b0)
    n_dsp_nx1_1f_num_r  <= n_dec_ip_d;
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dsp_nx1_1f_sc_r  <= 1'b0;
  else if(n_pini_r == 1'b1)
    n_dsp_nx1_1f_sc_r  <= 1'b0;
  else if(n_sta_1f_s == 1'b1 && n_pct_isb == 1'b0) begin
    if(n_fld_mis_ip_s == 1'b1)
      n_dsp_nx1_1f_sc_r  <= n_dsp_nx1_1f_sc_r | n_chg_slp_r;
    else
      n_dsp_nx1_1f_sc_r  <= n_chg_slp_r;
  end
  else if(n_sta_1f_s == 1'b1 && n_pct_isb == 1'b1) begin
    if(n_fld_mis_i_bmsk_s == 1'b1)
      n_dsp_nx1_1f_sc_r  <= n_dsp_nx1_1f_sc_r;
    else if(n_dsp_nx1_sc_r == 1'b1 || n_dsp_nx2_sc_r == 1'b1)
      n_dsp_nx1_1f_sc_r  <= 1'b0;
  end
  else if(n_sta_fr_s == 1'b1 && n_pct_isb == 1'b1) begin
    if(n_fld_mis_i_bmsk_s == 1'b1)
      n_dsp_nx1_1f_sc_r  <= n_dsp_nx1_1f_sc_r;
    else if(n_fld_mis_ip_s == 1'b1)
      n_dsp_nx1_1f_sc_r  <= 1'b0;
  end
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dsp_nx1_tf_num_r  <= 3'h7;
  else if(n_pini_r == 1'b1)
    n_dsp_nx1_tf_num_r  <= 3'h7;
  else if(n_sta_fr_s == 1'b1 && n_pct_isb == 1'b0)
    n_dsp_nx1_tf_num_r  <= {1'b0,n_dec_ip_d};
  else if(n_sta_2f_s == 1'b1 && n_pct_isb == 1'b0) begin
    if(n_pstr_r == 2'b01)
      n_dsp_nx1_tf_num_r  <= {1'b0,n_dec_ip_d};
    else if(n_pstr_r == 2'b10)
      n_dsp_nx1_tf_num_r  <= {1'b0,n_dsp_nx1_1f_num_r};
  end
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dsp_nx1_bf_num_r  <= 3'h7;
  else if(n_pini_r == 1'b1)
    n_dsp_nx1_bf_num_r  <= 3'h7;
  else if(n_sta_fr_s == 1'b1 && n_pct_isb == 1'b0)
    n_dsp_nx1_bf_num_r  <= {1'b0,n_dec_ip_d};
  else if(n_sta_2f_s == 1'b1 && n_pct_isb == 1'b0) begin
    if(n_pstr_r == 2'b10)
      n_dsp_nx1_bf_num_r  <= {1'b0,n_dec_ip_d};
    else if(n_pstr_r == 2'b01)
      n_dsp_nx1_bf_num_r  <= {1'b0,n_dsp_nx1_1f_num_r};
  end
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dsp_nx1_sc_r  <= 1'b0;
  else if(n_pini_r == 1'b1)
    n_dsp_nx1_sc_r  <= 1'b0;
  else if(n_sta_fr_s == 1'b1 && n_pct_isb == 1'b0)
    n_dsp_nx1_sc_r  <= n_chg_slp_r;
  else if(n_sta_fr_s     == 1'b1 && n_pct_isb == 1'b1 &&
    n_dsp_nx1_sc_r == 1'b1)
    n_dsp_nx1_sc_r  <= 1'b0;
  else if(n_sta_2f_s == 1'b1 && n_pct_isb == 1'b0) begin
    if(n_dsp_nx1_sc_r == 1'b1 || n_dsp_nx2_sc_r == 1'b1)
      n_dsp_nx1_sc_r  <= 1'b0;
    else
      n_dsp_nx1_sc_r  <= n_dsp_nx1_1f_sc_r;
  end
  else if(n_sta_2f_s     == 1'b1 && n_pct_isb == 1'b1 &&
    n_dsp_nx1_sc_r == 1'b1)
    n_dsp_nx1_sc_r  <= 1'b0;
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dsp_nx1_ps_r  <= 1'b0;
  else if(n_pini_r == 1'b1)
    n_dsp_nx1_ps_r  <= 1'b0;
  else if(n_sta_fr_s == 1'b1 && n_pct_isb == 1'b0)
    n_dsp_nx1_ps_r  <= n_prgseq_r;
  else if(n_sta_2f_s == 1'b1 && n_pct_isb == 1'b0)
    n_dsp_nx1_ps_r  <= n_prgseq_r;
  else if(n_fld_mis_ip_s == 1'b1 && n_pct_isb == 1'b1)
    n_dsp_nx1_ps_r  <= n_prgseq_r;
end

// Top Field First
always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dsp_nx1_tff_r  <= 1'b1;
  else if(n_pini_r == 1'b1)
    n_dsp_nx1_tff_r  <= 1'b1;
  else if(n_pcpl_r_s == 1'b1 && n_pstr_r == 2'b11 &&
    n_pct_isb  == 1'b0)
    n_dsp_nx1_tff_r  <=  n_first_top_r;
  else if(n_sta_2f_s == 1'b1 && n_pct_isb == 1'b0)
    n_dsp_nx1_tff_r  <= n_first_top_r;
end


always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dsp_nx2_1f_num_r  <= 2'h0;
  else if(n_pini_r == 1'b1)
    n_dsp_nx2_1f_num_r  <= 2'h0;
  else if(n_sta_1f_s == 1'b1 && n_pct_isb == 1'b1)
    n_dsp_nx2_1f_num_r  <= n_dec_b_d;
  else if(n_sta_1f_s == 1'b1 && n_pct_isb == 1'b0 &&
    n_lwdly_r  == 1'b1)
    n_dsp_nx2_1f_num_r  <= n_dec_ip_d;
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dsp_nx2_1f_sc_r  <= 1'b0;
  else if(n_pini_r == 1'b1)
    n_dsp_nx2_1f_sc_r  <= 1'b0;
  else if(n_sta_1f_s == 1'b1 && n_pct_isb == 1'b1) begin
    if(n_fld_mis_i_bmsk_s == 1'b1)
      n_dsp_nx2_1f_sc_r  <= n_chg_slp_r;
    else if(n_fld_mis_ip_s == 1'b1)
      n_dsp_nx2_1f_sc_r  <= n_dsp_nx1_1f_sc_r | n_dsp_nx2_1f_sc_r |
               n_chg_slp_r;
    else 
      n_dsp_nx2_1f_sc_r  <= n_chg_slp_r;
  end
  else if(n_sta_1f_s == 1'b1 && n_pct_isb == 1'b0 &&
    n_lwdly_r  == 1'b1) begin
    if(n_fld_mis_ip_s == 1'b1)
      n_dsp_nx2_1f_sc_r  <= n_dsp_nx2_1f_sc_r | n_chg_slp_r;
    else 
      n_dsp_nx2_1f_sc_r  <= n_chg_slp_r;
  end
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dsp_nx2_tf_num_r  <= 3'h7;
  else if(n_pini_r == 1'b1)
    n_dsp_nx2_tf_num_r  <= 3'h7;
  else if(n_sta_fr_s == 1'b1) begin
    if(n_pct_isb == 1'b1) begin
      if(n_mask_bpic == 1'b1)
        n_dsp_nx2_tf_num_r  <= n_dsp_nx1_tf_num_r;
      else
        n_dsp_nx2_tf_num_r  <= {1'b1,n_dec_b_d};
    end
    else if(n_lwdly_r == 1'b1)
      n_dsp_nx2_tf_num_r  <= {1'b0,n_dec_ip_d};
    else  
      n_dsp_nx2_tf_num_r  <= n_dsp_nx1_tf_num_r;
  end
  else if(n_sta_2f_s == 1'b1 && n_pct_isb == 1'b1) begin
    if(n_pstr_r == 2'b01) begin
      if(n_mask_bpic == 1'b1)
        n_dsp_nx2_tf_num_r  <= n_dsp_nx1_tf_num_r;
      else
        n_dsp_nx2_tf_num_r  <= {1'b1,n_dec_b_d};
    end
    else if(n_pstr_r == 2'b10) begin
      if(n_mask_bpic == 1'b1)
        n_dsp_nx2_tf_num_r  <= n_dsp_nx1_tf_num_r;
      else
        n_dsp_nx2_tf_num_r  <= {1'b1,n_dsp_nx2_1f_num_r};
    end
  end
  else if(n_sta_2f_s == 1'b1 && n_pct_isb == 1'b0 &&
    n_lwdly_r  == 1'b1) begin
    if(n_pstr_r == 2'b01)
      n_dsp_nx2_tf_num_r  <= {1'b0,n_dec_ip_d};
    else if(n_pstr_r == 2'b10)
      n_dsp_nx2_tf_num_r  <= {1'b0,n_dsp_nx2_1f_num_r};
  end
  else if(n_sta_2f_s == 1'b1 && n_pct_isb == 1'b0 &&
    n_lwdly_r  == 1'b0) begin
    if(n_dsp_nx1_tf_num_r == 3'h7)
      n_dsp_nx2_tf_num_r  <= n_dsp_nx2_tf_num_r;
    else
      n_dsp_nx2_tf_num_r  <= n_dsp_nx1_tf_num_r;
  end
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dsp_nx2_bf_num_r  <= 3'h7;
  else if(n_pini_r == 1'b1)
    n_dsp_nx2_bf_num_r  <= 3'h7;
  else if(n_sta_fr_s == 1'b1) begin
    if(n_pct_isb == 1'b1) begin
      if(n_mask_bpic == 1'b1)
        n_dsp_nx2_bf_num_r  <= n_dsp_nx1_bf_num_r;
      else
        n_dsp_nx2_bf_num_r  <= {1'b1,n_dec_b_d};
    end
    else if(n_lwdly_r == 1'b1)
      n_dsp_nx2_bf_num_r  <= {1'b0,n_dec_ip_d};
    else  
      n_dsp_nx2_bf_num_r  <= n_dsp_nx1_bf_num_r;
  end
  else if(n_sta_2f_s == 1'b1 && n_pct_isb == 1'b1) begin
    if(n_pstr_r == 2'b10) begin
      if(n_mask_bpic == 1'b1)
        n_dsp_nx2_bf_num_r  <= n_dsp_nx1_bf_num_r;
      else
        n_dsp_nx2_bf_num_r  <= {1'b1,n_dec_b_d};
    end
    else if(n_pstr_r == 2'b01) begin
      if(n_mask_bpic == 1'b1)
        n_dsp_nx2_bf_num_r  <= n_dsp_nx1_bf_num_r;
      else
        n_dsp_nx2_bf_num_r  <= {1'b1,n_dsp_nx2_1f_num_r};
    end
  end
  else if(n_sta_2f_s == 1'b1 && n_pct_isb == 1'b0 &&
    n_lwdly_r  == 1'b1) begin
    if(n_pstr_r == 2'b10)
      n_dsp_nx2_bf_num_r  <= {1'b0,n_dec_ip_d};
    else if(n_pstr_r == 2'b01)
      n_dsp_nx2_bf_num_r  <= {1'b0,n_dsp_nx2_1f_num_r};
  end
  else if(n_sta_2f_s == 1'b1 && n_pct_isb == 1'b0 &&
    n_lwdly_r  == 1'b0) begin
    if(n_dsp_nx1_bf_num_r == 3'h7)
      n_dsp_nx2_bf_num_r  <= n_dsp_nx2_bf_num_r;
    else
      n_dsp_nx2_bf_num_r  <= n_dsp_nx1_bf_num_r;
  end
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dsp_nx2_2f_num_r  <= 3'h7;
  else if(n_pini_r == 1'b1)
    n_dsp_nx2_2f_num_r  <= 3'h7;
  else if(n_frmpl_r_s == 1'b1 && n_dsp_nx2_ps_r == 1'b0) begin
    if(n_dsp_nx2_tff_r == 1'b1)
      n_dsp_nx2_2f_num_r  <= n_dsp_nx2_bf_num_r;
    else  
      n_dsp_nx2_2f_num_r  <= n_dsp_nx2_tf_num_r;
  end
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dsp_nx2_sc_r  <= 1'b0;
  else if(n_pini_r == 1'b1)
    n_dsp_nx2_sc_r  <= 1'b0;
  else if(n_sta_fr_s == 1'b1) begin
    if(n_fld_mis_i_bmsk_s == 1'b1)
      n_dsp_nx2_sc_r  <= n_dsp_nx2_sc_r;
    else if(n_fld_mis_ip_s == 1'b1)
      n_dsp_nx2_sc_r  <= n_dsp_nx1_1f_sc_r;
    else if(n_pct_isb == 1'b1)
      n_dsp_nx2_sc_r  <= n_chg_slp_r | n_dsp_nx1_sc_r;
    else if(n_lwdly_r == 1'b1)
      n_dsp_nx2_sc_r  <= n_chg_slp_r;
    else
      n_dsp_nx2_sc_r  <= n_dsp_nx1_sc_r;
  end
  else if(n_sta_2f_s == 1'b1) begin
    if(n_pct_isb == 1'b1) begin
      if(n_dsp_nx2_sc_r == 1'b1)
        n_dsp_nx2_sc_r  <= 1'b0;
      else
        n_dsp_nx2_sc_r  <= n_dsp_nx2_1f_sc_r | n_dsp_nx1_sc_r;
    end
    else if(n_lwdly_r == 1'b1)
      n_dsp_nx2_sc_r  <= n_dsp_nx2_1f_sc_r;
    else
      n_dsp_nx2_sc_r  <= n_dsp_nx1_sc_r;
  end
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dsp_nx2_ps_r  <= 1'b0;
  else if(n_pini_r == 1'b1)
    n_dsp_nx2_ps_r  <= 1'b0;
  else if(n_sta_fr_s == 1'b1 || n_sta_2f_s == 1'b1) begin
    if(n_pct_isb == 1'b1)
      n_dsp_nx2_ps_r  <= n_prgseq_r;
    else if(n_lwdly_r == 1'b1)
      n_dsp_nx2_ps_r  <= n_prgseq_r;
    else  
      n_dsp_nx2_ps_r  <= n_dsp_nx1_ps_r;
  end
end


always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dsp_nx2_tff_r  <= 1'b1;
  else if(n_pini_r == 1'b1)
    n_dsp_nx2_tff_r  <= 1'b1;
  else if(n_pcpl_r_s == 1'b1 && n_pstr_r == 2'b11) begin
    if(n_pct_isb == 1'b1)
      n_dsp_nx2_tff_r  <= n_first_top_r;
    else if(n_lwdly_r == 1'b1)
      n_dsp_nx2_tff_r  <= n_first_top_r;
    else  
      n_dsp_nx2_tff_r  <= n_dsp_nx1_tff_r;
  end
  else if(n_sta_2f_s == 1'b1) begin
    if(n_pct_isb == 1'b1)
      n_dsp_nx2_tff_r  <= n_first_top_r;
    else if(n_lwdly_r == 1'b1)
      n_dsp_nx2_tff_r  <= n_first_top_r;
    else  
      n_dsp_nx2_tff_r  <= n_dsp_nx1_tff_r;
  end
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dspfld_num1  <= 3'h7;
  else if(n_pini_r == 1'b1)
    n_dspfld_num1  <= 3'h7;
  else if(n_frmpl_r_s == 1'b1) begin
    if(n_dsp_nx2_ps_r == 1'b1)
      n_dspfld_num1  <= n_dsp_nx2_tf_num_r;
    else if(n_dsp_nx2_tff_r == 1'b1)
      n_dspfld_num1  <= n_dsp_nx2_tf_num_r;
  end
  else if(n_fldpl_r_s == 1'b1) begin
    if(v1_dsp_ps == 1'b0 && n_dsp_tff_r == 1'b0)
      n_dspfld_num1  <= n_dsp_nx2_2f_num_r;
  end
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dspfld_num2  <= 3'h7;
  else if(n_pini_r == 1'b1)
    n_dspfld_num2  <= 3'h7;
  else if(n_frmpl_r_s == 1'b1) begin
    if(n_dsp_nx2_ps_r == 1'b1)
      n_dspfld_num2  <= n_dsp_nx2_bf_num_r;
    else if(n_dsp_nx2_tff_r == 1'b0)
      n_dspfld_num2  <= n_dsp_nx2_bf_num_r;
  end
  else if(n_fldpl_r_s == 1'b1) begin
    if(v1_dsp_ps == 1'b0 && n_dsp_tff_r == 1'b1)
      n_dspfld_num2  <= n_dsp_nx2_2f_num_r;
  end
end

assign  v1_dspfld_num1  = {^(n_dspfld_num1),n_dspfld_num1};
assign  v1_dspfld_num2  = {^(n_dspfld_num2),n_dspfld_num2};
assign  n_dsp_tf_sc_dec_cnt  = n_dsp_tf_sc_cnt_r - 1'b1;
assign  n_dsp_bf_sc_dec_cnt  = n_dsp_bf_sc_cnt_r - 1'b1;

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0) begin
    v1_dspfld_sc1    <= 1'b0;
    n_dsp_tf_sc_cnt_r  <= 3'b000;
  end
  else if(n_pini_r == 1'b1) begin
    v1_dspfld_sc1    <= 1'b0;
    n_dsp_tf_sc_cnt_r  <= 3'b000;
  end
  else if(n_frmpl_r_s == 1'b1) begin
    if(n_dsp_nx2_ps_r == 1'b1) begin
      if(n_dsp_nx2_sc_r == 1'b1) begin
        v1_dspfld_sc1    <= n_dsp_nx2_sc_r;
        n_dsp_tf_sc_cnt_r  <= 3'b011;
      end
      else if(n_dsp_tf_sc_cnt_r != 3'b000) begin
        v1_dspfld_sc1    <= 1'b1;
        n_dsp_tf_sc_cnt_r  <= n_dsp_tf_sc_dec_cnt;
      end
      else begin
        v1_dspfld_sc1    <= n_dsp_nx2_sc_r;
        n_dsp_tf_sc_cnt_r  <= n_dsp_tf_sc_cnt_r;
      end
    end
    else if(n_dsp_nx2_tff_r == 1'b1) begin
      if(n_dsp_nx2_sc_r == 1'b1) begin
        v1_dspfld_sc1    <= n_dsp_nx2_sc_r;
        n_dsp_tf_sc_cnt_r  <= 3'b011;
      end
      else if(n_dsp_tf_sc_cnt_r != 3'b000) begin
        v1_dspfld_sc1    <= 1'b1;
        n_dsp_tf_sc_cnt_r  <= n_dsp_tf_sc_dec_cnt;
      end
      else begin
        v1_dspfld_sc1    <= n_dsp_nx2_sc_r;
        n_dsp_tf_sc_cnt_r  <= n_dsp_tf_sc_cnt_r;
      end
    end
    else begin
      if(n_dsp_nx2_sc_r == 1'b1) begin
        v1_dspfld_sc1    <= 1'b0;
        n_dsp_tf_sc_cnt_r  <= 3'b100;
      end
      else if(n_dsp_tf_sc_cnt_r != 3'b000) begin
        v1_dspfld_sc1    <= 1'b1;
        n_dsp_tf_sc_cnt_r  <= n_dsp_tf_sc_dec_cnt;
      end
      else begin
        v1_dspfld_sc1    <= n_dsp_nx2_sc_r;
        n_dsp_tf_sc_cnt_r  <= n_dsp_tf_sc_cnt_r;
      end
    end
  end
  else if(n_fldpl_r_s == 1'b1) begin
    if(n_dsp_tf_sc_cnt_r != 3'b000) begin
      v1_dspfld_sc1    <= 1'b1;
      n_dsp_tf_sc_cnt_r  <= n_dsp_tf_sc_dec_cnt;
    end
    else begin
      v1_dspfld_sc1    <= 1'b0;
      n_dsp_tf_sc_cnt_r  <= n_dsp_tf_sc_cnt_r;
    end
  end
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0) begin
    v1_dspfld_sc2    <= 1'b0;
    n_dsp_bf_sc_cnt_r  <= 3'b00;
  end
  else if(n_pini_r == 1'b1) begin
    v1_dspfld_sc2    <= 1'b0;
    n_dsp_bf_sc_cnt_r  <= 3'b000;
  end
  else if(n_frmpl_r_s == 1'b1) begin
    if(n_dsp_nx2_ps_r == 1'b1) begin
      if(n_dsp_nx2_sc_r == 1'b1) begin
        v1_dspfld_sc2    <= n_dsp_nx2_sc_r;
        n_dsp_bf_sc_cnt_r  <= 3'b011;
      end
      else if(n_dsp_bf_sc_cnt_r != 3'b000) begin
        v1_dspfld_sc2    <= 1'b1;
        n_dsp_bf_sc_cnt_r  <= n_dsp_bf_sc_dec_cnt;
      end
      else begin
        v1_dspfld_sc2    <= n_dsp_nx2_sc_r;
        n_dsp_bf_sc_cnt_r  <= n_dsp_bf_sc_cnt_r;
      end
    end
    else if(n_dsp_nx2_tff_r == 1'b0) begin
      if(n_dsp_nx2_sc_r == 1'b1) begin
        v1_dspfld_sc2    <= n_dsp_nx2_sc_r;
        n_dsp_bf_sc_cnt_r  <= 3'b011;
      end
      else if(n_dsp_bf_sc_cnt_r != 3'b000) begin
        v1_dspfld_sc2    <= 1'b1;
        n_dsp_bf_sc_cnt_r  <= n_dsp_bf_sc_dec_cnt;
      end
      else begin
        v1_dspfld_sc2    <= n_dsp_nx2_sc_r;
        n_dsp_bf_sc_cnt_r  <= n_dsp_bf_sc_cnt_r;
      end
    end
    else begin
      if(n_dsp_nx2_sc_r == 1'b1) begin
        v1_dspfld_sc2    <= 1'b0;
        n_dsp_bf_sc_cnt_r  <= 3'b100;
      end
      else if(n_dsp_bf_sc_cnt_r != 3'b000) begin
        v1_dspfld_sc2    <= 1'b1;
        n_dsp_bf_sc_cnt_r  <= n_dsp_bf_sc_dec_cnt;
      end
      else begin
        v1_dspfld_sc2    <= n_dsp_nx2_sc_r;
        n_dsp_bf_sc_cnt_r  <= n_dsp_bf_sc_cnt_r;
      end
    end
  end
  else if(n_fldpl_r_s == 1'b1) begin
    if(n_dsp_bf_sc_cnt_r != 3'b000) begin
      v1_dspfld_sc2    <= 1'b1;
      n_dsp_bf_sc_cnt_r  <= n_dsp_bf_sc_dec_cnt;
    end
    else begin
      v1_dspfld_sc2    <= 1'b0;
      n_dsp_bf_sc_cnt_r  <= n_dsp_bf_sc_cnt_r;
    end
  end
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    v1_dsp_ps  <= 1'b0;
  else if(n_pini_r == 1'b1)
    v1_dsp_ps  <= 1'b0;
  else if(n_frmpl_r_s == 1'b1)
    v1_dsp_ps  <= n_dsp_nx2_ps_r;
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dsp_tff_r  <= 1'b1;
  else if(n_pini_r == 1'b1)
    n_dsp_tff_r  <= 1'b1;
  else if(n_frmpl_r_s == 1'b1)
    n_dsp_tff_r  <= n_dsp_nx2_tff_r;
end

// Display Plane Trigger (Top Field)
always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dsp_tf_trg_r  <= 1'b0;
  else if(n_pini_r == 1'b1)
    n_dsp_tf_trg_r  <= 1'b0;
  else if(n_frmpl_r_s == 1'b1) begin
    if(n_dsp_nx2_ps_r == 1'b1)
      n_dsp_tf_trg_r  <= 1'b1;
    else if(n_dsp_nx2_tff_r == 1'b1)
      n_dsp_tf_trg_r  <= 1'b1;
    else
      n_dsp_tf_trg_r  <= 1'b0;
  end
  else if(n_fldpl_r_s == 1'b1) begin
    if(v1_dsp_ps         == 1'b0 && n_dsp_tff_r == 1'b0 && n_dsp_2f_mask_r == 1'b0)
      n_dsp_tf_trg_r  <= 1'b1;
    else
      n_dsp_tf_trg_r  <= 1'b0;
  end
  else
    n_dsp_tf_trg_r  <= 1'b0;
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dsp_bf_trg_r  <= 1'b0;
  else if(n_pini_r == 1'b1)
    n_dsp_bf_trg_r  <= 1'b0;
  else if(n_frmpl_r_s == 1'b1) begin
    if(n_dsp_nx2_ps_r == 1'b1)
      n_dsp_bf_trg_r  <= 1'b1;
    else if(n_dsp_nx2_tff_r == 1'b0)
      n_dsp_bf_trg_r  <= 1'b1;
    else
      n_dsp_bf_trg_r  <= 1'b0;
  end
  else if(n_fldpl_r_s == 1'b1) begin
    if(v1_dsp_ps         == 1'b0 && n_dsp_tff_r == 1'b1 &&
       n_dsp_2f_mask_r == 1'b0)
      n_dsp_bf_trg_r  <= 1'b1;
    else
      n_dsp_bf_trg_r  <= 1'b0;
  end
  else
    n_dsp_bf_trg_r  <= 1'b0;
end

always @(posedge clkdec or negedge rstdec_x) begin
  if(rstdec_x == 1'b0)
    n_dsp_2f_mask_r  <= 1'b1;
  else if(n_pini_r == 1'b1)
    n_dsp_2f_mask_r  <= 1'b1;
  else if(n_frmpl_r_s == 1'b1)
    n_dsp_2f_mask_r  <= 1'b0;
  else if(n_fldpl_r_s == 1'b1)
    n_dsp_2f_mask_r  <= 1'b1;
end

endmodule

