# RV32I listing; use the paired .data image.
    addi x26,x0,0 # 0000: 00000d13
    addi x27,x0,0 # 0004: 00000d93
    addi x3,x0,1 # 0008: 00100193
    lui x10,0x10000 # 000c: 10000537
    addi x10,x10,0 # 0010: 00050513
    lui x1,0x2265b # 0014: 2265b0b7
    addi x1,x1,501 # 0018: 1f508093
    lui x2,0x91b76 # 001c: 91b76137
    addi x2,x2,-1974 # 0020: 84a10113
    lui x3,0xd8f17 # 0024: d8f171b7
    addi x3,x3,-1313 # 0028: adf18193
    lui x4,0xcd614 # 002c: cd614237
    addi x4,x4,-464 # 0030: e3020213
    lui x5,0xc386c # 0034: c386c2b7
    addi x5,x5,-1084 # 0038: bc428293
    lui x6,0x1027c # 003c: 1027c337
    addi x6,x6,1233 # 0040: 4d130313
    lui x7,0x414c3 # 0044: 414c33b7
    addi x7,x7,1084 # 0048: 43c38393
    lui x8,0x1e2ff # 004c: 1e2ff437
    addi x8,x8,-1143 # 0050: b8940413
    lui x9,0x7ed4d # 0054: 7ed4d4b7
    addi x9,x9,1403 # 0058: 57b48493
    lui x11,0xc2ce7 # 005c: c2ce75b7
    addi x11,x11,-188 # 0060: f4458593
    lui x12,0x7311e # 0064: 7311e637
    addi x12,x12,-1885 # 0068: 8a360613
    lui x13,0x78e51 # 006c: 78e516b7
    addi x13,x13,97 # 0070: 06168693
    lui x14,0xa6ced # 0074: a6ced737
    addi x14,x14,-997 # 0078: c1b70713
    lui x15,0x612e7 # 007c: 612e77b7
    addi x15,x15,1686 # 0080: 69678793
    lui x16,0xc9e9c # 0084: c9e9c837
    addi x16,x16,1558 # 0088: 61680813
    lui x17,0x35bfa # 008c: 35bfa8b7
    addi x17,x17,-1747 # 0090: 92d88893
    srl x17,x1,x14 # 0094: 00e0d8b3
    bgeu x16,x9,skip1 # 0098: 00987463
    addi x1,x1,1 # 009c: 00108093
skip1:
    addi x4,x0,skip2+1 # 00a0: 0ad00213
    jalr x8,0(x4) # 00a4: 00020467
    addi x8,x0,999 # 00a8: 3e700413
skip2:
    srl x1,x1,x1 # 00ac: 0010d0b3
    jal x7,skip4 # 00b0: 008003ef
    addi x7,x0,999 # 00b4: 3e700393
skip4:
    bltu x16,x17,skip5 # 00b8: 01186463
    addi x8,x8,1 # 00bc: 00140413
skip5:
    addi x13,x8,1717 # 00c0: 6b540693
    lbu x1,37(x10) # 00c4: 02554083
    sltu x12,x15,x7 # 00c8: 0077b633
    lhu x17,30(x10) # 00cc: 01e55883
    jal x14,skip10 # 00d0: 0080076f
    addi x14,x0,999 # 00d4: 3e700713
skip10:
    lw x13,12(x10) # 00d8: 00c52683
    addi x14,x0,skip12+1 # 00dc: 0e900713
    jalr x6,0(x14) # 00e0: 00070367
    addi x6,x0,999 # 00e4: 3e700313
skip12:
    sh x17,50(x10) # 00e8: 03151923
    jal x6,skip14 # 00ec: 0080036f
    addi x6,x0,999 # 00f0: 3e700313
skip14:
    or x7,x8,x14 # 00f4: 00e463b3
    lw x13,0(x10) # 00f8: 00052683
    sb x7,61(x10) # 00fc: 02750ea3
    addi x7,x0,skip18+1 # 0100: 10d00393
    jalr x13,0(x7) # 0104: 000386e7
    addi x13,x0,999 # 0108: 3e700693
skip18:
    sb x15,42(x10) # 010c: 02f50523
    sw x8,20(x10) # 0110: 00852a23
    addi x9,x0,skip21+1 # 0114: 12100493
    jalr x3,0(x9) # 0118: 000481e7
    addi x3,x0,999 # 011c: 3e700193
skip21:
    addi x3,x0,skip22+1 # 0120: 12d00193
    jalr x3,0(x3) # 0124: 000181e7
    addi x3,x0,999 # 0128: 3e700193
skip22:
    sh x9,14(x10) # 012c: 00951723
    addi x13,x0,skip24+1 # 0130: 13d00693
    jalr x6,0(x13) # 0134: 00068367
    addi x6,x0,999 # 0138: 3e700313
skip24:
    or x6,x6,x9 # 013c: 00936333
    addi x9,x11,589 # 0140: 24d58493
    sh x4,48(x10) # 0144: 02451823
    lb x15,32(x10) # 0148: 02050783
    jal x7,skip29 # 014c: 008003ef
    addi x7,x0,999 # 0150: 3e700393
skip29:
    addi x1,x14,-1759 # 0154: 92170093
    jal x6,skip31 # 0158: 0080036f
    addi x6,x0,999 # 015c: 3e700313
skip31:
    bltu x16,x8,skip32 # 0160: 00886463
    addi x8,x8,1 # 0164: 00140413
skip32:
    jal x1,skip33 # 0168: 008000ef
    addi x1,x0,999 # 016c: 3e700093
skip33:
    jal x15,skip34 # 0170: 008007ef
    addi x15,x0,999 # 0174: 3e700793
skip34:
    addi x7,x2,-1469 # 0178: a4310393
    addi x11,x0,skip36+1 # 017c: 18900593
    jalr x3,0(x11) # 0180: 000581e7
    addi x3,x0,999 # 0184: 3e700193
skip36:
    jal x6,skip37 # 0188: 0080036f
    addi x6,x0,999 # 018c: 3e700313
skip37:
    addi x1,x2,1727 # 0190: 6bf10093
    addi x2,x14,794 # 0194: 31a70113
    sra x7,x15,x7 # 0198: 4077d3b3
    add x14,x11,x17 # 019c: 01158733
    lbu x14,25(x10) # 01a0: 01954703
    addi x5,x0,skip43+1 # 01a4: 1b100293
    jalr x12,0(x5) # 01a8: 00028667
    addi x12,x0,999 # 01ac: 3e700613
skip43:
    sh x9,44(x10) # 01b0: 02951623
    addi x8,x0,skip45+1 # 01b4: 1c100413
    jalr x17,0(x8) # 01b8: 000408e7
    addi x17,x0,999 # 01bc: 3e700893
skip45:
    jal x2,skip46 # 01c0: 0080016f
    addi x2,x0,999 # 01c4: 3e700113
skip46:
    addi x6,x7,673 # 01c8: 2a138313
    blt x13,x12,skip48 # 01cc: 00c6c463
    addi x9,x9,1 # 01d0: 00148493
skip48:
    sll x11,x8,x17 # 01d4: 011415b3
    bge x12,x2,skip50 # 01d8: 00265463
    addi x4,x4,1 # 01dc: 00120213
skip50:
    xor x14,x5,x5 # 01e0: 0052c733
    and x14,x3,x8 # 01e4: 0081f733
    and x9,x13,x11 # 01e8: 00b6f4b3
    beq x16,x9,skip54 # 01ec: 00980463
    addi x4,x4,1 # 01f0: 00120213
skip54:
    addi x11,x0,skip55+1 # 01f4: 20100593
    jalr x2,0(x11) # 01f8: 00058167
    addi x2,x0,999 # 01fc: 3e700113
skip55:
    beq x3,x15,skip56 # 0200: 00f18463
    addi x1,x1,1 # 0204: 00108093
skip56:
    addi x7,x0,skip57+1 # 0208: 21500393
    jalr x2,0(x7) # 020c: 00038167
    addi x2,x0,999 # 0210: 3e700113
skip57:
    addi x6,x0,skip58+1 # 0214: 22100313
    jalr x15,0(x6) # 0218: 000307e7
    addi x15,x0,999 # 021c: 3e700793
skip58:
    sw x8,12(x10) # 0220: 00852623
    sw x11,60(x10) # 0224: 02b52e23
    lb x4,3(x10) # 0228: 00350203
    srl x11,x12,x16 # 022c: 010655b3
    lh x14,58(x10) # 0230: 03a51703
    xor x9,x7,x17 # 0234: 0113c4b3
    lbu x6,31(x10) # 0238: 01f54303
    lhu x3,10(x10) # 023c: 00a55183
    jal x12,skip67 # 0240: 0080066f
    addi x12,x0,999 # 0244: 3e700613
skip67:
    lh x2,38(x10) # 0248: 02651103
    addi x12,x4,-41 # 024c: fd720613
    addi x1,x8,-1456 # 0250: a5040093
    lb x3,37(x10) # 0254: 02550183
    addi x17,x0,skip72+1 # 0258: 26500893
    jalr x13,0(x17) # 025c: 000886e7
    addi x13,x0,999 # 0260: 3e700693
skip72:
    addi x4,x0,skip73+1 # 0264: 27100213
    jalr x5,0(x4) # 0268: 000202e7
    addi x5,x0,999 # 026c: 3e700293
skip73:
    sll x6,x6,x5 # 0270: 00531333
    addi x11,x0,skip75+1 # 0274: 28100593
    jalr x12,0(x11) # 0278: 00058667
    addi x12,x0,999 # 027c: 3e700613
skip75:
    jal x11,skip76 # 0280: 008005ef
    addi x11,x0,999 # 0284: 3e700593
skip76:
    addi x2,x12,-589 # 0288: db360113
    lbu x15,32(x10) # 028c: 02054783
    addi x16,x0,skip79+1 # 0290: 29d00813
    jalr x3,0(x16) # 0294: 000801e7
    addi x3,x0,999 # 0298: 3e700193
skip79:
    addi x27,x0,1 # 029c: 00100d93
    addi x26,x0,1 # 02a0: 00100d13
done:
    jal x0,done # 02a4: 0000006f
fail:
    addi x27,x0,0 # 02a8: 00000d93
    addi x26,x0,1 # 02ac: 00100d13
failed:
    jal x0,failed # 02b0: 0000006f
