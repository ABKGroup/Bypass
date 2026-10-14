// ----------------------------------------------
// File: idct_prctu.v
// Module: idct_prctu
// Function:
// ----------------------------------------------

module idct_prctu(
    DAINXH, 
    DAINXL, 
    DPX,  
    CPLOAD, 
    CPRCT1, 
    CPRCT2, 
    CPRCT3, 
    CPRCT4, 
    CPRCT5,
    CPRCT6, 
    CPRCT7, 
    CPRCT8, 
    CTMODE, 
    clkdec
);

parameter w_size = 5'd16;      
output    [3:0]  DAINXH;    
output    [3:0]  DAINXL;    
input     [w_size-1:0] DPX; 
input     CPLOAD;           
input     CPRCT1;           
input     CPRCT2;           
input     CPRCT3;           
input     CPRCT4;           
input     CPRCT5;           
input     CPRCT6;           
input     CPRCT7;           
input     CPRCT8;           
input     CTMODE;           
input     clkdec;              

reg [w_size-1:0] reg0, reg1, reg2, reg3,
                 reg4, reg5, reg6, reg7;
reg [3:0]        out_regh, out_regl;

wire [w_size-1:0] in_sel4, in_sel5, in_sel6, in_sel7;
wire [w_size-1:0] mux_a, mux_b, mux_c, mux_d;
wire [3:0]        mux_h, mux_l;
wire [3:0]        m_sel1, m_sel2;

always @(posedge clkdec) begin
   reg3 <= reg2;
   reg2 <= reg1;
   reg1 <= reg0;
   reg0 <= DPX;
end

assign in_sel4 = (CPLOAD==1'b1)? reg0:reg4;
assign in_sel5 = (CPLOAD==1'b1)? reg1:reg5;
assign in_sel6 = (CPLOAD==1'b1)? reg2:reg6;
assign in_sel7 = (CPLOAD==1'b1)? reg3:reg7;

always @(posedge clkdec) begin
   reg4 <= in_sel4;
   reg5 <= in_sel5;
   reg6 <= in_sel6;
   reg7 <= in_sel7;
end

assign mux_d = reg4;
assign mux_c = reg5;
assign mux_b = reg6;
assign mux_a = reg7;

idct_pccsl idct_pccsl (
    .h(mux_h), 
    .l(mux_l),
    .a(mux_a), 
    .b(mux_b), 
    .c(mux_c), 
    .d(mux_d),
    .prct1(CPRCT1), 
    .prct2(CPRCT2), 
    .prct3(CPRCT3),
    .prct4(CPRCT4), 
    .prct5(CPRCT5), 
    .prct6(CPRCT6),
    .prct7(CPRCT7), 
    .prct8(CPRCT8) 
);

assign m_sel1 = (CTMODE==1'b1)? mux_h:{mux_h[0], mux_h[1], mux_h[2], mux_h[3]};
assign m_sel2 = (CTMODE==1'b1)? mux_l:{mux_l[0], mux_l[1], mux_l[2], mux_l[3]};


always @(posedge clkdec) begin
   out_regh <= m_sel1;
   out_regl <= m_sel2;
end

assign DAINXH = out_regh;
assign DAINXL = out_regl;

endmodule

