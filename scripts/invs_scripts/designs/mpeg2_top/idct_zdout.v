// ----------------------------------------------
// File: idct_zdout.v
// Module: idct_zdout
// Function:
// ----------------------------------------------

module idct_zdout(
     DDCTOP,
     GODATA, 
     TEST, 
     RTEST, 
     rstdec_x, 
     clkdec,
     SIGOUT81DD, 
     DSYNCX81PP 
);

input  [15:0]  DDCTOP;     
input          GODATA;             
input  [15:0]  TEST;       
input          RTEST;              
input          rstdec_x;              
input          clkdec;                
output [15:0]  SIGOUT81DD; 
output [15:0]  DSYNCX81PP;         

reg [15:0] go_reg0, go_reg1, go_reg2;
reg [15:0] muxout, out_reg;

always @(posedge clkdec) begin
   go_reg0 <= GODATA;
end

always @(posedge clkdec or negedge rstdec_x) begin
   if( !rstdec_x )
     go_reg1 <= 1'b0;
   else
     go_reg1 <= go_reg0;
end

always @(posedge clkdec or negedge rstdec_x) begin
   if(!rstdec_x)
     go_reg2 <= 1'b0;
   else
     go_reg2 <= go_reg1;
end

assign DSYNCX81PP = go_reg2;

always @(RTEST or DDCTOP or TEST) begin
  if(RTEST==1'b1)   muxout = TEST;
  else              muxout = DDCTOP;
end
 
always @(posedge clkdec) begin
  out_reg <= muxout;
end

assign SIGOUT81DD = out_reg;

endmodule

