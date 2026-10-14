// ----------------------------------------------
// File: idct_trnad.v
// Module: idct_trnad
// Function:
// ----------------------------------------------

module idct_trnad(
    clkdec, 
    CI, 
    DO
);

input  clkdec;       
input  [6:0]  CI; 
output [5:0]  DO; 

reg [5:0]  DO;
reg        d0, d1, d2, d3, d4, d5;

always @(CI) begin
  if (CI[6] == 1'b0) begin
    d5 = CI[5];
    d4 = CI[4];
    d3 = CI[3];
    d2 = CI[2];
    d1 = CI[1];
    d0 = CI[0];
  end 
  else if (CI[6] == 1'b1) begin
    d5 = CI[2];
    d4 = CI[1];
    d3 = CI[0];
    d2 = CI[5];
    d1 = CI[4];
    d0 = CI[3];
  end 
  else begin
    d5 = 1'bx;
    d4 = 1'bx;
    d3 = 1'bx;
    d2 = 1'bx;
    d1 = 1'bx;
    d0 = 1'bx;
  end
 end

 always @(posedge clkdec) begin
  DO[5] <= d5;
  DO[4] <= d4;
  DO[3] <= d3;
  DO[2] <= d2;
  DO[1] <= d1;
  DO[0] <= d0;
 end

endmodule

