// ----------------------------------------------
// File: vld_rldecd.v
// Module: vld_rldecd
// Function:generate block data  from VLD
// ----------------------------------------------

module vld_rldecd(
                      NEXT_VDOSGN,
                      NEXT_VDO,
                      NEXT_RUN,
                      esc_next_run, 
                      NEXT_FERROR,
                      NEXT_NFERROR,
                      NEXT_HOLD_SIGN,
                      NEXT_HOLD_VDO,
                      VDOSGN,
                      VDO,
                      RUN,
                      FERROR,
                      NFERROR, 
                      clkdec,
                      rstdec_x,
                      g_swrst_r_n,
                      y1_bs_wait_n,
                      v_enderror,
                      v_out_enderror
                      );

  output [10:0] VDO;
  output [5:0]  RUN;
  output        VDOSGN;
  output        FERROR;
  output        NFERROR;
  output        v_out_enderror;

  input [10:0]  NEXT_VDO, NEXT_HOLD_VDO;
  input [5:0]   NEXT_RUN;
  input         NEXT_VDOSGN, NEXT_FERROR, NEXT_NFERROR, NEXT_HOLD_SIGN, 
                clkdec, rstdec_x, g_swrst_r_n, y1_bs_wait_n;
  input         v_enderror;
  input [5:0]   esc_next_run; 
  reg [10:0]    VDO;
  wire [10:0]   hold_vdo;
  reg [10:0]    hold_vdo_r;
  wire [5:0]    RUN;
  reg [5:0]     RUN_r;
  reg           VDOSGN;
  reg           v_ferror_wdly1_r; 
  reg           level_nferror_r;
  reg           NFERROR;
  wire          hold_sign;
  reg           hold_sign_r;
  reg           v_out_enderror;


  assign FERROR = v_ferror_wdly1_r; // output

  always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x)begin
          v_ferror_wdly1_r <= 1'b0;
          v_out_enderror <= 1'b0;
      end
      else if(!g_swrst_r_n)  begin // SW reset
          v_ferror_wdly1_r <= 1'b0;
          v_out_enderror <= 1'b0;
      end
      else if(y1_bs_wait_n) begin// no wait 
          v_ferror_wdly1_r <= NEXT_FERROR;
          v_out_enderror <= v_enderror;
      end
      else  begin
          v_ferror_wdly1_r <= v_ferror_wdly1_r;
          v_out_enderror <= v_out_enderror;
      end
  end

assign RUN = (v_ferror_wdly1_r) ? 6'd0 : RUN_r;
assign hold_vdo = (v_ferror_wdly1_r) ? 11'd0 : hold_vdo_r;
assign hold_sign = (v_ferror_wdly1_r) ? 1'b0 : hold_sign_r;

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        RUN_r <= 6'd0;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) // SW reset
          begin
            RUN_r <= 6'd0;
          end
        else if(y1_bs_wait_n == 1'b1) // no wait
          begin
            if(RUN != 6'd0) // RUN is not 0
              begin
                RUN_r <= RUN - 1'b1;
              end
            else if(NEXT_RUN != 6'd0) // next_RUN is not 0
              begin
                RUN_r <= NEXT_RUN;
              end
            else
              begin
                RUN_r <= RUN;
              end
          end
        else
          begin
            RUN_r <= RUN;
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        hold_vdo_r <= 11'd0;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            hold_vdo_r <= 11'd0;
          end
        else if(y1_bs_wait_n == 1'b1) // no wait
          begin
            if(NEXT_RUN != 6'd0 && RUN == 6'd0) 
              begin
                hold_vdo_r <= NEXT_HOLD_VDO;
              end
            else
              begin
                hold_vdo_r <= hold_vdo;
              end
          end
        else
          begin
            hold_vdo_r <= hold_vdo;
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0)
      begin
        hold_sign_r <= 1'b0;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0)
          begin
            hold_sign_r <= 1'b0;
          end
        else if(y1_bs_wait_n == 1'b1) // no wait
          begin
            if(NEXT_RUN != 6'd0 && RUN == 6'd0)
              begin
                hold_sign_r <= NEXT_HOLD_SIGN;
              end
            else
              begin
                hold_sign_r <= hold_sign;
              end
          end
        else 
          begin
            hold_sign_r <= hold_sign;
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)  begin
    if(rstdec_x == 1'b0) 
      level_nferror_r <= 1'b0;
    else if(g_swrst_r_n == 1'b0) 
      level_nferror_r <= 1'b0;
    else if(y1_bs_wait_n == 1'b1) // no wait
      if(RUN == 6'd0)begin
          if(esc_next_run != 6'd0)
            level_nferror_r <= NEXT_NFERROR;
          else
            level_nferror_r <= 1'b0; // clear if AC or (ESC & run=0)
      end
      else
        level_nferror_r <= level_nferror_r; // holds until level
    else 
      level_nferror_r <= level_nferror_r; // in wait
end
       
always @(posedge clkdec or negedge rstdec_x)  begin
    if(!rstdec_x) begin
        NFERROR <= 1'b0;
    end
    else begin
        if(g_swrst_r_n == 1'b0) begin
            NFERROR <= 1'b0;
        end
        else if(y1_bs_wait_n)begin 
            if((RUN == 6'd0)&(esc_next_run == 6'd0)) NFERROR <= NEXT_NFERROR;
            else if(RUN == 6'd1)NFERROR <= level_nferror_r; // last result
            else NFERROR <= 1'b0; // 0 run
        end
        else begin // wait
            NFERROR <= NFERROR;
        end
    end
end

  always @(posedge clkdec or negedge rstdec_x)
    if(!rstdec_x)
      VDO <= 11'd0;
    else if(g_swrst_r_n == 1'b0)
      VDO <= 11'd0;
    else
      if(y1_bs_wait_n) begin
          if(RUN == 6'd0)
            VDO <= NEXT_VDO; 
          else if(RUN == 6'd1)
            VDO <= hold_vdo; 
          else
            VDO <= 11'd0;
      end
      else begin
          VDO <= VDO;
      end

  always @(posedge clkdec or negedge rstdec_x)
    if(!rstdec_x)
      VDOSGN <= 1'b0;
    else if(g_swrst_r_n == 1'b0)
      VDOSGN <= 1'b0;
    else
      if(y1_bs_wait_n) begin
          if(RUN == 6'd0)
            VDOSGN <= NEXT_VDOSGN;
          else if(RUN == 6'd1)
            VDOSGN <= hold_sign;
          else
            VDOSGN <= 1'b0;
      end
      else begin
          VDOSGN <= VDOSGN;
      end


                
endmodule

