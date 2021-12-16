#!/bin/bash
set -eou pipefail
Folder="$1"
Instr="$2"
rm -rf test/output/${Instr}* #removes any previous output files so no false positives of untested ones
Test_Type=$(awk 'NR==2' test/testcase/${Instr}.asm.txt)
Test_Comments=$(awk 'NR==3' test/testcase/${Instr}.asm.txt)
#CASES="test/testcase/${Instr}" #multiple testcase files per Instr
#>&2 echo "Testing MIPS_BUS using test-case ${Instr}" #based on MU0 .sh
#>&2 echo "2 - Compiling test-bench"
#CHECK OUT MU0 - should just be a iverilog command****
iverilog -Wall -g 2012 \
    -s mips_cpu_bus_tb test/mips_cpu_bus_tb_mem.v test/mips_cpu_bus_tb.v ${Folder}/mips_cpu_*.v \
    -P mips_cpu_bus_tb.RAM_FILE=\"test/bin/${Instr}.hex.txt\" \
    -o test/sim/${Instr}
#>&2 echo "3 - Running test-bench"
set +e #disables automatic script failure if command fails
#run test and store output to .stdout file
test/sim/${Instr} > test/output/${Instr}.stdout
RESULT=$?
#>&2 echo "${RESULT}"
set -e
if [[ "${RESULT}" -ne 0 ]] ; then
	echo "${Instr}, ${Test_Type}, Fail - Clocked out - program didn't stop - #${Test_Comments}"
	exit
fi
#>&2 echo "4 - Outputting final v0 value"
set +e
diff -q <(sort -u test/ref/${Instr}.txt) \
		<(grep -Fxf test/output/${Instr}.stdout test/ref/${Instr}.txt | sort -u) \
		> test/output/${Instr}Diff
#>&2 echo "5 - Comparing output"
RESULT=$?
#>&2 echo "${RESULT}"
set -e
if [[ "${RESULT}" -ne 0 ]] ; then
	echo "${Instr} Fail - Mismatch reference" 
else	
	#printf "$Test_Instr $Test_Type pass # $Test_Comments \n"
	echo "$Instr $Test_Type Pass #$Test_Comments"
fi

#if [[ "${RESULT}" -ne 0 ]] ; then
#	echo "${Instr} ${Test_Type} Fail - Mismatch reference #${Test_Comments}" 
#else
#	echo "${Instr} ${Test_Type} Pass #${Test_Comments}" 
#fi