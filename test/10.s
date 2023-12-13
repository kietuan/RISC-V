addi x1, zero, 1
addi x2, zero, 2
addi x3, zero, 3
li x4, 4
li x5, 5
li x6, 0xFFFFFFFF
sra x6, x6, x5
sra x6, x6, x6
srai x6, x6, 3
sll x6, x6, x3
slli x6, x6, 2
srl x6, x6, x2
srli x6, x6, 10
#test all shift
# result in x5