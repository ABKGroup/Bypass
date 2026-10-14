// ----------------------------------------------
// File: idct_mactp.v
// Module: idct_mactp
// Function:
// ----------------------------------------------

module idct_mactp( 
        DAINXH, 
        DAINXL, 
        DAINYH, 
        DAINYL, 
        CACSGN, 
        SDAO0, 
        SDAO1,
        SDAO2, 
        SDAO3, 
        SDAO4, 
        SDAO5, 
        SDAO6, 
        SDAO7, 
        CACRST,
        VDCT, 
        CPSMOD, 
        clkdec,
        DAOUTX, 
        DAOUTY
);
input  [3:0]  DAINXH;  
input  [3:0]  DAINXL;  
input  [3:0]  DAINYH;  
input  [3:0]  DAINYL;  
input  CACSGN;         
input  SDAO0;          
input  SDAO1;          
input  SDAO2;          
input  SDAO3;          
input  SDAO4;          
input  SDAO5;          
input  SDAO6;          
input  SDAO7;          
input  CACRST;         
input  VDCT;           
input  CPSMOD;         
input  clkdec;            
output [32:0]  DAOUTX; 
output [32:0]  DAOUTY; 

idct_dmacx idct_dmacx (
        .DAOUTX(DAOUTX), 
        .DAINXH(DAINXH), 
        .DAINXL(DAINXL), 
        .CACSGN(CACSGN),
        .SDAO0(SDAO0), 
        .SDAO1(SDAO1), 
        .SDAO2(SDAO2), 
        .SDAO3(SDAO3),
        .CACRST(CACRST), 
        .VDCT(VDCT),
        .CPSMOD(CPSMOD), 
        .clkdec(clkdec) 
);

idct_dmacy idct_dmacy (
        .DAOUTY(DAOUTY),     
        .DAINYH(DAINYH), 
        .DAINYL(DAINYL), 
        .CACSGN(CACSGN),      
        .SDAO4(SDAO4), 
        .SDAO5(SDAO5), 
        .SDAO6(SDAO6), 
        .SDAO7(SDAO7),                    
        .CACRST(CACRST), 
        .VDCT(VDCT),                    
        .CPSMOD(CPSMOD), 
        .clkdec(clkdec) 
);

endmodule
