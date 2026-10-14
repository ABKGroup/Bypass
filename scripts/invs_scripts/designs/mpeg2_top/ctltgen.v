// ----------------------------------------------
// File: ctltgen.v
// Module: ctltgen
// Function:
// ----------------------------------------------

module ctltgen
  (
    clkdec,             //Clock
    rstdec_x,           //Asynchronous Reset(N)
    g_swrst_r_n,        //Software Reset(N)
    c_mbpl_cycl_r,      //[11:0] MB Pulse Cycle Period
    c_pcpl_r_s,         //Picture Processing Start Pulse
    c_mbpl_base_r_s     //MB Pulse(Base Pulse)
  );

    input        clkdec;       
    input        rstdec_x;     
    input        g_swrst_r_n;    
    input [11:0] c_mbpl_cycl_r;  
    input        c_pcpl_r_s;  
    output       c_mbpl_base_r_s;   

    reg [8:0]    c_mbpl_wait_cnt_r;    //MB Pulse Wait Cntr
    reg          c_mbpl_wait_enb_r;    //MB Pulse Wait Cntr Enb
    reg [11:0]   c_mbpl_base_cnt_r;    //MB Pulse Base Cntr
    reg          c_mbpl_base_enb_r;    //MB Pulse Base Cntr Enb
    reg          c_mbpl_base_r_s;      //MB Pulse(Base Pulse)
    reg [11:0]   c_mbpl_cycl_now_r;    //MB Pulse Base Cntr Cycle

    wire         c_mbpl_wait_max_s;      //MB Pulse Wait Cntr Max
    wire         c_mbpl_base_max_s;      //MB Pulse Base Cntr Max

    parameter  P_MBPL_WCYCL = 9'd192;    //MB Pulse Wait Cycle Period

//--MB Cycle Now
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_mbpl_cycl_now_r  <= 12'h1b0;
          end
        else if (c_pcpl_r_s)
          begin
            c_mbpl_cycl_now_r  <= c_mbpl_cycl_r;
          end
      end


//--WaitCnt ENB
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_mbpl_wait_enb_r  <= 1'b0;
          end
        else if (c_pcpl_r_s)
          begin
            c_mbpl_wait_enb_r  <= 1'b1;
          end
        else if (!g_swrst_r_n | c_mbpl_wait_max_s)
          begin
            c_mbpl_wait_enb_r  <= 1'b0;
          end
      end

//--WaitCnt--
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            c_mbpl_wait_cnt_r  <= 9'h00;
          end
        else if (!g_swrst_r_n | c_mbpl_wait_max_s)
          begin
            c_mbpl_wait_cnt_r  <= 9'h00;
          end
        else if (c_mbpl_wait_enb_r)
          begin
            c_mbpl_wait_cnt_r  <= c_mbpl_wait_cnt_r + 1;
          end
      end

    assign c_mbpl_wait_max_s = 
           ( c_mbpl_wait_cnt_r == (P_MBPL_WCYCL - 9'h001)) ? 1'b1 : 1'b0;

//-- MB Cnt ENB --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)      
          begin
            c_mbpl_base_enb_r  <= 1'b0;
          end
        else if (!g_swrst_r_n | c_pcpl_r_s)
          begin
            c_mbpl_base_enb_r  <= 1'b0;
          end
        else if (c_mbpl_wait_max_s)
          begin
            c_mbpl_base_enb_r  <= 1'b1;
          end
      end

//-- MB Cnt--
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            c_mbpl_base_cnt_r  <= 12'h000;
          end
        else if (!g_swrst_r_n | c_pcpl_r_s | c_mbpl_base_max_s )
          begin
            c_mbpl_base_cnt_r  <= 12'h000;
          end
        else if (c_mbpl_base_enb_r)
          begin
            c_mbpl_base_cnt_r  <= c_mbpl_base_cnt_r + 1;
          end
      end

    assign c_mbpl_base_max_s = 
           ( c_mbpl_base_cnt_r == (c_mbpl_cycl_now_r - 12'h001)) ? 1'b1 : 1'b0;

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            c_mbpl_base_r_s  <= 1'b0;
          end
        else
          begin
            c_mbpl_base_r_s  <= (c_mbpl_base_max_s | c_mbpl_wait_max_s);
          end
      end

endmodule

