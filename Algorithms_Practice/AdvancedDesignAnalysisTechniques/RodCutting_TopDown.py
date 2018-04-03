import random

def memoized_cut_rod_aux(p,n,r):
    if n < 1:
        q = 0
        return q
    q = -1000000
    if r[n-1] > 0:
        return r[n-1]
    else:
        q = -1000000
        for i in range(1,n+1):
            q = max(q,p[i-1] + memoized_cut_rod_aux(p,n-i,r))
    r[n-1] = q
    return q


def cut_rod_top_down(p,n):
    r = [-1000000 for i in range(n)]
    # so, i means index of price table p
    # i denotes the inches we cut off of the rod..
    # correspondingly, shift left by one when accessing the price table
    # recall that the range function is as [), so n+1 will not be tested.
    return memoized_cut_rod_aux(p,n,r)

# for lengths [1...10]
price_table = [1,5,8,9,10,17,17,20,24,30]
rod_lengths = [i for i in range(1,11)]

for rod in rod_lengths:
    print(cut_rod_top_down(price_table,rod))

# and we see that we get the same optimal revenue as in the text
