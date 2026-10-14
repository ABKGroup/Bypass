// ----------------------------------------------
// File: bdc_sdictl.v
// Module: bdc_sdictl
// Function:
// ----------------------------------------------

module bdc_sdictl(
  clkdec,
  rstdec_x,
  p_hdtvh_dc_r,
  p_prgseq_dc_r,
  p_pstr_dc_r,
  n_decfld_num1_r,
  n_decfld_num2_r,
  p_mbh_adr_dc_r,
  p_mbv_adr_dc_r,
  b_mbpl_r_s,
  b_hdtvh_r,
  b_prgseq_r,
  b_fld_numt_r,
  b_fld_numb_r,
  b_mbh_adr_r,
  b_mbvt_adr_r,
  b_mbvb_adr_r
  );
  
  input         clkdec;       
  input         rstdec_x;     
  input         p_hdtvh_dc_r;   
  input         p_prgseq_dc_r;  
  input [1:0]   p_pstr_dc_r;    
  input [3:0]   n_decfld_num1_r;
  input [3:0]   n_decfld_num2_r;
  input [6:0]   p_mbh_adr_dc_r; 
  input [6:0]   p_mbv_adr_dc_r; 
  input         b_mbpl_r_s;     
  output        b_hdtvh_r;      
  output        b_prgseq_r;     
  output [3:0]  b_fld_numt_r;   
  output [3:0]  b_fld_numb_r;   
  output [7:0]  b_mbh_adr_r;    
  output [8:0]  b_mbvt_adr_r;   
  output [8:0]  b_mbvb_adr_r;   
  

  wire          clkdec;               // 108Mhz Clock
  wire          rstdec_x;             // System Reset
  wire          p_hdtvh_dc_r;         // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  wire          p_prgseq_dc_r;        // MB Interlace/Progressive Select[0:Interlace 1:Progressive]
  wire [1:0]    p_pstr_dc_r;          // Picture Stracture
  wire [3:0]    n_decfld_num1_r;      // Write Field Number1(Top-Field)
  wire [3:0]    n_decfld_num2_r;      // Write Field Number2(Bottom-Filed)
  wire [6:0]    p_mbh_adr_dc_r;       // Write Field Horizontal Address
  wire [6:0]    p_mbv_adr_dc_r;       // Write Field Vertical Address
  wire          b_mbpl_r_s;           // MB Pulse
  wire          b_pstr_dc3;           // Picture Stracture Decode(Frame Starcure)
  reg           b_hdtvh_r;            // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  reg           b_prgseq_r;           // MB Interlace/Progressive Select[0:Interlace 1:Progressive]
  reg [3:0]     b_fld_numt_r;         // Write Field Number1(Top)
  reg [3:0]     b_fld_numb_r;         // Write Field Number2(Bottom)
  reg [7:0]     b_mbh_adr_r;          // Write Field Horizontal Address
  reg [8:0]     b_mbvt_adr_r;         // Write Field Vertical Address(Top)
  reg [8:0]     b_mbvb_adr_r;         // Write Field Vertical Address(Bottom)
  reg           b_hdtvh_dc_r;         // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  reg           b_prgseq_dc_r;        // MB Interlace/Progressive Select[0:Interlace 1:Progressive]
  reg [1:0]     b_pstr_dc_r;          // Picture Stracture
  reg [3:0]     b_decfld_num1_dc_r;   // Write Field Number1(Top-Field)
  reg [3:0]     b_decfld_num2_dc_r;   // Write Field Number2(Bottom-Filed)
  reg [6:0]     b_mbh_adr_dc_r;       // Write Field Horizontal Address
  reg [6:0]     b_mbv_adr_dc_r;       // Write Field Vertical Address
  reg [1:0]     b_pstr_r;             // Picture Stracture
  reg [3:0]     b_decfld_num1_r;      // Write Field Number1(Top-Field)
  reg [3:0]     b_decfld_num2_r;      // Write Field Number2(Bottom-Filed)
  reg [6:0]     b_pmbh_adr_r;         // Write Field Horizontal Address
  reg [6:0]     b_pmbv_adr_r;         // Write Field Vertical Address
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_hdtvh_dc_r       <= 1'b0;
      b_prgseq_dc_r      <= 1'b0;
      b_pstr_dc_r        <= 2'h0;
      b_decfld_num1_dc_r <= 4'h0;
      b_decfld_num2_dc_r <= 4'h0;
      b_mbh_adr_dc_r     <= 7'h00;
      b_mbv_adr_dc_r     <= 7'h00;
    end
    else begin
      b_hdtvh_dc_r       <= p_hdtvh_dc_r;
      b_prgseq_dc_r      <= p_prgseq_dc_r;
      b_pstr_dc_r        <= p_pstr_dc_r;
      b_decfld_num1_dc_r <= n_decfld_num1_r;
      b_decfld_num2_dc_r <= n_decfld_num2_r; 
      b_mbh_adr_dc_r     <= p_mbh_adr_dc_r;
      b_mbv_adr_dc_r     <= p_mbv_adr_dc_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_hdtvh_r       <= 1'b0;
      b_prgseq_r      <= 1'b0;
      b_pstr_r        <= 2'h0;
      b_decfld_num1_r <= 4'h0;
      b_decfld_num2_r <= 4'h0;
      b_pmbh_adr_r     <= 7'h00;
      b_pmbv_adr_r     <= 7'h00;
    end
    else if ( b_mbpl_r_s ) begin
      b_hdtvh_r       <= b_hdtvh_dc_r;
      b_prgseq_r      <= b_prgseq_dc_r;
      b_pstr_r        <= b_pstr_dc_r;
      b_decfld_num1_r <= b_decfld_num1_dc_r;
      b_decfld_num2_r <= b_decfld_num2_dc_r;
      b_pmbh_adr_r    <= b_mbh_adr_dc_r;
      b_pmbv_adr_r    <= b_mbv_adr_dc_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_fld_numt_r <= 4'h0;
    end
    else if ( b_pstr_r == 2'h2 ) begin
      b_fld_numt_r <= b_decfld_num2_r;
    end
    else begin
      b_fld_numt_r <= b_decfld_num1_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_fld_numb_r <= 4'h0;
    end
    else if ( b_pstr_r == 2'h1 ) begin
      b_fld_numb_r <= b_decfld_num1_r;
    end
    else begin
      b_fld_numb_r <= b_decfld_num2_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_mbh_adr_r <= 8'h00;
    end
    else if ( b_hdtvh_r ) begin
      b_mbh_adr_r <= {1'b0,b_pmbh_adr_r};
    end
    else begin
      b_mbh_adr_r <= {b_pmbh_adr_r,1'b0};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_mbvt_adr_r <= 9'h000;
    end
    else if ( b_hdtvh_r ) begin
      if ( b_pstr_dc3 ) begin
        b_mbvt_adr_r <= {1'b0,b_pmbv_adr_r,1'b0};
      end
      else begin
        b_mbvt_adr_r <= {b_pmbv_adr_r,2'h0};
      end
    end
    else begin
      if ( b_pstr_dc3 ) begin
        b_mbvt_adr_r <= {b_pmbv_adr_r,2'h0};
      end
      else begin
        b_mbvt_adr_r <= {b_pmbv_adr_r[5:0],3'h0};
      end
    end
  end
  assign b_pstr_dc3 = ( b_pstr_r == 2'h3 ) ? 1'b1 : 1'b0;
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_mbvb_adr_r <= 9'h000;
    end
    else if ( b_hdtvh_r ) begin
      if ( b_pstr_dc3 ) begin
        b_mbvb_adr_r <= {1'b0,b_pmbv_adr_r,1'b0};
      end
      else begin
        b_mbvb_adr_r <= {b_pmbv_adr_r,2'h2};
      end
    end
    else begin
      if ( b_pstr_dc3 ) begin
        b_mbvb_adr_r <= {b_pmbv_adr_r,2'h0};
      end
      else begin
        b_mbvb_adr_r <= {b_pmbv_adr_r[5:0],3'h4};
      end
    end
  end
  
endmodule
