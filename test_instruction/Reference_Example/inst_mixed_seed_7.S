# RV32I listing; use the paired .data image.
    addi x26,x0,0 # 0000: 00000d13
    addi x27,x0,0 # 0004: 00000d93
    addi x3,x0,7 # 0008: 00700193
    lui x10,0x10000 # 000c: 10000537
    addi x10,x10,0 # 0010: 00050513
    lui x1,0x52e6b # 0014: 52e6b0b7
    addi x1,x1,1080 # 0018: 43808093
    lui x2,0xf2a75 # 001c: f2a75137
    addi x2,x2,-540 # 0020: de410113
    lui x3,0x269e1 # 0024: 269e11b7
    addi x3,x3,-713 # 0028: d3718193
    lui x4,0x65132 # 002c: 65132237
    addi x4,x4,1806 # 0030: 70e20213
    lui x5,0xa6a3a # 0034: a6a3a2b7
    addi x5,x5,1104 # 0038: 45028293
    lui x6,0xc5c8 # 003c: 0c5c8337
    addi x6,x6,-48 # 0040: fd030313
    lui x7,0x128b3 # 0044: 128b33b7
    addi x7,x7,-205 # 0048: f3338393
    lui x8,0xd23f1 # 004c: d23f1437
    addi x8,x8,-2012 # 0050: 82440413
    lui x9,0x892f9 # 0054: 892f94b7
    addi x9,x9,43 # 0058: 02b48493
    lui x11,0x1818f # 005c: 1818f5b7
    addi x11,x11,-2031 # 0060: 81158593
    lui x12,0x5d9dd # 0064: 5d9dd637
    addi x12,x12,-1544 # 0068: 9f860613
    lui x13,0x9531a # 006c: 9531a6b7
    addi x13,x13,-1955 # 0070: 85d68693
    lui x14,0xed90 # 0074: 0ed90737
    addi x14,x14,1141 # 0078: 47570713
    lui x15,0xe8e26 # 007c: e8e267b7
    addi x15,x15,-620 # 0080: d9478793
    lui x16,0x81e75 # 0084: 81e75837
    addi x16,x16,-267 # 0088: ef580813
    lui x17,0x36f67 # 008c: 36f678b7
    addi x17,x17,1484 # 0090: 5cc88893
    sub x3,x15,x15 # 0094: 40f781b3
    addi x3,x15,-1034 # 0098: bf678193
    addi x2,x14,-237 # 009c: f1370113
    sll x5,x11,x15 # 00a0: 00f592b3
    beq x11,x6,skip4 # 00a4: 00658463
    addi x4,x4,1 # 00a8: 00120213
skip4:
    bltu x13,x4,skip5 # 00ac: 0046e463
    addi x7,x7,1 # 00b0: 00138393
skip5:
    jal x3,skip6 # 00b4: 008001ef
    addi x3,x0,999 # 00b8: 3e700193
skip6:
    sw x12,56(x10) # 00bc: 02c52c23
    lbu x11,10(x10) # 00c0: 00a54583
    bgeu x17,x12,skip9 # 00c4: 00c8f463
    addi x11,x11,1 # 00c8: 00158593
skip9:
    sw x3,52(x10) # 00cc: 02352a23
    addi x12,x5,1406 # 00d0: 57e28613
    xor x3,x12,x12 # 00d4: 00c641b3
    beq x16,x3,skip13 # 00d8: 00380463
    addi x17,x17,1 # 00dc: 00188893
skip13:
    lh x17,56(x10) # 00e0: 03851883
    lhu x14,44(x10) # 00e4: 02c55703
    addi x4,x17,-261 # 00e8: efb88213
    addi x5,x0,skip17+1 # 00ec: 0f900293
    jalr x11,0(x5) # 00f0: 000285e7
    addi x11,x0,999 # 00f4: 3e700593
skip17:
    sb x17,57(x10) # 00f8: 03150ca3
    sw x5,32(x10) # 00fc: 02552023
    jal x15,skip20 # 0100: 008007ef
    addi x15,x0,999 # 0104: 3e700793
skip20:
    addi x5,x3,-809 # 0108: cd718293
    addi x8,x1,-555 # 010c: dd508413
    lhu x11,46(x10) # 0110: 02e55583
    bge x5,x2,skip24 # 0114: 0022d463
    addi x12,x12,1 # 0118: 00160613
skip24:
    addi x14,x0,skip25+1 # 011c: 12900713
    jalr x14,0(x14) # 0120: 00070767
    addi x14,x0,999 # 0124: 3e700713
skip25:
    sb x17,24(x10) # 0128: 01150c23
    sub x7,x16,x6 # 012c: 406803b3
    lw x2,16(x10) # 0130: 01052103
    beq x13,x1,skip29 # 0134: 00168463
    addi x4,x4,1 # 0138: 00120213
skip29:
    addi x14,x0,skip30+1 # 013c: 14900713
    jalr x7,0(x14) # 0140: 000703e7
    addi x7,x0,999 # 0144: 3e700393
skip30:
    jal x9,skip31 # 0148: 008004ef
    addi x9,x0,999 # 014c: 3e700493
skip31:
    sh x4,60(x10) # 0150: 02451e23
    sb x3,43(x10) # 0154: 023505a3
    jal x9,skip34 # 0158: 008004ef
    addi x9,x0,999 # 015c: 3e700493
skip34:
    bne x7,x13,skip35 # 0160: 00d39463
    addi x1,x1,1 # 0164: 00108093
skip35:
    jal x1,skip36 # 0168: 008000ef
    addi x1,x0,999 # 016c: 3e700093
skip36:
    jal x9,skip37 # 0170: 008004ef
    addi x9,x0,999 # 0174: 3e700493
skip37:
    lw x8,24(x10) # 0178: 01852403
    addi x14,x0,skip39+1 # 017c: 18900713
    jalr x8,0(x14) # 0180: 00070467
    addi x8,x0,999 # 0184: 3e700413
skip39:
    addi x17,x13,-1820 # 0188: 8e468893
    addi x17,x0,skip41+1 # 018c: 19900893
    jalr x9,0(x17) # 0190: 000884e7
    addi x9,x0,999 # 0194: 3e700493
skip41:
    addi x13,x16,939 # 0198: 3ab80693
    sra x8,x4,x8 # 019c: 40825433
    addi x12,x7,-2033 # 01a0: 80f38613
    sh x3,24(x10) # 01a4: 00351c23
    sb x15,50(x10) # 01a8: 02f50923
    sb x3,16(x10) # 01ac: 00350823
    and x5,x16,x5 # 01b0: 005872b3
    addi x13,x0,skip49+1 # 01b4: 1c100693
    jalr x17,0(x13) # 01b8: 000688e7
    addi x17,x0,999 # 01bc: 3e700893
skip49:
    bgeu x1,x1,skip50 # 01c0: 0010f463
    addi x5,x5,1 # 01c4: 00128293
skip50:
    jal x4,skip51 # 01c8: 0080026f
    addi x4,x0,999 # 01cc: 3e700213
skip51:
    addi x7,x0,skip52+1 # 01d0: 1dd00393
    jalr x7,0(x7) # 01d4: 000383e7
    addi x7,x0,999 # 01d8: 3e700393
skip52:
    lw x7,40(x10) # 01dc: 02852383
    lh x15,58(x10) # 01e0: 03a51783
    jal x15,skip55 # 01e4: 008007ef
    addi x15,x0,999 # 01e8: 3e700793
skip55:
    bltu x16,x6,skip56 # 01ec: 00686463
    addi x1,x1,1 # 01f0: 00108093
skip56:
    sra x5,x6,x5 # 01f4: 405352b3
    bgeu x2,x12,skip58 # 01f8: 00c17463
    addi x4,x4,1 # 01fc: 00120213
skip58:
    bne x4,x2,skip59 # 0200: 00221463
    addi x17,x17,1 # 0204: 00188893
skip59:
    addi x9,x2,1656 # 0208: 67810493
    blt x3,x16,skip61 # 020c: 0101c463
    addi x1,x1,1 # 0210: 00108093
skip61:
    bltu x9,x16,skip62 # 0214: 0104e463
    addi x7,x7,1 # 0218: 00138393
skip62:
    bltu x8,x9,skip63 # 021c: 00946463
    addi x17,x17,1 # 0220: 00188893
skip63:
    addi x16,x5,-1052 # 0224: be428813
    sw x12,28(x10) # 0228: 00c52e23
    sb x7,19(x10) # 022c: 007509a3
    jal x13,skip67 # 0230: 008006ef
    addi x13,x0,999 # 0234: 3e700693
skip67:
    addi x16,x8,1214 # 0238: 4be40813
    sw x8,52(x10) # 023c: 02852a23
    bne x12,x15,skip70 # 0240: 00f61463
    addi x14,x14,1 # 0244: 00170713
skip70:
    lb x12,43(x10) # 0248: 02b50603
    bge x16,x1,skip72 # 024c: 00185463
    addi x16,x16,1 # 0250: 00180813
skip72:
    lbu x11,13(x10) # 0254: 00d54583
    sll x9,x9,x2 # 0258: 002494b3
    lhu x5,18(x10) # 025c: 01255283
    blt x12,x3,skip76 # 0260: 00364463
    addi x17,x17,1 # 0264: 00188893
skip76:
    sltu x6,x15,x3 # 0268: 0037b333
    and x3,x9,x3 # 026c: 0034f1b3
    addi x3,x0,skip79+1 # 0270: 27d00193
    jalr x8,0(x3) # 0274: 00018467
    addi x8,x0,999 # 0278: 3e700413
skip79:
    addi x27,x0,1 # 027c: 00100d93
    addi x26,x0,1 # 0280: 00100d13
done:
    jal x0,done # 0284: 0000006f
fail:
    addi x27,x0,0 # 0288: 00000d93
    addi x26,x0,1 # 028c: 00100d13
failed:
    jal x0,failed # 0290: 0000006f
