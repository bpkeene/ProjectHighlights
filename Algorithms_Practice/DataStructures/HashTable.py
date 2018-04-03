# so, naturally, we could just use python's dict...
# but the point of this exercise is to do it ourselves.
# TASK: implement a hash table using python lists
import random

def customHash(value,a,b,p,m):
    return ((a*value + b) % p) % m

def insertValue(table,key,value):
    if table[key] is not None:
        if isinstance(table[key],list) and not isinstance(table[key],int):
            slot = table[key]
            slot.append(value)
            table[key] = slot
            return
        else:
            slot = [table[key]]
            slot.append(value)
            table[key] = slot
    else:
        table[key] = value

def removeValueByKey(table,key):
    pass

# a and b - distinct integer keys for hashing function, chosen at run time
a = int(random.random() * 256)
b = int(random.random() * 256)

# just in case we are unlucky..
while (b == a):
    b = int(random.random() * 256)

# prime number to use with hashing, p > m
p = 1031
# m, size of our hash table
m = 100
# initialize the table
hashTable = [None for i in range(m)]

dataEntries = [i for i in range(102)]

for value in dataEntries:
    key = customHash(value,a,b,p,m)
    insertValue(hashTable,key,value)

for index, item in enumerate(hashTable):
    print(index, item)

