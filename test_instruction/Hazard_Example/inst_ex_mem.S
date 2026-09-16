# ex_mem; expected load-use stalls: 0
# x3 = 1 on failure. Listing matches the .data image; addresses in comments.
    addi x26,x0,0 # 0x0000
    addi x27,x0,0 # 0x0004
    addi x3,x0,1 # 0x0008
    addi x5,x0,41 # 0x000c
    add x6,x5,x5 # 0x0010
    addi x0,x0,0 # 0x0014
    addi x0,x0,0 # 0x0018
    addi x0,x0,0 # 0x001c
    addi x28,x0,82 # 0x0020
    addi x0,x0,0 # 0x0024
    addi x0,x0,0 # 0x0028
    addi x0,x0,0 # 0x002c
    bne x6,x28,fail # 0x0030
    addi x27,x0,1 # 0x0034
    addi x26,x0,1 # 0x0038
    jal x0,0 # 0x003c
fail:
    addi x27,x0,0 # 0x0040
    addi x26,x0,1 # 0x0044
    jal x0,0 # 0x0048
