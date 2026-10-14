// ----------------------------------------------
// File: mc_hph.v
// Module: mc_hph
// Function:
// ----------------------------------------------

module mc_hph( 
   clkdec, 
   rstdec_x, 
   m_half_hpelf_r, 
   u_ref1dt_r, 
   m_halfhdt_r
);


  input         clkdec;    
  input         rstdec_x;  
  input         m_half_hpelf_r;   
  input  [15:0] u_ref1dt_r;       
  output [17:0] m_halfhdt_r;      
  
  wire          clkdec;
  wire          rstdec_x;
  wire          m_half_hpelf_r;
  wire [15:0]   u_ref1dt_r;
  reg  [17:0]   m_halfhdt_r;
  
  wire          m_add_co0;
  wire          m_add_co1;
  wire [7:0]    m_add_dt0;
  wire [7:0]    m_add_dt1;
  reg  [7:0]    m_eldt0;
  reg           m_half_hpelf_r_r;
  wire [17:0]   m_halfhdt;
  wire [8:0]    m_halfhdt0;
  reg  [8:0]    m_halfhdt0_r;
  wire [8:0]    m_halfhdt1;
  wire [7:0]    m_ref1dt0_r;
  wire [7:0]    m_ref1dt1_r;
  reg  [7:0]    m_ref1dt1_r_r;
  reg  [15:0]   m_ref1dt_r;
  reg  [7:0]    m_seldt1;
  reg  [15:0]   m_ref1dt_d1_r;  
  reg  [15:0]   m_ref1dt_d2_r;  
  reg  [15:0]   m_ref1dt_d3_r;  
  
  always @(posedge clkdec or negedge rstdec_x)
  begin
    if (!rstdec_x)
    begin
      m_half_hpelf_r_r <= 1'd0;
    end
    else
    begin
      m_half_hpelf_r_r <= m_half_hpelf_r;
    end
  end
  
  assign {m_ref1dt0_r,m_ref1dt1_r} = m_ref1dt_r;
  
  always @(m_ref1dt0_r or m_ref1dt1_r or m_half_hpelf_r_r)
  begin
    case (m_half_hpelf_r_r)
      1'd0: m_eldt0 = m_ref1dt0_r;
      default: m_eldt0 = m_ref1dt1_r;
    endcase
  end

  assign {m_add_co0, m_add_dt0} = m_eldt0 + m_ref1dt0_r + 8'b0000001;
  
  assign m_halfhdt0 = {m_add_co0,m_add_dt0};
  
  always @(posedge clkdec or negedge rstdec_x)
  begin
    if (!rstdec_x)
    begin
      m_ref1dt_d1_r <= 16'h0000;
      m_ref1dt_d2_r <= 16'h0000;
      m_ref1dt_d3_r <= 16'h0000;
      m_ref1dt_r    <= 16'h0000;
    end
    else
    begin
      m_ref1dt_d1_r <= u_ref1dt_r;
      m_ref1dt_d2_r <= m_ref1dt_d1_r;
      m_ref1dt_d3_r <= m_ref1dt_d2_r;
      m_ref1dt_r    <= m_ref1dt_d3_r;
    end
  end
  
  always @(m_ref1dt1_r_r or m_ref1dt0_r or m_half_hpelf_r_r)
  begin
    case (m_half_hpelf_r_r)
      1'd0: m_seldt1 = m_ref1dt1_r_r;
      default: m_seldt1 = m_ref1dt0_r;
    endcase
  end
  
  always @(posedge clkdec or negedge rstdec_x)
  begin
    if (!rstdec_x)
    begin
      m_ref1dt1_r_r <= 8'd0;
    end
    else
    begin
      m_ref1dt1_r_r <= m_ref1dt1_r;
    end
  end
  
  assign {m_add_co1, m_add_dt1} = m_seldt1 + m_ref1dt1_r_r + 8'b00000001;
  
  always @(posedge clkdec or negedge rstdec_x)
  begin
    if (!rstdec_x)
    begin
      m_halfhdt0_r <= 9'd0;
    end
    else
    begin
      m_halfhdt0_r <= m_halfhdt0;
    end
  end
  
  assign m_halfhdt = {m_halfhdt0_r,m_halfhdt1};
  
  assign m_halfhdt1 = {m_add_co1,m_add_dt1};
  
  always @(posedge clkdec or negedge rstdec_x)
  begin
    if (!rstdec_x)
    begin
      m_halfhdt_r <= 18'd0;
    end
    else
    begin
      m_halfhdt_r <= m_halfhdt;
    end
  end
  
endmodule
