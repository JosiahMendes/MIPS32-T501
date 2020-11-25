#!/bin/bash
set -eou pipefail

SRC="$1"
INSTR="$2"

#check if testcases for instruction exist
if test -d "test/testcases/${INSTR}" ; then
    #loop through every testcases available
    TESTCASES="test/testcases/${INSTR}/*.v"
    for i in ${TESTCASES} ; do
        TESTNAME=$(basename ${i} .v)
        >&2 echo "${TESTNAME} ${INSTR}"
    done
else
    >&2 echo "Invalid instruction"
fi
