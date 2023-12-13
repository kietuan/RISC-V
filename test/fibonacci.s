.data
n: .word 7

.text
        jal x0, main
fibonacci:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        sw      s1,20(sp)
        addi    s0,sp,32
        sw      a0,-20(s0)
        lw      a5,-20(s0)
        bne     a5,zero,.L2
        li      a5,0
        j       .L3
.L2:
        lw      a4,-20(s0)
        li      a5,1
        bne     a4,a5,.L4
        li      a5,1
        j       .L3
.L4:
        lw      a5,-20(s0)
        addi    a5,a5,-1
        mv      a0,a5
        call    fibonacci
        mv      s1,a0
        lw      a5,-20(s0)
        addi    a5,a5,-2
        mv      a0,a5
        call    fibonacci
        mv      a5,a0
        add     a5,s1,a5
.L3:
        mv      a0,a5
        lw      ra,28(sp)
        lw      s0,24(sp)
        lw      s1,20(sp)
        addi    sp,sp,32
        jr      ra
main:
	li      sp, 0x10010200
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        lw      a5, n
        sw      a5,-20(s0)
        lw      a0,-20(s0)
        call    fibonacci
        mv      a5,a0
        sw      a5,-24(s0)
        li      a5,0
        #mv      a0,a5
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
#the n-th fibonacci will be in a0 = x10, or in 0x1001001e8
