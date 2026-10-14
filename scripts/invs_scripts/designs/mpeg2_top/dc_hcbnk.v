// ----------------------------------------------
// File: dc_hcbnk.v
// Module: dc_hcbnk
// Function: Coef. bank for horizon filter
// ----------------------------------------------

module dc_hcbnk ( 
  clkdec, 
  rstdec_x, 
  d_decyen_r, 
  d_phase, 
  d_c_slct_r, 
  d_coef_0, 
  d_coef_1, 
  d_coef_2, 
  d_coef_3, 
  d_coef_4, 
  d_coef_5, 
  d_coef_6, 
  d_coef_7, 
  d_coef_8, 
  d_coef_9, 
  d_coef_a, 
  d_coef_b, 
  d_coef_c, 
  d_coef_d, 
  d_coef_e, 
  d_coef_f
);

input        clkdec;  
input        rstdec_x;
input        d_decyen_r;
input  [2:0] d_phase;   
input        d_c_slct_r;
output [8:0] d_coef_0; 
output [8:0] d_coef_1; 
output [8:0] d_coef_2; 
output [8:0] d_coef_3; 
output [8:0] d_coef_4; 
output [8:0] d_coef_5; 
output [8:0] d_coef_6; 
output [8:0] d_coef_7; 
output [8:0] d_coef_8; 
output [8:0] d_coef_9; 
output [8:0] d_coef_a; 
output [8:0] d_coef_b; 
output [8:0] d_coef_c; 
output [8:0] d_coef_d; 
output [8:0] d_coef_e; 
output [8:0] d_coef_f; 

wire         d_decyen_r; // Y-composit enb
wire         d_c_slct_r; // C-composit enb
wire   [2:0] d_phase;    // Coef phase
wire   [1:0] w_mode;     // Y/C mode sel
reg    [8:0] d_coef_0;   // Pos-0 coef
reg    [8:0] d_coef_1;   // Pos-1 coef
reg    [8:0] d_coef_2;   // Pos-2 coef
reg    [8:0] d_coef_3;   // Pos-3 coef
reg    [8:0] d_coef_4;   // Pos-4 coef
reg    [8:0] d_coef_5;   // Pos-5 coef
reg    [8:0] d_coef_6;   // Pos-6 coef
reg    [8:0] d_coef_7;   // Pos-7 coef
reg    [8:0] d_coef_8;   // Pos-8 coef
reg    [8:0] d_coef_9;   // Pos-9 coef
reg    [8:0] d_coef_a;   // Pos-a coef
reg    [8:0] d_coef_b;   // Pos-b coef
reg    [8:0] d_coef_c;   // Pos-c coef
reg    [8:0] d_coef_d;   // Pos-d coef
reg    [8:0] d_coef_e;   // Pos-e coef
reg    [8:0] d_coef_f;   // Pos-f coef
reg  [143:0] w_ydt;      // coef data @ Y-composit
reg  [143:0] w_cdt;      // coef data @ C-composit

assign w_mode = {d_decyen_r,d_c_slct_r};

// parameter for ROM data //
  parameter   P_VDCHC_Y00 =9'h09A;  // 154
  parameter   P_VDCHC_Y10 =9'h1DA;  // -38
  parameter   P_VDCHC_Y20 =9'h015;  // 21
  parameter   P_VDCHC_Y30 =9'h1F3;  // -13
  parameter   P_VDCHC_Y40 =9'h009;  // 9
  parameter   P_VDCHC_Y50 =9'h1FA;  // -6
  parameter   P_VDCHC_Y60 =9'h003;  // 3
  parameter   P_VDCHC_Y70 =9'h1FF;  // -1
  parameter   P_VDCHC_Y01 =9'h05C;  //
  parameter   P_VDCHC_Y11 =9'h032;  //
  parameter   P_VDCHC_Y21 =9'h1E9;  //
  parameter   P_VDCHC_Y31 =9'h00E;  //
  parameter   P_VDCHC_Y41 =9'h1F7;  //
  parameter   P_VDCHC_Y51 =9'h006;  //
  parameter   P_VDCHC_Y61 =9'h1FD;  //
  parameter   P_VDCHC_Y71 =9'h001;  //
  parameter   P_VDCHC_Y02 =9'h016;  //
  parameter   P_VDCHC_Y12 =9'h07D;  //
  parameter   P_VDCHC_Y22 =9'h1E4;  //
  parameter   P_VDCHC_Y32 =9'h010;  //
  parameter   P_VDCHC_Y42 =9'h1F6;  //
  parameter   P_VDCHC_Y52 =9'h006;  //
  parameter   P_VDCHC_Y62 =9'h1FD;  //
  parameter   P_VDCHC_Y72 =9'h001;  //
  parameter   P_VDCHC_Y03 =9'h1F6;  //
  parameter   P_VDCHC_Y13 =9'h06B;  //
  parameter   P_VDCHC_Y23 =9'h02B;  //
  parameter   P_VDCHC_Y33 =9'h1ED;  //
  parameter   P_VDCHC_Y43 =9'h00B;  //
  parameter   P_VDCHC_Y53 =9'h1F9;  //
  parameter   P_VDCHC_Y63 =9'h003;  //
  parameter   P_VDCHC_Y73 =9'h1FF;  //
  parameter   P_VDCHC_Y04 =9'h1FA;  //
  parameter   P_VDCHC_Y14 =9'h01F;  //
  parameter   P_VDCHC_Y24 =9'h077;  //
  parameter   P_VDCHC_Y34 =9'h1E7;  //
  parameter   P_VDCHC_Y44 =9'h00D;  //
  parameter   P_VDCHC_Y54 =9'h1F9;  //
  parameter   P_VDCHC_Y64 =9'h004;  //
  parameter   P_VDCHC_Y74 =9'h1FF;  //
  parameter   P_VDCHC_Y05 =9'h004;  //
  parameter   P_VDCHC_Y15 =9'h1EF;  //
  parameter   P_VDCHC_Y25 =9'h06F;  //
  parameter   P_VDCHC_Y35 =9'h028;  //
  parameter   P_VDCHC_Y45 =9'h1F0;  //
  parameter   P_VDCHC_Y55 =9'h009;  //
  parameter   P_VDCHC_Y65 =9'h1FC;  //
  parameter   P_VDCHC_Y75 =9'h001;  //
  parameter   P_VDCHC_Y06 =9'h003;  //
  parameter   P_VDCHC_Y16 =9'h1F5;  //
  parameter   P_VDCHC_Y26 =9'h023;  //
  parameter   P_VDCHC_Y36 =9'h074;  //
  parameter   P_VDCHC_Y46 =9'h1EA;  //
  parameter   P_VDCHC_Y56 =9'h00B;  //
  parameter   P_VDCHC_Y66 =9'h1FB;  //
  parameter   P_VDCHC_Y76 =9'h001;  //
  parameter   P_VDCHC_Y07 =9'h1FE;  //
  parameter   P_VDCHC_Y17 =9'h008;  //
  parameter   P_VDCHC_Y27 =9'h1EC;  //
  parameter   P_VDCHC_Y37 =9'h072;  //
  parameter   P_VDCHC_Y47 =9'h025;  //
  parameter   P_VDCHC_Y57 =9'h1F2;  //
  parameter   P_VDCHC_Y67 =9'h006;  //
  parameter   P_VDCHC_Y77 =9'h1FE;  //
  parameter   P_VDCHC_Y08 =9'h1FE;  //
  parameter   P_VDCHC_Y18 =9'h006;  //
  parameter   P_VDCHC_Y28 =9'h1F2;  //
  parameter   P_VDCHC_Y38 =9'h025;  //
  parameter   P_VDCHC_Y48 =9'h072;  //
  parameter   P_VDCHC_Y58 =9'h1EC;  //
  parameter   P_VDCHC_Y68 =9'h008;  //
  parameter   P_VDCHC_Y78 =9'h1FE;  //
  parameter   P_VDCHC_Y09 =9'h001;  //
  parameter   P_VDCHC_Y19 =9'h1FB;  //
  parameter   P_VDCHC_Y29 =9'h00B;  //
  parameter   P_VDCHC_Y39 =9'h1EA;  //
  parameter   P_VDCHC_Y49 =9'h074;  //
  parameter   P_VDCHC_Y59 =9'h023;  //
  parameter   P_VDCHC_Y69 =9'h1F5;  //
  parameter   P_VDCHC_Y79 =9'h003;  //
  parameter   P_VDCHC_Y0A =9'h001;  //
  parameter   P_VDCHC_Y1A =9'h1FC;  //
  parameter   P_VDCHC_Y2A =9'h009;  //
  parameter   P_VDCHC_Y3A =9'h1F0;  //
  parameter   P_VDCHC_Y4A =9'h028;  //
  parameter   P_VDCHC_Y5A =9'h06F;  //
  parameter   P_VDCHC_Y6A =9'h1EF;  //
  parameter   P_VDCHC_Y7A =9'h004;  //
  parameter   P_VDCHC_Y0B =9'h1FF;  //
  parameter   P_VDCHC_Y1B =9'h004;  //
  parameter   P_VDCHC_Y2B =9'h1F9;  //
  parameter   P_VDCHC_Y3B =9'h00D;  //
  parameter   P_VDCHC_Y4B =9'h1E7;  //
  parameter   P_VDCHC_Y5B =9'h077;  //
  parameter   P_VDCHC_Y6B =9'h01F;  //
  parameter   P_VDCHC_Y7B =9'h1FA;  //
  parameter   P_VDCHC_Y0C =9'h1FF;  //
  parameter   P_VDCHC_Y1C =9'h003;  //
  parameter   P_VDCHC_Y2C =9'h1F9;  //
  parameter   P_VDCHC_Y3C =9'h00B;  //
  parameter   P_VDCHC_Y4C =9'h1ED;  //
  parameter   P_VDCHC_Y5C =9'h02B;  //
  parameter   P_VDCHC_Y6C =9'h06B;  //
  parameter   P_VDCHC_Y7C =9'h1F6;  //
  parameter   P_VDCHC_Y0D =9'h001;  //
  parameter   P_VDCHC_Y1D =9'h1FD;  //
  parameter   P_VDCHC_Y2D =9'h006;  //
  parameter   P_VDCHC_Y3D =9'h1F6;  //
  parameter   P_VDCHC_Y4D =9'h010;  //
  parameter   P_VDCHC_Y5D =9'h1E4;  //
  parameter   P_VDCHC_Y6D =9'h07D;  //
  parameter   P_VDCHC_Y7D =9'h016;  //
  parameter   P_VDCHC_Y0E =9'h001;  //
  parameter   P_VDCHC_Y1E =9'h1FD;  //
  parameter   P_VDCHC_Y2E =9'h006;  //
  parameter   P_VDCHC_Y3E =9'h1F7;  //
  parameter   P_VDCHC_Y4E =9'h00E;  //
  parameter   P_VDCHC_Y5E =9'h1E9;  //
  parameter   P_VDCHC_Y6E =9'h032;  //
  parameter   P_VDCHC_Y7E =9'h05C;  //
  parameter   P_VDCHC_Y0F =9'h1FF;  //
  parameter   P_VDCHC_Y1F =9'h003;  //
  parameter   P_VDCHC_Y2F =9'h1FA;  //
  parameter   P_VDCHC_Y3F =9'h009;  //
  parameter   P_VDCHC_Y4F =9'h1F3;  //
  parameter   P_VDCHC_Y5F =9'h015;  //
  parameter   P_VDCHC_Y6F =9'h1DA;  //
  parameter   P_VDCHC_Y7F =9'h09A;  //

  parameter   P_VDCHC_C00 =9'h099;  //
  parameter   P_VDCHC_C10 =9'h1DE;  //
  parameter   P_VDCHC_C20 =9'h00F;  //
  parameter   P_VDCHC_C30 =9'h1FC;  //
  parameter   P_VDCHC_C40 =9'h000;  //
  parameter   P_VDCHC_C50 =9'h000;  //
  parameter   P_VDCHC_C60 =9'h000;  //
  parameter   P_VDCHC_C70 =9'h000;  //
  parameter   P_VDCHC_C01 =9'h05D;  //
  parameter   P_VDCHC_C11 =9'h02E;  //
  parameter   P_VDCHC_C21 =9'h1EF;  //
  parameter   P_VDCHC_C31 =9'h004;  //
  parameter   P_VDCHC_C41 =9'h000;  //
  parameter   P_VDCHC_C51 =9'h000;  //
  parameter   P_VDCHC_C61 =9'h000;  //
  parameter   P_VDCHC_C71 =9'h000;  //
  parameter   P_VDCHC_C02 =9'h017;  //
  parameter   P_VDCHC_C12 =9'h079;  //
  parameter   P_VDCHC_C22 =9'h1EA;  //
  parameter   P_VDCHC_C32 =9'h005;  //
  parameter   P_VDCHC_C42 =9'h000;  //
  parameter   P_VDCHC_C52 =9'h000;  //
  parameter   P_VDCHC_C62 =9'h000;  //
  parameter   P_VDCHC_C72 =9'h000;  //
  parameter   P_VDCHC_C03 =9'h1F5;  //
  parameter   P_VDCHC_C13 =9'h06F;  //
  parameter   P_VDCHC_C23 =9'h024;  //
  parameter   P_VDCHC_C33 =9'h1F9;  //
  parameter   P_VDCHC_C43 =9'h000;  //
  parameter   P_VDCHC_C53 =9'h000;  //
  parameter   P_VDCHC_C63 =9'h000;  //
  parameter   P_VDCHC_C73 =9'h000;  //
  parameter   P_VDCHC_C04 =9'h1F9;  //
  parameter   P_VDCHC_C14 =9'h024;  //
  parameter   P_VDCHC_C24 =9'h06F;  //
  parameter   P_VDCHC_C34 =9'h1F5;  //
  parameter   P_VDCHC_C44 =9'h000;  //
  parameter   P_VDCHC_C54 =9'h000;  //
  parameter   P_VDCHC_C64 =9'h000;  //
  parameter   P_VDCHC_C74 =9'h000;  //
  parameter   P_VDCHC_C05 =9'h005;  //
  parameter   P_VDCHC_C15 =9'h1EA;  //
  parameter   P_VDCHC_C25 =9'h079;  //
  parameter   P_VDCHC_C35 =9'h017;  //
  parameter   P_VDCHC_C45 =9'h000;  //
  parameter   P_VDCHC_C55 =9'h000;  //
  parameter   P_VDCHC_C65 =9'h000;  //
  parameter   P_VDCHC_C75 =9'h000;  //
  parameter   P_VDCHC_C06 =9'h004;  //
  parameter   P_VDCHC_C16 =9'h1EF;  //
  parameter   P_VDCHC_C26 =9'h02E;  //
  parameter   P_VDCHC_C36 =9'h05D;  //
  parameter   P_VDCHC_C46 =9'h000;  //
  parameter   P_VDCHC_C56 =9'h000;  //
  parameter   P_VDCHC_C66 =9'h000;  //
  parameter   P_VDCHC_C76 =9'h000;  //
  parameter   P_VDCHC_C07 =9'h1FC;  //
  parameter   P_VDCHC_C17 =9'h00F;  //
  parameter   P_VDCHC_C27 =9'h1DE;  //
  parameter   P_VDCHC_C37 =9'h099;  //
  parameter   P_VDCHC_C47 =9'h000;  //
  parameter   P_VDCHC_C57 =9'h000;  //
  parameter   P_VDCHC_C67 =9'h000;  //
  parameter   P_VDCHC_C77 =9'h000;  //
  parameter   P_VDCHC_C08 =9'h000;  //
  parameter   P_VDCHC_C18 =9'h000;  //
  parameter   P_VDCHC_C28 =9'h000;  //
  parameter   P_VDCHC_C38 =9'h000;  //
  parameter   P_VDCHC_C48 =9'h000;  //
  parameter   P_VDCHC_C58 =9'h000;  //
  parameter   P_VDCHC_C68 =9'h000;  //
  parameter   P_VDCHC_C78 =9'h000;  //
  parameter   P_VDCHC_C09 =9'h000;  //
  parameter   P_VDCHC_C19 =9'h000;  //
  parameter   P_VDCHC_C29 =9'h000;  //
  parameter   P_VDCHC_C39 =9'h000;  //
  parameter   P_VDCHC_C49 =9'h000;  //
  parameter   P_VDCHC_C59 =9'h000;  //
  parameter   P_VDCHC_C69 =9'h000;  //
  parameter   P_VDCHC_C79 =9'h000;  //
  parameter   P_VDCHC_C0A =9'h000;  //
  parameter   P_VDCHC_C1A =9'h000;  //
  parameter   P_VDCHC_C2A =9'h000;  //
  parameter   P_VDCHC_C3A =9'h000;  //
  parameter   P_VDCHC_C4A =9'h000;  //
  parameter   P_VDCHC_C5A =9'h000;  //
  parameter   P_VDCHC_C6A =9'h000;  //
  parameter   P_VDCHC_C7A =9'h000;  //
  parameter   P_VDCHC_C0B =9'h000;  //
  parameter   P_VDCHC_C1B =9'h000;  //
  parameter   P_VDCHC_C2B =9'h000;  //
  parameter   P_VDCHC_C3B =9'h000;  //
  parameter   P_VDCHC_C4B =9'h000;  //
  parameter   P_VDCHC_C5B =9'h000;  //
  parameter   P_VDCHC_C6B =9'h000;  //
  parameter   P_VDCHC_C7B =9'h000;  //
  parameter   P_VDCHC_C0C =9'h000;  //
  parameter   P_VDCHC_C1C =9'h000;  //
  parameter   P_VDCHC_C2C =9'h000;  //
  parameter   P_VDCHC_C3C =9'h000;  //
  parameter   P_VDCHC_C4C =9'h000;  //
  parameter   P_VDCHC_C5C =9'h000;  //
  parameter   P_VDCHC_C6C =9'h000;  //
  parameter   P_VDCHC_C7C =9'h000;  //
  parameter   P_VDCHC_C0D =9'h000;  //
  parameter   P_VDCHC_C1D =9'h000;  //
  parameter   P_VDCHC_C2D =9'h000;  //
  parameter   P_VDCHC_C3D =9'h000;  //
  parameter   P_VDCHC_C4D =9'h000;  //
  parameter   P_VDCHC_C5D =9'h000;  //
  parameter   P_VDCHC_C6D =9'h000;  //
  parameter   P_VDCHC_C7D =9'h000;  //
  parameter   P_VDCHC_C0E =9'h000;  //
  parameter   P_VDCHC_C1E =9'h000;  //
  parameter   P_VDCHC_C2E =9'h000;  //
  parameter   P_VDCHC_C3E =9'h000;  //
  parameter   P_VDCHC_C4E =9'h000;  //
  parameter   P_VDCHC_C5E =9'h000;  //
  parameter   P_VDCHC_C6E =9'h000;  //
  parameter   P_VDCHC_C7E =9'h000;  //
  parameter   P_VDCHC_C0F =9'h000;  //
  parameter   P_VDCHC_C1F =9'h000;  //
  parameter   P_VDCHC_C2F =9'h000;  //
  parameter   P_VDCHC_C3F =9'h000;  //
  parameter   P_VDCHC_C4F =9'h000;  //
  parameter   P_VDCHC_C5F =9'h000;  //
  parameter   P_VDCHC_C6F =9'h000;  //
  parameter   P_VDCHC_C7F =9'h000;  //

always @(d_phase)
begin
case (d_phase)
  3'b000 : w_ydt = { P_VDCHC_Y00,P_VDCHC_Y01,P_VDCHC_Y02,P_VDCHC_Y03,
                     P_VDCHC_Y04,P_VDCHC_Y05,P_VDCHC_Y06,P_VDCHC_Y07,
                     P_VDCHC_Y08,P_VDCHC_Y09,P_VDCHC_Y0A,P_VDCHC_Y0B,
                     P_VDCHC_Y0C,P_VDCHC_Y0D,P_VDCHC_Y0E,P_VDCHC_Y0F}; 
  3'b001 : w_ydt = { P_VDCHC_Y10,P_VDCHC_Y11,P_VDCHC_Y12,P_VDCHC_Y13,
                     P_VDCHC_Y14,P_VDCHC_Y15,P_VDCHC_Y16,P_VDCHC_Y17,
                     P_VDCHC_Y18,P_VDCHC_Y19,P_VDCHC_Y1A,P_VDCHC_Y1B,
                     P_VDCHC_Y1C,P_VDCHC_Y1D,P_VDCHC_Y1E,P_VDCHC_Y1F}; 
  3'b010 : w_ydt = { P_VDCHC_Y20,P_VDCHC_Y21,P_VDCHC_Y22,P_VDCHC_Y23,
                     P_VDCHC_Y24,P_VDCHC_Y25,P_VDCHC_Y26,P_VDCHC_Y27,
                     P_VDCHC_Y28,P_VDCHC_Y29,P_VDCHC_Y2A,P_VDCHC_Y2B,
                     P_VDCHC_Y2C,P_VDCHC_Y2D,P_VDCHC_Y2E,P_VDCHC_Y2F}; 
  3'b011 : w_ydt = { P_VDCHC_Y30,P_VDCHC_Y31,P_VDCHC_Y32,P_VDCHC_Y33,
                     P_VDCHC_Y34,P_VDCHC_Y35,P_VDCHC_Y36,P_VDCHC_Y37,
                     P_VDCHC_Y38,P_VDCHC_Y39,P_VDCHC_Y3A,P_VDCHC_Y3B,
                     P_VDCHC_Y3C,P_VDCHC_Y3D,P_VDCHC_Y3E,P_VDCHC_Y3F}; 
  3'b100 : w_ydt = { P_VDCHC_Y40,P_VDCHC_Y41,P_VDCHC_Y42,P_VDCHC_Y43,
                     P_VDCHC_Y44,P_VDCHC_Y45,P_VDCHC_Y46,P_VDCHC_Y47,
                     P_VDCHC_Y48,P_VDCHC_Y49,P_VDCHC_Y4A,P_VDCHC_Y4B,
                     P_VDCHC_Y4C,P_VDCHC_Y4D,P_VDCHC_Y4E,P_VDCHC_Y4F}; 
  3'b101 : w_ydt = { P_VDCHC_Y50,P_VDCHC_Y51,P_VDCHC_Y52,P_VDCHC_Y53,
                     P_VDCHC_Y54,P_VDCHC_Y55,P_VDCHC_Y56,P_VDCHC_Y57,
                     P_VDCHC_Y58,P_VDCHC_Y59,P_VDCHC_Y5A,P_VDCHC_Y5B,
                     P_VDCHC_Y5C,P_VDCHC_Y5D,P_VDCHC_Y5E,P_VDCHC_Y5F}; 
  3'b110 : w_ydt = { P_VDCHC_Y60,P_VDCHC_Y61,P_VDCHC_Y62,P_VDCHC_Y63,
                     P_VDCHC_Y64,P_VDCHC_Y65,P_VDCHC_Y66,P_VDCHC_Y67,
                     P_VDCHC_Y68,P_VDCHC_Y69,P_VDCHC_Y6A,P_VDCHC_Y6B,
                     P_VDCHC_Y6C,P_VDCHC_Y6D,P_VDCHC_Y6E,P_VDCHC_Y6F}; 
  3'b111 : w_ydt = { P_VDCHC_Y70,P_VDCHC_Y71,P_VDCHC_Y72,P_VDCHC_Y73,
                     P_VDCHC_Y74,P_VDCHC_Y75,P_VDCHC_Y76,P_VDCHC_Y77,
                     P_VDCHC_Y78,P_VDCHC_Y79,P_VDCHC_Y7A,P_VDCHC_Y7B,
                     P_VDCHC_Y7C,P_VDCHC_Y7D,P_VDCHC_Y7E,P_VDCHC_Y7F}; 
endcase
end

always @(d_phase)
begin
case (d_phase)
  3'b000 : w_cdt = { P_VDCHC_C00,P_VDCHC_C01,P_VDCHC_C02,P_VDCHC_C03,
                     P_VDCHC_C04,P_VDCHC_C05,P_VDCHC_C06,P_VDCHC_C07,
                     P_VDCHC_C08,P_VDCHC_C09,P_VDCHC_C0A,P_VDCHC_C0B,
                     P_VDCHC_C0C,P_VDCHC_C0D,P_VDCHC_C0E,P_VDCHC_C0F}; 
  3'b001 : w_cdt = { P_VDCHC_C10,P_VDCHC_C11,P_VDCHC_C12,P_VDCHC_C13,
                     P_VDCHC_C14,P_VDCHC_C15,P_VDCHC_C16,P_VDCHC_C17,
                     P_VDCHC_C18,P_VDCHC_C19,P_VDCHC_C1A,P_VDCHC_C1B,
                     P_VDCHC_C1C,P_VDCHC_C1D,P_VDCHC_C1E,P_VDCHC_C1F}; 
  3'b010 : w_cdt = { P_VDCHC_C20,P_VDCHC_C21,P_VDCHC_C22,P_VDCHC_C23,
                     P_VDCHC_C24,P_VDCHC_C25,P_VDCHC_C26,P_VDCHC_C27,
                     P_VDCHC_C28,P_VDCHC_C29,P_VDCHC_C2A,P_VDCHC_C2B,
                     P_VDCHC_C2C,P_VDCHC_C2D,P_VDCHC_C2E,P_VDCHC_C2F}; 
  3'b011 : w_cdt = { P_VDCHC_C30,P_VDCHC_C31,P_VDCHC_C32,P_VDCHC_C33,
                     P_VDCHC_C34,P_VDCHC_C35,P_VDCHC_C36,P_VDCHC_C37,
                     P_VDCHC_C38,P_VDCHC_C39,P_VDCHC_C3A,P_VDCHC_C3B,
                     P_VDCHC_C3C,P_VDCHC_C3D,P_VDCHC_C3E,P_VDCHC_C3F}; 
  3'b100 : w_cdt = { P_VDCHC_C40,P_VDCHC_C41,P_VDCHC_C42,P_VDCHC_C43,
                     P_VDCHC_C44,P_VDCHC_C45,P_VDCHC_C46,P_VDCHC_C47,
                     P_VDCHC_C48,P_VDCHC_C49,P_VDCHC_C4A,P_VDCHC_C4B,
                     P_VDCHC_C4C,P_VDCHC_C4D,P_VDCHC_C4E,P_VDCHC_C4F}; 
  3'b101 : w_cdt = { P_VDCHC_C50,P_VDCHC_C51,P_VDCHC_C52,P_VDCHC_C53,
                     P_VDCHC_C54,P_VDCHC_C55,P_VDCHC_C56,P_VDCHC_C57,
                     P_VDCHC_C58,P_VDCHC_C59,P_VDCHC_C5A,P_VDCHC_C5B,
                     P_VDCHC_C5C,P_VDCHC_C5D,P_VDCHC_C5E,P_VDCHC_C5F}; 
  3'b110 : w_cdt = { P_VDCHC_C60,P_VDCHC_C61,P_VDCHC_C62,P_VDCHC_C63,
                     P_VDCHC_C64,P_VDCHC_C65,P_VDCHC_C66,P_VDCHC_C67,
                     P_VDCHC_C68,P_VDCHC_C69,P_VDCHC_C6A,P_VDCHC_C6B,
                     P_VDCHC_C6C,P_VDCHC_C6D,P_VDCHC_C6E,P_VDCHC_C6F}; 
  3'b111 : w_cdt = { P_VDCHC_C70,P_VDCHC_C71,P_VDCHC_C72,P_VDCHC_C73,
                     P_VDCHC_C74,P_VDCHC_C75,P_VDCHC_C76,P_VDCHC_C77,
                     P_VDCHC_C78,P_VDCHC_C79,P_VDCHC_C7A,P_VDCHC_C7B,
                     P_VDCHC_C7C,P_VDCHC_C7D,P_VDCHC_C7E,P_VDCHC_C7F}; 
endcase
end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        d_coef_0    <= 9'b000000000; 
        d_coef_1    <= 9'b000000000; 
        d_coef_2    <= 9'b000000000; 
        d_coef_3    <= 9'b000000000; 
        d_coef_4    <= 9'b000000000; 
        d_coef_5    <= 9'b000000000; 
        d_coef_6    <= 9'b000000000; 
        d_coef_7    <= 9'b000000000; 
        d_coef_8    <= 9'b000000000; 
        d_coef_9    <= 9'b000000000; 
        d_coef_a    <= 9'b000000000; 
        d_coef_b    <= 9'b000000000; 
        d_coef_c    <= 9'b000000000; 
        d_coef_d    <= 9'b000000000; 
        d_coef_e    <= 9'b000000000; 
        d_coef_f    <= 9'b000000000; 
      end
    else
      begin
        if (w_mode == 2'b01) // Component-C
          begin
            {d_coef_0,d_coef_1,d_coef_2,d_coef_3,
             d_coef_4,d_coef_5,d_coef_6,d_coef_7,
             d_coef_8,d_coef_9,d_coef_a,d_coef_b, 
             d_coef_c,d_coef_d,d_coef_e,d_coef_f} <= w_cdt; 
          end
        else                 // Component-Y
          begin
            {d_coef_0,d_coef_1,d_coef_2,d_coef_3,
             d_coef_4,d_coef_5,d_coef_6,d_coef_7,
             d_coef_8,d_coef_9,d_coef_a,d_coef_b,
             d_coef_c,d_coef_d,d_coef_e,d_coef_f} <= w_ydt; 
          end
      end
  end
endmodule

