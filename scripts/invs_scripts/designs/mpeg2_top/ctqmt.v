// ----------------------------------------------
// File: ctqmt.v
// Module: ctqmt
// Function:
// ----------------------------------------------

module ctqmt (
    clkdec,           
    rstdec_x,         
    v_qmsyni_r_n,           //Intra Q-Matrix Sync(N)
    v_qmsynn_r_n,           //Non-Intra Q-Matrix Sync(N)
    v_ferror_r,             //Fatal Error by VLD
    v_qmseli_r,             //Intra Q-Matrix Select
    v_qmseln_r,             //Non-Intra Q-Matrix Select
    v_qmdata_r,             //Q-Matrix Data
    c_pcpl_r_s,             //Picture Processing Start Pulse
    w1_mtp00_q,               
    c_seqhdet_r,            //Sequence Header Detected
    c_qmsynn_r_n,           //Q-Matrix Sync(N) for IQ
    c_qmdata_r,             //Q-Matrix Data for IQ
    c_qmseln_r,             //Q-Matrix Select for IQ
    c_qmintra_r,            //Q-Matrix Intra for IQ
    v1_mtp00_bs,              
    v1_mtp00_we,              
    v1_mtp00_a,               
    v1_mtp00_d                
  );

    input         clkdec;     
    input         rstdec_x;   
    input         v_qmsyni_r_n; 
    input         v_qmsynn_r_n; 
    input         v_ferror_r;   
    input         v_qmseli_r;   
    input         v_qmseln_r;   
    input         c_pcpl_r_s;   
    input [7:0]   w1_mtp00_q  ;   
    input [7:0]   v_qmdata_r;   
    input         c_seqhdet_r;  
    output        c_qmsynn_r_n;    
    output [7:0]  c_qmdata_r;      
    output        c_qmseln_r;      
    output        c_qmintra_r;     
    output        v1_mtp00_bs;    
    output        v1_mtp00_we;    
    output [6:0]  v1_mtp00_a;     
    output [7:0]  v1_mtp00_d;     

    reg        v1_mtp00_bs;
    reg        v1_mtp00_we;
    reg [6:0]  v1_mtp00_a;
    reg [7:0]  v1_mtp00_d;

    reg       c_seq_flg_r;           //Sequence Header Flag
    reg [5:0] c_rxi_adscnt_r;        //RX Intra Address Counter
    reg [5:0] c_rxn_adscnt_r;        //RX NonIntra Address Counter

    reg       c_intra_rxflg_r;       //Intra Flag
    reg       c_nonintra_rxflg_r;    //NonIntra Flag

    reg [6:0] c_tx_mode_r;           //TX Mode
    reg       c_txcnt_ld_r_s;        //TX Counter Load("c_pcpl_r_s" Shift)
    reg [6:0] c_txadscnt_r;          //Intra Address Counter
    reg       c_tx_end_r;            //TX End
    reg [7:0] c_intra_txofst;        //TX Offset

    reg       c_men_re_r;            //Memory Read Enable
    reg       c_qmsynn_r_n;          //Q-Matrix Sync(N) for IQ
    reg [7:0] c_qmdata_r;            //Q-Matrix Data for IQ
    reg       c_qmseln_r;            //Q-Matrix Select for IQ
    reg       c_qmintra_r;           //Q-Matrix Intra for IQ

    reg       c_tx_sync_r;           //Shift"c_txcnt_ld"
    reg [7:0] c_mtp00_q1_r;          //Shift"w1_mtp00_q"
    reg [7:0] c_mtp00_q2_r;          //Shift"c_mtp00_q1_r"
    reg [7:0] c_intra_txofst_1_r;    //Shift"c_intra_txofst"
    reg [7:0] c_intra_txofst_2_r;    //Shift"c_intra_txofst_1_r"
    reg       c_tx_end_s1_r;         //Shift"c_tx_end_r"
    reg       c_tx_end_1_r_s;        //Shift"c_tx_end"
    reg       c_tx_end_2_r_s;        //Shift"c_tx_end_1_r"
    reg       c_tx_end_3_r_s;        //Shift"c_tx_end_2_r"
    reg       c_tx_end_4_r_s;        //Shift"c_tx_end_3_r"

    wire       c_tx_end;             //TX End
    wire       c_txcnt_ld;           //TX Counter Load
    wire [2:0] c_tx_flg;

    assign c_tx_end = c_tx_end_r & ~c_tx_end_s1_r ^ c_tx_sync_r;
    assign c_tx_flg = {c_seq_flg_r,c_intra_rxflg_r,c_nonintra_rxflg_r};

//-- Sequence Flag --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_seq_flg_r <= 1'b0;
          end
        else if (c_seqhdet_r) 
          begin
            c_seq_flg_r <= 1'b1;
          end
        else if (c_tx_end_4_r_s)
          begin
            c_seq_flg_r <= 1'b0;
          end
        else
          begin
            c_seq_flg_r <= c_seq_flg_r;
          end
      end

//-- Address Counter (RX:Intra) --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)      
          begin
            c_rxi_adscnt_r <= 6'b00_0000;
          end
        else if (c_tx_end_4_r_s || !v_qmsyni_r_n)
          begin                           
            c_rxi_adscnt_r <= 6'b00_0000;
          end
        else if (c_rxi_adscnt_r==6'b11_1111)
          begin
            c_rxi_adscnt_r <= c_rxi_adscnt_r;
          end
        else if (v_qmseli_r)         
          begin
            c_rxi_adscnt_r <= c_rxi_adscnt_r + 1;
          end
        else
          begin
            c_rxi_adscnt_r <= c_rxi_adscnt_r;
          end
      end

//-- Intra Flag --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_intra_rxflg_r <= 1'b0;
          end
        else if (!v_qmsyni_r_n)
          begin
            c_intra_rxflg_r <= 1'b1;
          end
        else if (c_tx_end_4_r_s || c_seqhdet_r
                 || (v_qmseli_r && v_ferror_r))
          begin
            c_intra_rxflg_r <= 1'b0;
          end
        else
          begin
            c_intra_rxflg_r <= c_intra_rxflg_r;
          end
      end

//-- Address Counter (RX:NonIntra) --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)    
          begin
            c_rxn_adscnt_r <= 6'b00_0000;
          end
        else if (c_tx_end_4_r_s || !v_qmsynn_r_n)
          begin               
            c_rxn_adscnt_r <= 6'b00_0000;
          end
        else if (c_rxn_adscnt_r==6'b11_1111)
          begin
            c_rxn_adscnt_r <= c_rxn_adscnt_r;
          end
        else if (v_qmseln_r)
          begin
            c_rxn_adscnt_r <= c_rxn_adscnt_r + 1;
          end
        else
          begin
            c_rxn_adscnt_r <= c_rxn_adscnt_r;
          end
      end

//-- NonIntra Flag --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)
          begin
            c_nonintra_rxflg_r <= 1'b0;
          end
        else if (!v_qmsynn_r_n)
          begin
            c_nonintra_rxflg_r <= 1'b1;
          end
        else if (c_tx_end_4_r_s || c_seqhdet_r
                 || (v_qmseln_r && v_ferror_r))
          begin
            c_nonintra_rxflg_r <= 1'b0;
          end
        else
          begin
            c_nonintra_rxflg_r <= c_nonintra_rxflg_r;
          end
      end

//-- TX Mode --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_tx_mode_r <= 7'b000_0000;
          end
        else if (c_tx_end_4_r_s)
          begin
            c_tx_mode_r <= 7'b000_0000;
          end
        else if (c_pcpl_r_s)
          begin
             case (c_tx_flg)
               3'b111  : c_tx_mode_r <= 7'b000_0001; //I:Real ,NonI:Real
               3'b110  : c_tx_mode_r <= 7'b000_0010; //I:Real ,NonI:Dummy
               3'b101  : c_tx_mode_r <= 7'b000_0100; //I:Dummy,NonI:Real
               3'b100  : c_tx_mode_r <= 7'b000_1000; //I:Dummy,NonI:Dummy
               3'b011  : c_tx_mode_r <= 7'b001_0000; //I:Real ,NonI:Real
               3'b010  : c_tx_mode_r <= 7'b010_0000; //I:Real ,NonI:---
               3'b001  : c_tx_mode_r <= 7'b100_0000; //I:---  ,NonI:Real
               default : c_tx_mode_r <= 7'b000_0000; //I:---  ,NonI:---
             endcase
          end
        else
          begin
            c_tx_mode_r <= c_tx_mode_r;
          end
      end

//-- TX Counter Load --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            c_txcnt_ld_r_s <= 1'b0;
          end
        else
          begin
            c_txcnt_ld_r_s <= c_pcpl_r_s;
          end
      end
   assign c_txcnt_ld = c_txcnt_ld_r_s & (|c_tx_mode_r);

//-- Address Counter Enable (TX) --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)    
          begin
            c_men_re_r <= 1'b0;
          end
        else if ((c_tx_mode_r == 7'b010_0000)
            && (c_txadscnt_r==7'b011_1111))
          begin
            c_men_re_r <= 1'b0;
          end
        else if ((|c_tx_mode_r)  
                 && (c_txadscnt_r==7'b111_1111))
          begin
            c_men_re_r <= 1'b0;
          end
        else if (|c_tx_mode_r)
          begin
            c_men_re_r <= 1'b1;
          end
        else
          begin
            c_men_re_r <= c_men_re_r;
          end
      end

//-- Address Counter (TX) --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)                
          begin
            c_txadscnt_r <= 7'b000_0000;
          end
        else if (c_tx_end_4_r_s)        
          begin
            c_txadscnt_r <= 7'b000_0000;
          end
        else if (c_txcnt_ld)            
          begin
            if (c_tx_mode_r == 7'b100_0000)
              begin
                c_txadscnt_r <= 7'b100_0000;
              end
            else
              begin
                c_txadscnt_r <= 7'b000_0000;
              end
          end
        else if (|c_tx_mode_r)
          begin
            if ((c_tx_mode_r == 7'b010_0000)
                && (c_txadscnt_r==7'b011_1111)) 
              begin
                c_txadscnt_r <= c_txadscnt_r;
              end
            else if ((|c_tx_mode_r) 
                     && (c_txadscnt_r==7'b111_1111))
              begin
                c_txadscnt_r <= c_txadscnt_r;
              end
            else 
              begin
                c_txadscnt_r <= c_txadscnt_r + 1;
              end
          end
        else
          begin
            c_txadscnt_r <= c_txadscnt_r;
          end
      end

//-- Transmit End         --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)     
          begin
            c_tx_end_r <= 1'b0;
          end
        else if ((c_tx_mode_r == 7'b010_0000)
                && (c_txadscnt_r==7'b011_1111))
          begin
            c_tx_end_r <= 1'b1;
          end
        else if ((|c_tx_mode_r)
                && (c_txadscnt_r==7'b111_1111))
          begin
            c_tx_end_r <= 1'b1;
          end
        else
          begin
            c_tx_end_r <= 1'b0;
          end
      end

//-- Write/Read --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)     
          begin
            v1_mtp00_bs <= 1'b0;
            v1_mtp00_we <= 1'b0;
            v1_mtp00_a  <= 7'h00;
            v1_mtp00_d  <= 8'h00;
          end
        else if (v_qmseli_r)   
          begin
            v1_mtp00_bs <= 1'b1;
            v1_mtp00_we <= 1'b1;
            v1_mtp00_a  <= {1'b0,c_rxi_adscnt_r};
            v1_mtp00_d  <= v_qmdata_r;
          end
        else if (v_qmseln_r)   
          begin
            v1_mtp00_bs <= 1'b1;
            v1_mtp00_we <= 1'b1;
            v1_mtp00_a  <= {1'b1,c_rxn_adscnt_r};
            v1_mtp00_d  <= v_qmdata_r;
          end
        else if (c_men_re_r)   
          begin
            v1_mtp00_bs <= 1'b1;
            v1_mtp00_we <= 1'b0;
            v1_mtp00_a  <= c_txadscnt_r;
            v1_mtp00_d  <= 8'h00;
          end
        else
          begin
            v1_mtp00_bs <= 1'b0;
            v1_mtp00_we <= 1'b0;
            v1_mtp00_a  <= 7'h00;
            v1_mtp00_d  <= 8'h00;
          end
      end

//-- TX Offset --
    always @ (c_txadscnt_r)
      begin
        case (c_txadscnt_r)
          7'd0    : c_intra_txofst = 8'd8;
          7'd1    : c_intra_txofst = 8'd16;
          7'd2    : c_intra_txofst = 8'd16;
          7'd3    : c_intra_txofst = 8'd19;

          7'd4    : c_intra_txofst = 8'd16;
          7'd5    : c_intra_txofst = 8'd19;
          7'd6    : c_intra_txofst = 8'd22;
          7'd7    : c_intra_txofst = 8'd22;

          7'd8    : c_intra_txofst = 8'd22;
          7'd9    : c_intra_txofst = 8'd22;
          7'd10   : c_intra_txofst = 8'd22;
          7'd11   : c_intra_txofst = 8'd22;

          7'd12   : c_intra_txofst = 8'd26;
          7'd13   : c_intra_txofst = 8'd24;
          7'd14   : c_intra_txofst = 8'd26;
          7'd15   : c_intra_txofst = 8'd27;

          7'd16   : c_intra_txofst = 8'd27;
          7'd17   : c_intra_txofst = 8'd27;
          7'd18   : c_intra_txofst = 8'd26;
          7'd19   : c_intra_txofst = 8'd26;

          7'd20   : c_intra_txofst = 8'd26;
          7'd21   : c_intra_txofst = 8'd26;
          7'd22   : c_intra_txofst = 8'd27;
          7'd23   : c_intra_txofst = 8'd27;

          7'd24   : c_intra_txofst = 8'd27;
          7'd25   : c_intra_txofst = 8'd29;
          7'd26   : c_intra_txofst = 8'd29;
          7'd27   : c_intra_txofst = 8'd29;

          7'd28   : c_intra_txofst = 8'd34;
          7'd29   : c_intra_txofst = 8'd34;
          7'd30   : c_intra_txofst = 8'd34;
          7'd31   : c_intra_txofst = 8'd29;

          7'd32   : c_intra_txofst = 8'd29;
          7'd33   : c_intra_txofst = 8'd29;
          7'd34   : c_intra_txofst = 8'd27;
          7'd35   : c_intra_txofst = 8'd27;

          7'd36   : c_intra_txofst = 8'd29;
          7'd37   : c_intra_txofst = 8'd29;
          7'd38   : c_intra_txofst = 8'd32;
          7'd39   : c_intra_txofst = 8'd32;

          7'd40   : c_intra_txofst = 8'd34;
          7'd41   : c_intra_txofst = 8'd34;
          7'd42   : c_intra_txofst = 8'd37;
          7'd43   : c_intra_txofst = 8'd38;

          7'd44   : c_intra_txofst = 8'd37;
          7'd45   : c_intra_txofst = 8'd35;
          7'd46   : c_intra_txofst = 8'd35;
          7'd47   : c_intra_txofst = 8'd34;

          7'd48   : c_intra_txofst = 8'd35;
          7'd49   : c_intra_txofst = 8'd38;
          7'd50   : c_intra_txofst = 8'd38;
          7'd51   : c_intra_txofst = 8'd40;

          7'd52   : c_intra_txofst = 8'd40;
          7'd53   : c_intra_txofst = 8'd40;
          7'd54   : c_intra_txofst = 8'd48;
          7'd55   : c_intra_txofst = 8'd48;

          7'd56   : c_intra_txofst = 8'd46;
          7'd57   : c_intra_txofst = 8'd46;
          7'd58   : c_intra_txofst = 8'd56;
          7'd59   : c_intra_txofst = 8'd56;

          7'd60   : c_intra_txofst = 8'd58;
          7'd61   : c_intra_txofst = 8'd69;
          7'd62   : c_intra_txofst = 8'd69;
          7'd63   : c_intra_txofst = 8'd83;
          default : c_intra_txofst = 8'd0;
        endcase
      end

//-- Shift --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            c_tx_sync_r    <= 1'b0;
            c_mtp00_q1_r   <= 8'h00;
            c_mtp00_q2_r   <= 8'h00;
            c_intra_txofst_1_r <=8'h00;
            c_intra_txofst_2_r <=8'h00;
            c_tx_end_s1_r  <= 1'b0;
            c_tx_end_1_r_s <= 1'b0;
            c_tx_end_2_r_s <= 1'b0;
            c_tx_end_3_r_s <= 1'b0;
            c_tx_end_4_r_s <= 1'b0;
          end
        else
          begin
            c_tx_sync_r    <= c_txcnt_ld;
            c_mtp00_q1_r   <= w1_mtp00_q;
            c_mtp00_q2_r   <= c_mtp00_q1_r;
            c_intra_txofst_1_r <= c_intra_txofst;
            c_intra_txofst_2_r <= c_intra_txofst_1_r;
            c_tx_end_s1_r  <= c_tx_end_r;
            c_tx_end_1_r_s <= c_tx_end;
            c_tx_end_2_r_s <= c_tx_end_1_r_s;
            c_tx_end_3_r_s <= c_tx_end_2_r_s;
            c_tx_end_4_r_s <= c_tx_end_3_r_s;
         end
      end

//-- Q-Matrix Sync(N)Data/Select for IQ --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_qmintra_r  <= 1'b0;
            c_qmsynn_r_n <= 1'b1;
            c_qmdata_r   <= 8'h00;
            c_qmseln_r   <= 1'b0;
         end
        else if (c_tx_end_4_r_s)
          begin
            c_qmintra_r  <= 1'b0;
            c_qmsynn_r_n <= 1'b1;
            c_qmdata_r   <= 8'h00;
            c_qmseln_r   <= 1'b0;
          end
        else if (c_tx_mode_r==7'b000_0001) 
          begin
            if (c_txadscnt_r==7'b000_0001) 
              begin
                c_qmintra_r  <= 1'b1;
                c_qmsynn_r_n <= 1'b0;
                c_qmdata_r   <= 8'h00;
                c_qmseln_r   <= 1'b0;
              end
            else if ((c_txadscnt_r>7'b000_0001)
                     && (c_txadscnt_r<7'b100_0010))
              begin
                c_qmintra_r  <= 1'b1;
                c_qmsynn_r_n <= 1'b1;
                c_qmdata_r   <= w1_mtp00_q;
                c_qmseln_r   <= 1'b1;
              end
            else if (c_txadscnt_r==7'b100_0011)
              begin
                c_qmintra_r  <= 1'b0;
                c_qmsynn_r_n <= 1'b0;
                c_qmdata_r   <= 8'h00;
                c_qmseln_r   <= 1'b0;
              end
            else if (c_txadscnt_r>7'b100_0011) 
              begin
                c_qmintra_r  <= 1'b0;
                c_qmsynn_r_n <= 1'b1;
                c_qmdata_r   <= c_mtp00_q2_r;
                c_qmseln_r   <= 1'b1;
              end
            else                                 
              begin
                c_qmintra_r  <= 1'b0;
                c_qmsynn_r_n <= 1'b1;
                c_qmdata_r   <= 8'h00;
                c_qmseln_r   <= 1'b0;
              end
          end
        else if (c_tx_mode_r==7'b000_0010) 
          begin
            if (c_txadscnt_r==7'b000_0001) 
              begin
                c_qmintra_r  <= 1'b1;
                c_qmsynn_r_n <= 1'b0;
                c_qmdata_r   <= 8'h00;
                c_qmseln_r   <= 1'b0;
              end
            else if ((c_txadscnt_r>7'b000_0001)
                     && (c_txadscnt_r<7'b100_0010))
              begin
                c_qmintra_r  <= 1'b1;
                c_qmsynn_r_n <= 1'b1;
                c_qmdata_r   <= w1_mtp00_q;
                c_qmseln_r   <= 1'b1;
              end
            else if (c_txadscnt_r==7'b100_0011)
              begin
                c_qmintra_r  <= 1'b0;
                c_qmsynn_r_n <= 1'b0;
                c_qmdata_r   <= 8'h00;
                c_qmseln_r   <= 1'b0;
              end
            else if (c_txadscnt_r>7'b100_0011)
              begin
                c_qmintra_r  <= 1'b0;
                c_qmsynn_r_n <= 1'b1;
                c_qmdata_r   <= 8'd16;
                c_qmseln_r   <= 1'b1;
              end
            else                                
              begin
                c_qmintra_r  <= 1'b0;
                c_qmsynn_r_n <= 1'b1;
                c_qmdata_r   <= 8'h00;
                c_qmseln_r   <= 1'b0;
              end
          end
        else if (c_tx_mode_r==7'b000_0100)    
          begin
            if (c_txadscnt_r==7'b000_0001)    
              begin
                c_qmintra_r  <= 1'b1;
                c_qmsynn_r_n <= 1'b0;
                c_qmdata_r   <= 8'h00;
                c_qmseln_r   <= 1'b0;
              end
            else if ((c_txadscnt_r>7'b000_0001) 
                     && (c_txadscnt_r<7'b100_0010))
              begin
                c_qmintra_r  <= 1'b1;
                c_qmsynn_r_n <= 1'b1;
                c_qmdata_r   <= c_intra_txofst_2_r;
                c_qmseln_r   <= 1'b1;
              end
            else if (c_txadscnt_r==7'b100_0011) 
              begin
                c_qmintra_r  <= 1'b0;
                c_qmsynn_r_n <= 1'b0;
                c_qmdata_r   <= 8'h00;
                c_qmseln_r   <= 1'b0;
              end
            else if (c_txadscnt_r>7'b100_0011) 
              begin
                c_qmintra_r  <= 1'b0;
                c_qmsynn_r_n <= 1'b1;
                c_qmdata_r   <= c_mtp00_q2_r;
                c_qmseln_r   <= 1'b1;
              end
            else                                 
              begin
                c_qmintra_r  <= 1'b0;
                c_qmsynn_r_n <= 1'b1;
                c_qmdata_r   <= 8'h00;
                c_qmseln_r   <= 1'b0;
              end
          end
        else if (c_tx_mode_r==7'b000_1000)     
          begin
            if (c_txadscnt_r==7'b000_0001)     
              begin
                c_qmintra_r  <= 1'b1;
                c_qmsynn_r_n <= 1'b0;
                c_qmdata_r   <= 8'h00;
                c_qmseln_r   <= 1'b0;
              end
            else if ((c_txadscnt_r>7'b000_0001)
                     && (c_txadscnt_r<7'b100_0010))
              begin
                c_qmintra_r  <= 1'b1;
                c_qmsynn_r_n <= 1'b1;
                c_qmdata_r   <= c_intra_txofst_2_r;
                c_qmseln_r   <= 1'b1;
              end
            else if (c_txadscnt_r==7'b100_0011)
              begin
                c_qmintra_r  <= 1'b0;
                c_qmsynn_r_n <= 1'b0;
                c_qmdata_r   <= 8'h00;
                c_qmseln_r   <= 1'b0;
              end
            else if (c_txadscnt_r>7'b100_0011) 
              begin
                c_qmintra_r  <= 1'b0;
                c_qmsynn_r_n <= 1'b1;
                c_qmdata_r   <= 8'd16;
                c_qmseln_r   <= 1'b1;
              end
            else                                 
              begin
                c_qmintra_r  <= 1'b0;
                c_qmsynn_r_n <= 1'b1;
                c_qmdata_r   <= 8'h00;
                c_qmseln_r   <= 1'b0;
              end
          end
        else if (c_tx_mode_r==7'b001_0000)     
          begin
            if (c_txadscnt_r==7'b000_0001)     
              begin
                c_qmintra_r  <= 1'b1;
                c_qmsynn_r_n <= 1'b0;
                c_qmdata_r   <= 8'h00;
                c_qmseln_r   <= 1'b0;
              end
            else if ((c_txadscnt_r>7'b000_0001)
                     && (c_txadscnt_r<7'b100_0010))
              begin
                c_qmintra_r  <= 1'b1;
                c_qmsynn_r_n <= 1'b1;
                c_qmdata_r   <= w1_mtp00_q;
                c_qmseln_r   <= 1'b1;
              end
            else if (c_txadscnt_r==7'b100_0011)
              begin
                c_qmintra_r  <= 1'b0;
                c_qmsynn_r_n <= 1'b0;
                c_qmdata_r   <= 8'h00;
                c_qmseln_r   <= 1'b0;
              end
            else if (c_txadscnt_r>7'b100_0011) 
              begin
                c_qmintra_r  <= 1'b0;
                c_qmsynn_r_n <= 1'b1;
                c_qmdata_r   <= c_mtp00_q2_r;
                c_qmseln_r   <= 1'b1;
              end
            else                                 
              begin
                c_qmintra_r  <= 1'b0;
                c_qmsynn_r_n <= 1'b1;
                c_qmdata_r   <= 8'h00;
                c_qmseln_r   <= 1'b0;
              end
          end
        else if (c_tx_mode_r==7'b010_0000)  
          begin
            if ((c_tx_end_2_r_s)            
                || (c_tx_end_3_r_s))
              begin
                c_qmintra_r  <= 1'b0;
                c_qmsynn_r_n <= 1'b1;
                c_qmdata_r   <= 8'h00;
                c_qmseln_r   <= 1'b0;
              end
            else if (c_txadscnt_r==7'b000_0001)
              begin
                c_qmintra_r  <= 1'b1;
                c_qmsynn_r_n <= 1'b0;
                c_qmdata_r   <= 8'h00;
                c_qmseln_r   <= 1'b0;
              end
            else if (c_txadscnt_r>7'b000_0001) 
              begin
                c_qmintra_r  <= 1'b1;
                c_qmsynn_r_n <= 1'b1;
                c_qmdata_r   <= w1_mtp00_q;
                c_qmseln_r   <= 1'b1;
              end
            else                                 
              begin
                c_qmintra_r  <= 1'b0;
                c_qmsynn_r_n <= 1'b1;
                c_qmdata_r   <= 8'h00;
                c_qmseln_r   <= 1'b0;
              end
          end
        else if (c_tx_mode_r==7'b100_0000)     
          begin
            if ((c_tx_end_2_r_s)               
                || (c_tx_end_3_r_s))
              begin
                c_qmintra_r  <= 1'b0;
                c_qmsynn_r_n <= 1'b1;
                c_qmdata_r   <= 8'h00;
                c_qmseln_r   <= 1'b0;
              end
            else if (c_txadscnt_r==7'b100_0011)
              begin
                c_qmintra_r  <= 1'b0;
                c_qmsynn_r_n <= 1'b0;
                c_qmdata_r   <= 8'h00;
                c_qmseln_r   <= 1'b0;
              end
            else if (c_txadscnt_r>7'b100_0011) 
              begin
                c_qmintra_r  <= 1'b0;
                c_qmsynn_r_n <= 1'b1;
                c_qmdata_r   <= c_mtp00_q2_r;
                c_qmseln_r   <= 1'b1;
              end
            else                                 
              begin
                c_qmintra_r  <= 1'b0;
                c_qmsynn_r_n <= 1'b1;
                c_qmdata_r   <= 8'h00;
                c_qmseln_r   <= 1'b0;
              end
          end
        else
          begin
            c_qmintra_r  <= 1'b0;
            c_qmsynn_r_n <= 1'b1;
            c_qmdata_r   <= 8'h00;
            c_qmseln_r   <= 1'b0;
          end
      end

endmodule

