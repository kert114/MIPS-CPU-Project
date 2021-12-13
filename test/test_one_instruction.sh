#!/bin/bash

set -eou pipefail
cd ..

#no variant as we are only testing bus
Folder="$1"

INSTR="$2"

CASES="test/testcase/${INSTR}*.asm.txt" #multiple testcase files per instr

>&2 echo "Testing MIPS_BUS using test-case ${INSTR}" #based on MU0 .sh

>&2 echo "2 - Compiling test-bench"

#CHECK OUT MU0 - should just be a iverilog command****

>&2 echo "3 - Running test-bench"

iverilog -Wall -g 2012 \
	-s mips_cpu_bus_tb test/mips_cpu_bus_tb_mem.v test/mips_cpu_bus_tb.v ${Folder}/mips_cpu_.v \
	-P mips_cpu_bus_tb.RAM_FILE=\"test/bin/${INSTR}.hex.txt\" \
	-o test/sim/${INSTR}

set +e #disables automatic script failure if command fails
#run test and store output to .stdout file

test/testcase/${INSTR} > test/output/${INSTR}.stdout
#not sure what to do with the .vcd file
RESULT=$?

set -e

if [[ "${RESULT}" -ne 0 ]] ; then
	echo "${INSTR}, Fail"
	exit
fi
>&2 echo "4 - Outputting final v0 value"
PATTERN="MIPS v0:" #depends on tb.v outputs
NOTHING=""

set +e

grep "${PATTERN}" test/testcase/${INSTR}/${TESTNAME}.stdout > test/testcase/${INSTR}/${TESTNAME}.out-lines
sed -e "s/${PATTERN}/${NOTHING}/g" test/testcase/${INSTR}/${TESTNAME}.out-lines > test/testcase/${INSTR}/${TESTNAME}.out
set -e #i think this would need to be redone depending on what out tb.v is
>&2 echo "5 - Comparing output"

set +e

diff -w test/testcase/${INSTR}/${TESTNAME}.out test/testacses/${INSTR}/${TESTNAME}.ref
RESULT=$?

set -e

if [[ "${RESULT}" -ne 0 && "$var" != "$fail" ]] ; then
	echo "${TESTNAME} ${INSTR} Fail - Mismatch reference" 
else
	echo "${TESTNAME} ${INSTR} Pass" 
fi

#I have NO CLUE what I'm doing but this is a start I guess...






