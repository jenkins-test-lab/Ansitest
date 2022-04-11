import os
import sys
 
#for k, v in os.environ.items():
    #print(f'{k}={v}')
def tokenreplace(argv):

    filename = argv[1]
    print(argv)
    print(filename)
    with open(filename, 'r') as file :
        filedata = file.read()

    for k, v in os.environ.items():
        filedata = filedata.replace("@{" + k + "}", v)

    with open(filename, 'w') as file:
        file.write(filedata)

if __name__ == "__main__":
    tokenreplace(sys.argv)
