# RV32I listing; use the paired .data image.
    addi x26,x0,0 # 0000: 00000d13
    addi x27,x0,0 # 0004: 00000d93
    addi x3,x0,42 # 0008: 02a00193
    lui x10,0x10000 # 000c: 10000537
    addi x10,x10,0 # 0010: 00050513
    lui x1,0xa3b18 # 0014: a3b180b7
    addi x1,x1,-1635 # 0018: 99d08093
    lui x2,0x1c803 # 001c: 1c803137
    addi x2,x2,383 # 0020: 17f10113
    lui x3,0x6672 # 0024: 066721b7
    addi x3,x3,-1327 # 0028: ad118193
    lui x4,0xbdd64 # 002c: bdd64237
    addi x4,x4,251 # 0030: 0fb20213
    lui x5,0x46685 # 0034: 466852b7
    addi x5,x5,599 # 0038: 25728293
    lui x6,0x3eb14 # 003c: 3eb14337
    addi x6,x6,-1136 # 0040: b9030313
    lui x7,0x39245 # 0044: 392453b7
    addi x7,x7,1758 # 0048: 6de38393
    lui x8,0x23b8c # 004c: 23b8c437
    addi x8,x8,489 # 0050: 1e940413
    lui x9,0xbc896 # 0054: bc8964b7
    addi x9,x9,169 # 0058: 0a948493
    lui x11,0x1a3d2 # 005c: 1a3d25b7
    addi x11,x11,-89 # 0060: fa758593
    lui x12,0xad3c3 # 0064: ad3c3637
    addi x12,x12,-659 # 0068: d6d60613
    lui x13,0xbd9c6 # 006c: bd9c66b7
    addi x13,x13,1715 # 0070: 6b368693
    lui x14,0xe465e # 0074: e465e737
    addi x14,x14,336 # 0078: 15070713
    lui x15,0x8b9d2 # 007c: 8b9d27b7
    addi x15,x15,1076 # 0080: 43478793
    lui x16,0x1641a # 0084: 1641a837
    addi x16,x16,-126 # 0088: f8280813
    lui x17,0x972a8 # 008c: 972a88b7
    addi x17,x17,1129 # 0090: 46988893
    sb x1,29(x10) # 0094: 00150ea3
    bne x7,x15,skip1 # 0098: 00f39463
    addi x1,x1,1 # 009c: 00108093
skip1:
    sw x1,52(x10) # 00a0: 02152a23
    lh x9,12(x10) # 00a4: 00c51483
    xor x14,x4,x13 # 00a8: 00d24733
    bltu x2,x16,skip5 # 00ac: 01016463
    addi x9,x9,1 # 00b0: 00148493
skip5:
    and x14,x3,x11 # 00b4: 00b1f733
    addi x7,x0,skip7+1 # 00b8: 0c500393
    jalr x13,0(x7) # 00bc: 000386e7
    addi x13,x0,999 # 00c0: 3e700693
skip7:
    slt x8,x11,x3 # 00c4: 0035a433
    addi x14,x0,skip9+1 # 00c8: 0d500713
    jalr x4,0(x14) # 00cc: 00070267
    addi x4,x0,999 # 00d0: 3e700213
skip9:
    sh x6,26(x10) # 00d4: 00651d23
    jal x9,skip11 # 00d8: 008004ef
    addi x9,x0,999 # 00dc: 3e700493
skip11:
    bge x6,x16,skip12 # 00e0: 01035463
    addi x8,x8,1 # 00e4: 00140413
skip12:
    lbu x8,4(x10) # 00e8: 00454403
    addi x14,x0,skip14+1 # 00ec: 0f900713
    jalr x12,0(x14) # 00f0: 00070667
    addi x12,x0,999 # 00f4: 3e700613
skip14:
    sra x7,x12,x7 # 00f8: 407653b3
    sb x5,31(x10) # 00fc: 00550fa3
    jal x9,skip17 # 0100: 008004ef
    addi x9,x0,999 # 0104: 3e700493
skip17:
    lb x8,6(x10) # 0108: 00650403
    addi x5,x0,skip19+1 # 010c: 11900293
    jalr x4,0(x5) # 0110: 00028267
    addi x4,x0,999 # 0114: 3e700213
skip19:
    addi x3,x0,skip20+1 # 0118: 12500193
    jalr x15,0(x3) # 011c: 000187e7
    addi x15,x0,999 # 0120: 3e700793
skip20:
    sw x9,12(x10) # 0124: 00952623
    jal x9,skip22 # 0128: 008004ef
    addi x9,x0,999 # 012c: 3e700493
skip22:
    lb x15,33(x10) # 0130: 02150783
    bgeu x4,x11,skip24 # 0134: 00b27463
    addi x6,x6,1 # 0138: 00130313
skip24:
    bne x5,x13,skip25 # 013c: 00d29463
    addi x7,x7,1 # 0140: 00138393
skip25:
    beq x12,x17,skip26 # 0144: 01160463
    addi x1,x1,1 # 0148: 00108093
skip26:
    add x13,x11,x8 # 014c: 008586b3
    addi x3,x3,-1482 # 0150: a3618193
    addi x5,x0,skip29+1 # 0154: 16100293
    jalr x5,0(x5) # 0158: 000282e7
    addi x5,x0,999 # 015c: 3e700293
skip29:
    bne x9,x15,skip30 # 0160: 00f49463
    addi x6,x6,1 # 0164: 00130313
skip30:
    bgeu x11,x14,skip31 # 0168: 00e5f463
    addi x7,x7,1 # 016c: 00138393
skip31:
    jal x13,skip32 # 0170: 008006ef
    addi x13,x0,999 # 0174: 3e700693
skip32:
    xor x8,x8,x3 # 0178: 00344433
    sub x8,x8,x1 # 017c: 40140433
    jal x2,skip35 # 0180: 0080016f
    addi x2,x0,999 # 0184: 3e700113
skip35:
    sltu x12,x3,x8 # 0188: 0081b633
    jal x17,skip37 # 018c: 008008ef
    addi x17,x0,999 # 0190: 3e700893
skip37:
    jal x17,skip38 # 0194: 008008ef
    addi x17,x0,999 # 0198: 3e700893
skip38:
    addi x7,x0,skip39+1 # 019c: 1a900393
    jalr x15,0(x7) # 01a0: 000387e7
    addi x15,x0,999 # 01a4: 3e700793
skip39:
    srl x15,x13,x15 # 01a8: 00f6d7b3
    sh x4,42(x10) # 01ac: 02451523
    addi x8,x0,skip42+1 # 01b0: 1bd00413
    jalr x4,0(x8) # 01b4: 00040267
    addi x4,x0,999 # 01b8: 3e700213
skip42:
    addi x16,x5,-545 # 01bc: ddf28813
    lhu x16,12(x10) # 01c0: 00c55803
    sll x1,x3,x8 # 01c4: 008190b3
    sh x17,6(x10) # 01c8: 01151323
    addi x14,x1,124 # 01cc: 07c08713
    addi x11,x0,skip48+1 # 01d0: 1dd00593
    jalr x16,0(x11) # 01d4: 00058867
    addi x16,x0,999 # 01d8: 3e700813
skip48:
    jal x17,skip49 # 01dc: 008008ef
    addi x17,x0,999 # 01e0: 3e700893
skip49:
    lh x7,6(x10) # 01e4: 00651383
    or x17,x6,x2 # 01e8: 002368b3
    slt x6,x3,x3 # 01ec: 0031a333
    sw x8,8(x10) # 01f0: 00852423
    sw x9,40(x10) # 01f4: 02952423
    addi x9,x14,409 # 01f8: 19970493
    sh x3,12(x10) # 01fc: 00351623
    xor x7,x9,x5 # 0200: 0054c3b3
    sll x8,x13,x11 # 0204: 00b69433
    sw x1,12(x10) # 0208: 00152623
    addi x9,x4,-775 # 020c: cf920493
    lbu x11,33(x10) # 0210: 02154583
    beq x9,x2,skip62 # 0214: 00248463
    addi x17,x17,1 # 0218: 00188893
skip62:
    jal x15,skip63 # 021c: 008007ef
    addi x15,x0,999 # 0220: 3e700793
skip63:
    sll x12,x5,x9 # 0224: 00929633
    jal x16,skip65 # 0228: 0080086f
    addi x16,x0,999 # 022c: 3e700813
skip65:
    xor x3,x5,x2 # 0230: 0022c1b3
    beq x15,x5,skip67 # 0234: 00578463
    addi x5,x5,1 # 0238: 00128293
skip67:
    lbu x13,31(x10) # 023c: 01f54683
    jal x4,skip69 # 0240: 0080026f
    addi x4,x0,999 # 0244: 3e700213
skip69:
    bne x8,x6,skip70 # 0248: 00641463
    addi x5,x5,1 # 024c: 00128293
skip70:
    sh x6,30(x10) # 0250: 00651f23
    lb x6,60(x10) # 0254: 03c50303
    addi x7,x16,452 # 0258: 1c480393
    addi x8,x0,skip74+1 # 025c: 26900413
    jalr x8,0(x8) # 0260: 00040467
    addi x8,x0,999 # 0264: 3e700413
skip74:
    jal x7,skip75 # 0268: 008003ef
    addi x7,x0,999 # 026c: 3e700393
skip75:
    lw x3,48(x10) # 0270: 03052183
    jal x12,skip77 # 0274: 0080066f
    addi x12,x0,999 # 0278: 3e700613
skip77:
    lb x6,55(x10) # 027c: 03750303
    lhu x12,24(x10) # 0280: 01855603
    addi x27,x0,1 # 0284: 00100d93
    addi x26,x0,1 # 0288: 00100d13
done:
    jal x0,done # 028c: 0000006f
fail:
    addi x27,x0,0 # 0290: 00000d93
    addi x26,x0,1 # 0294: 00100d13
failed:
    jal x0,failed # 0298: 0000006f
