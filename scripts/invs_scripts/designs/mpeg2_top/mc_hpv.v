// ----------------------------------------------
// File: mc_hpv.v
// Module: mc_hpv
// Function:
// ----------------------------------------------

module mc_hpv( 
   clkdec, 
   rstdec_x, 
   m_half_vpelf_r, 
   m_line_sel_r, 
   m_scan_even_r, 
   m_scan_odd_r, 
   m_halfvdt_r
);


input        clkdec; 
input        rstdec_x;
input        m_half_vpelf_r;
input        m_line_sel_r; 
input  [8:0] m_scan_even_r;
input  [8:0] m_scan_odd_r; 
output [7:0] m_halfvdt_r; 

wire        clkdec;
wire        rstdec_x;
wire        m_half_vpelf_r;
wire        m_line_sel_r;
wire [8:0]  m_scan_even_r;
wire [8:0]  m_scan_odd_r;
wire [1:0] m_add_acandt1_0;
wire [6:0] m_add_acandt8_2;
wire [8:0] m_add_scandt;
wire       m_co_scandt;
wire [7:0] m_halfvdt;
wire       m_sel_scan_even;
wire       m_sel_scan_odd;

reg [7:0]  m_halfvdt_r;
reg       m_half_vpelf_r_r;
reg       m_line_sel_r_r;
reg [8:0] m_scan_even_r_r;
reg [8:0] m_scan_evendt;
reg [8:0] m_scan_odd_r_r;
reg [8:0] m_scan_odddt;
reg [6:0] m_half_vpelf_dly_r; 

   assign m_sel_scan_odd = ~m_line_sel_r_r | m_half_vpelf_r_r;

   assign m_sel_scan_even = m_line_sel_r_r | m_half_vpelf_r_r;

always @(posedge clkdec or negedge rstdec_x)
begin
   if (!rstdec_x)
   begin
      m_scan_even_r_r <= 9'd0;
   end
   else
   begin
      m_scan_even_r_r <= m_scan_even_r;
   end
end

always @(posedge clkdec or negedge rstdec_x)
begin
   if (!rstdec_x)
   begin
      m_scan_odd_r_r <= 9'd0;
   end
   else
   begin
      m_scan_odd_r_r <= m_scan_odd_r;
   end
end

always @(posedge clkdec or negedge rstdec_x)
begin
   if (!rstdec_x)
   begin
      m_line_sel_r_r <= 1'd0;
   end
   else
   begin
      m_line_sel_r_r <= m_line_sel_r;
   end
end

always @(posedge clkdec or negedge rstdec_x)
begin
   if (!rstdec_x)
   begin
      m_half_vpelf_dly_r <= 7'h00;
      m_half_vpelf_r_r <= 1'd0;
   end
   else
   begin
      m_half_vpelf_dly_r <= {m_half_vpelf_dly_r[5:0],m_half_vpelf_r};
      m_half_vpelf_r_r <= m_half_vpelf_dly_r[6];
   end
end

assign {m_co_scandt, m_add_scandt} = m_scan_odddt + m_scan_evendt;

assign m_halfvdt = {m_co_scandt,m_add_acandt8_2};

assign {m_add_acandt8_2,m_add_acandt1_0} = m_add_scandt;

always @(posedge clkdec or negedge rstdec_x)
begin
   if (!rstdec_x)
   begin
      m_halfvdt_r <= 8'd0;
   end
   else
   begin
      m_halfvdt_r <= m_halfvdt;
   end
end

always @(m_scan_even_r_r or m_scan_odd_r_r or m_sel_scan_odd) begin
case (m_sel_scan_odd)
   1'd0: m_scan_odddt = m_scan_even_r_r;
   default: m_scan_odddt = m_scan_odd_r_r;
endcase
end

always @(m_scan_odd_r_r or m_scan_even_r_r or m_sel_scan_even) begin
case (m_sel_scan_even)
   1'd0: m_scan_evendt = m_scan_odd_r_r;
   default: m_scan_evendt = m_scan_even_r_r;
endcase
end

endmodule


