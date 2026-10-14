// ----------------------------------------------
// File: mc_frfi.v
// Module: mc_frfi
// Function:
// ----------------------------------------------

module mc_frfi (
  clkdec,
  rstdec_x,
  m_mbpl_dc_r_s,
  m_mbpl_mc_r_s,
  m_frm_inter_mc_r,
  m_frm_prog_mc_r,
  m_frm_prog_over_mc_r,
  m_decdt_r,
  m_decyen_r,
  m_deccen_r,
  m_calc_dat_r,
  v1_rit00_a,
  v1_rit00_d,
  w1_rit00_q,
  v1_rit00_bs,
  v1_rit00_we,
  v1_rit01_a,
  v1_rit01_d,
  w1_rit01_q,
  v1_rit01_bs,
  v1_rit01_we
                   );

   input clkdec;
   input rstdec_x;
   input m_mbpl_dc_r_s; 
   input m_mbpl_mc_r_s; 
   input m_frm_inter_mc_r; 
   input m_frm_prog_mc_r;  
   input m_frm_prog_over_mc_r;
   input [7:0]m_calc_dat_r;
   input [15:0]w1_rit00_q; 
   input [15:0]w1_rit01_q; 
   output [15:0]m_decdt_r;
   output m_decyen_r;
   output m_deccen_r;
   output [7:0]v1_rit00_a; 
   output [15:0]v1_rit00_d;
   output v1_rit00_bs;     
   output v1_rit00_we;     
   output [7:0]v1_rit01_a; 
   output [15:0]v1_rit01_d;
   output v1_rit01_bs;    
   output v1_rit01_we;    


   reg [1:0]mbpl_dc_r; 
   reg [13:0]mbpl_mc_r;
   reg frm_inter_r;
   reg [1:0]frm_prog_r;
   reg [1:0]frm_prog_over_r;
   reg [7:0]calc_dat0_r;
   reg [7:0]calc_dat1_r;

   reg [7:0]in_data_r;

   reg wr_nomal_start_r;
   reg wr_interace_start_r;
   reg rd_start_r;
   reg data_load_r;
   reg [7:0]wr_data_count_r;
   reg [7:0]rd_data_count_r;
   reg [7:0]interace_adr_r;
   reg [8:0]load_adr_w;

   reg mem_sel_r;
   reg [7:0]m_adr0_r;
   reg [7:0]m_adr1_r;

   reg rit00_bs_r;
   reg rit00_we_r;
   reg rit01_bs_r;
   reg rit01_we_r;
   reg [15:0]rit00_d_r;
   reg [15:0]rit01_d_r;
   reg [15:0]rit00_q_r;
   reg [15:0]rit01_q_r;

   wire w_count_clr_w;
   wire wr_count_clr_w;
   wire rd_count_clr_w;

   reg [3:0]decyen_r;
   reg [3:0]deccen_r;
   reg [15:0]m_decdt_r;

   wire start_w;
   wire [15:0]out_data;
   wire [7:0]interace_add_w;
   wire [7:0]interace_adr_w;
   wire [7:0]wadr0_sel_w;
   wire [7:0]adr0_w;
   wire [7:0]wadr1_sel_w;
   wire [7:0]adr1_w;
   wire wr_bs0_w;
   wire wr_bs1_w;

   always @(negedge rstdec_x or posedge clkdec)
   begin 
      if(rstdec_x==1'b0)
      begin
         mbpl_dc_r       <= 2'b00;
         mbpl_mc_r       <= 14'b00_0000_0000_0000;
         frm_inter_r     <= 1'b0;
         frm_prog_r      <= 2'b00;
         frm_prog_over_r <= 2'b00;
         calc_dat0_r     <= 8'b0000_0000;
         calc_dat1_r     <= 8'b0000_0000;
         rit00_q_r       <= 16'b0000_0000_0000_0000;
         rit01_q_r       <= 16'b0000_0000_0000_0000;
      end
      else
      begin
         mbpl_dc_r[0]    <= m_mbpl_dc_r_s;
         mbpl_dc_r[1]    <= mbpl_dc_r[0];
         mbpl_mc_r[0]    <= m_mbpl_mc_r_s;
         mbpl_mc_r[1]    <= mbpl_mc_r[0];
         mbpl_mc_r[2]    <= mbpl_mc_r[1];
         mbpl_mc_r[3]    <= mbpl_mc_r[2];
         mbpl_mc_r[4]    <= mbpl_mc_r[3];
         mbpl_mc_r[5]    <= mbpl_mc_r[4];
         mbpl_mc_r[6]    <= mbpl_mc_r[5];
         mbpl_mc_r[7]    <= mbpl_mc_r[6];
         mbpl_mc_r[8]    <= mbpl_mc_r[7];
         mbpl_mc_r[9]    <= mbpl_mc_r[8];
         mbpl_mc_r[10]   <= mbpl_mc_r[9];
         mbpl_mc_r[11]   <= mbpl_mc_r[10];
         mbpl_mc_r[12]   <= mbpl_mc_r[11];
         mbpl_mc_r[13]   <= mbpl_mc_r[12];
         frm_inter_r     <= m_frm_inter_mc_r;
         frm_prog_r[0]   <= m_frm_prog_mc_r;
         frm_prog_r[1]   <= frm_prog_r[0];
         frm_prog_over_r[0] <= m_frm_prog_over_mc_r;
         frm_prog_over_r[1] <= frm_prog_over_r[0];
         calc_dat0_r      <= m_calc_dat_r;
         calc_dat1_r      <= calc_dat0_r;
         rit00_q_r        <= w1_rit00_q;
         rit01_q_r        <= w1_rit01_q;
      end
   end

   always @(negedge rstdec_x or posedge clkdec)
   begin 
      if(rstdec_x==1'b0)
      begin
         wr_nomal_start_r    <= 1'b0;
         wr_interace_start_r <= 1'b0;
      end
      else
      begin
         if(wr_count_clr_w==1'b0)
         begin
            if(mbpl_mc_r[13]==1'b1)
            begin
               wr_nomal_start_r    <= ~frm_inter_r;
               wr_interace_start_r <= frm_inter_r; 
            end
            else
            begin
               wr_nomal_start_r    <= wr_nomal_start_r;
               wr_interace_start_r <= wr_interace_start_r;
            end
         end
         else
         begin
            wr_nomal_start_r    <= 1'b0;
            wr_interace_start_r <= 1'b0;
         end
      end
   end

   always @(negedge rstdec_x or posedge clkdec)
   begin 
      if(rstdec_x==1'b0)
      begin
         rd_start_r <= 1'b0;
      end
      else
      begin
         if(rd_count_clr_w==1'b0)
         begin
            if(mbpl_dc_r[1]==1'b1)
            begin
               rd_start_r <= 1'b1;
            end
            else
            begin
               rd_start_r <= rd_start_r;
            end
         end
         else
         begin
            rd_start_r <= 1'b0;
         end
      end
   end


   assign start_w = wr_nomal_start_r | wr_interace_start_r;

   always @(negedge rstdec_x or posedge clkdec)
   begin 
      if(rstdec_x==1'b0)
      begin
         data_load_r <= 1'b0;
      end
      else
      begin
         if(start_w==1'b1)
         begin
            data_load_r <= ~data_load_r;
         end
         else
         begin
            data_load_r <= 1'b0;
         end
      end
   end

always @(negedge rstdec_x or posedge clkdec)begin
    if(rstdec_x==1'b0)
        in_data_r <= 8'b0000_0000;
    else begin
        if(data_load_r==1'b0)
            in_data_r <= calc_dat1_r;
        else
            in_data_r <= in_data_r;
    end
end

assign out_data = {in_data_r,calc_dat1_r};

   always @(negedge rstdec_x or posedge clkdec)
   begin 
      if(rstdec_x==1'b0)
      begin
         rit00_d_r <= 16'b0000_0000_0000_0000;
         rit01_d_r <= 16'b0000_0000_0000_0000;
      end
      else
      begin
         if(start_w==1'b1)
         begin
            if(mem_sel_r==1'b0)
            begin
               if(data_load_r==1'b1)
               begin
                  rit00_d_r <= out_data;
                  rit01_d_r <= 16'b0000_0000_0000_0000;
               end
               else
               begin
                  rit00_d_r <= 16'b0000_0000_0000_0000;
                  rit01_d_r <= 16'b0000_0000_0000_0000;
               end
            end
            else
            begin
               if(data_load_r==1'b1)
               begin
                  rit00_d_r <= 16'b0000_0000_0000_0000;
                  rit01_d_r <= out_data;
               end
               else
               begin
                  rit00_d_r <= 16'b0000_0000_0000_0000;
                  rit01_d_r <= 16'b0000_0000_0000_0000;
               end
            end
         end
         else
         begin
            rit00_d_r <= 16'b0000_0000_0000_0000;
            rit01_d_r <= 16'b0000_0000_0000_0000;
         end
      end
   end

   assign v1_rit00_d = rit00_d_r;
   assign v1_rit01_d = rit01_d_r;


   assign w_count_clr_w = (wr_data_count_r==8'hBF)? 1'b1 : 1'b0;
   assign wr_count_clr_w = w_count_clr_w & data_load_r;

   always @(negedge rstdec_x or posedge clkdec)
   begin 
      if(rstdec_x==1'b0)
      begin
         wr_data_count_r <= 8'b0000_0000;
      end
      else
      begin
         if(start_w==1'b1 && wr_count_clr_w==1'b0)
         begin
            if(data_load_r==1'b1)
            begin
               wr_data_count_r <= wr_data_count_r + 8'b0000_0001;
            end
            else
            begin
               wr_data_count_r <= wr_data_count_r;
            end
         end
         else
         begin
            wr_data_count_r <= 8'b0000_0000;
         end
      end
   end

   assign rd_count_clr_w = (rd_data_count_r==8'hBF)? 1'b1 : 1'b0;

   always @(negedge rstdec_x or posedge clkdec)
   begin : READ_DATA_COUNTER
      if(rstdec_x==1'b0)
      begin
         rd_data_count_r <= 8'b0000_0000;
      end
      else
      begin
         if(mbpl_dc_r[1]==1'b0)
         begin
            if(rd_start_r==1'b1 && rd_count_clr_w==1'b0)
            begin
               rd_data_count_r <= rd_data_count_r + 8'b0000_0001;
            end
            else
            begin
               rd_data_count_r <= 8'b0000_0000;
            end
         end
         else
         begin
            rd_data_count_r <= 8'b0000_0000;
         end
      end
   end


   always @(wr_data_count_r)
   begin
      case(wr_data_count_r)
         8'h07: load_adr_w = 9'h140;
         8'h0f: load_adr_w = 9'h108;
         8'h17: load_adr_w = 9'h148;
         8'h1f: load_adr_w = 9'h110;
         8'h27: load_adr_w = 9'h150;
         8'h2f: load_adr_w = 9'h118;
         8'h37: load_adr_w = 9'h158;
         8'h3f: load_adr_w = 9'h120;
         8'h47: load_adr_w = 9'h160;
         8'h4f: load_adr_w = 9'h128;
         8'h57: load_adr_w = 9'h168;
         8'h5f: load_adr_w = 9'h130;
         8'h67: load_adr_w = 9'h170;
         8'h6f: load_adr_w = 9'h138;
         8'h77: load_adr_w = 9'h178;
         8'h83: load_adr_w = 9'h190;
         8'h87: load_adr_w = 9'h184;
         8'h8B: load_adr_w = 9'h194;
         8'h8f: load_adr_w = 9'h188;
         8'h93: load_adr_w = 9'h198;
         8'h97: load_adr_w = 9'h18C;
         8'h9b: load_adr_w = 9'h19C;
         8'ha3: load_adr_w = 9'h1B0;
         8'ha7: load_adr_w = 9'h1A4;
         8'hab: load_adr_w = 9'h1B4;
         8'haf: load_adr_w = 9'h1A8;
         8'hb3: load_adr_w = 9'h1B8;
         8'hb7: load_adr_w = 9'h1AC;
         8'hbb: load_adr_w = 9'h1BC;
         default: load_adr_w = 9'h000;
      endcase
   end

   assign interace_add_w = (interace_adr_r + 8'b0000_0001);
   assign interace_adr_w = (load_adr_w[8]==1'b1)? load_adr_w[7:0] : interace_add_w;

   always @(negedge rstdec_x or posedge clkdec)
   begin 
      if(rstdec_x==1'b0)
      begin
         interace_adr_r <= 8'b0000_0000;
      end
      else
      begin
         if(mbpl_mc_r[12]==1'b0)
         begin
            if(wr_interace_start_r && wr_count_clr_w==1'b0)
            begin
               if(data_load_r==1'b1)
               begin
                  interace_adr_r <= interace_adr_w;
               end
               else
               begin
                  interace_adr_r <= interace_adr_r;
               end
            end
            else
            begin
               interace_adr_r <= 8'b0000_0000;
            end
         end
         else
         begin
               interace_adr_r <= 8'b0000_0000;
         end
      end
   end

   assign wadr0_sel_w = (wr_interace_start_r==1'b1)? interace_adr_r : wr_data_count_r;
   assign adr0_w = (start_w==1'b1    & mem_sel_r==1'b0)? wadr0_sel_w :
                      (rd_start_r==1'b1 & mem_sel_r==1'b1)? rd_data_count_r : 8'h00;

   always @(negedge rstdec_x or posedge clkdec)
   begin 
      if(rstdec_x==1'b0)
      begin
         m_adr0_r <= 8'b0000_0000;
      end
      else
      begin
         m_adr0_r <= adr0_w;
      end
   end

   assign wadr1_sel_w = (wr_interace_start_r==1'b1)? interace_adr_r : wr_data_count_r;
   assign adr1_w = (start_w==1'b1    & mem_sel_r==1'b1)? wadr1_sel_w :
                      (rd_start_r==1'b1 & mem_sel_r==1'b0)? rd_data_count_r : 8'h00;

   always @(negedge rstdec_x or posedge clkdec)
   begin 
      if(rstdec_x==1'b0)
      begin
         m_adr1_r <= 8'b0000_0000;
      end
      else
      begin
         m_adr1_r <= adr1_w;
      end
   end

   assign v1_rit00_a = m_adr0_r;  //MEMORY1 ADDRESS OUT
   assign v1_rit01_a = m_adr1_r;  //MEMORY2 ADDRESS OUT

   always @(negedge rstdec_x or posedge clkdec)
   begin : MEMORY_SELECT
      if(rstdec_x==1'b0)
      begin
         mem_sel_r <= 1'b0;
      end
      else
      begin
         if(wr_count_clr_w==1'b1) begin
            mem_sel_r <= ~mem_sel_r;
         end
      end
   end

   always @(negedge rstdec_x or posedge clkdec)
   begin 
      if(rstdec_x==1'b0)
      begin
         rit00_we_r <= 1'b0;
         rit01_we_r <= 1'b0;
      end
      else
      begin
         rit00_we_r <= data_load_r & ~mem_sel_r;
         rit01_we_r <= data_load_r & mem_sel_r;
      end
   end

   assign v1_rit00_we = rit00_we_r;
   assign v1_rit01_we = rit01_we_r;

   assign wr_bs0_w = (start_w & ~mem_sel_r) | (rd_start_r & mem_sel_r);
   assign wr_bs1_w = (start_w & mem_sel_r) | (rd_start_r & ~mem_sel_r);

   always @(negedge rstdec_x or posedge clkdec)
   begin : MEMORY_BS
      if(rstdec_x==1'b0)
      begin
         rit00_bs_r <= 1'b0;
         rit01_bs_r <= 1'b0;
      end
      else
      begin
         rit00_bs_r <= wr_bs0_w;
         rit01_bs_r <= wr_bs1_w;
      end
   end

   assign v1_rit00_bs = rit00_bs_r;
   assign v1_rit01_bs = rit01_bs_r;


   always @(negedge rstdec_x or posedge clkdec)
   begin 
      if(rstdec_x==1'b0)
      begin
         decyen_r[0] <= 1'b0;
         deccen_r[0] <= 1'b0;
      end
      else
      begin
         if((rd_data_count_r > 8'h00) && (rd_data_count_r < 8'h80))
         begin
            decyen_r[0] <= 1'b1;
            deccen_r[0] <= 1'b0;
         end
         else
         begin
            if((rd_data_count_r >= 8'h80) && (rd_data_count_r < 8'hC0))
            begin
               decyen_r[0] <= 1'b0;
               deccen_r[0] <= 1'b1;
            end
            else
            begin
               decyen_r[0] <= 1'b0;
               deccen_r[0] <= 1'b0;
            end
         end
      end
   end

   always @(negedge rstdec_x or posedge clkdec)
   begin
      if(rstdec_x==1'b0)
      begin
         decyen_r[1] <= 1'b0;
         deccen_r[1] <= 1'b0;
         decyen_r[2] <= 1'b0;
         deccen_r[2] <= 1'b0;
         decyen_r[3] <= 1'b0;
         deccen_r[3] <= 1'b0;
      end
      else
      begin
         decyen_r[1] <= decyen_r[0];
         deccen_r[1] <= deccen_r[0];
         decyen_r[2] <= decyen_r[1];
         deccen_r[2] <= deccen_r[1];
         decyen_r[3] <= decyen_r[2];
         deccen_r[3] <= deccen_r[2];
      end
   end

   assign m_decyen_r = decyen_r[2] | decyen_r[3] | frm_prog_r[1];
   assign m_deccen_r = deccen_r[3] | frm_prog_over_r[1];

   always @(negedge rstdec_x or posedge clkdec)
   begin : OUTPUT_DATA_LATCH
      if(rstdec_x==1'b0)
      begin
         m_decdt_r <= 16'h0000;
      end
      else
      begin
         if(mem_sel_r==1'b1)
         begin 
            m_decdt_r <= rit00_q_r;
         end
         else
         begin
            m_decdt_r <= rit01_q_r;
         end
      end
   end


endmodule

