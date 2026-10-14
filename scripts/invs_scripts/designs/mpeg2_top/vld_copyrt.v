// ----------------------------------------------
// File: vld_copyrt.v
// Module: vld_copyrt
// Function:generate copyright_extension
// ----------------------------------------------

module vld_copyrt(
    clkdec, 
    rstdec_x, 
    g_swrst_r_n,
    y1_bs_wait_n, 
    v_interrpt_n, 
    v_cpxstrt_r_s,
    STREAM, 
    v_cpxend_r_s, 
    NFERROR, 
    CPR_SHIFT, 
    PARAA
);

input        clkdec;   
input        rstdec_x; 
input        g_swrst_r_n;  
input        y1_bs_wait_n;    // Wait signal
input        v_interrpt_n;  // Break signal
input        v_cpxstrt_r_s; // start decode copyright_extension
input [31:9] STREAM;          // bit stream(23bit) 

output       v_cpxend_r_s; // end-decode
output       NFERROR;        // non-fatal error
output [5:0] CPR_SHIFT;      // shift data
output [7:0] PARAA;          // address

reg       v_cpxend_r_s;
reg       next_v_cpxend_r_s;
reg       NFERROR;
reg [5:0] CPR_SHIFT;
reg       pre_SHIFT;
reg       next_SHIFT;
reg [7:0] PARAA;
reg [2:0] state;
reg       next_state;
reg       copyright_flag;
reg       next_copyright_flag;
reg [7:0] copyright_identifier;
reg [7:0] next_copyright_identifier;

parameter 
  IDLE = 3'b000,
  original_or_copy = 3'b001,
  reserved = 3'b010,
  copyright_number_1 = 3'b011,
  copyright_number_2 = 3'b100,
  copyright_number_3 = 3'b101;

parameter 
  error    = 1'b1,
  no_error = 1'b0;

parameter
  no_break = 1'b1;

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        state                <= IDLE;
        pre_SHIFT            <= 6'h00;
        v_cpxend_r_s       <= 1'b0;
        copyright_flag       <= 1'b0;
        copyright_identifier <= 8'h00;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            state                <= IDLE;
            pre_SHIFT            <= 6'h00;
            v_cpxend_r_s       <= 1'b0;
            copyright_flag       <= 1'b0;
            copyright_identifier <= 8'h00;
          end
        else if(y1_bs_wait_n == 1'b1) 
          begin
            state                <= next_state;
            pre_SHIFT            <= next_SHIFT;
            v_cpxend_r_s       <= next_v_cpxend_r_s;
            copyright_flag       <= next_copyright_flag; 
            copyright_identifier <= next_copyright_identifier;
          end
        else       
          begin
            state                <= state;
            pre_SHIFT            <= pre_SHIFT;
            v_cpxend_r_s       <= v_cpxend_r_s;
            copyright_flag       <= copyright_flag;
            copyright_identifier <= copyright_identifier;
          end
      end
  end

always @(state or v_interrpt_n or v_cpxstrt_r_s)
  begin
    if(v_interrpt_n == no_break)   
      begin
        case(state)
          IDLE : 
            begin
              if(v_cpxstrt_r_s == 1'b1) 
                begin
                  next_state = original_or_copy;
                end
              else
                begin
                  next_state = IDLE;
                end
            end

          original_or_copy : 
            begin
              next_state = reserved;
            end

          reserved : 
            begin
              next_state = copyright_number_1;
            end

          copyright_number_1 : 
            begin
              next_state = copyright_number_2;
            end

          copyright_number_2 : 
            begin
              next_state = copyright_number_3;
            end

          copyright_number_3 : 
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

always @(state or v_interrpt_n or v_cpxstrt_r_s)
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          IDLE :
            begin
              if(v_cpxstrt_r_s == 1'b1) 
                begin
                  next_SHIFT = 6'h08; 
                end
              else
                begin
                  next_SHIFT = 6'h00;
                end
            end
 
          original_or_copy :
            begin
              next_SHIFT = 6'h15;  
            end

          reserved :
            begin
              next_SHIFT = 6'h17; 
            end

          copyright_number_1 :
            begin
              next_SHIFT = 6'h16;  
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
          copyright_number_2 : 
            begin
              next_v_cpxend_r_s = 1'b1;
            end

          default :
            begin
              next_v_cpxend_r_s = 1'b0;
            end
        endcase
      end
    else
      begin
        next_v_cpxend_r_s = 1'b0;
      end
  end

always @(state or v_interrpt_n or v_cpxstrt_r_s)
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          IDLE :
            begin
              if(v_cpxstrt_r_s == 1'b1) 
                begin
                  PARAA = 8'h20; 
                end
              else
                begin
                  PARAA = 8'hFF;
                end
            end

          original_or_copy :
            begin
              PARAA = 8'h22;
            end

          reserved :
            begin
              PARAA = 8'h23; 
            end
 
          copyright_number_1 : 
            begin
              PARAA = 8'h24; 
            end

          copyright_number_2 :
            begin
              PARAA = 8'h25; 
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

always @(state or v_interrpt_n or v_cpxstrt_r_s or STREAM
        or copyright_flag or copyright_identifier)
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          IDLE :
            begin
              if(v_cpxstrt_r_s == 1'b1 &&                 
                  STREAM[31] == 1'b0 && STREAM[30:23] != 8'h00) 
                begin
                  NFERROR = error;
                end
              else
                begin
                  NFERROR = no_error;
                end
            end

          original_or_copy :
            begin
              if(STREAM[24] == 1'b0) 
                begin
                  NFERROR = error;
                end
              else
                begin
                  NFERROR = no_error;
                end
            end

          reserved :
            begin
              if(STREAM[31:12] != 20'h00000 &&        
                (copyright_flag == 1'b0 || copyright_identifier == 8'h00)
                || STREAM[11] == 1'b0)  
                begin
                  NFERROR = error;
                end
              else
                begin
                  NFERROR = no_error;
                end
            end

          copyright_number_1 :
            begin

              if((STREAM[31:10] != 22'h000000 &&  
                (copyright_flag == 1'b0 || copyright_identifier == 8'h00)) ||
                  STREAM[9] == 1'b0)                  
                begin
                  NFERROR = error;
                end
              else
                begin
                  NFERROR = no_error;
                end
            end

          copyright_number_2 :
            begin

              if(STREAM[31:10] != 22'h000000 &&    
                (copyright_flag == 1'b0 || copyright_identifier == 8'h00))
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

always @(state or v_interrpt_n or v_cpxstrt_r_s or STREAM or
                              copyright_flag or copyright_identifier)
  begin
    if(state == IDLE && v_interrpt_n == no_break && 
                v_cpxstrt_r_s == 1'b1) 
      begin
        next_copyright_flag = STREAM[31];
        next_copyright_identifier = STREAM[30:23];
      end
    else
      begin
        next_copyright_flag = copyright_flag;
        next_copyright_identifier = copyright_identifier;
      end
  end

always @(v_cpxstrt_r_s or pre_SHIFT)
  begin
    case(v_cpxstrt_r_s)  // start signal
      1'b1 :  CPR_SHIFT = 6'h0A;
      default : CPR_SHIFT = pre_SHIFT;
    endcase
  end

endmodule 

 
