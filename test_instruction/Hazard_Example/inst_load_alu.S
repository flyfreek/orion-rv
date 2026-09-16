# load_alu; expected load-use stalls: 1
# x3 = 5 on failure. Listing matches the .data image; addresses in comments.
    addi x26,x0,0 # 0x0000
    addi x27,x0,0 # 0x0004
    addi x3,x0,5 # 0x0008
    lui x1,0x10000 # 0x000c
    addi x2,x0,73 # 0x0010
    addi x0,x0,0 # 0x0014
    addi x0,x0,0 # 0x0018
    addi x0,x0,0 # 0x001c
    sw x2,0(x1) # 0x0020
    addi x0,x0,0 # 0x0024
    addi x0,x0,0 # 0x0028
    addi x0,x0,0 # 0x002c
    addi x5,x0,9 # 0x0030
    addi x0,x0,0 # 0x0034
    addi x0,x0,0 # 0x0038
    addi x0,x0,0 # 0x003c
    lw x5,0(x1) # 0x0040
    add x6,x5,x5 # 0x0044
    addi x0,x0,0 # 0x0048
    addi x0,x0,0 # 0x004c
    addi x0,x0,0 # 0x0050
    addi x28,x0,146 # 0x0054
    addi x0,x0,0 # 0x0058
    addi x0,x0,0 # 0x005c
    addi x0,x0,0 # 0x0060
    bne x6,x28,fail # 0x0064
    addi x27,x0,1 # 0x0068
    addi x26,x0,1 # 0x006c
    jal x0,0 # 0x0070
fail:
    addi x27,x0,0 # 0x0074
    addi x26,x0,1 # 0x0078
    jal x0,0 # 0x007c
