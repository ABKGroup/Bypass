// ----------------------------------------------
// File: idct_prctt.v
// Module: idct_prctt
// Function:
// ----------------------------------------------

module idct_prctt(
    DAINXH, 
    DAINXL, 
    DAINYH, 
    DAINYL, 
    DPX, 
    DPY, 
    CPLOAD, 
    CPRCT1, 
    CPRCT2,
    CPRCT3, 
    CPRCT4, 
    CPRCT5, 
    CPRCT6, 
    CPRCT7, 
    CPRCT8,
    CTMODE,
    clkdec
);

parameter w_size = 5'd16;      
output    [3:0]  DAINXH;    
output    [3:0]  DAINXL;    
output    [3:0]  DAINYH;    
output    [3:0]  DAINYL;    
input     [w_size-1:0] DPX; 
input     [w_size-1:0] DPY; 
input     CPLOAD;           
input     CPRCT1;           
input     CPRCT2;           
input     CPRCT3;           
input     CPRCT4;           
input     CPRCT5;           
input     CPRCT6;           
input     CPRCT7;           
input     CPRCT8;           
input     CTMODE;           
input     clkdec;              

reg   prct1, prct2, prct3, prct4,
      prct5, prct6, prct7, prct8;
wire   ctux_1, ctux_2, ctux_3, ctux_4,
       ctux_5, ctux_6, ctux_7, ctux_8;
wire   ctuy_1, ctuy_2, ctuy_3, ctuy_4,
       ctuy_5, ctuy_6, ctuy_7, ctuy_8;

always @(posedge clkdec) begin
   prct1 <= CPRCT1;
   prct2 <= CPRCT2;
   prct3 <= CPRCT3;
   prct4 <= CPRCT4;
   prct5 <= CPRCT5;
   prct6 <= CPRCT6;
   prct7 <= CPRCT7;
   prct8 <= CPRCT8;
end

assign ctux_1 = prct1;
assign ctux_2 = prct2;
assign ctux_3 = prct3;
assign ctux_4 = prct4;
assign ctux_5 = prct5;
assign ctux_6 = prct6;
assign ctux_7 = prct7;
assign ctux_8 = prct8;

assign ctuy_1 = prct1;
assign ctuy_2 = prct2;
assign ctuy_3 = prct3;
assign ctuy_4 = prct4;
assign ctuy_5 = prct5;
assign ctuy_6 = prct6;
assign ctuy_7 = prct7;
assign ctuy_8 = prct8;


idct_prctu idct_prctu_0 (
    .DAINXH(DAINXH), 
    .DAINXL(DAINXL), 
    .DPX(DPX),
    .CPLOAD(CPLOAD), 
    .CPRCT1(ctux_1), 
    .CPRCT2(ctux_2),
    .CPRCT3(ctux_3), 
    .CPRCT4(ctux_4), 
    .CPRCT5(ctux_5),
    .CPRCT6(ctux_6), 
    .CPRCT7(ctux_7), 
    .CPRCT8(ctux_8),
    .CTMODE(CTMODE), 
    .clkdec(clkdec) 
);

idct_prctu idct_prctu_1 (
    .DAINXH(DAINYH), 
    .DAINXL(DAINYL), 
    .DPX(DPY),
    .CPLOAD(CPLOAD), 
    .CPRCT1(ctuy_1), 
    .CPRCT2(ctuy_2),
    .CPRCT3(ctuy_3), 
    .CPRCT4(ctuy_4), 
    .CPRCT5(ctuy_5),
    .CPRCT6(ctuy_6), 
    .CPRCT7(ctuy_7), 
    .CPRCT8(ctuy_8),
    .CTMODE(CTMODE), 
    .clkdec(clkdec) 
);

endmodule

