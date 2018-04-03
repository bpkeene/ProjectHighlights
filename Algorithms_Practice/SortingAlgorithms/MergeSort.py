import random
import time
import copy
import math
import collections
import itertools

def merge(data,p,q,r):
    '''
        Given an array of data, [p <= q < r]...
        We assume that the subarrays [p...q+1) [q+1...r) are in sorted order
        and we must subsequently merge them in to an array [p...r)
        -- the double ended queue has fast pops on the left, regular lists do not
    '''

    left = collections.deque(data[p:q])
    right = collections.deque(data[q:r])
    subsequence = []
    while (left or right):
        if left and right:
            if left[0] <= right[0]:
                subsequence.append(left[0])
                left.popleft()
            else:
                subsequence.append(right[0])
                right.popleft()
        elif left:
            subsequence.append(left[0])
            left.popleft()
        else:
            subsequence.append(right[0])
            right.popleft()

    # above code is ~0.54s for 100K elements
    return subsequence

def mergeSort(data,p,r):
    if p+1 < r:
        q = int((p + r) /  2.0)
        mergeSort(data,p,q)
        mergeSort(data,q,r)
        data[p:r] = merge(data,p,q,r)
    return

def checkResults(data):

    for i in range(0,len(data)-2,1):
        if data[i+1] < data[i]:
            print("ERROR: {} is less than {} at indices {} {}".format(data[i+1],data[i],i+1,i))
            exit()
    #print("Array with {} items was found to be correct!".format(len(data)))
    return


if __name__ == '__main__':
    # array of our number of integers to sort
    n = [2**n for n in range(1,18)] + [100000]
    toSort = []
    toCompare = []
    # generate the data - randomly ordered integers [0, 100]
    # -- note that this means we can have repeats!
    for index, item in enumerate(n):
        numbersToSort = [int(100*random.random()) for i in range(item)]
        toSort.append(numbersToSort)
        toCompare.append(copy.deepcopy(numbersToSort))

    for i in range(len(n)):
        start = time.time()
        mergeSort(toSort[i],0,len(toSort[i]))
        end = time.time()
        checkResults(toSort[i])
        # we can see the O(n^2) appear even for as few as 160 integers to be sorted
        print("{:<8d} items took {:>16.8f} seconds".format(n[i],end-start))


# end
