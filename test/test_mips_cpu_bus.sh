#!/bin/bash
set -eou pipefail

chmod u+x test/test_all_instructions_bus.sh
chmod u+x test/test_one_instruction_bus.sh
rm -f utils/assembler
g++ utils/assemble.cpp -o utils/assembler

SRC="$1"
#check if source directory is valid
if test -f "${SRC}/mips_cpu_bus.v" ; then
    #check how many input passed
    if [ $# -eq 1 ]; then
        #if only source directory provided, test all instructions
        ./test/test_all_instructions_bus.sh ${SRC}
    elif [ $# -eq 2 ]; then
        #if instruction given test only that inustruction
        INSTR="$2"
        ./test/test_one_instruction_bus.sh ${SRC} ${INSTR}
    else
        >&2 echo "Incorrect number of arguments"
    fi
else
    >&2 echo "Invalid source directory"
fi
