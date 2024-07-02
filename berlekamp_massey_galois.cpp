#include <stdio.h>
#include <vector>
#include <algorithm>

#include "galios_calc.cpp"

typedef int gf256;
typedef std::vector<gf256> vgf256;

void printVector(const vgf256& vec) {
    for (const gf256& value : vec) {
        printf("%d ", value);
    }
    printf("\n");
}

vgf256 berlekampMassey(const gf256* initial_values_ptr, int n) {
    vgf256 C = {1}, B = {1};
    int L = 0, m = 1;
    gf256 b = 1;

    for (int N = 0; N < n; N++) {
        gf256 d = initial_values_ptr[N];
        for (int i = 1; i <= L; i++) {
            d = gf256_add(d, gf256_mul(C[i], initial_values_ptr[N-i]));
        }
        if (d == 0) {
            m++;
        } else {
            vgf256 T = C;
            C.resize(std::max(C.size(), B.size() + m), 0);
            gf256 coef = gf256_div(d, b);
            for (size_t i = 0; i < B.size(); i++) {
                C[i + m] = gf256_add(C[i + m], gf256_mul(coef, B[i]));
            }
            if (2 * L <= N) {
                L = N + 1 - L;
                B = T;
                b = d;
                m = 1;
            } else {
                m++;
            }
        }
    }

    // Remove leading zeros
    while (C.size() > 1 && C.back() == 0) {
        C.pop_back();
    }

    // Reverse the polynomial coefficients
    //std::reverse(C.begin(), C.end());

    return C;
}

int main() {
    gf256 initial_values[] = {2, 4, 8, 16, 32, 128, 128, 2, 4, 8, 16, 32, 64, 128};
    int n = sizeof(initial_values) / sizeof(initial_values[0]);
    
    vgf256 coeffs = berlekampMassey(initial_values, n);
    printVector(coeffs);
    
    return 0;
}
