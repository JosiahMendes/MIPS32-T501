#!/bin/bash
set -eou pipefail

SRC="$1"
#check if source directory is valid
if test -f "${SRC}/mips_cpu_harvard.v" ; then
    #check how many input passed
    if [ $# -eq 1 ]; then
        #if only source directory provided, test all instructions
        ./test/test_all_instructions_harvard.sh ${SRC}
    elif [ $# -eq 2 ]; then
        #if instruction given test only that inustruction
        INSTR="$2"
        ./test/test_one_instruction_harvard.sh ${SRC} ${INSTR}
    else
        >&2 echo "Incorrect number of arguments"
    fi
else
    >&2 echo "Invalid source directory"
fi
