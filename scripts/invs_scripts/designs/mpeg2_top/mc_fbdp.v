// ----------------------------------------------
// File: mc_fbdp.v
// Module: mc_fbdp
// Function:
// ----------------------------------------------

module mc_fbdp (
  clkdec,
  rstdec_x,
  p_pred_forward_buc_r,
  p_pred_backward_buc_r,
  p_mbtyp_0_buc_r,
  m_forward_data_r,
  m_backward_data_r,
  m_pred_dat_r,
  m_calc_dat_r,
  m_motion_dp_r
                   );

   input clkdec;
   input rstdec_x;
   input [7:0]m_forward_data_r;  
   input [7:0]m_backward_data_r; 
   input [8:0]m_pred_dat_r;
   input p_pred_forward_buc_r;   
   input p_pred_backward_buc_r;  
   input p_mbtyp_0_buc_r;        
   output [7:0]m_calc_dat_r;
   input m_motion_dp_r;      

   reg [7:0]forward_d_r;
   reg [7:0]backward_d_r;
   reg [8:0]pred0_d_r;         
   reg [8:0]pred1_d_r;
   reg [8:0]pred2_d_r;
   reg [8:0]pred3_d_r;
   reg [8:0]pred4_d_r;
   reg [8:0]ff_pred_d_r;
   reg pred_forward_r;
   reg pred_backward_r;
   reg intra0_r;
   reg dual_pirme_r;           

   reg [7:0]add_u9_calc_p;
   reg [7:0]pred_d_r;

   wire sel_pred_forward;
   wire sel_pred_backward;
   wire [7:0]forward_sel;
   wire [7:0]backward_sel;
   wire [8:0]add_u9_calc;
   wire [7:0]gate_u8_w;
   wire [9:0]add_s10_calc;

   always @(negedge rstdec_x or posedge clkdec)
   begin : INPUT_SIGNAL_LATCH
      if(rstdec_x==1'b0)
       begin
         forward_d_r   <= 8'b0000_0000;
         backward_d_r  <= 8'b0000_0000;
         pred0_d_r <= 9'b0_0000_0000;
         pred1_d_r <= 9'b0_0000_0000;
         pred2_d_r <= 9'b0_0000_0000;
         pred3_d_r <= 9'b0_0000_0000;
         pred4_d_r <= 9'b0_0000_0000;
         ff_pred_d_r  <= 9'b0_0000_0000;
         pred_forward_r  <= 1'b0;
         pred_backward_r <= 1'b0;
         intra0_r <= 1'b0;
         dual_pirme_r <= 1'b0;
      end
      else
      begin
         forward_d_r   <= m_forward_data_r;
         backward_d_r  <= m_backward_data_r;
         pred0_d_r <= m_pred_dat_r;
         pred1_d_r <= pred0_d_r;
         pred2_d_r <= pred1_d_r;
         pred3_d_r <= pred2_d_r;
         pred4_d_r <= pred3_d_r;
         ff_pred_d_r  <= pred4_d_r;
         pred_forward_r  <= p_pred_forward_buc_r;
         pred_backward_r <= p_pred_backward_buc_r;
         intra0_r <= p_mbtyp_0_buc_r;
         dual_pirme_r <= m_motion_dp_r;
      end
   end

   assign sel_pred_forward = pred_forward_r | dual_pirme_r;
   assign sel_pred_backward = pred_backward_r | dual_pirme_r;
   assign forward_sel = (sel_pred_forward)? forward_d_r : backward_d_r;
   assign backward_sel = (sel_pred_backward) ? backward_d_r : forward_d_r;
   assign add_u9_calc = ({1'b0,forward_sel} + {1'b0,backward_sel}) + 9'b0_0000_0001;

   always @(negedge rstdec_x or posedge clkdec)
   begin : U9_ADD_LATCH
      if(rstdec_x==1'b0)
      begin
         add_u9_calc_p <= 8'b0000_0000;  //v0.6 Modified
      end
      else
      begin
         add_u9_calc_p <= add_u9_calc[7:0];
      end
   end

   assign gate_u8_w = (~intra0_r)? add_u9_calc_p : 8'b0000_0000;
   assign add_s10_calc = {2'b00,gate_u8_w} + {ff_pred_d_r[8],ff_pred_d_r};

   always @(negedge rstdec_x or posedge clkdec)
   begin :OUTPUT_SIGNAL
      if(rstdec_x==1'b0)
      begin
         pred_d_r <= 8'b0000_0000;  //DATA CLEAR
      end
      else if(ff_pred_d_r[8]==1'b1 && add_s10_calc[8]==1'b1) 
      begin
         pred_d_r <= 8'b0000_0000;  //unsined change
      end
      else if(ff_pred_d_r[8]==1'b0 && add_s10_calc[8]==1'b1) 
      begin
         pred_d_r <= 8'b1111_1111;
      end
      else
      begin
         pred_d_r <= add_s10_calc[7:0];
      end
   end

   assign m_calc_dat_r = pred_d_r;

endmodule


