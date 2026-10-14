// ----------------------------------------------
// File: vld_picdis.v
// Module: vld_picdis
// Function:generate picture_display 
// ----------------------------------------------

module vld_picdis(
    clkdec, 
    rstdec_x, 
    g_swrst_r_n,
    y1_bs_wait_n,
    v_interrpt_n, 
    KICK, 
    STREAM, 
    PICTURE_STRUCTURE_CODE,
    PROGRESSIVE_SEQUENCE, 
    REPEAT_FIRST_FIELD, 
    v_topfldfst_r,
    ENDDEC, 
    NFERROR, 
    SHIFT, 
    PARAA, 
    PARAD
);
input         clkdec;        
input         rstdec_x;      
input         g_swrst_r_n;   
input         y1_bs_wait_n;            // Wait signal
input         v_interrpt_n;            // Break signal
input         KICK;                    // start decode
input         STREAM;                  // bit stream
input [1:0]   PICTURE_STRUCTURE_CODE;  // picture_structure
input         PROGRESSIVE_SEQUENCE;    // progressive_sequence
input         REPEAT_FIRST_FIELD;      // repeat first_field
input         v_topfldfst_r;           // top_field_first

output       ENDDEC;  // end-decode
output       NFERROR; // non-fatal error
output [5:0] SHIFT;   // shift data
output [7:0] PARAA;   // address
output [1:0] PARAD;   // parameter data(number_of_frame_centre_offset)

reg       ENDDEC;     
reg       next_ENDDEC;
reg       NFERROR;    
reg [5:0] SHIFT;  
reg       pre_SHIFT;
reg       next_SHIFT;
reg [7:0] PARAA;  
reg [1:0] PARAD;  
reg [1:0] number_of_frame_centre_offset;
reg       pre_number_of_frame_centre_offset;
reg       next_number_of_frame_centre_offset;
reg [1:0] loop_count;
reg       next_loop_count;
reg [2:0] state;
reg       next_state;
wire [2:0] loop_count_wire;  

parameter   IDLE = 3'b000,
            frame_centre_horizontal_offset = 3'b001,
            frame_centre_vertical_offset = 3'b010;

parameter   error    = 1'b1,
            no_error = 1'b0;

parameter   no_break = 1'b1;

always @(PROGRESSIVE_SEQUENCE or REPEAT_FIRST_FIELD or 
        v_topfldfst_r  or PICTURE_STRUCTURE_CODE)
  begin
    if(PROGRESSIVE_SEQUENCE == 1'b1)
      begin
        if(REPEAT_FIRST_FIELD == 1'b1)
          begin
            if(v_topfldfst_r == 1'b1)
              begin
                pre_number_of_frame_centre_offset = 2'b11;
              end
            else
              begin
                pre_number_of_frame_centre_offset = 2'b10;
              end
          end
        else
          begin
            pre_number_of_frame_centre_offset = 2'b01;
          end
      end
    else
      begin
        if(PICTURE_STRUCTURE_CODE == 2'b10 || PICTURE_STRUCTURE_CODE == 2'b01)
          begin
            pre_number_of_frame_centre_offset = 2'b01;
          end
        else
          begin
            if(REPEAT_FIRST_FIELD == 1'b1)
              begin
                pre_number_of_frame_centre_offset = 2'b11;
              end
            else
              begin
                pre_number_of_frame_centre_offset = 2'b10;
              end
          end
      end
  end
         

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        state <= IDLE;
        pre_SHIFT <= 6'b00;
        ENDDEC <= 1'b0;
        number_of_frame_centre_offset <= 2'b00;
        loop_count <= 2'b00;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            state <= IDLE;
            pre_SHIFT <= 6'b00;
            ENDDEC <= 1'b0;
            number_of_frame_centre_offset <= 2'b00;
            loop_count <= 2'b00;
          end
        else if(y1_bs_wait_n == 1'b1) 
          begin
            state <= next_state;
            pre_SHIFT <= next_SHIFT;
            ENDDEC <= next_ENDDEC;
            number_of_frame_centre_offset <= next_number_of_frame_centre_offset;
            loop_count <= next_loop_count;
          end
        else
          begin
            state <= state;
            pre_SHIFT <= pre_SHIFT;
            ENDDEC <= ENDDEC;
            number_of_frame_centre_offset <= number_of_frame_centre_offset;
            loop_count <= loop_count;
          end
      end
  end

always @(state or v_interrpt_n or KICK or 
         number_of_frame_centre_offset)
  begin
    if(v_interrpt_n == no_break) 
      begin
        case(state)
          IDLE : 
            begin
              if(KICK == 1'b1) 
                begin
                  next_state = frame_centre_horizontal_offset;
                end
              else
                begin
                  next_state = IDLE;
                end
            end

          frame_centre_horizontal_offset : 
            begin
              next_state = frame_centre_vertical_offset;
            end

          frame_centre_vertical_offset : 
            begin
              if(number_of_frame_centre_offset != 2'b00) 
                begin
                  next_state = frame_centre_horizontal_offset;
                end
              else
                begin
                  next_state = IDLE;
                end
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

always @(state or v_interrpt_n or KICK or number_of_frame_centre_offset)
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          IDLE :
            begin
              if(KICK == 1'b1) 
                begin
                  next_SHIFT = 6'h11; 
                end
              else
                begin
                  next_SHIFT = 6'h00;
                end
            end
      
          frame_centre_horizontal_offset : 
            begin
              if(number_of_frame_centre_offset != 2'b01) 
                begin
                  next_SHIFT = 6'h11;
                end
              else
                begin
                  next_SHIFT = 6'h00;
                end
            end

          frame_centre_vertical_offset :
            begin
              if(number_of_frame_centre_offset != 2'b00) 
                begin
                  next_SHIFT = 6'h11; 
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

always @(state or v_interrpt_n or number_of_frame_centre_offset)
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          frame_centre_vertical_offset :
            begin
              if(number_of_frame_centre_offset == 2'b00)
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

assign loop_count_wire = {loop_count, 1'b0}; 

always @(state or v_interrpt_n or KICK or number_of_frame_centre_offset or loop_count_wire)
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          IDLE :
            begin
              if(KICK == 1'b1) 
                begin
                  PARAA = 8'h38; 
                end
              else
                begin
                  PARAA = 8'hFF;
                end
            end

          frame_centre_horizontal_offset :
            begin
              PARAA = 8'h39 + {5'h00, loop_count_wire};
            end

          frame_centre_vertical_offset :
            begin
              if(number_of_frame_centre_offset != 2'b00) 
                begin
                  PARAA = 8'h38 + {5'h00, loop_count_wire};
                end
              else
                begin
                  PARAA = 8'h3E;  
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

always @(state or v_interrpt_n or KICK or STREAM or number_of_frame_centre_offset)
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          IDLE :
            begin
              if(KICK == 1'b1 && STREAM == 1'b0) 
                begin
                  NFERROR = error;
                end
              else
                begin
                  NFERROR = no_error;
                end
            end

          frame_centre_horizontal_offset :
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

          frame_centre_vertical_offset :
            begin
              if(STREAM == 1'b0 && number_of_frame_centre_offset != 2'b00) 
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

always @(state or v_interrpt_n or number_of_frame_centre_offset
          or loop_count)
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          frame_centre_horizontal_offset :
            begin
              next_loop_count = loop_count + 1;
            end
     
          frame_centre_vertical_offset :
            begin
              if(number_of_frame_centre_offset != 2'b00) 
                begin
                  next_loop_count = loop_count;
                end
              else
                begin
                  next_loop_count = 2'b00;
                end
            end

          default :
            begin 
              next_loop_count = 2'b00;
            end
        endcase
      end
    else
      begin
        next_loop_count = 2'b00;
      end
  end

always @(state or v_interrpt_n or KICK or number_of_frame_centre_offset
          or pre_number_of_frame_centre_offset)
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          IDLE :
            begin
              if(KICK == 1'b1) 
                begin
                  next_number_of_frame_centre_offset = pre_number_of_frame_centre_offset;
                end
              else
                begin
                  next_number_of_frame_centre_offset = 2'b00;
                end
            end

          frame_centre_horizontal_offset :
            begin
              next_number_of_frame_centre_offset = number_of_frame_centre_offset - 1;
            end

          frame_centre_vertical_offset :
            begin
              next_number_of_frame_centre_offset = number_of_frame_centre_offset;
            end

          default :
            begin
              next_number_of_frame_centre_offset = 2'b00;
            end
        endcase
      end
    else
      begin
        next_number_of_frame_centre_offset = 2'b00;
      end
  end

always @(state or v_interrpt_n or number_of_frame_centre_offset or
          pre_number_of_frame_centre_offset)
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          frame_centre_vertical_offset :
            begin
              if(number_of_frame_centre_offset == 2'b00)
                begin
                  PARAD = pre_number_of_frame_centre_offset;
                end
              else
                begin
                  PARAD = 2'b00;
                end
            end

          default :
            begin
              PARAD = 2'b00;
            end
        endcase
      end
    else 
      begin
        PARAD = 2'b00;
      end
  end

always @(KICK or pre_SHIFT)
  begin
    case(KICK) 
      1'b1 : SHIFT = 6'h11;
      default : SHIFT = pre_SHIFT;
    endcase
  end

endmodule


