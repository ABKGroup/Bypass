// ----------------------------------------------
// File: idct_round.v
// Module: idct_round
// Function:Round Inverse DCT result
// ----------------------------------------------

module idct_round(
    clkdec,
    rstdec_x,
    di, 
    do_r
);
input         clkdec;
input         rstdec_x;
input  [15:0] di; 
output [8:0]  do_r;
reg    [8:0]  do_r;

always@( posedge clkdec or negedge rstdec_x) begin
  if(!rstdec_x)
    do_r <= 9'd0;
  else
    if( di[15] )
      if( (|di[5:0]) && di[6] )
        do_r <= di[15:7] + 1'b1;
      else
        do_r <= di[15:7];
    else
      if( di[15:7] == 9'h0ff )
        do_r <= 9'h0ff;
      else if( di[6] )
        do_r <= di[15:7] + 1'b1;
      else
        do_r <= di[15:7];
end 

endmodule

