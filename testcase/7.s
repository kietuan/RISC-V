#test jalr
loop1:
	addi x12, x0, -1
	jal x2, loop2	
	
loop2:
	addi x12, x12, -1 #x2
	jalr x1, x2, 0