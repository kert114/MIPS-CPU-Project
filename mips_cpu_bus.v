module mips_cpu_bus(
    /* Standard signals */
    input logic clk,
    input logic reset, //sync to clk, must be active for 1 cycle
    output logic active, //when CPU poggywoggy, active = 1
    output logic[31:0] register_v0, //final value of $v0 (ie: reg2). (Only for testing purposes)

    /* Avalon memory mapped bus controller (master) */
    output logic[31:0] address,
    output logic write, // <-- write request
    output logic read, // <-- read request
    input logic waitrequest, //indicates stall cycle (ie:  read or write request cannot complete in the current cycle)
    output logic[31:0] writedata,
    output logic[3:0] byteenable,
    input logic[31:0] readdata //not avaliable until cycle following read request
);
        logic[31:0] instr; //todo: get instr from avalon thing

        logic[5:0] opcode = instr[31:26]; //R,I,J
        logic[5:0] source1 = instr[25:21]; //R,I
        logic[5:0] source2 = instr[20:16]; //R,I (note for I, source2 also refered as dest sometimes maybe)
        logic[5:0] dest = instr[15:11]; //R
        logic[5:0] shift = instr[10:6]; //R
        logic[5:0] fnCode = instr[5:0]; //R
        logic[15:0] addressI = instr[15:0]; //I
        logic[25:0] addressJ = instr[25:0]; //J

        typedef enum logic[5:0] {
            opcodeJR = 6'b000000,
            opcodeADDU = 6'b000000,
            opcodeADDIU = 6'b001001,
            opcodeLW = 6'b100011,
            opcodeSW = 6'b101011,
        } typeOpcode; //type declaration of a decoder (need to be redone for big CPU)

        logic[31:0] progCount;
        //logic[31:0] progCountTemp; (design choice lol)

        //5 cycle CPU: Fetch, Decode, Execute,Memory,W.B
        //CPU has 6 states, 5 cycles + HALT

        always @(posedge clk) begin
            if (reset == 1) begin
                PC <=32'hBFC00000;
                //other things as well
            end
            else if(Fetch) begin
                //PC --> Avalon
                //CPU must pause until waitrequest = 0
                //moves --> decode
            end
            else if(Decode) begin
                //data --> comb logic --> decoded stuff
                //honestly, if it's comb logic, we can just put the decoder on this sheet
                //ALU control gets set in this cycle
                //sets to 1111 (default) when ALU is not used
                //moves --> execute
            end
            else if(Execute) begin
                //Jumps will occur here (J,JAL,JR,JAlR)
                //moves --> Memory
            end
            else if(Memory) begin
                //says in this state until waitrequest = 0
                //(maybe additonal criteria for pauses but not sure yet)
                //branches will occur here I think?(BNE,BGTZ,BLEZ)
                //moves --> WriteBack
            end
            else if(WriteBack) begin
                //write to registers
                //mthi and mtlo also happens here
                //PC updates here depending on normal,jump or branch
            end
            else if(halted) begin
                //halted
                //PC stays perpetually the same
                //nothing happens
                //add some $display to show it when testing I guess?
            end




        //32'hBFC00000 is progCount on reset
        //32'h00000000 should cause a halt


//IR register on CPU sheet
//PC register on CPU sheet
//Get avalon working

//depending on R,I,J, split up instr:
/*
R:opcode[31:26]|source1[25:21]|source2[20:16]|Dest.[15:11]|Shift amt[10:6]|Fn code[5:0] => 0
I:opcode[31:26]|source1[25:21]|source2/Dest.[20:16]|Address/Data[15:0] => else:
J:opcode[31:26]|Address[25:0] => 2,3
*/



/*
32 registers within CPU
2 (hi,lo) registers within ALU 
1 PC register?
Do JR, ADDU, ADDIU, LW, SW first
max CPI of 36

/rtl/mips_cpu_bus.v
/rtl/mips_cpu/*.v
/test/test_mips_cpu_bus.sh
/docs/mips_data_sheet.pdf:
        Overall architecture,
        >=1 diagram,
        Design decisions,
        Approach in testing,
        >=1 diagram/flowchart descibing testing,
        MU0 area+timing summary
*/