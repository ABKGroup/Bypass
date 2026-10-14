// ----------------------------------------------
// File: idct_pccsl.v
// Module: idct_pccsl
// Function:
// ----------------------------------------------

module idct_pccsl(
    h, 
    l, 
    a, 
    b, 
    c, 
    d, 
    prct1, 
    prct2, 
    prct3, 
    prct4, 
    prct5, 
    prct6, 
    prct7,
    prct8
);
parameter w_size = 5'd16;    
output    [3:0]  h;       
output    [3:0]  l;       
input     [w_size-1:0] a; 
input     [w_size-1:0] b; 
input     [w_size-1:0] c; 
input     [w_size-1:0] d; 
input     prct1;          
input     prct2;          
input     prct3;          
input     prct4;          
input     prct5;          
input     prct6;          
input     prct7;          
input     prct8;          

reg [3:0]  regh, regl;

always @(prct1 or prct2 or prct3 or prct4 or prct5 or prct6 or prct7 or prct8 or a or b or c or d) begin
   if(prct1==1'b1)      regl = {a[0], b[0], c[0], d[0]};
   else if(prct2==1'b1) regl = {a[2], b[2], c[2], d[2]};
   else if(prct3==1'b1) regl = {a[4], b[4], c[4], d[4]};
   else if(prct4==1'b1) regl = {a[6], b[6], c[6], d[6]};
   else if(prct5==1'b1) regl = {a[8], b[8], c[8], d[8]};
   else if(prct6==1'b1) regl = {a[10], b[10], c[10], d[10]};
   else if(prct7==1'b1) regl = {a[12], b[12], c[12], d[12]};
   else if(prct8==1'b1) regl = {a[14], b[14], c[14], d[14]};
   else                 regl = 4'b0000;
end

always @(prct1 or prct2 or prct3 or prct4 or prct5 or prct6 or prct7 or prct8 or a or b or c or d) begin
   if     (prct1==1'b1) regh = {a[1], b[1], c[1], d[1]};
   else if(prct2==1'b1) regh = {a[3], b[3], c[3], d[3]};
   else if(prct3==1'b1) regh = {a[5], b[5], c[5], d[5]};
   else if(prct4==1'b1) regh = {a[7], b[7], c[7], d[7]};
   else if(prct5==1'b1) regh = {a[9], b[9], c[9], d[9]};
   else if(prct6==1'b1) regh = {a[11], b[11], c[11], d[11]};
   else if(prct7==1'b1) regh = {a[13], b[13], c[13], d[13]};
   else if(prct8==1'b1) regh = {a[15], b[15], c[15], d[15]};
   else                 regh = 4'b0000;
 end

assign h = regh;
assign l = regl;

endmodule

