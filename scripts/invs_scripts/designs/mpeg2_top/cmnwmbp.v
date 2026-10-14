// ----------------------------------------------
// File: cmnwmbp.v
// Module: cmnwmbp
// Function:
// ----------------------------------------------

module cmnwmbp (
    clkdec,        
    rstdec_x,      
    c_pcpl_r_s,           //Picture Processing Start Pulse
    c_mbpl_pos_r_s,       //MB Pulse(MB Position Renobation)
    c_mbai_r,             //[P]macroblock_address_increment
    c_svp_r,              //[P]slice_vertical_position
    c_pctv_mb_r,          //Picture Vertical Size
    c_pcth_mb_r,          //Picture Horizontal Size
    c_rvs_mbp_r,          //MB Reverse Position Command
    c_mb_fin_r,           //Final MB Position
    c_mbv_adr_r,          //Now MB Vertical Position(-1)
    c_mbh_adr_r,          //Now MB Horizontal Position(-1)
    c_mbv_adr_p1_r,       //Now MB Vertical Position
    c_mbh_adr_p1_r        //Now MB Horizontal Position
  );
    input       clkdec;       
    input       rstdec_x;     
    input       c_pcpl_r_s;     
    input       c_mbpl_pos_r_s; 
    input [6:0] c_mbai_r;       
    input [6:0] c_svp_r;        
    input [6:0] c_pctv_mb_r;    
    input [6:0] c_pcth_mb_r;    
    input       c_rvs_mbp_r;    
    output       c_mb_fin_r;    
    output [6:0] c_mbv_adr_r;   
    output [6:0] c_mbh_adr_r;   
    output [6:0] c_mbv_adr_p1_r; 
    output [6:0] c_mbh_adr_p1_r; 

    reg       c_mb_fin_r;           //Final MB Position
    reg [6:0] c_mbv_adr_r;          //Now MB Vertical Position(-1)
    reg [6:0] c_mbh_adr_r;          //Now MB Horizontal Position(-1)
    reg [6:0] c_mbv_adr_p1_r;       //Now MB Vertical Position
    reg [6:0] c_mbh_adr_p1_r;       //Now MB Horizontal Position

    reg [6:0] c_pre_mbv_adr_r;      //(Pre)Now MB Vertical Position
    reg [6:0] c_pre_mbh_adr_r;      //(Pre)Now MB Horizontal Position
    reg       c_mbv_adr_co_r;       //Now MB V Position(-1) Carry Over
    reg       c_mbh_adr_co_r;       //Now MB H Position(-1) Carry Over

    wire c_v_match;   
    wire c_h_match;   
    wire c_last_pos;  


//--Position CHECK--
    assign c_v_match = ( c_pctv_mb_r == c_pre_mbv_adr_r ) ? 1'b1 : 1'b0;
    assign c_h_match = ( c_pcth_mb_r == c_pre_mbh_adr_r ) ? 1'b1 : 1'b0;
    assign c_last_pos = ( c_v_match & c_h_match ) ^ c_mbh_adr_co_r ^ c_mbv_adr_co_r ;

//--Now Vertical Position Counter--
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)             
          begin
            c_pre_mbv_adr_r <= 7'b000_0001;
          end
        else if (c_pcpl_r_s)         
          begin
            c_pre_mbv_adr_r <= 7'b000_0001;
          end
        else if (c_mbpl_pos_r_s)     
          begin
            if (c_rvs_mbp_r)
              begin
                c_pre_mbv_adr_r <= c_svp_r;
              end
            else if (c_last_pos || (c_pre_mbv_adr_r==7'b111_1111))
              begin                    
                c_pre_mbv_adr_r <= c_pre_mbv_adr_r;
              end
            else if (c_h_match)      
              begin
                c_pre_mbv_adr_r <= c_pre_mbv_adr_r + 1;
              end
            else
              begin
                c_pre_mbv_adr_r <= c_pre_mbv_adr_r;
              end
          end
        else
          begin
            c_pre_mbv_adr_r <= c_pre_mbv_adr_r;
          end
      end

//--Now Horizontal Position Counter--
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)         
          begin
            c_pre_mbh_adr_r <= 7'b000_0000;
          end
        else if (c_pcpl_r_s)     
          begin
            c_pre_mbh_adr_r <= 7'b000_0000;
          end
        else if (c_mbpl_pos_r_s) 
          begin
            if (c_rvs_mbp_r)
              begin
                c_pre_mbh_adr_r <= c_mbai_r;
              end
            else if (c_last_pos || (c_pre_mbh_adr_r==7'b111_1111))
              begin                
                c_pre_mbh_adr_r <= c_pre_mbh_adr_r;
              end
            else if (c_h_match)  
              begin
                c_pre_mbh_adr_r <= 7'b000_0001;
              end
            else
              begin
                c_pre_mbh_adr_r <= c_pre_mbh_adr_r + 1;
              end
          end
        else
          begin
            c_pre_mbh_adr_r <= c_pre_mbh_adr_r;
          end
      end

//--Final MB--
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)          
          begin
            c_mb_fin_r <= 1'b0;
          end
        else if (c_pcpl_r_s)      
          begin
            c_mb_fin_r <= 1'b0;
          end
        else
          begin
            c_mb_fin_r <= c_last_pos;
          end
      end

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)           
          begin
            c_mbv_adr_co_r <= 1'b0;
            c_mbv_adr_r    <= 7'b000_0000;
            c_mbh_adr_co_r <= 1'b0;
            c_mbh_adr_r    <= 7'b000_0000;
            c_mbv_adr_p1_r <= 7'b000_0001;
            c_mbh_adr_p1_r <= 7'b000_0000;
          end
        else if (c_pcpl_r_s)       
          begin
            c_mbv_adr_co_r <= 1'b0;
            c_mbv_adr_r    <= 7'b000_0000;
            c_mbh_adr_co_r <= 1'b0;
            c_mbh_adr_r    <= 7'b000_0000;
            c_mbv_adr_p1_r <= 7'b000_0001;
            c_mbh_adr_p1_r <= 7'b000_0000;
          end
        else
          begin
            {c_mbv_adr_co_r,c_mbv_adr_r} <= {1'b0,c_pre_mbv_adr_r} + 8'h7F;
            {c_mbh_adr_co_r,c_mbh_adr_r} <= {1'b0,c_pre_mbh_adr_r} + 8'h7F;
            c_mbv_adr_p1_r <= c_pre_mbv_adr_r;
            c_mbh_adr_p1_r <= c_pre_mbh_adr_r;
          end
      end

endmodule


