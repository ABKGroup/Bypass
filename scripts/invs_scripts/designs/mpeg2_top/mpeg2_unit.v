//

module mpeg2_unit (
  clk ,
  hresetn ,
  haddr_s ,
  hwdata_s ,
  hrdata_mp2 ,
  hresp_mp2 ,
  hwrite_s ,
  hsel_mp2 ,
  hready_mp2 ,
  power_off_mp2 ,

  m_mclk ,
  resetn_dec ,
  m_v1_dmareq8_n ,
  m_mr_dmaack8_n ,
  m_sc_dmaack8_n ,
  v1_int18_n ,
  v1_int23_n ,
  m_y1_bs_wait_n ,
  m_v1_bs_req_n ,
  m_v1_sd_pichead_s ,
  m_y1_bs_data ,
  m_v1_dspfld_num1 ,
  m_v1_dspfld_sc1 ,
  m_v1_dspfld_num2 ,
  m_v1_dspfld_sc2 ,
  m_v1_dsp_ps ,
  m_vmem_wen ,
  m_vmem_we ,
  m_vmem_we_n ,
  m_vmem_ren ,
  m_vmem_add ,
  m_vmem_data_out ,
  m_vmem_data_in ,
  v_mode_mpeg1 ,
  m_vmem_ch 
);

  input         clk ;
  input         m_mclk ;
  input         hresetn ;
  input         resetn_dec ;
  input  [31:0] haddr_s ;
  input  [31:0] hwdata_s ;
  output [31:0] hrdata_mp2 ;
  output  [1:0] hresp_mp2 ;
  input         hwrite_s ;
  input         hsel_mp2 ;
  output        hready_mp2 ;
  input         power_off_mp2 ;

  output        m_v1_dmareq8_n ;
  input         m_mr_dmaack8_n ;
  input         m_sc_dmaack8_n ;
  output        v1_int18_n ;
  output        v1_int23_n ;
  input         m_y1_bs_wait_n ;
  output        m_v1_bs_req_n ;
  output        m_v1_sd_pichead_s ;
  input  [31:0] m_y1_bs_data ;
  output  [3:0] m_v1_dspfld_num1 ;
  output        m_v1_dspfld_sc1 ;
  output  [3:0] m_v1_dspfld_num2 ;
  output        m_v1_dspfld_sc2 ;
  output        m_v1_dsp_ps ;
  output        m_vmem_wen ;
  output  [3:0] m_vmem_we ;
  output  [3:0] m_vmem_we_n ;
  output        m_vmem_ren ;
  output [25:0] m_vmem_add ;
  output [31:0] m_vmem_data_out ;
  input  [31:0] m_vmem_data_in ;
  input         v_mode_mpeg1 ;
  input         m_vmem_ch ;

 wire   [31:0]  addr_o_mp2;
 wire   [31:0]  data_o_s;
 wire   [31:0]  addr_i_mp2;
 wire   [3:0]   sel_i_mp2;
 wire   [31:0]  data_i_mp2;
 wire   [3:0]   sel_o_mp2;
 wire   [31:0]  data_o_mp2;

ahb_wb_mpeg2 u_ahb_wb_mpeg2 (
  .hclk(clk),
  .hrst_x(hresetn),
  .haddr(haddr_s),
  .hwdata(hwdata_s),
  .hrdata(hrdata_mp2),
  .hresp(hresp_mp2),
  .hwrite(hwrite_s),
  .hsel(hsel_mp2),
  .hready(hready_mp2),
  .power_off(power_off_mp2),
  .wb_addr_i(addr_i_mp2),
  .wb_data_i(data_i_mp2),
  .wb_data_o(data_o_mp2),
  .wb_ack_o(ack_o_mp2),
  .wb_we_i(we_i_mp2),
  .wb_stb_i(stb_i_mp2)
);

mpeg2_top u_mpeg2 (
  .clkdec(m_mclk),
  .clkbus(clk),
  .rstdec_x(resetn_dec),
  .rstbus_x(hresetn),
  .wbb_stb_i(stb_i_mp2),
  .wbb_we_i(we_i_mp2),
  .wbb_adr_i(addr_i_mp2[8:2]),
  .wbb_dat_i(data_i_mp2),
  .wbb_dat_o(data_o_mp2),
  .wbb_ack_o(ack_o_mp2),
  .v1_dmareq8_n(m_v1_dmareq8_n),
  .mr_dmaack8_n(m_mr_dmaack8_n),
  .sc_dmaack8_n(m_sc_dmaack8_n),
  .v1_int18_n(v1_int18_n),
  .v1_int23_n(v1_int23_n),
  .y1_bs_wait_n(m_y1_bs_wait_n),
  .v1_bs_req_n(m_v1_bs_req_n),
  .v1_sd_pichead_s(m_v1_sd_pichead_s),
  .y1_bs_data(m_y1_bs_data),
  .v1_dspfld_num1(m_v1_dspfld_num1),
  .v1_dspfld_sc1(m_v1_dspfld_sc1),
  .v1_dspfld_num2(m_v1_dspfld_num2),
  .v1_dspfld_sc2(m_v1_dspfld_sc2),
  .v1_dsp_ps(m_v1_dsp_ps),
  .vmem_wen(m_vmem_wen),
  .vmem_we(m_vmem_we),
  .vmem_we_n(m_vmem_we_n),
  .vmem_ren(m_vmem_ren),
  .vmem_add(m_vmem_add),
  .vmem_data_out(m_vmem_data_out),
  .vmem_data_in(m_vmem_data_in),
  .v_mode_mpeg1(v_mode_mpeg1),
  .vmem_ch(m_vmem_ch)
);

endmodule
