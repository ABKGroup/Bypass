// ----------------------------------------------
// File: iq_pastdc.v
// Module: iq_pastdc
// Function:Generate PastDC value
// ----------------------------------------------

module iq_pastdc(
  clkdec,
  rstdec_x,
  slcsf_reg,
  iyxst_reg,
  icbst_reg,
  icrst_reg,
  ybr0_reg,
  cbblk_reg,
  crblk_reg,
  pintr_reg,
  smd2,
  iqpastdc_reg
  );
   
  input clkdec;  
  input rstdec_x;
  input slcsf_reg;    // Slice Home,Intra DC DPCM Reset
  input iyxst_reg;    // DPCM:IQ Yx DC latch enable
  input icbst_reg;    // DPCM:IQ CBx DC latch enable
  input icrst_reg;    // DPCM:IQ CRx DC latch enable
  input ybr0_reg;     // DPCM:Y0,CB0,CR0 Flag   
  input cbblk_reg;    // DPCM:CBx Cycle Flag
  input crblk_reg;    // DPCM:CRx Cycle Flag
  input pintr_reg;    // DPCM:Inter/Intra before 1MB
  input [11:0] smd2;  // without limit data for pastDC

  output [15:0] iqpastdc_reg; // IQ PAST DC data

  reg [11:0] iqydc_reg;     // IQ DC value latch -Y
  reg [11:0] iqbdc_reg;     // IQ DC value latch -Cb
  reg [11:0] iqrdc_reg;     // IQ DC value latch -Cr
  reg [11:0] iqpdc;         // IQ PastDC
  reg [15:0] iqpastdc_reg;  // IQ PastDC value latch

  always @(posedge clkdec or negedge rstdec_x)
    if (!rstdec_x)
      iqydc_reg <= 12'h000;
    else begin
      if (iyxst_reg == 1'b1)
        iqydc_reg <= smd2;
      else
        iqydc_reg <= iqydc_reg;
    end

  always @(posedge clkdec or negedge rstdec_x)
    if (!rstdec_x)
      iqbdc_reg <= 12'h000;
    else begin
      if (icbst_reg == 1'b1)
        iqbdc_reg <= smd2;
      else
        iqbdc_reg <= iqbdc_reg;
    end

  always @(posedge clkdec or negedge rstdec_x)
    if (!rstdec_x)
      iqrdc_reg <= 12'h000;
    else begin
      if (icrst_reg == 1'b1)
        iqrdc_reg <= smd2;
      else
        iqrdc_reg <= iqrdc_reg;
      end

  always @(slcsf_reg or pintr_reg or cbblk_reg or crblk_reg or 
           ybr0_reg or iqrdc_reg or iqbdc_reg or iqydc_reg )
    if (ybr0_reg == 1'b1 && ( slcsf_reg == 1'b1 || pintr_reg == 1'b0 ))
      iqpdc = 12'd1024;
    else if ( crblk_reg == 1'b1)
      iqpdc = iqrdc_reg;
    else if ( cbblk_reg == 1'b1)
      iqpdc = iqbdc_reg;
    else
    iqpdc = iqydc_reg;

  always @(posedge clkdec)
    iqpastdc_reg <= {{4{iqpdc[11]}},iqpdc};
 
endmodule


