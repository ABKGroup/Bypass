// ----------------------------------------------
// File: idct_trans.v
// Module: idct_trans
// Function:
// ----------------------------------------------

module idct_trans(
     DTRNIP, 
     LDTM0DOX81DD, 
     LDTM1DOX81DD, 
     MODEIN,
     GOTRN, 
     TEST, 
     RAMTEST, 
     GOTEST, 
     rstdec_x, 
     clkdec,
     DTRNOP, 
     MODEOUT, 
     GONEXT, 
     LDTM0DIN81DD, 
     LDTM0ADD81DD,
     LDTM1ADD81DD, 
     LDTM0WEC81NF, 
     LDTM1WEC81NF
);

input  [15:0]  DTRNIP;       
input  [15:0]  LDTM0DOX81DD; 
input  [15:0]  LDTM1DOX81DD; 
input          MODEIN;               
input          GOTRN;                
input  [15:0]  TEST;         
input          RAMTEST;              
input          GOTEST;               
input          rstdec_x;                
input          clkdec;                  
output [15:0]  DTRNOP;       
output         MODEOUT;              
output         GONEXT;               
output [15:0]  LDTM0DIN81DD; 
output [5:0]   LDTM0ADD81DD;  
output [5:0]   LDTM1ADD81DD;  
output         LDTM0WEC81NF;         
output         LDTM1WEC81NF;         

reg [15:0] test_sel, in_reg ;
wire       OEC1;
wire       OEC2;

always @(RAMTEST or DTRNIP or TEST) begin
    if(RAMTEST==1'b1) test_sel = TEST;
    else              test_sel = DTRNIP;
end

always @(posedge clkdec) begin
  in_reg <= test_sel;
end

assign LDTM0DIN81DD = in_reg;

idct_trnsq idct_trnsq(
     .LDTM0ADD81DD(LDTM0ADD81DD), 
     .LDTM1ADD81DD(LDTM1ADD81DD),
     .LDTM0WEC81NF(LDTM0WEC81NF), 
     .LDTM1WEC81NF(LDTM1WEC81NF),
     .OEC1(OEC1), 
     .OEC2(OEC2), 
     .MODEOUT(MODEOUT), 
     .GONEXT(GONEXT),
     .MODEIN(MODEIN), 
     .GOTRN(GOTRN), 
     .GOTEST(GOTEST),
     .rstdec_x(rstdec_x), 
     .clkdec(clkdec)
);

reg OEC1D;
reg OEC2D;

always @(posedge clkdec) begin
    OEC1D <= OEC1;
    OEC2D <= OEC2;
end

assign DTRNOP = DSEL(OEC1D,OEC2D,LDTM0DOX81DD,LDTM1DOX81DD);

function  [15:0] DSEL;
    input  C0;
    input  C1;
    input [15:0] M0;
    input [15:0] M1;
begin
  if(C0==1'b0)
    DSEL = M0;
  else if(C1==0)
    DSEL = M1;
  else
    DSEL = 16'h0000;
 end
endfunction

endmodule

