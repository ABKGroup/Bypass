// ----------------------------------------------
// File: vld_dcshft.v
// Module: vld_dcshft
// Function:generate block shift
// ----------------------------------------------

module vld_dcshft(
    STREAM, 
    SHIFT, 
    MPEG, 
    BLOCK_COUNT,
    NEXT_STATE
);

output [5:0] SHIFT;

input MPEG;
input [29:20] STREAM;
input [3:0] NEXT_STATE;
input [2:0] BLOCK_COUNT;

reg [5:0] SHIFT, lum_SHIFT, chr_SHIFT;

parameter   intra_DC=4'b0011,
            null_op=4'b0100;

parameter   MPEG_2 = 1'b0;

always @(NEXT_STATE or BLOCK_COUNT or lum_SHIFT or chr_SHIFT) begin
  case (NEXT_STATE) 
     intra_DC: begin
                 if(BLOCK_COUNT!=3'd5 && BLOCK_COUNT!=3'd6) 
                   SHIFT = lum_SHIFT;
                 else               
                   SHIFT = chr_SHIFT;
                 end
     null_op: SHIFT = 6'd0;
     default: SHIFT = 6'd0;
  endcase
end

always @(STREAM or MPEG) begin
   casex(STREAM[29:21]) 
        9'b100??????: lum_SHIFT = 6'd3;
        9'b00???????: lum_SHIFT = 6'd3;
        9'b01???????: lum_SHIFT = 6'd4;
        9'b101??????: lum_SHIFT = 6'd6;
        9'b110??????: lum_SHIFT = 6'd7;
        9'b1110?????: lum_SHIFT = 6'd9;
        9'b11110????: lum_SHIFT = 6'd11;
        9'b111110???: lum_SHIFT = 6'd13;
        9'b1111110??: lum_SHIFT = 6'd15;
        9'b11111110?: if(MPEG==MPEG_2) lum_SHIFT=6'd17; else lum_SHIFT=6'd0;
        9'b111111110: if(MPEG==MPEG_2) lum_SHIFT=6'd19; else lum_SHIFT=6'd0;
        9'b111111111: if(MPEG==MPEG_2) lum_SHIFT=6'd20; else lum_SHIFT=6'd0;
   endcase
end 

always @(STREAM or MPEG)begin
   casex(STREAM[29:20]) 
        10'b00????????: chr_SHIFT = 6'd2;
        10'b01????????: chr_SHIFT = 6'd3;
        10'b10????????: chr_SHIFT = 6'd4;
        10'b110???????: chr_SHIFT = 6'd6;
        10'b1110??????: chr_SHIFT = 6'd8;
        10'b11110?????: chr_SHIFT = 6'd10;
        10'b111110????: chr_SHIFT = 6'd12;
        10'b1111110???: chr_SHIFT = 6'd14;
        10'b11111110??: chr_SHIFT = 6'd16;
        10'b111111110?: if(MPEG==MPEG_2) chr_SHIFT=6'd18; else chr_SHIFT=6'd0;
        10'b1111111110: if(MPEG==MPEG_2) chr_SHIFT=6'd20; else chr_SHIFT=6'd0;
        10'b1111111111: if(MPEG==MPEG_2) chr_SHIFT=6'd21; else chr_SHIFT=6'd0;
   endcase
end 

endmodule

