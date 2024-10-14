.data
    # test cases pair = {input bf16 value, golden fp32 value}
    test_case:
        .word 0x00003f80, 0x3f800000 # 0: normal positive of bf16
        .word 0x0000bf80, 0xbf800000 # 1: normal negative of bf16
        .word 0x00000000, 0x00000000 # 2: positive zero of bf16
        .word 0x00007f80, 0x7f800000 # 3: positive infinity of bf16
        .word 0x00007fc0, 0x7fc00000 # 4: quiet NaN of bf16
        .word 0x00000001, 0x00010000 # 5: subnormal positive of bf16
        .word 0x00008001, 0x80010000 # 6: subnormal negative of bf16
        .word 0x00007f7f, 0x7f7f0000 # 7: normal maximum of bf16
        .word 0x00000080, 0x00800000 # 8: normal minimum of bf16
    err_str0: .string "TestCase"
    err_str1: .string " of bf16_to_fp32() failed!!\n"
    pass_str: .string "Pass all test cases of bf16_to_fp32()!!\n"

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

    # Load the argument that bf16_to_fp32() needs
    lw a0, 0(s0)

    # Function call
    jal ra, bf16_to_fp32        # jump to functioin bf16_to_fp32

    # Compare bf16_to_fp32() result with the golden
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

bf16_to_fp32:
    slli a0, a0, 16             # a0 = h.bits << 16
    ret                         # jalr x0, ra, 0
