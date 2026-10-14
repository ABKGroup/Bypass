// ----------------------------------------------
// File: para.h
// ----------------------------------------------
//
parameter  P_CPU_A_VDCNT0    = 7'h00;
parameter  P_CPU_A_VDCNT1    = 7'h01;
parameter  P_CPU_A_VDCNT2    = 7'h02;
parameter  P_CPU_A_VDCNT3    = 7'h03;
parameter  P_CPU_A_VDMOD0    = 7'h04;
parameter  P_CPU_A_VDSTS0    = 7'h08;
parameter  P_CPU_A_VDSTS1    = 7'h09;
parameter  P_CPU_A_VDICNT    = 7'h0c;
parameter  P_CPU_A_VDICLR    = 7'h0d;
parameter  P_CPU_A_VDISTS    = 7'h0e;
parameter  P_CPU_A_VDESTS0   = 7'h10;
parameter  P_CPU_A_VDESTS1   = 7'h11;
parameter  P_CPU_A_VDESTS2   = 7'h12;
parameter  P_CPU_A_VDESTS3   = 7'h13;
parameter  P_CPU_A_VDDCNT    = 7'h14;
parameter  P_CPU_A_VDDSTS    = 7'h15;
parameter  P_CPU_A_VDVSTS0   = 7'h18;
parameter  P_CPU_A_VDSDFMA   = 7'h1c;
parameter  P_CPU_A_VDSDFOS   = 7'h1d;
parameter  P_CPU_A_VDSDCOS   = 7'h1e;
parameter  P_CPU_A_VDSDLOS   = 7'h1f;
parameter  P_CPU_A_VDHCLR    = 7'h30;
parameter  P_CPU_A_VDHDET    = 7'h31;
parameter  P_CPU_A_VDSEQH0   = 7'h32;
parameter  P_CPU_A_VDSEQH1   = 7'h33;
parameter  P_CPU_A_VDSEQH2   = 7'h34;
parameter  P_CPU_A_VDSEQE    = 7'h35;
parameter  P_CPU_A_VDSEQDE0  = 7'h36;
parameter  P_CPU_A_VDSEQDE1  = 7'h37;
parameter  P_CPU_A_VDGOPH    = 7'h38;
parameter  P_CPU_A_VDPICH    = 7'h39;
parameter  P_CPU_A_VDPICCE0  = 7'h3a;
parameter  P_CPU_A_VDPICCE1  = 7'h3b;
parameter  P_CPU_A_VDPICDE0  = 7'h3c;
parameter  P_CPU_A_VDPICDE1  = 7'h3d;
parameter  P_CPU_A_VDPICDE2  = 7'h3e;
parameter  P_CPU_A_VDPICDE3  = 7'h3f;
parameter  P_CPU_A_VDUDBYT   = 7'h60;
parameter  P_CPU_A_VDADBYT   = 7'h40;

// SRAM Address
parameter  P_MEM_A_VDCPYE0   = 6'h3c;
parameter  P_MEM_A_VDCPYE1   = 6'h3d;
parameter  P_MEM_A_VDCPYE2   = 6'h3e;
parameter  P_MEM_A_VDCPYE3   = 6'h3f;

// Parameter Bus Address Mapping
parameter  P_VLD_A_SEQH0  = 8'h00;
parameter  P_VLD_A_SEQH1  = 8'h02;
parameter  P_VLD_A_SEQH2  = 8'h04;
parameter  P_VLD_A_SEQH3  = 8'h05;
parameter  P_VLD_A_SEQH4  = 8'h06;
parameter  P_VLD_A_SEQE0  = 8'h10;
parameter  P_VLD_A_SEQE1  = 8'h11;
parameter  P_VLD_A_SEQE2  = 8'h12;
parameter  P_VLD_A_SEQE3  = 8'h13;
parameter  P_VLD_A_SEQE4  = 8'h14;
parameter  P_VLD_A_SEQE5  = 8'h15;
parameter  P_VLD_A_SEQE6  = 8'h16;
parameter  P_VLD_A_SEQE7  = 8'h17;
parameter  P_VLD_A_SEQE8  = 8'h18;
parameter  P_VLD_A_SEQDE0 = 8'h19;
parameter  P_VLD_A_SEQDE1 = 8'h1a;
parameter  P_VLD_A_SEQDE2 = 8'h1b;
parameter  P_VLD_A_SEQDE3 = 8'h1c;
parameter  P_VLD_A_SEQDE4 = 8'h1d;
parameter  P_VLD_A_SEQDE5 = 8'h1e;
parameter  P_VLD_A_SEQDE6 = 8'h1f;
parameter  P_VLD_A_GOPH0  = 8'h08;
parameter  P_VLD_A_GOPH1  = 8'h09;
parameter  P_VLD_A_PICH0  = 8'h30;
parameter  P_VLD_A_PICH1  = 8'h31;
parameter  P_VLD_A_PICH2  = 8'h32;
parameter  P_VLD_A_PICH3  = 8'h33;
parameter  P_VLD_A_PICH4  = 8'h34;
parameter  P_VLD_A_PICH5  = 8'h35;
parameter  P_VLD_A_PICH6  = 8'h36;
parameter  P_VLD_A_PICCE0 = 8'h40;
parameter  P_VLD_A_PICCE1 = 8'h41;
parameter  P_VLD_A_PICCE2 = 8'h42;
parameter  P_VLD_A_PICCE3 = 8'h43;
parameter  P_VLD_A_PICCE4 = 8'h44;
parameter  P_VLD_A_PICCE5 = 8'h45;
parameter  P_VLD_A_PICCE6 = 8'h46;
parameter  P_VLD_A_PICCE7 = 8'h47;
parameter  P_VLD_A_PICCE8 = 8'h48;
parameter  P_VLD_A_PICDE0 = 8'h38;
parameter  P_VLD_A_PICDE1 = 8'h39;
parameter  P_VLD_A_PICDE2 = 8'h3a;
parameter  P_VLD_A_PICDE3 = 8'h3b;
parameter  P_VLD_A_PICDE4 = 8'h3c;
parameter  P_VLD_A_PICDE5 = 8'h3d;
parameter  P_VLD_A_PICDE6 = 8'h3e;
parameter  P_VLD_A_CPYE0  = 8'h20;
parameter  P_VLD_A_CPYE1  = 8'h23;
parameter  P_VLD_A_CPYE2  = 8'h24;
parameter  P_VLD_A_CPYE3  = 8'h25;
parameter  P_VLD_A_USRD0  = 8'h80;
parameter  P_VLD_A_USRD1  = 8'h82;
parameter  P_VLD_A_USRD2  = 8'h88;
parameter  P_VLD_A_ATSCD  = 8'h8a;
parameter  P_VLD_A_MPEG1  = 8'h3f;

parameter  P_VLD_A_SLC0D = 8'h0d;
parameter  P_VLD_A_MB50  = 8'h50;
parameter  P_VLD_A_MB51  = 8'h51;
parameter  P_VLD_A_MB52  = 8'h52;
parameter  P_VLD_A_MB54  = 8'h54;
parameter  P_VLD_A_MB55  = 8'h55;
parameter  P_VLD_A_MB61  = 8'h61;
parameter  P_VLD_A_MB62  = 8'h62;
parameter  P_VLD_A_MB64  = 8'h64;
parameter  P_VLD_A_MB65  = 8'h65;
parameter  P_VLD_A_MB69  = 8'h69;
parameter  P_VLD_A_MB6A  = 8'h6a;
parameter  P_VLD_A_MB6C  = 8'h6c;
parameter  P_VLD_A_MB6D  = 8'h6d;
parameter  P_VLD_A_MB71  = 8'h71;
parameter  P_VLD_A_MB72  = 8'h72;
parameter  P_VLD_A_MB74  = 8'h74;
parameter  P_VLD_A_MB75  = 8'h75;
parameter  P_VLD_A_MB79  = 8'h79;
parameter  P_VLD_A_MB7A  = 8'h7a;
parameter  P_VLD_A_MB7C  = 8'h7c;
parameter  P_VLD_A_MB7D  = 8'h7d;

// User_Data Max Byte
parameter  P_MAX_UD_BYTE  = 7'h6c;

// ATSC Data Max Byte
parameter  P_MAX_AD_BYTE  = 7'h7c;

