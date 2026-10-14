// ----------------------------------------------
// File: uc_vtflt.v
// Module: uc_vtflt
// Function:Up Convert Vertical Filter Operation
// ----------------------------------------------

module uc_vtflt(
  clkdec,
  rstdec_x,
  u_refdt_r,
  u_refyen_r,
  u_refcen_r,
  u_coe1_r,
  u_coe2_r,
  u_ysngl_r,
  u_csngl_r,
  u_opstp_r,
  u_dt_r,
  u_yen_r,
  u_cen_r,
  u_refv_ysngl_r,
  u_refv_csngl_r
  );
  
  input         clkdec;       
  input         rstdec_x;     
  input [31:0]  u_refdt_r;    
  input         u_refyen_r;   
  input         u_refcen_r;   
  input [39:0]  u_coe1_r;     
  input [39:0]  u_coe2_r;     
  input         u_ysngl_r;    
  input         u_csngl_r;    
  input         u_opstp_r;    
  output [15:0] u_dt_r;       
  output        u_yen_r;      
  output        u_cen_r;       
  output        u_refv_ysngl_r;
  output        u_refv_csngl_r;
  
  wire [31:0]   u_refdt_r;            // Vertical Fileter Reference Data
  wire          u_refyen_r;           // Vertical Fileter Reference Data Enable(Y)
  wire          u_refcen_r;           // Vertical Fileter Reference Data Enable(C)
  wire [39:0]   u_coe1_r;             // Vertical Fileter Coefficient1
  wire [39:0]   u_coe2_r;             // Vertical Fileter Coefficient2
  wire          u_ysngl_r;            // Vertical Data Single Flag(Y)
  wire          u_csngl_r;            // Vertical Data Single Flag(C)
  wire          u_opstp_r;            // Vertical Filater Operation Stop
 
  reg [15:0]    u_dt_r;               // Vertical Filter Data
  reg           u_yen_r;              // Vertical Filter Data Enable(Y)
  reg           u_cen_r;              // Vertical Filter Data Enable(C)
  reg           u_refv_ysngl_r;       // Vertical Data Single Flag(Y)
  reg           u_refv_csngl_r;       // Vertical Data Single Flag(C)
  reg [17:0]    u_vm0_r,              // Data Multi Result
                u_vm1_r,              // Data Multi Result
                u_vm2_r,              // Data Multi Result
                u_vm3_r;              // Data Multi Result
  reg [17:0]    u_vm4_r,              // Data Multi Result
                u_vm5_r,              // Data Multi Result
                u_vm6_r,              // Data Multi Result
                u_vm7_r;              // Data Multi Result
  reg [18:0]    u_va0_r,              // Data Adder Result
                u_va1_r,              // Data Adder Result
                u_va2_r,              // Data Adder Result
                u_va3_r;              // Data Adder Result
  reg [19:0]    u_va4_r,              // Data Adder Result
                u_va5_r;              // Data Adder Result
  reg [4:0]     u_ysngl_dly_r,        // Data Single(Y) Flag Delay
                u_csngl_dly_r,        // Data Single(C) Flag Delay
                u_refyen_dly_r,       // Data Enable(Y) Delay
                u_refcen_dly_r;       // Data Enable(C) Delay
  reg [19:0]    u_pdt1_r,             // Controled Data1
                u_pdt3_r;             // Controled Data3
  reg [11:0]    u_pdt2_r,             // Controled Data2
                u_pdt4_r;             // Controled Data4

  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vm0_r <= 18'b0;
    end
    else begin
      u_vm0_r <= {u_coe1_r[39:30]} * {10'b0,u_refdt_r[31:24]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vm1_r <= 18'b0;
    end
    else begin
      u_vm1_r <= {u_coe1_r[29:20]} * {10'b0,u_refdt_r[23:16]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vm2_r <= 18'b0;
    end
    else begin
      u_vm2_r <= {u_coe1_r[19:10]} * {10'b0,u_refdt_r[15:8]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vm3_r <= 18'b0;
    end
    else begin
      u_vm3_r <= {u_coe1_r[9:0]} * {10'b0,u_refdt_r[7:0]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vm4_r <= 18'b0;
    end
    else begin
      u_vm4_r <= {u_coe2_r[39:30]} * {10'b0,u_refdt_r[31:24]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vm5_r <= 18'b0;
    end
    else begin
      u_vm5_r <= {u_coe2_r[29:20]} * {1'b0,u_refdt_r[23:16]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vm6_r <= 18'b0;
    end
    else begin
      u_vm6_r <= {u_coe2_r[19:10]} * {10'b0,u_refdt_r[15:8]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_vm7_r <= 18'b0;
    end
    else begin
      u_vm7_r <= {u_coe2_r[9:0]} * {10'b0,u_refdt_r[7:0]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_va0_r <= 19'b0;
    end
    else begin
      u_va0_r <= {u_vm0_r[17],u_vm0_r} + {u_vm1_r[17],u_vm1_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_va1_r <= 19'b0;
    end
    else begin
      u_va1_r <= {u_vm2_r[17],u_vm2_r} + {u_vm3_r[17],u_vm3_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_va2_r <= 19'b0;
    end
    else begin
      u_va2_r <= {u_vm4_r[17],u_vm4_r} + {u_vm5_r[17],u_vm5_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_va3_r <= 19'b0;
    end
    else begin
      u_va3_r <= {u_vm6_r[17],u_vm6_r} + {u_vm7_r[17],u_vm7_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_va4_r <= 20'b0;
    end
    else begin
      u_va4_r <= {u_va0_r[18],u_va0_r} + {u_va1_r[18],u_va1_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_va5_r <= 20'b0;
    end
    else begin
      u_va5_r <= {u_va2_r[18],u_va2_r} + {u_va3_r[18],u_va3_r};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_refyen_dly_r <= 5'b0;
      u_refcen_dly_r <= 5'b0;
      u_ysngl_dly_r  <= 5'b0;
      u_csngl_dly_r  <= 5'b0;
    end
    else begin
      u_refyen_dly_r[4:1] <= u_refyen_dly_r[3:0];
      u_refyen_dly_r[0]   <= u_refyen_r & u_opstp_r;
      u_refcen_dly_r[4:1] <= u_refcen_dly_r[3:0];
      u_refcen_dly_r[0]   <= u_refcen_r & u_opstp_r;
      u_ysngl_dly_r[4:1] <= u_ysngl_dly_r[3:0];
      u_ysngl_dly_r[0]   <= u_ysngl_r;
      u_csngl_dly_r[4:1] <= u_csngl_dly_r[3:0];
      u_csngl_dly_r[0]   <= u_csngl_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_yen_r        <= 1'b0;
      u_cen_r        <= 1'b0;
      u_refv_ysngl_r <= 1'b0;
      u_refv_csngl_r <= 1'b0;
    end
    else begin
      u_yen_r        <= u_refyen_dly_r[4];
      u_cen_r        <= u_refcen_dly_r[4];
      u_refv_ysngl_r <= u_ysngl_dly_r[4];
      u_refv_csngl_r <= u_csngl_dly_r[4];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_pdt1_r <= 20'b0;
    end
    else if( u_opstp_r ) begin
      u_pdt1_r <= u_va4_r;
    end
    else begin
      u_pdt1_r <= 20'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_pdt3_r <= 20'b0;
    end
    else if( u_opstp_r &&
             (!( (u_ysngl_dly_r[2] && u_refyen_dly_r[2]) ||
                 (u_refcen_dly_r[2] && u_csngl_dly_r[2]) ))) begin
      u_pdt3_r <= u_va5_r;
    end
    else begin
      u_pdt3_r <= 20'b0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_pdt2_r <= 12'b0;
    end
    else begin
      u_pdt2_r <= u_pdt1_r[19:8] + u_pdt1_r[7:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_pdt4_r <= 12'b0;
    end
    else begin
      u_pdt4_r <= u_pdt3_r[19:8] + u_pdt3_r[7:0];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      u_dt_r <= 16'b0;
    end
    else begin
      u_dt_r[15:8] <= ({8{~u_pdt2_r[11]}}) & ( {8{u_pdt2_r[10:8] != 3'h0}} | u_pdt2_r[7:0] );
      u_dt_r[7:0]  <= ({8{~u_pdt4_r[11]}}) & ( {8{u_pdt4_r[10:8] != 3'h0}} | u_pdt4_r[7:0] );
    end
  end
  
  
endmodule
