import random
import time
import sys

# this is only utilized for the worst-case trial
sys.setrecursionlimit(10000)

# print(sys.getrecursionlimit())
# # above line prints the recursion depth permitted by default (= 1000)
def partition(data,left,right):
    x = data[right]
    # base case: left is 0, --> i = -1; right = 1
    i = left - 1
    # if data[0] <= data[1]:
    # we switch the data points
    for j in range(left,right):
        # if the far left data point is less than or equal to far right data point, exchange
        # data[i] with data[j]
        # so here, we are placing all elements with values l.e. x to the left of some arbitrary thing,
        # and then we exchange x with the final value not less than x
        # recursive sorting will solve the problem for all subarrays.
        if data[j] <= x:
            i += 1
            data[i], data[j] = data[j], data[i]

    # then, we have data[1] = data[1], after having switched the points...
    # at this point, data[1] <=  data[0]
    data[right], data[i+1] = data[i+1], data[right]
    return i+1

def quickSort(data,left=0,right=None):
    if (right is None):
        right = len(data) - 1
    if (left < right):
        # nominally the pivot
        middle = partition(data,left,right)
        # [p...q-1]
        quickSort(data,left,middle-1)
        # [q+1...r]
        quickSort(data,middle+1,right)


def checkResults(data):
    for i in range(0,len(data)-2,1):
        if data[i+1] < data[i]:
            print("ERROR: {} is less than {} at indices {} {}".format(data[i+1],data[i],i+1,i))
            print(data)
            exit()
    return


if __name__ == '__main__':

    # array of our number of integers to sort
    nWorstCase = 5000
    n = [2**n for n in range(1,18)] + [100000]
    toSort = []
    toCompare = []
    # generate the data - randomly ordered integers [0, 10000]
    # -- note that this means we can have repeats!
    for index, item in enumerate(n):
        numbersToSort = [int(10000*random.random()) for i in range(item)]
        toSort.append(numbersToSort)

    worstCase = []
    n.append(nWorstCase)
    for i in range(nWorstCase,0,-1):
        worstCase.append(int(i))

    toSort.append(worstCase)
    for i in range(len(n)):

        start = time.time()
        quickSort(toSort[i])
        end = time.time()
        checkResults(toSort[i])
        if n[i] < 100:
            print(toSort[i])
        # we can see the O(n^2) appear even for as few as 160 integers to be sorted
        print("{:<8d} items took {:>16.8f} seconds".format(n[i],end-start))
    # end
