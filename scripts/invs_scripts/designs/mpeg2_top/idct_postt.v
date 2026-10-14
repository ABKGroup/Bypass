// ----------------------------------------------
// File: idct_postt.v
// Module: idct_postt
// Function:
// ----------------------------------------------

module idct_postt(
    DX, 
    DY, 
    CPSADD, 
    clkdec,
    DCTOUT 
);

parameter w_size = 5'd16;         

input  [32:0]  DX;          
input  [32:0]  DY;          
input          CPSADD;              
input          clkdec;                 
output [w_size-1:0] DCTOUT; 

wire [31:0]  DAZ;

idct_pobtf idct_pobtf (
    .ZOUT(DAZ),
    .XIN(DX), 
    .YIN(DY), 
    .CPSADD(CPSADD), 
    .clkdec(clkdec) 
);

idct_pornt idct_pornt (
    .DCTOUT(DCTOUT), 
    .DAZ(DAZ[31:0]), 
    .clkdec(clkdec) 
);

endmodule

