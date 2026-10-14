// ----------------------------------------------
// File: ctautopd.v
// Module: ctautopd
// Function:
// ----------------------------------------------

module ctautopd (
    clkdec,               //Clock
    rstdec_x,             //Asynchronous Reset(N)
    g_swrst_r_n,          //Software Reset(N)
    c_auto_rpt_md_r,      //[1:0]Auto Repeat Mode
    c_pcpl_r_s,           //Picture Processing Time Start Pulse
    c_lwdly_r,            //Low Delay Mode
    c_auto_rpt_r,         //Auto Repeat Flag
    c_auto_rpt_05_r,      //Auto Repeat Half Frame
    c_auto_rpt_1_r,       //Auto Repeat 1 Frame
    c_auto_rpt_2_r        //Auto Repeat 2 Frame
  );

    input        clkdec;     
    input        rstdec_x;   
    input        g_swrst_r_n;  
    input [1:0]  c_auto_rpt_md_r;
    input        c_pcpl_r_s;    
    input        c_lwdly_r;     
    output       c_auto_rpt_r;  
    output       c_auto_rpt_05_r;
    output       c_auto_rpt_1_r; 
    output       c_auto_rpt_2_r; 

    reg          c_auto_rpt_r;           //auto repeat Flag
    reg          c_auto_rpt_05_r;        //auto repeat Half Frame 
    reg          c_auto_rpt_1_r;         //auto repeat 1 Frame  
    reg          c_auto_rpt_2_r;         //auto repeat 2 Frame     
    reg [1:0]    c_auto_rpt_md_d1_r;
    reg          c_lwdly_d1_r;      
    reg [1:0]    c_auto_state_r;    
    reg [1:0]    c_auto_nxt_state_r;

    wire         c_auto_rpt_det;  
    wire         c_auto_rpt_now;  
    wire [1:0]   c_auto_rpt_md_now; 
    wire         c_lwdly_diff;      

//--Parameter Generate
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_auto_rpt_md_d1_r <= 2'b00;
            c_lwdly_d1_r       <= 1'b0;
          end
        else if (!g_swrst_r_n)
          begin
            c_auto_rpt_md_d1_r <= 2'b00;
            c_lwdly_d1_r       <= 1'b0;
          end
        else if (c_pcpl_r_s)
          begin
            c_auto_rpt_md_d1_r <= c_auto_rpt_md_r;
            c_lwdly_d1_r       <= c_lwdly_r;
          end
      end

    assign c_auto_rpt_md_now = ( c_lwdly_r == 1'b1 ) ?
            c_auto_rpt_md_r : c_auto_rpt_md_d1_r;
    assign c_auto_rpt_det = | c_auto_rpt_md_r;
    assign c_auto_rpt_now = | c_auto_rpt_md_now;
    assign c_lwdly_diff = c_lwdly_r ^ c_lwdly_d1_r;

//--State Machine
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            c_auto_state_r <= 2'b00;
          end
        else if (!g_swrst_r_n)
          begin
            c_auto_state_r <= 2'b00;
          end
        else if (c_pcpl_r_s)
          begin
            c_auto_state_r <= c_auto_nxt_state_r;
          end
      end

//--State Change
    always @(c_auto_rpt_det or c_auto_rpt_now or 
              c_lwdly_r or c_lwdly_diff or c_auto_state_r)
      begin
        if (c_auto_state_r == 2'b00)
          begin
            if (c_auto_rpt_det == 1'b1)
              begin
                if (c_lwdly_r == 1'b0)
                  begin
                    c_auto_nxt_state_r = 2'b01; //pass 1
                  end
                else
                  begin
                    c_auto_nxt_state_r = 2'b10; //pass 2
                  end
              end
            else
              begin
                c_auto_nxt_state_r = 2'b00; //pass 12
              end
          end
        else if (c_auto_state_r == 2'b01) //State RPT1
          begin
            if (c_auto_rpt_now == 1'b0)
              begin
                c_auto_nxt_state_r = 2'b00; //pass 6
              end
            else
              begin
                c_auto_nxt_state_r = 2'b10; //pass 2
              end
          end
        else if (c_auto_state_r == 2'b10) //State RPT2
          begin
            if (c_auto_rpt_now == 1'b0)
              begin
                c_auto_nxt_state_r = 2'b00; //pass 7
              end
            else
              begin
                if (c_lwdly_diff == 1'b1)
                  begin
                    if (c_lwdly_r == 1'b0)
                      begin
                        c_auto_nxt_state_r = 2'b01; //pass 9
                      end
                    else
                      begin
                        c_auto_nxt_state_r = 2'b10; //pass 11
                      end
                  end
                else
                  begin
                    c_auto_nxt_state_r = 2'b11; //pass 3
                  end
              end
          end
        else // State RPT3
          begin
            if (c_auto_rpt_now == 1'b0)
              begin
                c_auto_nxt_state_r = 2'b00; //pass 8
              end
            else
              begin
                if (c_lwdly_diff == 1'b1)
                  begin
                    if (c_lwdly_r == 1'b1)
                      begin
                        c_auto_nxt_state_r = 2'b01; //pass 10
                      end
                    else
                      begin
                        c_auto_nxt_state_r = 2'b10; //pass 4
                      end
                  end
                else
                  begin
                    c_auto_nxt_state_r = 2'b10; //pass 4
                  end
              end
          end
      end

//--OutPut --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_auto_rpt_r    <= 1'b0; 
            c_auto_rpt_05_r <= 1'b0; 
            c_auto_rpt_1_r  <= 1'b0; 
            c_auto_rpt_2_r  <= 1'b0; 
          end
        else if (!g_swrst_r_n)
          begin
            c_auto_rpt_r    <= 1'b0; 
            c_auto_rpt_05_r <= 1'b0; 
            c_auto_rpt_1_r  <= 1'b0; 
            c_auto_rpt_2_r  <= 1'b0; 
          end
        else if (c_auto_rpt_md_now == 2'b10)
          begin
            c_auto_rpt_r    <= c_auto_rpt_now;
            c_auto_rpt_05_r <= (c_auto_state_r == 2'b11);
            c_auto_rpt_1_r  <= 1'b0;
            c_auto_rpt_2_r  <= 1'b0;
          end
        else if (c_auto_rpt_md_now == 2'b01)
          begin
            c_auto_rpt_r    <= c_auto_rpt_now;
            c_auto_rpt_05_r <= 1'b0;
            c_auto_rpt_1_r  <= (c_auto_state_r == 2'b10);
            c_auto_rpt_2_r  <= (c_auto_state_r == 2'b11);
          end
        else
          begin
            c_auto_rpt_r    <= 1'b0; 
            c_auto_rpt_05_r <= 1'b0; 
            c_auto_rpt_1_r  <= 1'b0; 
            c_auto_rpt_2_r  <= 1'b0; 
          end
      end

endmodule
