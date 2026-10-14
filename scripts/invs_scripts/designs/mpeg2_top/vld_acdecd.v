// ----------------------------------------------
// File: vld_acdecd.v
// Module: vld_acdecd
// Function:generate block data  from VLD
// ----------------------------------------------

module vld_acdecd(
    STREAM, 
    STARTVLD, 
    NEXT_STATE, 
    COUNT_COEFF,
    NEXT_VDOSGN, 
    NEXT_VDO, 
    NEXT_RUN, 
    NEXT_FERROR, 
    NEXT_HOLD_SIGN,
    NEXT_HOLD_VDO, 
    RUN
);

output [10:0] NEXT_VDO, NEXT_HOLD_VDO;
output [5:0] NEXT_RUN;
output NEXT_VDOSGN, NEXT_FERROR, NEXT_HOLD_SIGN;

input STARTVLD;
input [29:9] STREAM;
input [6:0] COUNT_COEFF;
input [5:0] RUN;
input [3:0] NEXT_STATE;

reg [10:0] NEXT_VDO, NEXT_HOLD_VDO;
reg [5:0] NEXT_RUN;
reg NEXT_VDOSGN, NEXT_FERROR, NEXT_HOLD_SIGN;

wire [10:0] B14_VDO, B14_hold_vdo, B15_VDO, B15_hold_vdo;
wire [5:0] B14_RUN, B15_RUN;
wire B14_VDOSGN, B14_ferror, B14_hold_sign, B15_VDOSGN, B15_ferror,
      B15_hold_sign;

parameter  B14=4'b0001,
           B15=4'b0010;

parameter  no_error = 1'b0;

vld_b14tbl vld_b14tbl (
    .STREAM(STREAM[29:11]), 
    .NEXT_VDOSGN(B14_VDOSGN),
    .NEXT_VDO(B14_VDO), 
    .NEXT_RUN(B14_RUN), 
    .NEXT_FERROR(B14_ferror),
    .NEXT_HOLD_SIGN(B14_hold_sign), 
    .NEXT_HOLD_VDO(B14_hold_vdo),
    .STARTVLD(STARTVLD), 
    .COUNT_COEFF(COUNT_COEFF)
);

vld_b15tbl vld_b15tbl (
    .STREAM(STREAM[29:9]), 
    .NEXT_VDOSGN(B15_VDOSGN),
    .NEXT_VDO(B15_VDO), 
    .NEXT_RUN(B15_RUN), 
    .NEXT_FERROR(B15_ferror),
    .NEXT_HOLD_SIGN(B15_hold_sign), 
    .NEXT_HOLD_VDO(B15_hold_vdo),
    .STARTVLD(STARTVLD), 
    .COUNT_COEFF(COUNT_COEFF)
);

always @(NEXT_STATE  
          or B14_VDOSGN or B14_VDO or B14_RUN
          or B14_ferror or B14_hold_sign or B14_hold_vdo
          or B15_VDOSGN or B15_VDO or B15_RUN  or B15_ferror
          or B15_hold_sign or B15_hold_vdo or RUN)
 begin
   case (NEXT_STATE) 

     B14: begin
            if(RUN==6'd0) begin
                NEXT_VDOSGN=B14_VDOSGN;
                NEXT_VDO=B14_VDO;
                NEXT_RUN=B14_RUN;
                NEXT_FERROR=B14_ferror;
                NEXT_HOLD_SIGN=B14_hold_sign;
                NEXT_HOLD_VDO=B14_hold_vdo;
            end
            else begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd0;
                NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b0;
                NEXT_HOLD_VDO=11'd0;
            end
          end

    B15: begin
           if(RUN==6'd0) begin
                NEXT_VDOSGN=B15_VDOSGN;
                NEXT_VDO=B15_VDO;
                NEXT_RUN=B15_RUN;
                NEXT_FERROR=B15_ferror;
                NEXT_HOLD_SIGN=B15_hold_sign;
                NEXT_HOLD_VDO=B15_hold_vdo;
           end
           else begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd0;
                NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b0;
                NEXT_HOLD_VDO=11'd0;
           end
         end
    default: begin
        NEXT_VDOSGN=1'b0;
        NEXT_VDO=11'd0;
        NEXT_RUN=6'd0;
        NEXT_FERROR=no_error;
        NEXT_HOLD_SIGN=1'b0;
        NEXT_HOLD_VDO=11'd0;
     end
   endcase
end 

endmodule


