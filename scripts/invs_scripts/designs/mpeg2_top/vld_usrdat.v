// ----------------------------------------------
// File: vld_usrdat.v
// Module: vvld_usrdat
// Function: generate user_data
// ----------------------------------------------

module vld_usrdat(
    clkdec, 
    rstdec_x, 
    g_swrst_r_n, 
    y1_bs_wait_n,
    v_interrpt_n, 
    KICK0, 
    KICK1, 
    KICK2, 
    STREAM, 
    v_vldmode_r,
    ENDDEC, 
    SHIFT, 
    PARAA, 
    PARAD, 
    v_atscdet_r_s
);

input         clkdec;         // VLD clock
input         rstdec_x;       // Async reset
input         g_swrst_r_n;    // Sync reset
input         y1_bs_wait_n;   // Wait signal
input         v_interrpt_n;   // Breadk signal
input         KICK0;          // start decode for user_data of sequence 
input         KICK1;          // start decode for user_data of GOP
input         KICK2;          // start decode for user_data of picture
input  [31:0] STREAM;         // bit stream(32bit)
input  [1:0]  v_vldmode_r;     // [0]=1:AT [0]=0:normal always [1]=0 
output        ENDDEC;          // end-decode
output [5:0]  SHIFT;           // shift data
output [7:0]  PARAA;           // address
output [7:0]  PARAD;           // data
output        v_atscdet_r_s;   // find AT identifier

reg ENDDEC;                 // end-decode
reg next_ENDDEC;            // next end-decode
reg [5:0] SHIFT;            // shift data
reg [7:0] PARAA;            // parameter address
reg [7:0] PARAD;            // parameter data
reg v_atscdet_r_s;          // find AT
reg next_v_atscdet_r_s;     // next find AT
reg [1:0] user_number;      // KICK start
reg [1:0] next_user_number; // next KICK start
reg AT;                     // AT
reg next_AT;                // 1:AT decode 0:normal decode
reg [2:0] state;            // now state
reg [2:0] next_state;       // next state


parameter IDLE = 3'b000,
          user_start_code1 = 3'b001,
          user_start_code2 = 3'b010,
          user_start_code3 = 3'b011,
          user_data        = 3'b100;

parameter no_break = 1'b1;


always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        state <= IDLE;
        user_number <= 2'b00;
        ENDDEC <= 1'b0;
        AT <= 1'b0;
        v_atscdet_r_s <= 1'b0;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            state <= IDLE;  
            user_number <= 2'b00;
            ENDDEC <= 1'b0;
            AT <= 1'b0;
            v_atscdet_r_s <= 1'b0;
          end
        else if(y1_bs_wait_n == 1'b1) 
          begin
            state <= next_state;
            user_number <= next_user_number;
            ENDDEC <= next_ENDDEC;
            AT <= next_AT;
            v_atscdet_r_s <= next_v_atscdet_r_s;
          end
        else
          begin
            state <= state;
            user_number <= user_number;
            ENDDEC <= ENDDEC;
            AT <= AT;
            v_atscdet_r_s <= v_atscdet_r_s;
          end
      end
  end

always @(state or v_interrpt_n or KICK0 or KICK1 or KICK2 or STREAM)
  begin
    if(v_interrpt_n == no_break) 
      begin
        case(state)
          IDLE : 
            begin   
              if(KICK0 == 1'b1 || KICK1 == 1'b1 || KICK2 ==1'b1) 
                begin
                  next_state = user_start_code1;
                end
              else
                begin
                  next_state = IDLE;
                end
            end

          user_start_code1 :  
            begin     
              next_state = user_start_code2;
            end
 
          user_start_code2 : 
            begin      
              next_state = user_start_code3;
            end 

          user_start_code3 :  
            begin          
              next_state = user_data;        
            end

          user_data : 
            begin
              if(STREAM[31:8] == 24'h000001) 
                begin
                  next_state = IDLE;
                end
              else
                begin
                  next_state = state;
                end
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

always @(state or v_interrpt_n or STREAM)
  begin
    if(v_interrpt_n == no_break) 
      begin
        case(state)
          user_data : 
            begin
              if(STREAM[31:8] == 24'h000001) 
                begin
                  SHIFT = 6'h00;
                end
              else 
                begin
                  SHIFT = 6'h08;
                end
            end

          default :
            begin
              SHIFT = 6'h00;
            end
        endcase
      end
    else
      begin
        SHIFT = 6'h00;
      end
  end

always @(state or v_interrpt_n or KICK0 or KICK1 or KICK2 or STREAM or
          user_number or v_vldmode_r or AT ) 
  begin
    if(v_interrpt_n == no_break) 
      begin
        case(state)
          IDLE :
            begin
              if(KICK0 == 1'b1) 
                begin
                  PARAA = 8'h80; 
                end
              else if(KICK1 == 1'b1) 
                begin
                  PARAA = 8'h82;  
                end
              else if(KICK2 == 1'b1) 
                begin
                  if(STREAM == 32'h47413934 && v_vldmode_r[0] == 1'b1)
                    begin
                      PARAA = 8'h8a;
                    end
                  else
                    begin
                      PARAA = 8'h88;
                    end
                end
              else
                begin
                  PARAA = 8'hFF;
                end
            end

          user_start_code1 :
            begin
              if(AT == 1'b1) 
                begin
                  PARAA = 8'h8a;
              end
              else if(user_number == 2'b01) 
                begin
                  PARAA = 8'h80;
                end
              else if(user_number == 2'b10) 
                begin
                  PARAA = 8'h82;
                end
              else if(user_number == 2'b11) 
                begin
                  PARAA = 8'h88;
                end
              else
                begin
                  PARAA = 8'hFF;
                end
            end

          user_start_code2 :
            begin

              if(AT == 1'b1) 
                begin
                  PARAA = 8'h8a;
                end
              else if(user_number == 2'b01)
                begin
                  PARAA = 8'h80;
                end
              else if(user_number == 2'b10) 
                begin
                  PARAA = 8'h82;
                end
              else if(user_number == 2'b11) 
                begin
                  PARAA = 8'h88;
                end
              else
                begin
                  PARAA = 8'hFF;
                end
            end

          user_start_code3 :
            begin
              if(AT == 1'b1) 
                begin
                  PARAA = 8'h8a;
                end
              else if(user_number == 2'b01) 
                begin
                  PARAA = 8'h80;
                end
             else if(user_number == 2'b10)
                begin
                  PARAA = 8'h82;
                end
              else if(user_number == 2'b11) 
                begin
                  PARAA = 8'h88;
                end
              else
                begin
                  PARAA = 8'hFF;
                end
            end

          user_data :
            begin
              if(STREAM[31:8] == 24'h000001) 
                begin
                  PARAA = 8'hFF;
                end
              else
                begin
                  if(AT == 1'b1) 
                    begin
                      PARAA = 8'h8a;
                    end
                  else if(user_number == 2'b01) 
                    begin
                      PARAA = 8'h80;
                    end
                  else if(user_number == 2'b10) 
                    begin
                      PARAA = 8'h82;
                    end
                  else if(user_number == 2'b11) 
                    begin
                      PARAA = 8'h88;
                    end
                  else
                    begin
                      PARAA = 8'hFF;
                    end
                end 
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
             
          
always @(state or v_interrpt_n or STREAM)
  begin
    if(v_interrpt_n == no_break) 
      begin
        case(state)
          user_start_code2 :
            begin
              PARAD = 8'h01;
            end

          user_start_code3 :
            begin
              PARAD = 8'hB2;
            end

          user_data :
            begin
              if(STREAM[31:8] == 24'h000001) 
                begin
                  PARAD = 8'h00;
                end
              else
                begin
                  PARAD = STREAM[31:24];
                end
            end

          default :
            begin
              PARAD = 8'h00;
            end
        endcase
      end
    else
      begin
        PARAD = 8'h00;
      end
  end

always @(state or v_interrpt_n or KICK0 or KICK1 or KICK2 or STREAM
          or user_number)
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          IDLE :
            begin
              if(KICK0 == 1'b1)
                begin
                  next_user_number = 2'b01;
                end
              else if(KICK1 == 1'b1) 
                begin
                  next_user_number = 2'b10;
                end
              else if(KICK2 == 1'b1) 
                begin
                  next_user_number = 2'b11;
                end
              else
                begin
                  next_user_number = 2'b00;
                end
            end

          user_data :
            begin
              if(STREAM[31:8] == 24'h000001) 
                begin
                  next_user_number = 2'b00;
                end
              else
                begin
                  next_user_number = user_number;
                end
            end
          default :
            begin
              next_user_number = user_number;
            end
        endcase
      end
    else
      begin
        next_user_number = 2'b00;
      end
  end

always @(state or v_interrpt_n or KICK2 or STREAM or AT or v_vldmode_r) 
  begin
    if(v_interrpt_n == no_break) 
      begin
        case(state)
          IDLE :
            begin
              if(KICK2 == 1'b1 && STREAM == 32'h47413934 
                  && v_vldmode_r[1] == 1'b1)        
                begin
                  next_AT = 1'b1;
                end
              else 
                begin
                  next_AT = 1'b0;
                end
            end

          user_data :
            begin
              if(STREAM[31:8] == 24'h000001) 
                begin
                  next_AT = 1'b0;
                end
              else
                begin
                  next_AT = AT;
                end
            end

          default :  
            begin
              next_AT = AT;
            end 
        endcase
      end
    else
      begin
        next_AT = 1'b0;
      end
  end

always @(state or v_interrpt_n or STREAM)
  begin
    if(v_interrpt_n == no_break)
      begin
        case(state)
          user_data :
            begin
              if(STREAM[31:8] == 24'h000001) 
                begin
                  next_ENDDEC = 1'b1;
                end
              else
                begin
                  next_ENDDEC = 1'b0; 
                end
            end

          default :
            begin
              next_ENDDEC = 1'b0;
            end
        endcase
      end
    else
      begin
        next_ENDDEC = 1'b0;
      end
  end

always @(state or v_interrpt_n or KICK2 or STREAM or v_vldmode_r)
  begin
    if(v_interrpt_n == no_break) 
      begin
        case(state)
          IDLE :
            begin
              if(KICK2 == 1'b1 && STREAM == 32'h47413934 && v_vldmode_r[0] == 1'b1) 
                begin
                  next_v_atscdet_r_s = 1'b1;
                end
              else
                begin
                  next_v_atscdet_r_s = 1'b0;
                end
            end

          default :
            begin
              next_v_atscdet_r_s = 1'b0;
            end
        endcase
      end
    else
      begin
        next_v_atscdet_r_s = 1'b0;
      end
  end

endmodule
            

