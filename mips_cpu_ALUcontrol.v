module ALUcontrol(
	input logic[5:0] opcode,
	input logic[5:0] fnCode,
	input logic[5:0] shift,
	output logic[2:0] control,
	);
//generated correct a,b and sa 
//tells alu whether signed or unsigned

	always_comb begin
		case(opcode)
		0: begin //if R-type
			case (fnCode)
				6'b000000: //sll
				6'b000010: //srl
				6'b000011: //sra
				6'b000100: //sllv
				6'b000110: //srlv
				6'b000111: //srav 
				//6'b010000: //mfhi
				//6'b010000: //mthi
				//6'b010010: //mflo
				//6'b010011: //mtlo
				6'b011000: //mult
				6'b011001: //multu
				6'b011010: //div
				6'b011011: //divu
				//6'b100000: //add
				6'b100001: //addu
				//6'b100010: //sub
				6'b100011: //subu
				6'b100100: //and
				6'b100101: //or
				6'b100110: //xor
				6'b101010: //slt
				6'b101011: //sltu
				//something to output op1 for jr and jalr
			endcase // fnCode
		end
		9: //addiu
		10: //slti
		11: //sltiu
		12: //andi
		13: //ori
		14: //xori





//andi immediate is zero extended to the left
//takes opcode and fncode and tells ALU to do correctly