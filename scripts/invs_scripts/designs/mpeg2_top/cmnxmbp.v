// ----------------------------------------------
// File: cmnxmbp.v
// Module: cmnxmbp
// Function:
// ----------------------------------------------

module cmnxmbp (
    clkdec,           
    rstdec_x,         
    c_mbai_r,             //macroblock_address_increment
    c_svp_r,              //slice_vertical_position
    c_pcth_mb_r,          //Picture Horizontal Size
    c_shdet_r,            //Slice Header Detected
    c_mbaidet_s,          //MBAI Detected
    c_mbv_adr_nxt_r,      //Next MB Vertical Position
    c_mbh_adr_nxt_r,      //Next MB Horizontal Position
    c_mb_nxt_fix_r        //Next MB Fix
  );
    input        clkdec;     
    input        rstdec_x;   
    input [17:0] c_mbai_r;     
    input [7:0]  c_svp_r;      
    input [6:0]  c_pcth_mb_r;  
    input        c_shdet_r;    
    input        c_mbaidet_s;  
    output [7:0] c_mbv_adr_nxt_r; 
    output [6:0] c_mbh_adr_nxt_r; 
    output       c_mb_nxt_fix_r;  

    reg [7:0]  c_mbv_adr_nxt_r;  
    reg [6:0]  c_mbh_adr_nxt_r;  
    reg        c_mb_nxt_fix_r;   

    reg [7:0]  c_pre_mbv_adr_nxt_r; 
    reg [17:0] c_pre_mbh_adr_nxt_r; 
    reg        c_pre_mb_nxt_fix_r;  
    reg        c_mbaidet_s_r;       
    reg        c_mbh_over_s_r;      

    wire        c_mbh_g_pcth;  
    wire [17:0] c_pcth_mb_18;  
    wire        c_mbh_over_s;  


//--Comp,Ext,Edge--
    assign c_mbh_g_pcth = (c_pre_mbh_adr_nxt_r > {11'd0,c_pcth_mb_r})
      ? 1'b1 : 1'b0;
    assign c_pcth_mb_18 = {11'b000_0000_0000,c_pcth_mb_r};
    assign c_mbh_over_s = ~c_mbh_g_pcth & ~c_mbh_over_s_r;

//--(Pre)Next Horizontal Position
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_pre_mbh_adr_nxt_r <= 18'h00001;
          end
        else if (c_mbaidet_s)
          begin
            if (c_shdet_r)
              begin
                c_pre_mbh_adr_nxt_r <= c_mbai_r;
              end
            else
              begin
                c_pre_mbh_adr_nxt_r <= c_pre_mbh_adr_nxt_r + c_mbai_r;
              end
          end
        else if (c_mbh_g_pcth)
          begin
            c_pre_mbh_adr_nxt_r <= c_pre_mbh_adr_nxt_r
                                     + (~c_pcth_mb_18) + 1;
          end
        else
          begin
            c_pre_mbh_adr_nxt_r <= c_pre_mbh_adr_nxt_r;
          end
      end

//--(Pre)Next Vertical Position Counter
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_pre_mbv_adr_nxt_r <= 8'b0000_0001;
          end
        else if (c_shdet_r && c_mbaidet_s)
          begin
            c_pre_mbv_adr_nxt_r <= c_svp_r;
          end
        else if (c_mbh_g_pcth)
          begin                              
            c_pre_mbv_adr_nxt_r <= c_pre_mbv_adr_nxt_r + 1;
          end
        else                                 
          begin
            c_pre_mbv_adr_nxt_r <= c_pre_mbv_adr_nxt_r;
          end
      end

//--Next Horizontal Position F/F--
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)        
          begin
            c_mbh_adr_nxt_r <= 7'b000_0001; 
          end
        else if (c_pre_mb_nxt_fix_r)
          begin
            c_mbh_adr_nxt_r <= c_pre_mbh_adr_nxt_r[6:0];
          end
        else
          begin
            c_mbh_adr_nxt_r <= c_mbh_adr_nxt_r;
          end
      end

//--Next Vertical Position Counter--
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)      
          begin
            c_mbv_adr_nxt_r <= 8'b0000_0001;
          end
        else if (c_pre_mb_nxt_fix_r)
          begin
            c_mbv_adr_nxt_r <= c_pre_mbv_adr_nxt_r[7:0];
          end
        else
          begin
            c_mbv_adr_nxt_r <= c_mbv_adr_nxt_r;
          end
      end

//--MBAI Detected Shift--
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)            
          begin
            c_mbaidet_s_r  <= 1'b0;
            c_mbh_over_s_r <= 1'b0;
            c_mb_nxt_fix_r <= 1'b0;
          end
        else
          begin
            c_mbaidet_s_r  <= c_mbaidet_s;
            c_mbh_over_s_r <= ~c_mbh_g_pcth;
            c_mb_nxt_fix_r <= c_pre_mb_nxt_fix_r;
          end
      end

//--Next MB Fix--
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)         
          begin
            c_pre_mb_nxt_fix_r <= 1'b0;
          end
        else if (c_mbaidet_s_r)
          begin
            if (!c_mbh_g_pcth)
              begin
                c_pre_mb_nxt_fix_r <= 1'b1;
              end
            else
              begin
                c_pre_mb_nxt_fix_r <= c_pre_mb_nxt_fix_r;
              end
          end
        else if (c_mbh_over_s)
          begin
            if (!c_mbh_g_pcth)
              begin
                c_pre_mb_nxt_fix_r <= 1'b1;
              end
            else
              begin
                c_pre_mb_nxt_fix_r <= c_pre_mb_nxt_fix_r;
              end
          end
        else
          begin
            c_pre_mb_nxt_fix_r <= 1'b0;
          end
      end

endmodule

