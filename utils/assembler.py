import os
import sys

opcodes = {'DIV'    : '000000',
           'DIVU'   : '000000',
           'ADDU'   : '000000',
           'AND'    : '000000',
           'JALR'   : '000000',
           'JR'     : '000000',
           'MFHI'   : '000000',
           'MFLO'   : '000000',
           'MTHI'   : '000000',
           'MTLO'   : '000000',
           'MULT'   : '000000',
           'MULTU'  : '000000',
           'OR'     : '000000',
           'SLL'    : '000000',
           'SLTU'   : '000000',
           'SRA'    : '000000',
           'SRAV'   : '000000',
           'SRL'    : '000000',
           'XOR'    : '000000',
           'SLLV'   : '000000',
           'SLT'    : '000000',
           'SRLV'   : '000000',
           'SUBU'   : '000000',
           'BLTZAL' : '000001',
           'BLTZ'   : '000001',
           'BGEZ'   : '000001',
           'BGEZAL' : '000001',
           'J'      : '000010',
           'JAL'    : '000011',
           'BEQ'    : '000100',
           'BNE'    : '000101',
           'BLEZ'   : '000110',
           'BGTZ'   : '000111',
           'ADDIU'  : '001001',
           'SLTI'   : '001010',
           'SLTIU'  : '001011',
           'ANDI'   : '001100',
           'ORI'    : '001101',
           'XORI'   : '001110',
           'LUI'    : '001111',
           'LB'     : '100000',
           'LH'     : '100001',
           'LWL'    : '100010',
           'LW'     : '100011',
           'LBU'    : '100100',
           'LHU'    : '100101',
           'LWR'    : '100110',
           'SB'     : '101000',
           'SH'     : '101001',
           'SW'     : '101011'
           }

funct_codes = {'SLL'   : '000000',
               'SRL'   : '000010',
               'SRA'   : '000011',
               'SLLV'  : '000100',
               'SRLV'  : '000110',
               'SRAV'  : '000111',
               'JR'    : '001000',
               'JALR'  : '001001',
               'MFHI'  : '010000',
               'MTHI'  : '010001',
               'MFLO'  : '010010',
               'MTLO'  : '010011',
               'MULT'  : '011000',
               'MULTU' : '011001',
               'DIV'   : '011010',
               'DIVU'  : '011011',
               'ADDU'  : '100001',
               'SUBU'  : '100011',
               'AND'   : '100100',
               'OR'    : '100101',
               'XOR'   : '100110',
               'SLT'   : '101010',
               'SLTU'  : '101011'
               }

br_z_codes = {'BGTZ'   : '00000', 
              'BLEZ'   : '00000',
              'BLTZ'   : '00000',
              'BGEZ'   : '00001',
              'BLTZAL' : '10000',
              'BGEZAL' : '10001'
              }

def to_bin(x, i):
    n = 0
    binary = ""
    while n < i:
        if x % 2 :
            binary = "1" + binary
        else:
            binary = "0" + binary
        x = int(x/2)
        n+=1
        print(x)
    return binary

def to_hex(asm_in, hex_out):
    
    asm_file = open(asm_in)
    hex_file = open(hex_out,'w')
    asm_input = asm_file.readlines()

    instructions = []
    
    for i,words in enumerate(asm_input):
        if i > 5:
            clean = [x.replace("$","").replace(",","") for x in words.split()]
            if len(clean) > 0:
                if clean[0] in opcodes:
                    instructions.append(clean)
    for words in instructions:
        opcode = opcodes[words[0]]
        if words[0] in ["ADDIU", "ANDI", "ORI", "SLTI", "SLTIU", "XORI"]:
            Rt = int(words[1])
            Rs = int(words[2])
            Imm = int(words[3])
            hex_instr = hex(int(opcode + to_bin(Rt, 5) + to_bin(Rs, 5) + to_bin(Imm, 16), 2))
        hex_instr = hex_instr.split("x")[-1].zfill(8)
        print(", ".join(words).ljust(20, " "), hex_instr)
        
for file in sys.argv[1]:
    if file.endswith(".asm.txt"):
        print(os.path.join(sys.argv[1], file))
        to_hex(os.path.join(sys.argv[1], file), os.path.join(sys.argv[2], file.replace('asm','hex')))

        
