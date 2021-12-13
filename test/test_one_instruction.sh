#!/bin/bash

set -eou pipefail

#no variant as we are only testing bus
Folder="$1"

INSTR="$2"

CASES="test/testcase/${INSTR}" #multiple testcase files per instr

>&2 echo "Testing MIPS_BUS using test-case ${INSTR}" #based on MU0 .sh

>&2 echo "2 - Compiling test-bench"

#CHECK OUT MU0 - should just be a iverilog command****

#iverilog -Wall -g 2012 \
#	-s mips_cpu_bus_tb \
#	-P mips_cpu_bus_tb.RAM_FILE=\"test/bin/${INSTR}.hex.txt\" \
#	-o test/sim/${INSTR} \
#	test/mips_cpu_bus_tb_mem.v test/mips_cpu_bus_tb.v ${Folder}/mips_cpu_*.v

iverilog -Wall -g 2012 \
    -s mips_cpu_bus_tb test/mips_cpu_bus_tb_mem.v test/mips_cpu_bus_tb.v ${Folder}/mips_cpu_*.v \
    -P mips_cpu_bus_tb.RAM_FILE=\"test/bin/${INSTR}.hex.txt\" \
    -o test/sim/${INSTR}


>&2 echo "3 - Running test-bench"

set +e #disables automatic script failure if command fails
#run test and store output to .stdout file

test/sim/${INSTR} > test/output/${INSTR}.stdout
#not sure what to do with the .vcd file
RESULT=$?

>&2 echo "${RESULT}"

set -e

if [[ "${RESULT}" -ne 0 ]] ; then
	echo "${INSTR}, Fail"
	exit
fi



>&2 echo "4 - Outputting final v0 value"

set +e



set -e #i think this would need to be redone depending on what out tb.v is
>&2 echo "5 - Comparing output"

set +e

diff -q <(sort -u test/ref/${INSTR}.txt) \
		<(grep -Fxf test/output/${INSTR}.stdout test/ref/${INSTR}.txt | sort -u) \
		> test/output/${INSTR}Diff

RESULT=$?
>&2 echo "${RESULT}"

set -e

if [[ "${RESULT}" -ne 0 ]] ; then
	echo "${INSTR} Fail - Mismatch reference" 
else
	echo "${INSTR} Pass" 
fi