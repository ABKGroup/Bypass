// ----------------------------------------------
// File: idct_dcttp.v
// Module: idct_dcttp
// Function:
// ----------------------------------------------

module idct_dcttp(
          LDTM0WEC81NF, 
          LDTM1WEC81NF,
          LDTM0DOX81DD, 
          LDTM1DOX81DD, 
          SIGXIN81DD, 
          DCTMOD81PF,
          STARTN81PP,
          rstdec_x, 
          clkdec,
          SIGOUT81DD, 
          DSYNCX81PP, 
          LDTM0DIN81DD, 
          LDTM0ADD81DD,
          LDTM1ADD81DD 
          );

input  [15:0]  LDTM0DOX81DD; 
input  [15:0]  LDTM1DOX81DD; 
input  [15:0]  SIGXIN81DD;   
input  DCTMOD81PF;           
input  STARTN81PP;           
input  rstdec_x;                
input  clkdec;                  
output [15:0]  SIGOUT81DD;   
output [15:0]  DSYNCX81PP;           
output [15:0]  LDTM0DIN81DD; 
output [5:0]  LDTM0ADD81DD;  
output [5:0]  LDTM1ADD81DD;  
output LDTM0WEC81NF;         
output LDTM1WEC81NF;         
 
reg [15:0] DDCTIP;
wire [15:0]     DTRNIP;
wire [15:0]     DTRNOP;
wire [15:0]     DDCTOP;
wire  DCTMODE1;
wire            DCTMODE2;
wire  GOTRN;
wire            GODCT2;
wire            GODATA;
wire  vacant;
 
always @(posedge clkdec) begin
   DDCTIP <= SIGXIN81DD;
end

 
 idct_dctxx idct_dctxx_1(
    .DCTOUT(DTRNIP), 
    .MODEOUT(DCTMODE1), 
    .GONEXT(GOTRN),
    .DCTINP(DDCTIP), 
    .GODCT(STARTN81PP), 
    .MODEIN(DCTMOD81PF),
    .rstdec_x(rstdec_x), 
    .clkdec(clkdec) 
 );
 
 idct_dctxx idct_dctxx_2(
    .DCTOUT(DDCTOP), 
    .MODEOUT(vacant), 
    .GONEXT(GODATA),
    .DCTINP(DTRNOP), 
    .GODCT(GODCT2), 
    .MODEIN(DCTMODE2),
    .rstdec_x(rstdec_x), 
    .clkdec(clkdec) 
);

 idct_trans idct_trans (
    .DTRNOP(DTRNOP), 
    .MODEOUT(DCTMODE2), 
    .GONEXT(GODCT2),
    .LDTM0DIN81DD(LDTM0DIN81DD),
    .LDTM0ADD81DD(LDTM0ADD81DD),
    .LDTM1ADD81DD(LDTM1ADD81DD),
    .LDTM0WEC81NF(LDTM0WEC81NF),
    .LDTM1WEC81NF(LDTM1WEC81NF),
    .DTRNIP(DTRNIP),
    .LDTM0DOX81DD(LDTM0DOX81DD),
    .LDTM1DOX81DD(LDTM1DOX81DD),
    .MODEIN(DCTMODE1),
    .GOTRN(GOTRN),
    .TEST(SIGXIN81DD),
    .RAMTEST(1'b0),
    .GOTEST(1'b0),
    .rstdec_x(rstdec_x),
    .clkdec(clkdec)
 );
 
 idct_zdout idct_zdout(
    .DDCTOP(DDCTOP),
    .GODATA(GODATA),
    .TEST(DTRNOP),
    .RTEST(1'b0),
    .rstdec_x(rstdec_x),
    .clkdec(clkdec),
    .SIGOUT81DD(SIGOUT81DD),
    .DSYNCX81PP(DSYNCX81PP)
);


endmodule

