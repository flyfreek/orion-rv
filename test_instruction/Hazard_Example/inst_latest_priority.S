# latest_priority; expected load-use stalls: 0
# x3 = 4 on failure. Listing matches the .data image; addresses in comments.
    addi x26,x0,0 # 0x0000
    addi x27,x0,0 # 0x0004
    addi x3,x0,4 # 0x0008
    addi x5,x0,11 # 0x000c
    addi x5,x0,43 # 0x0010
    add x6,x5,x5 # 0x0014
    addi x0,x0,0 # 0x0018
    addi x0,x0,0 # 0x001c
    addi x0,x0,0 # 0x0020
    addi x28,x0,86 # 0x0024
    addi x0,x0,0 # 0x0028
    addi x0,x0,0 # 0x002c
    addi x0,x0,0 # 0x0030
    bne x6,x28,fail # 0x0034
    addi x27,x0,1 # 0x0038
    addi x26,x0,1 # 0x003c
    jal x0,0 # 0x0040
fail:
    addi x27,x0,0 # 0x0044
    addi x26,x0,1 # 0x0048
    jal x0,0 # 0x004c
