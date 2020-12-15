# Approach to Testing

## Writing Testcases

Create a file `instr{i}.asm` where `i` is the testcase number, and write assembly code, following guidelines in [this document](https://www.cs.cornell.edu/courses/cs3410/2008fa/MIPS_Vol2.pdf).

#### Instructions

- Load/Store instructions -> `lh $dest offset($base)`
- Arithmetic/Logical Instructions (Register) -> `addu $dest $src1 $src2`
- Arithmetic/Logical Instructions (Immediate) -> `addu $dest $src1 immediate`
- Shifts -> `sll $dest $src sa`

FIXED! Specifiy hexadecimal by adding 0x to number, otherwise treated as decimal!

#### Loading Data
If you need to load data to another place in memory it should look like this. 
```
instr1
instr2
instr3
data:
address : data1
address : data2
address : data3
...
```
Each address matches to a byte, each address can hold a maximum of 2 hex digits, if storing only 1 digit, pad with zero. 
Valid addresses start at reset vector and end at memory size+reset vector. 

## Testing

Create `.ref` file with expected output of v0 with full 8 hex bits. 

Compile `assemble.cpp` into `assemble` in `utils` folder. 

Run `test_one_instruction_bus.sh rtl {instruction_name}`. 

## Debugging

If the test fails while runnning the cpu -> you can see the output of the cpu in `instr{i}.stdout`

If you want to see the hex version of the assembled code without the zeros run -> `./assembler filename hex`
If you wamt to see the binary version of the assembled code without the zeros run -> `./assembler filename bin`
if you want to see the little endian hex version of the assembled code run without zeros run -> `./assembler filename hex littleEndian`
if you want to see the little endian hex version of the assembled code run with zeros run-> `./assembler filename hex littleEndian 1`


