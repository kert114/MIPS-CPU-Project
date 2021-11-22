# MIPS-CPU
Mips CPU for IAC coursework \

JR
* J-instruction that modifies PC
* PC <= PC + 4 || Pc <= addressJ
* decode logic for J-type
* overarching design


ADDU
* R-instruction that uses ALU
* register access (part of decode logic)
* ALU input logic (only registers)
* ALU control signal logic (part of decode logic)
* register write-back


ADDIU
* I-instruction that uses ALU
* register access (part of decode logic)
* ALU input logic(register immediate)
* ALU control signal logic (part of decode logic)
* egister write-back

LW
* R-instruction that uses Avalon memory (and goes through ALU)
* ALU stuff (3,7 are the shit you need)
* read AVALON stuff: PC <=/= PC+4 when waitrequest is high. Instead, the instruction is re-tried
* multiple reads can happen in a row(doesn't matter to us as we're not pipelining)
* readdata is updated 1 cycle after read instruction(when wait-request is 0 but as long as you're retrying instr when waitrequest is high, then it should be fine)
* register write-back


SW
* R-type that uses Avalon memory (and goes through ALU)
* register access (part of decode logic)
* ALU stuff (3,7 are the shit you need)
* store AVALON stuff: PC <=/= PC+4 when waitrequest is high. Instead, the instruction is re-tried
* multiple writes can happen in a row(doesn't matter to us as we're not pipelining)
* writing is a 1 cycle operation

JR (Long)\
ADDU, ADDIU (Kert,Lun)\
LW, SW (Angus, Jerry)\
\
\
inc. all task is fixing and understanding ALU\
