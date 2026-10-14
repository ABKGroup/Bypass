// ----------------------------------------------
// File: vld_vlfeed.v
// Module: vld_vlfeed
// Function:bitstream feeder
// ----------------------------------------------

 module vld_vlfeed(
                      STREAM,
                      UREG,
                      ADP,
                      v1_bs_req_n,
                      clkdec,
                      rstdec_x,
                      g_swrst_r_n,
                      g_init_vld_r_s,
                      y1_bs_data,
                      y1_bs_wait_n,
                      SCSHIFT,
                      SEQ_SHIFT,
                      SQX_SHIFT,
                      SDX_SHIFT,
                      USR_SHIFT,
                      GOP_SHIFT,
                      PIC_SHIFT,
                      PDX_SHIFT,
                      PCX_SHIFT,
                      SLC_SHIFT,
                      MAC_SHIFT,
                      BLK_SHIFT,
                      CPR_SHIFT,
                      y1_bs_data_r
                      );

  output [31:0] STREAM;           // bitstream output
  output [31:0] UREG;             // upper buffer
  output [4:0]  ADP;              // accumulated shift value
  output        v1_bs_req_n;      // update request
  output [31:0]  y1_bs_data_r;       // data input

  input         clkdec;          
  input         rstdec_x;        
  input         g_swrst_r_n;      // s/w reset
  input         g_init_vld_r_s;   // vld init & kick
  input         y1_bs_wait_n;     // vld wait
  input [31:0]  y1_bs_data;       // data input
  input [5:0]   SCSHIFT;
  input [5:0]   SEQ_SHIFT;
  input [5:0]   SQX_SHIFT;
  input [5:0]   SDX_SHIFT;
  input [5:0]   USR_SHIFT;
  input [5:0]   GOP_SHIFT;
  input [5:0]   PIC_SHIFT;
  input [5:0]   PDX_SHIFT;
  input [5:0]   PCX_SHIFT;
  input [5:0]   SLC_SHIFT;
  input [5:0]   MAC_SHIFT;
  input [5:0]   BLK_SHIFT;
  input [5:0]   CPR_SHIFT;

  reg [31:0]    UREG;             // upper buffer
  reg [31:0]    lower;            // lower buffer
  reg [31:0]    temporal;         // temporal buffer
  reg           v1_bs_req_n;      // update request
  reg           feed_on;          // state
  reg           dselect_r;           // 1:temporal , 0:input
  reg [4:0]     ADP;              // accumulated shift value
  reg [31:0]    y1_bs_data_r;

  wire [31:0]   STREAM;           // bitstream output
  wire [31:0]   dummy32;          // dummy cell
  wire [5:0]    add;              // ADP + SHIFT
  wire [5:0]    vv1_next_shift_pre;   // all input shift
  wire [5:0]    vv1_next_shift;   // all input shift


  assign vv1_next_shift_pre = SCSHIFT   | 
                              SEQ_SHIFT | 
                              SQX_SHIFT | 
                              SDX_SHIFT | 
                              USR_SHIFT | 
                              GOP_SHIFT | 
                              PIC_SHIFT | 
                              PDX_SHIFT | 
                              PCX_SHIFT | 
                              SLC_SHIFT | 
                              MAC_SHIFT | 
                              CPR_SHIFT;

   assign vv1_next_shift = BLK_SHIFT | vv1_next_shift_pre;
                          
  always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          feed_on <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          feed_on <= 1'b0;
      end
      else if((!feed_on) & g_init_vld_r_s) begin
          feed_on <= 1'b1;
      end
      else begin
          feed_on <= feed_on;
      end
  end

   always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          v1_bs_req_n <= 1'b1;
      end
      else if(!g_swrst_r_n) begin
          v1_bs_req_n <= 1'b1;
      end
      else if((!feed_on) & g_init_vld_r_s) begin
          v1_bs_req_n <= 1'b0;
      end
      else if(feed_on & y1_bs_wait_n) begin 
          v1_bs_req_n <= ~add[5];
      end
      else begin
          v1_bs_req_n <= v1_bs_req_n;
      end
  end

  assign {STREAM,dummy32} = {UREG, lower} << ADP;
  assign add[5:0] = vv1_next_shift[5:0] + ADP[4:0];

  always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          ADP <= 5'd0;
      end
      else if(!g_swrst_r_n) begin
          ADP <= 5'd0;
      end
      else if(feed_on & y1_bs_wait_n) begin 
          ADP <= add[4:0];
      end
      else begin
          ADP <= ADP;
      end
  end

  always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          temporal <= 32'hffffffff;
      end
      else if(!g_swrst_r_n) begin
          temporal <= 32'hffffffff;
      end
      else if(feed_on & y1_bs_wait_n & !add[5] & !dselect_r) begin
          temporal <= y1_bs_data;
      end
      else begin
          temporal <= temporal;
      end
  end

  always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          UREG <= 32'hffffffff;
      end
      else if(!g_swrst_r_n) begin
          UREG <= 32'hffffffff;
      end
      else if(feed_on & y1_bs_wait_n & add[5]) begin
          UREG <= lower;
      end
      else begin
          UREG <= UREG;
      end
  end

  always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          lower <= 32'hffffffff;
      end
      else if(!g_swrst_r_n) begin
          lower <= 32'hffffffff;
      end
      else if(feed_on & y1_bs_wait_n & add[5]) begin
          if(dselect_r) lower <= temporal;
          else       lower <= y1_bs_data;
      end
      else begin
          lower <= lower;
      end
  end

  always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x) begin
          dselect_r <= 1'b0;
      end
      else if(!g_swrst_r_n) begin
          dselect_r <= 1'b0;
      end
      else if(feed_on & y1_bs_wait_n) begin 
          dselect_r <= ~add[5];
      end
      else begin
          dselect_r <= dselect_r;
      end
  end

  always @(posedge clkdec or negedge rstdec_x) begin
      if(!rstdec_x)
          y1_bs_data_r <= 32'h0;
      else 
          y1_bs_data_r <= y1_bs_data;
  end

endmodule
