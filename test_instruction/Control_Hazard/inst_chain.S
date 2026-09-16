# RV32I listing. Label address immediates are resolved in the paired .data image.
    addi x26,x0,0 # 0000 : 00000d13
    addi x27,x0,0 # 0004 : 00000d93
    addi x3,x0,11 # 0008 : 00b00193
    lui x10,0x10000 # 000c : 10000537
    addi x2,x0,73 # 0010 : 04900113
    addi x20,x0,9 # 0014 : 00900a13
    addi x6,x0,0 # 0018 : 00000313
    addi x18,x0,0 # 001c : 00000913
    addi x19,x0,0 # 0020 : 00000993
    addi x21,x0,0 # 0024 : 00000a93
    addi x7,x0,5 # 0028 : 00500393
    addi x0,x0,0 # 002c : 00000013
    addi x0,x0,0 # 0030 : 00000013
    addi x0,x0,0 # 0034 : 00000013
    sw x2,0(x10) # 0038 : 00252023
    addi x0,x0,0 # 003c : 00000013
    addi x0,x0,0 # 0040 : 00000013
    addi x0,x0,0 # 0044 : 00000013
test_start:
link:
    jal x19,t1 # 0048 : 00c009ef
    sw x2,4(x10) # 004c : 00252223
    addi x20,x0,123 # 0050 : 07b00a13
t1:
    beq x2,x2,t2 # 0054 : 00210663
    addi x20,x0,123 # 0058 : 07b00a13
    sw x2,4(x10) # 005c : 00252223
t2:
link2:
    jal x21,target # 0060 : 00c00aef
    sw x2,4(x10) # 0064 : 00252223
    addi x20,x0,123 # 0068 : 07b00a13
target:
    addi x6,x0,10 # 006c : 00a00313
test_end:
    addi x0,x0,0 # 0070 : 00000013
    addi x0,x0,0 # 0074 : 00000013
    addi x0,x0,0 # 0078 : 00000013
    addi x28,x0,10 # 007c : 00a00e13
    addi x0,x0,0 # 0080 : 00000013
    addi x0,x0,0 # 0084 : 00000013
    addi x0,x0,0 # 0088 : 00000013
    bne x6,x28,fail # 008c : 07c31863
    addi x28,x0,9 # 0090 : 00900e13
    addi x0,x0,0 # 0094 : 00000013
    addi x0,x0,0 # 0098 : 00000013
    addi x0,x0,0 # 009c : 00000013
    bne x20,x28,fail # 00a0 : 05ca1e63
    lw x12,4(x10) # 00a4 : 00452603
    addi x0,x0,0 # 00a8 : 00000013
    addi x0,x0,0 # 00ac : 00000013
    addi x0,x0,0 # 00b0 : 00000013
    addi x28,x0,0 # 00b4 : 00000e13
    addi x0,x0,0 # 00b8 : 00000013
    addi x0,x0,0 # 00bc : 00000013
    addi x0,x0,0 # 00c0 : 00000013
    bne x12,x28,fail # 00c4 : 03c61c63
    addi x28,x0,link+4 # 00c8 : 04c00e13
    addi x0,x0,0 # 00cc : 00000013
    addi x0,x0,0 # 00d0 : 00000013
    addi x0,x0,0 # 00d4 : 00000013
    bne x19,x28,fail # 00d8 : 03c99263
    addi x28,x0,link2+4 # 00dc : 06400e13
    addi x0,x0,0 # 00e0 : 00000013
    addi x0,x0,0 # 00e4 : 00000013
    addi x0,x0,0 # 00e8 : 00000013
    bne x21,x28,fail # 00ec : 01ca9863
    addi x27,x0,1 # 00f0 : 00100d93
    addi x26,x0,1 # 00f4 : 00100d13
done:
    jal x0,done # 00f8 : 0000006f
fail:
    addi x27,x0,0 # 00fc : 00000d93
    addi x26,x0,1 # 0100 : 00100d13
failed:
    jal x0,failed # 0104 : 0000006f
