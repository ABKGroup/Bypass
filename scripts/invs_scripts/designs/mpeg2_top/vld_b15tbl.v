// ----------------------------------------------
// File: vld_b15tbl.v
// Module: vld_b15tbl
// Function:generate block data  from B15
// ----------------------------------------------

module vld_b15tbl(
    STREAM, 
    STARTVLD, 
    COUNT_COEFF, 
    NEXT_VDOSGN, 
    NEXT_VDO, 
    NEXT_RUN, 
    NEXT_FERROR, 
    NEXT_HOLD_SIGN,        
    NEXT_HOLD_VDO
);

output [10:0] NEXT_VDO, NEXT_HOLD_VDO;
output [5:0] NEXT_RUN;
output NEXT_VDOSGN, NEXT_FERROR, NEXT_HOLD_SIGN;

input STARTVLD; 
input [6:0] COUNT_COEFF;
input [29:9] STREAM;

reg [10:0] NEXT_VDO, NEXT_HOLD_VDO;
reg [5:0] NEXT_RUN;
reg NEXT_VDOSGN, NEXT_FERROR, NEXT_HOLD_SIGN;

parameter 
 error = 1'b1,
 no_error = 1'b0;

always @(STREAM or STARTVLD or COUNT_COEFF)
    casex(STREAM[29:13]) 
        17'b0110?????????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd0;
                if(!STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b0;
                NEXT_HOLD_VDO=11'd0;
        end
        17'b10???????????????: begin
                NEXT_VDOSGN=STREAM[27];
                NEXT_VDO=11'd1;             // Level = 1
                NEXT_RUN=6'd0;              // Run = 0
                if(COUNT_COEFF==7'd64 && STREAM[26:23]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; // 2004.3.5 fixed value input
                NEXT_HOLD_VDO=11'd0; // 2004.3.5 fixed value input
        end
      // Run = 1 , Level = 1
        17'b010??????????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd1;             // Run = 1
                if((COUNT_COEFF==7'd63 && STREAM[25:22]!=4'b0110)
                  ||(COUNT_COEFF>7'd63))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[26];
                NEXT_HOLD_VDO=11'd1;       // Level = 1
        end
      // Run = 0 , Level = 2
        17'b110??????????????: begin
                NEXT_VDOSGN=STREAM[26];
                NEXT_VDO=11'd2;            // Level = 2
                NEXT_RUN=6'd0;             // Run = 0
                if(COUNT_COEFF==7'd64 && STREAM[25:22]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1;
                NEXT_HOLD_VDO=11'd0; 
        end
      // Run = 2 , Level = 1
        17'b00101????????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd2;              // Run = 2
                if((COUNT_COEFF==7'd62 && STREAM[23:20]!=4'b0110)
                  ||(COUNT_COEFF>7'd62))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[24];
                NEXT_HOLD_VDO=11'd1;        // Level = 1
        end
      // Run = 0 , Level = 3
        17'b0111?????????????: begin
                NEXT_VDOSGN=STREAM[25];
                NEXT_VDO=11'd3;             // Level = 3
                NEXT_RUN=6'd0;              // Run = 0
                if(COUNT_COEFF==7'd64 && STREAM[24:21]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
      // Run = 3 , Level = 1
        17'b00111????????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd3;              // Run = 3
                if((COUNT_COEFF==7'd61 && STREAM[23:20]!=4'b0110)
                  ||(COUNT_COEFF>7'd61))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[24];
                NEXT_HOLD_VDO=11'd1;        // Level = 1
        end
      // Run = 4 , Level = 1
        17'b000110???????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd4;              // Run = 4
                if((COUNT_COEFF==7'd60 && STREAM[22:19]!=4'b0110)
                  ||(COUNT_COEFF>7'd60))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[23];
                NEXT_HOLD_VDO=11'd1;        // Level = 1
        end
      // Run = 1 , Level = 2
        17'b00110????????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd1;              // Run = 1
                if((COUNT_COEFF==7'd63 && STREAM[23:20]!=4'b0110)
                  ||(COUNT_COEFF>7'd63))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[24];
                NEXT_HOLD_VDO=11'd2;        // Level = 2
        end
      // Run = 5 , Level = 1
        17'b000111???????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd5;              // Run = 5
            //if((COUNT_COEFF==7'd59&&STREAM[24:19]!=4'b0110)
                if((COUNT_COEFF==7'd59 && STREAM[22:19]!=4'b0110)
                  ||(COUNT_COEFF>7'd59))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[23];
                NEXT_HOLD_VDO=11'd1;        // Level = 1
        end
      // Run = 6 , Level = 1
        17'b0000110??????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd6;              // Run = 6
                if((COUNT_COEFF==7'd58 && STREAM[21:18]!=4'b0110)
                  ||(COUNT_COEFF>7'd58))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[22];
                NEXT_HOLD_VDO=11'd1;        // Level = 1
        end
      // Run = 7 , Level = 1
        17'b0000100??????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd7;              // Run = 7
                if((COUNT_COEFF==7'd57 && STREAM[21:18]!=4'b0110)
                  ||(COUNT_COEFF>7'd57))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[22];
                NEXT_HOLD_VDO=11'd1;        // Level = 1
        end
      // Run = 0 , Level = 4
        17'b11100????????????: begin
                NEXT_VDOSGN=STREAM[24];
                NEXT_VDO=11'd4;             // Level = 4
                NEXT_RUN=6'd0;              // Run = 0
                if(COUNT_COEFF==7'd64&&STREAM[23:20]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b0;
                NEXT_HOLD_VDO=11'd0;
        end
      // Run = 2 , Level = 2
        17'b0000111??????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd2;              // Run = 2
                if((COUNT_COEFF==7'd62&&STREAM[21:18]!=4'b0110)
                  ||(COUNT_COEFF>7'd62))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[22];
                NEXT_HOLD_VDO=11'd2;        // Level = 2
        end
      // Run = 8 , Level = 1
        17'b0000101??????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd8;              // Run = 8
                if((COUNT_COEFF==7'd56&&STREAM[21:18]!=4'b0110)
                  ||(COUNT_COEFF>7'd56))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[22];
                NEXT_HOLD_VDO=11'd1;        // Level = 1
        end
      // Run = 9 , Level = 1
        17'b1111000??????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd9;              // Run = 9
                if((COUNT_COEFF==7'd55&&STREAM[21:18]!=4'b0110)
                  ||(COUNT_COEFF>7'd55))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[22];
                NEXT_HOLD_VDO=11'd1;        // Level = 1
        end
        17'b000001???????????: begin // Escape
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd0;
                NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b0;
                NEXT_HOLD_VDO=11'd0;
        end
      // Run = 0 , Level = 5
        17'b11101????????????: begin
                NEXT_VDOSGN=STREAM[24];
                NEXT_VDO=11'd5;              // Level = 5
                NEXT_RUN=6'd0;               // Run = 0
                if(COUNT_COEFF==7'd64&&STREAM[23:20]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b0;
                NEXT_HOLD_VDO=11'd0;
        end
      // Run = 0 , Level = 6
        17'b000101???????????: begin
                NEXT_VDOSGN=STREAM[23];
                NEXT_VDO=11'd6;              // Level = 6
                NEXT_RUN=6'd0;               // Run = 0
                if(COUNT_COEFF==7'd64&&STREAM[22:19]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b0;
                NEXT_HOLD_VDO=11'd0;
        end
      // Run = 1 , Level = 3
        17'b1111001??????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd1;                // Run = 1
                if((COUNT_COEFF==7'd63&&STREAM[21:18]!=4'b0110)
                  ||(COUNT_COEFF>7'd63))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[22];
                NEXT_HOLD_VDO=11'd3;          // Level = 3
        end
      // Run = 3 , Level = 2
        17'b00100110?????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd3;                // Run = 3
                if((COUNT_COEFF==7'd61&&STREAM[20:17]!=4'b0110)
                  ||(COUNT_COEFF>7'd61))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[21];
                NEXT_HOLD_VDO=11'd2;          // Level = 2
        end
      // Run = 10 , Level = 1
        17'b1111010??????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd10;               // Run = 10
                if((COUNT_COEFF==7'd54&&STREAM[21:18]!=4'b0110)
                  ||(COUNT_COEFF>7'd54))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[22];
                NEXT_HOLD_VDO=11'd1;          // Level = 1
        end
      // Run = 11 , Level = 1
        17'b00100001?????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd11;               // Run = 11
                if((COUNT_COEFF==7'd53&&STREAM[20:17]!=4'b0110)
                  ||(COUNT_COEFF>7'd53))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[21];
                NEXT_HOLD_VDO=11'd1;          // Level = 1
        end
      // Run = 12 , Level = 1
        17'b00100101?????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd12;               // Run = 12
                if((COUNT_COEFF==7'd52&&STREAM[20:17]!=4'b0110)
                  ||(COUNT_COEFF>7'd52))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[21];
                NEXT_HOLD_VDO=11'd1;          // Level = 1
        end
      // Run = 13 , Level = 1
        17'b00100100?????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd13;               // Run = 13
                if((COUNT_COEFF==7'd51&&STREAM[20:17]!=4'b0110)
                  ||(COUNT_COEFF>7'd51))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[21];
                NEXT_HOLD_VDO=11'd1;          // Level = 1
        end
      // Run = 0 , Level = 7
        17'b000100???????????: begin
                NEXT_VDOSGN=STREAM[23];
                NEXT_VDO=11'd7;               // Level = 7
                NEXT_RUN=6'd0;                // Run = 0
                if(COUNT_COEFF==7'd64&&STREAM[22:19]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
      // Run = 1 , Level = 4
        17'b00100111?????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd1;                // Run = 1
                if((COUNT_COEFF==7'd63&&STREAM[20:17]!=4'b0110)
                  ||(COUNT_COEFF>7'd63))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[21];
                NEXT_HOLD_VDO=11'd4;          // Level = 4
        end
      // Run = 2 , Level = 3
        17'b11111100?????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd2;                // Run = 2
                if((COUNT_COEFF==7'd62&&STREAM[20:17]!=4'b0110)
                  ||(COUNT_COEFF>7'd62))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[21];
                NEXT_HOLD_VDO=11'd3;          // Level = 3
        end
      // Run = 4 , Level = 2
        17'b11111101?????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd4;                // Run = 4
                if((COUNT_COEFF==7'd60&&STREAM[20:17]!=4'b0110)
                  ||(COUNT_COEFF>7'd60))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[21];
                NEXT_HOLD_VDO=11'd2;          // Level = 2
        end
      // Run = 5 , Level = 2
        17'b000000100????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd5;                // Run = 5
                if((COUNT_COEFF==7'd59&&STREAM[19:16]!=4'b0110)
                  ||(COUNT_COEFF>7'd59))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[20];
                NEXT_HOLD_VDO=11'd2;          // Level = 2
        end
      // Run = 14 , Level = 1
        17'b000000101????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd14;               // Run = 14
                if((COUNT_COEFF==7'd50&&STREAM[19:16]!=4'b0110)
                  ||(COUNT_COEFF>7'd50))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[20];
                NEXT_HOLD_VDO=11'd1;         // Level = 1
        end
      // Run = 15 , Level = 1
        17'b000000111????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd15;              // Run = 15
                if((COUNT_COEFF==7'd49&&STREAM[19:16]!=4'b0110)
                  ||(COUNT_COEFF>7'd49))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[20];
                NEXT_HOLD_VDO=11'd1;         // Level = 1
        end
      // Run = 16 , Level = 1
        17'b0000001101???????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd16;              // Run = 16
                if((COUNT_COEFF==7'd48&&STREAM[18:15]!=4'b0110)
                  ||(COUNT_COEFF>7'd48))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[19];
                NEXT_HOLD_VDO=11'd1;         // Level = 1
        end
      // Run = 0 , Level = 8
        17'b1111011??????????: begin
                NEXT_VDOSGN=STREAM[22];
                NEXT_VDO=11'd8;              // Level = 8
                NEXT_RUN=6'd0;               // Run = 0
                if(COUNT_COEFF==7'd64&&STREAM[21:18]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b1111100??????????: begin
                NEXT_VDOSGN=STREAM[22];
                NEXT_VDO=11'd9;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[21:18]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b00100011?????????: begin
                NEXT_VDOSGN=STREAM[21];
                NEXT_VDO=11'd10;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[20:17]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1;
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b00100010?????????: begin
                NEXT_VDOSGN=STREAM[21];
                NEXT_VDO=11'd11;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[20:17]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b00100000?????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd1;
                if((COUNT_COEFF==7'd63&&STREAM[20:17]!=4'b0110)
                  ||(COUNT_COEFF>7'd63))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[21];
                NEXT_HOLD_VDO=11'd5;
        end
        17'b0000001100???????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd2;
                if((COUNT_COEFF==7'd62&&STREAM[18:15]!=4'b0110)
                  ||(COUNT_COEFF>7'd62))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[19];
                NEXT_HOLD_VDO=11'd4;
        end
        17'b000000011100?????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd3;
                if((COUNT_COEFF==7'd61&&STREAM[16:13]!=4'b0110)
                  ||(COUNT_COEFF>7'd61))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[17];
                NEXT_HOLD_VDO=11'd3;
        end
        17'b000000010010?????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd4;
                if((COUNT_COEFF==7'd60&&STREAM[16:13]!=4'b0110)
                  ||(COUNT_COEFF>7'd60))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[17];
                NEXT_HOLD_VDO=11'd3;
        end
        17'b000000011110?????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd6;
                if((COUNT_COEFF==7'd58&&STREAM[16:13]!=4'b0110)
                  ||(COUNT_COEFF>7'd58))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[17];
                NEXT_HOLD_VDO=11'd2;
        end
        17'b000000010101?????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd7;
                if((COUNT_COEFF==7'd57&&STREAM[16:13]!=4'b0110)
                  ||(COUNT_COEFF>7'd57))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[17];
                NEXT_HOLD_VDO=11'd2;
        end
        17'b000000010001?????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd8;
                if((COUNT_COEFF==7'd56&&STREAM[16:13]!=4'b0110)
                  ||(COUNT_COEFF>7'd56))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[17];
                NEXT_HOLD_VDO=11'd2;
        end
        17'b000000011111?????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd17;
                if((COUNT_COEFF==7'd47&&STREAM[16:13]!=4'b0110)
                  ||(COUNT_COEFF>7'd47))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[17];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b000000011010?????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd18;
                if((COUNT_COEFF==7'd46&&STREAM[16:13]!=4'b0110)
                  ||(COUNT_COEFF>7'd46))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[17];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b000000011001?????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd19;
                if((COUNT_COEFF==7'd45&&STREAM[16:13]!=4'b0110)
                  ||(COUNT_COEFF>7'd45))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[17];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b000000010111?????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd20;
                if((COUNT_COEFF==7'd44&&STREAM[16:13]!=4'b0110)
                  ||(COUNT_COEFF>7'd44))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[17];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b000000010110?????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd21;
                if((COUNT_COEFF==7'd43&&STREAM[16:13]!=4'b0110)
                  ||(COUNT_COEFF>7'd43))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[17];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b11111010?????????: begin
                NEXT_VDOSGN=STREAM[21];
                NEXT_VDO=11'd12;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[20:17]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b11111011?????????: begin
                NEXT_VDOSGN=STREAM[21];
                NEXT_VDO=11'd13;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[20:17]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b11111110?????????: begin
                NEXT_VDOSGN=STREAM[21];
                NEXT_VDO=11'd14;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[20:17]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b11111111?????????: begin
                NEXT_VDOSGN=STREAM[21];
                NEXT_VDO=11'd15;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[20:17]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b0000000010110????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd1;
                if((COUNT_COEFF==7'd63&&STREAM[15:12]!=4'b0110)
                  ||(COUNT_COEFF>7'd63))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[16];
                NEXT_HOLD_VDO=11'd6;
        end
        17'b0000000010101????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd1;
                if((COUNT_COEFF==7'd63&&STREAM[15:12]!=4'b0110)
                  ||(COUNT_COEFF>7'd63))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[16];
                NEXT_HOLD_VDO=11'd7;
        end
        17'b0000000010100????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd2;
                if((COUNT_COEFF==7'd62&&STREAM[15:12]!=4'b0110)
                  ||(COUNT_COEFF>7'd62))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[16];
                NEXT_HOLD_VDO=11'd5;
        end
        17'b0000000010011????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd3;
                if((COUNT_COEFF==7'd61&&STREAM[15:12]!=4'b0110)
                  ||(COUNT_COEFF>7'd61))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[16];
                NEXT_HOLD_VDO=11'd4;
        end
        17'b0000000010010????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd5;
                if((COUNT_COEFF==7'd59&&STREAM[15:12]!=4'b0110)
                  ||(COUNT_COEFF>7'd59))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[16];
                NEXT_HOLD_VDO=11'd3;
        end
        17'b0000000010001????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd9;
                if((COUNT_COEFF==7'd55&&STREAM[15:12]!=4'b0110)
                  ||(COUNT_COEFF>7'd55))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[16];
                NEXT_HOLD_VDO=11'd2;
        end
        17'b0000000010000????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd10;
                if((COUNT_COEFF==7'd54&&STREAM[15:12]!=4'b0110)
                  ||(COUNT_COEFF>7'd54))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[16];
                NEXT_HOLD_VDO=11'd2;
        end
        17'b0000000011111????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd22;
                if((COUNT_COEFF==7'd42&&STREAM[15:12]!=4'b0110)
                  ||(COUNT_COEFF>7'd42))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[16];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b0000000011110????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd23;
                if((COUNT_COEFF==7'd41&&STREAM[15:12]!=4'b0110)
                  ||(COUNT_COEFF>7'd41))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[16];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b0000000011101????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd24;
                if((COUNT_COEFF==7'd40&&STREAM[15:12]!=4'b0110)
                  ||(COUNT_COEFF>7'd40))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[16];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b0000000011100????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd25;
                if((COUNT_COEFF==7'd39&&STREAM[15:12]!=4'b0110)
                  ||(COUNT_COEFF>7'd39))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[16];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b0000000011011????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd26;
                if((COUNT_COEFF==7'd38&&STREAM[15:12]!=4'b0110)
                  ||(COUNT_COEFF>7'd38))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[16];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b00000000011111???: begin
                NEXT_VDOSGN=STREAM[15];
                NEXT_VDO=11'd16;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[14:11]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b00000000011110???: begin
                NEXT_VDOSGN=STREAM[15];
                NEXT_VDO=11'd17;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[14:11]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b00000000011101???: begin
                NEXT_VDOSGN=STREAM[15];
                NEXT_VDO=11'd18;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[14:11]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b00000000011100???: begin
                NEXT_VDOSGN=STREAM[15];
                NEXT_VDO=11'd19;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[14:11]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b00000000011011???: begin
                NEXT_VDOSGN=STREAM[15];
                NEXT_VDO=11'd20;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[14:11]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b00000000011010???: begin
                NEXT_VDOSGN=STREAM[15];
                NEXT_VDO=11'd21;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[14:11]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b00000000011001???: begin
                NEXT_VDOSGN=STREAM[15];
                NEXT_VDO=11'd22;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[14:11]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b00000000011000???: begin
                NEXT_VDOSGN=STREAM[15];
                NEXT_VDO=11'd23;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[14:11]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b00000000010111???: begin
                NEXT_VDOSGN=STREAM[15];
                NEXT_VDO=11'd24;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[14:11]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b00000000010110???: begin
                NEXT_VDOSGN=STREAM[15];
                NEXT_VDO=11'd25;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[14:11]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b00000000010101???: begin
                NEXT_VDOSGN=STREAM[15];
                NEXT_VDO=11'd26;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[14:11]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b00000000010100???: begin
                NEXT_VDOSGN=STREAM[15];
                NEXT_VDO=11'd27;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[14:11]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b00000000010011???: begin
                NEXT_VDOSGN=STREAM[15];
                NEXT_VDO=11'd28;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[14:11]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b00000000010010???: begin
                NEXT_VDOSGN=STREAM[15];
                NEXT_VDO=11'd29;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[14:11]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b00000000010001???: begin
                NEXT_VDOSGN=STREAM[15];
                NEXT_VDO=11'd30;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[14:11]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b00000000010000???: begin
                NEXT_VDOSGN=STREAM[15];
                NEXT_VDO=11'd31;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[14:11]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1;
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b000000000011000??: begin
                NEXT_VDOSGN=STREAM[14];
                NEXT_VDO=11'd32;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[13:10]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b000000000010111??: begin
                NEXT_VDOSGN=STREAM[14];
                NEXT_VDO=11'd33;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[13:10]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1;
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b000000000010110??: begin
                NEXT_VDOSGN=STREAM[14];
                NEXT_VDO=11'd34;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[13:10]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b000000000010101??: begin
                NEXT_VDOSGN=STREAM[14];
                NEXT_VDO=11'd35;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[13:10]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b000000000010100??: begin
                NEXT_VDOSGN=STREAM[14];
                NEXT_VDO=11'd36;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[13:10]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b000000000010011??: begin
                NEXT_VDOSGN=STREAM[14];
                NEXT_VDO=11'd37;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[13:10]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b000000000010010??: begin
                NEXT_VDOSGN=STREAM[14];
                NEXT_VDO=11'd38;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[13:10]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b000000000010001??: begin
                NEXT_VDOSGN=STREAM[14];
                NEXT_VDO=11'd39;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[13:10]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b000000000010000??: begin
                NEXT_VDOSGN=STREAM[14];
                NEXT_VDO=11'd40;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[13:10]!=4'b0110)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b000000000011111??: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd1;
                if((COUNT_COEFF==7'd63&&STREAM[13:10]!=4'b0110)
                  ||(COUNT_COEFF>7'd63))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[14];
                NEXT_HOLD_VDO=11'd8;
        end
        17'b000000000011110??: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd1;
                if((COUNT_COEFF==7'd63&&STREAM[13:10]!=4'b0110)
                  ||(COUNT_COEFF>7'd63))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[14];
                NEXT_HOLD_VDO=11'd9;
        end
        17'b000000000011101??: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd1;
                if((COUNT_COEFF==7'd63&&STREAM[13:10]!=4'b0110)
                  ||(COUNT_COEFF>7'd63))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[14];
                NEXT_HOLD_VDO=11'd10;
        end
        17'b000000000011100??: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd1;
                if((COUNT_COEFF==7'd63&&STREAM[13:10]!=4'b0110)
                  ||(COUNT_COEFF>7'd63))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[14];
                NEXT_HOLD_VDO=11'd11;
        end
        17'b000000000011011??: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd1;
                if((COUNT_COEFF==7'd63&&STREAM[13:10]!=4'b0110)
                  ||(COUNT_COEFF>7'd63))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[14];
                NEXT_HOLD_VDO=11'd12;
        end
        17'b000000000011010??: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd1;
                if((COUNT_COEFF==7'd63&&STREAM[13:10]!=4'b0110)
                  ||(COUNT_COEFF>7'd63))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[14];
                NEXT_HOLD_VDO=11'd13;
        end
        17'b000000000011001??: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd1;
                if((COUNT_COEFF==7'd63&&STREAM[13:10]!=4'b0110)
                  ||(COUNT_COEFF>7'd63))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[14];
                NEXT_HOLD_VDO=11'd14;
        end
        17'b0000000000010011?: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd1;
                if((COUNT_COEFF==7'd63&&STREAM[12:9]!=4'b0110)
                  ||(COUNT_COEFF>7'd63))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[13];
                NEXT_HOLD_VDO=11'd15;
        end
        17'b0000000000010010?: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd1;
                if((COUNT_COEFF==7'd63&&STREAM[12:9]!=4'b0110)
                  ||(COUNT_COEFF>7'd63))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[13];
                NEXT_HOLD_VDO=11'd16;
        end
        17'b0000000000010001?: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd1;
                if((COUNT_COEFF==7'd63&&STREAM[12:9]!=4'b0110)
                  ||(COUNT_COEFF>7'd63))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[13];
                NEXT_HOLD_VDO=11'd17;
        end
        17'b0000000000010000?: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd1;
                if((COUNT_COEFF==7'd63&&STREAM[12:9]!=4'b0110)
                  ||(COUNT_COEFF>7'd63))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[13];
                NEXT_HOLD_VDO=11'd18;
        end
        17'b0000000000010100?: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd6;
                if((COUNT_COEFF==7'd58&&STREAM[12:9]!=4'b0110)
                  ||(COUNT_COEFF>7'd58))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[13];
                NEXT_HOLD_VDO=11'd3;
        end
        17'b0000000000011010?: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd11;
                if((COUNT_COEFF==7'd53&&STREAM[12:9]!=4'b0110)
                  ||(COUNT_COEFF>7'd53))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[13];
                NEXT_HOLD_VDO=11'd2;
        end
        17'b0000000000011001?: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd12;
                if((COUNT_COEFF==7'd52&&STREAM[12:9]!=4'b0110)
                  ||(COUNT_COEFF>7'd52))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[13];
                NEXT_HOLD_VDO=11'd2;
        end
        17'b0000000000011000?: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd13;
                if((COUNT_COEFF==7'd51&&STREAM[12:9]!=4'b0110)
                  ||(COUNT_COEFF>7'd51))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[13];
                NEXT_HOLD_VDO=11'd2;
        end
        17'b0000000000010111?: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd14;
                if((COUNT_COEFF==7'd50&&STREAM[12:9]!=4'b0110)
                  ||(COUNT_COEFF>7'd50))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[13];
                NEXT_HOLD_VDO=11'd2;
        end
        17'b0000000000010110?: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd15;
                if((COUNT_COEFF==7'd49&&STREAM[12:9]!=4'b0110)
                  ||(COUNT_COEFF>7'd49))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[13];
                NEXT_HOLD_VDO=11'd2;
        end
        17'b0000000000010101?: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd16;
                if((COUNT_COEFF==7'd48&&STREAM[12:9]!=4'b0110)
                  ||(COUNT_COEFF>7'd48))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[13];
                NEXT_HOLD_VDO=11'd2;
        end
        17'b0000000000011111?: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd27;
                if((COUNT_COEFF==7'd37&&STREAM[12:9]!=4'b0110)
                  ||(COUNT_COEFF>7'd37))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[13];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b0000000000011110?: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd28;
                if((COUNT_COEFF==7'd36&&STREAM[12:9]!=4'b0110)
                  ||(COUNT_COEFF>7'd36))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[13];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b0000000000011101?: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd29;
                if((COUNT_COEFF==7'd35&&STREAM[12:9]!=4'b0110)
                  ||(COUNT_COEFF>7'd35))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[13];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b0000000000011100?: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd30;
                if((COUNT_COEFF==7'd34&&STREAM[12:9]!=4'b0110)
                  ||(COUNT_COEFF>7'd34))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[13];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b0000000000011011?: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd31;
                if((COUNT_COEFF==7'd33&&STREAM[12:9]!=4'b0110)
                  ||(COUNT_COEFF>7'd33))
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[13];
                NEXT_HOLD_VDO=11'd1;
        end
        default: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd0;
                NEXT_FERROR=error;
                NEXT_HOLD_SIGN=1'b0;
                NEXT_HOLD_VDO=11'd0;
        end
    endcase

endmodule

