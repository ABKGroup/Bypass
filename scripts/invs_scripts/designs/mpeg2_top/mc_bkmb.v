// ----------------------------------------------
// File: mc_bkmb.v
// Module: mc_bkmb
// Function:Block to MB scan change memories block
// ----------------------------------------------

module mc_bkmb(
  m_mbpl_idct_out_r_s,
  m_mbpl_mc_r_s,
  m_frm_fidp_r,
  p_dct_typ_mc_r,
  t_idcto_r,
  p_idct_dis_mc_r,
  m_pred_dat_r,
  v1_bmb00_a,
  v1_bmb00_d,
  w1_bmb00_q,
  v1_bmb00_bs,
  v1_bmb00_we,
  v1_bmb01_a,
  v1_bmb01_d,
  w1_bmb01_q,
  v1_bmb01_bs,
  v1_bmb01_we,
  v1_bmb02_a,
  v1_bmb02_d,
  w1_bmb02_q,
  v1_bmb02_bs,
  v1_bmb02_we,
  rstdec_x,
  clkdec
);

    input        m_mbpl_idct_out_r_s;
    input        m_mbpl_mc_r_s;      
    input        m_frm_fidp_r;
    input        p_dct_typ_mc_r;
    input  [8:0] t_idcto_r;
    input        p_idct_dis_mc_r;
    input  [8:0] w1_bmb00_q;
    input  [8:0] w1_bmb01_q;
    input  [8:0] w1_bmb02_q;
    input        rstdec_x;
    input        clkdec;
    output [8:0] m_pred_dat_r;
    output [8:0] v1_bmb00_a;
    output [8:0] v1_bmb00_d;
    output       v1_bmb00_bs;
    output       v1_bmb00_we;
    output [8:0] v1_bmb01_a;
    output [8:0] v1_bmb01_d;
    output       v1_bmb01_bs;
    output       v1_bmb01_we;
    output [8:0] v1_bmb02_a;
    output [8:0] v1_bmb02_d;
    output       v1_bmb02_bs;
    output       v1_bmb02_we;

    reg [8:0] m_pred_dat_r;
    reg [8:0] v1_bmb00_a;
    reg [8:0] v1_bmb00_d;
    reg       v1_bmb00_bs;
    reg       v1_bmb00_we;
    reg [8:0] v1_bmb01_a;
    reg [8:0] v1_bmb01_d;
    reg       v1_bmb01_bs;
    reg       v1_bmb01_we;
    reg [8:0] v1_bmb02_a;
    reg [8:0] v1_bmb02_d;
    reg       v1_bmb02_bs;
    reg       v1_bmb02_we;
    reg [1:0] ff_mbpl_idct_out_r;
    reg [1:0] ff_mbpl_mc_r;
    reg       ff_frm_fidp_r;
    reg       ff_dct_typ_mc_r;
    reg [8:0] ff_idcto_r;
    reg [8:0] ff0_idcto_r;
    reg [8:0] ff1_idcto_r;
    reg [8:0] ff2_idcto_r;
    reg       ff_idct_dis_mc_r;
    reg [8:0] ff_bmb00_q_r;
    reg [8:0] ff_bmb01_q_r;
    reg [8:0] ff_bmb02_q_r;
    reg [1:0] in_selcnt_r;
    reg [1:0] out_selcnt_r;
    reg       wr_framedct_start_r;
    reg       wr_fielddct_start_r;
    reg       rd_normal_start_r;
    reg       rd_fst_start_r;
    reg [3:0] in_add_a_r;
    reg [2:0] in_add_b_r;
    reg [1:0] in_add_c_r;
    reg [3:0] fs_add_a_r;
    reg [3:0] fs_add_b_r;
    reg       fs_add_c_r;
    reg [3:0] out_add_a_r;
    reg [3:0] out_add_b_r;
    reg       out_add_c_r;
    reg [3:0] fd_add_a_r;
    reg [3:0] fd_add_b_r;
    reg       fd_add_c_r;
    reg [2:0] dly_out_selcnt_r;
    reg       wr_framedct_start0_r;
    reg       odd_even_r;
    reg       wr_fielddct_start0_r;
    reg [8:0] ff_idcto1_r;

    wire wr_framedct_clr_w;
    wire wr_fielddct_clr_w;
    wire wr_start_w;
    wire rd_normal_clr_w;
    wire rd_fst_clr_w;
    wire wr_count_up_w;
    wire rd_count_up_w;
    wire fdct_clr_w;
    wire wr_framedct_start1_w;
    wire feild_dct_clr_w;
    wire normal_clr_w;
    wire adr_set1_w;
    wire fst_clr_r;
    wire adr_bit_w;
    wire adr_clr_w;
    wire wr_framedct_start_w;
    wire wr_fielddct_start_w;
    wire wr_framedct0_bs_w;
    wire wr_framedct1_bs_w;
    wire wr_framedct2_bs_w;
    wire wr_fielddct0_bs_w;
    wire wr_fielddct1_bs_w;
    wire wr_fielddct2_bs_w;
    wire rd_normal0_bs_w;
    wire rd_normal1_bs_w;
    wire rd_normal2_bs_w;
    wire rd_fst0_bs_w;
    wire rd_fst1_bs_w;
    wire rd_fst2_bs_w;

   always @(posedge clkdec or negedge rstdec_x) begin
       if(!rstdec_x) begin
           ff_mbpl_idct_out_r <= 2'b00;
           ff_mbpl_mc_r     <= 2'b00;
           ff_frm_fidp_r    <= 0;
           ff_dct_typ_mc_r  <= 0;
           ff_idct_dis_mc_r <= 0;
           ff_bmb00_q_r <= 0;
           ff_bmb01_q_r <= 0;
           ff_bmb02_q_r <= 0;
       end
       else begin
           ff_mbpl_idct_out_r[0] <= m_mbpl_idct_out_r_s;
           ff_mbpl_idct_out_r[1] <= ff_mbpl_idct_out_r[0];
           ff_mbpl_mc_r[0] <= m_mbpl_mc_r_s;
           ff_mbpl_mc_r[1] <= ff_mbpl_mc_r[0];
           ff_frm_fidp_r <= m_frm_fidp_r;
           ff_dct_typ_mc_r <= p_dct_typ_mc_r;
           ff_idct_dis_mc_r <= p_idct_dis_mc_r;
           ff_bmb00_q_r <= w1_bmb00_q;
           ff_bmb01_q_r <= w1_bmb01_q;
           ff_bmb02_q_r <= w1_bmb02_q;
      end
   end

   always @(posedge clkdec or negedge rstdec_x) begin
       if(!rstdec_x) begin
           ff_idcto_r  <= 9'd0;
           ff0_idcto_r <= 9'd0;
           ff1_idcto_r <= 9'd0;
           ff2_idcto_r <= 9'd0;
       end
       else begin
           ff0_idcto_r <= t_idcto_r;
           ff1_idcto_r <= ff0_idcto_r;
           ff2_idcto_r <= ff1_idcto_r;
           ff_idcto_r  <= ff2_idcto_r;
      end
   end

  assign wr_framedct_clr_w = in_add_c_r[1] & ((in_add_b_r==3'd7)&(in_add_a_r==4'hf));
  assign  wr_fielddct_clr_w = fs_add_c_r & ((fs_add_b_r==4'h7)&(fs_add_a_r==4'hf));

  always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
         wr_framedct_start_r <= 1'b0;
         wr_fielddct_start_r <= 1'b0;
      end
      else begin
         if(!wr_framedct_clr_w && !wr_fielddct_clr_w) begin
            if(ff_mbpl_idct_out_r[1]==1'b1) begin
               if(ff_dct_typ_mc_r==1'b0) begin
                  wr_framedct_start_r <= 1'b1;
                  wr_fielddct_start_r <= 1'b0;
               end
               else begin
                  wr_framedct_start_r <= 1'b0;
                  wr_fielddct_start_r <= 1'b1;
               end
            end
            else begin
               wr_framedct_start_r <= wr_framedct_start_r;
               wr_fielddct_start_r <= wr_fielddct_start_r;
            end
         end
         else begin
            wr_framedct_start_r <= 1'b0;
            wr_fielddct_start_r <= 1'b0;
         end
      end
   end

   assign wr_start_w = wr_framedct_start_r | wr_fielddct_start_r;

   assign rd_normal_clr_w = out_add_c_r & ((out_add_b_r==4'h7)&(out_add_a_r==4'hf));
   assign rd_fst_clr_w = fd_add_c_r & ((fd_add_b_r==4'h7)&(fd_add_a_r==4'hf));

   always @(posedge clkdec or negedge rstdec_x) begin
     if(!rstdec_x) begin
        rd_normal_start_r <= 1'b0;
        rd_fst_start_r <= 1'b0;
     end
     else begin
        if(!rd_normal_clr_w && !rd_fst_clr_w) begin
           if(ff_mbpl_mc_r[1] && !ff_frm_fidp_r) begin
              rd_normal_start_r <= 1'b1;
              rd_fst_start_r <= 1'b0;
           end
           else if(ff_mbpl_mc_r[1] && ff_frm_fidp_r) begin
              rd_normal_start_r <= 1'b0;
              rd_fst_start_r <= 1'b1;
           end
        end
        else begin
           rd_normal_start_r <= 1'b0;
           rd_fst_start_r <= 1'b0;
        end
     end
  end

  assign wr_count_up_w = wr_framedct_clr_w | wr_fielddct_clr_w;

  always @(posedge clkdec or negedge rstdec_x) begin
       if(!rstdec_x)
           in_selcnt_r <= 2'd0;
       else begin
          if(wr_count_up_w==1'b1) begin
             if(in_selcnt_r == 2'd2)
                 in_selcnt_r <= 0;
             else
                 in_selcnt_r <= in_selcnt_r + 1;
          end
       end
   end
   
   assign rd_count_up_w = rd_normal_clr_w | rd_fst_clr_w;

   always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x)
         dly_out_selcnt_r <= 3'd0;
      else begin
         dly_out_selcnt_r[0] <= rd_count_up_w;
         dly_out_selcnt_r[1] <= dly_out_selcnt_r[0];
         dly_out_selcnt_r[2] <= dly_out_selcnt_r[1];
      end
   end

   always @(posedge clkdec or negedge rstdec_x) begin
       if(!rstdec_x)
           out_selcnt_r <= 0;
       else begin
          if(dly_out_selcnt_r[2]==1'b1) begin
             if(out_selcnt_r == 2'd2)
                out_selcnt_r <= 0;
             else
                out_selcnt_r <= out_selcnt_r + 1;
          end
       end
   end

   assign fdct_clr_w = ff_mbpl_idct_out_r[0] | wr_framedct_clr_w;
   always @(posedge clkdec or negedge rstdec_x) begin
       if(!rstdec_x)
           in_add_a_r <= 4'd0;
       else begin
          if(wr_framedct_start_r==1'b1 && fdct_clr_w==1'b0) begin
             if(in_add_c_r[1]) begin
                if(in_add_b_r[2:0]==3'd7)
                   in_add_a_r <= in_add_a_r + 1;
                else
                   in_add_a_r <= in_add_a_r;
             end
             else begin
                if(in_add_b_r==3'd7)
                   in_add_a_r <= in_add_a_r + 1;
                else
                   in_add_a_r <= in_add_a_r;
             end
          end
          else
              in_add_a_r <= 4'd0;
       end
   end

   always @(posedge clkdec or negedge rstdec_x) begin
       if(!rstdec_x)
           wr_framedct_start0_r <= 1'd0;
       else begin
          if(fdct_clr_w==1'b0)
             wr_framedct_start0_r <= wr_framedct_start_r;
          else
             wr_framedct_start0_r <= 1'd0;
       end
   end

   assign wr_framedct_start1_w = wr_framedct_start0_r & wr_framedct_start_r;

   always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x)
          in_add_b_r <= 3'd0;
      else begin
         if(wr_framedct_start1_w==1'b1 && fdct_clr_w==1'b0)
            in_add_b_r <= in_add_b_r + 1;
         else
            in_add_b_r <= 3'd0;
      end
   end

   always @(posedge clkdec or negedge rstdec_x)  begin
       if(!rstdec_x)
           in_add_c_r <= 2'd0;
       else begin
           if(wr_framedct_start_r==1'b1 && fdct_clr_w==1'b0) begin
              if((in_add_a_r==4'hf)&&(in_add_b_r==4'h7))
                 in_add_c_r <= in_add_c_r + 1;
              else
                 in_add_c_r <= in_add_c_r;
           end
           else
              in_add_c_r <= 2'd0;
       end
   end

   assign feild_dct_clr_w = ff_mbpl_idct_out_r[0] | wr_fielddct_clr_w;

   always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x)
         odd_even_r <= 1'b0;
      else begin
         if(((fs_add_a_r==4'hf)&&(fs_add_b_r==4'he)) && !odd_even_r)
            odd_even_r <= 1'b1;
         else if(((fs_add_a_r==4'hf)&&(fs_add_b_r==4'he)) && odd_even_r)
            odd_even_r <= 1'b0;
      end
   end

   always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x)
         fs_add_a_r <= 4'd0;
      else begin
         if(wr_fielddct_start_r==1'b1 && feild_dct_clr_w==1'b0) begin
            if(fs_add_c_r) begin
               if(fs_add_b_r==4'd7)
                  fs_add_a_r <= fs_add_a_r + 4'd1;
            end
            else if(fs_add_b_r==4'he)
               fs_add_a_r <= fs_add_a_r + 4'b1;
         end
         else
            fs_add_a_r <= 4'b0;
      end
   end

   always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x)
         wr_fielddct_start0_r <= 1'b0;
      else begin
         if(feild_dct_clr_w==1'b0)
            wr_fielddct_start0_r <= wr_fielddct_start_r;
         else
            wr_fielddct_start0_r <= 1'b0;
      end
   end

   always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x)
         fs_add_b_r <= 4'd0;
      else begin
         if(wr_fielddct_start0_r==1'b1 && feild_dct_clr_w==1'b0) begin
            if(fs_add_c_r) begin
               fs_add_b_r[3] <= fs_add_b_r[3];
               fs_add_b_r[2:0] <= fs_add_b_r[2:0] + 3'd1;
            end
            else
               fs_add_b_r <= fs_add_b_r + 4'd2;
         end
         else
            fs_add_b_r <= 4'd0;
      end
   end

   always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x)
         fs_add_c_r <= 1'd0;
      else begin
         if(wr_fielddct_start_r==1'b1 && feild_dct_clr_w==1'b0) begin
            if(odd_even_r && ((fs_add_b_r==4'he)&&(fs_add_a_r==4'hf)))
               fs_add_c_r <= 1'd1;
         end
         else
            fs_add_c_r <= 1'd0;
      end
   end

   assign normal_clr_w = ff_mbpl_mc_r[0] | rd_normal_clr_w;
   assign adr_set1_w = ((out_add_a_r[2:0]==3'd7)&(out_add_b_r==4'd7));

   always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x)
         out_add_a_r <= 4'd0;
      else begin
         if(rd_normal_start_r==1'b1 && normal_clr_w==1'b0) begin
            if(out_add_c_r) begin
               if(adr_set1_w) begin
                  out_add_a_r[3] <= 1'b1;
                  out_add_a_r[2:0] <= 3'b0;
               end
               else begin
                  out_add_a_r[3] <= out_add_a_r[3];
                  out_add_a_r[2:0] <= out_add_a_r[2:0] + 4'd1;
               end
            end
            else
               out_add_a_r <= out_add_a_r + 4'd1;
         end
         else
            out_add_a_r <= 4'd0;
      end
   end

   always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x)
          out_add_b_r <= 4'd0;
      else begin
         if(rd_normal_start_r==1'b1 && normal_clr_w==1'b0) begin
            if((out_add_a_r==4'hf) && !out_add_c_r)
               out_add_b_r <= out_add_b_r + 4'd1;
            else begin
               if((out_add_a_r[2:0]==3'h7) && out_add_c_r) begin
                  if(out_add_b_r==4'h7)
                     out_add_b_r <= 4'd0;
                  else
                     out_add_b_r <= out_add_b_r + 4'd1;
               end
            end
         end
         else
            out_add_b_r <= 4'd0;
      end
   end

   always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x)
         out_add_c_r <= 1'b0;
      else begin
         if(rd_normal_start_r==1'b1 && normal_clr_w==1'b0) begin
            if((out_add_b_r==4'hf)&&(out_add_a_r==4'hf))
               out_add_c_r <= 1'b1;
         end
         else
            out_add_c_r <= 1'b0;
      end
   end

   assign fst_clr_r = ff_mbpl_mc_r[0] | rd_fst_clr_w;

   always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x)
         fd_add_a_r <= 4'd0;
      else begin
         if(rd_fst_start_r==1'b1 && fst_clr_r==1'b0) begin
            if(fd_add_c_r) begin
               if((fd_add_a_r==4'h7)&&(fd_add_b_r==4'h7)) begin
                  fd_add_a_r[3] <= 1'b1;
                  fd_add_a_r[2:0] <= fd_add_a_r[2:0] + 3'd1;
               end
               else begin
                  fd_add_a_r[3] <= fd_add_a_r[3];
                  fd_add_a_r[2:0] <= fd_add_a_r[2:0] + 3'd1;
               end
            end
            else
               fd_add_a_r <= fd_add_a_r + 4'd1;
         end
         else
            fd_add_a_r <= 4'd0;
      end
   end

   always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x)
         fd_add_b_r <= 4'd0;
      else begin
         if(rd_fst_start_r==1'b1 && fst_clr_r==1'b0) begin
            if((fd_add_a_r==4'hf) && (!fd_add_c_r)) begin
               if(fd_add_b_r==4'he)
                  fd_add_b_r <= 4'h1;
               else if(fd_add_b_r==4'hf)
                  fd_add_b_r <= 4'h0;
               else
                  fd_add_b_r <= fd_add_b_r + 4'd2;
            end
            else begin
               if((fd_add_a_r[2:0]==3'h7) && fd_add_c_r) begin
                  if(((fd_add_b_r==4'h6)&&(fd_add_a_r[3]==1'b0)) ||
                     ((fd_add_b_r==4'h6)&&(fd_add_a_r[3]==1'b1))) begin
                     fd_add_b_r <= 4'd1;
                  end
                  else if((fd_add_b_r==4'h7)&&(fd_add_a_r[3]==1'b0))
                     fd_add_b_r <= 4'd0;
                  else
                     fd_add_b_r <= fd_add_b_r + 4'd2;
               end
            end
         end
         else
            fd_add_b_r <= 4'd0;
      end
   end

   always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x)
         fd_add_c_r <= 1'b0;
      else begin
         if(rd_fst_start_r==1'b1 && fst_clr_r==1'b0) begin
            if((fd_add_b_r==4'hf)&&(fd_add_a_r==4'hf))
               fd_add_c_r <= 1'b1;
         end
         else
            fd_add_c_r <= 1'b0;
      end
   end

   assign adr_bit_w = (odd_even_r & ~fs_add_c_r) | (fs_add_b_r[0] & fs_add_c_r);
   assign adr_clr_w = (ff_mbpl_idct_out_r[0] | ff_mbpl_mc_r[0]);
   assign wr_framedct_start_w = wr_framedct_start_r;
   assign wr_fielddct_start_w = wr_fielddct_start_r;

   always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x)
         v1_bmb00_a <= 9'd0;
      else begin
         if(!adr_clr_w) begin
            if(wr_framedct_start_w && (in_selcnt_r==2'd0))
               v1_bmb00_a <= {in_add_c_r,in_add_b_r,in_add_a_r};
            else if(wr_fielddct_start_w && (in_selcnt_r==2'd0))
               v1_bmb00_a <= {fs_add_c_r,fs_add_b_r[3:1],adr_bit_w,fs_add_a_r};
            else if(rd_normal_start_r && (out_selcnt_r==2'd0))
               v1_bmb00_a <= {out_add_c_r,out_add_b_r,out_add_a_r};
            else if(rd_fst_start_r && (out_selcnt_r==2'd0))
               v1_bmb00_a <= {fd_add_c_r,fd_add_b_r,fd_add_a_r};
            else
               v1_bmb00_a <= 9'd0;
         end
         else
            v1_bmb00_a <= 9'd0;
      end
   end

   always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x)
          v1_bmb01_a <= 9'd0;
      else begin
         if(!adr_clr_w) begin
            if(wr_framedct_start_w && (in_selcnt_r==2'd1))
               v1_bmb01_a <= {in_add_c_r,in_add_b_r,in_add_a_r};
            else if(wr_fielddct_start_w && (in_selcnt_r==2'd1))
               v1_bmb01_a <= {fs_add_c_r,fs_add_b_r[3:1],adr_bit_w,fs_add_a_r};
            else if(rd_normal_start_r && (out_selcnt_r==2'd1))
               v1_bmb01_a <= {out_add_c_r,out_add_b_r,out_add_a_r};
            else if(rd_fst_start_r & (out_selcnt_r==2'd1))
               v1_bmb01_a <= {fd_add_c_r,fd_add_b_r,fd_add_a_r};
            else
               v1_bmb01_a <= 9'd0;
         end else
            v1_bmb01_a <= 9'd0;
      end
   end

   always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x)
          v1_bmb02_a <= 9'd0;
      else begin
         if(!adr_clr_w) begin
            if(wr_framedct_start_w && (in_selcnt_r==2'd2))
               v1_bmb02_a <= {in_add_c_r,in_add_b_r,in_add_a_r};
            else if(wr_fielddct_start_w && (in_selcnt_r==2'd2))
               v1_bmb02_a <= {fs_add_c_r,fs_add_b_r[3:1],adr_bit_w,fs_add_a_r};
            else if(rd_normal_start_r && (out_selcnt_r==2'd2))
               v1_bmb02_a <= {out_add_c_r,out_add_b_r,out_add_a_r};
            else if(rd_fst_start_r && (out_selcnt_r==2'd2))
               v1_bmb02_a <= {fd_add_c_r,fd_add_b_r,fd_add_a_r};
            else
               v1_bmb02_a <= 9'd0;
         end
         else
           v1_bmb02_a <= 9'd0;
      end
   end

   always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x)
         ff_idcto1_r <= 9'd0;
      else
         ff_idcto1_r <= ff_idcto_r;
   end

   always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
         v1_bmb00_d <= 0;
         v1_bmb01_d <= 0;
         v1_bmb02_d <= 0;
      end
      else begin
         if((in_selcnt_r==2'd0) && wr_start_w==1'b1)begin
            v1_bmb00_d <= ff_idcto1_r;
            v1_bmb01_d <= 0;
            v1_bmb02_d <= 0;
         end
         else if((in_selcnt_r==2'd1) && wr_start_w==1'b1) begin
            v1_bmb01_d <= ff_idcto1_r;
            v1_bmb00_d <= 0;
            v1_bmb02_d <= 0;
         end
         else if((in_selcnt_r==2'd2) && wr_start_w==1'b1) begin
            v1_bmb02_d <= ff_idcto1_r;
            v1_bmb01_d <= 0;
            v1_bmb00_d <= 0;
         end
      end
   end

   assign wr_framedct0_bs_w = ((in_selcnt_r==2'd0) & wr_framedct_start_r);
   assign wr_framedct1_bs_w = ((in_selcnt_r==2'd1) & wr_framedct_start_r);
   assign wr_framedct2_bs_w = ((in_selcnt_r==2'd2) & wr_framedct_start_r);
   assign wr_fielddct0_bs_w = ((in_selcnt_r==2'd0) & wr_fielddct_start_r);
   assign wr_fielddct1_bs_w = ((in_selcnt_r==2'd1) & wr_fielddct_start_r);
   assign wr_fielddct2_bs_w = ((in_selcnt_r==2'd2) & wr_fielddct_start_r);
   assign rd_normal0_bs_w = ((out_selcnt_r==2'd0) & rd_normal_start_r);
   assign rd_normal1_bs_w = ((out_selcnt_r==2'd1) & rd_normal_start_r);
   assign rd_normal2_bs_w = ((out_selcnt_r==2'd2) & rd_normal_start_r);
   assign rd_fst0_bs_w = ((out_selcnt_r==2'd0) & rd_fst_start_r);
   assign rd_fst1_bs_w = ((out_selcnt_r==2'd1) & rd_fst_start_r);
   assign rd_fst2_bs_w = ((out_selcnt_r==2'd2) & rd_fst_start_r);

   always @(posedge clkdec or negedge rstdec_x)
   begin
       if(!rstdec_x) begin
           v1_bmb00_bs <= 0;
           v1_bmb01_bs <= 0;
           v1_bmb02_bs <= 0;
       end
       else  begin
           v1_bmb00_bs <= wr_framedct0_bs_w | wr_fielddct0_bs_w | rd_normal0_bs_w | rd_fst0_bs_w;
           v1_bmb01_bs <= wr_framedct1_bs_w | wr_fielddct1_bs_w | rd_normal1_bs_w | rd_fst1_bs_w;
           v1_bmb02_bs <= wr_framedct2_bs_w | wr_fielddct2_bs_w | rd_normal2_bs_w | rd_fst2_bs_w;
       end
   end

   always @(posedge clkdec or negedge rstdec_x) begin
       if(!rstdec_x) begin
           v1_bmb00_we <= 0;
           v1_bmb01_we <= 0;
           v1_bmb02_we <= 0;
       end
       else begin
           v1_bmb00_we <= ((in_selcnt_r == 2'd0) & wr_start_w);
           v1_bmb01_we <= ((in_selcnt_r == 2'd1) & wr_start_w);
           v1_bmb02_we <= ((in_selcnt_r == 2'd2) & wr_start_w);
       end
   end

   always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x)
          m_pred_dat_r <= 9'd0;
      else begin
          if(ff_idct_dis_mc_r)
              m_pred_dat_r <= 9'd0;
          else if(out_selcnt_r == 2'd0)
              m_pred_dat_r <= ff_bmb00_q_r;
          else if(out_selcnt_r == 2'd1)
              m_pred_dat_r <= ff_bmb01_q_r;
          else
              m_pred_dat_r <= ff_bmb02_q_r;
      end
   end

endmodule

