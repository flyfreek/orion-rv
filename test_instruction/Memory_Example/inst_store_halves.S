# RV32I listing; use the paired .data image.
    addi x26,x0,0 # 0000: 00000d13
    addi x27,x0,0 # 0004: 00000d93
    addi x3,x0,5 # 0008: 00500193
    lui x10,0x10000 # 000c: 10000537
    addi x10,x10,0 # 0010: 00050513
    lui x2,0xa1b2c # 0014: a1b2c137
    addi x2,x2,980 # 0018: 3d410113
    sw x2,0(x10) # 001c: 00252023
    lui x4,0xdead9 # 0020: dead9237
    addi x4,x4,-1621 # 0024: 9ab20213
    sh x4,0(x10) # 0028: 00451023
    lw x5,0(x10) # 002c: 00052283
    addi x0,x0,0 # 0030: 00000013
    addi x0,x0,0 # 0034: 00000013
    lui x28,0xa1b29 # 0038: a1b29e37
    addi x28,x28,-1621 # 003c: 9abe0e13
    addi x0,x0,0 # 0040: 00000013
    addi x0,x0,0 # 0044: 00000013
    bne x5,x28,fail # 0048: 05c29463
    lui x2,0xa1b2c # 004c: a1b2c137
    addi x2,x2,980 # 0050: 3d410113
    sw x2,0(x10) # 0054: 00252023
    lui x4,0xdead9 # 0058: dead9237
    addi x4,x4,-1621 # 005c: 9ab20213
    sh x4,2(x10) # 0060: 00451123
    lw x5,0(x10) # 0064: 00052283
    addi x0,x0,0 # 0068: 00000013
    addi x0,x0,0 # 006c: 00000013
    lui x28,0x89abc # 0070: 89abce37
    addi x28,x28,980 # 0074: 3d4e0e13
    addi x0,x0,0 # 0078: 00000013
    addi x0,x0,0 # 007c: 00000013
    bne x5,x28,fail # 0080: 01c29863
    addi x27,x0,1 # 0084: 00100d93
    addi x26,x0,1 # 0088: 00100d13
done:
    jal x0,done # 008c: 0000006f
fail:
    addi x27,x0,0 # 0090: 00000d93
    addi x26,x0,1 # 0094: 00100d13
failed:
    jal x0,failed # 0098: 0000006f
