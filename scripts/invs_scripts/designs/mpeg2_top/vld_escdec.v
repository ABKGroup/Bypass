// ----------------------------------------------
// File: vld_escdec.v
// Module: vld_escdec
// Function:generate block data
// ----------------------------------------------

module vld_escdec (
    STREAM, 
    MPEG, 
    NEXT_STATE, 
    COUNT_COEFF,
    NEXT_VDOSGN, 
    NEXT_VDO, 
    NEXT_RUN, 
    NEXT_FERROR, 
    NEXT_HOLD_SIGN,
    NEXT_HOLD_VDO, 
    RUN, 
    NEXT_NFERROR
);

output [10:0] NEXT_VDO, NEXT_HOLD_VDO;
output [5:0] NEXT_RUN;
output NEXT_VDOSGN, NEXT_FERROR, NEXT_HOLD_SIGN;
output NEXT_NFERROR;

input MPEG;
input [29:0] STREAM;
input [6:0] COUNT_COEFF;
input [5:0] RUN;
input [3:0] NEXT_STATE;

reg [10:0] NEXT_VDO, NEXT_HOLD_VDO;
reg [5:0] NEXT_RUN;
reg NEXT_VDOSGN, NEXT_FERROR, NEXT_HOLD_SIGN;
reg NEXT_NFERROR;

parameter   B14=4'b0001,
            B15=4'b0010;

parameter   MPEG_2 = 1'b0;

parameter   error = 1'b1,
            no_error = 1'b0;

parameter   hold_vdo = 11'd0;
parameter   hold_sign = 1'b1;

always @(NEXT_STATE or STREAM or MPEG
         or COUNT_COEFF or RUN)

    case (NEXT_STATE) 

      B14: begin
             if(RUN==6'h00) begin
               if (STREAM[29:24]==6'b000001) begin // Escape
                 if(MPEG==MPEG_2) begin
                   if(STREAM[23:18]==6'h00) begin
                        NEXT_VDOSGN=STREAM[17];
                        if(STREAM[17]==1'b1)
                                NEXT_VDO=(~STREAM[16:6]+1);
                        else
                                NEXT_VDO=STREAM[16:6];
                        NEXT_RUN=6'd0;
                        if(COUNT_COEFF==7'd64&&STREAM[5:4]!=2'b10)
                                NEXT_FERROR=error;
                        else
                                NEXT_FERROR=no_error;
                        NEXT_HOLD_SIGN=hold_sign;
                        NEXT_HOLD_VDO=hold_vdo;
                   end
                   else begin // RUN!=0
                        NEXT_VDOSGN=1'b0;
                        NEXT_VDO=11'h00;
                        NEXT_RUN=STREAM[23:18];
                        if((COUNT_COEFF+STREAM[23:18]==7'd64&&STREAM[5:4]!=2'b10)
                          ||(COUNT_COEFF+STREAM[23:18]>7'd64))
                                NEXT_FERROR=error;
                        else
                                NEXT_FERROR=no_error;
                        if(STREAM[17]==1'b1)
                                NEXT_HOLD_VDO=(~STREAM[16:6]+1);
                        else
                                NEXT_HOLD_VDO=STREAM[16:6];
                        NEXT_HOLD_SIGN=STREAM[17];
                   end
                 if(STREAM[17:6] == 12'h800 || STREAM[17:6] == 12'h000)
                   begin                   
                     NEXT_NFERROR = error;
                   end
                 else
                   begin
                     NEXT_NFERROR = no_error;
                   end 
               end
             else begin // for MPEG1
               if(STREAM[23:18]==6'h00) begin // RUN == 0
                  NEXT_VDOSGN=STREAM[17];
                        if(STREAM[17]==1'b1)
                          if(STREAM[13:10]==4'h0)
                                NEXT_VDO=~({3'h7,STREAM[9:2]})+1;
                          else
                                NEXT_VDO=~({3'h7,STREAM[17:10]})+1;
                        else
                          if(STREAM[13:10]==4'h0)
                                NEXT_VDO={3'h0,STREAM[9:2]};
                          else
                                NEXT_VDO={3'h0,STREAM[17:10]};
                        NEXT_RUN=6'd0;
                        if((COUNT_COEFF==7'd64&&STREAM[1:0]!=2'b10)
                ||(STREAM[17:9] == 9'h000 && STREAM[8:2] != 7'h00)
                    || (STREAM[17:9] == 9'h101 && STREAM[8:2] != 7'h00))
                                NEXT_FERROR=error;
                        else
                                NEXT_FERROR=no_error;
                        NEXT_HOLD_SIGN=hold_sign;
                        NEXT_HOLD_VDO=hold_vdo;
                end
                else begin // RUN!=0
                        NEXT_VDOSGN=1'b0;
                        NEXT_VDO=11'h00;
                        NEXT_RUN=STREAM[23:18];
                        if(STREAM[16:10]==7'h00) // level(-256)-(-128),128-256
                          if((COUNT_COEFF+STREAM[23:18]==7'd64&&STREAM[1:0]!=2'b10)
                            ||(COUNT_COEFF+STREAM[23:18]>7'd64)
                ||(STREAM[17:9] == 9'h000 && STREAM[8:2] != 7'h00)
                    || (STREAM[17:9] == 9'h101 && STREAM[8:2] != 7'h00))
 
                                NEXT_FERROR=error;
                          else
                                NEXT_FERROR=no_error;
                        else // level (-127)-127
                          if((COUNT_COEFF+STREAM[23:18]==7'd64&&STREAM[9:8]!=2'b10)
                            ||(COUNT_COEFF+STREAM[23:18]>7'd64)
                ||(STREAM[17:9] == 9'h000 && STREAM[8:2] != 7'h00)
                    || (STREAM[17:9] == 9'h101 && STREAM[8:2] != 7'h00))
 
                                NEXT_FERROR=error;
                          else
                                NEXT_FERROR=no_error;
                        if(STREAM[17]==1'b1)
                          if(STREAM[16:10]==4'h0)
                                NEXT_HOLD_VDO=~({3'h7,STREAM[9:2]})+1;
                          else
                                NEXT_HOLD_VDO=~({3'h7,STREAM[17:10]})+1;
                        else
                          if(STREAM[16:10]==4'h0)
                                NEXT_HOLD_VDO={3'h0,STREAM[9:2]};
                          else
                                NEXT_HOLD_VDO={3'h0,STREAM[17:10]};
                        NEXT_HOLD_SIGN=STREAM[17];
                end
                if(STREAM[17:2] == 16'h8000 || STREAM[17:2] == 16'h0000)
                  begin 
                    NEXT_NFERROR = error;
                  end
                else
                  begin
                    NEXT_NFERROR = no_error;
                  end
          end
        end
        else begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd0;
                NEXT_FERROR=no_error;
                NEXT_NFERROR= no_error;
                NEXT_HOLD_SIGN=1'b0;
                NEXT_HOLD_VDO=11'd0;
        end
  end
  else begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd0;
                NEXT_FERROR=no_error;
                NEXT_NFERROR= no_error;
                NEXT_HOLD_SIGN=1'b0;
                NEXT_HOLD_VDO=11'd0;
  end
 end

 B15: begin
  if(RUN==6'h00) begin
        if(STREAM[29:24]==6'b000001) begin // Escape
                if(STREAM[23:18]==6'h00) begin
                        NEXT_VDOSGN=STREAM[17];
                        if(STREAM[17]==1'b1)
                                NEXT_VDO=(~STREAM[16:6]+1);
                        else
                                NEXT_VDO=STREAM[16:6];
                        NEXT_RUN=6'd0;
                        if(COUNT_COEFF==7'd64&&STREAM[5:2]!=4'b0110)
                                NEXT_FERROR=error;
                        else
                                NEXT_FERROR=no_error;
                        NEXT_HOLD_SIGN=hold_sign;
                        NEXT_HOLD_VDO=hold_vdo;
                end
                else begin // RUN!=0
                        NEXT_VDOSGN=1'b0;
                        NEXT_VDO=11'h00;
                        NEXT_RUN=STREAM[23:18];
                        if((COUNT_COEFF+STREAM[23:18]==7'd64&&STREAM[5:2]!=4'b0110)
                          ||(COUNT_COEFF+STREAM[23:18]>7'd64))
                                NEXT_FERROR=error;
                        else
                                NEXT_FERROR=no_error;
                        if(STREAM[17]==1'b1)
                                NEXT_HOLD_VDO=(~STREAM[16:6]+1);
                        else
                                NEXT_HOLD_VDO=STREAM[16:6];
                        NEXT_HOLD_SIGN=STREAM[17];
                end
                if(STREAM[17:6] == 12'h800 || STREAM[17:6] == 12'h000)
                  begin                     // forbidden or reserved
                    NEXT_NFERROR = error;
                  end
                else
                  begin
                    NEXT_NFERROR = no_error;
                  end
        end
        else begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd0;
                NEXT_FERROR=no_error;
                NEXT_NFERROR= no_error;
                NEXT_HOLD_SIGN=1'b0;
                NEXT_HOLD_VDO=11'd0;
        end
  end
  else begin
                NEXT_VDOSGN=1'b0;
                NEXT_VDO=11'd0;
                NEXT_RUN=6'd0;
                NEXT_FERROR=no_error;
                NEXT_NFERROR= no_error;
                NEXT_HOLD_SIGN=1'b0;
                NEXT_HOLD_VDO=11'd0;
  end
 end

 default: begin
        NEXT_VDOSGN=1'b0;
        NEXT_VDO=11'd0;
        NEXT_RUN=6'd0;
        NEXT_FERROR=no_error;
        NEXT_NFERROR= no_error;
        NEXT_HOLD_SIGN=1'b0;
        NEXT_HOLD_VDO=11'd0;
 end
endcase

endmodule

