module mips_cpu_bus_tb_mem(
	input logic clk,
	input logic read,
	input logic write,

	input logic[3:0] byteenable,
	input logic[31:0] addr,
	input logic[31:0] writedata,

	input logic waitrequest,
	output logic[31:0] readdata
	);

	parameter RAM_FILE = ""; //sh generates a ram file for each test I think

	reg[7:0] memory[2047:0]; //don't know how large this would be
	logic [10:0] tempaddress;
	logic dontread;
	
	initial begin
		integer i;
		for(i=0;i<2048;i++) begin
			memory[i] = 0;
		end
		if(RAM_FILE != "") begin
			$readmemh(RAM_FILE, memory, 0, 2047);
			$display("Loading initial RAM contents");
		end
		dontread = 0;
	end

	always @(posedge clk) begin
		$display("waitreq = %d", waitrequest);
		if(read == 1 && waitrequest == 0 && dontread == 0) begin
			
			if(addr[1:0] != 2'b00) begin
				$fatal(1, "Reading from misaligned address");
			end

			
			tempaddress <= (addr % 2048);
			$display("addr is %d", addr);
			$display("temp addr is %d, %d, %d, %d", tempaddress, tempaddress+1, tempaddress+2, tempaddress+3);
			$display("memory is %h, %h, %h, %h",  memory[tempaddress], memory[tempaddress+1], memory[tempaddress+2], memory[tempaddress+3]);

			readdata[31:24] <= (byteenable[0] == 1) ? memory[tempaddress] : 0;
			readdata[23:16] <= (byteenable[1] == 1) ? memory[tempaddress+1] : 0;
			readdata[15:8] <= (byteenable[2] == 1) ? memory[tempaddress+2] : 0;
			readdata[7:0] <= (byteenable[3] == 1) ? memory[tempaddress+3] : 0;
		end
		else if(read == 1 && waitrequest == 0 && dontread == 1) begin
			dontread = 1;
		end
		else if(write == 1 && waitrequest == 0) begin
			//readdata <= 32'bx; //writing means we don't care about read data
			if(addr[1:0] != 2'b00) begin
				$fatal(1, "Writing to misaligned address");
			end
			
			tempaddress <= (addr % 2048);
			$display("addr is %d", addr);
			$display("temp addr is %d, %d, %d, %d", tempaddress, tempaddress+1, tempaddress+2, tempaddress+3);
			$display("memory is %h, %h, %h, %h",  memory[tempaddress], memory[tempaddress+1], memory[tempaddress+2], memory[tempaddress+3]);

			if (byteenable[0] == 1) begin
				memory[tempaddress] <= writedata[31:24];
			end
			if (byteenable[1] == 1) begin
				memory[tempaddress+1] <= writedata[23:16];
			end
			if (byteenable[2] == 1) begin
				memory[tempaddress+2] <= writedata[15:8];
			end
			if (byteenable[3] == 1) begin
				memory[tempaddress+3] <= writedata[7:0];
			end

		end
		
		else begin
			readdata<=32'bx; //don't care what happens when not reading
		end
	end
	always @(negedge waitrequest) begin
		if(read) begin
			tempaddress <= (addr % 2048);
			$display("addr is %d", addr);
			$display("temp addr is %d, %d, %d, %d", tempaddress, tempaddress+1, tempaddress+2, tempaddress+3);
			$display("memory is %h, %h, %h, %h",  memory[tempaddress], memory[tempaddress+1], memory[tempaddress+2], memory[tempaddress+3]);

			readdata[31:24] <= (byteenable[0] == 1) ? memory[tempaddress] : 0;
			readdata[23:16] <= (byteenable[1] == 1) ? memory[tempaddress+1] : 0;
			readdata[15:8] <= (byteenable[2] == 1) ? memory[tempaddress+2] : 0;
			readdata[7:0] <= (byteenable[3] == 1) ? memory[tempaddress+3] : 0;
			dontread = 1;
		end
	end
endmodule
