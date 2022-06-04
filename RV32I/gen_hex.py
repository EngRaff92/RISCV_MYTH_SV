## Random Hex Generation File ##

## Import Library
import random
import sys

def open_file():
    ## Write - will create a file if the specified file does not exist
    global f
    f = open("mem_instr.hex","w")

def close_file():
    f.close()

def gen_number(len):
    rn = hex(random.randint(0,pow(2,len)))
    nrn = rn.strip("0x")
    f.write(f"{nrn}\n")

def main():
    #print("This is the name of the program:", sys.argv[0])
    #print("Argument List:", str(sys.argv))
    params = sys.argv[1:]
    if params[0] == '0':
        print("Instruction Length cannot be 0")    
        sys.exit()
    if params[1] == '0':
        print("Memory Dimension cannot be 0")    
        sys.exit()
    print("Hex Value Generation")
    open_file()
    for i in range(int(params[1])):
        gen_number(int(params[0]))
    close_file()
    print("Hex Value Generated in file mem_instr.hex")

if __name__ == "__main__":
    main()

