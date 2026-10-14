// ----------------------------------------------
// File: vld_gophed.v
// Module: vld_gophed
// Function: generate gop header
// ----------------------------------------------

module vld_gophed(
    clkdec, 
    rstdec_x, 
    g_swrst_r_n, 
    y1_bs_wait_n,
    v_interrpt_n, 
    KICK, 
    STREAM, 
    ENDDEC, 
    NFERROR, 
    SHIFT, 
    PARAA
);

input         clkdec;          // VLD clock
input         rstdec_x;        // Async reset
input         g_swrst_r_n;       // Sync reset
input         y1_bs_wait_n;        // Wait signal
input         v_interrpt_n;      // Break signal
input         KICK;                // start decode
input        STREAM;              // bit stream (25bit)
output       ENDDEC;                 // end-decode
output       NFERROR;                // non-fatal error
output [5:0] SHIFT;                  // shift data
output [7:0] PARAA;                  // address

reg       ENDDEC;
reg       next_ENDDEC;
reg       NFERROR;
reg [5:0] SHIFT;
reg       pre_SHIFT;
reg       next_SHIFT;
reg [7:0] PARAA;
reg [1:0] state;
reg       next_state;
    
parameter   IDLE                   = 2'b00,
            time_code              = 2'b01,
            closed_gop_broken_link = 2'b10;

parameter   error    = 1'b1,
            no_error = 1'b0;

parameter   no_break = 1'b1;

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        state                      <= IDLE;
        pre_SHIFT                  <= 6'h00;
        ENDDEC                     <= 1'b0;
      end
    else
      if(g_swrst_r_n == 1'b0) 
        begin
          state <= IDLE;
          pre_SHIFT                  <= 6'h00;
          ENDDEC                     <= 1'b0;
        end
      else if(y1_bs_wait_n == 1'b1)
        begin
          state <= next_state;
          pre_SHIFT                  <= next_SHIFT;
          ENDDEC                     <= next_ENDDEC;
        end
      else     
        begin
          state                      <= state;
          pre_SHIFT                  <= pre_SHIFT;
          ENDDEC                     <= ENDDEC;
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
                  next_state = time_code;
                end
              else
                begin
                  next_state = IDLE;
                end
            end

          time_code : 
            begin
              next_state = closed_gop_broken_link;
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
    if(v_interrpt_n == no_break ) 
      begin
        case(state)
          IDLE :
            begin
              if(KICK == 1'b1) 
                begin
                  next_SHIFT = 6'h02; 
                end
              else
                begin
                  next_SHIFT = 6'h00;
                end
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
          time_code : 
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
                  PARAA = 8'h08; 
                end
              else 
                begin
                  PARAA = 8'hFF;
                end
            end
 
           time_code :
             begin
               PARAA = 8'h09;
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
              if(KICK == 1'b1 &&  STREAM == 1'b0 )     
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
      1'b1 : SHIFT = 6'h19;  
      default : SHIFT = pre_SHIFT;
    endcase
  end

endmodule


