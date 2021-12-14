#!/bin/bash
set -eou pipefail

python3 utils/assembler.py test/testcase/ test/bin/ test/ref/ -v

Tests="test/testcase"
Folder="$1"
Instruction="${2:-all}"
if [[ ${Instruction} == "all" ]]; then
    for Test in ${Tests}/*;
    do
        Test_ID="$(basename -- ${Test})"
        Test_ID=${Test_ID//".asm.txt"/}
        ./test/test_one_instruction.sh ${Folder} ${Test_ID}
    done
else
    for Test in ${Tests}/${Instruction}*;
    do
        Test_ID="$(basename -- ${Test})"
        Test_ID=${Test_ID//".asm.txt"/}
        ./test/test_one_instruction.sh ${Folder} ${Test_ID}
    done
fi