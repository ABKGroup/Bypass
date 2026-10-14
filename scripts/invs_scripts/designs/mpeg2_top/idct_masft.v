// ----------------------------------------------
// File: idct_masft.v
// Module: idct_masft
// Function:
// ----------------------------------------------

module idct_masft(
    y, 
    a1, 
    a0, 
    clkdec
);

parameter w_size = 5'd16;    

output    [w_size-1:0] y; 
input     a1;             
input     a0;             
input     clkdec;            

reg   reg_0, reg_1, reg_2, reg_3, reg_4, 
      reg_5, reg_6, reg_7, reg_8, reg_9, 
      reg_10, reg_11, reg_12, reg_13, reg_14, reg_15;

always @(posedge clkdec) begin
   reg_0 <= reg_2;
   reg_2 <= reg_4;
   reg_4 <= reg_6;
   reg_6 <= reg_8;
   reg_8 <= reg_10;
   reg_10 <= reg_12;
   reg_12 <= reg_14;
   reg_14 <= a0;
end

always @(posedge clkdec) begin
   reg_1 <= reg_3;
   reg_3 <= reg_5;
   reg_5 <= reg_7;
   reg_7 <= reg_9;
   reg_9 <= reg_11;
   reg_11 <= reg_13;
   reg_13 <= reg_15;
   reg_15 <= a1;
end

assign y[0] = reg_0;
assign y[1] = reg_1;
assign y[2] = reg_2;
assign y[3] = reg_3;
assign y[4] = reg_4;
assign y[5] = reg_5;
assign y[6] = reg_6;
assign y[7] = reg_7;
assign y[8] = reg_8;
assign y[9] = reg_9;
assign y[10] = reg_10;
assign y[11] = reg_11;
assign y[12] = reg_12;
assign y[13] = reg_13;
assign y[14] = reg_14;
assign y[15] = reg_15;

endmodule

