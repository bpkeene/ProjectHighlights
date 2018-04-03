import random
import time


def insertionSort(data):

    # this is fairly clearly n^2, because we are looping over ever larger sub-arrays
    # predicated on [0...j) being sorted, then putting [j] in the proper place within that subarray
    for j in range(0,len(data),1):
        key = data[j]
        i = j - 1
        while (i > -1 and data[i] > key):
            data[i+1] = data[i]
            i = i - 1
        data[i+1] = key
    return data

def checkResults(data):

    for i in range(0,len(data)-2,1):
        if data[i+1] < data[i]:
            print("ERROR: {} is less than {} at indices {} {}".format(data[i+1],data[i],i+1,i))
            exit()
    #print("Array with {} items was found to be correct!".format(len(data)))
    return


# array of our number of integers to sort
n = [2**n for n in range(15)]
toSort = []

# generate the data - randomly ordered integers [0, 100]
# -- note that this means we can have repeats!
for index, item in enumerate(n):
    numbersToSort = [int(100*random.random()) for i in range(item)]
    toSort.append(numbersToSort)

for i in range(len(n)):
    start = time.time()
    insertionSort(toSort[i])
    end = time.time()
    checkResults(toSort[i])
    # we can see the O(n^2) appear even for as few as 160 integers to be sorted
    print("{:<8d} items took {:>16.8f} seconds".format(n[i],end-start))
