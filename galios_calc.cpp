#include <stdio.h>

// 函数：在GF(2^8)上执行加法
int gf256_add(int a, int b) {
    return a ^ b;
}

int gf256_mul(int a, int b) {
    int result = 0;
    int polynomial = 0x11b; // 不可约多项式 x^8 + x^4 + x^3 + x + 1
    for (int i = 0; i < 8; i++) {
        if (b & 1) { // 检查b的最低位
            result ^= a; // 将a加到结果上
        }
        int high_bit = a & 0x80; // 检查a的最高位
        a <<= 1; // 将a左移一位
        if (high_bit) {
            a ^= polynomial; // 如果最高位是1，执行模不可约多项式
        }
        b >>= 1; // 将b右移一位
    }
    return result;
}

int gf256_inv(int x) {
    int z = x;
    for (int i = 0; i < 6; i++) {
        z = gf256_mul(z, z);  // 先平方
        z = gf256_mul(z, x);  // 再乘以 x
    }
    z = gf256_mul(z, z);  // 最后再平方一次
    return z;
}

// GF(2^8) 除法
int gf256_div(int a, int b) {
    int inv_b = gf256_inv(b);
    return gf256_mul(a, inv_b);
}

int main() {
    int a = 0x17;  // 示例值
    int b = 0x23;  // 示例值
    int result = gf256_mul(a, b);
    printf("Result of GF(2^8) multiplication: 0x%X\n", result);

    int result2 = gf256_inv(b);
    printf("Result of GF(2^8) inversion: 0x%X\n", result2);

    result = gf256_div(a, b);
    printf("Result of GF(2^8) division: 0x%X\n", result);
    return 0;
}
