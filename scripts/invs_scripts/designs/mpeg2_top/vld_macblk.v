// ----------------------------------------------
// File: vld_macblk.v
// Module: vld_macblk
// Function:macroblock analyzer
// ----------------------------------------------

module vld_macblk(
                      clkdec,
                      rstdec_x,
                      g_swrst_r_n,
                      v_mbastrt_r_s,
                      v_mbpl_vld_r,
                      y1_bs_wait_n,
                      v_interrpt_n,  
                      FRAME_PRED_FRAME_DCT,
                      CONCEALMENT_MOTION_VECTORS,
                      SLICE_END, MPEG1,
                      FCODE_00,
                      FCODE_01,
                      FCODE_10,
                      FCODE_11, 
                      PICTURE_CODING_TYPE,
                      FORWARD_F_CODE,
                      BACKWARD_F_CODE,
                      PICTURE_STRUCTURE,
                      STREAM,
                      v_mbhend_r_s,
                      FERROR,
                      NFERROR,
                      AFTER_INTRA,
                      SHIFT,
                      CBP,
                      PARAA,
                      PARAD,
                      v_mbadet_r_s,
                      v_blkstart_r_s,
                      v_macstate_r,
                      v_mbmot_type_r
                      );

  input        clkdec;     
  input        rstdec_x;   
  input        g_swrst_r_n; 
  input        v_mbastrt_r_s;            // MBA start
  input        v_mbpl_vld_r;             // MB start
  input        y1_bs_wait_n;               // Wait signal
  input        v_interrpt_n;             // Break signal
  input        FRAME_PRED_FRAME_DCT;       // frame_pred_frame_dct
  input        CONCEALMENT_MOTION_VECTORS; // concealment_motion_vector
  input        SLICE_END;                  // slice deocode end
  input        MPEG1;                      // 1:MPEG1, 0:MPEG2
  input [3:0]  FCODE_00;                   // forward_horizontal_f_code
  input [3:0]  FCODE_01;                   // forward_vertical_f_code
  input [3:0]  FCODE_10;                   // backward_horizontal_f_code
  input [3:0]  FCODE_11;                   // backward_vertical_f_code
  input [2:0]  PICTURE_CODING_TYPE;        // picture_coding_type
  input [2:0]  FORWARD_F_CODE;             // forward_f_code(MPEG-1)
  input [2:0]  BACKWARD_F_CODE;            // backward_f_code(MPEG-2)
  input [1:0]  PICTURE_STRUCTURE;          // picture_structure
  input [11:0] STREAM;                     // bit stream(12bit)

  output       v_mbhend_r_s;   // MB decode end
  output       FERROR;           // fatal error
  output       NFERROR;          // non fatal error
  output       AFTER_INTRA;      // macroblock_intra
  output [5:0] SHIFT;            // shift data
  output [5:0] CBP;              // coded_block_pattern
  output [7:0] PARAA;            // address
  output [17:0] PARAD;            // data
  output        v_mbadet_r_s;   // MBA find signal
  output        v_blkstart_r_s; // 6 block start signal
  output [3:0]  v_macstate_r;   // macroblock state
  output [1:0]  v_mbmot_type_r; // motion_type 

  reg           v_mbhend_r_s;  
  reg           FERROR;        
  reg           NFERROR;       
  reg           next_enddec;      
  reg           slice_head_r;     
  reg           AFTER_INTRA;      
  reg           next_AFTER_INTRA;      
  reg           mmfwd, mmbwd;          
  reg           next_mmfwd, next_mmbwd;
  reg           mb_pattern, mb_quant;  
  reg           next_mb_pattern, next_mb_quant;
  reg           dmv, next_dmv;
  reg           mv_format, next_mv_format;
  reg           vecidx_s_r;   // FWD/BWD
  reg           next_s;       // FWD/BWD
  reg           vecidx_t_r;   // horisontal/vertical
  reg           next_t;       // horisontal/vertical
  reg           vecidx_r_r;   // 1st.\/2nd
  reg           next_r;       // 1st.\/2nd
  reg           mismatch;                     // "1" if find VLD mismatch
  reg           mark;                         // get tempolary marker
  reg [1:0]     motion_vector_count;    // motion count
  reg [1:0]     next_motion_vector_count;    // next motion count
  reg [1:0]     forward_f, backward_f;        // for MPEG1
  reg [2:0]     forward_r_size;         // forward size 
  reg [2:0]     backward_r_size;        // backward size
  reg [3:0]     next_state;        // next_state:Result of combination logic.
  reg [3:0]     temp_fcode;        // fcode
  reg [3:0]     temp2_fcode;       // fcode2
  reg [5:0]     SHIFT;                  // shift data
  reg [5:0]     temp_next_SHIFT;        // shift data (not marker bit)
  reg [5:0]     CBP;                    // coded block pattern
  reg [5:0]     next_CBP;               // next coded block pattern
  reg [5:0]     m_code;                 // cotion code
  reg [5:0]     next_m_code;            // motion_code hold register
  reg [7:0]     PARAA;                  // adress 
  reg [7:0]     paraa_a;                // adress(select)
  reg [7:0]     adr_inc;                // escape of adress increment
  reg [7:0]     next_adr_inc;           // hold "escape" of adrress increment
  reg [7:0]     adr_hld;                // adress invrement for dct_type
  reg [7:0]     next_adr_hld;           // hold adress increment for dct_type
  reg [17:0]    PARAD;                 // parameter data
  reg           next_v_mbadet_r_s;   // find macroblock_address_increment
  reg           v_mbadet_r_s;        // find MBA hold register
  reg [3:0]     v_macstate_r;         // macroblock state
  reg [1:0]     v_mbmot_type_r;       // motion type 
  reg [1:0]     next_v_mbmot_type;
  reg           v_blkstart_r_s;             // 6 block start signal

  parameter   P_IDLE=4'b0000;
  parameter   P_MBAI=4'b0001;
  parameter   P_MTYP=4'b0010;
  parameter   P_FRMT=4'b0011;
  parameter   P_FLMT=4'b0100;
  parameter   P_DTYP=4'b0101;
  parameter   P_QSCD=4'b0110;
  parameter   P_MVFS=4'b0111;
  parameter   P_MCOD=4'b1000;
  parameter   P_MRES=4'b1001;
  parameter   P_DMVC=4'b1010;
  parameter   P_CBP0=4'b1011;
  parameter   P_STFF=4'b1100;
  parameter   P_WAIT=4'b1101;

  parameter       P_ERROR = 1'b1, P_NO_ERROR = 1'b0;

  parameter       P_FIELD = 1'b0, P_FRAME = 1'b1;

  parameter       P_MPEG_1 = 1'b1, P_MPEG_2 = 1'b0;

  always @(posedge clkdec or negedge rstdec_x) begin
      if (!rstdec_x) begin 
          v_macstate_r <= P_IDLE; 
      end
      else if(g_swrst_r_n == 1'b0) begin
          v_macstate_r <= P_IDLE; 
      end
      else if(!y1_bs_wait_n) begin 
          v_macstate_r <= v_macstate_r;
      end
      else begin 
          if((!v_interrpt_n) | (FERROR == P_ERROR)) begin
              v_macstate_r <= P_IDLE;
          end
          else begin
              v_macstate_r <= next_state;
          end
      end
  end
  always @(posedge clkdec or negedge rstdec_x) begin
      if (!rstdec_x) 
        begin
            v_mbadet_r_s <= 1'b0;
        end
      else
        if(g_swrst_r_n == 1'b0) begin
            v_mbadet_r_s <= 1'b0;
        end
        else if(!y1_bs_wait_n) begin 
            v_mbadet_r_s <= v_mbadet_r_s;
        end
        else begin
            if((!v_interrpt_n) | (FERROR == P_ERROR)) begin
                v_mbadet_r_s <= 1'b0;
            end
            else begin
                v_mbadet_r_s <= next_v_mbadet_r_s;
            end
        end
  end

  always @(posedge clkdec or negedge rstdec_x) begin
      if (!rstdec_x) begin 
          v_mbhend_r_s   <= 1'b0;
      end
      else if(!g_swrst_r_n)begin
          v_mbhend_r_s   <= 1'b0;
      end
      else if(v_mbhend_r_s) begin 
          v_mbhend_r_s   <= 1'b0;
      end
      else if(!y1_bs_wait_n) begin 
          v_mbhend_r_s   <= v_mbhend_r_s;
      end
      else begin 
          if((!v_interrpt_n)|(FERROR == P_ERROR)) begin
              v_mbhend_r_s   <= 1'b0;
          end
          else begin
              v_mbhend_r_s   <= next_enddec;
          end
      end
  end

  always @(posedge clkdec or negedge rstdec_x) begin
    if (!rstdec_x) begin 
        v_blkstart_r_s <= 1'b0;
    end
    else if(!g_swrst_r_n)begin
        v_blkstart_r_s <= 1'b0;
    end
    else if(!y1_bs_wait_n) begin 
        v_blkstart_r_s <= v_blkstart_r_s;
    end
    else begin 
        if((!v_interrpt_n)|(FERROR == P_ERROR)) begin
            v_blkstart_r_s <= 1'b0;
        end
        else begin
            v_blkstart_r_s <= next_enddec;
        end
    end
  end

  always @(posedge clkdec or negedge rstdec_x) 
    if (!rstdec_x) begin 
        adr_inc <= 8'h00;
        slice_head_r <= 1'b0;
        AFTER_INTRA <= 1'b0;
        mmfwd <= 1'b0;
        mmbwd <= 1'b0;
        mb_pattern <= 1'b0;
        mb_quant <= 1'b0;
        motion_vector_count <= 2'b01;
        dmv <= 1'b0;
        mv_format <= 1'b0;
        vecidx_s_r <= 1'b0;
        vecidx_t_r <= 1'b0;
        vecidx_r_r <= 1'b0;
        adr_hld <= 8'h00;
        m_code <= 6'h00;
        CBP <= 6'h00;
        v_mbmot_type_r <= 2'b00;
    end
    else if(g_swrst_r_n == 1'b0)begin
        adr_inc <= 8'h00;
        slice_head_r <= 1'b0;
        AFTER_INTRA <= 1'b0;
        mmfwd <= 1'b0;
        mmbwd <= 1'b0;
        mb_pattern <= 1'b0;
        mb_quant <= 1'b0;
        motion_vector_count <= 2'b01;
        dmv <= 1'b0;
        mv_format <= 1'b0;
        vecidx_s_r <= 1'b0;
        vecidx_t_r <= 1'b0;
        vecidx_r_r <= 1'b0;
        adr_hld <= 8'h00;
        m_code <= 6'h00;
        CBP <= 6'h00;
        v_mbmot_type_r <= 2'b00;
    end
    else if(y1_bs_wait_n) begin
        adr_inc <= next_adr_inc;
        slice_head_r <= (SLICE_END | ((~v_mbpl_vld_r) & slice_head_r));
        AFTER_INTRA <= next_AFTER_INTRA;
        mmfwd <= next_mmfwd;
        mmbwd <= next_mmbwd;
        mb_pattern <= next_mb_pattern;
        mb_quant <= next_mb_quant;
        motion_vector_count <= next_motion_vector_count;
        dmv <= next_dmv;
        mv_format <= next_mv_format;
        vecidx_s_r <= next_s;
        vecidx_t_r <= next_t;
        vecidx_r_r <= next_r;
        adr_hld <= next_adr_hld;
        m_code <= next_m_code;
        CBP <= next_CBP;
        v_mbmot_type_r <= next_v_mbmot_type;
    end
    else begin 
        adr_inc <= adr_inc;
        slice_head_r <= slice_head_r;
        AFTER_INTRA <= AFTER_INTRA;
        mmfwd <= mmfwd;
        mmbwd <= mmbwd;
        mb_pattern <= mb_pattern;
        mb_quant <= mb_quant;
        motion_vector_count <= motion_vector_count;
        dmv <= dmv;
        mv_format <= mv_format;
        vecidx_s_r <= vecidx_s_r;
        vecidx_t_r <= vecidx_t_r;
        vecidx_r_r <= vecidx_r_r;
        adr_hld <= adr_hld;
        m_code <= m_code;
        CBP <= CBP;
        v_mbmot_type_r <= v_mbmot_type_r;
    end

  always @(v_macstate_r or     
           v_mbpl_vld_r or     
           STREAM or             
           vecidx_t_r or                 
           mb_quant or           
           motion_vector_count or
           mmfwd or      
           dmv or         
           CONCEALMENT_MOTION_VECTORS  or 
           vecidx_r_r or           
           mmbwd or            
           m_code or            
           SLICE_END or           
           mb_pattern or          
           PICTURE_STRUCTURE or     
           FRAME_PRED_FRAME_DCT or   
           vecidx_s_r or      
           mv_format or             
           AFTER_INTRA or            
           adr_inc or                 
           adr_hld or                 
           MPEG1 or                   
           forward_f or                
           backward_f or               
           v_mbastrt_r_s or    
           temp_fcode)          
    begin
        case(v_macstate_r)
          P_IDLE:
            if(v_mbastrt_r_s || SLICE_END)begin               
                if(MPEG1==P_MPEG_1&&STREAM[11:1]==11'b00000001111)begin
                    next_state = P_STFF;
                end 
                else begin         
                    next_state = P_MBAI;
                end
            end
            else begin                     
                next_state = P_IDLE;
            end
 
          P_MBAI: 
            begin
                if(adr_inc != 8'h00 && adr_hld != 8'h00) begin
                    next_state = v_macstate_r;
                end
                else begin 
                    next_state = P_WAIT;
                end
            end
          P_WAIT :
            begin
                if(v_mbpl_vld_r == 1'b1) begin 
                    next_state = P_MTYP;
                end
                else begin
                    next_state = v_macstate_r;
                end
            end
 
          P_MTYP: begin
              if(MPEG1 == P_MPEG_2) begin
                  if((mmfwd==1'b1 || mmbwd==1'b1)
                     &&(PICTURE_STRUCTURE==2'b11)
                     &&(FRAME_PRED_FRAME_DCT==1'b0)) begin
                      next_state = P_FRMT;
                  end
                  else if((mmfwd==1'b1 || mmbwd==1'b1) 
                          &&(PICTURE_STRUCTURE==2'b01 ||
                             PICTURE_STRUCTURE==2'b10)) begin
                      next_state = P_FLMT;
                  end
                  else if((PICTURE_STRUCTURE==2'b11) &
                          (FRAME_PRED_FRAME_DCT==1'b0) &
                          (AFTER_INTRA | mb_pattern))begin
                      next_state = P_DTYP;
                  end
                  else if(mb_quant) begin
                      next_state = P_QSCD;
                  end
                  else if(mmfwd||(AFTER_INTRA && CONCEALMENT_MOTION_VECTORS))
                    begin
                        if(motion_vector_count==2'b01) begin
                            if((mv_format == P_FIELD)&&(dmv!=1'b1)) begin
                                next_state = P_MVFS; 
                            end
                            else begin
                                next_state = P_MCOD; 
                            end
                        end
                        else begin
                            next_state = P_MVFS;
                        end
                    end
                  else if(mmbwd) begin 
                      if(motion_vector_count==2'b01) begin
                          if((mv_format == P_FIELD)&&(dmv!=1'b1)) begin
                              next_state = P_MVFS;  
                          end
                          else begin
                              next_state = P_MCOD; 
                          end
                      end
                      else begin
                          next_state = P_MVFS; 
                      end
                  end
                  else if(mb_pattern) begin
                      next_state = P_CBP0;
                  end
                  else begin    
                      next_state = P_IDLE;
                  end
              end
              else begin
                  if(mb_quant) begin
                      next_state = P_QSCD;
                  end
                  else if(mmfwd==1'b1) begin 
                      next_state = P_MCOD;
                  end
                  else if(mmbwd==1'b1) begin
                      next_state = P_MCOD;
                  end
                  else if(mb_pattern) begin 
                      next_state = P_CBP0;
                  end
                  else begin      
                      next_state = P_IDLE;
                  end
              end
          end

          P_FRMT: 
            begin
                if((PICTURE_STRUCTURE==2'b11) & 
                   (FRAME_PRED_FRAME_DCT==1'b0) &
                   (AFTER_INTRA||mb_pattern))begin
                    next_state = P_DTYP;
                end
                else if(mb_quant) begin
                    next_state = P_QSCD;
                end
                else if(mmfwd||(AFTER_INTRA && CONCEALMENT_MOTION_VECTORS))
                  begin
                      if(motion_vector_count==2'b01) begin
                          if((mv_format == P_FIELD)&&(dmv!=1'b1)) begin
                              next_state = P_MVFS;
                          end
                          else begin
                              next_state = P_MCOD;
                          end
                      end
                      else begin
                          next_state = P_MVFS; 
                      end
                  end
                else if(mmbwd) begin  
                    if(motion_vector_count==2'b01) begin
                        if((mv_format == P_FIELD)&&(dmv!=1'b1)) begin
                            next_state = P_MVFS; 
                        end
                        else begin
                            next_state = P_MCOD; 
                        end
                    end
                    else begin
                        next_state = P_MVFS; 
                    end
                end
                else if(mb_pattern) begin
                    next_state = P_CBP0;
                end
                else begin  
                    next_state = P_IDLE;
                end
            end

          P_FLMT: 
            begin
                if((PICTURE_STRUCTURE==2'b11) & 
                   (FRAME_PRED_FRAME_DCT==1'b0) & 
                   (AFTER_INTRA||mb_pattern))begin
                    next_state = P_DTYP;
                end
                else if(mb_quant) begin
                    next_state = P_QSCD;
                end
                else if(mmfwd||(AFTER_INTRA && CONCEALMENT_MOTION_VECTORS)) 
                  begin
                      if(motion_vector_count==2'b01) begin
                          if((mv_format == P_FIELD)&&(dmv!=1'b1)) begin
                              next_state = P_MVFS; 
                          end
                          else begin
                              next_state = P_MCOD;
                          end
                      end
                      else begin
                          next_state = P_MVFS; 
                      end
                  end
                else if(mmbwd) begin   
                    if(motion_vector_count==2'b01) begin
                        if((mv_format == P_FIELD)&&(dmv!=1'b1)) begin
                             next_state = P_MVFS; 
                        end
                        else begin
                            next_state = P_MCOD; 
                        end
                    end
                    else begin
                        next_state = P_MVFS; 
                    end
                end
                else if (mb_pattern) begin
                    next_state = P_CBP0;
                end
                else begin    
                    next_state = P_IDLE;
                end
            end

          P_DTYP: 
            begin
                if(mb_quant) begin
                    next_state = P_QSCD;
                end
                else if(mmfwd||(AFTER_INTRA && CONCEALMENT_MOTION_VECTORS))
                  begin
                      if(motion_vector_count==2'b01) begin
                          if((mv_format == P_FIELD)&&(dmv!=1'b1)) begin
                              next_state = P_MVFS; 
                          end
                          else begin
                              next_state = P_MCOD; 
                          end
                      end
                      else begin
                           next_state = P_MVFS; 
                      end
                  end
                else if(mmbwd) begin    
                    if(motion_vector_count==2'b01) begin
                        if((mv_format == P_FIELD)&&(dmv!=1'b1)) begin
                            next_state = P_MVFS; 
                        end
                        else begin
                            next_state = P_MCOD; 
                        end
                    end
                    else begin
                        next_state = P_MVFS; 
                    end
                end
                else if (mb_pattern) begin
                    next_state = P_CBP0;
                end
                else begin    
                    next_state = P_IDLE;
                end
            end

          P_QSCD: 
            if (MPEG1 == P_MPEG_2) 
              begin
                  if(mmfwd||(AFTER_INTRA && CONCEALMENT_MOTION_VECTORS)) begin
                      if(motion_vector_count==2'b01) begin
                          if((mv_format == P_FIELD)&&(dmv!=1'b1)) begin
                              next_state = P_MVFS; 
                          end
                          else begin
                              next_state = P_MCOD; 
                          end
                      end
                      else begin
                          next_state = P_MVFS; 
                      end
                  end
                  else if(mmbwd) begin   
                      if(motion_vector_count==2'b01) begin
                          if((mv_format == P_FIELD)&&(dmv!=1'b1)) begin
                              next_state = P_MVFS; 
                          end
                          else begin
                              next_state = P_MCOD;
                          end
                      end
                      else begin
                          next_state = P_MVFS; 
                      end
                  end
                  else if (mb_pattern) begin
                      next_state = P_CBP0;
                  end
                  else begin    
                      next_state = P_IDLE;
                  end
              end
            else begin
                if(mmfwd==1'b1) begin     
                    next_state = P_MCOD;
                end
                else if(mmbwd==1'b1) begin 
                    next_state = P_MCOD;
                end
                else if(mb_pattern)  begin 
                    next_state = P_CBP0;
                end
                else begin   
                    next_state = P_IDLE;
                end
            end
          P_MVFS: 
            begin
                next_state = P_MCOD;
            end

          P_MCOD:  
            if (MPEG1 == P_MPEG_2) 
              begin
                  if ((temp_fcode !=4'h1)&&(m_code!=6'h00)) begin
                      next_state = P_MRES;
                  end
                  else if (dmv == 1'b1) begin
                      next_state = P_DMVC;
                  end
                  else if(vecidx_t_r == 1'b0) begin  
                      next_state = P_MCOD;
                  end
                  else if ((motion_vector_count!=2'b01)&&(vecidx_r_r==1'b0)) begin 
                      next_state = P_MVFS;
                  end
                  else if (vecidx_s_r==1'b0) begin  
                      if(mmbwd) begin  
                          if(motion_vector_count==2'b01) begin
                              if((mv_format == P_FIELD)&&(dmv!=1'b1)) begin
                                  next_state = P_MVFS;
                              end
                              else begin
                                  next_state = P_MCOD; 
                              end
                          end
                          else begin
                              next_state = P_MVFS;
                           end
                      end
                      else if (mb_pattern) begin
                          next_state = P_CBP0;
                      end
                      else begin    
                          next_state = P_IDLE;
                      end
                  end 
                  else begin    
                      if (mb_pattern) begin
                          next_state = P_CBP0;
                      end
                      else begin   
                          next_state = P_IDLE;
                      end
                  end
              end
            else 
              begin
                  if (((vecidx_s_r==1'b0&&forward_f!=2'b01)||
                       (vecidx_s_r==1'b1&&backward_f!=2'b01))
                      &&(m_code!=6'h00)) begin
                      next_state = P_MRES;
                  end
                  else if(vecidx_t_r == 1'b0) begin 
                      next_state = P_MCOD; 
                  end
                  else if(vecidx_s_r==1'b0 &&mmbwd==1'b1) begin
                      next_state = P_MCOD;
                  end
                  else if(mb_pattern) begin  
                      next_state = P_CBP0;
                  end
                  else begin   
                      next_state = P_IDLE;
                  end
              end

          P_MRES: 
            if(MPEG1 == P_MPEG_2)begin 
                  if(dmv == 1'b1) 
                    next_state = P_DMVC; 
                  else if(vecidx_t_r == 1'b0)   
                    next_state = P_MCOD; 
                  else if((motion_vector_count!=2'b01)&&(vecidx_r_r==1'b0))
                    next_state = P_MVFS; 
                  else if (vecidx_s_r==1'b0) begin   
                      if(mmbwd) begin    
                          if(motion_vector_count==2'b01) begin
                              if((mv_format == P_FIELD)&&(dmv!=1'b1)) begin
                                  next_state = P_MVFS; 
                              end
                              else begin
                                  next_state = P_MCOD; 
                              end
                          end
                          else begin
                              next_state = P_MVFS; 
                          end
                      end
                      else if (mb_pattern) begin
                          next_state = P_CBP0;
                      end
                      else begin      
                          next_state = P_IDLE;
                      end
                  end
                  else  begin   
                      if (mb_pattern) begin
                          next_state = P_CBP0;
                      end
                      else begin  
                          next_state = P_IDLE;
                      end
                  end
              end
            else 
              begin
                  if(vecidx_t_r == 1'b0)  
                    next_state = P_MCOD; 
                  else if((vecidx_s_r == 1'b0) & (mmbwd == 1'b1))
                    next_state = P_MCOD;
                  else if(mb_pattern)    
                    next_state = P_CBP0;
                  else     
                    next_state = P_IDLE;
              end

          P_DMVC: 
            begin
                if(vecidx_t_r == 1'b0) begin     
                    next_state = P_MCOD;
                end
                else if((motion_vector_count!=2'b01)&&(vecidx_r_r==1'b0)) 
                  begin
                      next_state = P_MVFS;
                  end
                else if (vecidx_s_r==1'b0) begin    
                    if(mmbwd) begin     
                        if(motion_vector_count==2'b01) begin
                            if((mv_format == P_FIELD)&&(dmv!=1'b1)) begin
                                next_state = P_MVFS; 
                            end
                            else begin
                                next_state = P_MCOD; 
                            end
                        end
                        else begin
                            next_state = P_MVFS; 
                        end
                    end
                    else if (mb_pattern) begin
                        next_state = P_CBP0;
                    end
                    else begin     
                        next_state = P_IDLE;
                    end
                end  
                else  begin   
                    if (mb_pattern) begin
                        next_state = P_CBP0;
                    end
                    else begin  
                        next_state = P_IDLE;
                    end
                end
            end

          P_CBP0: 
            begin
                next_state = P_IDLE;
            end
          
          P_STFF: 
            begin
                if(STREAM[11:1]==11'b00000001111)begin
                    next_state = v_macstate_r;
                end
                else begin
                    next_state = P_MBAI;
                end 
            end
          default:
            begin
                next_state = P_IDLE;
            end
        endcase
    end

always @(v_macstate_r or
         v_mbpl_vld_r or 
         //v_interrpt_n or 
         vecidx_t_r or 
         mb_quant or 
         motion_vector_count or 
         mmfwd or 
         dmv or 
         CONCEALMENT_MOTION_VECTORS  or 
         vecidx_r_r or 
         mmbwd or 
         m_code or 
         mb_pattern or 
         PICTURE_STRUCTURE or
         FRAME_PRED_FRAME_DCT or 
         vecidx_s_r or 
         mv_format or 
         AFTER_INTRA or 
         MPEG1 or 
         forward_f or 
         backward_f or 
         temp_fcode)
   begin
      case(v_macstate_r)
        P_IDLE:
          paraa_a = 8'hFF;
        P_MBAI: 
          paraa_a = 8'hFF;
        P_WAIT :
          if(v_mbpl_vld_r == 1'b1)
              paraa_a = 8'h51;
          else
              paraa_a = 8'hFF;
        P_MTYP: begin
            if(MPEG1 == P_MPEG_2) begin
                if((mmfwd==1'b1 || mmbwd==1'b1)
                   &&(PICTURE_STRUCTURE==2'b11)
                   &&(FRAME_PRED_FRAME_DCT==1'b0)) begin
                    paraa_a = 8'h52;
                end
                else if((mmfwd==1'b1 || mmbwd==1'b1) 
                        &&(PICTURE_STRUCTURE==2'b01 ||
                           PICTURE_STRUCTURE==2'b10)) begin
                    paraa_a = 8'h52;
                end
                else if((PICTURE_STRUCTURE==2'b11) &
                        (FRAME_PRED_FRAME_DCT==1'b0) &
                        (AFTER_INTRA||mb_pattern))begin
                    paraa_a = 8'h53;
                end
                else if(mb_quant) begin
                    paraa_a = 8'h54;
                end
                else if(mmfwd||(AFTER_INTRA &&
                                CONCEALMENT_MOTION_VECTORS))begin
                    if(motion_vector_count==2'b01) begin
                        if((mv_format == P_FIELD)&&(dmv!=1'b1))
                          paraa_a = 8'h60;
                        else
                          paraa_a = 8'h61;
                    end
                    else
                      paraa_a = 8'h60;
                end
                else if(mmbwd) begin
                    if(motion_vector_count==2'b01) begin
                        if((mv_format == P_FIELD)&&(dmv!=1'b1))
                          paraa_a = 8'h68;
                         else
                          paraa_a = 8'h69;
                    end
                    else
                      paraa_a = 8'h68;
                end
                else if(mb_pattern)
                  paraa_a = 8'h55;
                else  
                  paraa_a = 8'hFF;
            end
            else begin
                if(mb_quant)
                  paraa_a = 8'h54;
                else if(mmfwd==1'b1)
                  paraa_a = 8'h61;
                else if(mmbwd==1'b1)
                  paraa_a = 8'h69;
                else if(mb_pattern) 
                  paraa_a = 8'h55;
                else                 
                  paraa_a = 8'hFF;
            end
        end
        P_FRMT: 
          begin
              if((PICTURE_STRUCTURE==2'b11) & (FRAME_PRED_FRAME_DCT==1'b0) &
                 (AFTER_INTRA||mb_pattern))
                paraa_a = 8'h53;
              else if(mb_quant)
                paraa_a = 8'h54;
              else if(mmfwd||(AFTER_INTRA && CONCEALMENT_MOTION_VECTORS)) 
                begin
                    if(motion_vector_count==2'b01) begin
                        if((mv_format == P_FIELD)&&(dmv!=1'b1))
                          paraa_a = 8'h60;
                        else
                          paraa_a = 8'h61;
                    end
                    else
                      paraa_a = 8'h60;
                end
              else if(mmbwd) begin   
                  if(motion_vector_count==2'b01) begin
                      if((mv_format == P_FIELD)&&(dmv!=1'b1))
                        paraa_a = 8'h68;
                      else
                        paraa_a = 8'h69;
                  end
                  else
                    paraa_a = 8'h68;
              end
              else if(mb_pattern)
                paraa_a = 8'h55;
              else     
                paraa_a = 8'hFF;
          end
        P_FLMT: 
          begin
              if((PICTURE_STRUCTURE==2'b11) & (FRAME_PRED_FRAME_DCT==1'b0) &
                 (AFTER_INTRA||mb_pattern))
                paraa_a = 8'h53;
              else if(mb_quant)
                paraa_a = 8'h54;
              else if(mmfwd||(AFTER_INTRA && CONCEALMENT_MOTION_VECTORS)) 
                begin
                    if(motion_vector_count==2'b01) begin
                        if((mv_format == P_FIELD)&&(dmv!=1'b1))
                          paraa_a = 8'h60;
                        else
                          paraa_a = 8'h61;
                    end
                    else
                      paraa_a = 8'h60;
                end
              else if(mmbwd) begin    
                  if(motion_vector_count==2'b01) begin
                      if((mv_format == P_FIELD)&&(dmv!=1'b1))
                        paraa_a = 8'h68;
                      else
                        paraa_a = 8'h69;
                  end
                  else
                    paraa_a = 8'h68;
              end
              else if (mb_pattern)
                paraa_a = 8'h55;
              else      
                paraa_a = 8'hFF;
          end
        P_DTYP: 
            begin
                if(mb_quant) begin
                    paraa_a = 8'h54;
                end
                else if(mmfwd||(AFTER_INTRA && CONCEALMENT_MOTION_VECTORS)) 
                  begin
                      if(motion_vector_count==2'b01) begin
                          if((mv_format == P_FIELD)&&(dmv!=1'b1))
                            paraa_a = 8'h60;
                          else
                            paraa_a = 8'h61;
                      end
                      else 
                        paraa_a = 8'h60;
                  end
                else if(mmbwd) begin        
                    if(motion_vector_count==2'b01) begin
                        if((mv_format == P_FIELD)&&(dmv!=1'b1))
                          paraa_a = 8'h68;
                        else
                          paraa_a = 8'h69;
                    end
                    else
                      paraa_a = 8'h68;
                end
                else if (mb_pattern)
                  paraa_a = 8'h55;
                else    
                  paraa_a = 8'hFF;
            end
        P_QSCD: 
          if (MPEG1 == P_MPEG_2) begin
              if(mmfwd||(AFTER_INTRA && CONCEALMENT_MOTION_VECTORS)) begin
                  if(motion_vector_count==2'b01) begin
                      if((mv_format == P_FIELD)&&(dmv!=1'b1))
                        paraa_a = 8'h60;
                      else 
                        paraa_a = 8'h61;
                  end
                  else 
                    paraa_a = 8'h60;
              end
              else if(mmbwd) begin    
                  if(motion_vector_count==2'b01) begin
                      if((mv_format == P_FIELD)&&(dmv!=1'b1))
                        paraa_a = 8'h68;
                      else 
                        paraa_a = 8'h69;
                  end
                  else 
                    paraa_a = 8'h68;
              end
              else if (mb_pattern) 
                paraa_a = 8'h55;
              else   
                paraa_a = 8'hFF;
          end
          else begin
              if(mmfwd==1'b1)     
                paraa_a = 8'h61;
              else if(mmbwd==1'b1)   
                paraa_a = 8'h69;
              else if(mb_pattern)   
                paraa_a = 8'h55;
              else  
                paraa_a = 8'hFF;
          end
        P_MVFS: 
              case ({vecidx_r_r,vecidx_s_r})
                2'b00:  paraa_a = 8'h61; 
                2'b01:  paraa_a = 8'h69; 
                2'b10:  paraa_a = 8'h71; 
                2'b11:  paraa_a = 8'h79; 
              endcase
        P_MCOD:  
          if (MPEG1 == P_MPEG_2) begin
              if ((temp_fcode !=4'h1)&&(m_code!=6'h00)) begin
                  case ({vecidx_r_r,vecidx_s_r,vecidx_t_r})
                    3'b000: paraa_a = 8'h62; 
                    3'b001: paraa_a = 8'h65; 
                    3'b010: paraa_a = 8'h6A; 
                    3'b011: paraa_a = 8'h6D; 
                    3'b100: paraa_a = 8'h72; 
                    3'b101: paraa_a = 8'h75; 
                    3'b110: paraa_a = 8'h7A; 
                    3'b111: paraa_a = 8'h7D; 
                  endcase
              end
              else if (dmv == 1'b1) begin
                  case (vecidx_t_r)
                    1'b0: paraa_a = 8'h63;
                    1'b1: paraa_a = 8'h66;
                  endcase
              end
              else if(vecidx_t_r == 1'b0) begin   
                  case ({vecidx_r_r,vecidx_s_r}) 
                    2'b00: paraa_a = 8'h64; 
                    2'b01: paraa_a = 8'h6C; 
                    2'b10: paraa_a = 8'h74; 
                    2'b11: paraa_a = 8'h7C; 
                  endcase
              end
              else    
                if ((motion_vector_count!=2'b01)&&(vecidx_r_r==1'b0)) 
                  begin
                      case (vecidx_s_r)
                        1'b0: paraa_a = 8'h70; 
                        1'b1: paraa_a = 8'h78; 
                      endcase
                  end
                else   
                  if(vecidx_s_r==1'b0) begin    
                      if(mmbwd)begin      
                          if(motion_vector_count==2'b01) begin
                              if((mv_format == P_FIELD)&&(dmv!=1'b1)) 
                                paraa_a = 8'h68;
                              else 
                                paraa_a = 8'h69;
                          end
                          else 
                            paraa_a = 8'h68;
                      end
                      else if (mb_pattern) 
                        paraa_a = 8'h55;
                      else    
                        paraa_a = 8'hFF;
                  end  
                  else begin   
                      if (mb_pattern) 
                        paraa_a = 8'h55;
                      else  
                        paraa_a = 8'hFF;
                  end
          end
          else begin
              if (((vecidx_s_r == 1'b0 && forward_f != 2'b01) ||
                   (vecidx_s_r == 1'b1 && backward_f != 2'b01))
                  &&(m_code!=6'h00)) begin
                  case ({vecidx_s_r,vecidx_t_r}) 
                    2'b00: paraa_a = 8'h62; 
                    2'b01: paraa_a = 8'h65; 
                    2'b10: paraa_a = 8'h6A; 
                    2'b11: paraa_a = 8'h6D; 
                  endcase
              end
              else if(vecidx_t_r == 1'b0) begin 
                  case ({vecidx_s_r}) 
                    1'b0: paraa_a = 8'h64; 
                    1'b1: paraa_a = 8'h6C; 
                  endcase
              end
              else if(vecidx_s_r==1'b0 &&mmbwd==1'b1) 
                paraa_a = 8'h69;
              else if(mb_pattern)     
                paraa_a = 8'h55;
              else 
                paraa_a = 8'hFF;
          end
        P_MRES: 
          if (MPEG1 == P_MPEG_2) 
            begin
                if (dmv == 1'b1) 
                  begin
                      case (vecidx_t_r) 
                        1'b0: paraa_a = 8'h63;
                        1'b1: paraa_a = 8'h66;
                      endcase
                  end
                else if(vecidx_t_r == 1'b0)     
                  begin
                      case ({vecidx_r_r,vecidx_s_r}) 
                        2'b00: paraa_a = 8'h64; 
                        2'b01: paraa_a = 8'h6C; 
                        2'b10: paraa_a = 8'h74; 
                        2'b11: paraa_a = 8'h7C; 
                      endcase
                  end
                else    
                  if ((motion_vector_count!=2'b01)&&(vecidx_r_r==1'b0))
                    begin
                        case (vecidx_s_r)
                          1'b0: paraa_a = 8'h70; 
                          1'b1: paraa_a = 8'h78; 
                        endcase
                    end
                  else   
                    if (vecidx_s_r==1'b0)begin  
                        if(mmbwd)begin  
                            if(motion_vector_count==2'b01) begin
                                if((mv_format == P_FIELD)&&(dmv!=1'b1)) 
                                  paraa_a = 8'h68;
                                else 
                                  paraa_a = 8'h69;
                            end
                            else 
                              paraa_a = 8'h68;
                        end
                        else if (mb_pattern) 
                          paraa_a = 8'h55;
                        else    
                          paraa_a = 8'hFF;
                    end  
                    else begin   
                        if (mb_pattern) 
                          paraa_a = 8'h55;
                        else     
                          paraa_a = 8'hFF;
                    end
            end
          else begin
              if(vecidx_t_r == 1'b0)begin      
                  case ({vecidx_s_r}) 
                    1'b0: paraa_a = 8'h64;
                    1'b1: paraa_a = 8'h6C; 
                  endcase
              end
              else if(vecidx_s_r==1'b0 &&mmbwd==1'b1) 
                paraa_a = 8'h69;
              else if(mb_pattern)    
                paraa_a = 8'h55;
              else       
                paraa_a = 8'hFF;
          end
        P_DMVC: 
          begin
              if(vecidx_t_r == 1'b0) begin   
                  case ({vecidx_r_r,vecidx_s_r}) 
                    2'b00: paraa_a = 8'h64; 
                    2'b01: paraa_a = 8'h6C;
                    2'b10: paraa_a = 8'h74; 
                    2'b11: paraa_a = 8'h7C; 
                  endcase
              end
              else if((motion_vector_count!=2'b01)&&(vecidx_r_r ==1'b0)) begin
                  case (vecidx_s_r) 
                    1'b0: paraa_a = 8'h70; 
                    1'b1: paraa_a = 8'h78;
                  endcase
              end
              else if(vecidx_s_r == 1'b0) begin     
                  if(mmbwd) begin   
                      if(motion_vector_count==2'b01) begin
                          if((mv_format == P_FIELD)&&(dmv!=1'b1))
                            paraa_a = 8'h68;
                          else
                            paraa_a = 8'h69;
                      end
                      else
                        paraa_a = 8'h68;
                  end
                  else if (mb_pattern)
                    paraa_a = 8'h55;
                  else 
                    paraa_a = 8'hFF;
              end  
              else begin   
                  if (mb_pattern)
                    paraa_a = 8'h55;
                  else   
                    paraa_a = 8'hFF;
              end
          end
        default:
          paraa_a = 8'hFF;
      endcase
  end
  
always @(v_macstate_r or
         v_interrpt_n or
         vecidx_t_r or 
         mb_quant or 
         motion_vector_count or 
         mmfwd or 
         dmv or 
         CONCEALMENT_MOTION_VECTORS  or 
         vecidx_r_r or 
         mmbwd or 
         m_code or 
         mb_pattern or 
         PICTURE_STRUCTURE or
         FRAME_PRED_FRAME_DCT or 
         vecidx_s_r or 
         AFTER_INTRA or 
         MPEG1 or 
         forward_f or 
         backward_f or 
         temp_fcode
         )
  begin
      if(!v_interrpt_n)  begin
          next_s = 1'b0;
          next_t = 1'b0;
          next_r = 1'b0;
      end
      else begin
          case(v_macstate_r) 
            P_IDLE:
              begin
                  next_s = 1'b0;
                  next_t = 1'b0;
                  next_r = 1'b0;
              end
            P_MTYP: 
              begin
                  if(MPEG1==P_MPEG_2) begin
                      if((mmfwd==1'b1 || mmbwd==1'b1)
                         &&(PICTURE_STRUCTURE==2'b11)
                         &&(FRAME_PRED_FRAME_DCT==1'b0)) begin
                          next_s = vecidx_s_r;
                          next_t = vecidx_t_r;
                          next_r = vecidx_r_r;
                      end
                      else if((mmfwd==1'b1 || mmbwd==1'b1) 
                              &&(PICTURE_STRUCTURE==2'b01 ||
                                 PICTURE_STRUCTURE==2'b10))begin
                          next_s = vecidx_s_r;
                          next_t = vecidx_t_r;
                          next_r = vecidx_r_r;
                      end
                      else if((PICTURE_STRUCTURE==2'b11) & 
                              (FRAME_PRED_FRAME_DCT==1'b0) &
                              (AFTER_INTRA||mb_pattern))begin
                          next_s = vecidx_s_r;
                          next_t = vecidx_t_r;
                          next_r = vecidx_r_r;
                      end
                      else if(mb_quant) begin
                          next_s = vecidx_s_r;
                          next_t = vecidx_t_r;
                          next_r = vecidx_r_r;
                      end
                      else if(mmfwd||(AFTER_INTRA &&
                                      CONCEALMENT_MOTION_VECTORS))begin
                          next_s = 0;
                          next_t = 0;
                          next_r = 0;
                      end
                      else if(mmbwd)begin  
                          next_s = 1'b1;
                          next_t = 1'b0;
                          next_r = 1'b0;
                      end
                      else begin   
                          next_s = vecidx_s_r;
                          next_t = vecidx_t_r;
                          next_r = vecidx_r_r;
                      end
                  end
                  else begin
                      if(mb_quant) begin
                          next_s = vecidx_s_r;
                          next_t = vecidx_t_r;
                          next_r = vecidx_r_r;
                      end
                      else if(mmfwd==1'b1)begin      
                          next_s = 1'b0; // forward
                          next_t = 1'b0; // horiaontal
                          next_r = 1'b0; // 1st
                      end
                      else if(mmbwd==1'b1) begin    
                          next_s = 1'b1; // forward
                          next_t = 1'b0; // horiaontal
                          next_r = 1'b0; // 1st
                      end
                      else begin       
                          next_s = vecidx_s_r;
                          next_t = vecidx_t_r;
                          next_r = vecidx_r_r;
                      end
                  end
              end
            P_FRMT: 
                begin
                    if((PICTURE_STRUCTURE==2'b11) & 
                       (FRAME_PRED_FRAME_DCT==1'b0) &
                       (AFTER_INTRA||mb_pattern))begin
                          next_s = vecidx_s_r;
                          next_t = vecidx_t_r;
                          next_r = vecidx_r_r;
                      end
                    else if(mb_quant) 
                      begin
                          next_s = vecidx_s_r;
                          next_t = vecidx_t_r;
                          next_r = vecidx_r_r;
                      end
                    else if(mmfwd||(AFTER_INTRA && CONCEALMENT_MOTION_VECTORS)) 
                      begin
                          next_s = 1'b0;
                          next_t = 1'b0;
                          next_r = 1'b0;
                      end
                    else if(mmbwd)     
                      begin
                          next_s = 1'b1;
                          next_t = 1'b0;
                          next_r = 1'b0;
                      end
                    else     
                      begin
                          next_s = vecidx_s_r;
                          next_t = vecidx_t_r;
                          next_r = vecidx_r_r;
                      end
                end
            P_FLMT: 
                begin
                    if((PICTURE_STRUCTURE==2'b11) & 
                       (FRAME_PRED_FRAME_DCT==1'b0) & 
                       (AFTER_INTRA||mb_pattern))begin
                        next_s = vecidx_s_r;
                        next_t = vecidx_t_r;
                        next_r = vecidx_r_r;
                    end
                    else if(mb_quant) 
                      begin
                          next_s = vecidx_s_r;
                          next_t = vecidx_t_r;
                          next_r = vecidx_r_r;
                      end
                    else if(mmfwd||(AFTER_INTRA && CONCEALMENT_MOTION_VECTORS))
                      begin
                          next_s = 1'b0;
                          next_t = 1'b0;
                          next_r = 1'b0;
                      end
                    else if(mmbwd)  
                      begin
                          next_s = 1'b1;
                          next_t = 1'b0;
                          next_r = 1'b0;
                      end
                    else     
                      begin
                          next_s = vecidx_s_r;
                          next_t = vecidx_t_r;
                          next_r = vecidx_r_r;
                      end
                end
            P_DTYP: 
                begin
                    if(mb_quant) 
                      begin
                          next_s = vecidx_s_r;
                          next_t = vecidx_t_r;
                          next_r = vecidx_r_r;
                      end
                    else if(mmfwd||(AFTER_INTRA && CONCEALMENT_MOTION_VECTORS))
                      begin
                          next_s = 1'b0;
                          next_t = 1'b0;
                          next_r = 1'b0;
                      end
                    else if(mmbwd)    
                      begin
                          next_s = 1'b1;
                          next_t = 1'b0;
                          next_r = 1'b0;
                      end
                    else     
                      begin
                          next_s = vecidx_s_r;
                          next_t = vecidx_t_r;
                          next_r = vecidx_r_r;
                      end
                end
            P_QSCD: 
              if (MPEG1==P_MPEG_2) 
                begin
                    if(mmfwd||(AFTER_INTRA && CONCEALMENT_MOTION_VECTORS)) 
                      begin
                          next_s = 1'b0;
                          next_t = 1'b0;
                          next_r = 1'b0;
                      end
                    else if(mmbwd)      
                      begin
                          next_s = 1'b1;
                          next_t = 1'b0;
                          next_r = 1'b0;
                      end
                    else       
                      begin
                          next_s = vecidx_s_r;
                          next_t = vecidx_t_r;
                          next_r = vecidx_r_r;
                      end
                end
              else 
                begin
                    if(mmfwd==1'b1)       
                      begin
                          next_s = 1'b0; 
                          next_t = 1'b0; 
                          next_r = 1'b0; 
                      end
                    else if(mmbwd==1'b1)   
                      begin
                          next_s = 1'b1; 
                          next_t = 1'b0; 
                          next_r = 1'b0; 
                      end
                    else    
                      begin
                          next_s = vecidx_s_r;
                          next_t = vecidx_t_r;
                          next_r = vecidx_r_r;
                      end
                end
            P_MVFS: 
              begin
                  next_s = vecidx_s_r;
                  next_t = vecidx_t_r;
                  next_r = vecidx_r_r;
              end
            P_MCOD:  
              if (MPEG1==P_MPEG_2) begin
                  if ((temp_fcode !=4'h1)&(m_code!=6'h00)) begin
                      next_s = vecidx_s_r;
                      next_r = vecidx_r_r;
                      next_t = vecidx_t_r;
                  end
                  else if(dmv == 1'b1) begin
                      next_s = vecidx_s_r;
                      next_r = vecidx_r_r;
                      next_t = vecidx_t_r;
                  end
                  else if(vecidx_t_r == 1'b0) begin 
                      next_t = 1;
                      next_s = vecidx_s_r;
                      next_r = vecidx_r_r;
                  end
                  else if((motion_vector_count!=2'b01)&(vecidx_r_r==1'b0))begin 
                      next_r = 1;
                      next_s = vecidx_s_r;
                      next_t = 0;
                  end
                  else if(vecidx_s_r==1'b0)     
                    begin
                        if(mmbwd) begin 
                            next_s = 1'b1;
                            next_t = 1'b0;
                            next_r = 1'b0;
                        end
                        else begin  
                            next_s = vecidx_s_r;
                            next_t = vecidx_t_r;
                            next_r = vecidx_r_r;
                        end
                    end 
                  else  begin   
                      next_s = vecidx_s_r;
                      next_t = vecidx_t_r;
                      next_r = vecidx_r_r;
                  end
              end
              else begin 
                  if (((vecidx_s_r==1'b0&&forward_f!=2'b01)||
                       (vecidx_s_r==1'b1&&backward_f!=2'b01))
                      &&(m_code!=6'h00)) begin
                      next_s = vecidx_s_r;
                      next_r = vecidx_r_r;
                      next_t = vecidx_t_r;
                  end
                  else if(vecidx_t_r == 1'b0) begin 
                      next_t = 1'b1;
                      next_s = vecidx_s_r;
                      next_r = vecidx_r_r;
                  end
                  else if((vecidx_s_r==1'b0) & (mmbwd==1'b1)) begin  
                      next_s = 1; 
                      next_t = 0; 
                      next_r = 0; 
                  end
                  else begin    
                      next_s = vecidx_s_r;
                      next_t = vecidx_t_r;
                      next_r = vecidx_r_r;
                  end
              end
            P_MRES: 
              if (MPEG1==P_MPEG_2)  
                begin
                    if(dmv == 1'b1) begin
                        next_s = vecidx_s_r;
                        next_r = vecidx_r_r;
                        next_t = vecidx_t_r;
                    end
                    else if(vecidx_t_r == 1'b0) begin 
                        next_t = 1;
                        next_s = vecidx_s_r;
                        next_r = vecidx_r_r;
                    end
                    else if((motion_vector_count!=2'b01) & (vecidx_r_r==1'b0)) begin
                        next_r = 1'b1;
                        next_s = vecidx_s_r;
                        next_t = 1'b0;
                    end
                    else if((vecidx_s_r==1'b0) & (mmbwd))begin
                        next_s = 1'b1;
                        next_t = 1'b0;
                        next_r = 1'b0;
                    end
                    else begin    
                        next_s = vecidx_s_r;
                        next_t = vecidx_t_r;
                        next_r = vecidx_r_r;
                    end
                end
              else begin
                  if(vecidx_t_r == 1'b0) begin  
                      next_t = 1'b1;
                      next_s = vecidx_s_r;
                      next_r = vecidx_r_r;
                  end
                  else if((vecidx_s_r==1'b0) & (mmbwd==1'b1)) begin 
                      next_s = 1'b1; 
                      next_t = 1'b0; 
                      next_r = 1'b0; 
                  end
                  else begin     
                      next_s = vecidx_s_r;
                      next_t = vecidx_t_r;
                      next_r = vecidx_r_r;
                  end
              end
            P_DMVC: begin
                if(vecidx_t_r == 1'b0) begin    
                    next_r = vecidx_r_r;
                    next_s = vecidx_s_r;
                    next_t = 1'b1;
                end
                else if((motion_vector_count!=2'b01)&&(vecidx_r_r==1'b0))begin
                    next_r = 1'b1;
                    next_s = vecidx_s_r;
                    next_t = 1'b0;
                end
                else if((vecidx_s_r==1'b0) & (mmbwd)) begin 
                    next_r = 1'b0;
                    next_s = 1'b1;
                    next_t = 1'b0;
                end
                else  begin    
                    next_s = vecidx_s_r;
                    next_t = vecidx_t_r;
                    next_r = vecidx_r_r;
                end
            end
            default:
              begin
                  next_s = 1'b0;
                  next_t = 1'b0;
                  next_r = 1'b0;
              end
          endcase
      end
  end

  always @(FCODE_00 or FCODE_01 or FCODE_10 or FCODE_11 or vecidx_s_r or vecidx_t_r)
     begin
       case({vecidx_s_r,vecidx_t_r}) 
         2'b00: temp_fcode = FCODE_00;
         2'b01: temp_fcode = FCODE_01;
         2'b10: temp_fcode = FCODE_10;
         2'b11: temp_fcode = FCODE_11;
       endcase
     end

  always @(v_macstate_r or v_mbastrt_r_s or
           PICTURE_STRUCTURE or STREAM or v_mbmot_type_r or
           SLICE_END or MPEG1 or next_state)begin
      if((v_macstate_r == P_IDLE)&(v_mbastrt_r_s | SLICE_END)) begin
          if(MPEG1 == P_MPEG_1)
            next_v_mbmot_type = 2'b10;
          else // MPEG-2
            if(PICTURE_STRUCTURE==2'b11)
              next_v_mbmot_type = 2'b10;
            else
              next_v_mbmot_type = 2'b01;
      end
      else begin
          if((next_state == P_FRMT)
             ||(next_state == P_FLMT))
            next_v_mbmot_type = STREAM[11:10]; 
          else
            next_v_mbmot_type = v_mbmot_type_r;
      end
  end

always @(next_state or 
         adr_inc or 
         mb_quant or 
         motion_vector_count or 
         STREAM or 
         vecidx_t_r or 
         AFTER_INTRA or 
         mmfwd or 
         mmbwd or 
         m_code or 
         adr_hld or 
         dmv or 
         CONCEALMENT_MOTION_VECTORS or 
         v_interrpt_n or 
         PICTURE_CODING_TYPE or 
         mb_pattern or 
         vecidx_r_r or 
         PICTURE_STRUCTURE or 
         temp_fcode or 
         FRAME_PRED_FRAME_DCT or 
         mv_format or 
         vecidx_s_r or 
         MPEG1 or 
         CBP or 
         backward_r_size or 
         forward_r_size or 
         next_t or 
         temp2_fcode or
         mark or temp_next_SHIFT
         )
  if (!v_interrpt_n)
    begin
        PARAD = 18'h00000;
        SHIFT = 6'h00;
        NFERROR = P_NO_ERROR;
        next_enddec = 1'b0;
        next_AFTER_INTRA = AFTER_INTRA;
        next_mmfwd = 1'b0;
        next_mmbwd = 1'b0;
        next_mb_pattern = 1'b0;
        next_mb_quant = 1'b0;
        next_motion_vector_count = 2'b01;
        next_dmv = 1'b0;
        if(PICTURE_STRUCTURE==2'b11)
          next_mv_format = P_FRAME;
        else
          next_mv_format = P_FIELD;
        next_m_code = 6'h00;
        next_adr_hld = 8'h00;
        next_adr_inc = 8'h00;
        temp_next_SHIFT = 6'h00;
        next_CBP = 6'h00;
        next_v_mbadet_r_s = 1'b0;
        mismatch = 1'b0;
        mark = 1'b1;
    end
  else
    case(next_state) 
      P_IDLE: 
        begin
            PARAD = 18'h00000;
            SHIFT = 6'h00;
            NFERROR = P_NO_ERROR;
            next_enddec = 1'b0;
            next_AFTER_INTRA = AFTER_INTRA;
            next_mmfwd = mmfwd;
            next_mmbwd = mmbwd;
            next_mb_pattern = mb_pattern;
            next_mb_quant = mb_quant;
            next_motion_vector_count = 2'b01;
            next_dmv = 1'b0;
            if(PICTURE_STRUCTURE==2'b11)
              next_mv_format = P_FRAME;
            else
              next_mv_format = P_FIELD;
            next_m_code = m_code;
            next_adr_hld = adr_hld;
            next_adr_inc = 8'h00;
            temp_next_SHIFT = 6'h00;
            next_CBP = CBP;
            next_v_mbadet_r_s = 1'b0;
            mismatch = 1'b0;
            mark = 1'b1;
        end
      P_MBAI: 
        begin
            casex (STREAM[11:1]) 
              11'b1??????????: 
                begin
                    PARAD = adr_inc + 8'd1;
                    next_mmfwd = 1'b0;
                    next_mmbwd = 1'b0;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h01; 
                end
              11'b011????????: 
                begin
                    PARAD = adr_inc + 8'd2;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h03; 
                end
              11'b010????????: 
                begin
                    PARAD = adr_inc + 8'd3;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h03; 
                end
              11'b0011???????: 
                begin 
                    PARAD = adr_inc + 8'd4;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h04; 
                end
              11'b0010???????: 
                begin
                    PARAD = adr_inc + 8'd5;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h04; 
                end
              11'b00011??????: 
                begin
                    PARAD = adr_inc + 8'd6;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h05; 
                end
              11'b00010??????: 
                begin
                    PARAD = adr_inc + 8'd7;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h05; 
                end
              11'b0000111????: 
                begin
                    PARAD = adr_inc + 8'd8;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h07; 
                end
              11'b0000110????: 
                begin
                    PARAD = adr_inc + 8'd9;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h07; 
                end
              11'b00001011???: 
                begin
                    PARAD = adr_inc + 8'd10;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h08; 
                end
              11'b00001010???: 
                begin
                    PARAD = adr_inc + 8'd11;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h08; 
                end
              11'b00001001???: 
                begin
                    PARAD = adr_inc + 8'd12;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h08; 
                end
              11'b00001000???: 
                begin
                    PARAD = adr_inc + 8'd13;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h08; 
                end
              11'b00000111???: 
                begin
                    PARAD = adr_inc + 8'd14;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h08; 
                end
              11'b00000110???: 
                begin
                    PARAD = adr_inc + 8'd15;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h08; 
                end
              11'b0000010111?: 
                begin
                    PARAD = adr_inc + 8'd16;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h0A; 
                end
              11'b0000010110?: 
                begin
                    PARAD = adr_inc + 8'd17;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h0A; 
                end
              11'b0000010101?: 
                begin
                    PARAD = adr_inc + 8'd18;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h0A; 
                end
              11'b0000010100?: 
                begin
                    PARAD = adr_inc + 8'd19;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h0A; 
                end
              11'b0000010011?: 
                begin
                    PARAD = adr_inc + 8'd20;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h0A; 
                end
              11'b0000010010?: 
                begin
                    PARAD = adr_inc + 8'd21;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h0A; 
                end
              11'b00000100011: 
                begin
                    PARAD = adr_inc + 8'd22;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h0B; 
                end
              11'b00000100010: 
                begin
                    PARAD = adr_inc + 8'd23;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h0B; 
                end
              11'b00000100001: 
                begin
                    PARAD = adr_inc + 8'd24;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h0B; 
                end
              11'b00000100000: 
                begin
                    PARAD = adr_inc + 8'd25;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h0B; 
                end
              11'b00000011111: 
                begin
                    PARAD = adr_inc + 8'd26;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h0B; 
                end
              11'b00000011110: 
                begin
                    PARAD = adr_inc + 8'd27;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h0B; 
                end
              11'b00000011101: 
                begin
                    PARAD = adr_inc + 8'd28;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h0B; 
                end
              11'b00000011100: 
                begin
                    PARAD = adr_inc + 8'd29;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h0B; 
                end
              11'b00000011011: 
                begin
                    PARAD = adr_inc + 8'd30;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h0B; 
                end
              11'b00000011010: 
                begin
                    PARAD = adr_inc + 8'd31;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h0B; 
                end
              11'b00000011001: 
                begin
                    PARAD = adr_inc + 8'd32;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h0B; 
                end
              11'b00000011000: 
                begin
                    PARAD = adr_inc + 8'd33;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b1;
                    SHIFT = 6'h0B; 
                end
              11'b00000001000: 
                begin
                    PARAD = 18'h00000;
                    next_adr_inc = adr_inc + 8'd33;
                    mismatch = 1'b0;
                    next_v_mbadet_r_s = 1'b0;
                    SHIFT = 6'h0B; 
                end
              default: 
                begin
                    PARAD = 18'h00000;
                    next_adr_inc = 8'h00;
                    mismatch = 1'b1;
                    next_v_mbadet_r_s = 1'b0;
                    SHIFT = 6'h00; 
                end
            endcase
            next_adr_hld = PARAD[7:0];
            NFERROR = P_NO_ERROR;
            next_enddec = 1'b0;
            next_AFTER_INTRA = AFTER_INTRA;
            next_mmfwd = mmfwd;
            next_mmbwd = mmbwd;
            next_mb_pattern = mb_pattern;
            next_mb_quant = mb_quant;
            next_motion_vector_count = motion_vector_count;
            next_dmv = dmv;
            next_mv_format = mv_format;
            next_m_code = m_code;
            temp_next_SHIFT = 6'h00;
            mark = 1'b1;
            next_CBP = 6'h00;
        end

      P_WAIT :
        begin
            PARAD = 18'h00000;
            SHIFT = 6'h00;
            NFERROR = P_NO_ERROR;
            next_enddec = 1'b0;
            next_AFTER_INTRA = AFTER_INTRA;
            next_mmfwd = 1'b0;
            next_mmbwd = 1'b0;
            next_mb_pattern = 1'b0;
            next_mb_quant = 1'b0;
            next_motion_vector_count = 2'b01;
            next_dmv = 1'b0;
            if(PICTURE_STRUCTURE == 2'b11)
              next_mv_format = P_FRAME;
            else
              next_mv_format = P_FIELD;
            next_m_code = 6'h00;
            next_adr_hld = 8'h00;
            next_adr_inc = 8'h00;
            temp_next_SHIFT = 6'h00;
            next_CBP = 6'h00;
            next_v_mbadet_r_s = 1'b0;
            mismatch = 1'b0;
            mark = 1'b1;
        end

      P_MTYP: 
        begin
            case (PICTURE_CODING_TYPE) 
              3'b001:  
                begin
                    casex (STREAM[11:3]) 
                      9'b1????????:  
                        begin
                            PARAD = {3'b001,15'h0000};
                            next_AFTER_INTRA = 1'b1;
                            next_mmfwd = 1'b0;
                            next_mmbwd = 1'b0;
                            next_mb_quant = 1'b0;
                            next_mb_pattern = 1'b0; 
                            mismatch = 1'b0;
                            SHIFT = 6'h01; 
                        end
                      9'b01???????: 
                        begin
                            PARAD = {3'b001,15'h0000};
                            next_AFTER_INTRA = 1'b1;
                            next_mmfwd = 1'b0;
                            next_mmbwd = 1'b0;
                            next_mb_quant = 1'b1;
                            next_mb_pattern = 1'b0;
                            mismatch = 1'b0;
                            SHIFT = 6'h02; 
                        end
                      default: 
                        begin
                            PARAD = 18'h00000;
                            next_AFTER_INTRA = 1'b0;
                            next_mmfwd = 1'b0;
                            next_mmbwd = 1'b0;
                            next_mb_quant = 1'b0;
                            next_mb_pattern = 1'b0;
                            mismatch = 1'b1;
                            SHIFT = 6'h00; 
                        end
                    endcase
                end
              3'b010:   
                begin
                    casex (STREAM[11:3]) 
                      9'b1????????:  
                        begin
                            PARAD = {3'b100,15'h0000};
                            next_AFTER_INTRA = 1'b0;
                            next_mmfwd = 1'b1;
                            next_mmbwd = 1'b0;
                            next_mb_quant = 1'b0;
                            next_mb_pattern = 1'b1;
                            mismatch = 1'b0;
                            SHIFT = 6'h01; 
                        end
                      9'b01???????:  
                        begin
                            PARAD = {3'b000,15'h0000};
                            next_AFTER_INTRA = 1'b0;
                            next_mmfwd = 1'b0;
                            next_mmbwd = 1'b0;
                            next_mb_quant = 1'b0;
                            next_mb_pattern = 1'b1;
                            mismatch = 1'b0;
                            SHIFT = 6'h02; 
                        end
                      9'b001??????: 
                        begin
                            PARAD = {3'b100,15'h0000};
                            next_AFTER_INTRA = 1'b0;
                            next_mmfwd = 1'b1;
                            next_mmbwd = 1'b0;
                            next_mb_quant = 1'b0;
                            next_mb_pattern = 1'b0;
                            mismatch = 1'b0;
                            SHIFT = 6'h03; 
                        end
                      9'b00011????:
                        begin
                            PARAD = {3'b001,15'h0000};
                            next_AFTER_INTRA = 1'b1;
                            next_mmfwd = 1'b0;
                            next_mmbwd = 1'b0;
                            next_mb_quant = 1'b0;
                            next_mb_pattern = 1'b0;
                            mismatch = 1'b0;
                            SHIFT = 6'h05; 
                        end
                      9'b00010????:  
                        begin
                            PARAD = {3'b100,15'h0000};
                            next_AFTER_INTRA = 1'b0;
                            next_mmfwd = 1'b1;
                            next_mmbwd = 1'b0;
                            next_mb_quant = 1'b1;
                            next_mb_pattern = 1'b1;
                            mismatch = 1'b0;
                            SHIFT = 6'h05; 
                        end
                      9'b00001????: 
                        begin
                            PARAD = {3'b000,15'h0000};
                            next_AFTER_INTRA = 1'b0;
                            next_mmfwd = 1'b0;
                            next_mmbwd = 1'b0;
                            next_mb_quant = 1'b1;
                            next_mb_pattern = 1'b1;
                            mismatch = 1'b0;
                            SHIFT = 6'h05; 
                        end
                      9'b000001???:  
                        begin
                            PARAD = {3'b001,15'h0000};
                            next_AFTER_INTRA = 1'b1;
                            next_mmfwd = 1'b0;
                            next_mmbwd = 1'b0;
                            next_mb_quant = 1'b1;
                            next_mb_pattern = 1'b0;
                            mismatch = 1'b0;
                            SHIFT = 6'h06; 
                        end
                      default: 
                        begin
                            PARAD = 18'h00000;
                            next_AFTER_INTRA = 1'b0;
                            next_mmfwd = 1'b0;
                            next_mmbwd = 1'b0;
                            next_mb_quant = 1'b0;
                            next_mb_pattern = 1'b0;
                            mismatch = 1'b1;
                            SHIFT = 6'h00; 
                        end
                    endcase
                end
              3'b011:  
                begin
                    casex (STREAM[11:3]) 
                      9'b10???????:  
                        begin
                            PARAD = {3'b110,15'h0000};
                            next_AFTER_INTRA = 1'b0;
                            next_mmfwd = 1'b1;
                            next_mmbwd = 1'b1;
                            next_mb_quant = 1'b0;
                            next_mb_pattern = 1'b0;
                            mismatch = 1'b0;
                            SHIFT = 6'h02; 
                        end
                      9'b11???????:  
                        begin
                            PARAD = {3'b110,15'h0000};
                            next_AFTER_INTRA = 1'b0;
                            next_mmfwd = 1'b1;
                            next_mmbwd = 1'b1;
                            next_mb_quant = 1'b0;
                            next_mb_pattern = 1'b1;
                            mismatch = 1'b0;
                            SHIFT = 6'h02; 
                        end
                      9'b010??????:  
                        begin
                            PARAD = {3'b010,15'h0000};
                            next_AFTER_INTRA = 1'b0;
                            next_mmfwd = 1'b0;
                            next_mmbwd = 1'b1;
                            next_mb_quant = 1'b0;
                            next_mb_pattern = 1'b0;
                            mismatch = 1'b0;
                            SHIFT = 6'h03; 
                        end
                      9'b011??????: 
                        begin
                            PARAD = {3'b010,15'h0000};
                            next_AFTER_INTRA = 1'b0;
                            next_mmfwd = 1'b0;
                            next_mmbwd = 1'b1;
                            next_mb_quant = 1'b0;
                            next_mb_pattern = 1'b1;
                            mismatch = 1'b0;
                            SHIFT = 6'h03; 
                        end
                      9'b0010?????: 
                        begin
                            PARAD = {3'b100,15'h0000};
                            next_AFTER_INTRA = 1'b0;
                            next_mmfwd = 1'b1;
                            next_mmbwd = 1'b0;
                            next_mb_quant = 1'b0;
                            next_mb_pattern = 1'b0;
                            mismatch = 1'b0;
                            SHIFT = 6'h04; 
                        end
                      9'b0011?????:  
                        begin
                            PARAD = {3'b100,15'h0000};
                            next_AFTER_INTRA = 1'b0;
                            next_mmfwd = 1'b1;
                            next_mmbwd = 1'b0;
                            next_mb_quant = 1'b0;
                            next_mb_pattern = 1'b1;
                            mismatch = 1'b0;
                            SHIFT = 6'h04; 
                        end
                      9'b00011????:  
                        begin
                            PARAD = {3'b001,15'h0000};
                            next_AFTER_INTRA = 1'b1;
                            next_mmfwd = 1'b0;
                            next_mmbwd = 1'b0;
                            next_mb_quant = 1'b0;
                            next_mb_pattern = 1'b0;
                            mismatch = 1'b0;
                            SHIFT = 6'h05; 
                        end
                      9'b00010????:  
                        begin
                            PARAD = {3'b110,15'h0000};
                            next_AFTER_INTRA = 1'b0;
                            next_mmfwd = 1'b1;
                            next_mmbwd = 1'b1;
                            next_mb_quant = 1'b1;
                            next_mb_pattern = 1'b1;
                            mismatch = 1'b0;
                            SHIFT = 6'h05; 
                        end
                      9'b000011???:  
                        begin
                            PARAD = {3'b100,15'h0000};
                            next_AFTER_INTRA = 1'b0;
                            next_mmfwd = 1'b1;
                            next_mmbwd = 1'b0;
                            next_mb_quant = 1'b1;
                            next_mb_pattern = 1'b1;
                            mismatch = 1'b0;
                            SHIFT = 6'h06; 
                        end
                      9'b000010???:  
                        begin
                            PARAD = {3'b010,15'h0000};
                            next_AFTER_INTRA = 1'b0;
                            next_mmfwd = 1'b0;
                            next_mmbwd = 1'b1;
                            next_mb_quant = 1'b1;
                            next_mb_pattern = 1'b1;
                            mismatch = 1'b0;
                            SHIFT = 6'h06; 
                        end
                      9'b000001???:  
                        begin
                            PARAD = {3'b001,15'h0000};
                            next_AFTER_INTRA = 1'b1;
                            next_mmfwd = 1'b0;
                            next_mmbwd = 1'b0;
                            next_mb_quant = 1'b1;
                            next_mb_pattern = 1'b0;
                            mismatch = 1'b0;
                            SHIFT = 6'h06; 
                        end
                      default: 
                        begin
                            PARAD = 18'h00000;
                            next_AFTER_INTRA = 1'b0;
                            next_mmfwd = 1'b0;
                            next_mmbwd = 1'b0;
                            next_mb_quant = 1'b0;
                            next_mb_pattern = 1'b0;
                            mismatch = 1'b1;
                            SHIFT = 6'h00; 
                        end
                    endcase
                end
              3'b100:  
                begin
                    casex (STREAM[11]) 
                      1'b1: 
                        begin
                            PARAD = {3'b001,15'h0000};
                            next_AFTER_INTRA = 1'b1;
                            next_mmfwd = 1'b0;
                            next_mmbwd = 1'b0;
                            next_mb_quant = 1'b0;
                            next_mb_pattern = 1'b0; 
                            mismatch = 1'b0;
                            SHIFT = 6'h01; 
                        end
                      default: 
                        begin
                            PARAD = 18'h00000;
                            next_AFTER_INTRA = 1'b0;
                            next_mmfwd = 1'b0;
                            next_mmbwd = 1'b0;
                            next_mb_quant = 1'b0;
                            next_mb_pattern = 1'b0;
                            mismatch = 1'b1;
                            SHIFT = 6'h00; 
                        end
                    endcase
                end
              default: 
                begin
                    PARAD = 18'h00000;
                    next_AFTER_INTRA = 1'b0;
                    next_mmfwd = 1'b0;
                    next_mmbwd = 1'b0;
                    next_mb_quant = 1'b0;
                    next_mb_pattern = 1'b0;
                    mismatch = 1'b1;
                    SHIFT = 6'h00;
                end
            endcase
            NFERROR = P_NO_ERROR;
            if(
               ((MPEG1 == P_MPEG_2) &
                ((~next_mmfwd) & (~next_mmbwd))
                &((PICTURE_STRUCTURE!=2'b11)|(FRAME_PRED_FRAME_DCT!=1'b0)
                  | ((~next_AFTER_INTRA)&(~next_mb_pattern)))
                & (~next_mb_quant)
                & ((~next_mmfwd)&((~next_AFTER_INTRA)|(~CONCEALMENT_MOTION_VECTORS)))
                & (~next_mmbwd) 
                & ((~next_AFTER_INTRA)|(~CONCEALMENT_MOTION_VECTORS))
                & (~next_mb_pattern)) 
               | ((MPEG1 == P_MPEG_1) &
                  ((~next_mb_quant) & (~next_mmfwd) & 
                   (~next_mmbwd) & (~next_mb_pattern))))
              next_enddec = 1'b1;
            else
              next_enddec = 1'b0;
            next_motion_vector_count = motion_vector_count;
            next_dmv = dmv;
            next_mv_format = mv_format;
            next_m_code = m_code;
            next_adr_hld = adr_hld;
            next_adr_inc = 8'h00;
            temp_next_SHIFT = 6'h00;
            mark = 1'b1;
            next_CBP = CBP;
            next_v_mbadet_r_s = 1'b0;
        end

      P_FRMT: 
        begin
            PARAD = {STREAM[11:10],16'h0000};
            SHIFT = 6'h02;
            NFERROR = P_NO_ERROR;
            if (((PICTURE_STRUCTURE!=2'b11)||(FRAME_PRED_FRAME_DCT!=1'b0)
                 ||(~AFTER_INTRA&&~mb_pattern))
                &&(~mb_quant)
                &&((~mmfwd)&&(~AFTER_INTRA||~CONCEALMENT_MOTION_VECTORS))
                &&(~mmbwd) 
                &&(~AFTER_INTRA||~CONCEALMENT_MOTION_VECTORS) 
                &&(~mb_pattern)) 
              next_enddec = 1'b1;
            else
              next_enddec = 1'b0;
            next_AFTER_INTRA = AFTER_INTRA;
            next_mmfwd = mmfwd;
            next_mmbwd = mmbwd;
            next_mb_quant = mb_quant;
            next_mb_pattern = mb_pattern;
            next_adr_hld = adr_hld;
            next_m_code = m_code;
            case (STREAM[11:10]) 
              2'b01: 
                begin
                    next_motion_vector_count = 2'd2;
                    next_dmv = 0;
                    next_mv_format = P_FIELD; 
                end
              2'b10: 
                begin
                    next_motion_vector_count = 2'd1;
                    next_dmv = 0;
                    next_mv_format = P_FRAME; 
                end
              2'b11: 
                begin
                    next_motion_vector_count = 2'd1;
                    next_dmv = 1'b1;
                    next_mv_format = P_FIELD; 
                end
              default: 
                begin
                    next_motion_vector_count = 2'd1;
                    next_dmv = 0;
                    next_mv_format = P_FRAME;
                end
            endcase
            next_adr_inc = 8'h00;
            temp_next_SHIFT = 6'h00;
            mismatch = 1'b0;
            mark = 1'b1;
            next_CBP = CBP;
            next_v_mbadet_r_s = 1'b0;
        end

      P_FLMT: 
        begin
            PARAD = {STREAM[11:10],16'h0000};
            SHIFT = 6'h02;
            NFERROR = P_NO_ERROR;
            if (((PICTURE_STRUCTURE!=2'b11)||(FRAME_PRED_FRAME_DCT!=1'b0)
                 ||(~AFTER_INTRA&&~mb_pattern))
                &&(~mb_quant)
                &&((~mmfwd)&&(~AFTER_INTRA||~CONCEALMENT_MOTION_VECTORS))
                &&(~mmbwd) 
                &&(~AFTER_INTRA||~CONCEALMENT_MOTION_VECTORS) 
                &&(~mb_pattern)) 
              next_enddec = 1'b1;
            else
              next_enddec = 1'b0;
            next_AFTER_INTRA = AFTER_INTRA;
            next_mmfwd = mmfwd;
            next_mmbwd = mmbwd;
            next_mb_quant = mb_quant;
            next_mb_pattern = mb_pattern;
            next_m_code = m_code;
            next_adr_hld = adr_hld;
            case (STREAM[11:10]) 
              2'b01: 
                begin
                    next_motion_vector_count = 2'd1;
                    next_dmv = 0;
                    next_mv_format = P_FIELD; 
                end
              2'b10: 
                begin
                    next_motion_vector_count = 2'd2;
                    next_dmv = 0;
                    next_mv_format = P_FIELD; 
                end
              2'b11: 
                begin
                    next_motion_vector_count = 2'd1;
                    next_dmv = 1'b1;
                    next_mv_format = P_FIELD; 
                end
              default: 
                begin
                    next_motion_vector_count = 2'd1;
                    next_dmv = 0;
                    next_mv_format = P_FRAME; 
                end
            endcase
            next_adr_inc = 8'h00;
            temp_next_SHIFT = 6'h00;
            next_CBP = CBP;
            mismatch = 1'b0;
            mark = 1'b1;
            next_v_mbadet_r_s = 1'b0;
        end

      P_DTYP: 
        begin
            PARAD = {STREAM[11],17'h00000};
            SHIFT = 6'h01;
            NFERROR = P_NO_ERROR;
            if ((~mb_quant) 
                &&((~mmfwd)&&(~AFTER_INTRA||~CONCEALMENT_MOTION_VECTORS))
                &&(~mmbwd) 
                &&(~AFTER_INTRA||~CONCEALMENT_MOTION_VECTORS) 
                &&(~mb_pattern)) 
              next_enddec = 1'b1;
            else
              next_enddec = 1'b0;
            next_AFTER_INTRA = AFTER_INTRA;
            next_mmfwd = mmfwd;
            next_mmbwd = mmbwd;
            next_mb_quant = mb_quant;
            next_mb_pattern = mb_pattern;
            next_motion_vector_count = motion_vector_count;
            next_dmv = dmv;
            next_mv_format = mv_format;
            next_m_code = m_code;
            next_adr_hld = adr_hld;
            next_adr_inc = 8'h00;
            temp_next_SHIFT = 6'h00;
            mismatch = 1'b0;
            mark = 1'b1;
            next_CBP = CBP;
            next_v_mbadet_r_s = 1'b0;
        end

      P_QSCD: 
        begin
            PARAD = {STREAM[11:7],13'h0000};
            SHIFT = 6'h05;
            NFERROR = P_NO_ERROR;
            if(
               ((MPEG1 == P_MPEG_2) &
                ((~mmfwd) & ((~AFTER_INTRA) | (~CONCEALMENT_MOTION_VECTORS)))
                & (~mmbwd) 
                & ~(AFTER_INTRA & CONCEALMENT_MOTION_VECTORS) 
                & (~mb_pattern)) 
               | ((MPEG1 == P_MPEG_1) &
                  (~mmfwd) & (~mmbwd) & (~mb_pattern))
               )
              next_enddec = 1'b1;
            else
              next_enddec = 1'b0;
            next_AFTER_INTRA = AFTER_INTRA;
            next_mmfwd = mmfwd;
            next_mmbwd = mmbwd;
            next_mb_quant = mb_quant;
            next_mb_pattern = mb_pattern;
            next_motion_vector_count = motion_vector_count;
            next_dmv = dmv;
            next_mv_format = mv_format;
            next_m_code = m_code;
            next_adr_hld = adr_hld;
            next_adr_inc = 8'h00;
            temp_next_SHIFT = 6'h00;
            mismatch = 1'b0;
            mark = 1'b1;
            next_CBP = CBP;
            next_v_mbadet_r_s = 1'b0;
        end

      P_MVFS: 
        begin
            PARAD = {STREAM[11],17'h00000};
            SHIFT = 6'h01;
            NFERROR = P_NO_ERROR;
            next_enddec = 1'b0;
            next_AFTER_INTRA = AFTER_INTRA;
            next_mmfwd = mmfwd;
            next_mmbwd = mmbwd;
            next_mb_quant = mb_quant;
            next_mb_pattern = mb_pattern;
            next_motion_vector_count = motion_vector_count;
            next_dmv = dmv;
            next_mv_format = mv_format;
            next_m_code = m_code;
            next_adr_hld = adr_hld;
            next_adr_inc = 8'h00;
            temp_next_SHIFT = 6'h00;
            mismatch = 1'b0;
            mark = 1'b1;
            next_CBP = CBP;
            next_v_mbadet_r_s = 1'b0;
        end

      P_MCOD: 
        begin
            casex (STREAM[11:1]) 
              11'b00000011001: // -16
                begin
                    PARAD = {6'b110000,12'h000};
                    temp_next_SHIFT = 6'h0B;
                    next_m_code = 6'b110000;
                    mark = STREAM[0];
                    mismatch = 1'b0;
                end
              11'b00000011011: // -15
                begin
                    PARAD = {6'b110001,12'h000};
                    temp_next_SHIFT = 6'h0B;
                    next_m_code = 6'b110001;
                    mark = STREAM[0];
                    mismatch = 1'b0;
                end
              11'b00000011101: // -14
                begin
                    PARAD = {6'b110010,12'h000};
                    temp_next_SHIFT = 6'h0B;
                    next_m_code = 6'b110010;
                    mark = STREAM[0];
                    mismatch = 1'b0;
                end
              11'b00000011111: //-13
                begin
                    PARAD = {6'b110011,12'h000};
                    temp_next_SHIFT = 6'h0B;
                    next_m_code = 6'b110011;
                    mark = STREAM[0];
                    mismatch = 1'b0;
                end
              11'b00000100001: //-12
                begin
                    PARAD = {6'b110100,12'h000};
                    temp_next_SHIFT = 6'h0B;
                    next_m_code = 6'b110100;
                    mark = STREAM[0];
                    mismatch = 1'b0;
                end
              11'b00000100011: //-11
                begin
                    PARAD = {6'b110101,12'h000};
                    temp_next_SHIFT = 6'h0B;
                    next_m_code = 6'b110101;
                    mark = STREAM[0];
                    mismatch = 1'b0;
                end
              11'b0000010011?:  // -10
                begin
                    PARAD = {6'b110110,12'h000};
                    temp_next_SHIFT = 6'h0A;
                    next_m_code = 6'b110110;
                    mark = STREAM[1];
                    mismatch = 1'b0;
                end
              11'b0000010101?:  //-9
                begin
                    PARAD = {6'b110111,12'h000};
                    temp_next_SHIFT = 6'h0A;
                    next_m_code = 6'b110111;
                    mark = STREAM[1];
                    mismatch = 1'b0;
                end
              11'b0000010111?: // -8
                begin
                    PARAD = {6'b111000,12'h000};
                    temp_next_SHIFT = 6'h0A;
                    next_m_code = 6'b111000;
                    mark = STREAM[1];
                    mismatch = 1'b0;
                end
              11'b00000111???: // -7
                begin
                    PARAD = {6'b111001,12'h000};
                    temp_next_SHIFT = 6'h08;
                    next_m_code = 6'b111001;
                    mark = STREAM[3];
                    mismatch = 1'b0;
                end
              11'b00001001???: // -6
                begin
                    PARAD = {6'b111010,12'h000};
                    temp_next_SHIFT = 6'h08;
                    next_m_code = 6'b111010;
                    mark = STREAM[3];
                    mismatch = 1'b0;
                end
              11'b00001011???: // -5
                begin
                    PARAD = {6'b111011,12'h000};
                    temp_next_SHIFT = 6'h08;
                    next_m_code = 6'b111011;
                    mark = STREAM[3];
                    mismatch = 1'b0;
                end
              11'b0000111????: // -4
                begin
                    PARAD = {6'b111100,12'h000};
                    temp_next_SHIFT = 6'h07;
                    next_m_code = 6'b111100;
                    mark = STREAM[4];
                    mismatch = 1'b0;
                end
              11'b00011??????: // -3
                begin
                    PARAD = {6'b111101,12'h000};
                    temp_next_SHIFT = 6'h05;
                    next_m_code = 6'b111101;
                    mark = STREAM[6];
                    mismatch = 1'b0;
                end
              11'b0011???????: // -2
                begin
                    PARAD = {6'b111110,12'h000};
                    temp_next_SHIFT = 6'h04;
                    next_m_code = 6'b111110;
                    mark = STREAM[7];
                    mismatch = 1'b0;
                end
              11'b011????????: // -1
                begin
                    PARAD = {6'b111111,12'h000};
                    temp_next_SHIFT = 6'h03;
                    next_m_code = 6'b111111;
                    mark = STREAM[8];
                    mismatch = 1'b0;
                end
              11'b1??????????: // 0
                begin
                    PARAD = 18'h00000;
                    temp_next_SHIFT = 6'h01;
                    next_m_code = 6'h00;
                    mark = STREAM[10];
                    mismatch = 1'b0;
                end
              11'b010????????: // 1
                begin
                    PARAD = {6'h01,12'h000};
                    temp_next_SHIFT = 6'h03;
                    next_m_code = 6'h01;
                    mark = STREAM[8];
                    mismatch = 1'b0;
                end
              11'b0010???????: // 2
                begin
                    PARAD = {6'h02,12'h000};
                    temp_next_SHIFT = 6'h04;
                    next_m_code = 6'h02;
                    mark = STREAM[7];
                    mismatch = 1'b0;
                end
              11'b00010??????: // 3
                begin
                    PARAD = {6'h03,12'h000};
                    temp_next_SHIFT = 6'h05;
                    next_m_code = 6'h03;
                    mark = STREAM[6];
                    mismatch = 1'b0;
                end
              11'b0000110????: // 4
                begin
                    PARAD = {6'h04,12'h000};
                    temp_next_SHIFT = 6'h07;
                    next_m_code = 6'h04;
                    mark = STREAM[4];
                    mismatch = 1'b0;
                end
              11'b00001010???: // 5
                begin
                    PARAD = {6'h05,12'h000};
                    temp_next_SHIFT = 6'h08;
                    next_m_code = 6'h05;
                    mark = STREAM[3];
                    mismatch = 1'b0;
                end
              11'b00001000???: // 6
                begin
                    PARAD = {6'h06,12'h000};
                    temp_next_SHIFT = 6'h08;
                    next_m_code = 6'h06;
                    mark = STREAM[3];
                    mismatch = 1'b0;
                end
              11'b00000110???: // 7
                begin
                    PARAD = {6'h07,12'h000};
                    temp_next_SHIFT = 6'h08;
                    next_m_code = 6'h07;
                    mark = STREAM[3];
                    mismatch = 1'b0;
                end
              11'b0000010110?:  // 8
                begin
                    PARAD = {6'h08,12'h000};
                    temp_next_SHIFT = 6'h0A;
                    next_m_code = 6'h08;
                    mark = STREAM[1];
                    mismatch = 1'b0;
                end
              11'b0000010100?: //9
                begin
                    PARAD = {6'h09,12'h000};
                    temp_next_SHIFT = 6'h0A;
                    next_m_code = 6'h09;
                    mark = STREAM[1];
                    mismatch = 1'b0;
                end
              11'b0000010010?: // 10
                begin
                    PARAD = {6'h0A,12'h000};
                    temp_next_SHIFT = 6'h0A;
                    next_m_code = 6'h0A;
                    mark = STREAM[1];
                    mismatch = 1'b0;
                end
              11'b00000100010: // 11
                begin
                    PARAD = {6'h0B,12'h000};
                    temp_next_SHIFT = 6'h0B;
                    next_m_code = 6'h0B;
                    mark = STREAM[0];
                    mismatch = 1'b0;
                end
              11'b00000100000: // 12
                begin
                    PARAD = {6'h0C,12'h000};
                    temp_next_SHIFT = 6'h0B;
                    next_m_code = 6'h0C;
                    mark = STREAM[0];
                    mismatch = 1'b0;
                end
              11'b00000011110: // 13
                begin
                    PARAD = {6'h0D,12'h000};
                    temp_next_SHIFT = 6'h0B;
                    next_m_code = 6'h0D;
                    mark = STREAM[0];
                    mismatch = 1'b0;
                end   
              11'b00000011100: // 14
                begin
                    PARAD = {6'h0E,12'h000};
                    temp_next_SHIFT = 6'h0B;
                    next_m_code = 6'h0E;
                    mark = STREAM[0];
                    mismatch = 1'b0;
                end
              11'b00000011010: // 15
                begin
                    PARAD = {6'h0F,12'h000};
                    temp_next_SHIFT = 6'h0B;
                    next_m_code = 6'h0F;
                    mark = STREAM[0];
                    mismatch = 1'b0;
                end
              11'b00000011000: // 16
                begin
                    PARAD = {6'h10,12'h000};
                    temp_next_SHIFT = 6'h0B;
                    next_m_code = 6'h10;
                    mark = STREAM[0];
                    mismatch = 1'b0;
                end
              default: 
                begin
                    PARAD = 18'h00000;
                    temp_next_SHIFT = 6'h00;
                    next_m_code = 6'h00;
                    mark = 1'b1;
                    mismatch = 1'b1;
                end
            endcase
            if(
               (MPEG1 == P_MPEG_2) &
               (next_t == 1'b1) &
               ((temp2_fcode == 4'h1) | (next_m_code==6'h00)) & 
               (dmv!=1'b1) &
               ((vecidx_r_r == 1'b1)|((motion_vector_count == 2'b01)&(vecidx_r_r == 1'b0))) &
               (((vecidx_s_r == 1'b0)&(mmbwd == 1'b0))|(vecidx_s_r == 1'b1)) &
               ((AFTER_INTRA == 1'b1)&(CONCEALMENT_MOTION_VECTORS==1'b1))
               )
              begin
                  if (mark==1'b0)
                    NFERROR = P_ERROR;
                  else
                    NFERROR = P_NO_ERROR;
                  SHIFT = temp_next_SHIFT +1;
              end
            else 
              begin
                  NFERROR = P_NO_ERROR;
                  SHIFT = temp_next_SHIFT;
              end

            if(
               ((MPEG1 == P_MPEG_2) &
                (next_t == 1'b1) & 
                ((temp2_fcode == 4'h1) | (next_m_code == 6'h00)) &
                (dmv != 1'b1) &
                ((vecidx_r_r == 1'b1)|((motion_vector_count == 2'b01)&(vecidx_r_r == 1'b0))) &
                (((vecidx_s_r == 1'b0)&(mmbwd == 1'b0))|(vecidx_s_r == 1'b1)) &
                (mb_pattern == 1'b0))  
               | ((MPEG1 == P_MPEG_1) &
                  (next_t==1'b1) &
                  ((temp2_fcode==4'h1)|(next_m_code==6'h00)) &
                  (((~mmbwd) & (vecidx_s_r==1'b0)) | (vecidx_s_r == 1'b1)) &
                  (~mb_pattern))
               )
              next_enddec = 1'b1;
            else
              next_enddec = 1'b0;
            next_AFTER_INTRA = AFTER_INTRA;
            next_mmfwd = mmfwd;
            next_mmbwd = mmbwd;
            next_mb_quant = mb_quant;
            next_mb_pattern = mb_pattern;
            next_motion_vector_count = motion_vector_count;
            next_dmv = dmv;
            next_mv_format = mv_format;
            next_adr_hld = adr_hld;
            next_adr_inc = 8'h00;
            next_CBP = CBP;
            next_v_mbadet_r_s = 1'b0;
        end

      P_MRES: 
        begin
            if(MPEG1==P_MPEG_2) 
              begin
                  case(temp_fcode) 
                    4'h2: 
                      begin
                          PARAD = {7'h00,STREAM[11],10'h000};
                          temp_next_SHIFT = 6'h01;
                          mark = STREAM[10];
                      end
                    4'h3: 
                      begin
                          PARAD = {6'h0,STREAM[11:10],10'h000};
                          temp_next_SHIFT = 6'h02;
                          mark = STREAM[9];
                      end
                    4'h4: 
                      begin
                          PARAD = {5'h00,STREAM[11:9],10'h000};
                          temp_next_SHIFT = 6'h03;
                          mark = STREAM[8];
                      end
                    4'h5: 
                      begin
                          PARAD = {4'h0,STREAM[11:8],10'h000};
                          temp_next_SHIFT = 6'h04;
                          mark = STREAM[7];
                      end
                    4'h6: 
                      begin
                          PARAD = {3'h0,STREAM[11:7],10'h000};
                          temp_next_SHIFT = 6'h05;
                          mark = STREAM[6];
                      end
                    4'h7: 
                      begin
                          PARAD = {2'h0,STREAM[11:6],10'h000};
                          temp_next_SHIFT = 6'h06;
                          mark = STREAM[5];
                      end
                    4'h8: 
                      begin
                          PARAD = {1'b0,STREAM[11:5],10'h000};
                          temp_next_SHIFT = 6'h07;
                          mark = STREAM[4];
                      end
                    4'h9: 
                      begin
                          PARAD = {STREAM[11:4],10'h000};
                          temp_next_SHIFT = 6'h08;
                          mark = STREAM[3];
                      end
                    default:
                      begin
                          PARAD = 18'h00000;
                          temp_next_SHIFT = 6'h0;
                          mark = 1'b1;
                      end
                  endcase
              end
            else 
              begin
                  mark = 1'b1;
                  if(vecidx_s_r==1'b0) 
                    begin
                        case(forward_r_size) 
                          3'h1: 
                            begin
                                PARAD = {7'h00,STREAM[11],10'h000};
                                temp_next_SHIFT = 6'h01;
                            end
                          3'h2: 
                            begin
                                PARAD = {6'h00,STREAM[11:10],10'h000};
                                temp_next_SHIFT = 6'h02;
                            end
                          3'h3: 
                            begin
                                PARAD = {5'h00,STREAM[11:9],10'h000};
                                temp_next_SHIFT = 6'h03;
                            end
                          3'h4: 
                            begin
                                PARAD = {4'h0,STREAM[11:8],10'h000};
                                temp_next_SHIFT = 6'h04;
                            end
                          3'h5: 
                            begin
                                PARAD = {3'h0,STREAM[11:7],10'h000};
                                temp_next_SHIFT = 6'h05;
                            end
                          3'h6: 
                            begin
                                PARAD = {2'h0,STREAM[11:6],10'h000};
                                temp_next_SHIFT = 6'h06;
                            end
                          3'h7: 
                            begin
                                PARAD = {1'b0,STREAM[11:5],10'h000};
                                temp_next_SHIFT = 6'h07;
                            end
                          default:
                            begin
                                PARAD = 18'h00000;
                                temp_next_SHIFT = 6'h00;
                            end
                        endcase
                    end
                  else 
                    begin
                        case(backward_r_size) 
                          3'h1:
                            begin
                                PARAD = {7'h00,STREAM[11],10'h000};
                                temp_next_SHIFT = 6'h01;
                            end
                          3'h2: 
                            begin
                                PARAD = {6'h00,STREAM[11:10],10'h000};
                                temp_next_SHIFT = 6'h02;
                            end
                          3'h3: 
                            begin
                                PARAD = {5'h00,STREAM[11:9],10'h000};
                                temp_next_SHIFT = 6'h03;
                            end
                          3'h4: 
                            begin
                                PARAD = {4'h0,STREAM[11:8],10'h000};
                                temp_next_SHIFT = 6'h04;
                            end
                          3'h5: 
                            begin
                                PARAD = {3'h0,STREAM[11:7],10'h000};
                                temp_next_SHIFT = 6'h05;
                            end
                          3'h6: 
                            begin
                                PARAD = {2'h0,STREAM[11:6],10'h000};
                                temp_next_SHIFT = 6'h06;
                            end
                          3'h7: 
                            begin
                                PARAD = {1'b0,STREAM[11:5],10'h000};
                                temp_next_SHIFT = 6'h07;
                            end
                          default:
                            begin
                                PARAD = 18'h00000;
                                temp_next_SHIFT = 6'h00;
                            end
                        endcase
                    end
              end

            if((MPEG1==P_MPEG_2) &&
               (
                (vecidx_t_r==1&&dmv!=1'b1) && 
                (vecidx_r_r==1'b1||(motion_vector_count==2'b01&&vecidx_r_r==1'b0)) && 
                ((vecidx_s_r==1'b0&&mmbwd==1'b0)||vecidx_s_r==1'b1) && 
                (AFTER_INTRA==1'b1&&CONCEALMENT_MOTION_VECTORS==1'b1) 
                )
               )
              begin
                  if (mark == 1'b0)
                    NFERROR = P_ERROR;
                  else
                    NFERROR = P_NO_ERROR;
                  SHIFT = temp_next_SHIFT +1;
              end 
            else 
              begin
                  NFERROR = P_NO_ERROR;
                  SHIFT = temp_next_SHIFT;
              end

            if(
                ((MPEG1 == P_MPEG_2) &
                ((vecidx_t_r == 1'b1) & (dmv != 1'b1)) & 
                ((vecidx_r_r == 1'b1)|((motion_vector_count == 2'b01)&(vecidx_r_r == 1'b0))) &
                (((vecidx_s_r == 1'b0) & (mmbwd == 1'b0))|(vecidx_s_r == 1'b1)) &
                (mb_pattern == 1'b0))  
               | ((MPEG1 == P_MPEG_1) & 
                  (vecidx_t_r == 1'b1) &
                  (((mmbwd == 1'b0) & (vecidx_s_r == 1'b0)) | (vecidx_s_r == 1'b1)) & 
                  (mb_pattern == 1'b0))  
               )
              next_enddec = 1'b1;
            else
              next_enddec = 1'b0;
            next_AFTER_INTRA = AFTER_INTRA;
            next_mmfwd = mmfwd;
            next_mmbwd = mmbwd;
            next_mb_quant = mb_quant;
            next_mb_pattern = mb_pattern;
            next_motion_vector_count = motion_vector_count;
            next_dmv = dmv;
            next_mv_format = mv_format;
            next_m_code = m_code;
            next_adr_hld = adr_hld;
            next_adr_inc = 8'h00;
            temp_next_SHIFT = 6'h00;
            mismatch = 1'b0;
            next_CBP = CBP;
            next_v_mbadet_r_s = 1'b0;
        end

      P_DMVC: begin
          mark = 1'b1;
          case (STREAM[11:10]) 
            2'b00 , 2'b01 :  // 0
              begin
                  PARAD = {2'b00,16'h0000};
                  temp_next_SHIFT = 6'h01;
              end
            2'b11:  // -1
              begin
                  PARAD = {2'b11,16'h0000};
                  temp_next_SHIFT = 6'h02;
              end
            2'b10:  // 1
              begin
                  PARAD = {2'b01,16'h0000};
                  temp_next_SHIFT = 6'h02;
              end
          endcase
          SHIFT = temp_next_SHIFT;
          NFERROR = P_NO_ERROR;
          if((vecidx_t_r==1'b1) 
             &&(vecidx_r_r==1'b1||(motion_vector_count==2'b01&&vecidx_r_r==1'b0))
             &&((vecidx_s_r==1'b0&&mmbwd==1'b0)||vecidx_s_r==1'b1) 
             &&(mb_pattern == 1'b0)) 
            next_enddec = 1'b1;
          else
            next_enddec = 1'b0;
          next_AFTER_INTRA = AFTER_INTRA;
          next_mmfwd = mmfwd;
          next_mmbwd = mmbwd;
          next_mb_quant = mb_quant;
          next_mb_pattern = mb_pattern;
          next_motion_vector_count = motion_vector_count;
          next_dmv = dmv;
          next_mv_format = mv_format;
          next_m_code = m_code;
          next_adr_hld = adr_hld;
          next_adr_inc = 8'h00;
          temp_next_SHIFT = 6'h00;
          mismatch = 1'b0;
          next_CBP = CBP;
          next_v_mbadet_r_s = 1'b0;
      end

      P_CBP0: 
        begin
            casex (STREAM[11:3]) 
              9'b111??????: 
                begin
                    PARAD = {6'd60,12'h000};
                    next_CBP = 6'd60;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h03; 
                end
              9'b1101?????: 
                begin
                    PARAD = {6'd4,12'h000};
                    next_CBP = 6'd4;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h04; 
                end
              9'b1100?????: 
                begin
                    PARAD = {6'd8,12'h000};
                    next_CBP = 6'd8;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h04; 
                end
              9'b1011?????: 
                begin
                    PARAD = {6'd16,12'h000};
                    next_CBP = 6'd16;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h04; 
                end
              9'b1010?????: 
                begin
                    PARAD = {6'd32,12'h000};
                    next_CBP = 6'd32;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h04; 
                end
              9'b10011????: 
                begin
                    PARAD = {6'd12,12'h000};
                    next_CBP = 6'd12;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h05; 
                end
              9'b10010????: 
                begin
                    PARAD = {6'd48,12'h000};
                    next_CBP = 6'd48;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h05; 
                end
              9'b10001????: 
                begin
                    PARAD = {6'd20,12'h000};
                    next_CBP = 6'd20;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h05; 
                end
              9'b10000????: 
                begin
                    PARAD = {6'd40,12'h000};
                    next_CBP = 6'd40;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h05; 
                end
              9'b01111????: 
                begin
                    PARAD = {6'd28,12'h000};
                    next_CBP = 6'd28;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h05; 
                end
              9'b01110????: 
                begin
                    PARAD = {6'd44,12'h000};
                    next_CBP = 6'd44;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h05; 
                end
              9'b01101????: 
                begin
                    PARAD = {6'd52,12'h000};
                    next_CBP = 6'd52;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h05; 
                end
              9'b01100????: 
                begin
                    PARAD = {6'd56,12'h000};
                    next_CBP = 6'd56;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h05; 
                end
              9'b01011????: 
                begin
                    PARAD = {6'd1,12'h000};
                    next_CBP = 6'd1;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h05; 
                end
              9'b01010????: 
                begin
                    PARAD = {6'd61,12'h000};
                    next_CBP = 6'd61;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h05; 
                end
              9'b01001????:  
                begin
                    PARAD = {6'd2,12'h000};
                    next_CBP = 6'd2;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h05; 
                end
              9'b01000????: 
                begin
                    PARAD = {6'd62,12'h000};
                    next_CBP = 6'd62;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h05; 
                end
              9'b001111???: 
                begin
                    PARAD = {6'd24,12'h000};
                    next_CBP = 6'd24;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h06; 
                end
              9'b001110???: 
                begin
                    PARAD = {6'd36,12'h000};
                    next_CBP = 6'd36;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h06; 
                end
              9'b001101???: 
                begin
                    PARAD = {6'd3,12'h000};
                    next_CBP = 6'd3;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h06; 
                end
              9'b001100???: 
                begin
                    PARAD = {6'd63,12'h000};
                    next_CBP = 6'd63;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h06; 
                end
              9'b0010111??:
                begin
                    PARAD = {6'd5,12'h000};
                    next_CBP = 6'd5;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h07; 
                end
              9'b0010110??: 
                begin
                    PARAD = {6'd9,12'h000};
                    next_CBP = 6'd9;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h07; 
                end
              9'b0010101??: 
                begin
                    PARAD = {6'd17,12'h000};
                    next_CBP = 6'd17;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h07; 
                end
              9'b0010100??: 
                begin
                    PARAD = {6'd33,12'h000};
                    next_CBP = 6'd33;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h07; 
                end
              9'b0010011??: 
                begin
                    PARAD = {6'd6,12'h000};
                    next_CBP = 6'd6;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h07; 
                end
              9'b0010010??: 
                begin
                    PARAD = {6'd10,12'h000};
                    next_CBP = 6'd10;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h07; 
                end
              9'b0010001??: 
                begin
                    PARAD = {6'd18,12'h000};
                    next_CBP = 6'd18;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h07; 
                end
              9'b0010000??: 
                begin
                    PARAD = {6'd34,12'h000};
                    next_CBP = 6'd34;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h07; 
                end
              9'b00011111?: 
                begin
                    PARAD = {6'd7,12'h000};
                    next_CBP = 6'd7;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b00011110?: 
                begin
                    PARAD = {6'd11,12'h000};
                    next_CBP = 6'd11;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b00011101?:  
                begin
                    PARAD = {6'd19,12'h000};
                    next_CBP = 6'd19;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b00011100?:
                begin
                    PARAD = {6'd35,12'h000};
                    next_CBP = 6'd35;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b00011011?:  
                begin
                    PARAD = {6'd13,12'h000};
                    next_CBP = 6'd13;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b00011010?: 
                begin
                    PARAD = {6'd49,12'h000};
                    next_CBP = 6'd49;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b00011001?: 
                begin
                    mismatch = 1'b0;
                    PARAD = {6'd21,12'h000};
                    next_CBP = 6'd21;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b00011000?: 
                begin
                    mismatch = 1'b0;
                    PARAD = {6'd41,12'h000};
                    next_CBP = 6'd41;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b00010111?: 
                begin
                    mismatch = 1'b0;
                    PARAD = {6'd14,12'h000};
                    next_CBP = 6'd14;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b00010110?: 
                begin
                    mismatch = 1'b0;
                    PARAD = {6'd50,12'h000};
                    next_CBP = 6'd50;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b00010101?:
                begin
                    mismatch = 1'b0;
                    PARAD = {6'd22,12'h000};
                    next_CBP = 6'd22;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b00010100?: 
                begin
                    mismatch = 1'b0;
                    PARAD = {6'd42,12'h000};
                    next_CBP = 6'd42;
                    temp_next_SHIFT = 6'h08;
                end
              9'b00010011?: 
                begin
                    mismatch = 1'b0;
                    PARAD = {6'd15,12'h000};
                    next_CBP = 6'd15;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b00010010?: 
                begin
                    PARAD = {6'd51,12'h000};
                    next_CBP = 6'd51;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b00010001?: 
                begin
                    PARAD = {6'd23,12'h000};
                    next_CBP = 6'd23;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b00010000?: 
                begin
                    PARAD = {6'd43,12'h000};
                    next_CBP = 6'd43;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b00001111?: 
                begin
                    PARAD = {6'd25,12'h000};
                    next_CBP = 6'd25;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b00001110?: 
                begin
                    PARAD = {6'd37,12'h000};
                    next_CBP = 6'd37;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b00001101?: 
                begin
                    PARAD = {6'd26,12'h000};
                    next_CBP = 6'd26;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b00001100?: 
                begin
                    PARAD = {6'd38,12'h000};
                    next_CBP = 6'd38;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h08;
                end
              9'b00001011?: 
                begin
                    PARAD = {6'd29,12'h000};
                    next_CBP = 6'd29;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b00001010?: 
                begin
                    PARAD = {6'd45,12'h000};
                    next_CBP = 6'd45;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b00001001?: 
                begin
                    PARAD = {6'd53,12'h000};
                    next_CBP = 6'd53;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h08;
                end
              9'b00001000?: 
                begin
                    PARAD = {6'd57,12'h000};
                    next_CBP = 6'd57;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b00000111?: 
                begin
                    PARAD = {6'd30,12'h000};
                    next_CBP =6'd30;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b00000110?:  
                begin
                    PARAD = {6'd46,12'h000};
                    next_CBP = 6'd46;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h08;
                end
              9'b00000101?:  
                begin
                    PARAD = {6'd54,12'h000};
                    next_CBP = 6'd54;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b00000100?: 
                begin
                    PARAD = {6'd58,12'h000};
                    next_CBP = 6'd58;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h08; 
                end
              9'b000000111: 
                begin
                    PARAD = {6'd31,12'h000};
                    next_CBP = 6'd31;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h09;
                end
              9'b000000110: 
                begin
                    PARAD = {6'd47,12'h000};
                    next_CBP = 6'd47;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h09; 
                end
              9'b000000101: 
                begin
                    PARAD = {6'd55,12'h000};
                    next_CBP = 6'd55;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h09; 
                end
              9'b000000100: 
                begin
                    PARAD = {6'd59,12'h000};
                    next_CBP = 6'd59;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h09; 
                end
              9'b000000011:
                begin
                    PARAD = {6'd27,12'h000};
                    next_CBP = 6'd27;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h09; 
                end
              9'b000000010: 
                begin
                    PARAD = {6'd39,12'h000};
                    next_CBP = 6'd39;
                    mismatch = 1'b0;
                    temp_next_SHIFT = 6'h09; 
                end
              default: 
                begin
                    PARAD = 18'h00000;
                    next_CBP = 6'h00;
                    mismatch = 1'b1;
                    temp_next_SHIFT = 6'h00; 
                end
            endcase
            SHIFT = temp_next_SHIFT;
            NFERROR = P_NO_ERROR;
            next_enddec = 1'b1;
            next_AFTER_INTRA = AFTER_INTRA;
            next_mmfwd = mmfwd;
            next_mmbwd = mmbwd;
            next_mb_pattern = mb_pattern;
            next_mb_quant = mb_quant;
            next_motion_vector_count = motion_vector_count;
            next_dmv = dmv;
            next_mv_format = mv_format;
            next_m_code = m_code;
            next_adr_hld = adr_hld;
            next_adr_inc = 8'h00;
            temp_next_SHIFT = 6'h00;
            next_v_mbadet_r_s = 1'b0;
            mark = 1'b1;
        end

      P_STFF: 
        begin
            PARAD = 18'h00000;
            SHIFT = 6'h0B;
            NFERROR = P_NO_ERROR;
            next_enddec = 1'b0;
            next_AFTER_INTRA = AFTER_INTRA;
            next_mmfwd = mmfwd;
            next_mmbwd = mmbwd;
            next_mb_pattern = mb_pattern;
            next_mb_quant = mb_quant;
            next_motion_vector_count = motion_vector_count;
            next_dmv = dmv;
            next_mv_format = mv_format;
            next_m_code = m_code;
            next_adr_hld = adr_hld;
            next_adr_inc = 8'h00;
            temp_next_SHIFT = 6'h00;
            next_CBP = CBP;
            next_v_mbadet_r_s = 1'b0;
            mismatch = 1'b0;
            mark = 1'b1;
        end

      default: begin
          mismatch = 1'b0;
          mark = 1'b1;
          SHIFT = 6'h00;
          PARAD = 18'h00000;
          NFERROR = P_NO_ERROR;
          next_enddec = 1'b0;
          next_AFTER_INTRA = AFTER_INTRA;
          next_mmfwd = mmfwd;
          next_mmbwd = mmbwd;
          next_mb_quant = mb_quant;
          next_mb_pattern = mb_pattern;
          next_motion_vector_count = motion_vector_count;
          next_dmv = dmv;
          next_mv_format = mv_format;
          next_m_code = m_code;
          next_adr_hld = adr_hld;
          next_adr_inc = 8'h00;
          temp_next_SHIFT = 6'h00;
          next_CBP = CBP;
          next_v_mbadet_r_s = 1'b0;
      end
    endcase

  always @(v_interrpt_n or paraa_a or next_state or STREAM) begin
      if (!v_interrpt_n) PARAA = 8'hff;
      else begin
          if (next_state == P_MBAI)begin 
              if(STREAM[11:1]==11'b00000001000)
                PARAA = 8'hff;
              else
                PARAA = 8'h50; 
          end
          else
            PARAA = paraa_a;
      end
  end    
  
  always  @(posedge clkdec or negedge rstdec_x) 
    begin
        if (!rstdec_x) 
          begin
              forward_r_size <= 3'h0;
              backward_r_size <= 3'h0;
              forward_f <= 2'h0;
              backward_f <= 2'h0;
          end
        else 
          begin
              forward_r_size <= FORWARD_F_CODE-1;
              backward_r_size <= BACKWARD_F_CODE-1;
              forward_f <= (FORWARD_F_CODE-1)<<1;
              backward_f <= (BACKWARD_F_CODE-1)<<1;
          end
    end

  always @(vecidx_s_r or FCODE_01 or FCODE_11)begin
      if(!vecidx_s_r) temp2_fcode = FCODE_01;
      else            temp2_fcode = FCODE_11;
  end

  always @(next_state or adr_inc or STREAM or AFTER_INTRA or  
           PICTURE_CODING_TYPE or SLICE_END or slice_head_r or 
           mismatch or PARAD)
    case(next_state) 
      P_IDLE: 
        FERROR = P_NO_ERROR;

      P_MBAI: 
        begin
            if ((PICTURE_CODING_TYPE==3'b001 
                 && (SLICE_END | slice_head_r)==1'b0
                 && PARAD!=18'h00001 && adr_inc==16'h0000)
                ||(PICTURE_CODING_TYPE==3'b100 
                   && (SLICE_END | slice_head_r)==1'b0
                   && PARAD!=18'h0001 && adr_inc==16'h0000)
                ||(PICTURE_CODING_TYPE==3'b011 && AFTER_INTRA==1'b1
                   && (SLICE_END | slice_head_r)==1'b0 && PARAD!=18'h00001 
                   && adr_inc == 16'h0000) 
                || mismatch==1'b1)     
              begin
                  FERROR = P_ERROR;
              end
            else begin
                FERROR = P_NO_ERROR;
            end
        end
      P_WAIT :
        FERROR = P_NO_ERROR;

      P_MTYP: 
        if (mismatch)
          FERROR = P_ERROR;
        else 
          FERROR = P_NO_ERROR;

      P_FRMT: 
        if(STREAM[11:10]==2'b00) 
          FERROR = P_ERROR;
        else
          FERROR = P_NO_ERROR;

      P_FLMT: 
        if (STREAM[11:10]==2'b00)
          FERROR = P_ERROR;
        else
          FERROR = P_NO_ERROR;

      P_DTYP: 
        FERROR = P_NO_ERROR;

      P_QSCD: 
        if(STREAM[11:7] == 5'h00) 
          FERROR = P_ERROR;
        else
          FERROR = P_NO_ERROR;

      P_MVFS: 
        FERROR = P_NO_ERROR;

      P_MCOD: 
        if(mismatch) 
          FERROR = P_ERROR;
        else
          FERROR = P_NO_ERROR;

      P_MRES: 
        FERROR = P_NO_ERROR;

      P_DMVC: 
        FERROR = P_NO_ERROR;

      P_CBP0: 
        if(mismatch) 
          FERROR = P_ERROR;
        else
          FERROR = P_NO_ERROR;

      P_STFF: 
        FERROR = P_NO_ERROR;

      default:
        FERROR = P_NO_ERROR;
endcase

endmodule
