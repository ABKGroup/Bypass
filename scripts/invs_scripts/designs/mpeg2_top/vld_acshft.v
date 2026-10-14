// ----------------------------------------------
// File: vld_acshft.v
// Module: vld_acshft
// Function:generate block shift data  from VLD
// ----------------------------------------------

module vld_acshft(
    STREAM, 
    SHIFT, 
    RUN, 
    STARTVLD, 
    NEXT_STATE,
    COUNT_COEFF
);

output [5:0] SHIFT;

input STARTVLD;
input [29:14] STREAM;
input [5:0] RUN;
input [6:0] COUNT_COEFF;
input [3:0] NEXT_STATE;

reg [5:0] SHIFT, B14_SHIFT, B15_SHIFT;

parameter B14=4'b0001,
          B15=4'b0010,
          null_op=4'b0100,
          end_of_macroblock=4'b0101;

always @(NEXT_STATE or RUN or B14_SHIFT or B15_SHIFT) begin
 if(RUN!='d0)
        SHIFT = 6'd0;
 else
        case (NEXT_STATE) 
         B14:                 SHIFT = B14_SHIFT;
         B15:                 SHIFT = B15_SHIFT;
         null_op:             SHIFT = 6'd0;
         end_of_macroblock :  SHIFT = 6'd1;
         default:             SHIFT = 6'd0;
 endcase
end

always @(STREAM or STARTVLD or COUNT_COEFF)
    casex(STREAM[29:14]) 
        16'b1???????????????: begin
                if(!STARTVLD) begin
                        B14_SHIFT = 6'd2; // DC coeff.
                end
                else if(STREAM[28]==1'b1) begin  // run = 0
                        if(COUNT_COEFF==7'd64)
                                B14_SHIFT = 6'd5;
                        else
                                B14_SHIFT = 6'd3;
                end
                else begin
                        B14_SHIFT = 6'd0;
                end
        end
        16'b011?????????????: // run = 1 
                if(COUNT_COEFF==7'd63)
                        B14_SHIFT = 6'd6;
                else
                        B14_SHIFT = 6'd4;
        16'b0100????????????:  // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd7;
                else
                        B14_SHIFT = 6'd5;
        16'b0101????????????:  // run = 2
                if(COUNT_COEFF==7'd62)
                        B14_SHIFT = 6'd7;
                else
                        B14_SHIFT = 6'd5;
        16'b00101???????????:  // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd8;
                else
                        B14_SHIFT = 6'd6;
        16'b00111???????????: // run = 3
                if(COUNT_COEFF==7'd61)
                        B14_SHIFT = 6'd8;
                else
                        B14_SHIFT = 6'd6;
        16'b00110???????????: // run = 4
                if(COUNT_COEFF==7'd60)
                        B14_SHIFT = 6'd8;
                else
                        B14_SHIFT = 6'd6;
        16'b000110??????????:  // run = 1
                if(COUNT_COEFF==7'd63)
                        B14_SHIFT = 6'd9;
                else
                        B14_SHIFT = 6'd7;
        16'b000111??????????: // run = 5
                if(COUNT_COEFF==7'd59)
                        B14_SHIFT = 6'd9;
                else
                        B14_SHIFT = 6'd7;
        16'b000101??????????: // run = 6
                if(COUNT_COEFF==7'd58)
                        B14_SHIFT = 6'd9;
                else
                        B14_SHIFT = 6'd7;
        16'b000100??????????: // run = 7
                if(COUNT_COEFF==7'd57)
                        B14_SHIFT = 6'd9;
                else
                        B14_SHIFT = 6'd7;
        16'b0000110?????????: // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd10;
                else
                        B14_SHIFT = 6'd8;
        16'b0000100?????????: // run = 2
                if(COUNT_COEFF==7'd62)
                        B14_SHIFT = 6'd10;
                else
                        B14_SHIFT = 6'd8;
        16'b0000111?????????: // run = 8
                if(COUNT_COEFF==7'd56)
                        B14_SHIFT = 6'd10;
                else
                        B14_SHIFT = 6'd8;
        16'b0000101?????????: // run = 9
                if(COUNT_COEFF==7'd55)
                        B14_SHIFT = 6'd10;
                else
                        B14_SHIFT = 6'd8;
        16'b00100110????????: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd11;
                else
                        B14_SHIFT = 6'd9;
        end
        16'b00100001????????: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd11;
                else
                        B14_SHIFT = 6'd9;
        end
        16'b00100101????????: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B14_SHIFT = 6'd11;
                else
                        B14_SHIFT = 6'd9;
        end
        16'b00100100????????: begin // run = 3
                if(COUNT_COEFF==7'd61)
                        B14_SHIFT = 6'd11;
                else
                        B14_SHIFT = 6'd9;
        end
        16'b00100111????????: begin // run = 10
                if(COUNT_COEFF==7'd54)
                        B14_SHIFT = 6'd11;
                else
                        B14_SHIFT = 6'd9;
        end
        16'b00100011????????: begin // run == 11
                if(COUNT_COEFF==7'd53)
                        B14_SHIFT = 6'd11;
                else
                        B14_SHIFT = 6'd9;
        end
        16'b00100010????????: begin // run = 12
                if(COUNT_COEFF==7'd52)
                        B14_SHIFT = 6'd11;
                else
                        B14_SHIFT = 6'd9;
        end
        16'b00100000????????: begin // run = 13
                if(COUNT_COEFF==7'd51)
                        B14_SHIFT = 6'd11;
                else
                        B14_SHIFT = 6'd9;
        end
        16'b0000001010??????: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd13;
                else
                        B14_SHIFT = 6'd11;
        end
        16'b0000001100??????: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B14_SHIFT = 6'd13;
                else
                        B14_SHIFT = 6'd11;
        end
        16'b0000001011??????: begin // run = 2
                if(COUNT_COEFF==7'd62)
                        B14_SHIFT = 6'd13;
                else
                        B14_SHIFT = 6'd11;
        end
        16'b0000001111??????: begin // run = 4
                if(COUNT_COEFF==7'd60)
                        B14_SHIFT = 6'd13;
                else
                        B14_SHIFT = 6'd11;
        end
        16'b0000001001??????: begin // run = 5
                if(COUNT_COEFF==7'd59)
                        B14_SHIFT = 6'd13;
                else
                        B14_SHIFT = 6'd11;
        end
        16'b0000001110??????: begin // run = 14
                if(COUNT_COEFF==7'd50)
                        B14_SHIFT = 6'd13;
                else
                        B14_SHIFT = 6'd11;
        end
        16'b0000001101??????: begin // run = 15
                if(COUNT_COEFF==7'd49)
                        B14_SHIFT = 6'd13;
                else
                        B14_SHIFT = 6'd11;
        end
        16'b0000001000??????: begin // run = 16
                if(COUNT_COEFF==7'd48)
                        B14_SHIFT = 6'd13;
                else
                        B14_SHIFT = 6'd11;
        end
        16'b000000011101????: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd15;
                else
                        B14_SHIFT = 6'd13;
        end
        16'b000000011000????: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd15;
                else
                        B14_SHIFT = 6'd13;
        end
        16'b000000010011????: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd15;
                else
                        B14_SHIFT = 6'd13;
        end
        16'b000000010000????: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd15;
                else
                        B14_SHIFT = 6'd13;
        end
        16'b000000011011????: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B14_SHIFT = 6'd15;
                else
                        B14_SHIFT = 6'd13;
        end
        16'b000000010100????: begin // run = 2
                if(COUNT_COEFF==7'd62)
                        B14_SHIFT = 6'd15;
                else
                        B14_SHIFT = 6'd13;
        end
        16'b000000011100????: begin // run = 3
                if(COUNT_COEFF==7'd61)
                        B14_SHIFT = 6'd15;
                else
                        B14_SHIFT = 6'd13;
        end
        16'b000000010010????: begin // run = 4
                if(COUNT_COEFF==7'd60)
                        B14_SHIFT = 6'd15;
                else
                        B14_SHIFT = 6'd13;
        end
        16'b000000011110????: begin // run = 6
                if(COUNT_COEFF==7'd58)
                        B14_SHIFT = 6'd15;
                else
                        B14_SHIFT = 6'd13;
        end
        16'b000000010101????: begin // run = 7
                if(COUNT_COEFF==7'd57)
                        B14_SHIFT = 6'd15;
                else
                        B14_SHIFT = 6'd13;
        end
        16'b000000010001????: begin // run =8
                if(COUNT_COEFF==7'd56)
                        B14_SHIFT = 6'd15;
                else
                        B14_SHIFT = 6'd13;
        end
        16'b000000011111????: begin // run = 17
                if(COUNT_COEFF==7'd47)
                        B14_SHIFT = 6'd15;
                else
                        B14_SHIFT = 6'd13;
        end
        16'b000000011010????: begin // run = 18
                if(COUNT_COEFF==7'd46)
                        B14_SHIFT = 6'd15;
                else
                        B14_SHIFT = 6'd13;
        end
        16'b000000011001????: begin // run = 19
                if(COUNT_COEFF==7'd45)
                        B14_SHIFT = 6'd15;
                else
                        B14_SHIFT = 6'd13;
        end
        16'b000000010111????: begin // run = 20
                if(COUNT_COEFF==7'd44)
                        B14_SHIFT = 6'd15;
                else
                        B14_SHIFT = 6'd13;
        end
        16'b000000010110????: begin // run = 21
                if(COUNT_COEFF==7'd43)
                        B14_SHIFT = 6'd15;
                else
                        B14_SHIFT = 6'd13;
        end
        16'b0000000011010???: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd16;
                else
                        B14_SHIFT = 6'd14;
        end
        16'b0000000011001???: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd16;
                else
                        B14_SHIFT = 6'd14;
        end
        16'b0000000011000???: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd16;
                else
                        B14_SHIFT = 6'd14;
        end
        16'b0000000010111???: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd16;
                else
                        B14_SHIFT = 6'd14;
        end
        16'b0000000010110???: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B14_SHIFT = 6'd16;
                else
                        B14_SHIFT = 6'd14;
        end
        16'b0000000010101???: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B14_SHIFT = 6'd16;
                else
                        B14_SHIFT = 6'd14;
        end
        16'b0000000010100???: begin // run = 2
                if(COUNT_COEFF==7'd62)
                        B14_SHIFT = 6'd16;
                else
                        B14_SHIFT = 6'd14;
        end
        16'b0000000010011???: begin // run = 3
                if(COUNT_COEFF==7'd61)
                        B14_SHIFT = 6'd16;
                else
                        B14_SHIFT = 6'd14;
        end
        16'b0000000010010???: begin // run = 5
                if(COUNT_COEFF==7'd59)
                        B14_SHIFT = 6'd16;
                else
                        B14_SHIFT = 6'd14;
        end
        16'b0000000010001???: begin // run = 9 
                if(COUNT_COEFF==7'd55)
                        B14_SHIFT = 6'd16;
                else
                        B14_SHIFT = 6'd14;
        end
        16'b0000000010000???: begin // run = 10
                if(COUNT_COEFF==7'd54)
                        B14_SHIFT = 6'd16;
                else
                        B14_SHIFT = 6'd14;
        end
        16'b0000000011111???: begin // run = 22
                if(COUNT_COEFF==7'd42)
                        B14_SHIFT = 6'd16;
                else
                        B14_SHIFT = 6'd14;
        end
        16'b0000000011110???: begin // run = 23
                if(COUNT_COEFF==7'd41)
                        B14_SHIFT = 6'd16;
                else
                        B14_SHIFT = 6'd14;
        end
        16'b0000000011101???: begin // run = 24
                if(COUNT_COEFF==7'd40)
                        B14_SHIFT = 6'd16;
                else
                        B14_SHIFT = 6'd14;
        end
        16'b0000000011100???: begin // run = 25
                if(COUNT_COEFF==7'd39)
                        B14_SHIFT = 6'd16;
                else
                        B14_SHIFT = 6'd14;
        end
        16'b0000000011011???: begin // run = 26
                if(COUNT_COEFF==7'd38)
                        B14_SHIFT = 6'd16;
                else
                        B14_SHIFT = 6'd14;
        end
        16'b00000000011111??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd17;
                else
                        B14_SHIFT = 6'd15;
        end
        16'b00000000011110??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd17;
                else
                        B14_SHIFT = 6'd15;
        end
        16'b00000000011101??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd17;
                else
                        B14_SHIFT = 6'd15;
        end
        16'b00000000011100??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd17;
                else
                        B14_SHIFT = 6'd15;
        end
        16'b00000000011011??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd17;
                else
                        B14_SHIFT = 6'd15;
        end
        16'b00000000011010??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd17;
                else
                        B14_SHIFT = 6'd15;
        end
        16'b00000000011001??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd17;
                else
                        B14_SHIFT = 6'd15;
        end
        16'b00000000011000??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd17;
                else
                        B14_SHIFT = 6'd15;
        end
        16'b00000000010111??: begin // run = 0 
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd17;
                else
                        B14_SHIFT = 6'd15;
        end
        16'b00000000010110??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd17;
                else
                        B14_SHIFT = 6'd15;
        end
        16'b00000000010101??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd17;
                else
                        B14_SHIFT = 6'd15;
        end
        16'b00000000010100??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd17;
                else
                        B14_SHIFT = 6'd15;
        end
        16'b00000000010011??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd17;
                else
                        B14_SHIFT = 6'd15;
        end
        16'b00000000010010??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd17;
                else
                        B14_SHIFT = 6'd15;
        end
        16'b00000000010001??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd17;
                else
                        B14_SHIFT = 6'd15;
        end
        16'b00000000010000??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd17;
                else
                        B14_SHIFT = 6'd15;
        end
        16'b000000000011000?: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd18;
                else
                        B14_SHIFT = 6'd16;
        end
        16'b000000000010111?: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd18;
                else
                        B14_SHIFT = 6'd16;
        end
        16'b000000000010110?: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd18;
                else
                        B14_SHIFT = 6'd16;
        end
        16'b000000000010101?: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd18;
                else
                        B14_SHIFT = 6'd16;
        end
        16'b000000000010100?: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd18;
                else
                        B14_SHIFT = 6'd16;
        end
        16'b000000000010011?: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd18;
                else
                        B14_SHIFT = 6'd16;
        end
        16'b000000000010010?: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd18;
                else
                        B14_SHIFT = 6'd16;
        end
        16'b000000000010001?: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd18;
                else
                        B14_SHIFT = 6'd16;
        end
        16'b000000000010000?: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B14_SHIFT = 6'd18;
                else
                        B14_SHIFT = 6'd16;
        end
        16'b000000000011111?: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B14_SHIFT = 6'd18;
                else
                        B14_SHIFT = 6'd16;
        end
        16'b000000000011110?: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B14_SHIFT = 6'd18;
                else
                        B14_SHIFT = 6'd16;
        end
        16'b000000000011101?: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B14_SHIFT = 6'd18;
                else
                        B14_SHIFT = 6'd16;
        end
        16'b000000000011100?: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B14_SHIFT = 6'd18;
                else
                        B14_SHIFT = 6'd16;
        end
        16'b000000000011011?: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B14_SHIFT = 6'd18;
                else
                        B14_SHIFT = 6'd16;
        end
        16'b000000000011010?: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B14_SHIFT = 6'd18;
                else
                        B14_SHIFT = 6'd16;
        end
        16'b000000000011001?: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B14_SHIFT = 6'd18;
                else
                        B14_SHIFT = 6'd16;
        end
        16'b0000000000010011: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B14_SHIFT = 6'd19;
                else
                        B14_SHIFT = 6'd17;
        end
        16'b0000000000010010: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B14_SHIFT = 6'd19;
                else
                        B14_SHIFT = 6'd17;
        end
        16'b0000000000010001: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B14_SHIFT = 6'd19;
                else
                        B14_SHIFT = 6'd17;
        end
        16'b0000000000010000: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B14_SHIFT = 6'd19;
                else
                        B14_SHIFT = 6'd17;
        end
        16'b0000000000010100: begin // run = 6
                if(COUNT_COEFF==7'd58)
                        B14_SHIFT = 6'd19;
                else
                        B14_SHIFT = 6'd17;
        end
        16'b0000000000011010: begin // run = 11
                if(COUNT_COEFF==7'd53)
                        B14_SHIFT = 6'd19;
                else
                        B14_SHIFT = 6'd17;
        end
        16'b0000000000011001: begin // run = 12
                if(COUNT_COEFF==7'd52)
                        B14_SHIFT = 6'd19;
                else
                        B14_SHIFT = 6'd17;
        end
        16'b0000000000011000: begin // run = 13
                if(COUNT_COEFF==7'd51)
                        B14_SHIFT = 6'd19;
                else
                        B14_SHIFT = 6'd17;
        end
        16'b0000000000010111: begin // run = 14
                if(COUNT_COEFF==7'd50)
                        B14_SHIFT = 6'd19;
                else
                        B14_SHIFT = 6'd17;
        end
        16'b0000000000010110: begin // run = 15
                if(COUNT_COEFF==7'd49)
                        B14_SHIFT = 6'd19;
                else
                        B14_SHIFT = 6'd17;
        end
        16'b0000000000010101: begin // run = 16
                if(COUNT_COEFF==7'd48)
                        B14_SHIFT = 6'd19;
                else
                        B14_SHIFT = 6'd17;
        end
        16'b0000000000011111: begin // run = 27
                if(COUNT_COEFF==7'd37)
                        B14_SHIFT = 6'd19;
                else
                        B14_SHIFT = 6'd17;
        end
        16'b0000000000011110: begin // run = 28
                if(COUNT_COEFF==7'd36)
                        B14_SHIFT = 6'd19;
                else
                        B14_SHIFT = 6'd17;
        end
        16'b0000000000011101: begin // run = 29
                if(COUNT_COEFF==7'd35)
                        B14_SHIFT = 6'd19;
                else
                        B14_SHIFT = 6'd17;
        end
        16'b0000000000011100: begin // run = 30
                if(COUNT_COEFF==7'd34)
                        B14_SHIFT = 6'd19;
                else
                        B14_SHIFT = 6'd17;
        end
        16'b0000000000011011: begin // run = 31
                if(COUNT_COEFF==7'd33)
                        B14_SHIFT = 6'd19;
                else
                        B14_SHIFT = 6'd17;
        end
        default: begin
                B14_SHIFT = 6'd0;
        end
    endcase

always @(STREAM or COUNT_COEFF)
        casex(STREAM[29:14]) 
        16'b10??????????????: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd7;
                else
                        B15_SHIFT = 6'd3;
        end
        16'b010?????????????: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B15_SHIFT = 6'd8;
                else
                        B15_SHIFT = 6'd4;
        end
        16'b110?????????????: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd8;
                else
                        B15_SHIFT = 6'd4;
        end
        16'b00101???????????: begin // run = 2
                if(COUNT_COEFF==7'd62)
                        B15_SHIFT = 6'd10;
                else
                        B15_SHIFT = 6'd6;
        end
        16'b0111????????????: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd9;
                else
                        B15_SHIFT = 6'd5;
        end
        16'b00111???????????: begin // run = 3
                if(COUNT_COEFF==7'd61)
                        B15_SHIFT = 6'd10;
                else
                        B15_SHIFT = 6'd6;
        end
        16'b000110??????????: begin // run = 4
                if(COUNT_COEFF==7'd60)
                        B15_SHIFT = 6'd11;
                else
                        B15_SHIFT = 6'd7;
        end
        16'b00110???????????: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B15_SHIFT = 6'd10;
                else
                        B15_SHIFT = 6'd6;
        end
        16'b000111??????????: begin // run = 5
                if(COUNT_COEFF==7'd59)
                        B15_SHIFT = 6'd11;
                else
                        B15_SHIFT = 6'd7;
        end
        16'b0000110?????????: begin // run = 6
                if(COUNT_COEFF==7'd58)
                        B15_SHIFT = 6'd12;
                else
                        B15_SHIFT = 6'd8;
        end
        16'b0000100?????????: begin // run = 7
                if(COUNT_COEFF==7'd57)
                        B15_SHIFT = 6'd12;
                else
                        B15_SHIFT = 6'd8;
        end
        16'b11100???????????: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd10;
                else
                        B15_SHIFT = 6'd6;
        end
        16'b0000111?????????: begin // run = 2
                if(COUNT_COEFF==7'd62)
                        B15_SHIFT = 6'd12;
                else
                        B15_SHIFT = 6'd8;
        end
        16'b0000101?????????: begin // run = 8
                if(COUNT_COEFF==7'd56)
                        B15_SHIFT = 6'd12;
                else
                        B15_SHIFT = 6'd8;
        end
        16'b1111000?????????: begin // run = 9
                if(COUNT_COEFF==7'd55)
                        B15_SHIFT = 6'd12;
                else
                        B15_SHIFT = 6'd8;
        end
        16'b11101???????????: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd10;
                else
                        B15_SHIFT = 6'd6;
        end
        16'b000101??????????: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd11;
                else
                        B15_SHIFT = 6'd7;
        end
        16'b1111001?????????: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B15_SHIFT = 6'd12;
                else
                        B15_SHIFT = 6'd8;
        end
        16'b00100110????????: begin // run = 3 
                if(COUNT_COEFF==7'd61)
                        B15_SHIFT = 6'd13;
                else
                        B15_SHIFT = 6'd9;
        end
        16'b1111010?????????: begin // run = 10
                if(COUNT_COEFF==7'd54)
                        B15_SHIFT = 6'd12;
                else
                        B15_SHIFT = 6'd8;
        end
        16'b00100001????????: begin // run = 11
                if(COUNT_COEFF==7'd53)
                        B15_SHIFT = 6'd13;
                else
                        B15_SHIFT = 6'd9;
        end
        16'b00100101????????: begin // run = 12
                if(COUNT_COEFF==7'd52)
                        B15_SHIFT = 6'd13;
                else
                        B15_SHIFT = 6'd9;
        end
        16'b00100100????????: begin // run = 13
                if(COUNT_COEFF==7'd51)
                        B15_SHIFT = 6'd13;
                else
                        B15_SHIFT = 6'd9;
        end
        16'b000100??????????: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd11;
                else
                        B15_SHIFT = 6'd7;
        end
        16'b00100111????????: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B15_SHIFT = 6'd13;
                else
                        B15_SHIFT = 6'd9;
        end
        16'b11111100????????: begin // run = 2
                if(COUNT_COEFF==7'd62)
                        B15_SHIFT = 6'd13;
                else
                        B15_SHIFT = 6'd9;
        end
        16'b11111101????????: begin // run = 4
                if(COUNT_COEFF==7'd60)
                        B15_SHIFT = 6'd13;
                else
                        B15_SHIFT = 6'd9;
        end
        16'b000000100???????: begin // run = 5
                if(COUNT_COEFF==7'd59)
                        B15_SHIFT = 6'd14;
                else
                        B15_SHIFT = 6'd10;
        end
        16'b000000101???????: begin // run = 14
                if(COUNT_COEFF==7'd50)
                        B15_SHIFT = 6'd14;
                else
                        B15_SHIFT = 6'd10;
        end
        16'b000000111???????: begin // run = 15
                if(COUNT_COEFF==7'd49)
                        B15_SHIFT = 6'd14;
                else
                        B15_SHIFT = 6'd10;
        end
        16'b0000001101??????: begin // run = 16
                if(COUNT_COEFF==7'd48)
                        B15_SHIFT = 6'd15;
                else
                        B15_SHIFT = 6'd11;
        end
        16'b1111011?????????: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd12;
                else
                        B15_SHIFT = 6'd8;
        end
        16'b1111100?????????: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd12;
                else
                        B15_SHIFT = 6'd8;
        end
        16'b00100011????????: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd13;
                else
                        B15_SHIFT = 6'd9;
        end
        16'b00100010????????: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd13;
                else
                        B15_SHIFT = 6'd9;
        end
        16'b00100000????????: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B15_SHIFT = 6'd13;
                else
                        B15_SHIFT = 6'd9;
        end
        16'b0000001100??????: begin // run = 2
                if(COUNT_COEFF==7'd62)
                        B15_SHIFT = 6'd15;
                else
                        B15_SHIFT = 6'd11;
        end
        16'b000000011100????: begin // run = 3
                if(COUNT_COEFF==7'd61)
                        B15_SHIFT = 6'd17;
                else
                        B15_SHIFT = 6'd13;
        end
        16'b000000010010????: begin // run = 4
                if(COUNT_COEFF==7'd60)
                        B15_SHIFT = 6'd17;
                else
                        B15_SHIFT = 6'd13;
        end
        16'b000000011110????: begin // run = 6
                if(COUNT_COEFF==7'd58)
                        B15_SHIFT = 6'd17;
                else
                        B15_SHIFT = 6'd13;
        end
        16'b000000010101????: begin // run = 7
                if(COUNT_COEFF==7'd57)
                        B15_SHIFT = 6'd17;
                else
                        B15_SHIFT = 6'd13;
        end
        16'b000000010001????: begin // run = 8
                if(COUNT_COEFF==7'd56)
                        B15_SHIFT = 6'd17;
                else
                        B15_SHIFT = 6'd13;
        end
        16'b000000011111????: begin // run = 17
                if(COUNT_COEFF==7'd47)
                        B15_SHIFT = 6'd17;
                else
                        B15_SHIFT = 6'd13;
        end
        16'b000000011010????: begin // run = 18
                if(COUNT_COEFF==7'd46)
                        B15_SHIFT = 6'd17;
                else
                        B15_SHIFT = 6'd13;
        end
        16'b000000011001????: begin // run = 19
                if(COUNT_COEFF==7'd45)
                        B15_SHIFT = 6'd17;
                else
                        B15_SHIFT = 6'd13;
        end
        16'b000000010111????: begin // run = 20
                if(COUNT_COEFF==7'd44)
                        B15_SHIFT = 6'd17;
                else
                        B15_SHIFT = 6'd13;
        end
        16'b000000010110????: begin // run = 21
                if(COUNT_COEFF==7'd43)
                        B15_SHIFT = 6'd17;
                else
                        B15_SHIFT = 6'd13;
        end
        16'b11111010????????: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd13;
                else
                        B15_SHIFT = 6'd9;
        end
        16'b11111011????????: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd13;
                else
                        B15_SHIFT = 6'd9;
        end
        16'b11111110????????: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd13;
                else
                        B15_SHIFT = 6'd9;
        end
        16'b11111111????????: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd13;
                else
                B15_SHIFT = 6'd9;
        end
        16'b0000000010110???: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B15_SHIFT = 6'd18;
                else
                        B15_SHIFT = 6'd14;
        end
        16'b0000000010101???: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B15_SHIFT = 6'd18;
                else
                        B15_SHIFT = 6'd14;
        end
        16'b0000000010100???: begin // run = 2
                if(COUNT_COEFF==7'd62)
                        B15_SHIFT = 6'd18;
                else
                        B15_SHIFT = 6'd14;
        end
        16'b0000000010011???: begin // run = 3
                if(COUNT_COEFF==7'd61)
                        B15_SHIFT = 6'd18;
                else
                        B15_SHIFT = 6'd14;
        end
        16'b0000000010010???: begin // run = 5
                if(COUNT_COEFF==7'd59)
                        B15_SHIFT = 6'd18;
                else
                        B15_SHIFT = 6'd14;
        end
        16'b0000000010001???: begin // run = 9
                if(COUNT_COEFF==7'd55)
                        B15_SHIFT = 6'd18;
                else
                        B15_SHIFT = 6'd14;
        end
        16'b0000000010000???: begin // run = 10
                if(COUNT_COEFF==7'd54)
                        B15_SHIFT = 6'd18;
                else
                        B15_SHIFT = 6'd14;
        end
        16'b0000000011111???: begin // run = 22
                if(COUNT_COEFF==7'd42)
                        B15_SHIFT = 6'd18;
                else
                        B15_SHIFT = 6'd14;
        end
        16'b0000000011110???: begin // run = 23
                if(COUNT_COEFF==7'd41)
                        B15_SHIFT = 6'd18;
                else
                        B15_SHIFT = 6'd14;
        end
        16'b0000000011101???: begin // run = 24
                if(COUNT_COEFF==7'd40)
                        B15_SHIFT = 6'd18;
                else
                        B15_SHIFT = 6'd14;
        end
        16'b0000000011100???: begin // run = 25
                if(COUNT_COEFF==7'd39)
                        B15_SHIFT = 6'd18;
                else
                        B15_SHIFT = 6'd14;
        end
        16'b0000000011011???: begin // run = 26
                if(COUNT_COEFF==7'd38)
                        B15_SHIFT = 6'd18;
                else
                        B15_SHIFT = 6'd14;
        end
        16'b00000000011111??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd19;
                else
                        B15_SHIFT = 6'd15;
        end
        16'b00000000011110??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd19;
                else
                        B15_SHIFT = 6'd15;
        end
        16'b00000000011101??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd19;
                else
                        B15_SHIFT = 6'd15;
        end
        16'b00000000011100??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd19;
                else
                        B15_SHIFT = 6'd15;
        end
        16'b00000000011011??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd19;
                else
                        B15_SHIFT = 6'd15;
        end
        16'b00000000011010??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd19;
                else
                        B15_SHIFT = 6'd15;
        end
        16'b00000000011001??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd19;
                else
                        B15_SHIFT = 6'd15;
        end
        16'b00000000011000??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd19;
                else
                        B15_SHIFT = 6'd15;
        end
        16'b00000000010111??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd19;
                else
                        B15_SHIFT = 6'd15;
        end
        16'b00000000010110??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd19;
                else
                        B15_SHIFT = 6'd15;
        end
        16'b00000000010101??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd19;
                else
                        B15_SHIFT = 6'd15;
        end
        16'b00000000010100??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd19;
                else
                        B15_SHIFT = 6'd15;
        end
        16'b00000000010011??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd19;
                else
                        B15_SHIFT = 6'd15;
        end
        16'b00000000010010??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd19;
                else
                        B15_SHIFT = 6'd15;
        end
        16'b00000000010001??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd19;
                else
                        B15_SHIFT = 6'd15;
        end
        16'b00000000010000??: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd19;
                else
                        B15_SHIFT = 6'd15;
        end
        16'b000000000011000?: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd20;
                else
                        B15_SHIFT = 6'd16;
        end
        16'b000000000010111?: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd20;
                else
                        B15_SHIFT = 6'd16;
        end
        16'b000000000010110?: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd20;
                else
                B15_SHIFT = 6'd16;
        end
        16'b000000000010101?: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd20;
                else
                        B15_SHIFT = 6'd16;
        end
        16'b000000000010100?: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd20;
                else
                        B15_SHIFT = 6'd16;
        end
        16'b000000000010011?: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd20;
                else
                        B15_SHIFT = 6'd16;
        end
        16'b000000000010010?: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd20;
                else
                        B15_SHIFT = 6'd16;
        end
        16'b000000000010001?: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd20;
                else
                        B15_SHIFT = 6'd16;
        end
        16'b000000000010000?: begin // run = 0
                if(COUNT_COEFF==7'd64)
                        B15_SHIFT = 6'd20;
                else
                        B15_SHIFT = 6'd16;
        end
        16'b000000000011111?: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B15_SHIFT = 6'd20;
                else
                        B15_SHIFT = 6'd16;
        end
        16'b000000000011110?: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B15_SHIFT = 6'd20;
                else
                        B15_SHIFT = 6'd16;
        end
        16'b000000000011101?: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B15_SHIFT = 6'd20;
                else
                        B15_SHIFT = 6'd16;
        end
        16'b000000000011100?: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B15_SHIFT = 6'd20;
                else
                        B15_SHIFT = 6'd16;
        end
        16'b000000000011011?: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B15_SHIFT = 6'd20;
                else
                        B15_SHIFT = 6'd16;
        end
        16'b000000000011010?: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B15_SHIFT = 6'd20;
                else
                        B15_SHIFT = 6'd16;
        end
        16'b000000000011001?: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B15_SHIFT = 6'd20;
                else
                        B15_SHIFT = 6'd16;
        end
        16'b0000000000010011: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B15_SHIFT = 6'd21;
                else
                        B15_SHIFT = 6'd17;
        end
        16'b0000000000010010: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B15_SHIFT = 6'd21;
                else
                        B15_SHIFT = 6'd17;
        end
        16'b0000000000010001: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B15_SHIFT = 6'd21;
                else
                        B15_SHIFT = 6'd17;
        end
        16'b0000000000010000: begin // run = 1
                if(COUNT_COEFF==7'd63)
                        B15_SHIFT = 6'd21;
                else
                        B15_SHIFT = 6'd17;
        end
        16'b0000000000010100: begin // run = 6
                if(COUNT_COEFF==7'd58)
                        B15_SHIFT = 6'd21;
                else
                        B15_SHIFT = 6'd17;
        end
        16'b0000000000011010: begin // run = 11
                if(COUNT_COEFF==7'd53)
                        B15_SHIFT = 6'd21;
                else
                        B15_SHIFT = 6'd17;
        end
        16'b0000000000011001: begin // run = 12
                if(COUNT_COEFF==7'd52)
                        B15_SHIFT = 6'd21;
                else
                        B15_SHIFT = 6'd17;
        end
        16'b0000000000011000: begin // run = 13
                if(COUNT_COEFF==7'd51)
                        B15_SHIFT = 6'd21;
                else
                        B15_SHIFT = 6'd17;
        end
        16'b0000000000010111: begin // run = 14
                if(COUNT_COEFF==7'd50)
                        B15_SHIFT = 6'd21;
                else
                        B15_SHIFT = 6'd17;
        end
        16'b0000000000010110: begin // run = 15
                if(COUNT_COEFF==7'd49)
                        B15_SHIFT = 6'd21;
                else
                        B15_SHIFT = 6'd17;
        end
        16'b0000000000010101: begin // run = 16
                if(COUNT_COEFF==7'd48)
                        B15_SHIFT = 6'd21;
                else
                B15_SHIFT = 6'd17;
        end
        16'b0000000000011111: begin // run = 27
                if(COUNT_COEFF==7'd37)
                        B15_SHIFT = 6'd21;
                else
                        B15_SHIFT = 6'd17;
        end
        16'b0000000000011110: begin // run = 28
                if(COUNT_COEFF==7'd36)
                        B15_SHIFT = 6'd21;
                else
                        B15_SHIFT = 6'd17;
        end
        16'b0000000000011101: begin // run = 29 
                if(COUNT_COEFF==7'd35)
                        B15_SHIFT = 6'd21;
                else
                        B15_SHIFT = 6'd17;
        end
        16'b0000000000011100: begin // run = 30
                if(COUNT_COEFF==7'd34)
                        B15_SHIFT = 6'd21;
                else
                        B15_SHIFT = 6'd17;
        end
        16'b0000000000011011: begin // run = 31
                if(COUNT_COEFF==7'd33)
                        B15_SHIFT = 6'd21;
                else
                        B15_SHIFT = 6'd17;
        end
        default: begin
                B15_SHIFT = 6'd0;
        end
    endcase

endmodule
