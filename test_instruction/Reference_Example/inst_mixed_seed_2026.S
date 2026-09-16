# RV32I listing; use the paired .data image.
    addi x26,x0,0 # 0000: 00000d13
    addi x27,x0,0 # 0004: 00000d93
    addi x3,x0,2026 # 0008: 7ea00193
    lui x10,0x10000 # 000c: 10000537
    addi x10,x10,0 # 0010: 00050513
    lui x1,0x1e7ea # 0014: 1e7ea0b7
    addi x1,x1,1049 # 0018: 41908093
    lui x2,0x51c9c # 001c: 51c9c137
    addi x2,x2,-912 # 0020: c7010113
    lui x3,0x80a4e # 0024: 80a4e1b7
    addi x3,x3,-166 # 0028: f5a18193
    lui x4,0xf38b3 # 002c: f38b3237
    addi x4,x4,-4 # 0030: ffc20213
    lui x5,0x8306d # 0034: 8306d2b7
    addi x5,x5,59 # 0038: 03b28293
    lui x6,0xa5aec # 003c: a5aec337
    addi x6,x6,1943 # 0040: 79730313
    lui x7,0xdc290 # 0044: dc2903b7
    addi x7,x7,-112 # 0048: f9038393
    lui x8,0xf3f49 # 004c: f3f49437
    addi x8,x8,585 # 0050: 24940413
    lui x9,0x1a467 # 0054: 1a4674b7
    addi x9,x9,-1916 # 0058: 88448493
    lui x11,0xe255b # 005c: e255b5b7
    addi x11,x11,-821 # 0060: ccb58593
    lui x12,0x39293 # 0064: 39293637
    addi x12,x12,-734 # 0068: d2260613
    lui x13,0xe5121 # 006c: e51216b7
    addi x13,x13,1154 # 0070: 48268693
    lui x14,0x99dd2 # 0074: 99dd2737
    addi x14,x14,1309 # 0078: 51d70713
    lui x15,0x9f199 # 007c: 9f1997b7
    addi x15,x15,1284 # 0080: 50478793
    lui x16,0x8e7aa # 0084: 8e7aa837
    addi x16,x16,1769 # 0088: 6e980813
    lui x17,0x6bad7 # 008c: 6bad78b7
    addi x17,x17,-1054 # 0090: be288893
    addi x16,x0,skip0+1 # 0094: 0a100813
    jalr x17,0(x16) # 0098: 000808e7
    addi x17,x0,999 # 009c: 3e700893
skip0:
    sub x3,x4,x11 # 00a0: 40b201b3
    sb x17,50(x10) # 00a4: 03150923
    lw x13,8(x10) # 00a8: 00852683
    jal x12,skip4 # 00ac: 0080066f
    addi x12,x0,999 # 00b0: 3e700613
skip4:
    lb x16,47(x10) # 00b4: 02f50803
    lhu x16,62(x10) # 00b8: 03e55803
    addi x15,x0,skip7+1 # 00bc: 0c900793
    jalr x4,0(x15) # 00c0: 00078267
    addi x4,x0,999 # 00c4: 3e700213
skip7:
    sw x15,0(x10) # 00c8: 00f52023
    bgeu x5,x2,skip9 # 00cc: 0022f463
    addi x8,x8,1 # 00d0: 00140413
skip9:
    bne x15,x17,skip10 # 00d4: 01179463
    addi x4,x4,1 # 00d8: 00120213
skip10:
    sw x4,60(x10) # 00dc: 02452e23
    jal x9,skip12 # 00e0: 008004ef
    addi x9,x0,999 # 00e4: 3e700493
skip12:
    bne x14,x15,skip13 # 00e8: 00f71463
    addi x17,x17,1 # 00ec: 00188893
skip13:
    lbu x9,58(x10) # 00f0: 03a54483
    addi x13,x0,skip15+1 # 00f4: 10100693
    jalr x17,0(x13) # 00f8: 000688e7
    addi x17,x0,999 # 00fc: 3e700893
skip15:
    lhu x17,4(x10) # 0100: 00455883
    addi x12,x0,skip17+1 # 0104: 11100613
    jalr x11,0(x12) # 0108: 000605e7
    addi x11,x0,999 # 010c: 3e700593
skip17:
    addi x16,x0,skip18+1 # 0110: 11d00813
    jalr x4,0(x16) # 0114: 00080267
    addi x4,x0,999 # 0118: 3e700213
skip18:
    sb x15,34(x10) # 011c: 02f50123
    sw x4,52(x10) # 0120: 02452a23
    addi x16,x1,-2047 # 0124: 80108813
    sb x7,5(x10) # 0128: 007502a3
    addi x13,x0,skip23+1 # 012c: 13900693
    jalr x9,0(x13) # 0130: 000684e7
    addi x9,x0,999 # 0134: 3e700493
skip23:
    or x12,x17,x5 # 0138: 0058e633
    addi x17,x5,-1357 # 013c: ab328893
    sw x5,52(x10) # 0140: 02552a23
    sb x7,13(x10) # 0144: 007506a3
    sw x2,44(x10) # 0148: 02252623
    addi x1,x0,skip29+1 # 014c: 15900093
    jalr x1,0(x1) # 0150: 000080e7
    addi x1,x0,999 # 0154: 3e700093
skip29:
    lb x11,63(x10) # 0158: 03f50583
    sh x5,42(x10) # 015c: 02551523
    sb x3,25(x10) # 0160: 00350ca3
    jal x6,skip33 # 0164: 0080036f
    addi x6,x0,999 # 0168: 3e700313
skip33:
    sb x17,27(x10) # 016c: 01150da3
    addi x6,x0,skip35+1 # 0170: 17d00313
    jalr x5,0(x6) # 0174: 000302e7
    addi x5,x0,999 # 0178: 3e700293
skip35:
    sb x15,49(x10) # 017c: 02f508a3
    lh x6,58(x10) # 0180: 03a51303
    sb x11,41(x10) # 0184: 02b504a3
    bltu x16,x4,skip39 # 0188: 00486463
    addi x17,x17,1 # 018c: 00188893
skip39:
    addi x4,x0,skip40+1 # 0190: 19d00213
    jalr x9,0(x4) # 0194: 000204e7
    addi x9,x0,999 # 0198: 3e700493
skip40:
    addi x1,x3,658 # 019c: 29218093
    sb x1,45(x10) # 01a0: 021506a3
    bltu x4,x9,skip43 # 01a4: 00926463
    addi x7,x7,1 # 01a8: 00138393
skip43:
    addi x11,x0,skip44+1 # 01ac: 1b900593
    jalr x7,0(x11) # 01b0: 000583e7
    addi x7,x0,999 # 01b4: 3e700393
skip44:
    jal x5,skip45 # 01b8: 008002ef
    addi x5,x0,999 # 01bc: 3e700293
skip45:
    add x15,x6,x4 # 01c0: 004307b3
    addi x6,x0,skip47+1 # 01c4: 1d100313
    jalr x13,0(x6) # 01c8: 000306e7
    addi x13,x0,999 # 01cc: 3e700693
skip47:
    blt x9,x3,skip48 # 01d0: 0034c463
    addi x12,x12,1 # 01d4: 00160613
skip48:
    lb x6,1(x10) # 01d8: 00150303
    sb x15,12(x10) # 01dc: 00f50623
    addi x1,x11,-1280 # 01e0: b0058093
    jal x13,skip52 # 01e4: 008006ef
    addi x13,x0,999 # 01e8: 3e700693
skip52:
    bltu x14,x12,skip53 # 01ec: 00c76463
    addi x2,x2,1 # 01f0: 00110113
skip53:
    addi x16,x15,1017 # 01f4: 3f978813
    addi x14,x0,skip55+1 # 01f8: 20500713
    jalr x9,0(x14) # 01fc: 000704e7
    addi x9,x0,999 # 0200: 3e700493
skip55:
    addi x2,x0,skip56+1 # 0204: 21100113
    jalr x13,0(x2) # 0208: 000106e7
    addi x13,x0,999 # 020c: 3e700693
skip56:
    sub x11,x12,x11 # 0210: 40b605b3
    lw x15,40(x10) # 0214: 02852783
    addi x2,x4,-1043 # 0218: bed20113
    and x2,x5,x13 # 021c: 00d2f133
    jal x11,skip61 # 0220: 008005ef
    addi x11,x0,999 # 0224: 3e700593
skip61:
    bge x13,x15,skip62 # 0228: 00f6d463
    addi x5,x5,1 # 022c: 00128293
skip62:
    sb x15,23(x10) # 0230: 00f50ba3
    bne x14,x9,skip64 # 0234: 00971463
    addi x1,x1,1 # 0238: 00108093
skip64:
    addi x1,x1,1874 # 023c: 75208093
    sw x12,8(x10) # 0240: 00c52423
    addi x2,x0,skip67+1 # 0244: 25100113
    jalr x6,0(x2) # 0248: 00010367
    addi x6,x0,999 # 024c: 3e700313
skip67:
    lbu x12,60(x10) # 0250: 03c54603
    xor x8,x5,x14 # 0254: 00e2c433
    addi x9,x0,skip70+1 # 0258: 26500493
    jalr x8,0(x9) # 025c: 00048467
    addi x8,x0,999 # 0260: 3e700413
skip70:
    addi x13,x0,skip71+1 # 0264: 27100693
    jalr x7,0(x13) # 0268: 000683e7
    addi x7,x0,999 # 026c: 3e700393
skip71:
    sb x17,20(x10) # 0270: 01150a23
    jal x15,skip73 # 0274: 008007ef
    addi x15,x0,999 # 0278: 3e700793
skip73:
    sll x13,x15,x2 # 027c: 002796b3
    sll x11,x13,x9 # 0280: 009695b3
    jal x4,skip76 # 0284: 0080026f
    addi x4,x0,999 # 0288: 3e700213
skip76:
    addi x2,x0,skip77+1 # 028c: 29900113
    jalr x11,0(x2) # 0290: 000105e7
    addi x11,x0,999 # 0294: 3e700593
skip77:
    sb x4,49(x10) # 0298: 024508a3
    lw x9,24(x10) # 029c: 01852483
    addi x27,x0,1 # 02a0: 00100d93
    addi x26,x0,1 # 02a4: 00100d13
done:
    jal x0,done # 02a8: 0000006f
fail:
    addi x27,x0,0 # 02ac: 00000d93
    addi x26,x0,1 # 02b0: 00100d13
failed:
    jal x0,failed # 02b4: 0000006f
