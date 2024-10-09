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
    addi s2, x0, 0              # s2 = test_err = 0

    # Initialize local variable for the mainLoop
    addi s3, x0, 0              # s3 = i = 0
    addi s4, x0, 4              # s4 = const. = 4

mainLoop:
    bgeu s3, s4, endMainLoop    # when i >= 4, end mainLoop

    # Prepare the arguments that hammingDistance() need
    lw a0, 0(s0)                # load argument x, a0 = x
    lw a1, 4(s0)                # load argument y, a1 = y

    # Function call
    jal ra, hammingDistance     # jump to function hammingDistance

    # Compare hammingDistance() result with the golden
    lw s5, 0(s1)                # load golden, s5 = golden[i]
    beq a0, s5, passTest        # if the result == golden, pass test

    # Update test error
    addi s2, s2, 1              # test_err++

    # Print faild message
    la a0, err_str0             # load the address of err_str0
    li a7, 4                    # system call code for printing a string
    ecall                       # print err_str0

    addi a0, s3, 0              # load the number of the test case
    li a7, 1                    # system call code for printing a integer
    ecall                       # print the number of the test case

    la a0, err_str1             # load the address of err_str1
    li a7, 4                    # system call code for printing a string
    ecall                       # print err_str1
    
passTest:
    # Update test case, golden and loop variable
    addi s0, s0, 8              # move s0 to next test_case
    addi s1, s1, 4              # move s1 to nest golden
    addi s3, s3, 1              # i++
    
    j mainLoop                  # jal x0, mainLoop              

endMainLoop:
    bne s2, x0, exit            # if test_err != 0, do not print pass message

    # Print pass message
    la a0, pass_str             # load the address of pass_str
    li a7, 4                    # system call code for printing a string
    ecall                       # print pass_str

exit:
    li a7, 10                   # system call code for exiting the program
    ecall                       # make the exit system call

hammingDistance:
    # Pass argument used in hammingDistance()
    addi t0, a0, 0              # pass argument x, t0 = x
    addi t1, a1, 0              # pass argument y, t1 = y

    # Initialize local variables of hammingDistance()
    xor t2, t0, t1              # n = x ^ y
    addi t3, x0, 0              # count = 0

loop:
    bgeu x0, t2, endLoop        # when 0 >= n, end loop

    andi t4, t2, 1              # t4 = n & 1
    add t3, t3, t4              # count += n & 1
    srli t2, t2, 1              # n = n >> 1

    andi t4, t2, 1              # t4 = (n >> 1) & 1
    add t3, t3, t4              # count += (n >> 1) & 1
    srli t2, t2, 1              # n = n >> 2

    andi t4, t2, 1              # t4 = (n >> 2) & 1
    add t3, t3, t4              # count += (n >> 2) & 1
    srli t2, t2, 1              # n = n >> 3

    andi t4, t2, 1              # t4 = (n >> 3) & 1
    add t3, t3, t4              # count += (n >> 3) & 1
    srli t2, t2, 1              # n = n >> 4

    j loop                      # jal x0, loop

endLoop:
    # Return count
    addi a0, t3, 0              # move t3 to a0, a0 = count
    ret                         # jalr x0, ra, 0