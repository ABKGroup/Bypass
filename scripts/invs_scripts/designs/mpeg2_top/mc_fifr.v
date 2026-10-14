// ----------------------------------------------
// File: mc_fifr.v
// Module: mc_fifr
// Function:vectol caluclation and select
// ----------------------------------------------

module mc_fifr(
  clkdec,
  rstdec_x,
  m_halfhdt_r,
  m_mbpl_mc_r_s,
  m_mbpl_uc_r_s,
  m_ref1yen_r,
  m_ref1cen_r,
  m_frm_inter_uc_r,
  m_frm_prog_uc_r,
  m_frm_pred_over_uc_r,
  m_frm_inter_mc_r,
  m_frm_prog_mc_r,
  m_frm_pred_over_mc_r,
  m_line17_cutf_r,
  p_pred_forward_buc_r,
  m_scan_even_r,
  m_scan_odd_r,
  m_line_sel_r,
  v1_ife00_a,
  v1_ife00_d,
  w1_ife00_q,
  v1_ife00_bs,
  v1_ife00_we,
  v1_ife01_a,
  v1_ife01_d,
  w1_ife01_q,
  v1_ife01_bs,
  v1_ife01_we,
  v1_ifo00_a,
  v1_ifo00_d,
  w1_ifo00_q,
  v1_ifo00_bs,
  v1_ifo00_we,
  v1_ifo01_a,
  v1_ifo01_d,
  w1_ifo01_q,
  v1_ifo01_bs,
  v1_ifo01_we,
  m_motion_dp_r
);
   input clkdec;
   input rstdec_x;
   input [17:0] m_halfhdt_r;
   input m_mbpl_mc_r_s; 
   input m_mbpl_uc_r_s; 
   input m_ref1yen_r;  
   input m_ref1cen_r;  
   input m_frm_inter_uc_r;
   input m_frm_prog_uc_r;
   input m_frm_pred_over_uc_r;
   input m_frm_inter_mc_r;
   input m_frm_prog_mc_r;
   input m_frm_pred_over_mc_r;
   input m_line17_cutf_r;
   input p_pred_forward_buc_r;
   input m_motion_dp_r;
   input [17:0] w1_ife00_q;
   input [17:0] w1_ife01_q;
   input [17:0] w1_ifo00_q;
   input [17:0] w1_ifo01_q;
   output [8:0] m_scan_even_r;
   output [8:0] m_scan_odd_r;
   output m_line_sel_r;
   output [6:0] v1_ife00_a;
   output [17:0] v1_ife00_d;
   output v1_ife00_bs;
   output v1_ife00_we;
   output [6:0] v1_ife01_a;
   output [17:0] v1_ife01_d;
   output v1_ife01_bs;
   output v1_ife01_we;
   output [6:0] v1_ifo00_a;
   output [17:0] v1_ifo00_d;
   output v1_ifo00_bs;
   output v1_ifo00_we;
   output [6:0] v1_ifo01_a;
   output [17:0] v1_ifo01_d;
   output v1_ifo01_bs;
   output v1_ifo01_we;

   reg [8:0] m_scan_even_r;
   reg [8:0] m_scan_odd_r;
   reg [6:0] v1_ife00_a;
   reg [17:0] v1_ife00_d;
   reg v1_ife00_bs;
   reg v1_ife00_we;
   reg [6:0] v1_ife01_a;
   reg [17:0] v1_ife01_d;
   reg v1_ife01_bs;
   reg v1_ife01_we;
   reg [6:0] v1_ifo00_a;
   reg [17:0] v1_ifo00_d;
   reg v1_ifo00_bs;
   reg v1_ifo00_we;
   reg [6:0] v1_ifo01_a;
   reg [17:0] v1_ifo01_d;
   reg v1_ifo01_bs;
   reg v1_ifo01_we;

   reg [17:0] ff_halfhdt_r;
   reg [1:0]ff_mbpl_mc_r;
   reg [1:0]ff_mbpl_uc_r;
   reg ff_ref1yen_r;
   reg ff_ref1cen_r;
   reg delay_ref1yen_r;
   reg delay_ref1cen_r;
   reg ff_frm_inter_uc_r;
   reg ff_frm_prog_uc_r;
   reg ff_frm_pred_over_uc_r;
   reg ff_frm_inter_mc_r;
   reg ff_frm_prog_mc_r;
   reg ff_frm_pred_over_mc_r;
   reg ff_line17_cutf_r;
   reg ff_pred_forward_buc_r;
   reg [17:0] ff_ife00_q_r;
   reg [17:0] ff_ife01_q_r;
   reg [17:0] ff_ifo00_q_r;
   reg [17:0] ff_ifo01_q_r;

   reg sel_input_r;
   reg sel_output_r;

   reg [3:0] cnt_iny_add0_r;
   reg [2:0] cnt_inc_add0_r;

   reg [3:0] cnt_outy_add0_r;
   reg [2:0] cnt_outc_add0_r;

   reg [5:0] cnt_line_r;    
   reg [4:0] rd_cnt_line_r; 
   reg [4:0] rd_a_adr_cnt_r;
   reg [4:0] rd_b_adr_cnt_r;

   reg [4:0] cnt_togle_w_r;

   reg sely_odd_even_r;
   reg selc_odd_even_r;

   reg wr_start_igai_r;     
   reg wr_start_interace_r; 
   reg wr_start_prog_r;     
   reg rd_start_igai_r;     
   reg rd_start_interace_r; 
   reg rd_start_prog_r;     

   reg line_up_r;           
   reg rd_line_up_r;        
   reg [4:0]prog_adr_w;
   reg [4:0]prog_adr1_w;
   reg y_line_varid_r;      
   reg c_line_varid_r;      
   reg y_line_rd_r;         
   reg c_line_rd_r;         
   reg dat_sel_r;           

   reg [6:0]adrcount;
   reg [6:0]adrcount_co;
   reg [6:0]wr_ife00_a_r;
   reg [6:0]rd_ife00_a_r;
   reg [6:0]wr_ife01_a_r;
   reg [6:0]rd_ife01_a_r;
   reg [6:0]wr_ifo00_a_r;
   reg [6:0]rd_ifo00_a_r;
   reg [6:0]wr_ifo01_a_r;
   reg [6:0]rd_ifo01_a_r;
   reg [17:0]wr_ife00_d_r;
   reg [17:0]wr_ifo00_d_r;
   reg [17:0]wr_ife01_d_r;
   reg [17:0]wr_ifo01_d_r;
   reg wr_ife00_bs_r;
   reg wr_ifo00_bs_r;
   reg wr_ife01_bs_r;
   reg wr_ifo01_bs_r;
   reg rd_ife00_bs_r;
   reg rd_ifo00_bs_r;
   reg rd_ife01_bs_r;
   reg rd_ifo01_bs_r;
   reg wr_ife00_we_r;
   reg wr_ifo00_we_r;
   reg wr_ife01_we_r;
   reg wr_ifo01_we_r;
   reg line_sel_r;
   reg[4:0]dly_line_r;
   reg [3:0]out_dat_sel_r;
   reg [3:0]dly_sel_output_r;
   reg [3:0]read_out_e_r;

   wire wr_start_clr_w;
   wire wr_start_w;
   wire rd_start_clr_w;
   wire rd_start_w;
   wire y_count_start_w;
   wire c_count_start_w;
   wire selc_odd_even_up_w;
   wire sely_odd_even_up_igai_w;
   wire sely_odd_even_up_interace_w;
   wire sely_odd_even_up_prog_w;
   wire sely_odd_even_up_w;
   wire selc_odd_even_up_igai_w;
   wire selc_odd_even_up_interace_w;
   wire selc_odd_even_up_prog_w;
   wire y_line_clr_w;
   wire togle_w;
   wire rd_y_cnt_start_w;
   wire rd_c_cnt_start_w;
   wire rd_y_line_clr_w;
   wire dat_sel_up_w;
   wire rd_cnt0_w;
   wire rd_cnt1_w;
   wire rd_cnt2_w;
   wire rd_cnt3_w;
   wire rd_cnt4_w;
   wire rd_cnt5_w;
   wire rd_cnt6_w;
   wire rd_cnt7_w;
   wire rd_cnt8_w;
   wire rd_cnt9_w;
   wire rd_cnt10_w;
   wire rd_cnt11_w;
   wire rd_cnt12_w;
   wire rd_cnt13_w;
   wire rd_cnt14_w;
   wire rd_cnt15_w;
   wire rd_cnt16_w;
   wire rd_cnt17_w;
   wire rd_cnt18_w;
   wire rd_cnt19_w;
   wire rd_cnt20_w;
   wire rd_cnt21_w;
   wire rd_cnt22_w;
   wire rd_cnt23_w;
   wire rd_cnt24_w;
   wire rd_cnt25_w;
   wire rd_cnt26_w;
   wire rd_cnt27_w;
   wire rd_cnt28_w;
   wire rd_cnt29_w;
   wire rd_cnt30_w;
   wire c_adr_load_w;
   wire up_a_igai_w;
   wire up_a_int_l17_w;
   wire up_a_int_h17_w;
   wire a_int_h17s_w;
   wire a_int_h17m1_w;
   wire a_int_h17m2_w;
   wire a_prog_l17_w;
   wire up_a_prog_h17_w;
   wire rd_a_up_w;
   wire up_b_igai_w;
   wire up_b_int_l17_w;
   wire b_int_l17_w;
   wire up_b_int_h17_w;
   wire b_prog_l17_w;
   wire up_b_prog_h17_w;
   wire rd_b_up_w;
   wire out_dat_sel_w;
   wire read_out_e_w;
   wire [8:0]even_datsel_a_w;
   wire [8:0] odd_datsel_a_w;
   wire [8:0]even_datsel_b_w;
   wire [8:0] odd_datsel_b_w;
   wire [8:0]e_datsel_line_w;
   wire [8:0]o_datsel_line_w;
   wire [8:0]rd_data_h_w;
   wire [8:0]rd_data_l_w;

   always @(posedge clkdec or negedge rstdec_x)
   begin
       if(!rstdec_x)
       begin
           ff_halfhdt_r <= 18'd0;
           ff_mbpl_mc_r <= 2'b00;
           ff_mbpl_uc_r <= 2'b00;
           ff_ref1yen_r <= 1'b0;
           ff_ref1cen_r <= 1'b0;
           delay_ref1yen_r <= 1'b0;
           delay_ref1cen_r <= 1'b0;
           ff_frm_inter_uc_r <= 1'b0;
           ff_frm_prog_uc_r  <= 1'b0;
           ff_frm_pred_over_uc_r <= 1'b0;
           ff_frm_inter_mc_r <= 1'b0;
           ff_frm_prog_mc_r  <= 1'b0;
           ff_frm_pred_over_mc_r <= 1'b0;
           ff_line17_cutf_r <= 1'b0;
           ff_pred_forward_buc_r <= 1'b0;
           ff_ife00_q_r <= 19'h00000;
           ff_ife01_q_r <= 19'h00000;
           ff_ifo00_q_r <= 19'h00000;
           ff_ifo01_q_r <= 19'h00000;
       end
       else
       begin
           ff_halfhdt_r <= m_halfhdt_r;
           ff_mbpl_mc_r[0] <= m_mbpl_mc_r_s;
           ff_mbpl_mc_r[1] <= ff_mbpl_mc_r[0];
           ff_mbpl_uc_r[0] <= m_mbpl_uc_r_s;
           ff_mbpl_uc_r[1] <= ff_mbpl_uc_r[0];
           delay_ref1yen_r <= m_ref1yen_r;
           delay_ref1cen_r <= m_ref1cen_r;
           ff_ref1yen_r <= delay_ref1yen_r;
           ff_ref1cen_r <= delay_ref1cen_r;
           ff_frm_inter_uc_r <= m_frm_inter_uc_r;
           ff_frm_prog_uc_r <= m_frm_prog_uc_r;
           ff_frm_pred_over_uc_r <= m_frm_pred_over_uc_r;
           ff_frm_inter_mc_r <= m_frm_inter_mc_r;
           ff_frm_prog_mc_r <= m_frm_prog_mc_r;
           ff_frm_pred_over_mc_r <= m_frm_pred_over_mc_r;
           ff_line17_cutf_r <= m_line17_cutf_r;
           ff_pred_forward_buc_r <= p_pred_forward_buc_r;
           ff_ife00_q_r <= w1_ife00_q;
           ff_ife01_q_r <= w1_ife01_q;
           ff_ifo00_q_r <= w1_ifo00_q;
           ff_ifo01_q_r <= w1_ifo01_q;
       end
   end

   assign wr_start_clr_w = (cnt_line_r==6'd37) & (cnt_inc_add0_r == 4'd4);

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         wr_start_igai_r <= 1'b0;
      end
      else
      begin
         if(wr_start_clr_w==1'b0)
         begin
            if(ff_mbpl_uc_r[1]==1'b1)
            begin
               if(ff_frm_pred_over_uc_r==1'b1)
               begin
                  wr_start_igai_r <= 1'b1;
               end
               else
               begin
                  wr_start_igai_r <= 1'b0;
               end
            end
            else
            begin
               wr_start_igai_r <= wr_start_igai_r;
            end
         end
         else
         begin
            wr_start_igai_r <= 1'b0;
         end
      end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         wr_start_interace_r <= 1'b0;
      end
      else
      begin
         if(wr_start_clr_w==1'b0)
         begin
            if(ff_mbpl_uc_r[1]==1'b1)
            begin
               if(ff_frm_inter_uc_r==1'b1)
               begin
                  wr_start_interace_r <= 1'b1;
               end
               else
               begin
                  wr_start_interace_r <= 1'b0;
               end
            end
            else
            begin
               wr_start_interace_r <= wr_start_interace_r;
            end
         end
         else
         begin
            wr_start_interace_r <= 1'b0;
         end
      end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         wr_start_prog_r <= 1'b0;
      end
      else
      begin
         if(wr_start_clr_w==1'b0)
         begin
            if(ff_mbpl_uc_r[1]==1'b1)
            begin
               if(ff_frm_prog_uc_r==1'b1)
               begin
                  wr_start_prog_r <= 1'b1;
               end
               else
               begin
                  wr_start_prog_r <= 1'b0;
               end
            end
            else
            begin
               wr_start_prog_r <= wr_start_prog_r;
            end
         end
         else
         begin
            wr_start_prog_r <= 1'b0;
         end
      end
   end

   assign wr_start_w = wr_start_igai_r | wr_start_interace_r | wr_start_prog_r;
   assign rd_start_clr_w = (rd_cnt_line_r==5'd31) & (cnt_outc_add0_r == 4'h7);

   always @(posedge clkdec or negedge rstdec_x)
   begin:READ_START_FRAME_YOSOKU_IGAI_FLAG
      if(!rstdec_x)
      begin
         rd_start_igai_r <= 1'b0;
         rd_start_interace_r <= 1'b0;
         rd_start_prog_r <= 1'b0;
      end
      else
      begin
         if((ff_pred_forward_buc_r ||  m_motion_dp_r) && !rd_start_clr_w)
         begin
            if(ff_mbpl_mc_r[1]==1'b1 && ff_frm_pred_over_mc_r==1'b1)
            begin
               rd_start_igai_r <= 1'b1;
               rd_start_interace_r <= 1'b0;
               rd_start_prog_r <= 1'b0;
            end
            else if(ff_mbpl_mc_r[1]==1'b1 && ff_frm_inter_mc_r==1'b1)
            begin
               rd_start_igai_r <= 1'b0;
               rd_start_interace_r <= 1'b1;
               rd_start_prog_r <= 1'b0;
            end
            else if(ff_mbpl_mc_r[1]==1'b1 && ff_frm_prog_mc_r==1'b1)
            begin
               rd_start_prog_r <= 1'b1;
               rd_start_igai_r <= 1'b0;
               rd_start_interace_r <= 1'b0;
            end
            else
            begin
               rd_start_igai_r     <= rd_start_igai_r;
               rd_start_interace_r <= rd_start_interace_r;
               rd_start_prog_r     <= rd_start_prog_r;
            end
         end
         else
         begin
            rd_start_igai_r <= 1'b0;
            rd_start_interace_r <= 1'b0;
            rd_start_prog_r <= 1'b0;
         end
      end
   end

   assign rd_start_w = rd_start_igai_r | rd_start_interace_r | rd_start_prog_r;

   assign y_count_start_w = wr_start_w & y_line_varid_r;

   always @(posedge clkdec or negedge rstdec_x) 
   begin:Y_DATA_COUNTER
      if(!rstdec_x)
      begin
          cnt_iny_add0_r <= 4'd0;
      end
      else
      begin
         if(ff_mbpl_uc_r[0]==1'b1)
         begin
             cnt_iny_add0_r <= 4'd0;
         end
         else
         begin
            if(y_count_start_w==1'b1)
            begin
               if(ff_ref1yen_r==1'b1)
               begin
                  if(cnt_iny_add0_r == 4'd8)
                  begin
                     cnt_iny_add0_r <= 4'd0;
                  end
                  else
                  begin
                     cnt_iny_add0_r <= cnt_iny_add0_r + 4'd1;
                  end
                end
               else
               begin
                  cnt_iny_add0_r <= cnt_iny_add0_r;
               end
            end
            else
            begin
               cnt_iny_add0_r <= 4'd0;
            end
         end
      end
   end

   always @(posedge clkdec or negedge rstdec_x) 
   begin:LINE_COUNT_UP
      if(!rstdec_x)
      begin
         line_up_r <= 1'b0;
      end
      else
      begin
         if(wr_start_w)
         begin
            line_up_r <= (cnt_iny_add0_r==4'd7)||(cnt_inc_add0_r==3'd3);
         end
         else
         begin
            line_up_r <= 1'b0;
         end
      end
   end

   assign c_count_start_w = wr_start_w & c_line_varid_r;

always @(posedge clkdec or negedge rstdec_x) begin
    if(!rstdec_x)
        cnt_inc_add0_r <= 3'd0;
    else begin
        if(c_count_start_w==1'b1) begin
            if(ff_ref1cen_r==1'b1) begin
                if(cnt_inc_add0_r == 3'd4)
                    cnt_inc_add0_r <= 3'd0;
                else
                    cnt_inc_add0_r <= cnt_inc_add0_r + 3'd1;
            end
        end
    end
end

   always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x)
      begin
         cnt_line_r <= 6'd0;
      end
      else
      begin
         if(line_up_r==1'b1)
         begin
            if(cnt_line_r==6'd37)
            begin
               cnt_line_r <= 6'd0;
            end
            else
            begin
               cnt_line_r <= cnt_line_r + 6'd1;
            end
         end
      end
   end

always @(posedge clkdec or negedge rstdec_x) begin
    if(!rstdec_x)
         adrcount <= 7'h00;
    else begin
        if(wr_start_interace_r) begin
            if(line_up_r==1'b1) begin
                if(y_line_varid_r && (adrcount==7'h08)) begin
                    if(sely_odd_even_r)
                       adrcount <= 7'h04;
                    else
                       adrcount <= 7'h00;
                end
                else if(c_line_varid_r && (adrcount==7'h0D))
                    adrcount <= 7'h09;
                else
                    adrcount <= adrcount + 7'd1;
            end
        end
        else
            adrcount <= 7'h00;
    end
end

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         adrcount_co <= 7'h00;
      end
      else
      begin
         if(wr_start_interace_r)
         begin
            if(line_up_r==1'b1)
            begin
               if(c_line_varid_r && (adrcount==7'h08))
               begin
                  if(selc_odd_even_up_w)
                  begin
                     adrcount_co <= 7'h04;
                  end
                  else
                  begin
                     adrcount_co <= 7'h00;
                  end
               end
               else if(c_line_varid_r && (adrcount_co==7'h0D))
               begin
                  adrcount_co <= 7'h09;
               end
               else
               begin
                  adrcount_co <= adrcount_co + 7'd1;
               end
            end
         end
         else
         begin
            adrcount_co <= 7'h00;
         end
      end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         sel_input_r <= 0;
      end
      else
      begin
         if(wr_start_clr_w==1'b1)
         begin
            sel_input_r <= ~sel_input_r;
         end
         else
         begin
            sel_input_r <=  sel_input_r;
         end
      end
   end

   assign sely_odd_even_up_igai_w = wr_start_igai_r & 
        (cnt_iny_add0_r==4'd8) & !((cnt_line_r==6'd8)|(cnt_line_r==6'd17));
   assign sely_odd_even_up_interace_w = wr_start_interace_r & 
        (cnt_iny_add0_r==4'd8) & ((cnt_line_r==6'd8)|(cnt_line_r==6'd17));
   assign sely_odd_even_up_prog_w = wr_start_prog_r & (cnt_iny_add0_r==4'd8);
   assign sely_odd_even_up_w = sely_odd_even_up_igai_w | sely_odd_even_up_interace_w |  sely_odd_even_up_prog_w;

   always @(posedge clkdec or negedge rstdec_x)
   begin
       if(!rstdec_x) 
           sely_odd_even_r <= 0;
       else
       begin
          if(ff_mbpl_uc_r[0] || wr_start_clr_w)
          begin
              sely_odd_even_r <= 0;
          end
          else
          begin
             if(ff_ref1yen_r==1'b1)
             begin
                if(wr_start_w==1'b1 && sely_odd_even_up_w== 1'b1)
                begin
                   sely_odd_even_r <= ~sely_odd_even_r;
                end
             end
             else
             begin
                sely_odd_even_r <= sely_odd_even_r;
             end
          end
       end
   end


   assign selc_odd_even_up_igai_w = wr_start_igai_r & 
        (cnt_inc_add0_r == 3'd4) & !((cnt_line_r==6'd22)|(cnt_line_r==6'd27)||(cnt_line_r==6'd32));
   assign selc_odd_even_up_interace_w = wr_start_interace_r & (cnt_inc_add0_r == 3'd4) & 
        ((cnt_line_r==6'd22)|(cnt_line_r==6'd32)|(cnt_line_r==6'd27)|(cnt_line_r==6'd37));
   assign selc_odd_even_up_prog_w = wr_start_prog_r & (cnt_inc_add0_r == 3'd4);
   assign selc_odd_even_up_w = selc_odd_even_up_igai_w | selc_odd_even_up_interace_w | selc_odd_even_up_prog_w;

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
          selc_odd_even_r <= 0;
      end
      else
      begin
         if(ff_mbpl_uc_r[0] || wr_start_clr_w)
         begin
             selc_odd_even_r <= 0;
         end
         else
         begin
            if(wr_start_w==1'b1 && selc_odd_even_up_w== 1'b1)
            begin
               selc_odd_even_r <= ~selc_odd_even_r;
            end
         end
      end
   end

   assign y_line_clr_w = (cnt_iny_add0_r==4'd8)&(cnt_line_r==6'd17);

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         y_line_varid_r <= 1'b0;
         c_line_varid_r <= 1'b0;
      end
      else
      begin
         if(wr_start_clr_w==1'b0)
         begin
            if(ff_mbpl_uc_r[1])
            begin
               y_line_varid_r <= 1'b1;
               c_line_varid_r <= 1'b0;
            end
            else
            begin
               if(y_line_clr_w==1'b1)
               begin
                  y_line_varid_r <= 1'b0;
                  c_line_varid_r <= 1'b1;
               end
               else
               begin
                  y_line_varid_r <= y_line_varid_r;
                  c_line_varid_r <= c_line_varid_r;
               end
            end
         end
         else
         begin
            y_line_varid_r <= 1'b0;
            c_line_varid_r <= 1'b0;
         end
      end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         sel_output_r <= 0;
      end
      else
      begin
         if(rd_start_clr_w==1'b1)
         begin
            sel_output_r <= ~sel_output_r;
         end
         else
         begin
            sel_output_r <=  sel_output_r;
         end
      end
   end

   assign rd_y_cnt_start_w = rd_start_w & y_line_rd_r;

   always @(posedge clkdec or negedge rstdec_x) 
   begin:RD_Y_DATA_COUNTER
      if(!rstdec_x)
      begin
          cnt_outy_add0_r <= 4'd0;
      end
      else
      begin
         if(ff_mbpl_mc_r[0] || !(ff_pred_forward_buc_r ||  m_motion_dp_r))
         begin
             cnt_outy_add0_r <= 4'd0;
         end
         else
         begin
            if(rd_y_cnt_start_w==1'b1)
            begin
               if(cnt_outy_add0_r == 4'd15)
               begin
                  cnt_outy_add0_r <= 4'd0;
               end
               else
               begin
                  cnt_outy_add0_r <= cnt_outy_add0_r + 4'd1;
               end
            end
            else
            begin
               cnt_outy_add0_r <= 4'd0;
            end
         end
      end
   end

   assign rd_c_cnt_start_w = rd_start_w & c_line_rd_r;

   always @(posedge clkdec or negedge rstdec_x) 
   begin:RD_C_DATA_COUNTER
      if(!rstdec_x)
      begin
          cnt_outc_add0_r <= 3'd0;
      end
      else
      begin
         if(rd_c_cnt_start_w==1'b1)
         begin
            if(cnt_outc_add0_r == 3'd7)
            begin
               cnt_outc_add0_r <= 3'd0;
            end
            else
            begin
               cnt_outc_add0_r <= cnt_outc_add0_r + 3'd1;
            end
         end
         else
         begin
            cnt_outc_add0_r <= 3'd0;
         end
      end
   end


   always @(posedge clkdec or negedge rstdec_x) 
   begin:RD_LINE_COUNT_UP
      if(!rstdec_x)
      begin
         rd_line_up_r <= 1'b0;
      end
      else
      begin
         if(rd_start_w)
         begin
            rd_line_up_r <= (cnt_outy_add0_r==4'd14)|(cnt_outc_add0_r==3'd6);
         end
         else
         begin
            rd_line_up_r <= 1'b0;
         end
      end
   end

   always @(posedge clkdec or negedge rstdec_x) 
   begin:RD_LINE_COUNT
      if(!rstdec_x)
      begin
         rd_cnt_line_r <= 5'd0;
      end
      else
      begin
         if(!ff_mbpl_mc_r[0])
         begin
            if(rd_line_up_r)
            begin
               if(rd_cnt_line_r==5'd31)
               begin
                  rd_cnt_line_r <= 5'd0;
               end
               else
               begin
                  rd_cnt_line_r <= rd_cnt_line_r + 5'd1;
               end
            end
         end
         else
         begin
            rd_cnt_line_r <= 5'd0;
         end
      end
   end

   assign rd_y_line_clr_w = (cnt_outy_add0_r==4'hf)&(rd_cnt_line_r==5'd15);

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         y_line_rd_r <= 1'b0;
         c_line_rd_r <= 1'b0;
      end
      else
      begin
         if(!rd_start_clr_w || ff_mbpl_mc_r[0])
         begin
            if(ff_mbpl_mc_r[1])
            begin
               y_line_rd_r <= 1'b1;
               c_line_rd_r <= 1'b0;
            end
            else
            begin
               if(rd_y_line_clr_w==1'b1)
               begin
                  y_line_rd_r <= 1'b0;
                  c_line_rd_r <= 1'b1;
               end
               else
               begin
                  y_line_rd_r <= y_line_rd_r;
                  c_line_rd_r <= c_line_rd_r;
               end
            end
         end
         else
         begin
            y_line_rd_r <= 1'b0;
            c_line_rd_r <= 1'b0;
         end
      end
   end

   assign dat_sel_up_w = (((cnt_outy_add0_r==4'h7)|(cnt_outy_add0_r==4'hf)) & y_line_rd_r) | 
        (((cnt_outc_add0_r==4'h3)|(cnt_outc_add0_r==4'h7)) & c_line_rd_r);

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         dat_sel_r <= 1'b0;
      end
      else
      begin
         if(!ff_mbpl_mc_r[0])
         begin
            if(dat_sel_up_w)
            begin
               dat_sel_r <= ~dat_sel_r;
            end
            else
            begin
               dat_sel_r <= dat_sel_r;
            end
         end
      end
   end

   assign rd_cnt0_w = (rd_cnt_line_r==5'd0);
   assign rd_cnt1_w = (rd_cnt_line_r==5'd1);
   assign rd_cnt2_w = (rd_cnt_line_r==5'd2);
   assign rd_cnt3_w = (rd_cnt_line_r==5'd3);
   assign rd_cnt4_w = (rd_cnt_line_r==5'd4);
   assign rd_cnt5_w = (rd_cnt_line_r==5'd5);
   assign rd_cnt6_w = (rd_cnt_line_r==5'd6);
   assign rd_cnt7_w = (rd_cnt_line_r==5'd7);
   assign rd_cnt8_w = (rd_cnt_line_r==5'd8);
   assign rd_cnt9_w = (rd_cnt_line_r==5'd9);
   assign rd_cnt10_w = (rd_cnt_line_r==5'd10);
   assign rd_cnt11_w = (rd_cnt_line_r==5'd11);
   assign rd_cnt12_w = (rd_cnt_line_r==5'd12);
   assign rd_cnt13_w = (rd_cnt_line_r==5'd13);
   assign rd_cnt14_w = (rd_cnt_line_r==5'd14);
   assign rd_cnt15_w = (rd_cnt_line_r==5'd15);
   assign rd_cnt16_w = (rd_cnt_line_r==5'd16);
   assign rd_cnt17_w = (rd_cnt_line_r==5'd17);
   assign rd_cnt18_w = (rd_cnt_line_r==5'd18);
   assign rd_cnt19_w = (rd_cnt_line_r==5'd19);
   assign rd_cnt20_w = (rd_cnt_line_r==5'd20);
   assign rd_cnt21_w = (rd_cnt_line_r==5'd21);
   assign rd_cnt22_w = (rd_cnt_line_r==5'd22);
   assign rd_cnt23_w = (rd_cnt_line_r==5'd23);
   assign rd_cnt24_w = (rd_cnt_line_r==5'd24);
   assign rd_cnt25_w = (rd_cnt_line_r==5'd25);
   assign rd_cnt26_w = (rd_cnt_line_r==5'd26);
   assign rd_cnt27_w = (rd_cnt_line_r==5'd27);
   assign rd_cnt28_w = (rd_cnt_line_r==5'd28);
   assign rd_cnt29_w = (rd_cnt_line_r==5'd29);
   assign rd_cnt30_w = (rd_cnt_line_r==5'd30);

   assign c_adr_load_w = rd_cnt15_w & togle_w;
   assign up_a_igai_w = rd_start_igai_r & togle_w & 
   (rd_cnt0_w|rd_cnt2_w|rd_cnt4_w|rd_cnt6_w|rd_cnt7_w|rd_cnt8_w|rd_cnt10_w|rd_cnt12_w|
    rd_cnt14_w|rd_cnt15_w|rd_cnt16_w|rd_cnt18_w|rd_cnt19_w|rd_cnt20_w|rd_cnt22_w|rd_cnt23_w|
    rd_cnt24_w|rd_cnt26_w|rd_cnt27_w|rd_cnt28_w|rd_cnt30_w);
   assign up_a_int_l17_w = rd_start_interace_r & ~ff_line17_cutf_r & togle_w & 
   (rd_cnt0_w|rd_cnt2_w|rd_cnt4_w|rd_cnt6_w|rd_cnt8_w|rd_cnt10_w|rd_cnt12_w|rd_cnt14_w|
    rd_cnt15_w|rd_cnt16_w|rd_cnt18_w|rd_cnt20_w|rd_cnt22_w|rd_cnt23_w|rd_cnt24_w|rd_cnt26_w|
    rd_cnt28_w|rd_cnt30_w);
   assign up_a_int_h17_w = rd_start_interace_r & ff_line17_cutf_r & togle_w & 
   (rd_cnt1_w|rd_cnt3_w|rd_cnt5_w|rd_cnt7_w|rd_cnt9_w|rd_cnt11_w|rd_cnt13_w|
    rd_cnt17_w|rd_cnt19_w|rd_cnt21_w|rd_cnt25_w|rd_cnt27_w|rd_cnt29_w);
   assign a_int_h17s_w = (ff_mbpl_mc_r[1] & ff_frm_inter_mc_r & ff_line17_cutf_r) |
   (ff_mbpl_mc_r[1] & ff_frm_prog_mc_r & ff_line17_cutf_r);
   assign a_int_h17m1_w = (rd_start_interace_r & ff_line17_cutf_r & togle_w & rd_cnt15_w) |
   (rd_start_prog_r & ff_line17_cutf_r & togle_w & rd_cnt15_w);
   assign a_int_h17m2_w = (rd_start_interace_r & ff_line17_cutf_r & togle_w & rd_cnt23_w) | 
   (rd_start_prog_r & ff_line17_cutf_r & togle_w & rd_cnt23_w);
   assign a_prog_l17_w = rd_start_prog_r & ~ff_line17_cutf_r & togle_w &
   (rd_cnt0_w|rd_cnt2_w|rd_cnt4_w|rd_cnt6_w|rd_cnt8_w|rd_cnt10_w|rd_cnt12_w|rd_cnt14_w|
    rd_cnt16_w|rd_cnt18_w|rd_cnt20_w|rd_cnt22_w|rd_cnt23_w|rd_cnt24_w|rd_cnt26_w|rd_cnt28_w|rd_cnt30_w);
   assign up_a_prog_h17_w = rd_start_prog_r & ff_line17_cutf_r & togle_w & 
   (rd_cnt1_w|rd_cnt3_w|rd_cnt5_w|rd_cnt7_w|rd_cnt9_w|rd_cnt11_w|rd_cnt13_w|
    rd_cnt17_w|rd_cnt19_w|rd_cnt21_w|rd_cnt25_w|rd_cnt27_w|rd_cnt29_w);
   assign rd_a_up_w = up_a_igai_w | up_a_int_l17_w | up_a_int_h17_w | a_prog_l17_w | up_a_prog_h17_w;

   always @(posedge clkdec or negedge rstdec_x) 
   begin:READ_ODD_ADDRESS_MAKE_UP
      if(!rstdec_x)
      begin
         rd_a_adr_cnt_r <= 5'd0;
      end
      else
      begin
         if(a_int_h17s_w)
         begin
            rd_a_adr_cnt_r <= 5'h01;
         end
         else if(!ff_mbpl_mc_r[1] && rd_start_w && !rd_start_clr_w)
         begin
            if(a_int_h17m1_w)
            begin
               rd_a_adr_cnt_r <= 5'h15;
            end
            else if(a_int_h17m2_w)
            begin
               rd_a_adr_cnt_r <= 5'h1a;
            end
            else if(c_adr_load_w)
            begin
               rd_a_adr_cnt_r <= 5'h14;
            end
            else if(rd_a_up_w)
            begin
               rd_a_adr_cnt_r <= rd_a_adr_cnt_r + 5'd1;
            end
            else
            begin
               rd_a_adr_cnt_r <= rd_a_adr_cnt_r;
            end
         end
         else
         begin
            rd_a_adr_cnt_r <= 5'd0;
         end
      end
   end

   assign up_b_igai_w = rd_start_igai_r & togle_w & 
   (rd_cnt1_w|rd_cnt3_w|rd_cnt5_w|rd_cnt7_w|rd_cnt9_w|rd_cnt11_w|rd_cnt13_w|rd_cnt15_w|
    rd_cnt17_w|rd_cnt19_w|rd_cnt21_w|rd_cnt23_w|rd_cnt25_w|rd_cnt27_w|rd_cnt29_w);
   assign up_b_int_l17_w = rd_start_interace_r & ~ff_line17_cutf_r & togle_w & 
   (rd_cnt1_w|rd_cnt3_w|rd_cnt5_w|rd_cnt7_w|rd_cnt9_w|rd_cnt11_w|rd_cnt13_w|rd_cnt15_w|
    rd_cnt17_w|rd_cnt19_w|rd_cnt21_w|rd_cnt25_w|rd_cnt27_w|rd_cnt29_w);
   assign b_int_l17_w = (rd_start_interace_r | rd_start_prog_r) & ~ff_line17_cutf_r & rd_cnt23_w & togle_w;
   assign up_b_int_h17_w = rd_start_interace_r & ff_line17_cutf_r & togle_w & 
   (rd_cnt0_w|rd_cnt2_w|rd_cnt4_w|rd_cnt6_w|rd_cnt8_w|rd_cnt10_w|rd_cnt12_w|
    rd_cnt14_w|rd_cnt16_w|rd_cnt18_w|rd_cnt20_w|rd_cnt22_w|rd_cnt23_w|rd_cnt24_w|
    rd_cnt26_w|rd_cnt28_w|rd_cnt30_w);
   assign b_prog_l17_w = rd_start_prog_r & ~ff_line17_cutf_r & togle_w &
   (rd_cnt1_w|rd_cnt3_w|rd_cnt5_w|rd_cnt7_w|rd_cnt9_w|rd_cnt11_w|rd_cnt13_w|
    rd_cnt17_w|rd_cnt19_w|rd_cnt21_w|rd_cnt25_w|rd_cnt27_w|rd_cnt29_w);
   assign up_b_prog_h17_w = rd_start_prog_r & ff_line17_cutf_r & togle_w & 
   (rd_cnt0_w|rd_cnt2_w|rd_cnt4_w|rd_cnt6_w|rd_cnt8_w|rd_cnt10_w|rd_cnt12_w|
    rd_cnt14_w|rd_cnt16_w|rd_cnt18_w|rd_cnt20_w|rd_cnt22_w|rd_cnt23_w|rd_cnt24_w|
    rd_cnt26_w|rd_cnt28_w|rd_cnt30_w);
   assign rd_b_up_w = up_b_igai_w | up_b_int_l17_w | up_b_int_h17_w | b_prog_l17_w | up_b_prog_h17_w;

   always @(posedge clkdec or negedge rstdec_x) 
   begin:READ_EVEN_ADDRESS_MAKE_UP
      if(!rstdec_x)
      begin
         rd_b_adr_cnt_r <= 5'd0;
      end
      else
      begin
         if(!ff_mbpl_mc_r[1] && rd_start_w && !rd_start_clr_w)
         begin
            if(c_adr_load_w)
            begin
               rd_b_adr_cnt_r <= 5'h14;
            end
            else if(b_int_l17_w)
            begin
               rd_b_adr_cnt_r <= 5'h19;
            end
            else if(rd_b_up_w)
            begin
               rd_b_adr_cnt_r <= rd_b_adr_cnt_r + 5'd1;
            end
            else
            begin
               rd_b_adr_cnt_r <= rd_b_adr_cnt_r;
            end
         end
         else
         begin
            rd_b_adr_cnt_r <= 5'd0;
         end
      end
   end


   always @(cnt_line_r or wr_start_igai_r)
   begin
      if(wr_start_igai_r)
      begin
         case(cnt_line_r)
            6'd0:  prog_adr_w = 5'h00;
            6'd1:  prog_adr_w = 5'h00;
            6'd2:  prog_adr_w = 5'h01;
            6'd3:  prog_adr_w = 5'h01;
            6'd4:  prog_adr_w = 5'h02;
            6'd5:  prog_adr_w = 5'h02;
            6'd6:  prog_adr_w = 5'h03;
            6'd7:  prog_adr_w = 5'h03;
            6'd8:  prog_adr_w = 5'h04;
            6'd9:  prog_adr_w = 5'h05;
            6'd10: prog_adr_w = 5'h04;
            6'd11: prog_adr_w = 5'h06;
            6'd12: prog_adr_w = 5'h05;
            6'd13: prog_adr_w = 5'h07;
            6'd14: prog_adr_w = 5'h06;
            6'd15: prog_adr_w = 5'h08;
            6'd16: prog_adr_w = 5'h07;
            6'd17: prog_adr_w = 5'h09;
          default: prog_adr_w = 5'h00;
         endcase
      end
      else
      begin
         case(cnt_line_r)
            6'd0:  prog_adr_w = 5'h00;
            6'd1:  prog_adr_w = 5'h00;
            6'd2:  prog_adr_w = 5'h01;
            6'd3:  prog_adr_w = 5'h01;
            6'd4:  prog_adr_w = 5'h02;
            6'd5:  prog_adr_w = 5'h02;
            6'd6:  prog_adr_w = 5'h03;
            6'd7:  prog_adr_w = 5'h03;
            6'd8:  prog_adr_w = 5'h04;
            6'd9:  prog_adr_w = 5'h04;
            6'd10: prog_adr_w = 5'h05;
            6'd11: prog_adr_w = 5'h05;
            6'd12: prog_adr_w = 5'h06;
            6'd13: prog_adr_w = 5'h06;
            6'd14: prog_adr_w = 5'h07;
            6'd15: prog_adr_w = 5'h07;
            6'd16: prog_adr_w = 5'h08;
            6'd17: prog_adr_w = 5'h08;
          default: prog_adr_w = 5'h00;
         endcase
      end
   end

   always @(cnt_line_r or wr_start_igai_r)
   begin
      if(wr_start_igai_r)
      begin
         case(cnt_line_r)
            6'd18: prog_adr1_w = 5'h0A;
            6'd19: prog_adr1_w = 5'h0A;
            6'd20: prog_adr1_w = 5'h1A;
            6'd21: prog_adr1_w = 5'h1A;
            6'd22: prog_adr1_w = 5'h0B;
            6'd23: prog_adr1_w = 5'h1B;
            6'd24: prog_adr1_w = 5'h0B;
            6'd25: prog_adr1_w = 5'h0C;
            6'd26: prog_adr1_w = 5'h1B;
            6'd27: prog_adr1_w = 5'h1C;
            6'd28: prog_adr1_w = 5'h0D;
            6'd29: prog_adr1_w = 5'h0C;
            6'd30: prog_adr1_w = 5'h1D;
            6'd31: prog_adr1_w = 5'h1C;
            6'd32: prog_adr1_w = 5'h0E;
            6'd33: prog_adr1_w = 5'h1E;
            6'd34: prog_adr1_w = 5'h0D;
            6'd35: prog_adr1_w = 5'h0F;
            6'd36: prog_adr1_w = 5'h1D;
            6'd37: prog_adr1_w = 5'h1F;
          default: prog_adr1_w = 5'h00;
         endcase
      end
      else
      begin
         case(cnt_line_r)
            6'd18: prog_adr1_w = 5'h0A;
            6'd19: prog_adr1_w = 5'h0A;
            6'd20: prog_adr1_w = 5'h1A;
            6'd21: prog_adr1_w = 5'h1A;
            6'd22: prog_adr1_w = 5'h0B;
            6'd23: prog_adr1_w = 5'h0B;
            6'd24: prog_adr1_w = 5'h1B;
            6'd25: prog_adr1_w = 5'h1B;
            6'd26: prog_adr1_w = 5'h0C;
            6'd27: prog_adr1_w = 5'h0C;
            6'd28: prog_adr1_w = 5'h1C;
            6'd29: prog_adr1_w = 5'h1C;
            6'd30: prog_adr1_w = 5'h0D;
            6'd31: prog_adr1_w = 5'h0D;
            6'd32: prog_adr1_w = 5'h1D;
            6'd33: prog_adr1_w = 5'h1D;
            6'd34: prog_adr1_w = 5'h0E;
            6'd35: prog_adr1_w = 5'h0E;
            6'd36: prog_adr1_w = 5'h1E;
            6'd37: prog_adr1_w = 5'h1E;
          default: prog_adr1_w = 5'h00;
         endcase
      end
   end


   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
          wr_ife00_a_r <= 7'd0;
      else
      begin
         if(!sel_input_r && (ff_ref1yen_r || ff_ref1cen_r))
         begin
            if(wr_start_igai_r || wr_start_prog_r)
            begin
               if(!sely_odd_even_r && !cnt_iny_add0_r[3] && y_line_varid_r)
               begin
                  wr_ife00_a_r <= {prog_adr_w[3:0],cnt_iny_add0_r[2:0]};
               end
               else if(!selc_odd_even_r && !cnt_inc_add0_r[2] && c_line_varid_r)
               begin
                  wr_ife00_a_r <= {prog_adr1_w[3:0],prog_adr1_w[4],cnt_inc_add0_r[1:0]};
               end
               else
               begin
                  wr_ife00_a_r <= 7'd0;
               end
            end
            else if(wr_start_interace_r)
            begin
               if(!sely_odd_even_r && !cnt_iny_add0_r[3] && y_line_varid_r)
               begin
                  wr_ife00_a_r <= {adrcount[3:0],cnt_iny_add0_r[2:0]};
               end
               else if(!selc_odd_even_r && !cnt_inc_add0_r[2] && c_line_varid_r)
               begin
                  wr_ife00_a_r <= {1'b1,adrcount[3:0],cnt_inc_add0_r[1:0]};
               end
               else
               begin
                  wr_ife00_a_r <= 7'd0;
               end
            end
         end
         else
         begin
            wr_ife00_a_r <= 7'd0;
         end
      end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         rd_ife00_a_r <= 7'd0;
      end
      else
      begin
         if(!sel_output_r)
         begin
            if(rd_start_w && y_line_rd_r && (ff_pred_forward_buc_r ||  m_motion_dp_r))
            begin
               rd_ife00_a_r <= {rd_a_adr_cnt_r[3:0],cnt_outy_add0_r[3:1]};
            end
            else if(rd_start_w && c_line_rd_r && (ff_pred_forward_buc_r ||  m_motion_dp_r))
            begin
               rd_ife00_a_r <= {rd_a_adr_cnt_r[4:0],cnt_outc_add0_r[2:1]};
            end
            else
            begin
               rd_ife00_a_r <= 7'd0;
            end
         end
         else
         begin
            rd_ife00_a_r <= 7'd0;
         end
      end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         v1_ife00_a <= 7'b0;
      end
      else
      begin
         v1_ife00_a[6] <= wr_ife00_a_r[6] | rd_ife00_a_r[6];
         v1_ife00_a[5] <= wr_ife00_a_r[5] | rd_ife00_a_r[5];
         v1_ife00_a[4] <= wr_ife00_a_r[4] | rd_ife00_a_r[4];
         v1_ife00_a[3] <= wr_ife00_a_r[3] | rd_ife00_a_r[3];
         v1_ife00_a[2] <= wr_ife00_a_r[2] | rd_ife00_a_r[2];
         v1_ife00_a[1] <= wr_ife00_a_r[1] | rd_ife00_a_r[1];
         v1_ife00_a[0] <= wr_ife00_a_r[0] | rd_ife00_a_r[0];
      end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
          wr_ife01_a_r <= 7'd0;
      end
      else
      begin
         if(!sel_input_r && (ff_ref1yen_r || ff_ref1cen_r))
         begin
            if(wr_start_igai_r || wr_start_prog_r)
            begin
               if(sely_odd_even_r && !cnt_iny_add0_r[3] && y_line_varid_r)
               begin
                  wr_ife01_a_r <= {prog_adr_w[3:0],cnt_iny_add0_r[2:0]};
               end
               else if(selc_odd_even_r && ~cnt_inc_add0_r[2] && c_line_varid_r)
               begin
                  wr_ife01_a_r <= {prog_adr1_w[3:0],prog_adr1_w[4],cnt_inc_add0_r[1:0]};
               end
               else
               begin
                  wr_ife01_a_r <= 7'd0;
               end
            end
            else if(wr_start_interace_r)
            begin
               if(sely_odd_even_r && !cnt_iny_add0_r[3] && y_line_varid_r)
               begin
                  wr_ife01_a_r <= {adrcount[3:0],cnt_iny_add0_r[2:0]};
               end
               else if(selc_odd_even_r && !cnt_inc_add0_r[2] && c_line_varid_r)
               begin
                  wr_ife01_a_r <= {1'b1,adrcount_co[3:0],cnt_inc_add0_r[1:0]};
               end
               else
               begin
                  wr_ife01_a_r <= 7'd0;
               end
            end
         end
         else begin
            wr_ife01_a_r <= 7'd0;
         end
      end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         rd_ife01_a_r <= 7'd0;
      end
      else
      begin
         if(!sel_output_r)
         begin
            if(rd_start_w && y_line_rd_r && (ff_pred_forward_buc_r ||  m_motion_dp_r))
            begin
               rd_ife01_a_r <= {rd_b_adr_cnt_r[3:0],cnt_outy_add0_r[3:1]};
            end
            else if(rd_start_w && c_line_rd_r && (ff_pred_forward_buc_r ||  m_motion_dp_r))
            begin
               rd_ife01_a_r <= {rd_b_adr_cnt_r[4:0],cnt_outc_add0_r[2:1]};
            end
            else
            begin
               rd_ife01_a_r <= 7'd0;
            end
         end
         else
         begin
            rd_ife01_a_r <= 7'd0;
         end
      end
   end

   always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x)
      begin
         v1_ifo00_a <= 7'd0;
      end
      else
      begin
         v1_ifo00_a[6] <= wr_ife01_a_r[6] | rd_ife01_a_r[6];
         v1_ifo00_a[5] <= wr_ife01_a_r[5] | rd_ife01_a_r[5];
         v1_ifo00_a[4] <= wr_ife01_a_r[4] | rd_ife01_a_r[4];
         v1_ifo00_a[3] <= wr_ife01_a_r[3] | rd_ife01_a_r[3];
         v1_ifo00_a[2] <= wr_ife01_a_r[2] | rd_ife01_a_r[2];
         v1_ifo00_a[1] <= wr_ife01_a_r[1] | rd_ife01_a_r[1];
         v1_ifo00_a[0] <= wr_ife01_a_r[0] | rd_ife01_a_r[0];
      end
   end


   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
          wr_ifo00_a_r <= 7'd0;
      end
      else
      begin
         if(sel_input_r && (ff_ref1yen_r || ff_ref1cen_r))
         begin
            if(wr_start_igai_r || wr_start_prog_r)
            begin
               if(!sely_odd_even_r && !cnt_iny_add0_r[3] && y_line_varid_r)
               begin
                  wr_ifo00_a_r <= {prog_adr_w[3:0],cnt_iny_add0_r[2:0]};
               end
               else if(!selc_odd_even_r && !cnt_inc_add0_r[2] && c_line_varid_r)
               begin
                  wr_ifo00_a_r <= {prog_adr1_w[3:0],prog_adr1_w[4],cnt_inc_add0_r[1:0]};
               end
               else
               begin
                  wr_ifo00_a_r <= 7'd0;
               end
            end
            else if(wr_start_interace_r)
            begin
               if(!sely_odd_even_r && !cnt_iny_add0_r[3] && y_line_varid_r)
               begin
                  wr_ifo00_a_r <= {adrcount[3:0],cnt_iny_add0_r[2:0]};
               end
               else if(!selc_odd_even_r && !cnt_inc_add0_r[2] && c_line_varid_r)
               begin
                  wr_ifo00_a_r <= {1'b1,adrcount[3:0],cnt_inc_add0_r[1:0]};
               end
               else
               begin
                  wr_ifo00_a_r <= 7'd0;
               end
            end
         end
         else
         begin
            wr_ifo00_a_r <= 7'd0;
         end
      end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         rd_ifo00_a_r <= 7'd0;
      end
      else
      begin
         if(sel_output_r)
         begin
            if(rd_start_w && y_line_rd_r && (ff_pred_forward_buc_r ||  m_motion_dp_r))
            begin
               rd_ifo00_a_r <= {rd_a_adr_cnt_r[3:0],cnt_outy_add0_r[3:1]};
            end
            else if(rd_start_w && c_line_rd_r && (ff_pred_forward_buc_r ||  m_motion_dp_r))
            begin
               rd_ifo00_a_r <= {rd_a_adr_cnt_r[4:0],cnt_outc_add0_r[2:1]};
            end
            else
            begin
               rd_ifo00_a_r <= 7'd0;
            end
         end
         else
         begin
            rd_ifo00_a_r <= 7'd0;
         end
      end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         v1_ife01_a <= 7'd0;
      end
      else
      begin
         v1_ife01_a[6] <= wr_ifo00_a_r[6] | rd_ifo00_a_r[6];
         v1_ife01_a[5] <= wr_ifo00_a_r[5] | rd_ifo00_a_r[5];
         v1_ife01_a[4] <= wr_ifo00_a_r[4] | rd_ifo00_a_r[4];
         v1_ife01_a[3] <= wr_ifo00_a_r[3] | rd_ifo00_a_r[3];
         v1_ife01_a[2] <= wr_ifo00_a_r[2] | rd_ifo00_a_r[2];
         v1_ife01_a[1] <= wr_ifo00_a_r[1] | rd_ifo00_a_r[1];
         v1_ife01_a[0] <= wr_ifo00_a_r[0] | rd_ifo00_a_r[0];
      end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
          wr_ifo01_a_r <= 0;
      end
      else
      begin
         if(sel_input_r && (ff_ref1yen_r || ff_ref1cen_r))
         begin
            if(wr_start_igai_r || wr_start_prog_r)
            begin
               if(sely_odd_even_r && !cnt_iny_add0_r[3] && y_line_varid_r)
               begin
                  wr_ifo01_a_r <= {prog_adr_w[3:0],cnt_iny_add0_r[2:0]};
               end
               else if(selc_odd_even_r && !cnt_inc_add0_r[2] && c_line_varid_r)
               begin
                  wr_ifo01_a_r <= {prog_adr1_w[3:0],prog_adr1_w[4],cnt_inc_add0_r[1:0]};
               end
               else
               begin
                  wr_ifo01_a_r <= 7'd0;
               end
            end
            else if(wr_start_interace_r)
            begin
               if(sely_odd_even_r && !cnt_iny_add0_r[3] && y_line_varid_r)
               begin
                  wr_ifo01_a_r <= {adrcount[3:0],cnt_iny_add0_r[2:0]};
               end
               else if(selc_odd_even_r && !cnt_inc_add0_r[2] && c_line_varid_r)
               begin
                  wr_ifo01_a_r <= {1'b1,adrcount_co[3:0],cnt_inc_add0_r[1:0]};
               end
               else
               begin
                  wr_ifo01_a_r <= 7'd0;
               end
            end
         end
         else
         begin
            wr_ifo01_a_r <= 7'd0;
         end
      end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         rd_ifo01_a_r <= 7'd0;
      end
      else
      begin
         if(sel_output_r)
         begin
            if(rd_start_w && y_line_rd_r && (ff_pred_forward_buc_r ||  m_motion_dp_r))
            begin
               rd_ifo01_a_r <= {rd_b_adr_cnt_r[3:0],cnt_outy_add0_r[3:1]};
            end
            else if(rd_start_w && c_line_rd_r && (ff_pred_forward_buc_r ||  m_motion_dp_r))
            begin
               rd_ifo01_a_r <= {rd_b_adr_cnt_r[4:0],cnt_outc_add0_r[2:1]};
            end
            else
            begin
               rd_ifo01_a_r <= 7'd0;
            end
         end
         else
         begin
            rd_ifo01_a_r <= 7'd0;
         end
      end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         v1_ifo01_a <= 7'd0;
      end
      else
      begin
         v1_ifo01_a[6] <= wr_ifo01_a_r[6] | rd_ifo01_a_r[6];
         v1_ifo01_a[5] <= wr_ifo01_a_r[5] | rd_ifo01_a_r[5];
         v1_ifo01_a[4] <= wr_ifo01_a_r[4] | rd_ifo01_a_r[4];
         v1_ifo01_a[3] <= wr_ifo01_a_r[3] | rd_ifo01_a_r[3];
         v1_ifo01_a[2] <= wr_ifo01_a_r[2] | rd_ifo01_a_r[2];
         v1_ifo01_a[1] <= wr_ifo01_a_r[1] | rd_ifo01_a_r[1];
         v1_ifo01_a[0] <= wr_ifo01_a_r[0] | rd_ifo01_a_r[0];
      end
   end


   always @(posedge clkdec or negedge rstdec_x)
   begin
       if(!rstdec_x)
       begin
           wr_ife00_d_r <= 18'd0;
       end
       else
       begin
          if(!sel_input_r && wr_start_w && 
            ((!sely_odd_even_r && ff_ref1yen_r && y_line_varid_r) ||
             (!selc_odd_even_r && ff_ref1cen_r && c_line_varid_r)))
          begin
             wr_ife00_d_r <= ff_halfhdt_r;
          end
          else
          begin
            wr_ife00_d_r <= 18'd0;
          end
       end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
       if(!rstdec_x)
       begin
           wr_ifo00_d_r <= 18'd0;
       end
       else
       begin
          if(!sel_input_r && wr_start_w &&
            (( sely_odd_even_r && ff_ref1yen_r && y_line_varid_r) ||
             ( selc_odd_even_r && ff_ref1cen_r && c_line_varid_r)))
          begin
             wr_ifo00_d_r <= ff_halfhdt_r;
          end
          else
          begin
            wr_ifo00_d_r <= 18'd0;
          end
       end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
       if(!rstdec_x)
       begin
           wr_ife01_d_r <= 18'd0;
       end
       else
       begin
          if(sel_input_r && wr_start_w && 
            ((!sely_odd_even_r && ff_ref1yen_r && y_line_varid_r) ||
             (!selc_odd_even_r && ff_ref1cen_r && c_line_varid_r)))
          begin
             wr_ife01_d_r <= ff_halfhdt_r;
          end
          else
          begin
            wr_ife01_d_r <= 18'd0;
          end
       end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
       if(!rstdec_x)
       begin
           wr_ifo01_d_r <= 18'd0;
       end
       else
       begin
          if(sel_input_r && wr_start_w &&
            (( sely_odd_even_r && ff_ref1yen_r && y_line_varid_r) ||
             ( selc_odd_even_r && ff_ref1cen_r && c_line_varid_r)))
          begin
             wr_ifo01_d_r <= ff_halfhdt_r;
          end
          else
          begin
            wr_ifo01_d_r <= 18'd0;
          end
       end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         v1_ife00_d <= 18'd0;
         v1_ifo00_d <= 18'd0;
         v1_ife01_d <= 18'd0;
         v1_ifo01_d <= 18'd0;
      end
      else
      begin
         v1_ife00_d <= wr_ife00_d_r;
         v1_ifo00_d <= wr_ifo00_d_r;
         v1_ife01_d <= wr_ife01_d_r;
         v1_ifo01_d <= wr_ifo01_d_r;
      end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         wr_ife00_bs_r <= 1'b0;
         wr_ifo00_bs_r <= 1'b0;
         wr_ife01_bs_r <= 1'b0;
         wr_ifo01_bs_r <= 1'b0;
         rd_ife00_bs_r <= 1'b0;
         rd_ifo00_bs_r <= 1'b0;
         rd_ife01_bs_r <= 1'b0;
         rd_ifo01_bs_r <= 1'b0;
      end
      else
      begin
         wr_ife00_bs_r <= ~sel_input_r & ~(sely_odd_even_r | selc_odd_even_r) & 
                   (ff_ref1yen_r | ff_ref1cen_r) & wr_start_w;
         wr_ifo00_bs_r <= ~sel_input_r &  (sely_odd_even_r | selc_odd_even_r) & 
                   (ff_ref1yen_r | ff_ref1cen_r) & wr_start_w;
         wr_ife01_bs_r <=  sel_input_r & ~(sely_odd_even_r | selc_odd_even_r) & 
                   (ff_ref1yen_r | ff_ref1cen_r) & wr_start_w;
         wr_ifo01_bs_r <=  sel_input_r &  (sely_odd_even_r | selc_odd_even_r) & 
                   (ff_ref1yen_r | ff_ref1cen_r) & wr_start_w;
         rd_ife00_bs_r <= ~sel_output_r & (ff_pred_forward_buc_r |  m_motion_dp_r) & rd_start_w;
         rd_ifo00_bs_r <= ~sel_output_r & (ff_pred_forward_buc_r |  m_motion_dp_r) & rd_start_w;
         rd_ife01_bs_r <=  sel_output_r & (ff_pred_forward_buc_r |  m_motion_dp_r) & rd_start_w;
         rd_ifo01_bs_r <=  sel_output_r & (ff_pred_forward_buc_r |  m_motion_dp_r) & rd_start_w;
      end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         v1_ife00_bs <= 1'b0;
         v1_ifo00_bs <= 1'b0;
         v1_ife01_bs <= 1'b0;
         v1_ifo01_bs <= 1'b0;
      end
      else
      begin
         v1_ife00_bs <= wr_ife00_bs_r | rd_ife00_bs_r;
         v1_ifo00_bs <= wr_ifo00_bs_r | rd_ifo00_bs_r;
         v1_ife01_bs <= wr_ife01_bs_r | rd_ife01_bs_r;
         v1_ifo01_bs <= wr_ifo01_bs_r | rd_ifo01_bs_r;
      end
   end

   always @(posedge clkdec or negedge rstdec_x) 
   begin
      if(!rstdec_x)
      begin
          wr_ife00_we_r <= 1'b0;
      end
      else
      begin
         if(!sel_input_r && (ff_ref1yen_r || ff_ref1cen_r))
         begin
            if(wr_start_igai_r || wr_start_prog_r)
            begin
               if(!sely_odd_even_r && !cnt_iny_add0_r[3] && ff_ref1yen_r && y_line_varid_r)
               begin
                  wr_ife00_we_r <= 1'b1;
               end
               else if(!selc_odd_even_r && !cnt_inc_add0_r[2] && ff_ref1cen_r && c_line_varid_r)
               begin
                  wr_ife00_we_r <= 1'b1;
               end
               else
               begin
                  wr_ife00_we_r <= 1'b0;
               end
            end
            else if(wr_start_interace_r)
            begin
               if(!sely_odd_even_r && !cnt_iny_add0_r[3] && ff_ref1yen_r && y_line_varid_r)
               begin
                  wr_ife00_we_r <= 1'b1;
               end
               else if(!selc_odd_even_r && !cnt_inc_add0_r[2] && ff_ref1cen_r && c_line_varid_r)
               begin
                  wr_ife00_we_r <= 1'b1;
               end
               else
               begin
                  wr_ife00_we_r <= 1'b0;
               end
            end
         end
      end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x) 
      begin
          v1_ife00_we <= 1'b0;
      end
      else
      begin
          v1_ife00_we <= wr_ife00_we_r;
      end
   end


   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         wr_ifo00_we_r <= 1'b0;
      end
      else
      begin
         if(!sel_input_r && (ff_ref1yen_r || ff_ref1cen_r))
         begin
            if(wr_start_igai_r || wr_start_prog_r)
            begin
               if(sely_odd_even_r && !cnt_iny_add0_r[3] && ff_ref1yen_r)
               begin
                  wr_ifo00_we_r <= 1'b1;
               end
               else if(selc_odd_even_r && !cnt_inc_add0_r[2] && ff_ref1cen_r && c_line_varid_r)
               begin
                  wr_ifo00_we_r <= 1'b1;
               end
               else
               begin
                  wr_ifo00_we_r <= 1'b0;
               end
            end
            else if(wr_start_interace_r)
            begin
               if(sely_odd_even_r && !cnt_iny_add0_r[3] && ff_ref1yen_r && y_line_varid_r)
               begin
                  wr_ifo00_we_r <= 1'b1;
               end
               else if(selc_odd_even_r && !cnt_inc_add0_r[2] && ff_ref1cen_r && c_line_varid_r)
               begin
                  wr_ifo00_we_r <= 1'b1;
               end
               else
               begin
                  wr_ifo00_we_r <= 1'b0;
               end
            end
         end
      end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         v1_ifo00_we <= 1'b0;
      end
      else
      begin
         v1_ifo00_we <= wr_ifo00_we_r;
      end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
          wr_ife01_we_r <= 1'b0;
      end
      else
      begin
         if(sel_input_r && (ff_ref1yen_r || ff_ref1cen_r))
         begin
            if(wr_start_igai_r || wr_start_prog_r)
            begin
               if(!sely_odd_even_r && !cnt_iny_add0_r[3] && ff_ref1yen_r && y_line_varid_r)
               begin
                  wr_ife01_we_r <= 1'b1;
               end
               else if(!selc_odd_even_r && !cnt_inc_add0_r[2] && ff_ref1cen_r && c_line_varid_r)
               begin
                  wr_ife01_we_r <= 1'b1;
               end
               else
               begin
                  wr_ife01_we_r <= 1'b0;
               end
            end
            else if(wr_start_interace_r)
            begin
               if(!sely_odd_even_r && !cnt_iny_add0_r[3] && ff_ref1yen_r && y_line_varid_r)
               begin
                  wr_ife01_we_r <= 1'b1;
               end
               else if(!selc_odd_even_r && !cnt_inc_add0_r[2] && ff_ref1cen_r && c_line_varid_r)
               begin
                  wr_ife01_we_r <= 1'b1;
               end
               else
               begin
                  wr_ife01_we_r <= 1'b0;
               end
            end
         end
      end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         v1_ife01_we <= 1'b0;
      end
      else
      begin
         v1_ife01_we <= wr_ife01_we_r;
      end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         wr_ifo01_we_r <= 1'b0;
      end
      else
      begin
         if(sel_input_r && (ff_ref1yen_r || ff_ref1cen_r))
         begin
            if(wr_start_igai_r || wr_start_prog_r)
            begin
               if(sely_odd_even_r && !cnt_iny_add0_r[3] && ff_ref1yen_r)
               begin
                  wr_ifo01_we_r <= 1'b1;
               end
               else if(selc_odd_even_r && !cnt_inc_add0_r[2] && ff_ref1cen_r && c_line_varid_r)
               begin
                  wr_ifo01_we_r <= 1'b1;
               end
               else
               begin
                  wr_ifo01_we_r <= 1'b0;
               end
            end
            else if(wr_start_interace_r)
            begin
               if(sely_odd_even_r && !cnt_iny_add0_r[3] && ff_ref1yen_r && y_line_varid_r)
               begin
                  wr_ifo01_we_r <= 1'b1;
               end
               else if(selc_odd_even_r && !cnt_inc_add0_r[2] && ff_ref1cen_r && c_line_varid_r)
               begin
                  wr_ifo01_we_r <= 1'b1;
               end
               else
               begin
                  wr_ifo01_we_r <= 1'b0;
               end
            end
         end
      end
   end

   always @(posedge clkdec or negedge rstdec_x)
   begin
      if(!rstdec_x)
      begin
         v1_ifo01_we <= 1'b0;
      end
      else
      begin
         v1_ifo01_we <= wr_ifo01_we_r;
      end
   end

   assign togle_w = dat_sel_up_w & dat_sel_r;

   always @(posedge clkdec or negedge rstdec_x) 
   begin:LINE_SELECT_SIG
      if(!rstdec_x)
      begin
         line_sel_r <= 1'b0;
      end
      else
      begin
         if(!ff_mbpl_mc_r[0] && !rd_start_clr_w && (ff_pred_forward_buc_r ||  m_motion_dp_r))
         begin
            if(ff_mbpl_mc_r[1] && ff_frm_pred_over_mc_r)
            begin
               line_sel_r <= 1'b1;
            end
            else if((ff_mbpl_mc_r[1] && (ff_frm_inter_mc_r || ff_frm_prog_mc_r)) ||
                    (togle_w && (cnt_togle_w_r == 5'h0f)))
            begin
               line_sel_r <= ~ff_line17_cutf_r;
            end
            else if(togle_w)
            begin
               line_sel_r <= ~line_sel_r;
            end
         end
         else
         begin
            line_sel_r <= 1'b0;
         end
      end
   end

   always @(posedge clkdec or negedge rstdec_x) 
   begin:TOGLE_CNT
      if(!rstdec_x) 
      begin
        cnt_togle_w_r <= 5'd0;
      end
      else
      begin
        if(ff_mbpl_mc_r[1]==1'b1)
        begin
          cnt_togle_w_r <= 5'b0;
        end
        else if(togle_w==1'b1)
        begin
          cnt_togle_w_r <= cnt_togle_w_r + 5'd1;
        end
        else
        begin
          cnt_togle_w_r <= cnt_togle_w_r;
        end
     end
   end

    always @(posedge clkdec or negedge rstdec_x) 
   begin:DELAY_LINE
      if(!rstdec_x)
      begin
         dly_line_r <= 5'd0;
      end
      else
      begin
         dly_line_r[0] <= line_sel_r;
         dly_line_r[1] <= dly_line_r[0];
         dly_line_r[2] <= dly_line_r[1];
         dly_line_r[3] <= dly_line_r[2];
         dly_line_r[4] <= dly_line_r[3];
      end
   end

   assign m_line_sel_r = dly_line_r[4];

   assign out_dat_sel_w = (y_line_rd_r & ~cnt_outy_add0_r[0]) |
                        (c_line_rd_r & ~cnt_outc_add0_r[0]);
   always @(posedge clkdec or negedge rstdec_x) 
   begin:MEM_SELECT
      if(!rstdec_x)
      begin
         out_dat_sel_r <= 4'b0000;
      end
      else
      begin
         out_dat_sel_r[0] <= out_dat_sel_w;
         out_dat_sel_r[1] <= out_dat_sel_r[0];
         out_dat_sel_r[2] <= out_dat_sel_r[1];
         out_dat_sel_r[3] <= out_dat_sel_r[2];
      end
   end

   always @(posedge clkdec or negedge rstdec_x) 
   begin:DLY_SEL_OUTPUT
      if(!rstdec_x)
      begin
         dly_sel_output_r <= 4'b0000;
      end
      else
      begin
         dly_sel_output_r[0] <= sel_output_r;
         dly_sel_output_r[1] <= dly_sel_output_r[0];
         dly_sel_output_r[2] <= dly_sel_output_r[1];
         dly_sel_output_r[3] <= dly_sel_output_r[2];
      end
   end

   assign read_out_e_w = (rd_start_w & (ff_pred_forward_buc_r |  m_motion_dp_r));
   always @(posedge clkdec or negedge rstdec_x) 
   begin:DLY_READ_OUT
      if(!rstdec_x)
      begin
         read_out_e_r <= 4'b0000;
      end
      else
      begin
         read_out_e_r[0] <= read_out_e_w;
         read_out_e_r[1] <= read_out_e_r[0];
         read_out_e_r[2] <= read_out_e_r[1];
         read_out_e_r[3] <= read_out_e_r[2];
      end
   end

   assign even_datsel_a_w = (out_dat_sel_r[3])? ff_ife00_q_r[17:9] : ff_ife00_q_r[8:0];
   assign odd_datsel_a_w = (out_dat_sel_r[3])? ff_ifo00_q_r[17:9] : ff_ifo00_q_r[8:0];
   assign even_datsel_b_w = (out_dat_sel_r[3])? ff_ife01_q_r[17:9] : ff_ife01_q_r[8:0];
   assign odd_datsel_b_w = (out_dat_sel_r[3])? ff_ifo01_q_r[17:9] : ff_ifo01_q_r[8:0];
   assign e_datsel_line_w = (~dly_sel_output_r[3])? even_datsel_a_w : even_datsel_b_w;
   assign o_datsel_line_w = (~dly_sel_output_r[3])?  odd_datsel_a_w :  odd_datsel_b_w;
   assign rd_data_h_w = (read_out_e_r[3])? e_datsel_line_w : 9'h000;
   assign rd_data_l_w = (read_out_e_r[3])? o_datsel_line_w : 9'h000;

   always @(posedge clkdec or negedge rstdec_x) 
   begin:DATA_SELECT
      if(!rstdec_x)
      begin
         m_scan_even_r <= 9'd0;
         m_scan_odd_r  <= 9'd0;
      end
      else
      begin
         m_scan_even_r <= rd_data_h_w;
         m_scan_odd_r  <= rd_data_l_w;
      end
   end

endmodule


