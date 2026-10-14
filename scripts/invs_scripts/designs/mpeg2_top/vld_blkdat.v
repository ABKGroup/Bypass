// ----------------------------------------------
// File: vld_blkdat.v
// Module: vld_blkdat
// Function:generate block top
// ----------------------------------------------

module vld_blkdat(
   clkdec, 
   rstdec_x, 
   g_swrst_r_n, 
   y1_bs_wait_n,
   v_interrpt_n, 
   v_blkstart_r, 
   MACROBLOCK_INTRA, 
   INTRA_VLC_FORMAT, 
   MPEG1, 
   PIC_CODE_TYPE, 
   CBP, 
   STREAM, 
   v_vdoen_r, 
   v_vdo_r, 
   FERROR, 
   NFERROR, 
   ENDBLK, 
   SHIFT, 
   v_enderror
);

input clkdec;          // VLD clock
input rstdec_x;        // Async reset
input g_swrst_r_n;       // Sync reset
input y1_bs_wait_n;        // Wait signal
input v_interrpt_n;      // Break singal
input v_blkstart_r;      // start decode
input MACROBLOCK_INTRA;    // macroblock_intra
input INTRA_VLC_FORMAT;    // intra_vlc_format
input MPEG1;               // 1:MPEG1, 0:MPEG2
input [2:0] PIC_CODE_TYPE; // picture_coding_type
input [5:0] CBP;           // coded_block_pattern
input [31:2] STREAM;       // bit staream(30bit)

output v_vdoen_r;      // index dataenable
output [11:0] v_vdo_r;   // index data
output FERROR;             // fatal error
output NFERROR;            // non-fatal error
output ENDBLK;             // end-decode
output [5:0] SHIFT;        // shift data
output v_enderror;       // end-of-macroblock error

wire [11:0] v_vdo_r;
reg [11:0] l_v_vdo_r;  
reg l_vdo_enb_r,
    v_vdoen_r,
    wait_sig_r;

wire [3:0] state,
           next_state;
wire [6:0] count_coeff;  
wire [2:0] block_count;
wire [5:0] run,
           next_run,
           AC_run,
           ESC_run;
wire [5:0] DC_SHIFT,
           AC_SHIFT,
           NUL_SHIFT,
           ESC_SHIFT;
wire next_FERROR,
     DC_FERROR,
     AC_FERROR;
wire next_NFERROR;
wire next_VDOSGN,
     AC_VDOSGN,
     ESC_VDOSGN,
     DC_VDOSGN,
     VDOSGN;
wire next_hold_sign,
     AC_hold_sign,
     ESC_hold_sign;
wire [10:0] VDO,
            next_VDO,
            AC_VDO,
            DC_VDO,
            ESC_VDO;
wire [10:0] next_hold_vdo,
            AC_hold_vdo,
            ESC_hold_vdo;
wire vdoenb;
wire v_enderror;
wire v_out_enderror;
wire ESC_FERROR;
wire STARTVLD_n;   
reg startvld_n_1;  
reg startvld_n_26; 

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0)
      begin
        startvld_n_1 <= 1'b1;   
      end
    else if(g_swrst_r_n == 1'b0)
      begin
        startvld_n_1 <= 1'b1;   
      end
   else if(y1_bs_wait_n == 1'b0) 
      begin
        startvld_n_1 <= startvld_n_1;
      end
    else if(v_interrpt_n == 1'b0) 
      begin
        startvld_n_1 <= 1'b1;
      end
    else
      begin
        startvld_n_1 <= ~v_blkstart_r;
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        startvld_n_26 <= 1'b1;
      end
    else if(g_swrst_r_n == 1'b0) 
      begin
        startvld_n_26 <= 1'b1;
      end
    else if(y1_bs_wait_n == 1'b0) 
      begin
        startvld_n_26 <= startvld_n_26;
      end
    else if(v_interrpt_n == 1'b0)
      begin
        startvld_n_26 <= 1'b1;
      end
    else if(count_coeff == 7'd64 && block_count >= 3'd1 
                                        && block_count < 3'd6) 
      begin                       
        startvld_n_26 <= 1'b0;
      end
    else
      begin
        startvld_n_26 <= 1'b1;
      end
  end
    
assign STARTVLD_n = startvld_n_1 & startvld_n_26;

     
vld_blksta vld_blksta( 
    .clkdec(clkdec), 
    .rstdec_x(rstdec_x),
    .g_swrst_r_n(g_swrst_r_n),
    .y1_bs_wait_n(y1_bs_wait_n), 
    .v_interrpt_n(v_interrpt_n), 
    .v_blkstart_r(v_blkstart_r),
    .MACROBLOCK_INTRA(MACROBLOCK_INTRA), 
    .INTRA_VLC_FORMAT(INTRA_VLC_FORMAT), 
    .MPEG1(MPEG1),
    .FERROR(FERROR), 
    .CBP(CBP), 
    .RUN(run), 
    .STREAM(STREAM[31:28]), 
    .PIC_CODE_TYPE(PIC_CODE_TYPE),
    .ENDBLK(ENDBLK), 
    .BLOCK_COUNT(block_count), 
    .COUNT_COEFF(count_coeff), 
    .STATE(state), 
    .NEXT_STATE(next_state), 
    .vdoenb_r(vdoenb),
    .v_enderror(v_out_enderror)
);

vld_nulsft vld_nulsft(
    .SHIFT(NUL_SHIFT), 
    .NEXT_STATE(next_state), 
    .STATE(state)
);

vld_dcshft vld_dcshft(
    .STREAM(STREAM[29:20]), 
    .SHIFT(DC_SHIFT), 
    .MPEG(MPEG1), 
    .BLOCK_COUNT(block_count),
    .NEXT_STATE(next_state)
);

vld_acshft vld_acshft(
    .STREAM(STREAM[31:16]), 
    .SHIFT(AC_SHIFT), 
    .RUN(run), 
    .STARTVLD(STARTVLD_n),
    .NEXT_STATE(next_state), 
    .COUNT_COEFF(count_coeff)
);

vld_escsft vld_escsft(
     .STREAM(STREAM[29:10]), 
     .SHIFT(ESC_SHIFT), 
     .MPEG(MPEG1), 
     .NEXT_STATE(next_state),
     .COUNT_COEFF(count_coeff), 
     .RUN(run)
);

vld_dcdecd vld_dcdecd(
     .STREAM(STREAM[31:11]), 
     .MPEG(MPEG1), 
     .BLOCK_COUNT(block_count),
     .NEXT_VDO(DC_VDO), 
     .NEXT_STATE(next_state),
     .NEXT_FERROR(DC_FERROR), 
     .NEXT_VDOSGN(DC_VDOSGN),
     .v_enderror(v_enderror)
); 

vld_acdecd vld_acdecd(
     .STREAM(STREAM[31:11]), 
     .STARTVLD(STARTVLD_n), 
     .NEXT_STATE(next_state), 
     .COUNT_COEFF(count_coeff),
     .NEXT_VDOSGN(AC_VDOSGN), 
     .NEXT_VDO(AC_VDO), 
     .NEXT_RUN(AC_run),
     .NEXT_FERROR(AC_FERROR), 
     .NEXT_HOLD_SIGN(AC_hold_sign),
     .NEXT_HOLD_VDO(AC_hold_vdo), 
     .RUN(run)
);

vld_escdec vld_escdec(
     .STREAM(STREAM), 
     .MPEG(MPEG1),
     .NEXT_STATE(next_state), 
     .COUNT_COEFF(count_coeff),
     .NEXT_VDOSGN(ESC_VDOSGN), 
     .NEXT_VDO(ESC_VDO), 
     .NEXT_RUN(ESC_run),
     .NEXT_FERROR(ESC_FERROR), 
     .NEXT_HOLD_SIGN(ESC_hold_sign),
     .NEXT_HOLD_VDO(ESC_hold_vdo), 
     .RUN(run), 
     .NEXT_NFERROR(next_NFERROR)
);

vld_rldecd vld_rldecd(
     .NEXT_VDOSGN(next_VDOSGN),
     .NEXT_VDO(next_VDO),
     .NEXT_RUN(next_run),
     .esc_next_run(ESC_run),
     .NEXT_FERROR(next_FERROR), 
     .NEXT_NFERROR(next_NFERROR),
     .NEXT_HOLD_SIGN(next_hold_sign), 
     .NEXT_HOLD_VDO(next_hold_vdo),
     .VDOSGN(VDOSGN),
     .VDO(VDO),
     .RUN(run), 
     .FERROR(FERROR),
     .NFERROR(NFERROR),
     .clkdec(clkdec),
     .rstdec_x(rstdec_x), 
     .g_swrst_r_n(g_swrst_r_n), 
     .y1_bs_wait_n(y1_bs_wait_n),
     .v_enderror(v_enderror),
     .v_out_enderror(v_out_enderror)
);

assign next_VDO = (DC_VDO | AC_VDO | ESC_VDO);
assign next_VDOSGN = (AC_VDOSGN | ESC_VDOSGN | DC_VDOSGN);
assign next_run = (AC_run | ESC_run);
assign next_FERROR = (DC_FERROR | AC_FERROR | ESC_FERROR);
assign next_hold_sign = (AC_hold_sign | ESC_hold_sign);
assign next_hold_vdo = (AC_hold_vdo | ESC_hold_vdo);

assign SHIFT = (DC_SHIFT | AC_SHIFT | ESC_SHIFT | NUL_SHIFT);

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0)
      begin
        l_v_vdo_r <= 12'h000;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0)
          begin
            l_v_vdo_r <= 12'h000;
          end
        else
          begin
            if(v_interrpt_n == 1'b1 && FERROR == 1'b0) 
              begin
                if(VDOSGN == 1'b0) 
                  begin
                    l_v_vdo_r <= {1'b0, VDO};
                  end
                else               
                  begin
                    l_v_vdo_r <= {1'b1,~VDO + 11'h001};
                  end
              end
            else
              begin
                l_v_vdo_r <= 12'h000;
              end
          end
      end
   end

assign v_vdo_r = l_v_vdo_r;

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        wait_sig_r <= 1'b1;
      end
    else if(g_swrst_r_n == 1'b0) 
      begin
        wait_sig_r <= 1'b1;
      end
    else
      begin
        wait_sig_r <= y1_bs_wait_n;
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        l_vdo_enb_r <= 1'b0;
      end
    else if(g_swrst_r_n == 1'b0)
      begin
        l_vdo_enb_r <= 1'b0;
      end
    else if(FERROR == 1'b1) 
      begin
        l_vdo_enb_r <= 1'b0;
      end
    else
      begin
        l_vdo_enb_r <= vdoenb;
      end
  end
 
always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0)
      begin
        v_vdoen_r <= 1'b0;
      end 
    else if(g_swrst_r_n == 1'b0)
      begin
        v_vdoen_r <= 1'b0;
      end
    else if(wait_sig_r == 1'b0)
      begin
        v_vdoen_r <= 1'b0;
      end
    else
      begin
        v_vdoen_r <= l_vdo_enb_r;
      end
   end
 
 
endmodule

