#include <stdio.h>

// 函数：在GF(2^8)上执行加法
int gf256_add(int a, int b) {
    return a ^ b;
}

// 函数：在GF(2^8)上执行乘法
int gf256_mul(int a, int b) {
    int tmp = 0;
    const int mod = 0x11B;  // 不可约多项式 x^8 + x^4 + x^3 + x + 1，用十六进制表示

    // 乘法操作：对b的每一位进行检查并相应地将a的移位结果异或到tmp中
    for (int i = 0; i < 8; ++i) {  // 只需要迭代8次，因为我们处理的是8位
        if ((b >> i) & 1) {  // 检查b的第i位是否为1
            tmp ^= a << i;  // 将a左移i位并异或到tmp
        }
    }

    // 模约简操作：确保结果不超过8位
    for (int i = 15; i >= 8; --i) {
        if ((tmp >> i) & 1) {  // 检查第i位是否为1
            tmp ^= mod << (i - 8);  // 将不可约多项式左移适当的位数并进行异或操作
        }
    }

    return tmp & 0xFF;  // 确保结果是一个字节大小
}


// 函数：执行指数运算
int gf256_exp(int a, int exp) {
    int result = 1;
    while (exp > 0) {
        if (exp & 1) {
            result = gf256_mul(result, a);  // 当exp的当前位为1时，乘以当前的a
        }
        a = gf256_mul(a, a);  // a自乘，计算下一个平方
        exp >>= 1;  // exp右移一位
    }
    return result;
}

// 函数：计算乘法逆元
int gf256_inv(int x) {
    // 计算x^(2^8 - 2) = x^254，根据费马小定理
    return gf256_exp(x, 254);
}


int gf256_div(int a, int b) {
    int inv_b = gf256_inv(b);
    return gf256_mul(a, inv_b);
}
