// ----------------------------------------------
// File: idct_dmade.v
// Module: idct_dmade
// Function:
// ----------------------------------------------

module idct_dmade(
    DAINH, 
    DAINL, 
    clkdec,
    DADRH, 
    DADRL 
);

input  [3:0]  DAINH;  
input  [3:0]  DAINL;  
input         clkdec;           
output [15:0] DADRH; 
output [15:0] DADRL; 
 
wire [3:0]  preout0, preout1, preout2, preout3;
wire [3:0]  dec0h, dec0l, dec1h, dec1l;
wire [15:0] dec0y, dec1y;
reg  [15:0] out_reg0, out_reg1;

assign preout0[0] = ~DAINH[1] & ~DAINH[0];
assign preout0[1] = ~DAINH[1] & DAINH[0];
assign preout0[2] = DAINH[1] & ~DAINH[0];
assign preout0[3] = DAINH[1] & DAINH[0];

assign preout1[0] = ~DAINH[3] & ~DAINH[2];
assign preout1[1] = ~DAINH[3] & DAINH[2];
assign preout1[2] = DAINH[3] & ~DAINH[2];
assign preout1[3] = DAINH[3] & DAINH[2];

assign preout2[0] = ~DAINL[1] & ~DAINL[0];
assign preout2[1] = ~DAINL[1] & DAINL[0];
assign preout2[2] = DAINL[1] & ~DAINL[0];
assign preout2[3] = DAINL[1] & DAINL[0];

assign preout3[0] = ~DAINL[3] & ~DAINL[2];
assign preout3[1] = ~DAINL[3] & DAINL[2];
assign preout3[2] = DAINL[3] & ~DAINL[2];
assign preout3[3] = DAINL[3] & DAINL[2];


assign dec0h = preout1;
assign dec0l = preout0;
assign dec1h = preout3;
assign dec1l = preout2;

assign dec0y[0] = dec0h[0] & dec0l[0];
assign dec0y[1] = dec0h[0] & dec0l[1];
assign dec0y[2] = dec0h[0] & dec0l[2];
assign dec0y[3] = dec0h[0] & dec0l[3];
assign dec0y[4] = dec0h[1] & dec0l[0];
assign dec0y[5] = dec0h[1] & dec0l[1];
assign dec0y[6] = dec0h[1] & dec0l[2];
assign dec0y[7] = dec0h[1] & dec0l[3];
assign dec0y[8] = dec0h[2] & dec0l[0];
assign dec0y[9] = dec0h[2] & dec0l[1];
assign dec0y[10] = dec0h[2] & dec0l[2];
assign dec0y[11] = dec0h[2] & dec0l[3];
assign dec0y[12] = dec0h[3] & dec0l[0];
assign dec0y[13] = dec0h[3] & dec0l[1];
assign dec0y[14] = dec0h[3] & dec0l[2];
assign dec0y[15] = dec0h[3] & dec0l[3];

assign dec1y[0] = dec1h[0] & dec1l[0];
assign dec1y[1] = dec1h[0] & dec1l[1];
assign dec1y[2] = dec1h[0] & dec1l[2];
assign dec1y[3] = dec1h[0] & dec1l[3];
assign dec1y[4] = dec1h[1] & dec1l[0];
assign dec1y[5] = dec1h[1] & dec1l[1];
assign dec1y[6] = dec1h[1] & dec1l[2];
assign dec1y[7] = dec1h[1] & dec1l[3];
assign dec1y[8] = dec1h[2] & dec1l[0];
assign dec1y[9] = dec1h[2] & dec1l[1];
assign dec1y[10] = dec1h[2] & dec1l[2];
assign dec1y[11] = dec1h[2] & dec1l[3];
assign dec1y[12] = dec1h[3] & dec1l[0];
assign dec1y[13] = dec1h[3] & dec1l[1];
assign dec1y[14] = dec1h[3] & dec1l[2];
assign dec1y[15] = dec1h[3] & dec1l[3];

always @(posedge clkdec) begin
    out_reg0 <= dec0y;
    out_reg1 <= dec1y;
end

assign DADRH = out_reg0;
assign DADRL = out_reg1;

endmodule

