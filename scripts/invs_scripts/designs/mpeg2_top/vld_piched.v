// ----------------------------------------------
// File: vtdvvld_piched.v
// Module: vtdvvld_piched
// Function:generate picture_header
// ----------------------------------------------

module vld_piched(
    clkdec, 
    rstdec_x, 
    g_swrst_r_n, 
    y1_bs_wait_n,
    v_interrpt_n, 
    KICK, 
    STREAM, 
    MPEG1, 
    v_low_delay_r,
    ENDDEC, 
    FERROR, 
    NFERROR, 
    SHIFT, 
    PARAA, 
    PARAD, 
    PIC_CODE_TYPE, 
    FWD_F_CODE, 
    BWD_F_CODE
);

input         clkdec;     // VLD clock
input         rstdec_x;   // Async reset
input         g_swrst_r_n;  // Sync reset
input         y1_bs_wait_n;   // Wait signal
input         v_interrpt_n; // Break signal
input         KICK;           // start decode
input [31:29] STREAM;         // bit stream(32bit)
input         MPEG1;          // 1:MPEG1, 0:MPEG2
input         v_low_delay_r; // 1:low_delay, 0:other 

output        ENDDEC;         // end-deocde
output        FERROR;         // fatal error
output        NFERROR;        // non-fatal error
output [5:0]  SHIFT;          // shift data
output [7:0]  PARAA;          // address
output [2:0]  PARAD;          // mapareter data  
output [2:0]  PIC_CODE_TYPE;  // picture_coding_type
output [2:0]  FWD_F_CODE;     // forward_f_code(MPEG-1)
output [2:0]  BWD_F_CODE;     // backward_f_code(MPEG-1)

reg       ENDDEC;
reg       next_ENDDEC;
reg       FERROR;
reg       NFERROR;
reg [5:0] SHIFT;
reg [5:0] pre_SHIFT;
reg [5:0] next_SHIFT;
reg [7:0] PARAA;
reg [2:0] PARAD; 
reg [2:0] PIC_CODE_TYPE;
reg [2:0] next_pic_code_type;
reg [2:0] FWD_F_CODE;
reg [2:0] next_fwd_f_code;
reg [2:0] BWD_F_CODE;
reg [2:0] next_bwd_f_code;
reg [3:0] state;
reg [3:0] next_state;
reg       flg_p;
reg       next_flg_p;
reg       flg_i;
reg       next_flg_i;
reg       flg_b;
reg       next_flg_b;

parameter  IDLE                      = 4'b0000,
           temporal_reference        = 4'b0001,
           picture_coding_type       = 4'b0010,
           vbv_delay                 = 4'b0011,
           full_pel_forward_vector   = 4'b0100,
           forward_f_code            = 4'b0101,
           full_pel_backward_vector  = 4'b0110,
           backward_f_code           = 4'b0111,
           extra_bit_picture         = 4'b1000,
           extra_information_picture = 4'b1001;

parameter  error    = 1'b1,
           no_error = 1'b0;

parameter  no_break = 1'b1;


always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0)  
      begin
        state         <= IDLE;
        pre_SHIFT     <= 6'h00; 
        ENDDEC        <= 1'b0;
        PIC_CODE_TYPE <= 3'b000;
        FWD_F_CODE    <= 3'b000;
        BWD_F_CODE    <= 3'b000;       
        flg_i         <= 1'b0;
        flg_p         <= 1'b0;
        flg_b         <= 1'b0;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0)
          begin
            state         <= IDLE;
            pre_SHIFT     <= 6'h00; 
            ENDDEC        <= 1'b0;
            PIC_CODE_TYPE <= 3'b000;
            FWD_F_CODE    <= 3'b000;
            BWD_F_CODE    <= 3'b000;       
            flg_i         <= 1'b0;
            flg_p         <= 1'b0;
            flg_b         <= 1'b0;
          end
        else if(y1_bs_wait_n == 1'b1) 
          begin
            state          <= next_state;
            pre_SHIFT      <= next_SHIFT;
            ENDDEC         <= next_ENDDEC;
            PIC_CODE_TYPE  <= next_pic_code_type;
            FWD_F_CODE     <= next_fwd_f_code;
            BWD_F_CODE     <= next_bwd_f_code;       
            flg_i          <= next_flg_i;
            flg_p          <= next_flg_p;
            flg_b          <= next_flg_b;
          end
        else
          begin
            state          <= state;
            pre_SHIFT      <= pre_SHIFT;
            ENDDEC         <= ENDDEC;
            PIC_CODE_TYPE  <= PIC_CODE_TYPE;
            FWD_F_CODE     <= FWD_F_CODE;
            BWD_F_CODE     <= BWD_F_CODE;       
            flg_i          <= flg_i;
            flg_p          <= flg_p;
            flg_b          <= flg_b;
          end
      end
  end

always @(state or v_interrpt_n or FERROR or KICK or STREAM or flg_b or flg_p or flg_i) 
  begin
    if(v_interrpt_n == no_break && FERROR == no_error) 
      begin
        case(state)
          IDLE : 
            begin
              if(KICK == 1'b1) 
                begin
                  next_state = temporal_reference;
                end
              else
                begin
                  next_state = IDLE;
                end
            end

          temporal_reference : 
            begin
              next_state = picture_coding_type;
            end

          picture_coding_type : 
            begin
              if(flg_p == 1'b1  || flg_b == 1'b1 || flg_i == 1'b1) 
                begin
                  next_state = vbv_delay;
                end
              else
                begin
                  next_state = backward_f_code;
                end
            end
 
          vbv_delay : 
            begin
              next_state = full_pel_forward_vector;
            end

          full_pel_forward_vector : 
            begin
              if(flg_b == 1'b1) 
                begin
                  next_state = forward_f_code;
                end
              else
                begin
                  next_state = backward_f_code;
                end
            end

          forward_f_code : 
            begin
              next_state = full_pel_backward_vector;
            end

          full_pel_backward_vector : 
            begin
              next_state = backward_f_code;
            end

          backward_f_code : 
            begin
              if(STREAM[31] == 1'b0) // extra_bit_picture = 0 -> don't have extra_information_picture
                begin
                  next_state = extra_information_picture;
                end
              else
                begin
                  next_state = extra_bit_picture;
                end
            end

          extra_bit_picture : 
            begin
              next_state = backward_f_code;
            end

          extra_information_picture : 
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

always @(state or v_interrpt_n or FERROR or KICK or STREAM)
  begin
    if(v_interrpt_n == no_break || FERROR == no_error)
      begin
        case(state)
          IDLE : 
            begin
              if(KICK == 1'b1) 
                begin
                  next_SHIFT = 6'h03; 
                end
              else
                begin
                  next_SHIFT = 6'h00;
                end
            end

          temporal_reference :
            begin
              next_SHIFT = 6'h10; 
            end

          picture_coding_type :
            begin
              next_SHIFT = 6'h01; 
            end            

          vbv_delay :
            begin
              next_SHIFT = 6'h03; 
            end

          full_pel_forward_vector :
            begin
              next_SHIFT = 6'h01; 
            end        
 
          forward_f_code :
            begin
              next_SHIFT = 6'h03;
            end

          full_pel_backward_vector :
            begin
              next_SHIFT = 6'h01; 
            end

          backward_f_code :
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

          extra_bit_picture :
            begin
              next_SHIFT = 6'h01; 
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
 

always @(state or v_interrpt_n or FERROR or STREAM)
  begin
    if(v_interrpt_n == no_break || FERROR == no_error)
      begin
        case(state)
          backward_f_code :
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

always @(state or v_interrpt_n or KICK)
  begin
    if(v_interrpt_n == no_break )
      begin
        case(state)
          IDLE :
            begin
              if(KICK == 1'b1) 
                begin
                  PARAA = 8'h30;  
                end
              else
                begin
                  PARAA = 8'hFF; 
                end
            end

          temporal_reference :
            begin
              PARAA = 8'h31;     
            end

          picture_coding_type :
            begin
              PARAA = 8'h32;   
            end

          vbv_delay :
            begin
              PARAA = 8'h33;   
            end

          full_pel_forward_vector :
            begin
              PARAA = 8'h34;   
            end

          forward_f_code :
            begin
              PARAA = 8'h35;   
            end

          full_pel_backward_vector :
            begin
              PARAA = 8'h36;   
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

always @(state or v_interrpt_n or STREAM or FERROR or v_low_delay_r)
  begin
    if(v_interrpt_n == no_break || FERROR == no_error)
      begin
        case(state)
          temporal_reference : 
            begin
              if(v_low_delay_r == 1'b1 && STREAM[31:29] == 3'b011)
                begin
                  PARAD = 3'b010; 
                end
              else
                begin
                  PARAD = STREAM[31:29];
                end
            end

          default:
            begin
              PARAD = 3'b000;
            end
        endcase
      end
    else
      begin
        PARAD = 3'b000;
      end
  end
          
always @(state or v_interrpt_n or STREAM or MPEG1)
  begin
    if(v_interrpt_n == no_break)  
      begin
        case(state)
          temporal_reference :
            begin
              if(STREAM[31:29] == 3'b000 ||          
                  (STREAM[31:29] >= 3'b101 && STREAM[31:29] <= 3'b111) ||  
                    (STREAM[31:29] == 3'b100 && MPEG1 == 1'b0))  
                begin
                  FERROR = error;
                end
              else
                begin
                  FERROR = no_error;
                end
            end

          full_pel_forward_vector :
            begin
              if((STREAM[31:29] == 3'b000 && MPEG1 == 1'b1) || 
                  ((STREAM[31:29] >= 3'b101 && STREAM[31:29] <= 3'b111) && MPEG1 == 1'b1)) 
                begin
                  FERROR = error;
                end
              else
                begin
                  FERROR = no_error;
                end
            end

          full_pel_backward_vector :
            begin
              if((STREAM[31:29] == 3'b000 && MPEG1 == 1'b1) ||
                  ((STREAM[31:29] >= 3'b101 && STREAM[31:29] <= 3'b111) && MPEG1 == 1'b1)) 
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

always @(state or v_interrpt_n or FERROR or STREAM or MPEG1 or 
        v_low_delay_r) 
  begin
    if(v_interrpt_n == no_break && FERROR == no_error)
      begin
        case(state)
          temporal_reference :
            begin
              if(v_low_delay_r == 1'b1 && STREAM[31:29] == 3'b011)
                begin
                  NFERROR = error;
                end
              else
                begin
                  NFERROR = no_error;
                end
            end
          vbv_delay :
            begin
              if(STREAM[31] == 1'b1 && MPEG1 == 1'b0)
                begin
                  NFERROR = error;
                end
              else
                begin
                  NFERROR = no_error;
                end
            end

          full_pel_forward_vector :
            begin
              if(STREAM[31:29] != 3'b111 && MPEG1 == 1'b0) 
                begin
                  NFERROR = error;
                end
              else
                begin
                  NFERROR = no_error;
                end
            end

          forward_f_code :
            begin
              if(STREAM[31] == 1'b1 && MPEG1 == 1'b0) 
                begin
                  NFERROR = error;
                end
              else
                begin
                  NFERROR = no_error;
                end
            end

          full_pel_backward_vector :
            begin
              if(STREAM[31:29] != 3'b111 && MPEG1 == 1'b0)
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

always @(state or v_interrpt_n or FERROR or STREAM
          or flg_i or flg_p or flg_b or v_low_delay_r) 
  begin
    if(v_interrpt_n == no_break || FERROR == no_error)
      begin
        case(state)
          temporal_reference :
            begin
              if(v_low_delay_r == 1'b1 && STREAM[31:29] == 3'b011)
                begin
                  next_flg_i = 1'b0;
                  next_flg_p = 1'b1;
                  next_flg_b = 1'b0;
                end
              else if(STREAM[31:29] == 3'b001)
                begin
                  next_flg_i = 1'b1;
                  next_flg_p = 1'b0;
                  next_flg_b = 1'b0;
                end
              else if(STREAM[31:29] == 3'b010)
                begin
                  next_flg_i = 1'b0;
                  next_flg_p = 1'b1;
                  next_flg_b = 1'b0;
                end
              else if(STREAM[31:29] == 3'b011)
                begin
                  next_flg_i = 1'b0;
                  next_flg_p = 1'b0;
                  next_flg_b = 1'b1;
                end
              else
                begin
                  next_flg_i = 1'b0;
                  next_flg_p = 1'b0;
                  next_flg_b = 1'b0;
                end
            end

          default : 
            begin
              next_flg_i = flg_i;
              next_flg_p = flg_p;
              next_flg_b = flg_b;
            end
        endcase
      end
    else
      begin
        next_flg_i = flg_i;
        next_flg_p = flg_p;
        next_flg_b = flg_b;
      end
  end 
 
always @(state or v_interrpt_n or FERROR or STREAM or 
                                PIC_CODE_TYPE or v_low_delay_r) 
  begin
    if(state == temporal_reference && v_interrpt_n == no_break 
      && FERROR == no_error)
      begin
        if(v_low_delay_r == 1'b1 && STREAM[31:29] == 3'b011) 
          begin
            next_pic_code_type = 3'b010; 
          end
        else
          begin 
            next_pic_code_type = STREAM[31:29];
          end
      end
    else
      begin
        next_pic_code_type = PIC_CODE_TYPE;
      end
  end

always @(state or v_interrpt_n or FERROR or STREAM or FWD_F_CODE)
  begin
    if(state == full_pel_forward_vector && v_interrpt_n == no_break && FERROR == no_error)
      begin
        next_fwd_f_code = STREAM[31:29];
      end
    else
      begin
        next_fwd_f_code = FWD_F_CODE;
      end
  end

always @(state or v_interrpt_n or FERROR or STREAM or BWD_F_CODE)
  begin
    if(state == full_pel_backward_vector && v_interrpt_n == no_break && FERROR == no_error)
      begin                 
        next_bwd_f_code = STREAM[31:29];
      end
    else
      begin
        next_bwd_f_code = BWD_F_CODE;
      end
  end

always @(KICK or pre_SHIFT)
  begin
    case(KICK)   
      1'b1 :  SHIFT = 6'h0A;
      default : SHIFT = pre_SHIFT;
    endcase
  end

endmodule 

