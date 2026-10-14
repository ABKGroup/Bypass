// ----------------------------------------------
// File: idct_macct.v
// Module: idct_macct
// Function:
// ----------------------------------------------

module idct_macct(
    DAH, 
    DAL, 
    CSIGN, 
    CADDCI, 
    CRST, 
    CPSMOD, 
    clkdec,
    DAOUT 
);

input  [16:0]  DAH;   
input  [17:0]  DAL;   
input  CSIGN;         
input  CADDCI;        
input  CRST;          
input  CPSMOD;        
input  clkdec;           
output [32:0]  DAOUT; 


 wire [17:0]  add0_a, add0_b, add0_y;
 wire         add0_ci, add0_co;
 wire [17:0]  add1_a, add1_b, add1_y;
 wire         add1_ci, add1_co;
 wire [15:0]  sft_y;
 wire [32:0]  dao_in, dao_out;
 wire         coo;
 wire [17:0]  brv_sel;
 wire [17:0]  add_sel;
 wire [32:0]  out_sel;

 reg [17:0]  reg_h, reg_l;
 reg [17:0]  reg_add0;
 reg [16:0]  reg_add1;
 reg         reg_add1c;
 reg [32:0]  out_reg;
 reg         CRST_reg1;
 reg         CRST_reg2;


always @(posedge clkdec) begin
    CRST_reg1 <= CRST;
end

always @(posedge clkdec) begin
    CRST_reg2 <= CRST;
end
 
assign brv_sel = (CSIGN==1'b1)? {~DAH[16:0], 1'b1} : {DAH[16:0], 1'b0};

always @(posedge clkdec) begin
    reg_h <= brv_sel;
    reg_l <= DAL;
end

assign add0_a = reg_h;
assign add0_b = reg_l;
assign add0_ci = CADDCI;

assign {add0_co, add0_y} = add0_a + add0_b + add0_ci;

always @(posedge clkdec) begin
    reg_add0 <= add0_y;
end

assign add_sel = (CRST_reg1==1'b1)? 18'b0 : {reg_add1c, reg_add1};

assign add1_a = reg_add0;
assign add1_b = add_sel;
assign add1_ci = 1'b0;

assign {coo,add1_co,add1_y} = {add1_a[17],add1_a} + {add1_b[17],add1_b} + add1_ci;

idct_masft idct_masft (
    .y(sft_y),
    .a1(add1_y[1]), 
    .a0(add1_y[0]), 
    .clkdec(clkdec) 
);

always @(posedge clkdec) begin
    reg_add1[16:0] <= {add1_co, add1_y[17:2]};
    reg_add1c <= add1_co;
end

assign dao_in = {reg_add1, sft_y};

assign dao_out = (CPSMOD==1'b1)? dao_in:{dao_in[30:0], 2'b0};


assign out_sel = (CRST_reg2==1'b1)? dao_out : out_reg-1;

always @(posedge clkdec) begin
    out_reg <= out_sel;
end

assign DAOUT = out_reg; 

endmodule

