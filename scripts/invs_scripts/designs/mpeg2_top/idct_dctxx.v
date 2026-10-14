// ----------------------------------------------
// File: idct_dctxx.v
// Module: idct_dctxx
// Function:
// ----------------------------------------------

module idct_dctxx(
       DCTINP, 
       GODCT, 
       MODEIN, 
       rstdec_x, 
       clkdec,
       DCTOUT, 
       MODEOUT, 
       GONEXT
);

input  [15:0]  DCTINP; 
input          GODCT;          
input          MODEIN;         
input          rstdec_x;          
input          clkdec;            
output [15:0]  DCTOUT; 
output         MODEOUT;        
output         GONEXT;

wire [3:0]   DAINXH, DAINXL, DAINYH, DAINYL;
wire [32:0]  DAOUTX, DAOUTY;
wire         CSFTPR;
wire         CPRDI1, CPRDI2, CPRDI3, CPRDI4;
wire         CTMOD1, CTMOD2, CTMOD3;
wire         CPBTF;
wire         CPLOAD;
wire         CPRCT1, CPRCT2, CPRCT3, CPRCT4,
             CPRCT5, CPRCT6, CPRCT7, CPRCT8;
wire         CACSGN;
wire         SDAO0, SDAO1, SDAO2, SDAO3,
             SDAO4, SDAO5, SDAO6, SDAO7;
wire         CACRST;
wire         VDCT;
wire         CPSMOD;
wire         CPSADD;


idct_dprtp idct_dprtp (
         .DAINXH(DAINXH),
         .DAINXL(DAINXL),
         .DAINYH(DAINYH),
         .DAINYL(DAINYL),
         .DCTINP(DCTINP),
         .CSFTPR(CSFTPR),
         .CPRDI1(CPRDI1),
         .CPRDI2(CPRDI2),
         .CPRDI3(CPRDI3),
         .CPRDI4(CPRDI4),
         .CTMOD1(CTMOD1),
         .CTMOD2(CTMOD2),
         .CTMOD3(CTMOD3),
         .CPBTF(CPBTF),
         .CPLOAD(CPLOAD),
         .CPRCT1(CPRCT1),
         .CPRCT2(CPRCT2),
         .CPRCT3(CPRCT3),
         .CPRCT4(CPRCT4),
         .CPRCT5(CPRCT5),
         .CPRCT6(CPRCT6),
         .CPRCT7(CPRCT7),
         .CPRCT8(CPRCT8),
         .clkdec(clkdec)
);

idct_mactp idct_mactp (
         .DAOUTX(DAOUTX), 
         .DAOUTY(DAOUTY), 
         .DAINXH(DAINXH), 
         .DAINXL(DAINXL), 
         .DAINYH(DAINYH), 
         .DAINYL(DAINYL),
         .CACSGN(CACSGN), 
         .SDAO0(SDAO0), 
         .SDAO1(SDAO1), 
         .SDAO2(SDAO2), 
         .SDAO3(SDAO3), 
         .SDAO4(SDAO4), 
         .SDAO5(SDAO5), 
         .SDAO6(SDAO6), 
         .SDAO7(SDAO7), 
         .CACRST(CACRST), 
         .VDCT(VDCT), 
         .CPSMOD(CPSMOD), 
         .clkdec(clkdec) 
);

idct_postt idct_postt (
         .DCTOUT(DCTOUT), 
         .DX(DAOUTX), 
         .DY(DAOUTY), 
         .CPSADD(CPSADD), 
         .clkdec(clkdec) 
);

idct_dctsq idct_dctsq (
         .CSFTPR(CSFTPR), 
         .CPRDI1(CPRDI1), 
         .CPRDI2(CPRDI2),
         .CPRDI3(CPRDI3), 
         .CPRDI4(CPRDI4), 
         .CTMOD1(CTMOD1),
         .CTMOD2(CTMOD2), 
         .CTMOD3(CTMOD3), 
         .CPBTF(CPBTF),
         .CPLOAD(CPLOAD), 
         .CPRCT1(CPRCT1), 
         .CPRCT2(CPRCT2),
         .CPRCT3(CPRCT3), 
         .CPRCT4(CPRCT4), 
         .CPRCT5(CPRCT5),
         .CPRCT6(CPRCT6), 
         .CPRCT7(CPRCT7), 
         .CPRCT8(CPRCT8),
         .CACSGN(CACSGN), 
         .SDAO0(SDAO0), 
         .SDAO1(SDAO1),
         .SDAO2(SDAO2), 
         .SDAO3(SDAO3), 
         .SDAO4(SDAO4), 
         .SDAO5(SDAO5),
         .SDAO6(SDAO6), 
         .SDAO7(SDAO7), 
         .CACRST(CACRST), 
         .VDCT(VDCT),
         .CPSMOD(CPSMOD), 
         .CPSADD(CPSADD),
         .MODEOUT(MODEOUT), 
         .GOTRN(GONEXT),
         .MODEIN(MODEIN), 
         .GODCT(GODCT), 
         .rstdec_x(rstdec_x), 
         .clkdec(clkdec)
);

endmodule

