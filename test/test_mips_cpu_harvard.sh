#!/bin/bash
set -eou pipefail

SRC="$1"
#check if source directory is valid
if test -f "${SRC}/mips_cpu_harvard.v" ; then
    #check how many parameters passed
    if [ $# -eq 1 ]; then
        >&2 echo "Testing all instructions"
    elif [ $# -eq 2 ]; then
        INSTR="$2"
        ./test/test_one_instruction_harvard.sh ${SRC} ${INSTR}
    else
        >&2 echo "Incorrect number of arguments"
    fi
else
    >&2 echo "Invalid source directory"
fi
