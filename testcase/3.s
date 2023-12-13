#chuong trinh nay kiem tra tinh dung dan cua signed sw, lw, neu dung het thi lap vo tan

loop:
    addi x3, x0, -10
    sw x3, 5(x0)
    lw x12, 5(x0)

    beq x12, x3, loop
