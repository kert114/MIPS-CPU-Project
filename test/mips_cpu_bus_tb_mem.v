module mips_cpu_bus_tb_mem(
	input logic clk,
	input logic read,
	input logic write,

	input logic[3:0] byteenable,
	input logic[15:0] addr,
	input logic[31:0] writedata,

	output logic waitrequest,
	output logic[31:0] readdata
	);

	parameter RAM_INITIAL = ""; //sh generates a ram file for each test I think

	reg[7:0] memory[2047:0]; //don't know how large this would be
	
	initial begin
		interger i;
		for(i=0;i<2048;i++) begin
			memory[i] = 0;
		end
		waitrequest = 0;
		if(RAM_INITIAL != "") begin
			$readmemh(RAM_INITIAL, memory);
			$display("Loading initial RAM contents");
		end
	end

	always @(posedge clk) begin
		waitrequest = ($urandom_range(0,5) == 0) //random waitrequest with probability 20%
		if(write == 1 && read == 0) begin
			readdata <= 32'bx; //writing means we don't care about read data
			if(addr[1:0] != 2'b00) begin
				$fatal(1, "Writing to misaligned address");
			end

			if (byteenable[0] == 1) begin
				memory[addr] <= writedata[7:0];
			end
			if (byteenable[1] == 1) begin
				memory[addr+1] <= writedata[15:8];
			end
			if (byteenable[2] == 1) begin
				memory[addr+2] <= writedata[23:16];
			end
			if (byteenable[3] == 1) begin
				memory[addr+3] <= writedata[31:24];
			end

		end
		else if(read == 1 && write == 0) begin
			if(addr[1:0] != 2'b00) begin
				$fatal(1, "Reading from misaligned address");
			end

			readata[7:0] <= (byteenable[0] == 1) ? memory[addr] : 0;
			readata[15:8] <= (byteenable[1] == 1) ? memory[addr+1] : 0;
			readata[23:16] <= (byteenable[2] == 1) ? memory[addr+2] : 0;
			readata[31:24] <= (byteenable[3] == 1) ? memory[addr+3] : 0;

		end
		else begin
			readdata<=32'bx; //don't care what happens when not reading
		end
	end
endmodule : mips_cpu_bus_tb_mem
