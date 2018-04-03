import itertools

# so, here is a recursive solution
# we want a powerset (no repeated elements) -- so, constructing it as
# a binary tree
def makeFlat(listOfLists):
    for sublist in listOfLists:
        if isinstance(sublist,list) and not isinstance(sublist,(str)):
            yield from makeFlat(sublist)
        else:
            yield sublist

def createPowerSet(data,toplevel=False):
    if len(data) > 0:
        powerSet = [data]
        # we want the different combinations of sub sets from a set with n-1 elements
        combinations = itertools.combinations(data,len(data)-1)
        for combination in combinations:
            subSet = createPowerSet(combination)
            if subSet is not None:
                powerSet.append(subSet)
        if (toplevel):
            powerSet = list(set(makeFlat(powerSet)))
            toReturn = []
            for setItem in powerSet:
                setItem = ''.join([str(i) for i in setItem])
                toReturn.append(setItem)
            return sorted(toReturn)
        else:
            return powerSet

initialSet = 'abxyz'

finalSet = createPowerSet(initialSet,True)
for item in finalSet:
    print(item)
