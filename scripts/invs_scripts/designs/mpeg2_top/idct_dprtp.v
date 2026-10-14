// ----------------------------------------------
// File: idct_dprtp.v
// Module: idct_dprtp
// Function:
// ----------------------------------------------

module idct_dprtp(
    DCTINP, 
    CSFTPR, 
    CPRDI1, 
    CPRDI2, 
    CPRDI3,
    CPRDI4, 
    CTMOD1, 
    CTMOD2, 
    CTMOD3, 
    CPBTF, 
    CPLOAD, 
    CPRCT1,
    CPRCT2, 
    CPRCT3, 
    CPRCT4, 
    CPRCT5, 
    CPRCT6, 
    CPRCT7,
    CPRCT8, 
    clkdec,
    DAINXH, 
    DAINXL, 
    DAINYH, 
    DAINYL
);

input  [15:0] DCTINP; 
input         CSFTPR;         
input         CPRDI1;         
input         CPRDI2;         
input         CPRDI3;         
input         CPRDI4;         
input         CTMOD1;         
input         CTMOD2;         
input         CTMOD3;         
input         CPBTF;          
input         CPLOAD;         
input         CPRCT1;         
input         CPRCT2;         
input         CPRCT3;         
input         CPRCT4;         
input         CPRCT5;         
input         CPRCT6;         
input         CPRCT7;         
input         CPRCT8;         
input         clkdec;            
output [3:0]  DAINXH;  
output [3:0]  DAINXL;  
output [3:0]  DAINYH;  
output [3:0]  DAINYL;  

wire [15:0] DPX;
wire [15:0] DPY;
wire [15:0] DPADD;
wire [15:0]     DPSUB;

idct_prdin idct_prdin (
    .DPX(DPX), 
    .DPY(DPY), 
    .DCTINP(DCTINP), 
    .CSFTPR(CSFTPR),
    .CPRDI1(CPRDI1), 
    .CPRDI2(CPRDI2), 
    .CPRDI3(CPRDI3),
    .CPRDI4(CPRDI4), 
    .CTMODE(CTMOD1), 
    .clkdec(clkdec) 
);

idct_prbtf idct_prbtf (
    .DPADD(DPADD), 
    .DPSUB(DPSUB),
    .DPX(DPX), 
    .DPY(DPY), 
    .CPBTF(CPBTF), 
    .CTMODE(CTMOD2),
    .clkdec(clkdec) 
);

idct_prctt idct_prctt (
    .DAINXH(DAINXH), 
    .DAINXL(DAINXL), 
    .DAINYH(DAINYH),
    .DAINYL(DAINYL), 
    .DPX(DPADD), 
    .DPY(DPSUB), 
    .CPLOAD(CPLOAD),
    .CPRCT1(CPRCT1), 
    .CPRCT2(CPRCT2), 
    .CPRCT3(CPRCT3),                   
    .CPRCT4(CPRCT4), 
    .CPRCT5(CPRCT5), 
    .CPRCT6(CPRCT6),
    .CPRCT7(CPRCT7), 
    .CPRCT8(CPRCT8), 
    .CTMODE(CTMOD3),
    .clkdec(clkdec) 
);

endmodule

