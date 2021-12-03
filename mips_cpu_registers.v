module mips_cpu_registers(
	input logic clk,
    input logic reset,

    input logic writeEnable,
    input logic[31:0] dataIn,
    input logic[4:0] writeAddress,

    input logic[4:0] readAddressA, //allows for potential to read and write to/from registers
    output logic[31:0] readDataA,

    input logic[4:0] readAddressB, //allows access to two separate registers at once.
    output logic[31:0] readDataB,

    output logic[31:0] register_v0 //for tb purporses
);

	logic[31:0] regs[31:0]; //32 registers of size 32

	assign register_v0 = (write && wrAddr == 2) ? wrData: Register[2]; //comb for tb
	
	integer i;
	always_ff @(posedge clk) begin
		if(reset == 1) begin
			for (i = 0; i < 32; i += 1) begin
				regs[i] <= 0;
			end
		end
		else if (writeEnable == 1) begin

			if (writeAddress == 0) begin
			end //don't overwrite reg0 cus it's 0 forever.
			else begin 
				regs[writeAddress] <= dataIn;
			end
		end
		else begin
			readDataA <= reset == 1 ? 0 : regs[readAddressA];
			readDataB <= reset == 1 ? 0 : regs[readAddressB]; 
		end
	end

endmodule : mips_cpu_registers