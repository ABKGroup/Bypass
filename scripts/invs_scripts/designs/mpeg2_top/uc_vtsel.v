// ----------------------------------------------
// File: uc_vtsel.v
// Module: uc_vtsel
// Function: Up Convert Vertical Filter
//                            SDTV/HDTV Selector
// ----------------------------------------------

module uc_vtsel(
  clkdec,
  rstdec_x,
  u_dt_r,
  u_yen_r,
  u_cen_r,
  u_refv_ysngl_r,
  u_refv_csngl_r,
  u_sdtvdt_r,
  u_syen_r,
  u_scen_r,
  u_hdtvh_r,
  u_ref1v_dt_r,
  u_ref1v_yen_r,
  u_ref1v_cen_r,
  u_ref1v_ysngl_r,
  u_ref1v_csngl_r
  );
  
  input         clkdec;     
  input         rstdec_x;   
  input [15:0]  u_dt_r;         
  input         u_yen_r;        
  input         u_cen_r;        
  input         u_refv_ysngl_r; 
  input         u_refv_csngl_r; 
  input [15:0]  u_sdtvdt_r;     
  input         u_syen_r;       
  input         u_scen_r;       
  input         u_hdtvh_r;      
  output [15:0] u_ref1v_dt_r;   
  output        u_ref1v_yen_r;  
  output        u_ref1v_cen_r;  
  output        u_ref1v_ysngl_r;
  output        u_ref1v_csngl_r;
  
  wire [15:0]   u_dt_r;               // Vertical Filter Data
  wire          u_yen_r;              // Vertical Filter Data Enable(Y)
  wire          u_cen_r;              // Vertical Filter Data Enable(C)
  wire          u_refv_ysngl_r;       // Vertical Data Single Flag(Y)
  wire          u_refv_csngl_r;       // Vertical Data Single Flag(C)
  wire [15:0]   u_sdtvdt_r;           // SDTV Data
  wire          u_syen_r;             // SDTV Data Enable(Y)
  wire          u_scen_r;             // SDTV Data Enable(C)
  wire          u_hdtvh_r;            // SDTV/HDTV Select
  
  reg [15:0]    u_ref1v_dt_r;         // Vertical Filter Data        
  reg           u_ref1v_yen_r;        // Vertical Filter Data Enable(Y)
  reg           u_ref1v_cen_r;        // Vertical Filter Data Enable(C)
  reg           u_ref1v_ysngl_r;      // Vertical Data Single Flag(Y)
  reg           u_ref1v_csngl_r;      // Vertical Data Single Flag(C)
  
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ref1v_dt_r     <= 16'b0;
      u_ref1v_yen_r    <= 1'b0;
      u_ref1v_cen_r    <= 1'b0;
      u_ref1v_ysngl_r  <= 1'b0;
      u_ref1v_csngl_r  <= 1'b0;
    end
    else if( u_hdtvh_r ) begin
      u_ref1v_dt_r     <= u_dt_r;
      u_ref1v_yen_r    <= u_yen_r;
      u_ref1v_cen_r    <= u_cen_r;
      u_ref1v_ysngl_r  <= u_refv_ysngl_r;
      u_ref1v_csngl_r  <= u_refv_csngl_r;
    end
    else begin
      u_ref1v_dt_r     <= u_sdtvdt_r;
      u_ref1v_yen_r    <= u_syen_r;
      u_ref1v_cen_r    <= u_scen_r;
      u_ref1v_ysngl_r  <= 1'b0;
      u_ref1v_csngl_r  <= 1'b0;
    end
  end
  
  
endmodule
