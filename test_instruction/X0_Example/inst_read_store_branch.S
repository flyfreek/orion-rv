# RV32I listing; use the paired .data image.
    addi x26,x0,0 # 0000: 00000d13
    addi x27,x0,0 # 0004: 00000d93
    addi x3,x0,4 # 0008: 00400193
    lui x10,0x10000 # 000c: 10000537
    addi x10,x10,0 # 0010: 00050513
    lui x2,0xfeedc # 0014: feedc137
    addi x2,x2,-273 # 0018: eef10113
    sw x2,0(x10) # 001c: 00252023
    addi x0,x0,123 # 0020: 07b00013
    sw x0,0(x10) # 0024: 00052023
    lw x5,0(x10) # 0028: 00052283
    addi x0,x0,0 # 002c: 00000013
    addi x0,x0,0 # 0030: 00000013
    addi x28,x0,0 # 0034: 00000e13
    addi x0,x0,0 # 0038: 00000013
    addi x0,x0,0 # 003c: 00000013
    bne x5,x28,fail # 0040: 05c29663
    bne x0,x0,fail # 0044: 04001463
    lw x5,0(x0) # 0048: 00002283
    addi x0,x0,0 # 004c: 00000013
    addi x0,x0,0 # 0050: 00000013
    lui x28,0x1 # 0054: 00001e37
    addi x28,x28,-749 # 0058: d13e0e13
    addi x0,x0,0 # 005c: 00000013
    addi x0,x0,0 # 0060: 00000013
    bne x5,x28,fail # 0064: 03c29463
    addi x0,x0,0 # 0068: 00000013
    addi x0,x0,0 # 006c: 00000013
    addi x28,x0,0 # 0070: 00000e13
    addi x0,x0,0 # 0074: 00000013
    addi x0,x0,0 # 0078: 00000013
    bne x0,x28,fail # 007c: 01c01863
    addi x27,x0,1 # 0080: 00100d93
    addi x26,x0,1 # 0084: 00100d13
done:
    jal x0,done # 0088: 0000006f
fail:
    addi x27,x0,0 # 008c: 00000d93
    addi x26,x0,1 # 0090: 00100d13
failed:
    jal x0,failed # 0094: 0000006f
