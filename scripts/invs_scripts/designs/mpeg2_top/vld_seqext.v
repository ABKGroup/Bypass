// ----------------------------------------------
// File: vld_seqext.v
// Module: vld_seqext
// Function: generate sequence_extension 
// ----------------------------------------------

module vld_seqext (
    clkdec,
    rstdec_x,
    g_swrst_r_n,
    y1_bs_wait_n,
    v_interrpt_n, 
    STREAM, 
    KICK,
    ENDDEC, 
    NFERROR, 
    HOLD_PROGRESSIVE_SEQUENCE, 
    SHIFT, 
    PARAA, 
    v_low_delay_r
);

input         clkdec;  
input         rstdec_x;
input         g_swrst_r_n;  
input         y1_bs_wait_n;   // Wait signal
input         v_interrpt_n;   // Break signal
input [31:20] STREAM;         // bit stream
input         KICK;           // start decode
output        ENDDEC;         // end-decode
output        NFERROR;        // non-fatal error
output        HOLD_PROGRESSIVE_SEQUENCE; // porogressive_sequence
output [ 5:0] SHIFT;          // shift data
output [ 7:0] PARAA;          // address
output        v_low_delay_r;  // 1:low_delay, 0:other

reg       ENDDEC;
reg       next_ENDDEC;
reg       NFERROR;
reg       HOLD_PROGRESSIVE_SEQUENCE;
reg       next_hold_progressive_sequence;
reg [5:0] SHIFT;
reg       pre_SHIFT;
reg       next_SHIFT;
reg [7:0] PARAA;
reg       v_low_delay_r;
reg       next_v_low_delay_r;  
reg [3:0] state;
reg       next_state;


parameter   IDLE = 4'b0000,
            profile_and_level_indication = 4'b0001,
            progressive_sequence         = 4'b0010,
            chroma_format                = 4'b0011,
            horizontal_size_extension    = 4'b0100,
            vertical_size_extension      = 4'b0101,
            bit_rate_extension           = 4'b0110,
            vbv_buffer_size_extension    = 4'b0111,
            low_delay                    = 4'b1000,
            frame_rate_extension         = 4'b1001;

parameter   error    = 1'b1,
            no_error = 1'b0;

parameter   no_break = 1'b1;

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        state <= IDLE;
        pre_SHIFT <= 6'h00;
        ENDDEC <= 1'b0;
        HOLD_PROGRESSIVE_SEQUENCE <= 1'b0;
        v_low_delay_r <= 1'b0; 
      end
    else
      if(g_swrst_r_n == 1'b0) 
        begin
          state <= IDLE;
          pre_SHIFT <= 6'h00;
          ENDDEC <= 1'b0;
          HOLD_PROGRESSIVE_SEQUENCE <= 1'b0;
          v_low_delay_r <= 1'b0; 
        end
      else if(y1_bs_wait_n == 1'b1) 
        begin
          state <= next_state;
          pre_SHIFT <= next_SHIFT;
          ENDDEC <= next_ENDDEC;
          HOLD_PROGRESSIVE_SEQUENCE <= next_hold_progressive_sequence;
          v_low_delay_r <= next_v_low_delay_r; 
        end
      else
        begin
          state <= state;
          pre_SHIFT <= pre_SHIFT;
          ENDDEC <= ENDDEC;
          HOLD_PROGRESSIVE_SEQUENCE <= HOLD_PROGRESSIVE_SEQUENCE;
          v_low_delay_r <= v_low_delay_r;
        end
  end

always @(state or v_interrpt_n or KICK)
  begin
    if(v_interrpt_n == no_break) 
      begin
        case(state)
          IDLE : 
            begin
              if(KICK == 1'b1)  
                begin
                  next_state = profile_and_level_indication;
                end
              else
                begin
                  next_state = IDLE;
                end
            end

          profile_and_level_indication : 
            begin
              next_state = progressive_sequence;
            end

          progressive_sequence  : 
            begin
              next_state = chroma_format;
            end

          chroma_format :
            begin
              next_state = horizontal_size_extension;
            end
 
          horizontal_size_extension : 
            begin
              next_state = vertical_size_extension;
            end

          vertical_size_extension  : 
            begin
              next_state = bit_rate_extension;
            end

          bit_rate_extension : 
            begin
              next_state = vbv_buffer_size_extension;
            end

          vbv_buffer_size_extension :
             begin
               next_state = low_delay;
             end
 
          low_delay :
            begin
              next_state = frame_rate_extension;
            end

          frame_rate_extension : 
            begin
              next_state = IDLE;
            end

          default :
            begin
              next_state = IDLE;
            end
        endcase
      end
    else
      begin
        next_state = IDLE;
      end
  end 
  
always @(state or v_interrpt_n or KICK)
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          IDLE :
            begin
              if(KICK == 1'b1) 
                begin
                  next_SHIFT = 6'h01;  
                end
              else
                begin
                  next_SHIFT = 6'h00;
                end
            end

          profile_and_level_indication :
            begin
              next_SHIFT = 6'h02; 
            end
          
          progressive_sequence :
            begin
              next_SHIFT = 6'h02;  
            end

          chroma_format :
            begin
              next_SHIFT = 6'h02;  
            end

          horizontal_size_extension :
            begin
              next_SHIFT = 6'h0C; 
            end

          vertical_size_extension :
            begin
              next_SHIFT = 6'h09;  
            end

          bit_rate_extension :
            begin
              next_SHIFT = 6'h01; 
            end

          vbv_buffer_size_extension :
            begin
              next_SHIFT = 6'h07; 
            end

          default : 
            begin
              next_SHIFT = 6'h00;
            end
        endcase
      end
    else
      begin
        next_SHIFT = 6'h00;
      end
  end

always @(state or v_interrpt_n)
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          low_delay :  
            begin
              next_ENDDEC = 1'b1;  
            end
        
          default :  
            begin
              next_ENDDEC = 1'b0;
            end
        endcase
      end
    else
      begin
        next_ENDDEC = 1'b0;
      end
  end

always @(state or v_interrpt_n or KICK )
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          IDLE :  
            begin
              if(KICK == 1'b1) 
                begin
                  PARAA = 8'h10;   
                end
              else
                begin
                  PARAA = 8'hFF;
                end
            end

          profile_and_level_indication :
            begin
              PARAA = 8'h11;    
            end

          progressive_sequence :
            begin
              PARAA = 8'h12;  
            end

          chroma_format :
            begin
              PARAA = 8'h13;  
            end

          horizontal_size_extension :
            begin
              PARAA = 8'h14;     
            end

          vertical_size_extension :
            begin
              PARAA = 8'h15;   
            end

          bit_rate_extension :
            begin
              PARAA = 8'h16;   
            end

          vbv_buffer_size_extension :
            begin
              PARAA = 8'h17;   
            end

          low_delay :
            begin
              PARAA = 8'h18;    
            end

          default : 
            begin
              PARAA = 8'hFF;
            end
        endcase
      end
    else
      begin
        PARAA = 8'hFF;
      end
  end

always @(state or v_interrpt_n or KICK or STREAM)
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          IDLE :
            begin
              if(KICK == 1'b1 &&        
                 (STREAM[31] == 1'b1 || 
                  (STREAM[30:28] != 3'b101 && STREAM[30:28] != 3'b100) || 
                   (STREAM[27:24] != 4'b1010 && STREAM[27:24] != 4'b1000 && 
                     STREAM[27:24] != 4'b0110 && STREAM[27:24] != 4'b0100)))
                begin
                  NFERROR = error;
                end
              else
                begin
                  NFERROR = no_error;
                end
            end

          progressive_sequence :
            begin
              if(STREAM[31:30] != 2'b01)
                begin
                  NFERROR = error;
                end
              else
                begin
                  NFERROR = no_error;
                end
            end

          chroma_format :
            begin
              if(STREAM[31:30] != 2'b00) 
                begin
                  NFERROR = error;
                end
              else
                begin
                  NFERROR = no_error;
                end
            end

          horizontal_size_extension :
            begin
              if(STREAM[31:30] != 2'b00) 
                begin
                  NFERROR = error;
                end
              else
                begin
                  NFERROR = no_error;
                end
            end

          vertical_size_extension :
            begin
              if(STREAM[31:20] != 12'h000) // bit_rate is not 0
                begin
                  NFERROR = error;
                end
              else
                begin
                  NFERROR = no_error;
                end
            end

          bit_rate_extension :
            begin
              if(STREAM[31] == 1'b0 || STREAM[30:23] != 8'h00) 
                begin
                  NFERROR = error;
                end
              else
                begin
                  NFERROR = no_error;
                end
            end

          low_delay :
            begin
              if(STREAM[31:25] != 7'h00)
                begin
                  NFERROR = error;
                end
              else
                begin
                  NFERROR = no_error;
                end
            end

          default : 
            begin
              NFERROR = no_error;
            end
        endcase
      end
    else
      begin
        NFERROR = no_error;
      end
  end

always @(state or v_interrpt_n or STREAM or HOLD_PROGRESSIVE_SEQUENCE)
  begin
    if(state == profile_and_level_indication && v_interrpt_n == no_break)
      begin            
        next_hold_progressive_sequence = STREAM[31];
      end
    else
      begin
        next_hold_progressive_sequence = HOLD_PROGRESSIVE_SEQUENCE;
      end
  end 

always @(state or v_interrpt_n or STREAM or v_low_delay_r)
  begin
    if(state == vbv_buffer_size_extension && v_interrpt_n == no_break)
      begin
        next_v_low_delay_r = STREAM[31];
      end
    else
      begin
        next_v_low_delay_r = v_low_delay_r;
      end
  end

always @(KICK or pre_SHIFT)
  begin
    case(KICK)  
      1'b1 : SHIFT = 6'h08;
      default : SHIFT = pre_SHIFT;
    endcase
  end

endmodule
                 
