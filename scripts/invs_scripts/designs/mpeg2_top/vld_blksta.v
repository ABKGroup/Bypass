// ----------------------------------------------
// File: vld_blksta.v
// Module: vld_blksta
// Function:generate block state
// ----------------------------------------------

module vld_blksta(
    clkdec, 
    rstdec_x, 
    g_swrst_r_n, 
    y1_bs_wait_n, 
    v_interrpt_n, 
    v_blkstart_r,
    MACROBLOCK_INTRA, 
    INTRA_VLC_FORMAT, 
    MPEG1,
    FERROR, 
    CBP, 
    RUN, 
    STREAM, 
    PIC_CODE_TYPE,
    ENDBLK, 
    BLOCK_COUNT, 
    COUNT_COEFF, 
    STATE, 
    NEXT_STATE,
    vdoenb_r, 
    v_enderror
);

input clkdec;         // VLD clock
input rstdec_x;       // Async reset
input g_swrst_r_n;      // Sync reset
input y1_bs_wait_n;       // Wait signal
input v_interrpt_n;     // Break signal 
input v_blkstart_r;     // start decode
input MACROBLOCK_INTRA;   // macroblock_intra
input INTRA_VLC_FORMAT;   // intra_vlc_format
input MPEG1;              // 0:MPEG1 1:MPEG2
input FERROR;             // fatal error
input [5:0] CBP;          // coded block pattern
input [5:0] RUN;          // run number
input [31:28] STREAM;      // bit stream(30bit)
input [2:0] PIC_CODE_TYPE; // picture_code_type
input v_enderror;       // end-of-macroblock error

output ENDBLK;            // end-decode
output [2:0] BLOCK_COUNT; // block_count(1-6) 
output [6:0] COUNT_COEFF; // count(1-64)
output [3:0] STATE;       // now state
output [3:0] NEXT_STATE;  // next state
output vdoenb_r;            // vdo enable

reg ENDBLK, 
    next_ENDBLK;
reg [2:0] BLOCK_COUNT;      // counting block until 6
reg [3:0] STATE,            // STATE:hold current STATE, 
          NEXT_STATE;       // NEXT_STATE:Result of combination logic.
reg [6:0] COUNT_COEFF;      // count number of coefficients
reg blkstart_r;
reg vdoenb_r;
reg v_endblk;
reg l_ENDBLK;


parameter  IDLE=4'b0000,
           B14=4'b0001, 
           B15=4'b0010, 
           INTRa_DC=4'b0011, 
           null_op=4'b0100,  
           end_of_macroblock=4'b0101;

parameter  MPEG_1 = 1'b1;
parameter  d_picture = 3'b100;
parameter  no_break = 1'b1;
parameter  no_error = 1'b0;

always @(posedge clkdec or negedge rstdec_x)
  begin 
    if(rstdec_x == 1'b0) 
      begin
        STATE       <= IDLE; 
      end
    else 
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            STATE       <= IDLE;
          end
        else if(y1_bs_wait_n == 1'b1)
          begin
            STATE       <= NEXT_STATE;
          end
        else 
          begin
            STATE       <= STATE;
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin 
    if (rstdec_x == 1'b0) 
      begin
        v_endblk <= 1'b0;
        l_ENDBLK <= 1'b0;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0)
          begin
            v_endblk <= 1'b0;
            l_ENDBLK <= 1'b0;
          end
        else if(y1_bs_wait_n == 1'b0)
          begin
            v_endblk <= v_endblk;
            l_ENDBLK <= l_ENDBLK;
          end
        else if(FERROR == no_error && v_enderror == no_error) 
          begin
            v_endblk <= next_ENDBLK;
            l_ENDBLK <= v_endblk;
          end
        else
          begin
            v_endblk <= 1'b0;
            l_ENDBLK <= 1'b0;
          end
      end
  end

always @(l_ENDBLK or v_enderror or FERROR) 
  begin
    if(v_enderror == 1'b1 || FERROR == 1'b1)
      ENDBLK = 1'b0;
    else
      ENDBLK = l_ENDBLK;
  end

always @(BLOCK_COUNT or COUNT_COEFF or PIC_CODE_TYPE or MPEG1 )
  begin
    if(PIC_CODE_TYPE == d_picture && MPEG1 == MPEG_1) 
      begin
        if(BLOCK_COUNT == 3'd7 && COUNT_COEFF == 7'd1) 
          begin
            next_ENDBLK = 1'b1;
          end
        else        
          begin
            next_ENDBLK = 1'b0;
          end
      end
    else
      begin
        if(BLOCK_COUNT == 3'd6 && COUNT_COEFF == 7'd63) 
          begin
            next_ENDBLK = 1'b1;
          end
        else
          begin
            next_ENDBLK = 1'b0;
          end
      end
  end  

always @(STATE or blkstart_r  or v_interrpt_n or MACROBLOCK_INTRA or
         INTRA_VLC_FORMAT or COUNT_COEFF or BLOCK_COUNT or PIC_CODE_TYPE
         or FERROR or v_enderror or MPEG1 or CBP or RUN or STREAM)
  begin
    if(v_interrpt_n == no_break && FERROR == no_error
        && v_enderror == no_error)
      begin 
        case(STATE) 
          IDLE:  
            begin
              if(blkstart_r == 1'b1)  
                begin
                  if(MACROBLOCK_INTRA)       
                    begin                     
                      NEXT_STATE = INTRa_DC;   
                    end
                  else
                    begin
                      case(BLOCK_COUNT) 
                        3'd1:if(CBP[5]==1'b1)     
                               begin  
                                 NEXT_STATE = B14;   
                               end
                             else
                               begin    
                                 NEXT_STATE = null_op; 
                               end
                        3'd2:if(CBP[4]==1'b1)  
                               begin
                                 NEXT_STATE = B14;
                               end
                             else
                               begin    
                                 NEXT_STATE = null_op;
                               end
                        3'd3:if(CBP[3]==1'b1)
                               begin  
                                 NEXT_STATE = B14;
                               end
                             else
                               begin    
                                 NEXT_STATE = null_op;
                               end
                        3'd4:if(CBP[2]==1'b1)
                               begin  
                                 NEXT_STATE = B14;
                               end
                             else
                               begin    
                                 NEXT_STATE = null_op;
                               end
                        3'd5:if(CBP[1]==1'b1)
                               begin  
                                 NEXT_STATE = B14;
                               end
                             else  
                               begin  
                                 NEXT_STATE = null_op;
                               end
                        3'd6:if(CBP[0]==1'b1)      
                               begin  
                                 NEXT_STATE = B14;
                               end
                             else
                               begin    
                                 NEXT_STATE = null_op;
                               end
                       default:
                          begin
                            NEXT_STATE = null_op;
                          end
                      endcase
                    end
                end
              else                    
                begin
                  NEXT_STATE = STATE;
                end
            end

          B14:   
            begin
              if(COUNT_COEFF == 7'd1)
                begin 
                  if(BLOCK_COUNT == 3'd7) 
                    begin
                      NEXT_STATE = IDLE;
                    end
                  else
                    begin
                      if(MACROBLOCK_INTRA)        
                        begin
                          NEXT_STATE = INTRa_DC; 
                        end  
                      else                      
                        begin
                          case(BLOCK_COUNT) 
                            3'd1:if(CBP[5]==1'b1)     
                                   begin
                                     NEXT_STATE = B14;
                                   end
                                 else            
                                   begin  
                                     NEXT_STATE = null_op;
                                   end
                            3'd2:if(CBP[4]==1'b1)  
                                   begin
                                     NEXT_STATE = B14;
                                   end
                                 else    
                                   begin
                                     NEXT_STATE = null_op;
                                   end
                            3'd3:if(CBP[3]==1'b1)  
                                   begin
                                     NEXT_STATE = B14;
                                   end
                                 else    
                                   begin
                                     NEXT_STATE = null_op;
                                   end
                            3'd4:if(CBP[2]==1'b1)  
                                   begin
                                     NEXT_STATE = B14;
                                   end
                                 else    
                                   begin
                                     NEXT_STATE = null_op;
                                   end
                            3'd5:if(CBP[1]==1'b1)  
                                   begin
                                     NEXT_STATE = B14;
                                   end
                                 else    
                                   begin
                                     NEXT_STATE = null_op;
                                   end
                            3'd6:if(CBP[0]==1'b1)  
                                   begin
                                     NEXT_STATE = B14;
                                   end
                                 else    
                                   begin
                                     NEXT_STATE = null_op;
                                 end
                            default:  
                               begin
                                 NEXT_STATE = null_op;
                               end
                          endcase
                        end
                    end
                end
              else if( COUNT_COEFF <= 7'd64 &&     
                 STREAM[31:30] == 2'b10 && RUN == 5'd0)
                begin
                  NEXT_STATE = null_op;    
                end
              else
                begin
                  NEXT_STATE = STATE;
                end
            end

          B15:
            begin
              if(COUNT_COEFF == 6'd1)
                begin
                  if(BLOCK_COUNT == 3'd7) 
                    begin
                      NEXT_STATE = IDLE;
                    end
                  else  
                    begin
                      if(MACROBLOCK_INTRA)      
                        begin 
                          NEXT_STATE = INTRa_DC;
                        end
                      else                             
                        begin
                          case(BLOCK_COUNT)   
                            3'd1:if(CBP[5]==1'b1)       
                                   begin  
                                     NEXT_STATE = B14;
                                   end
                                 else               
                                   begin
                                     NEXT_STATE = null_op;
                                   end
                            3'd2:if(CBP[4]==1'b1)  
                                   begin
                                     NEXT_STATE = B14;
                                   end
                                 else    
                                   begin
                                     NEXT_STATE = null_op;
                                   end
                            3'd3:if(CBP[3]==1'b1)  
                                   begin
                                     NEXT_STATE = B14;
                                   end
                                 else    
                                   begin
                                     NEXT_STATE = null_op;
                                   end
                            3'd4:if(CBP[2]==1'b1)  
                                   begin
                                     NEXT_STATE = B14;
                                    end
                                  else    
                                    begin
                                      NEXT_STATE = null_op;
                                    end
                            3'd5:if(CBP[1]==1'b1)  
                                   begin
                                     NEXT_STATE = B14;
                                   end
                                 else    
                                   begin
                                     NEXT_STATE = null_op;
                                   end
                            3'd6:if(CBP[0]==1'b1)  
                                   begin
                                     NEXT_STATE = B14;
                                   end
                                 else    
                                   begin
                                     NEXT_STATE = null_op;
                                   end
                            default:  
                              begin
                                NEXT_STATE = null_op;
                              end
                          endcase
                      end
                    end
                end
              else if(COUNT_COEFF <= 7'd64 && STREAM[31:28]== 4'b0110 
                       && RUN == 6'd0)        
                begin
                  NEXT_STATE = null_op;       
                end
              else
                begin
                  NEXT_STATE = STATE;
                end
            end

          INTRa_DC: 
            begin
              if(PIC_CODE_TYPE == d_picture && MPEG1 == MPEG_1) 
                begin
                  NEXT_STATE = null_op; 
                end
              else if(INTRA_VLC_FORMAT == 1'b1)    
                begin
                  if(MPEG1 ==  MPEG_1)    
                    begin
                      NEXT_STATE = B14;
                    end
                  else          
                    begin
                      NEXT_STATE = B15;
                    end
                end
              else         
                begin
                  NEXT_STATE = B14;
                end
            end

          null_op:
            begin
              if(COUNT_COEFF == 7'd1 && BLOCK_COUNT == 3'd7 && 
                   PIC_CODE_TYPE == d_picture && MPEG1 == MPEG_1)
                begin
                  NEXT_STATE = end_of_macroblock;
                end
              
             else if(COUNT_COEFF == 7'd1)
                begin
                  if(BLOCK_COUNT == 3'd7)  
                    begin
                      NEXT_STATE = IDLE;
                    end
                  else
                    begin
                      if(MACROBLOCK_INTRA)    
                        begin 
                          NEXT_STATE = INTRa_DC;
                        end
                      else                        
                        begin
                          case(BLOCK_COUNT) 
                            3'd1:if(CBP[5]==1'b1)
                                   begin  
                                     NEXT_STATE = B14;
                                   end
                                 else    
                                   begin
                                     NEXT_STATE = null_op;
                                   end
                            3'd2:if(CBP[4]==1'b1)  
                                   begin
                                     NEXT_STATE = B14;
                                   end
                                 else    
                                   begin
                                     NEXT_STATE = null_op;
                                   end
                            3'd3:if(CBP[3]==1'b1)
                                   begin  
                                     NEXT_STATE = B14;
                                   end
                                 else    
                                   begin
                                     NEXT_STATE = null_op;
                                   end
                            3'd4:if(CBP[2]==1'b1)  
                                   begin
                                     NEXT_STATE = B14;
                                   end
                                 else    
                                   begin
                                     NEXT_STATE = null_op;
                                   end
                            3'd5:if(CBP[1]==1'b1)  
                                   begin
                                     NEXT_STATE = B14;
                                   end
                                 else    
                                   begin
                                     NEXT_STATE = null_op;
                                   end
                            3'd6:if(CBP[0]==1'b1)  
                                   begin
                                     NEXT_STATE = B14;
                                   end
                                 else    
                                   begin
                                     NEXT_STATE = null_op;
                                   end
                            default:  
                              begin
                                NEXT_STATE = null_op;
                              end
                          endcase
                        end
                    end
                end
              else 
                begin
                  NEXT_STATE = STATE;
                end
            end

          end_of_macroblock :
            begin
              NEXT_STATE = IDLE;
            end

          default:
            begin
              NEXT_STATE = IDLE;
            end
        endcase
      end
    else
      begin
        NEXT_STATE = IDLE;
      end
  end   

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0)
      begin
        COUNT_COEFF <= 7'd0;
      end
    else
      if(g_swrst_r_n == 1'b0)
        begin
          COUNT_COEFF <= 7'd0;
        end
      else
        begin
          if(y1_bs_wait_n == 1'b0) 
            begin
              COUNT_COEFF <= COUNT_COEFF;
            end
          else if(v_interrpt_n == no_break && FERROR == no_error
              && v_enderror == no_error) 
                begin
                  if(v_blkstart_r == 1'b1) 
                    begin
                      COUNT_COEFF <= 7'd1;
                    end
                  else
                    begin
                      if(COUNT_COEFF == 7'd64)
                        begin
                          COUNT_COEFF <= 7'd1;
                        end
                      else if(COUNT_COEFF == 7'd1 && BLOCK_COUNT == 3'd7)
                        begin
                          COUNT_COEFF <= 7'd0;
                        end
                      else if(COUNT_COEFF > 7'd0)
                        begin
                          COUNT_COEFF <= COUNT_COEFF + 1;
                        end
                      else
                        begin
                          COUNT_COEFF <= COUNT_COEFF;
                        end
                    end
                end
          else
            begin
              COUNT_COEFF <= 7'd0;
            end
       end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        BLOCK_COUNT <= 3'd0;
      end
    else
      if(g_swrst_r_n == 1'b0) 
        begin
          BLOCK_COUNT <= 3'd0;
        end
      else if(y1_bs_wait_n == 1'b0)
        begin
          BLOCK_COUNT <= BLOCK_COUNT;
        end
      else
        begin
          if(v_interrpt_n == no_break && FERROR == no_error
               && v_enderror == no_error) 
            begin
              if(v_blkstart_r == 1'b1) 
                begin 
                  BLOCK_COUNT <= 3'd1;
                end
              else if(COUNT_COEFF == 7'd1 && BLOCK_COUNT == 3'd7)
                begin
                  BLOCK_COUNT <= 3'd0;
                end
              else if(COUNT_COEFF == 7'd64)
                begin
                  BLOCK_COUNT <= BLOCK_COUNT + 1;
                end
              else
                begin
                  BLOCK_COUNT <= BLOCK_COUNT;
                end
            end
          else
            begin
              BLOCK_COUNT <= 3'd0;
            end
        end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        vdoenb_r <= 1'b0;
      end
    else if(g_swrst_r_n == 1'b0) 
      begin
        vdoenb_r <= 1'b0;
      end
    else if(y1_bs_wait_n == 1'b0)
      begin
        vdoenb_r <= vdoenb_r;
      end
    else if(FERROR == 1'b1 || v_interrpt_n == 1'b0) 
      begin
        vdoenb_r <= 1'b0;
      end
    else if(v_blkstart_r == 1'b1) 
      begin
        vdoenb_r <= 1'b1;
      end
    else if(BLOCK_COUNT == 3'd6 && COUNT_COEFF == 7'd64)
      begin
        vdoenb_r <= 1'b0;
      end
    else
      begin
        vdoenb_r <= vdoenb_r;
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        blkstart_r <= 1'b0;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            blkstart_r <= 1'b0;
          end 
        else if(y1_bs_wait_n == 1'b0) 
          begin
            blkstart_r <= blkstart_r;
          end
        else if(v_interrpt_n == 1'b0) 
          begin
            blkstart_r <= 1'b0;
          end
        else
          begin
            blkstart_r <= v_blkstart_r;
          end
      end
  end

endmodule


