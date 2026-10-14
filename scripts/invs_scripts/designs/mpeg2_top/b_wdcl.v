// ----------------------------------------------
// File: b_wdcl.v
// Module: b_wdcl
// Function:BusI/F(W) write data control
// ----------------------------------------------

module b_wdcl(
                clkdec,         
                rstdec_x,       
                b_write_enable_r,
                b_write_data,    
                vwh_wrq_tranacc, 
                vwh_data_wait,   
                vh_2_ph_data,    
                vwh_wdc_dataready
                );

    input         clkdec;         
    input         rstdec_x;       
    input         b_write_enable_r;  // write data enable
    input [63:0]  b_write_data;      // write data
    input         vwh_wrq_tranacc;   // SHwy request acceptance
    output        vwh_data_wait;     // write data wait
    output [31:0] vh_2_ph_data;      // SHwy data
    output        vwh_wdc_dataready; // write data ready


    wire          clkdec;         
    wire          rstdec_x;       
    wire          vwh_data_wait;     // write data wait
    reg  [31:0]   vh_2_ph_data;      // SHwy data
    wire          vwh_wdc_dataready; // write data ready
    wire          vwh_wrq_tranacc;   // SHwy request acceptance

    reg [31:0]    vwh_wdc_wrtdata0_r;
    reg [31:0]    vwh_wdc_wrtdata1_r;
    reg [31:0]    vwh_wdc_wrtdata2_r;
    reg [31:0]    vwh_wdc_wrtdata3_r;
    wire          vwh_wdc_validdata;
    reg [1:0]     vwh_wdc_selaccdat_r;
    reg [1:0]     vwh_wdc_selissdat_r;
    reg           vwh_wdc_flgwrtdat0_r;
    reg           vwh_wdc_flgwrtdat1_r;
    reg           vwh_wdc_flgwrtdat2_r;
    reg           vwh_wdc_flgwrtdat3_r;

    always@(vwh_wdc_selissdat_r or vwh_wdc_wrtdata0_r or vwh_wdc_wrtdata1_r or vwh_wdc_wrtdata2_r or vwh_wdc_wrtdata3_r)begin
        case (vwh_wdc_selissdat_r)
            2'b00 : vh_2_ph_data <= vwh_wdc_wrtdata0_r;
            2'b01 : vh_2_ph_data <= vwh_wdc_wrtdata1_r;
            2'b10 : vh_2_ph_data <= vwh_wdc_wrtdata2_r;
            2'b11 : vh_2_ph_data <= vwh_wdc_wrtdata3_r;
        endcase
    end
  
    assign vwh_wdc_validdata = b_write_enable_r & ~vwh_data_wait;
    assign vwh_data_wait = (b_write_enable_r & 
                            vwh_wdc_flgwrtdat0_r & vwh_wdc_flgwrtdat1_r &
                            vwh_wdc_flgwrtdat2_r & vwh_wdc_flgwrtdat3_r);
    assign vwh_wdc_dataready = (vwh_wdc_flgwrtdat0_r | vwh_wdc_flgwrtdat1_r |
                                vwh_wdc_flgwrtdat2_r | vwh_wdc_flgwrtdat3_r);

    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)
            vwh_wdc_selaccdat_r <= 2'b00;
        else if(vwh_wdc_validdata)
            case(vwh_wdc_selaccdat_r)
                2'b00 : vwh_wdc_selaccdat_r <= 2'b01;
                2'b01 : vwh_wdc_selaccdat_r <= 2'b10;
                2'b10 : vwh_wdc_selaccdat_r <= 2'b11;
                2'b11 : vwh_wdc_selaccdat_r <= 2'b00;
            endcase
        else if(!b_write_enable_r)
            vwh_wdc_selaccdat_r <= 2'b00;
    end 
    
    always@(posedge clkdec or negedge rstdec_x) begin
        if(!rstdec_x)
            vwh_wdc_selissdat_r <= 2'b00;
        else if(vwh_wrq_tranacc)
            case(vwh_wdc_selissdat_r)
                2'b00 : vwh_wdc_selissdat_r <= 2'b01;
                2'b01 : vwh_wdc_selissdat_r <= 2'b10;
                2'b10 : vwh_wdc_selissdat_r <= 2'b11;
                2'b11 : vwh_wdc_selissdat_r <= 2'b00;
            endcase
    end 

    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x) begin
            vwh_wdc_flgwrtdat0_r <= 1'b0;
            vwh_wdc_flgwrtdat1_r <= 1'b0;
            vwh_wdc_flgwrtdat2_r <= 1'b0;
            vwh_wdc_flgwrtdat3_r <= 1'b0;
        end else if(vwh_wrq_tranacc)begin 
            case(vwh_wdc_selissdat_r)
                2'b00:begin
                        vwh_wdc_flgwrtdat0_r <= 1'b0;
                        vwh_wdc_flgwrtdat1_r <= 1'b1;
                        vwh_wdc_flgwrtdat2_r <= 1'b1;
                        vwh_wdc_flgwrtdat3_r <= 1'b1;
                      end
                2'b01:begin
                        vwh_wdc_flgwrtdat0_r <= 1'b1;
                        vwh_wdc_flgwrtdat1_r <= 1'b0;
                        vwh_wdc_flgwrtdat2_r <= 1'b1;
                        vwh_wdc_flgwrtdat3_r <= 1'b1;
                      end
                2'b10:begin
                        vwh_wdc_flgwrtdat0_r <= 1'b1;
                        vwh_wdc_flgwrtdat1_r <= 1'b1;
                        vwh_wdc_flgwrtdat2_r <= 1'b0;
                        vwh_wdc_flgwrtdat3_r <= 1'b1;
                      end
                2'b11:begin
                        vwh_wdc_flgwrtdat0_r <= 1'b1;
                        vwh_wdc_flgwrtdat1_r <= 1'b1;
                        vwh_wdc_flgwrtdat2_r <= 1'b1;
                        vwh_wdc_flgwrtdat3_r <= 1'b0;
                      end
            endcase
        end else if(vwh_wdc_validdata)begin
            case(vwh_wdc_selaccdat_r)
                2'b00:begin
                        vwh_wdc_flgwrtdat0_r <= 1'b1;
                        vwh_wdc_flgwrtdat1_r <= 1'b0;
                        vwh_wdc_flgwrtdat2_r <= 1'b0;
                        vwh_wdc_flgwrtdat3_r <= 1'b0;
                      end
                2'b01:begin
                        vwh_wdc_flgwrtdat0_r <= 1'b0;
                        vwh_wdc_flgwrtdat1_r <= 1'b1;
                        vwh_wdc_flgwrtdat2_r <= 1'b0;
                        vwh_wdc_flgwrtdat3_r <= 1'b0;
                      end
                2'b10:begin
                        vwh_wdc_flgwrtdat0_r <= 1'b0;
                        vwh_wdc_flgwrtdat1_r <= 1'b0;
                        vwh_wdc_flgwrtdat2_r <= 1'b1;
                        vwh_wdc_flgwrtdat3_r <= 1'b0;
                      end
                2'b11:begin
                        vwh_wdc_flgwrtdat0_r <= 1'b0;
                        vwh_wdc_flgwrtdat1_r <= 1'b0;
                        vwh_wdc_flgwrtdat2_r <= 1'b0;
                        vwh_wdc_flgwrtdat3_r <= 1'b1;
                      end
            endcase
        end
    end
    
    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)begin
            vwh_wdc_wrtdata0_r <= 32'h0000_0000;
            vwh_wdc_wrtdata1_r <= 32'h0000_0000;
            vwh_wdc_wrtdata2_r <= 32'h0000_0000;
            vwh_wdc_wrtdata3_r <= 32'h0000_0000;
        end else begin
            if(vwh_wdc_validdata)begin
                case(vwh_wdc_selaccdat_r)
                    2'b00: begin
                             vwh_wdc_wrtdata0_r <= b_write_data[63:32];
                             vwh_wdc_wrtdata1_r <= 32'h0000_0000;
                             vwh_wdc_wrtdata2_r <= 32'h0000_0000;
                             vwh_wdc_wrtdata3_r <= 32'h0000_0000;
                           end
                    2'b01: begin
                             vwh_wdc_wrtdata0_r <= 32'h0000_0000;
                             vwh_wdc_wrtdata1_r <= b_write_data[31:0];
                             vwh_wdc_wrtdata2_r <= 32'h0000_0000;
                             vwh_wdc_wrtdata3_r <= 32'h0000_0000;
                           end
                    2'b10: begin
                             vwh_wdc_wrtdata0_r <= 32'h0000_0000;
                             vwh_wdc_wrtdata1_r <= 32'h0000_0000;
                             vwh_wdc_wrtdata2_r <= b_write_data[63:32];
                             vwh_wdc_wrtdata3_r <= 32'h0000_0000;
                           end
                    2'b11: begin
                             vwh_wdc_wrtdata0_r <= 32'h0000_0000;
                             vwh_wdc_wrtdata1_r <= 32'h0000_0000;
                             vwh_wdc_wrtdata2_r <= 32'h0000_0000;
                             vwh_wdc_wrtdata3_r <= b_write_data[31:0];
                           end
                endcase
            end
        end 
    end 
    
endmodule


