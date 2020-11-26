#!/bin/bash
set -eou pipefail

SRC="$1"
#get a list of all the instructions
INSTRUCTIONS="test/testcases/*"

#loop through every instruction and test them individually
for i in ${INSTRUCTIONS} ; do
    INSTR=$(basename ${i})
    ./test/test_one_instruction_harvard.sh ${SRC} ${INSTR}
done
