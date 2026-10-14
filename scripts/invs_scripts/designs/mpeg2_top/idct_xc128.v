// ----------------------------------------------
// File: idct_xc128.v
// Module: idct_xc128
// Function:
// ----------------------------------------------

module idct_xc128(
      rstdec_x, 
      clkdec, 
      mrst, 
      ct);

parameter c_size = 3'd7;                
parameter r_size = 8'd128; 

input     rstdec_x;
input     clkdec;                       
input     mrst;                       
output    [c_size-1:0] ct; 

reg [c_size-1:0] ct;
wire [c_size:0]  incout;

function [c_size:0] incr_128;
  input [c_size:0] d;
  begin
    if (d >= r_size - 1'b1) 
      incr_128 = 8'b0;
    else
      incr_128 = d[6:0] + 7'b1; 
  end
endfunction

always @(posedge clkdec or negedge rstdec_x) begin
    if (!rstdec_x) 
      ct <= 0;
    else if(mrst==1'b0)
      ct <= 0;
    else 
      ct <= incout[6:0];
end

assign incout = incr_128 ({1'b0, ct});

endmodule
