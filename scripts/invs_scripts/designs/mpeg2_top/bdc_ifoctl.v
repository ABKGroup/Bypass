// ----------------------------------------------
// File: bdc_ifoctl.v
// Module: bdc_ifoctl
// Function: 
// ----------------------------------------------

module bdc_ifoctl(
  clkdec,
  rstdec_x,
  vwh_acceptance_r,
  vwh_data_wait,
  w1_rcn00_q,
  w1_rcn01_q,
  w1_rcn02_q,
  b_dtflg0_r,
  b_dtflg1_r,
  b_dtflg2_r,
  b_hdtvh_r,
  b_fld_numt_r,
  b_fld_numb_r,
  b_mbh_adr_r,
  b_mbvt_adr_r,
  b_mbvb_adr_r,
  b_bfcnt_init_r,
  b_request_r,
  b_field_num_r,
  b_addressx_r,
  b_addressy_r,
  b_byte_num_r,
  b_line_num_r,
  b_write_data,
  b_write_enable_r,
  b_rdhdtvh_r,
  b_rdreq0,
  b_rdreq1,
  b_rdreq2
  );
  
  input         clkdec;       
  input         rstdec_x;     
  input         vwh_acceptance_r; 
  input         vwh_data_wait;    
  input [63:0]  w1_rcn00_q;       
  input [63:0]  w1_rcn01_q;       
  input [63:0]  w1_rcn02_q;       
  input         b_dtflg0_r;     
  input         b_dtflg1_r;     
  input         b_dtflg2_r;     
  input         b_hdtvh_r;      
  input [3:0]   b_fld_numt_r;   
  input [3:0]   b_fld_numb_r;   
  input [7:0]   b_mbh_adr_r;    
  input [8:0]   b_mbvt_adr_r;   
  input [8:0]   b_mbvb_adr_r;   
  input         b_bfcnt_init_r; 
  
  
  output        b_request_r;    
  output [3:0]  b_field_num_r;  
  output [7:0]  b_addressx_r;   
  output [8:0]  b_addressy_r;   
  output [1:0]  b_byte_num_r;   
  output [2:0]  b_line_num_r;   
  output [63:0] b_write_data;   
  output        b_write_enable_r;
  output        b_rdhdtvh_r;    
  output        b_rdreq0;       
  output        b_rdreq1;        
  output        b_rdreq2;        

  wire          clkdec;        
  wire          rstdec_x;  
  wire [63:0]   w1_rcn00_q;           // DC Bus I/F Buffer Memory1 Read Data
  wire [63:0]   w1_rcn01_q;           // DC Bus I/F Buffer Memory2 Read Data
  wire [63:0]   w1_rcn02_q;           // DC Bus I/F Buffer Memory3 Read Data
  wire          b_dtflg0_r;           // DC Bus I/F Buffer Memory1 Write End Flag
  wire          b_dtflg1_r;           // DC Bus I/F Buffer Memory2 Write End Flag
  wire          b_dtflg2_r;           // DC Bus I/F Buffer Memory3 Write End Flag
  wire          b_hdtvh_r;            // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  wire [3:0]    b_fld_numt_r;         // Write Field Number1(Top)            
  wire [3:0]    b_fld_numb_r;         // Write Field Number2(Bottom)         
  wire [7:0]    b_mbh_adr_r;          // Write Field Horizontal Address      
  wire [8:0]    b_mbvt_adr_r;         // Write Field Vertical Address(Top)   
  wire [8:0]    b_mbvb_adr_r;         // Write Field Vertical Address(Bottom)
  wire          b_rdreq0;             // SRAM1 Read Request
  wire          b_rdreq1;             // SRAM2 Read Request
  wire          b_rdreq2;             // SRAM3 Read Request
  wire          b_acc;                // Request Permission
  wire          b_acc_pos;            // b_acc Posedge
  wire          b_req_cnt_dc0;        // b_req_cnt_r != 4'h0
  wire          b_dto_cnt_dc0a;       // b_dto_cnt_r Decode(0ah)
  wire          b_dto_cnt_dc0b;       // b_dto_cnt_r Decode(0bh)
  wire          b_dto_cnt_dc2e;       // b_dto_cnt_r Decode(2eh)
  wire          b_dto_cnt_dc2f;       // b_dto_cnt_r Decode(2fh)
  wire          b_dto_cnt_dc3f;       // b_dto_cnt_r Decode(3fh)
  wire          b_req_cnt_cd;         // b_req_cnt_r Count Down
  wire          b_dto_cnt_ld;         // b_dto_cnt_t Load Data
  wire          b_data_wait_pos;      // b_data_wait_r Posedge
  wire          b_data_wait_neg;      // b_data_wait_r Negedge
  wire [63:0]   b_wdata1;             // Write Data1 Select
  wire [63:0]   b_wdata2;             // Write Data2 Select
  wire [63:0]   b_wdata3;             // Write Data3 Select
  

  reg           b_request_r;          // I/F Output Request
  reg [3:0]     b_field_num_r;        // Field Number
  reg [7:0]     b_addressx_r;         // Field Horizontal Address
  reg [8:0]     b_addressy_r;         // Field Vertical Address
  reg [1:0]     b_byte_num_r;         // Byte Number/1 Data Line
  reg [2:0]     b_line_num_r;         // Line Number/1 Block
  reg           b_rdhdtvh_r;          // Read HDTV/SDTV Select[0:SDTV 1:HDTV]
  reg           b_write_enable_r;     // I/F Write Enable
  reg [63:0]    b_write_data;         // I/F Write Data
  reg [3:0]     b_reqout_cnt_r;       // b_request_r Output Number Counter
  reg           b_reqout_cnt_dc0_r;   // b_reqout_cnt_r Decode(Not 0h)
  reg           b_acc_d1_r;           // b_acc 1CLK Delay
  reg [1:0]     b_param_cnt_r;        // Parameter Control Counter
  reg [2:0]     b_rinum_r;            // SRAM Read Field Information Control
  reg           b_dtflg0_d1_r;        // b_dtflg0_r 1CLK Delay
  reg           b_dtflg1_d1_r;        // b_dtflg1_r 1CLK Delay
  reg           b_dtflg2_d1_r;        // b_dtflg2_r 1CLK Delay
  reg           b_dtflg0_pos_r;       // b_dtflg0_r Posedge
  reg           b_dtflg1_pos_r;       // b_dtflg1_r Posedge
  reg           b_dtflg2_pos_r;       // b_dtflg2_r Posedge
  reg           b_hdtvh1_r;           // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  reg [3:0]     b_fld_numt1_r;        // Write Field Number1(Top)            
  reg [3:0]     b_fld_numb1_r;        // Write Field Number2(Bottom)         
  reg [7:0]     b_mbh_adr1_r;         // Write Field Horizontal Address      
  reg [8:0]     b_mbvt_adr1_r;        // Write Field Vertical Address(Top)   
  reg [8:0]     b_mbvb_adr1_r;        // Write Field Vertical Address(Bottom)
  reg           b_hdtvh2_r;           // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  reg [3:0]     b_fld_numt2_r;        // Write Field Number1(Top)            
  reg [3:0]     b_fld_numb2_r;        // Write Field Number2(Bottom)         
  reg [7:0]     b_mbh_adr2_r;         // Write Field Horizontal Address      
  reg [8:0]     b_mbvt_adr2_r;        // Write Field Vertical Address(Top)   
  reg [8:0]     b_mbvb_adr2_r;        // Write Field Vertical Address(Bottom)
  reg           b_hdtvh3_r;           // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  reg [3:0]     b_fld_numt3_r;        // Write Field Number1(Top)            
  reg [3:0]     b_fld_numb3_r;        // Write Field Number2(Bottom)         
  reg [7:0]     b_mbh_adr3_r;         // Write Field Horizontal Address      
  reg [8:0]     b_mbvt_adr3_r;        // Write Field Vertical Address(Top)   
  reg [8:0]     b_mbvb_adr3_r;        // Write Field Vertical Address(Bottom)
  reg           b_phdtvh_r;           // MB HDTV/SDTV Select[0:SDTV 1:HDTV]
  reg [3:0]     b_pfld_numt_r;        // Write Field Number1(Top)            
  reg [3:0]     b_pfld_numb_r;        // Write Field Number2(Bottom)         
  reg [7:0]     b_pmbh_adr_r;         // Write Field Horizontal Address      
  reg [8:0]     b_pmbvt_adr_r;        // Write Field Vertical Address(Top)   
  reg [8:0]     b_pmbvb_adr_r;        // Write Field Vertical Address(Bottom)
  reg [3:0]     b_req_cnt_r;          // Request Counter
  reg [5:0]     b_dto_cnt_r;          // Data Output Counter
  reg [2:0]     b_rdnum_r;            // SRAM Read Field Control Counter
  reg [63:0]    b_rcn00_q_r;          // DC Bus I/F Buffer Memory1 Read Data
  reg [63:0]    b_rcn0_r;             // DC Bus I/F Buffer Memory1 Read Data
  reg [63:0]    b_rcn01_q_r;          // DC Bus I/F Buffer Memory2 Read Data
  reg [63:0]    b_rcn1_r;             // DC Bus I/F Buffer Memory2 Read Data
  reg [63:0]    b_rcn02_q_r;          // DC Bus I/F Buffer Memory3 Read Data
  reg [63:0]    b_rcn2_r;             // DC Bus I/F Buffer Memory3 Read Data
  reg           b_data_wait_r;        // Data Wait
  reg           b_data_wait_neg_r;    // b_data_wait_r Negedge
  reg [2:0]     b_rdnum_d1_r;         // b_rdnum_r 1CLK Delay
  reg [2:0]     b_rdnum_d2_r;         // b_rdnum_r 2CLK Delay
  reg [1:0]     b_pwrite_enb_r;       // Pre I/F Write Enable
  reg           b_dto_cnt_ld_r;       // b_dto_cnt_t Load Data
  reg [2:0]     b_dtflg_pos_dly_r;    // b_dtflg?_pos_r Delay
  

  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_reqout_cnt_r <= 4'h0;
    end
    else if( b_dtflg0_pos_r || b_dtflg1_pos_r|| b_dtflg2_pos_r ) begin
      if ( b_request_r ) begin
        b_reqout_cnt_r <= b_reqout_cnt_r + 4'h3;
      end
      else begin
        b_reqout_cnt_r <= b_reqout_cnt_r + 4'h4;
      end
    end
    else if ( b_request_r ) begin
      b_reqout_cnt_r <= b_reqout_cnt_r - 1'b1;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_reqout_cnt_dc0_r <= 1'b0;
    end
    else if ( b_reqout_cnt_r == 4'h0 ) begin
      b_reqout_cnt_dc0_r <= 1'b0;
    end
    else begin
      b_reqout_cnt_dc0_r <= 1'b1;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_acc_d1_r     <= 1'b0;
    end
    else begin
      b_acc_d1_r     <= b_acc;
    end
  end

  assign b_acc     = vwh_acceptance_r & b_reqout_cnt_dc0_r;
  assign b_acc_pos = b_acc & (~b_acc_d1_r);
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_request_r <= 1'b0;
    end
    else begin
      b_request_r <= b_acc_pos;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_param_cnt_r <= 2'b00;
    end
    else if ( b_bfcnt_init_r ) begin
      b_param_cnt_r <= 2'b00;
    end
    else if ( b_acc_pos ) begin
      b_param_cnt_r <= b_param_cnt_r + 1'b1;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_rinum_r <= 3'h1;
    end
    else if ( b_bfcnt_init_r ) begin
      b_rinum_r <= 3'h1;
    end
    else if ( b_acc_pos && ( b_param_cnt_r == 2'h3 ) ) begin
      b_rinum_r <= {b_rinum_r[1:0],b_rinum_r[2]};
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_dtflg0_d1_r <= 1'b0;
      b_dtflg1_d1_r <= 1'b0;
      b_dtflg2_d1_r <= 1'b0;
    end
    else begin
      b_dtflg0_d1_r <= b_dtflg0_r;
      b_dtflg1_d1_r <= b_dtflg1_r;
      b_dtflg2_d1_r <= b_dtflg2_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_dtflg0_pos_r <= 1'b0;
      b_dtflg1_pos_r <= 1'b0;
      b_dtflg2_pos_r <= 1'b0;
    end
    else begin
      b_dtflg0_pos_r <= b_dtflg0_r & (~b_dtflg0_d1_r);
      b_dtflg1_pos_r <= b_dtflg1_r & (~b_dtflg1_d1_r);
      b_dtflg2_pos_r <= b_dtflg2_r & (~b_dtflg2_d1_r);
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_hdtvh1_r    <= 1'b0;
      b_fld_numt1_r <= 4'h0;
      b_fld_numb1_r <= 4'h0;
      b_mbh_adr1_r  <= 8'h0;
      b_mbvt_adr1_r <= 9'h000;
      b_mbvb_adr1_r <= 9'h000;
    end
    else if ( b_dtflg0_pos_r ) begin
      b_hdtvh1_r    <= b_hdtvh_r;
      b_fld_numt1_r <= b_fld_numt_r;
      b_fld_numb1_r <= b_fld_numb_r;
      b_mbh_adr1_r  <= b_mbh_adr_r;
      b_mbvt_adr1_r <= b_mbvt_adr_r;
      b_mbvb_adr1_r <= b_mbvb_adr_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_hdtvh2_r    <= 1'b0;
      b_fld_numt2_r <= 4'h0;
      b_fld_numb2_r <= 4'h0;
      b_mbh_adr2_r  <= 8'h0;
      b_mbvt_adr2_r <= 9'h000;
      b_mbvb_adr2_r <= 9'h000;
    end
    else if ( b_dtflg1_pos_r ) begin
      b_hdtvh2_r    <= b_hdtvh_r;
      b_fld_numt2_r <= b_fld_numt_r;
      b_fld_numb2_r <= b_fld_numb_r;
      b_mbh_adr2_r  <= b_mbh_adr_r;
      b_mbvt_adr2_r <= b_mbvt_adr_r;
      b_mbvb_adr2_r <= b_mbvb_adr_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_hdtvh3_r    <= 1'b0;
      b_fld_numt3_r <= 4'h0;
      b_fld_numb3_r <= 4'h0;
      b_mbh_adr3_r  <= 8'h0;
      b_mbvt_adr3_r <= 9'h000;
      b_mbvb_adr3_r <= 9'h000;
    end
    else if ( b_dtflg2_pos_r ) begin
      b_hdtvh3_r    <= b_hdtvh_r;
      b_fld_numt3_r <= b_fld_numt_r;
      b_fld_numb3_r <= b_fld_numb_r;
      b_mbh_adr3_r  <= b_mbh_adr_r;
      b_mbvt_adr3_r <= b_mbvt_adr_r;
      b_mbvb_adr3_r <= b_mbvb_adr_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_phdtvh_r    <= 1'b0;   
      b_pfld_numt_r <= 4'h0;
      b_pfld_numb_r <= 4'h0;
      b_pmbh_adr_r  <= 8'h00; 
      b_pmbvt_adr_r <= 9'h000;
      b_pmbvb_adr_r <= 9'h000;
    end
    else begin
      case ( b_rinum_r )
        3'b001 : begin
          b_phdtvh_r    <= b_hdtvh1_r;   
          b_pfld_numt_r <= b_fld_numt1_r;
          b_pfld_numb_r <= b_fld_numb1_r;
          b_pmbh_adr_r  <= b_mbh_adr1_r; 
          b_pmbvt_adr_r <= b_mbvt_adr1_r;
          b_pmbvb_adr_r <= b_mbvb_adr1_r;
        end
        3'b010 : begin
          b_phdtvh_r    <= b_hdtvh2_r;   
          b_pfld_numt_r <= b_fld_numt2_r;
          b_pfld_numb_r <= b_fld_numb2_r;
          b_pmbh_adr_r  <= b_mbh_adr2_r; 
          b_pmbvt_adr_r <= b_mbvt_adr2_r;
          b_pmbvb_adr_r <= b_mbvb_adr2_r;
        end
        3'b100 : begin
          b_phdtvh_r    <= b_hdtvh3_r;   
          b_pfld_numt_r <= b_fld_numt3_r;
          b_pfld_numb_r <= b_fld_numb3_r;
          b_pmbh_adr_r  <= b_mbh_adr3_r; 
          b_pmbvt_adr_r <= b_mbvt_adr3_r;
          b_pmbvb_adr_r <= b_mbvb_adr3_r;
        end
        default : begin
          b_phdtvh_r    <= 1'b0;   
          b_pfld_numt_r <= 4'h0;
          b_pfld_numb_r <= 4'h0;
          b_pmbh_adr_r  <= 8'h00; 
          b_pmbvt_adr_r <= 9'h000;
          b_pmbvb_adr_r <= 9'h000;
        end
      endcase
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_line_num_r <= 3'h0;
    end
    else if ( b_param_cnt_r[0] ) begin
      if ( b_phdtvh_r ) begin
        b_line_num_r <= 3'h1;
      end
      else begin
        b_line_num_r <= 3'h2;
      end
    end
    else begin
      if ( b_phdtvh_r ) begin
        b_line_num_r <= 3'h2;
      end
      else begin
        b_line_num_r <= 3'h4;
      end
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_byte_num_r <= 2'h0;
    end
    else if ( b_phdtvh_r ) begin
      b_byte_num_r <= 2'h0;
    end
    else begin
      b_byte_num_r <= 2'h1;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_field_num_r <= 4'h0;
    end
    else if ( b_param_cnt_r[1] ) begin
      b_field_num_r <= b_pfld_numb_r;
    end
    else begin
      b_field_num_r <= b_pfld_numt_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_addressx_r <= 8'h00;
    end
    else begin
      b_addressx_r <= b_pmbh_adr_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_addressy_r <= 9'h000;
    end
    else begin
      case ( b_param_cnt_r )
        2'b00 : b_addressy_r <= b_pmbvt_adr_r;
        2'b01 : b_addressy_r <= {1'b0,b_pmbvt_adr_r[8:1]};
        2'b10 : b_addressy_r <= b_pmbvb_adr_r;
        2'b11 : b_addressy_r <= {1'b0,b_pmbvb_adr_r[8:1]};
      endcase
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_rdhdtvh_r <= 1'b0;
    end
    else begin
      case ( b_rdnum_r )
        3'b001 : b_rdhdtvh_r <= b_hdtvh1_r;
        3'b010 : b_rdhdtvh_r <= b_hdtvh2_r;
        3'b100 : b_rdhdtvh_r <= b_hdtvh3_r;
        default : b_rdhdtvh_r <= 1'b0;
      endcase
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_dtflg_pos_dly_r <= 3'h0;
    end
    else begin
      b_dtflg_pos_dly_r[2:1] <= b_dtflg_pos_dly_r[1:0];
      b_dtflg_pos_dly_r[0]   <= b_dtflg0_pos_r | b_dtflg1_pos_r | b_dtflg2_pos_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_req_cnt_r <= 4'h0;
    end
    else if( b_bfcnt_init_r ) begin
      b_req_cnt_r <= 4'h0;
    end
    else if( (b_request_r && !b_req_cnt_cd && !b_req_cnt_dc0) ||
             (!b_req_cnt_cd && b_req_cnt_dc0 && b_dtflg_pos_dly_r[2]) ) begin
      b_req_cnt_r <= b_req_cnt_r + 1'b1;
    end
    else if( !((b_request_r && !b_req_cnt_dc0) ||
               (b_req_cnt_dc0 && b_dtflg_pos_dly_r[2])) && b_req_cnt_cd ) begin
      b_req_cnt_r <= b_req_cnt_r - 1'b1;
    end
  end
  assign b_req_cnt_dc0 = ( b_req_cnt_r != 4'h0 );
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_dto_cnt_r <= 6'h3f;
    end
    else if( b_bfcnt_init_r || b_dto_cnt_ld ) begin
      b_dto_cnt_r <= 6'h3f;
    end
    else if( !vwh_data_wait && b_req_cnt_dc0 ) begin
      b_dto_cnt_r <= b_dto_cnt_r + 1'b1;
    end
  end

  assign b_dto_cnt_dc0a = (b_dto_cnt_r == 6'h0a);
  assign b_dto_cnt_dc0b = (b_dto_cnt_r == 6'h0b);
  assign b_dto_cnt_dc2e = (b_dto_cnt_r == 6'h2e);
  assign b_dto_cnt_dc2f = (b_dto_cnt_r == 6'h2f);
  assign b_dto_cnt_dc3f = (b_dto_cnt_r == 6'h3f);
  assign b_req_cnt_cd   = (b_rdhdtvh_r) ? b_dto_cnt_dc0a : b_dto_cnt_dc2e ;
  assign b_dto_cnt_ld   = (b_rdhdtvh_r) ? b_dto_cnt_dc0b : b_dto_cnt_dc2f;
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_dto_cnt_ld_r <= 1'b0;
    end
    else begin
      b_dto_cnt_ld_r <= b_dto_cnt_ld & (~vwh_data_wait);
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_pwrite_enb_r <= 2'h0;
    end
    else begin
      b_pwrite_enb_r[1] <= b_pwrite_enb_r[0];
      b_pwrite_enb_r[0] <= b_req_cnt_dc0;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_write_enable_r <= 1'b0;
    end
    else if ( !vwh_data_wait ) begin
      b_write_enable_r <= b_pwrite_enb_r[1];
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_rdnum_r <= 3'h1;
    end
    else if ( b_bfcnt_init_r ) begin
      b_rdnum_r <= 3'h1;
    end
    else if ( b_dto_cnt_ld_r ) begin
      b_rdnum_r <= {b_rdnum_r[1:0],b_rdnum_r[2]};
    end
  end

  assign b_rdreq0 = b_rdnum_r[0] & b_req_cnt_dc0;
  assign b_rdreq1 = b_rdnum_r[1] & b_req_cnt_dc0;
  assign b_rdreq2 = b_rdnum_r[2] & b_req_cnt_dc0;
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_rdnum_d1_r <= 3'h1;
      b_rdnum_d2_r <= 3'h1;
    end
    else begin
      b_rdnum_d1_r <= b_rdnum_r;
      b_rdnum_d2_r <= b_rdnum_d1_r;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_rcn00_q_r <= 64'h0;
      b_rcn01_q_r <= 64'h0;
      b_rcn02_q_r <= 64'h0;
    end
    else if ( !vwh_data_wait ) begin
      b_rcn00_q_r <= w1_rcn00_q;
      b_rcn01_q_r <= w1_rcn01_q;
      b_rcn02_q_r <= w1_rcn02_q;
    end
  end
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_rcn0_r <= 64'h0;
      b_rcn1_r <= 64'h0;
      b_rcn2_r <= 64'h0;
    end
    else if ( b_data_wait_pos ) begin
      b_rcn0_r <= w1_rcn00_q;
      b_rcn1_r <= w1_rcn01_q;
      b_rcn2_r <= w1_rcn02_q;
    end
  end
  
  always @( b_rdnum_d2_r or b_wdata1 or b_wdata2 or b_wdata3) begin
    case ( b_rdnum_d2_r )
      3'b001 : b_write_data = b_wdata1;
      3'b010 : b_write_data = b_wdata2;
      3'b100 : b_write_data = b_wdata3;
      default : b_write_data = 64'h0;
    endcase
  end

  assign b_wdata1 = ( b_data_wait_neg_r ) ? b_rcn0_r : b_rcn00_q_r;
  assign b_wdata2 = ( b_data_wait_neg_r ) ? b_rcn1_r : b_rcn01_q_r;
  assign b_wdata3 = ( b_data_wait_neg_r ) ? b_rcn2_r : b_rcn02_q_r;
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_data_wait_r <= 1'b0;
    end
    else begin
      b_data_wait_r <= vwh_data_wait;
    end
  end

  assign b_data_wait_pos = vwh_data_wait & (~b_data_wait_r);
  assign b_data_wait_neg = (~vwh_data_wait) & b_data_wait_r;
  
  always @(posedge clkdec or negedge rstdec_x) begin
    if ( !rstdec_x ) begin
      b_data_wait_neg_r <= 1'b0;
    end
    else begin
      b_data_wait_neg_r <= b_data_wait_neg;
    end
  end
  
endmodule
