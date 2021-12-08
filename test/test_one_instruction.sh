set -eou pipefail

#no variant as we are only testing bus
INSTR = "$1"

CASES = "test/testcases/${INSTR}/*.asm" #multiple testcases files per instr

for i in ${CASES}; do
	TESTNAME=$(basename ${i} .asm) #get name of individual test
	>&2 echo "Testing MIPS_BUS using test-case ${TESTNAME}" #based on MU0 .sh

	>&2 echo " 1 - Assembling input file"
	expected=$(< test/testcases/${INSTR}}/${TESTNAME}.ref) #expected output

	#CHECK OUT MU0 ASSEMBLER FOR MORE stuff to put here**********

	>& echo " 2 - Compiling test-bench"

	#CHECK OUT MU0 - should just be a iverilog command****

	>& echo " 3 - Running test-bench"
	set +e #don't know what this does but copied from MU0
	#run test and store output to .stdout file
	test/testcases/${INSTR}/${TESTNAME} > test/testcases/${INSTR}/${TESTNAME}.stdout
	#not sure what to do with the .vcd file
	RESULT=$?
	set -e

	if [[ "${RESULT}" -ne 0 ]] ; then
   		echo "  ${VARIANT}, ${TESTCASE}, Fail"
   		exit
	fi

	>& echo "4 - Outputting final v0 value"
	PATTERN="MIPS v0:" #depends on tb.v outputs
	NOTHING=""

	set +e
    grep "${PATTERN}" test/testcases/${INSTR}/${TESTNAME}.stdout > test/testcases/${INSTR}/${TESTNAME}.out-lines
    sed -e "s/${PATTERN}/${NOTHING}/g" test/testcases/${INSTR}/${TESTNAME}.out-lines > test/testcases/${INSTR}/${TESTNAME}.out
    set -e #i think this would need to be redone depending on what out tb.v is

    >& echo "5 - Comparing output"
    set +e
    diff -w test/testcases/${INSTR}/${TESTNAME}.out test/testacses/${INSTR}/${TESTNAME}.ref
    RESULT=$?
    set -e

    if [[ "${RESULT}" -ne 0 && "$var" != "$fail" ]] ; then
    	echo "${TESTNAME} ${INSTR} Fail - Mismatch reference" 
    else
    	echo "${TESTNAME} ${INSTR} Pass" 
    fi
done

#I have NO CLUE what I'm doing but this is a start I guess...






