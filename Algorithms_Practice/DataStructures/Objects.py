

def popItem(data, datum):
    # data.pop returns the popped item... so we need to call it first, then return..
    data.pop(data.index(datum))
    # now return the modified list
    return data


class MyObject:
    def __init__(self,data_):
        self.data = data_

    def __iadd__(self,other):
        self.data += other.getData()

    def getData(self):
        return self.data

    def __repr__(self):
        return ''.join(map(str,list(["Object instance: ", str(self.data)])))

a = MyObject(5)
b = MyObject(4)
c = MyObject(12)
d = MyObject(14)
objs = [a,b,c,d]
for obj in objs:
    print(obj)

a += b
newList = popItem(objs,b)
print("Completed the addition...")
for obj in newList:
    print(obj)
