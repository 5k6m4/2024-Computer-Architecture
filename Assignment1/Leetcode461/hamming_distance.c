#include <stdint.h>
#include <stdio.h>

int hammingDistance(int x, int y) {
    int n = x ^ y;
    int count = 0;
    while (n > 0) {
        count += n & 1;
        n = n >> 1;
    }
    return count;
}

int main() {
    uint32_t test_case[4][2] = {{0x0000000f, 0x0000000f},
                                {0x0000000f, 0x0000001f},
                                {0x0000000f, 0x0000003f},
                                {0x0f0f0f0f, 0xf0f0f0f0}};
    uint32_t golden[4] = {0, 1, 2, 32};

    int test_err = 0;
    for (int i = 0; i < 4; i++) {
        if (hammingDistance(test_case[i][0], test_case[i][1]) != golden[i]) {
            test_err++;
            printf("TestCase%d failed!!\n", i);
        }
    }
    if (test_err == 0) {
        printf("Pass all test cases!!\n");
    }

    return 0;
}