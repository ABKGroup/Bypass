// ----------------------------------------------
// File: vld_piccod.v
// Module: vld_piccod
// Function:generate picture_coding_extension
// ----------------------------------------------

module vld_piccod(
    clkdec, 
    rstdec_x, 
    g_swrst_r_n, 
    y1_bs_wait_n,
    v_interrpt_n,
    KICK, STREAM, 
    PICTURE_CODE_TYPE, 
    PROGRESSIVE_SEQUENCE,
    ENDDEC, 
    FERROR, 
    NFERROR, 
    SHIFT, 
    PARAA, 
    PARAD, 
    PICTURE_STRUCTURE_CODE,
    FRAME_PRED_FRAME_DCT, 
    CONCEALMENT_MOTION_VECTORS, 
    REPEAT_FIRST_FIELD, 
    INTRA_VLC_FORMAT, 
    FORWARD_HORIZONTAL, 
    FORWARD_VERTICAL, 
    BACKWARD_HORIZONTAL, 
    BACKWARD_VERTICAL,
    v_topfldfst_r
); 

input         clkdec;    
input         rstdec_x;  
input         g_swrst_r_n;   
input         y1_bs_wait_n;        // Wait signal
input         v_interrpt_n;        // Break signal
input         KICK;                // start decode
input [31:23] STREAM;              // bit stream (20bit)
input  [ 2:0] PICTURE_CODE_TYPE;   // picture_type(001:I,010:P,011:B)
input         PROGRESSIVE_SEQUENCE; // progressive_swquence 

output       ENDDEC;                 // end-decode
output       FERROR;                 // fatal error
output       NFERROR;                // non-fatal error
output [5:0] SHIFT;                  // shift data
output [7:0] PARAA;                  // address
output [8:0] PARAD;                  // parameter data(top_field_first..)
output [1:0] PICTURE_STRUCTURE_CODE; // picture_structure
output       FRAME_PRED_FRAME_DCT;   // frame_pred_frame_dct 
output       CONCEALMENT_MOTION_VECTORS; // concealment_motion_vectore
output       REPEAT_FIRST_FIELD;     // repeat_first_field
output       INTRA_VLC_FORMAT;       // intra_vlc_format
output [3:0] FORWARD_HORIZONTAL;
output [3:0] FORWARD_VERTICAL;
output [3:0] BACKWARD_HORIZONTAL;
output [3:0] BACKWARD_VERTICAL;
output       v_topfldfst_r;         // top_field_first

reg       ENDDEC;
reg       next_ENDDEC;
reg       FERROR;
reg       NFERROR;
reg [5:0] SHIFT;
reg       pre_SHIFT;
reg       next_SHIFT;
reg [7:0] PARAA;
reg [8:0] PARAD;
reg [1:0] PICTURE_STRUCTURE_CODE;
reg       next_picture_structure_code;
reg       FRAME_PRED_FRAME_DCT;
reg       next_frame_pred_frame_dct;
reg       CONCEALMENT_MOTION_VECTORS;
reg       next_concealment_motion_vectors;
reg       REPEAT_FIRST_FIELD;
reg       next_repeat_first_field;
reg       INTRA_VLC_FORMAT;
reg       next_intra_vlc_format;
reg       v_topfldfst_r;
reg       next_v_topfldfst_r;
reg [3:0] FORWARD_HORIZONTAL;
reg       next_forward_horizontal;
reg [3:0] FORWARD_VERTICAL;
reg       next_forward_vertical;
reg [3:0] BACKWARD_HORIZONTAL;
reg       next_backward_horizontal;
reg [3:0] BACKWARD_VERTICAL;
reg       next_backward_vertical;
reg [3:0] state;
reg       next_state;
reg [1:0] flg_field_frame;
reg       next_flg_field_frame;
reg [2:0] flg_md1_md2_nf; 
    
   
parameter   IDLE                       = 4'b0000,
            forward_horizontal_f_code  = 4'b0001,
            forward_vertical_f_code    = 4'b0010,
            backward_horizontal_f_code = 4'b0011,
            backward_vertical_f_code   = 4'b0100,
            intra_dc_precision         = 4'b0101,
            picture_structure          = 4'b0110,
            progressive_frame          = 4'b0111,
            composite_display_flag     = 4'b1000,
            sub_carrier_phase          = 4'b1001;

parameter   error    = 1'b1,
            no_error = 1'b0;

parameter   no_break = 1'b1;

parameter   i_picture = 3'b001,
            p_picture = 3'b010,
            b_picture = 3'b011;

parameter   Field = 2'b10,
            Frame = 2'b01;

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        state                      <= IDLE;
        pre_SHIFT                  <= 6'h00;
        ENDDEC                     <= 1'b0;
        PICTURE_STRUCTURE_CODE     <= 2'b00;
        FRAME_PRED_FRAME_DCT       <= 1'b0;
        CONCEALMENT_MOTION_VECTORS <= 1'b0;
        REPEAT_FIRST_FIELD         <= 1'b0;
        INTRA_VLC_FORMAT           <= 1'b0;
        FORWARD_HORIZONTAL         <= 4'b0000;
        FORWARD_VERTICAL           <= 4'b0000;
        BACKWARD_HORIZONTAL        <= 4'b0000;
        BACKWARD_VERTICAL          <= 4'b0000;
        flg_field_frame            <= 2'b00;
        v_topfldfst_r            <= 1'b0;
      end
    else
      if(g_swrst_r_n == 1'b0)
        begin
          state <= IDLE;
          pre_SHIFT                  <= 6'h00;
          ENDDEC                     <= 1'b0;
          PICTURE_STRUCTURE_CODE     <= 2'b00;
          FRAME_PRED_FRAME_DCT       <= 1'b0;
          CONCEALMENT_MOTION_VECTORS <= 1'b0;
          REPEAT_FIRST_FIELD         <= 1'b0;
          INTRA_VLC_FORMAT           <= 1'b0;
          FORWARD_HORIZONTAL         <= 4'b0000;
          FORWARD_VERTICAL           <= 4'b0000;
          BACKWARD_HORIZONTAL        <= 4'b0000;
          BACKWARD_VERTICAL          <= 4'b0000;
          flg_field_frame            <= 2'b00;
          v_topfldfst_r            <= 1'b0;
        end
      else if(y1_bs_wait_n == 1'b1) 
        begin
          state <= next_state;
          pre_SHIFT                  <= next_SHIFT;
          ENDDEC                     <= next_ENDDEC;
          PICTURE_STRUCTURE_CODE     <= next_picture_structure_code;
          FRAME_PRED_FRAME_DCT       <= next_frame_pred_frame_dct;
          CONCEALMENT_MOTION_VECTORS <= next_concealment_motion_vectors;
          REPEAT_FIRST_FIELD         <= next_repeat_first_field;
          INTRA_VLC_FORMAT           <= next_intra_vlc_format;
          FORWARD_HORIZONTAL         <= next_forward_horizontal;
          FORWARD_VERTICAL           <= next_forward_vertical;
          BACKWARD_HORIZONTAL        <= next_backward_horizontal;
          BACKWARD_VERTICAL          <= next_backward_vertical;
          flg_field_frame            <= next_flg_field_frame;
          v_topfldfst_r            <= next_v_topfldfst_r;
        end
      else                        
        begin
          state                      <= state;
          pre_SHIFT                  <= pre_SHIFT;
          ENDDEC                     <= ENDDEC;
          PICTURE_STRUCTURE_CODE     <= PICTURE_STRUCTURE_CODE;
          FRAME_PRED_FRAME_DCT       <= FRAME_PRED_FRAME_DCT;
          CONCEALMENT_MOTION_VECTORS <= CONCEALMENT_MOTION_VECTORS;
          REPEAT_FIRST_FIELD         <= REPEAT_FIRST_FIELD;
          INTRA_VLC_FORMAT           <= INTRA_VLC_FORMAT;
          FORWARD_HORIZONTAL         <= FORWARD_HORIZONTAL;
          FORWARD_VERTICAL           <= FORWARD_VERTICAL;
          BACKWARD_HORIZONTAL        <= BACKWARD_HORIZONTAL;
          BACKWARD_VERTICAL          <= BACKWARD_VERTICAL;
          flg_field_frame            <= flg_field_frame;
          v_topfldfst_r            <= v_topfldfst_r;
        end
  end 

always @(state or v_interrpt_n or FERROR or KICK or STREAM)
  begin
    if(v_interrpt_n == no_break && FERROR == no_error)
      begin
        case(state)
          IDLE : 
            begin
              if(KICK == 1'b1) 
                begin
                  next_state = forward_horizontal_f_code;
                end
              else
                begin
                  next_state = IDLE;
                end
            end

          forward_horizontal_f_code : 
            begin
              next_state = forward_vertical_f_code;
            end

          forward_vertical_f_code : 
            begin
              next_state = backward_horizontal_f_code;
            end

          backward_horizontal_f_code : 
            begin
              next_state = backward_vertical_f_code;
            end

          backward_vertical_f_code :
            begin
              next_state = intra_dc_precision;
            end

          intra_dc_precision :
            begin
              next_state = picture_structure;
            end

          picture_structure : 
            begin
              next_state = progressive_frame;
            end

          progressive_frame : 
            begin
              if(STREAM[31] == 1'b1) 
                begin
                  next_state = composite_display_flag;
                end
              else               
                begin 
                  next_state = sub_carrier_phase; 
                end
            end

          composite_display_flag : 
            begin                 
              next_state = sub_carrier_phase; 
            end

          sub_carrier_phase : 
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
    if(v_interrpt_n == no_break && FERROR == no_error) 
      begin
        case(state)
          IDLE :
            begin
              if(KICK == 1'b1) 
                begin
                  next_SHIFT = 6'h04; 
                end
              else
                begin
                  next_SHIFT = 6'h00;
                end
            end
 
          forward_horizontal_f_code :
            begin
              next_SHIFT = 6'h04; 
            end

          forward_vertical_f_code :
            begin
              next_SHIFT = 6'h04; 
            end

          backward_horizontal_f_code :
            begin
              next_SHIFT = 6'h02; 
            end

          backward_vertical_f_code :
            begin
              next_SHIFT = 6'h02; 
            end

          intra_dc_precision :
            begin
              next_SHIFT = 6'h09; 
            end

          picture_structure :
            begin
              next_SHIFT = 6'h01; 
            end

          progressive_frame :
            begin
              if(STREAM[31] == 1'b1) 
                begin
                  next_SHIFT = 6'h14; 
                end
              else
                begin
                  next_SHIFT = 6'h00; 
                end
            end

          composite_display_flag :
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

always @(state or v_interrpt_n or FERROR or STREAM)
  begin
    if(v_interrpt_n == no_break && FERROR == no_error)
      begin
        case(state)
          progressive_frame : 
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
          composite_display_flag : 
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
                  PARAA = 8'h40; 
                end
              else 
                begin
                  PARAA = 8'hFF;
                end
            end

          forward_horizontal_f_code :
            begin
              PARAA = 8'h41; 
            end

          forward_vertical_f_code :
            begin
              PARAA = 8'h42; 
            end

          backward_horizontal_f_code :
            begin
              PARAA = 8'h43; 
            end

          backward_vertical_f_code :
            begin
              PARAA = 8'h44; 
            end

          intra_dc_precision :
            begin
              PARAA = 8'h45; 
            end

          picture_structure :
            begin
              PARAA = 8'h46; 
            end

          progressive_frame :
            begin
              PARAA = 8'h47; 
            end

          composite_display_flag :
            begin
              PARAA = 8'h48; 
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

always @(state or v_interrpt_n or KICK or STREAM or PICTURE_CODE_TYPE)
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          IDLE :
            begin
              if(KICK == 1'b1 &&               
                 (STREAM[31:28] == 4'b0000 ||  
                 (STREAM[31:28] >= 4'b1010 && STREAM[31:28] < 4'b1111)) && 
                  (PICTURE_CODE_TYPE == p_picture || 
                    PICTURE_CODE_TYPE == b_picture)) 
                begin
                  FERROR = error;
                end
              else
                begin
                  FERROR = no_error;
                end
            end

          forward_horizontal_f_code :
            begin
              if((STREAM[31:28] == 4'b0000 || 
                (STREAM[31:28] >= 4'b0110 && STREAM[31:28] < 4'b1111)) &&
                  (PICTURE_CODE_TYPE == p_picture || 
                    PICTURE_CODE_TYPE == b_picture)) 
                begin
                  FERROR = error;
                end
              else
                begin
                  FERROR = no_error;
                end
            end

          forward_vertical_f_code :
            begin
              if((STREAM[31:28] == 4'b0000 || 
                (STREAM[31:28] >= 4'b1010 && STREAM[31:28] < 4'b1111)) && 
                  (PICTURE_CODE_TYPE == b_picture))   
                begin
                  FERROR = error;
                end
              else
                begin
                  FERROR = no_error;
                end
            end
 
          backward_horizontal_f_code :
            begin
              if((STREAM[31:28] == 4'b0000 || 
                (STREAM[31:28] >= 4'b0110 && STREAM[31:28] < 4'b1111)) && 
                  (PICTURE_CODE_TYPE == b_picture))  
                begin
                  FERROR = error;
                end
              else
                begin
                  FERROR = no_error;
                end
            end

          backward_vertical_f_code :
            begin
              if(STREAM[31:30] == 2'b11) 
                begin
                  FERROR = error;
                end
              else
                begin
                  FERROR = no_error;
                end
            end

          intra_dc_precision :
            begin
              if(STREAM[31:30] == 2'b00) 
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


always @(state or v_interrpt_n or FERROR or KICK or STREAM or 
         PICTURE_CODE_TYPE or flg_md1_md2_nf)
  begin
    if(v_interrpt_n == no_break && FERROR == no_error)
      begin
        case(state)
          IDLE :
            begin
              if(KICK == 1'b1 && PICTURE_CODE_TYPE == i_picture &&    
                 (STREAM[31:28] == 4'b0000 || (STREAM[31:28] >= 4'b1010 
                     && STREAM[31:28] <= 4'b1110))) 
                begin    
                  NFERROR = error;
                end
              else
                begin
                  NFERROR = no_error;
                end
            end

          forward_horizontal_f_code :
            begin
              if(PICTURE_CODE_TYPE == i_picture &&            
                 (STREAM[31:28] == 4'b0000 || (STREAM[31:28] >= 4'b0110 
                     && STREAM[31:28] <= 4'b1110))) 
                begin
                  NFERROR = error;
                end
              else
                begin
                  NFERROR = no_error;
                end
            end

          forward_vertical_f_code :
            begin
              if((PICTURE_CODE_TYPE == i_picture || PICTURE_CODE_TYPE == p_picture) && 
                  STREAM[31:28] != 4'b1111)   
                begin
                  NFERROR = error;
                end
              else
                begin
                  NFERROR = no_error;
                end
            end

          backward_horizontal_f_code :
            begin
              if((PICTURE_CODE_TYPE == i_picture || PICTURE_CODE_TYPE == p_picture) &&  
                  STREAM[31:28] != 4'b1111)
                begin
                  NFERROR = error;
                end
              else
                begin
                  NFERROR = no_error;
                end
            end

          intra_dc_precision :
            begin
              if(flg_md1_md2_nf != 3'b000)
                begin
                  NFERROR = error;
                end
              else
                begin
                  NFERROR = no_error;
                end
             end

          picture_structure :
            begin
              if(flg_md1_md2_nf != 3'b000) 
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

always @(state or v_interrpt_n or FERROR or STREAM or flg_field_frame
        or PROGRESSIVE_SEQUENCE) 
  begin
    if(v_interrpt_n == no_break && FERROR == no_error)
      begin
        case(state)
          intra_dc_precision :
            begin
              if(PROGRESSIVE_SEQUENCE == 1'b1)
                begin
                  next_flg_field_frame = Frame;
                end
              else if(STREAM[31:30] == 2'b01 || STREAM[31:30] == 2'b10) 
                begin
                  next_flg_field_frame = Field;
                end
              else if(STREAM[31:30] == 2'b11) // Frame picture
                begin
                  next_flg_field_frame = Frame;
                end
              else        
                begin
                  next_flg_field_frame = 2'b00;
                end
            end

          default : 
            begin
              next_flg_field_frame = flg_field_frame;
            end
        endcase
      end
    else
      begin
        next_flg_field_frame = flg_field_frame;
      end
  end

always @(state or v_interrpt_n or FERROR or STREAM 
         or PROGRESSIVE_SEQUENCE or flg_field_frame)
  begin
    if(v_interrpt_n == no_break || FERROR == no_error)
      begin
        case(state)

          intra_dc_precision :
            begin
              if(PROGRESSIVE_SEQUENCE == 1'b1 &&
                  (STREAM[31:30] == 2'b01 || STREAM[31:30] == 2'b10))
                begin
                  flg_md1_md2_nf = 3'b100;
                end
              else
                begin
                  flg_md1_md2_nf = 3'b000;
                end
            end

          picture_structure :
            begin
              if(PROGRESSIVE_SEQUENCE == 1'b1 &&               
                  STREAM[30] == 1'b0)  
                begin                  
                  flg_md1_md2_nf = 3'b100;
                end
              else if((PROGRESSIVE_SEQUENCE == 1'b0 &&         
                       flg_field_frame == Field) &&             
                      (STREAM[25] == 1'b1 || STREAM[30] == 1'b1)) 
                begin
                  flg_md1_md2_nf = 3'b010;
                end
              else if((PROGRESSIVE_SEQUENCE == 1'b0 && STREAM[23] == 1'b0 &&
                       flg_field_frame == Field && STREAM[31] == 1'b1 && 
                                             STREAM[25] == 1'b0 && STREAM[30] == 1'b0) ||
                 (PROGRESSIVE_SEQUENCE == 1'b0 && STREAM[23] == 1'b0 &&
                                       flg_field_frame == Frame && STREAM[25] == 1'b1) ||
                 (PROGRESSIVE_SEQUENCE == 1'b0 && STREAM[23] == 1'b1 &&
                                       flg_field_frame == Field && STREAM[25] == 1'b0) ||
                 (PROGRESSIVE_SEQUENCE == 1'b1 && STREAM[23] == 1'b0 &&
                                       flg_field_frame == Frame && STREAM[30] == 1'b1) ||
                 (PROGRESSIVE_SEQUENCE == 1'b1 && STREAM[23] == 1'b1 &&
                       flg_field_frame == Frame && STREAM[31] == 1'b1 &&
                                             STREAM[25] == 1'b0 && STREAM[30] == 1'b1))
                begin
                  flg_md1_md2_nf = 3'b001;
                end
              else
                begin
                  flg_md1_md2_nf = 3'b000;
                end
            end
 
          default :  
            begin
              flg_md1_md2_nf = 3'b000;
            end
        endcase
      end
    else
      begin
        flg_md1_md2_nf = 3'b000;
      end
  end

     
                  
always @(state or v_interrpt_n or FERROR or KICK or STREAM or FORWARD_HORIZONTAL)
  begin
    if(state == IDLE && v_interrpt_n == no_break && FERROR == no_error && KICK == 1'b1)
      begin
        next_forward_horizontal = STREAM[31:28];
      end
    else
      begin
        next_forward_horizontal = FORWARD_HORIZONTAL;
      end
  end

always @(state or v_interrpt_n or FERROR or STREAM or FORWARD_VERTICAL)
  begin
    if(state == forward_horizontal_f_code && v_interrpt_n == no_break && FERROR == no_error)
      begin
        next_forward_vertical = STREAM[31:28];
      end
    else
      begin
        next_forward_vertical = FORWARD_VERTICAL;
      end
  end

always @(state or v_interrpt_n or FERROR or STREAM or BACKWARD_HORIZONTAL)
  begin
    if(state == forward_vertical_f_code && v_interrpt_n == no_break && FERROR == no_error)
      begin
        next_backward_horizontal = STREAM[31:28];
      end
    else
      begin
        next_backward_horizontal = BACKWARD_HORIZONTAL;
      end
  end

always @(state or v_interrpt_n or FERROR or STREAM or BACKWARD_VERTICAL)
  begin
    if(state == backward_horizontal_f_code && v_interrpt_n == no_break && FERROR == no_error)
      begin
        next_backward_vertical = STREAM[31:28];
      end
    else
      begin
        next_backward_vertical = BACKWARD_VERTICAL;
      end
  end

always @(state or v_interrpt_n or FERROR or STREAM or PICTURE_STRUCTURE_CODE or flg_md1_md2_nf)
  begin
    if(state == intra_dc_precision && v_interrpt_n == no_break && FERROR == no_error)
      begin
        if(flg_md1_md2_nf == 3'b100) 
          begin
            next_picture_structure_code = 2'b11; 
          end
        else
          begin 
            next_picture_structure_code = STREAM[31:30];
          end
      end
    else
      begin
        next_picture_structure_code = PICTURE_STRUCTURE_CODE;
      end
  end


always @(state or v_interrpt_n or FERROR or STREAM or FRAME_PRED_FRAME_DCT 
           or flg_md1_md2_nf)
  begin
    if(state == picture_structure && v_interrpt_n == no_break && FERROR == no_error)
      begin
        if(flg_md1_md2_nf == 3'b100) 
          begin
            next_frame_pred_frame_dct = 1'b1;
          end
        else if(flg_md1_md2_nf == 3'b010)  
          begin
            next_frame_pred_frame_dct = 1'b0;
          end
        else
          begin
            next_frame_pred_frame_dct = STREAM[30];
          end
      end
    else
      begin
        next_frame_pred_frame_dct = FRAME_PRED_FRAME_DCT;
      end
  end

always @(state or v_interrpt_n or FERROR or STREAM or CONCEALMENT_MOTION_VECTORS)
  begin
    if(state == picture_structure && v_interrpt_n == no_break && FERROR == no_error)
      begin
        next_concealment_motion_vectors = STREAM[29];
      end
    else
      begin
        next_concealment_motion_vectors = CONCEALMENT_MOTION_VECTORS;
      end
  end

always @(state or v_interrpt_n or FERROR or STREAM or 
           REPEAT_FIRST_FIELD or flg_md1_md2_nf)
  begin
    if(state == picture_structure && v_interrpt_n == no_break && FERROR == no_error)
      begin
        if(flg_md1_md2_nf == 3'b010) 
          begin
            next_repeat_first_field = 1'b0;
          end
        else
          begin
            next_repeat_first_field = STREAM[25];
          end
      end
    else
      begin
        next_repeat_first_field = REPEAT_FIRST_FIELD;
      end
  end

always @(state or v_interrpt_n or FERROR or STREAM or INTRA_VLC_FORMAT)
  begin
    if(state == picture_structure && v_interrpt_n == no_break && FERROR == no_error)
      begin
        next_intra_vlc_format = STREAM[27]; 
      end
    else
      begin
        next_intra_vlc_format = INTRA_VLC_FORMAT;
      end
  end

always @(state or v_interrpt_n or FERROR or STREAM or v_topfldfst_r)
  begin
    if(state == picture_structure && v_interrpt_n == no_break && FERROR == no_error)
      begin
        next_v_topfldfst_r = STREAM[31];
      end
    else
      begin
        next_v_topfldfst_r = v_topfldfst_r;
      end
  end

always @(state or v_interrpt_n or STREAM or flg_md1_md2_nf
         or PROGRESSIVE_SEQUENCE) 
  begin
    if(v_interrpt_n == no_break) 
      begin
        case(state)
          intra_dc_precision :
            begin
              if(PROGRESSIVE_SEQUENCE == 1'b1) 
                begin
                  PARAD = {2'b11, 7'h00};
                end
              else
                begin
                  PARAD = {STREAM[31:30], 7'h00};
                end
            end
 
          picture_structure :
            begin
              if(flg_md1_md2_nf == 3'b100) 
                begin
                  PARAD = {STREAM[31],1'b1,STREAM[29:23]};
                end
              else if(flg_md1_md2_nf == 3'b010) 
                begin
                  PARAD = {STREAM[31],1'b0,STREAM[29:26],1'b0,STREAM[24:23]}; 
                end
              else
                begin
                  PARAD = STREAM[31:23];
                end 
            end

          default :
            begin
              PARAD = 9'h000;
            end
        endcase
      end
    else
      begin
        PARAD = 9'h000;
      end
  end  

always @(KICK or pre_SHIFT)
  begin
    case(KICK) 
      1'b1 :  SHIFT = 6'h04;
      default : SHIFT = pre_SHIFT;
    endcase
  end

endmodule

