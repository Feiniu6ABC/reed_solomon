#include <stdio.h>
#include <string.h>
#include "galios_calc.cpp"

typedef unsigned char gf256;

#define N 255
#define K 239
#define T ((N-K)/2)  // 纠错能力 t = 8

void printArray(const gf256* arr, int size) {
    for (int i = 0; i < size; i++) {
        printf("%02x ", arr[i]);
    }
    printf("\n");
}

void riBM(const gf256* syndromes, gf256* lambda, gf256* omega) {
    gf256 lambda_curr[T+1] = {1}, lambda_prev[T+1] = {1};
    gf256 b_curr[T+1] = {1}, b_prev[T+1] = {1};
    gf256 delta_curr[2*T] = {0}, delta_prev[2*T] = {0};
    gf256 theta_curr[2*T] = {0}, theta_prev[2*T] = {0};
    gf256 gamma = 1;
    int k = 0;

    // Initialize delta and theta with syndromes
    memcpy(delta_prev, syndromes, 2*T);
    memcpy(theta_prev, syndromes, 2*T);

    // Main loop
    for (int r = 0; r < 2*T; r++) {
        // Step riBM.1
        for (int i = 0; i <= T; i++) {
            lambda_curr[i] = gf256_add(gf256_mul(gamma, lambda_prev[i]),
                                       gf256_mul(delta_prev[0], b_prev[i]));
        }

        for (int i = 0; i < 2*T-1; i++) {
            delta_curr[i] = gf256_add(gf256_mul(gamma, delta_prev[i+1]),
                                      gf256_mul(delta_prev[0], theta_prev[i]));
        }
        delta_curr[2*T-1] = 0;  // Set the last element to 0

        // Step riBM.2
        if (delta_prev[0] != 0 && k >= 0) {
            memcpy(b_curr, lambda_prev, (T+1) * sizeof(gf256));
            memcpy(theta_curr, delta_prev + 1, (2*T-1) * sizeof(gf256));
            gamma = delta_prev[0];
            k = -k - 1;
        } else {
            for (int i = T; i > 0; i--) {
                b_curr[i] = b_prev[i-1];
            }
            b_curr[0] = 0;
            memcpy(theta_curr, theta_prev, 2*T * sizeof(gf256));
            k = k + 1;
        }

        // Swap current and previous
        memcpy(lambda_prev, lambda_curr, (T+1) * sizeof(gf256));
        memcpy(b_prev, b_curr, (T+1) * sizeof(gf256));
        memcpy(delta_prev, delta_curr, 2*T * sizeof(gf256));
        memcpy(theta_prev, theta_curr, 2*T * sizeof(gf256));
    }

    // Copy final results
    memcpy(lambda, lambda_prev, (T+1) * sizeof(gf256));
    memcpy(omega, delta_prev, T * sizeof(gf256));
}

int main() {
    //gf256 syndromes[2*T] = {1, 2, 4, 8, 16, 32, 64, 128, 2, 2, 4, 8, 7, 32, 64, 128};
    //gf256 syndromes[2*T] = {1, 2, 4, 8, 16, 32, 64, 128, 1, 2, 4, 8, 16, 32, 64, 128};
    gf256 syndromes[2*T] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1};
    gf256 lambda[T+1] = {0};
    gf256 omega[T] = {0};
    
    riBM(syndromes, lambda, omega);
    
    printf("Error Locator Polynomial (lambda): ");
    printArray(lambda, T+1);
    
    printf("Error Evaluator Polynomial (omega): ");
    printArray(omega, T);
    
    return 0;
}
