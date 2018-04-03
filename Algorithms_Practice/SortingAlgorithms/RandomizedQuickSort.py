import random
import time

def partition(data,left,right):
    x = data[right]
    i = left - 1
    for j in range(left,right):
        if data[j] <= x:
            i += 1
            data[i], data[j] = data[j], data[i]
    data[right], data[i+1] = data[i+1], data[right]
    return i+1

def randomizedPartition(data,left,right):
    # this randomization scheme will never result in 'right' being randomly chosen,
    # which is ok, because 'right' is our default pivot.
    randomIndex = int(random.random() * (right-left) + left)
    data[right], data[randomIndex] = data[randomIndex], data[right]
    return partition(data,left,right)

def quickSort(data,left=0,right=None):
    if (right is None):
        right = len(data) - 1
    if (left < right):
        # nominally the pivot
        middle = randomizedPartition(data,left,right)
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
    nWorstCase = 5000
    # array of our number of integers to sort
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
        # we can see the O(n^2) appear even for as few as 160 integers to be sorted
        print("{:<8d} items took {:>16.8f} seconds".format(n[i],end-start))
    # end
