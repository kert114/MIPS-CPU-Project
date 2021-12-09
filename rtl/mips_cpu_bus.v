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

	/*---Comb Decode---*/
	logic[31:0] instruction;
    logic[5:0] instrOp = instruction[31:26]; //R,I,J
    logic[4:0] instrS1 = instruction[25:21]; //R,I
    logic[4:0] instrS2 = instruction[20:16]; //R,I (note for I, source2 also refered as dest sometimes maybe)
    logic[4:0] instrD = instruction[15:11]; //R
    logic[4:0] instrShift = instruction[10:6]; //R
    logic[5:0] instrFn = instruction[5:0]; //R
    logic[15:0] instrImmI = instruction[15:0]; //I
    logic[25:0] instrAddrJ = instruction[25:0]; //J
    /*---*/

    /*----Memory combinational things-------------------*/
    assign write = (state == S_MEMORY && (instrOp == OP_SW || instrOp == OP_SH || instrOp == OP_SB)); //add SH and SB later
    assign writedata = (instrOp == OP_SW) ? registerReadB : 32'h00000000; //placeholder logic for SH and SB later
    
    assign read = (state == S_FETCH) ? 1:
                  (state == S_MEMORY && (instrOp == OP_LH || instrOp == OP_SH) && AluOut[0] = 2'b0) ? 1:
                  (state == S_MEMORY && instrOp == OP_LW || AluOut[1:0] == 2'b00) ? 1:
                  (state == S_MEMORY && (instrOp == OP_LWL || instrOp == OP_LWR)) ? 1:
                  (state == S_MEMORY && (instrOp == OP_LB || instrOp == OP_LBU)) ? 1:0;


    logic[31:0] addressemp;
    assign addressTemp = (state == S_FETCH) ? progCount : AluOut;
    assign address = {addressTemp[31:2], 2b'00}; //uses ALU to compute instrSource1 + instrImmI
    // ^ setting address to read from to be what's dictated by the instruction
    logic[3:0] bytemappingB; //bytemapping byte
    assign bytemappingB = (addressTemp[1:0] == 2'b00) ? 4'b0001 :
                          (addressTemp[1:0] == 2'b01) ? 4'b0010 :
                          (addressTemp[1:0] == 2'b10) ? 4'b0100 :
                          (addressTemp[1:0] == 2'b11) ? 4'b1000 : 4'b0000;

    logic[3:0] bytemappingLWL; //byte mapping word left
    assign bytemappingLWL = (addressTemp[1:0] == 2'b00) ? 4'b0001 :
                            (addressTemp[1:0] == 2'b01) ? 4'b0011 :
                            (addressTemp[1:0] == 2'b10) ? 4'b0111 :
                            (addressTemp[1:0] == 2'b11) ? 4'b1111 : 4'b0000;

    logic[3:0] bytemappingLWR; //byte mapping word right
    assign bytemappingLWR = (addressTemp[1:0] == 2'b00) ? 4'b1111 :
                            (addressTemp[1:0] == 2'b01) ? 4'b110 :
                            (addressTemp[1:0] == 2'b10) ? 4'b1100 :
                            (addressTemp[1:0] == 2'b11) ? 4'b1000 : 4'b0000;

    logic[3:0] bytemappingH; //byte mapping half
    assign bytemappingH = (addressTemp[1:0] == 2'b01) ? 4'b0011 :
                          (addressTemp[1:0] == 2'b10) ? 4'b1100 : 4'b0000;




    assign byteenable = (state == S_FETCH) ? 4'b1111 :
                        (state == S_MEMORY && (instrOp == OP_LW || instrOp == OP_SW) && addressTemp[1:0] == 2'b00) ? 4'b1111:
                        (state == S_MEMORY && instrOp == OP_LWL) ? bytemappingLWL:
                        (state == S_MEMORY && instrOp == OP_LWL) ? bytemappingLWR:
                        (state == S_MEMORY && (instrOp == OP_LB || instrOp == OP_LBU || instrOp == OP_SB)) ? bytemappingB:
                        (state == S_MEMORY && (instrOp == OP_LH || instrOp == OP_LHU || instrOp == OP_SH)) ? bytemappingH: 4'b0000;
    /*---*/

    /*---ALU things---*/
    logic [3:0] AluControl;
    logic[31:0] AluA;
    logic[31:0] AluB;
    logic[31:0] AluOut;
    logic AluZero;
    logic[4:0] shiftAmount;

    mips_cpu_ALU ALU0(.reset(reset),.clk(clk),.control(AluControl),
    				  .a(AluA),.b(AluB),.sa(shiftAmount),
    				  .r(AluOut),.zero(AluZero));
    /*---*/

    /*---Mult things---*/
    logic [63:0] multOut;
    logic multSign;
    assign multSign = (instrOp == OPCODE_R && R_instr_func == FUNC_MULT) ? 1'b1:1'b0;
    mips_cpu_mult MULT0 (.a(registerReadA), .b(registerReadB),.r(multOut),.reset(reset),.clk(clk),.sign(multSign))
    /*---*/

    /*---Div things---*/
    logic divStart, divDone, divDBZ, divSign;
    logic [31:0] divQuotient, divRemainder;

    assign divStart = (state == EXEC && instrOp == OP_R && (instrFn == FN_DIV ||instrFn == FN_DIVU))
    assign divSign = (instrOp == OP_R && instrFn == FN_DIV) ? 1'b1; 1'b0;
    //comb logic so that divstart can be 0 without needing to specify

    mips_cpu_div DIV0(.reset(reset),.clk(clk),.start(divStart),
    					  .done(divDone),.dbz(divDBZ),.reset(reset),
    				      .dividend(registerReadA),.divisor(registerReadB),
    				      .quotient(divQuotient),.remainder(divRemainder)
    				      .sign(divSign));
    /*---*/

    /*---Register0-31+HI+LO+progCountS---*/
    logic registerWriteEnable;
    logic[31:0] registerDataIn;
    logic[4:0] registerWriteAddress;
    logic[4:0] registerAddressA;
    logic[31:0] registerReadA;
    logic[4:0] registerAddressB;
    logic[31:0] registerReadB;  

    mips_cpu_registers REGS0(.reset(reset),.clk(clk),.writeEnable(registerWriteEnable),
    						 .dataIn(registerDataIn),.writeAddress(registerWriteAddress),
    						 .readAddressA(registerAddressA),.readDataA(registerReadA),
    						 .readAddressB(registerAddressB),.readDataB(registerReadB),
    						 .register_v0(register_v0));
    
    logic[31:0] registerHi;
    logic[31:0] registerLo;
    /*---*/

    /*---Program Counter---*/
    logic[31:0] progCount;
    logic[31:0] progTemp;
    logic[31:0] progNext;
    assign progNext = progCount + 4; //this is for J-type jumps as we need to get the value correct
    /*---*/

    /*---State------------*/
    logic[2:0] state;
    /*---*/


    /*---Jump controls---*/
    logic[1:0] branch; //0 = normal, 1 = jump instr current, 2 = previous instr jump
    /*---*/

    typedef enum logic[5:0] {
        OP_R_TYPE = 6'b000000,

        OP_REGIMM = 6'b000001,

        OP_J      = 6'b000010,
        OP_JAL    = 6'b000011,

        OP_BEQ    = 6'b000100,
        OP_BNE    = 6'b000101,
        OP_BLEZ   = 6'b000110,
        OP_BGTZ   = 6'b000111,
        OP_SLTI   = 6'b001010,
        OP_SLTIU  = 6'b001011,

        OP_ADDIU  = 6'b001001,
        OP_ANDI   = 6'b001100,
        OP_ORI    = 6'b001101,
        OP_XORI   = 6'b001110,

        OP_LUI    = 6'b001111,
        OP_LB     = 6'b100000,
        OP_LH     = 6'b100001,
        OP_LWL    = 6'b100010,
        OP_LW     = 6'b100011,
        OP_LBU    = 6'b100100,
        OP_LHU    = 6'b100101,
        OP_LWR    = 6'b100110,

        OP_SB     = 6'b101000,
        OP_SH     = 6'b101001,
        OP_SW     = 6'b101011
    } typeOpCode; 

    typedef enum logic[5:0] {
    	FN_SLL   = 6'b000000,
        FN_SRL   = 6'b000010,
        FN_SRA   = 6'b000011,
        FN_SLLV  = 6'b000100,
        FN_SRLV  = 6'b000110,
        FN_SRAV  = 6'b000111,

        FN_JR    = 6'b001000,
        FN_JALR  = 6'b001001,

        FN_MFHI  = 6'b010000,
        FN_MTHI  = 6'b010001,
        FN_MFLO  = 6'b010010,
        FN_MTLO  = 6'b010011,

        FN_MULT  = 6'b011000,
        FN_MULTU = 6'b011001,
        FN_DIV   = 6'b011010,
        FN_DIVU  = 6'b011011,

        FN_ADDU  = 6'b100001,
        FN_SUBU  = 6'b100011,
        FN_AND   = 6'b100100,
        FN_OR    = 6'b100101,
        FN_XOR   = 6'b100110,

        FN_SLT   = 6'b101010,
        FN_SLTU  = 6'b101011,
    } typeFnCode;

    typedef enum logic[3:0] {
    	ALU_AND    = 4'b0000,
    	ALU_OR     = 4'b0001,
    	ALU_XOR    = 4'b0010,
    	ALU_LOW    = 4'b0011,
    	ALU_ADD    = 4'b0100,
    	ALU_SUB    = 4'b0101,
    	ALU_SLTU   = 4'b0110,
    	ALU_A      = 4'b0111,
    	ALU_SLL    = 4'b1000,
    	ALU_SRL    = 4'b1001,
    	ALU_SLLV   = 4'b1010,
    	ALU_SRLV   = 4'b1011,
    	ALU_SRA    = 4'b1100,
    	ALU_SRAV   = 4'b1101,
    	ALU_SLT    = 4'b1110,
    	ALU_DEFAULT = 4'b1111
    } typeALUOp;

    typedef enum logic[2:0] {
       	S_FETCH = 3'b000,
        S_DECODE = 3'b001,
        S_EXECUTE = 3'b010,
        S_MEMORY = 3'b011,
        S_WRITEBACK = 3'b100,
        S_HALTED = 3'b111
    } typeState; //type declaration for the CPU states

         //normally progTemp = progCount + 4;
         //but when JR=1 progTemp = value of register A;

         //progCount <-- progTemp
        //5 cycle CPU: Fetch, Decode, Execute,Memory,W.B
        //CPU has 6 states, 5 cycles + HALT

    always @(posedge clk) begin
        if (reset == 1) begin
            progCount <=32'hBFC00000;
            progTemp <= 32'd0;
            registerHi <= 0;
            registerHi <= 0;
            branch <= 0;
            registerDataIn <= 0; //don't know if this is necessary but might as well right
            //other things as well
            reset <=1;
            state <= S_FETCH;
        end
        else if(state == S_FETCH) begin
        	$display("---FETCH---");
        	if(address == 32'h00000000) begin
        		active <= 0;
        		state <= S_HALTED;
        	end
        	else if(waitrequest) begin
        	end//if waitrequest = 1, keep waiting
        	else begin
        		state <= S_DECODE;
        	end
        	registerWriteEnable <= 0; //make sure register isn't writing (W.B sets it to 1)
        end
        else if(state == S_DECODE) begin
            $display("---DECODE---");
        	instruction <=readdata;
        	registerAddressA <= instrS1;
        	registerAddressB <= instrS2; //decode comb logic above

            AluControl <= (instrOp == OP_ADDIU  || instrOp == OP_LW)    ? ALU_ADD :
            		      (instrOp == OP_R_TYPE || instrOp == FN_ADDU)  ? ALU_ADD : ALU_DEFAULT;

            if(instrOp == OP_R_TYPE) begin
            	AluControl <= (instrOp == FN_SLL)  ? ALU_SLL  :
        					  (instrOp == FN_SRL)  ? ALU_SRL  :
        					  (instrOp == FN_SRA)  ? ALU_SRA  :
        					  (instrOp == FN_SLLV) ? ALU_SLLV :
        					  (instrOp == FN_SRLV) ? ALU_SRLV :
        					  (instrOp == FN_SRAV) ? ALU_SRAV :
        					  (instrOp == FN_MFHI) ? ALU_ADD  :
        					  (instrOp == FN_MTHI) ? ALU_ADD  :
        					  (instrOp == FN_ADDU) ? ALU_ADD  :
        					  (instrOp == FN_SUBU) ? ALU_SUB  :
        					  (instrOp == FN_AND)  ? ALU_AND  :
        					  (instrOp == FN_OR)   ? ALU_OR   :
        					  (instrOp == FN_XOR)  ? ALU_XOR  :
        					  (instrOp == FN_SLT)  ? ALU_SLT  :
        					  (instrOp == FN_SLTU) ? ALU_SLTU : ALU_DEFAULT;
            end
            else begin
            	(instrOp == OP_REGIMM) ? ALU_A    :
        		(instrOp == OP_BEQ)    ? ALU_SUB  :
        		(instrOp == OP_BNE)    ? ALU_SUB  :
        		(instrOp == OP_BLEZ)   ? ALU_A    :
        		(instrOp == OP_BGTZ)   ? ALU_A    :
        		(instrOp == OP_SLTI)   ? ALU_SLT  :
        		(instrOp == OP_SLTIU)  ? ALU_SLTU :
        		(instrOp == OP_ADDIU)  ? ALU_ADD  :
        		(instrOp == OP_ANDI)   ? ALU_AND  :
        		(instrOp == OP_ORI)    ? ALU_OR   :
        		(instrOp == OP_XORI)   ? ALU_XOR  :
        		(instrOp == OP_LUI)    ? ALU_ADD  :
        		(instrOp == OP_LB)     ? ALU_ADD  :
        		(instrOp == OP_LH)     ? ALU_ADD  :
        		(instrOp == OP_LWL)    ? ALU_ADD  :
        		(instrOp == OP_LW)     ? ALU_ADD  :
        		(instrOp == OP_LBU)    ? ALU_ADD  :
        		(instrOp == OP_LHU)    ? ALU_ADD  :
        		(instrOp == OP_LWR)    ? ALU_ADD  :
        		(instrOp == OP_SB)     ? ALU_ADD  :
        		(instrOp == OP_SH)     ? ALU_ADD  :
        		(instrOp == OP_SW)     ? ALU_ADD  : ALU_DEFAULT
            end

            state <= S_EXECUTE;
        end
        else if(state == S_EXECUTE) begin
        	$display("---EXEC---")

        	if(instrOp == OP_R_TYPE) begin
        		if(instrFn == FN_JR || instrFn == FN_JALR) begin
                    branch <= 1;
                    progTemp <=registerReadA;
                end
        		AluA <= registerReadA;
        		AluB <=registerReadB;
        		shiftAmount <= instrShift;
        	end
        	else if(instrOp == OP_J || instrOp == OP_JAL) begin
                branch <= 1;
                progTemp <= {progNext[31:28],instrAddrJ << 2'd00};
            end
        	else begin
        		AluA <= registerReadA;
        		AluB <= {{16{instrImmI[15]}} , instrImmI};
        		shiftAmount <= 0;
        	end

        	state <= S_MEMORY
        end
        else if(state == S_MEMORY) begin
        	//some logic to check if execute is done for multicycle executes (don't know what tho)
        	if (waitrequest == 1) begin
        	end
        	else if(DivDone == 0 && instrOp	== OP_R_TYPE && (instrFn == FN_DIVU || instrFn == FN_DIV)) begin
        	end
        	else begin
        		state <= S_MEMORY
        	end

        	//branch logic here
        	if(instrOp == OP_BEQ && AluZero) begin
                branch <= 1;
                PC_temp <= progNext + {{14{instrImmI[15]}},instrImmI, 2'd0};
            end
            else if(instrOp == OP_BNE && !AluZero) begin
                branch <= 1;
                PC_temp <= progNext + {{14{instrImmI[15]}},instrImmI, 2'd0};
            end
            else if(instrOp == OP_BGTZ && AluOut[31] == 0 && !AluZero) begin
                branch <= 1;
                PC_temp <= progNext + {{14{instrImmI[15]}},instrImmI, 2'd0};
            end
            else if(instrOp == OP_BLEZ && (AluOut[31] == 1 || AluZero)) begin
                branch <= 1;
                PC_temp <= progNext + {{14{instrImmI[15]}},instrImmI, 2'd0};
            end
            else if(instrOp == OP_REGIMM) begin
            	//need to fill in logic here
            end

        	//make sure avalon is avaliable before starting
        	//write is already taken care of in the comb logic written above I think?
            //(maybe additonal criteria for pauses but not sure yet)
            //branches will occur here I think?(BNE,BGTZ,BLEZ)
            //moves --> WriteBack
        end
        else if(state == S_WRITEBACK) begin

        	registerWriteEnable <= (instrOp == OP_R_TYPE && (instrFn == FN_ADDU || instrFn == FN_JALR
        																	    || (0))//placeholder
        						    || instrOp == OP_JAL
        						    || instrOp == OP_ADDIU
        						    || instrOp == OP_LW
        							|| (0)); //placeholder

        	registerWriteAddress <= (instrOp == OP_JAL)    ? 5'd31 :
        							(instrOp == OP_R_TYPE) ? instrD: instrS2;

        	
            registerDataIn <= (instrOp == OP_JAL)                          ? progCount + 8:
                              (instrOp == OP_R_TYPE && instrFn == FN_JALR) ? progCount + 8: AluOut;



    		if(instrOp == OP_R_TYPE) begin
                registerHi <= (instrFn == FN_MULT || instrFn == FN_MULTU) ? multOut[63:32] :
                              (instrFn == FN_DIV || instrFn == FN_DIVU)   ? divRemainder :
                              (instrFn == FN_MTHI)                        ? AluOut : registerHi;


                registerLo <= (instrFn == FN_MULT || instrFn == FN_MULTU) ? multOut[31:0] :
                              (instrFn == FN_DIV || instrFn == FN_DIVU)   ? divQuotient :
                              (instrFn == FN_MTHI)                        ? AluOut : registerLo;
            end //Hi, Lo register logic here

            //write to registers
            //mthi and mtlo also happens here
            //PC updates here depending on normal,jump or branch
            state <= S_FETCH;

        	/*---ProgramCounter stuff---*/
        	if(branch == 1) begin
        		branch <= 2;
            	progCount <= progNext;
        	end
        	else if(branch == 2) begin
        		branch <= 0;
        		progCount <= progTemp;
        	end
        	else begin
        		branch <= 0; //just to be sure lol
            	progCount <= progNext;
        	end
        	/*---*/
    	end

    	else if(state == S_HALTED) begin
        	$display("Halted kekw");
        end
    end
endmodule : mips_cpu_bus


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
*/
// /rtl/mips_cpu/*.v
/*
/test/test_mips_cpu_bus.sh
/docs/mips_data_sheet.pdf:
        Overall architecture,
        >=1 diagram,
        Design decisions,
        Approach in testing,
        >=1 diagram/flowchart descibing testing,
        MU0 area+timing summary
*/
