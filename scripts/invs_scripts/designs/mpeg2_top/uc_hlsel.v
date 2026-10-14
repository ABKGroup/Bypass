// ----------------------------------------------
// File: uc_hlsel.v
// Module: uc_hlsel
// Function:Up Convert Horizontal Filter
//                            SDTV/HDTV Selector
// ----------------------------------------------

module uc_hlsel(
  clkdec,
  rstdec_x,
  u_vyen_d1_r,
  u_vcen_d1_r,
  u_hyen_r,
  u_hcen_r,
  u_hdt_r,
  u_sdtvdth_r,
  u_hdtvhh_r,
  u_hopstp_r,
  u_ref1dt_r,
  u_ref1yen_r,
  u_ref1cen_r
  );
  
  input         clkdec;         
  input         rstdec_x;       
  input         u_vyen_d1_r;     
  input         u_vcen_d1_r;     
  input         u_hyen_r;        
  input         u_hcen_r;        
  input [15:0]  u_hdt_r;         
  input [15:0]  u_sdtvdth_r;     
  input         u_hdtvhh_r;      
  input         u_hopstp_r;      
  output [15:0] u_ref1dt_r;      
  output        u_ref1yen_r;     
  output        u_ref1cen_r;     
  
  wire          u_vyen_d1_r;          // MB Data Enable(Y/SDTV)
  wire          u_vcen_d1_r;          // MB Data Enable(C/SDTV)
  wire          u_hyen_r;             // MB Data Enable(Y/HDTV)
  wire          u_hcen_r;             // MB Data Enable(C/HDTV)
  wire [15:0]   u_hdt_r;              // MB Data(HDTV)
  wire [15:0]   u_sdtvdth_r;          // MB Data(SDTV)
  wire          u_hdtvhh_r;           // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  wire          u_hopstp_r;           // MB Estimate Valid Flag
  
  reg [15:0]    u_ref1dt_r;           // MB Data
  reg           u_ref1yen_r;          // MB Data Enable(Y)
  reg           u_ref1cen_r;          // MB Data Enable(C)
  reg [6:0]     u_hyen_dly_r,         // u_hyen_r Delay
                u_hcen_dly_r;         // u_cyen_r

  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hyen_dly_r <= 7'b0;
      u_hcen_dly_r <= 7'b0;
    end
    else begin
      u_hyen_dly_r <= {u_hyen_dly_r[5:0],u_hyen_r};
      u_hcen_dly_r <= {u_hcen_dly_r[5:0],u_hcen_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ref1dt_r  <= 16'b0;
      u_ref1yen_r <= 1'b0;
      u_ref1cen_r <= 1'b0;
    end
    else if( u_hdtvhh_r ) begin
      u_ref1dt_r  <= u_hdt_r;
      u_ref1yen_r <= u_hyen_dly_r[6];
      u_ref1cen_r <= u_hcen_dly_r[6];
    end
    else begin
      u_ref1dt_r  <= u_sdtvdth_r & {16{u_hopstp_r}};
      u_ref1yen_r <= u_vyen_d1_r & u_hopstp_r;
      u_ref1cen_r <= u_vcen_d1_r & u_hopstp_r;
    end
  end
  
  
endmodule
