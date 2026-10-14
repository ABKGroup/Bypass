// ----------------------------------------------
// File: vld_escsft.v
// Module: vld_escsft
// Function:generate block shift
// ----------------------------------------------

module vld_escsft(
    STREAM, 
    SHIFT, 
    MPEG, 
    NEXT_STATE, 
    RUN,
    COUNT_COEFF
);

output [5:0] SHIFT;

input MPEG;
input [29:10] STREAM;
input [6:0] COUNT_COEFF;
input [5:0] RUN;
input [3:0] NEXT_STATE;

reg [5:0] SHIFT, B14_SHIFT, B15_SHIFT;

parameter   B14=4'b0001,
            B15=4'b0010;

parameter   MPEG_2 = 1'b0;

always @(NEXT_STATE or B14_SHIFT or B15_SHIFT)
 case (NEXT_STATE) 
        B14: SHIFT = B14_SHIFT;
        B15: SHIFT = B15_SHIFT;
        default: SHIFT = 6'd0;
 endcase


always @(STREAM or MPEG or RUN or COUNT_COEFF) begin
        if (STREAM[29:24]==6'b000001&&RUN==6'd0) begin 
          if(MPEG==MPEG_2) begin
                if(STREAM[23:18]==6'h00) begin
                        if(COUNT_COEFF==7'd64)
                                B14_SHIFT = 6'd26;
                        else
                                B14_SHIFT = 6'd24; 
                end
                else begin 
                        if(COUNT_COEFF+STREAM[23:18]==7'd64)
                                B14_SHIFT = 6'd26;
                        else
                                B14_SHIFT = 6'd24;
                end
          end
          else begin 
                if(STREAM[23:18]==6'h00) begin
                        if(COUNT_COEFF==7'd64)
                          if(STREAM[16:10]==4'h0) B14_SHIFT = 6'd30;
                          else                          B14_SHIFT = 6'd22;
                        else
                          if(STREAM[16:10]==4'h0) B14_SHIFT = 6'd28;
                          else                          B14_SHIFT = 6'd20;
                end
                else begin 
                        if(COUNT_COEFF+STREAM[23:18]==7'd64)
                          if(STREAM[16:10]==4'h0) B14_SHIFT = 6'd30;
                          else                          B14_SHIFT = 6'd22;
                        else
                          if(STREAM[16:10]==4'h0) B14_SHIFT = 6'd28;
                          else                          B14_SHIFT = 6'd20;
                end
          end
        end
        else B14_SHIFT = 6'd0;
 end

always @(STREAM or RUN or COUNT_COEFF) begin
    if(STREAM[29:24]==6'b000001 && RUN==6'd0) begin
                if(STREAM[23:18]==6'h00) begin
                        if(COUNT_COEFF==7'd64)
                                B15_SHIFT = 6'd28; 
                        else
                                B15_SHIFT = 6'd24;
                end
                else begin 
                                if(COUNT_COEFF+STREAM[23:18]==7'd64)
                                B15_SHIFT = 6'd28;
                        else
                                B15_SHIFT = 6'd24;
                end
        end
        else B15_SHIFT = 6'd0;
 end

endmodule

