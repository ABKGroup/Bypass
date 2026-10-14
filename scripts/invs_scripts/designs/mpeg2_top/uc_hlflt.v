// ----------------------------------------------
// File: uc_hlflt.v
// Module: uc_hlflt
// Function:Up Convert Horizontal Filter Operation
// ----------------------------------------------

module uc_hlflt(
  clkdec,
  rstdec_x,
  u_refhdt1_r,
  u_refhdt2_r,
  u_hcoe1_r,
  u_hcoe2_r,
  u_hopstp_r,
  u_hdt_r
  );
  
  input         clkdec;       
  input         rstdec_x;     
  input [63:0]  u_refhdt1_r;    
  input [63:0]  u_refhdt2_r;    
  input [79:0]  u_hcoe1_r;      
  input [79:0]  u_hcoe2_r;      
  input         u_hopstp_r;     
  output [15:0] u_hdt_r;      

  wire [63:0]   u_refhdt1_r;          // Horizontal Reference Data1
  wire [63:0]   u_refhdt2_r;          // Horizontal Reference Data1
  wire [79:0]   u_hcoe1_r;            // Horizontal Coefficient1
  wire [79:0]   u_hcoe2_r;            // Horizontal Coefficient2
  wire          u_hopstp_r;           // MB Estimate Valid Flag
  
  reg [15:0]    u_hdt_r;              // MB Data
  reg [17:0]    u_hm00_r,             // Data Multi Result
                u_hm01_r,             // Data Multi Result
                u_hm02_r,             // Data Multi Result
                u_hm03_r;             // Data Multi Result
  reg [17:0]    u_hm04_r,             // Data Multi Result
                u_hm05_r,             // Data Multi Result
                u_hm06_r,             // Data Multi Result
                u_hm07_r;             // Data Multi Result
  reg [17:0]    u_hm10_r,             // Data Multi Result
                u_hm11_r,             // Data Multi Result
                u_hm12_r,             // Data Multi Result
                u_hm13_r;             // Data Multi Result
  reg [17:0]    u_hm14_r,             // Data Multi Result
                u_hm15_r,             // Data Multi Result
                u_hm16_r,             // Data Multi Result
                u_hm17_r;             // Data Multi Result
  reg [18:0]    u_ha00_r,             // Data Adder Result
                u_ha01_r,             // Data Adder Result
                u_ha02_r,             // Data Adder Result
                u_ha03_r;             // Data Adder Result
  reg [18:0]    u_ha10_r,             // Data Adder Result
                u_ha11_r,             // Data Adder Result
                u_ha12_r,             // Data Adder Result
                u_ha13_r;             // Data Adder Result
  reg [19:0]    u_ha04_r,             // Data Adder Result
                u_ha05_r;             // Data Adder Result
  reg [19:0]    u_ha14_r,             // Data Adder Result
                u_ha15_r;             // Data Adder Result
  reg [20:0]    u_ha06_r,             // Data Adder Result
                u_ha16_r;             // Data Adder Result
  reg [20:0]    u_pdt1_r,             // Controled Data1
                u_pdt3_r;             // Controled Data3
  reg [12:0]    u_pdt2_r,             // Controled Data2
                u_pdt4_r;             // Controled Data4
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hm00_r <= 18'b0;
    end
    else begin
      u_hm00_r <= {u_hcoe1_r[79:70]} * {10'b0,u_refhdt1_r[63:56]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hm01_r <= 18'b0;
    end
    else begin
      u_hm01_r <= {u_hcoe1_r[69:60]} * {10'b0,u_refhdt1_r[55:48]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hm02_r <= 18'b0;
    end
    else begin
      u_hm02_r <= {u_hcoe1_r[59:50]} * {10'b0,u_refhdt1_r[47:40]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hm03_r <= 18'b0;
    end
    else begin
      u_hm03_r <= {u_hcoe1_r[49:40]} * {10'b0,u_refhdt1_r[39:32]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hm04_r <= 18'b0;
    end
    else begin
      u_hm04_r <= {u_hcoe1_r[39:30]} * {10'b0,u_refhdt1_r[31:24]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hm05_r <= 18'b0;
    end
    else begin
      u_hm05_r <= {u_hcoe1_r[29:20]} * {10'b0,u_refhdt1_r[23:16]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hm06_r <= 18'b0;
    end
    else begin
      u_hm06_r <= {u_hcoe1_r[19:10]} * {10'b0,u_refhdt1_r[15:8]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hm07_r <= 18'b0;
    end
    else begin
      u_hm07_r <= {u_hcoe1_r[9:0]} * {10'b0,u_refhdt1_r[7:0]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hm10_r <= 18'b0;
    end
    else begin
      u_hm10_r <= {u_hcoe2_r[79:70]} * {10'b0,u_refhdt2_r[63:56]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hm11_r <= 18'b0;
    end
    else begin
      u_hm11_r <= {u_hcoe2_r[69:60]} * {10'b0,u_refhdt2_r[55:48]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hm12_r <= 18'b0;
    end
    else begin
      u_hm12_r <= {u_hcoe2_r[59:50]} * {10'b0,u_refhdt2_r[47:40]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hm13_r <= 18'b0;
    end
    else begin
      u_hm13_r <= {u_hcoe2_r[49:40]} * {10'b0,u_refhdt2_r[39:32]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hm14_r <= 18'b0;
    end
    else begin
      u_hm14_r <= {u_hcoe2_r[39:30]} * {10'b0,u_refhdt2_r[31:24]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hm15_r <= 18'b0;
    end
    else begin
      u_hm15_r <= {u_hcoe2_r[29:20]} * {10'b0,u_refhdt2_r[23:16]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hm16_r <= 18'b0;
    end
    else begin
      u_hm16_r <= {u_hcoe2_r[19:10]} * {10'b0,u_refhdt2_r[15:8]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hm17_r <= 18'b0;
    end
    else begin
      u_hm17_r <= {u_hcoe2_r[9:0]} * {10'b0,u_refhdt2_r[7:0]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ha00_r <= 19'b0;
    end
    else begin
      u_ha00_r <= {u_hm00_r[17],u_hm00_r} + {u_hm01_r[17],u_hm01_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ha01_r <= 19'b0;
    end
    else begin
      u_ha01_r <= {u_hm02_r[17],u_hm02_r} + {u_hm03_r[17],u_hm03_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ha02_r <= 19'b0;
    end
    else begin
      u_ha02_r <= {u_hm04_r[17],u_hm04_r} + {u_hm05_r[17],u_hm05_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ha03_r <= 19'b0;
    end
    else begin
      u_ha03_r <= {u_hm06_r[17],u_hm06_r} + {u_hm07_r[17],u_hm07_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ha10_r <= 19'b0;
    end
    else begin
      u_ha10_r <= {u_hm10_r[17],u_hm10_r} + {u_hm11_r[17],u_hm11_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ha11_r <= 19'b0;
    end
    else begin
      u_ha11_r <= {u_hm12_r[17],u_hm12_r} + {u_hm13_r[17],u_hm13_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ha12_r <= 19'b0;
    end
    else begin
      u_ha12_r <= {u_hm14_r[17],u_hm14_r} + {u_hm15_r[17],u_hm15_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ha13_r <= 19'b0;
    end
    else begin
      u_ha13_r <= {u_hm16_r[17],u_hm16_r} + {u_hm17_r[17],u_hm17_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ha04_r <= 20'b0;
    end
    else begin
      u_ha04_r <= {u_ha00_r[18],u_ha00_r} + {u_ha01_r[18],u_ha01_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ha05_r <= 20'b0;
    end
    else begin
      u_ha05_r <= {u_ha02_r[18],u_ha02_r} + {u_ha03_r[18],u_ha03_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ha14_r <= 20'b0;
    end
    else begin
      u_ha14_r <= {u_ha10_r[18],u_ha10_r} + {u_ha11_r[18],u_ha11_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ha15_r <= 20'b0;
    end
    else begin
      u_ha15_r <= {u_ha12_r[18],u_ha12_r} + {u_ha13_r[18],u_ha13_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ha06_r <= 21'b0;
    end
    else begin
      u_ha06_r <= {u_ha04_r[19],u_ha04_r} + {u_ha05_r[19],u_ha05_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_ha16_r <= 21'b0;
    end
    else begin
      u_ha16_r <= {u_ha14_r[19],u_ha14_r} + {u_ha15_r[19],u_ha15_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_pdt1_r <= 21'b0;
      u_pdt3_r <= 21'b0;
    end
    else if( u_hopstp_r ) begin
      u_pdt1_r <= u_ha06_r;
      u_pdt3_r <= u_ha16_r;
    end
    else begin
      u_pdt1_r <= 21'b0;
      u_pdt3_r <= 21'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_pdt2_r <= 13'b0;
    end
    else begin
      u_pdt2_r <= u_pdt1_r[20:8] + u_pdt1_r[7:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_pdt4_r <= 13'b0;
    end
    else begin
      u_pdt4_r <= u_pdt3_r[20:8] + u_pdt3_r[7:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_hdt_r <= 16'b0;
    end
    else begin
      u_hdt_r[15:8] <= ({8{~u_pdt2_r[12]}}) & ( {8{u_pdt2_r[11:8] != 4'h0}} | u_pdt2_r[7:0] );
      u_hdt_r[7:0]  <= ({8{~u_pdt4_r[12]}}) & ( {8{u_pdt4_r[11:8] != 4'h0}} | u_pdt4_r[7:0] );
    end
  end
  
  
endmodule
