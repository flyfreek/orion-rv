# RV32I listing; use the paired .data image.
    addi x26,x0,0 # 0000: 00000d13
    addi x27,x0,0 # 0004: 00000d93
    addi x3,x0,3 # 0008: 00300193
    lui x10,0x10000 # 000c: 10000537
    addi x10,x10,0 # 0010: 00050513
    jal x0,first # 0014: 0080006f
    addi x5,x0,99 # 0018: 06300293
first:
    addi x7,x0,second+1 # 001c: 02900393
    jalr x0,0(x7) # 0020: 00038067
    addi x0,x0,111 # 0024: 06f00013
second:
    addi x0,x0,0 # 0028: 00000013
    addi x0,x0,0 # 002c: 00000013
    addi x28,x0,0 # 0030: 00000e13
    addi x0,x0,0 # 0034: 00000013
    addi x0,x0,0 # 0038: 00000013
    bne x0,x28,fail # 003c: 01c01863
    addi x27,x0,1 # 0040: 00100d93
    addi x26,x0,1 # 0044: 00100d13
done:
    jal x0,done # 0048: 0000006f
fail:
    addi x27,x0,0 # 004c: 00000d93
    addi x26,x0,1 # 0050: 00100d13
failed:
    jal x0,failed # 0054: 0000006f
