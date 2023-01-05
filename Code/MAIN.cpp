/*
 * @Description: 
 * @Version: 
 * @Author: Tyrion Huu
 * @Date: 2022-11-30 15:02:32
 * @LastEditors: Tyrion Huu
 * @LastEditTime: 2022-11-30 20:53:41
 */
#include <iostream>

int FibonacciVariant(int N, int P, int Q)
{
    int F = 0;
    int F0 = 1;
    int F1 = 1;
    if(N == 0 || N == 1)
    {
        return 1;
    }
    for(; N > 1; N--)
    {
        F = F0 % P + F1 % Q;
        F0 = F1;
        F1 = F;
    }
    return F;
}

int main(void)
{
    int N = 0;
    int P = 0;
    int Q = 0;
    std::cin >> N >> P >> Q;
    std::cout << FibonacciVariant(N, P, Q) << std::endl;
    return 0;
}