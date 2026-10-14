// ----------------------------------------------
// File: idct_dmacx.v
// Module: idct_dmacx
// Function:
// ----------------------------------------------

module idct_dmacx(
    DAINXH, 
    DAINXL, 
    CACSGN, 
    SDAO0, 
    SDAO1, 
    SDAO2, 
    SDAO3, 
    CACRST,
    VDCT, 
    CPSMOD, 
    clkdec,
    DAOUTX
);

input  [3:0]  DAINXH;  
input  [3:0]  DAINXL;  
input  CACSGN;         
input  SDAO0;          
input  SDAO1;          
input  SDAO2;          
input  SDAO3;          
input  CACRST;         
input  VDCT;           
input  CPSMOD;         
input  clkdec;            
output [32:0]  DAOUTX; 


wire [15:0]  ADRH, ADRL;
wire [16:0]  dah0, dah1, dah2, dah3;
wire [17:0]  dal0, dal1, dal2, dal3;
wire [32:0]  daout0, daout1, daout2, daout3;
wire         CSIGN, CADDCI;
wire         CRST;
wire         cout0, cout1, cout2, cout3;

reg          caddci_reg;
reg          cout0_reg, cout1_reg, cout2_reg, cout3_reg;
reg  [32:0]  out_sel;

idct_dmade  idct_dmade (
    .DADRH(ADRH), 
    .DADRL(ADRL),
    .DAINH(DAINXH), 
    .DAINL(DAINXL), 
    .clkdec(clkdec) 
);

idct_romx0 idct_romx0 (
    .DAH(dah0), 
    .DAL(dal0),
    .ADRH(ADRH), 
    .ADRL(ADRL), 
    .MD(VDCT) 
);

idct_romx1 idct_romx1 (
    .DAH(dah1), 
    .DAL(dal1),
    .ADRH(ADRH), 
    .ADRL(ADRL), 
    .MD(VDCT) 
);

idct_romx2 idct_romx2 (
    .DAH(dah2), 
    .DAL(dal2),
    .ADRH(ADRH), 
    .ADRL(ADRL), 
    .MD(VDCT) 
);

idct_romx3 idct_romx3 (
    .DAH(dah3), 
    .DAL(dal3),
    .ADRH(ADRH), 
    .ADRL(ADRL), 
    .MD(VDCT) 
);

always @(posedge clkdec) begin
    caddci_reg <= CACSGN;
end

assign CSIGN = CACSGN;
assign CADDCI = caddci_reg;

assign CRST = CACRST;

idct_macct idct_macct_0 (
     .DAOUT(daout0), 
     .DAH(dah0), 
     .DAL(dal0), 
     .CSIGN(CSIGN), 
     .CADDCI(CADDCI),
     .CRST(CRST), 
     .CPSMOD(CPSMOD), 
     .clkdec(clkdec) 
);

idct_macct idct_macct_1 (
     .DAOUT(daout1), 
     .DAH(dah1), 
     .DAL(dal1), 
     .CSIGN(CSIGN), 
     .CADDCI(CADDCI),
     .CRST(CRST), 
     .CPSMOD(CPSMOD), 
     .clkdec(clkdec) 
);

idct_macct idct_macct_2 (
     .DAOUT(daout2), 
     .DAH(dah2), 
     .DAL(dal2), 
     .CSIGN(CSIGN), 
     .CADDCI(CADDCI),
     .CRST(CRST), 
     .CPSMOD(CPSMOD), 
     .clkdec(clkdec) 
);

idct_macct idct_macct_3 (
     .DAOUT(daout3), 
     .DAH(dah3), 
     .DAL(dal3), 
     .CSIGN(CSIGN), 
     .CADDCI(CADDCI),
     .CRST(CRST), 
     .CPSMOD(CPSMOD), 
     .clkdec(clkdec) 
);

always @(posedge clkdec) begin
   cout0_reg <= SDAO0;
   cout1_reg <= SDAO1;
   cout2_reg <= SDAO2;
   cout3_reg <= SDAO3;
end

assign cout0 = cout0_reg;
assign cout1 = cout1_reg;
assign cout2 = cout2_reg;
assign cout3 = cout3_reg;

always @(cout0 or cout1 or cout2 or cout3 or daout0 or daout1 or daout2 or daout3) begin
    if(cout0==1'b1)
        out_sel = daout0;
    else if(cout1==1'b1)
        out_sel = daout1;
    else if(cout2==1'b1)
        out_sel = daout2;
    else if(cout3==1'b1)
        out_sel = daout3;
    else 
        out_sel = 33'b0;
end

assign DAOUTX = out_sel;

endmodule


