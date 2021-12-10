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

    assign register_v0 = (writeEnable && writeAddress == 2) ? dataIn : regs[2];
    assign readDataA = reset ? 0 : regs[readAddressA];
    assign readDataB = reset ? 0 : regs[readAddressB];


	integer i;
	always @(posedge clk) begin //no _ff so i can use $display
		if(reset == 1) begin
			for (i = 0; i < 32; i += 1) begin
				regs[i] <= 0;
			end
            $display("!!REGISTER RESET");
		end
        else if (writeEnable == 1 && writeAddress != 0) begin
            $display("!! REG %d is being written with data %h", writeAddress, dataIn);
            regs[writeAddress] <= dataIn;
        end
	end

endmodule : mips_cpu_registers