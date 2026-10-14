// ----------------------------------------------
// File: idct_pobtf.v
// Module: idct_pobtf
// Function:
// ----------------------------------------------

module idct_pobtf(
    ZOUT, 
    XIN, 
    YIN, 
    CPSADD, 
    clkdec
);

output [31:0]  ZOUT; 
input  [32:0]  XIN;  
input  [32:0]  YIN;  
input          CPSADD;       
input          clkdec;          

reg [16:0]  as_oh;
reg [15:0]  as_ol;
reg         as_oc;
wire [15:0]  addl_a, addl_b, addl_y;
wire         addl_ci, addl_co;
wire [16:0]  addh_a, addh_b;
wire         addh_ci;
wire [17:0]  addh_y;

reg [16:0]  mid_reg0, mid_reg1;
reg         mid_reg2;
reg [15:0]  mid_reg3;
reg [15:0]  out_reg0;
reg [15:0]  out_reg1;

always @(CPSADD or YIN) begin
    if(CPSADD==1'b1) begin
      as_oh[16:0] = YIN[32:16];
      as_ol[15:0] = YIN[15:0];
      as_oc = 1'b0;
    end
    else begin
      as_oh[16:0] = ~YIN[32:16];
      as_ol[15:0] = ~YIN[15:0];
      as_oc = 1'b1;
    end
end

 
assign addl_a = XIN[15:0];
assign addl_b = as_ol;
assign addl_ci = as_oc;
 
assign {addl_co, addl_y} = addl_a + addl_b + addl_ci;

always @(posedge clkdec) begin
   mid_reg0 <= XIN[32:16];
   mid_reg1 <= as_oh;
   mid_reg2 <= addl_co;
   mid_reg3 <= addl_y;
end
 
assign addh_a = mid_reg0;
assign addh_b = mid_reg1;
assign addh_ci = mid_reg2;
 
assign addh_y = addh_a + addh_b + ( addh_ci & mid_reg0[16] & mid_reg1[16]);
 
always @(posedge clkdec) begin
   out_reg0 <= addh_y ;
   out_reg1 <= mid_reg3 ;
end

assign ZOUT[31:16] = out_reg0;
assign ZOUT[15:0] = out_reg1;

endmodule

