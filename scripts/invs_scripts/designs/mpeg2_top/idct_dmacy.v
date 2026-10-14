// ----------------------------------------------
// File: idct_dmacy.v
// Module: idct_dmacy
// Function:
// ----------------------------------------------

module idct_dmacy(
    DAINYH, 
    DAINYL, 
    CACSGN, 
    SDAO4, 
    SDAO5, 
    SDAO6, 
    SDAO7, 
    CACRST,
    VDCT, 
    CPSMOD, 
    clkdec,
    DAOUTY
);

input  [3:0]  DAINYH;  
input  [3:0]  DAINYL;  
input  CACSGN;         
input  SDAO4;          
input  SDAO5;          
input  SDAO6;          
input  SDAO7;          
input  CACRST;         
input  VDCT;           
input  CPSMOD;         
input  clkdec;            
output [32:0]  DAOUTY; 

wire [15:0]  ADRH, ADRL;
wire [16:0]  dah4, dah5, dah6, dah7;
wire [17:0]  dal4, dal5, dal6, dal7;
wire [32:0]  daout4, daout5, daout6, daout7;
wire         CSIGN, CADDCI;
wire         CRST;
wire         cout4, cout5, cout6, cout7;

reg          caddci_reg;
reg          cout4_reg, cout5_reg, cout6_reg, cout7_reg;
reg  [32:0]  out_sel;

idct_dmade  idct_dmade (
    .DADRH(ADRH), 
    .DADRL(ADRL),
    .DAINH(DAINYH), 
    .DAINL(DAINYL), 
    .clkdec(clkdec) 
);

idct_romx4 idct_romx4 (
     .DAH(dah4), 
     .DAL(dal4),
     .ADRH(ADRH), 
     .ADRL(ADRL), 
     .MD(VDCT) 
); 

idct_romx5 idct_romx5 (
     .DAH(dah5), 
     .DAL(dal5),
     .ADRH(ADRH), 
     .ADRL(ADRL), 
     .MD(VDCT) 
); 

idct_romx6 idct_romx6 (
     .DAH(dah6), 
     .DAL(dal6),
     .ADRH(ADRH), 
     .ADRL(ADRL), 
     .MD(VDCT) 
); 

idct_romx7 idct_romx7 (
     .DAH(dah7), 
     .DAL(dal7),
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

idct_macct idct_macct_4 (
    .DAOUT(daout4),
    .DAH(dah4), 
    .DAL(dal4), 
    .CSIGN(CSIGN), 
    .CADDCI(CADDCI),
    .CRST(CRST),
    .CPSMOD(CPSMOD),
    .clkdec(clkdec)
);

idct_macct idct_macct_5 (
    .DAOUT(daout5),
    .DAH(dah5), 
    .DAL(dal5), 
    .CSIGN(CSIGN), 
    .CADDCI(CADDCI),
    .CRST(CRST),
    .CPSMOD(CPSMOD),
    .clkdec(clkdec)
);

idct_macct idct_macct_6 (
    .DAOUT(daout6),
    .DAH(dah6), 
    .DAL(dal6), 
    .CSIGN(CSIGN), 
    .CADDCI(CADDCI),
    .CRST(CRST),
    .CPSMOD(CPSMOD),
    .clkdec(clkdec)
);

idct_macct idct_macct_7 (
    .DAOUT(daout7),
    .DAH(dah7), 
    .DAL(dal7), 
    .CSIGN(CSIGN), 
    .CADDCI(CADDCI),
    .CRST(CRST),
    .CPSMOD(CPSMOD),
    .clkdec(clkdec)
);

always @(posedge clkdec) begin
    cout4_reg <= SDAO4;
    cout5_reg <= SDAO5;
    cout6_reg <= SDAO6;
    cout7_reg <= SDAO7;
end

assign cout4 = cout4_reg;
assign cout5 = cout5_reg;
assign cout6 = cout6_reg;
assign cout7 = cout7_reg;

always @(cout4 or cout5 or cout6 or cout7 or daout4 or daout5 or daout6 or daout7) begin
    if(cout4==1'b1)
        out_sel = daout4;
    else if(cout5==1'b1)
        out_sel = daout5;
    else if(cout6==1'b1)
        out_sel = daout6;
    else if(cout7==1'b1)
        out_sel = daout7;
    else
        out_sel = 33'b0;
end

assign DAOUTY = out_sel;

endmodule

