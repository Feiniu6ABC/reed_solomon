#include <stdio.h>
#include <vector>

// Include the functions from the provided code
#include "galios_calc.cpp"

typedef int gf256; // Use gf256 to represent elements in GF(2^8)
typedef std::vector<gf256> vgf256;

void printVector(const vgf256& vec) {
    for (const gf256& value : vec) {
        printf("%X ", value);
    }
    printf("\n");
}

vgf256 berlekampMassey(const gf256* initial_values_ptr, int n) {
    // Create a local modifiable copy of initial_values
    std::vector<gf256> initial_values(initial_values_ptr, initial_values_ptr + n);

    vgf256 prev_poly, best_poly;
    gf256 delta[2333];
    int fail[2333], i, j;

    int best = 0, pn = 0;

    for (i = 1; i <= n; i++) {
        gf256 dt = initial_values[i];  // Directly use the local copy
        
        for (j = 0; j < prev_poly.size(); j++) {
            dt = gf256_add(dt, gf256_mul(prev_poly[j], initial_values[i - j - 1]));
        }
        delta[i] = dt;
        
        if (dt == 0) continue;
        
        fail[pn] = i;
        if (!pn) {
            pn++;
            prev_poly.resize(i);
            continue;
        }
        
        vgf256& ls = best_poly;
        gf256 k = gf256_div(dt, delta[fail[best]]);
        
        vgf256 cur(i - fail[best] - 1, 0);
        cur.push_back(k);
        
        for (j = 0; j < ls.size(); j++) {
            cur.push_back(gf256_mul(ls[j], k));
        }
        
        if (cur.size() < prev_poly.size()) {
            cur.resize(prev_poly.size(), 0);
        }
        
        for (j = 0; j < prev_poly.size(); j++) {
            cur[j] = gf256_add(cur[j], prev_poly[j]);
        }
        
        if (i - fail[best] + (int)ls.size() >= (int)prev_poly.size()) {
            best = pn;
            best_poly = prev_poly;
        }
        
        prev_poly = cur;
        ++pn;
    }
    return prev_poly;
}

int main() {
    gf256 initial_values[] = {2, 4, 8, 16, 32, 64, 128, 2, 4, 8, 16, 32, 64, 128};
    int n = sizeof(initial_values) / sizeof(initial_values[0]);
    
    vgf256 coeffs = berlekampMassey(initial_values, n);
    printVector(coeffs);
    
    return 0;
}
