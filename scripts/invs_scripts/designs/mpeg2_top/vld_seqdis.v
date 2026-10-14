// ----------------------------------------------
// File: vld_seqdis.v
// Module: vld_seqdis
// Function: generate sequence_display
// ----------------------------------------------

module vld_seqdis (
    clkdec, 
    rstdec_x,
    g_swrst_r_n, 
    y1_bs_wait_n,
    v_interrpt_n, 
    STREAM, 
    KICK,
    ENDDEC, 
    NFERROR, 
    SHIFT, 
    PARAA
);

 input         clkdec;         // VLD clock
 input         rstdec_x;       // Async reset
 input         g_swrst_r_n;  // Sync reset
 input         y1_bs_wait_n;   // Wait signal
 input         v_interrpt_n;   // Break signal 
 input         STREAM;         // bit stream
 input         KICK;           // start decode for seqdis
 output        ENDDEC;         // end decode from seqdis
 output        NFERROR;        // non-fatal error
 output [ 5:0] SHIFT;          // shift data
 output [ 7:0] PARAA;          // address

 reg [3:0] state;
 reg       next_state; 
 reg       ENDDEC;
 reg       next_ENDDEC;
 reg       NFERROR; 
 reg [5:0] SHIFT;
 reg       pre_SHIFT;
 reg       next_SHIFT;
 reg [7:0] PARAA;

 parameter
   IDLE                     = 4'b0000,
   video_format             = 4'b0001,
   colour_description       = 4'b0010,
   colour_primaries         = 4'b0011,
   transfer_characteristics = 4'b0100,
   matrix_coefficients      = 4'b0101,
   display_horizontal_size  = 4'b0110,
   display_vertical_size    = 4'b0111;

 parameter
   error    = 1'b1,
   no_error = 1'b0;

 parameter
   no_break = 1'b1;

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0)  
      begin
        state     <= IDLE;
        pre_SHIFT <= 6'h00;
        ENDDEC    <= 1'b0;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            state     <= IDLE;
            pre_SHIFT <= 6'h00;
            ENDDEC    <= 1'b0;
          end
        else if(y1_bs_wait_n == 1'b1)
          begin
            state     <= next_state;
            pre_SHIFT <= next_SHIFT;
            ENDDEC    <= next_ENDDEC;
          end
        else                        
          begin
            state     <= state;
            pre_SHIFT <= pre_SHIFT;
            ENDDEC    <= ENDDEC;
          end
      end
  end

always @(state or v_interrpt_n or KICK or STREAM)
  begin
    if(v_interrpt_n == no_break) 
      begin
        case(state)
          IDLE :       
            begin
              if(KICK == 1'b1) // start decode
                begin 
                  next_state = video_format;
                end
              else
                begin
                  next_state = IDLE;
                end
            end

          video_format :
            begin
              if(STREAM == 1'b0)  
                begin                 
                  next_state = matrix_coefficients;
                end
              else
                begin
                  next_state = colour_description;
                end
            end

          colour_description : 
            begin
              next_state = colour_primaries;
            end

          colour_primaries : 
            begin
              next_state = transfer_characteristics;
            end
 
          transfer_characteristics : 
            begin
              next_state = matrix_coefficients;
            end

          matrix_coefficients : 
            begin
              next_state = display_horizontal_size;
            end
 
          display_horizontal_size : 
            begin
              next_state = display_vertical_size;
            end
          
          display_vertical_size :
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

always @(state or v_interrpt_n or KICK or STREAM)
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

          video_format :
            begin
              if(STREAM == 1'b0)
                begin
                  next_SHIFT = 6'h0E; 
                end
              else
                begin
                  next_SHIFT = 6'h08; 
                end
            end

          colour_description :
            begin
              next_SHIFT = 6'h08; 
            end
 
          colour_primaries :
            begin
              next_SHIFT = 6'h08; 
            end

          transfer_characteristics :
            begin
              next_SHIFT = 6'h0E; 
            end

          matrix_coefficients :
            begin
              next_SHIFT = 6'h0F;
            end

          display_horizontal_size :
            begin
              next_SHIFT = 6'h00; 
            end

          display_vertical_size :
            begin
              next_SHIFT = 6'h00; 
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
          display_horizontal_size : 
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

always @(state or v_interrpt_n or KICK)
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          IDLE :
            begin
              if(KICK == 1'b1) 
                begin
                  PARAA = 8'h19;  
                end
              else
                begin
                  PARAA = 8'hFF;
                end
            end

          video_format :
            begin
              PARAA = 8'h1A;  
            end
 
          colour_description :
            begin
              PARAA = 8'h1B; 
            end

          colour_primaries :
            begin
              PARAA = 8'h1C;  
            end
 
          transfer_characteristics :
            begin
              PARAA = 8'h1D;  
            end

          matrix_coefficients :
            begin
              PARAA = 8'h1E;  
            end

          display_horizontal_size :
            begin
              PARAA = 8'h1F; 
            end

          display_vertical_size :
            begin
              PARAA = 8'hFF;  
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

always @(state or v_interrpt_n or STREAM)
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          display_horizontal_size :
            begin
              if(STREAM == 1'b0)  
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

always @(KICK or pre_SHIFT)
  begin
    case(KICK)   
      1'b1 : SHIFT = 6'h03; 
      default : SHIFT = pre_SHIFT;
    endcase
  end

endmodule  

