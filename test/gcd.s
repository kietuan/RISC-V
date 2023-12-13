# RISC-V Assembly code to find GCD of two numbers using Euclidean algorithm
#to verify this program: s0 and result will store the result
# program stops at ecall.

.data
    num1:   .word   36      # First number
    num2:   .word   48      # Second number
    result: .word   0       # Variable to store the GCD, or s0

.text
    # Load the two numbers into registers
    lw      a0, num1
    lw      a1, num2

    # Call the GCD function
    jal     ra, gcd

    # Exit the program
    li      a7, 10
    

# GCD function
gcd:
    # Save registers on the stack
    addi    sp, sp, -8
    sw      s0, 4(sp)
    sw      s1, 0(sp)

    # Initialize variables
    mv      s0, a0      # s0 = num1
    mv      s1, a1      # s1 = num2

gcd_loop:
    # Check if num2 is zero
    beqz    s1, gcd_done

    # Calculate remainder using the remainder operator
    rem     s2, s0, s1

    # num1 = num2, num2 = remainder
    mv      s0, s1
    mv      s1, s2

    # Repeat the loop
    j       gcd_loop

gcd_done:
    # GCD is in s0, store it in the result variable
    sw      s0, result, t0
    ecall