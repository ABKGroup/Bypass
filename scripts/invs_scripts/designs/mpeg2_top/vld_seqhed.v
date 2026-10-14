// ----------------------------------------------
// File: vld_seqhed.v
// Module: vld_seqhed
// Function:generate sequence_header 
// ----------------------------------------------

module vld_seqhed (
    clkdec, 
    rstdec_x, 
    g_swrst_r_n,
    y1_bs_wait_n, 
    v_interrpt_n, 
    STREAM, 
    KICKS,
    KICKQ, 
    ENDDECS, 
    ENDDECQ, 
    FERROR, 
    NFERROR,
    QMSYNI, 
    QMSELI, 
    QMSYNN, 
    QMSELN, 
    QM, 
    SHIFT,
    PARAA
);

input         clkdec;    
input         rstdec_x;  
input         g_swrst_r_n; 
input         y1_bs_wait_n;    // Wait signal
input         v_interrpt_n;    // Break signal
input  [31:8] STREAM;          // bit stream
input         KICKS;           // start-decode for seqhead
input         KICKQ;           // start-decode for QMi
output        ENDDECS;         // end-decode from seqhead
output        ENDDECQ;         // end-decode from QM
output        FERROR;          // fatal error
output        NFERROR;         // non-fatal error
output        QMSYNI;          // sync-signal for intra QM
output        QMSELI;          // select-signal for intra QM
output        QMSYNN;          // sync-signal for non-intra QM
output        QMSELN;          // select-signal for non-intra QM
output [7:0]  QM;              // QM data
output [5:0]  SHIFT;           // shift data
output [7:0]  PARAA;           // address

reg ENDDECS, ENDDECQ, FERROR, NFERROR, QMSYNI, QMSELI, QMSYNN, QMSELN,
    next_ENDDECS, next_ENDDECQ, next_QMSYNI, next_QMSELI,
    next_QMSYNN, next_QMSELN;          

reg       qm_flag;           
reg       next_qm_flag; 
reg [3:0] state;      
reg       next_state; 
reg [5:0] SHIFT;       
reg [5:0] pre_SHIFT;   
reg [5:0] next_SHIFT;  
reg [6:0] qm_count;      
reg       next_qm_count;  
reg [7:0] PARAA;
reg [7:0] QM;          
reg       next_qm;    
reg       v_dly_ferror;   
reg       v_ferror;    
wire [1:0] kick;    
 
parameter  IDLE                            = 4'b0000,
           vertical_size_value             = 4'b0001,
           frame_rate_code                 = 4'b0010,
           bit_rate_value                  = 4'b0011,
           vbv_buffer_size_value           = 4'b0100,
           load_intra_quantiser_matrix     = 4'b0101,
           intra_quantiser_matrix          = 4'b0110,
           load_non_intra_quantiser_matrix = 4'b0111,
           non_intra_quantiser_matrix      = 4'b1000;

parameter  error    = 1'b1,
           no_error = 1'b0;

parameter  no_break = 1'b1;

parameter  disable_qm = 8'h00;

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0)  
      begin
        state <= IDLE;
        pre_SHIFT <= 6'h00;
        ENDDECS   <= 1'b0;
        ENDDECQ   <= 1'b0;
        QMSYNI    <= 1'b1;
        QMSELI    <= 1'b0;
        QMSYNN    <= 1'b1;
        QMSELN    <= 1'b0;
        QM        <= 8'h00;
        qm_flag   <= 1'b0;
        qm_count  <= 7'h00;
      end
    else   
      begin
        if(g_swrst_r_n == 1'b0)  
          begin
            state <= IDLE;
            pre_SHIFT <= 6'h00;
            ENDDECS   <= 1'b0;
            ENDDECQ   <= 1'b0;
            QMSYNI    <= 1'b1;
            QMSELI    <= 1'b0;
            QMSYNN    <= 1'b1;
            QMSELN    <= 1'b0;
            QM        <= 8'h00;
            qm_flag   <= 1'b0;
            qm_count  <= 7'h00;
          end
        else if(y1_bs_wait_n == 1'b1) 
          begin
            state <= next_state;
            pre_SHIFT <= next_SHIFT;
            ENDDECS   <= next_ENDDECS;
            ENDDECQ   <= next_ENDDECQ;
            QMSYNI    <= next_QMSYNI;
            QMSELI    <= next_QMSELI;
            QMSYNN    <= next_QMSYNN;
            QMSELN    <= next_QMSELN;
            QM        <= next_qm;
            qm_flag   <= next_qm_flag;
            qm_count  <= next_qm_count;
          end
        else       
          begin
            state <= state;
            pre_SHIFT <= pre_SHIFT;
            ENDDECS   <= ENDDECS;
            ENDDECQ   <= ENDDECQ;
            QMSYNI    <= QMSYNI;
            QMSELI    <= 1'b0;
            QMSYNN    <= QMSYNN;
            QMSELN    <= 1'b0;
            QM        <= next_qm;
            qm_flag   <= qm_flag;
            qm_count  <= qm_count;
          end
      end 
  end

always @(state or KICKS or KICKQ or v_interrpt_n or 
        qm_count or pre_SHIFT or FERROR)
  begin
    case(state)
      IDLE :    
        begin     
          if(v_interrpt_n == no_break && FERROR == no_error) 
            begin 
              if(KICKS == 1'b1)
                  next_state = vertical_size_value;
              else if(KICKQ == 1'b1) 
                  next_state = load_intra_quantiser_matrix;
              else 
                  next_state = state;   
            end
          else    
              next_state = IDLE;
        end
     
      vertical_size_value : 
        begin    
          if(v_interrpt_n == no_break && FERROR == no_error)
              next_state = frame_rate_code;
          else              
              next_state = IDLE;
        end

      frame_rate_code :   
        begin
          if(v_interrpt_n == no_break && FERROR == 1'b0)   
              next_state = bit_rate_value;
          else                 
              next_state = IDLE;
        end

      bit_rate_value :   
        begin              
          if(v_interrpt_n == no_break && FERROR == no_error)   
              next_state = vbv_buffer_size_value;
          else                   
              next_state = IDLE;
        end

      vbv_buffer_size_value : 
        begin                 
          if(v_interrpt_n == no_break && FERROR == no_error)   
              next_state = load_intra_quantiser_matrix;
          else                      
              next_state = IDLE;
        end

      load_intra_quantiser_matrix : 
        begin               
          if(v_interrpt_n == no_break && FERROR == no_error)    
            begin 
              if(pre_SHIFT == 6'h08)   
                  next_state = intra_quantiser_matrix;
              else                 
                  next_state = load_non_intra_quantiser_matrix;
            end
          else                
              next_state = IDLE;
        end
      
      intra_quantiser_matrix :  
        begin          
          if(v_interrpt_n == no_break && FERROR == no_error)    
            begin 
              if(qm_count < 7'h40)    
                  next_state = state;
              else                  
                  next_state = load_non_intra_quantiser_matrix;
            end
          else 
              next_state = IDLE;
        end 
 
      load_non_intra_quantiser_matrix : 
        begin 
          if(v_interrpt_n == no_break && FERROR == no_error)    
            begin
              if(pre_SHIFT == 6'h08)    
                  next_state = non_intra_quantiser_matrix;
              else                    
                  next_state = IDLE;
            end
          else                          
              next_state = IDLE;
        end
 
      non_intra_quantiser_matrix :
        begin
          if(v_interrpt_n == no_break && FERROR == no_error)   
            begin
              if(qm_count < 7'h40)   
                  next_state = state;
              else                    
                  next_state = IDLE;
            end
          else                         
              next_state = IDLE;
        end
      
      default :   
        begin
          next_state = IDLE;
        end

    endcase
  end

always @(state or  KICKS or KICKQ or STREAM or v_interrpt_n or 
        qm_count or pre_SHIFT or FERROR) 
  begin
    case(state)
      IDLE :   
        begin
          if(v_interrpt_n == no_break && FERROR == no_error) 
            begin
              if(KICKS == 1'b1)    
                  next_SHIFT = 6'h08;
              else if(KICKQ == 1'b1) 
                begin
                  if(STREAM[31] == 1'b0)
                      next_SHIFT = 6'h01; 
                  else
                      next_SHIFT = 6'h08;  
                end
              else
                  next_SHIFT = 6'h00;
            end
          else
              next_SHIFT = 6'h00;
        end

      vertical_size_value :
        begin
          if(v_interrpt_n == no_break && FERROR == no_error) 
              next_SHIFT = 6'h12;         
          else
              next_SHIFT = 6'h00;
        end

      frame_rate_code :
        begin
          if(v_interrpt_n == no_break && FERROR == no_error)
              next_SHIFT = 6'h0B;          
          else
              next_SHIFT = 6'h00;
        end

      bit_rate_value :
        begin
          if(v_interrpt_n == no_break && FERROR == no_error)
              next_SHIFT = 6'h02;          
          else
              next_SHIFT = 6'h00;
        end 
 
      vbv_buffer_size_value :
        begin
          if(v_interrpt_n == no_break && FERROR == no_error)
            begin
              if(STREAM[30] == 1'b0)
                  next_SHIFT = 6'h01;      
              else
                  next_SHIFT = 6'h08;      
            end
          else
              next_SHIFT = 6'h00;
        end
  
      load_intra_quantiser_matrix :
        begin
          if(v_interrpt_n == no_break && FERROR == no_error)
            begin
              if(pre_SHIFT == 6'h08)
                  next_SHIFT = 6'h08;     
              else if(STREAM[31] == 1'b1)
                  next_SHIFT = 6'h08;     
              else
                  next_SHIFT = 6'h00;     
            end
          else
              next_SHIFT = 6'h00;
        end

      intra_quantiser_matrix :
        begin
          if(v_interrpt_n == no_break && FERROR == no_error)
            begin
              if(qm_count == 7'h3F)  
                  next_SHIFT = 6'h01;   
              else if(qm_count < 7'h40) 
                  next_SHIFT = 6'h08;   
              else if(STREAM[31] == 1'b1)
                  next_SHIFT = 6'h08;  
              else
                  next_SHIFT = 6'h00;  
            end
          else
              next_SHIFT = 6'h00;
        end

      load_non_intra_quantiser_matrix :
        begin
          if(v_interrpt_n == no_break && FERROR == no_error)
            begin
              if(pre_SHIFT == 6'h08)
                  next_SHIFT = 6'h08;
              else
                  next_SHIFT = 6'h00; 
            end
          else
              next_SHIFT = 6'h00;
        end

      non_intra_quantiser_matrix :
        begin
          if(v_interrpt_n == no_break && FERROR == no_error)
            begin
              if(qm_count == 7'h3F)  
                  next_SHIFT = 6'h00; 
              else if(qm_count < 7'h40)
                  next_SHIFT = 6'h08; 
              else
                  next_SHIFT = 6'h00; 
            end
          else
              next_SHIFT = 6'h00;
        end

      default :
          next_SHIFT = 6'h00;
 
    endcase
  end
        
always @(state or STREAM or v_interrpt_n or qm_count or qm_flag or pre_SHIFT or FERROR)
  begin
    case(state)
      load_intra_quantiser_matrix :
        begin
          if(v_interrpt_n == no_break && FERROR == no_error)
            begin
              if(pre_SHIFT == 6'h01 && STREAM[31] == 1'b0 && qm_flag == 1'b0) 
                  next_ENDDECS = 1'b1;
              else
                  next_ENDDECS = 1'b0;
            end
          else
              next_ENDDECS = 1'b0;
        end

      load_non_intra_quantiser_matrix :
        begin
          if(v_interrpt_n == no_break && FERROR == no_error)
            begin
              if(pre_SHIFT == 6'h00 && STREAM[31] == 1'b0 && qm_flag == 1'b0) 
                  next_ENDDECS = 1'b1;
              else
                  next_ENDDECS = 1'b0;
            end
          else
              next_ENDDECS = 1'b0;
        end

      non_intra_quantiser_matrix :
        begin
          if(v_interrpt_n == no_break && FERROR == no_error) 
            begin
              if(qm_count == 7'h40)     
                  next_ENDDECS = 1'b1;
              else
                  next_ENDDECS = 1'b0;
            end
          else
              next_ENDDECS = 1'b0;
        end
      default :    
          next_ENDDECS = 1'b0;
    endcase
  end

always @(state or STREAM or v_interrpt_n or qm_count or qm_flag or pre_SHIFT or FERROR)
  begin
    case(state)
      load_intra_quantiser_matrix :
        begin
          if(v_interrpt_n == no_break &&  FERROR == no_error)
            begin
              if(pre_SHIFT == 6'h01 && STREAM[31] == 1'b0 && qm_flag == 1'b1) 
                  next_ENDDECQ = 1'b1;
              else
                  next_ENDDECQ = 1'b0;
            end
          else
              next_ENDDECQ = 1'b0;
        end

      load_non_intra_quantiser_matrix :
        begin
          if(v_interrpt_n == no_break &&  FERROR == no_error)
            begin
              if(pre_SHIFT == 6'h00 && STREAM[31] == 1'b0 && qm_flag == 1'b1) 
                  next_ENDDECQ = 1'b1;
              else 
                  next_ENDDECQ = 1'b0;
            end
          else
              next_ENDDECQ = 1'b0;
        end

      non_intra_quantiser_matrix :
        begin
          if(v_interrpt_n == no_break && FERROR == no_error)
            begin
              if(qm_count == 7'h3F && qm_flag == 1'b1) 
                  next_ENDDECQ = 1'b1;
              else
                  next_ENDDECQ = 1'b0;
            end
          else
              next_ENDDECQ = 1'b0;
        end
       
      default :    // other state
          next_ENDDECQ = 1'b0;

    endcase
  end

always @(state or KICKQ or v_interrpt_n or STREAM or FERROR) 
  begin
    case(state)
      IDLE :
        begin
          if(v_interrpt_n == no_break && FERROR == no_error) 
            begin
              if(KICKQ == 1'b1)
                  next_QMSYNI = 1'b0;
              else
                  next_QMSYNI = 1'b1;
            end
          else
              next_QMSYNI = 1'b1;
        end
          
      vbv_buffer_size_value :
        begin
          if(v_interrpt_n == no_break && FERROR == no_error) 
            begin
              if(STREAM[30] == 1'b1) 
                  next_QMSYNI = 1'b0;
              else
                  next_QMSYNI = 1'b1;
            end
          else
              next_QMSYNI = 1'b1;
        end 

      default :
          next_QMSYNI = 1'b1;
    
    endcase
  end

always @(state or v_interrpt_n or FERROR or STREAM or qm_count or pre_SHIFT)
  begin
    case(state)
      load_intra_quantiser_matrix :
        begin
          if(v_interrpt_n == no_break && FERROR == no_error)
            begin
              if(pre_SHIFT == 6'h01 && STREAM[31] == 1'b1) 
                  next_QMSYNN = 1'b0;       
              else
                  next_QMSYNN = 1'b1;
            end
          else
              next_QMSYNN = 1'b1;
        end

      intra_quantiser_matrix :
        begin
          if(v_interrpt_n == no_break && FERROR == no_error)
            begin
              if(qm_count >= 7'h40 && STREAM[31] == 1'b1) 
                  next_QMSYNN = 1'b0;
              else
                  next_QMSYNN = 1'b1;
            end
          else
              next_QMSYNN = 1'b1;
        end

      default :
          next_QMSYNN = 1'b1;

    endcase
  end

always @(y1_bs_wait_n or FERROR)
  begin
    if(y1_bs_wait_n == 1'b1 && FERROR == error)
        v_ferror = error;
    else
        v_ferror = no_error;
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0)
        v_dly_ferror  <= 1'b0;
    else if(g_swrst_r_n == 1'b0)
        v_dly_ferror <= 1'b0;
    else
        v_dly_ferror <= v_ferror;
  end

always @(state or v_interrpt_n or qm_count or pre_SHIFT or
        v_dly_ferror)
  begin
    case(state)
      load_intra_quantiser_matrix :
        begin
          if(v_interrpt_n == no_break && v_dly_ferror == no_error)
            begin
              if(pre_SHIFT == 6'h08)   
                  next_QMSELI = 1'b1;
              else
                  next_QMSELI = 1'b0;
            end
          else
              next_QMSELI = 1'b0;
        end

      intra_quantiser_matrix :
        begin
          if(v_interrpt_n == no_break && v_dly_ferror == no_error)
            begin
              if(qm_count == 7'h40)   
                  next_QMSELI = 1'b0;
              else if(qm_count < 7'h40) 
                  next_QMSELI = 1'b1;
              else
                  next_QMSELI = 1'b0;
            end
          else
              next_QMSELI = 1'b0;
        end

      default :      
          next_QMSELI = 1'b0;
  

    endcase
  end

always @(state or v_interrpt_n or qm_count or pre_SHIFT or 
        v_dly_ferror)
  begin
    case(state)
      load_non_intra_quantiser_matrix :
        begin
          if(v_interrpt_n == no_break && v_dly_ferror == no_error)
            begin
              if(pre_SHIFT == 6'h08)   
                  next_QMSELN = 1'b1;
              else
                  next_QMSELN = 1'b0;
            end
          else
              next_QMSELN = 1'b0;
        end

      non_intra_quantiser_matrix :
        begin
          if(v_interrpt_n == no_break && v_dly_ferror == no_error)
            begin
              if(qm_count == 7'h40)       
                  next_QMSELN = 1'b0;
              else if(qm_count < 7'h40)    
                  next_QMSELN = 1'b1;
              else                    
                  next_QMSELN = 1'b0;
            end
          else
              next_QMSELN = 1'b0;
        end

      default :  
          next_QMSELN = 1'b0;

    endcase
  end 

 
always @(state or v_interrpt_n or KICKS or KICKQ or FERROR or qm_flag)
  begin
    if(v_interrpt_n == no_break && FERROR == no_error )
      begin
        case(state)
          IDLE :
            begin
              if(KICKS == 1'b1)   
                  next_qm_flag = 1'b0;
              else if(KICKQ == 1'b1) 
                  next_qm_flag = 1'b1;
              else                      
                  next_qm_flag = qm_flag;
            end

          default :  
              next_qm_flag = qm_flag;
        endcase
      end
    else
        next_qm_flag = 1'b0;
  end
 

always @(state or v_interrpt_n or  qm_count or FERROR or pre_SHIFT)
  begin
    if(v_interrpt_n == no_break && FERROR == no_error)
      begin
        case(state)
          load_intra_quantiser_matrix :
            begin
              if(pre_SHIFT == 6'h08)
                  next_qm_count = qm_count + 1;
              else
                  next_qm_count = qm_count;
            end

          intra_quantiser_matrix :
            begin
              if(qm_count < 7'h40) 
                  next_qm_count = qm_count + 1;
              else
                  next_qm_count = 7'h00; 
            end
          load_non_intra_quantiser_matrix :
              next_qm_count = qm_count + 1;

          non_intra_quantiser_matrix :
            begin
              if(qm_count < 7'h40)
                  next_qm_count = qm_count + 1;
              else
                  next_qm_count = 7'h00;
            end

          default :
              next_qm_count = 7'h00;
        endcase
      end
    else
      begin
        next_qm_count = 7'h00; 
      end
  end 

always @(state or v_interrpt_n or qm_count or pre_SHIFT or 
        v_dly_ferror or STREAM)
  begin
    if(v_interrpt_n == no_break && v_dly_ferror == no_error)
      begin
        case(state)
          load_intra_quantiser_matrix :
            begin
              if(pre_SHIFT == 6'h08) 
                  next_qm = 8'h08; 
              else
                  next_qm = disable_qm;
            end

          intra_quantiser_matrix :
            begin
              if(qm_count < 7'h40) 
                  next_qm = STREAM[31:24];
              else
                  next_qm = disable_qm;
            end

          load_non_intra_quantiser_matrix :
            begin
              if(pre_SHIFT == 6'h08) 
                  next_qm = STREAM[31:24];  
              else
                  next_qm = 8'h00;
            end

          non_intra_quantiser_matrix :
            begin
              if(qm_count < 7'h40) 
                  next_qm = STREAM[31:24];
              else
                  next_qm = 8'h00;
            end
 
          default :
              next_qm = 8'h00;
        endcase
      end
    else
        next_qm = 8'h00;
  end

always @(state or v_interrpt_n or KICKS)
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          IDLE :
            begin
              if(KICKS == 1'b1)
                  PARAA = 8'h00;
              else
                  PARAA = 8'hFF;
            end
          vertical_size_value  :
              PARAA = 8'h02;
          frame_rate_code :
              PARAA = 8'h04;
          bit_rate_value :
              PARAA = 8'h05;
          vbv_buffer_size_value :
              PARAA = 8'h06;
          default :
              PARAA = 8'hFF;      
        endcase
      end
    else
        PARAA = 8'hFF;
  end 


always @(state or v_interrpt_n or qm_count or STREAM or KICKS)
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          IDLE :
            begin
              if(KICKS == 1'b1 &&      
                ((STREAM[31:20] == 12'h000 || STREAM[31:20] > 12'h780) 
                ||(STREAM[19:8] == 12'h000 || STREAM[19:8] >12'h440)))
                  FERROR = error;
              else
                  FERROR = no_error;
            end
          intra_quantiser_matrix :
            begin
              if(qm_count < 7'h40 && STREAM[31:24] == 8'h00) 
                  FERROR = error;
              else
                  FERROR = no_error;
            end
          non_intra_quantiser_matrix :
            begin
              if(qm_count < 7'h40 && STREAM[31:24] == 8'h00) 
                  FERROR = error;
              else
                  FERROR = no_error;
            end
          default :  
              FERROR = no_error;
        endcase
      end
    else
        FERROR = no_error;
  end

always @(state or v_interrpt_n or STREAM or pre_SHIFT)
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          vertical_size_value :
            begin
              if(STREAM[27:24] == 4'b0000  
                || (STREAM[27:24] >= 4'b1001 &&  STREAM[27:24] <= 4'b1111))
                  NFERROR = error;
              else
                  NFERROR = no_error;
            end
          frame_rate_code :
            begin
              if(STREAM[31:14] == 18'h00000)  
                  NFERROR = error;
              else
                  NFERROR = no_error;
            end
          bit_rate_value :
            begin
              if(STREAM[31] == 1'b0) 
                  NFERROR = error;
              else
                  NFERROR = no_error;
            end
          load_intra_quantiser_matrix :
            begin
              if(pre_SHIFT == 6'h08 && STREAM[31:24] != 8'h08)
                  NFERROR = error;
              else
                  NFERROR = no_error;
            end

          default :
              NFERROR = no_error;
        endcase
      end
    else
        NFERROR = no_error;
  end


assign kick = {KICKS, KICKQ};

always @(kick or pre_SHIFT)
  begin
    case(kick)  
      2'b10 :  SHIFT = 6'h18; 
      2'b01 :  SHIFT = 6'h01;  
      default : SHIFT = pre_SHIFT; 
    endcase
  end

endmodule 

 
