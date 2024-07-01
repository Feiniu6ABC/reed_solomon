#include <cstdio>
#include <cmath>
#include <vector>
#include <iostream>

using namespace std;

typedef double ld;
typedef vector<ld> vld;

const int MAXN = 2333;
const double EPS = 1e-7;

ld x[MAXN], delta[MAXN];
int fail[MAXN]; // `fail` should be of type int

void printVector(const vld& vec) {
    for (const ld& value : vec) {
        cout << value << " ";
    }
    cout << endl;
}

vld berlekampMassey(const ld* initial_values, int n) {
    vld prev_poly, best_poly;
    
    for (int i = 1; i <= n; i++) {
        x[i] = initial_values[i - 1];
    }
    
    int best = 0, pn = 0;
    
    for (int i = 1; i <= n; i++) {
        ld dt = -x[i];
        for (size_t j = 0; j < prev_poly.size(); j++) {
            dt += x[i - j - 1] * prev_poly[j];
        }
        delta[i] = dt;
        
        if (fabs(dt) <= EPS) continue;
        
        fail[pn] = i;
        if (!pn) {
            pn++;
            prev_poly.resize(i);
            continue;
        }
        
        vld &ls = best_poly;
        ld k = -dt / delta[fail[best]]; // Correct the subscript
        
        vld cur(i - fail[best] - 1, 0);
        cur.push_back(-k);
        
        for (size_t j = 0; j < ls.size(); j++) {
            cur.push_back(ls[j] * k);
        }
        
        if (cur.size() < prev_poly.size()) {
            cur.resize(prev_poly.size(), 0);
        }
        
        for (size_t j = 0; j < prev_poly.size(); j++) {
            cur[j] += prev_poly[j];
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
    //ld initial_values[] = {1,2,4,9,20,40,90};
    ld initial_values[] = {2, 4, 8, 16, 32, 64, 128, 256, 512, 2, 4, 8, 16, 32, 64, 128, 256, 512};
    int n = sizeof(initial_values) / sizeof(initial_values[0]);
    
    vld coeffs = berlekampMassey(initial_values, n);
    printVector(coeffs);
    
    return 0;
}
