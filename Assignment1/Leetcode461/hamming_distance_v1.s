.data
    test_case0: .word 0x0000000f, 0x0000000f
    test_case1: .word 0x0000000f, 0x0000001f
    test_case2: .word 0x0000000f, 0x0000003f
    test_case3: .word 0x0f0f0f0f, 0xf0f0f0f0
    golden: .word 0, 1, 2, 32
    err_str0: .string "TestCase"
    err_str1: .string " failed!!\n"
    pass_str: .string "Pass all test cases!!\n"

.text
main:
    la s0, test_case0           # load the address of test_case0 to s0
    la s1, golden               # load the address of golden to s1
    
    # Initialize the test error to zero
    addi t0, x0, 0              # t0 = test_err = 0

    # Initialize local variable for the mainLoop
    addi t1, x0, 0              # t1 = i = 0
    addi t2, x0, 4              # t2 = const. = 4

mainLoop:
    bgeu t1, t2, endMainLoop    # when i >= 4, end mainLoop

    # Prepare the arguments that hammingDistance() need
    lw a0, 0(s0)                # load argument x, a0 = x
    lw a1, 4(s0)                # load argument y, a1 = y

    # RISC-V calling convention and function call
    addi sp, sp, -12            # push t0 ~ t2 to the stack
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    jal ra, hammingDistance     # jump to function hammingDistance
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    addi sp, sp, 12             # pop t0~t2 from the stack

    # Compare hammingDistance() result with the golden
    lw t3, 0(s1)                # load golden, t3 = golden[i]
    beq a0, t3, passTest        # if the result == golden, pass test

    # Update test error
    addi t0, t0, 1              # test_err++

    # Print faild message
    la a0, err_str0             # load the address of err_str0
    li a7, 4                    # system call code for printing a string
    ecall                       # print err_str0

    addi a0, t1, 0              # load the number of the test case
    li a7, 1                    # system call code for printing a integer
    ecall                       # print the number of the test case

    la a0, err_str1             # load the address of err_str1
    li a7, 4                    # system call code for printing a string
    ecall                       # print err_str1
    
passTest:
    # Update test case, golden and loop variable
    addi s0, s0, 8              # move s0 to next test_case
    addi s1, s1, 4              # move s1 to nest golden
    addi t1, t1, 1              # i++
    
    j mainLoop                  # jal x0, mainLoop              

endMainLoop:
    bne t0, x0, exit            # if test_err != 0, do not print pass message

    # Print pass message
    la a0, pass_str             # load the address of pass_str
    li a7, 4                    # system call code for printing a string
    ecall                       # print pass_str

exit:
    li a7, 10                   # system call code for exiting the program
    ecall                       # make the exit system call

hammingDistance:
    # RISC-V calling convention
    addi sp, sp, -8             # push s0 and s1 to stack
    sw s0, 0(sp)
    sw s1, 4(sp)

    # Pass argument used in hammingDistance()
    addi s0, a0, 0              # pass argument x, s0 = x
    addi s1, a1, 0              # pass argument y, s1 = y

    # Initialize local variables of hammingDistance()
    xor t0, s0, s1              # n = x ^ y
    addi t1, x0, 0              # count = 0

loop:
    bgeu x0, t0, endLoop        # when 0 >= n, end loop
    andi t2, t0, 1              # t2 = n & 1
    add t1, t1, t2              # count += n & 1
    srli t0, t0, 1              # n = n >> 1
    j loop                      # jal x0, loop

endLoop:
    # RISC-V calling convention
    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8              # pop s0 and s1 from stack

    # Return count
    addi a0, t1, 0              # move t1 to a0, a0 = count
    ret                         # jalr x0, ra, 0