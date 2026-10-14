// ----------------------------------------------
// File: idct_pornt.v
// Module: idct_pornt
// Function:
// ----------------------------------------------

module idct_pornt(
    DAZ, 
    clkdec,
    DCTOUT
);

parameter w_size = 5'd16;         

input     [31:0]  DAZ;         
input             clkdec;                 
output    [w_size-1:0] DCTOUT; 

wire              rnd_ci;
wire [w_size-1:0] rnd_a, rnd_y;
wire              str_s0, str_s1, str_s2,coo;

reg [w_size-1:0] str_o;
reg              rsl;
reg              s0, s1, s2;
reg              mid_reg0;
reg [w_size-1:0] mid_reg1;
reg              mid_reg2, mid_reg3, mid_reg4;
reg [w_size-1:0] out_reg;

always @(DAZ) begin
   if ({DAZ[30:15]} == 16'h7fff)
     rsl = 1'b0;
   else if (DAZ[30]==1'b1 & DAZ[14]==1'b1 & DAZ[13:0]==14'b0)
     rsl = 1'b0;
   else
     rsl = DAZ[14];
end


always @(DAZ) begin
    case (DAZ[31:30])
        2'b01:  begin
                s0 = 1'b1;
                s1 = 1'b0;
                s2 = 1'b0;
              end
        2'b10:  begin
                s0 = 1'b0;
                s1 = 1'b1;
                s2 = 1'b0;
              end
        default: begin
                s0 = 1'b0;
                s1 = 1'b0;
                s2 = 1'b1;
              end
   endcase
end

always @(posedge clkdec) begin
    mid_reg0 <= rsl;
    mid_reg1 <= DAZ[30:15];
    mid_reg2 <= s0;
    mid_reg3 <= s1;
    mid_reg4 <= s2;
end

assign rnd_ci = mid_reg0;
assign rnd_a = mid_reg1;

assign {coo,rnd_y} = rnd_a +  rnd_ci;

assign str_s0 = mid_reg2;
assign str_s1 = mid_reg3;
assign str_s2 = mid_reg4;

always @(str_s0 or str_s1 or str_s2 or rnd_y) begin
   if(str_s0 == 1'b1)
       str_o = 16'h7fff;
   else if(str_s1 == 1'b1)
       str_o = 16'h8000;
   else if(str_s2 == 1'b1)
       str_o = rnd_y;
   else 
       str_o = 16'h0000;
end



always @(posedge clkdec) begin
    out_reg <= str_o;
end

assign DCTOUT = out_reg;

endmodule
