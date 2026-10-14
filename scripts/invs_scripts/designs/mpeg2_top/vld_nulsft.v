// ----------------------------------------------
// File: vld_nulsft.v
// Module: vld_nulsft
// Function:generate null shift data
// ----------------------------------------------

module vld_nulsft(
    SHIFT, 
    NEXT_STATE, 
    STATE
);

output [5:0] SHIFT;
input [3:0] NEXT_STATE, STATE;

reg [5:0] SHIFT;

parameter   IDLE=4'b0000,
            B14=4'b0001,
            INTRA_DC=4'b0011,
            null_op=4'b0100;

always @(NEXT_STATE or STATE) begin
  if(NEXT_STATE==null_op && STATE!=null_op && STATE!=IDLE)
        if(STATE==B14)
                SHIFT = 6'd2;  
        else if(STATE==INTRA_DC)
                SHIFT = 6'd0;
        else
                SHIFT = 6'd4; 
  else
        SHIFT = 6'd0;
end

endmodule

