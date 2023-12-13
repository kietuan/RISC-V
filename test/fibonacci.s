# RISC-V Assembly code to calculate the nth Fibonacci number
# expect: the return segment has value
# t0 = x5 has the true value
.data
    n:      .word   12      # Value of n (change as needed)
    result: .word   0       # Variable to store the result

.text
    # Load the value of n into a register
    lw      a0, n

    # Call the Fibonacci function
    jal     ra, fibonacci

    # Exit the program
    li      a7, 10
    ecall

# Fibonacci function
fibonacci:
    # Save registers on the stack
    addi    sp, sp, -8
    sw      s0, 4(sp)
    sw      s1, 0(sp)

    # Base cases: if n is 0 or 1, return n
    bnez    a0, not_zero
    li      s0, 0       # n = 0
    j       fib_done

not_zero:
    bnez    a0, not_one
    li      s0, 1       # n = 1
    j       fib_done

not_one:
    # Recursive case: Fibonacci(n) = Fibonacci(n-1) + Fibonacci(n-2)

    # Calculate Fibonacci(n-1)
    addi    a0, a0, -1
    jal     ra, fibonacci
    mv      s0, a1      # s0 = Fibonacci(n-1)

    # Calculate Fibonacci(n-2)
    addi    a0, a0, -1
    jal     ra, fibonacci
    mv      s1, a1      # s1 = Fibonacci(n-2)

    # Calculate Fibonacci(n) = Fibonacci(n-1) + Fibonacci(n-2)
    add     s0, s0, s1

fib_done:
    # Store the result in the result variable
    sw      s0, result, s1
    mv      s0, t0
    # Restore registers from the stack
    lw      s0, 4(sp)
    lw      s1, 0(sp)
    addi    sp, sp, 8

    # Return from the function
    ret
