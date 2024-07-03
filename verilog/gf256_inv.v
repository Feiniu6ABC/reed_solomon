module gf256_inv(
    input [7:0] x,
    output reg [7:0] inv_x
);

// 预计算的逆元查找表
reg [7:0] inv_table [0:255];

initial begin
    inv_table[0] = 8'h00; inv_table[1] = 8'h01; inv_table[2] = 8'h8D; inv_table[3] = 8'hF6;
    inv_table[4] = 8'hCB; inv_table[5] = 8'h52; inv_table[6] = 8'h7B; inv_table[7] = 8'hD1;
    inv_table[8] = 8'hE8; inv_table[9] = 8'h4F; inv_table[10] = 8'h29; inv_table[11] = 8'hC0;
    inv_table[12] = 8'hB0; inv_table[13] = 8'hE1; inv_table[14] = 8'hE5; inv_table[15] = 8'hC7;
    inv_table[16] = 8'h74; inv_table[17] = 8'hB4; inv_table[18] = 8'hAA; inv_table[19] = 8'h4B;
    inv_table[20] = 8'h99; inv_table[21] = 8'h2B; inv_table[22] = 8'h60; inv_table[23] = 8'h5F;
    inv_table[24] = 8'h58; inv_table[25] = 8'h3F; inv_table[26] = 8'hFD; inv_table[27] = 8'hCC;
    inv_table[28] = 8'hFF; inv_table[29] = 8'h40; inv_table[30] = 8'hEE; inv_table[31] = 8'hB2;
    inv_table[32] = 8'h3A; inv_table[33] = 8'h6E; inv_table[34] = 8'h5A; inv_table[35] = 8'hF1;
    inv_table[36] = 8'h55; inv_table[37] = 8'h4D; inv_table[38] = 8'hA8; inv_table[39] = 8'hC9;
    inv_table[40] = 8'hC1; inv_table[41] = 8'h0A; inv_table[42] = 8'h98; inv_table[43] = 8'h15;
    inv_table[44] = 8'h30; inv_table[45] = 8'h44; inv_table[46] = 8'hA2; inv_table[47] = 8'hC2;
    inv_table[48] = 8'h2C; inv_table[49] = 8'h45; inv_table[50] = 8'h92; inv_table[51] = 8'h6C;
    inv_table[52] = 8'hF3; inv_table[53] = 8'h39; inv_table[54] = 8'h66; inv_table[55] = 8'h42;
    inv_table[56] = 8'hF2; inv_table[57] = 8'h35; inv_table[58] = 8'h20; inv_table[59] = 8'h6F;
    inv_table[60] = 8'h77; inv_table[61] = 8'hBB; inv_table[62] = 8'h59; inv_table[63] = 8'h19;
    inv_table[64] = 8'h1D; inv_table[65] = 8'hFE; inv_table[66] = 8'h37; inv_table[67] = 8'h67;
    inv_table[68] = 8'h2D; inv_table[69] = 8'h31; inv_table[70] = 8'hF5; inv_table[71] = 8'h69;
    inv_table[72] = 8'hA7; inv_table[73] = 8'h64; inv_table[74] = 8'hAB; inv_table[75] = 8'h13;
    inv_table[76] = 8'h54; inv_table[77] = 8'h25; inv_table[78] = 8'hE9; inv_table[79] = 8'h09;
    inv_table[80] = 8'hED; inv_table[81] = 8'h5C; inv_table[82] = 8'h05; inv_table[83] = 8'hCA;
    inv_table[84] = 8'h4C; inv_table[85] = 8'h24; inv_table[86] = 8'h87; inv_table[87] = 8'hBF;
    inv_table[88] = 8'h18; inv_table[89] = 8'h3E; inv_table[90] = 8'h22; inv_table[91] = 8'hF0;
    inv_table[92] = 8'h51; inv_table[93] = 8'hEC; inv_table[94] = 8'h61; inv_table[95] = 8'h17;
    inv_table[96] = 8'h16; inv_table[97] = 8'h5E; inv_table[98] = 8'hAF; inv_table[99] = 8'hD3;
    inv_table[100] = 8'h49; inv_table[101] = 8'hA6; inv_table[102] = 8'h36; inv_table[103] = 8'h43;
    inv_table[104] = 8'hF4; inv_table[105] = 8'h47; inv_table[106] = 8'h91; inv_table[107] = 8'hDF;
    inv_table[108] = 8'h33; inv_table[109] = 8'h93; inv_table[110] = 8'h21; inv_table[111] = 8'h3B;
    inv_table[112] = 8'h79; inv_table[113] = 8'hB7; inv_table[114] = 8'h97; inv_table[115] = 8'h85;
    inv_table[116] = 8'h10; inv_table[117] = 8'hB5; inv_table[118] = 8'hBA; inv_table[119] = 8'h3C;
    inv_table[120] = 8'hB6; inv_table[121] = 8'h70; inv_table[122] = 8'hD0; inv_table[123] = 8'h06;
    inv_table[124] = 8'hA1; inv_table[125] = 8'hFA; inv_table[126] = 8'h81; inv_table[127] = 8'h82;
    inv_table[128] = 8'h83; inv_table[129] = 8'h7E; inv_table[130] = 8'h7F; inv_table[131] = 8'h80;
    inv_table[132] = 8'h96; inv_table[133] = 8'h73; inv_table[134] = 8'hBE; inv_table[135] = 8'h56;
    inv_table[136] = 8'h9B; inv_table[137] = 8'h9E; inv_table[138] = 8'h95; inv_table[139] = 8'hD9;
    inv_table[140] = 8'hF7; inv_table[141] = 8'h02; inv_table[142] = 8'hB9; inv_table[143] = 8'hA4;
    inv_table[144] = 8'hDE; inv_table[145] = 8'h6A; inv_table[146] = 8'h32; inv_table[147] = 8'h6D;
    inv_table[148] = 8'hD8; inv_table[149] = 8'h8A; inv_table[150] = 8'h84; inv_table[151] = 8'h72;
    inv_table[152] = 8'h2A; inv_table[153] = 8'h14; inv_table[154] = 8'h9F; inv_table[155] = 8'h88;
    inv_table[156] = 8'hF9; inv_table[157] = 8'hDC; inv_table[158] = 8'h89; inv_table[159] = 8'h9A;
    inv_table[160] = 8'hFB; inv_table[161] = 8'h7C; inv_table[162] = 8'h2E; inv_table[163] = 8'hC3;
    inv_table[164] = 8'h8F; inv_table[165] = 8'hB8; inv_table[166] = 8'h65; inv_table[167] = 8'h48;
    inv_table[168] = 8'h26; inv_table[169] = 8'hC8; inv_table[170] = 8'h12; inv_table[171] = 8'h4A;
    inv_table[172] = 8'hCE; inv_table[173] = 8'hE7; inv_table[174] = 8'hD2; inv_table[175] = 8'h62;
    inv_table[176] = 8'h0C; inv_table[177] = 8'hE0; inv_table[178] = 8'h1F; inv_table[179] = 8'hEF;
    inv_table[180] = 8'h11; inv_table[181] = 8'h75; inv_table[182] = 8'h78; inv_table[183] = 8'h71;
    inv_table[184] = 8'hA5; inv_table[185] = 8'h8E; inv_table[186] = 8'h76; inv_table[187] = 8'h3D;
    inv_table[188] = 8'hBD; inv_table[189] = 8'hBC; inv_table[190] = 8'h86; inv_table[191] = 8'h57;
    inv_table[192] = 8'h0B; inv_table[193] = 8'h28; inv_table[194] = 8'h2F; inv_table[195] = 8'hA3;
    inv_table[196] = 8'hDA; inv_table[197] = 8'hD4; inv_table[198] = 8'hE4; inv_table[199] = 8'h0F;
    inv_table[200] = 8'hA9; inv_table[201] = 8'h27; inv_table[202] = 8'h53; inv_table[203] = 8'h04;
    inv_table[204] = 8'h1B; inv_table[205] = 8'hFC; inv_table[206] = 8'hAC; inv_table[207] = 8'hE6;
    inv_table[208] = 8'h7A; inv_table[209] = 8'h07; inv_table[210] = 8'hAE; inv_table[211] = 8'h63;
    inv_table[212] = 8'hC5; inv_table[213] = 8'hDB; inv_table[214] = 8'hE2; inv_table[215] = 8'hEA;
    inv_table[216] = 8'h94; inv_table[217] = 8'h8B; inv_table[218] = 8'hC4; inv_table[219] = 8'hD5;
    inv_table[220] = 8'h9D; inv_table[221] = 8'hF8; inv_table[222] = 8'h90; inv_table[223] = 8'h6B;
    inv_table[224] = 8'hB1; inv_table[225] = 8'h0D; inv_table[226] = 8'hD6; inv_table[227] = 8'hEB;
    inv_table[228] = 8'hC6; inv_table[229] = 8'h0E; inv_table[230] = 8'hCF; inv_table[231] = 8'hAD;
    inv_table[232] = 8'h08; inv_table[233] = 8'h4E; inv_table[234] = 8'hD7; inv_table[235] = 8'hE3;
    inv_table[236] = 8'h5D; inv_table[237] = 8'h50; inv_table[238] = 8'h1E; inv_table[239] = 8'hB3;
    inv_table[240] = 8'h5B; inv_table[241] = 8'h23; inv_table[242] = 8'h38; inv_table[243] = 8'h34;
    inv_table[244] = 8'h68; inv_table[245] = 8'h46; inv_table[246] = 8'h03; inv_table[247] = 8'h8C;
    inv_table[248] = 8'hDD; inv_table[249] = 8'h9C; inv_table[250] = 8'h7D; inv_table[251] = 8'hA0;
    inv_table[252] = 8'hCD; inv_table[253] = 8'h1A; inv_table[254] = 8'h41; inv_table[255] = 8'h1C;
end

always @(*) begin
    inv_x <= inv_table[x]; 
end

endmodule
