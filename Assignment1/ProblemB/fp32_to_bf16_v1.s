.data
    # test cases pair = {input fp32 value, golden bf16 value}
    test_case:
        .word 0x41200000, 0x00004120 # 0: normal positive of fp32
        .word 0xc1200000, 0x0000c120 # 1: normal negative of fp32
        .word 0x00000000, 0x00000000 # 2: positive zero of fp32
        .word 0x7f800000, 0x00007f80 # 3: positive infinity of fp32
        .word 0x7fc00000, 0x00007fc0 # 4: quiet NaN of fp32
        .word 0x00000001, 0x00000000 # 5: subnormal positive of fp32
        .word 0x80000001, 0x00008000 # 6: subnormal negative of fp32
        .word 0x7f7fffff, 0x00007f80 # 7: normal maximum of fp32
        .word 0x00800000, 0x00000080 # 8: normal minimum of fp32
    err_str0: .string "TestCase"
    err_str1: .string " of fp32_to_bf16() failed!!\n"
    pass_str: .string "Pass all test cases of fp32_to_bf16()!!\n"

.text
main:
    la s0, test_case            # load the address of test_case to s0

    # Initialize the test error to zero
    addi s1, x0, 0              # s1 = test_err = 0

    # Initialize local variables for the mainLoop
    addi s2, x0, 0              # s2 = i = 0
    addi s3, x0, 9              # s3 = const. = 9

mainLoop:
    bgeu s2, s3, endMainLoop    # when i >= 9, end mainLoop

    # Load the argument that fp32_to_bf16() needs
    lw a0, 0(s0)

    # Function call
    jal ra, fp32_to_bf16        # jump to functioin fp32_to_bf16

    # Compare fp32_to_bf16() result with the golden
    lw s4, 4(s0)                # load golden, s4 = golden value
    beq a0, s4, passTest        # if result == golden, pass test case

    # Update test error
    addi s1, s1, 1              # test_err++

    # Print failed message
    la a0, err_str0             # load the address of err_str0
    li a7, 4                    # system call code for printing a string
    ecall                       # print err_str0

    addi a0, s2, 0              # load the number of the test case
    li a7, 1                    # system call code for printing a integer
    ecall                       # print the number of the test case

    la a0, err_str1             # load the address of err_str1
    li a7, 4                    # system call code for printing a string
    ecall                       # print err_str1

passTest:
    # Update test case and loop variable
    addi s0, s0, 8              # move s0 to the address of the next test case
    addi s2, s2, 1              # i++

    j mainLoop                  # jal x0, mainLoop

endMainLoop:
    bne s1, x0, exit            # if test_err != 0, do not print pass message

    # Print pass message
    la a0, pass_str             # load the address of pass_str
    li a7, 4                    # system call code for printing a string
    ecall                       # print pass_str16

exit:
    li a7, 10                   # system call code for exiting the program
    ecall                       # make the exit system call

fp32_to_bf16:
    addi t0, a0, 0              # pass argument s, t0 = s

    li t1, 0x7fffffff           # t1 = 0x7fffffff
    and t1, t0, t1              # t1 = u.i & 0x7fffffff
    li t2, 0x7f800000           # t2 = 0x7f800000

if:
    bge t2, t1, endIf           # if 0x7f800000 >= (u.i & 0x7fffffff), skip NaN handling

    # Handle NaN value
    srli t1, t0, 16             # t1 = u.i >> 16
    ori a0, t1, 64              # t1 = h = (u.i >> 16) | 64
    ret                         # jalr x0, ra, 0

endIf:
    # Round to nearest even value
    srli t1, t0, 16             # t1 = u.i >> 0x10
    andi t1, t1, 1              # t1 = ((u.i >> 0x10) & 1)
    li t2, 0x7fff               # t2 = 0x7fff
    add t1, t2, t1              # t1 = 0x7fff + ((u.i >> 0x10) & 1)
    add t1, t0, t1              # t1 = u.i + (0x7fff + ((u.i >> 0x10) & 1))
    srli a0, t1, 16             # t1 = h = (u.i + (0x7fff + ((u.i >> 0x10) & 1))) >> 0x10;
    ret                         # jalr x0, ra, 0