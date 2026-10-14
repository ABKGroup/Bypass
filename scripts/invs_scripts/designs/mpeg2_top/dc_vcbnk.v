// ----------------------------------------------
// File: dc_vcbnkt.v
// Module: dc_vcbnk
// Function:Coef. bank for horizon filter
// ----------------------------------------------

module dc_vcbnk ( 
   clkdec, 
   rstdec_x, 
   d_decyen_r, 
   d_phase, 
   d_c1_slct,
   d_coef_0, 
   d_coef_1, 
   d_coef_2, 
   d_coef_3, 
   d_coef_4, 
   d_coef_5, 
   d_coef_6, 
   d_coef_7
);

input        clkdec;  
input        rstdec_x;
input        d_decyen_r; 
input  [2:0] d_phase;    
input        d_c1_slct;  
output [8:0] d_coef_0;   
output [8:0] d_coef_1;   
output [8:0] d_coef_2;   
output [8:0] d_coef_3;   
output [8:0] d_coef_4;   
output [8:0] d_coef_5;   
output [8:0] d_coef_6;   
output [8:0] d_coef_7;   

wire         clkdec;   
wire         rstdec_x; 
wire         d_decyen_r; // Y-enb
wire   [2:0] d_phase;    // coef phase
reg    [8:0] d_coef_0;   // coef_0
reg    [8:0] d_coef_1;   // coef_1
reg    [8:0] d_coef_2;   // coef_2
reg    [8:0] d_coef_3;   // coef_3
reg    [8:0] d_coef_4;   // coef_4
reg    [8:0] d_coef_5;   // coef_5
reg    [8:0] d_coef_6;   // coef_6
reg    [8:0] d_coef_7;   // coef_7
reg   [71:0] w_ydt;      // coef @ Y
reg   [71:0] w_cdt;      // coef @ C
wire   [1:0] w_mode;     // composit mode

assign w_mode = {d_decyen_r,d_c1_slct};

// parameter for ROM
  parameter   P_VDCVC_Y00 =9'h099;
  parameter   P_VDCVC_Y10 =9'h1DE;
  parameter   P_VDCVC_Y20 =9'h00F;
  parameter   P_VDCVC_Y30 =9'h1FC;
  parameter   P_VDCVC_Y40 =9'h000;
  parameter   P_VDCVC_Y50 =9'h000;
  parameter   P_VDCVC_Y60 =9'h000;
  parameter   P_VDCVC_Y70 =9'h000;

  parameter   P_VDCVC_Y01 =9'h05D;
  parameter   P_VDCVC_Y11 =9'h02E;
  parameter   P_VDCVC_Y21 =9'h1EF;
  parameter   P_VDCVC_Y31 =9'h004;
  parameter   P_VDCVC_Y41 =9'h000;
  parameter   P_VDCVC_Y51 =9'h000;
  parameter   P_VDCVC_Y61 =9'h000;
  parameter   P_VDCVC_Y71 =9'h000;

  parameter   P_VDCVC_Y02 =9'h017;
  parameter   P_VDCVC_Y12 =9'h079;
  parameter   P_VDCVC_Y22 =9'h1EA;
  parameter   P_VDCVC_Y32 =9'h005;
  parameter   P_VDCVC_Y42 =9'h000;
  parameter   P_VDCVC_Y52 =9'h000;
  parameter   P_VDCVC_Y62 =9'h000;
  parameter   P_VDCVC_Y72 =9'h000;

  parameter   P_VDCVC_Y03 =9'h1F5;
  parameter   P_VDCVC_Y13 =9'h06F;
  parameter   P_VDCVC_Y23 =9'h024;
  parameter   P_VDCVC_Y33 =9'h1F9;
  parameter   P_VDCVC_Y43 =9'h000;
  parameter   P_VDCVC_Y53 =9'h000;
  parameter   P_VDCVC_Y63 =9'h000;
  parameter   P_VDCVC_Y73 =9'h000;

  parameter   P_VDCVC_Y04 =9'h1F9;
  parameter   P_VDCVC_Y14 =9'h024;
  parameter   P_VDCVC_Y24 =9'h06F;
  parameter   P_VDCVC_Y34 =9'h1F5;
  parameter   P_VDCVC_Y44 =9'h000;
  parameter   P_VDCVC_Y54 =9'h000; 
  parameter   P_VDCVC_Y64 =9'h000; 
  parameter   P_VDCVC_Y74 =9'h000; 

  parameter   P_VDCVC_Y05 =9'h005; 
  parameter   P_VDCVC_Y15 =9'h1EA; 
  parameter   P_VDCVC_Y25 =9'h079; 
  parameter   P_VDCVC_Y35 =9'h017; 
  parameter   P_VDCVC_Y45 =9'h000; 
  parameter   P_VDCVC_Y55 =9'h000;  
  parameter   P_VDCVC_Y65 =9'h000; 
  parameter   P_VDCVC_Y75 =9'h000; 

  parameter   P_VDCVC_Y06 =9'h004; 
  parameter   P_VDCVC_Y16 =9'h1EF; 
  parameter   P_VDCVC_Y26 =9'h02E; 
  parameter   P_VDCVC_Y36 =9'h05D; 
  parameter   P_VDCVC_Y46 =9'h000; 
  parameter   P_VDCVC_Y56 =9'h000; 
  parameter   P_VDCVC_Y66 =9'h000; 
  parameter   P_VDCVC_Y76 =9'h000; 

  parameter   P_VDCVC_Y07 =9'h1FC; 
  parameter   P_VDCVC_Y17 =9'h00F; 
  parameter   P_VDCVC_Y27 =9'h1DE; 
  parameter   P_VDCVC_Y37 =9'h099; 
  parameter   P_VDCVC_Y47 =9'h000; 
  parameter   P_VDCVC_Y57 =9'h000; 
  parameter   P_VDCVC_Y67 =9'h000; 
  parameter   P_VDCVC_Y77 =9'h000; 

  parameter   P_VDCVC_C00 =9'h094; 
  parameter   P_VDCVC_C10 =9'h1EC; 
  parameter   P_VDCVC_C20 =9'h000; 
  parameter   P_VDCVC_C30 =9'h000; 
  parameter   P_VDCVC_C40 =9'h000; 
  parameter   P_VDCVC_C50 =9'h000; 
  parameter   P_VDCVC_C60 =9'h000; 
  parameter   P_VDCVC_C70 =9'h000; 

  parameter   P_VDCVC_C01 =9'h063; 
  parameter   P_VDCVC_C11 =9'h01D; 
  parameter   P_VDCVC_C21 =9'h000; 
  parameter   P_VDCVC_C31 =9'h000; 
  parameter   P_VDCVC_C41 =9'h000; 
  parameter   P_VDCVC_C51 =9'h000; 
  parameter   P_VDCVC_C61 =9'h000; 
  parameter   P_VDCVC_C71 =9'h000; 

  parameter   P_VDCVC_C02 =9'h01D; 
  parameter   P_VDCVC_C12 =9'h063; 
  parameter   P_VDCVC_C22 =9'h000; 
  parameter   P_VDCVC_C32 =9'h000; 
  parameter   P_VDCVC_C42 =9'h000; 
  parameter   P_VDCVC_C52 =9'h000; 
  parameter   P_VDCVC_C62 =9'h000; 
  parameter   P_VDCVC_C72 =9'h000; 

  parameter   P_VDCVC_C03 =9'h1EC; 
  parameter   P_VDCVC_C13 =9'h094; 
  parameter   P_VDCVC_C23 =9'h000; 
  parameter   P_VDCVC_C33 =9'h000; 
  parameter   P_VDCVC_C43 =9'h000; 
  parameter   P_VDCVC_C53 =9'h000; 
  parameter   P_VDCVC_C63 =9'h000; 
  parameter   P_VDCVC_C73 =9'h000; 

  parameter   P_VDCVC_C04 =9'h000; 
  parameter   P_VDCVC_C14 =9'h000; 
  parameter   P_VDCVC_C24 =9'h000; 
  parameter   P_VDCVC_C34 =9'h000; 
  parameter   P_VDCVC_C44 =9'h000; 
  parameter   P_VDCVC_C54 =9'h000; 
  parameter   P_VDCVC_C64 =9'h000; 
  parameter   P_VDCVC_C74 =9'h000; 

  parameter   P_VDCVC_C05 =9'h000; 
  parameter   P_VDCVC_C15 =9'h000; 
  parameter   P_VDCVC_C25 =9'h000; 
  parameter   P_VDCVC_C35 =9'h000; 
  parameter   P_VDCVC_C45 =9'h000; 
  parameter   P_VDCVC_C55 =9'h000; 
  parameter   P_VDCVC_C65 =9'h000; 
  parameter   P_VDCVC_C75 =9'h000; 

  parameter   P_VDCVC_C06 =9'h000; 
  parameter   P_VDCVC_C16 =9'h000; 
  parameter   P_VDCVC_C26 =9'h000; 
  parameter   P_VDCVC_C36 =9'h000; 
  parameter   P_VDCVC_C46 =9'h000; 
  parameter   P_VDCVC_C56 =9'h000; 
  parameter   P_VDCVC_C66 =9'h000; 
  parameter   P_VDCVC_C76 =9'h000; 

  parameter   P_VDCVC_C07 =9'h000; 
  parameter   P_VDCVC_C17 =9'h000; 
  parameter   P_VDCVC_C27 =9'h000; 
  parameter   P_VDCVC_C37 =9'h000; 
  parameter   P_VDCVC_C47 =9'h000; 
  parameter   P_VDCVC_C57 =9'h000; 
  parameter   P_VDCVC_C67 =9'h000; 
  parameter   P_VDCVC_C77 =9'h000; 

always @(d_phase)
begin
case (d_phase)
  3'b000 : w_ydt = { P_VDCVC_Y00,P_VDCVC_Y01,P_VDCVC_Y02,P_VDCVC_Y03,
                     P_VDCVC_Y04,P_VDCVC_Y05,P_VDCVC_Y06,P_VDCVC_Y07};
  3'b001 : w_ydt = { P_VDCVC_Y10,P_VDCVC_Y11,P_VDCVC_Y12,P_VDCVC_Y13,
                     P_VDCVC_Y14,P_VDCVC_Y15,P_VDCVC_Y16,P_VDCVC_Y17};
  3'b010 : w_ydt = { P_VDCVC_Y20,P_VDCVC_Y21,P_VDCVC_Y22,P_VDCVC_Y23,
                     P_VDCVC_Y24,P_VDCVC_Y25,P_VDCVC_Y26,P_VDCVC_Y27};
  3'b011 : w_ydt = { P_VDCVC_Y30,P_VDCVC_Y31,P_VDCVC_Y32,P_VDCVC_Y33,
                     P_VDCVC_Y34,P_VDCVC_Y35,P_VDCVC_Y36,P_VDCVC_Y37};
  3'b100 : w_ydt = { P_VDCVC_Y40,P_VDCVC_Y41,P_VDCVC_Y42,P_VDCVC_Y43,
                     P_VDCVC_Y44,P_VDCVC_Y45,P_VDCVC_Y46,P_VDCVC_Y47};
  3'b101 : w_ydt = { P_VDCVC_Y50,P_VDCVC_Y51,P_VDCVC_Y52,P_VDCVC_Y53,
                     P_VDCVC_Y54,P_VDCVC_Y55,P_VDCVC_Y56,P_VDCVC_Y57};
  3'b110 : w_ydt = { P_VDCVC_Y60,P_VDCVC_Y61,P_VDCVC_Y62,P_VDCVC_Y63,
                     P_VDCVC_Y64,P_VDCVC_Y65,P_VDCVC_Y66,P_VDCVC_Y67};
  3'b111 : w_ydt = { P_VDCVC_Y70,P_VDCVC_Y71,P_VDCVC_Y72,P_VDCVC_Y73,
                     P_VDCVC_Y74,P_VDCVC_Y75,P_VDCVC_Y76,P_VDCVC_Y77};
endcase
end

always @(d_phase)
begin
case (d_phase)
  3'b000 : w_cdt = { P_VDCVC_C00,P_VDCVC_C01,P_VDCVC_C02,P_VDCVC_C03,
                     P_VDCVC_C04,P_VDCVC_C05,P_VDCVC_C06,P_VDCVC_C07};
  3'b001 : w_cdt = { P_VDCVC_C10,P_VDCVC_C11,P_VDCVC_C12,P_VDCVC_C13,
                     P_VDCVC_C14,P_VDCVC_C15,P_VDCVC_C16,P_VDCVC_C17};
  3'b010 : w_cdt = { P_VDCVC_C20,P_VDCVC_C21,P_VDCVC_C22,P_VDCVC_C23,
                     P_VDCVC_C24,P_VDCVC_C25,P_VDCVC_C26,P_VDCVC_C27};
  3'b011 : w_cdt = { P_VDCVC_C30,P_VDCVC_C31,P_VDCVC_C32,P_VDCVC_C33,
                     P_VDCVC_C34,P_VDCVC_C35,P_VDCVC_C36,P_VDCVC_C37};
  3'b100 : w_cdt = { P_VDCVC_C40,P_VDCVC_C41,P_VDCVC_C42,P_VDCVC_C43,
                     P_VDCVC_C44,P_VDCVC_C45,P_VDCVC_C46,P_VDCVC_C47};
  3'b101 : w_cdt = { P_VDCVC_C50,P_VDCVC_C51,P_VDCVC_C52,P_VDCVC_C53,
                     P_VDCVC_C54,P_VDCVC_C55,P_VDCVC_C56,P_VDCVC_C57};
  3'b110 : w_cdt = { P_VDCVC_C60,P_VDCVC_C61,P_VDCVC_C62,P_VDCVC_C63,
                     P_VDCVC_C64,P_VDCVC_C65,P_VDCVC_C66,P_VDCVC_C67};
  3'b111 : w_cdt = { P_VDCVC_C70,P_VDCVC_C71,P_VDCVC_C72,P_VDCVC_C73,
                     P_VDCVC_C74,P_VDCVC_C75,P_VDCVC_C76,P_VDCVC_C77};
endcase
end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        {d_coef_0,d_coef_1,d_coef_2,d_coef_3,
         d_coef_4,d_coef_5,d_coef_6,d_coef_7} <= 72'd0;
      end
    else
      begin
        if (w_mode == 2'b01) // Component-C
          begin
            {d_coef_0,d_coef_1,d_coef_2,d_coef_3,
             d_coef_4,d_coef_5,d_coef_6,d_coef_7} <= w_cdt;
          end
        else                 // Component-Y
          begin
            {d_coef_0,d_coef_1,d_coef_2,d_coef_3,
             d_coef_4,d_coef_5,d_coef_6,d_coef_7} <= w_ydt;
          end
      end
  end
endmodule

