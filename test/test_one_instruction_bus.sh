#!/bin/bash
set -eou pipefail

SRC="$1"
INSTR="$2"

#check if testcases for instruction exist
if test -d "test/testcases/${INSTR}" ; then
    #loop through every testcases available
    TESTCASES="test/testcases/${INSTR}/*.asm"
    for i in ${TESTCASES} ; do

        #get the testnames
        TESTNAME=$(basename ${i} .asm)


        >&2 echo "  1 - Assembling input file"
        utils/assembler test/testcases/${INSTR}/${TESTNAME}.asm hex littleEndian 1 > test/testcases/${INSTR}/${TESTNAME}_MEM.txt

        >&2 echo "  2 - Compiling test-bench"
        #compile the testbench for this testname
        if [ -d "${SRC}/mips_cpu" ]; then
            iverilog -g 2012 \
                -s mips_cpu_bus_tb \
                -P mips_cpu_bus_tb.RAM_INIT_FILE=\"test/testcases/${INSTR}/${TESTNAME}_MEM.txt\" \
                -o test/testcases/${INSTR}/${TESTNAME} \
                ${SRC}/mips_cpu_*.v ${SRC}/mips_cpu/*.v test/mips_cpu_bus_tb.v 
        else
            iverilog -g 2012 \
                -s mips_cpu_bus_tb \
                -P mips_cpu_bus_tb.RAM_INIT_FILE=\"test/testcases/${INSTR}/${TESTNAME}_MEM.txt\" \
                -o test/testcases/${INSTR}/${TESTNAME} \
                ${SRC}/mips_cpu_*.v test/mips_cpu_bus_tb.v 
        fi


        >&2 echo "  3 - Running test-bench"
        set +e
        #run this testname
        test/testcases/${INSTR}/${TESTNAME} > test/testcases/${INSTR}/${TESTNAME}.stdout

        #capture the exit code of the testbench in a variable
        RESULT=$?
        set -e

        #if it returned a failure code
        if [[ "${RESULT}" -ne 0 ]] ; then
            echo "${TESTNAME} ${INSTR} Fail"
            #rm test/testcases/${INSTR}/${TESTNAME}.stdout
            rm test/testcases/${INSTR}/${TESTNAME}
            exit
        fi

        >&2 echo "  4 - Extracting final V0 value"

        PATTERN="TB : Register V0 has "
        NOTHING=""

        set +e
        grep "${PATTERN}" test/testcases/${INSTR}/${TESTNAME}.stdout > test/testcases/${INSTR}/${TESTNAME}.out-lines
        set -e

        sed -e "s/${PATTERN}/${NOTHING}/g" test/testcases/${INSTR}/${TESTNAME}.out-lines > test/testcases/${INSTR}/${TESTNAME}.out

        rm test/testcases/${INSTR}/${TESTNAME}.stdout
        rm test/testcases/${INSTR}/${TESTNAME}.out-lines

        >&2 echo "  5 - Comparing output"

        set +e
        diff -w test/testcases/${INSTR}/${TESTNAME}.out test/testcases/${INSTR}/${TESTNAME}.ref > /dev/null 2>&1
        RESULT=$?
        set -e

        if [[ "${RESULT}" -ne 0 ]] ; then
            echo "  ${TESTNAME} ${INSTR} Fail"
        else
            echo "  ${TESTNAME} ${INSTR} Pass"
        fi
        rm test/testcases/${INSTR}/${TESTNAME}
        rm test/testcases/${INSTR}/${TESTNAME}.out
    done
else
    >&2 echo "Invalid instruction"
fi
