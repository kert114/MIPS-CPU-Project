#!/bin/bash

set -eou pipefail 

python3 utils/assembler.py test/testcase/ test/testcase/bin/ -v