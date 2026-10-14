// ----------------------------------------------
// File: vld_vscdet.v
// Module: vld_vscdet
// Function:start code detector
// ----------------------------------------------

module vld_vscdet(
                      v_seqstrt_r,
                      v_sqxstrt_r,
                      v_sdxstrt_r,
                      v_ud0strt_r,
                      v_gopstrt_r,
                      v_ud1strt_r,
                      v_picstrt_r,
                      v_pcxstrt_r,
                      v_qmxstrt_r,
                      v_pdxstrt_r,
                      v_ud2strt_r,
                      v_cpxstrt_r,
                      v_slcstrt_r,
                      v_mbastrt_r,
                      MPEG1,      
                      v_vscdet_ferror_r,
                      v_sferror_r, 
                      v_slclverr_r,
                      SCSHIFT,     
                      PARAA,       
                      PARAD,       
                      v_interrupt_r_n,
                      v_vldstatus_r, 
                      v_vldmode_r, 
                      v_mbpl_vld_r,
                      clkdec,     
                      rstdec_x,   
                      g_swrst_r_n, 
                      y1_bs_wait_n,   
                      g_vldmode_r, 
                      g_init_vld_r_s,
                      c_skippic_r_s, 
                      c_skipslc_r_s, 
                      v_seqerr,  
                      v_picerr,  
                      v_pcxerr,  
                      v_slcerr,  
                      v_macerr,  
                      v_blkerr_r,
                      v_enderror,
                      SEQEOH,    
                      SQXEOH,    
                      SDXEOH,    
                      USDEOH,    
                      GOPEOH,    
                      PICEOH,    
                      PCXEOH,    
                      QMXEOH,    
                      PDXEOH,    
                      v_cpxend_r_s, 
                      SLICE_END,    
                      v_blkend_r_s, 
                      UREGW,        
                      UREG,         
                      ADP,          
                      STREAM,       
                      c_mbpl_vld_r_s
                      );
  output [5:0] SCSHIFT;         // shift value
  output [7:0] PARAA;           // parameter address
  output [7:0] PARAD;           // parameter data
  output [7:0] v_vldstatus_r;   // VLD status
  output       v_seqstrt_r;     // sequence_header start
  output       v_sqxstrt_r;     // sequence_extension start
  output       v_sdxstrt_r;     // sequence_display_extension start
  output       v_ud0strt_r;     // user_data(0) start
  output       v_gopstrt_r;     // group_of_pictures_header start
  output       v_ud1strt_r;     // user_data(1) start
  output       v_picstrt_r;     // picture_header start
  output       v_pcxstrt_r;     // picture_coding_extension start
  output       v_qmxstrt_r;     // quant_matrix_extension start
  output       v_pdxstrt_r;     // picture_display_extension start
  output       v_ud2strt_r;     // usr_data(2) start
  output       v_cpxstrt_r;     // copyright_extension start
  output       v_slcstrt_r;     // slice start
  output       v_mbastrt_r;     // MBA start (from 2nd MB)
  output       MPEG1;           // 0:MPEG-2, 1:MPEG-1
  output       v_interrupt_r_n; // interrupt
  output       v_vscdet_ferror_r; // fatal error
  output       v_sferror_r;      // sferror register
  output       v_slclverr_r;    // fatal error in a slice
  output [1:0]  v_vldmode_r;    // vld_mode
  output        v_mbpl_vld_r;   // MB start
  input        clkdec;          // clock
  input        rstdec_x;        // reset
  input        g_swrst_r_n;     // S/W reset
  input        y1_bs_wait_n;    // VLD wait
  input [1:0]  g_vldmode_r;     // vld_mode
  input        g_init_vld_r_s;  // VLD init & start
  input        c_skippic_r_s;   // picture skip
  input        c_skipslc_r_s;   // slice skip
  input        v_seqerr;        // seq_hdr,qmx_ext fatal error
  input        v_picerr;        // picture_header fatal error
  input        v_pcxerr;        // picture_coding_extension fatal error
  input        v_slcerr;        // slice fatal error
  input        v_macerr;        // macroblock fatal error
  input        v_blkerr_r;      // block fatal error
  input        v_enderror;      // end_of_macroblock error
  input        SEQEOH;          // sequence_header end
  input        SQXEOH;          // sequence_extension end
  input        SDXEOH;          // sequence_display_extension end
  input        USDEOH;          // user_data end
  input        GOPEOH;          // group_of_pictures_header end
  input        PICEOH;          // picture_header end
  input        PCXEOH;          // picture_coding_exyension end
  input        QMXEOH;          // quant_matrix_extension end
  input        PDXEOH;          // picture_display_extension end
  input        v_cpxend_r_s;  // copyright_extension end
  input        SLICE_END;       // slice_header end
  input        v_blkend_r_s;  // 6 block end
  input        UREGW;           // UREG update flag
  input [31:0] UREG;            // head of ES input
  input [4:0]  ADP;             // accumulated shift value
  input [31:8] STREAM;         // bitstream
  input        c_mbpl_vld_r_s; // MB start
  
  reg           v_seqstrt_r;  // sequence header start
  reg           v_sqxstrt_r;  // sequence extension start
  reg           v_sdxstrt_r;  // sequence display extension start
  reg           v_ud0strt_r;  // user_data 0 start
  reg           v_gopstrt_r;  // group_of_pictures_header start
  reg           v_ud1strt_r;  // user_data 1 start
  reg           v_picstrt_r;  // picture_header start
  reg           v_pcxstrt_r;  // picture_coding_extension start
  reg           v_qmxstrt_r;  // quant_matrix_extension start
  reg           v_pdxstrt_r;  // picture_display_extension start
  reg           v_cpxstrt_r;  // copyright_extension start
  reg           v_ud2strt_r;  // user_data 2 start
  reg           v_slcstrt_r;  // slice start
  reg           v_mbastrt_r;  // MBA start (from 2nd MB)
  reg           v_sferror_r;  // sferror register
  reg           v_vscdet_ferror_r;   // fatal error register
  reg           v_slclverr_r; // slice level error
  reg           v_ferrcond_r; // fatal error condition
  reg           v_seqerr_r;
  reg           v_picerr_r;
  reg           v_pcxerr_r;
  reg           v_slcerr_r;
  reg           v_macerr_r;
  reg           v_emberr_r;
  wire          v_search_state; // all SRCH state
  wire          v_scidck_state; // all SCID state
  wire          v_next_vscdet_ferror;  // fatal error
  wire          v_next_sferror; // sferror
  wire          MPEG1;
  reg           v_interrupt_r_n;   // interrupt reg
  wire          v_next_interrupt_n; // interrupt conditions
  reg [7:0]     PARAA;
  reg [7:0]     PARAD;
  reg [7:0]     v_vld_state_r;
  reg [7:0]     v_next_state;
  reg [2:0]     v_vld_mode_r;
  wire [1:0]    v_vldmode_r;
  reg           v_mbpl_vld_r;
  reg           v_skipslc_r;
  reg           v_skippic_r;
  reg [5:0]     SCSHIFT;         // shift value (wire)
  reg           v_scpfxdetect; // wire
  reg [1:0]     v_prezerotmp_r;
  reg [1:0]     v_prezerohld_r;
  wire [1:0]    v_prezero;
  wire          v_scpfxdet1;
  wire          v_scpfxdet2;
  wire          v_scpfxdet3;
  wire          v_scpfxdet4;
  reg           v_search_1st_r;
  wire          v_next_search_1st;
  reg [1:0]     v_detvald_r;
  wire          v_next_search_state;
  
  parameter   P_IDLE            = 8'h00;
  parameter   P_LOAD1           = 8'h01;
  parameter   P_LOAD2           = 8'h02;
  parameter   P_INI_SRCH        = 8'h10;
  parameter   P_INI_SCID        = 8'h11;
  parameter   P_SEQ_STRT        = 8'h12;
  parameter   P_SEQ_WAIT        = 8'h13;
  parameter   P_SEQ_SRCH        = 8'h14;
  parameter   P_SEQ_SCID        = 8'h15;
  parameter   P_SQX_EXID        = 8'h16;
  parameter   P_SQX_PRE         = 8'h17;
  parameter   P_SQX_STRT        = 8'h18;
  parameter   P_SQX_WAIT        = 8'h19;
  parameter   P_SQX_SRCH        = 8'h1a;
  parameter   P_SQX_SCID        = 8'h1b;
  parameter   P_SDX_EXID        = 8'h1c;
  parameter   P_SDX_STRT        = 8'h1d;
  parameter   P_SDX_WAIT        = 8'h1e;
  parameter   P_RD0_WAIT        = 8'h1f;
  parameter   P_UD0_STRT        = 8'h21;
  parameter   P_UD0_WAIT        = 8'h22;
  parameter   P_SEQ_STRT_MP2    = 8'h25;
  parameter   P_SEQ_WAIT_MP2    = 8'h26;
  parameter   P_SEQ_SRCH_MP2    = 8'h27;
  parameter   P_SEQ_SCID_MP2    = 8'h28;
  parameter   P_SQX_EXID_MP2    = 8'h29;
  parameter   P_SEC_STRT        = 8'h2c;
  parameter   P_GOP_STRT        = 8'h31;
  parameter   P_GOP_WAIT        = 8'h32;
  parameter   P_GOP_SRCH        = 8'h33;
  parameter   P_GOP_SCID        = 8'h34;
  parameter   P_UD1_STRT        = 8'h38;
  parameter   P_UD1_WAIT        = 8'h39;
  parameter   P_PIC_STRT        = 8'h3c;
  parameter   P_PIC_WAIT        = 8'h3d;
  parameter   P_PIC_SRCH        = 8'h3e;
  parameter   P_PIC_SCID        = 8'h3f;
  parameter   P_PCX_EXID        = 8'h40;
  parameter   P_PCX_STRT        = 8'h41;
  parameter   P_PCX_WAIT        = 8'h42;
  parameter   P_PCX_SRCH        = 8'h43;
  parameter   P_PCX_SCID        = 8'h44;
  parameter   P_QMX_EXID        = 8'h45;
  parameter   P_QMX_STRT        = 8'h46;
  parameter   P_QMX_WAIT        = 8'h47;
  parameter   P_CPX_STRT        = 8'h48;
  parameter   P_CPX_WAIT        = 8'h49;
  parameter   P_PDX_STRT        = 8'h4a;
  parameter   P_PDX_WAIT        = 8'h4b;
  parameter   P_RD2_WAIT        = 8'h4c;
  parameter   P_UD2_STRT        = 8'h4d;
  parameter   P_UD2_WAIT        = 8'h4e;
  parameter   P_PFE_SRCH        = 8'h51;
  parameter   P_PFE_SCID        = 8'h52;
  parameter   P_SLC_STRT        = 8'h60;
  parameter   P_SLC_WAIT        = 8'h61;
  parameter   P_MAC_STRT        = 8'h62;
  parameter   P_MAC_WAIT        = 8'h63;
  parameter   P_SLC_SRCH        = 8'h64;
  parameter   P_SLC_SCID        = 8'h65;
  parameter   P_MP1_UD0_PRE     = 8'ha0;
  parameter   P_MP1_UD0_STRT    = 8'ha1;
  parameter   P_MP1_UD0_WAIT    = 8'ha2;
  parameter   P_MP1_UD0_SRCH    = 8'ha3;
  parameter   P_MP1_UD0_SCID    = 8'ha4;
  parameter   P_SEQ_STRT_MP1    = 8'ha5;
  parameter   P_SEQ_WAIT_MP1    = 8'ha6;
  parameter   P_SEQ_SRCH_MP1    = 8'ha7;
  parameter   P_SEQ_SCID_MP1    = 8'ha8;
  parameter   P_SQX_WAIT_MP1    = 8'ha9;
  parameter   P_SQX_SRCH_MP1    = 8'haa;
  parameter   P_SQX_SCID_MP1    = 8'hab;
  parameter   P_MP1_SEC_STRT    = 8'hac;
  parameter   P_MP1_GOP_PRE     = 8'hb0;
  parameter   P_MP1_GOP_STRT    = 8'hb1;
  parameter   P_MP1_GOP_WAIT    = 8'hb2;
  parameter   P_MP1_GOP_SRCH    = 8'hb3;
  parameter   P_MP1_GOP_SCID    = 8'hb4;
  parameter   P_MP1_GPX_WAIT    = 8'hb5;
  parameter   P_MP1_GPX_SRCH    = 8'hb6;
  parameter   P_MP1_GPX_SCID    = 8'hb7;
  parameter   P_MP1_UD1_STRT    = 8'hb8;
  parameter   P_MP1_UD1_WAIT    = 8'hb9;
  parameter   P_MP1_UD1_SRCH    = 8'hba;
  parameter   P_MP1_UD1_SCID    = 8'hbb;
  parameter   P_MP1_PIC_STRT    = 8'hbc;
  parameter   P_MP1_PIC_WAIT    = 8'hbd;
  parameter   P_MP1_PIC_SRCH    = 8'hbe;
  parameter   P_MP1_PIC_SCID    = 8'hbf;
  parameter   P_MP1_PIX_WAIT    = 8'hc5;
  parameter   P_MP1_PIX_SRCH    = 8'hc6;
  parameter   P_MP1_PIX_SCID    = 8'hc7;
  parameter   P_MP1_UD2_STRT    = 8'hcd;
  parameter   P_MP1_UD2_WAIT    = 8'hce;
  parameter   P_MP1_UD2_SRCH    = 8'hcf;
  parameter   P_MP1_UD2_SCID    = 8'hd0;
  parameter   P_MP1_PFE_SRCH    = 8'hd1;
  parameter   P_MP1_PFE_SCID    = 8'hd2;
  parameter   P_MP1_SLC_STRT    = 8'he0;
  parameter   P_MP1_SLC_WAIT    = 8'he1;
  parameter   P_MP1_MAC_STRT    = 8'he2;
  parameter   P_MP1_MAC_WAIT    = 8'he3;
  parameter   P_MP1_SLC_SRCH    = 8'he4;
  parameter   P_MP1_SLC_SCID    = 8'he5;

  assign  v_vldstatus_r = v_vld_state_r;
  assign MPEG1 = v_vld_state_r[7]; 

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_mbpl_vld_r  <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          v_mbpl_vld_r  <= 1'b0;
      end
      else if(c_mbpl_vld_r_s)begin
          v_mbpl_vld_r  <= 1'b1;
      end
      else if(!y1_bs_wait_n)begin
          v_mbpl_vld_r  <= v_mbpl_vld_r;
      end
      else begin
          v_mbpl_vld_r  <= c_mbpl_vld_r_s;
      end
  end

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_seqstrt_r  <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          v_seqstrt_r  <= 1'b0;
      end
      else if(!y1_bs_wait_n)begin
          v_seqstrt_r  <= v_seqstrt_r;
      end
      else begin
          v_seqstrt_r  <= (v_next_state == P_SEQ_STRT) | 
                            (v_next_state == P_SEQ_STRT_MP2) |
                            (v_next_state == P_SEQ_STRT_MP1);
      end
  end

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_sqxstrt_r  <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          v_sqxstrt_r  <= 1'b0;
      end
      else if(!y1_bs_wait_n)begin
          v_sqxstrt_r  <= v_sqxstrt_r;
      end
      else begin
          v_sqxstrt_r  <= (v_next_state == P_SQX_STRT);
      end
  end

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_sdxstrt_r  <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          v_sdxstrt_r  <= 1'b0;
      end
      else if(!y1_bs_wait_n)begin
          v_sdxstrt_r  <= v_sdxstrt_r;
      end
      else begin
          v_sdxstrt_r  <= (v_next_state == P_SDX_STRT);
      end
  end

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_ud0strt_r  <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          v_ud0strt_r  <= 1'b0;
      end
      else if(!y1_bs_wait_n)begin
          v_ud0strt_r  <= v_ud0strt_r;
      end
      else begin
          v_ud0strt_r  <= (v_next_state == P_UD0_STRT) | 
                            (v_next_state == P_MP1_UD0_STRT);
      end
  end

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_gopstrt_r  <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          v_gopstrt_r  <= 1'b0;
      end
      else if(!y1_bs_wait_n)begin
          v_gopstrt_r  <= v_gopstrt_r;
      end
      else begin
          v_gopstrt_r  <= (v_next_state == P_GOP_STRT) | 
                            (v_next_state == P_MP1_GOP_STRT);
      end
  end

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_ud1strt_r  <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          v_ud1strt_r  <= 1'b0;
      end
      else if(!y1_bs_wait_n)begin
          v_ud1strt_r  <= v_ud1strt_r;
      end
      else begin
          v_ud1strt_r  <= (v_next_state == P_UD1_STRT) | 
                            (v_next_state == P_MP1_UD1_STRT);
      end
  end

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_picstrt_r  <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          v_picstrt_r  <= 1'b0;
      end
      else if(!y1_bs_wait_n)begin
          v_picstrt_r  <= v_picstrt_r;
      end
      else begin
          v_picstrt_r  <= (v_next_state == P_PIC_STRT) | 
                            (v_next_state == P_MP1_PIC_STRT);
      end
  end

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_pcxstrt_r  <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          v_pcxstrt_r  <= 1'b0;
      end
      else if(!y1_bs_wait_n)begin
          v_pcxstrt_r  <= v_pcxstrt_r;
      end
      else begin
          v_pcxstrt_r  <= (v_next_state == P_PCX_STRT);
      end
  end

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_qmxstrt_r  <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          v_qmxstrt_r  <= 1'b0;
      end
      else if(!y1_bs_wait_n)begin
          v_qmxstrt_r  <= v_qmxstrt_r;
      end
      else begin
          v_qmxstrt_r  <= (v_next_state == P_QMX_STRT);
      end
  end

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_pdxstrt_r  <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          v_pdxstrt_r  <= 1'b0;
      end
      else if(!y1_bs_wait_n)begin
          v_pdxstrt_r  <= v_pdxstrt_r;
      end
      else begin
          v_pdxstrt_r  <= (v_next_state == P_PDX_STRT);
      end
  end

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_cpxstrt_r  <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          v_cpxstrt_r  <= 1'b0;
      end
      else if(!y1_bs_wait_n)begin
          v_cpxstrt_r  <= v_cpxstrt_r;
      end
      else begin
          v_cpxstrt_r  <= (v_next_state == P_CPX_STRT);
      end
  end

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_ud2strt_r  <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          v_ud2strt_r  <= 1'b0;
      end
      else if(!y1_bs_wait_n)begin
          v_ud2strt_r  <= v_ud2strt_r;
      end
      else begin
          v_ud2strt_r  <= (v_next_state == P_UD2_STRT) | 
                            (v_next_state == P_MP1_UD2_STRT);
      end
  end

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_slcstrt_r  <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          v_slcstrt_r  <= 1'b0;
      end
      else if(!y1_bs_wait_n)begin
          v_slcstrt_r  <= v_slcstrt_r;
      end
      else begin
          v_slcstrt_r  <= (v_next_state == P_SLC_STRT) | 
                            (v_next_state == P_MP1_SLC_STRT);
      end
  end

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_mbastrt_r  <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          v_mbastrt_r  <= 1'b0;
      end
      else if(!y1_bs_wait_n)begin
          v_mbastrt_r  <= v_mbastrt_r;
      end
      else begin 
          v_mbastrt_r  <= ((v_next_state == P_MAC_STRT) & 
                             (v_vld_state_r == P_MAC_WAIT)) |
                            ((v_next_state == P_MP1_MAC_STRT) &
                             (v_vld_state_r == P_MP1_MAC_WAIT));

      end
  end


  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_seqerr_r  <= 1'b0;
          v_picerr_r  <= 1'b0;
          v_pcxerr_r  <= 1'b0;
          v_slcerr_r  <= 1'b0;
          v_macerr_r  <= 1'b0;
          v_emberr_r  <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          v_seqerr_r  <= 1'b0;
          v_picerr_r  <= 1'b0;
          v_pcxerr_r  <= 1'b0;
          v_slcerr_r  <= 1'b0;
          v_macerr_r  <= 1'b0;
          v_emberr_r  <= 1'b0;
      end
      else if(!y1_bs_wait_n) begin
          v_seqerr_r  <= v_seqerr_r;
          v_picerr_r  <= v_picerr_r;
          v_pcxerr_r  <= v_pcxerr_r;
          v_slcerr_r  <= v_slcerr_r;
          v_macerr_r  <= v_macerr_r;
          v_emberr_r  <= v_emberr_r;
      end
      else begin
          v_seqerr_r  <= v_seqerr;
          v_picerr_r  <= v_picerr;
          v_pcxerr_r  <= v_pcxerr;
          v_slcerr_r  <= v_slcerr;
          v_macerr_r  <= v_macerr;
          v_emberr_r  <= v_enderror;
      end
  end

 
  assign  v_search_state = (v_vld_state_r == P_INI_SRCH) |
                             (v_vld_state_r == P_SEQ_SRCH) |
                             (v_vld_state_r == P_SEQ_SRCH_MP2) |
                             (v_vld_state_r == P_SQX_SRCH) |
                             (v_vld_state_r == P_PFE_SRCH) |
                             (v_vld_state_r == P_GOP_SRCH) |
                             (v_vld_state_r == P_PIC_SRCH) |
                             (v_vld_state_r == P_PCX_SRCH) |
                             (v_vld_state_r == P_SLC_SRCH) |
                             (v_vld_state_r == P_SEQ_SRCH_MP1) |
                             (v_vld_state_r == P_SQX_SRCH_MP1) |
                             (v_vld_state_r == P_MP1_UD0_SRCH) |
                             (v_vld_state_r == P_MP1_PFE_SRCH) |
                             (v_vld_state_r == P_MP1_GOP_SRCH) |
                             (v_vld_state_r == P_MP1_GPX_SRCH) |
                             (v_vld_state_r == P_MP1_UD1_SRCH) |
                             (v_vld_state_r == P_MP1_PIC_SRCH) |
                             (v_vld_state_r == P_MP1_PIX_SRCH) |
                             (v_vld_state_r == P_MP1_UD2_SRCH) |
                             (v_vld_state_r == P_MP1_SLC_SRCH) ;

  assign  v_next_search_state = (v_next_state == P_INI_SRCH) |
                             (v_next_state == P_SEQ_SRCH) |
                             (v_next_state == P_SEQ_SRCH_MP2) |
                             (v_next_state == P_SQX_SRCH) |
                             (v_next_state == P_PFE_SRCH) |
                             (v_next_state == P_GOP_SRCH) |
                             (v_next_state == P_PIC_SRCH) |
                             (v_next_state == P_PCX_SRCH) |
                             (v_next_state == P_SLC_SRCH) |
                             (v_next_state == P_SEQ_SRCH_MP1) |
                             (v_next_state == P_SQX_SRCH_MP1) |
                             (v_next_state == P_MP1_UD0_SRCH) |
                             (v_next_state == P_MP1_PFE_SRCH) |
                             (v_next_state == P_MP1_GOP_SRCH) |
                             (v_next_state == P_MP1_GPX_SRCH) |
                             (v_next_state == P_MP1_UD1_SRCH) |
                             (v_next_state == P_MP1_PIC_SRCH) |
                             (v_next_state == P_MP1_PIX_SRCH) |
                             (v_next_state == P_MP1_UD2_SRCH) |
                             (v_next_state == P_MP1_SLC_SRCH) ;

  assign  v_scidck_state = (v_vld_state_r == P_INI_SCID) |
                             (v_vld_state_r == P_SEQ_SCID) |
                             (v_vld_state_r == P_SEQ_SCID_MP2) |
                             (v_vld_state_r == P_SQX_SCID) |
                             (v_vld_state_r == P_PFE_SCID) |
                             (v_vld_state_r == P_GOP_SCID) |
                             (v_vld_state_r == P_PIC_SCID) |
                             (v_vld_state_r == P_PCX_SCID) |
                             (v_vld_state_r == P_SLC_SCID) |
                             (v_vld_state_r == P_SEQ_SCID_MP1) |
                             (v_vld_state_r == P_SQX_SCID_MP1) |
                             (v_vld_state_r == P_MP1_UD0_SCID) |
                             (v_vld_state_r == P_MP1_PFE_SCID) |
                             (v_vld_state_r == P_MP1_GOP_SCID) |
                             (v_vld_state_r == P_MP1_GPX_SCID) |
                             (v_vld_state_r == P_MP1_UD1_SCID) |
                             (v_vld_state_r == P_MP1_PIC_SCID) |
                             (v_vld_state_r == P_MP1_PIX_SCID) |
                             (v_vld_state_r == P_MP1_UD2_SCID) |
                             (v_vld_state_r == P_MP1_SLC_SCID) ;


  always@(v_search_state or v_vld_state_r or v_search_1st_r or
          ADP or v_scpfxdet1 or v_detvald_r or
          v_scpfxdet2 or v_scpfxdet3 or v_vld_mode_r or
          v_scidck_state or STREAM)begin
      if(v_search_state) begin
          if(v_search_1st_r) begin 
              if((ADP == 5'd0) & v_scpfxdet3) begin
                  SCSHIFT = 6'd24; 
              end
              else begin 
                  SCSHIFT = 6'd32 - ADP[4:0];
              end
          end
          else begin 
              if(v_scpfxdet1 & v_detvald_r[1]) begin
                  SCSHIFT = 6'd8; 
              end
              else if(v_scpfxdet2 & v_detvald_r[0]) begin
                  SCSHIFT = 6'd16; 
              end
              else if(v_scpfxdet3) begin
                  SCSHIFT = 6'd24; 
              end
              else begin
                  SCSHIFT = 6'd32;
              end
          end
      end
      else if(v_scidck_state) begin
          SCSHIFT = 6'd8; 
      end
      else begin
          case(v_vld_state_r)
            P_LOAD1        : SCSHIFT = 6'd32;
            P_LOAD2        : SCSHIFT = 6'd32;
            P_SQX_EXID     : begin
                if((STREAM[31:28]==4'h1) | v_vld_mode_r[2])
                  SCSHIFT = 6'd4; 
                else
                  SCSHIFT = 6'd0; 
            end
            P_SQX_EXID_MP2     : SCSHIFT = 6'd4; 
            P_SDX_EXID     : begin
                if(STREAM[31:28]==4'h2)
                  SCSHIFT = 6'd4;
                else if(STREAM[31:8]==24'h000001)
                  SCSHIFT = 6'd0;
                else
                  SCSHIFT = 6'd8;
            end
            P_RD0_WAIT     : begin
                if(STREAM[31:8]==24'h000001)
                  SCSHIFT = 6'd0;
                else
                  SCSHIFT = 6'd8; 
            end
            P_PCX_EXID     : SCSHIFT = 6'd4; 
            P_QMX_EXID     : begin
                if(STREAM[31:8]==24'h000001)
                  SCSHIFT = 6'd0;
                else if((STREAM[31:28]==4'd3) | 
                        (STREAM[31:28]==4'd4) | (STREAM[31:28]==4'd7))
                  SCSHIFT = 6'd4;
                else
                  SCSHIFT = 6'd8; 
            end
            P_RD2_WAIT     : begin
                if(STREAM[31:8]==24'h000001)
                  SCSHIFT = 6'd0;
                else
                  SCSHIFT = 6'd8; 
            end
            P_SQX_WAIT_MP1 : begin
                if(STREAM[31:8]==24'h000001)
                  SCSHIFT = 6'd0;
                else
                  SCSHIFT = 6'd8; 
            end
            P_MP1_GPX_WAIT : begin
                if(STREAM[31:8]==24'h000001)
                  SCSHIFT = 6'd0;
                else
                  SCSHIFT = 6'd8; 
            end
            P_MP1_PIX_WAIT : begin
                if(STREAM[31:8]==24'h000001)
                  SCSHIFT = 6'd0;
                else
                  SCSHIFT = 6'd8; 
            end
            default        : SCSHIFT = 5'd0;
      endcase
      end
  end

  assign v_vldmode_r[1:0] = v_vld_mode_r[1:0]; 
  
  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_vld_mode_r <= 3'b000;
      end
      else if(!g_swrst_r_n) begin
          v_vld_mode_r <= 3'b000;
      end
      else begin
          v_vld_mode_r <= g_vldmode_r;
      end      
  end

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_vld_state_r <= P_IDLE;
      end
      else if(!g_swrst_r_n) begin
          v_vld_state_r <= P_IDLE;
      end
      else if((v_vld_state_r == P_IDLE) & g_init_vld_r_s) begin
          v_vld_state_r <= v_next_state;
      end
      else if(!y1_bs_wait_n) begin
          v_vld_state_r <= v_vld_state_r;
      end
      else begin
          v_vld_state_r <= v_next_state;
      end      
  end

  always@(v_search_state or v_search_1st_r or ADP or 
          v_scpfxdet1 or v_scpfxdet2 or v_scpfxdet4 or
          v_scpfxdet3 or v_detvald_r)begin
      if(v_search_state) begin
          if(v_search_1st_r) begin 
              if((ADP == 5'd0) & v_scpfxdet3) begin
                  v_scpfxdetect = 1'b1;
              end
              else if((ADP <= 5'd8) & v_scpfxdet4) begin
                  v_scpfxdetect = 1'b1;
              end
              else begin 
                  v_scpfxdetect = 1'b0;
              end
          end
          else begin 
              if(v_scpfxdet1 & v_detvald_r[1]) begin
                  v_scpfxdetect = 1'b1;
              end
              else if(v_scpfxdet2 & v_detvald_r[0]) begin
                  v_scpfxdetect = 1'b1;
              end
              else if(v_scpfxdet3) begin
                  v_scpfxdetect = 1'b1;
              end
              else if(v_scpfxdet4)begin
                  v_scpfxdetect = 1'b1;
              end
              else begin
                  v_scpfxdetect = 1'b0;
              end
          end
      end
      else    v_scpfxdetect = 1'b0;
  end

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_search_1st_r  <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          v_search_1st_r  <= 1'b0;
      end
      else begin 
          if(!y1_bs_wait_n)
            v_search_1st_r  <= v_search_1st_r;
          else
            v_search_1st_r  <= v_next_search_1st;
      end
  end

  assign v_next_search_1st = (v_next_search_state & (~v_search_state));

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_detvald_r  <= 2'b11;
      end
      else if(!g_swrst_r_n) begin
          v_detvald_r  <= 2'b11;
      end
      else begin 
          if(v_search_1st_r)begin
              if(ADP > 5'd24)begin
                  v_detvald_r <= 2'b00;
              end
              else if(ADP > 5'd16)begin
                  v_detvald_r <= 2'b01;
              end
          end
          else begin
              v_detvald_r  <= 2'b11;
          end
      end
  end

  assign v_scpfxdet1 = v_prezero[1] & (UREG[31:24]==8'h01); 
  assign v_scpfxdet2 = v_prezero[0] & (UREG[31:16]==16'h0001); 
  assign v_scpfxdet3 = (UREG[31:8]==24'h000001); 
  assign v_scpfxdet4 = (UREG[23:0]==24'h000001);
  assign v_prezero = (!UREGW)? v_prezerotmp_r : v_prezerohld_r;

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_prezerohld_r  <= 2'd0;
      end
      else if(!g_swrst_r_n) begin
          v_prezerohld_r  <= 2'd0;
      end
      else if(!UREGW) begin
          v_prezerohld_r  <= v_prezerotmp_r;
      end      
      else begin
          v_prezerohld_r  <= v_prezerohld_r;
      end      
  end

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_prezerotmp_r  <= 2'd0;
      end
      else if(!g_swrst_r_n) begin
          v_prezerotmp_r  <= 2'd0;
      end
      else begin
          if(!y1_bs_wait_n) 
            v_prezerotmp_r  <= v_prezerotmp_r;
          else
            v_prezerotmp_r  <= {(UREG[15:0] == 16'h0000),
                                  (UREG[7:0] == 8'h00)};
      end      
  end
  
  assign v_next_sferror =
                           ((v_vld_state_r == P_SEQ_SCID) &
                            (v_next_state == P_SEQ_STRT)) |
                           ((v_vld_state_r == P_SEQ_SCID_MP2) &
                            (v_next_state == P_SEQ_STRT)) |
                           ((v_vld_state_r == P_SQX_SCID) &
                            (v_next_state == P_SEQ_STRT)) |
                           ((v_vld_state_r == P_GOP_SCID) &
                            ((v_next_state == P_SEQ_STRT) |
                             (v_next_state == P_GOP_STRT))) |
                           ((v_vld_state_r == P_PIC_SCID) &
                            ((v_next_state == P_SEQ_STRT) |
                             (v_next_state == P_GOP_STRT) |
                             (v_next_state == P_PIC_STRT))) |
                           ((v_vld_state_r == P_PCX_SCID) &
                            ((v_next_state == P_SEQ_STRT) |
                             (v_next_state == P_GOP_STRT) |
                             (v_next_state == P_PIC_STRT))) |
                           ((v_vld_state_r == P_SEQ_SCID_MP1) &
                            ((v_next_state == P_SEQ_STRT) |
                             (v_next_state == P_MP1_SEC_STRT))) |
                           ((v_vld_state_r == P_SQX_SCID_MP1) &
                            ((v_next_state == P_SEQ_STRT) |
                             (v_next_state == P_MP1_SEC_STRT))) |
                           ((v_vld_state_r == P_MP1_UD0_SCID) &
                            ((v_next_state == P_SEQ_STRT) |
                             (v_next_state == P_MP1_SEC_STRT))) |
                           ((v_vld_state_r == P_MP1_GOP_SCID) &
                            ((v_next_state == P_SEQ_STRT) |
                             (v_next_state == P_MP1_SEC_STRT) | 
                             (v_next_state == P_MP1_GOP_STRT))) |
                           ((v_vld_state_r == P_MP1_GPX_SCID) &
                            ((v_next_state == P_SEQ_STRT) |
                             (v_next_state == P_MP1_SEC_STRT) |
                             (v_next_state == P_MP1_GOP_STRT))) |
                           ((v_vld_state_r == P_MP1_UD1_SCID) &
                            ((v_next_state == P_SEQ_STRT) |
                             (v_next_state == P_MP1_SEC_STRT) |
                             (v_next_state == P_MP1_GOP_STRT))) |
                           ((v_vld_state_r == P_MP1_PIC_SCID) &
                            ((v_next_state == P_SEQ_STRT) |
                             (v_next_state == P_MP1_SEC_STRT) |
                             (v_next_state == P_MP1_GOP_STRT) |
                             (v_next_state == P_MP1_PIC_STRT))) |
                           ((v_vld_state_r == P_MP1_PIX_SCID) &
                            ((v_next_state == P_SEQ_STRT) |
                             (v_next_state == P_MP1_SEC_STRT) |
                             (v_next_state == P_MP1_GOP_STRT) |
                             (v_next_state == P_MP1_PIC_STRT))) |
                           ((v_vld_state_r == P_MP1_UD2_SCID) &
                            ((v_next_state == P_SEQ_STRT) |
                             (v_next_state == P_MP1_SEC_STRT) |
                             (v_next_state == P_MP1_GOP_STRT) |
                             (v_next_state == P_MP1_PIC_STRT)));
  
  assign v_next_vscdet_ferror = ((v_vld_state_r == P_SEQ_SCID) &
                                   (v_next_state == P_INI_SRCH)) |
                                  ((v_vld_state_r == P_SEQ_SCID_MP2) & 
                                   (v_next_state == P_INI_SRCH)) |
                                  ((v_vld_state_r == P_SQX_SCID) &
                                   (v_next_state == P_INI_SRCH)) |
                                  ((v_vld_state_r == P_GOP_SCID) &
                                   (v_next_state == P_PFE_SRCH)) |
                                  ((v_vld_state_r == P_PIC_SCID) &
                                   (v_next_state == P_PFE_SRCH)) |
                                  ((v_vld_state_r == P_PCX_SCID) &
                                   (v_next_state == P_PFE_SRCH)) |
                                  ((v_vld_state_r == P_SQX_EXID) &
                                   (v_next_state == P_INI_SRCH)) |
                                  ((v_vld_state_r == P_SQX_EXID_MP2) &
                                   (v_next_state == P_INI_SRCH)) |
                                  ((v_vld_state_r == P_PCX_EXID) &
                                   (v_next_state == P_PFE_SRCH)) |
                                  ((v_vld_state_r == P_SEQ_SCID_MP1) &
                                   (v_next_state == P_INI_SRCH)) |
                                  ((v_vld_state_r == P_SQX_SCID_MP1) &
                                   (v_next_state == P_INI_SRCH)) |
                                  ((v_vld_state_r == P_MP1_UD0_SCID) &
                                   (v_next_state == P_INI_SRCH)) |
                                  ((v_vld_state_r == P_MP1_GOP_SCID) &
                                   (v_next_state == P_MP1_PFE_SRCH)) |
                                  ((v_vld_state_r == P_MP1_GPX_SCID) &
                                   (v_next_state == P_MP1_PFE_SRCH)) |
                                  ((v_vld_state_r == P_MP1_UD1_SCID) &
                                   (v_next_state == P_MP1_PFE_SRCH)) |
                                  ((v_vld_state_r == P_MP1_PIC_SCID) &
                                   (v_next_state == P_MP1_PFE_SRCH)) |
                                  ((v_vld_state_r == P_MP1_PIX_SCID) &
                                   (v_next_state == P_MP1_PFE_SRCH)) |
                                  ((v_vld_state_r == P_MP1_UD2_SCID) &
                                   (v_next_state == P_MP1_PFE_SRCH)) |
                                  ((v_vld_state_r == P_SLC_SCID) &
                                   (v_next_state == P_SLC_SRCH) & 
                                   v_ferrcond_r) | 
                                  ((v_vld_state_r == P_MP1_SLC_SCID) &
                                   (v_next_state == P_MP1_SLC_SRCH) & 
                                   v_ferrcond_r) | 
                                  ((v_vld_state_r == P_INI_SCID) &
                                   (v_next_state == P_INI_SRCH) & 
                                   v_ferrcond_r) 
                                    ;

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_sferror_r <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          v_sferror_r <= 1'b0;
      end
      else begin
          v_sferror_r <= v_next_sferror;
      end      
  end

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_vscdet_ferror_r <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          v_vscdet_ferror_r <= 1'b0;
      end
      else begin
          v_vscdet_ferror_r <= v_next_vscdet_ferror;
      end      
  end

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_slclverr_r <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          v_slclverr_r <= 1'b0;
      end
      else begin
          v_slclverr_r <= v_slcerr | v_macerr | 
                            v_blkerr_r | v_enderror;
      end      
  end


  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_skipslc_r <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          v_skipslc_r <= 1'b0;
      end
      else begin
          if(c_skipslc_r_s) begin 
              v_skipslc_r <= 1'b1;
          end      
          else if(y1_bs_wait_n & !c_skipslc_r_s) begin 
              v_skipslc_r <= 1'b0;
          end
          else begin
              v_skipslc_r <= v_skipslc_r; 
          end      
      end      
  end

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_skippic_r <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          v_skippic_r <= 1'b0;
      end
      else begin
          if(c_skippic_r_s) begin 
              v_skippic_r <= 1'b1;
          end      
          else if(y1_bs_wait_n & !c_skippic_r_s) begin 
              v_skippic_r <= 1'b0;
          end
          else begin
              v_skippic_r <= v_skippic_r; 
          end      
      end      
  end

  assign v_next_interrupt_n = ~(
                                  (v_skipslc_r & 
                                   ((v_vld_state_r == P_MAC_STRT) |
                                    (v_vld_state_r == P_MAC_WAIT) |
                                    (v_vld_state_r == P_MP1_MAC_STRT) |
                                    (v_vld_state_r == P_MP1_MAC_WAIT)))
                                  |
                                  (v_skippic_r &
                                   ((v_vld_state_r == P_SLC_STRT) |
                                    (v_vld_state_r == P_SLC_WAIT) |
                                    (v_vld_state_r == P_MAC_STRT) |
                                    (v_vld_state_r == P_MAC_WAIT) |
                                    (v_vld_state_r == P_MP1_SLC_STRT) |
                                    (v_vld_state_r == P_MP1_SLC_WAIT) |
                                    (v_vld_state_r == P_MP1_MAC_STRT) |
                                    (v_vld_state_r == P_MP1_MAC_WAIT)))
                                  );
  
  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_interrupt_r_n <= 1'b1;
      end
      else if(!g_swrst_r_n) begin
          v_interrupt_r_n <= 1'b1;
      end
      else if(!y1_bs_wait_n) begin
          v_interrupt_r_n <= v_interrupt_r_n;
      end
      else begin
          v_interrupt_r_n <= v_next_interrupt_n;
      end      
  end
  
  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v_ferrcond_r <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          v_ferrcond_r <= 1'b0;
      end
      else if(!y1_bs_wait_n) begin
          v_ferrcond_r <= v_ferrcond_r;
      end
      else begin
          if(
             ((v_vld_state_r == P_MAC_WAIT) &
              (v_next_state == P_SLC_SRCH)  &
              (~(v_macerr_r | v_blkerr_r | v_emberr_r))) |
             ((v_vld_state_r == P_MP1_MAC_WAIT) &
              (v_next_state == P_MP1_SLC_SRCH)  &
              (~(v_macerr_r | v_blkerr_r | v_emberr_r))) |
             (((v_vld_state_r == P_SEC_STRT) |
               (v_vld_state_r == P_MP1_SEC_STRT)) &
              (v_next_state == P_INI_SRCH))
             ) begin
              v_ferrcond_r <= 1'b1;
          end
          else if(
                  (v_vld_state_r == P_SLC_SCID) |
                  (v_vld_state_r == P_MP1_SLC_SCID) |
                  (v_vld_state_r == P_INI_SCID)
                  )begin
              v_ferrcond_r <= 1'b0;
          end
          else begin
              v_ferrcond_r <= v_ferrcond_r;
          end      
      end      
  end

  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          PARAA <= 8'hff;
      end
      else if(!g_swrst_r_n) begin
          PARAA <= 8'hff;
      end
      else if(!y1_bs_wait_n) begin
          PARAA <= PARAA;
      end
      else begin
          if((v_vld_state_r == P_SEQ_SCID) & 
             ((v_next_state == P_MP1_UD0_PRE) |
              (v_next_state == P_MP1_GOP_PRE))) begin
              PARAA <= 8'h3f; 
          end
          else if((v_vld_state_r == P_SQX_EXID) & 
             ((v_next_state == P_SQX_WAIT_MP1) | 
              (v_next_state == P_SQX_PRE))) begin
              PARAA <= 8'h3f; 
          end
          else if((v_next_state == P_SLC_STRT) | 
             (v_next_state == P_MP1_SLC_STRT)) begin
              PARAA <= 8'h0c; 
          end
          else begin
              PARAA <= 8'hff;
          end
      end      
  end
  always@(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          PARAD <= 8'h00;
      end
      else if(!g_swrst_r_n) begin
          PARAD <= 8'h00;
      end
      else if(!y1_bs_wait_n) begin
          PARAD <= PARAD;
      end
      else begin
          if(v_vld_state_r == P_SEQ_SCID) begin
              if((v_next_state == P_MP1_UD0_PRE) |
                 (v_next_state == P_MP1_GOP_PRE)) begin
                  PARAD <= 8'h80; 
              end
              else begin
                  PARAD <= 8'h00; 
              end
          end
          else if(v_vld_state_r == P_SQX_EXID) begin
              if(v_next_state == P_SQX_WAIT_MP1)
                PARAD <= 8'h80; 
              else
                PARAD <= 8'h00; 
          end
          else if((v_next_state == P_SLC_STRT) | 
             (v_next_state == P_MP1_SLC_STRT)) begin
              PARAD <= STREAM[31:24]; 
          end
          else begin
              PARAD <= 8'h00;
          end
      end      
  end



  always@(v_vld_state_r or g_init_vld_r_s or v_scpfxdetect or 
          STREAM or v_seqerr_r or SEQEOH or v_vld_mode_r or 
          SQXEOH or SDXEOH or USDEOH or GOPEOH or v_picerr_r or 
          PICEOH or v_pcxerr_r or PCXEOH or QMXEOH or v_cpxend_r_s or 
          PDXEOH or v_slcerr_r or SLICE_END or v_macerr_r or 
          v_blkerr_r  or v_emberr_r or v_blkend_r_s or v_skippic_r or 
          v_skipslc_r) begin
      case (v_vld_state_r)
        P_IDLE : begin
            if(g_init_vld_r_s)    v_next_state = P_LOAD1;
            else                    v_next_state = v_vld_state_r;
        end
        P_LOAD1 : v_next_state = P_LOAD2;
        P_LOAD2 : v_next_state = P_INI_SRCH;
        P_INI_SRCH : begin
            if(v_scpfxdetect) begin
                v_next_state = P_INI_SCID;
            end
            else begin
                v_next_state = v_vld_state_r;
            end
        end
        P_INI_SCID : begin
            if(STREAM[31:24]==8'hb3) begin
                v_next_state = P_SEQ_STRT; 
            end
            else begin
                v_next_state = P_INI_SRCH; 
            end
        end
        P_SEQ_STRT : v_next_state = P_SEQ_WAIT;
        P_SEQ_WAIT : begin
            if(v_seqerr_r) begin  
                v_next_state = P_INI_SRCH; 
            end
            else if(SEQEOH) begin 
                v_next_state = P_SEQ_SRCH;
            end
            else begin
                v_next_state = v_vld_state_r;
            end
        end
        P_SEQ_SRCH : begin
            if(v_scpfxdetect) begin
                v_next_state = P_SEQ_SCID;
            end
            else begin
                v_next_state = v_vld_state_r;// search
            end
        end
        P_SEQ_SCID : begin
            case (STREAM[31:24])
              8'hb2 : // user_data_start_code
                if(v_vld_mode_r[2])         
                  v_next_state = P_INI_SRCH;                 
                else
                  v_next_state = P_MP1_UD0_PRE; 
              8'hb3 : // sequence_header_code
                v_next_state = P_SEQ_STRT; 
              8'hb5 : // extension_start_code
                v_next_state = P_SQX_EXID; 
              8'hb8 : // group_start_code
                if(v_vld_mode_r[2])     
                  v_next_state = P_INI_SRCH;            
                else
                  v_next_state = P_MP1_GOP_PRE;
              default :
                v_next_state = P_INI_SRCH;               
            endcase
        end
        P_MP1_UD0_PRE : v_next_state = P_MP1_UD0_STRT;
        P_MP1_GOP_PRE : v_next_state = P_MP1_GOP_STRT;
        P_SEQ_STRT_MP2 : v_next_state = P_SEQ_WAIT_MP2;
        P_SEQ_WAIT_MP2 : begin
            if(v_seqerr_r) begin 
                v_next_state = P_INI_SRCH; 
            end
            else if(SEQEOH) begin 
                v_next_state = P_SEQ_SRCH_MP2;
            end
            else begin 
                v_next_state = v_vld_state_r;
            end
        end
        P_SEQ_SRCH_MP2 : begin
            if(v_scpfxdetect) begin
                v_next_state = P_SEQ_SCID_MP2;
            end
            else begin
                v_next_state = v_vld_state_r;
            end
        end
        P_SEQ_SCID_MP2 : begin
            case (STREAM[31:24])
              8'hb3 : // sequence_header_code
                v_next_state = P_SEQ_STRT; 
              8'hb5 : // extension_start_code
                v_next_state = P_SQX_EXID_MP2; 
              default :
                v_next_state = P_INI_SRCH; 
            endcase
        end
        P_SQX_EXID : begin
            if(STREAM[31:28]==4'h1)// extension_start_code_identifier
              v_next_state = P_SQX_PRE;
            else if(v_vld_mode_r[2]) // mpeg-2 only mode
              v_next_state = P_INI_SRCH; 
            else
              v_next_state = P_SQX_WAIT_MP1;
        end
        P_SQX_EXID_MP2 : begin
            case (STREAM[31:28]) 
              4'h1 : // sequence extension ID
                v_next_state = P_SQX_STRT;
              default : 
                v_next_state = P_INI_SRCH;
            endcase            
        end
        P_SQX_PRE : v_next_state = P_SQX_STRT;
        P_SQX_STRT : v_next_state = P_SQX_WAIT;
        P_SQX_WAIT : begin
            if(SQXEOH) begin // sequence_extension end
                v_next_state = P_SQX_SRCH;
            end
            else begin 
                v_next_state = v_vld_state_r;
            end
        end
        P_SQX_SRCH : begin
            if(v_scpfxdetect) begin
                v_next_state = P_SQX_SCID;
            end
            else begin
                v_next_state = v_vld_state_r;
            end
        end
        P_SQX_SCID : begin
            case (STREAM[31:24])
              8'h00 : // picture_start_code
                v_next_state = P_PIC_STRT; 
              8'hb2 : // user_data_start_code
                v_next_state = P_UD0_STRT; 
              8'hb3 : // sequence_header_code
                v_next_state = P_SEQ_STRT; 
              8'hb5 : // extension_start_code
                v_next_state = P_SDX_EXID;
              8'hb8 : // group_start_code
                v_next_state = P_GOP_STRT; 
              default :
                v_next_state = P_INI_SRCH; 
            endcase
        end
        P_SDX_EXID : begin
            if(STREAM[31:28]==4'h2) // sequence display extension ID
              v_next_state = P_SDX_STRT;
            else begin
                if(STREAM[31:8]==24'h000001)
                  v_next_state = P_SQX_SRCH;
                else
                  v_next_state = P_RD0_WAIT;
            end
        end
        P_SDX_STRT : v_next_state = P_SDX_WAIT;
        P_SDX_WAIT : begin
            if(SDXEOH) begin
                v_next_state = P_SQX_SRCH;
            end
            else begin 
                v_next_state = v_vld_state_r;
            end
        end
        P_RD0_WAIT : begin
            if(STREAM[31:8]==24'h000001)
              v_next_state = P_SQX_SRCH;
            else
              v_next_state = v_vld_state_r;
        end
        P_UD0_STRT : begin
              v_next_state = P_UD0_WAIT;
        end
        P_UD0_WAIT : begin
            if(USDEOH)
              v_next_state = P_SQX_SRCH;
            else
              v_next_state = v_vld_state_r;
        end
        P_GOP_STRT : v_next_state = P_GOP_WAIT;
        P_GOP_WAIT : begin
            if(GOPEOH) begin 
                v_next_state = P_GOP_SRCH;
            end
            else begin 
                v_next_state = v_vld_state_r;
            end
        end
        P_GOP_SRCH : begin
            if(v_scpfxdetect) begin
                v_next_state = P_GOP_SCID;
            end
            else begin
                v_next_state = v_vld_state_r;
            end
        end
        P_GOP_SCID : begin
            case (STREAM[31:24])
              8'h00 : // picture_start_code
                v_next_state = P_PIC_STRT; 
              8'hb2 : // user_data_start_code
                v_next_state = P_UD1_STRT;
              8'hb3 : // sequence_header_code
                v_next_state = P_SEQ_STRT;
              8'hb8 : // group_start_code
                v_next_state = P_GOP_STRT; 
              default :
                v_next_state = P_PFE_SRCH; 
            endcase
        end
        P_UD1_STRT : begin
              v_next_state = P_UD1_WAIT;
        end
        P_UD1_WAIT : begin
            if(USDEOH)
              v_next_state = P_GOP_SRCH;
            else
              v_next_state = v_vld_state_r;
        end
        P_PIC_STRT : v_next_state = P_PIC_WAIT;
        P_PIC_WAIT : begin
            if(v_picerr_r) begin 
                v_next_state = P_PFE_SRCH;
            end
            else if(PICEOH) begin 
                v_next_state = P_PIC_SRCH;
            end
            else begin 
                v_next_state = v_vld_state_r;
            end
        end
        P_PIC_SRCH : begin
            if(v_scpfxdetect) begin
                v_next_state = P_PIC_SCID;
            end
            else begin
                v_next_state = v_vld_state_r;
            end
        end
        P_PIC_SCID : begin
            case (STREAM[31:24])
              8'h00 : // picture_start_code
                v_next_state = P_PIC_STRT; 
              8'hb3 : // sequence_header_code
                v_next_state = P_SEQ_STRT; 
              8'hb5 : // extension_start_code
                v_next_state = P_PCX_EXID; 
              8'hb8 : // group_start_code
                v_next_state = P_GOP_STRT; 
              default :
                v_next_state = P_PFE_SRCH; 
            endcase
        end
        P_PFE_SRCH : begin
            if(v_scpfxdetect) begin
                v_next_state = P_PFE_SCID;
            end
            else begin
                v_next_state = v_vld_state_r;
            end
        end
        P_PFE_SCID : begin
            case (STREAM[31:24])
              8'h00 : // picture_start_code
                v_next_state = P_PIC_STRT; 
              8'hb3 : // sequence_header_code
                v_next_state = P_SEQ_STRT; 
              8'hb8 : // group_start_code
                v_next_state = P_GOP_STRT; 
              default :
                v_next_state = P_PFE_SRCH; 
            endcase
        end
        P_PCX_EXID : begin
            if(STREAM[31:28]==4'h8) // picture coding extension ID
              v_next_state = P_PCX_STRT;
            else
              v_next_state = P_PFE_SRCH; 
        end
        P_PCX_STRT : v_next_state = P_PCX_WAIT;
        P_PCX_WAIT : begin
            if(v_pcxerr_r) begin 
                v_next_state = P_PFE_SRCH;
            end
            else if(PCXEOH) begin 
                v_next_state = P_PCX_SRCH;
            end
            else begin 
                v_next_state = v_vld_state_r;
            end
        end
        P_PCX_SRCH : begin
            if(v_scpfxdetect) begin
                v_next_state = P_PCX_SCID;
            end
            else begin
                v_next_state = v_vld_state_r;
            end
        end
        P_PCX_SCID : begin
            if(STREAM[31:24]==8'h00) // picture_start_code
              v_next_state = P_PIC_STRT; 
            else if(STREAM[31:24] < 8'hb0) // slice_start_code
              v_next_state = P_SLC_STRT; 
            else begin
                case (STREAM[31:24])
                  8'hb2 : // user_data_start_code
                    v_next_state = P_UD2_STRT; 
                  8'hb3 : // sequence_header_code
                    v_next_state = P_SEQ_STRT; 
                  8'hb5 : // extension_start_code
                    v_next_state = P_QMX_EXID; 
                  8'hb8 : // group_start_code
                    v_next_state = P_GOP_STRT; 
                  default :
                    v_next_state = P_PFE_SRCH; 
                endcase
            end
        end
        P_QMX_EXID : begin
            if(STREAM[31:8]==24'h000001)
              v_next_state = P_PCX_SRCH;
            else begin
                case(STREAM[31:28])
                  4'h3 : // quant_matrix_extension ID
                    v_next_state = P_QMX_STRT;
                  4'h4 : // copyright_extension ID
                    v_next_state = P_CPX_STRT;
                  4'h7 : // picture_display_extension ID
                    v_next_state = P_PDX_STRT;
                  default : // reserved_extension_data_byte
                    v_next_state = P_RD2_WAIT;
                endcase
            end              
        end              
        P_QMX_STRT : v_next_state = P_QMX_WAIT;
        P_QMX_WAIT : begin
            if(v_seqerr_r) begin 
                v_next_state = P_PFE_SRCH;
            end
            else if(QMXEOH) begin 
                v_next_state = P_PCX_SRCH;
            end
            else begin 
                v_next_state = v_vld_state_r;
            end
        end
        P_CPX_STRT : v_next_state = P_CPX_WAIT;
        P_CPX_WAIT : begin
            if(v_cpxend_r_s) begin 
                v_next_state = P_PCX_SRCH;
            end
            else begin 
                v_next_state = v_vld_state_r;
            end
        end
        P_PDX_STRT : v_next_state = P_PDX_WAIT;
        P_PDX_WAIT : begin
            if(PDXEOH) begin 
                v_next_state = P_PCX_SRCH;
            end
            else begin
                v_next_state = v_vld_state_r;
            end
        end
        P_RD2_WAIT : begin
            if(STREAM[31:8]==24'h000001)
              v_next_state = P_PCX_SRCH;
            else
              v_next_state = v_vld_state_r;
        end
        P_UD2_STRT : begin
              v_next_state = P_UD2_WAIT;
        end
        P_UD2_WAIT : begin
            if(USDEOH)
              v_next_state = P_PCX_SRCH;
            else
              v_next_state = v_vld_state_r;
        end
        P_SLC_STRT : begin
            if(v_skippic_r)begin
                v_next_state = P_PFE_SRCH; 
            end
            else begin
                v_next_state = P_SLC_WAIT;
            end
        end
        P_SLC_WAIT : begin
            if(v_skippic_r)begin
                v_next_state = P_PFE_SRCH; 
            end
            else if(v_slcerr_r) begin
                v_next_state = P_SLC_SRCH; 
            end
            else if(SLICE_END) begin 
                v_next_state = P_MAC_WAIT;
            end
            else begin 
                v_next_state = v_vld_state_r;
            end
        end
        P_MAC_STRT : begin
            if(v_skippic_r) begin
                v_next_state = P_PFE_SRCH;
            end
            else if(v_skipslc_r) begin
                v_next_state = P_SLC_SRCH;
            end
            else begin
                v_next_state = P_MAC_WAIT;
            end
        end
        P_MAC_WAIT : begin
            if(v_skippic_r) begin
                v_next_state = P_PFE_SRCH;
            end
            else if(v_macerr_r | v_blkerr_r | 
                    v_skipslc_r | v_emberr_r) begin
                v_next_state = P_SLC_SRCH; 
            end
            else if(v_blkend_r_s) begin 
                if(STREAM[31:9]==23'h000000)
                  v_next_state = P_SLC_SRCH; 
                else
                  v_next_state = P_MAC_STRT;
            end
            else begin 
                v_next_state = v_vld_state_r;
            end
        end
        P_SLC_SRCH : begin
            if(v_scpfxdetect) begin
                if(v_skippic_r) begin
                    v_next_state = P_PFE_SCID;
                end                    
                else begin
                    v_next_state = P_SLC_SCID;
                end
            end
            else begin
                if(v_skippic_r) begin
                    v_next_state = P_PFE_SRCH;
                end                    
                else begin
                    v_next_state = v_vld_state_r;
                end
            end
        end
        P_SLC_SCID : begin
            if(STREAM[31:24]==8'h00) begin
              v_next_state = P_PIC_STRT;
            end
            else if(STREAM[31:24] < 8'hb0) begin
                if(v_skippic_r) begin
                    v_next_state = P_PFE_SRCH; 
                end                    
                else begin
                    v_next_state = P_SLC_STRT; 
                end                    
            end
            else begin
                case (STREAM[31:24])
                  8'hb3 : // sequence_header_code
                    v_next_state = P_SEQ_STRT_MP2; 
                  8'hb7 : // sequence_end_code
                    v_next_state = P_SEC_STRT; 
                  8'hb8 : // group_start_code
                    v_next_state = P_GOP_STRT; 
                  default :
                    if(v_skippic_r) begin
                        v_next_state = P_PFE_SRCH;
                    end                    
                    else begin
                        v_next_state = P_SLC_SRCH;                
                    end                    
                endcase
            end
        end
        P_SEC_STRT : v_next_state = P_INI_SRCH; 
        P_SEQ_STRT_MP1 : v_next_state = P_SEQ_WAIT_MP1;
        P_SEQ_WAIT_MP1 : begin
            if(v_seqerr_r) begin  
                v_next_state = P_INI_SRCH; 
            end
            else if(SEQEOH) begin
                v_next_state = P_SEQ_SRCH_MP1;
            end
            else begin 
                v_next_state = v_vld_state_r;
            end
        end
        P_SEQ_SRCH_MP1 : begin
            if(v_scpfxdetect) begin
                v_next_state = P_SEQ_SCID_MP1;
            end
            else begin
                v_next_state = v_vld_state_r;
            end
        end
        P_SEQ_SCID_MP1 : begin
            case (STREAM[31:24])
              8'hb2 : // user_data_start_code
                v_next_state = P_MP1_UD0_STRT; 
              8'hb3 : // sequence_header_code
                v_next_state = P_SEQ_STRT; 
              8'hb5 : // extension_start_code
                v_next_state = P_SQX_WAIT_MP1;
              8'hb7 : // sequence_end_code
                v_next_state = P_MP1_SEC_STRT;
              8'hb8 : // group_start_code
                v_next_state = P_MP1_GOP_STRT;
              default :
                v_next_state = P_INI_SRCH; 
            endcase
        end
        P_SQX_WAIT_MP1 : begin
            if(STREAM[31:8]==24'h000001)
              v_next_state = P_SQX_SRCH_MP1;
            else
              v_next_state = v_vld_state_r;
        end
        P_SQX_SRCH_MP1 : begin
            if(v_scpfxdetect) begin
                v_next_state = P_SQX_SCID_MP1;
            end
            else begin
                v_next_state = v_vld_state_r;
            end
        end
        P_SQX_SCID_MP1 : begin
            case (STREAM[31:24])
              8'hb2 : // user_data_start_code
                v_next_state = P_MP1_UD0_STRT; 
              8'hb3 : // sequence_header_code
                v_next_state = P_SEQ_STRT;
              8'hb7 : // sequence_end_code
                v_next_state = P_MP1_SEC_STRT; 
              8'hb8 : // group_start_code
                v_next_state = P_MP1_GOP_STRT; 
              default :
                v_next_state = P_INI_SRCH;
            endcase
        end
        P_MP1_UD0_STRT : v_next_state = P_MP1_UD0_WAIT;
        P_MP1_UD0_WAIT : begin
            if(USDEOH)
              v_next_state = P_MP1_UD0_SRCH;
            else
              v_next_state = v_vld_state_r;
        end
        P_MP1_UD0_SRCH : begin
            if(v_scpfxdetect) begin
                v_next_state = P_MP1_UD0_SCID;
            end
            else begin
                v_next_state = v_vld_state_r;
            end
        end
        P_MP1_UD0_SCID : begin
            case (STREAM[31:24])
              8'hb3 : // sequence_header_code
                v_next_state = P_SEQ_STRT; 
              8'hb7 : // sequence_end_code
                v_next_state = P_MP1_SEC_STRT; 
              8'hb8 : // group_start_code
                v_next_state = P_MP1_GOP_STRT; 
              default :
                v_next_state = P_INI_SRCH; 
            endcase
        end
        P_MP1_PFE_SRCH : begin
            if(v_scpfxdetect) begin
                v_next_state = P_MP1_PFE_SCID;
            end
            else begin
                v_next_state = v_vld_state_r;
            end
        end
        P_MP1_PFE_SCID : begin
            case (STREAM[31:24])
              8'h00 : // picture_start_code
                v_next_state = P_MP1_PIC_STRT; 
              8'hb3 : // sequence_header_code
                v_next_state = P_SEQ_STRT; 
              8'hb7 : // sequence_end_code
                v_next_state = P_MP1_SEC_STRT; 
              8'hb8 : // group_start_code
                v_next_state = P_MP1_GOP_STRT;
              default :
                v_next_state = P_MP1_PFE_SRCH; 
            endcase
        end
        P_MP1_GOP_STRT : v_next_state = P_MP1_GOP_WAIT;
        P_MP1_GOP_WAIT : begin
            if(GOPEOH) begin 
                v_next_state = P_MP1_GOP_SRCH;
            end
            else begin 
                v_next_state = v_vld_state_r;
            end
        end
        P_MP1_GOP_SRCH : begin
            if(v_scpfxdetect) begin
                v_next_state = P_MP1_GOP_SCID;
            end
            else begin
                v_next_state = v_vld_state_r;
            end
        end
        P_MP1_GOP_SCID : begin
            case (STREAM[31:24])
              8'h00 : // picture_start_code
                v_next_state = P_MP1_PIC_STRT; 
              8'hb2 : // user_data_start_code
                v_next_state = P_MP1_UD1_STRT; 
              8'hb3 : // sequence_header_code
                v_next_state = P_SEQ_STRT;
              8'hb5 : // extension_start_code
                v_next_state = P_MP1_GPX_WAIT; 
              8'hb7 : // sequence_end_code
                v_next_state = P_MP1_SEC_STRT; 
              8'hb8 : // group_start_code
                v_next_state = P_MP1_GOP_STRT; 
              default :
                v_next_state = P_MP1_PFE_SRCH; 
            endcase
        end
        P_MP1_GPX_WAIT : begin
            if(STREAM[31:8]==24'h000001)
              v_next_state = P_MP1_GPX_SRCH;
            else
              v_next_state = v_vld_state_r;
        end
        P_MP1_GPX_SRCH : begin
            if(v_scpfxdetect) begin
                v_next_state = P_MP1_GPX_SCID;
            end
            else begin
                v_next_state = v_vld_state_r;
            end
        end
        P_MP1_GPX_SCID : begin
            case (STREAM[31:24])
              8'h00 : // picture_start_code
                v_next_state = P_MP1_PIC_STRT;
              8'hb2 : // user_data_start_code
                v_next_state = P_MP1_UD1_STRT; 
              8'hb3 : // sequence_header_code
                v_next_state = P_SEQ_STRT; 
              8'hb7 : // sequence_end_code
                v_next_state = P_MP1_SEC_STRT; 
              8'hb8 : // group_start_code
                v_next_state = P_MP1_GOP_STRT; 
              default :
                v_next_state = P_MP1_PFE_SRCH; 
            endcase
        end
        P_MP1_UD1_STRT : v_next_state = P_MP1_UD1_WAIT;
        P_MP1_UD1_WAIT : begin
            if(USDEOH)
              v_next_state = P_MP1_UD1_SRCH;
            else
              v_next_state = v_vld_state_r;
        end
        P_MP1_UD1_SRCH : begin
            if(v_scpfxdetect) begin
                v_next_state = P_MP1_UD1_SCID;
            end
            else begin
                v_next_state = v_vld_state_r;
            end
        end
        P_MP1_UD1_SCID : begin
            case (STREAM[31:24])
              8'h00 : // picture_start_code
                v_next_state = P_MP1_PIC_STRT; 
              8'hb3 : // sequence_header_code
                v_next_state = P_SEQ_STRT; 
              8'hb7 : // sequence_end_code
                v_next_state = P_MP1_SEC_STRT; 
              8'hb8 : // group_start_code
                v_next_state = P_MP1_GOP_STRT;
              default :
                v_next_state = P_MP1_PFE_SRCH; 
            endcase
        end
        P_MP1_PIC_STRT : v_next_state = P_MP1_PIC_WAIT;
        P_MP1_PIC_WAIT : begin
            if(v_picerr_r) begin 
                v_next_state = P_MP1_PFE_SRCH;
            end
            else if(PICEOH) begin 
                v_next_state = P_MP1_PIC_SRCH;
            end
            else begin
                v_next_state = v_vld_state_r;
            end
        end
        P_MP1_PIC_SRCH : begin
            if(v_scpfxdetect) begin
                v_next_state = P_MP1_PIC_SCID;
            end
            else begin
                v_next_state = v_vld_state_r;
            end
        end
        P_MP1_PIC_SCID : begin
            if(STREAM[31:24]==8'h00) begin
                v_next_state = P_MP1_PIC_STRT; 
            end
            else if(STREAM[31:24] < 8'hb0) begin
                v_next_state = P_MP1_SLC_STRT; 
            end
            else begin
                case (STREAM[31:24])
                  8'hb2 : // user_data_start_code
                    v_next_state = P_MP1_UD2_STRT; 
                  8'hb3 : // sequence_header_code
                    v_next_state = P_SEQ_STRT; 
                  8'hb5 : // extension_start_code
                    v_next_state = P_MP1_PIX_WAIT; 
                  8'hb7 : // sequence_end_code
                    v_next_state = P_MP1_SEC_STRT; 
                  8'hb8 : // group_start_code
                    v_next_state = P_MP1_GOP_STRT; 
                  default :
                    v_next_state = P_MP1_PFE_SRCH; 
                endcase
            end
        end
        P_MP1_PIX_WAIT : begin
            if(STREAM[31:8]==24'h000001)
              v_next_state = P_MP1_PIX_SRCH;
            else
              v_next_state = v_vld_state_r;
        end
        P_MP1_PIX_SRCH : begin
            if(v_scpfxdetect) begin
                v_next_state = P_MP1_PIX_SCID;
            end
            else begin
                v_next_state = v_vld_state_r;
            end
        end
        P_MP1_PIX_SCID : begin
            if(STREAM[31:24]==8'h00) begin
                v_next_state = P_MP1_PIC_STRT; 
            end
            else if(STREAM[31:24] < 8'hb0) begin
                v_next_state = P_MP1_SLC_STRT;
            end
            else begin
                case (STREAM[31:24])
                  8'hb2 : // user_data_start_code
                    v_next_state = P_MP1_UD2_STRT; 
                  8'hb3 : // sequence_header_code
                    v_next_state = P_SEQ_STRT; 
                  8'hb7 : // sequence_end_code
                    v_next_state = P_MP1_SEC_STRT; 
                  8'hb8 : // group_start_code
                    v_next_state = P_MP1_GOP_STRT; 
                  default :
                    v_next_state = P_MP1_PFE_SRCH; 
                endcase
            end
        end
        P_MP1_UD2_STRT : v_next_state = P_MP1_UD2_WAIT;
        P_MP1_UD2_WAIT : begin
            if(USDEOH)
              v_next_state = P_MP1_UD2_SRCH;
            else
              v_next_state = v_vld_state_r;
        end
        P_MP1_UD2_SRCH : begin
            if(v_scpfxdetect) begin
                v_next_state = P_MP1_UD2_SCID;
            end
            else begin
                v_next_state = v_vld_state_r;
            end
        end
        P_MP1_UD2_SCID : begin
            if(STREAM[31:24]==8'h00) begin
                v_next_state = P_MP1_PIC_STRT; 
            end
            else if(STREAM[31:24] < 8'hb0) begin
                v_next_state = P_MP1_SLC_STRT; 
            end
            else begin
                case (STREAM[31:24])
                  8'hb3 : // sequence_header_code
                    v_next_state = P_SEQ_STRT;
                  8'hb7 : // sequence_end_code
                    v_next_state = P_MP1_SEC_STRT; 
                  8'hb8 : // group_start_code
                    v_next_state = P_MP1_GOP_STRT; 
                  default :
                    v_next_state = P_MP1_PFE_SRCH; 
                endcase
            end
        end
        P_MP1_SLC_STRT : begin
            if(v_skippic_r) begin
                v_next_state = P_MP1_PFE_SRCH;
            end
            else begin
                v_next_state = P_MP1_SLC_WAIT;
            end
        end
        P_MP1_SLC_WAIT : begin
            if(v_skippic_r) begin
                v_next_state = P_MP1_PFE_SRCH;
            end
            else if(v_slcerr_r) begin
                v_next_state = P_MP1_SLC_SRCH; 
            end
            else if(SLICE_END) begin 
                v_next_state = P_MP1_MAC_WAIT;
            end
            else begin
              v_next_state = v_vld_state_r;
            end
        end
        P_MP1_MAC_STRT : begin
            if(v_skippic_r) begin
                v_next_state = P_MP1_PFE_SRCH;
            end
            else if(v_skipslc_r) begin
                v_next_state = P_MP1_SLC_SRCH;
            end
            else begin
                v_next_state = P_MP1_MAC_WAIT;
            end
        end
        P_MP1_MAC_WAIT : begin
            if(v_skippic_r) begin
                v_next_state = P_MP1_PFE_SRCH;
            end
            else if(v_macerr_r | v_blkerr_r | 
                    v_skipslc_r | v_emberr_r) begin
                v_next_state = P_MP1_SLC_SRCH; 
            end               
            else if(v_blkend_r_s) begin 
                if(STREAM[31:9]==23'h000000)
                  v_next_state = P_MP1_SLC_SRCH;
                else
                  v_next_state = P_MP1_MAC_STRT;
            end
            else begin 
                v_next_state = v_vld_state_r;
            end
        end
        P_MP1_SLC_SRCH : begin
            if(v_scpfxdetect) begin
                if(v_skippic_r) begin
                    v_next_state = P_MP1_PFE_SCID;
                end                    
                else begin
                    v_next_state = P_MP1_SLC_SCID;
                end                    
            end
            else begin
                if(v_skippic_r) begin
                    v_next_state = P_MP1_PFE_SCID;
                end                    
                else begin
                    v_next_state = v_vld_state_r;
                end                    
            end
        end
        P_MP1_SLC_SCID : begin
            if(STREAM[31:24]==8'h00) begin
              v_next_state = P_MP1_PIC_STRT; 
            end
            else if(STREAM[31:24] < 8'hb0) begin
                if(v_skippic_r) begin
                    v_next_state = P_MP1_PFE_SCID;
                end                    
                else begin
                    v_next_state = P_MP1_SLC_STRT;
                end                    
            end
            else begin
                case (STREAM[31:24])
                  8'hb3 : // sequence_header_code
                    v_next_state = P_SEQ_STRT_MP1; 
                  8'hb7 : // sequence_end_code
                    v_next_state = P_MP1_SEC_STRT; 
                  8'hb8 : // group_start_code
                    v_next_state = P_MP1_GOP_STRT;
                  default :
                    if(v_skippic_r) begin
                        v_next_state = P_MP1_PFE_SCID;
                    end                    
                    else begin
                        v_next_state = P_MP1_SLC_SRCH; 
                    end                    
                endcase
            end
        end
        P_MP1_SEC_STRT : v_next_state = P_INI_SRCH; 
        default : v_next_state = P_IDLE;
      endcase
  end 

endmodule
