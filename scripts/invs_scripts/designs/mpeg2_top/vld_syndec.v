// ----------------------------------------------
// File: vld_syndec.v
// Module: vld_syndec
// Function:
// ----------------------------------------------

module vld_syndec(
                      v_mbhend_r_s,  
                      v_paramadr_r,  
                      v_paramdata_r, 
                      v_vdoen_r,    
                      v_vdo_r,      
                      v_vldstatus_r,
                      v_vldmstatus_r,
                      v_seqstrt_r,   
                      v_sqxstrt_r,   
                      v_sdxstrt_r,   
                      v_ud0strt_r,   
                      v_gopstrt_r,   
                      v_ud1strt_r,   
                      v_picstrt_r,   
                      v_pcxstrt_r,   
                      v_qmxstrt_r,   
                      v_cpxstrt_r,   
                      v_pdxstrt_r,   
                      v_ud2strt_r,   
                      v_atscdet_r,   
                      v_slicestart_r,
                      v_mbadet_r,   
                      v_qmsyni_r_n,  
                      v_qmseli_r,    
                      v_qmsynn_r_n,  
                      v_qmseln_r,    
                      v_qmdata_r,    
                      v_ferror_r,    
                      v_vscdet_ferror_r,
                      v_nferror_r,   
                      v_sferror_r, 
                      v_slclverr_r,   
                      v1_bs_req_n,    
                      v_mbmot_type_r, 
                      clkdec,     
                      rstdec_x,   
                      g_swrst_r_n,  
                      y1_bs_wait_n,   
                      g_init_vld_r_s,
                      c_mbpl_vld_r_s,
                      c_skipslc_r_s, 
                      c_skippic_r_s, 
                      y1_bs_data,      
                      g_vldmode_r,
                      y1_bs_data_r     
                      );

  output        v_mbhend_r_s;    
  output [7:0]  v_paramadr_r;    
  output [24:0] v_paramdata_r;   
  output        v_vdoen_r;       
  output [11:0] v_vdo_r;         
  output [7:0]  v_vldstatus_r;  
  output [3:0]  v_vldmstatus_r; 
  output        v_seqstrt_r;    
  output        v_sqxstrt_r;    
  output        v_sdxstrt_r;    
  output        v_ud0strt_r;    
  output        v_gopstrt_r;    
  output        v_ud1strt_r;    
  output        v_picstrt_r;    
  output        v_pcxstrt_r;    
  output        v_qmxstrt_r;    
  output        v_cpxstrt_r;    
  output        v_pdxstrt_r;    
  output        v_ud2strt_r;    
  output        v_atscdet_r;    
  output        v_slicestart_r; 
  output        v_mbadet_r;     
  output        v_qmsyni_r_n;   
  output        v_qmseli_r;     
  output        v_qmsynn_r_n;   
  output        v_qmseln_r;     
  output [7:0]  v_qmdata_r;     
  output        v_ferror_r;      
  output        v_vscdet_ferror_r;
  output        v_nferror_r;     
  output        v_sferror_r;     
  output        v_slclverr_r;    
  output        v1_bs_req_n;     
  output [1:0]  v_mbmot_type_r;  
  input         clkdec;         
  input         rstdec_x;       
  input         g_swrst_r_n;    
  input         y1_bs_wait_n;     
  input         g_init_vld_r_s; 
  input         c_mbpl_vld_r_s; 
  input         c_skipslc_r_s;  
  input         c_skippic_r_s;  
  input [31:0]  y1_bs_data;       
  input [1:0]   g_vldmode_r;    
  output [31:0] y1_bs_data_r;

  wire [31:0]   y1_bs_data;       
  wire [7:0]    v_paramadr_r;     
  wire [24:0]   v_paramdata_r;    
  wire [1:0]    v_mbmot_type_r;   
  wire [11:0]   v_vdo_r;        
  wire [3:0]    v_vldmstatus_r; 
  wire [7:0]    v_qmdata_r;     
  wire [5:0]    SCSHIFT;
  wire [7:0]    SC_PARAA;
  wire [7:0]    SC_PARAD;
  wire [7:0]    SQH_PARAA;
  wire [7:0]    SQX_PARAA;
  wire [7:0]    SQD_PARAA;
  wire [7:0]    USR_PARAA;
  wire [7:0]    USR_PARAD;
  wire [7:0]    GOP_PARAA;
  wire [7:0]    PIC_PARAA;
  wire [2:0]    PIC_PARAD;
  wire [7:0]    PCX_PARAA;
  wire [8:0]    PCX_PARAD;
  wire [7:0]    PDX_PARAA;
  wire [1:0]    PDX_PARAD;
  wire [7:0]    CPY_PARAA;
  wire [7:0]    SLC_PARAA;
  wire [7:0]    MAC_PARAA;
  wire [17:0]   MAC_PARAD;

  wire [7:0]    v_vldstatus_r;
  wire [1:0]    g_vldmode_r;
  wire [31:0]   UREG;
  wire [4:0]    ADP;
  wire [5:0]    SEQ_SHIFT;
  wire [5:0]    SQX_SHIFT;
  wire [5:0]    SDX_SHIFT;
  wire [5:0]    USR_SHIFT;
  wire [5:0]    GOP_SHIFT;
  wire [5:0]    PIC_SHIFT;
  wire [5:0]    PDX_SHIFT;
  wire [5:0]    PCX_SHIFT;
  wire [5:0]    SLC_SHIFT;
  wire [5:0]    MAC_SHIFT;
  wire [5:0]    BLK_SHIFT;
  wire [5:0]    CPR_SHIFT;
  wire [31:0]   STREAM;
  wire [2:0]    PIC_CODE_TYPE;
  wire [2:0]    FWD_F_CODE;
  wire [2:0]    BWD_F_CODE;
  wire [1:0]    PICTURE_STRUCTURE;
  wire [5:0]    v_cbp_r;
  wire [3:0]    v_fcode_fwdh_r;
  wire [3:0]    v_fcode_fwdv_r;
  wire [3:0]    v_fcode_bwdh_r;
  wire [3:0]    v_fcode_bwdv_r;
  wire [1:0]    v_vldmode_r;
  wire          v_slcstrt_r;
  wire          v_enderror;
  wire          v_low_delay_r;
  wire [31:0]   y1_bs_data_r;
  wire          SEQEOH,QMXEOH,v_seqhed_ferror,SQH_NERROR;
  wire          v_interrupt_r_n;

  assign v_slicestart_r = v_slcstrt_r;

vld_seqhed vld_seqhed(
     .ENDDECS(SEQEOH),
     .ENDDECQ(QMXEOH),
     .FERROR(v_seqhed_ferror),
     .NFERROR(SQH_NERROR),
     .QMSYNI(v_qmsyni_r_n),
     .QMSELI(v_qmseli_r),
     .QMSYNN(v_qmsynn_r_n),
     .QMSELN(v_qmseln_r),
     .QM(v_qmdata_r),
     .SHIFT(SEQ_SHIFT),
     .PARAA(SQH_PARAA),
     .clkdec(clkdec),
     .rstdec_x(rstdec_x),
     .g_swrst_r_n(g_swrst_r_n),
     .y1_bs_wait_n(y1_bs_wait_n),
     .v_interrpt_n(v_interrupt_r_n),
     .STREAM(STREAM[31:8]),
     .KICKS(v_seqstrt_r),
     .KICKQ(v_qmxstrt_r)
     );

wire   SQXEOH,SQX_NERROR,PROGRESSIVE_SEQUENCE; 

vld_seqext vld_seqext(
     .ENDDEC(SQXEOH),
     .NFERROR(SQX_NERROR),
     .HOLD_PROGRESSIVE_SEQUENCE(PROGRESSIVE_SEQUENCE),
     .SHIFT(SQX_SHIFT),
     .PARAA(SQX_PARAA),
     .v_low_delay_r(v_low_delay_r),
     .KICK(v_sqxstrt_r),
     .STREAM(STREAM[31:20]),
     .clkdec(clkdec),
     .rstdec_x(rstdec_x),
     .g_swrst_r_n(g_swrst_r_n),
     .y1_bs_wait_n(y1_bs_wait_n),
     .v_interrpt_n(v_interrupt_r_n)
     );

wire SDXEOH,SQD_NERROR;

vld_seqdis vld_seqdis(
     .ENDDEC(SDXEOH),
     .NFERROR(SQD_NERROR),
     .SHIFT(SDX_SHIFT),
     .PARAA(SQD_PARAA),
     .KICK(v_sdxstrt_r),
     .STREAM(STREAM[31]),
     .clkdec(clkdec),
     .rstdec_x(rstdec_x),
     .g_swrst_r_n(g_swrst_r_n),
     .y1_bs_wait_n(y1_bs_wait_n),
     .v_interrpt_n(v_interrupt_r_n)
     );

wire USDEOH;
     
vld_usrdat vld_usrdat(
     .ENDDEC(USDEOH),
     .SHIFT(USR_SHIFT),
     .PARAA(USR_PARAA),
     .PARAD(USR_PARAD),
     .v_atscdet_r_s(v_atscdet_r),
     .KICK0(v_ud0strt_r),
     .KICK1(v_ud1strt_r),
     .KICK2(v_ud2strt_r),
     .STREAM(STREAM[31:0]),
     .v_vldmode_r(v_vldmode_r),
     .clkdec(clkdec),
     .rstdec_x(rstdec_x),
     .g_swrst_r_n(g_swrst_r_n),
     .y1_bs_wait_n(y1_bs_wait_n),
     .v_interrpt_n(v_interrupt_r_n)
     );
  
wire GOPEOH,GOP_NERROR;

vld_gophed vld_gophed(
     .ENDDEC(GOPEOH),
     .NFERROR(GOP_NERROR),
     .SHIFT(GOP_SHIFT),
     .PARAA(GOP_PARAA),
     .KICK(v_gopstrt_r),
     .STREAM(STREAM[9]),
     .clkdec(clkdec),
     .rstdec_x(rstdec_x),
     .g_swrst_r_n(g_swrst_r_n),
     .y1_bs_wait_n(y1_bs_wait_n),
     .v_interrpt_n(v_interrupt_r_n)
     );

wire PICEOH,v_piched_ferror,PIC_NERROR,MPEG1;
  
vld_piched vld_piched(
     .ENDDEC(PICEOH),
     .FERROR(v_piched_ferror),
     .NFERROR(PIC_NERROR),
     .SHIFT(PIC_SHIFT),
     .PARAA(PIC_PARAA),
     .PARAD(PIC_PARAD),
     .PIC_CODE_TYPE(PIC_CODE_TYPE),
     .FWD_F_CODE(FWD_F_CODE),
     .BWD_F_CODE(BWD_F_CODE),
     .KICK(v_picstrt_r),
     .STREAM(STREAM[31:29]),
     .MPEG1(MPEG1),
     .v_low_delay_r(v_low_delay_r),
     .clkdec(clkdec),
     .rstdec_x(rstdec_x),
     .g_swrst_r_n(g_swrst_r_n),
     .y1_bs_wait_n(y1_bs_wait_n),
     .v_interrpt_n(v_interrupt_r_n)
     );

wire PCXEOH,v_piccod_ferror,PCX_NERROR,v_topfldfst_r;
wire v_fpredfdct_r,v_consvec_r,v_repfstfld_r,v_intravlcfmt_r;

vld_piccod vld_piccod(
     .ENDDEC(PCXEOH),
     .FERROR(v_piccod_ferror),
     .NFERROR(PCX_NERROR),
     .SHIFT(PCX_SHIFT),
     .PARAA(PCX_PARAA),
     .PARAD(PCX_PARAD),
     .PICTURE_STRUCTURE_CODE(PICTURE_STRUCTURE),
     .v_topfldfst_r(v_topfldfst_r),
     .FRAME_PRED_FRAME_DCT(v_fpredfdct_r),
     .CONCEALMENT_MOTION_VECTORS(v_consvec_r),
     .REPEAT_FIRST_FIELD(v_repfstfld_r),
     .INTRA_VLC_FORMAT(v_intravlcfmt_r),
     .FORWARD_HORIZONTAL(v_fcode_fwdh_r),
     .FORWARD_VERTICAL(v_fcode_fwdv_r),
     .BACKWARD_HORIZONTAL(v_fcode_bwdh_r),
     .BACKWARD_VERTICAL(v_fcode_bwdv_r),
     .KICK(v_pcxstrt_r),
     .STREAM(STREAM[31:23]),
     .PICTURE_CODE_TYPE(PIC_CODE_TYPE),
     .PROGRESSIVE_SEQUENCE(PROGRESSIVE_SEQUENCE),
     .clkdec(clkdec),
     .rstdec_x(rstdec_x),
     .g_swrst_r_n(g_swrst_r_n),
     .y1_bs_wait_n(y1_bs_wait_n),
     .v_interrpt_n(v_interrupt_r_n)
     );

wire PDXEOH,PDX_NERROR;
  
vld_picdis vld_picdis(
     .ENDDEC(PDXEOH),
     .NFERROR(PDX_NERROR),
     .SHIFT(PDX_SHIFT),
     .PARAA(PDX_PARAA),
     .PARAD(PDX_PARAD),
     .KICK(v_pdxstrt_r),
     .STREAM(STREAM[15]),
     .PICTURE_STRUCTURE_CODE(PICTURE_STRUCTURE),
     .PROGRESSIVE_SEQUENCE(PROGRESSIVE_SEQUENCE),
     .v_topfldfst_r(v_topfldfst_r),
     .REPEAT_FIRST_FIELD(v_repfstfld_r),
     .clkdec(clkdec),
     .rstdec_x(rstdec_x),
     .g_swrst_r_n(g_swrst_r_n),
     .y1_bs_wait_n(y1_bs_wait_n),
     .v_interrpt_n(v_interrupt_r_n)
     );

wire v_cpxend_r,CPY_NERROR;

vld_copyrt vld_copyrt(
     .v_cpxend_r_s(v_cpxend_r),
     .NFERROR(CPY_NERROR),
     .CPR_SHIFT(CPR_SHIFT),
     .PARAA(CPY_PARAA),
     .v_cpxstrt_r_s(v_cpxstrt_r),
     .STREAM(STREAM[31:9]),
     .clkdec(clkdec),
     .rstdec_x(rstdec_x),
     .g_swrst_r_n(g_swrst_r_n),
     .y1_bs_wait_n(y1_bs_wait_n),
     .v_interrpt_n(v_interrupt_r_n)
     );

wire SLICE_END,v_slched_ferror;

vld_slched vld_slched(
     .ENDDEC(SLICE_END),
     .FERROR(v_slched_ferror),
     .SHIFT(SLC_SHIFT),
     .PARAA(SLC_PARAA),
     .KICK(v_slcstrt_r),
     .STREAM(STREAM[31:27]),
     .clkdec(clkdec),
     .rstdec_x(rstdec_x),
     .g_swrst_r_n(g_swrst_r_n),
     .y1_bs_wait_n(y1_bs_wait_n),
     .v_interrpt_n(v_interrupt_r_n)
     );
     
wire v_macblk_ferror,MAC_NERROR,v_mbintra_r,v_mbpl_vld_r;
wire v_blkstart_r,v_mbastrt_r;

vld_macblk vld_macblk(
     .v_mbhend_r_s(v_mbhend_r_s),
     .FERROR(v_macblk_ferror),
     .NFERROR(MAC_NERROR),
     .AFTER_INTRA(v_mbintra_r),
     .SHIFT(MAC_SHIFT),
     .CBP(v_cbp_r),
     .PARAA(MAC_PARAA),
     .PARAD(MAC_PARAD),
     .v_mbadet_r_s(v_mbadet_r),
     .v_blkstart_r_s(v_blkstart_r),
     .v_macstate_r(v_vldmstatus_r),
     .v_mbmot_type_r(v_mbmot_type_r),
     .clkdec(clkdec),
     .rstdec_x(rstdec_x),
     .g_swrst_r_n(g_swrst_r_n),
     .y1_bs_wait_n(y1_bs_wait_n),
     .v_interrpt_n(v_interrupt_r_n),
     .v_mbpl_vld_r(v_mbpl_vld_r),
     .v_mbastrt_r_s(v_mbastrt_r),
     .SLICE_END(SLICE_END),
     .FRAME_PRED_FRAME_DCT(v_fpredfdct_r),
     .CONCEALMENT_MOTION_VECTORS(v_consvec_r),
     .MPEG1(MPEG1),
     .FCODE_00(v_fcode_fwdh_r),
     .FCODE_01(v_fcode_fwdv_r),
     .FCODE_10(v_fcode_bwdh_r),
     .FCODE_11(v_fcode_bwdv_r),
     .PICTURE_CODING_TYPE(PIC_CODE_TYPE),
     .FORWARD_F_CODE(FWD_F_CODE),
     .BACKWARD_F_CODE(BWD_F_CODE),
     .PICTURE_STRUCTURE(PICTURE_STRUCTURE),
     .STREAM(STREAM[31:20])
     );

wire v_blkdat_ferror_r,BLK_NERROR,v_blkend_r;

vld_blkdat vld_blkdat(
     .v_vdoen_r(v_vdoen_r),
     .v_vdo_r(v_vdo_r),
     .FERROR(v_blkdat_ferror_r),
     .NFERROR(BLK_NERROR),
     .ENDBLK(v_blkend_r),
     .SHIFT(BLK_SHIFT),
     .clkdec(clkdec),
     .rstdec_x(rstdec_x),
     .g_swrst_r_n(g_swrst_r_n),
     .y1_bs_wait_n(y1_bs_wait_n),
     .v_interrpt_n(v_interrupt_r_n),
     .v_blkstart_r(v_blkstart_r),
     .v_enderror(v_enderror),
     .MACROBLOCK_INTRA(v_mbintra_r),
     .INTRA_VLC_FORMAT(v_intravlcfmt_r),
     .MPEG1(MPEG1),
     .PIC_CODE_TYPE(PIC_CODE_TYPE),
     .CBP(v_cbp_r),
     .STREAM(STREAM[31:2])
     );
  
vld_outbuf vld_outbuf(
     .v_ferror_r(v_ferror_r),
     .v_nferror_r(v_nferror_r),
     .v_paramdata_r(v_paramdata_r),
     .v_paramadr_r(v_paramadr_r),
     .clkdec(clkdec),
     .rstdec_x(rstdec_x),
     .g_swrst_r_n(g_swrst_r_n),
     .y1_bs_wait_n(y1_bs_wait_n),
     .SQH_FERROR(v_seqhed_ferror),
     .SQH_NERROR(SQH_NERROR),
     .SQX_NERROR(SQX_NERROR),
     .SQD_NERROR(SQD_NERROR),
     .GOP_NERROR(GOP_NERROR),
     .PHD_FERROR(v_piched_ferror),
     .PHD_NERROR(PIC_NERROR),
     .PCX_FERROR(v_piccod_ferror),
     .PCX_NERROR(PCX_NERROR),
     .PDX_NERROR(PDX_NERROR),
     .CPY_NERROR(CPY_NERROR),
     .SLC_FERROR(v_slched_ferror),
     .MAC_FERROR(v_macblk_ferror),
     .MAC_NERROR(MAC_NERROR),
     .BLK_FERROR(v_blkdat_ferror_r),
     .v_enderror(v_enderror),
     .BLK_NERROR(BLK_NERROR),
     .SCD_PARAA(SC_PARAA),
     .SQH_PARAA(SQH_PARAA),
     .SQX_PARAA(SQX_PARAA),
     .SQD_PARAA(SQD_PARAA),
     .USR_PARAA(USR_PARAA),
     .GOP_PARAA(GOP_PARAA),
     .PHD_PARAA(PIC_PARAA),
     .PCX_PARAA(PCX_PARAA),
     .PDX_PARAA(PDX_PARAA),
     .CPY_PARAA(CPY_PARAA),
     .SLC_PARAA(SLC_PARAA),
     .MAC_PARAA(MAC_PARAA),
     .STREAM(STREAM[31:7]),
     .MAC_PARAD(MAC_PARAD),
     .SCD_PARAD(SC_PARAD),
     .USR_PARAD(USR_PARAD),
     .PHD_PARAD(PIC_PARAD), 
     .PCX_PARAD(PCX_PARAD),
     .PDX_PARAD(PDX_PARAD)
     );
  
vld_vscdet vld_vscdet(
     .v_seqstrt_r(v_seqstrt_r),
     .v_sqxstrt_r(v_sqxstrt_r),
     .v_sdxstrt_r(v_sdxstrt_r),
     .v_ud0strt_r(v_ud0strt_r),
     .v_gopstrt_r(v_gopstrt_r),
     .v_ud1strt_r(v_ud1strt_r),
     .v_picstrt_r(v_picstrt_r),
     .v_pcxstrt_r(v_pcxstrt_r),
     .v_qmxstrt_r(v_qmxstrt_r),
     .v_pdxstrt_r(v_pdxstrt_r),
     .v_ud2strt_r(v_ud2strt_r),
     .v_cpxstrt_r(v_cpxstrt_r),
     .v_slcstrt_r(v_slcstrt_r),
     .v_mbastrt_r(v_mbastrt_r),
     .MPEG1(MPEG1),
     .v_vscdet_ferror_r(v_vscdet_ferror_r),
     .v_sferror_r(v_sferror_r),
     .v_slclverr_r(v_slclverr_r),
     .SCSHIFT(SCSHIFT),
     .PARAA(SC_PARAA),
     .PARAD(SC_PARAD),
     .v_interrupt_r_n(v_interrupt_r_n),
     .v_vldstatus_r(v_vldstatus_r),
     .v_mbpl_vld_r(v_mbpl_vld_r),
     .v_vldmode_r(v_vldmode_r),
     .clkdec(clkdec),
     .rstdec_x(rstdec_x),
     .g_swrst_r_n(g_swrst_r_n),
     .y1_bs_wait_n(y1_bs_wait_n),
     .g_vldmode_r(g_vldmode_r),
     .g_init_vld_r_s(g_init_vld_r_s),
     .c_skippic_r_s(c_skippic_r_s),
     .c_skipslc_r_s(c_skipslc_r_s),
     .v_seqerr(v_seqhed_ferror),
     .v_picerr(v_piched_ferror),
     .v_pcxerr(v_piccod_ferror),
     .v_slcerr(v_slched_ferror),
     .v_macerr(v_macblk_ferror),
     .v_blkerr_r(v_blkdat_ferror_r),
     .v_enderror(v_enderror),
     .SEQEOH(SEQEOH),
     .SQXEOH(SQXEOH),
     .SDXEOH(SDXEOH),
     .USDEOH(USDEOH),
     .GOPEOH(GOPEOH),
     .PICEOH(PICEOH),
     .PCXEOH(PCXEOH),
     .QMXEOH(QMXEOH),
     .PDXEOH(PDXEOH),
     .v_cpxend_r_s(v_cpxend_r),
     .SLICE_END(SLICE_END),
     .v_blkend_r_s(v_blkend_r),
     .UREGW(v1_bs_req_n),
     .UREG(UREG),
     .ADP(ADP),
     .STREAM(STREAM[31:8]),
     .c_mbpl_vld_r_s(c_mbpl_vld_r_s)
     );

vld_vlfeed vld_vlfeed(
     .STREAM(STREAM),
     .UREG(UREG),
     .ADP(ADP),
     .v1_bs_req_n(v1_bs_req_n),
     .clkdec(clkdec),
     .rstdec_x(rstdec_x),
     .g_swrst_r_n(g_swrst_r_n),
     .g_init_vld_r_s(g_init_vld_r_s),
     .y1_bs_data(y1_bs_data),
     .y1_bs_wait_n(y1_bs_wait_n),
     .SCSHIFT(SCSHIFT),
     .SEQ_SHIFT(SEQ_SHIFT),
     .SQX_SHIFT(SQX_SHIFT),
     .SDX_SHIFT(SDX_SHIFT),
     .USR_SHIFT(USR_SHIFT),
     .GOP_SHIFT(GOP_SHIFT),
     .PIC_SHIFT(PIC_SHIFT),
     .PDX_SHIFT(PDX_SHIFT),
     .PCX_SHIFT(PCX_SHIFT),
     .SLC_SHIFT(SLC_SHIFT),
     .MAC_SHIFT(MAC_SHIFT),
     .BLK_SHIFT(BLK_SHIFT),
     .CPR_SHIFT(CPR_SHIFT),
     .y1_bs_data_r(y1_bs_data_r)
     );
  
endmodule

