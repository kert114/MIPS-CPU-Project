module mips_cpu_mult(
	input logic[31:0] a,
	input logic[31:0] b,
	input logic clk,
	input logic sign, 
	input logic reset,

	output logic[63:0] r
	);

	always_ff @(posedge clk) begin
		if(reset == 1) begin
			r <= 0;
		end
		else if(sign == 1) begin
			r = $signed(a) * $signed(b);
		end
		else begin
			r = $unsigned(a) * $unsigned(b);
		end 
	end
endmodule
//apparently * is easily synthesiable so I didn't do the mult logic thing here