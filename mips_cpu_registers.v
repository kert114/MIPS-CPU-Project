module mips_cpu_registers(
	input logic clk,
    input logic reset,

    input logic w.en,
    input logic[31:0] d.in,
    input logic w.addr,

    input logic r.addrA, //allows for potential to read and write to/from registers
    output logic[31:0] r.dataA,

    input logic r.addrB, //allows access to two separate registers at once.
    output logic[31:0] r.dataB,

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
		else if (w.en == 1) begin
			if (w.addr == 0) begin
			end //don't overwrite reg0 cus it's 0 forever.
			reg[w.addr] <= d.in;
		end
		else begin
			r.dataA <= reset == 1 ? 0 : reg[r.addrA];
			r.dataB <= reset == 1 ? 0 : reg[r.addrB]; 
		end
	end

endmodule : mips_cpu_registers