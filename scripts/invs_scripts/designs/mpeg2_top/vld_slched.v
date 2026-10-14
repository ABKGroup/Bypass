// ----------------------------------------------
// File: vld_slched.v
// Module: vld_slched
// Function:generate slice_header
// ----------------------------------------------

module vld_slched (
    clkdec, 
    rstdec_x, 
    g_swrst_r_n,
    y1_bs_wait_n, 
    v_interrpt_n, 
    STREAM, 
    KICK,
    ENDDEC, 
    FERROR, 
    SHIFT, 
    PARAA
);

input         clkdec;         // VLD clock
input         rstdec_x;       // Async reset
input         g_swrst_r_n;    // sync reset
input         y1_bs_wait_n;   // Wait signal
input         v_interrpt_n;   // Break signal
input [31:27] STREAM;         // bit stream 
input         KICK;           // start-decode for slicehead
output        ENDDEC;         // end-decode from slicehead
output        FERROR;         // fatal error
output [5:0]  SHIFT;          // shift data
output [7:0]  PARAA;          // address

reg [2:0] state;
reg       next_state;
reg [5:0] pre_SHIFT;
reg [5:0] SHIFT;
reg       next_SHIFT;
reg [7:0] PARAA;
reg       ENDDEC;
reg       next_ENDDEC;
reg       FERROR;
reg       v_start_dly;
reg       v_wait_dly;
reg       v_start_enable;

parameter IDLE = 3'b000,
          quantiser_scale_code    = 3'b001,
          slice_extension_flag    = 3'b010,
          slice_picture_id        = 3'b011,
          extra_bit_slice         = 3'b100,
          extra_information_slice = 3'b101;

parameter error    = 1'b1,
          no_error = 1'b0;

parameter no_break = 1'b1;

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
            pre_SHIFT <= SHIFT;
            ENDDEC    <= ENDDEC;
          end
      end
  end 

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        v_start_dly <= 1'b0;
        v_wait_dly <= 1'b1;
      end
    else if(g_swrst_r_n == 1'b0) 
      begin
        v_start_dly <= 1'b0;
        v_wait_dly <= 1'b1;
      end
    else if(y1_bs_wait_n == 1'b1) 
      begin
        v_start_dly <= KICK ; 
        v_wait_dly <= y1_bs_wait_n;
      end
    else 
      begin
        v_start_dly <= v_start_dly;
        v_wait_dly <= y1_bs_wait_n;
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        v_start_enable <= 1'b0;
      end
    else if(g_swrst_r_n == 1'b0) 
      begin
        v_start_enable <= 1'b0;
      end
    else if(y1_bs_wait_n == 1'b1)
      begin
        v_start_enable <= 1'b0;
      end
    else if(v_start_dly == 1'b1 && v_wait_dly == 1'b0)
      begin
        v_start_enable <= 1'b1;
      end
    else
      begin
        v_start_enable <= v_start_enable;
      end
  end

always @(state or v_interrpt_n or v_start_dly or STREAM or FERROR or v_start_enable)
  begin
    if(v_interrpt_n == no_break && FERROR == no_error) 
      begin
        case(state)

          IDLE :  
            begin
              if(v_start_dly == 1'b1 ||
                 v_start_enable == 1'b1) 
                begin
                  next_state = quantiser_scale_code;
                end
              else
                begin
                  next_state = IDLE;
                end
            end

          quantiser_scale_code : 
            begin
              if(STREAM[31] == 1'b0)  
                begin
                  next_state = extra_information_slice;
                end
              else                    
                begin
                  next_state = slice_extension_flag;
                end
            end
         
          slice_extension_flag : 
            begin             
              next_state = slice_picture_id;
            end

          slice_picture_id :
            begin
              if(STREAM[31] == 1'b0) 
                begin
                  next_state = extra_information_slice;
                end
              else             
                begin
                  next_state = extra_bit_slice; 
                end
            end

          extra_bit_slice :
            begin
              next_state = slice_picture_id;
            end

          extra_information_slice :
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

always @(state or v_interrpt_n or v_start_dly or STREAM or FERROR)
  begin
    if(v_interrpt_n == no_break && FERROR == no_error)
      begin
        case(state)
          IDLE :
            begin
              if(v_start_dly == 1'b1)   
                begin
                  next_SHIFT = 6'h01;
                end
              else             
                begin
                  next_SHIFT = 6'h00;
                end
            end

          quantiser_scale_code :
            begin
              if(STREAM[31] == 1'b1) 
                begin               
                  next_SHIFT = 6'h08;
                end
              else
                begin
                  next_SHIFT = 6'h00;
                end
            end

          slice_extension_flag :
            begin
              next_SHIFT = 6'h01;
            end

          slice_picture_id : 
            begin
              if(STREAM[31] == 1'b1) 
                begin      
                  next_SHIFT = 6'h08;
                end
              else
                begin
                  next_SHIFT = 6'h00;
                end
            end
 
          extra_bit_slice :
            begin
              next_SHIFT = 6'h01;
            end

          extra_information_slice :
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

always @(state or v_interrpt_n or STREAM or FERROR)
  begin
    if(v_interrpt_n == no_break && FERROR == no_error)
      begin
        case(state)
          quantiser_scale_code :
            begin
              if(STREAM[31] == 1'b0) 
                begin                
                  next_ENDDEC = 1'b1;
                end
              else
                begin
                  next_ENDDEC = 1'b0;
                end
            end

          slice_picture_id :
            begin
              if(STREAM[31] == 1'b0)  
                begin               
                  next_ENDDEC = 1'b1;
                end
              else
                begin
                  next_ENDDEC = 1'b0;
                end
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
   
      
always @(state or v_interrpt_n or v_start_dly or v_start_enable)
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          IDLE :
            begin
              if(v_start_dly == 1'b1 || 
                v_start_enable == 1'b1)   
                begin
                  PARAA = 8'h0d;    
                end
              else
                begin
                  PARAA = 8'hFF;
                end
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

always @(state or v_interrpt_n or v_start_dly or STREAM
         or v_start_enable)
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          IDLE :
            begin
              if((v_start_dly == 1'b1 || v_start_enable == 1'b1)
                  && STREAM[31:27] == 5'h00)
                begin
                  FERROR = error;   
                end
              else
                begin
                  FERROR = no_error;
                end
            end
 
          default :
            begin
              FERROR = no_error;
            end
        endcase
      end
    else
      begin
        FERROR = no_error;
      end
  end
 

always @(v_start_dly or pre_SHIFT or v_interrpt_n) 
  begin
    if(v_interrpt_n == no_break) 
      begin 
        case(v_start_dly)
          1'b1 : SHIFT = 6'h05;     
          default : SHIFT = pre_SHIFT;
        endcase
      end
    else 
      begin
        SHIFT = 6'h00;
      end
  end

endmodule
 
 
