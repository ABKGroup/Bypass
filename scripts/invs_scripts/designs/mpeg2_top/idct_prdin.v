// ----------------------------------------------
// File: idct_prdin.v
// Module: idct_prdin
// Function:
// ----------------------------------------------

module idct_prdin(
    DCTINP, 
    CSFTPR, 
    CPRDI1, 
    CPRDI2, 
    CPRDI3, 
    CPRDI4, 
    CTMODE,
    clkdec,
    DPX, 
    DPY 
);

input  [15:0]  DCTINP; 
input  CSFTPR;         
input  CPRDI1;         
input  CPRDI2;         
input  CPRDI3;         
input  CPRDI4;         
input  CTMODE;         
input  clkdec;            
output [15:0]  DPX;    
output [15:0]  DPY;    

reg [15:0] sreg0, sreg1, sreg2, sreg3, sreg4;
reg [15:0] outselx, outsely;
reg sprdi1, sprdi2, sprdi3, sprdi4,sprdi5, sprdi6, sprdi7, sprdi8;
reg csftpr_reg;

wire [15:0] sftsel1, sftsel2, sftsel3, sftsel4;
wire msel1, msel2, msel3, msel4, msel5, msel6, msel7, msel8;

always @(posedge clkdec) begin
    sreg0 <= DCTINP;
    sreg1 <= sftsel1;
    sreg2 <= sftsel2;
    sreg3 <= sftsel3;
    sreg4 <= sftsel4;
end

always @(posedge clkdec) begin
    csftpr_reg <= CSFTPR;
end

assign sftsel1 = (csftpr_reg==1'b1)? sreg0:sreg1;
assign sftsel2 = (csftpr_reg==1'b1)? sreg1:sreg2;
assign sftsel3 = (csftpr_reg==1'b1)? sreg2:sreg3;
assign sftsel4 = (csftpr_reg==1'b1)? sreg3:sreg4;

assign msel1 = (CTMODE==1'b1)? CPRDI1:CPRDI4;
assign msel2 = (CTMODE==1'b1)? CPRDI2:CPRDI3;
assign msel3 = (CTMODE==1'b1)? CPRDI3:CPRDI2;
assign msel4 = (CTMODE==1'b1)? CPRDI4:CPRDI1;
assign msel5 = (CTMODE==1'b1)? 1'b1:CPRDI4;
assign msel6 = (CTMODE==1'b1)? 1'b0:CPRDI3;
assign msel7 = (CTMODE==1'b1)? 1'b0:CPRDI2;
assign msel8 = (CTMODE==1'b1)? 1'b0:CPRDI1;

always @(posedge clkdec) begin
    sprdi1 <= msel1;
    sprdi2 <= msel2;
    sprdi3 <= msel3;
    sprdi4 <= msel4;
    sprdi5 <= msel5;
    sprdi6 <= msel6;
    sprdi7 <= msel7;
    sprdi8 <= msel8;
end

always @(sprdi5 or sprdi6 or sprdi7 or sprdi8 or sreg0 or sreg1 or sreg2 or sreg3) begin
    if(sprdi5==1'b1)
        outselx = sreg0;
    else if(sprdi6==1'b1)
        outselx = sreg1;
    else if(sprdi7==1'b1)
        outselx = sreg2;
    else if(sprdi8==1'b1)
        outselx = sreg3;
    else
        outselx = 16'h0000;
end

always @(sprdi1 or sprdi2 or sprdi3 or sprdi4 or sreg1 or sreg2 or sreg3 or sreg4) begin
    if(sprdi1==1'b1)
        outsely = sreg1;
    else if(sprdi2==1'b1)
        outsely = sreg2;
    else if(sprdi3==1'b1)
        outsely = sreg3;
    else if(sprdi4==1'b1)
        outsely = sreg4;
    else
        outsely = 16'h0000;
end

assign DPX = outselx;
assign DPY = outsely;

endmodule

