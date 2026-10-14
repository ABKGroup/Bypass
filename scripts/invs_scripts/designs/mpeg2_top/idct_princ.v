// ----------------------------------------------
// File: idct_princ.v
// Module: idct_princ
// Function:
// ----------------------------------------------

module idct_princ(
    y, 
    a, 
    c);

parameter w_size = 5'd16;    
output    [w_size-1:0] y; 
input     [w_size-1:0] a; 
input     c;              

wire [w_size:0]  tmp_ac;
reg   add_sel;
wire [w_size-1:0] inc_s;
reg [w_size-1:0] y;
wire coo;

assign tmp_ac = {a, c};

always @(tmp_ac or c) begin
   if (tmp_ac[w_size] == 1'b1 | tmp_ac == 17'b0_1111_1111_1111_1111)
     add_sel = 1'b0;
   else
     add_sel = c;
end

assign {coo, inc_s} = a + 16'h0001;

always @(add_sel or a or inc_s) begin
   if (add_sel)
     y = inc_s;
   else
     y = a;
end
 
endmodule

