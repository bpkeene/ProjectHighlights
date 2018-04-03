import random
import time

def countingSort(data):
    # we already know that the lower bound is zero, for this input
    k = int(len(data))+5

    C = [0 for i in range(k+1)]

    for j in range(len(data)):
        C[data[j]] += 1

    for i in range(1,k):
        C[i] += C[i-1]

    B = [None for i in range(len(data))]

    for j in range(len(data)-1,-1,-1):
        B[C[data[j]]-1] = data[j]
        C[data[j]] -= 1

    return B


def checkResults(data):
    for i in range(0,len(data)-2,1):
        if data[i+1] < data[i]:
            print("ERROR: {} is less than {} at indices {} {}".format(data[i+1],data[i],i+1,i))
            print(data)
            exit()

    for i in range(0,len(data)-1):
        if data[i] is None:
            print("ERROR: None type value found!")
            exit()

    return


# array of our number of integers to sort
n = [2**n for n in range(1,18)] + [100000]
toSort = []
toCompare = []
# generate the data - randomly ordered integers [0, 10000]
# -- note that this means we can have repeats!
for index, item in enumerate(n):
    # here we modify s.t. the input is suitable for countingSort, by
    # restricting the inputs to be s.t. k = O(n), k = np.amax(n) - np.amin(n)
    numbersToSort = [int(item*random.random()) for i in range(item)]
    toSort.append(numbersToSort)

for i in range(len(n)):
    start = time.time()
    toSort[i] = countingSort(toSort[i])
    end = time.time()
    checkResults(toSort[i])
    # we can see the O(n^2) appear even for as few as 160 integers to be sorted
    print("{:<8d} items took {:>16.8f} seconds".format(n[i],end-start))
# end
