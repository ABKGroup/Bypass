// ----------------------------------------------
// File: idct_prbtf.v
// Module: idct_prbtf
// Function:
// ----------------------------------------------

module idct_prbtf(
    DPX, 
    DPY, 
    CPBTF, 
    CTMODE, 
    clkdec,
    DPADD, 
    DPSUB
);

input  [15:0]  DPX;   
input  [15:0]  DPY;   
input  CPBTF;         
input  CTMODE;        
input  clkdec;           
output [15:0]  DPADD; 
output [15:0]  DPSUB; 

wire [15:0] add0_a, add0_b, add0_y;
wire        add0_ci, add0_co;
wire [15:0] add1_a, add1_b, add1_y;
wire        add1_ci, add1_co;
wire [15:0] sft0_a, sft1_a;
wire        sft0_c, sft1_c, sft0_mod, sft1_mod;
wire [15:0] inc0_y, inc1_y;
wire        sdct1,coo0,coo1;
wire [15:0] add_sel, sub_sel, brv;
wire [15:0] in_sel0, in_sel1, in_sel2, in_sel3;

reg [15:0] sft0_x, sft1_x;
reg        sft0_y, sft1_y;
reg [15:0] in_reg0, in_reg1, in_reg2, in_reg3;
reg        mid_reg0, mid_reg2;
reg [15:0] mid_reg1, mid_reg3;
reg [15:0] out_reg0, out_reg1;
reg        sdct2, sdct3;

assign sdct1 = CTMODE;

always @(posedge clkdec) begin
    sdct3 <= sdct2;
    sdct2 <= CTMODE;
end

assign add_sel = (sdct1==1'b1)? DPX:16'b0 ;
assign sub_sel = (sdct1==1'b1)? DPY:16'b0 ;
assign brv = (sdct1==1'b1)? ~DPX:DPX ;

assign in_sel0 = (CPBTF==1'b1)? DPY:in_reg0 ;
assign in_sel1 = (CPBTF==1'b1)? add_sel:in_reg1 ;
assign in_sel2 = (CPBTF==1'b1)? sub_sel:in_reg2 ;
assign in_sel3 = (CPBTF==1'b1)? brv:in_reg3 ;

always @(posedge clkdec) begin
    in_reg0 <= in_sel0;
    in_reg1 <= in_sel1;
    in_reg2 <= in_sel2;
    in_reg3 <= in_sel3;
end

assign add0_a = in_reg0;
assign add0_b = in_reg1;
assign add0_ci = 1'b0;

assign add1_a = in_reg2;
assign add1_b = in_reg3;
assign add1_ci = sdct2;

assign {coo0, {add0_co,add0_y}} = 
            {add0_a[15],add0_a} + {add0_b[15],add0_b} + add0_ci;

assign {coo1, {add1_co,add1_y}} = 
            {add1_a[15],add1_a} + {add1_b[15],add1_b} + add1_ci;

always @(posedge clkdec) begin
    mid_reg0 <= add0_co;
    mid_reg1 <= add0_y;
    mid_reg2 <= add1_co;
    mid_reg3 <= add1_y;
end

assign sft0_a = mid_reg1;
assign sft0_c = mid_reg0;
assign sft0_mod = sdct3;

assign sft1_a = mid_reg3;
assign sft1_c = mid_reg2;
assign sft1_mod = sdct3;

always @(sft0_mod or sft0_a or sft0_c) begin
    if(sft0_mod==1'b1)begin
        sft0_x[15] = sft0_c;
        sft0_x[14:0] = sft0_a[15:1];
        sft0_y = sft0_a[0];
    end
    else  begin
        sft0_x[15:0] = sft0_a[15:0];
        sft0_y = 1'b0;
    end
end

always @(sft1_mod or sft1_a or sft1_c or sft0_a) begin
    if(sft1_mod==1'b1)begin
        sft1_x[15] = sft1_c;
        sft1_x[14:0] = sft1_a[15:1];
        sft1_y = sft0_a[0];
    end
    else  begin
        sft1_x[15:0] = sft1_a[15:0];
        sft1_y = 1'b0;
    end
end

idct_princ idct_princ_0 (
    .y(inc0_y), 
    .a(sft0_x), 
    .c(sft0_y) 
);
 
idct_princ idct_princ_1 ( 
    .y(inc1_y), 
    .a(sft1_x), 
    .c(sft1_y) 
);


always @(posedge clkdec) begin
    out_reg0 <= inc0_y;
    out_reg1 <= inc1_y;
end

assign DPADD = out_reg0;
assign DPSUB = out_reg1;

endmodule

