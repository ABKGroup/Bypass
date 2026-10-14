// ----------------------------------------------
// File: vld_b14tbl.v
// Module: vld_b14tbl
// Function:generate block data  from B14
// ----------------------------------------------

module vld_b14tbl(
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
input [29:11] STREAM;

reg [10:0] NEXT_VDO, NEXT_HOLD_VDO;
reg [5:0] NEXT_RUN;
reg NEXT_VDOSGN, NEXT_FERROR, NEXT_HOLD_SIGN;

parameter 
 error = 1'b1,
 no_error = 1'b0;

always @(STREAM or STARTVLD or COUNT_COEFF)  

    casex(STREAM[29:13]) 
        17'b1????????????????: begin
                if(!STARTVLD) begin
                        NEXT_VDOSGN=STREAM[28];
                        NEXT_VDO=11'd1;
                        NEXT_RUN=6'd0;
                        NEXT_FERROR=no_error;
                        NEXT_HOLD_SIGN=1'b1;
                        NEXT_HOLD_VDO=11'd0; 
                end
                else if(STREAM[28]==1'b1) begin 
                        NEXT_VDOSGN=STREAM[27];
                        NEXT_VDO=11'd1;
                        NEXT_RUN=6'd0;
                        if(COUNT_COEFF==7'd64&&STREAM[26:25]!=2'b10)
                                NEXT_FERROR=error;
                        else
                                NEXT_FERROR=no_error;
                        NEXT_HOLD_SIGN=1'b1; 
                        NEXT_HOLD_VDO=11'd0; 
                end
                else begin
                        NEXT_VDOSGN=1'b0;
                        NEXT_VDO=11'd0;
                        NEXT_RUN=6'd0;
                        NEXT_FERROR=no_error;
                        NEXT_HOLD_SIGN=1'b0;
                        NEXT_HOLD_VDO=11'h00;
                end
        end
        17'b011??????????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd1;
                if(((COUNT_COEFF==7'd63&&STREAM[25:24]!=2'b10)
                  ||(COUNT_COEFF>7'd63))&&STARTVLD) 
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[26];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b0100?????????????: begin
                NEXT_VDOSGN=STREAM[25];
                NEXT_VDO=11'd2;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[24:23]!=2'b10)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b0101?????????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd2;
                if(((COUNT_COEFF==7'd62&&STREAM[24:23]!=2'b10)
                  ||(COUNT_COEFF>7'd62))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[25];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b00101????????????: begin
                NEXT_VDOSGN=STREAM[24];
                NEXT_VDO=11'd3;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[23:22]!=2'b10)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1;  
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b00111????????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd3;
                if(((COUNT_COEFF==7'd61&&STREAM[23:22]!=2'b10)
                  ||(COUNT_COEFF>7'd61))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[24];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b00110????????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd4;
                if(((COUNT_COEFF==7'd60&&STREAM[23:22]!=2'b10)
                  ||(COUNT_COEFF>7'd60))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[24];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b000110???????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd1;
                if(((COUNT_COEFF==7'd63&&STREAM[22:21]!=2'b10)
                  ||(COUNT_COEFF>7'd63))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[23];
                NEXT_HOLD_VDO=11'd2;
        end
        17'b000111???????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd5;
                if(((COUNT_COEFF==7'd59&&STREAM[22:21]!=2'b10)
                  ||(COUNT_COEFF>7'd59))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[23];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b000101???????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd6;
                if(((COUNT_COEFF==7'd58&&STREAM[22:21]!=2'b10)
                  ||(COUNT_COEFF>7'd58))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[23];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b000100???????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd7;
                if(((COUNT_COEFF==7'd57&&STREAM[22:21]!=2'b10)
                  ||(COUNT_COEFF>7'd57))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[23];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b0000110??????????: begin
                NEXT_VDOSGN=STREAM[22];
                NEXT_VDO=11'd4;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[21:20]!=2'b10)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b0000100??????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd2;
                if(((COUNT_COEFF==7'd62&&STREAM[21:20]!=2'b10)
                  ||(COUNT_COEFF>7'd62))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[22];
                NEXT_HOLD_VDO=11'd2;
        end
        17'b0000111??????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd8;
                if(((COUNT_COEFF==7'd56&&STREAM[21:20]!=2'b10)
                  ||(COUNT_COEFF>7'd56))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[22];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b0000101??????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd9;
                if(((COUNT_COEFF==7'd55&&STREAM[21:20]!=2'b10)
                  ||(COUNT_COEFF>7'd55))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[22];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b000001???????????: begin // Escape
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd0;
                NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b0;
                NEXT_HOLD_VDO=11'd0;
        end
        17'b00100110?????????: begin
                NEXT_VDOSGN=STREAM[21];
                NEXT_VDO=11'd5;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[20:19]!=2'b10)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1;
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b00100001?????????: begin
                NEXT_VDOSGN=STREAM[21];
                NEXT_VDO=11'd6;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[20:19]!=2'b10)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b00100101?????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd1;
                if(((COUNT_COEFF==7'd63&&STREAM[20:19]!=2'b10)
                  ||(COUNT_COEFF>7'd63))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[21];
                NEXT_HOLD_VDO=11'd3;
        end
        17'b00100100?????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd3;
                if(((COUNT_COEFF==7'd61&&STREAM[20:19]!=2'b10)
                  ||(COUNT_COEFF>7'd61))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[21];
                NEXT_HOLD_VDO=11'd2;
        end
        17'b00100111?????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd10;
                if(((COUNT_COEFF==7'd54&&STREAM[20:19]!=2'b10)
                  ||(COUNT_COEFF>7'd54))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[21];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b00100011?????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd11;
                if(((COUNT_COEFF==7'd53&&STREAM[20:19]!=2'b10)
                  ||(COUNT_COEFF>7'd53))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[21];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b00100010?????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd12;
                if(((COUNT_COEFF==7'd52&&STREAM[20:19]!=2'b10)
                  ||(COUNT_COEFF>7'd52))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[21];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b00100000?????????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd13;
                if(((COUNT_COEFF==7'd51&&STREAM[20:19]!=2'b10)
                  ||(COUNT_COEFF>7'd51))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[21];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b0000001010???????: begin
                NEXT_VDOSGN=STREAM[19];
                NEXT_VDO=11'd7;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[18:17]!=2'b10)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b0000001100???????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd1;
                if(((COUNT_COEFF==7'd63&&STREAM[18:17]!=2'b10)
                  ||(COUNT_COEFF>7'd63))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[19];
                NEXT_HOLD_VDO=11'd4;
        end
        17'b0000001011???????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd2;
                if(((COUNT_COEFF==7'd62&&STREAM[18:17]!=2'b10)
                  ||(COUNT_COEFF>7'd62))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[19];
                NEXT_HOLD_VDO=11'd3;
        end
        17'b0000001111???????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd4;
                if(((COUNT_COEFF==7'd60&&STREAM[18:17]!=2'b10)
                  ||(COUNT_COEFF>7'd60))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[19];
                NEXT_HOLD_VDO=11'd2;
        end
        17'b0000001001???????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd5;
                if(((COUNT_COEFF==7'd59&&STREAM[18:17]!=2'b10)
                  ||(COUNT_COEFF>7'd59))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[19];
                NEXT_HOLD_VDO=11'd2;
        end
        17'b0000001110???????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd14;
                if(((COUNT_COEFF==7'd50&&STREAM[18:17]!=2'b10)
                  ||(COUNT_COEFF>7'd50))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[19];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b0000001101???????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd15;
                if(((COUNT_COEFF==7'd49&&STREAM[18:17]!=2'b10)
                  ||(COUNT_COEFF>7'd49))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[19];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b0000001000???????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd16;
                if(((COUNT_COEFF==7'd48&&STREAM[18:17]!=2'b10)
                  ||(COUNT_COEFF>7'd48))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[19];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b000000011101?????: begin
                NEXT_VDOSGN=STREAM[17];
                NEXT_VDO=11'd8;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[16:15]!=2'b10)
                        NEXT_FERROR=error; 
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b000000011000?????: begin
                NEXT_VDOSGN=STREAM[17];
                NEXT_VDO=11'd9;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[16:15]!=2'b10)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b000000010011?????: begin
                NEXT_VDOSGN=STREAM[17];
                NEXT_VDO=11'd10;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[16:15]!=2'b10)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b000000010000?????: begin
                NEXT_VDOSGN=STREAM[17];
                NEXT_VDO=11'd11;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[16:15]!=2'b10)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0; 
        end
        17'b000000011011?????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd1;
                if(((COUNT_COEFF==7'd63&&STREAM[16:15]!=2'b10)
                  ||(COUNT_COEFF>7'd63))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[17];
                NEXT_HOLD_VDO=11'd5;
        end
        17'b000000010100?????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd2;
                if(((COUNT_COEFF==7'd62&&STREAM[16:15]!=2'b10)
                  ||(COUNT_COEFF>7'd62))&&STARTVLD)
                        NEXT_FERROR=error;  
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[17];
                NEXT_HOLD_VDO=11'd4;
        end
        17'b000000011100?????: begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd3;
                if(((COUNT_COEFF==7'd61&&STREAM[16:15]!=2'b10)
                  ||(COUNT_COEFF>7'd61))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd60&&STREAM[16:15]!=2'b10)
                  ||(COUNT_COEFF>7'd60))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd58&&STREAM[16:15]!=2'b10)
                  ||(COUNT_COEFF>7'd58))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd57&&STREAM[16:15]!=2'b10)
                  ||(COUNT_COEFF>7'd57))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd56&&STREAM[16:15]!=2'b10)
                  ||(COUNT_COEFF>7'd56))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd47&&STREAM[16:15]!=2'b10)
                  ||(COUNT_COEFF>7'd47))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd46&&STREAM[16:15]!=2'b10)
                  ||(COUNT_COEFF>7'd46))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd45&&STREAM[16:15]!=2'b10)
                  ||(COUNT_COEFF>7'd45))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd44&&STREAM[16:15]!=2'b10)
                  ||(COUNT_COEFF>7'd44))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd43&&STREAM[16:15]!=2'b10)
                  ||(COUNT_COEFF>7'd43))&&STARTVLD)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=STREAM[17];
                NEXT_HOLD_VDO=11'd1;
        end
        17'b0000000011010????: begin
                NEXT_VDOSGN=STREAM[16];
                NEXT_VDO=11'd12;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[15:14]!=2'b10)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0;
        end
        17'b0000000011001????: begin
                NEXT_VDOSGN=STREAM[16];
                NEXT_VDO=11'd13;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[15:14]!=2'b10)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0;
        end
        17'b0000000011000????: begin
                NEXT_VDOSGN=STREAM[16];
                NEXT_VDO=11'd14;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[15:14]!=2'b10)
                        NEXT_FERROR=error;
                else
                        NEXT_FERROR=no_error;
                NEXT_HOLD_SIGN=1'b1; 
                NEXT_HOLD_VDO=11'd0;
        end
        17'b0000000010111????: begin
                NEXT_VDOSGN=STREAM[16];
                NEXT_VDO=11'd15;
                NEXT_RUN=6'd0;
                if(COUNT_COEFF==7'd64&&STREAM[15:14]!=2'b10)
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
                if(((COUNT_COEFF==7'd63&&STREAM[15:14]!=2'b10)
                  ||(COUNT_COEFF>7'd63))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd63&&STREAM[15:14]!=2'b10)
                  ||(COUNT_COEFF>7'd63))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd62&&STREAM[15:14]!=2'b10)
                  ||(COUNT_COEFF>7'd62))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd61&&STREAM[15:14]!=2'b10)
                  ||(COUNT_COEFF>7'd61))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd59&&STREAM[15:14]!=2'b10)
                  ||(COUNT_COEFF>7'd59))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd55&&STREAM[15:14]!=2'b10)
                  ||(COUNT_COEFF>7'd55))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd54&&STREAM[15:14]!=2'b10)
                  ||(COUNT_COEFF>7'd54))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd42&&STREAM[15:14]!=2'b10)
                  ||(COUNT_COEFF>7'd42))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd41&&STREAM[15:14]!=2'b10)
                  ||(COUNT_COEFF>7'd41))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd40&&STREAM[15:14]!=2'b10)
                  ||(COUNT_COEFF>7'd40))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd39&&STREAM[15:14]!=2'b10)
                  ||(COUNT_COEFF>7'd39))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd38&&STREAM[15:14]!=2'b10)
                  ||(COUNT_COEFF>7'd38))&&STARTVLD)
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
                if(COUNT_COEFF==7'd64&&STREAM[14:13]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[14:13]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[14:13]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[14:13]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[14:13]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[14:13]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[14:13]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[14:13]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[14:13]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[14:13]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[14:13]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[14:13]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[14:13]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[14:13]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[14:13]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[14:13]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[13:12]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[13:12]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[13:12]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[13:12]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[13:12]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[13:12]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[13:12]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[13:12]!=2'b10)
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
                if(COUNT_COEFF==7'd64&&STREAM[13:12]!=2'b10)
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
                if(((COUNT_COEFF==7'd63&&STREAM[13:12]!=2'b10)
                  ||(COUNT_COEFF>7'd63))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd63&&STREAM[13:12]!=2'b10)
                  ||(COUNT_COEFF>7'd63))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd63&&STREAM[13:12]!=2'b10)
                  ||(COUNT_COEFF>7'd63))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd63&&STREAM[13:12]!=2'b10)
                  ||(COUNT_COEFF>7'd63))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd63&&STREAM[13:12]!=2'b10)
                  ||(COUNT_COEFF>7'd63))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd63&&STREAM[13:12]!=2'b10)
                  ||(COUNT_COEFF>7'd63))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd63&&STREAM[13:12]!=2'b10)
                  ||(COUNT_COEFF>7'd63))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd63&&STREAM[12:11]!=2'b10)
                  ||(COUNT_COEFF>7'd63))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd63&&STREAM[12:11]!=2'b10)
                  ||(COUNT_COEFF>7'd63))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd63&&STREAM[12:11]!=2'b10)
                  ||(COUNT_COEFF>7'd63))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd63&&STREAM[12:11]!=2'b10)
                  ||(COUNT_COEFF>7'd63))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd58&&STREAM[12:11]!=2'b10)
                  ||(COUNT_COEFF>7'd58))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd53&&STREAM[12:11]!=2'b10)
                  ||(COUNT_COEFF>7'd53))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd52&&STREAM[12:11]!=2'b10)
                  ||(COUNT_COEFF>7'd52))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd51&&STREAM[12:11]!=2'b10)
                  ||(COUNT_COEFF>7'd51))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd50&&STREAM[12:11]!=2'b10)
                  ||(COUNT_COEFF>7'd50))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd49&&STREAM[12:11]!=2'b10)
                  ||(COUNT_COEFF>7'd49))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd48&&STREAM[12:11]!=2'b10)
                  ||(COUNT_COEFF>7'd48))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd37&&STREAM[12:11]!=2'b10)
                  ||(COUNT_COEFF>7'd37))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd36&&STREAM[12:11]!=2'b10)
                  ||(COUNT_COEFF>7'd36))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd35&&STREAM[12:11]!=2'b10)
                  ||(COUNT_COEFF>7'd35))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd34&&STREAM[12:11]!=2'b10)
                  ||(COUNT_COEFF>7'd34))&&STARTVLD)
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
                if(((COUNT_COEFF==7'd33&&STREAM[12:11]!=2'b10)
                  ||(COUNT_COEFF>7'd33))&&STARTVLD)
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


