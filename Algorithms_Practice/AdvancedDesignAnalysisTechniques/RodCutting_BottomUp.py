import random

LARGE_NEGATIVE = -1000000
def cut_rod_bottom_up(p,n):
    r = [LARGE_NEGATIVE for i in range(n+1)]
    # so, i means index of price table p
    # i denotes the inches we cut off of the rod..
    # correspondingly, shift left by one when accessing the price table
    # recall that the range function is as [), so n+1 will not be tested.
    r[0] = 0
    for j in range(1,n+1):
        q = LARGE_NEGATIVE
        for i in range(1,j+1):
            q = max(q,p[i-1] + r[j-i])
        r[j] = q
    return r[n-1]

# for lengths [1...10]
price_table = [1,5,8,9,10,17,17,20,24,30]
rod_lengths = [i for i in range(1,11)]

for rod in rod_lengths:
    print(cut_rod_bottom_up(price_table,rod))

# and we see that we get the same optimal revenue as in the text
