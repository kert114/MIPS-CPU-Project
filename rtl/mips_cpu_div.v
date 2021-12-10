module mips_cpu_div(
	input logic clk,
	input logic start,
	input logic[31:0] divisor,
	input logic[31:0] dividend,
	input logic reset,
	input logic sign,

	output logic[31:0] quotient,
    output logic[31:0] remainder,
    output logic done,
    output logic dbz // identical compared to divu
	);

	//wrapper for divu that sorts signs out because division makes me angry

	logic[31:0] dividendIn;
	logic[31:0] divisorIn;

	logic[31:0] quotientOut;
	logic[31:0] remainderOut;

	always @(*) begin
		if(sign == 1) begin
			dividendIn = (dividend[31] == 1) ? -dividend : dividend;
			divisorIn = (divisor[31] == 1) ? -divisor :divisor;

			quotient = (divisor[31]==dividend[31]) ? quotientOut : -quotientOut;
			remainder = (dividend[31] == 1) ? -remainderOut : remainderOut;
		end
		else begin
			dividendIn = dividend;
			divisorIn = divisor;

			quotient = quotientOut;
			remainder = remainderOut;
		end //sign == 0 means unsigned so everything just works fine
	end

	mips_cpu_divu div0(.clk(clk),
					  .start(start),
					  .reset(reset),
					  .done(done),
					  .dbz(dbz),
					  .quotient(quotientOut),
					  .remainder(remainderOut),
					  .dividend(dividendIn),
					  .divisor(divisorIn)
					  );

endmodule