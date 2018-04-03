import random

# python implementation of Ch. 15 of Cormen textbook - top down recursive Rod Cut algorithm
# recursive top-down algorithm:
def cut_rod_recursive(p,n):
    if n <= 0:
        return 0
    q = -10000
    # so, i means index of price table p
    # i denotes the inches we cut off of the rod..
    # correspondingly, shift left by one when accessing the price table
    # recall that the range function is as [), so n+1 will not be tested.
    for i in range(1,n+1):
        q = max(q,p[i-1] + cut_rod_recursive(p,n-i))
    return q

# for lengths [1...10]
price_table = [1,5,8,9,10,17,17,20,24,30]
rod_lengths = [i for i in range(1,11)]

for rod in rod_lengths:
    print(cut_rod_recursive(price_table,rod))

# and we see that we get the same optimal revenue as in the text
