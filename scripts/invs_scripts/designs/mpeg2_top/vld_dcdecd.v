// ----------------------------------------------
// File: vld_dcdecd.v
// Module: vld_dcdecd
// Function:generate block data  from VLD
// ----------------------------------------------

module vld_dcdecd(
    STREAM, 
    MPEG, 
    BLOCK_COUNT, 
    NEXT_VDO,
    NEXT_STATE, 
    NEXT_FERROR, 
    NEXT_VDOSGN, 
    v_enderror
);

output [10:0] NEXT_VDO;
output NEXT_FERROR, NEXT_VDOSGN;
output v_enderror;

input MPEG;
input [29:9] STREAM;
input [3:0] NEXT_STATE;
input [2:0] BLOCK_COUNT;

reg [10:0] NEXT_VDO, dc_dct_diff;
reg [10:0] half_range;
reg [3:0] dc_dct_size;
reg NEXT_FERROR, NEXT_VDOSGN;
reg v_enderror;

parameter  intra_DC=4'b0011,
           end_of_macroblock=4'b0101;
 

parameter
 error = 1'b1,
 no_error = 1'b0;

parameter
 MPEG_1 = 1'b1;

always @(NEXT_STATE or BLOCK_COUNT or STREAM or MPEG)
begin
 case (NEXT_STATE)

 intra_DC: begin
  if(BLOCK_COUNT!=3'd5 && BLOCK_COUNT!=3'd6) begin // luminance
   casex(STREAM[29:21]) 
        9'b100??????: begin
                dc_dct_size='d0;
                dc_dct_diff='d0;
                NEXT_FERROR=no_error;
                half_range = 11'h000; 
        end
        9'b00???????: begin
                dc_dct_size='d1;
                dc_dct_diff={10'h000,STREAM[27]};
                NEXT_FERROR=no_error;
                half_range = 11'h001; 
        end
        9'b01???????: begin
                dc_dct_size='d2;
                dc_dct_diff={9'h000,STREAM[27:26]};
                NEXT_FERROR=no_error;
                half_range = 11'h002; 
        end
        9'b101??????: begin
                dc_dct_size='d3;
                dc_dct_diff={8'h00,STREAM[26:24]};
                NEXT_FERROR=no_error;
                half_range = 11'h004; 
        end
        9'b110??????: begin
                dc_dct_size='d4;
                dc_dct_diff={7'h00,STREAM[26:23]};
                NEXT_FERROR=no_error;
                half_range = 11'h008; 
        end
        9'b1110?????: begin
                dc_dct_size='d5;
                dc_dct_diff={6'h00,STREAM[25:21]};
                NEXT_FERROR=no_error;
                half_range = 11'h010; 
        end
        9'b11110????: begin
                dc_dct_size='d6;
                dc_dct_diff={5'h00,STREAM[24:19]};
                NEXT_FERROR=no_error;
                half_range = 11'h020; 
        end
        9'b111110???: begin
                dc_dct_size='d7;
                dc_dct_diff={4'h0,STREAM[23:17]};
                NEXT_FERROR=no_error;
                half_range = 11'h040; 
        end
        9'b1111110??: begin
                dc_dct_size='d8;
                dc_dct_diff={3'h0,STREAM[22:15]};
                NEXT_FERROR=no_error;
                half_range = 11'h080; 
        end
        9'b11111110?: begin
                dc_dct_size='d9;
                dc_dct_diff={2'h0,STREAM[21:13]};
                if(MPEG==MPEG_1)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                half_range = 11'h100; 
        end
        9'b111111110: begin
                dc_dct_size='d10;
                dc_dct_diff={1'h0,STREAM[20:11]};
                if(MPEG==MPEG_1)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                half_range = 11'h200; 
        end
        9'b111111111: begin
                dc_dct_size='d11;
                dc_dct_diff=STREAM[20:10];
                if(MPEG==MPEG_1)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                half_range = 11'h400; 
        end
   endcase
  end
  else   // chrominance 
  begin
   casex(STREAM[29:20]) 
        10'b00????????: begin
                dc_dct_size='d0;
                dc_dct_diff=11'd0;
                NEXT_FERROR=no_error;
                half_range = 11'h000; 
        end
        10'b01????????: begin
                dc_dct_size='d1;
                dc_dct_diff={10'h000,STREAM[27]};
                NEXT_FERROR=no_error;
                half_range = 11'h001; 
        end
        10'b10????????: begin
                dc_dct_size='d2;
                dc_dct_diff={9'h000,STREAM[27:26]};
                NEXT_FERROR=no_error;
                half_range = 11'h002; 
        end
        10'b110???????: begin
                dc_dct_size='d3;
                dc_dct_diff={8'h00,STREAM[26:24]};
                NEXT_FERROR=no_error;
                half_range = 11'h004; 
        end
        10'b1110??????: begin
                dc_dct_size='d4;
                dc_dct_diff={7'h00,STREAM[25:22]};
                NEXT_FERROR=no_error;
                half_range = 11'h008; 
        end
        10'b11110?????: begin
                dc_dct_size='d5;
                dc_dct_diff={6'h00,STREAM[24:20]};
                NEXT_FERROR=no_error;
                half_range = 11'h010; 
        end
        10'b111110????: begin
                dc_dct_size='d6;
                dc_dct_diff={5'h00,STREAM[23:18]};
                NEXT_FERROR=no_error;
                half_range = 11'h020; 
        end
        10'b1111110???: begin
                dc_dct_size='d7;
                dc_dct_diff={4'h0,STREAM[22:16]};
                NEXT_FERROR=no_error;
                half_range = 11'h040; 
        end
        10'b11111110??: begin
                dc_dct_size='d8;
                dc_dct_diff={3'h0,STREAM[21:14]};
                NEXT_FERROR=no_error;
                half_range = 11'h080; 
        end
        10'b111111110?: begin
                dc_dct_size='d9;
                dc_dct_diff={2'h0,STREAM[20:12]};
                if(MPEG==MPEG_1)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                half_range = 11'h100; 
        end
        10'b1111111110: begin
                dc_dct_size='d10;
                dc_dct_diff={1'h0,STREAM[19:10]};
                if(MPEG==MPEG_1)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                half_range = 11'h200; 
        end
        10'b1111111111: begin
                dc_dct_size='d11;
                dc_dct_diff=STREAM[19:9];
                if(MPEG==MPEG_1)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                half_range = 11'h400; 
        end
   endcase
  end
end

 end_of_macroblock : begin
   dc_dct_size='d0;
   dc_dct_diff=11'd0;
   NEXT_FERROR = no_error;
   half_range = 11'h000;
end

 default: 
   begin
     dc_dct_size='d0;
     dc_dct_diff=11'd0;
     NEXT_FERROR = no_error;
     half_range = 11'h000; 
   end

 endcase
end

always @(NEXT_STATE or  STREAM)
  begin
    case(NEXT_STATE)
      end_of_macroblock :
        begin
          if(STREAM[29] == 1'b0)
            begin
              v_enderror = error;
            end
          else
            begin
              v_enderror = no_error;
            end
        end
 
      default :
        begin
          v_enderror = no_error;
        end
    endcase
  end
           
      
    
always @(dc_dct_diff or half_range or v_enderror)
  begin
    if(v_enderror == 1'b1)
      begin
        NEXT_VDOSGN = 1'b0;
        NEXT_VDO = 11'd0;
      end 
    else if(dc_dct_diff >= half_range) 
      begin
        NEXT_VDOSGN = 1'b0;
        NEXT_VDO = dc_dct_diff;
      end 
    else
      begin
        NEXT_VDOSGN = 1'b1;
        NEXT_VDO = (half_range<<1)-(dc_dct_diff+1);
      end
  end

endmodule
