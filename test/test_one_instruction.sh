#!/bin/bash
set -eou pipefail
Folder="$1"
INSTR="$2"
rm -rf test/output/${INSTR}* #removes any previous output files so no false positives of untested ones
CASES="test/testcase/${INSTR}" #multiple testcase files per instr
#>&2 echo "Testing MIPS_BUS using test-case ${INSTR}" #based on MU0 .sh
#>&2 echo "2 - Compiling test-bench"
#CHECK OUT MU0 - should just be a iverilog command****
iverilog -Wall -g 2012 \
    -s mips_cpu_bus_tb test/mips_cpu_bus_tb_mem.v test/mips_cpu_bus_tb.v ${Folder}/mips_cpu_*.v \
    -P mips_cpu_bus_tb.RAM_FILE=\"test/bin/${INSTR}.hex.txt\" \
    -o test/sim/${INSTR}
#>&2 echo "3 - Running test-bench"
set +e #disables automatic script failure if command fails
#run test and store output to .stdout file
test/sim/${INSTR} > test/output/${INSTR}.stdout
RESULT=$?
#>&2 echo "${RESULT}"
set -e
if [[ "${RESULT}" -ne 0 ]] ; then
	echo "${INSTR}, Fail - Clocked out - program didn't stop"
	exit
fi
#>&2 echo "4 - Outputting final v0 value"
set +e
diff -q <(sort -u test/ref/${INSTR}.txt) \
		<(grep -Fxf test/output/${INSTR}.stdout test/ref/${INSTR}.txt | sort -u) \
		> test/output/${INSTR}Diff
#>&2 echo "5 - Comparing output"
RESULT=$?
#>&2 echo "${RESULT}"
set -e
if [[ "${RESULT}" -ne 0 ]] ; then
	echo "${INSTR} Fail - Mismatch reference" 
else
	echo "${INSTR} Pass" 
fi