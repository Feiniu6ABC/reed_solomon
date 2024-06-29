//implement of berlekamp_massey algorithm in real number field

#include <cstdio>
#include <cmath>
#include <vector>
#include <iostream>

using namespace std;

typedef double ld; 
typedef vector<ld> vld; 

const int MAXN = 2333;
const double EPS = 1e-7;

int n, pn = 0, fail[MAXN];

ld x[MAXN], delta[MAXN];

vld prev_poly;
vld best_poly;

void printVector(const std::vector<double>& vec) {
    for (const double& value : vec) {
        std::cout << value << " ";
    }
    std::cout << std::endl; 
}


int main() {
    // input syndrome equation
    //ld initial_values[] = {2, 4, 8, 16, 32, 64, 128, 256, 512, 2, 4, 8, 16, 32, 64, 128, 256, 512};
    
    ld initial_values[] = {1,2,4,9,20,40,90};
  
    n = sizeof(initial_values) / sizeof(initial_values[0]);

    for (int i = 1; i <= n; i++) {
        x[i] = initial_values[i - 1];
    }

    int best = 0; //index of the shortest r
    for (int i = 1; i <= n; i++) {
        // calculate discrepency
        ld dt = -x[i];

        cout <<"value in current array : ";
        for (int i=0; i<prev_poly.size(); i++){
            cout <<prev_poly[i]<<" ";
        }

        for (size_t j = 0; j < prev_poly.size(); j++) {
            dt += x[i - j - 1] * prev_poly[j];
        }
        delta[i] = dt; // store discrepency of everystep

        cout<<"fabs dt is "<<fabs(dt)<<endl;
        if (fabs(dt) <= EPS) continue;                                           // next loop if close enough to 0

        fail[pn] = i; 
        if (!pn) {
            
            pn++;
            prev_poly.resize(i);
            //best_poly = prev_poly;
            cout<<"pn is "<<pn<<endl;
            continue;
        }

        vld &ls = best_poly;
        ld k = -dt / delta[fail[best]]; 
        cout <<"best is :";
        printVector(best_poly);

        cout<<"k is "<<k<<endl;

        vld cur(i - fail[best] - 1, 0); 
        cur.push_back(-k); 
        cout<<"cur0 is: ";
        printVector(cur);
        for (size_t j = 0; j < ls.size(); j++) {
            cur.push_back(ls[j] * k);                                             //push back old poly*k
        }
        cout<<"cur1 is: ";
        printVector(cur);
        if (cur.size() < prev_poly.size()) {
            cur.resize(prev_poly.size(), 0);                                      
        }
        for (size_t j = 0; j < prev_poly.size(); j++) {
            cur[j] += prev_poly[j];                                               
        }
        if (i - fail[best] + (int)best_poly.size() >= (int)prev_poly.size()) {
            best = pn;                                                             //update best index
            cout<<"best in is:"<<best<<endl;
            best_poly = prev_poly;
        }
        prev_poly = cur; 
        ++pn;
    }

    for (size_t g = 0; g < prev_poly.size(); g++) {
        cout << prev_poly[g] << " ";
    }

    cout << endl;

    return 0;
}
