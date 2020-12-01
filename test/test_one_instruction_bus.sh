#!/bin/bash
set -eou pipefail

SRC="$1"
INSTR="$2"

#check if testcases for instruction exist
if test -d "test/testcases/${INSTR}" ; then
    #loop through every testcases available
    TESTCASES="test/testcases/${INSTR}/*.v"
    for i in ${TESTCASES} ; do
        #get the testnames
        TESTNAME=$(basename ${i} _tb.v)

        #compile the testbench for this testname
        iverilog -g 2012 -Wall\
        -s test/mips_cpu_bus_tb \
        -P${TESTNAME}_tb.RAM_INIT_FILE=\"test/testcases/${INSTR}/${TESTNAME}_ram_init.txt\" \
        -o test/testcases/${INSTR}/${TESTNAME} \
        ${SRC}/mips_cpu_bus_*.v test/testcases/${INSTR}/${TESTNAME}_tb.v

        set +e
        #run this testname
        test/testcases/${INSTR}/${TESTNAME}

        #capture the exit code of the testbench in a variable
        RESULT=$?
        set -e

        #if it returned a failure code
        if [[ "${RESULT}" -ne 0 ]] ; then
            echo "${TESTNAME} ${INSTR} Fail"
        else
            echo "${TESTNAME} ${INSTR} Pass"
        fi
    done
else
    >&2 echo "Invalid instruction"
fi
